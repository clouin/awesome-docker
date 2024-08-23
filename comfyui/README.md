# ComfyUI

[ComfyUI](https://github.com/comfyanonymous/ComfyUI) is a powerful user interface designed for deploying and managing deep learning models. This project supports both NVIDIA GPUs and CPUs, allowing users to choose the appropriate mode based on their hardware environment.

## Quick Start

The following commands demonstrate how to run ComfyUI using Docker. Choose the command that matches your hardware setup.

### Running with NVIDIA GPU

For users with NVIDIA GPUs, you can start ComfyUI with the following command:

```
docker run -d --name=comfy --gpus all -p 8188:8188 \
  -v /path/to/models/checkpoints:/ComfyUI/models/checkpoints \
  -v /path/to/output:/ComfyUI/output \
  registry.cn-hangzhou.aliyuncs.com/openrepo/comfyui
```

### Running with CPU

If you do not have an NVIDIA GPU, you can run ComfyUI in CPU mode with the following command:

```
docker run -d --name=comfy-cpu -p 8188:8188 \
  -v /path/to/models/checkpoints:/ComfyUI/models/checkpoints \
  -v /path/to/output:/ComfyUI/output \
  registry.cn-hangzhou.aliyuncs.com/openrepo/comfyui --cpu
```

## Deployment with Docker Compose

If you prefer to manage and deploy ComfyUI using Docker Compose, refer to the configurations below.

### NVIDIA GPU Configuration

Use the following Docker Compose configuration to run ComfyUI in an NVIDIA GPU environment:

```
version: '3.8'
services:
  comfy:
    image: registry.cn-hangzhou.aliyuncs.com/openrepo/comfyui
    restart: unless-stopped
    ports:
      - '8188:8188'
    volumes:
      - ./models/checkpoints:/ComfyUI/models/checkpoints
      - ./output:/ComfyUI/output
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### CPU Configuration

If you are running in a CPU environment, use the following Docker Compose configuration:

```
version: '3.8'
services:
  comfy-cpu:
    image: registry.cn-hangzhou.aliyuncs.com/openrepo/comfyui
    restart: unless-stopped
    ports:
      - '8188:8188'
    volumes:
      - ./models/checkpoints:/ComfyUI/models/checkpoints
      - ./output:/ComfyUI/output
    command: --cpu
```

## Volume Mounts

- `models/checkpoints`: Directory to store models. Place your model files here, and they will be automatically loaded when the container starts.
- `output`: Directory for outputs. The generated results will be saved here.
