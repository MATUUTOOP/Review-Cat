# ToolUISystem

## Overview

`ToolUISystem` defines a minimal, dependency-light UI layer for ReviewCat tools.

It exists to avoid external immediate-mode UI frameworks (e.g., Dear ImGui) while still providing:

- readable, consistent text rendering (bitmap glyph font)
- simple UI primitives (lines/rects)
- a small “panel/window” model with explicit z-index layering
- top/bottom single-line status bars for hotkey help and focused-view state

This system is intended to be shared by:

- the runtime app UI (`reviewcat ui`)
- the dev harness operator UI / swarm visualizer (`SwarmVisualizerSystem`)

## Requirements

1. **Bitmap glyph font (baseline text rendering)**
   - Must provide a fixed-size bitmap font intended for tool overlays.
   - Baseline glyph size: **5×7** pixels per character (scalable by integer factor).
   - Supported characters (MVP):
     - `0–9`, `A–Z` (case-insensitive input)
     - space and a core punctuation set used by status bars and logs: `: - _ / . , ( ) | ? = + * # @ ! [ ] < > \\ ~`
   - Must provide:
     - `measure_text_width(text, scale)`
     - `count_text_lines(text)`
     - `draw_text(renderer, x, y, text, color, scale)`

2. **Hex color helpers (programmatic theming)**
   - Must support specifying UI colors via hex codes.
   - Accepted formats (MVP):
     - `#RRGGBB` (opaque)
     - `#RRGGBBAA`
     - `0xRRGGBB` / `0xRRGGBBAA`
   - Invalid inputs must fall back to a safe default (e.g., magenta for visibility) and be logged (without spamming).

3. **Draw primitives (SDL3-backed)**
   - Must support drawing the following primitives (2D overlay):
     - filled rectangles
     - rectangle outlines
     - lines
     - text (via bitmap font)
   - Rendering must be deterministic given the same inputs (no hidden frame-order dependencies).

4. **Layering and z-index (explicit ordering)**
   - Must define a small set of UI layers, at minimum:
     - `World` (scene/viewport)
     - `Overlay` (panels, inspectors)
     - `StatusBars` (top/bottom bars)
     - `Modal` (confirmations)
   - Must allow ordering of overlays via a **z-index** (integer) within a layer.
   - Input focus must track the active panel/view and be surfaced to the bottom status bar.

5. **Panel/window model (MVP)**
   - Must support bordered tool panels with:
     - title line
     - body region
     - focus highlight state
   - Panel layout can be fixed-position in MVP.
   - Optional (future): dragging/resizing.

6. **Status bars (top and bottom)**
   - Must render a **top** single-line status bar used for hotkey/help text.
   - Must render a **bottom** single-line status bar used for focused panel/view state and current status.
   - Status bars must remain visible regardless of world/scene camera state.

## Interfaces

This spec intentionally stays at the interface level. A plausible public surface for the C++ implementation:

- `toolui::Glyph` representation: 7 rows of 5-bit data (implementation detail)
- `toolui::Color` / `toolui::parse_hex_color(std::string_view)` returning an `SDL_Color`
- `toolui::DrawList` or direct draw calls that write to an SDL3 renderer
- `toolui::PanelId`, `toolui::PanelState{rect,z,focused,title}`
- `toolui::FrameState{focused_panel, hotkey_help_text, status_text}`

## Acceptance criteria

- A sample overlay can render:
  - a top status bar showing hotkey helper text (e.g., `F1 Help  F2 Filters  F3 Logs  ...`)
  - a bottom status bar showing the current focused panel/view state (e.g., `Focus: Inspector | Conn: OK | Msg/s: 120`)
  - at least two bordered panels with different z-index ordering
  - multi-line text blocks (logs) with correct line wrapping behavior (by `\n`)
- Colors can be set via hex strings and produce correct RGBA output.
- Unsupported characters render as a visible placeholder glyph.

## Test cases

- Parse color:
  - `#112233` → `(0x11,0x22,0x33,0xFF)`
  - `#11223344` → `(0x11,0x22,0x33,0x44)`
  - invalid (`"#GG"`, empty) → fallback color
- Text measurement:
  - empty string returns width 0
  - `"A\nB"` returns max width of a single glyph advance and line count 2
- Layer ordering:
  - a modal panel must always render above overlay panels

## Edge cases

- Very long status bar text: must truncate or clip safely (no overflow).
- High scale factors: must not cause integer overflow in coordinate math.
- Unknown characters: render placeholder glyph and continue.

## Non-functional constraints

- No third-party UI framework dependency.
- Keep per-frame allocations minimal (MVP can be simple; optimize later).
- Rendering must be stable across platforms supported by SDL3.
