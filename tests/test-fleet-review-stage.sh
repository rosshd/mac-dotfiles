#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d /private/tmp/fleet-review-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT

repo="$tmp/repo"
fakebin="$tmp/bin"
calls="$tmp/no-mistakes.calls"
review_calls="$tmp/codex-review.calls"
mkdir -p "$repo" "$fakebin"

printf '#!/usr/bin/env bash\nexit 0\n' > "$fakebin/notify"
chmod +x "$fakebin/notify"
cat > "$fakebin/tmux" <<'SCRIPT'
#!/usr/bin/env bash
if [ "${1:-}" = "list-panes" ]; then
  [ "${TMUX_NO_SERVER:-0}" = "1" ] && exit 1
  if [ -n "${TMUX_LIVE_SLUG:-}" ]; then
    printf 'fleet:7.2 fleet-%s %s\n' "$TMUX_LIVE_SLUG" "${TMUX_LIVE_COMMAND:-gnhf}"
  fi
fi
exit 0
SCRIPT
chmod +x "$fakebin/tmux"
cat > "$fakebin/gnhf" <<'SCRIPT'
#!/usr/bin/env bash
[ "${GNHF_SKIP_LOG:-0}" = "1" ] && exit 0
mkdir -p .gnhf/runs/test
reason="${GNHF_TEST_REASON:-stop condition met}"
printf '{"event":"run:start","runId":"%s","pid":%s}\n' "${GNHF_LOGGED_RUN_ID:-test}" "$$" > .gnhf/runs/test/gnhf.log
if [ "${GNHF_COMMIT_DURING_PAUSE:-0}" = "1" ]; then
  printf 'advanced during GNHF\n' > gnhf-advanced
  git add gnhf-advanced
  git commit -q -m "advance during GNHF"
fi
if [ -n "${GNHF_PAUSE_FILE:-}" ]; then
  : > "$GNHF_PAUSE_FILE.started"
  while [ ! -f "$GNHF_PAUSE_FILE.release" ]; do
    sleep 0.05
  done
