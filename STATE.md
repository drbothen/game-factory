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
| 4 | L2 domain spec (business-analyst) — 10 shards; 18 entities, 14 caps [7P0/5P1/2P2], 12 invariants, 6 processes, 42 glossary terms, 8 assumptions, 17 risks, 10 failure-modes, 7 differentiators; committed 79a625c. Optional follow-up shards (event-flow, genre-profiles) non-blocking. | DONE |
| 5 | L3 PRD + behavioral contracts (product-owner) — 168 BCs (CAP-001:34, 002:6, 003:9, 004:15, 005:16, 006:11, 007:12, 008:5, 009:11, 010:6, 011:13, 012:9, 013:14, 014:7); prd.md + BC-INDEX + nfr-catalog (19 NFRs) + error-taxonomy (11 families); full-depth Approach B (all 14 caps); committed e05fd9d | DONE |
| 6 | create-architecture (architect) — sharded ADRs, subsystem decomposition + assign SS-NN to all 168 BCs from ARCH-INDEX, formalize four adapter protocols, DTU assessment, methodology layer | NEXT |

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
| `.factory/specs/domain-spec/L2-INDEX.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/ubiquitous-language.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/entities.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/capabilities.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/processes.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/invariants.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/assumptions.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/risks.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/failure-modes.md` | 1.0 | committed 79a625c |
| `.factory/specs/domain-spec/differentiators.md` | 1.0 | committed 79a625c |
| `.factory/specs/prd.md` | 1.0 | committed e05fd9d |
| `.factory/specs/behavioral-contracts/BC-INDEX.md` | 1.0 | committed e05fd9d |
| `.factory/specs/behavioral-contracts/ss-01/…ss-14/` | 1.0 | 168 BC files; see BC-INDEX; committed e05fd9d |
| `.factory/specs/prd-supplements/nfr-catalog.md` | 1.0 | committed e05fd9d |
| `.factory/specs/prd-supplements/error-taxonomy.md` | 1.0 | committed e05fd9d |
| `.factory/specs/prd-supplements/prd-cap-{001…013-014}.md` | 1.0 | 9 supplement files; committed e05fd9d |

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

## Drift / Follow-up Items

Items identified during create-prd; to be resolved by architect and/or Phase-1d adversarial pass:

| ID | Item | Owner | When |
|----|------|-------|------|
| FU-001 | DI-010 (kernel-anti-cheat-never-authored) and DI-011 (NFT/Web3-off-by-default) have no dedicated BC — add lint/default BCs | architect | create-architecture |
| FU-002 | NFR numerical-target gaps for CAP-001–003, 006–007, 009–011, 013–014 — specific thresholds TBD in architecture | architect | create-architecture |
| FU-003 | Missing error families: E-GEN (CAP-004), E-ETH (CAP-011), E-XR (CAP-014), and ~7 others not yet modeled in error-taxonomy | architect / Phase-1d adversary | create-architecture / Phase-1d |
| FU-004 | All 168 BCs carry `subsystem: SS-TBD` — architect must assign final SS-NN identifiers from ARCH-INDEX | architect | create-architecture |

## Session Resume Checkpoint

**Date:** 2026-06-08
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–5 DONE. L3 PRD + 168 BCs committed (e05fd9d).
**Next action:** Dispatch architect for create-architecture (`/vsdd-factory:create-architecture`) — sharded ADRs, subsystem decomposition, assign SS-NN to all 168 BCs, formalize four adapter protocols, DTU assessment, methodology layer.
**Phase 1 remaining steps:** create-architecture (architect) → verification properties → MANDATORY DTU assessment (dtu-assessment.md) → CI/CD setup (.github/workflows/ + cicd-setup.md) → Phase-1d adversarial convergence (≥3 clean passes) → fresh-context consistency audit → Phase-1 spec-package human approval gate.
**PRD/BC summary:** 168 BCs across 14 caps; nfr-catalog (19 NFRs); error-taxonomy (11 families). All BCs SS-TBD pending architect. 4 follow-up items (FU-001–004) logged above.
**Key Phase-0 findings (for context):** ~70% conceptual / ~85% file-level neutral spine REUSE; quality model REPLACE; BC-VP/convergence-dims/dependency-model ADAPT; seam = 4 declarative swap interfaces. D-009: devops-engineer owns extracted-core release/cross-compile pipeline (Phase 1+).
**Context:** .factory/ worktree on factory-artifacts is healthy. Reference clone at `.reference/vsdd-factory` @ `82163b7`. Pre-Phase-3 remediation items (LiteLLM proxy, API keys) outstanding — not current blockers.
