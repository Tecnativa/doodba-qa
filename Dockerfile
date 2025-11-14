FROM python:3.12-slim
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
    VERBOSE=0 \
    DOCKER_VERSION=27.3.1 \
    DOCKER_COMPOSE_VERSION=2.30.3
RUN apt-get update \
    && apt-get install -yqq \
        build-essential \
        libxml2-dev \
        libxml2-dev \
        libxslt-dev \
        curl \
        git \
        jq \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && pip install --no-cache-dir pipx \
    && pipx install git-aggregator \
    && pipx install pre-commit \
    && pipx install yq \
    && pip install --no-cache-dir "docker>=7,<8" \
    && curl -fsSLO "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    && tar xzvf "docker-${DOCKER_VERSION}.tgz" --strip-components=1 -C /usr/local/bin docker/docker \
    && rm "docker-${DOCKER_VERSION}.tgz" \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fsSLo /usr/local/lib/docker/cli-plugins/docker-compose \
         "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    && ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose \
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
