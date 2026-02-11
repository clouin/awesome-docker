# Step 1: Get the new-api source
FROM debian:bookworm-slim AS source

WORKDIR /new-api

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git

ARG VERSION=0.10.8
RUN git clone --branch v${VERSION} --depth 1 https://github.com/QuantumNous/new-api.git /new-api

FROM oven/bun:latest AS builder

WORKDIR /build
COPY --from=source /new-api/web/package.json .
COPY --from=source /new-api/web/bun.lock .
RUN bun install
COPY --from=source /new-api/web .
COPY --from=source /new-api/VERSION .
RUN DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat VERSION) bun run build

FROM golang:alpine AS builder2
ENV GO111MODULE=on CGO_ENABLED=0

ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64}
ENV GOEXPERIMENT=greenteagc

WORKDIR /build

COPY --from=source /new-api/go.mod /new-api/go.sum ./
RUN go mod download

COPY --from=source /new-api .
COPY --from=builder /build/dist ./web/dist
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