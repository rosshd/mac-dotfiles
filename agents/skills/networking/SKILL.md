---
name: networking
description: Maintain Ross's private local networking workspace. Use when the user dictates information about a person, asks to add or update a contact, records a meeting or relationship, imports Apple Calendar events, processes networking inbox notes, asks who someone knows, or requests networking follow-ups.
---

# Networking

Maintain `${NETWORKING_HOME:-~/networking}` as a private, provenance-aware relationship record.

## Direct Capture

When the user supplies information directly:

1. Search `people/` by filename, name, and aliases before creating a profile.
2. Read the matching profile and relevant recent interactions.
3. Separate explicit facts, quoted claims, and inference.
4. Update the profile using `references/schema.md`.
5. Create a dated interaction only when the user describes a meeting, call, message, or encounter.
6. Update `relationships.csv` only for an explicit or clearly sourced connection.
7. Add a dated follow-up only when an action or useful next step exists.
8. Summarize the files changed and any uncertainty left unresolved.

Do not turn a sparse mention into a speculative biography.
Do not infer sensitive traits.

## Inbox Processing

Run `networking inbox` to list pending captures.
For each note:

1. Read the raw note and its capture metadata.
2. Search for existing people and organizations before creating files.
3. Apply the direct-capture workflow.
4. Verify every durable write and relationship row.
5. Run `networking archive <inbox-path>` only after the note is fully filed.

Archive instead of deleting.
Leave ambiguous notes pending and explain what is missing.
Never archive a note merely because it was read.

## Apple Calendar

Run `networking calendar --days-back 1 --days-forward 14` to copy event context into the inbox.
Use `--calendar <name>` to restrict imports.
Calendar access is read-only.

Treat imported events as scheduled context, not proof that an interaction occurred.
Do not update `last_contact` or claim attendance until the user confirms it or another source establishes it.
Read `references/calendar.md` when changing or troubleshooting Calendar ingestion.

## Relationships And Follow-ups

Keep `relationships.csv` as the canonical graph.
Use stable person slugs in both endpoints.
Preserve direction when the source only establishes a one-way relationship.
Record confidence, source, and verification date.

Keep actionable dated items in `follow-ups.md`.
Update a profile's `next_follow_up` to match its earliest active follow-up.

## Deterministic Commands

- `networking capture --source dictated -- "<note>"` creates a pending inbox note.
- `networking inbox` lists pending notes.
- `networking process` opens Codex in the workspace with this skill.
- `networking calendar` imports upcoming or recent Apple Calendar events.
- `networking find <query>` searches people and organizations.
- `networking due` lists due follow-ups from profiles.
- `networking connect <from> <to> --relationship <kind>` records a sourced connection.
- `networking doctor` validates the private workspace.

Use `scripts/networking.py` for these operations.
Use the read-only MCP server only for retrieval; all writes remain in the skill workflow.

## Privacy Boundary

- Keep the workspace local and private.
- Never publish or attach its contents without explicit approval.
- Never contact a person or modify an external system without explicit approval.
- Do not store credentials, authentication tokens, financial identifiers, or unnecessary sensitive data.
- Preserve source wording when confidence matters.
