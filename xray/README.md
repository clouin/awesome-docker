# Xray Core Docker Image

[Xray-core](https://github.com/XTLS/Xray-core) is a platform for building proxies to bypass network restrictions. This Docker image provides a lightweight, secure proxy solution with geolocation data support.

## Features

- Based on distroless static image for minimal footprint
- Includes geoip.dat and geosite.dat for routing rules
- Multi-architecture support
- Configurable via JSON configuration files
- Volume support for custom configurations and logs

## Usage

```bash
docker run -d \
  --name xray \
  -p 8080:8080 \
  -v /path/to/config:/usr/local/etc/xray \
  jerryin/xray:latest
```

## Configuration

The image includes default empty configuration files:

- `00_log.json` - Logging configuration
- `01_api.json` - API settings
- `02_dns.json` - DNS configuration
- `03_routing.json` - Routing rules
- `04_policy.json` - Policy settings
- `05_inbounds.json` - Inbound connections
- `06_outbounds.json` - Outbound connections
- `07_transport.json` - Transport settings
- `08_stats.json` - Statistics
- `09_reverse.json` - Reverse proxy settings

Mount your custom configuration directory to `/usr/local/etc/xray` to override defaults.

## Volumes

- `/usr/local/etc/xray` - Configuration files
- `/var/log/xray` - Log files

## Environment Variables

- `TZ` - Timezone (default: Etc/UTC)
