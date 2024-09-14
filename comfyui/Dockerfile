FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# Set non-interactive mode to prevent interactive prompts during package installation
# Set PIP_PREFER_BINARY to prioritize binary wheels for faster installations
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1

# Update the package list and install required packages
RUN apt-get update && apt-get install -y git curl && \
    rm -rf /var/lib/apt/lists/*

# Define a build argument for the version to be used when cloning the ComfyUI repository
ARG VERSION

# Clone the ComfyUI repository from the specified version tag and install its Python dependencies
RUN git clone --branch v${VERSION} --depth 1 https://github.com/comfyanonymous/ComfyUI.git /ComfyUI && \
    pip install -r /ComfyUI/requirements.txt

# Set the working directory to the ComfyUI directory
WORKDIR /ComfyUI

# Copy the custom node installation script into the container
COPY install_custom_nodes.sh /ComfyUI/install_custom_nodes.sh

# Make the custom node installation script executable
RUN chmod +x /ComfyUI/install_custom_nodes.sh

# Run the custom node installation script to install additional nodes
RUN /ComfyUI/install_custom_nodes.sh

# Expose port 8188 to allow external access to the application
EXPOSE 8188

# Add a health check that runs every 30 seconds with a 30-second timeout, and retries 3 times on failure.
# It checks if the service on http://127.0.0.1:8188 is available, otherwise exits with an error.
HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl -f http://127.0.0.1:8188 || exit 1

# Set the default command to start the application with the listen mode enabled on port 8188
ENTRYPOINT ["python", "main.py", "--listen", "--port", "8188"]
