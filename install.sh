#!/usr/bin/env bash
# Install the tools to /usr/local/bin.
set -euo pipefail
cd "$(dirname "$0")"

# Pillow is required; lz4 is optional (faster unpacking). Only touch the
# package manager when something is actually missing.
if ! python3 -c "import PIL, lz4" 2>/dev/null; then
    echo "Installing Python dependencies (Pillow, lz4)..."
    if command -v dnf >/dev/null; then
        sudo dnf install -y python3-pillow python3-lz4
    elif command -v apt-get >/dev/null; then
        sudo apt-get install -y python3-pil python3-lz4
    elif command -v pacman >/dev/null; then
        sudo pacman -S --needed python-pillow python-lz4
    elif command -v zypper >/dev/null; then
        sudo zypper install -y python3-Pillow python3-lz4
    else
        echo "Install Pillow (and optionally lz4) for Python 3 with your package manager."
    fi
fi

for f in bin/*; do
    sudo install -m 755 "$f" "/usr/local/bin/$(basename "$f")"
    echo "Installed /usr/local/bin/$(basename "$f")"
done
