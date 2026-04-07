# NanoBot

🐈 **nanobot** is an **ultra-lightweight** personal AI assistant inspired by [Clawdbot](https://github.com/openclaw/openclaw)

⚡️ Delivers core agent functionality in just **~4,000** lines of code — **99% smaller** than Clawdbot's 430k+ lines.

## Key Features

- 🪶 **Ultra-Lightweight**: Just ~4,000 lines of core agent code
- 🔬 **Research-Ready**: Clean, readable code that's easy to understand
- ⚡️ **Lightning Fast**: Minimal footprint means faster startup
- 💎 **Easy-to-Use**: One-click to deploy

## Docker

> ⚠️ Container runs as non-root user (UID 1000). Use absolute host paths for volume mounting.

```bash
# Create config directory
mkdir -p ./nanobot_data && chmod 777 ./nanobot_data

# Initialize config (first time only)
docker run --rm -v ./nanobot_data:/home/nanobot/.nanobot jerryin/nanobot onboard

# Or use interactive wizard
docker run --rm -v ./nanobot_data:/home/nanobot/.nanobot jerryin/nanobot onboard --wizard

# Run gateway
docker run -d --name nanobot -v ./nanobot_data:/home/nanobot/.nanobot -p 18790:18790 jerryin/nanobot gateway

# Send a message
docker run --rm -v ./nanobot_data:/home/nanobot/.nanobot jerryin/nanobot agent -m "Hello!"

# Check status
docker run --rm -v ./nanobot_data:/home/nanobot/.nanobot jerryin/nanobot status
```

## Links

- [GitHub](https://github.com/HKUDS/nanobot)
- [PyPI](https://pypi.org/project/nanobot-ai/)
- [Docs](https://nanobot.wiki)
