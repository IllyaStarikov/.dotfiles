"""
Configuration management for Cortex.
"""

import os
import yaml
import json
import logging
from pathlib import Path
from typing import Dict, Any, Optional
from dataclasses import dataclass, asdict
from datetime import datetime

logger = logging.getLogger(__name__)


@dataclass
class ConfigDefaults:
    """Default configuration values."""
    version: str = "0.1.0"
    mode: str = "offline"
    
    # Provider defaults
    providers: Dict[str, Dict[str, Any]] = None
    
    # Preferences
    preferences: Dict[str, Any] = None
    
    # Current model
    current_model: Dict[str, Any] = None
    
    # Ensemble configuration
    ensemble: Dict[str, Any] = None
    
    def __post_init__(self):
        """Initialize default values."""
        if self.providers is None:
            self.providers = {
                "mlx": {
                    "enabled": True,
                    "models_dir": "~/.cache/mlx_models",
                    "port": 8080
                },
                "ollama": {
                    "enabled": True,
                    "models_dir": "~/.ollama/models",
                    "port": 11434
                },
                "claude": {
                    "enabled": True,
                    "api_key_env": "ANTHROPIC_API_KEY"
                },
                "openai": {
                    "enabled": True,
                    "api_key_env": "OPENAI_API_KEY"
                },
                "gemini": {
                    "enabled": True,
                    "api_key_env": "GEMINI_API_KEY"
                }
            }
        
        if self.preferences is None:
            self.preferences = {
                "auto_download": False,
                "verbose_default": False,
                "theme": "dark"
            }
        
        if self.current_model is None:
            self.current_model = {}
        
        if self.ensemble is None:
            self.ensemble = {
                "enabled": False,
                "models": []
            }


class Config:
    """Configuration manager for Cortex."""
    
    DEFAULT_CONFIG_DIR = Path.home() / ".dotfiles" / "config" / "cortex"
    DEFAULT_PRIVATE_DIR = Path.home() / ".dotfiles" / ".dotfiles.private"
    
    def __init__(self, config_path: Optional[Path] = None):
        """Initialize configuration."""
        self.config_dir = config_path or self.DEFAULT_CONFIG_DIR
        self.config_file = self.config_dir / "config.yaml"
        self.env_file = self.config_dir / "cortex.env"
        self.models_cache_file = self.config_dir / "models.yaml"
        self.private_dir = self.DEFAULT_PRIVATE_DIR
        
        # Ensure directories exist
        self.config_dir.mkdir(parents=True, exist_ok=True)
        # Only create private dir if it doesn't exist - it's managed by the dotfiles repo
        if not self.private_dir.exists():
            logger.warning(f"Private directory {self.private_dir} does not exist. API keys will not be loaded.")
        
        # Load configuration
        self.data = self._load_config()
        
        # Load API keys from private directory
        self._load_api_keys()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file or create default."""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    config = yaml.safe_load(f) or {}
                logger.info(f"Loaded configuration from {self.config_file}")
            except Exception as e:
                logger.error(f"Failed to load config: {e}")
                config = {}
        else:
            config = {}
        
        # Merge with defaults
        defaults = asdict(ConfigDefaults())
        return self._merge_configs(defaults, config)
    
    def _merge_configs(self, base: Dict, override: Dict) -> Dict:
        """Recursively merge two configuration dictionaries."""
        result = base.copy()
        
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self._merge_configs(result[key], value)
            else:
                result[key] = value
        
        return result
    
    def _load_api_keys(self):
        """Load API keys from private directory."""
        if not self.private_dir.exists():
            return

        # Try multiple possible locations for API keys
        possible_files = [
            self.private_dir / "api_keys.yaml",
            self.private_dir / "api_keys.toml",
            self.private_dir / ".env",
            self.private_dir / "config" / "api_keys.yaml"
        ]

        for api_keys_file in possible_files:
            if api_keys_file.exists():
                try:
                    if api_keys_file.suffix == '.yaml' or api_keys_file.suffix == '.yml':
                        with open(api_keys_file, 'r') as f:
                            api_keys = yaml.safe_load(f) or {}
                    elif api_keys_file.suffix == '.toml':
                        import toml
                        with open(api_keys_file, 'r') as f:
                            api_keys = toml.load(f)
                    elif api_keys_file.name == '.env':
                        # Parse .env file
                        api_keys = {}
                        with open(api_keys_file, 'r') as f:
                            for line in f:
                                line = line.strip()
                                if line and not line.startswith('#') and '=' in line:
                                    key, value = line.split('=', 1)
                                    # Remove quotes if present
                                    value = value.strip('"\'')
                                    # Extract provider name from env var (e.g., ANTHROPIC_API_KEY -> anthropic)
                                    if key.endswith('_API_KEY'):
                                        provider = key[:-8].lower()
                                        api_keys[provider] = value
                    else:
                        continue

                    # Set environment variables for API keys
                    for key, value in api_keys.items():
                        if isinstance(value, str) and value:
                            env_var = f"{key.upper()}_API_KEY"
                            os.environ[env_var] = value
                            logger.debug(f"Loaded API key for {key}")

                    logger.info(f"Loaded API keys from {api_keys_file}")
                    break  # Stop after first successful load

                except Exception as e:
                    logger.warning(f"Failed to load API keys from {api_keys_file}: {e}")
                    continue
    
    def save(self):
        """Save current configuration to file."""
        try:
            with open(self.config_file, 'w') as f:
                yaml.dump(self.data, f, default_flow_style=False, sort_keys=False)
            logger.info(f"Saved configuration to {self.config_file}")
        except Exception as e:
            logger.error(f"Failed to save config: {e}")
            raise
    
    def update_current_model(self, model_info: Dict[str, Any]):
        """Update the current model configuration."""
        self.data["current_model"] = model_info
        self.save()
        self._update_env_file(model_info)
    
    def _update_env_file(self, model_info: Dict[str, Any]):
        """Update the environment file for shell integration."""
        env_content = f"""# Cortex environment variables for shell integration
