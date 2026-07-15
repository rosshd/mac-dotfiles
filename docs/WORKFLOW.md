# Captain Workflow

This is the single canonical workflow doc.
Any other workflow file (including `~/.config/agents/workflow.md`) is a deprecated pointer to this one.
Agent-facing instructions live in `agents/AGENTS.md` and the shared skills under `agents/skills/`.

## The captain loop

Your job is the outer loop only.
Everything inside a lane runs without you until a gate or the end.
The `captain` command is the terminal control surface for this loop.

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

Daily commands:

```bash
captain status              # one-shot status across fleet, Treehouse, no-mistakes, GitHub, voice
captain phone-status        # compact iPhone Shortcut status output
captain dispatch "<task>"   # create a fleet brief and dispatch from phone voice/text
captain watch               # live terminal dashboard
captain brief <slug>        # write a bounded task brief
captain start <slug>        # dispatch a fleet run in a Treehouse-leased worktree
captain done <path>         # return/remove a finished worktree
captain review "<intent>"   # run no-mistakes for interactive-lane work
captain voice               # open OpenSuperWhisper and show voice vocabulary
captain station             # test the local station notification sound
herdr                       # rich terminal dashboard for live agent panes
```

`captain status` and `captain phone-status` read each fleet's latest GNHF run log rather than treating a tmux window as proof that an agent is active.
They report running, ready, capped, failed, stuck, orphaned, idle, stale, or untracked state, plus iteration and commit progress.
A run is considered stuck after 20 minutes without a GNHF log update; override this with `CAPTAIN_FLEET_STUCK_SECONDS` when needed.
Captain only shows a completed no-mistakes result as current when it matches the checkout branch and HEAD and was updated within three days.
Older or mismatched results collapse automatically to `gate needed` when work exists or `gate idle` on a clean default branch.
Override the three-day window with `CAPTAIN_NO_MISTAKES_MAX_AGE_SECONDS` and the 20-minute active-run threshold with `CAPTAIN_NO_MISTAKES_STUCK_SECONDS`.

## Workspace

Open WezTerm.
Fish runs `ship`, which attaches to the persistent tmux session named `main`.
Nothing should launch automatically at login.
The day starts with a clean desktop; open WezTerm only when you are ready to work.
tmux saves sessions periodically and restores the last saved workspace when a new tmux server starts.
If no snapshot exists, `ship` creates the fallback `home` and `notes` windows.
`ship` attempts an explicit resurrect restore before it creates that fallback.
Use `ship --save` before a restart when you want the current pane layout captured immediately.

```bash
ship          # attaches to main
ship --save   # manually save the tmux layout before restarting
doctor        # health check when tooling behaves unexpectedly
rebuild-mac check # package and Nix readiness check
gh dash       # PR and issue board across repos
```

Session windows:

- `home` - project navigation, Git status, quick commands
- `notes` - plans, lavish artifacts, review surfaces

Open extra tmux windows only when the task needs them:

- `code` - Neovim, git status, diffs
- `agent` - primary interactive agent (Codex default)
- `test` - focused checks, green gate, smoke flows
- `captain` - `captain watch`, fleet state, gates, and station alerts

Herdr is the alternate live-agent surface.
Use tmux for the normal terminal workspace and fast keyboard muscle memory.
Use Herdr when the main job is keeping several agent panes visible, tracking which one is blocked/done/working, or attaching from a narrow terminal.
It complements the captain loop rather than replacing it.

```bash
herdr
herdr --session captain
herdr integration status
```

Inside Herdr, start agents exactly as you do elsewhere:

```bash
codex
claude
opencode
```

Herdr has integrations installed for Codex, Claude, OpenCode, and Copilot CLI.
It sorts the agent panel by attention priority and uses in-app toasts without sound so Glass/ntfy remains the captain-needed alert.

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
Fleet worktrees are leased from Treehouse by default and their paths are recorded next to the brief.
A default run ends at an independently reviewed local branch; you decide whether to ship it.
The fleet runner enforces this as two stages: GNHF owns bounded implementation and local verification, then no-mistakes owns independent review and any explicitly selected push, PR, and CI work.
`--ship committed-branch` intentionally stops after the first stage and is reported as ready for review rather than reviewed.
`--ship green-pr` explicitly enables the push, PR, and CI stages; the default `--ship reviewed-branch` skips them.
`fleet start` on an existing slug resumes the run from where gnhf left off.

Brief template fields: objective, scope (in/out/conflicts-with), stop condition, verification, escalation, ship.
Write the stop condition around the completed outcome and verification, not around the existence of GNHF's automatic commit.
The agent must set `should_fully_stop=true` when the final iteration completes the scoped outcome; GNHF commits that successful iteration after the response.

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
Local station notifications also play a sound.
Sound playback is single-owner through `afplay`, so alerts do not double-trigger through the macOS notification system.
Use `Glass` for captain-needed alerts because it is clear, pleasant, and less fatiguing than harsher system sounds.
Tune it with `--volume quiet|normal|loud|urgent` and `--repeat <n>`.

```bash
notify "title" "message"
notify --sound Glass --volume loud --repeat 2 --priority high --tag rotating_light "Captain needed" "Review the gate"
notify --sound Glass --volume normal --repeat 1 "Done" "The run finished"
captain station
notify "title" "message" --priority high --tag rotating_light
```

Config at `~/.config/notify/notify.conf` (NTFY_SERVER, NTFY_TOPIC).
Optional defaults: `NOTIFY_SOUND`, `NOTIFY_VOLUME`, and `NOTIFY_REPEAT`.
Wired into: Claude Code Stop/Notification hooks, `fleet start` run end, no-mistakes gates.
Only fires on done/blocked/gate - never on progress updates.

