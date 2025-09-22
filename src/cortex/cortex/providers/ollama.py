"""
Ollama Provider for local model hosting.
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Any, Dict, List, Optional

import aiohttp

from . import BaseProvider, ModelCapability, ModelInfo, ProviderType

logger = logging.getLogger(__name__)


class OllamaProvider(BaseProvider):
    """Provider for Ollama models."""

    OLLAMA_API = 'http://localhost:11434/api'

    @property
    def provider_type(self) -> ProviderType:
        """Ollama is offline once models are downloaded."""
        return ProviderType.OFFLINE

    @property
    def requires_api_key(self) -> bool:
        """Ollama doesn't require an API key."""
        return False

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize Ollama provider."""
        super().__init__(config)
        self.port = config.get('port', 11434) if config else 11434
        self.api_url = f'http://localhost:{self.port}/api'

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch available Ollama models from API."""
        models = []

        try:
            # Get locally installed models from /api/tags
            async with aiohttp.ClientSession() as session:
                async with session.get(f'{self.api_url}/tags') as response:
                    if response.status == 200:
                        data = await response.json()
                        # API returns: models array with name, model, modified_at, size, digest, details
                        for model_data in data.get('models', []):
                            # For each model, get detailed info from /api/show
                            model_info = await self._get_model_details(session, model_data)
                            if model_info:
                                models.append(model_info)
                            else:
                                # Fallback to basic parsing if /api/show fails
                                models.append(self._parse_ollama_model(model_data))
        except Exception as e:
            logger.warning(f'Failed to fetch Ollama models: {e}')

        # Only use minimal fallback if API is completely unavailable
        if not models:
            models = self._get_minimal_fallback()

        self.models_cache = models
        self.last_fetch = datetime.now()

        return models

    async def _get_model_details(
        self, session: aiohttp.ClientSession, model_data: Dict[str, Any]
    ) -> Optional[ModelInfo]:
        """Get detailed model info from /api/show endpoint."""
        try:
            model_name = model_data.get('name', '')
            if not model_name:
                return None

            # Call /api/show for detailed metadata
            async with session.post(f'{self.api_url}/show', json={'name': model_name}) as response:
                if response.status == 200:
                    details = await response.json()

                    # Extract all available metadata from API
                    # /api/show provides: modelfile, parameters, template, details, model_info
                    model_info_data = details.get('model_info', {})
                    details_data = details.get('details', {})

                    # Get context length from model_info (e.g., llama.context_length)
                    context = 8192  # Default
                    for key, value in model_info_data.items():
                        if 'context_length' in key:
                            context = value
                            break

                    # Get size from the /api/tags data
                    size_bytes = model_data.get('size', 0)
                    size_gb = round(size_bytes / (1024**3), 1) if size_bytes else 1.0

                    # Extract capabilities from API response
                    capabilities = self._extract_capabilities_from_api(details, model_name)

                    # Get parameter size from details
                    param_size = details_data.get('parameter_size', '')

                    # Generate description from API data
                    family = details_data.get('family', '')
                    quant = details_data.get('quantization_level', '')
                    description = (
                        f'{family} {param_size} model' if family else f'Ollama model {param_size}'
                    )
                    if quant:
                        description += f' ({quant} quantization)'

                    return ModelInfo(
                        id=model_name,
                        name=model_name.split(':')[0],
                        provider='ollama',
                        size_gb=size_gb,
                        ram_gb=size_gb * 1.2,  # Estimate RAM
                        context_window=context,
                        capabilities=capabilities,
                        online=False,
                        open_source=True,
                        recommended_ram=int(size_gb * 1.5),
                        description=description,
                        metadata={
                            'downloaded': True,
                            'modified_at': model_data.get('modified_at'),
                            'digest': model_data.get('digest'),
                            'format': details_data.get('format'),
                            'family': family,
                            'parameter_size': param_size,
                            'quantization': quant,
                            'model_info': model_info_data,
                        },
                    )
        except Exception as e:
            logger.debug(f'Failed to get details for {model_data.get("name")}: {e}')
            return None

    def _extract_capabilities_from_api(
        self, details: Dict[str, Any], model_name: str
    ) -> List[ModelCapability]:
        """Extract capabilities from API response."""
        capabilities = []

        # Check the capabilities field if present
        api_caps = details.get('capabilities', [])
        if 'completion' in api_caps or not api_caps:
            capabilities.append(ModelCapability.CHAT)
        if 'vision' in api_caps:
            capabilities.append(ModelCapability.VISION)
            capabilities.append(ModelCapability.MULTIMODAL)

        # Also check model name for hints
        model_lower = model_name.lower()
        if any(
            x in model_lower for x in ['code', 'coder', 'codellama', 'deepseek-coder', 'starcoder']
        ):
            if ModelCapability.CODE not in capabilities:
                capabilities.append(ModelCapability.CODE)
        if any(x in model_lower for x in ['vision', 'llava', 'bakllava']):
            if ModelCapability.VISION not in capabilities:
                capabilities.append(ModelCapability.VISION)
                capabilities.append(ModelCapability.MULTIMODAL)

        return capabilities if capabilities else [ModelCapability.CHAT]

    def _get_minimal_fallback(self) -> List[ModelInfo]:
        """Minimal fallback when API is unavailable."""
        # Only the most essential models
        return [
            ModelInfo(
                id='llama3.2:latest',
                name='llama3.2',
                provider='ollama',
                size_gb=2.0,
                ram_gb=3.0,
                context_window=131072,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=4,
                description='Llama 3.2 model',
            ),
            ModelInfo(
                id='mistral:latest',
                name='mistral',
                provider='ollama',
                size_gb=4.1,
                ram_gb=5.0,
                context_window=32768,
                capabilities=[ModelCapability.CHAT],
                online=False,
                open_source=True,
                recommended_ram=6,
                description='Mistral model',
            ),
        ]

    def _parse_ollama_model(self, model_data: Dict[str, Any]) -> ModelInfo:
        """Parse basic Ollama model data when /api/show is unavailable."""
        # /api/tags provides: name, model, modified_at, size, digest, details
        name = model_data.get('name', 'unknown')
        size_bytes = model_data.get('size', 0)
        size_gb = round(size_bytes / (1024**3), 1) if size_bytes else 1.0

        # Use details from /api/tags
        details = model_data.get('details', {})
        param_size = details.get('parameter_size', '')
        family = details.get('family', '')
        quant = details.get('quantization_level', '')

        # Generate capabilities from model name and family
        caps = [ModelCapability.CHAT]
        name_lower = name.lower()
        if any(x in name_lower for x in ['code', 'coder']) or family == 'codellama':
            caps.append(ModelCapability.CODE)
        if any(x in name_lower for x in ['vision', 'llava']):
            caps.append(ModelCapability.VISION)
            caps.append(ModelCapability.MULTIMODAL)

        # Generate description from available data
        description = f'{family} {param_size}' if family else name.split(':')[0]
        if quant:
            description += f' ({quant})'

        return ModelInfo(
            id=name,
            name=name.split(':')[0],
            provider='ollama',
            size_gb=size_gb,
            ram_gb=size_gb * 1.2,
            context_window=8192,  # Conservative default
            capabilities=caps,
            online=False,
            open_source=True,
            recommended_ram=int(size_gb * 1.5),
            description=description,
            metadata={
                'downloaded': True,
                'modified_at': model_data.get('modified_at'),
                'digest': model_data.get('digest'),
                'format': details.get('format'),
                'family': family,
                'parameter_size': param_size,
                'quantization': quant,
            },
        )

    async def download_model(self, model_id: str, progress_callback=None) -> bool:
        """Download an Ollama model."""
        try:
            async with aiohttp.ClientSession() as session:
                data = {'name': model_id, 'stream': True}

                async with session.post(f'{self.api_url}/pull', json=data) as response:
                    if response.status != 200:
                        logger.error(f'Failed to pull model {model_id}: HTTP {response.status}')
                        return False

                    total_size = 0
                    completed = 0

                    async for line in response.content:
                        if line:
                            try:
                                # Decode and parse the JSON status
                                status = json.loads(line.decode())

                                # Parse Ollama's pull status which includes total/completed
                                if 'total' in status and 'completed' in status:
                                    total_size = status['total']
                                    completed = status['completed']

                                    if progress_callback and total_size > 0:
                                        progress_callback(completed, total_size)

                                # Check for completion
                                if status.get('status') == 'success':
                                    logger.info(f'Successfully downloaded {model_id}')
                                    return True

                                # Check for errors
                                if 'error' in status:
                                    logger.error(f'Error downloading {model_id}: {status["error"]}')
                                    return False

                            except (json.JSONDecodeError, UnicodeDecodeError):
                                pass

            return True
        except Exception as e:
            logger.error(f'Failed to download Ollama model {model_id}: {e}')
            return False

    async def is_model_available(self, model_id: str) -> bool:
        """Check if a model is available locally."""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f'{self.api_url}/tags') as response:
                    if response.status == 200:
                        data = await response.json()
                        models = data.get('models', [])
                        return any(m.get('name') == model_id for m in models)
        except (aiohttp.ClientError, asyncio.TimeoutError):
            # Ollama API may be unavailable
            pass
        return False

    async def start_server(self, model_id: str, **kwargs) -> bool:
        """Ollama server runs as a system service."""
        # Check if Ollama is running
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f'{self.api_url}/tags') as response:
                    if response.status == 200:
                        logger.info('Ollama server is already running')
                        return True
        except (aiohttp.ClientError, asyncio.TimeoutError):
            logger.error("Ollama server is not running. Please start it with 'ollama serve'")
            return False

    async def stop_server(self) -> bool:
        """Ollama server is managed externally."""
        logger.info('Ollama server is managed as a system service')
        return True

    async def get_server_status(self) -> Dict[str, Any]:
        """Get Ollama server status."""
        status = {'running': False, 'port': self.port, 'models': []}

        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f'{self.api_url}/tags') as response:
                    if response.status == 200:
                        status['running'] = True
                        data = await response.json()
                        status['models'] = [m.get('name') for m in data.get('models', [])]
        except (aiohttp.ClientError, asyncio.TimeoutError):
            # Server status might be unavailable
            pass

        return status
