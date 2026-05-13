# MarkItDown

[MarkItDown](https://github.com/microsoft/markitdown) is a lightweight Python utility for converting various files to Markdown for use with LLMs and related text analysis pipelines. To this end, it is most comparable to [textract](https://github.com/deanmalmgren/textract), but with a focus on preserving important document structure and content as Markdown (including: headings, lists, tables, links, etc.) While the output is often reasonably presentable and human-friendly, it is meant to be consumed by text analysis tools -- and may not be the best option for high-fidelity document conversions for human consumption.

At present, MarkItDown supports:

- PDF
- PowerPoint
- Word
- Excel
- Images (EXIF metadata and OCR)
- Audio (EXIF metadata and speech transcription)
- HTML
- Text-based formats (CSV, JSON, XML)
- ZIP files (iterates over contents)
- Youtube URLs
- EPubs
- ... and more!

## Why Markdown?

Markdown is extremely close to plain text, with minimal markup or formatting, but still provides a way to represent important document structure. Mainstream LLMs, such as OpenAI's GPT-4o, natively "_speak_" Markdown, and often incorporate Markdown into their responses unprompted. This suggests that they have been trained on vast amounts of Markdown-formatted text, and understand it well. As a side benefit, Markdown conventions are also highly token-efficient.

## Usage

The primary way to use MarkItDown is via Docker.

### Basic Usage

```bash
docker run --rm -i jerryin/markitdown:latest < ~/your-file.pdf > output.md
```

### Helper Script for Convenience

The included `.bash_profile` provides a convenient `markitdown()` shell function that simplifies the process.

**1. Setup**

To use it, source the file in your current shell session:

```bash
source .bash_profile
```

For persistent use, add this command to your shell's startup file (e.g., `~/.bashrc` or `~/.zshrc`).

**2. Examples**

- **Convert a local file:** This command will convert `your-file.pdf` and automatically save the output to `your-file.md`.

  ```bash
  markitdown your-file.pdf
  ```

- **Piping from stdin or passing arguments:** The function also handles other cases, like piping content or passing command-line arguments to the container.

  ```bash
  cat your-file.txt | markitdown > output.md
  markitdown --help
  ```
