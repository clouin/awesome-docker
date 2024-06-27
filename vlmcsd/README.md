# vlmcsd - A Fully Microsoft Compatible KMS Server

`vlmcsd` is a fully Microsoft compatible Key Management Service (KMS) server that provides product activation services to clients. It is designed to be a drop-in replacement for a Microsoft KMS server (Windows computer with KMS key entered). The server currently supports KMS protocol versions 4, 5, and 6.

## Features

- Fully compatible with Microsoft KMS protocol versions 4, 5, and 6.
- Runs on POSIX compatible operating systems.
- Requires only a basic C library with BSD-style sockets API and either `fork` or `pthreads`.
- Suitable for most embedded systems such as routers, NASes, mobile phones, tablets, TVs, and set-top boxes.
- Some efforts have been made to ensure compatibility with Windows.

## Quick Start

To get started with `vlmcsd`, you can use the following Docker command:

```
docker run -d -p 1688:1688 --name vlmcsd --restart=unless-stopped jerryin/vlmcsd
```

**Note**: Ensure that the TCP port number `1688` is opened in your firewall to allow traffic.

## Getting Started

### Prerequisites

- Docker installed on your system.

### Installation

1. Pull the Docker image:

```
docker pull jerryin/vlmcsd
```

2. Run the Docker container:

```
docker run -d -p 1688:1688 --name vlmcsd --restart=unless-stopped jerryin/vlmcsd
```

### Usage

Once the container is running, `vlmcsd` will start listening on TCP port `1688` for incoming KMS client requests.

## Acknowledgments

Thanks to all the contributors who have made this project possible.
