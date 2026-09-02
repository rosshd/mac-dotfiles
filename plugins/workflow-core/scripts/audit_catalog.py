#!/usr/bin/env python3
"""Validate and summarize Workflow Core without third-party packages."""

from __future__ import annotations

import re
import sys
from pathlib import Path


EXPECTED = {
    "blast-radius",
    "ce-babysit-pr",
    "ce-brainstorm",
    "ce-code-review",
    "ce-commit",
    "ce-commit-push-pr",
    "ce-debug",
    "ce-plan",
    "ce-pov",
    "ce-resolve-pr-feedback",
    "ce-simplify-code",
    "ce-work",
    "factory-bootstrap",
    "factory-dispatch",
    "security-best-practices",
    "typescript-best-practices",
    "unslop",
    "writing-for-agents",
}

EXPLICIT_ONLY = {"blast-radius", "security-best-practices"}

REMOVED_DEPENDENCIES = {
    "ce-compound",
    "ce-doc-review",
    "ce-prototype",
    "lfg",
    "no-mistakes",
    "type-system-discipline",
    "boundary-discipline",
}


def frontmatter(text: str) -> tuple[str, str]:
    if not text.startswith("---\n"):
        raise ValueError("missing frontmatter")
    block = text.split("---\n", 2)[1]
    name_match = re.search(r'^name:\s*["\']?([^"\'\n]+)', block, re.MULTILINE)
    description_match = re.search(
        r'^description:\s*["\']?(.*?)["\']?\s*$', block, re.MULTILINE
    )
    if not name_match or not description_match:
        raise ValueError("missing name or description")
    return name_match.group(1).strip(), description_match.group(1).strip()


def implicit_policy(skill_dir: Path) -> bool:
    policy = skill_dir / "agents" / "openai.yaml"
    if not policy.exists():
        return True
    match = re.search(
        r"allow_implicit_invocation:\s*(true|false)",
        policy.read_text(),
        re.IGNORECASE,
    )
    return match is None or match.group(1).lower() == "true"


def main() -> int:
    plugin_root = Path(__file__).resolve().parents[1]
    root = plugin_root / "skills"
    rows: list[tuple[str, bool, int]] = []
    names: set[str] = set()
    failures: list[str] = []

    for skill_dir in sorted(path for path in root.iterdir() if path.is_dir()):
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            failures.append(f"{skill_dir.name}: missing SKILL.md")
            continue
        text = skill_file.read_text()
        try:
            name, description = frontmatter(text)
        except ValueError as exc:
            failures.append(f"{skill_dir.name}: {exc}")
            continue
        if name != skill_dir.name:
            failures.append(f"{skill_dir.name}: frontmatter name is {name}")
        if name in names:
            failures.append(f"{name}: duplicate skill name")
        names.add(name)
        implicit = implicit_policy(skill_dir)
        if (name in EXPLICIT_ONLY) == implicit:
            failures.append(f"{name}: unexpected implicit invocation policy")
        policy = skill_dir / "agents" / "openai.yaml"
        if policy.exists() and "default_prompt:" in policy.read_text():
            if f"${name}" not in policy.read_text():
                failures.append(f"{name}: default prompt does not name the skill")
        rows.append((name, implicit, len(description)))

    missing = EXPECTED - names
    extra = names - EXPECTED
    if missing:
        failures.append(f"missing skills: {', '.join(sorted(missing))}")
    if extra:
        failures.append(f"unexpected skills: {', '.join(sorted(extra))}")

    unslop = (root / "unslop" / "SKILL.md").read_text()
    if "description: Cut AI tells from any writing. Must always apply." not in unslop:
        failures.append("unslop: broad trigger changed")

    factory_contract = plugin_root / "references" / "factory-contract.md"
    if not factory_contract.exists():
        failures.append("missing references/factory-contract.md")
    else:
        contract = factory_contract.read_text()
        required_contract_terms = {
            "Acceptance checks",
            "status:ready",
            "Permissions",
            "Dependencies",
            "dispatch.authorized",
            "task.created",
        }
        for term in sorted(required_contract_terms):
            if term not in contract:
                failures.append(f"factory contract missing: {term}")

    searchable = "\n".join(
        path.read_text()
        for path in root.rglob("*.md")
        if path.name != "AUDIT.md"
    )
    for dependency in sorted(REMOVED_DEPENDENCIES):
        if dependency in searchable:
            failures.append(f"removed dependency still referenced: {dependency}")

    print("skill                         invocation     description chars")
    for name, implicit, chars in rows:
        invocation = "implicit" if implicit else "explicit-only"
        print(f"{name:<29} {invocation:<14} {chars:>5}")
    print(f"skills: {len(rows)}")
    print(f"description chars: {sum(row[2] for row in rows)}")

    if failures:
        print("audit: FAILED", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("audit: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
