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
