---
pipeline: IN-PROGRESS
phase: 1
product: game-factory
mode: greenfield
brief_version: "2.0"
timestamp: 2026-06-08T00:00:00Z
brief_approval: PASSED
preflight_verdict: READY-WITH-WARNINGS
market_intel_verdict: PASSED
phase0_gate: PASSED
dtu_required: true
dtu_assessment: 2026-06-08
dtu_clones_built: pending
dtu_services: [game-engine-bevy, game-engine-unity, asset-gen-visual, asset-gen-audio, asset-gen-voice, asset-gen-3d, compliance-iarc, compliance-ai-disclosure, distribution-steam, distribution-itch]
---

# Factory State

## Phase Progress

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| pre-1 | Brief + Validation | PASSED | brief v2.0 human-approved; preflight READY-WITH-WARNINGS; market-intel PASSED (D-006/07/08 human-ratified) |
| 0 | Brownfield Extraction | PASSED | extraction-ingestion VERIFIED-WITH-CORRECTIONS; ~70% conceptual/~85% file-level REUSE; quality model REPLACE; BC-VP/convergence-dims/dependency-model ADAPT; seam: 4 config/content swap interfaces; phase0_gate PASSED (human approved REUSE/REPLACE/ADAPT plan + devops pipeline item) |
| 1 | Spec Crystallization | IN PROGRESS | Steps 1–6 DONE (L2→L3 PRD+168 BCs→architecture+VPs); remaining: prd-revision → CI/CD setup → Phase-1d adversarial (≥3 passes) → consistency audit → human gate |
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
| 5 | L3 PRD + behavioral contracts (product-owner) — 168 BCs (CAP-001:34, 002:6, 003:9, 004:15, 005:16, 006:11, 007:12, 008:5, 009:11, 010:6, 011:13, 012:9, 013:14, 014:7); prd.md + BC-INDEX + nfr-catalog (19 NFRs) + error-taxonomy (11 families); committed e05fd9d | DONE |
| 6 | create-architecture (architect) — 12 subsystems (CAP-001+002→SS-01, CAP-009+010→SS-08); ADR-0004..0007; adapter-protocols (4 seams, 8 contract schemas); methodology-layer (11 convergence predicates, 11 dims incl. D-ETHICS+D-SEC); studio-of-agents (14 REUSE/18 ADAPT/34 NEW); 10 VPs (pure-sim slice, SS-02/05/11); DTU=REQUIRED (10 clones — GATES pre-Phase-3 check); 168 BC SS-TBD resolved (FU-004 closed); committed c29f412 | DONE |
| 7 | prd-revision (product-owner revises PRD per architect feasibility feedback) | NEXT |
| 8 | CI/CD setup (devops-engineer — .github/workflows/ + cicd-setup.md; D-009) | PENDING |
| 9 | Phase-1d adversarial spec convergence (≥3 clean passes) | PENDING |
| 10 | Consistency audit + drift check | PENDING |
| 11 | Phase-1 human approval gate | PENDING |

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
| `.factory/specs/architecture/ARCH-INDEX.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/layered-architecture.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/subsystem-decomposition.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/adapter-protocols.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/methodology-layer.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/studio-of-agents.md` | 1.0 | committed c29f412 |
| `.factory/specs/architecture/dtu-assessment.md` | 1.0 | committed c29f412; DTU_REQUIRED=true, 10 clones |
| `.factory/specs/architecture/adrs/ADR-0004..0007.md` | 1.0 | 4 ADRs; committed c29f412 |
| `.factory/specs/verification-properties/VP-INDEX.md` | 1.0 | committed c29f412 |
| `.factory/specs/verification-properties/VP-001..VP-010.md` | 1.0 | 10 VPs; committed c29f412 |

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
| D-010 | 11-dimension convergence model final (ADR-0006): D-ETHICS + D-SEC added to original 9 dims | ACCEPTED (architect, 2026-06-08) |
| D-011 | compliance.iarc = objective-questions-only (no LLM inference on IARC rating) | ACCEPTED (architect, 2026-06-08) |
| D-012 | design-intent-contract requires playtest_delegation_note schema field (methodology-layer) | ACCEPTED (architect, 2026-06-08) |
| D-013 | sequence-graph directed:true = creative gate distinct from DI-006 external-human-gate (ADR-0007) | ACCEPTED (architect, 2026-06-08) |

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
| FU-001 | DI-010 (kernel-anti-cheat-never-authored) and DI-011 (NFT/Web3-off-by-default) have no dedicated BC — add lint/default BCs | architect | prd-revision |
| FU-002 | NFR numerical-target gaps for CAP-001–003, 006–007, 009–011, 013–014 — specific thresholds TBD in architecture | product-owner | prd-revision |
| FU-003 | Missing error families: E-GEN (CAP-004), E-ETH (CAP-011), E-XR (CAP-014), and ~7 others not yet modeled in error-taxonomy | product-owner / Phase-1d adversary | prd-revision / Phase-1d |
| FU-004 | All 168 BCs carry `subsystem: SS-TBD` — architect must assign final SS-NN identifiers from ARCH-INDEX | — | CLOSED (c29f412) |
| FU-005 | Adversarial spec pass must validate architect clarifications D-010..D-013 (convergence dims final; compliance.iarc; playtest_delegation_note field; directed sequence-graph gate) | Phase-1d adversary | Phase-1d pass-1 |

## Session Resume Checkpoint

**Date:** 2026-06-08
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–6 DONE. Architecture + VPs committed (c29f412).
**Next action:** Dispatch product-owner for prd-revision (`/vsdd-factory:phase-1-prd-revision`) — incorporate architect feasibility feedback, close FU-001/002/003 (missing BCs for DI-010/011, NFR thresholds, error families).
**Phase 1 remaining steps:** prd-revision (product-owner) → CI/CD setup (devops-engineer; D-009) → Phase-1d adversarial convergence (≥3 clean passes) → consistency audit + drift check → Phase-1 human approval gate.
**Architecture summary:** 12 subsystems; 4-layer stack; 4 adapter seams (8 contract schemas); methodology-layer (11 convergence dims + 11 predicates); 66-role studio (14R/18A/34N); DTU_REQUIRED=true, 10 clones pending (GATES pre-Phase-3). ADR-0004..0007. 10 VPs (SS-02/05/11 pure-sim slice).
**BC/VP summary:** 168 BCs all SS-TBD resolved to SS-01..SS-12 (FU-004 closed). 10 VPs (VP-001..VP-010). 5 follow-up items (FU-001..005); FU-004 closed.
**Adversarial clarifications for Phase-1d (FU-005):** validate D-010 (11-dim convergence final), D-011 (compliance.iarc objective-only), D-012 (playtest_delegation_note field), D-013 (directed sequence-graph = creative gate distinct from DI-006).
**Key Phase-0 findings:** ~70% conceptual / ~85% file-level neutral spine REUSE; quality model REPLACE; seam = 4 declarative swap interfaces. D-009: devops-engineer owns extracted-core pipeline.
**Context:** .factory/ worktree on factory-artifacts healthy @ c29f412. Pre-Phase-3 remediation items (LiteLLM proxy, API keys) outstanding — not current blockers.
