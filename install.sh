#!/usr/bin/env bash
# Install the tools to /usr/local/bin.
set -euo pipefail
cd "$(dirname "$0")"

sudo dnf install -y python3-pillow python3-lz4

for f in bin/*; do
    sudo install -m 755 "$f" "/usr/local/bin/$(basename "$f")"
    echo "Installed /usr/local/bin/$(basename "$f")"
done
