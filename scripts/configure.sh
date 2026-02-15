#!/usr/bin/env bash
set -euo pipefail

# ─── wa-relay configure v0.2.0 ───
# Generates the JSON config for multi-agent WhatsApp routing.
# Usage: bash configure.sh <owner-phone-number> [direct-numbers]
# Example: bash configure.sh +573001234567 +573009999999,+573008888888
#
# direct-numbers: comma-separated list of additional numbers that go
#                 directly to the main agent (bypassing the relay).

OWNER="${1:?Usage: configure.sh <owner-phone-number> [direct-numbers-comma-separated]}"
DIRECT="${2:-}"

# Build YAML bindings for owner
YAML_BINDINGS="bindings:
  - channel: whatsapp
    agent: main
    filter:
      from: \"${OWNER}\""

JSON_BINDINGS="    {
      \"channel\": \"whatsapp\",
      \"agent\": \"main\",
      \"filter\": { \"from\": \"${OWNER}\" }
    }"

# Add direct numbers if provided
if [[ -n "$DIRECT" ]]; then
  IFS=',' read -ra NUMS <<< "$DIRECT"
  for NUM in "${NUMS[@]}"; do
    NUM="$(echo "$NUM" | xargs)"  # trim whitespace
    YAML_BINDINGS+="
  - channel: whatsapp
    agent: main
    filter:
      from: \"${NUM}\""
    JSON_BINDINGS+=",
    {
      \"channel\": \"whatsapp\",
      \"agent\": \"main\",
      \"filter\": { \"from\": \"${NUM}\" }
    }"
  done
fi

# Add catch-all for relay
YAML_BINDINGS+="
  - channel: whatsapp
    agent: relay"

JSON_BINDINGS+=",
    {
      \"channel\": \"whatsapp\",
      \"agent\": \"relay\"
    }"

cat << EOF

═══════════════════════════════════════════════════════
  wa-relay — Configuration Output (v0.2.0)
═══════════════════════════════════════════════════════

Add the following to your OpenClaw config:

── 1. agents.list ──────────────────────────────────

In ~/.openclaw/config.yaml (or your config file), set:

agents:
  list:
    - name: main
      workspace: ~/.openclaw/workspace
    - name: relay
      workspace: ~/.openclaw/workspace-relay

── 2. bindings ─────────────────────────────────────

${YAML_BINDINGS}

── JSON equivalent (if your config uses JSON) ──────

{
  "agents": {
    "list": [
      { "name": "main", "workspace": "~/.openclaw/workspace" },
      { "name": "relay", "workspace": "~/.openclaw/workspace-relay" }
    ]
  },
  "bindings": [
${JSON_BINDINGS}
  ]
}

── 3. Restart OpenClaw ─────────────────────────────

  openclaw gateway restart

═══════════════════════════════════════════════════════

EOF

if [[ -n "$DIRECT" ]]; then
  echo "ℹ️  Direct numbers (bypass relay): $DIRECT"
  echo ""
fi
