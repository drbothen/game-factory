---
document_type: prd
level: L3
version: "2.3"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
traces_to: product-brief.md
supplements:
  - prd-supplements/prd-cap-001.md
  - prd-supplements/prd-cap-002-003.md
  - prd-supplements/prd-cap-004.md
  - prd-supplements/prd-cap-005.md
  - prd-supplements/prd-cap-006-007.md
  - prd-supplements/prd-cap-008-012.md
  - prd-supplements/prd-cap-009-010.md
  - prd-supplements/prd-cap-011.md
  - prd-supplements/prd-cap-013-014.md
  - prd-supplements/prd-cap-015.md
  - prd-supplements/nfr-catalog.md
  - prd-supplements/error-taxonomy.md
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/differentiators.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# L3 PRD — game-factory

> **Index document (DF-021).** This file provides overview, scope, cross-cutting NFRs,
> consolidated error taxonomy, requirements traceability, and an integration-pass report.
> Full behavioral contracts live in `.factory/specs/behavioral-contracts/`.
> Per-capability requirements live in `.factory/specs/prd-supplements/`.
> Navigate to individual BCs via `behavioral-contracts/BC-INDEX.md`.

---

## Section 1 — Product Overview

### 1.1 Problem Statement

Game studios at every scale face a fundamental production problem: a game requires
coordinated output across six or more disciplines (design, art, audio, narrative, code,
QA) against multiple target engines and platforms, with growing legal obligations (EU AI
Act, platform cert requirements, PEGI/ESRB ratings, COPPA), while the only existing
automation tools are single-engine, single-discipline, or black-box (pixel/OCR level).

There is no system that applies a rigorous, governed, adversarially reviewed pipeline to
the entire game production stack — engine-agnostically, across all disciplines, with
verifiable quality gates at every step.

### 1.2 Product Vision

game-factory is a **Dark Factory for AAA game development**: a lights-out, multi-agent
production system that generates every artifact a game requires — design, art, audio,
narrative, code, QA artifacts — at AAA quality, for any genre, against any engine, via
five adapter seams (engine / asset / distribution / XR / online-services), with canon-KB
as the sixth load-bearing seam. Factory compliance, provenance, and ethics are first-class
pipeline outputs, not afterthought checklists. The "fun shell" (subjective game feel) is
governed by a human playtest gate that cannot be automated away.

### 1.3 Competitive Differentiators

See Section 6 for full BC traceability. Summary:

| ID | Differentiator |
|----|----------------|
| D-001 | First engine-agnostic multi-engine semantic test layer (not pixel/OCR) |
| D-002 | Deterministic replay regression as first-class multi-engine quality gate |
| D-003 | Pure-maximal lights-out asset generation at AAA scale with auto-provenance |
| D-004 | Governed monetization ethics envelope — unconstrained LTV is a factory defect |
| D-005 | Engine-portable spec layer — re-target design without spec revision |
| D-006 | Compliance and provenance pipeline as first-class pipeline output |
| D-007 | Structured playtest protocol that refuses to auto-score fun |

### 1.4 Target Users

| Persona | Pain Point |
|---------|-----------|
| Multi-studio platform teams | Siloed per-engine CI; no shared semantic test/replay layer |
| Indie / small-studio tech leads | Want spec-driven, adversarially reviewed pipelines; lack team to build them |
| Solo / AI-assisted developers | Want multi-agent automation across all disciplines; current tools are black-box only |

### 1.5 Out of Scope

- Building a game engine (factory adapts to engines; does not replace them)
- Auto-scoring "fun" or subjective game feel (DI-007; human gate only)
- Kernel anti-cheat authoring (DI-010; wrap-only integration)
- NFT/web3 mechanics by default (DI-011; off-by-default, explicit declaration required)
- Running live esports events or tournaments
- Virtual-production hardware
- Unconstrained LTV optimization (DI-005; any such output is a factory defect)
- Unreal Engine adapter (seam reserved; Tier 3 deferred)
- VR/AR/XR implementation (XR seam reserved in CAP-014; impl. deferred)

---

## Section 2 — Scope: Three-Tier Delivery Model

### Tier 1 — v1-Core (P0, all capabilities)

Must ship in v1. These capabilities form the load-bearing factory spine.

| Capability | Description | BC Count |
|-----------|-------------|---------|
| CAP-001 | Engine-Agnostic Game Build and Test (EAP + full adapter protocol) | 35 |
| CAP-002 | Engine Adapter Conformance Gating (anti-drift load-bearing artifact) | 6 |
| CAP-003 | Determinism-Tier-Governed Replay Regression (T1/T2/T3 + golden state) | 9 |
| CAP-004 | Pure-Maximal Asset Generation with Auto-Provenance | 15 |
| CAP-005 | Multi-Discipline Game Artifact Production (design/art/audio/narrative/code) | 16 |
| CAP-006 | Contract-Driven Simulation Quality Verification | 11 |
| CAP-007 | 11-Dimension Convergence Tracking | 19 (+7 v1.2: BC-7.11.002..008 server-authority invariant suite CWE-602) |

**Tier 1 total: 123 BCs** (111 prior + 12 added in v1.9: BC-15.01.001/002, BC-15.02.001, BC-15.04.001, BC-15.06.001, BC-15.08.001, BC-15.09.001, BC-15.10.001, BC-15.11.001 are P0; BC-15.03.001, BC-15.05.001, and BC-15.07.001 are P1 but CAP-015 is Tier-1)

