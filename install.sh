#!/usr/bin/env bash
# install.sh

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TARGET_DIR="$HOME/.local/bin"

mkdir -p "$TARGET_DIR"

for script in "$SCRIPT_DIR/bin"/*; do
  script_name=$(basename "$script")
  ln -sf "$script" "$TARGET_DIR/$script_name"
  echo "Linked $script_name"
done

ln -sf "$HOME/Code/GitHub/rapidhash/cli/build/rapidhash" "$TARGET_DIR/rapidhash"
echo "Linked rapidhash_cli"
