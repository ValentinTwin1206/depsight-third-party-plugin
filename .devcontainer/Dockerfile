ARG PYTHON_VERSION=3.12
FROM mcr.microsoft.com/devcontainers/python:${PYTHON_VERSION}

# Install uv via the official installer
ARG UV_VERSION=0.10.9
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# Download the depsight wheel to a staging path. The postCreateCommand in
# devcontainer.json copies it into the project's wheels/ directory before
# uv sync runs, matching pyproject.toml's relative find-links = ["wheels"].
ARG DEPSIGHT_VERSION
ARG WHL_PKG=depsight-${DEPSIGHT_VERSION}-py3-none-any.whl
ADD https://github.com/ValentinTwin1206/depsight-dependency-manager/releases/download/${DEPSIGHT_VERSION}/${WHL_PKG} /opt/depsight-wheels/
RUN chmod -R a+r /opt/depsight-wheels/

# Environment variables
ENV DEPSIGHT_ENV=development
ENV PYTHONUNBUFFERED=1

USER vscode