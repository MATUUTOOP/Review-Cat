# Skill: memory-query

**Name:** memory-query

**Summary / Purpose:**
Provides a standardized interface to query engrams (`/memory/st` + `/memory/lt`)
and the `MEMORY.md` focus view.

**Owner:** @p3nGu1nZz

**Inputs:**
- query string (keywords, filters, date ranges)

**Outputs:**
- search results in JSON or markdown summary

**Examples:**
- `memory-query "recent consensus on retry-policy" --format=json`

**Acceptance Criteria:**
- Returns matching engrams and `MEMORY.md` snippets with provenance.

**Testing Plan:**
- Unit: parse small engram samples
- Integration: query over `test/fixtures/replays` with expected matches

**Related Specs / Docs:**
- `docs/specs/dev/components/SkillsLibrary.md`
- `AGENT.md` (memory agent)
