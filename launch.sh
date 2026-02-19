#!/bin/bash

set -e
cleanup() {
    echo "Stopping..."
    if [ -n "$GATEWAY_PID" ]; then
        kill -TERM "$GATEWAY_PID" 2>/dev/null || true
        wait "$GATEWAY_PID" 2>/dev/null || true
    fi
    exit 0
}
trap cleanup SIGTERM SIGINT SIGQUIT

# Ensure the directory exists and has the correct permissions
OPENCLAW_HOME="/home/node/.openclaw"
mkdir -p "$OPENCLAW_HOME"
if [ "$(id -u)" -eq 0 ]; then
    chown -R node:node /home/node/.openclaw
fi

# Launch openclaw gateway
gosu node openclaw gateway run \
    --allow-unconfigured \
    --verbose &
GATEWAY_PID=$!

echo "=== OpenClaw Gateway Launched (PID: $GATEWAY_PID) ==="
wait "$GATEWAY_PID"
EXIT_CODE=$?
echo "=== OpenClaw Gateway Exited ($EXIT_CODE) ==="
exit $EXIT_CODE
