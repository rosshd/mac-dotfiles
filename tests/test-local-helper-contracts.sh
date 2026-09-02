#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for helper in spotify-popup focus-app spotify-mute; do
  [ -x "$root/bin/$helper" ]
  rg -Fq "$helper" "$root/setup.sh" "$root/nix/home.nix"
done
rg -Fq 'brew "spotify_player"' "$root/Brewfile"
rg -Fq 'brew "switchaudio-osx"' "$root/Brewfile"
rg -Fq '"spotify_player"' "$root/nix/darwin.nix"
rg -Fq '"switchaudio-osx"' "$root/nix/darwin.nix"

tmp="$(mktemp -d /private/tmp/spotify-mute-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
player="$tmp/spotify-player"
calls="$tmp/calls"
cat > "$player" <<'SCRIPT'
#!/usr/bin/env sh
if [ "${1:-}" = "get" ]; then
  printf '{"device":{"volume_percent":37}}\n'
else
  printf '%s\n' "$*" >> "$SPOTIFY_TEST_CALLS"
fi
SCRIPT
chmod +x "$player"
SPOTIFY_PLAYER="$player" SPOTIFY_MUTE_STATE="$tmp/state" SPOTIFY_TEST_CALLS="$calls" \
  "$root/bin/spotify-mute"
[ "$(cat "$tmp/state")" = "37" ]
[ "$(cat "$calls")" = "playback volume 0" ]

echo "local helper contracts: ok"
