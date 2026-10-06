"""Behavior tests using isolated repositories, not developer workspaces."""
import copy
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

CLI = Path(__file__).resolve().parents[1] / "bin/factory-workflow"
loader = importlib.machinery.SourceFileLoader("workflow", str(CLI))
spec = importlib.util.spec_from_loader(loader.name, loader)
workflow = importlib.util.module_from_spec(spec)
loader.exec_module(workflow)


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.repo = self.home / "repo"
        self.repo.mkdir()
        self.git("init", "-b", "feature")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "user.name", "Fixture")
        (self.repo / "code").write_text("initial\n")
        self.git("add", "code")
        self.git("commit", "-m", "fixture")
        self.git("branch", "main")
        self.base = self.git("rev-parse", "HEAD").strip()
        self.context = {"environment": "fixture", "toolchain": "fixture-v1"}
        self.ledger = self.home / "receipts.jsonl"
        self.context_file = self.home / "context.json"
        self.context_file.write_text(json.dumps(self.context))

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], stderr=subprocess.DEVNULL).decode()

    def receipt(self, task="feature", parent="root", root="root", branch="feature", target="main"):
        current = workflow.candidate(self.repo, "mock", self.context)
        return {"schema_version": 1, "receipt_id": task + "-1", "root_task_id": root,
                "parent_task_id": parent, "task_id": task, "issue": "https://github.com/example/repo/issues/1",
                "worktree": str(self.repo), "branch": branch, "base_branch": target, "base_sha": self.base,
                "candidate": current, "authority": {"endpoint": "release", "human_verified": False},
                "endpoint": "pr", "risk": "medium", "ci": {"status": "not-run", "sha": current["sha"]},
                "gate": {"command": "make check", "status": "passed", "candidate": current["digest"]},
                "review": {"status": "passed", "candidate": current["digest"], "reviewer_task_id": "reviewer"},
                "state": "pr-ready"}

    def consume(self, value, parent="root", target="main", context=None):
        return workflow.consume(self.ledger, value, self.repo, "mock", context or self.context,
                                "root", parent, target)

    def cli(self, *args, success=True):
        result = subprocess.run(["python3", str(CLI), *args], capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        return json.loads(result.stdout) if success else result.stderr

    def test_exact_candidate_covers_dirty_index_untracked_environment_mode_head(self):
        first = workflow.candidate(self.repo, "mock", self.context)
        self.git("update-index", "--assume-unchanged", "code")
        (self.repo / "code").write_text("dirty\n")
        dirty = workflow.candidate(self.repo, "mock", self.context)
        self.assertNotEqual(first["digest"], dirty["digest"])
        self.git("update-index", "--no-assume-unchanged", "code")
        self.git("add", "code")
        staged = workflow.candidate(self.repo, "mock", self.context)
        self.assertNotEqual(dirty["digest"], staged["digest"])
        (self.repo / "new").write_text("new\n")
        untracked = workflow.candidate(self.repo, "mock", self.context)
        self.assertNotEqual(staged["digest"], untracked["digest"])
        (self.repo / "new").chmod(0o755)
        self.assertNotEqual(untracked["digest"], workflow.candidate(self.repo, "mock", self.context)["digest"])
        self.assertNotEqual(first["context_hash"], workflow.candidate(self.repo, "mock", {**self.context, "toolchain": "v2"})["context_hash"])
        self.assertNotEqual(first["digest"], workflow.candidate(self.repo, "live", self.context)["digest"])
        self.git("commit", "-m", "candidate")
        self.assertNotEqual(staged["sha"], workflow.candidate(self.repo, "mock", self.context)["sha"])

    def test_gate_reuse_requires_before_after_match_and_pass(self):
        snapshot = self.home / "before.json"
        evidence = self.home / "gate.json"
        snapshot.write_text(json.dumps(workflow.candidate(self.repo, "mock", self.context)))
        common = ["--repo", str(self.repo), "--mode", "mock", "--context", str(self.context_file), "--evidence", str(evidence)]
        self.cli("gate-record", *common, "--candidate", str(snapshot), "--exit-code", "0")
        self.assertTrue(self.cli("gate-reuse", *common)["reusable"])
        self.cli("gate-reuse", *common, "--gate-command", "pytest", success=False)
        self.context_file.write_text(json.dumps({**self.context, "environment": "other"}))
        self.cli("gate-reuse", *common, success=False)
        self.context_file.write_text(json.dumps(self.context))
        (self.repo / "code").write_text("changed\n")
        self.cli("gate-reuse", *common, success=False)
        self.cli("gate-record", *common, "--candidate", str(snapshot), "--exit-code", "0", success=False)
        snapshot.write_text(json.dumps(workflow.candidate(self.repo, "mock", self.context)))
        failed = self.home / "failed.json"
        failure_common = [*common[:-1], str(failed)]
        self.cli("gate-record", *failure_common, "--candidate", str(snapshot), "--exit-code", "1")
        self.cli("gate-reuse", *failure_common, success=False)

    def test_authority_local_high_risk_and_ci_pause(self):
        value = self.receipt()
        workflow.validate_receipt(value)
        value["ci"]["status"] = "paused"
        with self.assertRaisesRegex(ValueError, "pause"):
            workflow.validate_receipt(value)
        value["ci"]["status"] = "not-run"
        value["authority"]["endpoint"] = "local"
        with self.assertRaisesRegex(ValueError, "authority"):
            workflow.validate_receipt(value)
        value["endpoint"], value["state"] = "local", "local-complete"
        value["ci"]["status"] = "paused"
        value["review"] = {"status": "not-run", "candidate": None, "reviewer_task_id": None}
        workflow.validate_receipt(value)
        value = self.receipt()
        value["endpoint"], value["state"] = "merge", "merged"
        with self.assertRaisesRegex(ValueError, "CI"):
            workflow.validate_receipt(value)
        value["ci"]["status"] = "passed"
        value["risk"] = "high"
        with self.assertRaisesRegex(ValueError, "human"):
            workflow.validate_receipt(value)
        value["authority"]["human_verified"] = True
        workflow.validate_receipt(value)
        value["ci"]["sha"] = "a" * 40
        with self.assertRaisesRegex(ValueError, "exact-head"):
            workflow.validate_receipt(value)

    def test_recursive_root_feature_leaves_target_parent_and_resumption(self):
        root = self.receipt(task="root", parent=None, branch="feature", target="main")
        self.consume(root, parent=None)
        next_worktree = self.home / "feature-parent"
        self.git("worktree", "add", "-b", "feature-parent", str(next_worktree), "HEAD")
        self.repo = next_worktree
        parent = self.receipt(branch="feature-parent", target="feature")
        self.consume(parent, target="feature")
        next_worktree = self.home / "leaf-one"
        self.git("worktree", "add", "-b", "leaf-one", str(next_worktree), "HEAD")
        self.repo = next_worktree
        leaf = self.receipt(task="leaf-one", parent="feature", branch="leaf-one", target="feature-parent")
        self.consume(leaf, parent="feature", target="feature-parent")
        next_worktree = self.home / "leaf-two"
        self.git("worktree", "add", "-b", "leaf-two", str(next_worktree), "HEAD")
        self.repo = next_worktree
        leaf2 = self.receipt(task="leaf-two", parent="feature", branch="leaf-two", target="feature-parent")
        self.consume(leaf2, parent="feature", target="feature-parent")
        state = self.cli("state", "--ledger", str(self.ledger))
        self.assertEqual(set(state), {"root", "feature", "leaf-one", "leaf-two"})
        self.assertEqual(state["leaf-two"]["parent_task_id"], "feature")
        with self.assertRaisesRegex(ValueError, "target"):
            self.consume(leaf2, parent="feature", target="main")

    def test_duplicate_collision_stale_content_environment_and_branch(self):
        value = self.receipt()
        self.assertFalse(self.consume(value)["duplicate"])
        self.assertTrue(self.consume(value)["duplicate"])
        collision = copy.deepcopy(value)
        collision["risk"] = "low"
        with self.assertRaisesRegex(ValueError, "collision"):
            self.consume(collision)
        with self.assertRaisesRegex(ValueError, "stale"):
            self.consume(value, context={**self.context, "environment": "other"})
        (self.repo / "code").write_text("secret-content-never-returned\n")
        with self.assertRaisesRegex(ValueError, "stale"):
            self.consume(value)
        current = self.receipt()
        current["receipt_id"] = "next"
        current["task_id"] = "other"
        with self.assertRaisesRegex(ValueError, "owner"):
            self.consume(current)

    def test_strict_schema_stale_review_and_independence(self):
        value = self.receipt()
        for field, mutate in [("extra", lambda r: r.update(secret="forbidden")),
                              ("review", lambda r: r["review"].update(candidate="0" * 64)),
                              ("self", lambda r: r["review"].update(reviewer_task_id="feature")),
                              ("root", lambda r: r.update(parent_task_id=None)),
                              ("enum", lambda r: r.update(state=[]))]:
            changed = copy.deepcopy(value)
            mutate(changed)
            with self.subTest(field=field), self.assertRaises(ValueError):
                workflow.validate_receipt(changed)

    def test_stale_head_unknown_base_and_gate_evidence_storage(self):
        value = self.receipt()
        self.git("commit", "--allow-empty", "-m", "new head")
        with self.assertRaisesRegex(ValueError, "stale"):
            self.consume(value)
        unknown_base = self.receipt()
        unknown_base["base_sha"] = "a" * 40
        with self.assertRaisesRegex(ValueError, "base SHA"):
            self.consume(unknown_base)
        snapshot = self.home / "before.json"
        snapshot.write_text(json.dumps(workflow.candidate(self.repo, "mock", self.context)))
        self.cli("gate-record", "--repo", str(self.repo), "--mode", "mock", "--context", str(self.context_file),
                 "--candidate", str(snapshot), "--evidence", str(self.repo / "gate.json"), "--exit-code", "0", success=False)
        self.assertFalse((self.repo / "gate.json").exists())

    def test_inventory_external_dirty_owned_settled_and_dependencies(self):
        initial = self.git("status", "--porcelain")
        self.assertEqual(workflow.inventory(self.repo, [])[0]["classification"], "external")
        value = self.receipt()
        self.assertEqual(workflow.inventory(self.repo, [value])[0]["classification"], "owned")
        value["endpoint"], value["state"] = "merge", "merged"
        value["ci"]["status"] = "passed"
        settled = workflow.inventory(self.repo, [value])[0]
        self.assertEqual(settled["classification"], "settled")
        self.assertIn("verify remote", settled["proposal"])
        downstream = self.receipt(task="leaf", parent="feature", branch="leaf", target="feature")
        downstream["worktree"] = str(self.home / "other-owner")
        self.assertEqual(workflow.inventory(self.repo, [value, downstream])[0]["classification"], "owned")
        (self.repo / "code").write_text("dirty\n")
        self.assertEqual(workflow.inventory(self.repo, [value])[0]["classification"], "unresolved-dirty")
        self.assertEqual(initial, "")
        self.assertEqual(self.git("branch", "--show-current").strip(), "feature")

    def test_ledger_inside_candidate_rejected_and_missing_state_is_read_only(self):
        self.ledger = self.repo / "receipts.jsonl"
        with self.assertRaisesRegex(ValueError, "outside"):
            self.consume(self.receipt())
        self.assertFalse(self.ledger.exists())
        self.cli("state", "--ledger", str(self.ledger), success=False)
        self.assertFalse(self.ledger.exists())

    def test_cycles_identity_changes_and_endpoint_regression(self):
        first = self.receipt(parent="leaf", target="leaf-branch")
        self.consume(first, parent="leaf", target="leaf-branch")
        regression = copy.deepcopy(first)
        regression["receipt_id"] = "regression"
        regression["endpoint"], regression["state"] = "local", "local-complete"
        with self.assertRaisesRegex(ValueError, "regressed"):
            self.consume(regression, parent="leaf", target="leaf-branch")
        changed = copy.deepcopy(first)
        changed["receipt_id"] = "changed-owner"
        changed["issue"] = "https://github.com/example/repo/issues/2"
        with self.assertRaisesRegex(ValueError, "identity"):
            self.consume(changed, parent="leaf", target="leaf-branch")
        next_worktree = self.home / "leaf-branch"
        self.git("worktree", "add", "-b", "leaf-branch", str(next_worktree), "HEAD")
        self.repo = next_worktree
        leaf = self.receipt(task="leaf", parent="feature", branch="leaf-branch", target="feature")
        with self.assertRaisesRegex(ValueError, "cycle"):
            self.consume(leaf, parent="feature", target="feature")


if __name__ == "__main__":
    unittest.main()
