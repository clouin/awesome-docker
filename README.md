# Awesome Docker

Welcome to the **Awesome Docker** project! This repository contains a collection of Docker images, each focusing on different services. Below you'll find an overview of each module, including supported architectures and links to more details.

## Module Overview

| Module                             | Supported Architectures                                                                                   | Docker Pulls                                                            |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [cloudflare-warp][cloudflare-warp] | `linux/amd64`, `linux/arm64`                                                                              | [![Docker Pulls][cloudflare-warp-docker-pulls]][cloudflare-warp-docker] |
| [iperf3][iperf3]                   | `linux/amd64`, `linux/arm64`, `linux/riscv64`, `linux/ppc64le`, `linux/s390x`, `linux/arm/v7`             | [![Docker Pulls][iperf3-docker-pulls]][iperf3-docker]                   |
| [vlmcsd][vlmcsd]                   | `linux/amd64`, `linux/arm64`, `linux/ppc64le`, `linux/s390x`, `linux/arm/v7`, `linux/arm/v6`, `linux/386` | [![Docker Pulls][vlmcsd-docker-pulls]][vlmcsd-docker]                   |
| [xray][xray]                       | `linux/amd64`, `linux/arm64`, `linux/ppc64le`, `linux/s390x`, `linux/arm/v7`                              | [![Docker Pulls][xray-docker-pulls]][xray-docker]                       |
| [zerotier][zerotier]               | `linux/amd64`, `linux/arm64`                                                                              | [![Docker Pulls][zerotier-docker-pulls]][zerotier-docker]               |
| [zerotier-moon][zerotier-moon]     | `linux/amd64`, `linux/arm64`                                                                              | [![Docker Pulls][zerotier-moon-docker-pulls]][zerotier-moon-docker]     |

## License

Licensed under the MIT License. See the [LICENSE][license] file for details.

[cloudflare-warp]: ./cloudflare-warp/README.md
[cloudflare-warp-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/cloudflare-warp
[cloudflare-warp-docker]: https://hub.docker.com/r/jerryin/cloudflare-warp
[iperf3]: ./iperf3/README.md
[iperf3-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/iperf3
[iperf3-docker]: https://hub.docker.com/r/jerryin/iperf3
[vlmcsd]: ./vlmcsd/README.md
[vlmcsd-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/vlmcsd
[vlmcsd-docker]: https://hub.docker.com/r/jerryin/vlmcsd
[xray]: ./xray/README.md
[xray-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/xray
[xray-docker]: https://hub.docker.com/r/jerryin/xray
[zerotier]: ./zerotier/README.md
[zerotier-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/zerotier
[zerotier-docker]: https://hub.docker.com/r/jerryin/zerotier
[zerotier-moon]: ./zerotier-moon/README.md
[zerotier-moon-docker-pulls]: https://img.shields.io/docker/pulls/jerryin/zerotier-moon
[zerotier-moon-docker]: https://hub.docker.com/r/jerryin/zerotier-moon
[license]: ./LICENSE
