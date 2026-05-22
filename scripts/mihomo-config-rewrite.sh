#!/usr/bin/env bash
# mihomo config rewrite script
# Called by the deployment skill to safely rewrite a Clash subscription config.
# Reads MIHOMO_SECRET from env, generates a random one if not set.
set -euo pipefail

CONFIG="${1:-/etc/mihomo/config.yaml}"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config not found: $CONFIG"
  exit 1
fi

# Backup
BACKUP="${CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG" "$BACKUP"
echo "Backup: $BACKUP"

MIHOMO_SECRET="${MIHOMO_SECRET:-$(openssl rand -hex 24)}"

python3 - << PYEOF
import yaml, pathlib, os

path = pathlib.Path("$CONFIG")
with path.open("r", encoding="utf-8", errors="ignore") as f:
    cfg = yaml.safe_load(f) or {}

cfg["mixed-port"] = 7890
cfg["allow-lan"] = False
cfg["bind-address"] = "127.0.0.1"
cfg["mode"] = cfg.get("mode") or "rule"
cfg["log-level"] = "info"
cfg["external-controller"] = "127.0.0.1:9090"
cfg["secret"] = os.environ["MIHOMO_SECRET"]
cfg["ipv6"] = False
cfg.pop("port", None)
cfg.pop("socks-port", None)
cfg["geodata-mode"] = False

if isinstance(cfg.get("tun"), dict):
    cfg["tun"]["enable"] = False

# Remove GEOIP rules that require MMDB
if "rules" in cfg:
    cfg["rules"] = [
        r for r in cfg["rules"]
        if not (isinstance(r, str) and r.startswith("GEOIP,"))
        and not (isinstance(r, dict) and r.get("type") == "GEOIP")
    ]

with path.open("w", encoding="utf-8") as f:
    yaml.safe_dump(cfg, f, allow_unicode=True, sort_keys=False)

print("Config rewritten OK")
PYEOF

chmod 600 "$CONFIG"
echo "Permissions: 600"
