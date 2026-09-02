#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d /private/tmp/crew-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"
fakebin="$tmp/bin"
mkdir -p "$repo" "$fakebin"

git -C "$repo" init -q -b main
git -C "$repo" config user.name "Crew Test"
git -C "$repo" config user.email "crew-test@example.invalid"
printf 'test\n' > "$repo/README"
git -C "$repo" add README
git -C "$repo" commit -q -m base

cat > "$fakebin/wt" <<'SCRIPT'
#!/usr/bin/env bash
path="$CREW_TEST_ROOT/worktrees/$2"
mkdir -p "$path"
printf '%s\n' "$path"
SCRIPT
cat > "$fakebin/tmux" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$CREW_TEST_ROOT/tmux-call"
SCRIPT
chmod +x "$fakebin/wt" "$fakebin/tmux"

(
  cd "$repo"
  PATH="$fakebin:$PATH" CREW_TEST_ROOT="$tmp" "$root/bin/crew" start task implement feature
) >/dev/null
[ "$(cat "$tmp/worktrees/task/.crew/prompt.md")" = "implement feature" ]
rg -Fq "exec agent 'codex'" "$tmp/tmux-call"

(
  cd "$repo"
  PATH="$fakebin:$PATH" CREW_TEST_ROOT="$tmp" "$root/bin/crew" start explicit claude fix bug
) >/dev/null
[ "$(cat "$tmp/worktrees/explicit/.crew/prompt.md")" = "fix bug" ]
rg -Fq "exec agent 'claude'" "$tmp/tmux-call"

echo "crew argument parsing: ok"
