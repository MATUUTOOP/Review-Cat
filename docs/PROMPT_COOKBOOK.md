# Prompt Cookbook

This is a curated set of prompt patterns used by ReviewCat.

> **Context:** Prompts are invoked via `copilot -p "prompt"` subprocess calls —
> from **bash scripts** (dev harness) and from the **C++ binary** (runtime app).
> Agents use the **GitHub MCP Server** for issue/PR operations when configured.
> See [PLAN.md](../PLAN.md) §4.3 for integration details.

The intent is consistency and auditable prompt engineering.

## Persona prompt contract

All persona prompts must request output in strict JSON, as an array of findings.

Each finding:

- file
- line_start
- line_end
- severity: critical|high|medium|low|nit
- title
- description
- rationale
- suggested_fix
- suggested_patch (optional, unified diff)
- confidence: 0.0..1.0

## Persona: security

Prompt pattern:

- Input: diff hunks and minimal context.
- Output: vulnerabilities, exploitability, unsafe defaults, data leak risks.
- Require: at least one concrete fix suggestion per finding.

## Persona: performance

Prompt pattern:

- Focus on algorithmic complexity, hot paths, allocations, I/O.
- Require: explain impact and conditions.

## Persona: architecture

Prompt pattern:

- Focus on module boundaries, naming, dependency direction.
- Require: propose refactors only if they reduce complexity.

## Persona: testing

Prompt pattern:

- Identify missing tests and propose concrete test cases.

## Persona: docs

Prompt pattern:

- Identify missing usage docs and confusing behaviors.

## Synthesis prompt

Prompt pattern:

- Input: all persona JSON outputs.
- Output:
  - unified review markdown
  - merged finding list with dedupe rationale
  - action plan JSON suitable for GitHub issues

## Patch planning prompt

Prompt pattern:

- Input: prioritized findings.
- Output: small safe patches.
- Constraints:
  - avoid broad refactors
  - prefer tests first
  - no unrelated formatting changes

## Coder Agent Prompt (Issue → Fix → PR)

Prompt pattern for the coding agent that closes the review→fix loop:

```
copilot -p @dev/agents/coder.md \
  "Fix issue #<N> on <REPO>. \
   Read the issue description via GitHub MCP tools. \
   Understand the problem, implement a fix in C++17/20, \
   write Catch2 tests, and create a PR that Closes #<N>. \
   Follow project conventions: nlohmann/json for JSON, \
   toml++ for config, CMake build system." \
  --mcp-config github-mcp.json \
  --allow-tools write
```

Key elements:
- References the issue number for GitHub MCP to fetch context.
- Specifies the tech stack for code generation.
- Includes `--mcp-config` for issue/PR operations.
- Uses `--allow-tools write` for file creation.

## Code Review Prompt (PR Review)

```
copilot -p @dev/agents/code-review.md \
  "Review the diff on PR #<N> via GitHub MCP. \
   Check for: C++ best practices, memory safety, error handling, \
   consistent naming, CMake target correctness. \
   Post a review comment on the PR via GitHub MCP tools." \
  --mcp-config github-mcp.json
```

## Docs Agent Prompt

```
copilot -p @dev/agents/docs.md \
  "Update documentation for the changes in issue #<N>. \
   Read the issue and PR via GitHub MCP. \
   Update README.md, relevant docs/, and code comments." \
  --mcp-config github-mcp.json \
  --allow-tools write
```

## DirectorDev Planning Prompt

Prompt pattern:

- Input: a spec file from `docs/specs/`.
- Output:
  - task graph
  - role assignments
  - exact acceptance criteria mapping

## DirectorDev Heartbeat Prompts

The Director daemon (`dev/harness/director.sh`) uses these prompt patterns
when delegating to role agents:

### Implementer

```
copilot -p @dev/agents/implementer.md \
  "Implement the following spec: <spec content>. \
   Write C++17/20 code under app/src/. Use nlohmann/json for JSON, \
   toml++ for config, Catch2 for tests. Follow CMake build conventions." \
  --allow-tools write
```

### QA

```
copilot -p @dev/agents/qa.md \
  "Write Catch2 tests for the spec: <spec content>. \
   Tests go under app/tests/. Use record/replay fixtures where Copilot \
   CLI responses are needed." \
  --allow-tools write
```

### Security

```
copilot -p @dev/agents/security.md \
  "Security review the changes for: <spec content>. \
   Check for: buffer overflows, unsafe subprocess calls, credential \
   exposure, path traversal."
```

### Code Review

```
copilot -p @dev/agents/code-review.md \
  "Review this diff: <git diff output>. \
   Check for: C++ best practices, memory safety, error handling, \
   consistent naming, CMake target correctness."
```

## Self-Review Prompts

### Self-Review Persona Pass

Used by `dev/harness/review-self.sh` to review ReviewCat's own code:

```
copilot -p @dev/agents/<persona>-review.md \
  "Review the following code changes for <persona> concerns. \
   Output findings as a JSON array with fields: \
   title, description, severity, file, line_start, suggested_fix. \
   Severity must be one of: critical, high, medium, low, nit." \
  --stdin <<< "$DIFF"
```

### Issue Creation from Self-Review Findings

Used to create GitHub Issues for critical/high findings:

```
copilot -p \
  "Create a GitHub Issue on <REPO> with: \
   Title: '[<persona>] <finding_title>' \
   Body: '<finding_description>\n\n**Suggested fix:** <suggested_fix>' \
   Labels: agent-task, <persona>, auto-review, priority-<severity>. \
   Use GitHub MCP tools." \
  --mcp-config github-mcp.json
```

## GitHub MCP Integration Prompts

These prompts leverage the GitHub MCP Server for issue/PR operations:

### Create Issue

```
copilot -p \
  "Create a GitHub Issue on <REPO>. \
   Title: '<title>' \
   Body: '<body>' \
   Labels: <labels> \
   Use the create_issue GitHub MCP tool." \
  --mcp-config github-mcp.json
```

### Create Pull Request

```
copilot -p \
  "Create a Pull Request on <REPO>. \
   Head branch: '<branch>' \
   Base branch: 'main' \
   Title: '<title>' \
   Body: 'Closes #<issue_number>\n\n<description>' \
   Use the create_pull_request GitHub MCP tool." \
  --mcp-config github-mcp.json
```

### Claim Issue

```
copilot -p \
  "Update issue #<N> on <REPO>: \
   Add label 'agent-claimed'. \
   Remove label 'agent-task'. \
   Use the update_issue GitHub MCP tool." \
  --mcp-config github-mcp.json
```

### Merge Pull Request

```
copilot -p \
  "Merge PR #<N> on <REPO> using squash merge. \
   Use the merge_pull_request GitHub MCP tool." \
  --mcp-config github-mcp.json
```

## Prompt Design Principles

1. **Structured output** — Always request JSON with a defined schema.
   Include field names and allowed values in the prompt.
2. **Persona isolation** — Each persona prompt focuses on one concern area.
   Do not mix security and performance in a single prompt.
3. **Tech stack context** — Include the project's tech stack (C++17/20,
   CMake, nlohmann/json, toml++, Catch2) so agents generate idiomatic code.
4. **MCP-aware** — When agents need GitHub operations, include
   `--mcp-config github-mcp.json` and name the specific MCP tool to use.
5. **Repair prompts** — If JSON validation fails, re-prompt with the
   validation error and the original output for repair.
6. **Scope constraints** — Explicitly state what files/modules the agent
   may modify to prevent scope creep.
7. **Auditability** — All prompts and responses are logged to the prompt
   ledger for reproducibility and evidence.
