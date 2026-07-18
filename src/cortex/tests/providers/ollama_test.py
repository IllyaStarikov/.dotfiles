"""
Tests for ollama.py provider module.

Removed with the API rewrite: chat() test — the provider has no chat method
(chat moved to the CLI layer, which shells out to `ollama run`).
"""

import asyncio
import unittest
from unittest.mock import MagicMock, patch

import aiohttp
from cortex.providers import ModelCapability, ProviderType
from cortex.providers.ollama import OllamaProvider

from tests.fakes import FakeStreamContent, make_cm, make_response, make_session_class

TAGS_PAYLOAD = {
    "models": [
        {
            "name": "llama2:latest",
            "size": 3825819519,  # ~3.6 GiB
            "modified_at": "2024-01-01T12:00:00Z",
            "digest": "abc123",
            "details": {
                "family": "llama",
                "parameter_size": "7B",
                "quantization_level": "Q4_0",
                "format": "gguf",
            },
        },
        {
            "name": "codellama:13b",
            "size": 13958643712,  # ~13 GiB
            "modified_at": "2024-01-01T12:00:00Z",
            "digest": "def456",
            "details": {
                "family": "codellama",
                "parameter_size": "13B",
                "quantization_level": "Q4_0",
                "format": "gguf",
            },
        },
    ]
}

SHOW_PAYLOAD = {
    "model_info": {"llama.context_length": 4096},
    "details": {"family": "llama", "parameter_size": "7B", "quantization_level": "Q4_0"},
    "capabilities": ["completion"],
}


class TestOllamaProvider(unittest.TestCase):
    """Test Ollama Provider."""

    def setUp(self):
        """Set up test fixtures."""
        self.provider = OllamaProvider()

    def test_initialization(self):
        """Test Ollama provider initialization."""
        self.assertEqual(self.provider.name, "ollama")
        self.assertEqual(self.provider.port, 11434)
        self.assertEqual(self.provider.api_url, "http://localhost:11434/api")
        self.assertEqual(self.provider.provider_type, ProviderType.OFFLINE)
        self.assertFalse(self.provider.requires_api_key)

    def test_initialization_custom_port(self):
        """Test Ollama provider with a custom port."""
        provider = OllamaProvider({"port": 12345})

        self.assertEqual(provider.port, 12345)
        self.assertEqual(provider.api_url, "http://localhost:12345/api")

    def test_fetch_models_success(self):
        """Test fetching locally installed Ollama models."""
        session = MagicMock()
        session.get = MagicMock(return_value=make_cm(make_response(200, TAGS_PAYLOAD)))
        session.post = MagicMock(return_value=make_cm(make_response(200, SHOW_PAYLOAD)))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        self.assertEqual(len(models), 2)
        self.assertEqual(models[0].id, "llama2:latest")
        self.assertEqual(models[0].name, "llama2")
        self.assertEqual(models[0].provider, "ollama")
        self.assertAlmostEqual(models[0].size_gb, 3.6, places=1)
        self.assertEqual(models[0].context_window, 4096)
        self.assertIn(ModelCapability.CHAT, models[0].capabilities)
        self.assertTrue(models[0].metadata["downloaded"])

        # Code models are detected from the name
        self.assertIn(ModelCapability.CODE, models[1].capabilities)

    def test_fetch_models_fallback_when_offline(self):
        """Test the minimal fallback list when the Ollama API is unavailable."""
        session = MagicMock()
        session.get = MagicMock(side_effect=aiohttp.ClientConnectionError("Connection refused"))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            models = asyncio.run(self.provider.fetch_models())

        ids = [m.id for m in models]
        self.assertEqual(ids, ["llama3.2:latest", "mistral:latest"])
        for model in models:
            self.assertEqual(model.provider, "ollama")
            self.assertFalse(model.online)

    def test_download_model_success(self):
        """Test downloading an Ollama model via the pull API."""
        response = make_response(200)
        response.content = FakeStreamContent(
            [
                b'{"status": "downloading", "total": 100, "completed": 50}',
                b'{"status": "success"}',
            ]
        )
        session = MagicMock()
        session.post = MagicMock(return_value=make_cm(response))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            result = asyncio.run(self.provider.download_model("llama2"))

        self.assertTrue(result)
        session.post.assert_called_once()
        self.assertEqual(session.post.call_args[0][0], "http://localhost:11434/api/pull")
        self.assertEqual(session.post.call_args[1]["json"]["name"], "llama2")

    def test_download_model_reports_progress(self):
        """Test that pull progress is forwarded to the callback."""
        response = make_response(200)
        response.content = FakeStreamContent(
            [
                b'{"status": "downloading", "total": 100, "completed": 50}',
                b'{"status": "success"}',
            ]
        )
        session = MagicMock()
        session.post = MagicMock(return_value=make_cm(response))

        progress_calls = []

        def on_progress(completed, total):
            progress_calls.append((completed, total))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            result = asyncio.run(
                self.provider.download_model("llama2", progress_callback=on_progress)
            )

        self.assertTrue(result)
        self.assertEqual(progress_calls, [(50, 100)])

    def test_download_model_http_error(self):
        """Test download failure on non-200 response."""
        session = MagicMock()
        session.post = MagicMock(return_value=make_cm(make_response(500)))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            result = asyncio.run(self.provider.download_model("llama2"))

        self.assertFalse(result)

    def test_download_model_error_in_stream(self):
        """Test download failure reported inside the pull stream."""
        response = make_response(200)
        response.content = FakeStreamContent([b'{"error": "model not found"}'])
        session = MagicMock()
        session.post = MagicMock(return_value=make_cm(response))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            result = asyncio.run(self.provider.download_model("nonexistent"))

        self.assertFalse(result)

    def test_is_model_available(self):
        """Test local model availability via the tags API."""
        session = MagicMock()
        session.get = MagicMock(
            return_value=make_cm(make_response(200, {"models": [{"name": "llama2:latest"}]}))
        )

        with patch("aiohttp.ClientSession", make_session_class(session)):
            self.assertTrue(asyncio.run(self.provider.is_model_available("llama2:latest")))
            self.assertFalse(asyncio.run(self.provider.is_model_available("missing:latest")))

    def test_get_server_status_running(self):
        """Test server status when Ollama is running."""
        session = MagicMock()
        session.get = MagicMock(
            return_value=make_cm(make_response(200, {"models": [{"name": "llama2:latest"}]}))
        )

        with patch("aiohttp.ClientSession", make_session_class(session)):
            status = asyncio.run(self.provider.get_server_status())

        self.assertTrue(status["running"])
        self.assertEqual(status["port"], 11434)
        self.assertEqual(status["models"], ["llama2:latest"])

    def test_get_server_status_offline(self):
        """Test server status when Ollama is not running."""
        session = MagicMock()
        session.get = MagicMock(side_effect=aiohttp.ClientConnectionError("Connection refused"))

        with patch("aiohttp.ClientSession", make_session_class(session)):
            status = asyncio.run(self.provider.get_server_status())

        self.assertFalse(status["running"])
        self.assertEqual(status["models"], [])


if __name__ == "__main__":
    unittest.main()
