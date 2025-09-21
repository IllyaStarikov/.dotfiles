"""
MLX Provider for Apple Silicon Macs

Provides access to MLX models optimized for Apple Silicon.
"""

import asyncio
import json
import logging
import re
from pathlib import Path
from typing import Any, Dict, List, Optional

import aiohttp

from . import BaseProvider, ModelCapability, ModelInfo, ProviderType

logger = logging.getLogger(__name__)


class MLXProvider(BaseProvider):
    """Provider for MLX models on Apple Silicon."""

    MLX_HUB_API = "https://huggingface.co/api/models"
    MLX_SERVER_PORT = 8080

    @property
    def provider_type(self) -> ProviderType:
        """MLX is offline once models are downloaded."""
        return ProviderType.OFFLINE

    @property
    def requires_api_key(self) -> bool:
        """MLX doesn't require an API key."""
        return False

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize MLX provider."""
        super().__init__(config)
        self.mlx_path = Path.home() / ".cache" / "mlx"
        self.server_process = None

    async def fetch_models(self, force_refresh: bool = False) -> List[ModelInfo]:
        """Fetch MLX models from HuggingFace Hub."""
        models = []

        try:
            # Fetch MLX models from HuggingFace
            async with aiohttp.ClientSession() as session:
                params = {
                    "author": "mlx-community",  # Use author instead of filter
                    "sort": "downloads",
                    "direction": "-1",
                    "limit": "100"  # Get top 100 models
                }

                async with session.get(self.MLX_HUB_API, params=params) as response:
                    if response.status == 200:
                        data = await response.json()

                        for model_data in data:
                            model_id = model_data.get("id", "")

                            # All results should be from mlx-community with author filter
                            # But double-check just in case
                            if not (model_id.startswith("mlx-community/") or
                                    "mlx" in model_data.get("library_name", "")):
                                continue

                            # Extract model info from the data
                            model_info = await self._parse_huggingface_model(session, model_data)
                            if model_info:
                                models.append(model_info)

                        logger.info(f"Fetched {len(models)} MLX models from HuggingFace")
        except Exception as e:
            logger.error(f"Failed to fetch MLX models: {e}")

        # Also check local models
        local_models = await self._scan_local_models()

        # Merge local models with fetched ones
        model_ids = {m.id for m in models}
        for local_model in local_models:
            if local_model.id not in model_ids:
                models.append(local_model)

        return models

    async def _parse_huggingface_model(self, session: aiohttp.ClientSession,
                                       model_data: Dict[str, Any]) -> Optional[ModelInfo]:
        """Parse HuggingFace model data into ModelInfo."""
        try:
            model_id = model_data.get("id", "")
            model_name = model_id.split("/")[-1] if "/" in model_id else model_id

            # Extract metadata from tags and model card
            tags = model_data.get("tags", [])
            downloads = model_data.get("downloads", 0)
            likes = model_data.get("likes", 0)

            # Try to fetch model details from HuggingFace
            model_details = {}
            try:
                detail_url = f"https://huggingface.co/api/models/{model_id}"
                async with session.get(detail_url) as resp:
                    if resp.status == 200:
                        model_details = await resp.json()
            except:
                pass

            # Extract from model details or infer
            siblings = model_details.get("siblings", [])

            # Calculate actual size from file siblings
            size_gb = 0
            for sibling in siblings:
                if sibling.get("rfilename", "").endswith((".gguf", ".safetensors", ".bin")):
                    size_bytes = sibling.get("size", 0)
                    size_gb += size_bytes / (1024**3)

            # If no size from API, extract from model name
            if size_gb == 0:
                size_gb = self._extract_size_from_name(model_name)

            # Extract or infer capabilities
            capabilities = self._extract_capabilities(model_name, tags, model_details)

            # Extract context from model card or name
            context = self._extract_context(model_name, model_details)

            # Calculate score based on downloads and likes
            score = min(100, 50 + (downloads // 1000) + (likes // 10))

            # Check if model is downloaded locally
            local_path = self.mlx_path / model_id.replace("/", "_")
            is_downloaded = local_path.exists()

            # Get description from model card
            description = model_details.get("cardData", {}).get("description", "")
            if not description:
                description = "MLX model optimized for Apple Silicon"

            return ModelInfo(
                id=model_id,
                name=model_name,
                provider="mlx",
                size_gb=size_gb if size_gb > 0 else self._extract_size_from_name(model_name),
                ram_gb=(size_gb if size_gb > 0 else self._extract_size_from_name(model_name)) * 1.2,
                context_window=context,
                capabilities=capabilities,
                online=False,
                open_source=True,
                recommended_ram=(size_gb if size_gb > 0 else
                                 self._extract_size_from_name(model_name)) * 1.2,
                description=description[:200]
                if description else "MLX model optimized for Apple Silicon",
                score=score,
                downloads=downloads,
                likes=likes,
                metadata={
                    "downloaded": is_downloaded,
                    "local_path": str(local_path) if is_downloaded else None,
                    "tags": tags,
                    "library": model_details.get("library_name"),
                    "pipeline_tag": model_details.get("pipeline_tag")
                })
        except Exception as e:
            logger.debug(f"Failed to parse model {model_data.get('id')}: {e}")
            return None

    def _extract_size_from_name(self, model_name: str) -> float:
        """Extract model size in GB from name using regex."""
        model_lower = model_name.lower()

        # Try to extract parameter count with regex
        size_patterns = [
            (r'(\d+\.?\d*)b', 1.0),  # billions of parameters
            (r'(\d+)m', 0.001),  # millions of parameters
        ]

        for pattern, multiplier in size_patterns:
            match = re.search(pattern, model_lower)
            if match:
                param_count = float(match.group(1))
                # Rough estimate: 4-bit quantization
                return param_count * multiplier * 0.5  # 0.5 GB per billion params at 4-bit

        # Default size if can't extract
        return 3.8

    def _extract_context(self, model_name: str, model_details: Dict[str, Any]) -> int:
        """Extract context window from model details or name."""
        model_lower = model_name.lower()

        # Check model config if available
        config = model_details.get("config", {})
        if "max_position_embeddings" in config:
            return config["max_position_embeddings"]

        # Extract from name with regex
        context_patterns = [
            (r'(\d+)k', 1024),  # e.g., 32k, 128k
            (r'(\d+)m', 1048576),  # e.g., 1m, 2m
        ]

        for pattern, multiplier in context_patterns:
            match = re.search(pattern, model_lower)
            if match:
                return int(match.group(1)) * multiplier

        # Model-specific defaults
        if "llama-3.1" in model_lower or "llama-3-1" in model_lower:
            return 131072
        elif "deepseek" in model_lower:
            return 163840
        elif "mistral" in model_lower:
            return 32768
        elif "codellama" in model_lower:
            return 16384

        return 8192  # Default

    def _extract_capabilities(self, model_name: str, tags: List[str],
                              model_details: Dict[str, Any]) -> List[ModelCapability]:
        """Extract capabilities from model metadata."""
        capabilities = []
        model_lower = model_name.lower()
        pipeline_tag = model_details.get("pipeline_tag", "")

        # Check tags first
        if "code" in tags or "text-generation" in tags:
            capabilities.append(ModelCapability.CHAT)

        # Check pipeline tag
        if pipeline_tag == "text-generation":
            if ModelCapability.CHAT not in capabilities:
                capabilities.append(ModelCapability.CHAT)
        elif pipeline_tag == "image-text-to-text":
            capabilities.extend([ModelCapability.VISION, ModelCapability.MULTIMODAL])

        # Check model name patterns
        if any(x in model_lower
               for x in ["code", "coder", "codellama", "deepseek-coder", "qwen2.5-coder"]):
            if ModelCapability.CODE not in capabilities:
                capabilities.append(ModelCapability.CODE)
            if ModelCapability.CHAT not in capabilities:
                capabilities.append(ModelCapability.CHAT)
        elif any(x in model_lower for x in ["vision", "llava", "multimodal"]):
            if ModelCapability.VISION not in capabilities:
                capabilities.append(ModelCapability.VISION)
            if ModelCapability.MULTIMODAL not in capabilities:
                capabilities.append(ModelCapability.MULTIMODAL)
            if ModelCapability.CHAT not in capabilities:
                capabilities.append(ModelCapability.CHAT)
        elif any(x in model_lower for x in ["instruct", "chat", "assistant"]):
            if ModelCapability.CHAT not in capabilities:
                capabilities.append(ModelCapability.CHAT)

        # Default to chat if no capabilities found
        if not capabilities:
            capabilities.append(ModelCapability.CHAT)

        return capabilities

    async def _scan_local_models(self) -> List[ModelInfo]:
        """Scan for locally downloaded MLX models."""
        models = []

        if not self.mlx_path.exists():
            return models

        try:
            # Look for model directories
            for model_dir in self.mlx_path.iterdir():
                if model_dir.is_dir():
                    # Try to load model config
                    config_path = model_dir / "config.json"
                    if config_path.exists():
                        with open(config_path, 'r') as f:
                            config = json.load(f)

                        model_id = model_dir.name.replace("_", "/")
                        model_name = model_id.split("/")[-1]

                        # Get actual size on disk
                        size_gb = sum(
                            f.stat().st_size for f in model_dir.rglob("*") if f.is_file()) / (1024**
                                                                                              3)

                        # Extract capabilities from config
                        capabilities = []
                        architectures = config.get("architectures", [])
                        if any("Code" in arch for arch in architectures):
                            capabilities.extend([ModelCapability.CODE, ModelCapability.CHAT])
                        else:
                            capabilities.append(ModelCapability.CHAT)

                        model_info = ModelInfo(id=model_id,
                                               name=model_name,
                                               provider="mlx",
                                               size_gb=size_gb,
                                               ram_gb=size_gb * 1.2,
                                               context_window=config.get(
                                                   "max_position_embeddings", 8192),
                                               capabilities=capabilities,
                                               online=False,
                                               open_source=True,
                                               recommended_ram=size_gb * 1.2,
                                               description="Local MLX model",
                                               score=70,
                                               metadata={
                                                   "downloaded": True,
                                                   "local_path": str(model_dir),
                                                   "model_type": config.get("model_type"),
                                                   "architectures": architectures
                                               })
                        models.append(model_info)
        except Exception as e:
            logger.debug(f"Error scanning local models: {e}")

        return models

    async def download_model(self, model_id: str, progress_callback=None) -> bool:
        """Download an MLX model from HuggingFace."""
        try:
            # Check if model is already quantized (has "bit" in name)
            is_quantized = any(
                x in model_id.lower() for x in ["-4bit", "-8bit", "-2bit", "-3bit", "-6bit"])

            # Ensure MLX models directory exists
            self.mlx_path.mkdir(parents=True, exist_ok=True)
            output_path = self.mlx_path / model_id.replace("/", "_")

            # Remove existing model directory if it exists (for re-download)
            if output_path.exists():
                import shutil
                shutil.rmtree(output_path)
                logger.info(f"Removed existing model at {output_path}")

            # Build command - don't quantize already quantized models
            if is_quantized:
                # Download without quantization for pre-quantized models
                cmd = ["mlx_lm", "convert", "--hf-path", model_id, "--mlx-path", str(output_path)]
            else:
                # Apply quantization for full precision models
                cmd = [
                    "mlx_lm", "convert", "--hf-path", model_id, "--mlx-path",
                    str(output_path), "-q"
                ]

            # Check if mlx_lm is installed
            check_cmd = await asyncio.create_subprocess_exec("which",
                                                             "mlx_lm",
                                                             stdout=asyncio.subprocess.PIPE,
                                                             stderr=asyncio.subprocess.PIPE)
            stdout, stderr = await check_cmd.communicate()

            if check_cmd.returncode != 0:
                # Try using Python module directly
                if is_quantized:
                    cmd = [
                        "python", "-m", "mlx_lm.convert", "--hf-path", model_id, "--mlx-path",
                        str(output_path)
                    ]
                else:
                    cmd = [
                        "python", "-m", "mlx_lm.convert", "--hf-path", model_id, "--mlx-path",
                        str(output_path), "-q"
                    ]

            process = await asyncio.create_subprocess_exec(*cmd,
                                                           stdout=asyncio.subprocess.PIPE,
                                                           stderr=asyncio.subprocess.PIPE)

            # Monitor output for progress
            total_size = 0
            downloaded = 0

            while True:
                line = await process.stdout.readline()
                if not line:
                    break

                line_text = line.decode().strip()

                # Parse download progress from output
                if "Downloading" in line_text:
                    # Extract file size if available
                    import re
                    size_match = re.search(r'(\d+\.?\d*)\s*(GB|MB|KB)', line_text)
                    if size_match:
                        size = float(size_match.group(1))
                        unit = size_match.group(2)
                        if unit == "GB":
                            total_size = size * 1024 * 1024 * 1024
                        elif unit == "MB":
                            total_size = size * 1024 * 1024
                        elif unit == "KB":
                            total_size = size * 1024

                # Update progress if callback provided
                if progress_callback and total_size > 0:
                    # Estimate progress (simplified)
                    downloaded += len(line)
                    progress_callback(downloaded, total_size)

            await process.wait()

            if process.returncode == 0:
                logger.info(f"Successfully downloaded {model_id}")

                # Create marker for downloaded model
                local_path = self.mlx_path / model_id.replace("/", "_")
                local_path.mkdir(parents=True, exist_ok=True)

                return True
            else:
                stderr_output = await process.stderr.read()
                logger.error(f"Failed to download {model_id}: {stderr_output.decode()}")
                return False

        except Exception as e:
            logger.error(f"Error downloading model {model_id}: {e}")
            return False

    async def is_model_available(self, model_id: str) -> bool:
        """Check if a model is available locally."""
        local_path = self.mlx_path / model_id.replace("/", "_")
        return local_path.exists()

    async def start_server(self, model_id: str, **kwargs) -> bool:
        """Start MLX server with specified model."""
        try:
            # Stop existing server if running
            await self.stop_server()

            cmd = ["mlx_lm.server", "--model", model_id, "--port", str(self.MLX_SERVER_PORT)]

            self.server_process = await asyncio.create_subprocess_exec(
                *cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)

            # Wait a bit for server to start
            await asyncio.sleep(3)

            # Check if server is running
            if self.server_process.returncode is None:
                logger.info(f"MLX server started with model {model_id}")
                return True
            else:
                logger.error("MLX server failed to start")
                return False

        except Exception as e:
            logger.error(f"Error starting MLX server: {e}")
            return False

    async def stop_server(self) -> bool:
        """Stop MLX server."""
        if self.server_process:
            try:
                self.server_process.terminate()
                await self.server_process.wait()
                self.server_process = None
                logger.info("MLX server stopped")
                return True
            except Exception as e:
                logger.error(f"Error stopping MLX server: {e}")
                return False
        return True

    async def get_server_status(self) -> Dict[str, Any]:
        """Get MLX server status."""
        return {
            "running": self.server_process is not None and self.server_process.returncode is None,
            "port": self.MLX_SERVER_PORT,
            "type": "mlx"
        }
