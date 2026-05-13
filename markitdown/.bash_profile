#!/bin/bash

markitdown() {
  # Check if the first argument is a file that exists.
  if [ -f "$1" ]; then
    # If it's a file, use it as stdin and redirect stdout to a new markdown file.
    # The output filename will be based on the input filename (e.g., "file.pdf" -> "file.md").
    output_filename="${1%.*}.md"
    echo "Converting file '$1' to '$output_filename'..."
    docker run --rm -i jerryin/markitdown:latest <"$1" >"$output_filename"
    echo "Done."
  else
    # Otherwise, pass all arguments directly to the container.
    # This handles --help, -o, and piping from stdin.
    docker run --rm -i jerryin/markitdown:latest "$@"
  fi
}
