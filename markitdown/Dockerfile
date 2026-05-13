FROM python:3.13-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV FFMPEG_PATH=/usr/bin/ffmpeg

#  Install dependency
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg exiftool git

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG VERSION=0.1.1

RUN git clone --branch v${VERSION} --depth 1 https://github.com/microsoft/markitdown.git /app && \
    pip --no-cache-dir install \
    /app/packages/markitdown[all] \
    /app/packages/markitdown-sample-plugin

# Default USERID and GROUPID
ARG USERID=nobody
ARG GROUPID=nogroup

USER $USERID:$GROUPID

ENTRYPOINT [ "markitdown" ]