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

for command in tmux notify; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$fakebin/$command"
  chmod +x "$fakebin/$command"
done
cat > "$fakebin/gnhf" <<'SCRIPT'
#!/usr/bin/env bash
mkdir -p .gnhf/runs/test
reason="${GNHF_TEST_REASON:-stop condition met}"
printf '{"event":"orchestrator:abort","reason":"%s"}\n' "$reason" > .gnhf/runs/test/gnhf.log
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
  exit 0
fi
cat <<STATUS
run:
  status: completed
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
    bash "$repo/.artifacts/fleet/$slug.run.sh" >/dev/null
}

run_case committed-branch
[ ! -f "$calls" ]
[ ! -f "$review_calls" ]
[ ! -f "$repo/.artifacts/fleet/review-committed-branch.review-status" ]

run_case green-pr capped-green-pr "max iterations reached (8)"
[ ! -f "$calls" ]
[ ! -f "$repo/.artifacts/fleet/capped-green-pr.review-status" ]

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
[ "$(rg -c '^axi run --intent ' "$calls")" = "1" ]
rg -Fq 'passed|' "$repo/.artifacts/fleet/review-green-pr.review-status"

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
run_case green-pr full-intent "stop condition met" PASS 0 checks-passed
rg -Fq 'passed|' "$repo/.artifacts/fleet/full-intent.review-status"
for expected in \
  'First objective line.' \
  'Second objective line.' \
  'preserve all constraints.' \
  'Preserve the deliberate tradeoff.'; do
  rg -Fq "$expected" "$calls"
done

rg -Fq 'exactly one bounded, lightweight, read-only Codex review' \
  "$root/docs/WORKFLOW.md" "$root/docs/WORKFLOW-QUICKLEARN.md"
if rg -Fq 'starts no-mistakes automatically for `reviewed-branch`' \
  "$root/docs/WORKFLOW.md" "$root/docs/WORKFLOW-QUICKLEARN.md" \
  "$root/agents/brief-template.md"; then
  echo "reviewed-branch documentation must not delegate review to no-mistakes" >&2
  exit 1
fi

echo "fleet review stage: ok"
