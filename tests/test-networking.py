#!/usr/bin/env python3

import argparse
import datetime as dt
import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "agents/skills/networking/scripts/networking.py"
SPEC = importlib.util.spec_from_file_location("networking_skill", SCRIPT)
networking = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(networking)


class NetworkingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        for name in ["inbox", "people", "organizations", "interactions", "templates"]:
            (self.root / name).mkdir()
        (self.root / "AGENTS.md").write_text("# Rules\n", encoding="utf-8")
        (self.root / "relationships.csv").write_text(
            ",".join(networking.RELATIONSHIP_HEADER) + "\n",
            encoding="utf-8",
        )

    def tearDown(self):
        self.temporary.cleanup()

    def test_capture_and_archive_preserve_raw_note(self):
        path = networking.write_inbox_note(
            self.root, "Met Ada at a compiler meetup.", "dictated"
        )
        self.assertIn("Met Ada", path.read_text(encoding="utf-8"))
        self.assertEqual(networking.inbox_paths(self.root), [path])

        archived = networking.archive_note(self.root, str(path))

        self.assertFalse(path.exists())
        self.assertTrue(archived.exists())
        self.assertIn("Met Ada", archived.read_text(encoding="utf-8"))

    def test_calendar_import_deduplicates_uid_and_start(self):
        event = {
            "uid": "event-1",
            "calendar": "Work",
            "title": "Coffee with Ada",
            "start": "2026-07-29T10:00:00",
            "end": "2026-07-29T11:00:00",
            "location": "Cafe",
            "url": "",
            "notes": "Discuss compilers",
            "all_day": "false",
        }

        created, skipped = networking.import_calendar_events(self.root, [event])
        second_created, second_skipped = networking.import_calendar_events(
            self.root, [event]
        )

        self.assertEqual(len(created), 1)
        self.assertEqual(skipped, 0)
        self.assertEqual(second_created, [])
        self.assertEqual(second_skipped, 1)
        self.assertIn("not proof", created[0].read_text(encoding="utf-8"))

    def test_relationship_rejects_duplicate(self):
        args = argparse.Namespace(
            from_slug="ada-lovelace",
            to_slug="charles-babbage",
            relationship="collaborator",
            confidence="confirmed",
            source="user dictated 2026-07-29",
            last_verified="2026-07-29",
            notes="",
        )
        networking.add_relationship(self.root, args)
        with self.assertRaisesRegex(ValueError, "already exists"):
            networking.add_relationship(self.root, args)

    def test_due_profiles(self):
        profile = self.root / "people" / "ada-lovelace.md"
        profile.write_text(
            '---\nname: "Ada Lovelace"\nnext_follow_up: "2026-07-29"\n---\n',
            encoding="utf-8",
        )

        due = networking.due_profiles(self.root, dt.date(2026, 7, 29))

        self.assertEqual(due, [(dt.date(2026, 7, 29), profile)])

    def test_calendar_parser_preserves_multiline_notes(self):
        events = networking.parse_calendar_output(
            '[{"uid":"uid","calendar":"Work","title":"Coffee","start":"start",'
            '"end":"end","location":"Cafe","url":"","notes":"line one\\nline two","all_day":"false"}]'
        )
        self.assertEqual(events[0]["notes"], "line one\nline two")


if __name__ == "__main__":
    unittest.main()
