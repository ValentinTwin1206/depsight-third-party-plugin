FROM mcr.microsoft.com/devcontainers/python:3.12

# Install uv (RUST based Python package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Prevent Python stdout buffering
ENV PYTHONUNBUFFERED=1

# App environment
ENV APP_NAME=MY_DEPLY_PLUGIN

USER vscode