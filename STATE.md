---
document_type: pipeline-state
project: game-factory
status: in_progress
current_step: phase-1d-adversarial
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
dtu_services: [game-engine-bevy, game-engine-unity, asset-gen-visual, asset-gen-audio, asset-gen-voice, asset-gen-3d, compliance-iarc, compliance-ai-disclosure, distribution-steam, distribution-itch, online-services-baas-nakama]
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

**Thesis (do not silently drop):** engine-agnostic / five-seam / no-lock-in — REAFFIRMED by human. Adapter seams are mandatory architecture, not optional scaffolding. Five seams: engine, asset, compliance, analytics, online-services (CAP-015/SS-13; Pass-13 C13-01 resolution).

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
| current step | phase-1d-adversarial |
| current cycle | v0.1.0-greenfield |

---

## Current Phase Steps

| Step | Description | Status |
|------|-------------|--------|
| create-domain-spec | L2 domain spec (10 shards; 18 entities, 14 caps) | DONE |
| create-prd | PRD + 168 BCs across 14 caps → SS-01..SS-12 | DONE |
| create-architecture | 13 subsystems (SS-01..SS-13), 4-layer stack, 10 VPs, DTU assessment | DONE |
| prd-revision | Incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | DONE |
| cicd-setup | devops-engineer; `.github/workflows/` + `cicd-setup.md` (D-009; MANDATORY before Phase 3) | DONE |
| phase-1d-adversarial | Adversarial spec convergence (>=3 clean passes; FU-005) — Passes 1–13 resolved (see phase-1-log.md rows 9–21); Pass 14 FINDINGS (2C/3I; C14-01 E-OSVC re-citations; C14-02 CI k.ii gap; I14-01 four-seam prose; I14-02 ARCH-INDEX intra-doc; I14-03 BC-15.11.001 H1 fragment; all resolved; CI v1.14; counter stays 0/3); clean passes: **0/3** | IN PROGRESS |
| consistency-audit | Fresh-context consistency audit (consistency-validator) | PENDING |
| drift-check | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| human-gate | Phase-1 spec-package human gate | PENDING |

---

## Next Action

