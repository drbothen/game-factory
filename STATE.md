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

**Branch model:** `main` = product source; `factory-artifacts` = orphan branch (`.factory/` worktree); `.reference/vsdd-factory` @ develop `82163b7` (gitignored).

**Thesis (do not silently drop):** engine-agnostic / five-seam / no-lock-in — REAFFIRMED by human. Five ADAPTER seams: engine, asset, distribution, XR, online-services (CAP-015/SS-13 = online-services). Canon-KB (SS-10) is the SIXTH load-bearing (non-adapter) seam. (D-017: thesis wording corrected from prior 'compliance/analytics' restatement; spec is canonical.)

---

### ACTIVE SUB-LOOP (read this before doing anything)

**Phase-1d adversarial spec convergence IN PROGRESS — requires 3 CONSECUTIVE CLEAN adversary passes.**

**Current clean-pass counter: 0/3** (reset at Pass-32; Pass-35 was 8th findings pass since last reset)

**Next action: dispatch a FRESH-CONTEXT adversary (subagent `vsdd-factory:adversarial-review`) for Pass 36 against the spec package.**

Loop protocol:
1. Dispatch fresh-context adversary for Pass N. Route critical/important findings: product-owner (BC/PRD/error-taxonomy changes) and/or architect (architecture/methodology/ADR/CI-gate changes).
2. After each fix burst: run `bash scripts/check-spec-counts.sh` (must exit 0 — gate v1.28, checks a–y + o.ii, ~33 sub-assertions). Machine-enforced spec-integrity gate. NEVER credit a pass without a green gate run.
3. Commit via state-manager (main branch for script changes; factory-artifacts for .factory/ changes).
4. If pass is CLEAN (0 critical, 0 important): increment counter. If FINDINGS: reset counter to 0.
5. On reaching 3/3 consecutive clean passes: Phase-1d CONVERGED.

**On Phase-1d CONVERGED:** proceed to:
- Fresh-context consistency-validator audit (`/vsdd-factory:consistency-validation`) — T10
- `/vsdd-factory:check-input-drift` — T11
- Phase-1 spec-package HUMAN GATE — T12
- Phase 2+ — T13

**CI-gate contract:** `scripts/check-spec-counts.sh` v1.29 (checks a–z + o.ii, ~34 sub-assertions) on `main`. Purpose: prevent count-drift, vocabulary regression, and fix-induced cross-spec inconsistency across BC/NFR/error-taxonomy/priority/VP/studio/seam/dimension/creative-gate surfaces. MUST be green before any pass is credited.

---

## Current Phase Steps

| Step | Description | Status |
|------|-------------|--------|
| create-domain-spec | L2 domain spec (10 shards; 18 entities, 14 caps) | DONE |
| create-prd | PRD + 168 BCs across 14 caps → SS-01..SS-12 | DONE |
| create-architecture | 13 subsystems (SS-01..SS-13), 4-layer stack, 10 VPs, DTU assessment | DONE |
| prd-revision | Incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | DONE |
| cicd-setup | devops-engineer; `.github/workflows/` + `cicd-setup.md` (D-009; MANDATORY before Phase 3) | DONE |
| phase-1d-adversarial | Adversarial spec convergence (>=3 clean passes); Pass 35 FINDINGS (0C/1I) RESOLVED; **CLEAN-PASS COUNTER: 0/3**; Pass 36 pending | IN PROGRESS |
| consistency-audit | Fresh-context consistency audit (consistency-validator) | PENDING |
| drift-check | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| human-gate | Phase-1 spec-package human gate | PENDING |

---

## Next Action

