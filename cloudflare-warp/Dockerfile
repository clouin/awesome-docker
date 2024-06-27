FROM debian:bullseye-slim

# Install necessary packages and Cloudflare WARP
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	curl \
	gnupg \
	ca-certificates \
	socat \
	lsb-release && \
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends cloudflare-warp && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set permissions
COPY --chmod=755 entrypoint.sh /usr/local/bin/

# Set environment variables for WARP
ENV WARP_LICENSE=
ENV FAMILIES_MODE=off

# Expose port 1080 for TCP traffic
EXPOSE 1080/tcp

# Define a mount point for Cloudflare WARP data
VOLUME ["/var/lib/cloudflare-warp"]

# Set the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
