"""
Tests for health.py module.
"""

import asyncio
import time
import unittest
from unittest.mock import AsyncMock
from unittest.mock import MagicMock
from unittest.mock import patch

from cortex.health import HealthMonitor


class TestHealthMonitor(unittest.TestCase):
    """Test HealthMonitor class."""

    def setUp(self):
        """Set up test fixtures."""
        self.monitor = HealthMonitor()

    def test_initialization(self):
        """Test HealthMonitor initialization."""
        self.assertIsInstance(self.monitor.checks, dict)
        self.assertIn("system", self.monitor.checks)
        self.assertIn("mlx_server", self.monitor.checks)
        self.assertIn("ollama_server", self.monitor.checks)
        self.assertIn("api_keys", self.monitor.checks)
        self.assertIn("network", self.monitor.checks)
        self.assertIn("disk_space", self.monitor.checks)
        self.assertIn("model_cache", self.monitor.checks)

    @patch('psutil.cpu_percent')
    @patch('psutil.virtual_memory')
    @patch('psutil.disk_usage')
    def test_check_system_resources_healthy(self, mock_disk, mock_memory, mock_cpu):
        """Test system resource check when healthy."""
        mock_cpu.return_value = 25.0

        mock_mem = MagicMock()
        mock_mem.percent = 50.0
        mock_mem.available = 32 * (1024**3)  # 32 GB
        mock_memory.return_value = mock_mem

        mock_disk_usage = MagicMock()
        mock_disk_usage.percent = 60.0
        mock_disk_usage.free = 100 * (1024**3)  # 100 GB
        mock_disk.return_value = mock_disk_usage

        result = asyncio.run(self.monitor.check_system_resources())

        self.assertEqual(result["status"], "healthy")
        self.assertEqual(result["cpu_percent"], 25.0)
        self.assertEqual(result["memory_percent"], 50.0)
        self.assertEqual(len(result["issues"]), 0)

    @patch('psutil.cpu_percent')
    @patch('psutil.virtual_memory')
    @patch('psutil.disk_usage')
    def test_check_system_resources_warning(self, mock_disk, mock_memory, mock_cpu):
        """Test system resource check with warnings."""
        mock_cpu.return_value = 92.0  # High CPU

        mock_mem = MagicMock()
        mock_mem.percent = 91.0  # High memory
        mock_mem.available = 3 * (1024**3)
        mock_memory.return_value = mock_mem

        mock_disk_usage = MagicMock()
        mock_disk_usage.percent = 60.0
        mock_disk_usage.free = 100 * (1024**3)
        mock_disk.return_value = mock_disk_usage

        result = asyncio.run(self.monitor.check_system_resources())

        self.assertEqual(result["status"], "warning")
        self.assertGreater(len(result["issues"]), 0)
        self.assertIn("High CPU usage", result["issues"][0])
        self.assertIn("High memory usage", result["issues"][1])

    @patch('psutil.cpu_percent')
    @patch('psutil.virtual_memory')
    @patch('psutil.disk_usage')
    def test_check_system_resources_critical(self, mock_disk, mock_memory, mock_cpu):
        """Test system resource check with critical status."""
        mock_cpu.return_value = 50.0

        mock_mem = MagicMock()
        mock_mem.percent = 96.0  # Critical memory
        mock_mem.available = 1 * (1024**3)
        mock_memory.return_value = mock_mem

        mock_disk_usage = MagicMock()
        mock_disk_usage.percent = 96.0  # Critical disk
        mock_disk_usage.free = 5 * (1024**3)
        mock_disk.return_value = mock_disk_usage

        result = asyncio.run(self.monitor.check_system_resources())

        self.assertEqual(result["status"], "critical")
        self.assertGreater(len(result["issues"]), 0)

    @patch('aiohttp.ClientSession')
    async def test_check_mlx_server_running(self, mock_session_class):
        """Test MLX server check when running."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json.return_value = {"data": [{"id": "model1"}, {"id": "model2"}]}

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        result = await self.monitor.check_mlx_server()

        self.assertEqual(result["status"], "healthy")
        self.assertTrue(result["running"])
        self.assertEqual(result["models"], 2)

    @patch('aiohttp.ClientSession')
    async def test_check_mlx_server_offline(self, mock_session_class):
        """Test MLX server check when offline."""
        mock_session = AsyncMock()
        mock_session.get.side_effect = Exception("Connection refused")
        mock_session_class.return_value.__aenter__.return_value = mock_session

        result = await self.monitor.check_mlx_server()

        self.assertEqual(result["status"], "offline")
        self.assertFalse(result["running"])

    @patch('os.environ.get')
    def test_check_api_keys_configured(self, mock_env_get):
        """Test API keys check when configured."""
        mock_env_get.side_effect = lambda key: {
            "ANTHROPIC_API_KEY": "test-key",
            "OPENAI_API_KEY": "test-key",
            "GEMINI_API_KEY": None,
            "GOOGLE_API_KEY": "test-key"
        }.get(key)

        result = asyncio.run(self.monitor.check_api_keys())

        self.assertEqual(result["status"], "healthy")
        self.assertEqual(result["configured"], 3)
        self.assertEqual(result["total"], 3)
        self.assertTrue(result["details"]["anthropic"])
        self.assertTrue(result["details"]["openai"])
        self.assertTrue(result["details"]["gemini"])  # Has Google key

    @patch('os.environ.get')
    def test_check_api_keys_none_configured(self, mock_env_get):
        """Test API keys check when none configured."""
        mock_env_get.return_value = None

        result = asyncio.run(self.monitor.check_api_keys())

        self.assertEqual(result["status"], "warning")
        self.assertEqual(result["configured"], 0)

    @patch('aiohttp.ClientSession')
    async def test_check_network_healthy(self, mock_session_class):
        """Test network check when healthy."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200

        mock_session.head.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        result = await self.monitor.check_network()

        self.assertEqual(result["status"], "healthy")
        self.assertEqual(result["connectivity"], 100.0)

    @patch('aiohttp.ClientSession')
    async def test_check_network_degraded(self, mock_session_class):
        """Test network check when degraded."""
        mock_session = AsyncMock()

        # Simulate mixed results
        responses = [AsyncMock(status=200), Exception("timeout"), AsyncMock(status=200)]
        mock_session.head.side_effect = [
            AsyncMock(__aenter__=AsyncMock(return_value=r)) if not isinstance(r, Exception) else r
            for r in responses
        ]

        mock_session_class.return_value.__aenter__.return_value = mock_session

        result = await self.monitor.check_network()

        # Should be healthy as 2/3 succeeded
        self.assertIn(result["status"], ["healthy", "degraded"])
        self.assertGreater(result["connectivity"], 50)

    @patch('pathlib.Path.exists')
    @patch('pathlib.Path.rglob')
    @patch('psutil.disk_usage')
    def test_check_disk_space(self, mock_disk_usage, mock_rglob, mock_exists):
        """Test disk space check."""
        mock_exists.return_value = True

        # Mock file sizes
        mock_file1 = MagicMock()
        mock_file1.is_file.return_value = True
        mock_file1.stat.return_value.st_size = 1 * (1024**3)  # 1 GB

        mock_file2 = MagicMock()
        mock_file2.is_file.return_value = True
        mock_file2.stat.return_value.st_size = 2 * (1024**3)  # 2 GB

        mock_rglob.return_value = [mock_file1, mock_file2]

        mock_disk = MagicMock()
        mock_disk.free = 50 * (1024**3)  # 50 GB free
        mock_disk.total = 500 * (1024**3)  # 500 GB total
        mock_disk_usage.return_value = mock_disk

        result = asyncio.run(self.monitor.check_disk_space())

        self.assertEqual(result["status"], "healthy")
        self.assertAlmostEqual(result["free_space_gb"], 50.0, places=1)
        # 3 paths * 3GB = 9GB total
        self.assertAlmostEqual(result["model_cache_gb"], 9.0, places=1)

    @patch('pathlib.Path.exists')
    @patch('pathlib.Path.glob')
    def test_check_model_cache(self, mock_glob, mock_exists):
        """Test model cache check."""
        mock_exists.side_effect = [True, True]  # Both paths exist

        # Mock MLX models
        mock_glob.side_effect = [
            ["model1", "model2", "model3"],  # 3 MLX models
            ["model4", "model5"]  # 2 Ollama models
        ]

        result = asyncio.run(self.monitor.check_model_cache())

        self.assertEqual(result["status"], "healthy")
        self.assertEqual(result["mlx_models"], 3)
        self.assertEqual(result["ollama_models"], 2)
        self.assertEqual(result["total_models"], 5)

    def test_run_health_checks_all(self):
        """Test running all health checks."""

        # Mock all check methods
        async def mock_check():
            return {"status": "healthy", "timestamp": time.time()}

        for check_name in self.monitor.checks:
            self.monitor.checks[check_name] = mock_check

        results = asyncio.run(self.monitor.run_health_checks())

        self.assertEqual(len(results), len(self.monitor.checks))
        for result in results.values():
            self.assertEqual(result["status"], "healthy")

    def test_run_health_checks_specific(self):
        """Test running specific health checks."""

        # Mock check methods
        async def mock_check():
            return {"status": "healthy", "timestamp": time.time()}

        for check_name in self.monitor.checks:
            self.monitor.checks[check_name] = mock_check

        results = asyncio.run(self.monitor.run_health_checks(["system", "api_keys"]))

        self.assertEqual(len(results), 2)
        self.assertIn("system", results)
        self.assertIn("api_keys", results)

    def test_get_summary_healthy(self):
        """Test getting summary when all healthy."""
        self.monitor.status = {
            "system": {
                "status": "healthy"
            },
            "api_keys": {
                "status": "healthy"
            },
            "network": {
                "status": "healthy"
            }
        }
        self.monitor.last_check = {
            "system": time.time(),
            "api_keys": time.time(),
            "network": time.time()
        }

        summary = self.monitor.get_summary()

        self.assertEqual(summary["overall_status"], "healthy")
        self.assertEqual(summary["checks_run"], 3)
        self.assertEqual(len(summary["issues"]), 0)

    def test_get_summary_with_issues(self):
        """Test getting summary with issues."""
        self.monitor.status = {
            "system": {
                "status": "warning",
                "message": "High CPU"
            },
            "api_keys": {
                "status": "critical",
                "message": "No keys"
            },
            "network": {
                "status": "error",
                "message": "No connection"
            }
        }
        self.monitor.last_check = {
            "system": time.time(),
            "api_keys": time.time(),
            "network": time.time()
        }

        summary = self.monitor.get_summary()

        self.assertEqual(summary["overall_status"], "critical")
        self.assertEqual(summary["checks_run"], 3)
        self.assertGreater(len(summary["issues"]), 0)

    def test_get_summary_empty(self):
        """Test getting summary with no checks run."""
        summary = self.monitor.get_summary()

        self.assertEqual(summary["overall_status"], "healthy")
        self.assertEqual(summary["checks_run"], 0)
        self.assertEqual(len(summary["issues"]), 0)
        self.assertIsNone(summary["last_update"])


if __name__ == '__main__':
    unittest.main()
