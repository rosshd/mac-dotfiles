#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$root" <<'PY'
import json
from pathlib import Path
import sys

root = Path(sys.argv[1])
hooks = json.loads((root / "agents/config/codex-hooks.json").read_text())["hooks"]
assert set(hooks) == {"SessionStart", "UserPromptSubmit", "Interrupt", "Stop"}
for event, timeout in (("UserPromptSubmit", 2), ("Interrupt", 1)):
    groups = hooks[event]
    assert len(groups) == 1 and "matcher" not in groups[0]
    handlers = groups[0]["hooks"]
    assert len(handlers) == 1
    handler = handlers[0]
    assert handler["type"] == "command" and handler["timeout"] == timeout
    assert "/factory-input-hook " in handler["command"]
    assert "--spool-directory /Users/ross/Developer/projects/factory-observability/.data/workflow-v3/inputs" in handler["command"]
    assert "--health-directory /Users/ross/Developer/projects/factory-observability/.data/workflow-v3/health" in handler["command"]
    assert "factory-prompt-hook" not in handler["command"]
    assert "--event-database" not in handler["command"]
    assert not handler.get("async", False)
assert hooks["UserPromptSubmit"][0]["hooks"][0]["additionalContextLimit"] == 300
assert "additionalContextLimit" not in hooks["Interrupt"][0]["hooks"][0]
stop = hooks["Stop"][0]["hooks"][0]
assert stop["command"].endswith("/factory-notify-hook")
assert stop["timeout"] == 3

contract = (root / "plugins/workflow-core/references/factory-contract.md").read_text()
for required in (
    "import-input-observations", "capture-health", "runtime_interrupted",
    "one hook invocation, not a unique host message", "agent_intervention",
    "source_grade: agent_reported", "otherwise leave capture linkage null",
    "agent_intervention_correction", "Normal intake", "unknown assessments",
    "app-server event adapter remains deferred",
):
    assert required in contract, required
PY

echo "hybrid capture configuration: ok"
