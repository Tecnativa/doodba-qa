FROM python:3-slim
ARG MQT=https://github.com/OCA/maintainer-quality-tools.git
ENV ADDON_CATEGORIES="--private" \
    ADMIN_PASSWORD="admin" \
    ARTIFACTS_DIR="artifacts" \
    BUILD_FLAGS="--pull --no-cache" \
    COMPOSE_INTERACTIVE_NO_CLI=1 \
    CONTAINER_PREFIX="ci" \
    DESTROY_FLAGS="-v --rmi local --remove-orphans" \
    LANG=C.UTF-8 \
    LINT_DISABLE="manifest-required-author" \
    LINT_ENABLE="" \
    LINT_MODE=strict \
    PGPASSWORD="odoopassword" \
    PIPX_BIN_DIR="/usr/local/bin" \
    PYTHONOPTIMIZE="" \
    REPOS_FILE="odoo/custom/src/repos.yaml" \
    VERBOSE=0
RUN apt-get update \
    && apt-get install -yqq curl docker.io git jq build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && pip install --no-cache-dir docker-compose pipx \
    && pipx install git-aggregator \
    && pipx install pre-commit \
    && pipx install yq \
    && sync
# Scripts that run inside your Doodba's Odoo container
COPY insider /usr/local/src/insider
# Scripts that run in this container, usually against a docker engine
WORKDIR /usr/local/bin
COPY outsider .
RUN for f in $(ls /usr/local/src/insider); do ln -s insider $f; done; sync
WORKDIR /project

# Labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date="$BUILD_DATE" \
    org.label-schema.name="Doodba QA" \
    org.label-schema.description="QA tools for Doodba projects" \
    org.label-schema.license=Apache-2.0 \
    org.label-schema.url="https://www.tecnativa.com" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.vcs-url="https://github.com/Tecnativa/doodba-qa" \
    org.label-schema.vendor="Tecnativa" \
    org.label-schema.version="$VERSION" \
    org.label-schema.schema-version="1.0"
