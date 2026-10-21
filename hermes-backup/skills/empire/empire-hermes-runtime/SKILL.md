---
name: empire-hermes-runtime
description: "Use for any Empire work. Runs empire-orchestrator on Hermes."
version: 1.0.0
author: Hermes Agent for Osama
metadata:
  hermes:
    tags: [empire, orchestrator, adapter]
    related_skills: [empire-orchestrator, empire-guardrails, empire-run-protocol, empire-verify, empire-docs-first]
---

# Empire on Hermes - runtime adapter

The Empire orchestrator was written for Claude Code. Its source of truth stays in `F:\The Empire ecosystem\.claude\` (skills + agents) and `C:\Users\Kahrman\.claude\skills\` (support skills: credit-watcher, giving-osama-tasks, platform-access-ladder under `synced\...`, etc.). Both are mounted into Hermes via `skills.external_dirs`, so edit them there, never copy them here. This file only translates Claude Code terms to Hermes. Where they conflict, the Empire files win on WHAT to do; this file wins on HOW in Hermes.

## Entry rule

For any request about Empire work (Fenix, Dalilek, Squillaci/Content, Empire-CRM, Command Center, AI income system, governance, leads, clients, sales, sweeps, status, handover), on any surface (CLI, Telegram, desktop):

1. `skill_view("empire-orchestrator")` and follow its triage (Phase 0) before answering.
2. `skill_view("empire-guardrails")` before anything that sends, publishes, spends, pushes, deletes, touches credentials or a live system.
3. Trivial / off-domain requests: answer directly (orchestrator triage 1). Do not load the stack for small talk or Hermes configuration questions.

## Term mapping

| Claude Code term in Empire files | Hermes equivalent |
|---|---|
| `Agent` tool, spawn `empire-builder` etc. | `delegate_task`, one task per agent. Context must open with: "Read and follow `F:\The Empire ecosystem\.claude\agents\<name>.md`. Load with skill_view: <the skills that agent file lists>." then the spawn brief (run folder, goal in Osama's words, project folder, writable paths, off-limits, prune list, files to produce, return format). Children know nothing else: repeat everything. |
| `general-purpose` fallback | Not needed; every delegate child is general-purpose. |
| `run_in_background` for independent runs | Several entries in one `delegate_task` call. Keep the Empire caps: max 3 at once, max 1 browser-driving child. |
| Reviewer `model: "fable"` / `claude-fable-5-1` pin | delegate_task has no per-child model. Children use `delegation.model` (empty = same as parent). The pin is NOT honoured on Hermes; independence comes from a fresh child that built nothing. Write this in STATUS.md `Concern:` for every run until Osama decides on a reviewer model. |
| `TeamCreate` / `TaskCreate` | Not used (same as in Claude). `todo_list` may track the orchestrator's own steps. |
| Read / Write / Edit / Glob / Grep / Bash / PowerShell | `read_file`, `write_file`, `patch`, `search_files`, `terminal` (git-bash, POSIX syntax; call `powershell.exe -NoProfile -Command ...` when a step needs PowerShell, e.g. `Read-Host -AsSecureString`). Guardrail 9 still applies: scoped paths only, never search from the `F:\The Empire ecosystem` root. |
| WebSearch / WebFetch | `web_search`, `web_extract`; `browser_exec` for logged-in pages (one browser only). |
| session scratchpad (reviewer sandboxes) | `C:\Users\Kahrman\AppData\Local\hermes\cache\scratch` |
| `anthropic-skills:<name>` / account skills | `skill_view("<name>")` - resolved from the mounted `~/.claude/skills`. If missing, apply guardrails section 7 and say the gate was not run. |
| `credit-watcher` (Claude plan limits) | Still run it before waves of 2+ children; on Hermes also note the active model/provider cost (default gemma4 via Ollama free plan; fallback OpenRouter `openrouter/free`). |

## Hermes-specific limits

- **The Colocation Law:** All files, logs, and outputs must be produced in the project's designated run folder. Do not scatter work across the system.
- **Path Verification Gate:** Before any `git push`, `git pull`, or sync operation, you MUST verify the current working directory matches the project root. If the local path is not the default, stop and report the drift.
- Delegate children skip auto-loaded skills and project context files: the brief is their only context.
- Scheduling stays outside the agent (orchestrator + `AGENT-STATUS-2026-09-04.md`): do not create Hermes cron jobs for Empire work without Osama's yes; propose a Task Scheduler entry instead, as the orchestrator says.
- Telegram replies: same 8-line close-out and one-ask rule (guardrails section 10); he reads on a phone.
- Child summaries are self-reports: the reviewer child and the evidence files decide, not the producer's message.

## Gap resolution workflow (Osama's standing preference)

- **One gap at a time.** Present the current gap, options, and wait for explicit decision before moving to the next. Never present a list of gaps.
- Each gap gets a decision record in `SOLE.md` (or the relevant handover) and, for reviewer model, a `Concern:` line in every run's `STATUS.md`.

## Telegram bot wiring — verified pattern

- Bot tokens live in User env vars: `FENIX_TG_BOT_A_TOKEN` (Leads @FenixLeads_bot), `FENIX_TG_BOT_B_TOKEN` (Content @FenixContent_bot), `SQUILLACI_TG_BOT_TOKEN` (Main @EmpireAgent_bot).
- **Verification priority:** `@EmpireAgent_bot` (main orchestrator) first, then `@FenixLeads_bot` / `@FenixContent_bot` (project-specific).
- **Pitfall:** A bot cannot send to a `chat_id` until that chat has sent `/start` to the bot (or the bot is added to the group/channel). `getUpdates` returns empty until then; `sendMessage` returns `400: chat not found`.
- Procedure: verify token with `getMe` → have Osama open the bot in Telegram and send `/start` → confirm `getUpdates` shows the chat → wire the endpoint (webhook or long-poll target).
- Original endpoints (from Build Brief): `@FenixLeads_bot` → chat_id `8679444137` (Osama); `@FenixContent_bot` → Make scenario S2b (parked per D9).
- **Actual chat_id (verified 2026-10-20):** `717323277` (from `getUpdates` after `/start`). Build Brief's `8679444137` is stale.
- Current wiring: `@FenixLeads_bot` → chat_id `717323277` (leads/alerts); `@FenixContent_bot` → chat_id `717323277` (content/approvals); `@EmpireAgent_bot` → chat_id `717323277` (orchestrator); Make S2b still parked.

## Reviewer model pin — Hermes resolution

- Empire orchestrator pins reviewer to `fable` / `claude-fable-5-1`. Hermes `delegate_task` has no per-child model; children inherit parent model.
- **Resolution pattern:** Designate the intended reviewer model (e.g., `anthropic/claude-3.5-sonnet` on OpenRouter), document in `SOLE.md`, and write `Concern: reviewer model pin not honoured — designated <model>, running on parent model via fresh context` in every run's `STATUS.md` until Osama revises.

## Command Center dashboard verification

- Dashboard runs on `http://127.0.0.1:8787` with token from `C:\Users\Kahrman\.empire\cc.env` (`CC_UI_TOKEN`).
- Token format: `http://127.0.0.1:8787/#code=<CC_UI_TOKEN>`.
- Verification: `browser_exec` to the URL with token → confirm title "🐴 Empire Command Center" and content loads.
- If server not running: `start-command-center.bat` spawns `python -m empire_cc.server` on :8787.

