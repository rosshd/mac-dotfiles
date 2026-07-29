#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d /private/tmp/agent-doctor-test.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p \
  "$tmp/mac-dotfiles/agents/skills/example" \
  "$tmp/.codex/skills/example" \
  "$tmp/.codex" \
  "$tmp/.claude" \
  "$tmp/.config/opencode" \
  "$tmp/.copilot" \
  "$tmp/.gemini" \
  "$tmp/networking/inbox" \
  "$tmp/networking/people" \
  "$tmp/networking/organizations" \
  "$tmp/networking/interactions" \
  "$tmp/networking/templates"

ln -s "$tmp/mac-dotfiles/agents" "$tmp/agents"
for path in \
  "$tmp/.codex/AGENTS.md" \
  "$tmp/.claude/CLAUDE.md" \
  "$tmp/.config/opencode/AGENTS.md" \
  "$tmp/.copilot/copilot-instructions.md" \
  "$tmp/.gemini/GEMINI.md"; do
  ln -s "$tmp/agents/AGENTS.md" "$path"
done
printf '# Rules\n' > "$tmp/mac-dotfiles/agents/AGENTS.md"
printf '%s\n' '---' 'name: example' 'description: Example.' '---' > "$tmp/mac-dotfiles/agents/skills/example/SKILL.md"
cp "$tmp/mac-dotfiles/agents/skills/example/SKILL.md" "$tmp/.codex/skills/example/SKILL.md"
printf '# Rules\n' > "$tmp/networking/AGENTS.md"
printf 'from_slug,to_slug,relationship,confidence,source,last_verified,notes\n' > "$tmp/networking/relationships.csv"
chmod 700 "$tmp/networking"

mkdir -p "$tmp/bin"
cat > "$tmp/bin/networking" <<'SCRIPT'
#!/usr/bin/env bash
exit 0
SCRIPT
cat > "$tmp/bin/codex" <<'SCRIPT'
#!/usr/bin/env bash
exit 0
SCRIPT
chmod +x "$tmp/bin/networking" "$tmp/bin/codex"

HOME="$tmp" PATH="$tmp/bin:/usr/bin:/bin" \
  /usr/bin/python3 "$root/bin/agent-doctor" --home "$tmp" --skip-git |
  grep -Fq '0 failure(s)'

echo "agent doctor contract: ok"
