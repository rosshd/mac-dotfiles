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
mkdir "$tmp/.artifacts/fleet/dispatching.ownership"
[[ "$(fleet_run_info "$tmp" dispatching)" == running\|dispatching* ]]
rm -rf "$tmp/.artifacts/fleet/dispatching.ownership"
printf '%s\n' "$worktree" > "$tmp/.artifacts/fleet/$slug.worktree"
git -C "$worktree" init -q -b fleet/review-state
git -C "$worktree" config user.name "Captain Test"
git -C "$worktree" config user.email "captain-test@example.invalid"
printf 'test\n' > "$worktree/README"
git -C "$worktree" add README
git -C "$worktree" commit -q -m "test"
head="$(git -C "$worktree" rev-parse HEAD)"

mkdir "$tmp/.artifacts/fleet/$slug.ownership"
printf 'implementing|%s|%s|pending|\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == running\|*awaiting\ exact* ]]
rm -rf "$tmp/.artifacts/fleet/$slug.ownership"
printf 'implementation-failed|%s|%s|unknown|\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == failed\|*before\ creating* ]]

cat > "$worktree/.gnhf/runs/run/gnhf.log" <<'LOG'
{"event":"orchestrator:abort","reason":"stop condition met"}
{"event":"orchestrator:end","status":"aborted","iterations":2,"commitCount":2}
LOG

mkdir "$tmp/.artifacts/fleet/$slug.ownership"
printf 'implementing|%s|%s|pending|\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == running\|*awaiting\ exact* ]]
rm -rf "$tmp/.artifacts/fleet/$slug.ownership"

printf 'reviewing|%s|%s|run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewing\|* ]]
printf 'reviewed|%s|%s|run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewed\|* ]]

no_mistakes_info() {
  printf 'passed|passed|validated recently||\n'
}
printf 'reviewed-branch\n' > "$tmp/.artifacts/fleet/$slug.ship"
printf 'reviewing|%s|%s|run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewing\|*lightweight* ]]
printf 'failed|%s|%s|run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == review-failed\|*lightweight* ]]
rm "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == review-failed\|*missing* ]]
printf 'green-pr\n' > "$tmp/.artifacts/fleet/$slug.ship"
[[ "$(fleet_run_info "$tmp" "$slug")" == review-failed\|*missing* ]]
printf 'ship-ready|%s|%s|run|nm-exact\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == ship-ready\|* ]]
printf 'ship-ready|%s|%s|run|\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == review-failed\|*invalid* ]]

printf 'reviewed-branch\n' > "$tmp/.artifacts/fleet/$slug.ship"
printf 'reviewed|%s|%s|run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"

cat > "$worktree/.gnhf/runs/run/gnhf.log" <<'LOG'
{"event":"orchestrator:abort","reason":"max iterations reached (8)"}
{"event":"orchestrator:end","status":"aborted","iterations":8,"commitCount":7}
LOG
mkdir -p "$worktree/.gnhf/runs/other"
cat > "$worktree/.gnhf/runs/other/gnhf.log" <<'LOG'
{"event":"orchestrator:abort","reason":"stop condition met"}
{"event":"orchestrator:end","status":"aborted","iterations":1,"commitCount":1}
LOG
touch -t 202601010101 "$worktree/.gnhf/runs/run/gnhf.log" "$worktree/.gnhf/runs/other/gnhf.log"
[[ "$(fleet_run_info "$tmp" "$slug")" == reviewed\|* ]]

printf 'reviewed|%s|%s|older-run\n' "$head" "$now" > "$tmp/.artifacts/fleet/$slug.review-status"
[[ "$(fleet_run_info "$tmp" "$slug")" == review-failed\|*exact* ]]

echo "captain status freshness policy: ok"
