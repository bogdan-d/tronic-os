#!/usr/bin/env bash
set -xeuo pipefail

# Add tronic-os just file
echo "import \"/usr/share/ublue-os/just/95-tronic-os.just\"" >> /usr/share/ublue-os/justfile
