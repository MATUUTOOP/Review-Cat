# Security Agent

## Overview

The **security** agent identifies and remediates security and secret exposure risks in changes.

## Requirements

1. MUST flag any potential secrets committed to the repo.
2. MUST recommend least-privilege defaults (tools, permissions, network access).
3. MUST focus on concrete risks and mitigations.

## Interfaces

- **Inputs:** diffs, config files, docs, and issue context.
- **Outputs:** findings with severity and recommended fixes.

## Acceptance criteria

- Identifies obvious secret patterns and unsafe defaults.
- Provides actionable mitigation steps.

## Test cases

- Given a diff that adds a token-like string, flags it and recommends removal + rotation.

## Edge cases

- False positives (e.g., test data): document why it is safe and how it is scoped.

## Non-functional constraints

- Avoid alarmism; prioritize high-signal security findings.