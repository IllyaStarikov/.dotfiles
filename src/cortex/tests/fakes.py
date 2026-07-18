"""
Shared offline test doubles for the cortex test suite.

No test in this suite may touch the network: providers are faked in-memory and
aiohttp sessions are replaced with canned responses.
"""

from unittest.mock import AsyncMock, MagicMock

from cortex.providers import BaseProvider, ModelCapability, ModelInfo, ProviderType
from cortex.system_utils import PerformanceTier, SystemInfo, SystemType


def make_model(model_id, provider, capabilities=None, ram_gb=2.0, online=False):
    """Build a ModelInfo with sensible defaults for tests."""
    return ModelInfo(
        id=model_id,
        name=model_id.split("/")[-1],
        provider=provider,
        size_gb=ram_gb / 1.2,
        ram_gb=ram_gb,
        context_window=8192,
        capabilities=capabilities or [ModelCapability.CHAT],
        online=online,
        open_source=not online,
        recommended_ram=int(ram_gb * 1.5),
    )


def make_system_info():
    """Build a SystemInfo for an M1 Max with 64GB RAM."""
    return SystemInfo(
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
        platform_details={},
    )


class FakeProvider(BaseProvider):
    """Offline in-memory provider used to avoid any network calls."""

    def __init__(self, name, models, download_result=True):
        super().__init__({})
        self.name = name
        self._models = models
        self.download_result = download_result
        self.download_calls = []
        self.started_models = []
        self.stop_calls = 0

    @property
    def provider_type(self):
        return ProviderType.OFFLINE

    @property
    def requires_api_key(self):
        return False

    async def fetch_models(self, force_refresh=False):
        return self._models

    async def download_model(self, model_id, progress_callback=None):
        self.download_calls.append(model_id)
        return self.download_result

    async def is_model_available(self, model_id):
        return any(m.id == model_id for m in self._models)

    async def start_server(self, model_id, **kwargs):
        self.started_models.append(model_id)
        return True

    async def stop_server(self):
        self.stop_calls += 1
        return True

    async def get_server_status(self):
        return {"running": False, "type": self.name}


def make_response(status=200, json_data=None, text=""):
    """Build a fake aiohttp response object."""
    response = MagicMock()
    response.status = status
    response.json = AsyncMock(return_value=json_data)
    response.text = AsyncMock(return_value=text)
    return response


def make_cm(value):
    """Wrap a value in an async context manager mock."""
    cm = MagicMock()
    cm.__aenter__.return_value = value
    cm.__aexit__.return_value = False
    return cm


def make_session_class(session):
    """Return a mock class suitable for patching aiohttp.ClientSession."""
    return MagicMock(return_value=make_cm(session))


class FakeStreamContent:
    """Async iterator over canned byte lines, mimicking aiohttp response.content."""

    def __init__(self, lines):
        self._lines = list(lines)

    def __aiter__(self):
        return self

    async def __anext__(self):
        if not self._lines:
            raise StopAsyncIteration
        return self._lines.pop(0)