| Capability | Description | BC Count |
|-----------|-------------|---------|
| CAP-015 | Online-Services Adapter (BaaS seam; Nakama reference; DTU-08; server-authority enforcement) | 12 (+12 v1.9) |

### Tier 2 — Optional / P1 (ship-required per product brief, P1 priority)

Required for first-release compliance and distribution capability.

| Capability | Description | BC Count |
|-----------|-------------|---------|
| CAP-008 | Structured Playtest Protocol (3-lens; human-gated sign-off) | 5 |
| CAP-009 | Cert Pre-Flight and Distribution-Readiness | 11 |
| CAP-010 | Compliance Pipeline and AI Disclosure (EU AI Act Art. 50) | 6 |
| CAP-011 | Monetization Ethics Enforcement | 14 (+1 v1.2: BC-11.03.006 DP-007) |
| CAP-012 | Canon Knowledge-Base Grounding | 9 |

**Tier 2 total: 45 BCs** (44 original + 1 added in v1.2: BC-11.03.006 for DP-007)

### Tier 3 — Optional / Genre-Gated or Deferred (P2)

Activated by genre profile or platform declaration. XR implementation deferred (seam reserved).

| Capability | Description | BC Count |
|-----------|-------------|---------|
| CAP-013 | Genre-Gated Optional Lane Activation (esports / UGC / marketing lanes) | 15 |
| CAP-014 | XR Platform Seam (seam spec complete; implementation deferred) | 7 |

**Tier 3 total: 22 BCs** (21 original + 1 added in v1.1: BC-13.01.004 for DI-011)

**Grand total: 190 BCs**

---

## Section 3 — Capability → Supplement Map

| Capability | Priority | Tier | Supplement File | BC Subsystem Dir | BC Count |
|-----------|----------|------|----------------|-----------------|---------|
| CAP-001 | P0 | 1 | prd-supplements/prd-cap-001.md | ss-01/ | 35 |
| CAP-002 | P0 | 1 | prd-supplements/prd-cap-002-003.md | ss-02/ | 6 |
| CAP-003 | P0 | 1 | prd-supplements/prd-cap-002-003.md | ss-03/ | 9 |
| CAP-004 | P0 | 1 | prd-supplements/prd-cap-004.md | ss-04/ | 15 |
| CAP-005 | P0 | 1 | prd-supplements/prd-cap-005.md | ss-05/ | 16 |
| CAP-006 | P0 | 1 | prd-supplements/prd-cap-006-007.md | ss-06/ | 11 |
| CAP-007 | P0 | 1 | prd-supplements/prd-cap-006-007.md | ss-07/ | 19 |
| CAP-008 | P1 | 2 | prd-supplements/prd-cap-008-012.md | ss-08/ | 5 |
| CAP-009 | P1 | 2 | prd-supplements/prd-cap-009-010.md | ss-09/ | 11 |
| CAP-010 | P1 | 2 | prd-supplements/prd-cap-009-010.md | ss-10/ | 6 |
| CAP-011 | P1 | 2 | prd-supplements/prd-cap-011.md | ss-11/ | 14 |
| CAP-012 | P1 | 2 | prd-supplements/prd-cap-008-012.md | ss-12/ | 9 |
| CAP-013 | P2 | 3 | prd-supplements/prd-cap-013-014.md | ss-13/ | 15 |
| CAP-014 | P2 | 3 | prd-supplements/prd-cap-013-014.md | ss-14/ | 7 |
| CAP-015 | P1 | 1 | prd-supplements/prd-cap-015.md | ss-15/ | 12 |

> **Note on ss-NN directories:** Directory names `ss-01` through `ss-15` mirror capability
> numbers for navigability. They are NOT architecture subsystem IDs. Subsystem IDs have
> been assigned from `.factory/specs/architecture/subsystem-decomposition.md` (see
> ARCH-INDEX.md). All BC frontmatter `subsystem:` fields are now populated with real SS-NN
> values (SS-01 through SS-12; CAP-015 uses SS-13). CAP-002 is merged into SS-01
> (Engine-Adapter Protocol); CAP-010 is merged into SS-08 (Cert+Distribution).

---

## Section 4 — Cross-Cutting NFRs

Full NFR catalog: `.factory/specs/prd-supplements/nfr-catalog.md` (41 NFRs, NFR-001 through NFR-041). v1.9: +6 NFRs for CAP-015 (NFR-036..041: identity auth latency, leaderboard submit latency, entitlement verify latency, cloud save write latency, graceful degradation gate, tampered-score rejection rate).

NFR summary — capabilities now with defined numeric targets (v1.1 additions marked with `*`):

