"""
Tests for config.py module.
"""

import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import yaml
from cortex.config import Config, ConfigDefaults


class TestConfigDefaults(unittest.TestCase):
    """Test ConfigDefaults dataclass."""

    def test_defaults_initialization(self):
        """Test that defaults are properly initialized."""
        defaults = ConfigDefaults()

        self.assertEqual(defaults.version, '0.1.0')
        self.assertEqual(defaults.mode, 'offline')

        # Check providers
        self.assertIn('mlx', defaults.providers)
        self.assertIn('ollama', defaults.providers)
        self.assertIn('claude', defaults.providers)
        self.assertIn('openai', defaults.providers)
        self.assertIn('gemini', defaults.providers)

        # Check MLX is enabled by default
        self.assertTrue(defaults.providers['mlx']['enabled'])
        self.assertEqual(defaults.providers['mlx']['port'], 8080)

        # Check preferences
        self.assertFalse(defaults.preferences['auto_download'])
        self.assertEqual(defaults.preferences['theme'], 'dark')


class TestConfig(unittest.TestCase):
    """Test Config class."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.config_dir = Path(self.temp_dir) / 'config'
        self.private_dir = Path(self.temp_dir) / 'private'
        self.config_dir.mkdir(parents=True)
        self.private_dir.mkdir(parents=True)

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil

        shutil.rmtree(self.temp_dir)

    def test_config_initialization(self):
        """Test Config initialization."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                self.assertEqual(config.config_dir, self.config_dir)
                self.assertTrue(config.config_file.exists())
                self.assertIsInstance(config.data, dict)

    def test_load_config_from_file(self):
        """Test loading configuration from existing file."""
        # Create a config file
        config_data = {
            'version': '0.2.0',
            'mode': 'online',
            'current_model': {'id': 'test-model', 'provider': 'test'},
        }

        config_file = self.config_dir / 'config.yaml'
        with open(config_file, 'w') as f:
            yaml.dump(config_data, f)

        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                self.assertEqual(config.data['version'], '0.2.0')
                self.assertEqual(config.data['mode'], 'online')
                self.assertEqual(config.data['current_model']['id'], 'test-model')

    def test_load_api_keys_from_yaml(self):
        """Test loading API keys from YAML file."""
        # Create API keys file
        api_keys = {
            'anthropic': 'test-anthropic-key',
            'openai': 'test-openai-key',
            'gemini': 'test-gemini-key',
        }

        api_keys_file = self.private_dir / 'api_keys.yaml'
        with open(api_keys_file, 'w') as f:
            yaml.dump(api_keys, f)

        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                # Check environment variables were set
                self.assertEqual(os.environ.get('ANTHROPIC_API_KEY'), 'test-anthropic-key')
                self.assertEqual(os.environ.get('OPENAI_API_KEY'), 'test-openai-key')
                self.assertEqual(os.environ.get('GEMINI_API_KEY'), 'test-gemini-key')

    def test_load_api_keys_from_env_file(self):
        """Test loading API keys from .env file."""
        # Create .env file
        env_content = """
ANTHROPIC_API_KEY=env-anthropic-key
OPENAI_API_KEY=env-openai-key
GEMINI_API_KEY=env-gemini-key
# Comment line
INVALID_LINE
KEY_WITHOUT_VALUE=
"""

        env_file = self.private_dir / '.env'
        with open(env_file, 'w') as f:
            f.write(env_content)

        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                # Check environment variables were set
                self.assertEqual(os.environ.get('ANTHROPIC_API_KEY'), 'env-anthropic-key')
                self.assertEqual(os.environ.get('OPENAI_API_KEY'), 'env-openai-key')
                self.assertEqual(os.environ.get('GEMINI_API_KEY'), 'env-gemini-key')

    def test_update_current_model(self):
        """Test updating current model configuration."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                model_info = {'id': 'gpt-4', 'name': 'GPT-4', 'provider': 'openai', 'online': True}

                config.update_current_model(model_info)

                self.assertEqual(config.data['current_model']['id'], 'gpt-4')
                self.assertEqual(config.data['current_model']['provider'], 'openai')

                # Check that env file was created
                self.assertTrue(config.env_file.exists())

    def test_save_configuration(self):
        """Test saving configuration to file."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                # Modify configuration
                config.data['test_key'] = 'test_value'
                config.save()

                # Load the saved file
                with open(config.config_file, 'r') as f:
                    saved_data = yaml.safe_load(f)

                self.assertEqual(saved_data['test_key'], 'test_value')

    def test_merge_configs(self):
        """Test configuration merging."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                base = {'a': 1, 'b': {'c': 2, 'd': 3}}
                override = {'b': {'c': 4, 'e': 5}, 'f': 6}

                result = config._merge_configs(base, override)

                self.assertEqual(result['a'], 1)
                self.assertEqual(result['b']['c'], 4)  # Overridden
                self.assertEqual(result['b']['d'], 3)  # Preserved
                self.assertEqual(result['b']['e'], 5)  # Added
                self.assertEqual(result['f'], 6)  # Added

    def test_env_file_generation_for_mlx(self):
        """Test environment file generation for MLX provider."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                model_info = {'id': 'mlx-community/test-model', 'provider': 'mlx'}

                config.update_current_model(model_info)

                # Read the env file
                with open(config.env_file, 'r') as f:
                    env_content = f.read()

                self.assertIn('CORTEX_PROVIDER="mlx"', env_content)
                self.assertIn('CORTEX_MODEL="mlx-community/test-model"', env_content)
                self.assertIn('AVANTE_PROVIDER="openai"', env_content)
                self.assertIn('AVANTE_OPENAI_ENDPOINT=', env_content)

    def test_env_file_generation_for_claude(self):
        """Test environment file generation for Claude provider."""
        with patch.object(Config, 'DEFAULT_CONFIG_DIR', self.config_dir):
            with patch.object(Config, 'DEFAULT_PRIVATE_DIR', self.private_dir):
                Config()  # Config initialization sets environment variables

                model_info = {'id': 'claude-3-opus', 'provider': 'claude'}

                config.update_current_model(model_info)

                # Read the env file
                with open(config.env_file, 'r') as f:
                    env_content = f.read()

                self.assertIn('CORTEX_PROVIDER="claude"', env_content)
                self.assertIn('CORTEX_MODEL="claude-3-opus"', env_content)
                self.assertIn('AVANTE_PROVIDER="claude"', env_content)


if __name__ == '__main__':
    unittest.main()