Use the tmux `Ctrl-a N` binding to test the sound from the terminal.

## Phone Shortcuts

Phone access uses Tailscale plus normal macOS Remote Login.
The Tailscale macOS app gives the phone a private network path to this Mac; macOS `sshd` handles the actual Shortcut command execution.
Do not rely on Tailscale SSH for the Mac app variant because the standalone macOS app is not a Tailscale SSH server.
Prefer the Tailscale MagicDNS hostname over a raw `100.x` IP when Shortcuts supports it.
The hostname is more stable and avoids the wrong-IP failure mode.

Mac setup:

```bash
brew install --cask tailscale-app
open -a Tailscale
sudo systemsetup -setremotelogin on
tailscale status
captain phone-host
```

Sign in to Tailscale on the Mac and phone with the same account.
Use the Mac's Tailscale hostname or `100.x.y.z` address as the SSH host in Shortcuts.
Keep Remote Login limited to your user account in System Settings > General > Sharing > Remote Login.

Use `captain phone-status` for iPhone Shortcuts instead of `captain status`.
It is designed for the small Shortcuts result modal: short lines, no ANSI escape codes, no raw tool tables, and a decision-first `Needs You` section.

```bash
/bin/zsh -lc 'cd /Users/ross/Developer/projects/openlearn && /Users/ross/.local/bin/captain phone-status'
```

Keep full terminal status on `captain status`.

Use `captain phone-host` when Shortcuts says it cannot connect to SSH.
It prints the Mac hostname and Tailscale self status when the CLI is available.

Herdr can also be used from a phone SSH terminal when you need a live session instead of a Shortcut result modal.
For phone prompting, Shortcuts remain faster for dispatch/status.
For live triage, SSH into the Mac and run `herdr` or `herdr --session captain`.

Use `captain dispatch` for voice-driven work from the phone.
The command turns rough dictated text into a dispatch preview by default.
It does not create a brief, worktree, or fleet run unless you pass `--start`.
This prevents accidental Shortcut submissions from creating worktrees.

Shortcut: `Captain Dispatch`

1. Add `Dictate Text`.
2. Add `Run Script over SSH` for preview.
3. Set host to the Mac SSH host, user `ross`, port `22`, and authentication to the iPhone SSH key.
4. Pass the dictated text as Shortcut Input.
5. Use this preview script:

```bash
/bin/zsh -lc 'cd /Users/ross/Developer/projects/openlearn && /Users/ross/.local/bin/captain dispatch "$1"' -- 'DICTATED_TEXT'
```

Replace `DICTATED_TEXT` with the dictated text variable in Shortcuts.
6. Add `Choose from Menu` with `Yes` and `No`.
7. Under `Yes`, run this start script with the same dictated text:

```bash
/bin/zsh -lc 'cd /Users/ross/Developer/projects/openlearn && /Users/ross/.local/bin/captain dispatch --start "$1"' -- 'DICTATED_TEXT'
```

8. Under `No`, run the `Captain Dispatch` shortcut again when you want a clean retry.

Phone dispatch defaults to `--ship reviewed-branch`, which performs independent local review without pushing.
Use `--ship committed-branch` to skip independent review or `--ship green-pr` to request push, PR, and CI explicitly.

## Voice Input

OpenSuperWhisper is the local voice entry surface.
Use it for long prompts, fleet briefs, and planning notes instead of squeezing ideas into short typed commands.

```bash
captain voice
voice-vocab
```

Keep voice input as a prompt accelerator, not a hidden automation layer.
The agent still needs explicit scope, done criteria, and verification.
Update `voice/vocabulary.md` whenever new tool names or project terms are misheard.

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

The fleet lane starts no-mistakes automatically after a successful GNHF implementation for `--ship reviewed-branch` and `--ship green-pr`.
No-mistakes may pause at an approval gate; use `captain status` to see the decision and `no-mistakes axi respond` to continue.
Run it manually only for interactive-lane work.

## Reproducible laptop foundation

The active reproducibility path is the Lix-backed nix-darwin and Home Manager configuration in `flake.nix`, `nix/darwin.nix`, and `nix/home.nix`.
The `Brewfile` remains the package manifest and package-only recovery path.

```bash
rebuild-mac check
rebuild-mac brew
rebuild-mac nix
```

`doctor` reports package drift, Nix readiness, Herdr install state, and Herdr integration status.

See [Reproducibility](REPRODUCIBILITY.md).

## Reusable Templates

Use [Coding Templates](CODING_TEMPLATES.md) for repeatable repo setup, bug fix, review, validation, worktree, and planning workflows.
The templates map each workflow part to the tool that owns it and explain why.

## Model Policy

Codex defaults to `gpt-5.5` for captain, planning, difficult implementation, review, debugging, and computer-use work.
Use faster/lighter models only for read-heavy scouts, summarization, and low-risk support agents.
Let Codex choose subagent settings when the task is routine; pin model/reasoning only when the brief needs it.

Good split:

- Captain/orchestrator: strongest available model, medium or high reasoning.
- Review/security/debug agents: high reasoning.
- Scouts/status/document extraction: fast model, low or medium reasoning.

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
wt get                    # lease a Treehouse worktree for this repo
wt status                 # show Treehouse pool state
wt return <path>          # return a Treehouse worktree
wt new <slug>             # create worktree at ~/Developer/worktrees/<repo>/<slug>
wt list                   # list worktrees
wt done <path>            # remove a clean worktree
wt prune                  # prune stale git metadata
```

Fleet runs lease and resume Treehouse worktrees automatically.
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