| NFR-ID | Category | Capability | Target | Validation |
|--------|----------|-----------|--------|------------|
| NFR-001 | Provenance completeness | CAP-004 | 0 missing `disclosure_class` | Quality-gate hook CI |
| NFR-002 | Generation latency | CAP-004 | p50 < 120 s; p99 < 600 s per asset | CI smoke test |
| NFR-003 | Quality gate pass rate | CAP-004 | ≥ 80% first-attempt (Tier-1 assets) | 100-asset corpus |
| NFR-004 | Blocked-backend enforcement | CAP-004 | 0 exceptions | Integration test |
| NFR-005 | License-gate latency | CAP-004 | < 30 s for 1,000-asset build | CI benchmark |
| NFR-006 | Design artifact generation | CAP-005 | < 30 s full bundle | Timed CI step |
| NFR-007 | Schema validation reliability | CAP-005 | < 0.1% false-negative over 1,000 runs | Property-based test |
| NFR-008 | Audio bank build throughput | CAP-005 | < 120 s (< 200 events) | CI timed step |
| NFR-009 | Narrative graph coverage | CAP-005 | 100% terminal nodes classified | Graph-traversal CI |
| NFR-010 | Dependency validation latency | CAP-005 | < 5 s per contract | Timed CI step |
| NFR-011 | Engine-neutrality (spec) | CAP-005 | 0 engine-specific identifiers in spec artifacts | Lint rule CI |
| NFR-012 | Audio loudness conformance | CAP-005 | LUFS within ±2 dB target | libebur128 CI |
| NFR-013 | Playtest protocol completeness | CAP-008 | 100% mandatory fields populated | Schema validation |
| NFR-014 | Fun-score hook latency | CAP-008 | p99 ≤ 100 ms added latency | CI perf gate |
| NFR-015 | Playtest sign-off auditability | CAP-008 | 100% sign-offs have valid `reviewer_id` | Schema + registry |
| NFR-016 | Canon-KB query performance | CAP-012 | p99 ≤ 20 ms (≤ 10,000 entities) | CI perf gate |
| NFR-017 | Continuity check throughput | CAP-012 | p95 ≤ 30 s (10,000-word artifact) | CI perf gate |
| NFR-018 | Retrieval determinism | CAP-012 | 100% same result for same query | Property-based test |
| NFR-019 | Grounding coverage | CAP-012 | 100% required-grounding agents produce `grounded_against` tags | Schema validation |
| NFR-020 * | Adapter protocol round-trip | CAP-001 | p50 < 5 ms; p99 < 50 ms (stdio transport, no engine op) | CI micro-benchmark |
| NFR-021 * | Engine-neutrality lint time | CAP-001 | < 10 s for ≤ 100K-line codebase | Timed CI lint step |
| NFR-022 * | Conformance suite run time | CAP-002 | p95 < 10 min per adapter on CI (4 vCPU / 8 GB) | Timed CI conformance run |
| NFR-023 * | Conformance drift detection | CAP-002 | < 15 min end-to-end (trigger → verdict) | Timed CI scheduled run |
| NFR-024 * | Replay recording overhead | CAP-003 | < 5% wall-clock overhead vs. unrecorded run (T1) | CI replay benchmark |
| NFR-025 * | Replay execution time | CAP-003 | p95 < 2× original wall-clock (10,000-frame session, T1) | CI replay benchmark |
| NFR-026 * | Sim-BC verification throughput | CAP-006 | p95 < 60 s (full 11-check battery, reference game) | Timed CI sim-BC gate |
| NFR-027 * | Convergence tick latency | CAP-007 | p95 < 30 s (full 11-dimension evaluation, populated project) | Timed CI convergence benchmark |
| NFR-028 * | Cert pre-flight time | CAP-009 | p95 < 5 min per platform on CI | Timed CI cert-preflight step |
| NFR-029 * | Compliance manifest gen time | CAP-010 | p95 < 60 s (1,000-asset project) | Timed CI compliance-pipeline step |
| NFR-030 * | Ethics contract validation | CAP-011 | p95 < 10 s per contract | Timed CI ethics-gate step |
| NFR-031 * | Ethics review surface time | CAP-011 | < 30 s (task creation + notification) | CI integration test |
| NFR-032 * | Genre profile validation | CAP-013 | p99 < 1 s per profile document | Property-based test (10K profiles) |
| NFR-033 * | Inactive-lane scan time | CAP-013 | p99 < 30 s (full artifact manifest scan) | Timed CI artifact-scan step |
| NFR-034 * | XR manifest validation | CAP-014 | p99 < 500 ms per manifest | CI integration test (100 manifests) |
| NFR-035 * | XR seam isolation check | CAP-014 | 0 core files modified on XR adapter add/remove | Static analysis git diff check |

**NFR gap status:** All 14 capability domains now have defined numeric NFR targets. FU-002 closed.

---

## Section 5 — Consolidated Error Taxonomy

Full taxonomy: `.factory/specs/prd-supplements/error-taxonomy.md` (255 error codes, 30 active families + 1 retired — v2.0). Note: 9 of the 255 are in the retired E-GEN family; 246 are active codes. (v2.0: +42 codes across E-KB/E-PLAY/E-REPLAY/E-NAR — Pass-20 symbolic token reconciliation + F-20-02 E-NAR fix.)

Family summary (v1.1 additions marked with `*`; v1.2 additions marked with `**`; v1.6 additions marked with `***`; v1.9 additions marked with `****`):

