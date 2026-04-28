# Step 1: Get the new-api source
FROM debian:bookworm-slim AS source

WORKDIR /code

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git

ARG VERSION=0.13.2
RUN git clone --branch v${VERSION} --depth 1 https://github.com/QuantumNous/new-api.git /code

FROM oven/bun:1 AS builder

WORKDIR /build
COPY --from=source /code/web/default/package.json .
COPY --from=source /code/web/default/bun.lock .
RUN bun install
COPY --from=source /code/web/default .
COPY --from=source /code/VERSION .
RUN DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

FROM oven/bun:1 AS builder-classic

WORKDIR /build
COPY --from=source /code/web/classic/package.json .
COPY --from=source /code/web/classic/bun.lock .
RUN bun install
COPY --from=source /code/web/classic .
COPY --from=source /code/VERSION .
RUN VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

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
COPY --from=builder /build/dist ./web/default/dist
COPY --from=builder-classic /build/dist ./web/classic/dist
RUN go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(cat VERSION)'" -o new-api

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata libasan8 wget \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

COPY --from=builder2 /build/new-api /
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/new-api"]