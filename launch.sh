#!/bin/bash
set -e

OPENCLAW_HOME="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"
SETUP_OK="$OPENCLAW_HOME/setup-ok"

# Ensure the directory exists and has the correct permissions
mkdir -p "$OPENCLAW_HOME"
if [ "$(id -u)" -eq 0 ]; then
    chown -R node:node $OPENCLAW_HOME
fi

# Initialize
if [ ! -f "$CONFIG_FILE" ]; then
    echo "================================================================="
    echo "⚠️  OpenClaw configuration not found at: $CONFIG_FILE"
    echo "================================================================="
    echo "Please run the following command to initialize OpenClaw:"
    echo ""
    echo "  docker exec -it -u node $CONTAINER_NAME /bin/bash"
    echo "  openclaw setup --wizard"
    echo ""
    echo "The container will launch openclaw gateway with default config."
    echo "================================================================="
fi

# Launch openclaw gateway
exec gosu node openclaw gateway run \
    --bind lan \
    --allow-unconfigured \
    --verbose
