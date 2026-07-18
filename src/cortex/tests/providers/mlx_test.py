"""
Tests for mlx.py provider module.

Removed with the API rewrite (features no longer exist on MLXProvider):
- chat() tests: chat moved to the CLI layer (subprocess-based), the provider
  has no chat method.
- validate_connection() and _parse_model_info() tests: methods were removed.
- download force flag test: download_model() no longer takes force.
"""

import asyncio
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch

import aiohttp
from cortex.providers import ModelCapability, ModelInfo, ProviderType
from cortex.providers.mlx import MLXProvider

from tests.fakes import make_cm, make_response, make_session_class


def _hub_model(model_id, tags=None, downloads=1000, likes=10):
    """Build a HuggingFace hub API list entry."""
    return {"id": model_id, "tags": tags or [], "downloads": downloads, "likes": likes}


class TestMLXProvider(unittest.TestCase):
    """Test MLX Provider."""

    def setUp(self):
        """Set up test fixtures with an isolated local model cache."""
        self.provider = MLXProvider()
        self.temp_dir = tempfile.mkdtemp()
        self.provider.mlx_path = Path(self.temp_dir) / "mlx"
        self.addCleanup(shutil.rmtree, self.temp_dir)

    def _mock_hub_session(self, list_payload, detail_payload=None):
        """Build a fake aiohttp session serving hub list + per-model detail."""
        session = MagicMock()

        def get_side_effect(url, **kwargs):
            if url == MLXProvider.MLX_HUB_API:
                return make_cm(make_response(200, list_payload))
            return make_cm(make_response(200, detail_payload or {}))

        session.get = MagicMock(side_effect=get_side_effect)
        return session

    def test_initialization(self):
        """Test MLX provider initialization."""
        self.assertEqual(self.provider.name, "mlx")
        self.assertEqual(self.provider.provider_type, ProviderType.OFFLINE)
        self.assertFalse(self.provider.requires_api_key)
        self.assertEqual(self.provider.MLX_SERVER_PORT, 8080)
        self.assertIsNone(self.provider.server_process)

    def test_fetch_models_success(self):
        """Test fetching MLX models from the hub API."""
        session = self._mock_hub_session(
            [
                _hub_model("mlx-community/test-model-7b", tags=["text-generation"]),
                _hub_model("mlx-community/code-model-13b"),
            ]
        )

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        self.assertEqual(len(models), 2)
        self.assertIsInstance(models[0], ModelInfo)
        self.assertEqual(models[0].id, "mlx-community/test-model-7b")
        self.assertEqual(models[0].provider, "mlx")
        self.assertFalse(models[0].online)
        self.assertTrue(models[0].open_source)

    def test_fetch_models_skips_non_mlx_entries(self):
        """Test that non-mlx-community results are filtered out."""
        session = self._mock_hub_session(
            [
                _hub_model("mlx-community/good-model-7b"),
                _hub_model("someone-else/other-model-7b"),
            ]
        )

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        self.assertEqual([m.id for m in models], ["mlx-community/good-model-7b"])

    def test_fetch_models_hub_offline(self):
        """Test fetching models when the hub API is unreachable."""
        session = MagicMock()
        session.get = MagicMock(side_effect=aiohttp.ClientConnectionError("Connection refused"))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        self.assertEqual(models, [])

    def test_fetch_models_size_parse(self):
        """Test model size estimation from parameter counts in the id."""
        session = self._mock_hub_session(
            [
                _hub_model("mlx-community/model-1b"),
                _hub_model("mlx-community/model-7b-4bit"),
                _hub_model("mlx-community/model-13b"),
                _hub_model("mlx-community/model-70b"),
            ]
        )

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        # 0.5 GB per billion params at 4-bit quantization
        self.assertAlmostEqual(models[0].size_gb, 0.5, places=1)
        self.assertAlmostEqual(models[1].size_gb, 3.5, places=1)
        self.assertAlmostEqual(models[2].size_gb, 6.5, places=1)
        self.assertAlmostEqual(models[3].size_gb, 35.0, places=1)

        # RAM estimate is 1.2x the model size
        for model in models:
            self.assertAlmostEqual(model.ram_gb, model.size_gb * 1.2, places=2)

    def test_extract_capabilities(self):
        """Test capability detection from model names."""
        code_caps = self.provider._extract_capabilities("CodeLlama-7b", [], {})
        self.assertIn(ModelCapability.CODE, code_caps)
        self.assertIn(ModelCapability.CHAT, code_caps)

        vision_caps = self.provider._extract_capabilities("phi-3-vision", [], {})
        self.assertIn(ModelCapability.VISION, vision_caps)
        self.assertIn(ModelCapability.MULTIMODAL, vision_caps)

        default_caps = self.provider._extract_capabilities("random-model", [], {})
        self.assertEqual(default_caps, [ModelCapability.CHAT])

    def test_extract_context(self):
        """Test context window extraction from names and configs."""
        self.assertEqual(self.provider._extract_context("model-32k", {}), 32 * 1024)
        self.assertEqual(self.provider._extract_context("Llama-3.1-Instruct", {}), 131072)
        self.assertEqual(
            self.provider._extract_context("plain", {"config": {"max_position_embeddings": 4096}}),
            4096,
        )
        self.assertEqual(self.provider._extract_context("plain", {}), 8192)

    def _make_subprocess_mocks(self, returncode=0, stderr=b""):
        """Build (which, download) process mocks for create_subprocess_exec."""
        which_proc = MagicMock()
        which_proc.communicate = AsyncMock(return_value=(b"/usr/local/bin/mlx_lm", b""))
        which_proc.returncode = 0

        dl_proc = MagicMock()
        dl_proc.stdout.readline = AsyncMock(side_effect=[b"Downloading model 3.5 GB\n", b""])
        dl_proc.stderr.read = AsyncMock(return_value=stderr)
        dl_proc.wait = AsyncMock(return_value=returncode)
        dl_proc.returncode = returncode
        return which_proc, dl_proc

    def test_download_model_success(self):
        """Test downloading an MLX model successfully."""
        which_proc, dl_proc = self._make_subprocess_mocks(returncode=0)

        with patch(
            "asyncio.create_subprocess_exec", AsyncMock(side_effect=[which_proc, dl_proc])
        ) as mock_exec:
            result = asyncio.run(self.provider.download_model("mlx-community/test-model"))

        self.assertTrue(result)
        download_cmd = mock_exec.call_args_list[1][0]
        self.assertIn("convert", download_cmd)
        self.assertIn("--hf-path", download_cmd)
        self.assertIn("mlx-community/test-model", download_cmd)
        # Full-precision models get quantized on download
        self.assertIn("-q", download_cmd)

    def test_download_model_prequantized_skips_quantization(self):
        """Test that pre-quantized models are not re-quantized."""
        which_proc, dl_proc = self._make_subprocess_mocks(returncode=0)

        with patch(
            "asyncio.create_subprocess_exec", AsyncMock(side_effect=[which_proc, dl_proc])
        ) as mock_exec:
            result = asyncio.run(self.provider.download_model("mlx-community/test-model-4bit"))

        self.assertTrue(result)
        download_cmd = mock_exec.call_args_list[1][0]
        self.assertNotIn("-q", download_cmd)

    def test_download_model_failure(self):
        """Test MLX model download failure."""
        which_proc, dl_proc = self._make_subprocess_mocks(returncode=1, stderr=b"Error downloading")

        with patch("asyncio.create_subprocess_exec", AsyncMock(side_effect=[which_proc, dl_proc])):
            result = asyncio.run(self.provider.download_model("mlx-community/test-model"))

        self.assertFalse(result)

    def test_is_model_available(self):
        """Test local model availability check."""
        model_dir = self.provider.mlx_path / "mlx-community_local-model"
        model_dir.mkdir(parents=True)

        self.assertTrue(asyncio.run(self.provider.is_model_available("mlx-community/local-model")))
        self.assertFalse(asyncio.run(self.provider.is_model_available("mlx-community/missing")))

    def test_scan_local_models(self):
        """Test scanning locally downloaded models."""
        model_dir = self.provider.mlx_path / "mlx-community_local-model"
        model_dir.mkdir(parents=True)
        (model_dir / "config.json").write_text(
            '{"architectures": ["LlamaForCausalLM"], "max_position_embeddings": 4096}'
        )

        models = asyncio.run(self.provider._scan_local_models())

        self.assertEqual(len(models), 1)
        self.assertEqual(models[0].id, "mlx-community/local-model")
        self.assertEqual(models[0].context_window, 4096)
        self.assertTrue(models[0].metadata["downloaded"])

    def test_get_server_status_stopped(self):
        """Test server status when no server is running."""
        status = asyncio.run(self.provider.get_server_status())

        self.assertFalse(status["running"])
        self.assertEqual(status["port"], MLXProvider.MLX_SERVER_PORT)
        self.assertEqual(status["type"], "mlx")

    def test_stop_server_without_process(self):
        """Test stopping when no server process exists."""
        self.assertTrue(asyncio.run(self.provider.stop_server()))


if __name__ == "__main__":
    unittest.main()
