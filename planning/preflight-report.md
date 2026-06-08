---
created: 2026-06-07
phase: pre-pipeline
pipeline_stage: before-phase-0
verdict: READY-WITH-WARNINGS
---

# Pre-Pipeline Preflight Report

**Checked:** 2026-06-07  
**Purpose:** Readiness gate before Phase 0 (Brownfield Extraction)  
**Scope:** Presence and connectivity checks only — no installs, no full toolchain provisioning

---

## Summary Verdict: READY-WITH-WARNINGS

Phase 0 can proceed. No blockers. Three warnings require resolution before Phase 3
(TDD Implementation) begins: LiteLLM proxy not running, API keys not in environment,
.env/.envrc setup incomplete.

---

## Check Results

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1a | git installed | PASS | via system git |
| 1b | gh auth status | PASS | authenticated as drbothen (keyring) |
| 1c | remote origin reachable | PASS | drbothen/game-factory confirmed via gh API |
| 1d | main branch on remote | PASS | remotes/origin/main present, in sync |
| 1e | factory-artifacts branch on remote | PASS | remotes/origin/factory-artifacts present, in sync |
| 2a | .factory/ is a worktree | PASS | worktree at .factory/ on branch factory-artifacts |
| 2b | factory-artifacts is orphan branch | PASS | branch has no shared history with main |
| 2c | STATE.md present | PASS | .factory/STATE.md present, phase=pre-1 |
| 2d | Factory content structure | PASS | specs/, planning/, cycles/, stories/, holdout-scenarios/ all present |
| 3a | .reference/vsdd-factory present | PASS | directory exists |
| 3b | vsdd-factory HEAD = 82163b7 | PASS | HEAD is 82163b7fe627e196ea19c88eab26f4b4325f6fcd |
| 3c | vsdd-factory branch = develop | PASS | branch is develop |
| 4a | LiteLLM proxy on :4000 | WARN | port 4000 is OrbStack, NOT LiteLLM — proxy not running |
| 4b | API keys in environment | WARN | ANTHROPIC_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY, OPENROUTER_API_KEY: all MISSING from shell env |
| 4c | Model routing config present | PASS | dark-factory/config/litellm-config-macos.yaml present and valid |
| 4d | Adversary model tier (GPT-5.4) | WARN | Cannot verify — depends on LiteLLM proxy + OPENAI_API_KEY (see 4a/4b) |
| 5a | Perplexity MCP | PASS | Listed in .mcp.json; tools reachable this session (mcp__perplexity__*) |
| 5b | Tavily MCP | PASS | Listed in .mcp.json; tools reachable this session (mcp__tavily__*) |
| 5c | Context7 MCP | PASS | Not in project .mcp.json — loaded via plugin/ClawHub; reachable this session (mcp__context7__*) |
| 5d | Playwright MCP | PASS | Listed in .mcp.json; tools reachable this session (mcp__playwright__*) |
| 5e | Tally MCP | PASS | Listed in .mcp.json; tools reachable this session (mcp__tally__*) |
| 5f | MCP auth in headless/cron runs | WARN | Perplexity/Tavily API keys not in shell env; will fail outside interactive session |
| 6a | node present | PASS | v25.2.1 |
| 6b | npm present | PASS | v11.6.2 |
| 6c | docker present | PASS | Docker 29.4.0 (via OrbStack) |
| 6d | jq present | PASS | jq-1.6 |
| 6e | ripgrep present | PASS | ripgrep 15.1.0 |
| 6f | lobster-parse helper | WARN | bin/lobster-parse not present in game-factory (expected: not yet generated) |
| 7a | workspace NOT inside dark-factory | PASS | /Users/jmagady/Dev/game-factory is a sibling of /Users/jmagady/Dev/dark-factory |
| 7b | .gitignore covers .factory/ | PASS | .factory/ entry present in .gitignore |
| 7c | .gitignore covers .reference/ | PASS | .reference/ entry present in .gitignore |
| 7d | .gitignore covers .mcp.json | PASS | .mcp.json entry present in .gitignore |
| 7e | .env / .envrc present | WARN | Neither .env nor .envrc exists in game-factory root |

---

## Check Detail Notes

### Check 1 — Git & GitHub

- `git` available on PATH; `gh` authenticated as account `drbothen` with scopes: gist,
  project, read:org, repo, workflow (sufficient for all pipeline operations).
- Remote `origin` verified reachable via `gh api repos/drbothen/game-factory`.
- Both `main` and `factory-artifacts` exist on remote and are in sync with local
  (no unpushed commits on either branch).

### Check 2 — Factory Worktree Health

