ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}-dev AS builder

WORKDIR /depsight

COPY pyproject.toml uv.lock ./
COPY wheels/ dist/ /tmp/wheels/

# TODO: Run `uv sync` with the following flags:
#   --no-dev           (exclude dev dependencies)
#   --find-links       (point to /tmp/wheels/ so uv can find the copied wheels)
#   --no-install-project (install only dependencies, not the project itself yet)

# TODO: Copy the rest of the project source code into the container

# TODO: Run `uv sync` again with:
#   --no-dev
#   --find-links /tmp/wheels/
#   (this time it will install the project itself using the already-cached dependencies)

#
# PROD STAGE
# # # # # # # #
ARG PYTHON_VERSION=3.12
FROM dhi.io/python:${PYTHON_VERSION}

WORKDIR /depsight


# TODO: Copy the virtual environment from the builder stage at /depsight/.venv
#       into /depsight/.venv in this final stage

ENTRYPOINT ["depsight"]
