#!/bin/bash
# AI Handle fleet heartbeat — run this on any machine that has cloned an AI Handle
# repo (e.g. AI-Handle-Agents-OS / Specialized Team box). Every run commits and
# pushes this device's own status file. Omar reads last-commit-time on
# devices/<DEVICE_ID>.json to know if a device is online and what it's running.
#
# Setup (once per device):
#   1. git clone https://github.com/Omar-Abuzaid-stack/ai-handle-fleet-status.git
#   2. cd ai-handle-fleet-status
#   3. export DEVICE_ID="specialized-team-win"        # unique name for this device
#   4. export APP_REPO_PATH="/path/to/AI-Handle-Agents-OS"   # the repo this device runs
#   5. ./heartbeat.sh                                  # test once
#   6. cron every 5 min: */5 * * * * cd /path/to/ai-handle-fleet-status && ./heartbeat.sh
#
set -euo pipefail
cd "$(dirname "$0")"

DEVICE_ID="${DEVICE_ID:?set DEVICE_ID to a unique name for this machine}"
APP_REPO_PATH="${APP_REPO_PATH:-}"
OUT="devices/${DEVICE_ID}.json"

git pull --quiet --rebase origin main 2>/dev/null || true
mkdir -p devices

APP_COMMIT="unknown"
APP_BRANCH="unknown"
if [ -n "$APP_REPO_PATH" ] && [ -d "$APP_REPO_PATH/.git" ]; then
  APP_COMMIT=$(git -C "$APP_REPO_PATH" rev-parse --short HEAD 2>/dev/null || echo unknown)
  APP_BRANCH=$(git -C "$APP_REPO_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
fi

cat > "$OUT" <<EOF
{
  "device_id": "$DEVICE_ID",
  "hostname": "$(hostname)",
  "platform": "$(uname -s)",
  "app_repo_commit": "$APP_COMMIT",
  "app_repo_branch": "$APP_BRANCH",
  "last_seen_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

git add "$OUT"
if ! git diff --cached --quiet; then
  git commit --quiet -m "heartbeat: $DEVICE_ID $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push --quiet origin main
  echo "[heartbeat] pushed $DEVICE_ID"
else
  echo "[heartbeat] no change for $DEVICE_ID"
fi
