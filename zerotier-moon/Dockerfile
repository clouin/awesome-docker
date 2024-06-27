# Stage 1: Builder
FROM alpine:3.20 AS builder

# Define the version argument
ARG VERSION

# Install necessary packages and Rust
RUN apk add --no-cache \
    build-base \
    cmake \
    linux-headers \
    git \
    curl \
    pkgconfig \
    openssl-dev && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source "$HOME/.cargo/env"

# Clone the ZeroTierOne repository and build the project
RUN git clone --branch ${VERSION} --depth 1 https://github.com/zerotier/ZeroTierOne.git /zerotier && \
    cd /zerotier && \
    make

# Stage 2: Final image
FROM alpine:3.20

# Install necessary runtime dependencies
RUN apk add --no-cache libstdc++

# Copy the ZeroTier binaries from the builder stage
COPY --from=builder /zerotier/zerotier-one /usr/sbin/zerotier-one

# Create symbolic links for the ZeroTier CLI and ID tool
RUN ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli && \
    ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool

# Copy entrypoint script and set permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Expose the ZeroTier UDP port
EXPOSE 9993/udp

# Define a mount point for ZeroTier data
VOLUME ["/var/lib/zerotier-one"]

# Set the entrypoint for the container
ENTRYPOINT ["/entrypoint.sh"]
