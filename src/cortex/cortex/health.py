"""
Health check and monitoring system for Cortex.
"""

import asyncio
import logging
import os
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

import aiohttp
import psutil

logger = logging.getLogger(__name__)


class HealthMonitor:
    """System health monitoring and checking."""

    def __init__(self):
        """Initialize health monitor."""
        self.checks = {
            'system': self.check_system_resources,
            'mlx_server': self.check_mlx_server,
            'ollama_server': self.check_ollama_server,
            'api_keys': self.check_api_keys,
            'network': self.check_network,
            'disk_space': self.check_disk_space,
            'model_cache': self.check_model_cache,
        }
        self.last_check = {}
        self.status = {}

    async def run_health_checks(self, checks: Optional[List[str]] = None) -> Dict[str, Any]:
        """Run specified health checks or all if none specified."""
        results = {}
        checks_to_run = checks or list(self.checks.keys())

        for check_name in checks_to_run:
            if check_name in self.checks:
                try:
                    result = await self.checks[check_name]()
                    results[check_name] = result
                    self.status[check_name] = result
                    self.last_check[check_name] = time.time()
                except Exception as e:
                    logger.error(f"Health check '{check_name}' failed: {e}")
                    results[check_name] = {
                        'status': 'error',
                        'message': str(e),
                        'timestamp': time.time(),
                    }

        return results

    async def check_system_resources(self) -> Dict[str, Any]:
        """Check system resource availability."""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage(Path.home())

            status = 'healthy'
            issues = []

            if cpu_percent > 90:
                status = 'warning'
                issues.append(f'High CPU usage: {cpu_percent}%')

            if memory.percent > 90:
                status = 'critical' if memory.percent > 95 else 'warning'
                issues.append(f'High memory usage: {memory.percent}%')

            if disk.percent > 90:
                status = 'critical' if disk.percent > 95 else 'warning'
                issues.append(f'Low disk space: {100 - disk.percent:.1f}% free')

            return {
                'status': status,
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_available_gb': memory.available / (1024**3),
                'disk_free_gb': disk.free / (1024**3),
                'disk_percent': disk.percent,
                'issues': issues,
                'timestamp': time.time(),
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

    async def check_mlx_server(self, port: int = 8080) -> Dict[str, Any]:
        """Check if MLX server is running and responsive."""
        try:
            async with aiohttp.ClientSession() as session:
                url = f'http://localhost:{port}/v1/models'
                async with session.get(url, timeout=2) as response:
                    if response.status == 200:
                        data = await response.json()
                        return {
                            'status': 'healthy',
                            'running': True,
                            'port': port,
                            'models': len(data.get('data', [])),
                            'timestamp': time.time(),
                        }
        except asyncio.TimeoutError:
            return {
                'status': 'timeout',
                'running': False,
                'port': port,
                'message': 'Server not responding',
                'timestamp': time.time(),
            }
        except Exception:
            return {'status': 'offline', 'running': False, 'port': port, 'timestamp': time.time()}

    async def check_ollama_server(self, port: int = 11434) -> Dict[str, Any]:
        """Check if Ollama server is running."""
        try:
            async with aiohttp.ClientSession() as session:
                url = f'http://localhost:{port}/api/tags'
                async with session.get(url, timeout=2) as response:
                    if response.status == 200:
                        data = await response.json()
                        return {
                            'status': 'healthy',
                            'running': True,
                            'port': port,
                            'models': len(data.get('models', [])),
                            'timestamp': time.time(),
                        }
        except (ConnectionError, OSError, asyncio.TimeoutError):
            return {'status': 'offline', 'running': False, 'port': port, 'timestamp': time.time()}

    async def check_api_keys(self) -> Dict[str, Any]:
        """Check if API keys are configured."""
        api_keys = {
            'anthropic': bool(os.environ.get('ANTHROPIC_API_KEY')),
            'openai': bool(os.environ.get('OPENAI_API_KEY')),
            'gemini': bool(os.environ.get('GEMINI_API_KEY') or os.environ.get('GOOGLE_API_KEY')),
        }

        configured = sum(api_keys.values())
        total = len(api_keys)

        return {
            'status': 'healthy' if configured > 0 else 'warning',
            'configured': configured,
            'total': total,
            'details': api_keys,
            'timestamp': time.time(),
        }

    async def check_network(self) -> Dict[str, Any]:
        """Check network connectivity."""
        try:
            async with aiohttp.ClientSession() as session:
                # Check multiple endpoints for robustness
                endpoints = [
                    'https://api.openai.com',
                    'https://api.anthropic.com',
                    'https://generativelanguage.googleapis.com',
                ]

                results = []
                for endpoint in endpoints:
                    try:
                        async with session.head(endpoint, timeout=3) as response:
                            results.append(response.status < 500)
                    except (ConnectionError, OSError, asyncio.TimeoutError):
                        results.append(False)

                success_rate = sum(results) / len(results)

                return {
                    'status': 'healthy' if success_rate > 0.5 else 'degraded',
                    'connectivity': success_rate * 100,
                    'timestamp': time.time(),
                }
        except Exception as e:
            return {
                'status': 'error',
                'connectivity': 0,
                'message': str(e),
                'timestamp': time.time(),
            }

    async def check_disk_space(self) -> Dict[str, Any]:
        """Check available disk space for model storage."""
        try:
            paths = [
                Path.home() / '.cache' / 'mlx_models',
                Path.home() / '.ollama' / 'models',
                Path.home() / '.cache' / 'huggingface',
            ]

            total_size = 0
            for path in paths:
                if path.exists():
                    total_size += sum(f.stat().st_size for f in path.rglob('*') if f.is_file())

            disk = psutil.disk_usage(Path.home())
            free_gb = disk.free / (1024**3)
            used_gb = total_size / (1024**3)

            return {
                'status': 'healthy' if free_gb > 10 else 'warning',
                'model_cache_gb': used_gb,
                'free_space_gb': free_gb,
                'total_space_gb': disk.total / (1024**3),
                'timestamp': time.time(),
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

    async def check_model_cache(self) -> Dict[str, Any]:
        """Check model cache status."""
        try:
            mlx_path = Path.home() / '.cache' / 'mlx_models'
            ollama_path = Path.home() / '.ollama' / 'models'

            mlx_models = len(list(mlx_path.glob('*'))) if mlx_path.exists() else 0
            ollama_models = len(list(ollama_path.glob('*'))) if ollama_path.exists() else 0

            return {
                'status': 'healthy',
                'mlx_models': mlx_models,
                'ollama_models': ollama_models,
                'total_models': mlx_models + ollama_models,
                'timestamp': time.time(),
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}

    def get_summary(self) -> Dict[str, Any]:
        """Get a summary of all health checks."""
        overall_status = 'healthy'
        issues = []

        for check_name, status in self.status.items():
            if status.get('status') == 'critical':
                overall_status = 'critical'
                issues.append(f'{check_name}: {status.get("message", "Critical issue")}')
            elif status.get('status') == 'warning' and overall_status != 'critical':
                overall_status = 'warning'
                issues.append(f'{check_name}: {status.get("message", "Warning")}')
            elif status.get('status') == 'error':
                if overall_status not in ['critical', 'warning']:
                    overall_status = 'degraded'
                issues.append(f'{check_name}: {status.get("message", "Error")}')

        return {
            'overall_status': overall_status,
            'checks_run': len(self.status),
            'issues': issues,
            'last_update': max(self.last_check.values()) if self.last_check else None,
        }


# Global health monitor instance
health_monitor = HealthMonitor()
