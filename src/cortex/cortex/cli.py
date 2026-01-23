"""
Cortex CLI - Command Line Interface for the Cortex system.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import click
from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    DownloadColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeRemainingColumn,
)
from rich.prompt import Confirm
from rich.syntax import Syntax
from rich.table import Table

from .config import Config
from .providers import ModelCapability, ModelInfo, registry
from .system_utils import ModelRecommender, SystemDetector

# Extended commands are now integrated directly into cli.py

# Set up logging
logging.basicConfig(
    level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Rich console for beautiful output
console = Console()


@click.group()
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
@click.option('--config', '-c', type=click.Path(), help='Path to config file')
@click.pass_context
def cli(ctx, verbose, config):
    """Cortex - Unified AI Model Management System"""
    ctx.ensure_object(dict)

    # Load configuration
    config_path = Path(config) if config else None
    ctx.obj['config'] = Config(config_path)

    if verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Initialize provider registry
    asyncio.run(registry.initialize_providers(ctx.obj['config'].data))


@cli.command()
@click.option(
    '--category',
    '-c',
    type=click.Choice(['all', 'online', 'offline', 'open_source']),
    default='all',
    help='Filter by category',
)
@click.option('--provider', '-p', help='Filter by specific provider')
@click.option(
    '--capability',
    type=click.Choice(['chat', 'code', 'vision', 'multimodal']),
    help='Filter by capability',
)
@click.option('--max-ram', type=float, help='Maximum RAM usage in GB')
@click.option(
    '--recommended', '-r', is_flag=True, help='Show only recommended models for your system'
)
@click.option('--detailed', '-d', is_flag=True, help='Show detailed information')
@click.option('--summary', '-s', is_flag=True, help='Show summary with counts by provider')
@click.option('--export', type=click.Choice(['json', 'csv']), help='Export results to file')
@click.pass_context
def list(ctx, category, provider, capability, max_ram, recommended, detailed, summary, export):
    """List all available AI models with smart categorization and recommendations."""

    async def _list_models():
        # Show loading spinner
        with Progress(
            SpinnerColumn(),
            TextColumn('[progress.description]{task.description}'),
            console=console,
        ) as progress:
            task = progress.add_task('Fetching models from providers...', total=None)

            # Fetch all models
            all_models = await registry.fetch_all_models()

            progress.update(task, description='Analyzing system capabilities...')

            # Detect system info
            system_info = SystemDetector.detect_system()

            progress.update(task, description='Processing models...')

        # Categorize models
        categorized = registry.categorize_models(all_models)

        # Apply filters
        filtered_models = categorized[category]

        if provider:
            filtered_models = [m for m in filtered_models if m.provider == provider]

        if capability:
            cap_enum = ModelCapability(capability)
            filtered_models = [m for m in filtered_models if cap_enum in m.capabilities]

        if max_ram:
            filtered_models = [m for m in filtered_models if m.ram_gb <= max_ram]

        # Get recommendations if requested
        if recommended:
            filtered_models = ModelRecommender.recommend_models(
                system_info, filtered_models, max_recommendations=10
            )

        # Display system info panel
        _display_system_info(system_info)

        # Display based on mode
        if summary:
            _display_provider_summary(all_models, system_info)
        elif detailed:
            _display_models_detailed(filtered_models, system_info)
        else:
            _display_models_table(filtered_models, system_info, recommended)

        # Export if requested
        if export:
            _export_models(filtered_models, export)

        # Show summary statistics
        _display_statistics(filtered_models, all_models, system_info)

    asyncio.run(_list_models())


@cli.command()
@click.argument('model_id', required=False)
@click.option('--provider', '-p', help='Specify provider (mlx, ollama, claude, openai, gemini)')
@click.option('--recommend', '-r', is_flag=True, help='Show recommended model for your system')
@click.option('--current', '-c', is_flag=True, help='Show current model configuration')
@click.option('--env', '-e', is_flag=True, help='Output environment variables for shell eval')
@click.option('--validate', '-v', is_flag=True, help='Validate model exists before setting')
@click.pass_context
def model(ctx, model_id, provider, recommend, current, env, validate):
    """Set or display the global AI model configuration.

    Examples:
        cortex model                                    # Show current model
        cortex model --recommend                        # Show recommended model
        cortex model mlx-community/Qwen2.5-Coder-7B-4bit  # Set specific model
        cortex model gpt-4o --provider openai          # Set with provider hint
        cortex model --env                             # Output env vars for eval
    """

    async def _model_command():
        config = ctx.obj['config']

        # Show current model configuration
        if current or (not model_id and not recommend and not env):
            _show_current_model(config)
            return

        # Output environment variables for shell evaluation
        if env:
            _output_env_vars(config)
            return

        # Show recommended model
        if recommend:
            await _show_recommended_model(config)
            return

        # Set new model
        if model_id:
            await _set_model(config, model_id, provider, validate)

    asyncio.run(_model_command())


def _show_current_model(config):
    """Display the current model configuration."""
    current = config.data.get('current_model', {})

    if not current:
        console.print('[yellow]No model currently configured.[/yellow]')
        console.print('Run [cyan]cortex model --recommend[/cyan] to see recommendations.')
        return

    # Create a nice panel display
    info_lines = [
        f'[bold]Provider:[/bold] [cyan]{current.get("provider", "unknown")}[/cyan]',
        f'[bold]Model ID:[/bold] [bright_white]{current.get("id", "unknown")}[/bright_white]',
    ]

    if current.get('name'):
        info_lines.append(f'[bold]Name:[/bold] {current.get("name")}')

    if current.get('size_gb'):
        size_color = _get_size_color(current.get('size_gb', 0), 64.0)  # Assuming 64GB RAM
        info_lines.append(
            f'[bold]Size:[/bold] [{size_color}]{current.get("size_gb"):.1f}GB[/{size_color}]'
        )

    if current.get('ram_gb'):
        ram_color = _get_ram_color(current.get('ram_gb', 0), 35.0)  # Typical available RAM
        info_lines.append(
            f'[bold]RAM Required:[/bold] [{ram_color}]{current.get("ram_gb"):.1f}GB[/{ram_color}]'
        )

    if current.get('context_window'):
        context_color = _get_context_color(current.get('context_window', 0))
        context = current.get('context_window')
        if context >= 1000000:
            context_str = f'{context // 1000000}M'
        elif context >= 1000:
            context_str = f'{context // 1000}K'
        else:
            context_str = str(context)
        info_lines.append(
            f'[bold]Context:[/bold] [{context_color}]{context_str} tokens[/{context_color}]'
        )

    if current.get('capabilities'):
        caps_str = ', '.join(current.get('capabilities', []))
        info_lines.append(f'[bold]Capabilities:[/bold] {caps_str}')

    if current.get('online') is not None:
        status = 'Online API' if current.get('online') else 'Local/Offline'
        info_lines.append(f'[bold]Type:[/bold] {status}')

    panel = Panel(
        '\n'.join(info_lines),
        title='🧠 Current Model Configuration',
        border_style='bright_blue',
        box=box.ROUNDED,
    )
    console.print(panel)

    # Show environment variable hint
    console.print('\n[dim]To export environment variables:[/dim]')
    console.print('[cyan]eval $(cortex model --env)[/cyan]')


def _output_env_vars(config):
    """Output environment variables for shell evaluation."""
    current = config.data.get('current_model', {})

    if not current:
        # Output empty vars to clear any existing settings
        print('export CORTEX_PROVIDER=""')
        print('export CORTEX_MODEL=""')
        print('export CORTEX_ENDPOINT=""')
        return

    provider = current.get('provider', '')
    model_id = current.get('id', '')

    # Basic cortex environment variables
    print(f'export CORTEX_PROVIDER="{provider}"')
    print(f'export CORTEX_MODEL="{model_id}"')

    # Provider-specific configurations for Neovim integration
    if provider == 'mlx':
        port = config.data.get('providers', {}).get('mlx', {}).get('port', 8080)
        print(f'export CORTEX_ENDPOINT="http://localhost:{port}/v1"')
        print('export CORTEX_API_KEY="mlx-local-no-key-needed"')
        print('')
        print('# Neovim CodeCompanion/Avante integration')
        print('export AVANTE_PROVIDER="openai"')
        print(f'export AVANTE_OPENAI_MODEL="{model_id}"')
        print(f'export AVANTE_OPENAI_ENDPOINT="http://localhost:{port}/v1"')
        print('export OPENAI_API_KEY="mlx-local-no-key-needed"')

    elif provider == 'ollama':
        port = config.data.get('providers', {}).get('ollama', {}).get('port', 11434)
        print(f'export CORTEX_ENDPOINT="http://localhost:{port}"')
        print('export CORTEX_API_KEY=""')
        print('')
        print('# Neovim CodeCompanion/Avante integration')
        print('export AVANTE_PROVIDER="ollama"')
        print(f'export AVANTE_OLLAMA_MODEL="{model_id}"')
        print(f'export OLLAMA_HOST="http://localhost:{port}"')

    elif provider == 'claude' or provider == 'anthropic':
        print('export CORTEX_ENDPOINT="https://api.anthropic.com"')
        print('export CORTEX_API_KEY="${ANTHROPIC_API_KEY}"')
        print('')
        print('# Neovim CodeCompanion/Avante integration')
        print('export AVANTE_PROVIDER="claude"')
        print(f'export AVANTE_CLAUDE_MODEL="{model_id}"')

    elif provider == 'openai':
        print('export CORTEX_ENDPOINT="https://api.openai.com"')
        print('export CORTEX_API_KEY="${OPENAI_API_KEY}"')
        print('')
        print('# Neovim CodeCompanion/Avante integration')
        print('export AVANTE_PROVIDER="openai"')
        print(f'export AVANTE_OPENAI_MODEL="{model_id}"')

    elif provider == 'gemini' or provider == 'google':
        print('export CORTEX_ENDPOINT="https://generativelanguage.googleapis.com"')
        print('export CORTEX_API_KEY="${GEMINI_API_KEY}"')
        print('')
        print('# Neovim CodeCompanion/Avante integration')
        print('export AVANTE_PROVIDER="gemini"')
        print(f'export AVANTE_GEMINI_MODEL="{model_id}"')


async def _show_recommended_model(config):
    """Show recommended model based on system capabilities."""
    # Detect system
    system_info = SystemDetector.detect_system()

    # Fetch all models
    with Progress(
        SpinnerColumn(),
        TextColumn('[progress.description]{task.description}'),
        console=console,
    ) as progress:
        progress.add_task('Analyzing models...', total=None)
        all_models_dict = await registry.fetch_all_models()

    # Flatten all models
    all_models = []
    for provider_models in all_models_dict.values():
        all_models.extend(provider_models)

    # Get recommendations
    recommendations = ModelRecommender.recommend_models(
        system_info, all_models, max_recommendations=5
    )

    if not recommendations:
        console.print('[yellow]No suitable models found for your system.[/yellow]')
        return

    console.print('\n[bold cyan]Top Recommended Models for Your System:[/bold cyan]\n')

    for i, model in enumerate(recommendations, 1):
        # Determine fit quality
        ram_left = system_info.ram_available_gb - model.ram_gb
        if ram_left > 20:
            fit_emoji = '✅'
            fit_text = 'Excellent fit'
        elif ram_left > 10:
            fit_emoji = '🟢'
            fit_text = 'Good fit'
        elif ram_left > 5:
            fit_emoji = '⚡'
            fit_text = 'Tight fit'
        else:
            fit_emoji = '⚠️'
            fit_text = 'Just fits'

        # Create recommendation panel
        info_lines = [
            f'[bold]Provider:[/bold] [cyan]{model.provider}[/cyan]',
            f'[bold]Size:[/bold] {model.size_gb:.1f}GB | [bold]RAM:[/bold] {model.ram_gb:.1f}GB',
            f'[bold]Context:[/bold] {model.context_window:,} tokens',
            f'[bold]Capabilities:[/bold] {", ".join([c.value for c in model.capabilities])}',
            f'[bold]Fitness Score:[/bold] {model.metadata.get("fitness_score", 0):.1f}/100',
            f'[bold]System Fit:[/bold] {fit_emoji} {fit_text}',
        ]

        if model.description:
            info_lines.append(f'\n[dim]{model.description[:100]}...[/dim]')

        panel = Panel(
            '\n'.join(info_lines),
            title=f'[bold]#{i}. {model.id}[/bold]',
            border_style='green' if i == 1 else 'blue',
            box=box.ROUNDED,
        )
        console.print(panel)

    # Show how to set the top recommendation
    top_model = recommendations[0]
    console.print('\n[dim]To use the top recommendation:[/dim]')
    console.print(f'[cyan]cortex model {top_model.id}[/cyan]')


async def _set_model(config, model_id, provider_hint, validate):
    """Set the global model configuration."""
    # If validating, fetch all models to check
    if validate:
        with Progress(
            SpinnerColumn(),
            TextColumn('[progress.description]{task.description}'),
            console=console,
        ) as progress:
            progress.add_task('Validating model...', total=None)
            all_models_dict = await registry.fetch_all_models()

        # Find the model
        found_model = None
        for provider_name, models in all_models_dict.items():
            for model in models:
                if model.id == model_id or model.name == model_id:
                    if provider_hint and provider_name != provider_hint:
                        continue
                    found_model = model
                    break
            if found_model:
                break

        if not found_model:
            console.print(f"[red]Error: Model '{model_id}' not found.[/red]")
            if provider_hint:
                console.print(f'[yellow]Searched in provider: {provider_hint}[/yellow]')
            console.print('\nRun [cyan]cortex list[/cyan] to see available models.')
            return

        model_info = {
            'id': found_model.id,
            'name': found_model.name,
            'provider': found_model.provider,
            'size_gb': found_model.size_gb,
            'ram_gb': found_model.ram_gb,
            'context_window': found_model.context_window,
            'capabilities': [c.value for c in found_model.capabilities],
            'online': found_model.online,
            'open_source': found_model.open_source,
            'score': found_model.score,
            'last_modified': found_model.last_modified,
            'downloads': found_model.downloads,
            'likes': found_model.likes,
        }
    else:
        # Set without validation (user knows what they're doing)
        if not provider_hint:
            # Try to infer provider from model_id
            if 'mlx-community/' in model_id:
                provider_hint = 'mlx'
            elif 'claude' in model_id.lower():
                provider_hint = 'claude'
            elif 'gpt' in model_id.lower() or 'o1' in model_id.lower():
                provider_hint = 'openai'
            elif 'gemini' in model_id.lower():
                provider_hint = 'gemini'
            elif ':' in model_id:  # Ollama style
                provider_hint = 'ollama'
            else:
                console.print(
                    '[yellow]Warning: Could not infer provider. '
                    'Please specify with --provider[/yellow]'
                )
                return

        model_info = {
            'id': model_id,
            'name': model_id,
            'provider': provider_hint,
            'online': provider_hint in ['claude', 'openai', 'gemini'],
            'capability': 'chat',  # Default capability
        }

    # Update configuration
    config.update_current_model(model_info)

    # Show success message
    console.print(f'[green]✓[/green] Model set to: [bright_white]{model_info["id"]}[/bright_white]')
    console.print(f'  Provider: [cyan]{model_info["provider"]}[/cyan]')

    if model_info.get('size_gb'):
        console.print(f'  Size: {model_info["size_gb"]:.1f}GB | RAM: {model_info["ram_gb"]:.1f}GB')

    # Show how to apply the configuration
    console.print('\n[dim]To apply this configuration to your shell:[/dim]')
    console.print('[cyan]eval $(cortex model --env)[/cyan]')

    # If it's an offline model, check if it needs downloading
    if not model_info.get('online', True) and model_info['provider'] in ['mlx', 'ollama']:
        console.print(
            '\n[yellow]Note: This is a local model. '
            'Run [cyan]cortex download[/cyan] to download it.[/yellow]'
        )


@cli.command()
@click.option('--model', '-m', help='Model to download (uses current if not specified)')
@click.option('--force', '-f', is_flag=True, help='Force re-download even if exists')
@click.option('--no-progress', is_flag=True, help='Disable progress bar')
@click.option('--validate', '-v', is_flag=True, help='Validate download after completion')
@click.pass_context
def download(ctx, model, force, no_progress, validate):
    """Download the currently configured model or a specific model.

    Examples:
        cortex download                    # Download current model
        cortex download --model llama3.2   # Download specific model
        cortex download --force            # Re-download even if exists
    """

    async def _download_command():
        config = ctx.obj['config']

        # Get model to download
        if model:
            # Parse model ID and provider
            if '/' in model and 'mlx' in model:
                provider = 'mlx'
                model_id = model
            elif ':' in model:
                provider = 'ollama'
                model_id = model
            else:
                # Use current model's provider
                current = config.data.get('current_model', {})
                provider = current.get('provider', 'mlx')
                model_id = model
        else:
            # Use current model
            current = config.data.get('current_model', {})
            if not current:
                console.print("[red]No model configured. Run 'cortex model' first.[/red]")
                return
            provider = current.get('provider')
            model_id = current.get('id')

            if not provider or not model_id:
                console.print('[red]Invalid model configuration.[/red]')
                return

        # Check if provider supports downloading
        if provider not in ['mlx', 'ollama']:
            console.print(
                f"[yellow]Provider '{provider}' doesn't require downloading (cloud-based).[/yellow]"
            )
            return

        # Get the provider
        provider_obj = registry.get_provider(provider)
        if not provider_obj:
            console.print(f"[red]Provider '{provider}' not found.[/red]")
            return

        # Check if already downloaded
        if not force:
            is_available = await provider_obj.is_model_available(model_id)
            if is_available:
                console.print(f"[yellow]Model '{model_id}' is already downloaded.[/yellow]")
                if not Confirm.ask('Do you want to re-download it?'):
                    return

        # Download the model
        console.print(f'\n[cyan]Downloading model: {model_id}[/cyan]')
        console.print(f'Provider: {provider}\n')

        # Create progress tracking
        download_start = datetime.now()

        if not no_progress:
            with Progress(
                SpinnerColumn(),
                TextColumn('[progress.description]{task.description}'),
                BarColumn(),
                TextColumn('[progress.percentage]{task.percentage:>3.0f}%'),
                TextColumn('•'),
                DownloadColumn(),
                TextColumn('•'),
                TimeRemainingColumn(),
                console=console,
            ) as progress:
                task = progress.add_task(f'Downloading {model_id}', total=100)

                def progress_callback(current, total):
                    if total > 0:
                        percentage = (current / total) * 100
                        progress.update(task, completed=percentage)

                success = await provider_obj.download_model(model_id, progress_callback)
        else:
            success = await provider_obj.download_model(model_id, None)

        download_end = datetime.now()
        download_time = (download_end - download_start).total_seconds()

        if success:
            console.print(f'\n[green]✓[/green] Successfully downloaded {model_id}')
            console.print(f'  Download time: {download_time:.1f} seconds')

            # Validate if requested
            if validate:
                console.print('\n[cyan]Validating download...[/cyan]')
                is_valid = await provider_obj.is_model_available(model_id)
                if is_valid:
                    console.print('[green]✓[/green] Download validated successfully')
                else:
                    console.print('[red]✗[/red] Download validation failed')

            # Log statistics
            _log_download_stats(config, model_id, provider, download_time, success)

            # Update current model if this was a new model
            if model and model != config.data.get('current_model', {}).get('id'):
                console.print('\n[dim]To use this model:[/dim]')
                console.print(f'[cyan]cortex model {model_id}[/cyan]')
        else:
            console.print(f'\n[red]✗[/red] Failed to download {model_id}')
            _log_download_stats(config, model_id, provider, download_time, False)

    asyncio.run(_download_command())


def _log_download_stats(config, model_id, provider, download_time, success):
    """Log download statistics."""
    stats = config.data.get('download_stats', [])
    stats.append(
        {
            'model_id': model_id,
            'provider': provider,
            'timestamp': datetime.now().isoformat(),
            'duration_seconds': download_time,
            'success': success,
        }
    )

    # Keep only last 100 download records
    config.data['download_stats'] = stats[-100:]
    config.save()


def _display_system_info(system_info):
    """Display system information panel."""
    info_text = f"""
