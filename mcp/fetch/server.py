import os
from typing import Optional

import httpx
import markdownify
from bs4 import BeautifulSoup
from fastmcp import FastMCP
from pydantic import AnyUrl, BaseModel, Field

mcp = FastMCP("FetchMCP-SSE")


class FetchRequest(BaseModel):
    url: AnyUrl
    max_length: int = Field(5000, gt=0, le=1000000)
    start_index: int = Field(0, ge=0)
    raw: bool = False
    proxy: Optional[str] = None


def process_html_content(content: str) -> str:
    """Process HTML content to extract and convert to markdown"""
    soup = BeautifulSoup(content, "html.parser")
    main_content = soup.find("main") or soup.find("article") or soup.body
    if main_content:
        return markdownify.markdownify(str(main_content), heading_style="ATX", bullets="•")
    return content


async def fetch_content(request: FetchRequest) -> dict:
    """Fetch and process URL content"""
    user_agent = os.environ.get("USER_AGENT", "") or "FetchMCP/1.0"
    proxy = os.environ.get("PROXY", "") or request.proxy

    transport = httpx.AsyncHTTPTransport(proxy=proxy) if proxy else None
    url = str(request.url)

    try:
        async with httpx.AsyncClient(transport=transport) as client:
            response = await client.get(url, headers={"User-Agent": user_agent}, timeout=30.0)
            response.raise_for_status()

            content_type = response.headers.get("content-type", "")
            content = response.text
            if not request.raw and (
                "text/html" in content_type or content.lstrip()[:15].lower().startswith("<!doctype html")
            ):
                content = process_html_content(content)

            truncated = content[request.start_index : request.start_index + request.max_length]
            remaining = len(content) - (request.start_index + len(truncated))
            result = {
                "content": truncated,
                "url": url,
                "length": len(truncated),
                "remaining": remaining if remaining > 0 else 0,
            }
            if remaining > 0:
                result["next_index"] = request.start_index + len(truncated)
            return result

    except httpx.HTTPError as e:
        return {"error": f"HTTP error: {str(e)}"}
    except Exception as e:
        return {"error": f"Processing error: {str(e)}"}


@mcp.tool()
async def fetch(
    url: AnyUrl, max_length: int = 5000, start_index: int = 0, raw: bool = False, proxy: Optional[str] = None
) -> dict:
    """Fetch URL content with processing

    Args:
        url: Target URL to fetch (required)
        max_length: Maximum content length (1-1000000, default: 5000)
        start_index: Start position for content (default: 0)
        raw: Return raw content without processing (default: False)
        proxy: Proxy server URL (optional), e.g. "http://proxy.example.com:8080" or "socks5://user:pass@host:port"
    """
    request = FetchRequest(url=url, max_length=max_length, start_index=start_index, raw=raw, proxy=proxy)
    return await fetch_content(request)


if __name__ == "__main__":
    mcp.run(transport="sse")
