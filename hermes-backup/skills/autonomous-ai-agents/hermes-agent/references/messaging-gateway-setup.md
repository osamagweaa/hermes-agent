# Messaging gateway setup, model choice and fallback (verified workflow)

Use for: "configure Telegram/Discord/...", "start the gateway", a bot that replies with a provider error, "add X as fallback".
Platform docs: `/user-guide/messaging/<platform>`; fallback docs: `/user-guide/features/fallback-providers`.

## 1. Check state before giving steps

```bash
hermes --version; hermes gateway status
grep -o '^TELEGRAM[A-Z_]*' "$HERMES_HOME/.env"     # names only, never values
hermes config get model; hermes fallback list; hermes auth list
```
- `python cli.py --gateway` is a legacy form. The current command is `hermes gateway run` (foreground). `hermes gateway install` registers an OS auto-start task (a system change, so it needs the user's explicit yes).

## 2. Credentials: the user enters them, you verify them

- The user creates the bot (@BotFather `/newbot`) and gets a numeric ID (@userinfobot), then runs `hermes gateway setup` in their own terminal, or uses the dashboard/desktop "Create with QR". Never ask for the token in chat.
- Verify without printing anything: confirm the variable is present, its length, a sha256 fingerprint (first 6 hex), the format (`^[0-9]+:[A-Za-z0-9_-]{30,}$`, numeric allowed-user IDs), and a live `curl https://api.telegram.org/bot$TOKEN/getMe` that prints only `ok` and `username`.

## 3. The bot replies with a provider error, so the transport works

If the bot posts an HTTP 402 or a billing error, Telegram and the gateway are fine. The configured **model** isn't entitled. Read `hermes config get model` and the model the error suggests (Ollama names a free-plan model). Then:
1. Back up `config.yaml`, then run `hermes config set model.default <model>`. This changes CLI and gateway alike, so say so.
2. Probe the model directly before reporting success, e.g. Ollama: `curl -s http://127.0.0.1:11434/api/chat -d '{"model":"<m>","messages":[{"role":"user","content":"Reply with just: ok"}],"stream":false}'`.
3. Tell the user to restart the gateway (Ctrl+C, `hermes gateway run`). A running gateway keeps the old model.

If the user has a no-new-spend rule, offer the free option first and label any paid option as spend.

## 4. Adding a fallback provider

- `hermes fallback add` is interactive only (no flags). From an agent, set the list in one command, then confirm:
  `hermes config set fallback_providers '[{"provider":"openrouter","model":"openrouter/free"}]'` then `hermes fallback list`.
- Choosing a free OpenRouter model: list candidates from `https://openrouter.ai/api/v1/models` (ids ending `:free`, `tools` in `supported_parameters`), then **call each one** with a one-line chat completion before configuring. Specific `:free` models can return no `choices` when overloaded. `openrouter/free` (the Free Models Router, price 0, tool-capable) routes to whatever free model is up and answered in ~1 s. It's the safer default, but output quality varies between calls.
- Per-turn semantics: the primary model comes back on the next turn. Each switch re-reads the full history uncached.

## 5. Pitfall: key in OS env but not visible to the process

`hermes auth list` can show `env:OPENROUTER_API_KEY` while a spawned `hermes chat` says "No API key found". The key sits in the Windows **User** environment, and processes started from shells opened before it was set don't inherit it.
- Diagnose by scope without printing: `[Environment]::GetEnvironmentVariable('OPENROUTER_API_KEY','User')` and the same for 'Machine' and 'Process', reporting set/length only.
- To test with it, load the User value into a PowerShell process env inside a script file and call the API from there.
- Fix for the user: start the gateway from a **new** terminal window (or let them add the key to `$HERMES_HOME/.env` via `hermes gateway setup` / `hermes model`). Never copy the secret yourself.
- On git-bash, run PowerShell probes from a `.ps1` file in `$TMPDIR` (`-File`). Inline `$`-heavy `-Command` strings get mangled by quoting.
