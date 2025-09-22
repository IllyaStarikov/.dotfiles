"""
Google Gemini Provider

Provides access to Gemini models via Google AI API.
"""

import logging
import os
from typing import Any, Dict, List, Optional

import aiohttp

from . import BaseProvider, ModelCapability, ModelInfo, ProviderType

logger = logging.getLogger(__name__)


class GoogleProvider(BaseProvider):
    """Provider for Google Gemini models."""

    GOOGLE_AI_API = 'https://generativelanguage.googleapis.com/v1beta'

    # Minimal fallback for when API is unavailable
    FALLBACK_MODELS = [
        'gemini-2.0-flash-exp',
        'gemini-1.5-pro-latest',
        'gemini-1.5-flash-latest',
        'gemini-1.0-pro',
    ]

    @property
    def provider_type(self) -> ProviderType:
        """Google is an online API provider."""
        return ProviderType.ONLINE

    @property
    def requires_api_key(self) -> bool:
        """Google requires an API key."""
        return True

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize Google provider."""
        super().__init__(config)
        self.api_key = (
            os.environ.get('GEMINI_API_KEY')
            or os.environ.get('GOOGLE_API_KEY')
            or os.environ.get('GOOGLE_AI_API_KEY')
            or ''
        )

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch available Gemini models."""
        models = []

        # Known Gemini models as of January 2025
        known_models = [
            # Gemini 2.0 Flash (Experimental)
            {
                'id': 'gemini-2.0-flash-exp',
                'name': 'Gemini 2.0 Flash Experimental',
                'context': 1048576,
                'output': 8192,
                'tier': 'experimental',
            },
            {
                'id': 'gemini-2.0-flash-thinking-exp',
                'name': 'Gemini 2.0 Flash Thinking',
                'context': 32767,
                'output': 8192,
                'tier': 'experimental',
            },
            # Gemini 1.5 Pro models
            {
                'id': 'gemini-1.5-pro',
                'name': 'Gemini 1.5 Pro',
                'context': 2097152,
                'output': 8192,
                'tier': 'pro',
            },
            {
                'id': 'gemini-1.5-pro-latest',
                'name': 'Gemini 1.5 Pro Latest',
                'context': 2097152,
                'output': 8192,
                'tier': 'pro',
            },
            {
                'id': 'gemini-1.5-pro-002',
                'name': 'Gemini 1.5 Pro 002',
                'context': 2097152,
                'output': 8192,
                'tier': 'pro',
            },
            {
                'id': 'gemini-1.5-pro-001',
                'name': 'Gemini 1.5 Pro 001',
                'context': 2097152,
                'output': 8192,
                'tier': 'pro',
            },
            # Gemini 1.5 Flash models
            {
                'id': 'gemini-1.5-flash',
                'name': 'Gemini 1.5 Flash',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            {
                'id': 'gemini-1.5-flash-latest',
                'name': 'Gemini 1.5 Flash Latest',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            {
                'id': 'gemini-1.5-flash-002',
                'name': 'Gemini 1.5 Flash 002',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            {
                'id': 'gemini-1.5-flash-001',
                'name': 'Gemini 1.5 Flash 001',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            {
                'id': 'gemini-1.5-flash-8b',
                'name': 'Gemini 1.5 Flash 8B',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            {
                'id': 'gemini-1.5-flash-8b-latest',
                'name': 'Gemini 1.5 Flash 8B Latest',
                'context': 1048576,
                'output': 8192,
                'tier': 'flash',
            },
            # Gemini 1.0 Pro (Legacy)
            {
                'id': 'gemini-1.0-pro',
                'name': 'Gemini 1.0 Pro',
                'context': 32768,
                'output': 8192,
                'tier': 'legacy',
            },
            {
                'id': 'gemini-1.0-pro-latest',
                'name': 'Gemini 1.0 Pro Latest',
                'context': 32768,
                'output': 8192,
                'tier': 'legacy',
            },
            {
                'id': 'gemini-1.0-pro-001',
                'name': 'Gemini 1.0 Pro 001',
                'context': 32768,
                'output': 8192,
                'tier': 'legacy',
            },
            # Gemini Pro Vision (Legacy)
            {
                'id': 'gemini-pro-vision',
                'name': 'Gemini Pro Vision',
                'context': 16384,
                'output': 2048,
                'tier': 'legacy',
            },
        ]

        fetched_ids = set()

        # Try to fetch from API if we have a key
        if self.api_key:
            try:
                async with aiohttp.ClientSession() as session:
                    url = f'{self.GOOGLE_AI_API}/models?key={self.api_key}'
                    async with session.get(url, timeout=5) as response:
                        if response.status == 200:
                            data = await response.json()
                            api_models = data.get('models', [])

                            for model_data in api_models:
                                model_name = model_data.get('name', '')
                                model_id = (
                                    model_name.split('/')[-1] if '/' in model_name else model_name
                                )

                                # Only include generative models
                                if 'gemini' in model_id.lower():
                                    fetched_ids.add(model_id)
                                    # Find known model data or use defaults
                                    known = next(
                                        (m for m in known_models if m['id'] == model_id), None
                                    )
                                    if known:
                                        metadata = self._infer_model_metadata(
                                            model_id,
                                            {
                                                **model_data,
                                                'context': known['context'],
                                                'output': known['output'],
                                                'tier': known['tier'],
                                            },
                                        )
                                    else:
                                        metadata = self._infer_model_metadata(model_id, model_data)

                                    model_info = ModelInfo(
                                        id=model_id,
                                        name=metadata['name'],
                                        provider='gemini',
                                        size_gb=0,
                                        ram_gb=0,
                                        context_window=metadata['context'],
                                        capabilities=metadata['capabilities'],
                                        online=True,
                                        open_source=False,
                                        recommended_ram=0,
                                        description=metadata['description'],
                                        metadata={
                                            'output_tokens': metadata['output'],
                                            'available': True,
                                            'from_api': True,
                                        },
                                    )
                                    model_info.score = metadata['score']
                                    models.append(model_info)

                            logger.info(f'Fetched {len(models)} models from Google AI API')
            except Exception as e:
                logger.warning(f'Failed to fetch from Google AI API: {e}')

        # Add known models that weren't fetched from API
        existing_ids = {m.id for m in models}
        for known in known_models:
            if known['id'] not in existing_ids:
                metadata = self._infer_model_metadata(
                    known['id'],
                    {
                        'context': known['context'],
                        'output': known['output'],
                        'tier': known.get('tier', 'standard'),
                        'displayName': known['name'],
                    },
                )

                model_info = ModelInfo(
                    id=known['id'],
                    name=known['name'],
                    provider='gemini',
                    size_gb=0,
                    ram_gb=0,
                    context_window=known['context'],
                    capabilities=metadata['capabilities'],
                    online=True,
                    open_source=False,
                    recommended_ram=0,
                    description=metadata['description'],
                    metadata={
                        'output_tokens': known['output'],
                        'available': self._check_api_key(),
                        'from_api': False,
                    },
                )
                model_info.score = metadata['score']
                models.append(model_info)

        logger.info(f'Total {len(models)} Gemini models available')
        return models

    def _infer_model_metadata(self, model_id: str, model_data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract metadata from API response - Google provides excellent metadata!"""
        # Google API provides: name, baseModelId, version, displayName, description,
        # inputTokenLimit, outputTokenLimit, supportedGenerationMethods, temperature,
        # maxTemperature, topP, topK, thinking

        # Use ALL available API fields
        metadata = {
            'name': model_data.get('displayName') or self._format_model_name(model_id),
            'context': model_data.get('inputTokenLimit', 32768),
            'output': model_data.get('outputTokenLimit', 8192),
            'capabilities': self._extract_capabilities_from_api(model_data),
            'description': model_data.get('description', ''),
            'score': self._calculate_score_from_api(model_data, model_id),
            # Store additional API metadata
            'version': model_data.get('version'),
            'base_model': model_data.get('baseModelId'),
            'temperature': model_data.get('temperature'),
            'max_temperature': model_data.get('maxTemperature'),
            'top_p': model_data.get('topP'),
            'top_k': model_data.get('topK'),
            'thinking': model_data.get('thinking', False),
        }

        # If description is empty, generate one from available data
        if not metadata['description']:
            if metadata.get('thinking'):
                metadata['description'] = 'Reasoning model with transparent thinking'
            elif metadata['context'] >= 1000000:
                metadata['description'] = (
                    f'Model with {metadata["context"] // 1000000}M token context'
                )
            elif 'embedding' in model_id.lower():
                metadata['description'] = 'Text embedding model'
            else:
                metadata['description'] = f'Gemini model v{metadata.get("version", "1.0")}'

        return metadata

    def _format_model_name(self, model_id: str) -> str:
        """Format model ID into display name when API doesn't provide one."""
        # Remove models/ prefix if present
        if model_id.startswith('models/'):
            model_id = model_id[7:]

        # Convert gemini-x.y-type to Gemini X.Y Type
        parts = model_id.split('-')
        if parts[0].lower() == 'gemini':
            name_parts = ['Gemini']
            i = 1
            while i < len(parts):
                if parts[i].replace('.', '').isdigit():
                    # Version number
                    name_parts.append(parts[i])
                elif parts[i] in ['pro', 'flash', 'nano', 'ultra']:
                    name_parts.append(parts[i].title())
                elif parts[i] == 'exp':
                    name_parts.append('Experimental')
                elif parts[i] == '8b':
                    name_parts.append('8B')
                elif parts[i] == 'vision':
                    name_parts.append('Vision')
                elif parts[i] == 'thinking':
                    name_parts.append('Thinking')
                elif parts[i].isdigit() and len(parts[i]) >= 3:
                    # Skip version numbers like 001, 002
                    pass
                else:
                    name_parts.append(parts[i].title())
                i += 1
            return ' '.join(name_parts)

        # For embedding models
        if 'embedding' in model_id.lower():
            return model_id.replace('-', ' ').title()

        return model_id

    def _extract_capabilities_from_api(self, model_data: Dict[str, Any]) -> List[ModelCapability]:
        """Extract capabilities from API response data."""
        capabilities = []

        # Check supported generation methods from API
        methods = model_data.get('supportedGenerationMethods', [])
        if 'generateContent' in methods or 'generateAnswer' in methods:
            capabilities.append(ModelCapability.CHAT)
        if 'embedContent' in methods or 'embedText' in methods:
            return [ModelCapability.EMBEDDING]  # Embedding models only do embedding

        # Check model name/baseModelId for capabilities
        model_name = model_data.get('name', '').lower()
        base_model = model_data.get('baseModelId', '').lower()

        # Vision capability
        if 'vision' in model_name or 'vision' in base_model:
            capabilities.append(ModelCapability.VISION)

        # Check description for multimodal hints
        description = model_data.get('description', '').lower()
        if any(x in description for x in ['multimodal', 'image', 'video', 'audio']):
            if ModelCapability.VISION not in capabilities:
                capabilities.append(ModelCapability.VISION)
            capabilities.append(ModelCapability.MULTIMODAL)

        # Code capability - most non-embedding Gemini models support code
        if capabilities and ModelCapability.EMBEDDING not in capabilities:
            if 'generateContent' in methods:
                capabilities.append(ModelCapability.CODE)

        # Thinking capability
        if model_data.get('thinking'):
            # Thinking models focus on reasoning/code
            if ModelCapability.CODE not in capabilities:
                capabilities.append(ModelCapability.CODE)

        return capabilities if capabilities else [ModelCapability.CHAT]

    def _calculate_score_from_api(self, model_data: Dict[str, Any], model_id: str) -> int:
        """Calculate score based on API data."""
        score = 70  # Base score

        # Adjust based on version
        version = model_data.get('version', '')
        if version:
            try:
                v = float(version)
                if v >= 2.0:
                    score += 20
                elif v >= 1.5:
                    score += 15
                elif v >= 1.0:
                    score += 5
            except:
                pass

        # Adjust based on context size
        context = model_data.get('inputTokenLimit', 0)
        if context >= 2000000:
            score += 10
        elif context >= 1000000:
            score += 8
        elif context >= 128000:
            score += 5
        elif context >= 32000:
            score += 2

        # Thinking models get bonus
        if model_data.get('thinking'):
            score += 5

        # Model tier inference from name
        model_lower = model_id.lower()
        if 'pro' in model_lower and '1.5' in model_lower:
            score += 5
        elif 'flash' in model_lower and '8b' not in model_lower:
            score += 3
        elif '8b' in model_lower:
            score -= 5

        return min(99, score)

    def _check_api_key(self) -> bool:
        """Check if API key is configured."""
        return bool(self.api_key and len(self.api_key) > 10)

    async def download_model(self, model_id: str, progress_callback=None) -> bool:
        """Cloud models don't need downloading."""
        return True

    async def is_model_available(self, model_id: str) -> bool:
        """Check if model is available (API key configured)."""
        return self._check_api_key()

    async def start_server(self, model_id: str, **kwargs) -> bool:
        """No server needed for API access."""
        return True

    async def stop_server(self) -> bool:
        """No server to stop."""
        return True

    async def get_server_status(self) -> Dict[str, Any]:
        """Get API status."""
        return {
            'running': True,
            'type': 'api',
            'api_key_configured': self._check_api_key(),
            'endpoint': self.GOOGLE_AI_API,
        }
