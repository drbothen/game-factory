---
document_type: pipeline-state
project: game-factory
status: in_progress
current_step: prd-revision
current_cycle: v0.1.0-greenfield
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

# Factory State — game-factory

## How To Resume

**Workspace:** cwd = `/Users/jmagady/Dev/game-factory`

The orchestrator auto-reads this file on startup. On resuming:
1. Run `/vsdd-factory:factory-worktree-health` to verify `.factory/` is mounted on `factory-artifacts`.
2. Read the "Next Action" and "Durable Task Ledger" sections below.
3. Resume from the NEXT item in the ledger.

To resume in a fresh session: open this repo as cwd and say "resume".

**Branch model:**
- `main` = product source repo
- `factory-artifacts` = orphan branch; mounted as `.factory/` worktree
- `.reference/vsdd-factory` @ develop `82163b7` (gitignored; Phase-0 extraction source)
- `.mcp.json` = gitignored (contains local API keys)

**Thesis (do not silently drop):** engine-agnostic / four-seam / no-lock-in — REAFFIRMED by human. Adapter seams (8 contract schemas) are mandatory architecture, not optional scaffolding.

---

## Project Metadata

| Field | Value |
|-------|-------|
| project | game-factory |
| mode | greenfield + Phase-0 extraction |
| product type | software — engine-agnostic AAA game factory |
| repo | drbothen/game-factory |
| branch: main | product source |
| branch: factory-artifacts | `.factory/` worktree |
| reference | vsdd-factory @ 82163b7 |
| current phase | 1 — Spec Crystallization |
| current step | prd-revision |
| current cycle | v0.1.0-greenfield |

---

## Current Phase Steps

| Step | Description | Status |
|------|-------------|--------|
| create-domain-spec | L2 domain spec (10 shards; 18 entities, 14 caps) | DONE |
| create-prd | PRD + 168 BCs across 14 caps → SS-01..SS-12 | DONE |
| create-architecture | 12 subsystems, 4-layer stack, 10 VPs, DTU assessment | DONE |
| prd-revision | Incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | NEXT |
| cicd-setup | devops-engineer; `.github/workflows/` + `cicd-setup.md` (D-009; MANDATORY before Phase 3) | PENDING |
| phase-1d-adversarial | Adversarial spec convergence (>=3 clean passes; FU-005) | PENDING |
| consistency-audit | Fresh-context consistency audit (consistency-validator) | PENDING |
| drift-check | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| human-gate | Phase-1 spec-package human gate | PENDING |

---

## Next Action

**NEXT: `prd-revision`** — product-owner revises PRD per architect feasibility feedback.
Resolve FU-001 (add BCs for DI-010/011), FU-002 (NFR numeric targets for 9 caps), FU-003 (add missing error families E-GEN/E-ETH/E-XR + ~7 others).
Skill: `/vsdd-factory:phase-1-prd-revision`

---

## Durable Task Ledger

| # | Milestone / Task | Status |
|---|-----------------|--------|
| M1 | Pre-pipeline preflight (product-brief v2.0 approved; preflight READY-WITH-WARNINGS) | DONE |
| M2 | Market-intel gate (D-006/07/08 human-ratified) | DONE |
| M3 | Phase-0 brownfield extraction + validation (VERIFIED-WITH-CORRECTIONS; REUSE/REPLACE/ADAPT plan human-approved) | DONE |
| M4 | Phase-1 L2 domain spec (10 shards; 18 entities, 14 caps; 79a625c) | DONE |
| M5 | Phase-1 L3 PRD + 168 BCs across 14 caps → 12 subsystems SS-01..SS-12 (e05fd9d) | DONE |
| M6 | Phase-1 architecture + 10 VPs + DTU assessment (c29f412; DTU_REQUIRED=true, 10 clones DTU-01..10) | DONE |
| T7 | **prd-revision** — incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | **NEXT** |
| T8 | CI/CD setup — devops-engineer; `.github/workflows/` + `cicd-setup.md`; D-009 (MANDATORY before Phase 3) | PENDING |
| T9 | Phase-1d adversarial spec convergence — >=3 clean passes; adversary validates D-010..D-013 (FU-005) | PENDING |
| T10 | Fresh-context consistency audit (`consistency-validator`) | PENDING |
| T11 | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| T12 | Phase-1 spec-package HUMAN GATE | PENDING |
| T13 | Phase 2 — Story decomposition onward | PENDING |

---

