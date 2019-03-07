#!/usr/bin/env python3
"""Test that this test image tests tests fine."""
import logging
import sys
import os
import unittest

from os.path import dirname, isfile, join
from shutil import rmtree

import docker


logging.root.setLevel(logging.INFO)
IMAGE = os.environ.get("IMAGE_NAME", "tecnativa/doodba-qa:latest")
SCAFFOLDINGS_DIR = join(dirname(__file__), "scaffoldings")
BASE_ENVIRON = {
    "ARTIFACTS_UID": os.getuid(),
    "ARTIFACTS_GID": os.getgid(),
    "DB_VERSION": os.environ.get("DB_VERSION", "11"),
    "ODOO_MINOR": os.environ.get("ODOO_MINOR", "12.0"),
    "VERBOSE": os.environ.get("VERBOSE", "0"),
}


class TestException(Exception):
    pass


class DoodbaQAScaffoldingCase(unittest.TestCase):
    def setUp(self):
        super().setUp()
        self.fulldir = join(SCAFFOLDINGS_DIR, self.directory)
        self.client = docker.from_env()
        self.environment = {}
        self.addCleanup(self.client.close)

    def tearDown(self):
        self.run_qa("shutdown")
        return super().tearDown()

    def run_qa(self, *args, **kwargs):
        """Shortcut to run QA and ensure it works.

        :param list args:
            Commands to run in the QA container.

        :param dict kwargs:
            Additional configurations for the Docker client.
        """
        env = dict(BASE_ENVIRON, **self.environment)
        scaffolding = join(SCAFFOLDINGS_DIR, self.directory)
        params = {
            "command": args,
            "detach": True,
            "stdout": True,
            "stderr": True,
            "environment": env,
            "image": IMAGE,
            "mounts": [
                docker.types.Mount(
                    target=scaffolding,
                    source=scaffolding,
                    type="bind",
                    read_only=False,
                ),
                docker.types.Mount(
                    target="/var/run/docker.sock",
                    source="/var/run/docker.sock",
                    type="bind",
                    read_only=True,
                ),
            ],
            "privileged": True,
            "tty": True,
            "working_dir": scaffolding,
        }
        params.update(kwargs)
        logging.info(
            "Executing %s in %s with environment %s",
            args, scaffolding, env,
        )
        container = self.client.containers.run(**params)
        self.addCleanup(container.remove)
        self.addCleanup(
            rmtree,
            join(scaffolding, env.get("ARTIFACTS_DIR", "artifacts")),
            ignore_errors=True,
        )
        # Stream logs
        with os.fdopen(sys.stderr.fileno(), "wb", closefd=False) as stderr:
            for part in container.logs(stream=True):
                stderr.write(part)
                stderr.flush()
        result = container.wait()
        if result["StatusCode"]:
            raise TestException(result)
        return result


class Scaffolding0Case(DoodbaQAScaffoldingCase):
    directory = "0"

    def setUp(self):
        super().setUp()
        self.environment["COMPOSE_FILE"] = "test.yaml"

    def test_100_networks_autocreate(self):
        """Automatic creation of required external networks."""
        with self.assertRaises(docker.errors.NotFound):
            self.client.networks.get("some_external_network")
        self.run_qa("networks-autocreate")
        self.client.networks.get("some_external_network")

    def test_200_build(self):
        """Test building images."""
        self.environment["BUILD_FLAGS"] = "--pull"
        self.run_qa("build")

    def test_400_addons_install(self):
        """Install test dependencies."""
        self.environment["ADDON_CATEGORIES"] = "-edp"
        self.run_qa("addons-install")

    def test_500_coverage(self):
        """Test coverage works fine."""
        self.environment["ARTIFACTS_DIR"] = "other_dir"
        self.run_qa("coverage")
        self.assertTrue(isfile(join(
            SCAFFOLDINGS_DIR,
            self.directory,
            "other_dir",
            "coverage",
            "index.html",
        )))

    def test_500_curl(self):
        """Make sure curl is installed and working."""
        self.run_qa("curl", "--version")

    def test_500_flake8(self):
        """Check flake8 tests work fine."""
        # Defaults to private addons, where there are linter errors
        with self.assertRaises(TestException):
            self.run_qa("flake8")
        self.environment["ADDON_CATEGORIES"] = "-e"
        self.run_qa("flake8")

    def test_500_jq(self):
        """The ``jq`` CLI tool should work."""
        self.run_qa("jq", "--version")

    def test_500_pylint(self):
        """Check pylint tests work fine"""
        with self.assertRaises(TestException):
            self.run_qa("pylint")
        self.environment["ADDON_CATEGORIES"] = "-e"
        self.run_qa("pylint")

    def test_500_secrets_setup_defaults(self):
        """Check secrets-setup works fine with default values."""
        self.run_qa("secrets-setup")
        values = {
            "backup": "",
            "db-access": "PGPASSWORD=odoopassword",
            "db-creation": "POSTGRES_PASSWORD=odoopassword",
            "odoo": "ADMIN_PASSWORD=admin",
            "smtp": "",
        }
        for key, value in values.items():
            with open(join(self.fulldir, ".docker", f"{key}.env")) as env_file:
                self.assertEqual(value, env_file.read())

    def test_500_secrets_setup_altered(self):
        """Check secrets-setup works fine with altered values."""
        self.environment["PGPASSWORD"] = "pgother"
        self.environment["ADMIN_PASSWORD"] = "adminother"
        self.run_qa("secrets-setup")
        values = {
            "backup": "",
            "db-access": "PGPASSWORD=pgother",
            "db-creation": "POSTGRES_PASSWORD=pgother",
            "odoo": "ADMIN_PASSWORD=adminother",
            "smtp": "",
        }
        for key, value in values.items():
            with open(join(self.fulldir, ".docker", f"{key}.env")) as env_file:
                self.assertEqual(value, env_file.read())

    def test_500_yq(self):
        """The ``yq`` CLI tool should work."""
        self.run_qa("yq", "--version")

    def test_999_destroy(self):
        """Destroy everything related to this test case."""
        self.run_qa("destroy")
        self.client.networks.get("some_external_network").remove()


if __name__ == "__main__":
    unittest.main()
