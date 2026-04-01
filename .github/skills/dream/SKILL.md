---
name: dream
description: "Performs a reflective memory consolidation pass at session end. Use when: ending a session, finishing a feature, after a significant investigation, or when handoff context needs updating. Consolidates .agent/memory/, promotes stable facts to .docs/, and updates .agent/memory/NOW.md so the next session can orient immediately."
argument-hint: "Optional: topic or focus area for the consolidation pass"
---

# Dream

Perform a reflective pass over working memory and durable docs. The goal: leave a clean handoff and promote stable knowledge so future sessions orient quickly and resume without re-investigation.

## Storage Layers

| Layer | Path | What goes here |
|-------|------|----------------|
| Durable docs | `.docs/` | Stable facts: architecture, game design, build system, environment, workflows |
| Working memory | `.agent/memory/` | Session dumps, investigation trails, open questions, command snippets, partial conclusions |
| Memory index | `.agent/MEMORY.md` | Index only — one-line links to both `.agent/memory/` and `.docs/` files |
| Handoff | `.agent/memory/NOW.md` | Canonical resume file — always current |

**Classification rule:** If it should still matter after the current task is forgotten → `.docs/`. If it helps resume current work → `.agent/memory/`. If both → stable conclusion in `.docs/`, trail in `.agent/memory/`.

## Procedure

1. **Survey** — Read `.agent/MEMORY.md` and skim recent `.agent/memory/` files to understand what's active.

2. **Promote stable facts** — Move any conclusions that belong in `.docs/` into the right file:
   - Architecture, engine internals → `.docs/ARCHITECTURE.md`
   - Build/install flow → `.docs/BUILD.md`
   - Dev environment, config, Docker → `.docs/DEV-ENV.md`
   - Game design → `.docs/GAME.md`
   - Lua/Eluna patterns → `.docs/WOW-LUA-HELPERS.md`
   - Plans, milestones, implementation sequences → `.docs/plans/`

3. **Update `NOW.md`** — Overwrite `.agent/memory/NOW.md` with the current state. Include all six fields:
   - **Last Worked On** — what was just completed or investigated
   - **Next Work** — concrete next step
   - **Current Status** — one-line state (blocked / in progress / ready to resume)
   - **Key Files** — files that matter for resuming
   - **Useful Commands** — build, debug, test commands relevant to the active thread
   - **Open Questions / Blockers** — anything unresolved

4. **Prune working memory** — Remove or consolidate `.agent/memory/` dump files that no longer add value. Don't delete files that contain unresolved questions or partial work.

5. **Update `.agent/MEMORY.md`** — Keep it under ~50 lines. Sections:
   - `## Active Handoff` → link to `NOW.md` with one-line description
   - `## Working Memory` → indexed links to any active dump files
   - `## Durable Docs` → indexed links to `.docs/` files
   - `## Plans` → indexed links to `.docs/plans/` files

6. **Return a summary** — Briefly state what was promoted, updated, or pruned. If nothing changed, say so.

## Quality Checks

- `NOW.md` answers: what did we do, what's next, what files matter?
- `MEMORY.md` is scannable in under 30 seconds
- No stable facts stranded in `.agent/memory/` dump files
- No stale dump files cluttering working memory
