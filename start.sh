#!/bin/bash

set -euo pipefail

LOCKFILE="run.pid"
LOGDIR="logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$LOGDIR/run_${TIMESTAMP}.log"

mkdir -p "$LOGDIR"
# PID Lock
if [ -f "$LOCKFILE" ]; then
    if kill -0 "$(cat $LOCKFILE)" 2>/dev/null; then
        echo "[ERROR] Service already running with PID $(cat $LOCKFILE)."
        exit 1
    else
        echo "[WARN] Stale lock file found. Removing."
        rm -f "$LOCKFILE"
    fi
fi

echo $$ > "$LOCKFILE"

cleanup() {
    rm -f "$LOCKFILE"
}
trap cleanup EXIT

# Logging Setup
exec > >(tee -a "$LOGFILE") 2>&1

echo "[Swap Optimizer] Starting the path-finder service..."
echo "[INFO] Logs at $LOGFILE"

# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Swap Optimizer] Starting orchestrator..."
npm run build & npm start &
APP_PID=$!

(
  sleep 300
  pkill -f "node src/app.js"
  echo "[SWAP OPTIMIZER] Simulated crash: app.js stopped after 5 minutes." >> logs/output.log
) &


# wait app to finsih
wait $APP_PID
APP_EXIT=$?

if [ $APP_EXIT -ne 0 ]; then
    echo "[ERROR] App terminated abnormally with exit code $APP_EXIT."
    exit $APP_EXIT
else
    echo "[INFO] App exited normally."
fi
