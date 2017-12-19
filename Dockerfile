FROM docker
RUN apk add --no-cache python3
RUN pip3 install docker-compose
WORKDIR /project
ENV COMPOSE_FILE=test.yaml \
    COMPOSE_PROJECT_NAME=project \
    ADDON_CATEGORIES="--private --extra" \
    CONTAINER_PREFIX="ci" \
    SHARED_NETWORK=inverseproxy_shared
# Scripts that run in this container
COPY outside /usr/local/bin
# Scripts that run inside your Doodba's Odoo service
COPY inside /usr/local/src
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
