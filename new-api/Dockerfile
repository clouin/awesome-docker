# Step 1: Get the new-api source
FROM debian:bookworm-slim AS source

WORKDIR /code

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git

ARG VERSION=1.0.0-rc.11
RUN git clone --branch v${VERSION} --depth 1 https://github.com/QuantumNous/new-api.git /code

FROM oven/bun:1 AS builder

WORKDIR /build/web
COPY --from=source /code/web/package.json /code/web/bun.lock ./
COPY --from=source /code/web/default/package.json ./default/package.json
COPY --from=source /code/web/classic/package.json ./classic/package.json
RUN bun install --frozen-lockfile
COPY --from=source /code/web/default ./default
COPY --from=source /code/VERSION /build/VERSION
RUN cd default && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat /build/VERSION) bun run build

FROM oven/bun:1 AS builder-classic

WORKDIR /build/web
COPY --from=source /code/web/package.json /code/web/bun.lock ./
COPY --from=source /code/web/default/package.json ./default/package.json
COPY --from=source /code/web/classic/package.json ./classic/package.json
RUN bun install --frozen-lockfile
COPY --from=source /code/web/classic ./classic
COPY --from=source /code/VERSION /build/VERSION
RUN cd classic && VITE_REACT_APP_VERSION=$(cat /build/VERSION) bun run build

FROM golang:1.26.1-alpine AS builder2
ENV GO111MODULE=on CGO_ENABLED=0

ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64}
ENV GOEXPERIMENT=greenteagc

WORKDIR /build

COPY --from=source /code/go.mod /code/go.sum ./
RUN go mod download

COPY --from=source /code .
COPY --from=builder /build/web/default/dist ./web/default/dist
COPY --from=builder-classic /build/web/classic/dist ./web/classic/dist
RUN go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(cat VERSION)'" -o new-api

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata libasan8 wget \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

COPY --from=builder2 /build/new-api /
COPY --from=source /code/LICENSE /code/NOTICE /code/THIRD-PARTY-LICENSES.md /licenses/
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/new-api"]