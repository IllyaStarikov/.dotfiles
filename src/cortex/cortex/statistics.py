"""
Statistics tracking and analytics for Cortex.
"""

import json
import logging
import time
from dataclasses import asdict, dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)


@dataclass
class ChatSession:
    """Chat session statistics."""
    session_id: str
    model: str
    provider: str
    start_time: float
    end_time: Optional[float]
    duration_seconds: float
    input_tokens: int
    output_tokens: int
    total_tokens: int
    messages: int
    temperature: float
    max_tokens: Optional[int]
    ensemble: bool
    ensemble_models: List[str]
    error: Optional[str]
    metadata: Dict[str, Any]


@dataclass
class ModelUsage:
    """Model usage statistics."""
    model_id: str
    provider: str
    total_sessions: int
    total_tokens: int
    total_duration_seconds: float
    average_tokens_per_session: float
    average_duration_seconds: float
    last_used: float
    error_count: int
    success_rate: float


class StatisticsTracker:
    """Track and analyze usage statistics."""

    def __init__(self, stats_dir: Optional[Path] = None):
        """Initialize statistics tracker."""
        self.stats_dir = stats_dir or (Path.home() / ".dotfiles" / "config" / "cortex" / "stats")
        self.stats_dir.mkdir(parents=True, exist_ok=True)

        self.sessions_file = self.stats_dir / "sessions.json"
        self.models_file = self.stats_dir / "models.json"
        self.daily_file = self.stats_dir / "daily.json"

        self.current_session = None
        self.sessions = self._load_sessions()
        self.model_stats = self._load_model_stats()

    def _load_sessions(self) -> List[ChatSession]:
        """Load session history."""
        if self.sessions_file.exists():
            try:
                with open(self.sessions_file) as f:
                    data = json.load(f)
                return [ChatSession(**s) for s in data[-1000:]]  # Keep last 1000 sessions
            except Exception as e:
                logger.error(f"Failed to load sessions: {e}")
        return []

    def _load_model_stats(self) -> Dict[str, ModelUsage]:
        """Load model usage statistics."""
        if self.models_file.exists():
            try:
                with open(self.models_file) as f:
                    data = json.load(f)
                return {k: ModelUsage(**v) for k, v in data.items()}
            except Exception as e:
                logger.error(f"Failed to load model stats: {e}")
        return {}

    def _save_sessions(self):
        """Save session history."""
        try:
            with open(self.sessions_file, 'w') as f:
                json.dump([asdict(s) for s in self.sessions[-1000:]], f, indent=2)
        except Exception as e:
            logger.error(f"Failed to save sessions: {e}")

    def _save_model_stats(self):
        """Save model statistics."""
        try:
            with open(self.models_file, 'w') as f:
                json.dump({k: asdict(v) for k, v in self.model_stats.items()}, f, indent=2)
        except Exception as e:
            logger.error(f"Failed to save model stats: {e}")

    def start_session(self,
                      model: str,
                      provider: str,
                      temperature: float = 0.7,
                      max_tokens: Optional[int] = None,
                      ensemble: bool = False,
                      ensemble_models: List[str] = None) -> str:
        """Start a new chat session."""
        session_id = f"{model}_{int(time.time())}"

        self.current_session = ChatSession(session_id=session_id,
                                           model=model,
                                           provider=provider,
                                           start_time=time.time(),
                                           end_time=None,
                                           duration_seconds=0,
                                           input_tokens=0,
                                           output_tokens=0,
                                           total_tokens=0,
                                           messages=0,
                                           temperature=temperature,
                                           max_tokens=max_tokens,
                                           ensemble=ensemble,
                                           ensemble_models=ensemble_models or [],
                                           error=None,
                                           metadata={})

        logger.info(f"Started session {session_id}")
        return session_id

    def update_session(self,
                       input_tokens: int = 0,
                       output_tokens: int = 0,
                       messages: int = 0,
                       metadata: Optional[Dict[str, Any]] = None):
        """Update current session statistics."""
        if not self.current_session:
            logger.warning("No active session to update")
            return

        self.current_session.input_tokens += input_tokens
        self.current_session.output_tokens += output_tokens
        self.current_session.total_tokens = (self.current_session.input_tokens +
                                             self.current_session.output_tokens)
        self.current_session.messages += messages

        if metadata:
            self.current_session.metadata.update(metadata)

    def end_session(self, error: Optional[str] = None):
        """End the current chat session."""
        if not self.current_session:
            logger.warning("No active session to end")
            return

        self.current_session.end_time = time.time()
        self.current_session.duration_seconds = (self.current_session.end_time -
                                                 self.current_session.start_time)
        self.current_session.error = error

        # Add to sessions list
        self.sessions.append(self.current_session)
        self._save_sessions()

        # Update model statistics
        self._update_model_stats(self.current_session)

        # Update daily statistics
        self._update_daily_stats(self.current_session)

        logger.info(f"Ended session {self.current_session.session_id}")
        self.current_session = None

    def _update_model_stats(self, session: ChatSession):
        """Update model usage statistics."""
        model_key = f"{session.provider}:{session.model}"

        if model_key not in self.model_stats:
            self.model_stats[model_key] = ModelUsage(model_id=session.model,
                                                     provider=session.provider,
                                                     total_sessions=0,
                                                     total_tokens=0,
                                                     total_duration_seconds=0,
                                                     average_tokens_per_session=0,
                                                     average_duration_seconds=0,
                                                     last_used=session.end_time,
                                                     error_count=0,
                                                     success_rate=1.0)

        stats = self.model_stats[model_key]
        stats.total_sessions += 1
        stats.total_tokens += session.total_tokens
        stats.total_duration_seconds += session.duration_seconds
        stats.average_tokens_per_session = stats.total_tokens / stats.total_sessions
        stats.average_duration_seconds = stats.total_duration_seconds / stats.total_sessions
        stats.last_used = session.end_time

        if session.error:
            stats.error_count += 1

        stats.success_rate = 1.0 - (stats.error_count / stats.total_sessions)

        self._save_model_stats()

    def _update_daily_stats(self, session: ChatSession):
        """Update daily usage statistics."""
        try:
            today = datetime.now().strftime("%Y-%m-%d")
            daily_stats = {}

            if self.daily_file.exists():
                with open(self.daily_file) as f:
                    daily_stats = json.load(f)

            if today not in daily_stats:
                daily_stats[today] = {
                    "sessions": 0,
                    "total_tokens": 0,
                    "total_duration": 0,
                    "models_used": {},
                    "providers_used": {},
                    "errors": 0
                }

            daily = daily_stats[today]
            daily["sessions"] += 1
            daily["total_tokens"] += session.total_tokens
            daily["total_duration"] += session.duration_seconds

            model_key = f"{session.provider}:{session.model}"
            daily["models_used"][model_key] = daily["models_used"].get(model_key, 0) + 1
            daily["providers_used"][session.provider] = daily["providers_used"].get(
                session.provider, 0) + 1

            if session.error:
                daily["errors"] += 1

            # Keep only last 90 days
            cutoff = (datetime.now() - timedelta(days=90)).strftime("%Y-%m-%d")
            daily_stats = {k: v for k, v in daily_stats.items() if k >= cutoff}

            with open(self.daily_file, 'w') as f:
                json.dump(daily_stats, f, indent=2)

        except Exception as e:
            logger.error(f"Failed to update daily stats: {e}")

    def estimate_tokens(self, text: str) -> int:
        """Estimate token count for text."""
        # Rough approximation: 1 token ≈ 4 characters or 0.75 words
        words = len(text.split())
        chars = len(text)
        return max(int(words / 0.75), int(chars / 4))

    def get_summary(self, days: int = 30) -> Dict[str, Any]:
        """Get usage summary for the last N days."""
        cutoff = time.time() - (days * 86400)
        recent_sessions = [s for s in self.sessions if s.start_time >= cutoff]

        if not recent_sessions:
            return {
                "period_days": days,
                "total_sessions": 0,
                "total_tokens": 0,
                "total_duration_hours": 0,
                "most_used_model": None,
                "average_tokens_per_session": 0,
                "success_rate": 0
            }

        total_tokens = sum(s.total_tokens for s in recent_sessions)
        total_duration = sum(s.duration_seconds for s in recent_sessions)
        error_count = sum(1 for s in recent_sessions if s.error)

        # Find most used model
        model_counts = {}
        for session in recent_sessions:
            model_key = f"{session.provider}:{session.model}"
            model_counts[model_key] = model_counts.get(model_key, 0) + 1

        most_used = max(model_counts.items(), key=lambda x: x[1])[0] if model_counts else None

        return {
            "period_days": days,
            "total_sessions": len(recent_sessions),
            "total_tokens": total_tokens,
            "total_duration_hours": total_duration / 3600,
            "most_used_model": most_used,
            "average_tokens_per_session": total_tokens / len(recent_sessions),
            "success_rate": 1.0 - (error_count / len(recent_sessions))
        }

    def get_model_rankings(self) -> List[Dict[str, Any]]:
        """Get models ranked by usage."""
        rankings = []

        for model_key, stats in self.model_stats.items():
            rankings.append({
                "model": stats.model_id,
                "provider": stats.provider,
                "sessions": stats.total_sessions,
                "tokens": stats.total_tokens,
                "avg_tokens": stats.average_tokens_per_session,
                "avg_duration": stats.average_duration_seconds,
                "success_rate": stats.success_rate,
                "last_used": datetime.fromtimestamp(stats.last_used).isoformat()
            })

        # Sort by total sessions descending
        rankings.sort(key=lambda x: x["sessions"], reverse=True)
        return rankings[:20]  # Top 20 models


# Global statistics tracker
stats_tracker = StatisticsTracker()