# Generated at {datetime.now().isoformat()}
# Source this file or use: eval $(cortex env)

export CORTEX_PROVIDER="{model_info.get('provider', '')}"
export CORTEX_MODEL="{model_info.get('id', '')}"
"""
        
        # Add provider-specific variables
        provider = model_info.get('provider', '')
        
        if provider == 'mlx':
            env_content += f"""export CORTEX_ENDPOINT="http://localhost:{self.data['providers']['mlx']['port']}/v1"
export CORTEX_API_KEY="mlx-local-no-key-needed"

# For Neovim integration
export AVANTE_PROVIDER="openai"
export AVANTE_OPENAI_MODEL="{model_info.get('id', '')}"
export AVANTE_OPENAI_ENDPOINT="http://localhost:{self.data['providers']['mlx']['port']}/v1"
export OPENAI_API_KEY="mlx-local-no-key-needed"
"""
        elif provider == 'ollama':
            env_content += f"""export CORTEX_ENDPOINT="http://localhost:{self.data['providers']['ollama']['port']}"
export CORTEX_API_KEY=""

# For Neovim integration
export AVANTE_PROVIDER="ollama"
export AVANTE_OLLAMA_MODEL="{model_info.get('id', '')}"
export OLLAMA_HOST="http://localhost:{self.data['providers']['ollama']['port']}"
"""
        elif provider == 'claude':
            env_content += f"""export CORTEX_ENDPOINT="https://api.anthropic.com"
export CORTEX_API_KEY="${{ANTHROPIC_API_KEY}}"

# For Neovim integration
export AVANTE_PROVIDER="claude"
export AVANTE_CLAUDE_MODEL="{model_info.get('id', '')}"
"""
        elif provider == 'openai':
            env_content += f"""export CORTEX_ENDPOINT="https://api.openai.com"
export CORTEX_API_KEY="${{OPENAI_API_KEY}}"

# For Neovim integration
export AVANTE_PROVIDER="openai"
export AVANTE_OPENAI_MODEL="{model_info.get('id', '')}"
"""
        elif provider == 'gemini':
            env_content += f"""export CORTEX_ENDPOINT="https://generativelanguage.googleapis.com"
export CORTEX_API_KEY="${{GEMINI_API_KEY}}"

# For Neovim integration
export AVANTE_PROVIDER="gemini"
export AVANTE_GEMINI_MODEL="{model_info.get('id', '')}"
"""
        
        try:
            with open(self.env_file, 'w') as f:
                f.write(env_content)
            logger.info(f"Updated environment file: {self.env_file}")
        except Exception as e:
            logger.error(f"Failed to update env file: {e}")
    
    def get_api_key(self, provider: str) -> Optional[str]:
        """Get API key for a provider."""
        env_var = self.data.get("providers", {}).get(provider, {}).get("api_key_env")
        if env_var:
            return os.environ.get(env_var)
        return None
    
    def cache_models(self, models_data: Dict[str, Any]):
        """Cache model data to file."""
        try:
            cache_data = {
                "timestamp": datetime.now().isoformat(),
                "models": models_data
            }
            with open(self.models_cache_file, 'w') as f:
                yaml.dump(cache_data, f, default_flow_style=False)
            logger.debug(f"Cached model data to {self.models_cache_file}")
        except Exception as e:
            logger.warning(f"Failed to cache models: {e}")
    
    def load_models_cache(self) -> Optional[Dict[str, Any]]:
        """Load cached model data."""
        if self.models_cache_file.exists():
            try:
                with open(self.models_cache_file, 'r') as f:
                    return yaml.safe_load(f)
            except Exception as e:
                logger.warning(f"Failed to load models cache: {e}")
        return None