"""
System utilities for detecting hardware capabilities and making recommendations.
"""

from dataclasses import dataclass
from enum import Enum
import logging
import platform
import subprocess
from typing import Any, Dict, List, Optional

import psutil

logger = logging.getLogger(__name__)


class SystemType(Enum):
    """System type classification."""
    MACOS_APPLE_SILICON = "macos_apple_silicon"
    MACOS_INTEL = "macos_intel"
    LINUX = "linux"
    WINDOWS = "windows"
    UNKNOWN = "unknown"


class PerformanceTier(Enum):
    """Performance tier based on system capabilities."""
    ULTRA = "ultra"  # 64GB+ RAM, high-end GPU
    HIGH = "high"  # 32GB+ RAM, good GPU
    MEDIUM = "medium"  # 16GB+ RAM, decent GPU
    LOW = "low"  # 8GB+ RAM, basic GPU
    MINIMAL = "minimal"  # < 8GB RAM


@dataclass
class SystemInfo:
    """System information and capabilities."""
    os_type: SystemType
    cpu_model: str
    cpu_cores: int
    ram_gb: float
    ram_available_gb: float
    gpu_info: str
    gpu_memory_gb: Optional[float]
    performance_tier: PerformanceTier
    has_neural_engine: bool
    has_cuda: bool
    has_metal: bool
    platform_details: Dict[str, Any]