- `.factory/` is a git worktree (confirmed via `git worktree list`) on branch
  `factory-artifacts` at commit `72a71bd`.
- STATE.md present and well-formed. Pipeline phase reads `pre-1`; current step is
  "Run validate-brief" — consistent with brief having been approved and preflight
  being the next action.
- All expected sub-directories under `.factory/` are present.

### Check 3 — Brownfield Reference

- `.reference/vsdd-factory` is present and on branch `develop` at the exact commit
  `82163b7` specified. Gitignored. Ready for Phase 0 extraction.

### Check 4 — LLM / Model Routing

**This is the most important warning.** The LiteLLM proxy is NOT running.

Port 4000 is occupied by OrbStack (container networking). No LiteLLM process is
active. The model routing config (`litellm-config-macos.yaml`) is present and
correctly defines five tiers:

| Tier | Model | Provider | Key Needed |
|------|-------|----------|------------|
| judgment/primary | claude-opus-4-6 | Anthropic | ANTHROPIC_API_KEY |
| implementation/primary | claude-sonnet-4-6 | Anthropic | ANTHROPIC_API_KEY |
| validation/primary | claude-haiku-4-5 | Anthropic | ANTHROPIC_API_KEY |
| adversary/primary | gpt-5.4 | OpenAI | OPENAI_API_KEY |
| review/primary | gemini-3.1-pro-preview | Google | GOOGLE_API_KEY |

None of the four required API keys are present in the shell environment. This is
expected for Phase 0 (brownfield extraction runs through the Claude Code harness
directly, not through LiteLLM). However, the proxy MUST be started with keys loaded
before Phase 3 begins.

**Note on current session:** This preflight is running inside Claude Code (Sonnet 4.6)
which has direct Anthropic API access via the harness. Phase 0 and Phase 1 can
proceed through Claude Code. The LiteLLM proxy and multi-model fleet is only required
when the full agent fleet activates in Phase 3.

**Adversary model (GPT-5.4):** Cannot verify reachability without the proxy running.
This must be validated before Phase 5 (Adversarial Refinement).

### Check 5 — MCP Servers

All four required MCP servers were reachable during this session:
- perplexity, tavily: configured in `.mcp.json`
- context7: loaded via ClawHub plugin mechanism (not in project .mcp.json — this is
  expected; it is a global/plugin-level MCP server)
- playwright: configured in `.mcp.json`

**Headless/cron warning:** Perplexity and Tavily require API keys that are not in
the shell environment. These MCP connections work in the current interactive session
because the keys are embedded in `.mcp.json` (which is gitignored). Any headless or
cron-triggered agent run would need keys available via environment or a secrets
manager. This is not a Phase 0 blocker.

### Check 6 — Core CLI Tooling

All required tools present. `lobster-parse` absence is expected: this is the engine's
Lobster workflow binary helper and has not been generated yet (it is produced during
engine toolchain provisioning, after architecture is confirmed in Phase 1).

### Check 7 — Disk / Workspace Sanity

- Workspace at `/Users/jmagady/Dev/game-factory` is a sibling directory to
  `/Users/jmagady/Dev/dark-factory`, not nested inside it.
- `.gitignore` correctly covers all three sensitive paths: `.factory/`, `.reference/`,
  `.mcp.json`.
- Neither `.env` nor `.envrc` exists. This is expected at this point (DX setup is
  deferred until product API keys are known after Phase 1 DTU assessment). However,
  direnv is installed and functional — setup can proceed whenever needed.

---

## Remediation Required Before Phase 3

| Item | Action | Urgency |
|------|--------|---------|
| LiteLLM proxy not running | Start with `litellm --config .../litellm-config-macos.yaml --port 4000` after loading API keys | Before Phase 3 |
| API keys not in environment | Populate `.env` with ANTHROPIC_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY, OPENROUTER_API_KEY; create `.envrc` with `dotenv .env`; run `direnv allow .` | Before Phase 3 |
| Adversary model (GPT-5.4) not verified | Once proxy is running, verify with `curl http://localhost:4000/v1/models` and confirm adversary/primary route resolves | Before Phase 5 |
| .env/.envrc setup | Run `/vsdd-factory:setup-env` or DX engineer setup step when product keys are known | Before Phase 3 |

---

## Phase 0 Go / No-Go

**GO.** All hard dependencies for Phase 0 (brownfield extraction) are satisfied:
- git, gh, brownfield reference at correct SHA, .factory/ worktree healthy, MCP
  servers reachable, core CLI tools present.
- Phase 0 runs through Claude Code directly — no LiteLLM proxy or multi-model fleet
  required at this stage.
