# # # # # # # # 
# BUILD STAGE
# # # # # # # # 
FROM python:3.12-slim AS builder

ARG UV_VERSION=0.10.9
ARG DEPSIGHT_VERSION=0.3.0
ARG USER_NAME=depsight

WORKDIR /depsight

# TODO: Download the depsight wheel from the GitHub release into the 'wheels/' directory.
#       Use the ADD instruction with the full URL to the .whl file.
#       The release URL follows this pattern:
#         https://github.com/ValentinTwin1206/depsight-dependency-manager/releases/download/<VERSION>/<WHL_FILE>
#       Use ARG variables so the version is easy to change.
#       Example:
#         ARG DEPSIGHT_VERSION=0.3.0
#         ARG WHL_PKG=depsight-${DEPSIGHT_VERSION}-py3-none-any.whl
#         ADD https://github.com/ValentinTwin1206/depsight-dependency-manager/releases/download/${DEPSIGHT_VERSION}/${WHL_PKG} wheels/

# TODO: Copy pyproject.toml and uv.lock into the container.
#       These files define project dependencies and their locked versions.
#       Copying them before the source code allows Docker to cache the
#       dependency-install layer — dependencies are only re-installed when
#       these files change, not on every code edit.
#       Command:
#         COPY pyproject.toml uv.lock ./

# TODO: Install only the project's dependencies (not the project itself).
#       Use 'uv sync' with two flags:
#         --frozen          : use the exact versions from uv.lock without updating it
#         --no-install-project : skip installing your own package (just its dependencies)
#       This creates a cached layer so dependency installation is skipped on rebuilds
#       unless pyproject.toml or uv.lock changes.
#       Command:
#         RUN uv sync --frozen --no-install-project

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

WORKDIR /depsight

# Create non-root user
ARG USER_ID=1000
ARG USER_NAME=depsight
# TODO: Create a non-root group and user for running the container securely.
#       Use 'groupadd' to create a group with the given GID, then 'useradd' to
#       create a user with the given UID, assigned to that group, with a home
#       directory (-m) and a login shell (-s /bin/bash).
#       Command:
#         RUN groupadd -g ${USER_ID} ${USER_NAME} && \
#             useradd -u ${USER_ID} -g ${USER_NAME} -m -s /bin/bash ${USER_NAME}

# Copy uv binaries from the builder stage
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/

# Copy the virtual environment from the builder stage to the same path —
# the depsight script shebang is hardcoded to /depsight/.venv/bin/python
COPY --from=builder /depsight/.venv /depsight/.venv

# Copy the plugin source so depsight can load it via the entry point
COPY --from=builder /depsight/src /depsight/src

# Prepare runtime directories for output
RUN mkdir -p /home/${USER_NAME}/.depsight/logs /home/${USER_NAME}/.depsight/data && \
    chown -R ${USER_NAME}:${USER_NAME} /depsight /home/${USER_NAME}

USER ${USER_NAME}

ENV PATH="/depsight/.venv/bin:$PATH"
ENV PYTHONPATH="/depsight/src"
ENV PYTHONUNBUFFERED=1

# TODO: Define the container's entrypoint to launch the depsight CLI.
#       Use the exec form (JSON array) so signals are forwarded correctly.
#       Command:
#         ENTRYPOINT ["depsight"]
