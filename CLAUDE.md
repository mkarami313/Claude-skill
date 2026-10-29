# Claude skills repository

This repo is a source of Claude skills and a Claude Code plugin marketplace.

## Layout
- `skills/<name>/SKILL.md` — one folder per skill; optional `scripts/` and `references/` inside it.
- `.claude-plugin/marketplace.json` — one plugin entry per skill (`"source": "./"`, `"strict": false`, `"skills": ["./skills/<name>"]`).
- `README.md` — the skills table and install instructions.

## Adding or changing a skill
1. Folder name = `name` in the SKILL.md frontmatter (kebab-case). The `description` says what the skill does and when to use it.
2. Keep SKILL.md lean; move long checklists to `references/` and runnable code to `scripts/`, loaded or run only when needed.
3. No README inside a skill folder — documentation goes in the root README.
4. Add the skill to `marketplace.json` and to the table in `README.md`, and bump `metadata.version`.
5. Everything in this repo is written in English.
6. Scripts: bash with `set -u`, LF line endings, `bash -n` clean; Python 3 standard library only.
