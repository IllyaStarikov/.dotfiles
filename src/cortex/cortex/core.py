"""
Core Cortex system orchestrator.
"""

import logging
from pathlib import Path
from typing import Any, Dict, List, Optional

from .config import Config
from .providers import registry
from .system_utils import ModelRecommender
from .system_utils import SystemDetector

logger = logging.getLogger(__name__)


class Cortex:
    """Main Cortex system orchestrator."""

    def __init__(self, config_path: Optional[Path] = None):
        """Initialize Cortex system."""
        self.config = Config(config_path)
        self.system_info = SystemDetector.detect_system()
        self.registry = registry

    async def initialize(self):
        """Initialize the Cortex system."""
        await self.registry.initialize_providers(self.config.data)
        logger.info("Cortex system initialized")

    async def list_models(self,
                          category: str = "all",
                          provider: Optional[str] = None,
                          capability: Optional[str] = None,
                          max_ram: Optional[float] = None,
                          recommended: bool = False) -> Dict[str, Any]:
        """List available models with filtering."""
        # Fetch all models
        all_models = await self.registry.fetch_all_models()

        # Categorize
        categorized = self.registry.categorize_models(all_models)

        # Apply filters
        filtered = categorized.get(category, [])

        if provider:
            filtered = [m for m in filtered if m.provider == provider]

        if capability:
            filtered = [m for m in filtered if capability in [c.value for c in m.capabilities]]

        if max_ram:
            filtered = [m for m in filtered if m.ram_gb <= max_ram]

        # Get recommendations if requested
        if recommended:
            filtered = ModelRecommender.recommend_models(self.system_info,
                                                         filtered,
                                                         max_recommendations=10)

        return {"models": filtered, "system_info": self.system_info, "total_count": len(filtered)}

    async def set_model(self, model_id: str, provider: Optional[str] = None) -> bool:
        """Set the active model."""
        # Find the model
        all_models = await self.registry.fetch_all_models()

        model = None
        for provider_models in all_models.values():
            for m in provider_models:
                if m.id == model_id:
                    model = m
                    break
            if model:
                break

        if not model:
            logger.error(f"Model {model_id} not found")
            return False

        # Update configuration
        model_info = {
            "id":
                model.id,
            "name":
                model.name,
            "provider":
                model.provider,
            "size_gb":
                model.size_gb,
            "ram_gb":
                model.ram_gb,
            "context_window":
                model.context_window,
            "capability": [c.value for c in model.capabilities][0]
                          if model.capabilities else "chat",
            "online":
                model.online,
            "downloads":
                model.downloads,
            "likes":
                model.likes,
            "last_modified":
                model.last_modified
        }

        self.config.update_current_model(model_info)
        logger.info(f"Set active model to {model_id}")

        return True

    async def download_model(self, model_id: str, provider: Optional[str] = None) -> bool:
        """Download a model."""
        # Find the provider
        if provider:
            prov = self.registry.get_provider(provider)
            if prov:
                return await prov.download_model(model_id)

        # Try all providers
        for prov_name in self.registry.list_providers():
            prov = self.registry.get_provider(prov_name)
            if await prov.is_model_available(model_id):
                return await prov.download_model(model_id)

        logger.error(f"Could not find provider for model {model_id}")
        return False

    async def start_server(self, model_id: Optional[str] = None) -> bool:
        """Start the model server."""
        if not model_id:
            model_id = self.config.data.get("current_model", {}).get("id")

        if not model_id:
            logger.error("No model specified")
            return False

        provider_name = self.config.data.get("current_model", {}).get("provider")
        if not provider_name:
            # Try to determine provider from model ID
            if "mlx" in model_id.lower():
                provider_name = "mlx"
            elif any(x in model_id.lower() for x in ["llama", "mistral", "phi", "gemma"]):
                provider_name = "ollama"

        provider = self.registry.get_provider(provider_name)
        if not provider:
            logger.error(f"Provider {provider_name} not found")
            return False

        return await provider.start_server(model_id)

    async def stop_server(self, provider: Optional[str] = None) -> bool:
        """Stop the model server."""
        if not provider:
            provider = self.config.data.get("current_model", {}).get("provider")

        if not provider:
            logger.error("No provider specified")
            return False

        prov = self.registry.get_provider(provider)
        if not prov:
            logger.error(f"Provider {provider} not found")
            return False

        return await prov.stop_server()

    async def get_status(self) -> Dict[str, Any]:
        """Get system status."""
        status = {
            "system": self.system_info,
            "current_model": self.config.data.get("current_model", {}),
            "providers": {}
        }

        # Get status from each provider
        for prov_name in self.registry.list_providers():
            prov = self.registry.get_provider(prov_name)
            if prov:
                status["providers"][prov_name] = await prov.get_server_status()

        return status
