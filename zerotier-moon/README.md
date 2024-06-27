# ZeroTier Moon

ZeroTier Moon is a Docker image that allows you to easily create a ZeroTier moon in one step.

## Usage

### Pull the Image

```bash
docker pull jerryin/zerotier-moon
```

### Start a Container

```bash
docker run --name zerotier-moon -d --restart always -p 9993:9993/udp jerryin/zerotier-moon -4 1.2.3.4
```

Replace `1.2.3.4` with the IP address of your moon.
To display your moon's ID, run:

```bash
docker logs zerotier-moon
```

**Note:** When you create a new container, a new moon ID will be generated. To persist the identity when creating a new container, see **Mount ZeroTier Conf Folder** below.

## Advanced Usage

### Manage ZeroTier

```bash
docker exec zerotier-moon zerotier-cli
```

### Mount ZeroTier Conf Folder

```bash
docker run --name zerotier-moon -d -p 9993:9993/udp -v /var/lib/zerotier-one:/var/lib/zerotier-one jerryin/zerotier-moon -4 1.2.3.4
```

This will mount `/var/lib/zerotier-one` to `/var/lib/zerotier-one` inside the container, allowing your ZeroTier moon to preserve the same moon ID. If you don't do this, a new moon ID will be generated when you start a new container.

### IPv6 Support

```bash
docker run --name zerotier-moon -d -p 9993:9993/udp jerryin/zerotier-moon -4 1.2.3.4 -6 2001:abcd:abcd::1
```

Replace `1.2.3.4` and `2001:abcd:abcd::1` with your moon's IPv4 and IPv6 addresses, respectively. You can remove the `-4` option in a pure IPv6 environment.

### Docker Compose

```yaml
version: '3'

services:
  zerotier-moon:
    image: jerryin/zerotier-moon
    restart: always
    container_name: zerotier-moon
    ports:
      - '9993:9993/udp'
    volumes:
      - ./zerotier-one:/var/lib/zerotier-one
    command: -4 1.2.3.4
```
