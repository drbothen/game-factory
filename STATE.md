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
timestamp: 2026-06-16T00:00:00Z
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

**Current clean-pass counter: 0/3** (restart #3 still seeking clean #1). Next action: Pass 64 (candidate clean #1). Pass 63 FINDINGS (F63-01: BC-7.01.001 test vectors claimed 11 sim-BCs but precondition/postcondition define 10; BC-6.04.001 Red Gate is impl-dimension input, not a sim-BC — fixed test vectors to 10, v1.1; F63-02→FU-025).

Loop protocol:
1. Dispatch fresh-context adversary for Pass N. Route critical/important findings: product-owner (BC/PRD/error-taxonomy changes) and/or architect (architecture/methodology/ADR/CI-gate changes).
2. After each fix burst: run `bash scripts/check-spec-counts.sh` (must exit 0 — gate v1.44, checks a–z + aa, bb, cc, dd, ee, ff, gg, hh, ii, jj, kk, ll, mm + o.ii, ~42 sub-assertions; check (gg) is D-SEC evaluator-completeness guard; check (hh) is economy-conservation BC-routing guard; check (ii) is visionOS/OpenXR dedicated-code routing guard; check (jj) is D-SEC no-DEGRADED-path consistency guard; check (kk) is W-code identifier-resolution guard; check (ll) is T2 comparison-method consistency guard; check (mm) is anti-cheat kernel-anomaly routing guard). Machine-enforced spec-integrity gate. NEVER credit a pass without a green gate run.
3. Commit via state-manager (main branch for script changes; factory-artifacts for .factory/ changes).
4. If pass is CLEAN (0 critical, 0 important): increment counter. If FINDINGS: reset counter to 0.
5. On reaching 3/3 consecutive clean passes: Phase-1d CONVERGED.

**Adversary dispatch template (turnkey resume):** see `.factory/cycles/v0.1.0-greenfield/adversary-dispatch-playbook.md` — captures the gated-class skip-list, accepted conventions, already-swept classes, FU-005 targets, and deep-cross-BC focus to reconstruct an equivalent Pass-N dispatch from zero context.

**On Phase-1d CONVERGED:** proceed to:
- Fresh-context consistency-validator audit (`/vsdd-factory:consistency-validation`) — T10
- `/vsdd-factory:check-input-drift` — T11
- Phase-1 spec-package HUMAN GATE — T12
- Phase 2+ — T13

---

## Current Phase Steps

| Step | Description | Status |
|------|-------------|--------|
| create-domain-spec | L2 domain spec (10 shards; 18 entities, 14 caps) | DONE |
| create-prd | PRD + 168 BCs across 14 caps → SS-01..SS-12 | DONE |
| create-architecture | 13 subsystems (SS-01..SS-13), 4-layer stack, 10 VPs, DTU assessment | DONE |
| prd-revision | Incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | DONE |
| cicd-setup | devops-engineer; `.github/workflows/` + `cicd-setup.md` (D-009; MANDATORY before Phase 3) | DONE |
| phase-1d-adversarial | Adversarial spec convergence (>=3 clean passes); Passes 1–63 resolved (see phase-1-log.md + convergence table below); 3 streak breaks at P46/49/51; security-burst tails at P43/44/53; latest: Pass 63 FINDINGS (F63-01: BC-7.01.001 test vectors sim-BC set 11→10, Red Gate is impl-dimension input — fixed v1.1; F63-02→FU-025); **COUNTER: 0/3**; Pass 64 = restart #3 clean #1 candidate | IN PROGRESS |
| consistency-audit | Fresh-context consistency audit (consistency-validator) | PENDING |
| drift-check | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| human-gate | Phase-1 spec-package human gate | PENDING |

---

## Next Action

**NEXT: `phase-1d-adversarial` — Pass 64** (candidate clean #1, restart #3 continues). Pass-42/53 security-burst tails now found+fixed+gated at Passes 43(dd), 44(ee), 53(gg), 56(jj). Pass-63 F63-01 fixed BC-7.01.001 test vectors: sim-BC set cardinality was 11 (phantom BC-6.04.001 Red Gate); corrected to 10 (BC-6.01.001–004 + BC-6.02.001–005 + BC-6.03.001); v1.1. Gate stays v1.44. FU-007..025 open (non-blocking).

**Spec state:** prd v2.7; BC-INDEX v1.9 (193 BCs; BC-5.04.002 v1.3, BC-14.02.001 v1.2, BC-7.01.001 **v1.1** — BC-INDEX has no per-BC version column, no index edit needed); error-taxonomy **v2.5** (267 error codes / 34 families / 258 active + Warning Codes registry: 4 W-codes W-XR-001..004); nfr-catalog v1.4 (41 NFRs); subsystem-decomposition v2.0 (P0=127/P1=42/P2=24); ARCH-INDEX v2.3 (13 subsystems, ADR-0008); methodology-layer **v1.16** (F56: D-SEC=GREEN,BLOCKED always-enabled SP4 unconditional); BC-7.11.001 v1.2 (SP4 fail-closed secrets); BC-7.11.002 v1.2 (offline test vector scoped); BC-7.11.004 **v1.1** (F57-01: wrong-BC-ID route 7.11.006→7.11.007 fixed); BC-14.02.001 **v1.2** (F58-01: EC-001 60→E-XR-004 corrected); BC-5.04.002 **v1.3** (F59-01: OBS-20-B reciprocal subordination; SS-04 = validation view over CAP-012-owned store); L2-INDEX v1.2 (F49: comprehensive registry audit); BC-12.12.003 v1.3 (F52: DI-007 removed); verification-architecture **v1.2** (F60-01+F60-02); BC-13.02.001 **v1.2** (F60-01 VP-007 back-ref); VP-004-no-softlock-reachability **v1.2** (F60-02); VP-INDEX **v1.6** (F60-02 VP-004 row); verification-coverage-matrix **v1.3** (F60-02); BC-6.02.004 **v1.1** (F60-02 back-ref); adapter-protocols **v1.5** (F61-01: §2.3 same-machine→snapshot-structured-diff; §2.5 ReplayResult enum all 3 methods); ADR-0008 **v1.2** (F62-01: Conformance Assertion item 3 kernel-anomaly mis-route E-ANTICH-001→E-ANTICH-002 corrected); BC-7.01.001 **v1.1** (F63-01: sim-BC set cardinality 11→10 in test vectors; Red Gate BC-6.04.001 is impl-dimension input, not a sim-BC); CI gate **v1.44** (checks a–z + aa, bb, cc, dd, ee, ff, gg, hh, ii, jj, kk, ll, mm + o.ii, ~42 sub-assertions; check (ll) = T2 comparison-method consistency guard; check (mm) = anti-cheat kernel-anomaly routing guard). Totals: 193 BCs / 267 error codes (258 active) / 41 NFRs / 15 caps / 13 subsystems / 13 DI / P0=127/P1=42/P2=24. Note: error-taxonomy now carries a Warning Codes registry (4 W-codes) — warnings NOT counted in the 267 error codes. See Session Resume Checkpoint for full version-bump list.

---

### Phase-1d Adversarial Convergence

| Pass | Date | Verdict | Summary | Clean-pass counter |
|------|------|---------|---------|-------------------|
| 1–17 | 2026-06-08 | FINDINGS×16 / CLEAN×1 | (see phase-1-log.md rows 9–25) | 0/3 after Pass-17 |
| 18–32 | 2026-06-08 | FINDINGS×5 / CLEAN×5 | (see phase-1-log.md rows 26–40) | 0/3 after Pass-32 |
| 33–53 | 2026-06-08–10 | FINDINGS×18 / CLEAN×3 | (see phase-1-log.md — Passes 33–53 appended 2026-06-13; 3 streak breaks at Pass-46/49/51, security-burst tails at P43/44/53, Pass-45 clean 1/3 reset P46, Pass-47/48 clean 2/3 reset P49, Pass-50 clean 1/3 reset P51) | 0/3 after Pass-53 |
| 54–62 | 2026-06-10–13 | FINDINGS×9 | (see phase-1-log.md — Passes 54–62 appended 2026-06-16; checks hh/ii/jj/kk/ll/mm added; gate stays v1.44; BC-7.11.001/002 v1.2, BC-7.11.004 v1.1, BC-14.02.001 v1.2, BC-5.04.002 v1.3, BC-14.01.001 v1.1, verification-architecture v1.2, BC-13.02.001 v1.2, VP-004 v1.2, VP-INDEX v1.6, adapter-protocols v1.5, ADR-0008 v1.2) | 0/3 after Pass-62 |
| 63 | 2026-06-16 | FINDINGS | F63-01(I): BC-7.01.001 test vectors claimed 11 sim-BCs but precondition/postcondition define 10 (BC-6.04.001 Red Gate is impl-dimension input, not a sim-BC). Fixed test vectors to 10; v1.1. F63-02(obs→FU-025): BC-7.09.001:56-57 docs-dimension GREEN phrasing awkward. | **0/3** (stays) |
| 64 | — | PENDING | — | — |

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
| T9 | Phase-1d adversarial spec convergence — Passes 1–63 resolved; Pass 63 FINDINGS (F63-01: BC-7.01.001 sim-BC set 11→10 in test vectors — BC-6.04.001 Red Gate is impl-dimension input; fixed v1.1; F63-02→FU-025); counter 0/3; Pass 64 = restart #3 clean #1 candidate | **IN PROGRESS** |
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
| 1 | Spec Crystallization | IN PROGRESS | Steps 1–8 DONE; 193 BCs / 13 subsystems / 15 caps / 41 NFRs / 267 error codes / 13 DI; see phase-1-log.md |
| 2–7 | Story Decomp → Convergence | PENDING | — |

---

## Decisions Log

| ID | Decision | Status |
|----|----------|--------|
| D-001..013 | Founding decisions (engine pair, protocol, determinism, asset-gen, human-gated, IP, music, regulatory, pipeline, 11-dim model, IARC, playtest-delegation, creative-gate). All ACCEPTED/RATIFIED. | See `.factory/cycles/v0.1.0-greenfield/decisions-log-archive.md` |
| D-014 | DI-008 engine-neutrality scope = Layer-1/2 only; L3 adapter BCs may name engines | ACCEPTED — FLAG FOR HUMAN RATIFICATION at Phase-1 gate |
| D-015 | VP-TBD-NNN are BC-local placeholders; canonical `<BC-ID>/VP-TBD-NNN`; Phase-6 promotes | ACCEPTED — FLAG FOR HUMAN AWARENESS at Phase-1 gate |
| D-016 | CAP-015 Online-Services Adapter = Tier-1 v1; five-seam model | ACCEPTED (human, 2026-06-08) |
| D-017 | Canonical five ADAPTER seams = engine/asset/distribution/XR/online-services; Canon-KB (SS-10) sixth load-bearing seam. STATE.md thesis wording corrected (prior 'compliance/analytics' was a misremembered restatement; converged spec is canonical). | RATIFIED (human, 2026-06-08) |
| D-018 | D-012 refinement: design-intent-contract delegation field is the STRUCTURED `playtest_delegation` section with `delegated_claims[]` (each {claim, reason_not_machine_verifiable, instrument}), NOT the prior scalar `playtest_delegation_note`. Intent (explicit delegation boundary) preserved; name+shape refined. methodology-layer §2.2 + DI-012 pass-predicate updated. | ACCEPTED (Pass-40 F40-03) |
| D-019 | Pass-42 security gap: D-SEC dimension referenced undefined moderation-pipeline-contract (CSAM→NCMEC, 18 U.S.C. §2258A) + anti-cheat-integration-adapter; no secrets gate on output. Human approved authoring the FULL contracts now: BC-13.03.005 (moderation/SS-11), BC-13.02.006 (anti-cheat/SS-11, ADR-0008 allowed providers {EAC,EOS,BattlEye}, Riot Vanguard rejected), BC-1.15.003 (never-emit-secrets/SS-01, DI-013). | RATIFIED (human, 2026-06-09) |

---

## Pre-Phase-3 Mandatory Gates

| Item | Action | When |
|------|--------|------|
| DTU clone existence check | Verify 11 clones DTU-01..DTU-11 built | Before Phase 3 |
| CI/CD verification | DONE: 3 workflows on main @ de99845; branch protection pending | Before Phase 3 |
| LiteLLM proxy + API keys | Start proxy; populate `.env`/`.envrc`; verify GPT adversary route | Before Phase 5 |

**HUMAN-AWARENESS FLAG (Pass-42 new security scope — review at Phase-1 spec-package gate):**
- **BC-13.03.005** (moderation-pipeline-contract, CSAM→NCMEC reporting, 18 U.S.C. §2258A): NEW mandatory compliance contract authored in Pass-42. Legal/compliance significance — requires explicit human review at Phase-1 gate.
- **ADR-0008** (anti-cheat provider policy): Riot Vanguard REJECTED (kernel-level driver); EAC/EOS/BattlEye allowed. Human must confirm this policy is acceptable before Phase-3 implementation.
- **BC-1.15.003** (never-emit-secrets): New gate added to cicd-setup v1.2. Confirm secrets scanning toolchain is provisioned before Phase-3.

---

## Open Follow-up Items

| ID | Item | Owner | When |
|----|------|-------|------|
| FU-005 | Adversarial spec pass must validate D-010..D-013 + BC-1.15.002 + BC-13.01.004. Pass-1: ALL VALIDATED WITH CORRECTIONS. Pending: 3 clean passes from Pass 33. | Phase-1d adversary | ONGOING |
| FU-006 | DTU framing divergence: DTU-01..10 authoritative vs brief §10 pre-architecture intent. Human confirm at Phase-1 gate. | human (Phase-1 gate) | OPEN |
| FU-007 | E-GLG-001 Coverage Note under-attributes (O7-01). Deferred optional cleanup. | product-owner | OPEN — non-blocking |
| FU-008 | methodology §3.0 "Subsystem" column dual-meaning. One-line clarifying note deferred. | product-owner | OPEN — non-blocking |
| FU-010 | methodology-layer.md §4.3 ~line 1066: release-gating verb "blocked" for DEGRADED-PENDING D-CERT. Optional polish before Phase-1 human gate — NOT mid-streak. | product-owner | OPEN — non-blocking |
| FU-011 | Online-services seam-isolation NFR parity: no NFR parallels NFR-035 (XR seam isolation) for BC-15.09.001. Property IS enforced by BC-15.09.001 + E-OSVC-011; adding an NFR cascades count 41→42. Deferred — flag for human awareness at Phase-1 gate. | product-owner / human | OPEN — non-blocking |
| FU-012 | VP-TBD placeholder ID collisions across BCs (VP-TBD-043..046 reused in ss-01/ss-03/ss-14 BCs with different properties). Harmless until promotion. Resolve (renumber to globally-unique or namespace by BC-ID) AND add a VP-TBD uniqueness lint at Phase-6 VP promotion. | architect | OPEN — non-blocking; target Phase-6 |
| FU-013 | OBS-47-A: BC-13.02.006:149 Related-BCs annotation uses descriptive "competitive-multiplayer lane" without the genre-profile.esports_enabled pin. Prose-only; operative trigger unambiguous elsewhere. Cleanup at Phase-1 gate or next BC touch. | product-owner | OPEN — non-blocking |
| FU-014 | OBS-47-B [process-gap]: BC "Architecture Anchors" sections reference forward-reference module files architecture/SS-NN-*.md that don't exist yet (uniform across 13 subsystems; likely intentional convention). Decide: (a) document the forward-reference convention explicitly, or (b) extend gate to assert anchor subsystem-prefix matches BC subsystem: field. | architect | OPEN — non-blocking; decide at Phase-1 gate |
| FU-016 | OBS-1: BC-13.01.004 PC§2 (~line 99-101) parenthetical "set to DEGRADED-PENDING (not PASS)" uses "PASS" as loose shorthand for the dimension GREEN state; dimension enum is GREEN/DEGRADED-PENDING/BLOCKED while overall_status enum is PASS/FAIL/PARTIAL. Operative value (DEGRADED-PENDING) correct; cosmetic clarity nit. Cleanup at Phase-1 gate or next BC touch. | product-owner | OPEN — non-blocking |
| FU-017 | OBS-51-A: BC-10.05.001 describes EU Art.50 scope as "image/audio/video/text" but no `video` asset_class exists (factory ships engine-agnostic real-time sequence-graphs, not pre-rendered video). Add a one-line note that the EU video category is structurally N/A. | product-owner | OPEN — non-blocking |
| FU-018 | OBS-51-B: BC-14.01.001 frontmatter appears to lack an explicit `id:` field (unlike SS-04/SS-09 siblings). Verify against frontmatter-schema check (f); add id: if genuinely missing. | product-owner | OPEN — non-blocking; verify |
| FU-019 | OBS-55-A/ambiguous: BC-14.02.002 EC-005 — automated sign-off of a human gate (playtest_gate.signed_off:true by tooling) emits E-XR-001 (schema). Genuinely ambiguous vs E-EAP-013 (HumanGatedTaskPending / human-gate-boundary). Human adjudication: schema-level vs DI-006-boundary enforcement. | human (Phase-1 gate) | OPEN — non-blocking |
| FU-020 | OBS-55-B [process-gap codification]: generic-vs-dedicated error-code routing class has recurred (F39-02 E-ENG/E-CIN, F55-01 E-XR). A GENERAL cross-BC "same canonical-test-vector input → consistent error-code" check would codify it, but is infeasible as a simple grep (semantic input-matching). Targeted guards added per-instance (hh economy, ii visionOS). Consider a real tooling investment if the class recurs again. | architect | OPEN — non-blocking; codification candidate |
| FU-021 | F57-02 (obs): VP-TBD-003 (BC-6.01.002:108) asserts `hp_delta ≥ 0` but EC-005 (line 90) permits healing modeled as negative damage → non-entailment. Non-blocking (VP-TBD-003 is unresolved placeholder; EC-005 conditional). Resolve at VP-TBD-003 promotion (Phase-6): scope VP-TBD-003 to non-healing rows OR restate as `hp_delta ∈ [-(max_hp − current_hp), current_hp]`. | product-owner | Phase-6 VP-TBD-003 promotion — OPEN non-blocking |
| FU-022 | F58-02 (obs): BC-12.12.009:105 canonical-test-vector label "(EC-001 bootstrap variant)" is a stale cross-ref — bootstrap behavior is in Postcondition §5, not EC-001. Cosmetic cleanup. | product-owner | Phase-1 gate or next BC touch — OPEN non-blocking |
| FU-023 | F60-03 (obs): verification-architecture.md:71 paraphrases VP-006 loosely as "RD strictly decreasing across rating periods", eliding the F40-05 baseline nuance (RD increases over inactive periods; strictly decreases below pre-inactivity RD_old). Description-tightening only. | architect | Phase-1 gate or next touch — OPEN non-blocking |
| FU-024 | [process-gap, codification candidate] Gate check (ll) — VP property-statement propagation to BC "Formally verified by VP-NNN (...)" back-refs. Deferred: prerequisite is normalizing BC VP back-refs verbatim-from-VP-INDEX (VP-006 abbreviated, VP-008 enriched). Once normalized, add lead-phrase-substring check (ll) to scripts/check-spec-counts.sh. Per LESSON-F52, avoid over-firing gate. | architect | Before Phase-6 VP promotion — OPEN non-blocking |
| FU-025 | F63-02 (obs): BC-7.09.001:56-57 docs-dimension GREEN postcondition phrasing reads as if a Red-Gate bypass must EXIST to be GREEN; intent is "if any bypass occurred it must be logged." Awkward phrasing, not a contradiction; non-blocking. Cleanup at Phase-1 gate or next BC touch. | product-owner | Phase-1 gate or next BC touch — OPEN non-blocking |
| LESSONS-CODIFIED | LESSON-F43/F46/F49a/F49b/F52/F53/F56/F58 — all codified in CI checks dd/ee/ff/w/gg/jj/kk. LESSON-F60 [pending-codification] — VP re-scope must sweep all downstream surfaces. LESSON-F61 [codified] — F40-01 determinism/replay fix must sweep adapter-protocols.md tier table + ReplayResult enum; new gate guard must be validated by orchestrator's own run before crediting. Codified check (ll). LESSON-F62 [codified] — ADR is normative; wrong-but-registered E-code (semantic mis-routing) passes check (k) — routing target must also be semantically correct. Codified check (mm) for kernel-anomaly anti-cheat case. Full text: `.factory/cycles/v0.1.0-greenfield/lessons.md` | — | CODIFIED (LESSON-F60 pending gate; LESSON-F61 codified check ll; LESSON-F62 codified check mm) |

---

## Session Resume Checkpoint

**Date:** 2026-06-16
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–8 DONE + Phase-1d Passes 1–63 DONE.
**Phase-1d Pass 63:** FINDINGS (0C/1I/1obs). F63-01(I): BC-7.01.001 (sim/spec convergence dimension evaluator) test vectors said "All 11 sim-BCs PASS" / "10 PASS, BC-6.01.001 FAIL" (an 11-member set), contradicting Precondition 1 + Postcondition which define the sim-BC set as exactly 10 (BC-6.01.001–004 + BC-6.02.001–005 + BC-6.03.001). The phantom 11th was BC-6.04.001 (TDD Red Gate, SS-05/CAP-006) — an implementation-dimension input (BC-7.03.001), not a sim-BC. Fixed both test-vector rows to 10; BC-7.01.001 v1.0→v1.1. F63-02(obs→FU-025): BC-7.09.001:56-57 docs-dimension GREEN postcondition phrasing awkward; non-blocking, deferred.
**Clean-pass counter: 0/3 (counter stays — findings pass; restart #3 still seeking clean #1).** Pass 64 = restart #3 candidate clean #1.
**Next action:** `phase-1d-adversarial` — **Pass 64** (candidate clean #1, restart #3 continues). Spec FROZEN after F63 fix burst. FU-007/FU-008/FU-010/FU-011/FU-012/FU-013/FU-014/FU-016/FU-017/FU-018/FU-019/FU-020/FU-021/FU-022/FU-023/FU-024/FU-025 open (non-blocking). FU-015 CLOSED (F51-02).
**Phase 1 remaining:** Phase-1d adversarial convergence (0/3 clean passes, need 3) → consistency audit (T10) → drift check (T11) → Phase-1 human gate (T12).
**Spec totals:** 193 BCs / 267 error codes (258 active) / 41 NFRs / 15 caps / 13 subsystems / 13 DI invariants / P0=127/P1=42/P2=24 / CI gate v1.44 (~42 sub-assertions). Error codes UNCHANGED (267); Warning Codes registry carries 4 W-codes (NOT counted in 267). §3.1 D-SEC = 2 allowed values (GREEN, BLOCKED); check (s) verifies 33 dim-value pairs.
**Version bumps Pass 63:** BC-7.01.001 v1.1 (F63-01: sim-BC set cardinality 11→10 in test vectors; Red Gate BC-6.04.001 is impl-dimension input, not a sim-BC). BC count UNCHANGED (193). CI gate UNCHANGED v1.44. Spec totals UNCHANGED (193 BCs / 267 error codes / 41 NFRs / 15 caps / 13 subsystems / 4 W-codes).
**Open FUs:** FU-005/006/007/008/010/011/012/013/014/016/017/018/019/020/021/022/023/024/025 open (all non-blocking except FU-005 ONGOING). FU-009 CLOSED (Pass-24). FU-015 CLOSED (F51-02). See Open Follow-up Items table above.
**Decisions:** D-014/015/019 flagged for human gate review. D-001..013 see decisions-log-archive.md. D-018/019 in effect.
**main branch:** CI gate v1.44 (no change this pass). Step history: see phase-1-log.md.
**GATE EXECUTION NOTE:** Run `bash scripts/check-spec-counts.sh` as a SINGLE isolated process — concurrent runs corrupt shared state and produced a spurious check-(k) false-positive during Pass 57. Gate must exit 0 before crediting any pass.
