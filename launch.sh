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
    echo ""
    echo "Please run the following command to initialize OpenClaw:"
    echo ""
    echo "  docker exec -it -u node $CONTAINER_NAME /bin/bash -c 'openclaw setup --wizard'"
    echo ""
    echo "After completing the setup, create the marker file to continue:"
    echo ""
    echo "  touch $HOME/.openclaw/setup-ok"
    echo ""
    echo "================================================================="

    # Wait for setup-ok file to be created
    while [ ! -f "$SETUP_OK" ]; do
        sleep 1
    done
    echo "Setup marker file detected, proceeding to launch gateway..."
    rm "$SETUP_OK_FILE"
fi

# Launch openclaw gateway
exec gosu node openclaw gateway run --verbose
