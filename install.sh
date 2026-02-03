#!/usr/bin/env bash
# install.sh

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TARGET_DIR="$HOME/.local/bin"

mkdir -p "$TARGET_DIR"
ln -sf "$SCRIPT_DIR/*" "$TARGET_DIR" 2>/dev/null || true

for script in "$SCRIPT_DIR/bin"/*; do
  script_name=$(basename "$script")
  ln -sf "$script" "$TARGET_DIR/$script_name"
  echo "Linked $script_name"
done
