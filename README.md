# Doodba Quality Assurance

[![Build Status](https://travis-ci.org/Tecnativa/doodba-qa.svg?branch=master)](https://travis-ci.org/Tecnativa/doodba-qa)
[![Docker Pulls](https://img.shields.io/docker/pulls/tecnativa/doodba-qa.svg)](https://hub.docker.com/r/tecnativa/doodba-qa)
[![Layers](https://images.microbadger.com/badges/image/tecnativa/doodba-qa.svg)](https://microbadger.com/images/tecnativa/doodba-qa)
[![Commit](https://images.microbadger.com/badges/commit/tecnativa/doodba-qa.svg)](https://microbadger.com/images/tecnativa/doodba-qa)
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

### `ADMIN_PASSWORD`

Defaults to `admin`. If set, is used as the DB manager password.

### `ARTIFACTS_DIR`

Directory where all the artifacts produced by insider scripts will be extracted.

### `ARTIFACTS_UID` and `ARTIFACTS_GID`

UID/GID to be set as owner for artifacts produced by insider scripts.

### `BUILD_FLAGS`

Flags to append to `docker-compose build`. Defaults to `--pull --no-cache`.

### `DESTROY_FLAGS`

Flags to append to `docker-compose down`. Defaults to `-v --rmi local --remove-orphans`.

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

### `PGPASSWORD`

Used in [`secrets-setup`](#secrets-setup) when you need a specific DB password.

Defaults to `odoopassword`.

### `REPOS_FILE`

Path for the `repos.yaml` file in current scaffolding (*not* inside the container).

## Scripts

You can use `sh`, `docker` and `docker-compose` commands with all of their features.

Besides, there are other scripts bundled, useful to do a CI pipeline:

### `addons-install`

Install requested addons.

### `build`

Build your project with `docker-compose` and check odoo works.

Uses [`BUILD_FLAGS`](#build-flags).

### `closed-prs`

Know if your `repos.yaml` definition includes merged or closed pull requests.

Uses the [`REPOS_FILE`](#repos-file) and [`GITHUB_TOKEN`][1] environment variables.

### `coverage`

Run addons' unit tests and report coverage.

Usually you should run [`addons-install`](#addons-install) before.

You will find the HTML report files in `./$ARTIFACTS_DIR/coverage`.

### `destroy`

Destroy all containers, volumes, local images and networks.

Uses [`DESTROY_FLAGS`](#destroy-flags).

### `flake8`

Lint code with [flake8](https://pypi.python.org/pypi/flake8) using [MQT][].

### `networks-autocreate`

Create missing external networks, which are not autocreated by docker compose because it expects them to be present at the time of booting an environment.

Common examples of such networks are [`inverseproxy_shared`](https://github.com/Tecnativa/doodba#global-inverse-proxy) or [`globalwhitelist_shared`](https://github.com/Tecnativa/doodba#global-whitelist).

It extracts the required networks from the chosen `docker-compose.yaml` file.

### `pylint`

Lint code with [pylint-odoo](https://github.com/OCA/pylint-odoo/) using [MQT][].

Some [environment variables](#environment-variables) modify this script's behavior; check them out.

### `secrets-setup`

Creates all needed environment files for the official `test.yaml` environment to work.

Uses [`ADMIN_PASSWORD`](#admin-password) and [`PGPASSWORD`](#pgpassword).

### `shutdown`

Like [`destroy`](#destroy), but keeping volumes and images.

## Other utilities

These tools are not strictly related to Doodba, but they are helpful and are included:

- [`jq`](https://stedolan.github.io/jq/)
- [`yq`](https://yq.readthedocs.io/en/latest/)

[1]: https://github.com/acsone/git-aggregator#show-closed-github-pull-requests
[Doodba]: https://github.com/Tecnativa/docker-odoo-base
[MQT]: https://github.com/OCA/maintainer-quality-tools
[scaffolding]: https://github.com/Tecnativa/docker-odoo-base/tree/scaffolding
