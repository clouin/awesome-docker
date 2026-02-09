# NanoBot

🐈 **nanobot** is an **ultra-lightweight** personal AI assistant inspired by [Clawdbot](https://github.com/openclaw/openclaw)

⚡️ Delivers core agent functionality in just **~4,000** lines of code — **99% smaller** than Clawdbot's 430k+ lines.

## Key Features

- 🪶 **Ultra-Lightweight**: Just ~4,000 lines of core agent code
- 🔬 **Research-Ready**: Clean, readable code that's easy to understand
- ⚡️ **Lightning Fast**: Minimal footprint means faster startup
- 💎 **Easy-to-Use**: One-click to deploy

## Docker

```bash
# Initialize config (first time only)
docker run -v ~/.nanobot:/root/.nanobot --rm jerryin/nanobot onboard

# Run gateway (connects to Telegram/WhatsApp)
docker run -d --name nanobot -v ~/.nanobot:/root/.nanobot -p 18790:18790 jerryin/nanobot gateway

# Or run a single command
docker run -v ~/.nanobot:/root/.nanobot --rm jerryin/nanobot agent -m "Hello!"
docker run -v ~/.nanobot:/root/.nanobot --rm jerryin/nanobot status
```

## License

MIT

## Links

- [GitHub](https://github.com/HKUDS/nanobot)
- [PyPI](https://pypi.org/project/nanobot-ai/)
