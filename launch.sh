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
mkdir -p "$OPENCLAW_HOME"
if [ "$(id -u)" -eq 0 ]; then
    chown -R node:node /home/node/.openclaw
fi

# Initialize
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "================================================================="
    echo "⚠️  OpenClaw configuration not found at: $CONFIG_FILE"
    echo "================================================================="
    echo "Please run the following command to initialize OpenClaw:"
    echo ""
    echo "  docker exec -it -u node $CONTAINER_NAME /bin/bash -c 'openclaw onboard'"
    echo ""
    echo "After completing the configuration, return here and type 'yes' to continue:"
    echo "================================================================="
    
    while true; do
        read -p "Have you completed the configuration? (yes/No): " CONFIRM
        case $CONFIRM in
            [Yy][Ee][Ss]|[Yy])
                echo "Checking configuration file..."
                if [ -f "$CONFIG_FILE" ]; then
                    echo "✅ Configuration file found. Starting gateway..."
                    break
                else
                    echo "❌ Configuration file still not found at $CONFIG_FILE"
                    echo "Please make sure you have completed the 'openclaw onboard' setup."
                fi
                ;;
            *)
                echo "Waiting for you to complete the configuration..."
                ;;
        esac
    done
fi

# Launch openclaw gateway
gosu node openclaw gateway run --verbose &
GATEWAY_PID=$!

echo "=== OpenClaw Gateway Launched (PID: $GATEWAY_PID) ==="
wait "$GATEWAY_PID"
EXIT_CODE=$?
echo "=== OpenClaw Gateway Exited ($EXIT_CODE) ==="
exit $EXIT_CODE
