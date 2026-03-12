from __future__ import annotations

import csv
from pathlib import Path

# third-party imports
from deply.core.plugins.base import BasePlugin
from deply.core.plugins.dependency import Dependency

# TODO: REPLACE THE IMPORT STATEMENT To "npm.npm import NpmPlugin"
from myplugin.myplugin import MyPlugin


class TestCollect:
    """Verify collect() populates dependencies correctly."""

    # TODO: REIMPLEMENT THE WHOLE TEST
    def test_collect_dependency_details(self):
        plugin = MyPlugin()
        plugin.collect("/nonexistent")
        foo, bar = plugin.dependencies
        assert (foo.name, foo.version, foo.tool_name) == ("foo", "1.0.0", "myplugin")
        assert (bar.name, bar.version, bar.tool_name) == ("bar", "2.0.0", "myplugin")


class TestExport:
    """Verify export() writes a valid CSV."""

    # TODO: REIMPLEMENT THE WHOLE TEST
    def test_export_csv(self, tmp_path: Path):
        plugin = MyPlugin()
        plugin.collect("/some/project")
        csv_path = plugin.export("/some/project", tmp_path)
        assert csv_path.exists()
        assert csv_path.name == "myplugin_project.csv"

        with csv_path.open(encoding="utf-8") as fh:
            rows = list(csv.DictReader(fh))
        assert len(rows) == 2
        assert rows[0]["name"] == "foo"
        assert rows[1]["name"] == "bar"
