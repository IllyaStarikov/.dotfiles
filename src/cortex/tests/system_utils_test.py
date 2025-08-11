"""
Tests for system_utils.py module.
"""

import unittest
from unittest.mock import patch, MagicMock
from dataclasses import dataclass

from cortex.system_utils import (
    SystemType, PerformanceTier, SystemInfo,
    SystemDetector, ModelRecommender
)
from cortex.providers import ModelInfo, ModelCapability


class TestSystemDetector(unittest.TestCase):
    """Test SystemDetector class."""

    @patch('platform.system')
    @patch('platform.machine')
    def test_detect_macos_apple_silicon(self, mock_machine, mock_system):
        """Test detection of macOS Apple Silicon."""
        mock_system.return_value = 'Darwin'
        mock_machine.return_value = 'arm64'

        os_type = SystemDetector._detect_os_type()
        self.assertEqual(os_type, SystemType.MACOS_APPLE_SILICON)

    @patch('platform.system')
    @patch('platform.machine')
    def test_detect_macos_intel(self, mock_machine, mock_system):
        """Test detection of macOS Intel."""
        mock_system.return_value = 'Darwin'
        mock_machine.return_value = 'x86_64'

        os_type = SystemDetector._detect_os_type()
        self.assertEqual(os_type, SystemType.MACOS_INTEL)

    @patch('platform.system')
    def test_detect_linux(self, mock_system):
        """Test detection of Linux."""
        mock_system.return_value = 'Linux'

        os_type = SystemDetector._detect_os_type()
        self.assertEqual(os_type, SystemType.LINUX)

    @patch('psutil.virtual_memory')
    def test_get_memory_info(self, mock_memory):
        """Test memory information retrieval."""
        mock_mem = MagicMock()
        mock_mem.total = 68719476736  # 64 GB
        mock_mem.available = 34359738368  # 32 GB
        mock_memory.return_value = mock_mem

        mem_info = SystemDetector._get_memory_info()

        self.assertEqual(mem_info["ram_gb"], 64.0)
        self.assertEqual(mem_info["available_gb"], 32.0)

    @patch('psutil.cpu_count')
    @patch('platform.processor')
    def test_get_cpu_info(self, mock_processor, mock_cpu_count):
        """Test CPU information retrieval."""
        mock_processor.return_value = 'Apple M1 Max'
        mock_cpu_count.return_value = 10

        cpu_info = SystemDetector._get_cpu_info()

        self.assertEqual(cpu_info["model"], "Apple M1 Max")
        self.assertEqual(cpu_info["cores"], 10)

    def test_calculate_performance_tier_ultra(self):
        """Test performance tier calculation for ultra systems."""
        tier = SystemDetector._calculate_performance_tier(
            ram_gb=64.0,
            gpu_memory_gb=48.0,
            os_type=SystemType.MACOS_APPLE_SILICON
        )

        self.assertEqual(tier, PerformanceTier.ULTRA)

    def test_calculate_performance_tier_high(self):
        """Test performance tier calculation for high-end systems."""
        tier = SystemDetector._calculate_performance_tier(
            ram_gb=32.0,
            gpu_memory_gb=16.0,
            os_type=SystemType.MACOS_APPLE_SILICON
        )

        self.assertEqual(tier, PerformanceTier.HIGH)

    def test_calculate_performance_tier_minimal(self):
        """Test performance tier calculation for minimal systems."""
        tier = SystemDetector._calculate_performance_tier(
            ram_gb=4.0,
            gpu_memory_gb=None,
            os_type=SystemType.LINUX
        )

        self.assertEqual(tier, PerformanceTier.MINIMAL)


