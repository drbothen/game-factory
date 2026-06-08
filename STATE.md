---
pipeline: IN-PROGRESS
phase: 1
product: game-factory
mode: greenfield
brief_version: "2.0"
timestamp: 2026-06-07T00:00:00Z
brief_approval: PASSED
preflight_verdict: READY-WITH-WARNINGS
market_intel_verdict: PASSED
phase0_gate: PASSED
---

# Factory State

## Phase Progress

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| pre-1 | Brief + Validation | PASSED | brief v2.0 human-approved; preflight READY-WITH-WARNINGS; market-intel PASSED (D-006/07/08 human-ratified) |
| 0 | Brownfield Extraction | PASSED | extraction-ingestion VERIFIED-WITH-CORRECTIONS; ~70% conceptual/~85% file-level REUSE; quality model REPLACE; BC-VP/convergence-dims/dependency-model ADAPT; seam: 4 config/content swap interfaces; phase0_gate PASSED (human approved REUSE/REPLACE/ADAPT plan + devops pipeline item) |
| 1 | Spec Crystallization | IN PROGRESS | Steps: L2 domain spec → L3 PRD+BCs → architecture+DTU assessment → VPs → DTU assessment (dtu-assessment.md) → CI/CD (.github/workflows/ + cicd-setup.md) → Phase-1d adversarial convergence (≥3 passes) → consistency audit → human approval gate |
| 2 | Story Decomposition | PENDING | — |
| 3 | TDD Implementation | PENDING | — |
| 4 | Holdout Evaluation | PENDING | — |
| 5 | Adversarial Refinement | PENDING | — |
| 6 | Formal Hardening | PENDING | — |
| 7 | Convergence | PENDING | — |

## Current Phase Steps (Phase 1 — Spec Crystallization)

| # | Step | Status |
|---|------|--------|
| 1 | Phase 0 outputs validated VERIFIED-WITH-CORRECTIONS (validate-extraction); committed f77e91e | DONE |
| 2 | Human approved Phase-0 context: REUSE/REPLACE/ADAPT plan; devops pipeline item accepted | DONE |
| 3 | Phase-0 gate PASSED; transitioning to Phase 1 Spec Crystallization | DONE |
| 4 | L2 domain spec (business-analyst) | NEXT |
| 5 | L3 PRD + behavioral contracts (product-owner) | PENDING |

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
| `.factory/phase-0-ingestion/project-context.md` | — | committed f77e91e |
| `.factory/phase-0-ingestion/extraction-boundary-validated.md` | — | committed f77e91e |
| `.factory/phase-0-ingestion/component-inventory.md` | — | committed f77e91e |

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
| D-009 | Extracted core needs its own release/cross-compile pipeline (dispatcher currently from marketplace tarball) — owner: devops-engineer, target Phase 1+ | ACCEPTED (human, 2026-06-07) |

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
**Phase:** 1 — Spec Crystallization IN PROGRESS. Phase-0 gate PASSED (human approved REUSE/REPLACE/ADAPT plan; devops pipeline item D-009 accepted). pre-1 fully PASSED; D-006/D-007/D-008 human-ratified.
**Next action:** Dispatch business-analyst for L2 domain spec (`/vsdd-factory:create-domain-spec`).
**Phase 1 planned steps:** L2 domain spec (business-analyst) → L3 PRD + BCs (product-owner) → architecture + DTU assessment (architect) → verification properties → MANDATORY DTU assessment (dtu-assessment.md) → CI/CD setup (.github/workflows/ + cicd-setup.md) → Phase-1d adversarial convergence (≥3 clean passes) → fresh-context consistency audit → Phase-1 spec-package human approval gate.
**Key Phase-0 findings (for context):** ~70% conceptual / ~85% file-level neutral spine REUSE; quality model REPLACE; BC-VP/convergence-dims/dependency-model ADAPT; seam = 4 declarative swap interfaces. D-009: devops-engineer owns extracted-core release/cross-compile pipeline (Phase 1+).
**Context:** .factory/ worktree on factory-artifacts is healthy. Reference clone at `.reference/vsdd-factory` @ `82163b7`. Planning corpus under `.factory/planning/`. Pre-Phase-3 remediation items (LiteLLM proxy, API keys) outstanding — not current blockers.
