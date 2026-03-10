# ZeroClaw 🦀

**ZeroClaw** is an ultra-lightweight AI assistant runtime built in 100% Rust, designed to run on $10 hardware with less than 5MB RAM — 99% less memory than OpenClaw!

## Key Features

- ⚡️ **Ultra-Lightweight**: < 5MB RAM usage, ~8.8MB binary size
- 🏎️ **Lightning Fast**: < 10ms cold start on 0.8GHz edge hardware
- 🔒 **Secure by Default**: Pairing, sandboxing, allowlists, workspace scoping
- 🔄 **Fully Swappable**: Providers, channels, tools, memory via trait-driven architecture
- 🌐 **Cross-Platform**: ARM, x86, RISC-V support

## Docker

```bash
# Create data directory
mkdir -p ~/zeroclaw-data
chmod 777 ~/zeroclaw-data

# Initialize config (first time only)
docker run -v ~/zeroclaw-data:/zeroclaw-data --rm jerryin/zeroclaw onboard
# Or interactive wizard
docker run -it -v ~/zeroclaw-data:/zeroclaw-data --rm jerryin/zeroclaw onboard --interactive

# Start full autonomous runtime
docker run -d --name zeroclaw -v ~/zeroclaw-data:/zeroclaw-data -p 42617:42617 jerryin/zeroclaw daemon

# Chat
docker run -v ~/zeroclaw-data:/zeroclaw-data --rm jerryin/zeroclaw agent -m "Hello!"

# Check status
docker run -v ~/zeroclaw-data:/zeroclaw-data --rm jerryin/zeroclaw status
```

## Architecture

| Subsystem     | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| **AI Models** | OpenAI, Anthropic, Ollama, vLLM, llama.cpp, custom endpoints |
| **Channels**  | CLI, Telegram, Discord, Slack, WhatsApp, Matrix, and more    |
| **Memory**    | SQLite, PostgreSQL, Lucid, Markdown, or none                 |
| **Tools**     | shell, file, memory, git, browser, http_request, and more    |
| **Runtime**   | Native or Docker sandboxed execution                         |

## License

Dual-licensed under MIT or Apache 2.0. See [GitHub repository](https://github.com/zeroclaw-labs/zeroclaw) for details.

## Links

- [GitHub](https://github.com/zeroclaw-labs/zeroclaw)
- [Website](https://zeroclawlabs.ai)
