# wa-relay — Setup Guide

## Prerequisites

- OpenClaw installed and running with WhatsApp channel connected
- Your phone number in international format (e.g. `+573001234567`)

## Step-by-Step

### 1. Run the setup script

```bash
cd ~/.openclaw/workspace/skills/wa-relay-skill
bash scripts/setup.sh +57XXXXXXXXXX
```

This will:
- Create `~/.openclaw/workspace-relay/` with a `SOUL.md` for the relay agent
- Copy `auth-profiles.json` from your main workspace
- Patch the `SAFE_SESSION_ID_RE` regex in OpenClaw's `paths-*.js` files to allow phone-number-based session routing (temporary until [PR #16531](https://github.com/nichochar/openclaw/pull/16531) is merged)

### 2. Generate the routing config

```bash
bash scripts/configure.sh +57XXXXXXXXXX
```

This outputs the YAML/JSON you need for `agents.list` and `bindings`.

### 3. Apply the config

Edit your OpenClaw config (typically `~/.openclaw/config.yaml`) and add:

```yaml
agents:
  list:
    - name: main
      workspace: ~/.openclaw/workspace
    - name: relay
      workspace: ~/.openclaw/workspace-relay

bindings:
  - channel: whatsapp
    agent: main
    filter:
      from: "+57XXXXXXXXXX"    # ← your number
  - channel: whatsapp
    agent: relay
    filter:
      fromNot: "+57XXXXXXXXXX" # ← your number
```

### 4. Restart OpenClaw

```bash
openclaw gateway restart
```

### 5. Test it

- Send a message **from your phone** → should go to the **main** agent
- Have someone else message you → should go to the **relay** agent, which notifies you

## How the Relay Agent Works

The relay agent:
- **Never** responds to third-party messages on its own
- Forwards every incoming message to the owner with sender info
- Only replies when the owner says: `reply to [number]: [message]`

## Reverting the Patch

Once PR #16531 is merged, restore the original files:

```bash
# Find and restore .bak files
find ~/.openclaw/node_modules -name 'paths-*.js.bak' -exec sh -c 'mv "$1" "${1%.bak}"' _ {} \;
```

Or simply update OpenClaw to the latest version.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Relay not receiving messages | Check `bindings` config — `fromNot` must match your exact number |
| Session ID errors | Verify the `paths-*.js` patch was applied (check for `[a-z0-9._:+\-]`) |
| Auth errors on relay | Ensure `auth-profiles.json` was copied to `workspace-relay/` |
| Messages going to wrong agent | Restart gateway: `openclaw gateway restart` |
