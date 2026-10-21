---
name: wiki-consolidation-pattern
description: Build a navigation INDEX.md from scattered Empire markdown files.
version: 1.0.0
license: MIT
---

# Wiki Consolidation Pattern for Empire Projects

## When to Use

Consolidate Empire project markdown into a single navigation wiki — e.g., first-run onboarding, new agent session bootstrap, or cross-project handover prep.

## Procedure

1. **Find candidate files**
   ```bash
   find "F:\The Empire ecosystem" -maxdepth 3 -name '*.md' -type f \
     | grep -v '/agent-runs/' | grep -v '/.claude/' | sort
   ```

2. **Read governance spine first** (always these four):
   - `The Empire Goverence System/Empire-System-Doctrine.md`
   - `The Empire Goverence System/HANDOVER.MD`
   - `AGENT-STATUS-2026-09-04.md`
   - `CLAUDE.md` (harness)

3. **Read project-level changelogs & key docs** per project map in Doctrine.

4. **Flag secret files — never expand**. Reference by path + sha256 only (from `C:\Users\Kahrman\.empire\vault\MANIFEST.txt`).

5. **Write INDEX.md** to `F:\The Empire ecosystem\wiki\INDEX.md` with sections:
   - Read this first (governance spine)
   - Project map table (folder, role, feeds, key docs, status)
   - Key sessions/changelogs
   - Tooling & runtime
   - Secret files (paths + hashes only)
   - Standing rules
   - Decisions to track

## Pitfalls
- Grep the full tree before assuming file locations — Empire layout is mixed (some projects under `Empire Active Projects\`, others at root).
- Never read vault files into the wiki; the manifest gives paths + hashes, that's the safe reference.
- Exclude `agent-runs/` and `.claude/` — they are ephemeral run artifacts, not durable knowledge.
- The Colocation Law applies: write the wiki to the project's designated folder (`wiki/` at ecosystem root), not scattered.

## Canonical example

`F:\The Empire ecosystem\wiki\INDEX.md` (2026-10-19) — generated from this pattern. Use as the reference structure for future consolidations.