**NEXT: `phase-1d-adversarial` — Pass 15** (candidate clean #1 of 3). Pass 14 FINDINGS: 2C/3I — C14-01 E-OSVC mis-citations in new CAP-015 BCs (security-relevant; D-SEC signal collision); C14-02 CI check (k) false-green (k.ii label-match added); I14-01 residual four-seam prose in 8+ files; I14-02 ARCH-INDEX intra-doc contradiction; I14-03 BC-15.11.001 H1 orphan fragment. All resolved. Counter stays 0/3. Full CAP-015 surface now audited.
**Spec state:** prd v2.0; BC-INDEX v1.6; error-taxonomy v1.9 (213 codes / 31 families total / 204 active; E-GEN 9 retired); subsystem-decomposition v1.6 (P0=126/P1=42/P2=22); ARCH-INDEX v1.9 (13 subsystems); VP-INDEX v1.3; methodology-layer v1.6; ADR-0004 v1.2 (five-seam; canon-KB=sixth); ADR-0006 v1.2; adapter-protocols.md v1.2; studio-of-agents v1.3; dtu-assessment v1.1; nfr-catalog v1.3 (41 NFRs); prd-cap-015.md; capabilities.md v1.1; invariants.md v1.1; L2-INDEX.md v1.1; prd-cap-002-003.md v1.1; BC-15.02.001 v1.1; BC-15.05.001 v1.1; BC-15.11.001 v1.1; product-brief.md v2.2. CI gate v1.14 (checks a–o; k.ii label-match + o seam-count added). Totals unchanged: 190 BCs / 213 codes / 15 caps / 13 subsystems / priority P0=126/P1=42/P2=22.
**cicd-setup COMPLETE** — 3 workflows (ci.yml, release.yml, security.yml) + cicd-setup.md on main @ de99845; D-009 implemented. lint job now includes Spec count consistency (S2-02) gate.

### Phase-1d Adversarial Convergence

| Pass | Date | Verdict | Findings | Resolved | Clean-pass counter |
|------|------|---------|----------|----------|--------------------|
| 1–11 | 2026-06-08 | FINDINGS×10 / CLEAN×1 | (see phase-1-log.md rows 9–19) | ALL RESOLVED | 1/3 after Pass-7; reset on Pass-8 → 0/3; back to 0/3 after Pass-11 |
| 12 | 2026-06-08 | FINDINGS | 0C / 2I / 3 obs | ALL RESOLVED | **0/3** |
| 13 | 2026-06-08 | FINDINGS | 1C / 1I / 0 obs | RESOLVED via CAP-015 build (human-approved scope completion) | **0/3** |
| 14 | 2026-06-08 | FINDINGS | 2C / 3I / 2 obs | RESOLVED (E-OSVC re-citations, five-seam prose sweep, k.ii+o checks) | **0/3** |

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
| T7 | prd-revision — PRD v1.1; FU-001/002/003 closed; 170 BCs, 35 NFRs, 137 error codes / 21 families | DONE |
| T8 | **CI/CD setup** — devops-engineer; `.github/workflows/` + `cicd-setup.md`; D-009 (MANDATORY before Phase 3) | **DONE** |
| T9 | Phase-1d adversarial spec convergence — Passes 1–13 all findings resolved (see phase-1-log.md); Pass 14 FINDINGS (2C/3I; C14-01 E-OSVC re-citations; C14-02 k.ii CI gap; I14-01 four-seam prose; I14-02 ARCH-INDEX intra-doc; I14-03 H1 fragment; CI v1.14; counter stays 0/3); Pass 15 pending | **IN PROGRESS** |
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
| 1 | Spec Crystallization | IN PROGRESS | Steps 1–8 DONE (L2→PRD+190 BCs→architecture+VPs→prd-revision→CI/CD→adversarial Pass 1–14); 13 subsystems / 15 caps / 41 NFRs / 213 error codes; see phase-1-log.md |
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
| D-009 | Extracted core needs its own release/cross-compile pipeline — owner: devops-engineer, target Phase 1+ | ACCEPTED (human, 2026-06-07) (IMPLEMENTED de99845) |
| D-010 | 11-dimension convergence model final (ADR-0006): D-ETHICS + D-SEC added to original 9 dims | ACCEPTED (architect, 2026-06-08) |
| D-011 | compliance.iarc = objective-questions-only (no LLM inference on IARC rating) | ACCEPTED (architect, 2026-06-08) |
| D-012 | design-intent-contract requires playtest_delegation_note schema field (methodology-layer) | ACCEPTED (architect, 2026-06-08) |
| D-013 | sequence-graph directed:true = creative gate distinct from DI-006 external-human-gate (ADR-0007) | ACCEPTED (architect, 2026-06-08) |
| D-014 | DI-008 engine-neutrality scope = Layer-1/Layer-2 core+spec artifacts only; L3 adapter-behavior BCs may name specific engines illustratively (adapters are engine-specific by design); O1 adjudicated IN-BOUNDS | ACCEPTED (orchestrator, 2026-06-08) — FLAG FOR HUMAN RATIFICATION at Phase-1 gate |
| D-015 | VP-TBD-NNN labels are BC-LOCAL placeholder identifiers; canonical form is `<BC-ID>/VP-TBD-NNN` (e.g., BC-6.01.001/VP-TBD-001); VP-INDEX is not required to enumerate all BC-local VP-TBDs globally; Phase-6 formal hardening promotes BC-local VP-TBDs to canonical VP-NNN identifiers | ACCEPTED (architect, 2026-06-08) — FLAG FOR HUMAN AWARENESS at Phase-1 gate |
| D-016 | Online-services/BaaS (Nakama) = Tier-1 v1 ship-prerequisite capability CAP-015; built faithful to product brief per human decision 2026-06-08; five-seam adapter model (engine/asset/compliance/analytics/online-services); `serverAuthoritative` required for leaderboards + entitlements; `offlineProject` off-by-default | ACCEPTED (human, 2026-06-08) |

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
| DTU clone existence check | Verify 11 clones DTU-01..DTU-11 built (DTU-08 Nakama wired to CAP-015/SS-13; see `specs/architecture/dtu-assessment.md` v1.1) | Before Phase 3 |
| CI/CD verification | DONE: 3 workflows on main @ de99845 (ci.yml/release.yml/security.yml; SHA-pinned actions; timeout-minutes; least-priv perms; 4 stub jobs); cicd-setup.md @ cf9fc6a. lint job now includes **Spec count consistency (S2-02)** gate (`scripts/check-spec-counts.sh`). Required status checks: `CI / lint`, `CI / test`, `CI / build`, `CI / pure-sim-verify`. Branch protection NOT yet applied — pending. | Before Phase 3 |
| LiteLLM proxy + API keys | Start proxy; populate `.env` / `.envrc`; verify GPT adversary route | Before Phase 5 |

---

## Open Follow-up Items

| ID | Item | Owner | When |
|----|------|-------|------|
| FU-001..004 | DI-010/011 BCs; NFR numeric targets; missing error families; SS-TBD identifiers | — | **ALL CLOSED** (see phase-1-log.md steps 7/9) |
| FU-005 | Adversarial spec pass must validate architect clarifications D-010..D-013 + BC-1.15.002 + BC-13.01.004. **Pass-1 status: ALL VALIDATED WITH CORRECTIONS** — D-010 confirmed; D-011 confirmed; D-012 DI-012 normalization applied (I4); D-013 creative-gate disambiguation applied (I5); BC-1.15.002 pattern list extended (I7); BC-13.01.004 cert path completed (I8). Pending: 3 clean passes from Pass 2 onward. | Phase-1d adversary | ONGOING |
| FU-006 | **DTU framing divergence (human-gate awareness):** DTU clone enumeration DTU-01..10 (post-architecture) differs from product-brief §10 service list (pre-architecture framing). Both enumerate 10 services but names/groupings differ. DTU-01..10 is authoritative; brief §10 is pre-architecture intent. Human should confirm at Phase-1 gate that DTU-01..10 is the operative enumeration. Flagged by Pass-4 O3. | human (Phase-1 gate) | OPEN — awaiting human gate |
| FU-007 | **E-GLG-001 changelog attribution (O7-01 from Pass 7):** error-taxonomy.md line ~596 Coverage Note under E-GLG-001 under-attributes the code — omits BC-13.02.002/004/005 and BC-13.03.001 as emitters. Section header (line ~516) is correct and CI check (k) is GREEN; this is a changelog-summary granularity nit only. Deferred optional cleanup — may fold into a later doc-cleanup pass. | product-owner | OPEN — non-blocking; deferred |
| FU-008 | **methodology §3.0 dimension "Subsystem" field dual-meaning clarification (O-1 from Pass 11):** §3.0 dimension table "Subsystem" column names the source-domain subsystem (e.g. D-CERT→SS-08/09) while §3.1 "Owner BC" column lists SS-07 evaluation-layer BCs as owners. A one-line clarifying note under the column header would resolve the dual-meaning ambiguity for fresh-context readers. Non-blocking; may fold into a doc-cleanup pass. | product-owner | OPEN — non-blocking; deferred |

---

## Session Resume Checkpoint

**Date:** 2026-06-08
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–8 DONE + Phase-1d Passes 1–14 DONE.
**Phase-1d Pass 14 FINDINGS resolved:** (C14-01 CRITICAL) E-OSVC mis-citations in new CAP-015 BCs — BC-15.02.001 E-OSVC-003→013 (3 sites); BC-15.05.001 E-OSVC-004→014 + E-OSVC-006→015 (5+ sites); registry was correct, BCs had drifted; D-SEC signal collision closed. (C14-02 CRITICAL, process) CI check (k) false-green — k.ii label-match added (E-EAP exact-CamelCase + E-OSVC word-overlap; 32 citations validated, 0 contradictions). (I14-01 IMPORTANT) Residual four-seam prose in 8+ files — capabilities.md/invariants.md/L2-INDEX.md/prd.md/prd-cap-002-003.md/product-brief.md/planning docs all updated to five-seam. (I14-02 IMPORTANT) ARCH-INDEX intra-doc contradiction resolved; ARCH-INDEX v1.9. (I14-03 IMPORTANT) BC-15.11.001 H1 orphan fragment removed; BC-INDEX v1.6. O14-01/O14-02 resolved: check (o) seam-count guard added; ADR-0004 v1.2 (canon-KB = sixth seam). CI gate v1.14 (a–o) ALL CHECKS PASSED exit 0.
**Next action:** `phase-1d-adversarial` — **Pass 15** (candidate clean #1 of 3). Full CAP-015/SS-13 surface has been audited. Need 3 consecutive clean passes to converge.
**Phase 1 remaining:** Phase-1d adversarial convergence (0/3 clean passes) → consistency audit → drift check → Phase-1 human gate.
**PRD status:** v2.0. 190 BCs; 41 NFRs; 213 error codes / 31 families total (204 active; E-GEN 9 codes retired). FU-001/002/003 CLOSED. FU-005 ongoing. FU-006 open (DTU framing, human gate). FU-007 open (E-GLG-001 Coverage Note, non-blocking deferred). FU-008 open (§3.0 Subsystem col dual-meaning, non-blocking deferred).
**Architecture:** 13 subsystems (SS-01..SS-13); 4-layer stack; 5 adapter seams; methodology-layer v1.6 (11 convergence dims); 66-role studio (53T1+13T2); DTU_REQUIRED=true, 11 clones pending. ADR-0004 v1.2 (five-seam; canon-KB=sixth) / ADR-0006 v1.2. 10 VPs (6 P0, 4 P1). Priority: 190 BCs / P0=126 / P1=42 / P2=22.
**Key versions changed Pass 14:** BC-15.02.001 v1.1; BC-15.05.001 v1.1; BC-15.11.001 v1.1; BC-INDEX.md v1.6; ARCH-INDEX.md v1.9; ADR-0004.md v1.2; prd.md v2.0; product-brief.md v2.2; capabilities.md v1.1; invariants.md v1.1; L2-INDEX.md v1.1; prd-cap-002-003.md v1.1; CI gate v1.14 (checks a–o; k.ii label-match + o seam-count).
**D-014:** DI-008 engine-neutrality scope = Layer-1/Layer-2 only; L3 adapter-behavior BCs may name engines illustratively. FLAG FOR HUMAN RATIFICATION at Phase-1 gate.
**D-015:** VP-TBD-NNN are BC-local placeholders; canonical form `<BC-ID>/VP-TBD-NNN`; Phase-6 promotes to VP-NNN. FLAG FOR HUMAN AWARENESS at Phase-1 gate.
**D-016:** CAP-015 Online-Services Adapter = Tier-1 v1 capability per product brief; human-approved build 2026-06-08; five-seam model.
**Step history:** see `.factory/cycles/v0.1.0-greenfield/phase-1-log.md`
**File manifest:** see `.factory/cycles/v0.1.0-greenfield/phase-1-log.md`
