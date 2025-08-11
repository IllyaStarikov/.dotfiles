"""
Tests for statistics.py module.
"""

import unittest
import tempfile
import json
from pathlib import Path
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock
import time

from cortex.statistics import StatisticsTracker, ChatSession


class TestStatisticsTracker(unittest.TestCase):
    """Test StatisticsTracker class."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.stats_file = Path(self.temp_dir) / "stats.json"

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_initialization_empty(self):
        """Test Statistics initialization with no existing file."""
        stats = StatisticsTracker(self.stats_file)

        self.assertEqual(stats.total_sessions, 0)
        self.assertEqual(stats.total_tokens, 0)
        self.assertEqual(stats.total_input_tokens, 0)
        self.assertEqual(stats.total_output_tokens, 0)
        self.assertEqual(len(stats.sessions), 0)
        self.assertEqual(len(stats.model_usage), 0)

    def test_initialization_with_existing_data(self):
        """Test Statistics initialization with existing data file."""
        # Create existing stats file
        existing_data = {
            "total_sessions": 10,
            "total_tokens": 5000,
            "total_input_tokens": 2000,
            "total_output_tokens": 3000,
            "sessions": [
                {
                    "session_id": "test-session",
                    "model": "gpt-4",
                    "start_time": "2024-01-01T12:00:00",
                    "duration": 60.5,
                    "input_tokens": 100,
                    "output_tokens": 200,
                    "total_tokens": 300
                }
            ],
            "model_usage": {
                "gpt-4": {
                    "sessions": 5,
                    "total_tokens": 2500
                }
            }
        }

        with open(self.stats_file, 'w') as f:
            json.dump(existing_data, f)

        stats = StatisticsTracker(self.stats_file)

        self.assertEqual(stats.total_sessions, 10)
        self.assertEqual(stats.total_tokens, 5000)
        self.assertEqual(stats.total_input_tokens, 2000)
        self.assertEqual(stats.total_output_tokens, 3000)
        self.assertEqual(len(stats.sessions), 1)
        self.assertIn("gpt-4", stats.model_usage)

    def test_start_session(self):
        """Test starting a new chat session."""
        stats = StatisticsTracker(self.stats_file)

        session = stats.start_session("test-model")

        self.assertIsInstance(session, ChatSession)
        self.assertEqual(session.model, "test-model")
        self.assertIsNotNone(session.session_id)
        self.assertIsNotNone(session.start_time)
        self.assertEqual(session.input_tokens, 0)
        self.assertEqual(session.output_tokens, 0)
        self.assertEqual(stats.current_session, session)

    def test_end_session(self):
        """Test ending a chat session."""
        stats = StatisticsTracker(self.stats_file)

        session = stats.start_session("test-model")
        time.sleep(0.1)  # Small delay for duration calculation

        # Add some tokens
        session.input_tokens = 100
        session.output_tokens = 200
        session.total_tokens = 300

        stats.end_session()

        # Check session was saved
        self.assertEqual(stats.total_sessions, 1)
        self.assertEqual(stats.total_tokens, 300)
        self.assertEqual(stats.total_input_tokens, 100)
        self.assertEqual(stats.total_output_tokens, 200)
        self.assertIsNone(stats.current_session)

        # Check model usage updated
        self.assertIn("test-model", stats.model_usage)
        self.assertEqual(stats.model_usage["test-model"]["sessions"], 1)
        self.assertEqual(stats.model_usage["test-model"]["total_tokens"], 300)

        # Check file was saved
        self.assertTrue(self.stats_file.exists())

    def test_end_session_without_current(self):
        """Test ending session when no current session."""
        stats = StatisticsTracker(self.stats_file)

        # Should not raise error
        stats.end_session()

        self.assertEqual(stats.total_sessions, 0)

    def test_update_tokens(self):
        """Test updating token counts."""
        stats = StatisticsTracker(self.stats_file)

        session = stats.start_session("test-model")

        stats.update_tokens(input_tokens=150, output_tokens=250)

        self.assertEqual(session.input_tokens, 150)
        self.assertEqual(session.output_tokens, 250)
        self.assertEqual(session.total_tokens, 400)

    def test_update_tokens_without_session(self):
        """Test updating tokens without active session."""
        stats = StatisticsTracker(self.stats_file)

        # Should not raise error
        stats.update_tokens(input_tokens=100, output_tokens=200)

        # No tokens should be recorded
        self.assertEqual(stats.total_tokens, 0)

    def test_get_summary(self):
        """Test getting statistics summary."""
        stats = StatisticsTracker(self.stats_file)

        # Add some data
        session1 = stats.start_session("gpt-4")
        session1.input_tokens = 100
        session1.output_tokens = 200
        session1.total_tokens = 300
        stats.end_session()

        session2 = stats.start_session("claude-3")
        session2.input_tokens = 50
        session2.output_tokens = 150
        session2.total_tokens = 200
        stats.end_session()

        summary = stats.get_summary()

        self.assertEqual(summary["total_sessions"], 2)
        self.assertEqual(summary["total_tokens"], 500)
        self.assertEqual(summary["total_input_tokens"], 150)
        self.assertEqual(summary["total_output_tokens"], 350)
        self.assertEqual(summary["average_tokens_per_session"], 250)
        self.assertIn("gpt-4", summary["model_usage"])
        self.assertIn("claude-3", summary["model_usage"])

    def test_get_summary_empty(self):
        """Test getting summary with no data."""
        stats = StatisticsTracker(self.stats_file)

        summary = stats.get_summary()

        self.assertEqual(summary["total_sessions"], 0)
        self.assertEqual(summary["total_tokens"], 0)
        self.assertEqual(summary["average_tokens_per_session"], 0)
        self.assertEqual(summary["model_usage"], {})

    def test_get_recent_sessions(self):
        """Test getting recent sessions."""
        stats = StatisticsTracker(self.stats_file)

        # Add multiple sessions
        for i in range(5):
            session = stats.start_session(f"model-{i}")
            session.input_tokens = i * 10
            session.output_tokens = i * 20
            session.total_tokens = i * 30
            stats.end_session()
            time.sleep(0.01)  # Small delay between sessions

        recent = stats.get_recent_sessions(3)

        self.assertEqual(len(recent), 3)
        # Should be in reverse chronological order
        self.assertEqual(recent[0]["model"], "model-4")
        self.assertEqual(recent[1]["model"], "model-3")
        self.assertEqual(recent[2]["model"], "model-2")

    def test_get_recent_sessions_less_than_requested(self):
        """Test getting recent sessions when fewer exist than requested."""
        stats = StatisticsTracker(self.stats_file)

        # Add only 2 sessions
        stats.start_session("model-1")
        stats.end_session()
        stats.start_session("model-2")
        stats.end_session()

        recent = stats.get_recent_sessions(5)

        self.assertEqual(len(recent), 2)

    def test_clear_old_sessions(self):
        """Test clearing old sessions."""
        stats = StatisticsTracker(self.stats_file)

        # Add sessions with different timestamps
        now = datetime.now()

        # Old session (40 days ago)
        old_session = ChatSession(
            session_id="old",
            model="old-model",
            start_time=(now - timedelta(days=40)).isoformat(),
            input_tokens=100,
            output_tokens=100,
            total_tokens=200
        )
        stats.sessions.append(old_session.__dict__)

        # Recent session (5 days ago)
        recent_session = ChatSession(
            session_id="recent",
            model="recent-model",
            start_time=(now - timedelta(days=5)).isoformat(),
            input_tokens=50,
            output_tokens=50,
            total_tokens=100
        )
        stats.sessions.append(recent_session.__dict__)

        stats.clear_old_sessions(days=30)

        # Only recent session should remain
        self.assertEqual(len(stats.sessions), 1)
        self.assertEqual(stats.sessions[0]["session_id"], "recent")

    def test_get_model_statistics(self):
        """Test getting statistics for specific model."""
        stats = StatisticsTracker(self.stats_file)

        # Add sessions for different models
        for i in range(3):
            session = stats.start_session("gpt-4")
            session.input_tokens = 100
            session.output_tokens = 200
            session.total_tokens = 300
            stats.end_session()

        for i in range(2):
            session = stats.start_session("claude-3")
            session.input_tokens = 50
            session.output_tokens = 100
            session.total_tokens = 150
            stats.end_session()

        gpt4_stats = stats.get_model_statistics("gpt-4")

        self.assertEqual(gpt4_stats["sessions"], 3)
        self.assertEqual(gpt4_stats["total_tokens"], 900)
        self.assertEqual(gpt4_stats["average_tokens"], 300)

        claude_stats = stats.get_model_statistics("claude-3")

        self.assertEqual(claude_stats["sessions"], 2)
        self.assertEqual(claude_stats["total_tokens"], 300)
        self.assertEqual(claude_stats["average_tokens"], 150)

    def test_get_model_statistics_unknown_model(self):
        """Test getting statistics for unknown model."""
        stats = StatisticsTracker(self.stats_file)

        unknown_stats = stats.get_model_statistics("unknown-model")

        self.assertEqual(unknown_stats["sessions"], 0)
        self.assertEqual(unknown_stats["total_tokens"], 0)
        self.assertEqual(unknown_stats["average_tokens"], 0)

    def test_save_and_load(self):
        """Test saving and loading statistics."""
        stats1 = StatisticsTracker(self.stats_file)

        # Add data
        session = stats1.start_session("test-model")
        session.input_tokens = 100
        session.output_tokens = 200
        session.total_tokens = 300
        stats1.end_session()

        # Create new instance loading from file
        stats2 = StatisticsTracker(self.stats_file)

        self.assertEqual(stats2.total_sessions, 1)
        self.assertEqual(stats2.total_tokens, 300)
        self.assertEqual(len(stats2.sessions), 1)
        self.assertIn("test-model", stats2.model_usage)

    def test_concurrent_sessions_warning(self):
        """Test handling multiple concurrent sessions."""
        stats = StatisticsTracker(self.stats_file)

        session1 = stats.start_session("model-1")
        # Starting another session should replace current
        session2 = stats.start_session("model-2")

        self.assertEqual(stats.current_session, session2)
        self.assertNotEqual(stats.current_session, session1)

    def test_session_duration_calculation(self):
        """Test session duration is calculated correctly."""
        stats = StatisticsTracker(self.stats_file)

        session = stats.start_session("test-model")
        start_time = session.start_time
        time.sleep(0.5)  # 500ms delay
        stats.end_session()

        saved_session = stats.sessions[-1]
        self.assertIn("duration", saved_session)
        self.assertGreater(saved_session["duration"], 0.4)
        self.assertLess(saved_session["duration"], 1.0)


if __name__ == '__main__':
    unittest.main()