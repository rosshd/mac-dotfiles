# Captain Workflow

This is the single canonical workflow doc.
Any other workflow file (including `~/.config/agents/workflow.md`) is a deprecated pointer to this one.
Agent-facing instructions live in `agents/AGENTS.md` and the shared skills under `agents/skills/`.

## The captain loop

Your job is the outer loop only.
Everything inside a lane runs without you until a gate or the end.

```text
intake (idea, bug, issue)
  -> write brief (objective, scope, stop condition, verification, escalation)
  -> pick lane
      interactive  - ambiguous or design-heavy work
      fleet        - any well-briefed task (default)
      cloud        - scheduled or off-machine work
  -> lane runs to the no-mistakes gate
  -> notify: done / blocked / gate
  -> review PR or gate finding
      approve -> merge
      redirect -> new brief
  -> compound reusable learning (ce-compound)
```

## Workspace

Open WezTerm.
Fish runs `ship`, which attaches to the persistent tmux session named `main`.

```bash
ship          # attaches to main
doctor        # health check when tooling behaves unexpectedly
gh dash       # PR and issue board across repos
```

Session windows:

- `code` - Neovim, git status, diffs
- `agent` - primary interactive agent (Codex default)
- `test` - focused checks, green gate, smoke flows
- `notes` - plans, lavish artifacts, review surfaces

## Agent roles

**Codex** is the default agent for implementation, repo inspection, tests, terminal tools, and GitHub workflows.

```bash
codex   # or: cdx   agent codex
```

**Claude Code** adds value when an independent model family helps: second opinion on a consequential decision, cross-model review, diagnosing a Codex blind spot.

```bash
claude   # or: cc   agent claude
```

Do not run two agents on the same implementation without separate ownership boundaries (separate worktrees).

## The three lanes

### Interactive lane (exception)

Use when requirements are unclear, the work is design-heavy, or a product decision dominates.

```bash
agent codex          # or agent claude
```

- Use `ce-brainstorm` or `ce-plan` to converge.
- Once converged, write a brief and dispatch to the fleet lane.
- Today this is the default; the target is to make it the minority.

### Fleet lane (default for well-briefed work)

Any task you can write a bounded brief for: features, bug fixes, refactors, test coverage.

```bash
fleet brief <slug>          # create brief from template, open in $EDITOR
fleet start <slug>          # dispatch: gnhf in a worktree, notify on done/blocked
fleet start <slug> --agent claude   # override agent per task (codex default)
fleet status                # show active windows and worktrees
fleet done <worktree-path>  # remove a finished worktree
```

Briefs live at `.artifacts/fleet/<slug>.md` in the repo (gitignored).
Worktrees live at `~/Developer/worktrees/<repo>/fleet-<slug>`.
A run ends at a green PR; you review and merge.
`fleet start` on an existing slug resumes the run from where gnhf left off.

Brief template fields: objective, scope (in/out/conflicts-with), stop condition, verification, escalation, ship.

### Cloud lane (scheduled and off-machine)

Recurring maintenance and PR babysitting that runs while you sleep.

**Routines** (run in the cloud on a cron schedule):

| Routine | Schedule | Repo |
| --- | --- | --- |
| openlearn nightly chores | 3am ET daily | rosshd/openlearn |
| mac-dotfiles doc-drift check | 8am ET Mondays | rosshd/mac-dotfiles |

Manage at https://claude.ai/code/routines.
Prompt sources: `agents/routines/`.

**PR babysitter** (per-session loop, fixes red CI and surfaces review comments):

```bash
/loop 15m /babysit-prs
```

**Fleet status from anywhere:**

```bash
fleet status              # tmux windows + worktrees
gh dash                   # PR and issue board
```

## Notifications

`notify` fans out to a macOS banner and an ntfy push (phone), so agent done/blocked/gate events reach you anywhere.

```bash
notify "title" "message"
notify "title" "message" --priority high --tag rotating_light
```

Config at `~/.config/notify/notify.conf` (NTFY_SERVER, NTFY_TOPIC).
Wired into: Claude Code Stop/Notification hooks, `fleet start` run end, no-mistakes gates.
Only fires on done/blocked/gate - never on progress updates.

## GitHub tools

```bash
gh dash           # terminal dashboard: PRs, issues, CI status across repos
gh pr list        # raw list
gh issue list     # raw list
```

gh-dash config: `gh-dash/config.yml` (symlinked to `~/.config/gh-dash/config.yml`).

## Validation layers

**Focused checks** - the narrowest test, lint, typecheck, or manual reproduction for the changed behavior.
Run repeatedly during implementation.

**Project green gate** - the repo's authoritative local command.
Must pass before implementation is complete.

```bash
make check      # openlearn: lint + unittest + pytest + mocked smoke flow
make validate   # other repos
```

**Project review evidence** - captures diff, checks, results, skipped coverage, remaining risk.

```bash
make review
```

**CE deep review** (`ce-code-review`) - semantic review for broad, risky, or architecturally important changes.
Run before final review evidence only when the risk warrants it.
Strong triggers: storage formats, provider boundaries, auth/permissions, concurrency, large diffs with new behavior.