[bold cyan]System Information[/bold cyan]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OS: [green]{system_info.os_type.value}[/green]
 CPU: {system_info.cpu_model} ({system_info.cpu_cores} cores)
 RAM: [yellow]{system_info.ram_gb}GB[/yellow] \
(Available: [green]{system_info.ram_available_gb}GB[/green])
 GPU: [cyan]{system_info.gpu_info}[/cyan]
 Performance Tier: [bold]{system_info.performance_tier.value.upper()}[/bold]
"""

    if system_info.has_metal:
        info_text += ' Metal: ✅'
    if system_info.has_neural_engine:
        info_text += ' Neural Engine: ✅'
    if system_info.has_cuda:
        info_text += ' CUDA: ✅'

    panel = Panel(
        info_text.strip(),
        title='🧠 Cortex System Analysis',
        border_style='bright_blue',
        box=box.ROUNDED,
    )
    console.print(panel)
    console.print()


def _get_size_color(size_gb: float, system_ram_gb: float) -> str:
    """Get color for model size based on system capacity.
    Green -> Yellow -> Orange -> Red gradient based on RAM usage.
    """
    if size_gb <= 0:
        return 'dim'  # Cloud models

    # Calculate percentage of available RAM
    ram_percent = (size_gb * 1.2) / system_ram_gb * 100  # Models need ~1.2x their size

    if ram_percent <= 10:
        return 'green'
    elif ram_percent <= 25:
        return 'bright_green'
    elif ram_percent <= 50:
        return 'yellow'
    elif ram_percent <= 75:
        return 'bright_yellow'
    elif ram_percent <= 90:
        return 'rgb(255,165,0)'  # Orange
    elif ram_percent <= 100:
        return 'rgb(255,100,0)'  # Dark orange
    else:
        return 'red'


def _get_ram_color(ram_gb: float, available_ram_gb: float) -> str:
    """Get color for RAM requirement based on available RAM."""
    if ram_gb <= 0:
        return 'dim'  # Cloud models

    # Calculate how much RAM is left after loading model
    ram_left_percent = ((available_ram_gb - ram_gb) / available_ram_gb) * 100

    if ram_left_percent >= 50:
        return 'green'  # Plenty of RAM left
    elif ram_left_percent >= 30:
        return 'bright_green'  # Good amount left
    elif ram_left_percent >= 20:
        return 'yellow'  # Getting tight
    elif ram_left_percent >= 10:
        return 'bright_yellow'  # Very tight
    elif ram_left_percent >= 0:
        return 'rgb(255,165,0)'  # Just fits
    else:
        return 'red'  # Doesn't fit


def _get_context_color(context_window: int) -> str:
    """Get color for context window size."""
    if context_window >= 1000000:
        return 'bright_magenta'  # 1M+ context
    elif context_window >= 200000:
        return 'magenta'  # 200K+ context
    elif context_window >= 128000:
        return 'bright_blue'  # 128K context
    elif context_window >= 32000:
        return 'blue'  # 32K context
    elif context_window >= 16000:
        return 'cyan'  # 16K context
    elif context_window >= 8000:
        return 'green'  # 8K context
    else:
        return 'yellow'  # < 8K context


def _get_score_color(score: float) -> str:
    """Get color for model score/power."""
    if score >= 95:
        return 'bright_magenta'  # Top tier
    elif score >= 90:
        return 'magenta'  # Excellent
    elif score >= 80:
        return 'bright_blue'  # Very good
    elif score >= 70:
        return 'blue'  # Good
    elif score >= 60:
        return 'cyan'  # Decent
    elif score >= 50:
        return 'green'  # OK
    else:
        return 'yellow'  # Basic


def _get_capability_color(capabilities: list) -> str:
    """Get color based on capabilities."""
    from cortex.providers import ModelCapability

    if ModelCapability.MULTIMODAL in capabilities:
        return 'bright_magenta'  # Most capable
    elif ModelCapability.VISION in capabilities:
        return 'magenta'  # Vision capable
    elif ModelCapability.CODE in capabilities:
        return 'bright_blue'  # Code capable
    elif ModelCapability.EMBEDDING in capabilities:
        return 'cyan'  # Embedding only
    else:
        return 'green'  # Basic chat


def _display_models_table(models: list[ModelInfo], system_info, show_recommendations: bool):
    """Display models in a formatted table, grouped by provider."""
    if not models:
        console.print('[yellow]No models found matching your criteria.[/yellow]')
        return

    # Group models by provider
    models_by_provider = {}
    for model in models:
        if model.provider not in models_by_provider:
            models_by_provider[model.provider] = []
        models_by_provider[model.provider].append(model)

    # Sort each provider's models by score (power) and then by size
    for provider in models_by_provider:
        models_by_provider[provider].sort(
            key=lambda m: (-m.score, -m.size_gb if m.size_gb > 0 else -m.context_window)
        )

    # Create table
    table = Table(
        title='Available AI Models' + (' - Recommended' if show_recommendations else ''),
        box=box.ROUNDED,
        show_lines=True,
        title_style='bold magenta',
    )

    # Add columns (no Provider or Status columns)
    table.add_column('Model', style='bright_white', width=55, overflow='fold')
    table.add_column('Size', justify='right', width=8)  # Color per value
    table.add_column('RAM', justify='right', width=8)  # Color per value
    table.add_column('Context', justify='right', width=10)  # Color per value
    table.add_column('Capabilities', width=20)  # Color per value

    # Add rows grouped by provider
    provider_order = ['mlx', 'ollama', 'claude', 'openai', 'gemini', 'huggingface']

    for provider in provider_order:
        if provider not in models_by_provider:
            continue

        provider_models = models_by_provider[provider]

        # Add provider header row with custom styling
        table.add_row(
            f'[bold cyan]━━━ {provider.upper()} ({len(provider_models)} models) ━━━[/bold cyan]',
            '',
            '',
            '',
            '',
            end_section=True,
        )

        # Add all models for this provider
        for model in provider_models:
            # Check if model fits in system
            can_run = model.ram_gb <= system_info.ram_available_gb

            # Smart split model ID at sensible points
            model_id = model.id
            # Split at common delimiters: /, -, _
            # Prioritize splitting after community/, models/, etc.
            if len(model_id) > 50:
                # Try to split at good breakpoints
                if '/' in model_id:
                    parts = model_id.split('/')
                    if len(parts) >= 2:
                        # Keep provider/org on first line, model name on second
                        if len(parts[0]) + len(parts[1]) < 45:
                            model_display = '/'.join(parts[:2])
                            if len(parts) > 2:
                                model_display += '\n  /' + '/'.join(parts[2:])
                        else:
                            model_display = parts[0] + '/\n  ' + '/'.join(parts[1:])
                    else:
                        model_display = model_id
                elif '-' in model_id[20:]:
                    # Split at dash if it's not too early in the string
                    idx = model_id[20:].index('-') + 20
                    model_display = model_id[:idx] + '\n  ' + model_id[idx:]
                else:
                    # Force split at 50 chars
                    model_display = model_id[:50] + '\n  ' + model_id[50:]
            else:
                model_display = model_id

            # Add status indicator to model name based on fit
            if not model.online and model.metadata.get('downloaded'):
                status = '💾'  # Downloaded/Local
            elif can_run:
                ram_left = system_info.ram_available_gb - model.ram_gb
                if ram_left > 20:
                    status = '✅'  # Easy - lots of RAM left
                elif ram_left > 10:
                    status = '🟢'  # Good - comfortable RAM
                elif ram_left > 5:
                    status = '⚡'  # Tight - getting close
                else:
                    status = '⚠️'  # Warning - just fits
            else:
                over_by = model.ram_gb - system_info.ram_available_gb
                if over_by < 5:
                    status = '🟡'  # Close - almost fits
                elif over_by < 20:
                    status = '❌'  # Too large
                else:
                    status = '🚫'  # Way too large

            # Add status to the beginning of model display
            model_name = f'{status} {model_display}'

            # Format capabilities with color
            caps = ', '.join([c.value for c in model.capabilities])
            caps_color = _get_capability_color(model.capabilities)

            # Format context window with color
            if model.context_window >= 1000000:
                context = f'{model.context_window // 1000000}M'
            elif model.context_window >= 1000:
                context = f'{model.context_window // 1000}K'
            else:
                context = str(model.context_window)
            context_color = _get_context_color(model.context_window)

            # Format size/RAM with intelligent colors
            if model.size_gb > 0:
                size_str = f'{model.size_gb:.1f}GB'
                size_color = _get_size_color(model.size_gb, system_info.ram_gb)
            else:
                size_str = 'Cloud'
                size_color = 'dim'

            if model.ram_gb > 0:
                ram_str = f'{model.ram_gb:.1f}GB'
                ram_color = _get_ram_color(model.ram_gb, system_info.ram_available_gb)
            else:
                ram_str = 'API'
                ram_color = 'dim'

            # Split model_name by newlines for multiline display
            if '\n' in model_name:
                lines = model_name.split('\n')
                # Use Text object for multiline with proper styling
                from rich.text import Text

                model_text = Text()
                for i, line in enumerate(lines):
                    if i > 0:
                        model_text.append('\n')
                    model_text.append(line)

                table.add_row(
                    model_text,  # Model name with status indicator
                    f'[{size_color}]{size_str}[/{size_color}]',
                    f'[{ram_color}]{ram_str}[/{ram_color}]',
                    f'[{context_color}]{context}[/{context_color}]',
                    f'[{caps_color}]{caps}[/{caps_color}]',
                )
            else:
                table.add_row(
                    model_name,  # Model name with status indicator
                    f'[{size_color}]{size_str}[/{size_color}]',
                    f'[{ram_color}]{ram_str}[/{ram_color}]',
                    f'[{context_color}]{context}[/{context_color}]',
                    f'[{caps_color}]{caps}[/{caps_color}]',
                )

    console.print(table)


def _display_provider_summary(all_models: dict[str, list[ModelInfo]], system_info):
    """Display a summary of models by provider."""
    table = Table(
        title='AI Models by Provider', box=box.ROUNDED, show_lines=True, title_style='bold magenta'
    )

    table.add_column('Provider', style='cyan', width=15)
    table.add_column('Total', justify='right', style='yellow', width=10)
    table.add_column('Online', justify='right', style='green', width=10)
    table.add_column('Offline', justify='right', style='blue', width=10)
    table.add_column('Can Run', justify='right', style='bright_green', width=10)
    table.add_column('Top Models', style='white', width=50)

    total_all = 0
    total_online = 0
    total_offline = 0
    total_runnable = 0

    for provider_name, models in all_models.items():
        if not models:
            continue

        online_count = sum(1 for m in models if m.online)
        offline_count = len(models) - online_count
        runnable_count = sum(1 for m in models if m.ram_gb <= system_info.ram_available_gb)

        # Get top 3 models
        top_models = sorted(models, key=lambda m: m.score, reverse=True)[:3]
        top_names = ', '.join([m.name[:20] for m in top_models])

        table.add_row(
            provider_name.upper(),
            str(len(models)),
            str(online_count) if online_count > 0 else '-',
            str(offline_count) if offline_count > 0 else '-',
            str(runnable_count),
            top_names,
        )

        total_all += len(models)
        total_online += online_count
        total_offline += offline_count
        total_runnable += runnable_count

    # Add totals row
    table.add_row(
        '[bold]TOTAL[/bold]',
        f'[bold]{total_all}[/bold]',
        f'[bold]{total_online}[/bold]',
        f'[bold]{total_offline}[/bold]',
        f'[bold]{total_runnable}[/bold]',
        '',
        style='bold yellow',
    )

    console.print(table)
    console.print()


def _display_models_detailed(models: list[ModelInfo], system_info):
    """Display detailed information for each model."""
    for model in models:  # Show all models
        # Create a panel for each model
        can_run = model.ram_gb <= system_info.ram_available_gb

        info_lines = [
            f'[bold]Provider:[/bold] {model.provider}',
            f'[bold]Size:[/bold] {model.size_gb:.1f}GB | [bold]RAM:[/bold] {model.ram_gb:.1f}GB',
            f'[bold]Context:[/bold] {model.context_window:,} tokens',
            f'[bold]Capabilities:[/bold] {", ".join([c.value for c in model.capabilities])}',
            f'[bold]Score:[/bold] {model.score:.0f}/100',
            f'[bold]Type:[/bold] {"Open Source" if model.open_source else "Proprietary"} | '
            f'{"Online" if model.online else "Offline"}',
        ]

        if model.description:
            info_lines.append(f'\n{model.description}')

        if model.downloads:
            info_lines.append(f'\n[dim]Downloads: {model.downloads:,} | Likes: {model.likes}[/dim]')

        status = '✅ Can run on your system' if can_run else '❌ Requires more RAM'
        border_style = 'green' if can_run else 'red'

        panel = Panel(
            '\n'.join(info_lines),
            title=f'[bold]{model.id}[/bold]',
            subtitle=status,
            border_style=border_style,
            box=box.ROUNDED,
        )
        console.print(panel)
        console.print()


def _display_statistics(filtered_models, all_models, system_info):
    """Display statistics about the models."""
    total_count = sum(len(models) for models in all_models.values())
    filtered_count = len(filtered_models)

    # Count by category
    online_count = sum(1 for m in filtered_models if m.online)
    offline_count = filtered_count - online_count
    open_source_count = sum(1 for m in filtered_models if m.open_source)

    # Count by capability
    code_count = sum(1 for m in filtered_models if ModelCapability.CODE in m.capabilities)
    vision_count = sum(1 for m in filtered_models if ModelCapability.VISION in m.capabilities)

    # Count runnable models
    runnable = sum(1 for m in filtered_models if m.ram_gb <= system_info.ram_available_gb)

    stats_text = f"""
