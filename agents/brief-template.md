# Fleet Brief: <slug>

## Objective

<One paragraph: the user-visible outcome. What exists when this is done that does not exist now.>

## Scope

- In: <files, subsystems, or behaviors this task owns>
- Out: <adjacent things the agent must not touch>
- Conflicts with: <other active fleet slugs that share files or storage; leave empty if none>

## Stop condition

<The verifiable implementation and local-verification end state. Set `should_fully_stop=true` when that end state is achieved by this iteration. GNHF commits successful iteration changes automatically afterward, so do not make that commit a prerequisite and do not commit manually. The fleet runner then runs one bounded read-only Codex review for `reviewed-branch`, the full no-mistakes gate for `green-pr`, or no independent review for `committed-branch`.>

## Verification

<The exact commands that prove the change works, e.g. `make check`, plus any focused test or smoke flow.>

## Escalation

<Decisions the agent must not make alone: product tradeoffs, UX changes, storage format, privacy, compatibility. On hitting one, stop and report instead of guessing.>

## Ship

<reviewed-branch (default) | green-pr | committed-branch>