class SystemDetector:
    """Detect system capabilities and specifications."""

    @staticmethod
    def detect_system() -> SystemInfo:
        """Detect and return system information."""
        os_type = SystemDetector._detect_os_type()
        cpu_info = SystemDetector._get_cpu_info()
        memory_info = SystemDetector._get_memory_info()
        gpu_info = SystemDetector._get_gpu_info(os_type)

        # Determine performance tier
        performance_tier = SystemDetector._calculate_performance_tier(memory_info["ram_gb"],
                                                                      gpu_info.get("memory_gb"),
                                                                      os_type)

        return SystemInfo(os_type=os_type,
                          cpu_model=cpu_info["model"],
                          cpu_cores=cpu_info["cores"],
                          ram_gb=memory_info["ram_gb"],
                          ram_available_gb=memory_info["available_gb"],
                          gpu_info=gpu_info.get("name", "Unknown"),
                          gpu_memory_gb=gpu_info.get("memory_gb"),
                          performance_tier=performance_tier,
                          has_neural_engine=gpu_info.get("has_neural_engine", False),
                          has_cuda=gpu_info.get("has_cuda", False),
                          has_metal=gpu_info.get("has_metal", False),
                          platform_details={
                              "platform": platform.platform(),
                              "processor": platform.processor(),
                              "machine": platform.machine(),
                              "python_version": platform.python_version(),
                          })

    @staticmethod
    def _detect_os_type() -> SystemType:
        """Detect the operating system type."""
        system = platform.system().lower()

        if system == "darwin":
            # Check if Apple Silicon
            machine = platform.machine().lower()
            if "arm" in machine or "m1" in machine or "m2" in machine or "m3" in machine:
                return SystemType.MACOS_APPLE_SILICON
            else:
                return SystemType.MACOS_INTEL
        elif system == "linux":
            return SystemType.LINUX
        elif system == "windows":
            return SystemType.WINDOWS
        else:
            return SystemType.UNKNOWN

    @staticmethod
    def _get_cpu_info() -> Dict[str, Any]:
        """Get CPU information."""
        try:
            cpu_count = psutil.cpu_count(logical=False) or psutil.cpu_count()

            # Try to get CPU model
            cpu_model = "Unknown"
            if platform.system() == "Darwin":
                # macOS
                try:
                    result = subprocess.run(["sysctl", "-n", "machdep.cpu.brand_string"],
                                            capture_output=True,
                                            text=True,
                                            check=True)
                    cpu_model = result.stdout.strip()
                except:
                    pass
            elif platform.system() == "Linux":
                # Linux
                try:
                    with open("/proc/cpuinfo", "r") as f:
                        for line in f:
                            if "model name" in line:
                                cpu_model = line.split(":")[1].strip()
                                break
                except:
                    pass

            return {
                "model": cpu_model,
                "cores": cpu_count,
                "frequency": psutil.cpu_freq().current if psutil.cpu_freq() else 0
            }
        except Exception as e:
            logger.warning(f"Failed to get CPU info: {e}")
            return {"model": "Unknown", "cores": 4, "frequency": 0}

    @staticmethod
    def _get_memory_info() -> Dict[str, Any]:
        """Get memory information."""
        try:
            mem = psutil.virtual_memory()
            return {
                "ram_gb": round(mem.total / (1024**3), 1),
                "available_gb": round(mem.available / (1024**3), 1),
                "used_gb": round(mem.used / (1024**3), 1),
                "percent": mem.percent
            }
        except Exception as e:
            logger.warning(f"Failed to get memory info: {e}")
            return {"ram_gb": 8.0, "available_gb": 4.0, "used_gb": 4.0, "percent": 50}

    @staticmethod
    def _get_gpu_info(os_type: SystemType) -> Dict[str, Any]:
        """Get GPU information based on OS type."""
        gpu_info = {}

        try:
            if os_type == SystemType.MACOS_APPLE_SILICON:
                # Apple Silicon specific detection
                gpu_info["name"] = "Apple Silicon GPU"
                gpu_info["has_metal"] = True
                gpu_info["has_neural_engine"] = True

                # Try to detect specific chip
                try:
                    result = subprocess.run(["system_profiler", "SPHardwareDataType"],
                                            capture_output=True,
                                            text=True,
                                            check=True)
                    output = result.stdout.lower()

                    if "m3 max" in output:
                        gpu_info["name"] = "Apple M3 Max"
                        gpu_info["memory_gb"] = 48 if "128 gb" in output else 36
                    elif "m3 pro" in output:
                        gpu_info["name"] = "Apple M3 Pro"
                        gpu_info["memory_gb"] = 18
                    elif "m3" in output:
                        gpu_info["name"] = "Apple M3"
                        gpu_info["memory_gb"] = 8
                    elif "m2 max" in output:
                        gpu_info["name"] = "Apple M2 Max"
                        gpu_info["memory_gb"] = 32
                    elif "m2 pro" in output:
                        gpu_info["name"] = "Apple M2 Pro"
                        gpu_info["memory_gb"] = 16
                    elif "m2" in output:
                        gpu_info["name"] = "Apple M2"
                        gpu_info["memory_gb"] = 8
                    elif "m1 max" in output:
                        gpu_info["name"] = "Apple M1 Max"
                        gpu_info["memory_gb"] = 32
                    elif "m1 pro" in output:
                        gpu_info["name"] = "Apple M1 Pro"
                        gpu_info["memory_gb"] = 16
                    elif "m1" in output:
                        gpu_info["name"] = "Apple M1"
                        gpu_info["memory_gb"] = 8

                    # For unified memory, GPU memory is shared with system RAM
                    # Estimate available GPU memory as ~75% of total RAM
                    mem_info = SystemDetector._get_memory_info()
                    gpu_info["memory_gb"] = round(mem_info["ram_gb"] * 0.75, 1)

                except:
                    pass

            elif os_type == SystemType.LINUX:
                # Try to detect NVIDIA GPU
                try:
                    result = subprocess.run(
                        ["nvidia-smi", "--query-gpu=name,memory.total", "--format=csv,noheader"],
                        capture_output=True,
                        text=True,
                        check=True)
                    lines = result.stdout.strip().split("\n")
                    if lines:
                        parts = lines[0].split(",")
                        gpu_info["name"] = parts[0].strip()
                        mem_str = parts[1].strip()
                        # Parse memory (e.g., "24576 MiB")
                        mem_mb = float(mem_str.split()[0])
                        gpu_info["memory_gb"] = round(mem_mb / 1024, 1)
                        gpu_info["has_cuda"] = True
                except:
                    gpu_info["name"] = "CPU only"
                    gpu_info["has_cuda"] = False

            elif os_type == SystemType.MACOS_INTEL:
                # Intel Mac GPU detection
                gpu_info["name"] = "Intel/AMD GPU"
                gpu_info["has_metal"] = True
                gpu_info["has_neural_engine"] = False

        except Exception as e:
            logger.warning(f"Failed to get GPU info: {e}")
            gpu_info["name"] = "Unknown"

        return gpu_info

    @staticmethod
    def _calculate_performance_tier(ram_gb: float, gpu_memory_gb: Optional[float],
                                    os_type: SystemType) -> PerformanceTier:
        """Calculate system performance tier."""
        # Apple Silicon gets a boost due to unified memory and efficiency
        if os_type == SystemType.MACOS_APPLE_SILICON:
            if ram_gb >= 64:
                return PerformanceTier.ULTRA
            elif ram_gb >= 32:
                return PerformanceTier.HIGH
            elif ram_gb >= 16:
                return PerformanceTier.MEDIUM
            elif ram_gb >= 8:
                return PerformanceTier.LOW
            else:
                return PerformanceTier.MINIMAL
        else:
            # Standard tiers for other systems
            if ram_gb >= 64 and gpu_memory_gb and gpu_memory_gb >= 16:
                return PerformanceTier.ULTRA
            elif ram_gb >= 32 and gpu_memory_gb and gpu_memory_gb >= 8:
                return PerformanceTier.HIGH
            elif ram_gb >= 16:
                return PerformanceTier.MEDIUM
            elif ram_gb >= 8:
                return PerformanceTier.LOW
            else:
                return PerformanceTier.MINIMAL