**no-mistakes shipping gate** - owns rebase, release review, tests, docs, lint, push, PR creation, and CI.
Start only after the change is committed on a feature branch.

```bash
git status --short
git branch --show-current
no-mistakes axi run --intent "<user-visible objective, constraints, deliberate tradeoffs>"
```

When a gate fires: read every finding, allow mechanical fixes, escalate product decisions.
Advance with `no-mistakes axi respond`.
Never edit around an active gate or abort to bypass a finding.

```bash
no-mistakes axi status
no-mistakes axi logs --step review --full
```

The fleet lane drives no-mistakes automatically.
Run it manually only for interactive-lane work.

## Task intake (interactive lane)

Before editing anything:

1. Read the project `AGENTS.md`.
2. Inspect `git status`.
3. Identify unrelated existing changes.
4. State the user-visible outcome.
5. Reproduce or understand the failure when fixing a bug.
6. Find the nearest implementation and tests.
7. Classify as small, medium, or large.

**Small** - narrow, well understood, low risk, obvious test:

```text
understand/reproduce -> implement -> focused test -> green gate -> commit -> no-mistakes
```

**Medium** - several files, meaningful behavior, clear direction:

```text
short plan -> implement -> focused tests -> green gate -> review evidence -> commit -> no-mistakes
```

Add CE review when implementation contains significant judgment or crosses an important boundary.

**Large/risky** - uncertain requirements, broad behavior, storage, architecture, external integrations:

```text
ce-brainstorm/ce-plan -> approve decisions -> worktree -> implement
-> focused tests -> green gate -> CE review -> review evidence
-> commit -> no-mistakes -> human merge -> ce-compound
```

## Compound Engineering skills

Installed globally in Codex. Restart Codex after upgrading.

| Skill | Use when |
| --- | --- |
| `ce-pov` | Deciding whether to adopt a library, platform, or pattern |
| `ce-brainstorm` | Requirements, users, or constraints are unclear |
| `ce-plan` | Multi-file, multi-phase, or high-risk work |
| `ce-debug` | Intermittent, cross-boundary, or hard-to-localize failures |
| `ce-code-review` | Broad, risky, unfamiliar, or architecturally important changes |
| `ce-compound` | After solving something surprising whose lesson improves future work |

Do not use `ce-commit-push-pr` when shipping through no-mistakes.
Do not use `ce-work`, `ce-worktree`, or `/lfg` unless you explicitly want CE to own a hands-off execution lane.

## Lavish artifacts

Use Lavish when a plan, comparison, architecture map, or review report benefits from visual review.

```bash
lavish-axi path/to/artifact.html
```

Keep artifacts in an ignored project directory (`.lavish/`).
Use the product's design language when the artifact represents a specific app.

## Isolation

One active scoped task can use the working tree directly when its state is clear.
Use a worktree when another task or agent needs independent filesystem state.

```bash
wt new <slug>             # create worktree at ~/Developer/worktrees/<repo>/<slug>
wt list                   # list worktrees
wt done <path>            # remove a clean worktree
wt prune                  # prune stale git metadata
```

Fleet runs create and manage their own worktrees automatically.
Manual worktrees are for interactive-lane parallel work.
Parallel tasks need separate subsystems, separate worktrees, and independent stop conditions.

## Failure handling

**Focused check fails** - fix the implementation or test assumption before broadening.

**Green gate fails** - do not ship.

**CE review finds a product decision** - resolve it before applying a speculative fix.

**no-mistakes gate fires** - use its respond mechanism; do not edit around it or abort to bypass.

**CI fails** - inspect the exact job and logs, fix the cause on the same branch, rerun.

**Fleet run blocked** - gnhf notifies you; inspect the worktree, fix the blocker, `fleet start <slug>` to resume.

**no-mistakes stuck/hung** - inspect with `no-mistakes axi logs --step <step> --full`; abort with `no-mistakes axi abort` only after confirming the run is genuinely hung, not just slow.

**Rate limit during fleet run** - gnhf backs off and retries; if it hits 3 consecutive failures it aborts. `fleet start <slug>` resumes from the same run ID at the next iteration.

**Unrelated changes exist** - preserve them; keep task commits scoped.

## Compounding

After consequential work, ask:

1. What was surprising?
2. Could the failure recur?
3. Can a test catch it?
4. Can an automated gate catch it?
5. Does a project skill need a rule?
6. Does an architecture document need a durable contract?
7. Will a future agent find and use the learning?

Prefer in order: regression test -> automated check -> project skill -> architecture doc -> solution note.
Global instruction only when universally applicable.
Keep `AGENTS.md` short.

## Definition of done

A task is done when:

- the requested outcome is present
- unrelated behavior is preserved
- focused tests cover the change
- the project green gate passes
- required smoke or end-to-end checks pass
- review findings are resolved or explicitly accepted
- the diff contains no unrelated changes
- exact verification evidence is reported
- the branch is a green PR when shipping was requested
- reusable learning is encoded at the narrowest durable layer
