#
# DEV STAGE
# # # # # # # 
ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}-dev AS builder

# Install UV from the hardened uv image
COPY --from=dhi.io/uv:0.10.9 /usr/local/bin/uv \
    /usr/local/bin/uvx /usr/local/bin/

WORKDIR /depsight


# TODO: Download the depsight wheel to 'wheels/' (hint: see Dockerfile of DevContainer)
# ADD ...

# TODO: Copy pyproject.toml and uv.lock from the project
# COPY ...

# TODO: Install dependencies only using '--frozen' and '--no-install-project' flag of uv sync command
# RUN ...

COPY . .

# Install the project itself, reusing the cached dependency layer above
RUN uv sync --frozen

#
# PROD STAGE
# # # # # # # #
ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}

# TODO: Define the working directory as '/depsight'
# WORKDIR ...

# Copy the virtual environment from the builder stage to the same path —
# the depsight script shebang is hardcoded to /depsight/.venv/bin/python
COPY --from=builder /depsight/.venv /depsight/.venv

# Copy the plugin source so depsight can load it via the entry point
COPY --from=builder /depsight/src /depsight/src

# Add the venv to PATH so the depsight entrypoint is found
ENV PATH="/depsight/.venv/bin:$PATH"

# TODO: DEFINE AN ENTRYPOINT TO THE depsight CLI
# ENTRYPOINT [...]
