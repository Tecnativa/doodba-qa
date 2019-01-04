#!/usr/bin/env python3
"""Test that this test image tests tests fine."""
import logging
import sys
import os
import unittest

from os.path import dirname, join

import docker


logging.root.setLevel(logging.INFO)
IMAGE = os.environ.get("IMAGE_NAME", "tecnativa/doodba-qa:latest")
SCAFFOLDINGS_DIR = join(dirname(__file__), "scaffoldings")
BASE_ENVIRON = {
    "DB_VERSION": os.environ.get("DB_VERSION", "11"),
    "ODOO_MINOR": os.environ.get("ODOO_MINOR", "12.0"),
    "VERBOSE": "1",
}


class TestException(Exception):
    pass


class ScaffoldingCase(unittest.TestCase):
    def setUp(self):
        super().setUp()
        self.client = docker.from_env()
        self.addCleanup(self.client.close)

    def run_qa(self, directory, command, environment=None, **kwargs):
        """Shortcut to run QA and ensure it works."""
        scaffolding = join(SCAFFOLDINGS_DIR, directory)
        environment = environment or {}
        params = {
            "command": command,
            "detach": True,
            "stdout": True,
            "stderr": True,
            "environment": dict(BASE_ENVIRON, **environment),
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
        container = self.client.containers.run(**params)
        self.addCleanup(container.remove)
        # Stream logs
        with os.fdopen(sys.stderr.fileno(), "wb", closefd=False) as stderr:
            for part in container.logs(stream=True):
                stderr.write(part)
                stderr.flush()
        result = container.wait()
        if result["StatusCode"]:
            raise TestException(result)
        return result

    def test_100_build(self):
        """Test building images."""
        self.run_qa("0", ["build"], {
            "BUILD_FLAGS": "--pull",
        })

    def test_500_flake8(self):
        """Check flake8 tests work fine."""
        self.run_qa("0", "flake8", environment={"ADDON_CATEGORIES": "-e"})
        with self.assertRaises(TestException):
            self.run_qa("0", "flake8")


if __name__ == "__main__":
    unittest.main()
