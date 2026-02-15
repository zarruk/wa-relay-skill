---
name: wa-relay
description: "WhatsApp message relay for OpenClaw. Routes third-party DMs to a dedicated relay agent that notifies the owner and only responds when authorized. Use when setting up WhatsApp message filtering, relay, or firewall for third-party contacts."
---

# wa-relay

Routes third-party WhatsApp DMs to a dedicated relay agent that notifies the owner and only responds when authorized.

## How It Works

- **Main agent** receives messages from the owner only
- **Relay agent** receives messages from everyone else, notifies the owner, and only responds when explicitly authorized

## Setup

1. Run `scripts/setup.sh <owner-phone-number>` (e.g. `+573001234567`)
2. Run `scripts/configure.sh <owner-phone-number>` to generate the config JSON
3. Apply the generated config to your OpenClaw settings (see `references/SETUP.md`)

## Requirements

- OpenClaw v2026.2.14+ with WhatsApp channel configured
- Owner's phone number in international format (e.g. `+573001234567`)

## Security Notes

This skill performs two actions that require elevated access. Both are necessary for multi-agent WhatsApp routing to work and are explained here for transparency:

### 1. Auth credential sharing
The setup script copies `auth-profiles.json` from the main agent to the relay agent. This is required because OpenClaw agents have isolated auth — without shared credentials, the relay agent cannot authenticate with any model provider and will silently fail. The script asks for confirmation before copying.

### 2. Session ID regex patch (temporary)
OpenClaw's session ID validator rejects `:` and `+` characters that WhatsApp phone-number routing generates (e.g. `agent:wa-relay:whatsapp:+15551234567`). The setup script patches the `SAFE_SESSION_ID_RE` regex in OpenClaw's dist files to allow these characters. This is a known bug (openclaw/openclaw#16211) with an open fix (PR #16531). Once merged, this patch becomes unnecessary and can be reverted. The script creates `.bak` backups and asks for confirmation before patching.
