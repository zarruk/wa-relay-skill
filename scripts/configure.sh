#!/usr/bin/env bash
set -euo pipefail

# ─── wa-relay configure ───
# Generates the JSON config for multi-agent WhatsApp routing.
# Usage: bash configure.sh <owner-phone-number>
# Example: bash configure.sh +573001234567

OWNER="${1:?Usage: configure.sh <owner-phone-number> (e.g. +573001234567)}"

# Strip + for session ID use
OWNER_CLEAN="${OWNER//+/}"

cat << EOF

═══════════════════════════════════════════════════════
  wa-relay — Configuration Output
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

bindings:
  - channel: whatsapp
    agent: main
    filter:
      from: "${OWNER}"
  - channel: whatsapp
    agent: relay
    filter:
      fromNot: "${OWNER}"

── JSON equivalent (if your config uses JSON) ──────

{
  "agents": {
    "list": [
      { "name": "main", "workspace": "~/.openclaw/workspace" },
      { "name": "relay", "workspace": "~/.openclaw/workspace-relay" }
    ]
  },
  "bindings": [
    {
      "channel": "whatsapp",
      "agent": "main",
      "filter": { "from": "${OWNER}" }
    },
    {
      "channel": "whatsapp",
      "agent": "relay",
      "filter": { "fromNot": "${OWNER}" }
    }
  ]
}

── 3. Restart OpenClaw ─────────────────────────────

  openclaw gateway restart

═══════════════════════════════════════════════════════

EOF
