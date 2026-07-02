# Fleet Brief: <slug>

## Objective

<One paragraph: the user-visible outcome. What exists when this is done that does not exist now.>

## Scope

- In: <files, subsystems, or behaviors this task owns>
- Out: <adjacent things the agent must not touch>
- Conflicts with: <other active fleet slugs that share files or storage; leave empty if none>

## Stop condition

<The verifiable end state. Default: project green gate passes, the change is committed on a feature branch, and no-mistakes has produced a green PR.>

## Verification

<The exact commands that prove the change works, e.g. `make check`, plus any focused test or smoke flow.>

## Escalation

<Decisions the agent must not make alone: product tradeoffs, UX changes, storage format, privacy, compatibility. On hitting one, stop and report instead of guessing.>

## Ship

<green-pr (default) | committed-branch>
