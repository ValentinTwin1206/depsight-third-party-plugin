from __future__ import annotations

from pathlib import Path

# third-party imports
from deply.core.plugins.base import BasePlugin
from deply.core.plugins.dependency import Dependency

# TODO: RENAME "MyPlugin" TO "NpmPlugin"
class MyPlugin(BasePlugin):
    """Example third-party plugin for deply."""

    def __init__(self) -> None:
        self.dependencies: list[Dependency] = []

    @property
    def name(self) -> str:
        # TODO: Replace the name to "npm"
        return "myplugin"

    @property
    def dependency_files(self) -> tuple[str, ...]:
        # TODO: Add "package.json"to the tuple
        return ("")

    def collect(self, project_dir: str | Path) -> None:
        """Return two fake dependencies for testing."""
        # TODO: TOTALLY REIMLPEMENT THIS METHOD TO PARSE A REAL NPM DEPENDENCIES
        self.dependencies = [
            Dependency(name="foo", version="1.0.0", tool_name=self.name),
            Dependency(name="bar", version="2.0.0", tool_name=self.name),
        ]
