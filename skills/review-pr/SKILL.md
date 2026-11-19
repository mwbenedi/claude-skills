---
name: review-pr
description: Review someone else's code changes on a pull request or branch for correctness, factoring, idiom and consistency, clarity and types, prose and comment quality, performance, test value, ADR and convention compliance, and maintainability, present the findings for me to choose from, and on my go-ahead post them as a GitHub review with comments on the affected lines. Use when I share a PR link or number, say "review this PR" or "review <branch>", or invoke /review-pr. For my own changes, use review-mine.
---

# Review a PR

Review another person's change, discuss the findings with me, then post the ones I pick as a GitHub review.

First read `~/.claude/skills/_shared/review-method.md` and follow it for scope, focus areas, verification and severity.

## Phase 1: review (read-only)

1. **Identify the PR.** Accept a URL, a number or a branch name. For a branch, find its PR with `gh pr list --head <branch>`. If there is no PR, review the branch against its base and tell me that posting needs a PR.
2. **Fetch it without disturbing my working tree.** Run `gh pr view <n> --json title,body,baseRefName,headRefName,headRefOid,files`, then `git fetch origin <head> <base>` and diff `origin/<base>...origin/<head>`. Read files at the PR head with `git show origin/<head>:<path>`. Don't check out the branch.
3. **Read the PR description.** It may say what is intentionally deferred, for example in a stacked series. Don't report work the author says lands later, but do ask about it if the deferral itself looks risky.
4. **Review and verify** per the method. Also note existing review comments (`gh api repos/{owner}/{repo}/pulls/<n>/comments`) so you don't repeat what someone already raised.
5. **Present the findings** as the method describes, then stop and wait. Don't post anything in this phase.

## Phase 2: post (only after I say go)

I'll say which findings to include (for example "1, 2, 5" or "all") and possibly how to post them. Default to comments on the affected lines.

- **Line comments.** Post one review through the API, so it is a single notification with every comment anchored to the head commit:
  `gh api -X POST repos/{owner}/{repo}/pulls/<n>/reviews --input payload.json` with `commit_id` (the PR's `headRefOid`), `event`, `body`, and `comments: [{path, line, side: "RIGHT", body}]`. Build the payload with a script (for example Python `json.dump`) written to the scratchpad, not hand-escaped shell. For a range, add `start_line`.
- **A comment can only anchor to a line in the diff.** Put findings about unchanged lines or files outside the PR in the review `body`, with their `file:line`.
- **One finding that spans several spots** becomes one comment per spot, each self-contained.
- **A general comment**, if I ask for one instead: `gh pr review <n> --comment --body-file <file>`.
- **Event.** Use `COMMENT` unless I explicitly say approve or request changes.
- **Write for the author, not for me.** Keep each comment self-contained: say what is wrong, the failure scenario, and a suggested fix. Cite the server or other code being compared by symbol name. Be direct and collegial, and mark latent issues as latent. Phrase it as a question when you're unsure whether something is intended. Before posting, tell me in one line who the comments are written for.
- **Verify after posting.** List the review's comments (`gh api repos/{owner}/{repo}/pulls/<n>/comments`, filtered by `pull_request_review_id`) to confirm each one landed on the intended line. Report the review URL and a table of finding → file:line.

## Gotchas

- A submitted GitHub review can't be deleted, only edited (`PUT .../reviews/<id>` with a new `body`). Line comments can be deleted individually. Get the content right before posting, and if you have to redo a review, ask before editing or removing the old one.
- `.line` reads back as `null` from the review-comments endpoint. Check anchors through `pulls/<n>/comments` instead.
- Posting is outward-facing. Never post, edit or resolve anything on GitHub without my go-ahead in the current conversation.
