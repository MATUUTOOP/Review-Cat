# GitHubOpsSystem

## Overview

`GitHubOpsSystem` integrates ReviewCat with GitHub via the `gh` CLI.

## Requirements

1. Must fetch PR metadata and diff.
2. Must optionally post a unified comment.
3. Must never perform GitHub mutations unless explicitly enabled.

## Interfaces

- `fetch_pr_diff(repo, pr_number|url) -> diff_text`
- `post_pr_comment(repo, pr_number, body) -> url`

## Acceptance criteria

- Without `--comment` or explicit enablement, system performs no writes to GitHub.
- If `gh` is missing or unauthenticated, system fails gracefully and suggests `gh auth login`.

## Test cases

- Replay mode stubs gh calls.

## Edge cases

- PR from fork.
- Large PR diff.

## Non-functional constraints

- No token storage.
- Redact sensitive content before posting.
