# 1. Build argument (n8n version)
ARG VERSION=1.98.2

# 2. Pull official n8n image as base
FROM n8nio/n8n:${VERSION} AS runtime

# 3. Builder stage: download i18n tar
FROM alpine:latest AS builder

# install curl for download
RUN apk add --no-cache curl

WORKDIR /app

# Download and extract Chinese UI pack matching n8n version
ARG VERSION=1.98.2
RUN curl -L \
    https://github.com/other-blowsnow/n8n-i18n-chinese/releases/download/n8n%40${VERSION}/editor-ui.tar.gz \
    -o editor-ui.tar.gz \
    && tar -xzf editor-ui.tar.gz \
    && rm editor-ui.tar.gz

# 4. Final stage: install translation
FROM runtime

USER root

# Copy extracted dist into n8n-editor-ui module
COPY --from=builder /app/dist /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist

# Ensure correct ownership
RUN chown -R node:node /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist

# Switch back to non-root user
USER node

# 5. Default environment variables
# Set default UI locale to Chinese
ENV N8N_DEFAULT_LOCALE=zh-CN

# Expose default n8n port
EXPOSE 5678

# Entrypoint and CMD inherited from official image
