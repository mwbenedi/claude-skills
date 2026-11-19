---
name: review-mine
description: Review my own code changes (uncommitted work and/or the commits on my current branch) for correctness, factoring, idiom and consistency, clarity and types, prose and comment quality, performance, test value, ADR and convention compliance, and maintainability, and list the findings so I can fix them locally. Use when I say "review my changes", "review my branch", "check my code before I push", or invoke /review-mine. Does not post anything to GitHub. To review someone else's PR, use review-pr.
---

# Review my changes

Review the code I wrote and report what I should fix. The output is a list for me to work through locally. Nothing is posted anywhere.

First read `~/.claude/skills/_shared/review-method.md` and follow it for scope, focus areas, verification and severity.

## Steps

1. **Work out what to review.** Default: everything on the current branch that isn't on its base, plus uncommitted and staged changes. Find the base as the method describes. If a PR is open for the branch (`gh pr view --json baseRefName`), use its base. If I pass arguments (a path, a commit range, "just uncommitted", focus areas), they narrow the scope or override the focus areas.
2. **Read the diff** (`git diff <base>...HEAD` plus `git diff HEAD`), then the code around it as needed.
3. **Review and verify** per the method.
4. **Present the findings** as the method describes, with `file:line` links so I can jump to each one in the editor.

## After presenting

- Don't change any code unless I ask. I'll usually fix things myself.
- If I say "fix N" or "fix all", make those fixes, keep each one minimal and in the surrounding style, run the relevant tests, and report what changed and whether the tests passed.
- Don't commit or push unless I ask.
