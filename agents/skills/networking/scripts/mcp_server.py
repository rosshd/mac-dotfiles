# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "mcp>=1.27,<2",
# ]
# ///
"""Read-only MCP access to the private networking workspace."""

from __future__ import annotations

import csv
import os
import sys
from pathlib import Path

from mcp.server.fastmcp import FastMCP

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

import networking as store  # noqa: E402


def root() -> Path:
    return store.workspace_root(os.environ.get("NETWORKING_HOME"))


mcp = FastMCP(
    "Private Networking",
    instructions=(
        "Read-only access to Ross's private networking workspace. "
        "Never expose returned data outside the current user-requested context."
    ),
)


@mcp.tool()
def search_people(query: str) -> list[dict[str, str]]:
    """Search private person and organization profiles."""
    results = []
    for path in store.search_workspace(root(), query):
        metadata = store.basic_frontmatter(path)
        results.append(
            {
                "path": str(path.relative_to(root())),
                "slug": metadata.get("slug", path.stem),
                "name": metadata.get("name", path.stem),
                "kind": metadata.get("kind", path.parent.name.rstrip("s")),
            }
        )
    return results


@mcp.tool()
def get_person(slug: str) -> str:
    """Read one private person profile by stable slug."""
    if not store.SLUG_RE.fullmatch(slug):
        raise ValueError("invalid person slug")
    path = root() / "people" / f"{slug}.md"
    return path.read_text(encoding="utf-8")


@mcp.tool()
def list_due_follow_ups(on_date: str = "") -> list[dict[str, str]]:
    """List profile follow-ups due on or before an ISO date."""
    import datetime as dt

    date_value = dt.date.fromisoformat(on_date) if on_date else dt.date.today()
    return [
        {"date": follow_up.isoformat(), "path": str(path.relative_to(root()))}
        for follow_up, path in store.due_profiles(root(), date_value)
    ]


@mcp.tool()
def list_relationships(slug: str = "") -> list[dict[str, str]]:
    """List relationship rows, optionally involving one person slug."""
    path = root() / "relationships.csv"
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    if slug:
        if not store.SLUG_RE.fullmatch(slug):
            raise ValueError("invalid person slug")
        rows = [
            row for row in rows if slug in (row.get("from_slug"), row.get("to_slug"))
        ]
    return rows


@mcp.tool()
def list_recent_interactions(limit: int = 20) -> list[dict[str, str]]:
    """List recent private interaction records without modifying them."""
    if limit < 1 or limit > 100:
        raise ValueError("limit must be between 1 and 100")
    paths = sorted((root() / "interactions").rglob("*.md"), reverse=True)[:limit]
    return [
        {
            "path": str(path.relative_to(root())),
            "date": store.basic_frontmatter(path).get("date", ""),
            "title": next(
                (
                    line.removeprefix("# ")
                    for line in path.read_text(encoding="utf-8").splitlines()
                    if line.startswith("# ")
                ),
                path.stem,
            ),
        }
        for path in paths
    ]


@mcp.resource("networking://people/{slug}")
def person_resource(slug: str) -> str:
    """Read one person profile as a private resource."""
    return get_person(slug)


if __name__ == "__main__":
    mcp.run(transport="stdio")
