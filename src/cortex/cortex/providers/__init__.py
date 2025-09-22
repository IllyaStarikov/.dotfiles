"""
Provider Registry System for Cortex

Manages all AI model providers and their dynamic model discovery.
"""

import asyncio
import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)


class ModelCapability(Enum):
    """Model capability categories."""

    CHAT = 'chat'
    CODE = 'code'
    VISION = 'vision'
    EMBEDDING = 'embedding'
    MULTIMODAL = 'multimodal'


class ProviderType(Enum):
    """Provider categories."""

    ONLINE = 'online'
    OFFLINE = 'offline'
    HYBRID = 'hybrid'


@dataclass
class ModelInfo:
    """Information about a specific model."""

    id: str
    name: str
    provider: str
    size_gb: float
    ram_gb: float
    context_window: int
    capabilities: List[ModelCapability]
    online: bool
    open_source: bool
    recommended_ram: int
    score: float = 0.0  # Power/capability score
    downloads: int = 0
    likes: int = 0
    last_modified: Optional[str] = None
    description: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


class BaseProvider(ABC):
    """Abstract base class for all model providers."""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize provider with configuration."""
        self.config = config or {}
        self.name = self.__class__.__name__.replace('Provider', '').lower()
        self.models_cache: List[ModelInfo] = []
        self.last_fetch = None

    @property
    @abstractmethod
    def provider_type(self) -> ProviderType:
        """Return the provider type (online/offline/hybrid)."""
        pass

    @property
    @abstractmethod
    def requires_api_key(self) -> bool:
        """Whether this provider requires an API key."""
        pass

    @abstractmethod
    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch available models from the provider."""
        pass

    @abstractmethod
    async def download_model(self, model_id: str, progress_callback=None) -> bool:
        """Download a specific model."""
        pass

    @abstractmethod
    async def is_model_available(self, model_id: str) -> bool:
        """Check if a model is available locally or online."""
        pass

    @abstractmethod
    async def start_server(self, model_id: str, **kwargs) -> bool:
        """Start the model server if required."""
        pass

    @abstractmethod
    async def stop_server(self) -> bool:
        """Stop the model server."""
        pass

    @abstractmethod
    async def get_server_status(self) -> Dict[str, Any]:
        """Get the current server status."""
        pass

    def estimate_ram_usage(self, model_size_gb: float) -> float:
        """Estimate RAM usage for a model."""
        # Rule of thumb: quantized models need ~1.2x their size in RAM
        return model_size_gb * 1.2

    def calculate_model_score(self, model: ModelInfo) -> float:
        """Calculate a power/capability score for the model."""
        # Basic scoring based on size and capabilities
        base_score = 0.0

        # Size contribution (larger = more capable generally)
        if model.size_gb < 2:
            base_score += 10
        elif model.size_gb < 4:
            base_score += 20
        elif model.size_gb < 8:
            base_score += 30
        elif model.size_gb < 15:
            base_score += 40
        elif model.size_gb < 35:
            base_score += 50
        elif model.size_gb < 75:
            base_score += 60
        else:
            base_score += 70

        # Capability bonuses
        if ModelCapability.CODE in model.capabilities:
            base_score += 10
        if ModelCapability.VISION in model.capabilities:
            base_score += 5
        if ModelCapability.MULTIMODAL in model.capabilities:
            base_score += 15

        # Context window bonus
        if model.context_window >= 128000:
            base_score += 15
        elif model.context_window >= 32000:
            base_score += 10
        elif model.context_window >= 16000:
            base_score += 5

        # Popularity bonus
        if model.downloads > 10000:
            base_score += 5
        if model.likes > 100:
            base_score += 3

        return min(base_score, 100.0)


class ProviderRegistry:
    """Registry for managing all AI model providers."""

    def __init__(self):
        """Initialize the provider registry."""
        self._providers: Dict[str, BaseProvider] = {}
        self._initialized = False

    def register(self, provider: BaseProvider) -> None:
        """Register a new provider."""
        self._providers[provider.name] = provider
        logger.info(f'Registered provider: {provider.name}')

    def unregister(self, name: str) -> None:
        """Unregister a provider."""
        if name in self._providers:
            del self._providers[name]
            logger.info(f'Unregistered provider: {name}')

    def get_provider(self, name: str) -> Optional[BaseProvider]:
        """Get a specific provider by name."""
        return self._providers.get(name)

    def list_providers(self) -> List[str]:
        """List all registered provider names."""
        return list(self._providers.keys())

    async def fetch_all_models(self, force_refresh: bool = False) -> Dict[str, List[ModelInfo]]:
        """Fetch models from all registered providers."""
        results = {}
        tasks = []

        for name, provider in self._providers.items():
            tasks.append(self._fetch_provider_models(name, provider, force_refresh))

        provider_results = await asyncio.gather(*tasks, return_exceptions=True)

        for name, models in zip(self._providers.keys(), provider_results):
            if isinstance(models, Exception):
                logger.error(f'Failed to fetch models from {name}: {models}')
                results[name] = []
            else:
                results[name] = models

        return results

    async def _fetch_provider_models(
        self, name: str, provider: BaseProvider, force_refresh: bool
    ) -> List[ModelInfo]:
        """Fetch models from a single provider."""
        try:
            models = await provider.fetch_models(force_refresh)
            # Calculate scores for each model
            for model in models:
                model.score = provider.calculate_model_score(model)
            return models
        except Exception as e:
            logger.error(f'Error fetching models from {name}: {e}')
            raise

    def categorize_models(
        self, all_models: Dict[str, List[ModelInfo]]
    ) -> Dict[str, List[ModelInfo]]:
        """Categorize models by online/offline/open-source."""
        categorized = {'online': [], 'offline': [], 'open_source': [], 'proprietary': [], 'all': []}

        for provider_models in all_models.values():
            for model in provider_models:
                categorized['all'].append(model)

                if model.online:
                    categorized['online'].append(model)
                else:
                    categorized['offline'].append(model)

                if model.open_source:
                    categorized['open_source'].append(model)
                else:
                    categorized['proprietary'].append(model)

        # Sort each category by score
        for category in categorized:
            categorized[category].sort(key=lambda m: m.score, reverse=True)

        return categorized

    async def initialize_providers(self, config: Dict[str, Any]) -> None:
        """Initialize all providers with configuration."""
        from .anthropic import AnthropicProvider
        from .google import GoogleProvider
        from .huggingface import HuggingFaceProvider
        from .mlx import MLXProvider
        from .ollama import OllamaProvider
        from .openai import OpenAIProvider

        # Register providers based on configuration
        if config.get('providers', {}).get('mlx', {}).get('enabled', True):
            self.register(MLXProvider(config.get('providers', {}).get('mlx', {})))

        if config.get('providers', {}).get('ollama', {}).get('enabled', True):
            self.register(OllamaProvider(config.get('providers', {}).get('ollama', {})))

        if config.get('providers', {}).get('claude', {}).get('enabled', False):
            self.register(AnthropicProvider(config.get('providers', {}).get('claude', {})))

        if config.get('providers', {}).get('openai', {}).get('enabled', False):
            self.register(OpenAIProvider(config.get('providers', {}).get('openai', {})))

        if config.get('providers', {}).get('gemini', {}).get('enabled', False):
            self.register(GoogleProvider(config.get('providers', {}).get('gemini', {})))

        # HuggingFace is always enabled for model discovery
        self.register(HuggingFaceProvider(config.get('providers', {}).get('huggingface', {})))

        self._initialized = True
        logger.info('Provider registry initialized')


# Global registry instance
registry = ProviderRegistry()
