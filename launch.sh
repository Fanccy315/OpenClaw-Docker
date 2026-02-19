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

# Launch openclaw gateway
openclaw gateway run \
    --bind "$OPENCLAW_GATEWAY_BIND" \
    --port "$OPENCLAW_GATEWAY_PORT" \
    --token "$OPENCLAW_GATEWAY_TOKEN" &
GATEWAY_PID=$!

echo "=== OpenClaw Gateway Launched (PID: $GATEWAY_PID) ==="
wait "$GATEWAY_PID"
EXIT_CODE=$?
echo "=== OpenClaw Gateway Exited (退出码: $EXIT_CODE) ==="
exit $EXIT_CODE
