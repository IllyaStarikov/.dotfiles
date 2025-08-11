"""
Cortex - Unified AI Model Management System

A production-grade AI model management system that provides unified access 
to multiple AI providers with seamless terminal and Neovim integration.
"""

__version__ = "0.1.0"
__author__ = "Cortex Team"

from .core import Cortex
from .config import Config
from .providers import ProviderRegistry

__all__ = ["Cortex", "Config", "ProviderRegistry"]