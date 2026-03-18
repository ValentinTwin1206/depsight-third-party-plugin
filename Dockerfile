#
# DEV STAGE
# # # # # # # 
ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}-dev AS builder

# Install UV from the hardened uv image
COPY --from=dhi.io/uv:0.10.9 /usr/local/bin/uv \
    /usr/local/bin/uvx /usr/local/bin/

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

# The plugin wheel must exist in the build context. In the CI (build.yml)
# we are providing the plugin wheel via 'Download plugin wheel artifact' 
# before invoking Docker build.
COPY . .

# Install the project itself, reusing the cached dependency layer above
RUN uv sync --frozen

#
# PROD STAGE
# # # # # # # #
ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}

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
