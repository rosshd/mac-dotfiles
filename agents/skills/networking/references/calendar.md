# Apple Calendar Ingestion

The networking CLI reads Calendar through JavaScript for Automation using macOS `osascript`.
macOS may ask the invoking terminal or Raycast for Calendar permission.

The integration:

- reads events within a bounded date window;
- optionally filters by calendar name;
- captures title, calendar, start, end, location, URL, notes, and event UID;
- deduplicates imports by UID and start time;
- writes pending inbox notes;
- never creates, edits, or deletes Calendar events.

An imported event is evidence that time was scheduled.
It is not evidence that Ross attended or spoke with every named attendee.

If access is denied, enable Calendar automation for the invoking application in System Settings, then rerun `networking calendar`.
Use `networking calendar --dry-run` to inspect event counts without writing notes or deduplication state.
