# Doodba Quality Assurance

## What?

Tools for checking that your [Doodba][]-based project is cool.

## Why?

Because [OCA's maintainer quality tools][MQT] are too addons-repo-focused.

We needed a too Doodba-focused version instead. 😆

## How?

1. Mount your project structure, usually based on the provided [scaffolding][], on `/project` in the container. Docker CLI example: `-v $(pwd):/project`.
1. Give him access to a Docker socket (beware of the **security implications!**) with `--privileged -v /var/run/docker.sock` or with `-e DOCKER_HOST=tcp://dockerhost:2375`.
1. Configure through [environment variables](#environment-variables).
1. Run any of the bundled [scripts](#scripts).

Example command:

    docker container run --rm -it --privileged -v "$PWD:/project:z" -v /var/run/docker.sock:/var/run/docker.sock:z -e COMPOSE_PROJECT_NAME=$(basename "$PWD") tecnativa/doodba-qa pylint

You most likely want to run this into a CI environment, so just check out the `examples` directory and you'll get a hint on how to do it.

## Environment variables

You can use any of the upstream [Docker Compose environment variables](https://docs.docker.com/compose/reference/envvars/).

Besides, you have these too:

### `ADDON_CATEGORIES`

Defaults to `--private --extra` for all jobs.

You can change it per job, removing any of those or adding `--core`.

These flags are used for [the `addons` script](https://github.com/Tecnativa/docker-odoo-base#addons) available in all Doodba projects. Use this command in your project's folder to understand its usage:

    docker-compose run --rm odoo addons --help

### `SHARED_NETWORK`

An external network that should always exist before running containers. It is created automatically if missing. Defaults to `inverseproxy_shared`.

## Scripts

You can use `sh`, `docker` and `docker-compose` commands with all of their features.

Besides, there are other scripts bundled, useful to do a CI pipeline:

### `build`

Build your project with `docker-compose` and check odoo works.

### `coverage`

Install all the indicated addons, run their unit tests and report coverage.

### `destroy`

Destroy all containers, volumes, local images and networks.

### `flake8`

Lint code with [flake8](https://pypi.python.org/pypi/flake8) using [MQT][].

### `pylint`

Lint code with [pylint-odoo](https://github.com/OCA/pylint-odoo/) using [MQT][].

[Doodba]: https://github.com/Tecnativa/docker-odoo-base
[MQT]: https://github.com/OCA/maintainer-quality-tools
[scaffolding]: https://github.com/Tecnativa/docker-odoo-base/tree/scaffolding
