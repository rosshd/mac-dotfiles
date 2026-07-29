#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

eval "$(sed -n '/^STOP_COMMIT_GUIDANCE=/p; /^STOP_DEFAULT=/p; /^STOP_COMMITTED_BRANCH=/p' "$root/bin/fleet")"

for condition in "$STOP_DEFAULT" "$STOP_COMMITTED_BRANCH"; do
  [[ "$condition" == *'Set should_fully_stop=true when the scoped outcome and required verification are complete after this iteration'* ]]
  [[ "$condition" == *'GNHF commits successful iteration changes automatically after your response'* ]]
done

[[ "$STOP_DEFAULT" == *'fleet runner starts its independent review stage after GNHF exits'* ]]
[[ "$STOP_DEFAULT" == *'do not run review or shipping automation inside this implementation loop'* ]]
[[ "$STOP_DEFAULT" != *'green pull request'* ]]
[[ "$STOP_COMMITTED_BRANCH" != *'green pull request'* ]]

if rg -Fq 'the change is committed on a feature branch' \
  "$root/bin/fleet" \
  "$root/bin/captain" \
  "$root/agents/prompts/templates/fleet-brief.md"; then
  echo "fleet stop conditions must not wait for GNHF's automatic commit" >&2
  exit 1
fi

echo "fleet stop-condition contract: ok"
