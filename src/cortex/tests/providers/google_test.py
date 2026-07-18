"""
Tests for google.py provider module.

Removed with the API rewrite: chat() tests — the provider has no chat method.
"""

import asyncio
import unittest
from unittest.mock import MagicMock, patch

from cortex.providers import ModelCapability, ProviderType
from cortex.providers.google import GoogleProvider

from tests.fakes import make_cm, make_response, make_session_class

FAKE_KEY = "test-fake-gemini-key-1234567890"

_NO_GOOGLE_KEYS = {"GEMINI_API_KEY": "", "GOOGLE_API_KEY": "", "GOOGLE_AI_API_KEY": ""}


class TestGoogleProvider(unittest.TestCase):
    """Test Google Provider."""

    def setUp(self):
        """Set up test fixtures with a fake API key."""
        env_patcher = patch.dict("os.environ", {**_NO_GOOGLE_KEYS, "GEMINI_API_KEY": FAKE_KEY})
        env_patcher.start()
        self.addCleanup(env_patcher.stop)
        self.provider = GoogleProvider()

    def test_initialization(self):
        """Test Google provider initialization."""
        # BaseProvider derives the registry name from the class name
        self.assertEqual(self.provider.name, "google")
        self.assertEqual(self.provider.provider_type, ProviderType.ONLINE)
        self.assertTrue(self.provider.requires_api_key)
        self.assertEqual(self.provider.api_key, FAKE_KEY)

    def test_fetch_models_known_list_without_key(self):
        """Test that the known model list is served without an API key (no HTTP)."""
        with patch.dict("os.environ", _NO_GOOGLE_KEYS):
            provider = GoogleProvider()
            models = asyncio.run(provider.fetch_models())

        self.assertGreater(len(models), 0)

        model_ids = [m.id for m in models]
        self.assertIn("gemini-1.5-pro", model_ids)
        self.assertIn("gemini-1.5-flash", model_ids)

        for model in models:
            self.assertEqual(model.provider, "gemini")
            self.assertTrue(model.online)
            self.assertFalse(model.open_source)

    def test_fetch_models_merges_api_results(self):
        """Test that models fetched from the API are flagged and merged."""
        api_payload = {
            "models": [
                {
                    "name": "models/gemini-1.5-pro",
                    "displayName": "Gemini 1.5 Pro",
                    "inputTokenLimit": 2097152,
                    "outputTokenLimit": 8192,
                    "supportedGenerationMethods": ["generateContent"],
                    "version": "1.5",
                }
            ]
        }
        session = MagicMock()
        session.get = MagicMock(return_value=make_cm(make_response(200, api_payload)))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        by_id = {m.id: m for m in models}
        self.assertIn("gemini-1.5-pro", by_id)
        self.assertTrue(by_id["gemini-1.5-pro"].metadata["from_api"])
        # Known models not returned by the API are still merged in
        self.assertIn("gemini-1.5-flash", by_id)
        self.assertFalse(by_id["gemini-1.5-flash"].metadata["from_api"])

    def test_format_model_name(self):
        """Test model id formatting into display names."""
        self.assertEqual(self.provider._format_model_name("gemini-1.5-pro"), "Gemini 1.5 Pro")
        self.assertEqual(
            self.provider._format_model_name("gemini-2.0-flash-exp"),
            "Gemini 2.0 Flash Experimental",
        )

    def test_extract_capabilities_embedding(self):
        """Test that embedding models report only the embedding capability."""
        caps = self.provider._extract_capabilities_from_api(
            {"supportedGenerationMethods": ["embedContent"]}
        )

        self.assertEqual(caps, [ModelCapability.EMBEDDING])

    def test_extract_capabilities_generation(self):
        """Test that generative models report chat and code capabilities."""
        caps = self.provider._extract_capabilities_from_api(
            {"supportedGenerationMethods": ["generateContent"]}
        )

        self.assertIn(ModelCapability.CHAT, caps)
        self.assertIn(ModelCapability.CODE, caps)

    def test_check_api_key(self):
        """Test API key validation."""
        self.assertTrue(self.provider._check_api_key())

        with patch.dict("os.environ", _NO_GOOGLE_KEYS):
            self.assertFalse(GoogleProvider()._check_api_key())

    def test_cloud_model_lifecycle(self):
        """Test that cloud models need no download or local server."""
        self.assertTrue(asyncio.run(self.provider.download_model("gemini-1.5-pro")))
        self.assertTrue(asyncio.run(self.provider.is_model_available("gemini-1.5-pro")))
        self.assertTrue(asyncio.run(self.provider.start_server("gemini-1.5-pro")))
        self.assertTrue(asyncio.run(self.provider.stop_server()))

    def test_get_server_status(self):
        """Test API status reporting."""
        status = asyncio.run(self.provider.get_server_status())

        self.assertTrue(status["running"])
        self.assertEqual(status["type"], "api")
        self.assertTrue(status["api_key_configured"])


if __name__ == "__main__":
    unittest.main()
