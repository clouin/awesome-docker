# Step 1: Get the nanobot source
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS source

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends git

ARG VERSION=0.1.4

RUN set -eux; \
    repo="https://github.com/HKUDS/nanobot.git"; \
    tag="$(git ls-remote --tags --refs --sort=-v:refname "$repo" "v${VERSION}.post*" \
          | head -n 1 | cut -f2 | sed 's#refs/tags/##')" || true; \
    if [ -z "$tag" ]; then \
      if git ls-remote --exit-code --tags --refs "$repo" "v${VERSION}" >/dev/null; then \
        tag="v${VERSION}"; \
      else \
        echo "No tag found for v${VERSION} or v${VERSION}.post*"; \
        exit 1; \
      fi; \
    fi; \
    git clone --branch "$tag" --depth 1 "$repo" /app

# Step 2: Install dependencies and build the project
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Install Node.js 20 for the WhatsApp bridge
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg git openssh-client && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get purge -y gnupg && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (cached layer)
COPY --from=source /app/pyproject.toml /app/README.md /app/LICENSE ./
RUN mkdir -p nanobot bridge && touch nanobot/__init__.py && \
    uv pip install --system --no-cache . && \
    rm -rf nanobot bridge

# Copy the full source and install
COPY --from=source /app/nanobot/ nanobot/
COPY --from=source /app/bridge/ bridge/
RUN uv pip install --system --no-cache .

# Build the WhatsApp bridge
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

WORKDIR /app/bridge
RUN npm install && npm run build
WORKDIR /app

# Create config directory
RUN mkdir -p /root/.nanobot

# Gateway default port
EXPOSE 18790

ENTRYPOINT ["nanobot"]
CMD ["status"]