# # # # # # # # 
# BUILD STAGE
# # # # # # # # 
FROM python:3.12-slim AS builder

ARG UV_VERSION=0.10.9
ARG DEPSIGHT_VERSION=0.3.0
ARG USER_NAME=depsight

WORKDIR /depsight

# Install curl (required for uv installer)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# TODO: Use 'RUN' and a pipe '|' to install the 'uv' package manager.
# Hint: Check the Dockerfile of the DevContainer

# Create wheels directory
RUN mkdir -p wheels

# Download depsight wheel
ARG WHL_PKG=depsight-${DEPSIGHT_VERSION}-py3-none-any.whl
ADD https://github.com/ValentinTwin1206/depsight-dependency-manager/releases/download/${DEPSIGHT_VERSION}/${WHL_PKG} ./wheels/

# Copy dependency config
COPY pyproject.toml uv.lock ./

# TODO: Use 'RUN' and 'uv sync' to set up the environment.
# Hint: Use the flags '--frozen' and '--find-links' to point to your wheels directory.


# # # # # # # #
# FINAL STAGE
# # # # # # # #
FROM python:3.12-slim

ARG UV_VERSION=0.10.9
ARG USER_ID=1000
ARG USER_NAME=depsight

WORKDIR /depsight

# Install curl (needed for uv install)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv again in final image
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh \
    | UV_INSTALL_DIR=/usr/local/bin sh

# TODO: Use 'RUN' with 'groupadd' and 'useradd' to create a non-root system user.
# Hint: Use the '-u' and '-g' flags to map the IDs from the ARGs, 
# and '-m' to ensure a home directory is created.

# TODO: Use 'COPY' with the '--from' flag to implement the Multi-Stage build.
# Hint: You need to bring the '.venv' directory from the 'builder' stage into your current WORKDIR.

# Copy app source
COPY . .

# TODO: Use 'RUN' with 'mkdir -p' and 'chown -R' to set up permissions.
# Hint: The application needs to write to '/home/${USER_NAME}/.depsight/logs' 
# and '/home/${USER_NAME}/.depsight/data'. Ensure both the WORKDIR 
# and the home directory are owned by your new user.

# TODO: Use the 'USER' instruction to drop root privileges.
# Hint: Switch to the username defined in the ARGs.

# Environment
ENV PATH="/depsight/.venv/bin:$PATH"
ENV PYTHONPATH="/depsight/src"
ENV PYTHONUNBUFFERED=1

# TODO: Use the 'ENTRYPOINT' instruction.
# Hint: This should be in "exec form" (using brackets) to run the 'depsight' binary.