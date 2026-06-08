---
document_type: prd
level: L3
version: "1.2"
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
four adapter seams. Factory compliance, provenance, and ethics are first-class pipeline
outputs, not afterthought checklists. The "fun shell" (subjective game feel) is governed
by a human playtest gate that cannot be automated away.

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

**Tier 1 total: 111 BCs** (103 original + 1 added in v1.1: BC-1.15.002 for DI-010; +7 added in v1.2: BC-7.11.002..008 server-authority invariant suite)

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

**Grand total: 179 BCs**

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

> **Note on ss-NN directories:** Directory names `ss-01` through `ss-14` mirror capability
> numbers for navigability. They are NOT architecture subsystem IDs. Subsystem IDs have
> been assigned from `.factory/specs/architecture/subsystem-decomposition.md` (see
> ARCH-INDEX.md). All BC frontmatter `subsystem:` fields are now populated with real SS-NN
> values (SS-01 through SS-12). CAP-002 is merged into SS-01 (Engine-Adapter Protocol);
> CAP-010 is merged into SS-08 (Cert+Distribution).

---

## Section 4 — Cross-Cutting NFRs

Full NFR catalog: `.factory/specs/prd-supplements/nfr-catalog.md` (35 NFRs, NFR-001 through NFR-035).

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

Full taxonomy: `.factory/specs/prd-supplements/error-taxonomy.md` (141 error codes, 22 families — v1.2).

Family summary (v1.1 additions marked with `*`):

| Family | Owning Capability | Code Count |
|--------|------------------|-----------|
| E-EAP | CAP-001 (Engine Adapter Protocol) | 11 (+1: E-EAP-011 kernel anti-cheat, v1.1) |
| E-CONF * | CAP-002 (Conformance suite) | 5 |
| E-REPLAY * | CAP-003 (Replay harness) | 7 |
| E-GEN * | CAP-004 (Asset generation) | 9 |
| E-DES | CAP-005 (Design artifacts) | 5 |
| E-ART | CAP-005 (Art quality gate) | 3 |
| E-AUD | CAP-005 (Audio build) | 4 |
| E-NAR | CAP-005 (Narrative graph) | 4 |
| E-ENG | CAP-005 (Code separation) | 2 |
| E-CIN | CAP-005 (Cinematic graph) | 4 |
| E-PROD | CAP-005 (Production / wave) | 3 |
| E-SIM * | CAP-006 (Simulation QA) | 9 |
| E-CONV * | CAP-007 (Convergence) | 6 |
| E-PLAY * | CAP-008 (Playtest) | 5 |
| E-CERT | CAP-009 (Cert pre-flight) | 3 |
| E-DIST | CAP-009 (Distribution tools) | 19 |
| E-COMP | CAP-010 (Compliance) | 2 |
| E-ETH * | CAP-011 (Monetization Ethics) | 9 (+1: E-ETH-009 DP-007, v1.2) |
| E-KB * | CAP-012 (Canon KB) | 7 |
| E-GENRE * | CAP-013 (Genre lanes) | 6 |
| E-XR * | CAP-014 (XR seam) | 6 |
| E-PRV ** | CAP-004 (Provenance disclosure_class) | 3 (E-PRV-010/011/012, v1.2) |

**Error family gap status:** All 14 capability families now have error families defined. FU-003 closed. v1.2 adds E-PRV (3 codes, CAP-004 provenance) and E-ETH-009. See `error-taxonomy.md §Coverage Notes`.

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
| No lock-in (all four seams) | New engine onboarding cost | Implement adapter + pass conformance; ZERO core changes | BC-1.15.001, BC-2.02.002 | Covered |
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

### 8.1 Subsystem Assignment (Resolved)

**All 170 behavioral contracts have been assigned to architecture subsystems (SS-01 through
SS-12).** The `subsystem: SS-TBD` placeholder has been replaced in all BC frontmatter.
The assignment was propagated from `.factory/specs/architecture/subsystem-decomposition.md`
(see ARCH-INDEX.md Subsystem Registry). BC file paths (directory `ss-NN/`, filename) are
immutable per `append_only_numbering` policy.

Subsystem distribution: SS-01 (41 BCs: CAP-001+002 + BC-1.15.002), SS-02 (9), SS-03 (15),
SS-04 (16), SS-05 (11), SS-06 (19: CAP-007 12 original + 7 server-authority invariant BCs v1.2), SS-07 (5), SS-08 (17: CAP-009+010), SS-09 (14: CAP-011 13 original + BC-11.03.006 v1.2),
SS-10 (9), SS-11 (15: CAP-013 + BC-13.01.004), SS-12 (7).

### 8.2 BC Frontmatter Priority Gap — CLOSED (v1.2)

Priority fields have been backfilled for all 94 BCs in `ss-01/` through `ss-03/` and
`ss-05/` through `ss-08/` that previously lacked them. Priority values assigned from
`capabilities.md`: P0 for CAP-001–007 (ss-01..ss-07 dirs), P1 for CAP-008 (ss-08 dir).
All 179 BCs now have explicit `priority:` fields in frontmatter.

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

### 8.4 Error Taxonomy — Updated (v1.2)

E-PRV family added (3 codes: E-PRV-010/011/012) to register BC-4.03.002's failure paths.
E-ETH-009 added for DP-007 enforcement. E-GEN-004 vocabulary corrected to canonical three
values `[pre-generated, live-generated, procedural-exempt]`. E-ETH-005 "(DP-007 equivalent)"
mislabel removed. E-SIM-009 identifier corrected from `(D-012)` to `(DI-012)`.
Total: 141 error codes across 22 families. See `error-taxonomy.md §Coverage Notes`.

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
