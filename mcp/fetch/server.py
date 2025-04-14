from typing import Optional

import httpx
import markdownify
from bs4 import BeautifulSoup
from fastmcp import FastMCP
from pydantic import AnyUrl

mcp = FastMCP("FetchMCP-SSE")


def process_html_content(content: str) -> str:
    """Process HTML content to extract and convert to markdown"""
    soup = BeautifulSoup(content, "html.parser")
    main_content = soup.find("main") or soup.find("article") or soup.body
    if main_content:
        return markdownify.markdownify(str(main_content), heading_style="ATX", bullets="•")
    return content


async def fetch_and_process(
    url: str,
    max_length: int = 5000,
    start_index: int = 0,
    raw: bool = False,
    proxy: Optional[str] = None,
    user_agent: str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
) -> dict:
    """Fetch and process URL content

    Args:
        url: URL to fetch
        max_length: Maximum content length to return
        start_index: Start position for content
        raw: Return raw content without processing
        proxy: Proxy server URL
        user_agent: User-Agent string for HTTP requests
    """
    transport = httpx.AsyncHTTPTransport(proxy=proxy) if proxy else None

    try:
        async with httpx.AsyncClient(transport=transport) as client:
            response = await client.get(url, follow_redirects=True, headers={"User-Agent": user_agent}, timeout=30.0)
            response.raise_for_status()

            content_type = response.headers.get("content-type", "")
            content = response.text

            if not raw and ("text/html" in content_type or "<html" in content[:100].lower()):
                content = process_html_content(content)

            content_length = len(content)
            if start_index >= content_length:
                return {"error": "Start index exceeds content length", "available": content_length}

            truncated = content[start_index : start_index + max_length]
            remaining = content_length - (start_index + len(truncated))

            result = {
                "content": truncated,
                "url": url,
                "length": len(truncated),
                "remaining": remaining if remaining > 0 else 0,
            }

            if remaining > 0:
                result["next_index"] = start_index + len(truncated)

            return result

    except httpx.HTTPError as e:
        return {"error": f"HTTP error: {str(e)}"}
    except Exception as e:
        return {"error": f"Processing error: {str(e)}"}


@mcp.tool()
async def fetch(
    url: AnyUrl,
    max_length: int = 5000,
    start_index: int = 0,
    raw: bool = False,
    proxy: Optional[str] = None,
) -> dict:
    """Fetch URL content with optional processing

    Args:
        url: URL to fetch (required)
        max_length: Maximum content length to return (default: 5000)
        start_index: Start position for content (default: 0)
        raw: Return raw content without processing (default: False)
        proxy: Proxy server URL (optional), e.g. "http://proxy.example.com:8080" or "socks5://user:pass@host:port"
    """
    return await fetch_and_process(url=str(url), max_length=max_length, start_index=start_index, raw=raw, proxy=proxy)


if __name__ == "__main__":
    mcp.run(transport="sse")
