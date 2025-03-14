# Cloudflare Warp

This project provides a Docker image for running Cloudflare Warp in proxy mode.

## Usage

The SOCKS proxy is exposed on port `1080`.
You can use the following environment variables:

- `FAMILIES_MODE`: Optional values are `off`, `malware`, and `full`. (Default: `off`)
- `TUNNEL_PROTOCOL`: Optional values are `WireGuard`, and `MASQUE`. (Default: `WireGuard`)
- `WARP_LICENSE`: Enter your WARP+ license key. (You can get a free WARP+ license from this Telegram bot: [https://t.me/generatewarpplusbot](https://t.me/generatewarpplusbot))

### Running

```
docker run -d --name=cloudflare-warp -p 1080:1080 -e WARP_LICENSE=xxxxxxxx-xxxxxxxx-xxxxxxxx -v ${PWD}/warp:/var/lib/cloudflare-warp --restart=unless-stopped jerryin/cloudflare-warp
```

#### Use `warp-cli` to control your connection

```
docker exec cloudflare-warp warp-cli --accept-tos status

Status update: Connected
Success
```

#### Verify Warp by accessing this URL

```
curl -x socks5://127.0.0.1:1080 -sL https://cloudflare.com/cdn-cgi/trace | grep warp

warp=plus
```

#### Find your Warp IP location

```
curl -s -x socks5://127.0.0.1:1080 https://ipinfo.io
```

#### Speed test

```
curl -x socks5://127.0.0.1:1080 https://speed.cloudflare.com/__down?bytes=1000000000 > /dev/null
```

### Using docker-compose

```
version: '3.8'

services:
  warp:
    image: jerryin/cloudflare-warp
    container_name: cloudflare-warp
    restart: unless-stopped
    ports:
      - '1080:1080'
    environment:
      WARP_LICENSE: xxxxxxxx-xxxxxxxx-xxxxxxxx
      FAMILIES_MODE: off
    volumes:
      - ./warp:/var/lib/cloudflare-warp
```