class ModelRecommender:
    """Recommend models based on system capabilities."""

    @staticmethod
    def recommend_models(
            system_info: SystemInfo,
            models: List[Any],  # List of ModelInfo objects
            max_recommendations: int = 10,
            prefer_local: bool = True,
            capability_filter: Optional[str] = None) -> List[Any]:
        """Recommend models based on system capabilities.

        Args:
            system_info: System information and capabilities
            models: List of available models
            max_recommendations: Maximum number of recommendations
            prefer_local: Prefer local models over cloud models
            capability_filter: Filter by specific capability (code, vision, etc.)

        Returns:
            List of recommended models sorted by suitability
        """
        if not models:
            return []

        recommendations = []

        # Apply capability filter if specified
        filtered_models = models
        if capability_filter:
            from . import ModelCapability
            cap_enum = ModelCapability(capability_filter)
            filtered_models = [m for m in models if cap_enum in m.capabilities]

        # Filter models that can run on this system
        viable_models = []
        for model in filtered_models:
            # Online models are always viable
            if model.online:
                if not prefer_local or len(viable_models) < max_recommendations // 2:
                    fitness_score = ModelRecommender._calculate_fitness_score(
                        model, system_info, prefer_local)
                    model.metadata["fitness_score"] = fitness_score
                    viable_models.append(model)
            else:
                # Check if model can fit in available RAM (with safety margin)
                required_ram = model.ram_gb * 1.2  # 20% safety margin

                if required_ram <= system_info.ram_available_gb:
                    fitness_score = ModelRecommender._calculate_fitness_score(
                        model, system_info, prefer_local)
                    model.metadata["fitness_score"] = fitness_score
                    viable_models.append(model)

        # Sort by fitness score
        viable_models.sort(key=lambda m: m.metadata.get("fitness_score", 0), reverse=True)

        # Ensure diversity in recommendations
        recommendations = ModelRecommender._ensure_diversity(viable_models, max_recommendations)

        return recommendations

    @staticmethod
    def _calculate_fitness_score(model: Any,
                                 system_info: SystemInfo,
                                 prefer_local: bool = True) -> float:
        """Calculate how well a model fits the system."""
        score = 0.0

        # Base score from model capability
        score += model.score

        # Efficiency bonus - prefer models that use resources well
        ram_utilization = model.ram_gb / system_info.ram_gb
        if 0.3 <= ram_utilization <= 0.7:
            score += 20  # Optimal utilization
        elif ram_utilization < 0.3:
            score += 10  # Under-utilizing
        elif ram_utilization > 0.9:
            score -= 20  # Too close to limits

        # Platform-specific bonuses
        if system_info.os_type == SystemType.MACOS_APPLE_SILICON:
            if model.provider == "mlx":
                score += 30  # MLX is optimized for Apple Silicon
            elif model.provider == "ollama":
                score += 10  # Ollama works well too

        # Performance tier adjustments
        if system_info.performance_tier == PerformanceTier.ULTRA:
            # Prefer larger, more capable models
            if model.size_gb >= 30:
                score += 20
        elif system_info.performance_tier == PerformanceTier.LOW:
            # Prefer smaller, efficient models
            if model.size_gb <= 4:
                score += 20

        # Context window bonus for coding
        if "code" in [cap.value for cap in model.capabilities]:
            if model.context_window >= 32000:
                score += 15

        # Popularity bonus (well-tested models)
        if model.downloads > 10000:
            score += 5
        if model.likes > 100:
            score += 3

        # Prefer local models if specified
        if prefer_local and not model.online:
            score += 15
        elif not prefer_local and model.online:
            score += 10

        return score

    @staticmethod
    def _ensure_diversity(models: List[Any], max_count: int) -> List[Any]:
        """Ensure diversity in model recommendations."""
        if len(models) <= max_count:
            return models

        recommendations = []
        providers_included = set()
        sizes_included = set()

        # First pass: Include best model from each provider
        for model in models:
            if len(recommendations) >= max_count:
                break

            if model.provider not in providers_included:
                recommendations.append(model)
                providers_included.add(model.provider)
                sizes_included.add(ModelRecommender._categorize_size(model.size_gb))

        # Second pass: Fill with diverse sizes
        for model in models:
            if len(recommendations) >= max_count:
                break

            if model not in recommendations:
                size_cat = ModelRecommender._categorize_size(model.size_gb)
                if size_cat not in sizes_included or len(sizes_included) >= 3:
                    recommendations.append(model)
                    sizes_included.add(size_cat)

        return recommendations

    @staticmethod
    def _categorize_size(size_gb: float) -> str:
        """Categorize model size."""
        if size_gb < 2:
            return "tiny"
        elif size_gb < 5:
            return "small"
        elif size_gb < 15:
            return "medium"
        elif size_gb < 40:
            return "large"
        else:
            return "xlarge"
