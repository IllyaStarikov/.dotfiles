"""HuggingFace Provider - Placeholder for list command."""

from typing import Any, Dict, List

from . import BaseProvider, ModelInfo, ProviderType


class HuggingFaceProvider(BaseProvider):
    @property
    def provider_type(self) -> ProviderType:
        return ProviderType.HYBRID  # Can be both online (Inference API) and offline

    @property
    def requires_api_key(self) -> bool:
        return False  # Optional for public models

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        # Placeholder - would fetch from HuggingFace Hub API
        return []

    async def download_model(self, model_id: str, progress_callback=None) -> bool:
        return False

    async def is_model_available(self, model_id: str) -> bool:
        return False

    async def start_server(self, model_id: str, **kwargs) -> bool:
        return False

    async def stop_server(self) -> bool:
        return True

    async def get_server_status(self) -> Dict[str, Any]:
        return {'running': False, 'type': 'hybrid'}