**NEXT: `phase-1d-adversarial` — Pass 36** (candidate clean #1). Pass-35 FINDINGS (0C/1I) RESOLVED: F35-01(I) adapter-protocols.md §1.3 base manifest `seam` enum omitted `online-services-adapter` (5th seam) → added (v1.4); cross-surface propagation gap (JSONC enum in code fence, gate blind spot); CI check (z) added (gate v1.29) closes the JSONC-enum blind spot. FU-007/FU-008/FU-010/FU-011 open (non-blocking).

**Spec state:** prd v2.4; BC-INDEX v1.7; error-taxonomy v2.0 (255 codes / 31 families total / 246 active; E-GEN 9 retired); subsystem-decomposition v1.7 (P0=126/P1=42/P2=22); ARCH-INDEX v1.9 (13 subsystems); VP-INDEX v1.3; methodology-layer v1.11; ADR-0004 v1.3; ADR-0006 v1.2; adapter-protocols.md v1.4; studio-of-agents v1.4; dtu-assessment v1.1; nfr-catalog v1.3 (41 NFRs); layered-architecture v1.1; capabilities v1.2; prd-cap-008-012 v1.1; prd-cap-009-010 v1.1; BC-7.04.001 v1.2; BC-5.06.001 v1.3; BC-7.05.001 v1.3; BC-12.12.008 v1.3; BC-10.06.001 v1.2; CI gate v1.29 (checks a–z + o.ii, ~34 sub-assertions). Totals: 190 BCs / 255 error codes (246 active) / 41 NFRs / 15 caps / 13 subsystems / priority 126/42/22.

---

### Phase-1d Adversarial Convergence

| Pass | Date | Verdict | Findings | Resolved | Clean-pass counter |
|------|------|---------|----------|----------|--------------------|
| 1–17 | 2026-06-08 | FINDINGS×16 / CLEAN×1 | (see phase-1-log.md rows 9–25) | ALL RESOLVED | 1/3 after Pass-7; reset to 0/3 after Pass-8; 0/3 after Pass-17 |
| 18–30 | 2026-06-08 | FINDINGS×3 / CLEAN×7 | (see phase-1-log.md rows 26–38) | ALL RESOLVED | 2/3 after Pass-26; reset 0/3 at Pass-23, Pass-27; reset 0/3 at Pass-31 |
| 31 | 2026-06-08 | FINDINGS | 0C / 1I RESOLVED | I31-01: Canon-KB ordinal fifth→sixth (5 files, check o.ii); CI gate v1.25 | **RESET: 0/3** |
| 32 | 2026-06-08 | FINDINGS | 0C / 1I / 2 obs RESOLVED | I-PASS32-01: spurious DI-007 on cinematic creative gate (4 BCs); O-PASS32-01: prd §8.4 typo 34→30 families; O-PASS32-02: check (u) comment fix; check (w) added; CI gate v1.26 | **0/3** (stays; findings pass) |
| 33 | 2026-06-08 | FINDINGS | 0C / 1I / 2obs RESOLVED | F33-01: prd §4 NFR summary table missing NFR-036..041 → added (prd v2.4) + CI check (x)/gate v1.27; F33-03: BC-10.06.001 "compliance seam"→"compliance pipeline" (v1.2); F33-02: seam thesis human-adjudicated → D-017, STATE.md corrected | **0/3** (stays; findings pass) |
| 34 | 2026-06-08 | FINDINGS | 1C / 2I / 3obs RESOLVED | F34-01(C): studio-of-agents.md directed:true mislabeled human-gated → D-013 creative gate (E-CIN-003) [surviving I28-01 in arch roster] (studio v1.4) + check (u) broadened to arch docs; F34-02(I): lipsync-animator SS-03→SS-04 + §3 counts (studio v1.4) + check (h) updated; F34-03(I): distribution "fifth seam"→"third of five" (prd-cap-009-010 v1.1) + check (y) added; F34-04(obs): ADR-0004 §Context/§Alt 4-seam→5-seam (v1.3); F34-05(obs): studio §3 SS-01/SS-02 rows; F34-06(obs): DEFERRED → FU-011. CI gate v1.28 | **0/3** (stays; findings pass) |
| 35 | 2026-06-08 | FINDINGS | 0C / 1I / 0obs RESOLVED | F35-01(I): adapter-protocols.md §1.3 base manifest seam enum omitted online-services-adapter (5th seam) → added (v1.4); cross-surface propagation gap (JSONC enum in code fence, gate blind spot); CI check (z) added (gate v1.29) | **0/3** (stays; findings pass) |
| 36 | — | PENDING | — | — | — |

---

## Durable Task Ledger

| # | Milestone / Task | Status |
|---|-----------------|--------|
| M1 | Pre-pipeline preflight (product-brief v2.0 approved; preflight READY-WITH-WARNINGS) | DONE |
| M2 | Market-intel gate (D-006/07/08 human-ratified) | DONE |
| M3 | Phase-0 brownfield extraction + validation (VERIFIED-WITH-CORRECTIONS; human-approved) | DONE |
| M4 | Phase-1 L2 domain spec (10 shards; 18 entities, 14 caps; 79a625c) | DONE |
| M5 | Phase-1 L3 PRD + 168 BCs across 14 caps → 12 subsystems (e05fd9d) | DONE |
| M6 | Phase-1 architecture + 10 VPs + DTU assessment (c29f412; DTU_REQUIRED=true) | DONE |
| T7 | prd-revision — PRD v1.1; FU-001/002/003 closed; 170 BCs, 35 NFRs, 137 error codes | **DONE** |
| T8 | CI/CD setup — devops-engineer; `.github/workflows/` + `cicd-setup.md`; D-009 | **DONE** |
| T9 | Phase-1d adversarial spec convergence — Passes 1–35 all resolved/clean; Pass 35 FINDINGS (0c/1i) RESOLVED (adapter-protocols seam-enum [F35-01]: §1.3 base manifest omitted online-services-adapter; gate check (z) added); counter **0/3**; Pass 36 pending | **IN PROGRESS** |
| T10 | Fresh-context consistency audit (`consistency-validator`) | PENDING |
| T11 | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| T12 | Phase-1 spec-package HUMAN GATE | PENDING |
| T13 | Phase 2 — Story decomposition onward | PENDING |

---

## Phase Progress

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| pre-1 | Brief + Validation | PASSED | brief v2.0 human-approved; preflight READY-WITH-WARNINGS; market-intel PASSED |
| 0 | Brownfield Extraction | PASSED | VERIFIED-WITH-CORRECTIONS; ~70% conceptual/~85% file-level REUSE; human-approved |
| 1 | Spec Crystallization | IN PROGRESS | Steps 1–8 DONE; 13 subsystems / 15 caps / 41 NFRs / 255 error codes; see phase-1-log.md |
| 2–7 | Story Decomp → Convergence | PENDING | — |

---

## Decisions Log

| ID | Decision | Status |
|----|----------|--------|
| D-001 | Founding engine pair: Bevy + Unity | ACCEPTED |
| D-002 | Protocol stance: JSON-RPC 2.0 + conformance suite | ACCEPTED |
| D-003 | Determinism tiers T1/T2/T3 | ACCEPTED |
| D-004 | Asset generation: pure-maximal, no mandatory human creative finishing | ACCEPTED |
| D-005 | human-gated = external third-party acts only | ACCEPTED |
| D-006 | IP/copyrightability: pure-maximal retained; provenance sidecar | RATIFIED (human, 2026-06-07) |
| D-007 | Music/voice: pure-maximal retained; DEFAULT ship-safe generators | RATIFIED (human, 2026-06-07) |
| D-008 | Regulatory: compliance/provenance/ai-disclosure = P0 wave-1 | RATIFIED (human, 2026-06-07) |
| D-009 | Extracted core needs its own release/cross-compile pipeline (IMPLEMENTED de99845) | ACCEPTED (human, 2026-06-07) |
| D-010 | 11-dimension convergence model final (ADR-0006): D-ETHICS + D-SEC added | ACCEPTED |
| D-011 | compliance.iarc = objective-questions-only | ACCEPTED |
| D-012 | design-intent-contract requires playtest_delegation_note schema field | ACCEPTED |
| D-013 | sequence-graph directed:true = creative gate distinct from DI-006 | ACCEPTED |
| D-014 | DI-008 engine-neutrality scope = Layer-1/2 only; L3 adapter BCs may name engines | ACCEPTED — FLAG FOR HUMAN RATIFICATION at Phase-1 gate |
| D-015 | VP-TBD-NNN are BC-local placeholders; canonical `<BC-ID>/VP-TBD-NNN`; Phase-6 promotes | ACCEPTED — FLAG FOR HUMAN AWARENESS at Phase-1 gate |
| D-016 | CAP-015 Online-Services Adapter = Tier-1 v1; five-seam model | ACCEPTED (human, 2026-06-08) |
| D-017 | Canonical five ADAPTER seams = engine/asset/distribution/XR/online-services; Canon-KB (SS-10) sixth load-bearing seam. STATE.md thesis wording corrected (prior 'compliance/analytics' was a misremembered restatement; converged spec is canonical). | RATIFIED (human, 2026-06-08) |

---

## Blocking Issues

_(none open)_

---

## Pre-Phase-3 Mandatory Gates

| Item | Action | When |
|------|--------|------|
| DTU clone existence check | Verify 11 clones DTU-01..DTU-11 built | Before Phase 3 |
| CI/CD verification | DONE: 3 workflows on main @ de99845; branch protection pending | Before Phase 3 |
| LiteLLM proxy + API keys | Start proxy; populate `.env`/`.envrc`; verify GPT adversary route | Before Phase 5 |

---

## Open Follow-up Items

| ID | Item | Owner | When |
|----|------|-------|------|
| FU-005 | Adversarial spec pass must validate D-010..D-013 + BC-1.15.002 + BC-13.01.004. Pass-1: ALL VALIDATED WITH CORRECTIONS. Pending: 3 clean passes from Pass 33. | Phase-1d adversary | ONGOING |
| FU-006 | DTU framing divergence: DTU-01..10 authoritative vs brief §10 pre-architecture intent. Human confirm at Phase-1 gate. | human (Phase-1 gate) | OPEN |
| FU-007 | E-GLG-001 Coverage Note under-attributes (O7-01). Deferred optional cleanup. | product-owner | OPEN — non-blocking |
| FU-008 | methodology §3.0 "Subsystem" column dual-meaning. One-line clarifying note deferred. | product-owner | OPEN — non-blocking |
| FU-009 | methodology-layer.md SS-07→SS-06 owner-attribution mislabel (7 sites). Fixed Pass-24; check t added. | architect | **CLOSED** (Pass-24) |
| FU-010 | methodology-layer.md §4.3 ~line 1066: release-gating verb "blocked" for DEGRADED-PENDING D-CERT. Optional polish before Phase-1 human gate — NOT mid-streak. | product-owner | OPEN — non-blocking |
| FU-011 | Online-services seam-isolation NFR parity: no NFR parallels NFR-035 (XR seam isolation) for BC-15.09.001. Property IS enforced by BC-15.09.001 + E-OSVC-011; adding an NFR cascades count 41→42. Deferred — flag for human awareness at Phase-1 gate. | product-owner / human | OPEN — non-blocking |

---

## Session Resume Checkpoint

**Date:** 2026-06-08
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–8 DONE + Phase-1d Passes 1–35 DONE.
**Phase-1d Pass 35:** FINDINGS (0C/1I) RESOLVED. F35-01(I): adapter-protocols.md §1.3 base Capability Manifest `seam` field enum listed only 4 seam tokens (engine, asset, distribution, XR) — omitting `online-services-adapter` (the 5th seam). §6/§7 already had it; §1.3 JSONC code-fence was the gap. Fix: added `online-services-adapter` to §1.3 enum (adapter-protocols.md v1.4). Root cause: cross-surface propagation gap — JSONC enum inside code fence was not covered by any prior CI check. CI gate v1.29 adds check (z): asserts §1.3 enum token-set equals §8 compatibility-matrix seam-key set (both must be exactly 5 tokens). **Clean-pass counter stays 0/3** (findings pass; does not increment).
**Next action:** `phase-1d-adversarial` — **Pass 36** (candidate clean #1). FU-007/FU-008/FU-010/FU-011 remain open (non-blocking).
**Phase 1 remaining:** Phase-1d adversarial convergence (0/3 clean passes, need 3) → consistency audit (T10) → drift check (T11) → Phase-1 human gate (T12).
**Spec totals:** 190 BCs / 255 error codes (246 active) / 41 NFRs / 15 caps / 13 subsystems / priority P0=126/P1=42/P2=22 / CI gate v1.29 (checks a–z + o.ii, ~34 sub-assertions).
**Open FUs:** FU-007 (non-blocking), FU-008 (non-blocking), FU-010 (non-blocking), FU-011 (non-blocking). FU-009 CLOSED (Pass-24).
**Version bumps Pass 35:** adapter-protocols.md v1.4, CI gate v1.29.
**D-014/015/016/017:** see Decisions Log. D-014/D-015 flagged for human gate.
**Unpushed main commits:** v1.27 (e3fb80b) + v1.28 (960d2c2) + v1.29 (7a1498f) — 3 commits ahead of origin/main; awaiting user push authorization.
**Step history:** see `.factory/cycles/v0.1.0-greenfield/phase-1-log.md`
