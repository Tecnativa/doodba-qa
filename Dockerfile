FROM docker
RUN apk add --no-cache python3
RUN pip3 install docker-compose
ENV ADDON_CATEGORIES="--private" \
    CONTAINER_PREFIX="ci" \
    LINT_DISABLE="manifest-required-author" \
    LINT_ENABLE="" \
    LINT_MODE=strict \
    SHARED_NETWORK=inverseproxy_shared \
    VERBOSE=0
# Scripts that run inside your Doodba's Odoo container
COPY insider /usr/local/src
# Scripts that run in this container
WORKDIR /usr/local/bin
COPY outsider .
RUN for f in $(ls /usr/local/src); do ln -s insider $f; done; sync
WORKDIR /project
# Remove problematic parent image entrypoint
ENTRYPOINT []

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