| Family | Owning Capability | Code Count |
|--------|------------------|-----------|
| E-EAP | CAP-001 (Engine Adapter Protocol) | 13 (v1.1: +E-EAP-011; v1.2: +E-EAP-012 MalformedManifest, +E-EAP-013 HumanGatedTaskPending) |
| E-CONF * | CAP-002 (Conformance suite) | 5 |
| E-REPLAY * | CAP-003 (Replay harness) | 18 (v2.0: +E-REPLAY-008..018 — Pass-20 symbolic token reconciliation) |
| ~~E-GEN *~~ | ~~CAP-004 (Asset generation placeholder)~~ | ~~9~~ — **RETIRED v1.6**: orphaned placeholder; never referenced by any BC |
| E-AAG *** | CAP-004 (Asset-adapter routing, BC-4.01.*) | 7 |
| E-SVC *** | CAP-004 (GenerationRequest validation, BC-4.02.*) | 6 |
| E-PRV ** | CAP-004 (Provenance sidecar field validation) | 8 (v1.2: E-PRV-010/011/012; v1.6: +E-PRV-001/002/003/020/030) |
| E-QG *** | CAP-004 (Quality gate per-modality, BC-4.04.*) | 11 |
| E-SHIP *** | CAP-004 (Ship gate license, BC-4.05.001) | 3 |
| E-ING *** | CAP-004 (Ingest pre-flight, BC-4.06.001) | 4 |
| E-DES | CAP-005 (Design artifacts) | 5 |
| E-ART | CAP-005 (Art quality gate) | 3 |
| E-AUD | CAP-005 (Audio build) | 4 |
| E-NAR | CAP-005 (Narrative graph) | 6 (v2.0: +E-NAR-005/006 — F-20-02 fix: undeclared variable + invalid naming-registry regex) |
| E-ENG | CAP-005 (Code separation) | 2 |
| E-CIN | CAP-005 (Cinematic graph) | 4 |
| E-PROD | CAP-005 (Production / wave) | 3 |
| E-SIM * | CAP-006 (Simulation QA) | 9 |
| E-CONV * | CAP-007 (Convergence) | 6 |
| E-PLAY * | CAP-008 (Playtest) | 15 (v2.0: +E-PLAY-006..015 — Pass-20 symbolic token reconciliation) |
| E-CERT | CAP-009 (Cert pre-flight) | 3 |
| E-DIST | CAP-009 (Distribution tools) | 19 |
| E-COMP | CAP-010 (Compliance) | 2 |
| E-ETH * | CAP-011 (Monetization Ethics) | 14 (v1.2: +E-ETH-009 DP-007; v1.5: +E-ETH-010..014 DP-005/004/003/008/006) |
| E-KB * | CAP-012 (Canon KB) | 26 (v2.0: +E-KB-008..026 — Pass-20 symbolic token reconciliation) |
| E-GENRE * | CAP-013 (Genre lanes — core activation BCs) | 6 |
| E-GLG *** | CAP-013 (Genre sub-lane gate config, BC-13.01.*/13.02.*/13.03.*/13.04.*) | 5 |
| E-MOD *** | CAP-013 (Modding/UGC lane, BC-13.03.*) | 11 |
| E-MKT *** | CAP-013 (Marketing lane, BC-13.04.*) | 4 |
| E-XR * | CAP-014 (XR seam) | 7 (v1.1: 6 codes; v1.6: +E-XR-007 visionOS/OpenXR) |
| E-OSVC **** | CAP-015 (Online-Services Adapter — identity, cloud-save, leaderboards, matchmaking, entitlements, remote-config, seam integrity) | 15 (v1.9: all new) |
| **TOTAL (all registered incl. retired E-GEN)** | **30 active + 1 retired** | **255** |

**Error family gap status:** All 15 capability families have error families defined. v2.0 (Pass-20) extends E-KB (7→26), E-PLAY (5→15), E-REPLAY (7→18), E-NAR (4→6) to cover all symbolic tokens emitted by their BCs. Every registered non-retired family is now cited by ≥1 BC. See `error-taxonomy.md §Coverage Notes`.

---

## Section 6 — Competitive Differentiator Traceability

Seeded from `domain-spec/differentiators.md`. Every differentiator must have at least one
BC with testable postconditions backing the claim.

| Differentiator | Claim Summary | Backing BCs |
|---------------|--------------|------------|
| D-001 — Engine-Agnostic Semantic Test | Engine-agnostic build/test across Bevy/Unity/Godot without pixel/OCR | BC-1.01.001, BC-1.05.001, BC-1.06.001, BC-2.02.002, BC-2.02.006, BC-1.15.001 |
| D-002 — Deterministic Replay Regression | First multi-engine tier-graded replay serving QA, esports, anti-cheat from one primitive | BC-3.03.001–009, BC-1.12.001–003, BC-6.03.001 |
| D-003 — Pure-Maximal Lights-Out Asset Generation | All assets lights-out with auto-provenance per EU AI Act + Steam | BC-4.03.001, BC-4.03.002, BC-4.05.001, BC-4.06.001, BC-10.05.001 |
| D-004 — Governed Monetization Ethics | Unconstrained LTV is a factory defect; ethics contract adversarially reviewed | BC-11.02.001, BC-11.01.003, BC-11.03.001–006 |
| D-005 — Engine-Portable Spec Layer | Design artifacts re-targetable to new engine without spec revision | BC-5.01.001, BC-1.15.001, BC-5.05.001 |
| D-006 — Compliance as First-Class Output | EU AI Act, PEGI/ESRB, COPPA generated from same provenance data as quality | BC-10.01.001, BC-10.02.001, BC-10.05.001, BC-4.03.001 |
| D-007 — Structured Playtest Protocol | Refuses to auto-score fun; 3-lens convergence + mandatory human gate | BC-8.08.004, BC-8.08.005, BC-7.05.001 |