fi
printf '{"event":"orchestrator:abort","reason":"%s"}\n' "$reason" >> .gnhf/runs/test/gnhf.log
printf '{"event":"orchestrator:end","status":"aborted","iterations":1,"commitCount":1}\n' >> .gnhf/runs/test/gnhf.log
exit 0
SCRIPT
chmod +x "$fakebin/gnhf"
cat > "$fakebin/codex" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$REVIEW_CALLS"
result_file=""
while [ $# -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    result_file="$2"
    shift 2
  else
    shift
  fi
done
if [ "${FLEET_REVIEW_MUTATE:-0}" = "1" ]; then
  printf 'changed during review\n' > changed-during-review
  git add changed-during-review
  git commit -q -m "change during review"
fi
printf 'review complete\n'
printf 'FLEET_REVIEW: %s\n' "${FLEET_REVIEW_RESULT:-PASS}" > "$result_file"
SCRIPT
chmod +x "$fakebin/codex"
cat > "$fakebin/no-mistakes" <<'SCRIPT'
#!/usr/bin/env bash
if [ "${1:-}" = "axi" ] && [ "${2:-}" = "run" ]; then
  printf '%s\n' "$*" >> "$NM_CALLS"
  cat <<STATUS
run:
  id: "${NM_RUN_ID:-run-current}"
  status: ${NM_STATUS:-completed}
outcome: ${NM_OUTCOME:-passed}
STATUS
  exit "${NM_RUN_EXIT:-0}"
fi
cat <<STATUS
run:
  id: "${NM_STATUS_ID:-${NM_RUN_ID:-run-current}}"
  status: ${NM_STATUS:-completed}
outcome: ${NM_OUTCOME:-passed}
STATUS
SCRIPT
chmod +x "$fakebin/no-mistakes"

git -C "$repo" init -q -b main
git -C "$repo" config user.name "Fleet Test"
git -C "$repo" config user.email "fleet-test@example.invalid"
printf 'test\n' > "$repo/README"
git -C "$repo" add README
git -C "$repo" commit -q -m "test base"

run_case() {
  local ship="$1"
  local slug="${2:-review-$ship}"
  local reason="${3:-stop condition met}"
  local review_result="${4:-PASS}"
  local mutate="${5:-0}"
  local nm_outcome="${6:-passed}"
  local nm_status="${7:-completed}"
  local nm_run_exit="${8:-0}"
  local nm_status_id="${9:-run-current}"
  local gnhf_skip_log="${10:-0}"
  local gnhf_logged_run_id="${11:-test}"
  rm -f "$calls" "$review_calls"
  (
    cd "$repo"
    PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
      "$root/bin/fleet" start "$slug" --worktree-engine git --ship "$ship" "test review stage"
  ) >/dev/null
  [ "$(cat "$repo/.artifacts/fleet/$slug.ship")" = "$ship" ]
  printf 'reviewed|%s|0\n' "$(git -C "$repo" rev-parse HEAD)" > \
    "$repo/.artifacts/fleet/$slug.review-status"
  printf '\n' | PATH="$fakebin:$PATH" NM_CALLS="$calls" REVIEW_CALLS="$review_calls" \
    FLEET_REVIEW_RESULT="$review_result" GNHF_TEST_REASON="$reason" \
    FLEET_REVIEW_MUTATE="$mutate" NM_OUTCOME="$nm_outcome" \
    NM_STATUS="$nm_status" NM_RUN_EXIT="$nm_run_exit" NM_STATUS_ID="$nm_status_id" \
    GNHF_SKIP_LOG="$gnhf_skip_log" GNHF_LOGGED_RUN_ID="$gnhf_logged_run_id" \
    bash "$repo/.artifacts/fleet/$slug.run.sh" >/dev/null || true
  [ ! -d "$repo/.artifacts/fleet/$slug.ownership" ]
}

run_case committed-branch
[ ! -f "$calls" ]
[ ! -f "$review_calls" ]
rg -Fq 'ready|' "$repo/.artifacts/fleet/review-committed-branch.review-status"
[ ! -d "$repo/.artifacts/fleet/review-committed-branch.ownership" ]

(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start active-rerun --worktree-engine git --ship committed-branch \
    "persist the active run identity"
) >/dev/null
active_worktree="$tmp/worktrees/repo/fleet-active-rerun"
mkdir -p "$active_worktree/.gnhf/runs/old"
printf '%s\n' \
  '{"event":"orchestrator:abort","reason":"stop condition met"}' \
  '{"event":"orchestrator:end","status":"aborted","iterations":1,"commitCount":1}' \
  > "$active_worktree/.gnhf/runs/old/gnhf.log"
pause_file="$tmp/active-rerun"
PATH="$fakebin:$PATH" GNHF_PAUSE_FILE="$pause_file" GNHF_COMMIT_DURING_PAUSE=1 \
  bash "$repo/.artifacts/fleet/active-rerun.run.sh" >/dev/null &
active_pid=$!
for _ in $(seq 1 100); do
  if rg -q '^implementing\|[^|]+\|[^|]+\|test\|$' "$repo/.artifacts/fleet/active-rerun.review-status" 2>/dev/null \
    && [ -f "$pause_file.started" ]; then
    break
  fi
  sleep 0.05
done
if ! rg -q '^implementing\|[^|]+\|[^|]+\|test\|$' "$repo/.artifacts/fleet/active-rerun.review-status"; then
  : > "$pause_file.release"
  wait "$active_pid" || true
  echo "fleet did not persist the active GNHF run ID" >&2
  exit 1
fi
marker_head="$(cut -d'|' -f2 "$repo/.artifacts/fleet/active-rerun.review-status")"
[ "$marker_head" != "$(git -C "$active_worktree" rev-parse HEAD)" ]
if rg -Fq 'shasum' "$repo/.artifacts/fleet/active-rerun.run.sh"; then
  echo "fleet active discovery must not hash GNHF logs" >&2
  exit 1
fi
active_status="$(CAPTAIN_SOURCE_ONLY=1 bash -c 'source "$1"; fleet_run_info "$2" "$3"' _ "$root/bin/captain" "$repo" active-rerun)"
[[ "$active_status" == running\|* ]]
: > "$pause_file.release"
wait "$active_pid"
rg -Fq 'ready|' "$repo/.artifacts/fleet/active-rerun.review-status"
[ ! -d "$repo/.artifacts/fleet/active-rerun.ownership" ]

run_case green-pr capped-green-pr "max iterations reached (8)"
[ ! -f "$calls" ]
rg -Fq 'capped|' "$repo/.artifacts/fleet/capped-green-pr.review-status"

run_case reviewed-branch
[ ! -f "$calls" ]
[ "$(wc -l < "$review_calls" | tr -d ' ')" = "1" ]
rg -Fq -- 'exec --ephemeral -s read-only -o' "$review_calls"
rg -Fq 'reviewed|' "$repo/.artifacts/fleet/review-reviewed-branch.review-status"

run_case reviewed-branch failed-light-review "stop condition met" FAIL
[ "$(wc -l < "$review_calls" | tr -d ' ')" = "1" ]
rg -Fq 'failed|' "$repo/.artifacts/fleet/failed-light-review.review-status"

run_case reviewed-branch changed-during-review "stop condition met" PASS 1
rg -Fq 'failed|' "$repo/.artifacts/fleet/changed-during-review.review-status"

run_case green-pr
[ "$(rg -c '^axi run --yes --intent ' "$calls")" = "1" ]
[ ! -f "$review_calls" ]
rg -Fq 'ship-ready|' "$repo/.artifacts/fleet/review-green-pr.review-status"
rg -q '\|run-current$' "$repo/.artifacts/fleet/review-green-pr.review-status"

mkdir -p "$repo/.artifacts/fleet"
cat > "$repo/.artifacts/fleet/full-intent.md" <<'BRIEF'
# Fleet Brief: full-intent

## Objective

First objective line.
Second objective line.

## Scope

- In: preserve all constraints.
- Out: unrelated behavior.

## Stop condition

The focused contract passes.

## Verification

Run the focused test.

## Escalation

Preserve the deliberate tradeoff.

## Ship

green-pr
BRIEF
run_case green-pr full-intent "stop condition met" PASS 0 checks-passed running
rg -Fq 'ship-ready|' "$repo/.artifacts/fleet/full-intent.review-status"
for expected in \
  'First objective line.' \
  'Second objective line.' \
  'preserve all constraints.' \
  'Preserve the deliberate tradeoff.'; do
  rg -Fq "$expected" "$calls"
done

run_case green-pr failed-gate-old-pass "stop condition met" PASS 0 passed completed 1 run-current
rg -Fq 'failed|' "$repo/.artifacts/fleet/failed-gate-old-pass.review-status"

run_case green-pr mismatched-gate-status "stop condition met" PASS 0 passed completed 0 old-run
rg -Fq 'failed|' "$repo/.artifacts/fleet/mismatched-gate-status.review-status"
if rg -Fq 'ship-ready|' "$repo/.artifacts/fleet/mismatched-gate-status.review-status"; then
  echo "fleet accepted status from a different no-mistakes run" >&2
  exit 1
fi

run_case reviewed-branch missing-gnhf-identity "stop condition met" PASS 0 passed completed 0 run-current 1
rg -Fq 'failed|' "$repo/.artifacts/fleet/missing-gnhf-identity.review-status"
[ ! -f "$review_calls" ]

run_case reviewed-branch mismatched-gnhf-identity "stop condition met" PASS 0 passed completed 0 run-current 0 other-run
rg -Fq 'failed|' "$repo/.artifacts/fleet/mismatched-gnhf-identity.review-status"
[ ! -f "$review_calls" ]

cat > "$repo/.artifacts/fleet/unknown-sections.md" <<'BRIEF'
# Fleet Brief: unknown-sections

## Objective

Preserve the full issue brief.

## Acceptance Criteria

- Include custom acceptance criteria.

## Constraints

- Preserve custom constraints.

## Ship

green-pr
BRIEF
run_case green-pr unknown-sections
rg -Fq 'Include custom acceptance criteria.' "$calls"
rg -Fq 'Preserve custom constraints.' "$calls"
if rg -Fq 'green-pr' "$calls"; then
  echo "Ship metadata must not be included in gate intent" >&2
  exit 1
fi

for invalid_slug in '../escape' 'bad_slug' 'BadSlug' 'bad$(touch-pwned)'; do
  if (
    cd "$repo"
    PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
      "$root/bin/fleet" start "$invalid_slug" --worktree-engine git "invalid slug"
  ) >/dev/null 2>&1; then
    echo "fleet accepted invalid slug: $invalid_slug" >&2
    exit 1
  fi
done

unsafe_root="$tmp/worktrees-\$(touch $tmp/pwned)"
(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$unsafe_root" \
    "$root/bin/fleet" start shell-quoted --worktree-engine git --ship committed-branch \
    "quote generated runner values"
) >/dev/null
printf '\n' | PATH="$fakebin:$PATH" REVIEW_CALLS="$review_calls" \
  bash "$repo/.artifacts/fleet/shell-quoted.run.sh" >/dev/null
[ ! -e "$tmp/pwned" ]

(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" TMUX_NO_SERVER=1 \
    "$root/bin/fleet" start first-tmux --worktree-engine git --ship committed-branch \
    "start without an existing tmux server"
) >/dev/null
[ -d "$repo/.artifacts/fleet/first-tmux.ownership" ]
PATH="$fakebin:$PATH" bash "$repo/.artifacts/fleet/first-tmux.run.sh" >/dev/null
[ ! -d "$repo/.artifacts/fleet/first-tmux.ownership" ]

(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start durable-owner --worktree-engine git --ship committed-branch \
    "hold ownership through runner acknowledgement"
) >/dev/null
durable_output="$tmp/durable-output"
if (
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start durable-owner --worktree-engine git --ship committed-branch \
    "reject duplicate ownership"
) >"$durable_output" 2>&1; then
  echo "fleet accepted a second durable owner for one slug" >&2
  exit 1
fi
rg -Fq "already has an active owner" "$durable_output"
rg -Fq "captain status" "$durable_output"
PATH="$fakebin:$PATH" bash "$repo/.artifacts/fleet/durable-owner.run.sh" >/dev/null
[ ! -d "$repo/.artifacts/fleet/durable-owner.ownership" ]

(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start stale-owner --worktree-engine git --ship committed-branch \
    "reclaim stale durable ownership"
) >/dev/null
stale_token="$(cat "$repo/.artifacts/fleet/stale-owner.ownership/token")"
printf 'running pid=999999 started=0\n' > "$repo/.artifacts/fleet/stale-owner.ownership/owner"
stale_worktree="$tmp/worktrees/repo/fleet-stale-owner"
mkdir -p "$stale_worktree/.gnhf/runs/live-child"
sleep 30 &
live_child_pid=$!
printf '{"event":"run:start","runId":"live-child","pid":%s}\n' "$live_child_pid" > \
  "$stale_worktree/.gnhf/runs/live-child/gnhf.log"
printf 'implementing|unknown|0|live-child|\n' > "$repo/.artifacts/fleet/stale-owner.review-status"
set +e
(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start stale-owner --worktree-engine git --ship committed-branch \
    "reject ownership while exact GNHF child lives"
) >/dev/null 2>&1
live_child_start_ec=$?
set -e
kill "$live_child_pid"
wait "$live_child_pid" 2>/dev/null || true
if [ "$live_child_start_ec" -eq 0 ]; then
  echo "fleet reclaimed ownership from a live exact GNHF child" >&2
  exit 1
fi
(
  cd "$repo"
  PATH="$fakebin:$PATH" WORKTREE_ROOT="$tmp/worktrees" \
    "$root/bin/fleet" start stale-owner --worktree-engine git --ship committed-branch \
    "reclaim stale durable ownership"
) >/dev/null
[ "$(cat "$repo/.artifacts/fleet/stale-owner.ownership/token")" != "$stale_token" ]
PATH="$fakebin:$PATH" bash "$repo/.artifacts/fleet/stale-owner.run.sh" >/dev/null
[ ! -d "$repo/.artifacts/fleet/stale-owner.ownership" ]

live_output="$tmp/live-output"
if (
  cd "$repo"
  PATH="$fakebin:$PATH" TMUX_LIVE_SLUG="already-running" \
    "$root/bin/fleet" start already-running --worktree-engine git "duplicate run"
) >"$live_output" 2>&1; then
  echo "fleet accepted a concurrent runner for the same slug" >&2
  exit 1
fi
rg -Fq "already has a live runner at fleet:7.2 (gnhf)" "$live_output"
rg -Fq "tmux select-window -t 'fleet:7.2'" "$live_output"
rg -Fq "tmux kill-window -t 'fleet:7.2'" "$live_output"
[ ! -e "$repo/.artifacts/fleet/already-running.md" ]

rg -Fq 'exactly one bounded, lightweight, read-only Codex review' \
  "$root/docs/WORKFLOW.md" "$root/docs/WORKFLOW-QUICKLEARN.md"
if rg -Fq 'starts no-mistakes automatically for `reviewed-branch`' \
  "$root/docs/WORKFLOW.md" "$root/docs/WORKFLOW-QUICKLEARN.md" \
  "$root/agents/brief-template.md"; then
  echo "reviewed-branch documentation must not delegate review to no-mistakes" >&2
  exit 1
fi

echo "fleet review stage: ok"
