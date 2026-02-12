#!/usr/bin/env python3
"""Validate .github/skills/*/SKILL.md files against the Agent Skills spec.

This intentionally implements only what we rely on in-repo:
- YAML frontmatter must exist
- name + description must exist
- name must match directory name and naming constraints

No external dependencies.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


_NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def _gh_error(path: Path, msg: str) -> None:
    # GitHub Actions annotation format.
    print(f"::error file={path.as_posix()}::{msg}")


def _split_frontmatter(text: str, path: Path) -> tuple[str, str] | None:
    if not text.startswith("---\n"):
        _gh_error(path, "SKILL.md must start with YAML frontmatter ('---' on first line)")
        return None

    end = text.find("\n---\n", 4)
    if end == -1:
        # Also allow EOF-terminated frontmatter: \n---\n is strongly preferred.
        end = text.find("\n---", 4)
        if end == -1:
            _gh_error(path, "Frontmatter must be terminated by a second '---' line")
            return None

    front = text[4:end]
    body = text[end + len("\n---\n") :]
    return front, body


def _parse_frontmatter(front: str) -> dict[str, object]:
    """Parse a tiny YAML subset.

    We only need top-level scalar keys plus an optional one-level map for `metadata`.
    """

    result: dict[str, object] = {}
    current_map: str | None = None

    for raw_line in front.splitlines():
        line = raw_line.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue

        m_top = re.match(r"^([A-Za-z0-9_-]+):(?:\s+(.*))?$", line)
        if m_top and not line.startswith(" "):
            key = m_top.group(1)
            value = m_top.group(2)
            if value is None or value == "":
                result[key] = {}
                current_map = key
            else:
                # strip simple quotes
                value = value.strip()
                if (value.startswith('"') and value.endswith('"')) or (
                    value.startswith("'") and value.endswith("'")
                ):
                    value = value[1:-1]
                result[key] = value
                current_map = None
            continue

        if current_map and line.startswith(" "):
            m_kv = re.match(r"^\s+([A-Za-z0-9_-]+):\s*(.*)$", line)
            if m_kv:
                subkey = m_kv.group(1)
                subval = m_kv.group(2).strip()
                if (subval.startswith('"') and subval.endswith('"')) or (
                    subval.startswith("'") and subval.endswith("'")
                ):
                    subval = subval[1:-1]
                assert isinstance(result[current_map], dict)
                result[current_map][subkey] = subval
                continue

        # Unknown line format; ignore (keeps this parser permissive).

    return result


def validate_skill(skill_dir: Path) -> int:
    problems = 0

    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return 0

    text = skill_md.read_text(encoding="utf-8")
    split = _split_frontmatter(text, skill_md)
    if split is None:
        return 1

    front, _body = split
    fm = _parse_frontmatter(front)

    name = fm.get("name")
    desc = fm.get("description")

    if not isinstance(name, str) or not name.strip():
        _gh_error(skill_md, "Frontmatter field 'name' is required")
        problems += 1
    if not isinstance(desc, str) or not desc.strip():
        _gh_error(skill_md, "Frontmatter field 'description' is required")
        problems += 1

    if isinstance(name, str):
        if len(name) > 64:
            _gh_error(skill_md, "'name' must be <= 64 characters")
            problems += 1
        if not _NAME_RE.match(name):
            _gh_error(
                skill_md,
                "'name' must be lowercase alphanumeric with hyphens (e.g. 'webapp-testing'); no leading/trailing hyphen; no consecutive hyphens",
            )
            problems += 1
        if name != skill_dir.name:
            _gh_error(skill_md, f"'name' must match directory name ('{skill_dir.name}')")
            problems += 1

    if isinstance(desc, str) and len(desc) > 1024:
        _gh_error(skill_md, "'description' must be <= 1024 characters")
        problems += 1

    return 1 if problems else 0


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    skills_root = root / ".github" / "skills"

    if not skills_root.exists():
        print("No .github/skills directory; skipping.")
        return 0

    rc = 0
    for child in sorted(skills_root.iterdir()):
        if not child.is_dir():
            continue
        # Ignore common non-skill directories.
        if child.name.startswith("."):
            continue
        rc |= validate_skill(child)

    return rc


if __name__ == "__main__":
    raise SystemExit(main())
