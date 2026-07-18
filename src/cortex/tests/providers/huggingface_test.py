"""
Tests for huggingface.py provider module.

The provider is currently a placeholder used by the list command; the old
tests exercised a removed implementation (api_url, chat, _parse_model_info,
hub fetching). These tests pin the placeholder contract instead.
"""

import asyncio
import unittest

from cortex.providers import ProviderType
from cortex.providers.huggingface import HuggingFaceProvider


class TestHuggingFaceProvider(unittest.TestCase):
    """Test HuggingFace Provider placeholder."""

    def setUp(self):
        """Set up test fixtures."""
        self.provider = HuggingFaceProvider()

    def test_initialization(self):
        """Test HuggingFace provider initialization."""
        self.assertEqual(self.provider.name, "huggingface")
        self.assertEqual(self.provider.provider_type, ProviderType.HYBRID)
        self.assertFalse(self.provider.requires_api_key)

    def test_fetch_models_empty(self):
        """Test that the placeholder returns no models (and makes no HTTP calls)."""
        models = asyncio.run(self.provider.fetch_models())

        self.assertEqual(models, [])

    def test_download_not_supported(self):
        """Test that download is not supported."""
        result = asyncio.run(self.provider.download_model("some-model"))

        self.assertFalse(result)

    def test_is_model_available(self):
        """Test that no models are reported as available."""
        result = asyncio.run(self.provider.is_model_available("some-model"))

        self.assertFalse(result)

    def test_server_lifecycle(self):
        """Test the no-op server lifecycle."""
        self.assertFalse(asyncio.run(self.provider.start_server("some-model")))
        self.assertTrue(asyncio.run(self.provider.stop_server()))

        status = asyncio.run(self.provider.get_server_status())
        self.assertEqual(status, {"running": False, "type": "hybrid"})


if __name__ == "__main__":
    unittest.main()
