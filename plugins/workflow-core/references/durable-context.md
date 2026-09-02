# Durable project context

Use durable context only for repository-backed work whose domain language or prior decisions affect the result.

## Read path

Follow the repository's documented convention first.

If it has `CONTEXT-MAP.md`, use that map to find the relevant `CONTEXT.md` files.

Otherwise read a root `CONTEXT.md` when present.

Read accepted ADRs from the repository's established ADR location, commonly `docs/adr/`.

Treat accepted ADRs as constraints.
Flag a conflict instead of silently overriding one.

## Write threshold

The brainstorm workflow may update durable context after a decision is settled.
Planning, implementation, and review consume it and report drift; they do not rewrite it as a side effect.

Create or extend `CONTEXT.md` only when exact project vocabulary changes design, acceptance criteria, or module boundaries.
Record the term's project-specific meaning and important boundary cases.
Keep speculative ideas in the requirements or plan instead.

Create an ADR only for a hard-to-reverse decision with lasting consequences, such as a data model, public interface, service boundary, security rule, or operational constraint.
Use the repository's existing template and location.
Capture the context, decision, and consequences without duplicating the implementation plan.

Small changes and one-off implementation choices do not need new durable context.
