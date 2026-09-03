#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

home="$tmp/home"
repo="$home/mac-dotfiles"
installed="$tmp/nix/store/home-manager-files/.local/bin"
mkdir -p "$home/.local/bin" "$repo" "$installed"
touch "$repo/Brewfile" "$repo/flake.nix"
cp bin/rebuild-mac "$installed/rebuild-mac"
chmod +x "$installed/rebuild-mac"

cat > "$home/.local/bin/brew" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLS"
SCRIPT
cat > "$home/.local/bin/nix" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLS"
SCRIPT
cat > "$home/.local/bin/darwin-rebuild" <<'SCRIPT'
#!/usr/bin/env bash
exit 0
SCRIPT
chmod +x "$home/.local/bin/brew" "$home/.local/bin/nix" "$home/.local/bin/darwin-rebuild"

HOME="$home" CALLS="$tmp/calls" "$installed/rebuild-mac" check >/dev/null

rg -Fq -- "--file $repo/Brewfile" "$tmp/calls"
rg -Fq -- "flake show $repo" "$tmp/calls"

echo "rebuild-mac installed path resolution: ok"
