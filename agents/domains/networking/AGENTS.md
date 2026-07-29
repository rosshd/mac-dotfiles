# Networking Workspace Instructions

This workspace is a private, local-first record of people, organizations, interactions, relationships, and follow-ups.

## Data Rules

- Keep one person per `people/<slug>.md` and one organization per `organizations/<slug>.md`.
- Use stable lowercase hyphenated slugs.
- Record facts with their source and date when they may change.
- Mark interpretation as inference instead of presenting it as fact.
- Keep `relationships.csv` as the canonical record of who knows whom.
- Add meetings and messages as dated files under `interactions/YYYY/MM/`.
- Use `inbox/` for uncategorized notes, then file them into the durable structure.
- Keep follow-ups concrete, dated, and attributable to a person or organization.

## Privacy

- Never publish, upload, or commit this workspace to a public repository.
- Do not add credentials, authentication tokens, financial identifiers, or unnecessary sensitive personal data.
- Do not infer protected or sensitive traits.
- Do not contact anyone, send messages, or modify external systems without explicit user approval.
- Preserve uncertainty and provenance when relationship information is secondhand.

## Maintenance

- Prefer updating an existing profile over creating a duplicate.
- Link profiles with relative Markdown links.
- Update `last_contact` after recording an interaction.
- Update `last_verified` when confirming a relationship.
- Leave raw imports in `inbox/` until their facts have been reviewed.
