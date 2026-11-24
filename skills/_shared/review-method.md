# Code review method

Shared by the `review-mine` and `review-pr` skills. It covers how to find and verify issues. The skill that loaded it decides what happens to the findings.

## The bar

Ask of every change: is it idiomatic, correct, concise, clear, consistent, well-factored, well-tested and well-typed? Are all prose and comments high-value, high-signal, low-verbosity and free of external ticket IDs? Are the tests proportionate to the change, valuable, non-tautological, performant and minimally overlapping, and do they extend existing tests where they can? Is the approach maintainable, delightful and anxiety-reducing for end users and developers alike? Does it follow all of our ADRs? The focus areas below break this question into checks.

## Scope

- Review only what the change touches: the diff against its base, plus the code it calls or that calls it. Read surrounding code to judge the change, not to audit the rest of the file.
- Find the right base. For a stacked branch the base is the parent branch, not `main`. Use the PR's `baseRefName` when a PR exists, otherwise ask or use the merge-base with the default branch.
- Read the project's `CLAUDE.md`, the architecture docs it points to for the area touched, and the ADR register, if the repo has one. Open every ADR whose subject the change touches. A convention or decision the repo writes down is a valid finding. Personal taste is not.

## What to look for

Unless the user names other focus areas, cover all of these:

1. **Correctness.** The code does something other than what it intends, or other than what its comments and docstrings claim. Check edge cases (empty, null, boundaries, ordering, time zones), error paths, and whether a check runs before or after the state it depends on. When code says it mirrors another rule (a server validation, another module, a spec), open that rule and compare the two branch by branch. Divergences between "mirrors" are the most common real bug.
2. **Factoring and duplication.** The same check or computation done twice in one path, logic that already exists elsewhere in the codebase (search before claiming it is new), helpers placed in a module that doesn't fit their use, responsibilities split or merged at the wrong boundary, and old code the change makes obsolete but leaves in place.
3. **Idiom and consistency.** Code that fights the language, framework or the surrounding code: a hand-rolled version of something the framework or an existing helper provides, naming or structure that differs from its siblings for no reason, or a new pattern where the repo already has one. Cite the sibling or idiom being departed from.
4. **Clarity and types.** Code longer or harder to follow than it needs to be: indirection that buys nothing, unclear names, control flow that hides the main path. Types that are looser than the data (`any`, untyped hashes passed across boundaries, nullable where it can't be null, a string where an enum exists), or generated types not regenerated after a model or serializer change.
5. **Prose and comments.** Every comment, docstring, test name, log line, user-facing string and doc edit should be high-value, high-signal and low-verbosity. Flag comments that restate the code or narrate the change, stale or misleading text, and padding. Flag external ticket, Rollbar or PR IDs unless they track unfinished work or justify a suppression, with the reason inline.
6. **Performance.** N+1 queries, work inside loops or render paths that could be done once, unbounded queries or loads, and missing indexes for new query shapes. Judge the real cost: say plainly when something is wasted work that doesn't matter at realistic sizes, rather than inflating it.
7. **Tests.** Tests should be proportionate to the change, valuable, non-tautological, performant and minimally overlapping. They give a general confirmation that what the change adds works, not complete coverage. Start by weighing the tests against the change:
   - **Check proportion.** Compare the lines added to code with the lines added to tests (`git diff --numstat`). When the tests far outweigh the change, for example 2 lines of code and 80 lines of tests, report it with the counts. Propose the smallest set of tests that still covers the main behavior.
   - **Question whether a small change needs a new test.** A one- or two-line change often needs none, or only one assertion added to an existing test. Examples: a guard clause, a renamed field, a changed default or config value, or a fix whose behavior existing tests already pin. For each new test ask: would it catch a plausible future regression that nothing else catches? If not, recommend removing it.
   - **Prefer extending existing tests.** Before accepting a new test, search the existing test file for the class or method under change, and for nearby tests that already set up the state it needs. Suggest adding an assertion or a case to one of those instead. Flag a new test file for code that already has one, unless the existing file is clearly the wrong home.
   - **Remove** tests that add no value: ones that restate the implementation or assert the mock they just set up (tautological), check framework or library behavior, duplicate another test's assertions, or cover an edge case too unlikely to matter.
   - **Merge** tests that set up the same state, or that could reasonably check several behaviors at once, into one test with several assertions or a table of cases.
   - **Speed up** tests that are slower than they need to be: building records the assertion never reads, hitting the database or a browser where a unit test would do, or sleeping and polling.
   - **Flag a missing test** only when the change's main behavior, or a finding from the other areas, has no test at all. Don't ask for coverage of every branch.

   For each test finding, name the tests involved and say whether to remove, merge, fold into an existing test, or speed them up. When suggesting a merge or a fold, name the target test and sketch the combined test or the added assertion in a line or two.
8. **Conventions and ADRs.** The change contradicts a written convention (`CLAUDE.md`, architecture docs, convention tests) or an accepted ADR. Name the ADR or doc and the rule. If the change makes a decision that deserves an ADR and doesn't add one, say so.
9. **Maintainability and experience.** Would the next developer change this with confidence, and would an end user trust what they see? Flag surprising behavior, silent failures, error messages that don't say what to do, states the user can't tell apart (loading vs empty vs failed), destructive actions without confirmation or undo, and code whose correctness depends on knowledge nothing in the code or docs records.

## Verify before reporting

- Every correctness, performance or test-gap finding needs a concrete failure scenario: the input or state, and the wrong result. If you can't write one, it is a style note or nothing.
- Every quality finding (areas 2–5, 7–9) needs a concrete cost instead: what a reader misreads, what a future change breaks, what a user is confused or worried by, or which written convention or ADR it contradicts. "I'd write it differently" is not a cost.
- Confirm claims by reading the code, not by inference from names. When cheap, prove it: run a snippet, a test, or a query.
- Say when an issue is latent (it can't happen with today's data or callers but will when X changes), and still report it if X is plausible.
- Drop findings that a later part of the change or the stack already handles, and say you checked.
- If you used a sub-review (an agent or another skill), re-check its findings yourself before presenting them.

## Severity

Rank each finding:

- **High**: wrong results, data loss, security exposure, or a crash on a realistic path.
- **Medium**: wrong behavior on an edge case users can reach, a misleading comment that will cause a future bug, a contradicted ADR, a user-facing flow that fails silently or alarms the user, or new tests far out of proportion to a small change.
- **Low**: latent issues, redundancy, minor inefficiency, misplaced code, non-idiomatic or unclear code, loose types, low-signal prose, ticket IDs, and slow or overlapping tests.

## Presenting findings

Number the findings so the user can pick by number. Group them by focus area, most severe first. For each one give the file and line as a clickable link, one or two sentences on what is wrong, the failure scenario or cost, and a suggested fix. Close with a short "checked and found correct" list so the user knows what was covered, including which ADRs you checked against, and say plainly if nothing worth raising turned up.
