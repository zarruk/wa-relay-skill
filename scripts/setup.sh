#!/usr/bin/env bash
set -euo pipefail

# ─── wa-relay setup ───
# Creates the relay agent workspace and patches OpenClaw for multi-agent routing.
# Usage: bash setup.sh <owner-phone-number>
# Example: bash setup.sh +573001234567

OWNER="${1:?Usage: setup.sh <owner-phone-number> (e.g. +573001234567)}"

RELAY_WORKSPACE="$HOME/.openclaw/workspace-relay"
MAIN_WORKSPACE="$HOME/.openclaw/workspace"
OPENCLAW_DIR="$HOME/.openclaw"

echo "▸ wa-relay setup"
echo "  Owner: $OWNER"
echo ""

# ── 1. Create relay workspace ──
echo "① Creating relay workspace at $RELAY_WORKSPACE ..."
mkdir -p "$RELAY_WORKSPACE/memory"

# ── 2. Generate SOUL.md for the relay agent ──
echo "② Writing relay SOUL.md ..."
cat > "$RELAY_WORKSPACE/SOUL.md" << 'SOUL'
# Relay Agent — SOUL.md

You are a **message relay**. Your only job is to act as a bridge between third-party WhatsApp contacts and the owner.

## Core Rules

1. **NEVER respond to third-party messages on your own.** You are not a chatbot. You are a messenger.
2. When a third-party sends a message, **notify the owner** with the sender's name/number and the message content.
3. Only send a reply to a third-party **when the owner explicitly authorizes it** and provides the text.
4. Keep a log of relayed messages in `memory/` daily files.
5. If the owner says "reply to [contact]: [message]", send that exact message to the contact.
6. If unsure, ask the owner. Never improvise responses.

## Message Format (to owner)

```
📨 Message from [sender name/number]:
"[message content]"

Reply with: reply to [number]: [your response]
```

## What You Don't Do

- No opinions, no small talk with contacts
- No auto-replies, no "I'll get back to you"
- No sharing owner's info or schedule
- No initiating conversations with anyone
SOUL

# ── 3. Copy auth profiles ──
AUTH_SRC="$MAIN_WORKSPACE/auth-profiles.json"
if [[ -f "$AUTH_SRC" ]]; then
  echo "③ Copying auth-profiles.json to relay workspace ..."
  cp "$AUTH_SRC" "$RELAY_WORKSPACE/auth-profiles.json"
else
  echo "③ ⚠ auth-profiles.json not found at $AUTH_SRC — you'll need to copy it manually."
fi

# ── 4. Patch SAFE_SESSION_ID_RE ──
# This allows colons and plus signs in session IDs (needed for phone-number-based routing).
# Temporary fix until PR #16531 is merged upstream.
echo "④ Patching SAFE_SESSION_ID_RE in OpenClaw paths-*.js files ..."

PATCHED=0
for f in "$OPENCLAW_DIR"/node_modules/@openclaw/*/dist/paths-*.js "$OPENCLAW_DIR"/node_modules/.openclaw/*/dist/paths-*.js 2>/dev/null; do
  [[ -f "$f" ]] || continue
  if grep -q '\[a-z0-9._-\]' "$f"; then
    sed -i.bak 's/\[a-z0-9\._-\]/[a-z0-9._:+\\-]/g' "$f"
    echo "  ✓ Patched: $f"
    PATCHED=$((PATCHED + 1))
  fi
done

if [[ $PATCHED -eq 0 ]]; then
  echo "  ⚠ No files needed patching (already patched or paths not found)."
  echo "    If OpenClaw is installed elsewhere, patch manually:"
  echo "    Change [a-z0-9._-] → [a-z0-9._:+\\-] in paths-*.js"
else
  echo "  ✓ Patched $PATCHED file(s). (.bak backups created)"
  echo "  ℹ This patch is temporary — remove after PR #16531 is merged."
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next step: run configure.sh to generate the routing config:"
echo "  bash scripts/configure.sh $OWNER"
