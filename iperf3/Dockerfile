FROM alpine:3.20

LABEL maintainer="Jerry"

# Define the version argument
ARG VERSION

# Install the specified version of iperf3
RUN apk add --no-cache iperf3=${VERSION}

# Expose the iperf3 port
EXPOSE 5201/tcp

# Set the entrypoint for the container
ENTRYPOINT ["/usr/bin/iperf3"]
