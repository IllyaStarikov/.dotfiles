"""
OpenAI Provider

Provides access to GPT models via OpenAI API.
"""

from datetime import datetime
from datetime import timedelta
import logging
import os
from typing import Any, Dict, List, Optional

import aiohttp

from . import BaseProvider
from . import ModelCapability
from . import ModelInfo
from . import ProviderType

logger = logging.getLogger(__name__)


class OpenAIProvider(BaseProvider):
    """Provider for OpenAI GPT models."""

    OPENAI_API = "https://api.openai.com/v1"

    @property
    def provider_type(self) -> ProviderType:
        """OpenAI is an online API provider."""
        return ProviderType.ONLINE

    @property
    def requires_api_key(self) -> bool:
        """OpenAI requires an API key."""
        return True

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize OpenAI provider."""
        super().__init__(config)
        self.api_key = os.environ.get("OPENAI_API_KEY") or ""

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch available OpenAI models dynamically from API."""
        models = []

        # Try to fetch from API if we have a key
        if self.api_key:
            try:
                async with aiohttp.ClientSession() as session:
                    headers = {"Authorization": f"Bearer {self.api_key}"}
                    async with session.get(f"{self.OPENAI_API}/models", headers=headers,
                                           timeout=5) as response:
                        if response.status == 200:
                            data = await response.json()
                            api_models = data.get("data", [])

                            for model_data in api_models:
                                model_id = model_data.get("id", "")

                                # Only include chat/completion models
                                include_patterns = ["gpt", "o1", "o3", "text-", "chat"]
                                skip_patterns = [
                                    "whisper", "tts", "dall-e", "embedding", "moderation"
                                ]

                                # Check if we should include this model
                                should_include = any(
                                    pattern in model_id.lower() for pattern in include_patterns)
                                should_skip = any(
                                    pattern in model_id.lower() for pattern in skip_patterns)

                                if should_include and not should_skip:
                                    models.append(self._create_model_info(model_id, model_data))

                            logger.info(f"Fetched {len(models)} models from OpenAI API")
            except Exception as e:
                logger.debug(f"Could not fetch from OpenAI API: {e}")

        # Always include known models as fallback or addition
        known_models = self._get_known_models()

        # Merge known models with API results (avoiding duplicates)
        existing_ids = {m.id for m in models}
        for model in known_models:
            if model.id not in existing_ids:
                models.append(model)

        logger.info(f"Total {len(models)} OpenAI models available")
        return models

    def _get_known_models(self) -> List[ModelInfo]:
        """Get list of known OpenAI models as of January 2025."""
        known_models = [
            # O-series reasoning models
            {
                "id": "o1",
                "context": 200000,
                "output": 100000,
                "tier": "reasoning"
            },
            {
                "id": "o1-mini",
                "context": 128000,
                "output": 65536,
                "tier": "reasoning"
            },
            {
                "id": "o1-preview",
                "context": 128000,
                "output": 32768,
                "tier": "reasoning"
            },

            # GPT-4o models (multimodal)
            {
                "id": "gpt-4o",
                "context": 128000,
                "output": 16384,
                "tier": "flagship"
            },
            {
                "id": "gpt-4o-2024-11-20",
                "context": 128000,
                "output": 16384,
                "tier": "flagship"
            },
            {
                "id": "gpt-4o-2024-08-06",
                "context": 128000,
                "output": 16384,
                "tier": "flagship"
            },
            {
                "id": "gpt-4o-2024-05-13",
                "context": 128000,
                "output": 4096,
                "tier": "flagship"
            },
            {
                "id": "gpt-4o-mini",
                "context": 128000,
                "output": 16384,
                "tier": "efficient"
            },
            {
                "id": "gpt-4o-mini-2024-07-18",
                "context": 128000,
                "output": 16384,
                "tier": "efficient"
            },

            # GPT-4 Turbo models
            {
                "id": "gpt-4-turbo",
                "context": 128000,
                "output": 4096,
                "tier": "turbo"
            },
            {
                "id": "gpt-4-turbo-2024-04-09",
                "context": 128000,
                "output": 4096,
                "tier": "turbo"
            },
            {
                "id": "gpt-4-turbo-preview",
                "context": 128000,
                "output": 4096,
                "tier": "turbo"
            },
            {
                "id": "gpt-4-0125-preview",
                "context": 128000,
                "output": 4096,
                "tier": "turbo"
            },
            {
                "id": "gpt-4-1106-preview",
                "context": 128000,
                "output": 4096,
                "tier": "turbo"
            },

            # GPT-4 models
            {
                "id": "gpt-4",
                "context": 8192,
                "output": 8192,
                "tier": "standard"
            },
            {
                "id": "gpt-4-0613",
                "context": 8192,
                "output": 8192,
                "tier": "standard"
            },
            {
                "id": "gpt-4-32k",
                "context": 32768,
                "output": 8192,
                "tier": "standard"
            },
            {
                "id": "gpt-4-32k-0613",
                "context": 32768,
                "output": 8192,
                "tier": "standard"
            },

            # GPT-3.5 Turbo models
            {
                "id": "gpt-3.5-turbo",
                "context": 16385,
                "output": 4096,
                "tier": "fast"
            },
            {
                "id": "gpt-3.5-turbo-0125",
                "context": 16385,
                "output": 4096,
                "tier": "fast"
            },
            {
                "id": "gpt-3.5-turbo-1106",
                "context": 16385,
                "output": 4096,
                "tier": "fast"
            },
            {
                "id": "gpt-3.5-turbo-16k",
                "context": 16385,
                "output": 4096,
                "tier": "fast"
            },
        ]

        models = []
        for model_data in known_models:
            model_info = self._create_model_info(
                model_data["id"], {
                    "context_window": model_data["context"],
                    "max_output_tokens": model_data["output"],
                    "tier": model_data["tier"]
                })
            models.append(model_info)

        return models

    def _get_fallback_models(self) -> List[ModelInfo]:
        """Minimal fallback list if API is unavailable."""
        # Just the most essential models
        return self._get_known_models()[:6]

    def _create_model_info(self, model_id: str, api_data: Dict[str, Any]) -> ModelInfo:
        """Create ModelInfo using API data and minimal inference."""
        # OpenAI API provides: id, object, created, owned_by, parent, root, permission
        created = api_data.get("created")
        owned_by = api_data.get("owned_by", "openai")
        parent = api_data.get("parent")

        # Format name from ID
        name = self._format_model_name(model_id)

        # Check permissions for capabilities
        permissions = api_data.get("permission", [])
        capabilities = self._extract_capabilities_from_permissions(permissions, model_id)

        # Default context/output - OpenAI doesn't provide these in /models
        # Using reasonable defaults, not hardcoded per model
        context = 128000 if "gpt-4" in model_id.lower() else 16384 if "turbo" in model_id.lower(
        ) else 8192
        output = 4096  # Standard for most models

        # Embedding models have different defaults
        if "embedding" in model_id.lower():
            capabilities = [ModelCapability.EMBEDDING]
            output = 0
            context = 8191

        # Calculate score based on creation date and model family
        score = self._calculate_score(created, model_id)

        # Generate description from model type
        description = self._generate_description(model_id, owned_by)

        return ModelInfo(id=model_id,
                         name=name,
                         provider="openai",
                         size_gb=0,
                         ram_gb=0,
                         context_window=context,
                         capabilities=capabilities,
                         online=True,
                         open_source=False,
                         recommended_ram=0,
                         description=description or f"OpenAI model: {name}",
                         metadata={
                             "output_tokens": output,
                             "available": self._check_api_key(),
                             "from_api": bool(api_data),
                             "created": created,
                             "owned_by": owned_by
                         })

    def _format_model_name(self, model_id: str) -> str:
        """Format model ID into display name."""
        # Basic formatting - convert ID to readable name
        name = model_id

        # Remove common prefixes
        if name.startswith("gpt-"):
            name = "GPT-" + name[4:]
        elif name.startswith("o1-") or name == "o1":
            name = "O1" + (" " + name[3:] if len(name) > 2 else "")
        elif name.startswith("text-"):
            name = "Text " + name[5:]

        # Capitalize parts
        parts = name.split("-")
        formatted = []
        for part in parts:
            if part.lower() in ["gpt", "o1", "o3"]:
                formatted.append(part.upper())
            elif part.replace(".", "").isdigit():
                formatted.append(part)
            elif part.lower() in ["mini", "turbo", "vision", "audio", "realtime", "instruct"]:
                formatted.append(part.title())
            elif len(part) == 4 and part.isdigit() and part[0] == "0":
                # Date in MMDD format
                try:
                    month = int(part[:2])
                    months = [
                        "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
                        "Nov", "Dec"
                    ]
                    formatted.append(f"({months[month]})")
                except:
                    formatted.append(part)
            else:
                formatted.append(part.title())

        return " ".join(formatted)

    def _extract_capabilities_from_permissions(self, permissions: list,
                                               model_id: str) -> List[ModelCapability]:
        """Extract capabilities from permissions and model ID."""
        capabilities = []

        # Check permissions for hints
        for perm in permissions:
            if isinstance(perm, dict):
                if perm.get("allow_fine_tuning"):
                    # Fine-tunable models are usually text generation
                    if ModelCapability.CHAT not in capabilities:
                        capabilities.append(ModelCapability.CHAT)

        # Basic inference from model ID
        model_lower = model_id.lower()
        if "embedding" in model_lower:
            return [ModelCapability.EMBEDDING]
        elif any(x in model_lower for x in ["gpt", "o1", "o3", "turbo", "davinci"]):
            if ModelCapability.CHAT not in capabilities:
                capabilities.append(ModelCapability.CHAT)
            # Most GPT models support code
            if "instruct" not in model_lower:
                capabilities.append(ModelCapability.CODE)
            # Vision support
            if "vision" in model_lower or "4o" in model_lower:
                capabilities.append(ModelCapability.VISION)
            # Multimodal
            if "audio" in model_lower or "realtime" in model_lower or "4o" in model_lower:
                if "mini" not in model_lower:
                    capabilities.append(ModelCapability.MULTIMODAL)

        return capabilities if capabilities else [ModelCapability.CHAT]

    def _calculate_score(self, created: int, model_id: str) -> int:
        """Calculate score based on creation date and model family."""
        model_lower = model_id.lower()

        # Base score from model family
        if "o1" in model_lower or "o3" in model_lower:
            base = 95
        elif "gpt-4o" in model_lower:
            base = 90 if "mini" not in model_lower else 75
        elif "gpt-4" in model_lower:
            base = 85
        elif "gpt-3.5" in model_lower:
            base = 70
        elif "embedding" in model_lower:
            base = 50
        else:
            base = 60

        # Adjust for recency if created date provided
        if created:
            from datetime import datetime
            created_date = datetime.fromtimestamp(created)
            days_old = (datetime.now() - created_date).days
            if days_old < 30:
                base += 3
            elif days_old < 90:
                base += 2
            elif days_old < 180:
                base += 1

        return min(99, base)

    def _generate_description(self, model_id: str, owned_by: str) -> str:
        """Generate description based on model type."""
        model_lower = model_id.lower()

        if "embedding" in model_lower:
            return "Text embedding model"
        elif "o1" in model_lower or "o3" in model_lower:
            return "Advanced reasoning model"
        elif "gpt-4o" in model_lower:
            return "Multimodal GPT-4 optimized model"
        elif "gpt-4" in model_lower:
            return "Advanced language model"
        elif "gpt-3.5" in model_lower:
            return "Fast and efficient model"
        else:
            return f"OpenAI model by {owned_by}"

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
            "running": True,
            "type": "api",
            "api_key_configured": self._check_api_key(),
            "endpoint": self.OPENAI_API
        }
