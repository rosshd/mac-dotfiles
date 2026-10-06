#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$root" <<'PY'
import json
import os
from pathlib import Path
import re
import stat
import sys

root = Path(sys.argv[1])
config_path = root / "agents/config/factory-observer-projects.json"
metadata = config_path.lstat()
assert stat.S_ISREG(metadata.st_mode) and not config_path.is_symlink()
assert metadata.st_uid == os.getuid()
assert stat.S_IMODE(metadata.st_mode) == 0o644
config = json.loads(config_path.read_text())
assert set(config) == {"schema_version", "projects"}
assert type(config["schema_version"]) is int and config["schema_version"] == 1
projects = config["projects"]
assert projects == [
    {
        "repository": f"rosshd/{name}",
        "path": path,
        "ownership": "standalone_root",
    }
    for name, path in (
        ("applyquest", "/Users/ross/Developer/projects/job-hunt-leaderboard"),
        ("openlearn", "/Users/ross/Developer/projects/openlearn"),
        ("mac-dotfiles", "/Users/ross/mac-dotfiles"),
        ("factory-observability", "/Users/ross/Developer/projects/factory-observability"),
    )
]

hooks = json.loads((root / "agents/config/codex-hooks.json").read_text())["hooks"]
groups = hooks["SessionStart"]
assert len(groups) == 1 and set(groups[0]) == {"matcher", "hooks"}
for source in ("startup", "resume", "clear", "compact"):
    assert re.search(groups[0]["matcher"], source), source
assert re.search(groups[0]["matcher"], "unknown") is None
handlers = groups[0]["hooks"]
assert len(handlers) == 1
handler = handlers[0]
assert set(handler) == {"command", "statusMessage", "timeout", "type"}
assert handler["type"] == "command" and handler["timeout"] == 2
assert handler["command"] == (
    "/usr/bin/env PATH=/opt/homebrew/bin:/Users/ross/.local/bin:/usr/bin:/bin "
    "/Users/ross/Developer/projects/factory-observability/bin/factory-session-hook "
    "--project-config /Users/ross/mac-dotfiles/agents/config/factory-observer-projects.json "
    "--context-directory /Users/ross/Developer/projects/factory-observability/.data/workflow-v3/contexts "
    "--health-directory /Users/ross/Developer/projects/factory-observability/.data/workflow-v3/enrollment-health"
)

contract = (root / "plugins/workflow-core/references/factory-contract.md").read_text()
for required in (
    "Existing valid session enrollment is reused unchanged before cwd eligibility",
    "random run ID", "UUID session", "codex_chat", "null parent",
    "No parent identity is inferred", "Managed worktree chats",
    "register-observer", "malformed or unsafe context",
    "normal trust approval",
):
    assert required in contract, required

workflow = (root / "docs/WORKFLOW.md").read_text()
for required in (
    "No special phrase or manual enrollment command",
    "normal `/hooks` trust review", "startup, resume, clear, and compact",
    "Runtime acceptance", "enrollment-health", "complete input coverage",
    "job-hunt-leaderboard", "applyquest` is a linked checkout",
):
    assert required in workflow, required
PY

echo "session enrollment configuration: ok"