---

## Section 7 — Requirements Traceability Matrix

### 7.1 Success Criteria Coverage

| Brief Success Criterion | Metric | Target | Covering BCs | Status |
|------------------------|--------|--------|-------------|--------|
| Engine-agnostic by construction | Engine adapters passing conformance | ≥ 3 (Bevy, Unity, Godot) | BC-2.02.002, BC-2.02.006 | Covered |
| One spec → many engines | Reference game from engine-neutral spec | Runs on ≥ 2 engines | BC-1.15.001, BC-5.01.001 | Covered |
| Replay-regression works | Injected sim regression detected at T1 | 100% on reference game | BC-3.03.006 | Covered |
| No lock-in (all five seams) | New engine onboarding cost | Implement adapter + pass conformance; ZERO core changes | BC-1.15.001, BC-2.02.002 | Covered |
| Full asset provenance | Generated assets with complete provenance sidecar | 100%; 0 missing `disclosure_class` | BC-4.03.001, BC-4.03.002, NFR-001 | Covered |
| All-genre + pilot proven | Core contract set defined; det-sim pilot ships end-to-end | Contract set complete; pilot on Bevy | BC-6.04.001, BC-3.03.003 | Covered |

### 7.2 Domain Invariant Coverage

All 12 domain invariants (DI-001 through DI-012) have BC coverage. No orphan invariants. (DI-010 and DI-011 gaps closed in PRD v1.1.)

| Invariant | Description | Primary Enforcing BCs |
|-----------|-------------|----------------------|
| DI-001 | Factory Core Never Names a Specific Engine | BC-1.15.001 |
| DI-002 | Every Engine Adapter Must Pass Conformance Before Acceptance | BC-2.02.002 |
| DI-003 | Every Generated Asset Has a Complete Provenance Sidecar | BC-4.03.001, BC-4.03.002 |
| DI-004 | Determinism Tier Is Declared, Never Assumed | BC-1.12.001, BC-1.12.002 |
| DI-005 | Monetization Optimization Is Always Constrained | BC-11.02.001 |
| DI-006 | Human-Gated Tasks Are Surfaced, Not Silently Dropped | BC-9.06.001, BC-9.06.002, BC-8.08.004, BC-4.03.004, BC-14.01.003 |
| DI-007 | Playtest Satisfaction Is Always a Human Gate | BC-8.08.004, BC-7.05.001, BC-8.08.005 |
| DI-008 | Factory Core Spec Layer Is Engine-Portable by Construction | BC-5.01.001, BC-1.15.001 |
| DI-009 | Suno/Udio and Unlicensed AI Music Providers Are Blocked | BC-4.01.004 |
| DI-010 | Kernel Anti-Cheat Is Never Autonomously Authored | **BC-1.15.002** (added PRD v1.1; primary enforcement) |
| DI-011 | NFT and Web3 Mechanics Are Off by Default | **BC-13.01.004** (added PRD v1.1; primary enforcement) |
| DI-012 | Every ContractArtifact Has a Declared Validation Method | BC-6.04.001, BC-5.05.002 |

### 7.3 CAP → BC ID Range → Domain Invariants Matrix

| CAP | BC ID Ranges | Primary DIs Enforced |
|-----|-------------|---------------------|
| CAP-001 | BC-1.01.001 – BC-1.15.002 | DI-001, DI-004, DI-006, DI-010 |
| CAP-002 | BC-2.02.001 – BC-2.02.006 | DI-002 |
| CAP-003 | BC-3.03.001 – BC-3.03.009 | DI-004 |
| CAP-004 | BC-4.01.001 – BC-4.06.001 | DI-003, DI-006, DI-009 |
| CAP-005 | BC-5.01.001 – BC-5.07.003 | DI-008, DI-003, DI-012 |
| CAP-006 | BC-6.01.001 – BC-6.04.001 | DI-012 |
| CAP-007 | BC-7.01.001 – BC-7.12.001 (+ BC-7.11.002..008) | DI-006, DI-007, DI-010 (via BC-7.11.001/D-SEC) |
| CAP-008 | BC-8.08.001 – BC-8.08.005 | DI-007, DI-006 |
| CAP-009 | BC-9.01.001 – BC-9.06.002 | DI-006 |
| CAP-010 | BC-10.01.001 – BC-10.06.001 | DI-003, DI-006 |
| CAP-011 | BC-11.01.001 – BC-11.04.002 (+ BC-11.03.006) | DI-005 |
| CAP-012 | BC-12.12.001 – BC-12.12.009 | DI-012 |
| CAP-013 | BC-13.01.001 – BC-13.04.002 (+ BC-13.01.004) | DI-004 (esports replay reuse), DI-011, DI-006 |
| CAP-014 | BC-14.01.001 – BC-14.02.003 | DI-006, DI-001 |

---

## Section 8 — Open Items and Integration Notes

