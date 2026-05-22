#!/usr/bin/env bash
# OpenClaw + mihomo status check
# Safe for daily use — all secrets are redacted.
set -euo pipefail

redact() {
  sed -E \
    -e 's#(https?://[^/? ]+)[^ ]*#\1/***REDACTED***#g' \
    -e 's/(sk-[A-Za-z0-9._-]{6})[A-Za-z0-9._-]+([A-Za-z0-9._-]{4})/\1***REDACTED***\2/g' \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[A-Za-z0-9._-]+/\1***REDACTED***/gi' \
    -e 's/(secret["[:space:]]*[:=]["[:space:]]*)[^" ,}]+/\1***REDACTED***/gi'
}

PATH="/usr/local/bin:$HOME/.local/npm-global/bin:$PATH"

echo "===== OpenClaw Status — $(date) ====="
echo

echo "--- System ---"
hostname
lsb_release -ds 2>/dev/null || . /etc/os-release && echo "$PRETTY_NAME"
uname -a
echo

echo "--- Versions ---"
for tool in openclaw node npm docker; do
  printf "%-12s %s\n" "$tool:" "$($tool --version 2>/dev/null || echo 'N/A')"
done
printf "%-12s %s\n" "mihomo:" "$(/usr/local/bin/mihomo -v 2>/dev/null || echo 'N/A')"
echo

echo "--- mihomo ---"
systemctl status mihomo --no-pager 2>&1 | redact | head -6
ss -lntp 2>/dev/null | grep -E ':(7890|9090)' || true
echo

echo "--- OpenClaw Gateway ---"
openclaw gateway status 2>&1 | redact
echo

echo "--- Models ---"
openclaw models list 2>&1 | redact | head -15
echo

echo "--- Recent Gateway Logs ---"
journalctl --user -u openclaw-gateway.service -n 20 --no-pager 2>&1 | redact
