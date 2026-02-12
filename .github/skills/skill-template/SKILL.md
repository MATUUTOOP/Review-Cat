---
name: skill-template
description: Template for authoring new skills in this repo. Use when creating a new .github/skills/<name>/SKILL.md.
metadata:
	category: authoring
	owner: p3nGu1nZz
	version: "0.1"
	tags: "template agent skills"
---

# Skill template

Copy this directory to a new skill folder and edit `SKILL.md`.

## Checklist

- [ ] Directory name is lowercase and uses hyphens
- [ ] `name` matches the directory name
- [ ] `description` says *what it does* and *when to use it*
- [ ] Add `metadata.category` and useful keywords in `metadata.tags`
- [ ] Keep `SKILL.md` concise; put long references in separate files

## Example skeleton

```md
---
name: my-skill
description: One sentence on what it does + when to use it.
metadata:
	category: docs
	tags: "keywords here"
---

# Skill: my-skill

## Steps

1. ...
```