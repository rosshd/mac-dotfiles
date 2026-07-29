# Networking Schema

## Person

Store one profile at `people/<slug>.md`.
Use this frontmatter:

```yaml
---
kind: person
slug: ada-lovelace
name: "Ada Lovelace"
aliases: []
organization: ""
role: ""
location: ""
first_met: ""
last_contact: ""
next_follow_up: ""
tags: []
sources: []
updated_at: "2026-07-29"
---
```

Use these headings in order:

1. `Snapshot`
2. `How We Met`
3. `Work And Interests`
4. `What Matters To Them`
5. `Interaction History`
6. `Open Loops`
7. `Notes`

Keep time-varying facts sourced and dated.
Use relative links for referenced organizations and interactions.

## Organization

Store one profile at `organizations/<slug>.md`.
Use `kind`, `slug`, `name`, `aliases`, `website`, `location`, `tags`, `sources`, and `updated_at` frontmatter.

## Interaction

Store interactions at `interactions/YYYY/MM/YYYY-MM-DD-<slug>.md`.
Use `kind`, `date`, `type`, `status`, `people`, `organizations`, `location`, `source`, and `follow_up_date` frontmatter.

Valid status values:

- `scheduled`
- `confirmed`
- `cancelled`
- `unknown`

Calendar imports begin as `scheduled` or `unknown`.

## Relationships

`relationships.csv` is canonical.
Its columns are:

```text
from_slug,to_slug,relationship,confidence,source,last_verified,notes
```

Confidence is `confirmed`, `reported`, or `inferred`.
Do not write `inferred` relationships unless the inference is useful and explicitly labeled.

## Inbox

Inbox notes use `kind: inbox-note`, `status: pending`, `captured_at`, `source`, and `source_id`.
Raw content is immutable until it is moved to `archive/inbox/YYYY/MM/`.