### 8.0 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-06-08 | product-owner | Initial PRD: 168 BCs, 19 NFRs, 59 error codes / 11 families |
| 1.1 | 2026-06-08 | product-owner | PRD revision (FU-001/002/003): +2 BCs (BC-1.15.002, BC-13.01.004); +16 NFRs (NFR-020..035); +10 error families, +79 error codes; all DI orphan invariants closed; incorporates DI-010 (kernel AC never authored, §DI-010) and DI-011 (NFT/web3 off by default, §DI-011) as primary architectural decisions, plus ADR-0006 (11-dim convergence model) and ADR-0007 (human-gated fidelity tier) |
| 1.2 | 2026-06-08 | product-owner | Phase-1d adversarial pass-1 resolution: +9 BCs (BC-11.03.006 DP-007; BC-7.11.002–008 server-authority CWE-602 invariants); E-PRV family (3 codes); E-ETH-009; E-GEN-004 vocabulary corrected; E-ETH-005 mislabel fixed; E-SIM-009 identifier corrected; BC-1.15.002 kernel patterns extended (macOS/IOKit, eBPF, binary blobs, build.rs); BC-13.01.004 console cert-preflight routing added; BC-4.03.002 procedural-exempt audit controls specified; DP deny-list coverage documented; priority fields backfilled on ss-01..ss-08 BCs |
| 1.3 | 2026-06-08 | product-owner | Phase-1d adversarial pass-2 integrity fixes (C2-01/02/03, S2-01, I2-02/03): corrected grand total 179→178 (BC-INDEX was erroneously self-counted); corrected error-code total 143/141→134 (prose change-notes were incorrectly counted as codes); per-family code-count table added to prd.md §5 and error-taxonomy.md (S2-01); priority backfill completed on remaining 44 BCs in ss-11..ss-14; CAP-011 DP-enforcement BCs escalated to P0 per D-008 compliance policy; all three locations (prd-cap-011.md, BC-INDEX, BC frontmatter) now consistent |
| 1.5 | 2026-06-08 | product-owner | Phase-1d adversarial pass-6 I6-02 fix: +5 E-ETH codes (E-ETH-010..014) for DP-003/004/005/006/008; DP→E-ETH crosswalk + SS-09 symbolic-name crosswalk added to error-taxonomy.md; all dark-pattern BCs (BC-11.03.001..005) updated to cite registered E-ETH codes; SS-09 ethics BCs (BC-11.01.001, BC-11.02.001, BC-11.02.003, BC-11.04.002) crosswalked to registered parent codes; error total 134→139, E-ETH family 9→14; BC count unchanged at 178 |
| 1.6 | 2026-06-08 | product-owner | CI check (k) completeness fix: registered 57 E-codes referenced by ss-04 (BC-4.01.*–4.06.*) and ss-13 (BC-13.02.*–13.04.*) BCs that were unregistered. New families: E-AAG (7), E-SVC (6), E-QG (11), E-SHIP (3), E-ING (4), E-GLG (5), E-MOD (11), E-MKT (4). E-PRV extended (+5 codes: 001/002/003/020/030). E-XR extended (+1 code: 007). E-GEN retired — orphaned placeholder, never referenced by any BC (9 codes remain in retired table, still counted by CI). CI-computed total: 139 + 57 = **196 total registered codes** (187 active, 9 retired E-GEN). 29 active families. BC count unchanged at 178 |
| 1.7 | 2026-06-08 | product-owner | Pass-9 adversarial fixes: E-COMP-011 registered (disclosure_class out-of-vocabulary at manifest aggregation — distinct from E-COMP-010 missing-field; BC-10.05.001 v1.2 uses E-COMP-011 for vocab fault); E-COMP-012 registered (NFT flag divergence seam guard — nft_blockchain/nft_mechanics inconsistency; BC-10.01.001 v1.1 emits on divergence; INV-2 fail-closed: PEGI-18 if EITHER NFT flag true). +2 codes: **198 total registered codes** (189 active, 9 retired E-GEN). BC count unchanged at 178. methodology-layer v1.3 §3.0 canonical dimension field table added; BC-9.04.001/9.06.001/9.06.002 dimension field renamed distribution_readiness→cert_preflight. |
| 1.9 | 2026-06-08 | product-owner | CAP-015 Online-Services Adapter (fifth seam, SS-13, Tier 1): +12 BCs (BC-15.01.001..002, BC-15.02.001, BC-15.03.001, BC-15.04.001, BC-15.05.001, BC-15.06.001, BC-15.07.001, BC-15.08.001, BC-15.09.001, BC-15.10.001, BC-15.11.001); new E-OSVC error family (15 codes); CAP-015 added to domain-spec/capabilities.md; prd-cap-015.md created; NFR-036..041 added (identity/leaderboard/entitlement/save latency, graceful degradation, tampered-score rejection). Grand total: 178→190 BCs. Error codes: 198→213 total (189→204 active). Families: 29→30 active. |
| 2.3 | 2026-06-08 | product-owner | Pass-32 O-PASS32-01 fix: §8.4 v2.0 ledger entry family-count typo corrected 34→30 active families (authoritative: 30 active + 1 retired E-GEN = 31 total; prd.md:233/270 and error-taxonomy.md:806 are canonical). No code/BC/NFR count changes. |
| 2.2 | 2026-06-08 | product-owner | Pass-20 symbolic token reconciliation: E-KB extended 7→26 (+19 codes E-KB-008..026); E-PLAY extended 5→15 (+10 codes E-PLAY-006..015); E-REPLAY extended 7→18 (+11 codes E-REPLAY-008..018); E-NAR extended 4→6 (+2 codes E-NAR-005/006 — F-20-02 fix: "E-NAR-003 variant" language removed). OBS-20-A: BC-12.12.004 Invariant 2 reworded to permit shared ordinals for concurrent:true events. OBS-20-B: CAP-012 Canon-KB declared authoritative timeline store; CAP-005 BC-5.04.002 declared consumer view. Total error codes: 213→255 (204→246 active). BC count unchanged: 190. |
| 2.1 | 2026-06-08 | product-owner | Pass-17 adversarial fix F-17-01: corrected stale BC count 189→190 in §8.1 subsystem-assignment prose (was copied from the 189-active-error-codes figure; grand total is 190 per BC-INDEX, ARCH-INDEX, and per-subsystem distribution). BC count unchanged: 190. |
| 2.0 | 2026-06-08 | product-owner | Pass-14 adversarial defect fixes: C14-01 — E-OSVC error-code mis-citations corrected in BC-15.02.001 (E-OSVC-003→013 UnsupportedAuthProvider) and BC-15.05.001 (E-OSVC-004→014 LobbyCapacityExceeded, E-OSVC-006→015 LobbyNotFound); I14-03 — orphan "(100-Token Active Cap)" fragment removed from BC-15.11.001 H1 and BC-INDEX row (title now accurately describes D-SEC routing contract); I14-01 — seam-count prose updated from "four adapter seams" to "five adapter seams (engine / asset / distribution / XR / online-services)" in prd.md, L2-INDEX.md, capabilities.md, invariants.md, prd-cap-002-003.md, and product-brief.md; canon-KB clarified as sixth load-bearing (non-adapter) seam. BC count unchanged: 190. Error code count unchanged: 213. |

