ARG PYTHON_VERSION
FROM mcr.microsoft.com/devcontainers/python:${PYTHON_VERSION}

# Install uv (RUST based Python package manager)
ARG UV_VERSION
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh \
  && mv /root/.local/bin/uv /usr/local/bin/uv \
  && mv /root/.local/bin/uvx /usr/local/bin/uvx

# Download deply wheel so uv sync can resolve it via find-links
ARG DEPSIGHT_VERSION
ARG WHL_NAME="depsight-${DEPSIGHT_VERSION}-py3-none-any.whl"
RUN mkdir -p /opt/depsight-wheels \
  && cd /opt/depsight-wheels \
  && curl -fsSL -O \
    "https://github.com/ValentinTwin1206/depsight-dependency-manager/releases/download/${DEPSIGHT_VERSION}/${WHL_NAME}"
    
# Environment variables
ENV DEPSIGHT_ENV=development
ENV PYTHONUNBUFFERED=1

USER vscode