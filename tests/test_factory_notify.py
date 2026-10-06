import importlib.machinery
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "factory-notify-hook"
loader = importlib.machinery.SourceFileLoader("factory_notify", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)


class NotificationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.directory = self.root / ".artifacts" / "factory-notifications"
        self.directory.mkdir(parents=True)
        self.event = {"hook_event_name": "Stop", "session_id": "thr_test",
                      "cwd": str(self.root), "last_assistant_message": "PRIVATE",
                      "transcript_path": "/never/read"}
        self.path = self.directory / "thr_test.json"

    def write(self, state="completed", **extra):
        self.path.write_text(json.dumps({"schema_version": 1, "task_id": "/root",
                                        "state": state, **extra}))

    def test_record_is_allowlisted_and_rejects_escape(self):
        module.record(str(self.root), "thr_test", "/root", "completed")
        self.assertEqual(set(json.loads(self.path.read_text())),
                         {"schema_version", "state", "task_id"})
        with self.assertRaises(ValueError):
            module.record(str(self.root), "../escape", "/root", "completed")

    @patch.object(module.subprocess, "run")
    def test_unregistered_is_silent(self, run):
        self.assertFalse(module.notify(self.event))
        run.assert_not_called()

    @patch.object(module.subprocess, "run")
    def test_completion_is_quiet_local_and_deduplicated(self, run):
        self.write()
        self.assertTrue(module.notify(self.event))
        self.assertFalse(module.notify(self.event))
        args = run.call_args.args[0]
        self.assertIn("--local-only", args)
        self.assertIn("none", args)
        self.assertIn("low", args)
        self.assertNotIn("PRIVATE", str(args))
        self.assertEqual(run.call_count, 1)

    @patch.object(module.subprocess, "run")
    def test_decision_and_failed_release_are_urgent(self, run):
        for state in ("needs_human", "release_failed"):
            self.write(state)
            self.assertTrue(module.notify(self.event))
            self.assertIn("high", run.call_args.args[0])
            self.assertIn("Glass", run.call_args.args[0])

    @patch.object(module.subprocess, "run")
    def test_rejects_prose_path_traversal_and_symlink(self, run):
        self.write(message="PRIVATE")
        self.assertFalse(module.notify(self.event))
        self.write()
        self.assertFalse(module.notify({**self.event, "session_id": "../elsewhere"}))
        self.assertFalse(module.notify({**self.event, "stop_hook_active": True}))
        self.path.unlink()
        self.path.symlink_to(self.root / "not-a-receipt")
        self.assertFalse(module.notify(self.event))
        run.assert_not_called()