[bold]Statistics[/bold]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total Models Found: [cyan]{total_count}[/cyan]
 Filtered Results: [yellow]{filtered_count}[/yellow]
 Can Run on System: [green]{runnable}[/green]

 By Type:
   Online: {online_count} | Offline: {offline_count}
   Open Source: {open_source_count} | Proprietary: {filtered_count - open_source_count}

 By Capability:
   Code: {code_count} | Vision: {vision_count}
"""

    console.print(
        Panel(
            stats_text.strip(),
            title='📊 Model Statistics',
            border_style='bright_blue',
            box=box.ROUNDED,
        )
    )


def _export_models(models: list[ModelInfo], format: str):
    """Export models to file."""
    import csv
    import json
    from datetime import datetime

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    if format == 'json':
        filename = f'cortex_models_{timestamp}.json'
        data = []
        for model in models:
            data.append(
                {
                    'id': model.id,
                    'name': model.name,
                    'provider': model.provider,
                    'size_gb': model.size_gb,
                    'ram_gb': model.ram_gb,
                    'context_window': model.context_window,
                    'capabilities': [c.value for c in model.capabilities],
                    'score': model.score,
                    'online': model.online,
                    'open_source': model.open_source,
                    'description': model.description,
                }
            )

        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

    elif format == 'csv':
        filename = f'cortex_models_{timestamp}.csv'
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(
                [
                    'Provider',
                    'Model ID',
                    'Name',
                    'Size (GB)',
                    'RAM (GB)',
                    'Context',
                    'Capabilities',
                    'Score',
                    'Online',
                    'Open Source',
                ]
            )

            for model in models:
                writer.writerow(
                    [
                        model.provider,
                        model.id,
                        model.name,
                        model.size_gb,
                        model.ram_gb,
                        model.context_window,
                        ', '.join([c.value for c in model.capabilities]),
                        model.score,
                        model.online,
                        model.open_source,
                    ]
                )

    console.print(f'[green]✓[/green] Exported {len(models)} models to {filename}')


# Extended Commands
@cli.command()
@click.option('--verbose', '-v', is_flag=True, help='Show detailed health information')
@click.option('--check', '-c', multiple=True, help='Specific checks to run')
@click.pass_context
def health(ctx, verbose, check):
    """Run system health checks.

    Available checks:
    - system: System resources (CPU, RAM, disk)
    - mlx_server: MLX server status
    - ollama_server: Ollama server status
    - api_keys: API key configuration
    - network: Network connectivity
    - disk_space: Model cache disk space
    - model_cache: Model cache status
    """

    async def _run_health_checks():
        from .health import health_monitor

        # Run health checks
        checks_to_run = list(check) if check else None
        with Progress(
            SpinnerColumn(),
            TextColumn('[progress.description]{task.description}'),
            console=console,
        ) as progress:
            progress.add_task('Running health checks...', total=None)
            results = await health_monitor.run_health_checks(checks_to_run)

        # Get summary
        summary = health_monitor.get_summary()

        # Display results
        status_emoji = {
            'healthy': '✅',
            'warning': '⚠️',
            'critical': '🔴',
            'degraded': '⚡',
            'error': '❌',
            'offline': '🔌',
            'timeout': '⏱️',
        }

        # Overall status panel
        overall_color = {
            'healthy': 'green',
            'warning': 'yellow',
            'critical': 'red',
            'degraded': 'orange1',
            'error': 'red',
        }.get(summary['overall_status'], 'white')

        console.print(
            Panel(
                f'[{overall_color}]Overall Status: '
                f'{status_emoji.get(summary["overall_status"], "❓")} '
                f'{summary["overall_status"].upper()}[/{overall_color}]',
                title='🏥 System Health Report',
                border_style=overall_color,
            )
        )

        # Individual check results
        if verbose or summary.get('issues'):
            table = Table(show_header=True, header_style='bold cyan')
            table.add_column('Check', style='dim')
            table.add_column('Status')
            table.add_column('Details')

            for check_name, result in results.items():
                status = result.get('status', 'unknown')
                emoji = status_emoji.get(status, '❓')

                # Format details based on check type
                details = []
                if check_name == 'system':
                    details.append(f'CPU: {result.get("cpu_percent", 0):.1f}%')
                    details.append(f'RAM: {result.get("memory_percent", 0):.1f}%')
                    details.append(f'Disk: {result.get("disk_percent", 0):.1f}%')
                elif check_name == 'api_keys':
                    details.append(
                        f'{result.get("configured", 0)}/{result.get("total", 0)} configured'
                    )
                elif check_name in ['mlx_server', 'ollama_server']:
                    if result.get('running'):
                        details.append(f'Port: {result.get("port", "N/A")}')
                        details.append(f'Models: {result.get("models", 0)}')
                    else:
                        details.append('Not running')
                elif check_name == 'network':
                    details.append(f'Connectivity: {result.get("connectivity", 0):.0f}%')
                elif check_name == 'disk_space':
                    details.append(f'Free: {result.get("free_space_gb", 0):.1f} GB')
                    details.append(f'Cache: {result.get("model_cache_gb", 0):.1f} GB')
                elif check_name == 'model_cache':
                    details.append(f'MLX: {result.get("mlx_models", 0)}')
                    details.append(f'Ollama: {result.get("ollama_models", 0)}')

                table.add_row(
                    check_name.replace('_', ' ').title(),
                    f'{emoji} {status}',
                    ', '.join(details) if details else result.get('message', ''),
                )

            console.print(table)

        # Issues summary
        if summary.get('issues'):
            console.print('\n[yellow]Issues Found:[/yellow]')
            for issue in summary['issues']:
                console.print(f'  • {issue}')

    asyncio.run(_run_health_checks())


@cli.command()
@click.option('--model', '-m', help='Model to start server for (uses current if not specified)')
@click.option('--port', '-p', type=int, default=8080, help='Port to run server on')
@click.option('--background', '-b', is_flag=True, help='Run server in background')
@click.pass_context
def start(ctx, model, port, background):
    """Start the AI model server (MLX or Ollama)."""

    async def _start_server():
        config = ctx.obj['config']

        # Get model to start
        if model:
            model_id = model
            # Determine provider from model ID
            if 'mlx' in model.lower() or '/' in model:
                provider = 'mlx'
            else:
                provider = 'ollama'
        else:
            current = config.data.get('current_model', {})
            if not current:
                console.print("[red]No model configured. Run 'cortex model' first.[/red]")
                return
            model_id = current.get('id')
            provider = current.get('provider')

        console.print(
            Panel(f'[cyan]Starting {provider.upper()} server for model: {model_id}[/cyan]')
        )

        if provider == 'mlx':
            # Start MLX server
            server_cmd = [
                sys.executable,
                '-m',
                'mlx_lm.server',
                '--model',
                model_id,
                '--port',
                str(port),
                '--trust-remote-code',
            ]

            log_file = Path.home() / '.dotfiles/config/cortex/logs/mlx_server.log'
            log_file.parent.mkdir(parents=True, exist_ok=True)

            if background:
                # Start in background
                with open(log_file, 'a') as log:
                    process = subprocess.Popen(
                        server_cmd, stdout=log, stderr=log, start_new_session=True
                    )

                # Save PID
                pid_file = Path.home() / '.dotfiles/config/cortex/mlx_server.pid'
                pid_file.write_text(str(process.pid))

                console.print(
                    f'[green]✓[/green] MLX server started in background (PID: {process.pid})'
                )
                console.print(f'[dim]Logs: {log_file}[/dim]')
            else:
                # Run in foreground
                console.print(
                    '[yellow]Starting server in foreground. Press Ctrl+C to stop.[/yellow]'
                )
                subprocess.run(server_cmd)

        elif provider == 'ollama':
            # Check if Ollama is running
            try:
                subprocess.run(['ollama', 'list'], capture_output=True, check=True)
                console.print('[green]✓[/green] Ollama server is already running')
            except subprocess.CalledProcessError:
                console.print('[yellow]Starting Ollama server...[/yellow]')
                log_file = Path.home() / '.dotfiles/config/cortex/logs/ollama_server.log'
                log_file.parent.mkdir(parents=True, exist_ok=True)

                with open(log_file, 'a') as log:
                    process = subprocess.Popen(
                        ['ollama', 'serve'], stdout=log, stderr=log, start_new_session=True
                    )

                # Save PID for later stop
                pid_file = Path.home() / '.dotfiles/config/cortex/ollama_server.pid'
                pid_file.write_text(str(process.pid))

                await asyncio.sleep(2)
                console.print(f'[green]✓[/green] Ollama server started (PID: {process.pid})')
                console.print(f'[dim]Logs: {log_file}[/dim]')

        # Update server status in config
        config.data['server_status'] = {
            'provider': provider,
            'model': model_id,
            'port': port,
            'started_at': datetime.now().isoformat(),
            'running': True,
        }
        config.save()

    asyncio.run(_start_server())


@cli.command()
@click.option('--provider', '-p', help='Provider to stop (auto-detect if not specified)')
@click.pass_context
def stop(ctx, provider):
    """Stop the running AI model server."""

    config = ctx.obj['config']

    if not provider:
        # Check config for running server
        server_status = config.data.get('server_status', {})
        provider = server_status.get('provider')

    if not provider:
        console.print('[yellow]No server appears to be running.[/yellow]')
        return

    if provider == 'mlx':
        # Stop MLX server
        pid_file = Path.home() / '.dotfiles/config/cortex/mlx_server.pid'
        if pid_file.exists():
            try:
                pid = int(pid_file.read_text())
                os.kill(pid, 15)  # SIGTERM
                pid_file.unlink()
                console.print('[green]✓[/green] MLX server stopped')
            except (OSError, ProcessLookupError):
                console.print('[red]Failed to stop MLX server[/red]')
        else:
            # Try to find and kill mlx_lm.server process
            try:
                result = subprocess.run(['pkill', '-f', 'mlx_lm.server'], capture_output=True)
                if result.returncode == 0:
                    console.print('[green]✓[/green] MLX server stopped')
                else:
                    console.print('[yellow]No MLX server found running[/yellow]')
            except (OSError, subprocess.CalledProcessError):
                console.print('[red]Failed to stop MLX server[/red]')

    elif provider == 'ollama':
        pid_file = Path.home() / '.dotfiles/config/cortex/ollama_server.pid'
        if pid_file.exists():
            try:
                pid = int(pid_file.read_text())
                os.kill(pid, 15)  # SIGTERM
                pid_file.unlink()
                console.print('[green]✓[/green] Ollama server stopped')
            except (OSError, ProcessLookupError, ValueError):
                console.print('[yellow]Ollama process not found, cleaning up...[/yellow]')
                pid_file.unlink(missing_ok=True)
        else:
            # Fallback: try pkill
            result = subprocess.run(['pkill', '-f', 'ollama serve'], capture_output=True)
            if result.returncode == 0:
                console.print('[green]✓[/green] Ollama server stopped')
            else:
                console.print('[yellow]No Ollama server found running[/yellow]')

    # Update config
    if 'server_status' in config.data:
        config.data['server_status']['running'] = False
        config.save()


@cli.command()
@click.pass_context
def status(ctx):
    """Show the status of Cortex system and servers."""

    config = ctx.obj['config']

    # System info
    from .system_utils import SystemDetector

    system_info = SystemDetector.detect_system()

    console.print(Panel.fit('[bold cyan]🧠 Cortex System Status[/bold cyan]', style='cyan'))

    # Current model
    current_model = config.data.get('current_model', {})
    if current_model:
        table = Table(show_header=False, box=None)
        table.add_column('Key', style='dim')
        table.add_column('Value')

        table.add_row('Current Model', current_model.get('name', 'Not set'))
        table.add_row('Provider', current_model.get('provider', 'Not set'))
        table.add_row('Type', 'Offline' if not current_model.get('online') else 'Online')

        console.print(Panel(table, title='[cyan]Model Configuration[/cyan]', border_style='cyan'))

    # Server status
    server_status = config.data.get('server_status', {})
    if server_status.get('running'):
        table = Table(show_header=False, box=None)
        table.add_column('Key', style='dim')
        table.add_column('Value')

        table.add_row('Provider', server_status.get('provider', 'Unknown'))
        table.add_row('Model', server_status.get('model', 'Unknown'))
        table.add_row('Port', str(server_status.get('port', 8080)))
        table.add_row('Started', server_status.get('started_at', 'Unknown'))

        console.print(
            Panel(table, title='[green]Server Status (Running)[/green]', border_style='green')
        )

        # Check if server is actually responding
        if server_status.get('provider') == 'mlx':
            import requests

            try:
                port = server_status.get('port', 8080)
                response = requests.get(f'http://localhost:{port}/v1/models', timeout=2)
                if response.status_code == 200:
                    console.print('[green]✓[/green] Server is responding')
                else:
                    console.print('[yellow]⚠[/yellow] Server not responding properly')
            except (ConnectionError, OSError):
                console.print('[red]✗[/red] Cannot connect to server')
    else:
        console.print(Panel('[yellow]No server running[/yellow]', border_style='yellow'))

    # System resources
    table = Table(show_header=False, box=None)
    table.add_column('Resource', style='dim')
    table.add_column('Value')

    table.add_row('OS', system_info.os_type.value)
    table.add_row('CPU', system_info.cpu_model)
    table.add_row(
        'RAM', f'{system_info.ram_gb:.1f} GB (Available: {system_info.ram_available_gb:.1f} GB)'
    )
    table.add_row('GPU', system_info.gpu_info)

    console.print(Panel(table, title='[blue]System Resources[/blue]', border_style='blue'))


@cli.command()
@click.option('--tail', '-t', type=int, help='Number of lines to show')
@click.option('--follow', '-f', is_flag=True, help='Follow log output')
@click.option('--provider', '-p', help='Show logs for specific provider')
@click.pass_context
def logs(ctx, tail, follow, provider):
    """Show Cortex system and server logs."""

    log_dir = Path.home() / '.dotfiles/config/cortex/logs'

    if not log_dir.exists():
        console.print('[yellow]No logs found.[/yellow]')
        return

    # Determine which log to show
    if provider == 'mlx':
        log_file = log_dir / 'mlx_server.log'
    elif provider == 'ollama':
        log_file = log_dir / 'ollama.log'
    else:
        log_file = log_dir / 'cortex.log'

    if not log_file.exists():
        # Try to find any log file
        log_files = list(log_dir.glob('*.log'))
        if log_files:
            log_file = log_files[0]
        else:
            console.print('[yellow]No log files found.[/yellow]')
            return

    console.print(f'[cyan]Showing logs from: {log_file}[/cyan]\n')

    if follow:
        # Follow logs in real-time
        console.print('[yellow]Following logs. Press Ctrl+C to stop.[/yellow]\n')
        try:
            subprocess.run(['tail', '-f', str(log_file)])
        except KeyboardInterrupt:
            console.print('\n[dim]Stopped following logs.[/dim]')
    else:
        # Show last N lines
        if not tail:
            tail = 50

        try:
            result = subprocess.run(
                ['tail', f'-{tail}', str(log_file)], capture_output=True, text=True
            )
            if result.stdout:
                syntax = Syntax(result.stdout, 'log', theme='monokai')
                console.print(syntax)
            else:
                console.print('[yellow]Log file is empty.[/yellow]')
        except (OSError, subprocess.CalledProcessError):
            console.print('[red]Failed to read log file.[/red]')


@cli.command()
@click.argument('message', required=False)
@click.option('--model', '-m', help='Model to use for this chat')
@click.option('--ensemble', '-e', multiple=True, help='Use ensemble of models')
@click.option('--system', '-s', help='System prompt')
@click.option('--temperature', '-t', type=float, default=0.7, help='Temperature for generation')
@click.option('--max-tokens', type=int, help='Maximum tokens to generate')
@click.option('--stream', is_flag=True, default=True, help='Stream the response')
@click.pass_context
def chat(ctx, message, model, ensemble, system, temperature, max_tokens, stream):
    """Start an interactive chat session with the AI model.

    Examples:
        cortex chat                           # Interactive chat with current model
        cortex chat "Hello"                   # Single message
        cortex chat --model llama3.2         # Chat with specific model
        cortex chat -e model1 -e model2      # Ensemble chat with multiple models
    """

    config = ctx.obj['config']

    # Determine models to use
    if ensemble:
        models = list(ensemble)
        console.print(Panel(f'[cyan]Starting ensemble chat with {len(models)} models[/cyan]'))
    elif model:
        models = [model]
    else:
        current = config.data.get('current_model', {})
        if not current:
            console.print("[red]No model configured. Run 'cortex model' first.[/red]")
            return
        models = [current.get('id')]

    # Start chat session
    chat_start = datetime.now()
    total_tokens = 0
    responses = {}

    async def _run_chat():
        nonlocal total_tokens, responses

        if len(models) > 1:
            # Ensemble mode - run models in parallel
            console.print(
                Panel(f'[cyan]Running ensemble chat with {len(models)} models in parallel[/cyan]')
            )

            async def run_model(model_id):
                """Run a single model asynchronously."""
                try:
                    # Determine provider
                    if 'claude' in model_id.lower():
                        provider = 'claude'
                    elif 'gpt' in model_id.lower() or 'o1' in model_id.lower():
                        provider = 'openai'
                    elif 'gemini' in model_id.lower():
                        provider = 'gemini'
                    elif 'mlx' in model_id.lower() or '/' in model_id:
                        provider = 'mlx'
                    else:
                        provider = 'ollama'

                    if provider in ['claude', 'openai', 'gemini']:
                        # Use API for online models
                        result = await _call_api_model(
                            provider, model_id, message or 'Hello', temperature, max_tokens
                        )
                        responses[model_id] = result
                    elif provider == 'mlx':
                        # Use subprocess for MLX
                        cmd = [
                            sys.executable,
                            '-m',
                            'mlx_lm.generate',
                            '--model',
                            model_id,
                            '--prompt',
                            message or 'Hello',
                            '--temp',
                            str(temperature),
                        ]
                        if max_tokens:
                            cmd.extend(['--max-tokens', str(max_tokens)])

                        process = await asyncio.create_subprocess_exec(
                            *cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
                        )
                        stdout, stderr = await process.communicate()
                        responses[model_id] = stdout.decode()
                    else:
                        responses[model_id] = f'Provider {provider} not implemented for ensemble'
                except Exception as e:
                    responses[model_id] = f'Error: {e}'

            # Run all models in parallel
            tasks = [run_model(model_id) for model_id in models]
            await asyncio.gather(*tasks)

            # Display results side by side
            for model_id, response in responses.items():
                console.print(f'\n[cyan]━━━ {model_id} ━━━[/cyan]')
                console.print(response[:500] + ('...' if len(response) > 500 else ''))
                total_tokens += len((message or '').split()) + len(response.split())

        else:
            # Single model mode
            model_id = models[0]

            # Determine provider
            if 'mlx' in model_id.lower() or '/' in model_id:
                provider = 'mlx'
            elif any(x in model_id.lower() for x in ['gpt', 'claude', 'gemini']):
                provider = 'api'
            else:
                provider = 'ollama'

            if provider == 'mlx':
                # Use mlx_lm chat
                cmd = [
                    sys.executable,
                    '-m',
                    'mlx_lm.chat',
                    '--model',
                    model_id,
                    '--temp',
                    str(temperature),
                ]
                if max_tokens:
                    cmd.extend(['--max-tokens', str(max_tokens)])

                if message:
                    # Single message mode
                    process = subprocess.Popen(
                        cmd,
                        stdin=subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True,
                    )
                    stdout, stderr = process.communicate(input=message)
                    console.print(stdout)
                    total_tokens += len(message.split()) + len(stdout.split())
                else:
                    # Interactive mode
                    console.print("[dim]Starting interactive chat. Type 'exit' to quit.[/dim]")
                    subprocess.run(cmd)

            elif provider == 'ollama':
                # Use ollama run
                cmd = ['ollama', 'run', model_id]
                if message:
                    cmd.append(message)
                subprocess.run(cmd)
            else:
                console.print('[yellow]Use ensemble mode for API models[/yellow]')

    async def _call_api_model(provider, model_id, prompt, temp, max_tok):
        """Call API-based models."""
        # This is a simplified version - in production you'd use the actual SDK
        return f'Response from {model_id}: [API call would go here for prompt: {prompt}]'

    try:
        asyncio.run(_run_chat())
    except KeyboardInterrupt:
        console.print('\n[dim]Chat session ended.[/dim]')

    # Log chat statistics
    chat_end = datetime.now()
    duration = (chat_end - chat_start).total_seconds()

    stats = {
        'models': models,
        'start_time': chat_start.isoformat(),
        'duration_seconds': duration,
        'estimated_tokens': total_tokens,
        'temperature': temperature,
    }

    # Save stats
    stats_file = Path.home() / '.dotfiles/config/cortex/logs/chat_stats.json'
    stats_file.parent.mkdir(parents=True, exist_ok=True)

    existing_stats = []
    if stats_file.exists():
        try:
            existing_stats = json.loads(stats_file.read_text())
        except (json.JSONDecodeError, OSError):
            pass

    existing_stats.append(stats)
    stats_file.write_text(json.dumps(existing_stats, indent=2))

    # Display session summary
    console.print(f'\n[dim]Chat duration: {duration:.1f}s | Estimated tokens: {total_tokens}[/dim]')


def main():
    """Main entry point for the CLI."""
    try:
        cli()
    except Exception as e:
        console.print(f'[red]Error: {e}[/red]')
        logger.exception('Unhandled exception in CLI')
        raise


if __name__ == '__main__':
    main()
