#!/usr/bin/env bash
set -euo pipefail

REPO="triggerware/releases"
BINARY="triggerware"

# Detect OS
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  linux)  OS="linux" ;;
  darwin) OS="darwin" ;;
  *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)       echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

# Get latest version
VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/')

FILENAME="${BINARY}-${VERSION}-${OS}-${ARCH}"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${FILENAME}"

echo "Installing ${BINARY} ${VERSION} (${OS}/${ARCH})..."

curl -fsSL "$URL" -o "/tmp/${BINARY}"
chmod +x "/tmp/${BINARY}"

# Install to ~/.local/bin (no sudo required)
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
mv "/tmp/${BINARY}" "${INSTALL_DIR}/${BINARY}"

# Warn if not in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  echo "Warning: ${INSTALL_DIR} is not in your PATH."
  echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Create config dir
CONFIG_DIR="$HOME/.triggerware"
mkdir -p "$CONFIG_DIR"

echo "Installed to ${INSTALL_DIR}/${BINARY}"
echo "Config dir: ${CONFIG_DIR}"
echo "Run: ${BINARY} --help"
