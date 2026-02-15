# wa-relay

WhatsApp message relay for OpenClaw. Routes third-party DMs to a dedicated relay agent that notifies the owner and only responds when authorized. Use when setting up WhatsApp message filtering, relay, or firewall for third-party contacts.

## How It Works

- **Main agent** receives messages from the owner only
- **Relay agent** receives messages from everyone else, notifies the owner, and only responds when explicitly authorized

## Setup

1. Run `scripts/setup.sh <owner-phone-number>` (e.g. `+573001234567`)
2. Run `scripts/configure.sh <owner-phone-number>` to generate the config JSON
3. Apply the generated config to your OpenClaw settings (see `references/SETUP.md`)

## Requirements

- OpenClaw with WhatsApp channel configured
- Owner's phone number in international format (e.g. `+573001234567`)
