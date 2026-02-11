# New-API

New-API is an innovative AI gateway interface that provides a unified API for accessing multiple AI models.

## Key Features

- 🚀 **Unified Interface**: Single API endpoint for multiple AI providers
- 💪 **Multi-Provider Support**: OpenAI, Anthropic, Google, and more
- 🔐 **Secure**: Built-in authentication and rate limiting
- 🎨 **Modern UI**: Beautiful web interface for easy management
- 📦 **Easy Deployment**: Docker support for quick setup

## Docker

```bash
# Run with default configuration
docker run -d --name new-api -p 3000:3000 jerryin/new-api

# With custom configuration
docker run -d --name new-api -p 3000:3000 -v ${PWD}/config.json:/data/config.json jerryin/new-api
```

## License

MIT

## Links

- [GitHub](https://github.com/QuantumNous/new-api)
