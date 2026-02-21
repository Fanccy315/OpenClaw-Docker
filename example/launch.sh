#!/bin/bash
set -e

OPENCLAW_HOME="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"

mkdir -p "$OPENCLAW_HOME"

# Initialize
if [ ! -f "$CONFIG_FILE" ]; then
    docker compose run --rm openclaw onboard --no-install-daemon
fi

# Launch openclaw gateway
docker compose up