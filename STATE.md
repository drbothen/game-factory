---
pipeline: IN-PROGRESS
phase: 0
product: game-factory
mode: greenfield
brief_version: "2.0"
timestamp: 2026-06-07T00:00:00Z
brief_approval: PASSED
preflight_verdict: READY-WITH-WARNINGS
market_intel_verdict: PASSED
---

# Factory State

## Phase Progress

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| pre-1 | Brief + Validation | PASSED | brief v2.0 human-approved; preflight READY-WITH-WARNINGS; market-intel PASSED (D-006/07/08 human-ratified) |
| 0 | Brownfield Extraction | IN PROGRESS | extract vsdd-factory core from .reference/ @ 82163b7; codebase-analyzer writing .factory/phase-0-ingestion/ |
| 1 | Spec Crystallization | PENDING | — |
| 2 | Story Decomposition | PENDING | — |
| 3 | TDD Implementation | PENDING | — |
| 4 | Holdout Evaluation | PENDING | — |
| 5 | Adversarial Refinement | PENDING | — |
| 6 | Formal Hardening | PENDING | — |
| 7 | Convergence | PENDING | — |

## Current Phase Steps

| # | Step | Status |
|---|------|--------|
| 1 | Product brief v2.0 authored (AAA Dark Factory scope) | DONE |
| 2 | product-brief.md committed on factory-artifacts | DONE |
| 3 | validate-brief run; brief v2.0 human-approved | DONE |
| 4 | Pre-pipeline preflight run — READY-WITH-WARNINGS (see planning/preflight-report.md) | DONE |
| 5 | Market-intel assessment run — CAUTION (see planning/market-intel-assessment.md) | DONE |
| 6 | Human ratified D-006, D-007, D-008 at market-intel gate; gate PASSED | DONE |
| 7 | Phase 0 brownfield extraction started; codebase-analyzer dispatched to .factory/phase-0-ingestion/ | IN PROGRESS |

## Key Facts

| Fact | Detail |
|------|--------|
| .factory/ branch | orphan `factory-artifacts`; worktree at `.factory/` |
| Reference clone | `.reference/vsdd-factory` @ develop `82163b7` (gitignored) |
| Planning corpus | 22-doc AAA research + design + input ADRs under `.factory/planning/{research,design,decisions}` |
| Methodology charter | `.factory/planning/research/aaa/AAA-RECONCILIATION.md` v2.0 |
| Product brief | `.factory/specs/product-brief.md` v2.0 (AAA scope) |
| Phase-0 plan | Brownfield extraction of vsdd-factory core; boundary doc: `planning/design/extraction-boundary.md` |

## File Manifest

| File | Version | Status |
|------|---------|--------|
| `.factory/specs/product-brief.md` | 2.0 | committed |
| `.factory/planning/research/aaa/AAA-RECONCILIATION.md` | 2.0 | committed |
| `.factory/planning/design/architecture.md` | — | committed |
| `.factory/planning/design/engine-adapter-protocol.md` | — | committed |
| `.factory/planning/design/protocol-schema.md` | — | committed |
| `.factory/planning/design/extraction-boundary.md` | — | committed |
| `.factory/planning/decisions/0001-founding-engine-pair.md` | — | committed |
| `.factory/planning/decisions/0002-protocol-and-conformance-stance.md` | — | committed |
| `.factory/planning/decisions/0003-determinism-tier-capability.md` | — | committed |
| `.factory/planning/preflight-report.md` | 1.0 | committed |
| `.factory/planning/market-intel-assessment.md` | 1.0 | committed |

## Decisions Log

| ID | Decision | Status |
|----|----------|--------|
| D-001 | Founding engine pair: Bevy + Unity (Decision 0001) | ACCEPTED |
| D-002 | Protocol stance: JSON-RPC 2.0 + conformance suite (Decision 0002) | ACCEPTED |
| D-003 | Determinism tiers T1/T2/T3 (Decision 0003) | ACCEPTED |
| D-004 | Asset generation: pure-maximal, no mandatory human creative finishing | ACCEPTED |
| D-005 | human-gated = external third-party acts only (cert, publish, SAG-AFTRA, legal) | ACCEPTED |
| D-006 | IP/copyrightability: pure-maximal retained; provenance sidecar records copyrightability honestly; per-project humanization optional for IP-critical assets | RATIFIED (human, 2026-06-07) |
| D-007 | Music/voice: pure-maximal retained; DEFAULT ship-safe generators (licensed-output music e.g. AIVA/Stable Audio; non-performer synthetic voice); real-performer likeness = human-gated consent | RATIFIED (human, 2026-06-07) |
| D-008 | Regulatory: compliance/provenance/ai-disclosure = P0 wave-1 (not deferred); enforced in Phase-2 wave planning | RATIFIED (human, 2026-06-07) |

## Skip Log

_(none yet)_

## Blocking Issues

_(none open)_

## Pre-Phase-3 Remediation Log

| Item | Action | When |
|------|--------|------|
| LiteLLM proxy not running | Start with `litellm --config .../litellm-config-macos.yaml --port 4000` after loading API keys | Before Phase 3 |
| API keys missing | Populate `.env` (ANTHROPIC_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY, OPENROUTER_API_KEY); create `.envrc` + `direnv allow .` | Before Phase 3 |
| GPT adversary route unverified | Once proxy running: `curl http://localhost:4000/v1/models`; confirm adversary/primary resolves | Before Phase 5 |
| lobster-parse not generated | Generated during Phase-1 toolchain provisioning (`/vsdd-factory:toolchain-provisioning`) — not a current blocker | Phase 1 |

## Session Resume Checkpoint

**Date:** 2026-06-07
**Phase:** 0 — IN PROGRESS. pre-1 fully PASSED (brief, preflight, market-intel). D-006/D-007/D-008 human-ratified.
**Next action:** Await codebase-analyzer completion of Phase 0 brownfield extraction (output: .factory/phase-0-ingestion/). Then human approval gate on Phase-0 context before proceeding to Phase 1.
**Context:** .factory/ worktree on factory-artifacts is healthy. Reference clone at `.reference/vsdd-factory` @ `82163b7`. Planning corpus under `.factory/planning/`. Market-intel gate PASSED — D-006/07/08 ratified as recommended. D-008 enforces compliance/provenance/ai-disclosure as P0 wave-1 (Phase-2 wave planning). Pre-Phase-3 remediation items (LiteLLM proxy, API keys) remain outstanding but are not current blockers.
