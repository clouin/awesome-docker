FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git curl && \
    rm -rf /var/lib/apt/lists/*

ARG VERSION

RUN git clone --branch v${VERSION} --depth 1 https://github.com/comfyanonymous/ComfyUI.git /ComfyUI && \
    pip install --no-cache-dir -r /ComfyUI/requirements.txt

WORKDIR /ComfyUI

RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt && \
    git clone --depth 1 https://github.com/AIGODLIKE/AIGODLIKE-ComfyUI-Translation.git custom_nodes/AIGODLIKE-ComfyUI-Translation

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl -f http://127.0.0.1:8188 || exit 1

ENTRYPOINT ["python", "main.py", "--listen", "--port", "8188"]