### 8.1 Subsystem Assignment (Resolved)

**All 190 behavioral contracts have been assigned to architecture subsystems (SS-01 through
SS-13).** The `subsystem: SS-TBD` placeholder has been replaced in all BC frontmatter.
The assignment was propagated from `.factory/specs/architecture/subsystem-decomposition.md`
(see ARCH-INDEX.md Subsystem Registry). BC file paths (directory `ss-NN/`, filename) are
immutable per `append_only_numbering` policy.

Subsystem distribution: SS-01 (41 BCs: CAP-001+002 + BC-1.15.002), SS-02 (9), SS-03 (15),
SS-04 (16), SS-05 (11), SS-06 (19: CAP-007 12 original + 7 server-authority invariant BCs v1.2), SS-07 (5), SS-08 (17: CAP-009+010), SS-09 (14: CAP-011 13 original + BC-11.03.006 v1.2),
SS-10 (9), SS-11 (15: CAP-013 + BC-13.01.004), SS-12 (7), SS-13 (12: CAP-015 online-services adapter, v1.9).

### 8.2 BC Frontmatter Priority Gap — CLOSED (v1.3)

Priority fields have been backfilled on all 178 BCs across all directories.

- *v1.2:* Backfilled 94 BCs in `ss-01/` through `ss-03/` and `ss-05/` through `ss-08/`. Values: P0 for CAP-001–007, P1 for CAP-008.
- *v1.3:* Backfilled remaining 44 BCs in `ss-11/` through `ss-14/`. Values: P0/P1 for CAP-011 (see priority-split rationale below), P1 for CAP-012, P2 for CAP-013/014. Also corrected false "CLOSED" assertion — `ss-09/` and `ss-10/` were already complete per v1.2.

**CAP-011 priority split (D-008 compliance = P0):** BCs that enforce regulatory-mandatory consumer-protection obligations (ethics contract gate, forbidden dark patterns with legal basis, minor protection with COPPA/PEGI-16, no-unconstrained-LTV) are P0. BCs that enforce economy-quality properties (economy-spine propagation, pity correctness, Gini guardrail, loss-triggered-offers) are P1. See BC-INDEX §CAP-011 for the per-BC assignments.

All 178 pre-v1.9 BCs have explicit `priority:` fields in frontmatter. All 12 new CAP-015 BCs (BC-15.*) also carry explicit `priority:` fields (9×P0, 3×P1).

### 8.3 Domain Invariant Coverage — CLOSED (v1.1)

Previously two invariants had no dedicated behavioral contract. Both are now covered:

- **DI-010 (Kernel Anti-Cheat):** Closed by **BC-1.15.002** (added PRD v1.1). Implements
  a CI lint gate that scans factory output artifacts for kernel-mode driver code patterns.
  Assigned to SS-01 (Engine-Adapter Protocol). Error code: E-EAP-011.

- **DI-011 (NFT/Web3 off by default):** Closed by **BC-13.01.004** (added PRD v1.1).
  Enforces `nft_mechanics: false` and `web3_enabled: false` as schema defaults with explicit
  opt-in requiring `business-model-spec` and PEGI-18 acknowledgment.
  Assigned to SS-11 (Genre-Gated Lanes). Error codes: E-GENRE-004, E-GENRE-005.

**No orphan invariants remain. FU-001 closed.**

### 8.4 Error Taxonomy — Updated (v2.0)

*v2.0 (Pass-32 / E-KB/E-PLAY/E-REPLAY/E-NAR expansions):* +42 codes registered across the E-KB (Canon-KB grounding), E-PLAY (playtest protocol), E-REPLAY (replay/recording), and E-NAR (narrative generation) families. Total: **255 registered codes (246 active + 9 retired E-GEN) across 30 active families**.

