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

OPENCLAW_HOME="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"
# Ensure the directory exists and has the correct permissions
mkdir -p "$OPENCLAW_HOME"
if [ "$(id -u)" -eq 0 ]; then
    chown -R node:node $OPENCLAW_HOME
    chmod g+w /home/linuxbrew
fi

# Initialize
if [ ! -f "$CONFIG_FILE" ]; then
    echo "================================================================="
    echo "⚠️  OpenClaw configuration not found at: $CONFIG_FILE"
    echo "================================================================="
    echo "Please run the following command to initialize OpenClaw:"
    echo ""
    echo "  docker exec -it -u node $CONTAINER_NAME /bin/bash -c 'openclaw onboard'"
    echo ""
    echo "The container will continue running and launch openclaw gateway."
    echo "================================================================="
fi

# Launch openclaw gateway
exec gosu node openclaw gateway run \
    --bind "$OPENCLAW_GATEWAY_BIND" \
    --port "$OPENCLAW_GATEWAY_PORT" \
    --allow-unconfigured \
    --verbose &
GATEWAY_PID=$!

echo "=== OpenClaw Gateway Launched (PID: $GATEWAY_PID) ==="
wait "$GATEWAY_PID"
EXIT_CODE=$?
echo "=== OpenClaw Gateway Exited ($EXIT_CODE) ==="
exit $EXIT_CODE
