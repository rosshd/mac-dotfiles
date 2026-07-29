#!/usr/bin/env python3
"""Deterministic helpers for the private networking workspace."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import uuid
from pathlib import Path
from typing import Iterable

RELATIONSHIP_HEADER = [
    "from_slug",
    "to_slug",
    "relationship",
    "confidence",
    "source",
    "last_verified",
    "notes",
]
SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def workspace_root(value: str | None = None) -> Path:
    raw = value or os.environ.get("NETWORKING_HOME") or "~/networking"
    return Path(raw).expanduser().resolve()


def local_now() -> dt.datetime:
    return dt.datetime.now().astimezone()


def yaml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def require_workspace(root: Path) -> None:
    required = ["inbox", "people", "organizations", "interactions", "templates"]
    missing = [name for name in required if not (root / name).is_dir()]
    if missing:
        raise RuntimeError(f"networking workspace is missing: {', '.join(missing)}")


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{uuid.uuid4().hex}.tmp")
    temporary.write_text(content, encoding="utf-8")
    os.replace(temporary, path)


def note_filename(source: str, now: dt.datetime | None = None) -> str:
    moment = now or local_now()
    safe_source = re.sub(r"[^a-z0-9]+", "-", source.lower()).strip("-") or "manual"
    return f"{moment:%Y%m%d-%H%M%S}-{safe_source}-{uuid.uuid4().hex[:8]}.md"


def write_inbox_note(
    root: Path,
    text: str,
    source: str,
    source_id: str = "",
    metadata: dict[str, str] | None = None,
) -> Path:
    require_workspace(root)
    if not text.strip():
        raise ValueError("capture text cannot be empty")
    captured_at = local_now().isoformat(timespec="seconds")
    lines = [
        "---",
        "kind: inbox-note",
        "status: pending",
        f"captured_at: {yaml_string(captured_at)}",
        f"source: {yaml_string(source)}",
        f"source_id: {yaml_string(source_id)}",
    ]
    for key, value in sorted((metadata or {}).items()):
        lines.append(f"{key}: {yaml_string(value)}")
    lines.extend(["---", "", "# Networking Inbox Note", "", text.strip(), ""])
    path = root / "inbox" / note_filename(source)
    atomic_write(path, "\n".join(lines))
    return path


def inbox_paths(root: Path) -> list[Path]:
    require_workspace(root)
    return sorted(
        path for path in (root / "inbox").rglob("*.md") if path.name != ".gitkeep"
    )


def archive_note(root: Path, raw_path: str) -> Path:
    require_workspace(root)
    path = Path(raw_path).expanduser()
    if not path.is_absolute():
        path = root / "inbox" / path
    path = path.resolve(strict=True)
    inbox = (root / "inbox").resolve()
    if inbox not in path.parents:
        raise ValueError("only files inside the networking inbox can be archived")
    if path.suffix != ".md":
        raise ValueError("only Markdown inbox notes can be archived")
    now = local_now()
    destination_dir = root / "archive" / "inbox" / f"{now:%Y}" / f"{now:%m}"
    destination_dir.mkdir(parents=True, exist_ok=True)
    destination = destination_dir / path.name
    if destination.exists():
        destination = destination.with_name(
            f"{destination.stem}-{uuid.uuid4().hex[:6]}.md"
        )
    shutil.move(str(path), str(destination))
    return destination


def parse_calendar_output(output: str) -> list[dict[str, str]]:
    parsed = json.loads(output or "[]")
    if not isinstance(parsed, list) or any(
        not isinstance(event, dict) for event in parsed
    ):
        raise ValueError("Calendar output must be a JSON event list")
    return [{str(key): str(value) for key, value in event.items()} for event in parsed]


def calendar_source_id(event: dict[str, str]) -> str:
    identity = (
        f"{event.get('uid', '')}\0{event.get('start', '')}\0{event.get('title', '')}"
    )
    return hashlib.sha256(identity.encode("utf-8")).hexdigest()


def calendar_note(event: dict[str, str]) -> str:
    lines = [
        f"Calendar event: {event.get('title') or '(untitled)'}",
        f"Calendar: {event.get('calendar', '')}",
        f"Starts: {event.get('start', '')}",
        f"Ends: {event.get('end', '')}",
        f"All day: {event.get('all_day', '')}",
    ]
    if event.get("location"):
        lines.append(f"Location: {event['location']}")
    if event.get("url"):
        lines.append(f"URL: {event['url']}")
    if event.get("notes"):
        lines.extend(["", "Event notes:", event["notes"]])
    lines.extend(
        [
            "",
            "This event was imported from Apple Calendar.",
            "Treat it as scheduled context, not proof that the interaction occurred.",
        ]
    )
    return "\n".join(lines)


def load_calendar_state(root: Path) -> dict[str, dict[str, str]]:
    path = root / ".state" / "calendar-imports.json"
    if not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("calendar import state must be a JSON object")
    return data


def save_calendar_state(root: Path, state: dict[str, dict[str, str]]) -> None:
    atomic_write(
        root / ".state" / "calendar-imports.json",
        json.dumps(state, indent=2, sort_keys=True) + "\n",
    )


def import_calendar_events(
    root: Path,
    events: Iterable[dict[str, str]],
    dry_run: bool = False,
) -> tuple[list[Path], int]:
    state = load_calendar_state(root)
    created: list[Path] = []
    skipped = 0
    for event in events:
        source_id = calendar_source_id(event)
        if source_id in state:
            skipped += 1
            continue
        if dry_run:
            created.append(Path(f"{event.get('start', '')} {event.get('title', '')}"))
            continue
        path = write_inbox_note(
            root,
            calendar_note(event),
            "apple-calendar",
            source_id,
            {"calendar_event_uid": event.get("uid", "")},
        )
        state[source_id] = {
            "imported_at": local_now().isoformat(timespec="seconds"),
            "inbox_path": str(path.relative_to(root)),
        }
        created.append(path)
    if not dry_run:
        save_calendar_state(root, state)
    return created, skipped


def run_calendar_script(
    days_back: int,
    days_forward: int,
    calendars: list[str],
    script_path: Path,
) -> list[dict[str, str]]:
    command = [
        os.environ.get("NETWORKING_OSASCRIPT", "/usr/bin/osascript"),
        "-l",
        "JavaScript",
        str(script_path),
        str(days_back),
        str(days_forward),
        *calendars,
    ]
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    return parse_calendar_output(result.stdout)


def basic_frontmatter(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return data
    for line in lines[1:]:
        if line == "---":
            break
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip('"')
    return data


def search_workspace(root: Path, query: str) -> list[Path]:
    needle = query.casefold()
    matches = []
    for folder in ("people", "organizations"):
        for path in sorted((root / folder).glob("*.md")):
            if (
                needle in path.stem.casefold()
                or needle in path.read_text(encoding="utf-8").casefold()
            ):
                matches.append(path)
    return matches


def due_profiles(root: Path, on_date: dt.date) -> list[tuple[dt.date, Path]]:
    due = []
    for path in sorted((root / "people").glob("*.md")):
        raw_date = basic_frontmatter(path).get("next_follow_up", "")
        if not raw_date:
            continue
        try:
            follow_up = dt.date.fromisoformat(raw_date)
        except ValueError:
            continue
        if follow_up <= on_date:
            due.append((follow_up, path))
    return sorted(due)


def add_relationship(root: Path, args: argparse.Namespace) -> None:
    if not SLUG_RE.fullmatch(args.from_slug) or not SLUG_RE.fullmatch(args.to_slug):
        raise ValueError("relationship endpoints must be lowercase hyphenated slugs")
    path = root / "relationships.csv"
    existing = []
    if path.exists():
        with path.open(newline="", encoding="utf-8") as handle:
            existing = list(csv.DictReader(handle))
    duplicate = any(
        row.get("from_slug") == args.from_slug
        and row.get("to_slug") == args.to_slug
        and row.get("relationship") == args.relationship
        for row in existing
    )
    if duplicate:
        raise ValueError("that relationship already exists")
    write_header = not path.exists() or path.stat().st_size == 0
    with path.open("a", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=RELATIONSHIP_HEADER)
        if write_header:
            writer.writeheader()
        writer.writerow(
            {
                "from_slug": args.from_slug,
                "to_slug": args.to_slug,
                "relationship": args.relationship,
                "confidence": args.confidence,
                "source": args.source,
                "last_verified": args.last_verified or local_now().date().isoformat(),
                "notes": args.notes,
            }
        )


def workspace_doctor(root: Path) -> tuple[list[str], list[str]]:
    failures: list[str] = []
    warnings: list[str] = []
    try:
        require_workspace(root)
    except RuntimeError as error:
        failures.append(str(error))
        return failures, warnings
    relationship_path = root / "relationships.csv"
    if not relationship_path.exists():
        failures.append("relationships.csv is missing")
    else:
        with relationship_path.open(newline="", encoding="utf-8") as handle:
            header = next(csv.reader(handle), [])
        if header != RELATIONSHIP_HEADER:
            failures.append("relationships.csv has an unexpected header")
    policy = root / "AGENTS.md"
    if not policy.exists():
        failures.append("AGENTS.md is missing or its target is unavailable")
    mode = root.stat().st_mode & 0o777
    if mode & 0o077:
        warnings.append(f"workspace permissions are {mode:o}; 700 is recommended")
    pending = len(inbox_paths(root))
    if pending:
        warnings.append(f"{pending} inbox note(s) are pending")
    return failures, warnings


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="networking")
    parser.add_argument("--home", help="override the networking workspace")
    subparsers = parser.add_subparsers(dest="command", required=True)

    capture = subparsers.add_parser("capture", help="write a pending inbox note")
    capture.add_argument("--source", default="dictated")
    capture.add_argument("text", nargs="*")

    inbox = subparsers.add_parser("inbox", help="list pending inbox notes")
    inbox.add_argument("--count", action="store_true")
    inbox.add_argument("--paths", action="store_true")

    archive = subparsers.add_parser("archive", help="archive a filed inbox note")
    archive.add_argument("path")

    calendar = subparsers.add_parser("calendar", help="import Apple Calendar events")
    calendar.add_argument("--days-back", type=int, default=1)
    calendar.add_argument("--days-forward", type=int, default=14)
    calendar.add_argument("--calendar", action="append", default=[])
    calendar.add_argument("--dry-run", action="store_true")

    find = subparsers.add_parser("find", help="search people and organizations")
    find.add_argument("query")

    due = subparsers.add_parser("due", help="list due profile follow-ups")
    due.add_argument("--date", default=dt.date.today().isoformat())

    connect = subparsers.add_parser("connect", help="record a sourced relationship")
    connect.add_argument("from_slug")
    connect.add_argument("to_slug")
    connect.add_argument("--relationship", required=True)
    connect.add_argument(
        "--confidence",
        choices=["confirmed", "reported", "inferred"],
        default="reported",
    )
    connect.add_argument("--source", required=True)
    connect.add_argument("--last-verified", default="")
    connect.add_argument("--notes", default="")

    process = subparsers.add_parser("process", help="open Codex to process the inbox")
    process.add_argument("--exec", action="store_true", dest="non_interactive")

    subparsers.add_parser("doctor", help="validate the networking workspace")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    root = workspace_root(args.home)
    try:
        if args.command == "capture":
            text = " ".join(args.text).strip()
            if not text and not sys.stdin.isatty():
                text = sys.stdin.read().strip()
            path = write_inbox_note(root, text, args.source)
            print(path)
        elif args.command == "inbox":
            paths = inbox_paths(root)
            if args.count:
                print(len(paths))
            else:
                for path in paths:
                    print(path if args.paths else path.relative_to(root))
        elif args.command == "archive":
            print(archive_note(root, args.path))
        elif args.command == "calendar":
            if args.days_back < 0 or args.days_forward < 0:
                raise ValueError("Calendar day windows cannot be negative")
            script = Path(__file__).with_name("calendar-events.js")
            events = run_calendar_script(
                args.days_back, args.days_forward, args.calendar, script
            )
            created, skipped = import_calendar_events(root, events, args.dry_run)
            action = "would import" if args.dry_run else "imported"
            print(f"{action} {len(created)} event(s); skipped {skipped} duplicate(s)")
            if args.dry_run:
                for item in created:
                    print(item)
        elif args.command == "find":
            for path in search_workspace(root, args.query):
                print(path.relative_to(root))
        elif args.command == "due":
            for follow_up, path in due_profiles(root, dt.date.fromisoformat(args.date)):
                print(f"{follow_up.isoformat()}\t{path.relative_to(root)}")
        elif args.command == "connect":
            add_relationship(root, args)
            print(root / "relationships.csv")
        elif args.command == "process":
            if not inbox_paths(root):
                print("networking inbox is empty")
                return 0
            prompt = (
                "Use $networking to process every pending networking inbox note. "
                "File only supported facts, validate the durable changes, and archive each source "
                "note only after it is fully processed. Leave ambiguous notes pending."
            )
            command = ["codex"]
            if args.non_interactive:
                command.append("exec")
            command.extend(["-C", str(root), prompt])
            return subprocess.run(command).returncode
        elif args.command == "doctor":
            failures, warnings = workspace_doctor(root)
            for warning in warnings:
                print(f"warn {warning}")
            for failure in failures:
                print(f"fail {failure}")
            if not failures:
                print("ok   networking workspace")
            return 1 if failures else 0
    except (
        OSError,
        RuntimeError,
        ValueError,
        subprocess.CalledProcessError,
        json.JSONDecodeError,
    ) as error:
        print(f"networking: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
