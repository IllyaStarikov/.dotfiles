"""
Tests for anthropic.py provider module.

Removed with the API rewrite: chat() tests — the provider has no chat method.
Note: download_model() now returns True (a no-op for cloud models) rather
than False.
"""

import asyncio
import unittest
from unittest.mock import patch

from cortex.providers import ModelCapability, ProviderRegistry, ProviderType
from cortex.providers.anthropic import AnthropicProvider

FAKE_KEY = "sk-ant-test-fake-key-1234567890"


class TestAnthropicProvider(unittest.TestCase):
    """Test Anthropic Provider."""

    def setUp(self):
        """Set up test fixtures with a fake API key."""
        env_patcher = patch.dict("os.environ", {"ANTHROPIC_API_KEY": FAKE_KEY})
        env_patcher.start()
        self.addCleanup(env_patcher.stop)
        self.provider = AnthropicProvider()

    def test_initialization(self):
        """Test Anthropic provider initialization."""
        # Canonical name matches the config key and ModelInfo.provider stamps
        # ("claude") — the class-derived "anthropic" broke registry lookups.
        self.assertEqual(self.provider.name, "claude")
        self.assertEqual(self.provider.provider_type, ProviderType.ONLINE)
        self.assertTrue(self.provider.requires_api_key)
        self.assertEqual(self.provider.api_key, FAKE_KEY)

    def test_registry_resolves_canonical_name_and_alias(self):
        """get_provider must resolve both 'claude' and the legacy 'anthropic'."""
        registry = ProviderRegistry()
        registry.register(self.provider)
        self.assertIs(registry.get_provider("claude"), self.provider)
        self.assertIs(registry.get_provider("anthropic"), self.provider)

    def test_format_model_name_renders_dates(self):
        """8-digit date suffixes render as (Mon YYYY), not raw digits."""
        self.assertEqual(
            self.provider._format_model_name("claude-3-opus-20240229"),
            "Claude 3 Opus (Feb 2024)",
        )

    def test_fetch_models(self):
        """Test listing Anthropic models from the known catalog (no HTTP)."""
        models = asyncio.run(self.provider.fetch_models())

        self.assertGreater(len(models), 0)

        model_ids = [m.id for m in models]
        self.assertIn("claude-3-5-sonnet-20241022", model_ids)
        self.assertIn("claude-3-opus-20240229", model_ids)

        for model in models:
            self.assertEqual(model.provider, "claude")
            self.assertTrue(model.online)
            self.assertFalse(model.open_source)
            self.assertIn(ModelCapability.CHAT, model.capabilities)
            self.assertIn(ModelCapability.CODE, model.capabilities)

    def test_vision_capability_for_claude_3(self):
        """Test that Claude 3+ models get vision, legacy instant does not."""
        models = asyncio.run(self.provider.fetch_models())
        by_id = {m.id: m for m in models}

        self.assertIn(ModelCapability.VISION, by_id["claude-3-opus-20240229"].capabilities)
        self.assertNotIn(ModelCapability.VISION, by_id["claude-instant-1.2"].capabilities)

    def test_format_model_name(self):
        """Test model id formatting into display names (versions kept as-is)."""
        self.assertEqual(
            self.provider._format_model_name("claude-3.5-sonnet"),
            "Claude 3.5 Sonnet",
        )

    def test_check_api_key(self):
        """Test API key validation."""
        self.assertTrue(self.provider._check_api_key())

        with patch.dict("os.environ", {"ANTHROPIC_API_KEY": "", "CLAUDE_API_KEY": ""}):
            self.assertFalse(AnthropicProvider()._check_api_key())

    def test_cloud_model_lifecycle(self):
        """Test that cloud models need no download or local server."""
        self.assertTrue(asyncio.run(self.provider.download_model("claude-3-opus-20240229")))
        self.assertTrue(asyncio.run(self.provider.is_model_available("claude-3-opus-20240229")))
        self.assertTrue(asyncio.run(self.provider.start_server("claude-3-opus-20240229")))
        self.assertTrue(asyncio.run(self.provider.stop_server()))

    def test_get_server_status(self):
        """Test API status reporting."""
        status = asyncio.run(self.provider.get_server_status())

        self.assertTrue(status["running"])
        self.assertEqual(status["type"], "api")
        self.assertTrue(status["api_key_configured"])
        self.assertEqual(status["endpoint"], "https://api.anthropic.com")


if __name__ == "__main__":
    unittest.main()
