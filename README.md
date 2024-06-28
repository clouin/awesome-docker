# Awesome Docker

This project contains a collection of Docker images, each focusing on different services.

## Module Overview

### Cloudflare Warp

Cloudflare Warp provides a Docker image for running in proxy mode.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`

#### Usage

The SOCKS proxy is exposed on port `1080`.

To run the container:

```bash
docker run -d --name=cloudflare-warp -p 1080:1080 -e WARP_LICENSE=xxxxxxxx-xxxxxxxx-xxxxxxxx -v ${PWD}/warp:/var/lib/cloudflare-warp --restart=unless-stopped jerryin/cloudflare-warp
```

Control the connection using `warp-cli`:

```
docker exec cloudflare-warp warp-cli --accept-tos status
```

For more details, refer to [cloudflare-warp/README.md](./cloudflare-warp/README.md).

### Iperf3

Iperf3 is a Docker image based on Alpine Linux for network performance testing.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`,`linux/riscv64`,`linux/ppc64le`,`linux/s390x`,`linux/arm/v7`

#### Usage

To display Iperf3 options:

```
docker run --rm jerryin/iperf3 --help
```

Start an Iperf3 server:

```
docker run --name=iperf3-server -it --rm -p 5201:5201 jerryin/iperf3 -s
```

For more details, refer to [iperf3/README.md](./iperf3/README.md).

### vlmcsd

`vlmcsd` is a fully compatible Microsoft KMS server for product activation.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`,`linux/ppc64le`,`linux/s390x`,`linux/arm/v7`,`linux/arm/v6`,`linux/386`

#### Usage

Run the server:

```
docker run -d -p 1688:1688 --name vlmcsd --restart=unless-stopped jerryin/vlmcsd
```

For more details, refer to [vlmcsd/README.md](./vlmcsd/README.md).

### ZeroTier

ZeroTier is a lightweight container based on Alpine Linux containing ZeroTier One.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`

#### Usage

Run the container:

```
docker run --name zerotier-one -d --restart always --device=/dev/net/tun --net=host --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN -v /var/lib/zerotier-one:/var/lib/zerotier-one jerryin/zerotier
```

For more details, refer to [zerotier/README.md](./zerotier/README.md).

### ZeroTier Moon

ZeroTier Moon is a Docker image that allows easy creation of a ZeroTier moon.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`

#### Usage

Run the container:

```
docker run --name zerotier-moon -d --restart always -p 9993:9993/udp jerryin/zerotier-moon -4 1.2.3.4
```

For more details, refer to [zerotier-moon/README.md](./zerotier-moon/README.md).

### Xray

[Xray](https://github.com/XTLS/Xray-core) is a platform for building proxies to bypass network restrictions and protect privacy.

#### Reference

Supported Architectures: `linux/amd64`,`linux/arm64`,`linux/ppc64le`,`linux/s390x`,`linux/386`,`linux/arm/v7`,`linux/arm/v6`

#### Usage

Before starting the container, ensure you create a configuration file `/etc/xray/config.json` on the host system. Here's an example configuration:

```
{
  "inbounds": [{
    "port": 9000,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "1eb6e917-774b-4a84-aff6-b058577c60a5",
          "level": 1,
          "alterId": 64
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
```

To start a container running Xray as a server on port `9000`, execute:

```
docker run -d -p 9000:9000 --name xray --restart=always -v /etc/xray:/etc/xray jerryin/xray
```

Ensure the port in the configuration matches the one opened in your firewall.
For more details, refer to [Xray-core project](https://github.com/XTLS/Xray-core) and [Xray-examples](https://github.com/XTLS/Xray-examples).

## License

Licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
