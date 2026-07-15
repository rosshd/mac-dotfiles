#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPTAIN_SOURCE_ONLY=1 source "$root/bin/captain"

expect_state() {
  local expected="$1"
  shift
  local actual
  actual="$(classify_no_mistakes "$@")"
  if [[ "$actual" != "$expected|"* ]]; then
    printf 'expected %s, got %s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

now=2000000
recent=$((now - 300))
expired=$((now - 604800))

expect_state passed completed feature abc feature abc true "$recent" "$now" none ""
expect_state failed failed feature abc feature abc true "$recent" "$now" none test
expect_state running running feature abc feature abc true "$recent" "$now" none ""
expect_state stuck running feature abc feature abc true "$expired" "$now" none ""
expect_state needed completed old def main abc true "$expired" "$now" none ""
expect_state idle completed old def main abc false "$expired" "$now" none ""
expect_state needed "" "" "" feature abc true 0 "$now" "" ""

tmp="$(mktemp -d /private/tmp/captain-status-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
worktree="$tmp/worktree"
slug="review-state"
mkdir -p "$tmp/.artifacts/fleet" "$worktree/.gnhf/runs/run"
printf '%s\n' "$worktree" > "$tmp/.artifacts/fleet/$slug.worktree"
git -C "$worktree" init -q -b fleet/review-state
git -C "$worktree" config user.name "Captain Test"
git -C "$worktree" config user.email "captain-test@example.invalid"
printf 'test\n' > "$worktree/README"
git -C "$worktree" add README
git -C "$worktree" commit -q -m "test"
head="$(git -C "$worktree" rev-parse HEAD)"
cat > "$worktree/.gnhf/runs/run/gnhf.log" <<'LOG'
{"event":"orchestrator:abort","reason":"stop condition met"}
{"event":"orchestrator:end","status":"aborted","iterations":2,"commitCount":2}
LOG

printf 'reviewing|%s|%s\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewing\|* ]]
printf 'passed|%s|%s\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == ship-ready\|* ]]
printf 'reviewed|%s|%s\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewed\|* ]]

cat > "$worktree/.gnhf/runs/run/gnhf.log" <<'LOG'
{"event":"orchestrator:abort","reason":"max iterations reached (8)"}
{"event":"orchestrator:end","status":"aborted","iterations":8,"commitCount":7}
LOG
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewed\|*recovered* ]]

echo "captain status freshness policy: ok"
