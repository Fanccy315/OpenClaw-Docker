FROM node:22-bookworm

RUN corepack enable

# Install deps
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential procps curl file git \
    python3 \
    unzip \
    websockify \
    ca-certificates
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Update npm
RUN npm install -g npm@latest

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install homebrew
RUN useradd --create-home linuxbrew
USER linuxbrew
RUN NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
USER root
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Install openclaw
RUN npm install -g openclaw@latest
RUN npm install -g playwright && npx playwright install chromium --with-deps
RUN npm install -g playwright-extra puppeteer-extra-plugin-stealth

# Install plugin-Xueheng-Li/openclaw-wechat
RUN mkdir -p /home/node/.openclaw/extensions && \
    cd /home/node/.openclaw/extensions && \
    git clone https://github.com/Xueheng-Li/openclaw-wechat.git && \
    cd openclaw-wechat && \
    npm install && \
    openclaw plugins install -l .

EXPOSE 18789 18790
ENTRYPOINT ["/bin/bash", "/usr/local/bin/launch.sh"]
CMD ["node", "openclaw", "gateway", "run", "--verbose"]
