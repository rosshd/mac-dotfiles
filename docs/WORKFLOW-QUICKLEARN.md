# Captain Workflow - Quick Learn Reference

This file is optimized for spaced repetition via `openlearn quicklearn WORKFLOW-QUICKLEARN.md`.
It covers the key concepts, commands, and decisions you need to operate the captain workflow fluently.

---

## Core mental model

The captain runs the outer loop only.
The captain writes briefs, dispatches lanes, reviews gates, and merges PRs.
The captain does not drive every implementation step.

The three modes of work:
- **Interactive lane** - you drive the agent (exception, for ambiguous or design-heavy work)
- **Fleet lane** - you write a brief, agent runs unattended to a green PR (default)
- **Cloud lane** - scheduled agents run while you sleep (routines, PR babysitter)

The shift: previously 100% interactive. Target: interactive is the minority.

---

## The outer loop (always)

```
intake -> brief -> pick lane -> lane runs -> notify -> review -> merge or redirect -> compound
```

Every fleet or cloud run ends at a gate.
You never watch the run - you get notified when it needs you.

---

## When to use each lane

**Interactive** when:
- Requirements or product direction are unclear
- The work is design-heavy (use ce-brainstorm or ce-plan first)
- A product decision dominates and the agent can't make it alone

**Fleet** when:
- You can write a bounded brief with a clear stop condition
- Examples: features, bug fixes, refactors, test coverage, CLI additions

**Cloud** when:
- Work is recurring (nightly chores, weekly doc-drift)
- You want it to run off-machine or while you sleep
- PR CI is failing and you want it babysit automatically

---

## Fleet commands (daily use)

```bash
fleet brief <slug>            # create brief from template, opens in $EDITOR
fleet start <slug>            # dispatch: gnhf in worktree, notify on done/blocked
fleet start <slug> --agent claude   # override agent (codex is default)
fleet status                  # show running windows + worktrees
fleet done <worktree-path>    # clean up a finished worktree
```

After a rate-limit abort or machine sleep, `fleet start <slug>` resumes from where gnhf stopped.
Fleet reuses idle tmux windows; only opens a new window if the existing one is still running.

---

## The brief (what makes fleet work)

File: `.artifacts/fleet/<slug>.md` in the repo (gitignored).

Fields every brief must have:

| Field | Purpose |
|---|---|
| Objective | User-visible outcome. What exists when done that doesn't now. |
| Scope - In | Files, subsystems, behaviors this task owns. |
| Scope - Out | Adjacent things the agent must not touch. |
| Conflicts with | Other active fleet slugs sharing files or storage. |
| Stop condition | Verifiable end state (default: green gate + committed + green PR). |
| Verification | Exact commands that prove the change works. |
| Escalation | Decisions the agent must not make alone. On hit: stop and report. |
| Ship | `green-pr` (default) or `committed-branch`. |

A bad brief is the primary cause of wasted fleet iterations.
Tight stop conditions and explicit escalation rules are the mitigation.

---

## Notifications

`notify` fans out to macOS banner (terminal-notifier) + ntfy phone push.

```bash
notify "title" "message"
notify "title" "message" --priority high --tag rotating_light
```

Fires on: fleet done, fleet blocked, no-mistakes gate, Claude Code Stop/Notification.
Never fires on progress updates (notification fatigue rule).

Config: `~/.config/notify/notify.conf` (NTFY_SERVER, NTFY_TOPIC).

---

## Cloud lane - what's running

| Name | When | What it does |
|---|---|---|
| openlearn nightly chores | 3am ET daily | `make check`, fixes breakage, opens PR if needed |
| mac-dotfiles doc-drift | 8am ET Mondays | audits docs vs repo, opens issue if drift found |
| PR babysitter | `/loop 15m /babysit-prs` (per session) | fixes red CI, surfaces review comments |

Manage routines at https://claude.ai/code/routines.
Prompt sources: `~/mac-dotfiles/agents/routines/`.

---

## Validation layers (in order)