## Known gap patterns (status as of 2026-10-20)

### Fenix two-lineage trap — RESOLVED (option a)
- Lineage A: `Empire Active Projects\Fenix\Fenix` (local commit, had 3 client-call recordings in git history, **no remote**).
- Lineage B: `osamagweaa/fenix-project` on GitHub (clean, no recordings).
- New commits in A did NOT reach B.
- **Resolution (2026-10-20):** `git-filter-repo` purged 3 recordings from all history (`GTM/Al-Raied/Abdalkarim Araied (1).m4a`, `GTM/Al-Raied/Abudalkarim 1st contact call - part 2.mp3`, `GTM/Al-Raied/Abudalkarim 1st contact call.mp3`), then force-pushed rewritten history to `osamagweaa/fenix-project` (master). Lineage A now matches clean Lineage B. New commits flow to GitHub.

### Telegram bot wiring — RESOLVED (2026-10-20)
- Tokens in env vars; bots `@FenixLeads_bot` (A) and `@FenixContent_bot` (B).
- Original endpoints (Build Brief): A → chat_id `8679444137`, B → Make S2b (parked per D9).
- **Pitfall:** A bot cannot send to a `chat_id` until that chat has sent `/start` to the bot. `getUpdates` returns empty until then; `sendMessage` returns `400: chat not found`.
- **Actual chat_id (verified via `getUpdates` after `/start`):** `717323277`. Build Brief's `8679444137` is stale.
- Current wiring: `@FenixLeads_bot` → chat_id `717323277` (leads/alerts); `@FenixContent_bot` → chat_id `717323277` (content/approvals); Make S2b remains parked.

### Reviewer model pin — RESOLVED (2026-10-20)
- Empire orchestrator pins reviewer to `fable` / `claude-fable-5-1`. Hermes `delegate_task` has no per-child model; children inherit parent model (Nemotron 3 Ultra via OpenRouter).
- **Resolution:** Designated `anthropic/claude-3.5-sonnet` as intended reviewer model. Documented in `SOLE.md`. Every run's `STATUS.md` carries `Concern: reviewer model pin not honoured — designated claude-3.5-sonnet, running on parent model (Nemotron 3 Ultra) via fresh context`.

### Command Center dashboard — VERIFIED (2026-10-20)
- Dashboard runs on `http://127.0.0.1:8787` with token from `C:\Users\Kahrman\.empire\cc.env` (`CC_UI_TOKEN`).
- Token format: `http://127.0.0.1:8787/#code=<CC_UI_TOKEN>`.
- Verified via `browser_exec` — title "🐴 Empire Command Center", content loads. Server was running.

### Associate Orchestrator role (SOLE.md)
- When Primary Orchestrator (Claude) is unavailable, Hermes acts as Associate Orchestrator.
- Full triage/spawn/guardrail authority; **no approval authority** for send/publish/spend/push/delete.
- Documented in `F:\The Empire ecosystem\The Empire Goverence System\SOLE.md`.

### Remaining gaps (2026-10-20)
1. HeyGen v2 retirement 2026-10-31 — "Test connection" click pending.
