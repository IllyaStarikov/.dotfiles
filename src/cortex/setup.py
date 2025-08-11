"""
Cortex - Unified AI Model Management System
Setup configuration for the Cortex package
"""

from setuptools import setup, find_packages
import os

# Read the README file
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Read requirements
def read_requirements(filename):
    """Read requirements from file."""
    req_path = os.path.join(os.path.dirname(__file__), filename)
    if os.path.exists(req_path):
        with open(req_path, "r", encoding="utf-8") as f:
            return [line.strip() for line in f if line.strip() and not line.startswith("#")]
    return []

setup(
    name="cortex-ai",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="Unified AI model management system for terminal and Neovim integration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/cortex",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: POSIX :: Linux",
    ],
    python_requires=">=3.9",
    install_requires=[
        "rich>=13.0.0",
        "click>=8.0.0",
        "pyyaml>=6.0",
        "requests>=2.31.0",
        "aiohttp>=3.9.0",
        "huggingface-hub>=0.20.0",
        "anthropic>=0.20.0",
        "openai>=1.10.0",
        "google-generativeai>=0.3.0",
        "psutil>=5.9.0",
        "platformdirs>=4.0.0",
        "python-dotenv>=1.0.0",
        "tabulate>=0.9.0",
        "tqdm>=4.66.0",
        "pydantic>=2.5.0",
        "asyncio-throttle>=1.0.0",
        "orjson>=3.9.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-asyncio>=0.21.0",
            "pytest-cov>=4.0.0",
            "black>=23.0.0",
            "ruff>=0.1.0",
            "mypy>=1.0.0",
            "pre-commit>=3.0.0",
        ],
        "mlx": [
            "mlx-lm>=0.16.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "cortex=cortex.cli:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)