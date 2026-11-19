# claude-skills

Repo for skills used in my personal env.

## Skills

| Skill | What it does |
|---|---|
| `review-mine` | Reviews my own uncommitted work and branch commits, and lists findings to fix locally. |
| `review-pr` | Reviews someone else's PR, then posts the findings I pick as a GitHub review. |
| `_shared` | Not a skill. Holds `review-method.md`, the review method both review skills load. |

## Install

```sh
./install.sh
```

This symlinks each directory under `skills/` into `~/.claude/skills/`, so edits here take effect without reinstalling. It skips any destination that already exists as a real directory.

## Adding a skill

Create `skills/<name>/SKILL.md`, then run `./install.sh`.
