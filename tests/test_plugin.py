from __future__ import annotations

import csv
from pathlib import Path

# third-party imports
from depsight.core.plugins.base import BasePlugin

from myplugin.myplugin import MyPlugin


class TestCollect:
    """Verify collect() populates dependencies correctly."""

    def test_plugin_implements_base_plugin_contract(self):
        plugin = MyPlugin()

        assert isinstance(plugin, BasePlugin)
        assert plugin.default_file in plugin.dependency_files

    def test_collect_dependency_details(self):
        plugin = MyPlugin()
        plugin.collect("/nonexistent", file=plugin.default_file)
        foo, bar = plugin.dependencies
        assert (foo.name, foo.version, foo.tool_name) == ("foo", "1.0.0", "myplugin")
        assert (bar.name, bar.version, bar.tool_name) == ("bar", "2.0.0", "myplugin")


class TestExport:
    """Verify export() writes a valid CSV."""

    def test_export_csv(self, tmp_path: Path):
        plugin = MyPlugin()
        plugin.collect("/some/project", file=plugin.default_file)
        csv_path = plugin.export("/some/project", tmp_path)
        assert csv_path.exists()
        assert csv_path.name == "myplugin_project.csv"

        with csv_path.open(encoding="utf-8") as fh:
            rows = list(csv.DictReader(fh))
        assert len(rows) == 2
        assert rows[0]["name"] == "foo"
        assert rows[1]["name"] == "bar"
