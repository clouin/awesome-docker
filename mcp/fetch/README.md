# Fetch MCP Server

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](../../LICENSE)
[![Python Version](https://img.shields.io/badge/python-3.12%2B-blue)](https://www.python.org/)
[![Docker](https://img.shields.io/badge/docker-ready-blue)](https://www.docker.com/)

A high-performance URL fetching service built with FastMCP, featuring:

- URL content fetching
- HTML to Markdown conversion
- Proxy configuration
- Docker deployment
- SSE transport protocol

## Features

- **FastMCP Integration**: SSE service based on FastMCP
- **Smart Content Processing**: Automatic HTML to Markdown conversion
- **Proxy Support**: Configurable via parameters
- **Containerization**: Multi-stage Docker build

## Quick Start

### Prerequisites

- Python 3.12+
- Docker (optional)

### Installation

```bash
pip install -r requirements.txt
```

### Run the Service

```bash
python server.py
```

### Docker Deployment

```bash
# Build image
docker build -t fetch-mcp .

# Run container
docker run -d -p 8000:8000 fetch-mcp
```

## MCP Configuration

Update your Cline configuration. You can use either the `http://localhost:8000/sse` URL, or the URL of your deployed MCP server:

```json
{
  "mcpServers": {
    "fetch": {
      "url": "http://localhost:8000/sse"
    }
  }
}
```

## License

MIT License, see [LICENSE](../../LICENSE) file
