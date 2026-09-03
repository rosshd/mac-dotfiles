#!/usr/bin/env python3
"""Remove the retired Herdr SessionStart hooks from agent settings."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import stat
import tempfile
from typing import Any


def remove_claude_hook(settings: dict[str, Any], home: Path) -> bool:
    expected = f"bash '{home}/.claude/hooks/herdr-agent-state.sh' session"
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return False

    groups = hooks.get("SessionStart")
    if not isinstance(groups, list):
        return False

    changed = False
    retained_groups: list[Any] = []
    for group in groups:
        if not isinstance(group, dict) or not isinstance(group.get("hooks"), list):
            retained_groups.append(group)
            continue

        retained_hooks = [
            hook
            for hook in group["hooks"]
            if not (
                isinstance(hook, dict)
                and hook.get("type") == "command"
                and hook.get("command") == expected
            )
        ]
        if len(retained_hooks) == len(group["hooks"]):
            retained_groups.append(group)
            continue

        changed = True
        if retained_hooks:
            group["hooks"] = retained_hooks
            retained_groups.append(group)

    if changed:
        if retained_groups:
            hooks["SessionStart"] = retained_groups
        else:
            del hooks["SessionStart"]
    return changed


def remove_copilot_hook(settings: dict[str, Any], home: Path) -> bool:
    expected = f"bash '{home}/.copilot/hooks/herdr-agent-state.sh'"
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return False

    entries = hooks.get("SessionStart")
    if not isinstance(entries, list):
        return False

    retained = [
        hook
        for hook in entries
        if not (
            isinstance(hook, dict)
            and hook.get("type") == "command"
            and hook.get("bash") == expected
        )
    ]
    if len(retained) == len(entries):
        return False

    if retained:
        hooks["SessionStart"] = retained
    else:
        del hooks["SessionStart"]
    return True


def write_atomically(path: Path, settings: dict[str, Any]) -> None:
    original_mode = stat.S_IMODE(path.stat().st_mode)
    rendered = json.dumps(settings, indent=2, ensure_ascii=False) + "\n"
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=path.parent,
        prefix=f".{path.name}.",
        delete=False,
    ) as handle:
        temporary = Path(handle.name)
        handle.write(rendered)
        handle.flush()
        os.fsync(handle.fileno())

    try:
        temporary.chmod(original_mode)
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("agent", choices=("claude", "copilot"))
    parser.add_argument("settings", type=Path)
    parser.add_argument("--home", type=Path, required=True)
    args = parser.parse_args()

    if not args.settings.exists():
        return 0

    with args.settings.open(encoding="utf-8") as handle:
        settings = json.load(handle)
    if not isinstance(settings, dict):
        raise ValueError(f"{args.settings} must contain a JSON object")

    removers = {
        "claude": remove_claude_hook,
        "copilot": remove_copilot_hook,
    }
    if removers[args.agent](settings, args.home):
        write_atomically(args.settings, settings)
        print(f"  removed retired Herdr hook from {args.settings}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
