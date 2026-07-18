"""
Tests for statistics.py module.
"""

import json
import tempfile
import time
import unittest
from pathlib import Path

from cortex.statistics import ChatSession, StatisticsTracker


def _make_session_dict(session_id, model, provider="mlx", start_time=None, total_tokens=300):
    """Build a serialized ChatSession dict matching the current schema."""
    start = start_time if start_time is not None else time.time()
    return {
        "session_id": session_id,
        "model": model,
        "provider": provider,
        "start_time": start,
        "end_time": start + 1.0,
        "duration_seconds": 1.0,
        "input_tokens": total_tokens // 3,
        "output_tokens": total_tokens - total_tokens // 3,
        "total_tokens": total_tokens,
        "messages": 1,
        "temperature": 0.7,
        "max_tokens": None,
        "ensemble": False,
        "ensemble_models": [],
        "error": None,
        "metadata": {},
    }


class TestStatisticsTracker(unittest.TestCase):
    """Test StatisticsTracker class."""

    def setUp(self):
        """Set up test fixtures with a unique stats directory per test."""
        # mkdtemp() is unique per call, so parallel/repeated tests never collide.
        self.temp_dir = tempfile.mkdtemp()
        self.stats_dir = Path(self.temp_dir) / "stats"

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil

        shutil.rmtree(self.temp_dir)

    def test_initialization_empty(self):
        """Test tracker initialization with no existing files."""
        stats = StatisticsTracker(self.stats_dir)

        self.assertEqual(len(stats.sessions), 0)
        self.assertEqual(stats.model_stats, {})
        self.assertIsNone(stats.current_session)
        self.assertTrue(self.stats_dir.exists())

    def test_initialization_with_existing_data(self):
        """Test tracker initialization with existing data files."""
        self.stats_dir.mkdir(parents=True)

        sessions = [_make_session_dict("test-session", "gpt-4", provider="openai")]
        with open(self.stats_dir / "sessions.json", "w") as f:
            json.dump(sessions, f)

        model_stats = {
            "openai:gpt-4": {
                "model_id": "gpt-4",
                "provider": "openai",
                "total_sessions": 5,
                "total_tokens": 2500,
                "total_duration_seconds": 50.0,
                "average_tokens_per_session": 500.0,
                "average_duration_seconds": 10.0,
                "last_used": time.time(),
                "error_count": 0,
                "success_rate": 1.0,
            }
        }
        with open(self.stats_dir / "models.json", "w") as f:
            json.dump(model_stats, f)

        stats = StatisticsTracker(self.stats_dir)

        self.assertEqual(len(stats.sessions), 1)
        self.assertEqual(stats.sessions[0].session_id, "test-session")
        self.assertIn("openai:gpt-4", stats.model_stats)
        self.assertEqual(stats.model_stats["openai:gpt-4"].total_sessions, 5)
        self.assertEqual(stats.model_stats["openai:gpt-4"].total_tokens, 2500)

    def test_start_session(self):
        """Test starting a new chat session."""
        stats = StatisticsTracker(self.stats_dir)

        session_id = stats.start_session("test-model", "mlx")

        self.assertIsInstance(session_id, str)
        self.assertIn("test-model", session_id)
        self.assertIsInstance(stats.current_session, ChatSession)
        self.assertEqual(stats.current_session.model, "test-model")
        self.assertEqual(stats.current_session.provider, "mlx")
        self.assertEqual(stats.current_session.input_tokens, 0)
        self.assertEqual(stats.current_session.output_tokens, 0)

    def test_end_session(self):
        """Test ending a chat session."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("test-model", "mlx")
        stats.update_session(input_tokens=100, output_tokens=200, messages=1)

        stats.end_session()

        # Session recorded and current session cleared
        self.assertEqual(len(stats.sessions), 1)
        self.assertIsNone(stats.current_session)
        self.assertEqual(stats.sessions[0].total_tokens, 300)

        # Model usage aggregated under "provider:model"
        self.assertIn("mlx:test-model", stats.model_stats)
        self.assertEqual(stats.model_stats["mlx:test-model"].total_sessions, 1)
        self.assertEqual(stats.model_stats["mlx:test-model"].total_tokens, 300)

        # Files persisted
        self.assertTrue(stats.sessions_file.exists())
        self.assertTrue(stats.models_file.exists())

    def test_end_session_without_current(self):
        """Test ending session when no current session."""
        stats = StatisticsTracker(self.stats_dir)

        # Should not raise error
        stats.end_session()

        self.assertEqual(len(stats.sessions), 0)

    def test_update_session_tokens(self):
        """Test updating token counts on the active session."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("test-model", "mlx")
        stats.update_session(input_tokens=150, output_tokens=250, messages=2)

        self.assertEqual(stats.current_session.input_tokens, 150)
        self.assertEqual(stats.current_session.output_tokens, 250)
        self.assertEqual(stats.current_session.total_tokens, 400)
        self.assertEqual(stats.current_session.messages, 2)

    def test_update_session_without_session(self):
        """Test updating tokens without active session."""
        stats = StatisticsTracker(self.stats_dir)

        # Should not raise error
        stats.update_session(input_tokens=100, output_tokens=200)

        self.assertIsNone(stats.current_session)
        self.assertEqual(len(stats.sessions), 0)

    def test_get_summary(self):
        """Test getting statistics summary."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("gpt-4", "openai")
        stats.update_session(input_tokens=100, output_tokens=200)
        stats.end_session()

        stats.start_session("claude-3", "claude")
        stats.update_session(input_tokens=50, output_tokens=150)
        stats.end_session()

        stats.start_session("gpt-4", "openai")
        stats.update_session(input_tokens=10, output_tokens=20)
        stats.end_session()

        summary = stats.get_summary(days=30)

        self.assertEqual(summary["total_sessions"], 3)
        self.assertEqual(summary["total_tokens"], 530)
        self.assertEqual(summary["most_used_model"], "openai:gpt-4")
        self.assertAlmostEqual(summary["average_tokens_per_session"], 530 / 3, places=2)
        self.assertEqual(summary["success_rate"], 1.0)

    def test_get_summary_empty(self):
        """Test getting summary with no data."""
        stats = StatisticsTracker(self.stats_dir)

        summary = stats.get_summary()

        self.assertEqual(summary["total_sessions"], 0)
        self.assertEqual(summary["total_tokens"], 0)
        self.assertEqual(summary["average_tokens_per_session"], 0)
        self.assertIsNone(summary["most_used_model"])

    def test_get_summary_excludes_old_sessions(self):
        """Test that get_summary only counts sessions within the window."""
        stats = StatisticsTracker(self.stats_dir)

        now = time.time()

        # Old session (40 days ago)
        old = ChatSession(**_make_session_dict("old", "old-model", start_time=now - 40 * 86400))
        stats.sessions.append(old)

        # Recent session (5 days ago)
        recent = ChatSession(
            **_make_session_dict("recent", "recent-model", start_time=now - 5 * 86400)
        )
        stats.sessions.append(recent)

        summary = stats.get_summary(days=30)

        self.assertEqual(summary["total_sessions"], 1)
        self.assertEqual(summary["most_used_model"], "mlx:recent-model")

    def test_sessions_accumulate_in_order(self):
        """Test that completed sessions are stored in chronological order."""
        stats = StatisticsTracker(self.stats_dir)

        for i in range(5):
            stats.start_session(f"model-{i}", "mlx")
            stats.end_session()

        self.assertEqual(len(stats.sessions), 5)
        # Most recent sessions are at the end of the list
        recent = stats.sessions[-3:]
        self.assertEqual(recent[0].model, "model-2")
        self.assertEqual(recent[1].model, "model-3")
        self.assertEqual(recent[2].model, "model-4")

    def test_model_stats_aggregation(self):
        """Test per-model statistics aggregation across sessions."""
        stats = StatisticsTracker(self.stats_dir)

        for _ in range(3):
            stats.start_session("gpt-4", "openai")
            stats.update_session(input_tokens=100, output_tokens=200)
            stats.end_session()

        for _ in range(2):
            stats.start_session("claude-3", "claude")
            stats.update_session(input_tokens=50, output_tokens=100)
            stats.end_session()

        gpt4_stats = stats.model_stats["openai:gpt-4"]
        self.assertEqual(gpt4_stats.total_sessions, 3)
        self.assertEqual(gpt4_stats.total_tokens, 900)
        self.assertEqual(gpt4_stats.average_tokens_per_session, 300)

        claude_stats = stats.model_stats["claude:claude-3"]
        self.assertEqual(claude_stats.total_sessions, 2)
        self.assertEqual(claude_stats.total_tokens, 300)
        self.assertEqual(claude_stats.average_tokens_per_session, 150)

    def test_model_stats_unknown_model(self):
        """Test that unused models have no statistics entries."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("gpt-4", "openai")
        stats.end_session()

        self.assertNotIn("openai:unknown-model", stats.model_stats)
        rankings = stats.get_model_rankings()
        self.assertEqual(len(rankings), 1)
        self.assertEqual(rankings[0]["model"], "gpt-4")

    def test_get_model_rankings_order(self):
        """Test that model rankings are sorted by session count."""
        stats = StatisticsTracker(self.stats_dir)

        for _ in range(3):
            stats.start_session("popular-model", "mlx")
            stats.end_session()

        stats.start_session("rare-model", "ollama")
        stats.end_session()

        rankings = stats.get_model_rankings()

        self.assertEqual(rankings[0]["model"], "popular-model")
        self.assertEqual(rankings[0]["sessions"], 3)
        self.assertEqual(rankings[1]["model"], "rare-model")
        self.assertEqual(rankings[1]["sessions"], 1)

    def test_save_and_load(self):
        """Test saving and loading statistics."""
        stats1 = StatisticsTracker(self.stats_dir)

        stats1.start_session("test-model", "mlx")
        stats1.update_session(input_tokens=100, output_tokens=200)
        stats1.end_session()

        # Create new instance loading from the same directory
        stats2 = StatisticsTracker(self.stats_dir)

        self.assertEqual(len(stats2.sessions), 1)
        self.assertEqual(stats2.sessions[0].total_tokens, 300)
        self.assertIn("mlx:test-model", stats2.model_stats)
        self.assertEqual(stats2.model_stats["mlx:test-model"].total_tokens, 300)

    def test_concurrent_sessions_replace_current(self):
        """Test that starting a new session replaces the current one."""
        stats = StatisticsTracker(self.stats_dir)

        first_id = stats.start_session("model-1", "mlx")
        second_id = stats.start_session("model-2", "mlx")

        self.assertNotEqual(first_id, second_id)
        self.assertEqual(stats.current_session.model, "model-2")
        self.assertEqual(stats.current_session.session_id, second_id)

    def test_session_duration_calculation(self):
        """Test session duration is calculated correctly."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("test-model", "mlx")
        time.sleep(0.5)  # 500ms delay
        stats.end_session()

        saved_session = stats.sessions[-1]
        self.assertGreater(saved_session.duration_seconds, 0.4)
        self.assertLess(saved_session.duration_seconds, 2.0)

    def test_end_session_with_error(self):
        """Test that errors are recorded and reflected in success rate."""
        stats = StatisticsTracker(self.stats_dir)

        stats.start_session("flaky-model", "mlx")
        stats.end_session(error="timeout")

        stats.start_session("flaky-model", "mlx")
        stats.end_session()

        model_stats = stats.model_stats["mlx:flaky-model"]
        self.assertEqual(model_stats.error_count, 1)
        self.assertEqual(model_stats.success_rate, 0.5)

    def test_estimate_tokens(self):
        """Test token estimation heuristic."""
        stats = StatisticsTracker(self.stats_dir)

        self.assertEqual(stats.estimate_tokens(""), 0)
        estimate = stats.estimate_tokens("hello world this is a test")
        self.assertGreater(estimate, 0)
        # 6 words / 0.75 = 8, 26 chars / 4 = 6 -> max is 8
        self.assertEqual(estimate, 8)


if __name__ == "__main__":
    unittest.main()
