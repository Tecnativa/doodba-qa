FROM docker
RUN apk add --no-cache python3
RUN pip3 install docker-compose
ENV COMPOSE_FILE=test.yaml \
    COMPOSE_PROJECT_NAME=project \
    ADDON_CATEGORIES="--private --extra" \
    CONTAINER_PREFIX="ci" \
    SHARED_NETWORK=inverseproxy_shared
# Scripts that run inside your Doodba's Odoo container
COPY insider /usr/local/src
# Scripts that run in this container
WORKDIR /usr/local/bin
COPY outsider .
RUN for f in $(ls /usr/local/src); do ln -s insider $f; done; sync
WORKDIR /project
