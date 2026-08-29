#!/bin/sh
set -eu
TARGET_DIR="${TARGET_DIR:-/tmp/log/scripts}"
SOURCE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p "$TARGET_DIR"
cp "$SOURCE_DIR/bin/cellnet" "$TARGET_DIR/cellnet"
chmod +x "$TARGET_DIR/cellnet"
echo "Installed: $TARGET_DIR/cellnet"
echo "Validate:  sh -n $TARGET_DIR/cellnet"
echo "PATH:      export PATH=\"\$PATH:$TARGET_DIR\""
