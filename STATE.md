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
timestamp: 2026-06-16T12:00:00Z
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

**Current clean-pass counter: 0/3** (restart #3 still seeking clean #1). Next action: Pass 66 (candidate clean #1). Pass 65 FINDINGS (F65-01: adapter-seam divergence — BC-15.01.001 hard-gates leaderboards.variantsSupported (E-EAP-012) but adapter-protocols §6.2 mandatory-field rules omitted it + BC citation mis-targeted; fixed adapter-protocols v1.6 + BC-15.01.001 v1.2; codified gate check (oo) v1.46).

Loop protocol:
1. Dispatch fresh-context adversary for Pass N. Route critical/important findings: product-owner (BC/PRD/error-taxonomy changes) and/or architect (architecture/methodology/ADR/CI-gate changes).
2. After each fix burst: run `bash scripts/check-spec-counts.sh` (must exit 0 — gate v1.46, checks a–z + aa, bb, cc, dd, ee, ff, gg, hh, ii, jj, kk, ll, mm, nn, oo + o.ii, ~44 sub-assertions; check (gg) is D-SEC evaluator-completeness guard; check (hh) is economy-conservation BC-routing guard; check (ii) is visionOS/OpenXR dedicated-code routing guard; check (jj) is D-SEC no-DEGRADED-path consistency guard; check (kk) is W-code identifier-resolution guard; check (ll) is T2 comparison-method consistency guard; check (mm) is anti-cheat kernel-anomaly routing guard; check (nn) is non-canonical amber-token prose guard; check (oo) is §6.2 mandatory-field-rule completeness guard). Machine-enforced spec-integrity gate. NEVER credit a pass without a green gate run.
3. Commit via state-manager (main branch for script changes; factory-artifacts for .factory/ changes).
4. If pass is CLEAN (0 critical, 0 important): increment counter. If FINDINGS: reset counter to 0.
5. On reaching 3/3 consecutive clean passes: Phase-1d CONVERGED.

**Adversary dispatch template (turnkey resume):** see `.factory/cycles/v0.1.0-greenfield/adversary-dispatch-playbook.md` — captures the gated-class skip-list, accepted conventions, already-swept classes, FU-005 targets, and deep-cross-BC focus to reconstruct an equivalent Pass-N dispatch from zero context.

**On Phase-1d CONVERGED:** T10 consistency-validator audit → T11 `/vsdd-factory:check-input-drift` → T12 Phase-1 human gate → T13 Phase 2+.

---

## Current Phase Steps

| Step | Description | Status |
|------|-------------|--------|
| create-domain-spec | L2 domain spec (10 shards; 18 entities, 14 caps) | DONE |
| create-prd | PRD + 168 BCs across 14 caps → SS-01..SS-12 | DONE |
| create-architecture | 13 subsystems (SS-01..SS-13), 4-layer stack, 10 VPs, DTU assessment | DONE |
| prd-revision | Incorporate FU-001/002/003; close NFR gaps + error families + DI-010/011 BCs | DONE |
| cicd-setup | devops-engineer; `.github/workflows/` + `cicd-setup.md` (D-009; MANDATORY before Phase 3) | DONE |
| phase-1d-adversarial | Adversarial spec convergence (>=3 clean passes); Passes 1–65 resolved (see phase-1-log.md + convergence table below); 3 streak breaks at P46/49/51; security-burst tails at P43/44/53; latest: Pass 65 FINDINGS (F65-01: adapter-seam divergence — BC-15.01.001 hard-gates variantsSupported (E-EAP-012) but §6.2 omitted rule + BC citation mis-targeted; fixed adapter-protocols v1.6 + BC-15.01.001 v1.2; codified oo v1.46; F65-02→FU-026); **COUNTER: 0/3**; Pass 66 = restart #3 clean #1 candidate | IN PROGRESS |
| consistency-audit | Fresh-context consistency audit (consistency-validator) | PENDING |
| drift-check | Input-hash drift check (`/vsdd-factory:check-input-drift`) | PENDING |
| human-gate | Phase-1 spec-package human gate | PENDING |

---

## Next Action

**NEXT: `phase-1d-adversarial` — Pass 66** (candidate clean #1, restart #3 continues). Pass-65 F65-01 fixed adapter-seam producer/consumer divergence: adapter-protocols v1.5→v1.6 (§6.2 variantsSupported mandatory-field rule + schema annotation), BC-15.01.001 v1.1→v1.2 (corrected PC1 citation from :822/selfHostable to §6.2). Codified gate check (oo) v1.46 (§6.2 mandatory-field-rule completeness). Gate v1.45→v1.46. FU-007..026 open (non-blocking).

**Spec state:** prd v2.7; BC-INDEX v1.9 (193 BCs); error-taxonomy **v2.5** (267 error codes / 34 families / 258 active + Warning Codes registry: 4 W-codes W-XR-001..004); nfr-catalog v1.4 (41 NFRs); subsystem-decomposition v2.0 (P0=127/P1=42/P2=24); ARCH-INDEX v2.3 (13 subsystems, ADR-0008); methodology-layer **v1.16**; BC-7.11.001/002 v1.2; BC-7.01.001 v1.1 (F63-01); adapter-protocols **v1.6** (F65-01: §6.2 variantsSupported mandatory-field rule); BC-15.01.001 **v1.2** (F65-01: PC1 citation fix); ADR-0008 v1.2; BC-11.01.002/003 v1.2; prd-cap-011 v1.4; processes.md v1.1; CI gate **v1.46** (checks a–z + aa..oo + o.ii, ~44 sub-assertions; check (oo) = §6.2 mandatory-field-rule completeness guard). Totals UNCHANGED: 193 BCs / 267 error codes (258 active) / 41 NFRs / 15 caps / 13 subsystems / 13 DI / P0=127/P1=42/P2=24. Note: error-taxonomy carries Warning Codes registry (4 W-codes) — NOT counted in 267. See Session Resume Checkpoint for full version-bump list.

---

### Phase-1d Adversarial Convergence

| Pass | Date | Verdict | Summary | Clean-pass counter |
|------|------|---------|---------|-------------------|
| 1–17 | 2026-06-08 | FINDINGS×16 / CLEAN×1 | (see phase-1-log.md rows 9–25) | 0/3 after Pass-17 |
| 18–32 | 2026-06-08 | FINDINGS×5 / CLEAN×5 | (see phase-1-log.md rows 26–40) | 0/3 after Pass-32 |
| 33–53 | 2026-06-08–10 | FINDINGS×18 / CLEAN×3 | (see phase-1-log.md — Passes 33–53 appended 2026-06-13; 3 streak breaks at Pass-46/49/51, security-burst tails at P43/44/53, Pass-45 clean 1/3 reset P46, Pass-47/48 clean 2/3 reset P49, Pass-50 clean 1/3 reset P51) | 0/3 after Pass-53 |
| 54–62 | 2026-06-10–13 | FINDINGS×9 | (see phase-1-log.md — checks hh/ii/jj/kk/ll/mm added; gate v1.44; multiple BC/VP/arch fixes) | 0/3 after Pass-62 |
| 63 | 2026-06-16 | FINDINGS | F63-01(I): BC-7.01.001 test vectors claimed 11 sim-BCs but precondition/postcondition define 10 (BC-6.04.001 Red Gate is impl-dimension input, not a sim-BC). Fixed test vectors to 10; v1.1. F63-02(obs→FU-025): BC-7.09.001:56-57 docs-dimension GREEN phrasing awkward. | **0/3** (stays) |
| 64 | 2026-06-16 | FINDINGS | F64-01(I,process-gap→CODIFIED): Pass-10 AMBER→canonical migration left 4 live-prose 'amber' residuals (adversary found 2; orchestrator corpus-grep found 4 — LESSON-F46). Fixed BC-11.01.002 v1.2 / BC-11.01.003 v1.2 / prd-cap-011 v1.4 / processes.md v1.1 → BLOCKED/DEGRADED-PENDING; codified gate check (nn) v1.45 (amber prose guard). | **0/3** (stays) |
| 65 | 2026-06-16 | FINDINGS | F65-01(I,process-gap→CODIFIED): adapter-seam divergence — BC-15.01.001 hard-gates leaderboards.variantsSupported (E-EAP-012) but §6.2 mandatory-field rules omitted it + BC citation pointed at :822 (selfHostable) not variantsSupported rule. Fixed adapter-protocols v1.6 (rule+annotation) + BC-15.01.001 v1.2 (citation); codified gate (oo) v1.46. F65-02(obs→FU-026): BC-15.04.001:76-78 PC5 'PASS' label returns E-EAP-002 (confusing vs sibling PCs); deferred. | **0/3** (stays) |
| 66 | — | PENDING | — | — |

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
| T9 | Phase-1d adversarial spec convergence — Passes 1–65 resolved; Pass 65 FINDINGS (F65-01: adapter-seam divergence — fixed adapter-protocols v1.6 + BC-15.01.001 v1.2; codified check (oo) v1.46); counter 0/3; Pass 66 = restart #3 clean #1 candidate | **IN PROGRESS** |
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
| FU-026 | F65-02 (obs): BC-15.04.001:76-78 PC5 labeled "PASS — variant not supported" but returns E-EAP-002 (CapabilityUnsupported); label is internally confusing vs sibling PCs (which use FAIL for errors). Behavior unambiguous; non-blocking. Relabel to "PASS (graceful degradation)" at next BC touch. | product-owner | Phase-1 gate or next BC touch — OPEN non-blocking |
| LESSONS-CODIFIED | LESSON-F43/F46/F49a/F49b/F52/F53/F56/F58 — all codified in CI checks dd/ee/ff/w/gg/jj/kk. LESSON-F60 [pending-codification] — VP re-scope must sweep all downstream surfaces. LESSON-F61 [codified] — F40-01 determinism/replay fix must sweep adapter-protocols.md tier table + ReplayResult enum. Codified check (ll). LESSON-F62 [codified] — ADR normative; wrong-but-registered E-code passes check (k). Codified check (mm). LESSON-F64 [codified] — enum-value migration (AMBER→canonical) must sweep ALL live prose corpus-wide. Codified check (nn). LESSON-F65 [codified] — manifest-validation BC that hard-gates a field (E-EAP-012) MUST have matching mandatory-field rule in §6.2; recurred (F35-01 seam enum, F61-01 T2 method, F65-01 variantsSupported). Codified check (oo) as curated allow-list. Full text: `.factory/cycles/v0.1.0-greenfield/lessons.md` | — | CODIFIED |

---

## Session Resume Checkpoint

**Date:** 2026-06-16
**Phase:** 1 — Spec Crystallization IN PROGRESS. Steps 1–8 DONE + Phase-1d Passes 1–65 DONE.
**Phase-1d Pass 65:** FINDINGS (0C/1I/1obs). F65-01(I,process-gap→CODIFIED): adapter-seam producer/consumer divergence — BC-15.01.001 (F40-07) hard-gates leaderboards.variantsSupported (PC5/EC-007/008 → E-EAP-012) but adapter-protocols.md §6.2 "Mandatory field rules" omitted it (appeared only as unannotated schema example), and BC-15.01.001 PC1 citation pointed at :822 (selfHostable line) not variantsSupported rule. Fixed: adapter-protocols.md v1.5→v1.6 (§6.2 mandatory-field rule for variantsSupported + `// MUST be non-empty` annotation); BC-15.01.001 v1.1→v1.2 (PC1 citation corrected to "§6.2 mandatory-field rule"; postconditions/ECs/test-vectors unchanged). Codified gate check (oo) v1.46 (§6.2 mandatory-field-rule completeness; curated allow-list {selfHostable, serverAuthoritative, offlineProject, variantsSupported}). F65-02(obs→FU-026): BC-15.04.001:76-78 PC5 'PASS' label returns E-EAP-002; deferred.
**Clean-pass counter: 0/3 (counter stays — findings pass; restart #3 still seeking clean #1).** Pass 66 = restart #3 candidate clean #1.
**Next action:** `phase-1d-adversarial` — **Pass 66** (candidate clean #1, restart #3 continues). Spec FROZEN after F65 fix burst. FU-007/008/010/011/012/013/014/016/017/018/019/020/021/022/023/024/025/026 open (non-blocking). FU-015 CLOSED (F51-02).
**Phase 1 remaining:** Phase-1d adversarial convergence (0/3 clean passes, need 3) → consistency audit (T10) → drift check (T11) → Phase-1 human gate (T12).
**Spec totals:** 193 BCs / 267 error codes (258 active) / 41 NFRs / 15 caps / 13 subsystems / 13 DI invariants / P0=127/P1=42/P2=24 / CI gate v1.46 (~44 sub-assertions). Error codes UNCHANGED (267); Warning Codes registry carries 4 W-codes (NOT counted in 267). §3.1 D-SEC = 2 allowed values (GREEN, BLOCKED); check (s) verifies 33 dim-value pairs.
**Version bumps Pass 65:** adapter-protocols v1.6 (F65-01: §6.2 variantsSupported rule + annotation), BC-15.01.001 v1.2 (F65-01: PC1 citation fix). BC count UNCHANGED (193). CI gate v1.45→v1.46 (check oo added). Spec totals UNCHANGED.
**Open FUs:** FU-005/006/007/008/010/011/012/013/014/016/017/018/019/020/021/022/023/024/025/026 open (all non-blocking except FU-005 ONGOING). FU-009 CLOSED (Pass-24). FU-015 CLOSED (F51-02). See Open Follow-up Items table above.
**Decisions:** D-014/015/019 flagged for human gate review. D-001..013 see decisions-log-archive.md. D-018/019 in effect.
**main branch:** CI gate v1.46 (check oo added — §6.2 mandatory-field-rule completeness guard). Step history: see phase-1-log.md.
**GATE EXECUTION NOTE:** Run `bash scripts/check-spec-counts.sh` as a SINGLE isolated process — concurrent runs corrupt shared state and produced a spurious check-(k) false-positive during Pass 57. Gate must exit 0 before crediting any pass.
