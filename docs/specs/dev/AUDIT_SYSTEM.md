# Audit System (Dev + Runtime)

## Overview

The Audit System records developer cycles and runtime review runs so that
changes are reproducible and auditable.

## Bundle structure (dev: `dev/audits/<audit_id>/`)

```
dev/audits/<audit_id>/
├── meta.json          # Audit metadata (issue, branch, timestamp)
├── audit.json         # Top-level AuditRecord
├── worker.json        # Worker execution metadata (container id, image tag)
├── ledger/            # Prompt ledger files (one file per persona invocation)
├── patches/           # patch/diff files
├── build.log          # Build output
├── test.log           # Test output
└── summary.md         # Human-readable summary
```

## Index example (`dev/audits/index.json`)

```json
{
  "audits": [
    {
      "id": "20260212-113000-issue-29",
      "timestamp": "2026-02-12T11:30:00Z",
      "task_type": "doc",
      "issue_number": 29,
      "branch": "feature/docs/batch-specs-20260212",
      "pr_number": 31,
      "status": "success",
      "build_passed": true,
      "test_passed": true,
      "agents_invoked": ["coder", "qa"]
    }
  ]
}
```

## Prompt ledger format

- Command invoked (copilot CLI invocation)
- Full prompt text (markdown)
- Stdout/stderr captured
- Exit code and duration
- Timestamps

## Retention & cleanup

- Dev audit bundles are versioned and kept in `dev/audits/` (committed)
- Runtime audit bundles are stored at `~/.reviewcat/audits/` and subject to
  configurable retention (`reviewcat.toml`)

## Integration notes

- The Director should update the index atomically and record the bundle on
  each successful or failed cycle.
- Prompt ledger files must avoid secrets.

**Phase:** Phase 0 (dev audits)  
**Component:** Audit System  
**Priority:** High
