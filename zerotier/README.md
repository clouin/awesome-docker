# ZeroTier

## Description

ZeroTier is a lightweight container based on Alpine Linux, containing ZeroTier One. It is designed to run ZeroTier One as a service on container-oriented distributions like Fedora CoreOS, although it should work on any Linux system with Docker or Podman.

## Usage

```bash
docker run --name zerotier-one -d --restart always --device=/dev/net/tun --net=host --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN -v /var/lib/zerotier-one:/var/lib/zerotier-one jerryin/zerotier
```

This command runs `jerryin/zerotier` in a container with special network admin permissions and access to the host's network stack (no network isolation), as well as `/dev/net/tun` for creating tun/tap devices. This enables the container to create zt# interfaces on the host, similar to how ZeroTier One running directly on the host would operate.
The command also mounts `/var/lib/zerotier-one` to `/var/lib/zerotier-one` inside the container. This allows the ZeroTier service to persist its state across restarts of the container. If you omit this mount, a new identity will be generated every time the container restarts. You can choose to store the actual data in a different location if desired.
To join a ZeroTier network, you can use the following command:

```bash
docker exec zerotier-one zerotier-cli join 8056c2e21c000001
```

Alternatively, you can create an empty file with the network ID as its name:

```
/var/lib/zerotier-one/networks.d/8056c2e21c000001.conf
```
