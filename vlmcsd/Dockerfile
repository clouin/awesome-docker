# Stage 1: Build the vlmcsd binary
FROM alpine:3.20 as builder

# Set working directory
WORKDIR /root

# Install dependencies, clone the repository, and build the project
RUN apk add --no-cache git make build-base && \
    git clone --branch master --single-branch https://github.com/Wind4/vlmcsd.git && \
    cd vlmcsd/ && \
    make

# Stage 2: Create the final image
FROM alpine:3.20

# Set working directory
WORKDIR /root/

# Copy the vlmcsd binary from the builder stage
COPY --from=builder /root/vlmcsd/bin/vlmcsd /usr/bin/vlmcsd

# Expose the KMS port
EXPOSE 1688/tcp

# Command to run vlmcsd
CMD [ "/usr/bin/vlmcsd", "-D", "-d" ]
