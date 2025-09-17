"""
Anthropic Claude Provider

Provides access to Claude models via Anthropic API.
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


class AnthropicProvider(BaseProvider):
    """Provider for Anthropic Claude models."""

    ANTHROPIC_API = "https://api.anthropic.com/v1"

    @property
    def provider_type(self) -> ProviderType:
        """Anthropic is an online API provider."""
        return ProviderType.ONLINE

    @property
    def requires_api_key(self) -> bool:
        """Anthropic requires an API key."""
        return True

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize Anthropic provider."""
        super().__init__(config)
        # Try multiple environment variable names
        self.api_key = (os.environ.get("ANTHROPIC_API_KEY") or os.environ.get("CLAUDE_API_KEY") or
                        "")

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch available Claude models."""
        models = []

        # Always use the known Claude models list since Anthropic doesn't have a public models endpoint
        # These are the current Claude models as of January 2025
        known_models = [
            # Claude 3.5 Models
            {
                "id": "claude-3-5-sonnet-20241022",
                "name": "Claude 3.5 Sonnet (Oct 2024)",
                "tier": "sonnet",
                "context": 200000,
                "output": 8192
            },
            {
                "id": "claude-3-5-haiku-20241022",
                "name": "Claude 3.5 Haiku (Oct 2024)",
                "tier": "haiku",
                "context": 200000,
                "output": 8192
            },

            # Claude 3 Opus
            {
                "id": "claude-3-opus-20240229",
                "name": "Claude 3 Opus",
                "tier": "opus",
                "context": 200000,
                "output": 4096
            },

            # Claude 3 Sonnet
            {
                "id": "claude-3-sonnet-20240229",
                "name": "Claude 3 Sonnet",
                "tier": "sonnet",
                "context": 200000,
                "output": 4096
            },

            # Claude 3 Haiku
            {
                "id": "claude-3-haiku-20240307",
                "name": "Claude 3 Haiku",
                "tier": "haiku",
                "context": 200000,
                "output": 4096
            },

            # Claude 2 Models (Legacy)
            {
                "id": "claude-2.1",
                "name": "Claude 2.1",
                "tier": "legacy",
                "context": 200000,
                "output": 4096
            },
            {
                "id": "claude-2.0",
                "name": "Claude 2.0",
                "tier": "legacy",
                "context": 100000,
                "output": 4096
            },

            # Claude Instant (Legacy)
            {
                "id": "claude-instant-1.2",
                "name": "Claude Instant 1.2",
                "tier": "instant",
                "context": 100000,
                "output": 4096
            },
        ]

        for model_data in known_models:
            model_info = self._create_model_info(
                model_data["id"], {
                    "name": model_data["name"],
                    "tier": model_data["tier"],
                    "context_window": model_data["context"],
                    "max_output_tokens": model_data["output"]
                })
            models.append(model_info)

        logger.info(f"Loaded {len(models)} Claude models")
        return models

    async def _probe_available_models(self, session, headers) -> List[ModelInfo]:
        """Probe for available models by testing completions endpoint."""
        models = []

        # Minimal list of model IDs to probe - these are the known patterns
        probe_ids = [
            # Just probe the base names, we'll expand variants if they work
            "claude-opus-4-1",
            "claude-opus-4",
            "claude-sonnet-4",
            "claude-3-7-sonnet",
            "claude-3-5-sonnet",
            "claude-3-5-haiku",
            "claude-3-opus",
            "claude-3-sonnet",
            "claude-3-haiku",
            "claude-2.1",
            "claude-2.0",
            "claude-instant-1.2"
        ]

        for model_id in probe_ids:
            try:
                # Try a minimal completion to see if model exists
                payload = {
                    "model": model_id,
                    "messages": [{
                        "role": "user",
                        "content": "Hi"
                    }],
                    "max_tokens": 1
                }

                async with session.post(f"{self.ANTHROPIC_API}/messages",
                                        headers=headers,
                                        json=payload,
                                        timeout=aiohttp.ClientTimeout(total=5)) as response:
                    if response.status in [200, 400]:  # 400 might mean model exists but bad params
                        models.append(self._create_model_info(model_id, {}))

                        # If base model works, try dated versions
                        if response.status == 200:
                            await self._probe_model_variants(session, headers, model_id, models)

            except Exception:
                pass

        return models

    async def _probe_model_variants(self, session, headers, base_model_id: str,
                                    models: List[ModelInfo]):
        """Probe for dated variants of a model."""
        # Common date patterns to try
        date_patterns = [
            "20250805",
            "20250514",
            "20250219",  # 2025 dates
            "20241022",
            "20240620",
            "20240307",
            "20240229",  # 2024 dates
        ]

        for date in date_patterns:
            variant_id = f"{base_model_id}-{date}"
            try:
                payload = {
                    "model": variant_id,
                    "messages": [{
                        "role": "user",
                        "content": "Hi"
                    }],
                    "max_tokens": 1
                }

                async with session.post(f"{self.ANTHROPIC_API}/messages",
                                        headers=headers,
                                        json=payload,
                                        timeout=aiohttp.ClientTimeout(total=5)) as response:
                    if response.status in [200, 400]:
                        models.append(self._create_model_info(variant_id, {}))
            except:
                pass

    def _get_fallback_models(self) -> List[ModelInfo]:
        """Get minimal fallback list of known models."""
        # Absolute minimal list - just the main models
        fallback_ids = [
            "claude-opus-4-1-20250805", "claude-opus-4-20250514", "claude-sonnet-4-20250514",
            "claude-3-7-sonnet-20250219", "claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022",
            "claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-3-haiku-20240307",
            "claude-2.1", "claude-2.0", "claude-instant-1.2"
        ]

        return [self._create_model_info(model_id, {}) for model_id in fallback_ids]

    def _create_model_info(self, model_id: str, api_data: Dict[str, Any]) -> ModelInfo:
        """Create ModelInfo using ONLY API data when available."""
        # Anthropic API provides: created_at, display_name, id, type
        # Use display_name from API if available
        name = api_data.get("display_name") or self._format_model_name(model_id)

        # Since Anthropic API doesn't provide these, we use reasonable defaults
        # These are NOT hardcoded per model - just sensible defaults
        context = 200000  # Most Claude models support 200k
        output = 8192  # Standard output for most models

        # All Claude models support these basic capabilities
        capabilities = [ModelCapability.CHAT, ModelCapability.CODE]

        # Add vision for Claude 3+ models (based on version in ID)
        if any(x in model_id.lower() for x in ["claude-3", "claude-4", "opus", "sonnet", "haiku"]):
            if "instant" not in model_id.lower():
                capabilities.append(ModelCapability.VISION)

        # Claude 4 models are multimodal
        if "claude-4" in model_id.lower() or "opus-4" in model_id.lower(
        ) or "sonnet-4" in model_id.lower():
            capabilities.append(ModelCapability.MULTIMODAL)

        # Use created_at from API to determine relative age/capability
        created_at = api_data.get("created_at")
        score = self._calculate_score_from_created_date(created_at, model_id)

        description = f"{name} - Anthropic language model"

        return ModelInfo(
            id=model_id,
            name=name,
            provider="claude",
            size_gb=0,  # Cloud model
            ram_gb=0,  # Cloud model
            context_window=context,
            capabilities=capabilities,
            online=True,
            open_source=False,
            recommended_ram=0,
            description=description or f"Claude model: {name}",
            metadata={
                "output_tokens": output,
                "available": self._check_api_key(),
                "from_api": bool(api_data)
            })

    def _format_model_name(self, model_id: str) -> str:
        """Format model ID into a display name when API doesn't provide one."""
        # Remove claude- prefix for cleaner name
        name = model_id
        if name.startswith("claude-"):
            name = name[7:]

        # Convert to title case and replace hyphens
        parts = name.split("-")
        formatted_parts = []

        for part in parts:
            if part.replace(".", "").isdigit():
                # Version numbers
                formatted_parts.append(part)
            elif len(part) == 8 and part.isdigit():
                # Date in YYYYMMDD format
                try:
                    year = part[:4]
                    month = int(part[4:6])
                    months = [
                        "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
                        "Nov", "Dec"
                    ]
                    formatted_parts.append(f"({months[month]} {year})")
                except:
                    pass
            else:
                formatted_parts.append(part.title())

        return "Claude " + " ".join(formatted_parts)

    def _calculate_score_from_created_date(self, created_at: str, model_id: str) -> int:
        """Calculate a score based on creation date and model tier."""
        # Base score from model tier (inferred from name)
        model_lower = model_id.lower()

        if "opus" in model_lower:
            base_score = 90
        elif "sonnet" in model_lower:
            base_score = 80
        elif "haiku" in model_lower:
            base_score = 70
        elif "instant" in model_lower:
            base_score = 50
        else:
            base_score = 60

        # Adjust based on version if present
        if "4" in model_id:
            base_score += 5
        elif "3.7" in model_id or "3-7" in model_id:
            base_score += 3
        elif "3.5" in model_id or "3-5" in model_id:
            base_score += 2
        elif "3" in model_id:
            base_score += 1

        # Newer models get slight bonus based on created_at
        if created_at:
            try:
                from datetime import datetime
                created_date = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                days_old = (datetime.now(created_date.tzinfo) - created_date).days
                if days_old < 30:
                    base_score += 2
                elif days_old < 90:
                    base_score += 1
            except:
                pass

        return min(99, base_score)  # Cap at 99

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
            "endpoint": "https://api.anthropic.com"
        }
