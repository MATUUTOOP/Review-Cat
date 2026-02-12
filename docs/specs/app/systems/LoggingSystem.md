# LoggingSystem

## Overview

`LoggingSystem` provides structured, leveled logging for both the C++ runtime
application and the bash development harness. It is active from Phase 0 onward
— not deferred to polish.

Two implementations coexist:

1. **Bash logging** (`scripts/harness/log.sh`) — sourced by all harness scripts.
2. **C++ logging** (`spdlog`) — used by the compiled `reviewcat` binary.

Both share a common log format and never log secrets or tokens.

## Requirements

1. Must provide leveled logging: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`.
2. Must write to both console (stderr) and rotating log files.
3. Must support structured format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] [component] message`.
4. Must never log tokens, PATs, passwords, or sensitive environment variables.
5. Must support runtime log level selection (CLI flag or config).
6. Must provide a UI log sink for the Log Viewer panel (Phase 6) using the project’s custom ToolUI text renderer (no Dear ImGui dependency).
7. Must be lightweight — no blocking I/O on the hot path.

## Interfaces

### Bash (`scripts/harness/log.sh`)

```bash
source scripts/harness/log.sh

log_info  "director" "Heartbeat #42 starting"
log_warn  "worktree" "Worker slot at capacity (3/3)"
log_error "run-cycle" "Build failed for issue #17"
log_debug "monitor" "Checking worktree at ../Review-Cat-agent-17-..."
```

Output goes to stderr and appends to `dev/audits/director.log`.

### C++ (`spdlog`)

```cpp
#include <spdlog/spdlog.h>

auto logger = spdlog::rotating_logger_mt("reviewcat",
    "~/.reviewcat/reviewcat.log", 1048576 * 5, 3);
spdlog::set_default_logger(logger);

spdlog::info("Starting review pipeline for {}", repo);
spdlog::warn("MCP server timeout, falling back to gh CLI");
spdlog::error("Build failed in worktree {}", worktree_path);
```

### Configuration

| Setting | Source | Default |
|---------|--------|---------|
| Log level | `--log-level` CLI flag or `reviewcat.toml` | `info` |
| Log file (dev) | Hardcoded | `dev/audits/director.log` |
| Log file (app) | `reviewcat.toml` or default | `~/.reviewcat/reviewcat.log` |
| Max file size | Hardcoded | 5 MB |
| Max rotated files | Hardcoded | 3 |

## Acceptance criteria

- All harness scripts source `log.sh` and use `log_*` functions.
- Director daemon logs every heartbeat iteration.
- C++ binary creates `~/.reviewcat/reviewcat.log` on first run.
- `--log-level debug` enables debug output without recompilation.
- No tokens appear in any log file (verify via grep in tests).
- Log Viewer panel (Phase 6) displays live log output.

## Test cases

- Verify log file rotation at 5 MB boundary.
- Verify `--log-level error` suppresses info/debug messages.
- Verify no PAT/token appears in log output after a full pipeline run.
- Verify bash `log_*` functions write to both stderr and file.

## Edge cases

- Log directory does not exist (must create `~/.reviewcat/` on first use).
- Disk full — degrade gracefully (console-only).
- Concurrent writes from multiple worktree agents (bash: append is atomic for
  short lines; C++: spdlog is thread-safe).

## Non-functional constraints

- spdlog is header-only — no extra runtime dependency.
- Log file I/O must not block the review pipeline.
- Bash logging adds < 1ms overhead per call.