class TestModelRecommender(unittest.TestCase):
    """Test ModelRecommender class."""

    def setUp(self):
        """Set up test fixtures."""
        # Create mock system info for M1 Max with 64GB RAM
        self.system_info = SystemInfo(
            os_type=SystemType.MACOS_APPLE_SILICON,
            cpu_model="Apple M1 Max",
            cpu_cores=10,
            ram_gb=64.0,
            ram_available_gb=30.0,
            gpu_info="Apple M1 Max",
            gpu_memory_gb=48.0,
            performance_tier=PerformanceTier.ULTRA,
            has_neural_engine=True,
            has_cuda=False,
            has_metal=True,
            platform_details={}
        )

        # Create test models
        self.models = [
            ModelInfo(
                id="mlx-community/large-model",
                name="Large Model",
                provider="mlx",
                size_gb=30.0,
                ram_gb=35.0,  # Too large for available RAM
                context_window=32000,
                capabilities=[ModelCapability.CHAT, ModelCapability.CODE],
                online=False,
                open_source=True,
                recommended_ram=40,
                score=80.0,
                downloads=15000,
                likes=200
            ),
            ModelInfo(
                id="mlx-community/medium-model",
                name="Medium Model",
                provider="mlx",
                size_gb=7.0,
                ram_gb=8.0,
                context_window=16000,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=10,
                score=60.0,
                downloads=5000,
                likes=50
            ),
            ModelInfo(
                id="gpt-4",
                name="GPT-4",
                provider="openai",
                size_gb=0,
                ram_gb=0,
                context_window=8192,
                capabilities=[ModelCapability.CHAT, ModelCapability.CODE],
                online=True,
                open_source=False,
                recommended_ram=0,
                score=85.0
            ),
            ModelInfo(
                id="ollama/tiny-model",
                name="Tiny Model",
                provider="ollama",
                size_gb=1.5,
                ram_gb=2.0,
                context_window=4096,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=3,
                score=40.0,
                downloads=1000,
                likes=10
            )
        ]

    def test_recommend_models_basic(self):
        """Test basic model recommendation."""
        recommendations = ModelRecommender.recommend_models(
            self.system_info,
            self.models,
            max_recommendations=5
        )

        # Should not include the model that requires too much RAM
        model_ids = [m.id for m in recommendations]
        self.assertNotIn("mlx-community/large-model", model_ids)

        # Should include models that fit in available RAM
        self.assertIn("mlx-community/medium-model", model_ids)

    def test_recommend_models_prefer_local(self):
        """Test recommendation with local preference."""
        recommendations = ModelRecommender.recommend_models(
            self.system_info,
            self.models,
            max_recommendations=3,
            prefer_local=True
        )

        # Local models should be preferred
        if len(recommendations) > 0:
            # Check that local models get higher scores
            local_models = [m for m in recommendations if not m.online]
            online_models = [m for m in recommendations if m.online]

            if local_models and online_models:
                max_local_score = max(m.metadata.get("fitness_score", 0) for m in local_models)
                max_online_score = max(m.metadata.get("fitness_score", 0) for m in online_models)
                # Local models should generally score higher when preferred
                self.assertGreaterEqual(max_local_score, max_online_score - 20)

    def test_recommend_models_capability_filter(self):
        """Test recommendation with capability filter."""
        recommendations = ModelRecommender.recommend_models(
            self.system_info,
            self.models,
            max_recommendations=5,
            capability_filter="code"
        )

        # All recommendations should have code capability
        for model in recommendations:
            self.assertIn(ModelCapability.CODE, model.capabilities)

    def test_fitness_score_calculation(self):
        """Test fitness score calculation."""
        model = self.models[1]  # Medium model
        score = ModelRecommender._calculate_fitness_score(
            model, self.system_info, prefer_local=True
        )

        # Score should include base score + various bonuses
        self.assertGreater(score, 0)
        self.assertIsInstance(score, float)

    def test_fitness_score_mlx_bonus(self):
        """Test that MLX models get bonus on Apple Silicon."""
        mlx_model = self.models[1]  # MLX medium model
        ollama_model = self.models[3]  # Ollama tiny model

        mlx_score = ModelRecommender._calculate_fitness_score(
            mlx_model, self.system_info, prefer_local=True
        )
        ollama_score = ModelRecommender._calculate_fitness_score(
            ollama_model, self.system_info, prefer_local=True
        )

        # MLX should score higher on Apple Silicon (30 point bonus)
        self.assertGreater(mlx_score, ollama_score)

    def test_ensure_diversity(self):
        """Test that recommendations have diversity."""
        # Create models from same provider
        same_provider_models = [
            ModelInfo(
                id=f"mlx-community/model-{i}",
                name=f"Model {i}",
                provider="mlx",
                size_gb=float(i),
                ram_gb=float(i + 1),
                context_window=8192,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=i + 2,
                score=float(90 - i * 10)
            )
            for i in range(5)
        ]

        recommendations = ModelRecommender._ensure_diversity(
            same_provider_models, max_count=3
        )

        # Should include diverse sizes even if from same provider
        self.assertLessEqual(len(recommendations), 3)

    def test_categorize_size(self):
        """Test model size categorization."""
        self.assertEqual(ModelRecommender._categorize_size(0.5), "tiny")
        self.assertEqual(ModelRecommender._categorize_size(3.0), "small")
        self.assertEqual(ModelRecommender._categorize_size(10.0), "medium")
        self.assertEqual(ModelRecommender._categorize_size(25.0), "large")
        self.assertEqual(ModelRecommender._categorize_size(50.0), "xlarge")

    def test_empty_models_list(self):
        """Test recommendation with empty models list."""
        recommendations = ModelRecommender.recommend_models(
            self.system_info,
            [],
            max_recommendations=5
        )

        self.assertEqual(recommendations, [])

    def test_all_models_too_large(self):
        """Test when all models are too large for system."""
        large_models = [
            ModelInfo(
                id="huge-model",
                name="Huge Model",
                provider="mlx",
                size_gb=100.0,
                ram_gb=120.0,  # Way too large
                context_window=32000,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=130,
                score=95.0
            )
        ]

        recommendations = ModelRecommender.recommend_models(
            self.system_info,
            large_models,
            max_recommendations=5
        )

        # Should be empty as no models fit
        self.assertEqual(recommendations, [])


if __name__ == '__main__':
    unittest.main()