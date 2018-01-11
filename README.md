# Doodba Quality Assurance

[![Docker Pulls](https://img.shields.io/docker/pulls/tecnativa/doodba-qa.svg)](https://hub.docker.com/r/tecnativa/doodba-qa)
[![Layers](https://images.microbadger.com/badges/image/tecnativa/doodba-qa.svg)](https://microbadger.com/images/tecnativa/doodba-qa)
[![Commit](https://images.microbadger.com/badges/commit/tecnativa/doodba-qa:latest.svg)](https://microbadger.com/images/tecnativa/doodba-qa:latest)
[![License](https://images.microbadger.com/badges/license/tecnativa/doodba-qa.svg)](https://microbadger.com/images/tecnativa/doodba-qa)

BEWARE!, this project is in **beta stage**. Things are changing quickly.

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

Example command for test environment, good for CI:

    docker container run --rm -it --privileged -e COMPOSE_FILE=test.yaml -v "$PWD:/project:z" -v /var/run/docker.sock:/var/run/docker.sock:z tecnativa/doodba-qa pylint

Example command for devel environment, linting only private addons:

    docker container run --rm -it --privileged -v "$PWD:$PWD:z" -v /var/run/docker.sock:/var/run/docker.sock:z -w "$PWD" -e ADDON_CATEGORIES=-p tecnativa/doodba-qa pylint

You most likely want to run this into a CI environment, so just check out the `examples` directory and you'll get a hint on how to do it.

## Environment variables

You can use any of the upstream [Docker Compose environment variables](https://docs.docker.com/compose/reference/envvars/).

Besides, you have these too:

### `ADDON_CATEGORIES`

Defaults to `--private` for all jobs.

You can change it per job, using any of `--private --extra --core` (or `-pec`).

These flags are used for [the `addons` script](https://github.com/Tecnativa/docker-odoo-base#addons) available in all Doodba projects. Use this command in your project's folder to understand its usage:

    docker-compose run --rm odoo addons --help

### `LINT_DISABLE`

Disables specific linter messages. Its format depends on the underlying linter.

Defaults to `manifest-required-author`, since it's expected that you will only want to lint private addons, and those are not OCA's.

TODO: Make it work with flake8.

### `LINT_ENABLE`

Enables specific linter messages. Its format depends on the underlying linter.

Empty by default.

TODO: Make it work with flake8.

### `LINT_MODE`

Right now, only useful for [`pylint`](#pylint). Valid values:

- `loose` (default) uses [MQT][] standard cfg.
- `strict` uses pull request cfg.
- `beta` uses beta cfg.

### `SHARED_NETWORK`

An external network that should always exist before running containers. It is created automatically if missing. Defaults to `inverseproxy_shared`.

## Scripts

You can use `sh`, `docker` and `docker-compose` commands with all of their features.

Besides, there are other scripts bundled, useful to do a CI pipeline:

### `addons-install`

Install requested addons.

### `build`

Build your project with `docker-compose` and check odoo works.

### `coverage`

Run addons' unit tests and report coverage.

Usually you should run [`addons-install`](#addons-install) before.

### `destroy`

Destroy all containers, volumes, local images and networks.

### `flake8`

Lint code with [flake8](https://pypi.python.org/pypi/flake8) using [MQT][].

### `pylint`

Lint code with [pylint-odoo](https://github.com/OCA/pylint-odoo/) using [MQT][].

Some [environment variables](#environment-variables) modify this script's behavior; check them out.

[Doodba]: https://github.com/Tecnativa/docker-odoo-base
[MQT]: https://github.com/OCA/maintainer-quality-tools
[scaffolding]: https://github.com/Tecnativa/docker-odoo-base/tree/scaffolding
