#!/bin/bash

# Function to install a custom node
install_custom_node() {
  local repo_url=$1
  local repo_name=$(basename -s .git "$repo_url")
  local target_dir="custom_nodes/$repo_name"

  echo "Cloning $repo_url into $target_dir"
  git clone "$repo_url" "$target_dir"

  # Check if requirements.txt exists and install dependencies
  if [ -f "$target_dir/requirements.txt" ]; then
    echo "Installing dependencies from $target_dir/requirements.txt"
    pip install -r "$target_dir/requirements.txt"
  else
    echo "No requirements.txt found in $target_dir"
  fi
}

# Custom node repositories list
custom_nodes=(
  "https://github.com/ltdrdata/ComfyUI-Manager.git"
  "https://github.com/AIGODLIKE/AIGODLIKE-ComfyUI-Translation.git"
)

# Loop through each custom node and install it
for repo_url in "${custom_nodes[@]}"; do
  install_custom_node "$repo_url"
done
