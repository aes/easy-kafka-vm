#!/bin/bash

set -euo pipefail

bash gimme.sh

VERSION=$(cat version.txt)

echo "VERSION=$VERSION" >> "$GITHUB_ENV"

tar cvz \
    -f "/tmp/easy-kafka-vm_${VERSION}.tar.gz" \
    --exclude='.*' \
    -C .. \
    "$(basename "$PWD")"