## Phase Progress

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| pre-1 | Brief + Validation | PASSED | brief v2.0 human-approved; preflight READY-WITH-WARNINGS; market-intel PASSED (D-006/07/08 human-ratified) |
| 0 | Brownfield Extraction | PASSED | VERIFIED-WITH-CORRECTIONS; ~70% conceptual/~85% file-level REUSE; quality model REPLACE; seam: 4 config/content swap interfaces; human-approved |
| 1 | Spec Crystallization | IN PROGRESS | Steps 1–6 DONE (L2→PRD+168 BCs→architecture+VPs); see cycles/v0.1.0-greenfield/phase-1-log.md |
| 2–7 | Story Decomp → Convergence | PENDING | — |

---

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
| D-009 | Extracted core needs its own release/cross-compile pipeline — owner: devops-engineer, target Phase 1+ | ACCEPTED (human, 2026-06-07) |
| D-010 | 11-dimension convergence model final (ADR-0006): D-ETHICS + D-SEC added to original 9 dims | ACCEPTED (architect, 2026-06-08) |
| D-011 | compliance.iarc = objective-questions-only (no LLM inference on IARC rating) | ACCEPTED (architect, 2026-06-08) |
| D-012 | design-intent-contract requires playtest_delegation_note schema field (methodology-layer) | ACCEPTED (architect, 2026-06-08) |
| D-013 | sequence-graph directed:true = creative gate distinct from DI-006 external-human-gate (ADR-0007) | ACCEPTED (architect, 2026-06-08) |

---

## Skip Log

_(none yet)_

---

## Blocking Issues

_(none open)_

---

## Pre-Phase-3 Mandatory Gates

| Item | Action | When |
|------|--------|------|
| DTU clone existence check | Verify 10 clones DTU-01..DTU-10 built (see `specs/architecture/dtu-assessment.md`) | Before Phase 3 |
| CI/CD verification | `.github/workflows/` + `cicd-setup.md` must exist and pass | Before Phase 3 |
| LiteLLM proxy + API keys | Start proxy; populate `.env` / `.envrc`; verify GPT adversary route | Before Phase 5 |

---

## Open Follow-up Items

| ID | Item | Owner | When |
|----|------|-------|------|
| FU-001 | DI-010 (kernel-anti-cheat-never-authored) and DI-011 (NFT/Web3-off-by-default) have no dedicated BC — add lint/default BCs | architect | prd-revision |
| FU-002 | NFR numerical-target gaps for CAP-001–003, 006–007, 009–011, 013–014 — specific thresholds TBD | product-owner | prd-revision |
| FU-003 | Missing error families: E-GEN (CAP-004), E-ETH (CAP-011), E-XR (CAP-014), and ~7 others not modeled | product-owner / Phase-1d adversary | prd-revision / Phase-1d |
| FU-004 | All 168 BCs carry `subsystem: SS-TBD` — architect must assign final SS-NN identifiers | — | CLOSED (c29f412) |
| FU-005 | Adversarial spec pass must validate architect clarifications D-010..D-013 | Phase-1d adversary | Phase-1d pass-1 |

---

## Session Resume Checkpoint

**Date:** 2026-06-08
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–6 DONE. Architecture + VPs committed (c29f412). Latest factory-artifacts commit: 068d4a2.
**Next action:** `prd-revision` (`/vsdd-factory:phase-1-prd-revision`) — product-owner revises PRD per architect feasibility feedback; close FU-001/002/003.
**Phase 1 remaining:** prd-revision → CI/CD setup (devops-engineer; D-009; MANDATORY) → Phase-1d adversarial convergence (>=3 passes; FU-005) → consistency audit → drift check → Phase-1 human gate.
**Architecture:** 12 subsystems; 4-layer stack; 4 adapter seams (8 contract schemas); methodology-layer (11 convergence dims + predicates); 66-role studio (14R/18A/34N); DTU_REQUIRED=true, 10 clones pending. ADR-0004..0007. 10 VPs (SS-02/05/11 pure-sim slice).
**BCs/VPs:** 168 BCs resolved to SS-01..SS-12 (FU-004 closed). 10 VPs (VP-001..VP-010).
**FU-005 items for Phase-1d adversary:** D-010 (11-dim convergence final), D-011 (compliance.iarc objective-only), D-012 (playtest_delegation_note field), D-013 (directed sequence-graph = creative gate).
**Phase-0:** ~70% conceptual / ~85% file-level REUSE; quality model REPLACE; 4-seam adapter interfaces. D-009 outstanding.
**Step history:** see `.factory/cycles/v0.1.0-greenfield/phase-1-log.md`
**File manifest:** see `.factory/cycles/v0.1.0-greenfield/phase-1-log.md`
