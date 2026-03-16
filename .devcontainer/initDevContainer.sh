#!/usr/bin/env bash
set -euo pipefail

# Copy depsight wheel into the local wheels/ directory and install all dependencies
mkdir -p wheels
cp /opt/depsight-wheels/*.whl wheels/
uv sync --all-groups

# Clone the JS fullstack learning course repository
git clone https://github.com/ValentinTwin1206/fancy-fileserver.git \
    ~/fancy-fileserver