*v1.9 (CAP-015 delivery):* E-OSVC family registered — 15 codes covering CAP-015 online-services adapter (identity, cloud-save, leaderboards, matchmaking, entitlements, remote-config, seam integrity). Total: **213 registered codes (204 active + 9 retired E-GEN) across 30 active families**.

*v1.7 (pass-9 I-1, I-2):* E-COMP-011 added (disclosure_class out-of-vocabulary at manifest aggregation; distinct fault class from E-COMP-010 missing-field). E-COMP-012 added (NFT flag divergence seam guard; nft_blockchain/nft_mechanics inconsistency; DI-011). Total: **198 registered codes (189 active + 9 retired E-GEN) across 29 active families**.

*v1.6 (check-k):* 57 unregistered E-codes closed. 8 new families registered (E-AAG, E-SVC, E-QG, E-SHIP, E-ING, E-GLG, E-MOD, E-MKT). E-PRV extended by 5 codes. E-XR extended by 1 code. E-GEN retired as orphaned placeholder — never referenced by any BC (9 codes remain in retired table). All E-xxx-NNN tokens in ss-04/ss-13/ss-14 BCs now resolve to registered codes. CI check (k): 0 unregistered codes. Total (v1.6): **196 registered codes (187 active + 9 retired E-GEN) across 29 active families**.

*v1.5 (I6-02):* E-ETH-010..014 added — dedicated registered codes for DP-005 (gacha odds disclosure), DP-004 (P2W in ranked), DP-003 (loss-triggered prompt), DP-008 (minor loot box), DP-006 (best-value label). DP→E-ETH crosswalk and SS-09 symbolic-name crosswalk added to E-ETH section of error-taxonomy.md. All dark-pattern and ethics BCs now cite registered E-ETH-NNN codes; symbolic names are `error.data.reason` sub-codes only.
Total (v1.5): 139 error codes across 22 families. See `error-taxonomy.md §Coverage Notes`.

*v1.2:* E-PRV family added (3 codes: E-PRV-010/011/012) to register BC-4.03.002's failure paths.
E-ETH-009 added for DP-007 enforcement. E-GEN-004 vocabulary corrected to canonical three
values `[pre-generated, live-generated, procedural-exempt]`. E-ETH-005 "(DP-007 equivalent)"
mislabel removed. E-SIM-009 identifier corrected from `(D-012)` to `(DI-012)`.

*v1.1:* All 14 capability families had defined error families. 10 new families added.

*v1.1:* All 14 capability families had defined error families. 10 new families added.
E-EAP extended with E-EAP-011. 137 codes across 21 families. **FU-003 closed.**

### 8.5 NFR Gaps — CLOSED (v1.1)

All 14 capability domains now have explicit NFR numeric targets (NFR-001 through NFR-035).
16 new NFRs added (NFR-020..NFR-035) covering CAP-001, CAP-002, CAP-003, CAP-006,
CAP-007, CAP-009, CAP-010, CAP-011, CAP-013, CAP-014.
**FU-002 closed.** See `nfr-catalog.md §Notes`.

### 8.6 Supplement Document-Type Inconsistency

`prd-cap-004.md` uses `document_type: prd-section` while all other supplements use
`document_type: prd-supplement`. This is a cosmetic inconsistency; the content is
equivalent. **Flag for state-manager to normalize.**

### 8.8 Phase-1d Adversarial Pass-1 Resolution Notes (v1.2)

**New BCs for architect ARCH-INDEX / subsystem-decomposition.md update:**

The following new BCs were added and require the architect to update BC counts in
`architecture/ARCH-INDEX.md` and `architecture/subsystem-decomposition.md`:

| New BC IDs | Subsystem | Capability | Count Impact |
|-----------|-----------|-----------|-------------|
| BC-7.11.002..BC-7.11.008 | SS-06 | CAP-007 | +7 BCs; SS-06 count: 12 → 19 |
| BC-11.03.006 | SS-09 | CAP-011 | +1 BC; SS-09 count: 13 → 14 |

**Architect also owns:**
- Correcting `subsystem-decomposition.md §SS-09` which refers to "five declared patterns:
  DP-003 through DP-008" — now SIX enforced patterns (DP-003..DP-008 inclusive). Update
  the count and language from "five" to "six."
- `methodology-layer.md` references to "no forbidden pattern (DP-003 through DP-008)"
  remain accurate (DP-007 is now enforced by BC-11.03.006, which is already in the range).

**VP-INDEX update needed:**
- BC-7.11.002..008 introduce VP-TBD-200..209 (provisional). Architect must register these
  in VP-INDEX.md with proper VP IDs after story decomposition assigns final IDs.

### 8.7 Cross-Capability Claim Notes

No contradictions detected between supplement files during integrate pass. The following
cross-capability dependencies are documented but consistent:

- CAP-013 BC-13.02.003 (Esports Replay) explicitly reuses CAP-003 replay spine — consistent
  with supplement narrative and DI-004.
- CAP-005 BC-5.04.002 and CAP-012 both reference Canon-KB structural integrity — consistent;
  CAP-005 produces artifacts that CAP-012 governs.
- CAP-010 AI disclosure mandate derives from CAP-004 provenance sidecars — consistent;
  BC-10.05.001 is explicitly a projection of CAP-004 provenance data.
- CAP-011 ethics contract ties into CAP-005/CAP-006 economy spine (see prd-cap-011.md §11.5) —
  consistent; no contradiction found.
