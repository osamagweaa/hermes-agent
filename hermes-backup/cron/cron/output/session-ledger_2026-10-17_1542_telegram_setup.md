# SESSION LOG: 2026-10-17_1542_telegram_setup
Project: Infrastructure / Governance
Surface: chat
Date: 2026-10-17
Entry Count: 31
Model: gemma4:31b-cloud

## Timeline
- Intent: Plan ecosystem toggles -> Result: Read HANDOVER.MD and proposed ranked priority list (Telegram Security, Fenix Lineage, CRM).
- Intent: Revoke and restart all bots -> Result: Proposed separate bots for Noise (Alerts) and Signal (Control).
- Intent: Install tokens securely -> Result: Provided PowerShell scripts for User Env Vars.
- Intent: Verify connectivity -> Result: Repeated 404 Not Found errors.
- Intent: Debug 404s -> Result: Discovered tokens were only 14 chars (Bot IDs) instead of ~45 chars (API Tokens).

## Decisions
- Separate bots for Lead Alerts and Control to maintain signal-to-noise ratio.
- Use `Read-Host -AsSecureString` to avoid plaintext tokens in chat/scripts.

## Artifacts
- Env Vars targeted: `FENIX_TG_BOT_A_TOKEN`, `FENIX_TG_BOT_B_TOKEN`, `SQUILLACI_TG_BOT_TOKEN`.

## Verified Outcomes
- Bot @SquillaciAgent revoked and deleted.
- All 3 bot tokens installed and verified (getMe OK).
- @FenixLeads_bot (Alerts), @FenixContent_bot (Approvals), @EmpireAgent_bot (Orchestrator) are live.

## Not Finished
- None.

## Next Actions
- None.