1. **Focused checks** - narrowest test/lint for the changed behavior. Run during implementation.
2. **Project green gate** (`make check`) - must pass before implementation is complete. Do not ship without it.
3. **Project review evidence** (`make review`) - captures diff + results + remaining risk.
4. **CE deep review** (`ce-code-review`) - only for broad/risky/architecturally important changes.
5. **no-mistakes gate** - owns rebase, review, tests, docs, lint, push, PR, CI. Start after committing on a feature branch.

Fleet drives no-mistakes automatically.
Run no-mistakes manually only for interactive-lane work.

---

## no-mistakes key rules

- Start only after the change is committed on a feature branch (never mid-implementation).
- When a gate fires: read every finding, allow mechanical fixes, escalate product decisions.
- Never edit around an active gate.
- Never abort to bypass a finding.
- `no-mistakes axi abort` only when a run is genuinely hung (check logs first).

```bash
no-mistakes axi status
no-mistakes axi logs --step review --full
no-mistakes axi respond
no-mistakes axi abort
```

---

## CE skills - when to reach for each

| Skill | Trigger |
|---|---|
| `ce-brainstorm` | Requirements, users, or edge cases are unclear |
| `ce-plan` | Multi-file, multi-phase, or high-risk work |
| `ce-pov` | Deciding whether to adopt a library, pattern, or tool |
| `ce-debug` | Intermittent, cross-boundary, or hard-to-localize failures |
| `ce-code-review` | Broad, risky, unfamiliar, or architecturally important changes |
| `ce-compound` | After solving something surprising with reusable learning |

CE review triggers: storage formats, provider boundaries, auth/permissions, concurrency, large diffs.
Do not run CE review for every small patch.

---

## GitHub tools

```bash
gh dash                 # terminal dashboard: PRs, issues, CI status (default view)
fleet status            # cross-repo fleet tmux windows + worktrees
```

gh-dash sections: My PRs, Fleet PRs (`fleet/*`), Needs review, openlearn issues, dotfiles issues.

---

## Agent roles

**Codex** - default for implementation, repo inspection, tests, terminal tools, GitHub.
**Claude Code** - use when an independent model family adds value (second opinion, cross-model review).

Do not run two agents on the same implementation without separate worktrees.

---

## Failure handling cheat sheet

| Failure | Response |
|---|---|
| Focused check fails | Fix implementation or test assumption before broadening |
| Green gate fails | Do not ship |
| CE finds a product decision | Resolve it before applying speculative fix |
| no-mistakes gate fires | Use `axi respond`; never edit around it |
| CI fails | Inspect exact job logs; fix on same branch; rerun |
| Fleet run blocked | Read notify message; fix blocker; `fleet start <slug>` to resume |
| no-mistakes hung | Check `axi logs`; only `axi abort` if genuinely stuck |
| Rate limit aborts fleet | gnhf preserves run state; `fleet start <slug>` resumes next iteration |

---

## Definition of done

- Requested outcome is present
- Unrelated behavior is preserved
- Focused tests cover the change
- Project green gate passes
- Review findings resolved or explicitly accepted
- Diff contains no unrelated changes
- Branch is a green PR (when shipping was requested)
- Reusable learning encoded at the narrowest durable layer

---

## Key paths

| Thing | Location |
|---|---|
| Canonical workflow doc | `~/mac-dotfiles/docs/WORKFLOW.md` |
| This quick-learn file | `~/mac-dotfiles/docs/WORKFLOW-QUICKLEARN.md` |
| Agent instructions | `~/mac-dotfiles/agents/AGENTS.md` |
| Brief template | `~/mac-dotfiles/agents/brief-template.md` |
| Shared skills | `~/mac-dotfiles/agents/skills/` |
| Routine prompts | `~/mac-dotfiles/agents/routines/` |
| gh-dash config | `~/mac-dotfiles/gh-dash/config.yml` |
| notify config | `~/.config/notify/notify.conf` |
| Fleet worktrees | `~/Developer/worktrees/<repo>/fleet-<slug>` |
| Fleet briefs | `<repo>/.artifacts/fleet/<slug>.md` |
