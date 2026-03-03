"""
Cortex - Unified AI Model Management System
Setup configuration for the Cortex package
"""

from setuptools import find_packages, setup

# Read the README file
with open('README.md', 'r', encoding='utf-8') as fh:
    long_description = fh.read()


setup(
    name='cortex-ai',
    version='0.1.0',
    author='Illya Starikov',
    author_email='illya@starikov.co',
    description='Unified AI model management system for terminal and Neovim integration',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/IllyaStarikov/.dotfiles/tree/main/src/cortex',
    packages=find_packages(),
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX :: Linux',
    ],
    python_requires='>=3.9',
    install_requires=[
        'rich>=13.0.0',
        'click>=8.0.0',
        'pyyaml>=6.0',
        'requests>=2.31.0',
        'aiohttp>=3.9.0',
        'psutil>=5.9.0',
    ],
    extras_require={
        'dev': [
            'pytest>=7.0.0',
            'pytest-asyncio>=0.21.0',
            'pytest-cov>=4.0.0',
            'black>=23.0.0',
            'ruff>=0.1.0',
            'mypy>=1.0.0',
            'pre-commit>=3.0.0',
        ],
        'mlx': [
            'mlx-lm>=0.16.0',
        ],
    },
    entry_points={
        'console_scripts': [
            'cortex=cortex.cli:main',
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
