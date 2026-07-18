"""
Tests for openai.py provider module.

Removed with the API rewrite: chat() tests — the provider has no chat method.
"""

import asyncio
import unittest
from unittest.mock import MagicMock, patch

from cortex.providers import ModelCapability, ProviderType
from cortex.providers.openai import OpenAIProvider

from tests.fakes import make_cm, make_response, make_session_class

FAKE_KEY = "sk-test-fake-key-1234567890"


class TestOpenAIProvider(unittest.TestCase):
    """Test OpenAI Provider."""

    def setUp(self):
        """Set up test fixtures with a fake API key."""
        env_patcher = patch.dict("os.environ", {"OPENAI_API_KEY": FAKE_KEY})
        env_patcher.start()
        self.addCleanup(env_patcher.stop)
        self.provider = OpenAIProvider()

    def test_initialization(self):
        """Test OpenAI provider initialization."""
        self.assertEqual(self.provider.name, "openai")
        self.assertEqual(self.provider.provider_type, ProviderType.ONLINE)
        self.assertTrue(self.provider.requires_api_key)
        self.assertEqual(self.provider.api_key, FAKE_KEY)

    def test_fetch_models_known_list_without_key(self):
        """Test that the known model list is served without an API key (no HTTP)."""
        with patch.dict("os.environ", {"OPENAI_API_KEY": ""}):
            provider = OpenAIProvider()
            models = asyncio.run(provider.fetch_models())

        self.assertGreater(len(models), 0)

        model_ids = [m.id for m in models]
        self.assertIn("gpt-4-turbo-preview", model_ids)
        self.assertIn("gpt-3.5-turbo", model_ids)
        self.assertIn("gpt-4o", model_ids)

        for model in models:
            self.assertEqual(model.provider, "openai")
            self.assertTrue(model.online)
            self.assertFalse(model.open_source)

    def test_fetch_models_merges_api_results(self):
        """Test that API results are merged with the known list, skipping non-chat models."""
        api_payload = {
            "data": [
                {"id": "gpt-4o-custom", "owned_by": "openai", "created": 1700000000},
                {"id": "whisper-1", "owned_by": "openai"},
                {"id": "dall-e-3", "owned_by": "openai"},
            ]
        }
        session = MagicMock()
        session.get = MagicMock(return_value=make_cm(make_response(200, api_payload)))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        model_ids = [m.id for m in models]
        self.assertIn("gpt-4o-custom", model_ids)
        self.assertNotIn("whisper-1", model_ids)
        self.assertNotIn("dall-e-3", model_ids)
        # Known models are merged in without duplicates
        self.assertIn("gpt-4o", model_ids)
        self.assertEqual(len(model_ids), len(set(model_ids)))

    def test_capabilities_inference(self):
        """Test capability inference from model ids."""
        caps = self.provider._extract_capabilities_from_permissions([], "gpt-4o")
        self.assertIn(ModelCapability.CHAT, caps)
        self.assertIn(ModelCapability.CODE, caps)
        self.assertIn(ModelCapability.VISION, caps)

        embed_caps = self.provider._extract_capabilities_from_permissions(
            [], "text-embedding-3-small"
        )
        self.assertEqual(embed_caps, [ModelCapability.EMBEDDING])

    def test_check_api_key(self):
        """Test API key validation."""
        self.assertTrue(self.provider._check_api_key())

        with patch.dict("os.environ", {"OPENAI_API_KEY": ""}):
            self.assertFalse(OpenAIProvider()._check_api_key())

        with patch.dict("os.environ", {"OPENAI_API_KEY": "short"}):
            self.assertFalse(OpenAIProvider()._check_api_key())

    def test_cloud_model_lifecycle(self):
        """Test that cloud models need no download or local server."""
        self.assertTrue(asyncio.run(self.provider.download_model("gpt-4o")))
        self.assertTrue(asyncio.run(self.provider.is_model_available("gpt-4o")))
        self.assertTrue(asyncio.run(self.provider.start_server("gpt-4o")))
        self.assertTrue(asyncio.run(self.provider.stop_server()))

    def test_get_server_status(self):
        """Test API status reporting."""
        status = asyncio.run(self.provider.get_server_status())

        self.assertTrue(status["running"])
        self.assertEqual(status["type"], "api")
        self.assertTrue(status["api_key_configured"])


if __name__ == "__main__":
    unittest.main()
