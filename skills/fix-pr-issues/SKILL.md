---
name: fix-pr-issues
description: Address the review comments on my own pull request. Walks me through each open comment one at a time so I can choose fix, reply or ignore, then commits and pushes the fixes, replies briefly on each addressed comment, and resolves any merge conflicts with the base branch. Use when I say "address the PR comments", "fix the PR feedback", "go through the review on my PR", or invoke /fix-pr-issues. To review someone else's PR, use review-pr.
---

# Fix PR issues

Work through the open feedback on my PR with me, one comment at a time. Then ship the result: commit, push, reply on GitHub, and make sure the PR can merge into its base.

## Phase 1: gather

1. **Identify the PR.** Accept a URL, a number or a branch name. With no argument, use the PR for the current branch (`gh pr view --json number`).
2. **Get the working tree ready.** Run `gh pr view <n> --json number,title,url,headRefName,baseRefName,headRefOid,mergeable,mergeStateStatus`. If I'm not on the PR's head branch, check it out with `gh pr checkout <n>`, but only if my tree is clean. Otherwise stop and tell me. Then `git pull --ff-only` so the fixes start from the latest remote head. If that fails because the local and remote branches have diverged, stop and ask.
3. **Collect the open feedback.**
   - **Review threads**, with GraphQL `repository.pullRequest.reviewThreads`: get `id`, `isResolved`, `isOutdated`, `path`, `line`, `originalLine`, and `comments { databaseId author { login } body createdAt }`. Skip resolved threads. Also skip threads whose last comment is mine, because I already answered them.
   - **Review summaries** (`gh api repos/{owner}/{repo}/pulls/<n>/reviews`) that have a non-empty `body`.
   - **General PR comments** (`gh api repos/{owner}/{repo}/issues/<n>/comments`) from anyone but me. Skip any I've already replied to below.
   - Include comments from bots (linters, AI reviewers), but mark them as from a bot. Skip pure status noise such as CI, deploy-preview and coverage reports.
4. **Tell me what you found:** the number of open items by type and author, then start the walkthrough. If nothing is open, say so and go straight to Phase 3's conflict check.

## Phase 2: walk through, one comment at a time

For each item, oldest first and grouped by file:

1. **Show it:** the author, `file:line` as a clickable link (use `originalLine` and say the thread is outdated if it is), the comment text, and the code it refers to as it is now.
2. **Give your take** in one or two sentences: is the comment right, and what is the smallest change that addresses it? Check the claim against the code first. Don't assume the reviewer is right or wrong.
3. **Ask me** with AskUserQuestion: **Fix**, **Reply** or **Ignore**, with your recommendation first. Put the proposed change or the draft reply in the option's preview.
   - **Fix:** make the change, keeping it minimal and in the surrounding style, and show me the diff. Draft the reply ("Fixed: …") for later.
   - **Reply:** no code change. Agree the reply text with me, for example an answer to a question or why we're keeping the code as it is.
   - **Ignore:** no change and no reply.
4. Record the decision and move to the next item. I can say "back", "skip" or "stop" at any time. On "stop", go to Phase 3 with what has been decided.

Don't commit, push or post anything during this phase.

## Phase 3: ship

1. **Summarize and confirm once.** Show a table: item → decision → reply text. Include the commit message and say whether you'll push. Wait for my go-ahead. One go-ahead covers everything in this phase.
2. **Test.** If any fixes were made, run the tests for the files touched. Follow the project's own instructions for running tests (for example its `CLAUDE.md`). If they fail, stop and show me the failure.
3. **Commit** all fixes in one commit with a short message that describes the changes, not the review. Skip this step if nothing changed.
4. **Check for merge conflicts with the base.** Use the PR's `baseRefName`, not an assumed `main`. If `mergeable` is `UNKNOWN`, wait a few seconds and query again. If it is `CONFLICTING`, or `git merge-tree --write-tree origin/<base> HEAD` reports conflicts after `git fetch origin <base>`:
   - Run `git merge origin/<base>`. Rebase only if the repo's conventions call for it, because a rebase needs a force push.
   - Resolve each conflict by understanding what both sides intended. Keep both changes where they're compatible. Don't simply pick one side.
   - Show me each non-trivial resolution: anything beyond imports, lockfiles, or edits that only sit next to each other. Get my OK before continuing.
   - Rerun the affected tests, then finish the merge commit.
5. **Push** with a normal `git push`. Never force push without my explicit OK. If the push is rejected because the remote moved, fetch, merge, retest and tell me before pushing again.
6. **Reply on GitHub**, only after the push succeeds, so a reply never points at a commit the reviewer can't see.
   - Review threads: `gh api -X POST repos/{owner}/{repo}/pulls/<n>/comments/<root comment databaseId>/replies --input payload.json`.
   - Review summaries and general comments: post one issue comment that @mentions each author and briefly answers each point.
   - Build the payloads with a script (for example Python `json.dump`) written to the scratchpad, not hand-escaped shell.
   - Don't resolve threads unless I ask. Reviewers usually resolve their own threads.
7. **Report** the commit SHA(s), whether a merge was needed, a table of comment → action → reply link, and anything left unaddressed.

## Writing the replies

- Write for the reviewer. Keep each reply to about two sentences, direct and specific.
- Fix: "Fixed in `<short sha>`: <what changed>." Add a reason only if the change differs from what the reviewer suggested.
- Reply: answer the question or give the reason, without hedging or padding.
- Don't thank the reviewer in every reply or restate their comment.
- Before posting, tell me in one line who the replies are written for.

## Gotchas

- Replies only work on a thread's top-level comment ID. A reply to a reply returns 404, so use the first comment's `databaseId` from the thread.
- An outdated thread's `line` is `null`. Use `originalLine` to show where it was, and read the current code to see whether it still applies.
- `mergeable` is computed lazily and is often `UNKNOWN` on the first query after a push.
- Posting, pushing and resolving are outward-facing. Do none of them without the Phase 3 go-ahead in the current conversation.
