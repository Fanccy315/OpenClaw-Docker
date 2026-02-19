FROM node:22-bookworm

RUN corepack enable

WORKDIR /app
# Install deps
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    git \
    python3 \
    unzip \
    gosu \
    websockify \
    ca-certificates
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Update npm
RUN npm install -g npm@latest

# Install openclaw
RUN npm install -g openclaw@latest opencode-ai@latest
RUN npm install -g playwright && npx playwright install chromium --with-deps
RUN npm install -g playwright-extra puppeteer-extra-plugin-stealth

# Install homebrew, skip root check
RUN touch /.dockerenv 
RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
RUN rm /.dockerenv 

# Copy launch script
COPY ./launch.sh /usr/local/bin/launch.sh
RUN chmod +x /usr/local/bin/launch.sh

# Allow non-root user to write temp files during runtime/tests.
RUN chown -R node:node /app


WORKDIR /home/node
# Security hardening: Run as non-root user
# The node:22-bookworm image includes a 'node' user (uid 1000)
# This reduces the attack surface by preventing container escape via root privileges
USER node

# Install plugin-Xueheng-Li/openclaw-wechat
RUN mkdir -p /home/node/.openclaw/extensions && \
    cd /home/node/.openclaw/extensions && \
    git clone https://github.com/Xueheng-Li/openclaw-wechat.git && \
    cd openclaw-wechat && \
    npm install && \
    openclaw plugins install -l .

EXPOSE 18789 18790
ENTRYPOINT ["/bin/bash", "/usr/local/bin/launch.sh"]
