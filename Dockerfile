FROM debian:9
ARG MQT=https://github.com/OCA/maintainer-quality-tools.git
ENV ADDON_CATEGORIES="--private" \
    BUILD_FLAGS="--pull --no-cache" \
    CONTAINER_PREFIX="ci" \
    LANG=C.UTF-8 \
    LINT_DISABLE="manifest-required-author" \
    LINT_ENABLE="" \
    LINT_MODE=strict \
    QA_VOLUME="" \
    REPOS_FILE="odoo/custom/src/repos.yaml" \
    SHARED_NETWORK=inverseproxy_shared \
    VERBOSE=0
RUN apt-get -qq update \
    && apt-get install -yqq --no-install-recommends \
        curl git gnupg2 virtualenv \
        python-pip python-setuptools python-lxml python-virtualenv \
        python3-pip python3-setuptools python3-lxml python3-virtualenv \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -yqq nodejs \
    && curl -fsSL https://get.docker.com | sh \
    && apt-get -yqq autoremove \
    && rm -Rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir docker-compose git-aggregator
# Insider script dependencies
RUN for v in 2 3; \
        do virtualenv --system-site-packages -p python$v /qa/py$v \
        && virtualenv --relocatable -p python$v /qa/py$v \
        && . /qa/py$v/bin/activate \
        && pip install --no-cache-dir coverage click flake8 pylint-odoo six \
        && npm install --loglevel error eslint \
        && deactivate; \
    done \
    && mkdir -p /qa/artifacts \
    && chown -R 1000:1000 /qa/artifacts \
    && chmod a=rwX /qa/artifacts \
    && git clone --depth 1 $MQT /qa/mqt
# Scripts that run inside your Doodba's Odoo container
COPY --chown=root:1000 insider /qa/insider
# Scripts that run in this container
WORKDIR /usr/local/bin
COPY outsider .
RUN for f in $(ls /qa/insider); do ln -s insider $f; done; sync
WORKDIR /project
ENTRYPOINT ["/usr/local/bin/entrypoint"]

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
