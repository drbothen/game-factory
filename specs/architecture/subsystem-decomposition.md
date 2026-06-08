---
document_type: architecture-section
level: L4
section: subsystem-decomposition
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
inputs:
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Subsystem Decomposition

> **Primary purpose of this document:** (1) define each subsystem with scope, layer
> assignment, and principal agents; (2) provide the BC→Subsystem assignment table
> resolving the 168 SS-TBD placeholders in BC frontmatter.
>
> **Note on directory names.** The BC file tree uses `ss-01/`…`ss-14/` as navigability
> aliases for `CAP-001`…`CAP-014`. These directory names do NOT correspond to SS-NN IDs.
> The authoritative SS-NN assignments are in this document and in ARCH-INDEX.md.
> A separate mechanical pass will update the `subsystem:` frontmatter field in each BC
> file once this document is accepted.

---

## Subsystem Definitions

### SS-01 — Engine-Adapter Protocol

**Layer:** 3 + 4 (protocol layer + adapter implementations)
**Owned capabilities:** CAP-001, CAP-002
**BC count:** 40 (34 + 6)
**Priority:** P0

Owns the complete engine adapter protocol surface (JSON-RPC 2.0 transport, capability
manifest, fidelity grades, execution profiles, conformance suite) and the adapter
implementations for the founding pair (Bevy, Unity) and planned third (Godot).
Enforces DI-001 (core never names an engine) and DI-002 (conformance required before
acceptance). The two-adapter rule (ADR-0001) is a structural constraint on this
subsystem's design process.

**Principal agents:** `devops-engineer` (CI conformance runner), specialist adapter
implementers (one per engine), `consistency-validator` (manifest drift detection).

---

### SS-02 — Deterministic Replay Harness

**Layer:** 2 + 3 (methodology layer owns the harness contract; Layer 3 provides the
`replay` capability surface via the engine adapter protocol)
**Owned capabilities:** CAP-003
**BC count:** 9
**Priority:** P0

Owns input-stream recording keyed by sim frame, deterministic replay execution, and
state comparison using the tier-declared method (T1 exact snapshot-hash / T2
pinned-runner / T3 tolerance-window). Enforces DI-004 (tier declared, never assumed).
Golden-state bootstrap and invalidation protocol is a critical lifecycle concern.
The replay spine is cross-cutting: QA regression, esports demo export (BC-3.03.009),
anti-cheat proof-of-state — all served by the same harness.

**Principal agents:** `functional-qa`, replay-regression specialist, `formal-verifier`
(sim hardening scope only).

---

### SS-03 — Asset Generation Pipeline

**Layer:** 2 (methodology layer — asset-adapter is Layer 4)
**Owned capabilities:** CAP-004
**BC count:** 15
**Priority:** P0

Owns pure-maximal asset generation across all modalities (3D mesh, texture, audio,
music, voice, concept art, narrative text), the asset-adapter routing and fidelity
grading, backend blocklist enforcement (DI-009: Suno/Udio blocked), risk-tier
assignment, provenance sidecar population (DI-003: mandatory at generation time),
quality gate definitions per asset class, and asset store ingest gating.
Enforces R-001/R-002/R-003/R-004 mitigations (copyright, indemnification, Suno/Udio,
SAG-AFTRA). The `disclosure_class` field supports R-014 (EU AI Act Art. 50 C2PA marks).

**Principal agents:** `asset-generation-orchestrator`, `concept-artist`, `env-modeler`,
`prop-artist`, `char-modeler`, `char-texture`, `vfx-artist`, `composer`, `voice-director`.

---

### SS-04 — Multi-Discipline Production

**Layer:** 2 (methodology layer)
**Owned capabilities:** CAP-005
**BC count:** 16
**Priority:** P0

Owns the cross-discipline artifact production scope: design spec bundle, economy graph,
accessibility contract, art package + art bible, audio build manifest + provenance ledger,
narrative graph + canon-KB binding, gameplay code (gameplay-logic/pure-sim separation
contract), cinematics sequence graph + lip-sync pipeline, and cross-discipline dependency
contracts governing wave ordering. This is the "Studio-of-Agents" integration layer —
it does not own individual discipline artifacts but owns the dependency DAG and handoff
contracts that link them.

**Principal agents:** `producer`, all 66 studio roles (depending on active genre lanes),
wave scheduling orchestrator.

---

### SS-05 — Simulation Quality Verification

**Layer:** 2 (methodology layer — pure-sim slice)
**Owned capabilities:** CAP-006
**BC count:** 11
**Priority:** P0

Owns the machine-verifiable quality spine for game simulation: economy conservation
invariant, damage I/O matrix correctness, FSM state legality, AI behavior-tree
determinism, design-intent reachability, game solvability, balance bands, no-softlock
invariant, and TDD Red Gate enforcement for the pure-sim code slice. Distinct from
SS-02 (which owns the *replay mechanism*); SS-05 owns the *contract declarations* that
the replay harness verifies against. DI-012 (every contract has a declared validation
method) is enforced here.

**Principal agents:** `functional-qa`, `balance-qa`, `systems-designer`, `economy-designer`,
`implementer` (pure-sim), `test-writer` (pure-sim).

---

### SS-06 — Convergence Tracking Engine

**Layer:** 2 (methodology layer — convergence loop)
**Owned capabilities:** CAP-007
**BC count:** 12
**Priority:** P0

Owns the 11-dimension convergence evaluation and release-gating loop. Each of the 12
BCs maps to one convergence dimension evaluation contract plus the release-gating rule.
The convergence loop engine itself (novelty-decay, 3-CLEAN streak, dimension declarations)
is ADAPTED from vsdd-factory's 7-dim machinery (extraction-boundary-validated.md §3.2).
A release is blocked until all required dimensions are green or explicitly degraded to a
declared fallback. SS-06 is the structural integration of all other subsystems — it
reads convergence signals from SS-01 through SS-12 and gates the release.

**Principal agents:** `convergence-tracking` skill, adversary (monetization-ethics review),
`state-manager` (convergence state bookkeeping).

---

### SS-07 — Playtest Protocol

**Layer:** 2 (methodology layer — human gate)
**Owned capabilities:** CAP-008
**BC count:** 5
**Priority:** P1

Owns the structured human playtest protocol (3-lens: say/do/behave), GEQ/PENS/SUS
instrument scaffolding, evidence capture, convergence report synthesis, human sign-off
gate, and agent-fun-score detection (any auto-emitted fun score is a defect per DI-007).
This is the game-factory analog of vsdd-factory's holdout evaluator — but explicitly
not automated. The mandatory human sign-off (BC-8.08.004) is a non-suppressible hook.

**Principal agents:** `playtest-evaluator`, `functional-qa`, `balance-qa`.

---

### SS-08 — Cert and Distribution

**Layer:** 2 + 4 (methodology layer owns the cert-preflight contracts; distribution
adapter is Layer 4)
**Owned capabilities:** CAP-009, CAP-010
**BC count:** 17 (11 + 6)
**Priority:** P1

Owns cert pre-flight (machine-checkable subset per platform), distribution CLI execution
(steamcmd/butler/fastlane), distribution-release-pipeline artifact, store-asset spec
conformance, human-gated task surfacing for console cert sign-off and store publish (DI-006),
and the full compliance pipeline: IARC auto-fill, compliance-checklist, privacy-config-contract,
legal-doc-set, and `ai-disclosure-manifest` (C2PA marks from provenance sidecar, R-014).
Enforces R-013 (PEGI 2026 content-descriptor min-rating rules) and R-015 (COPPA per-SDK
consent flags).

**Principal agents:** `cert-owner`, `compliance-officer`, `ratings-submitter`,
`release-engineer`, `platform-integrator`.

---

### SS-09 — Monetization Ethics

**Layer:** 2 (methodology layer — ethics enforcement)
**Owned capabilities:** CAP-011
**BC count:** 13
**Priority:** P1

Owns the monetization-ethics-contract schema, default ethics envelope, mandatory adversarial
review gate, and all constrained-optimization invariants: no unconstrained LTV objective
(DI-005), economy-spine propagation, no-progression-deadlock-without-spend, and forbidden
dark-pattern enforcement (five declared patterns: DP-003 through DP-008). Also owns gacha
EV/pity correctness and spend-concentration guardrail (Gini coefficient bound). This
subsystem applies to any game with monetization; ethics contract absence is a factory
defect when monetization is present.

**Principal agents:** `monetization-designer`, `economy-designer`, `economy-balancer`,
adversary (mandatory ethics review).

---

### SS-10 — Canon Knowledge-Base

**Layer:** 2 (methodology layer — lore/RAG spine)
**Owned capabilities:** CAP-012
**BC count:** 9
**Priority:** P1

Owns the Canon-KB structure (entity-registry, relationship-graph, timeline, naming-registry,
canon-facts), machine-checkable structural integrity (no dangling refs, timeline consistency,
phonotactic naming rules), retcon propagation (where-used impact analysis), and the
RAG-grounding contract ensuring all generative agents query the Canon-KB rather than
hallucinating lore. The Canon-KB is identified as the fifth load-bearing seam
(product-brief §Overflow Context).

**Principal agents:** `worldbuilder`, `loremaster`, `narrative-director`, `quest-designer`.

---

### SS-11 — Genre-Gated Lanes

**Layer:** 2 (methodology layer — genre activation)
**Owned capabilities:** CAP-013
**BC count:** 14
**Priority:** P2

Owns the genre-profile schema, inactive-lane zero-artifact guarantee, lane idempotency,
and four optional lanes: competitive-multiplayer/esports (ranking system, matchmaking,
replay export, spectator, tournament), modding/UGC (mod-API contract, UGC schema,
mod-load determinism, mod.io distribution adapter), marketing/GTM (store asset
conformance, marketing asset manifest), and a genre-profile activation router.
Inactive lanes impose zero constraints on the universal core. This subsystem is
Tier-2: v1-ready, genre-gated opt-in.

**Principal agents:** `ranking-systems-engineer`, `spectator-tournament-engineer`,
`mod-api-owner`, `ugc-pipeline-engineer`, `store-copywriter`, `trailer-editor`,
`key-art-director`.

---

### SS-12 — XR Platform Seam

**Layer:** 3 (seam contract only; implementation Layer 4 DEFERRED)
**Owned capabilities:** CAP-014
**BC count:** 7
**Priority:** P2 (Tier 3 — seam reserved; implementation deferred)

Owns the XR adapter manifest schema, OpenXR capability fidelity grading (extension
namespace: KHR > EXT > vendor), XR seam isolation invariant (zero core changes on
XR adapter add/remove), XR performance budget schema, XR comfort spec (locomotion,
vignette, candidate rating), and human-gated comfort-cert (vestibular gate by
construction, DI-006). Apple Vision Pro is a separate non-OpenXR adapter target.
The seam contract (Layer 3 schema) is defined now so it does not require core changes
when implementation begins; the adapter implementation is deferred.

**Principal agents:** `xr-adapter-owner` (deferred).

---

## BC to Subsystem Assignment Table

> This table is the authoritative resolution of all 168 SS-TBD placeholders.
> A mechanical pass will apply `subsystem: SS-NN` to each BC file's frontmatter.
> BC directory names (ss-01/…ss-14/) are navigability aliases for CAP numbers only.

| BC ID Range | Count | Assigned Subsystem | Rationale |
|-------------|-------|--------------------|-----------|
| BC-1.01.001 – BC-1.15.001 | 34 | **SS-01** | CAP-001 = engine adapter protocol surface |
| BC-2.02.001 – BC-2.02.006 | 6 | **SS-01** | CAP-002 = conformance gating (protocol quality gate) |
| BC-3.03.001 – BC-3.03.009 | 9 | **SS-02** | CAP-003 = deterministic replay harness |
| BC-4.01.001 – BC-4.06.001 | 15 | **SS-03** | CAP-004 = asset generation pipeline |
| BC-5.01.001 – BC-5.07.003 | 16 | **SS-04** | CAP-005 = multi-discipline production |
| BC-6.01.001 – BC-6.04.001 | 11 | **SS-05** | CAP-006 = simulation quality verification |
| BC-7.01.001 – BC-7.12.001 | 12 | **SS-06** | CAP-007 = convergence tracking engine |
| BC-8.08.001 – BC-8.08.005 | 5 | **SS-07** | CAP-008 = playtest protocol |
| BC-9.01.001 – BC-9.06.002 | 11 | **SS-08** | CAP-009 = cert + distribution |
| BC-10.01.001 – BC-10.06.001 | 6 | **SS-08** | CAP-010 = compliance pipeline (co-owned with cert) |
| BC-11.01.001 – BC-11.04.002 | 13 | **SS-09** | CAP-011 = monetization ethics |
| BC-12.12.001 – BC-12.12.009 | 9 | **SS-10** | CAP-012 = canon knowledge-base |
| BC-13.01.001 – BC-13.04.002 | 14 | **SS-11** | CAP-013 = genre-gated lanes |
| BC-14.01.001 – BC-14.02.003 | 7 | **SS-12** | CAP-014 = XR platform seam |
| **TOTAL** | **168** | | |

---

## Subsystem Grouping Rationale

**CAP-001 + CAP-002 grouped into SS-01.** Conformance gating (CAP-002) is structurally
part of the engine adapter protocol system, not a separate subsystem. The 6 conformance
BCs describe quality gates on the protocol layer, not a standalone service boundary.
Grouping reduces subsystem count from 14 to 12 without losing traceability.

**CAP-009 + CAP-010 grouped into SS-08.** Cert pre-flight (CAP-009) and compliance
pipeline (CAP-010) are co-owned by the same principal agents (`cert-owner`,
`compliance-officer`) and share the human-gated task surfacing pattern (DI-006).
Compliance artifacts (IARC, ratings submission manifest, AI disclosure) are prerequisites
for distribution. A single subsystem boundary is cleaner than two with overlapping owners.

**All other capabilities map 1:1 to a subsystem.**

---

## Subsystem Priority Summary

| Priority | Subsystems | BC Count |
|----------|-----------|----------|
| P0 (must ship v1) | SS-01, SS-02, SS-03, SS-04, SS-05, SS-06 | 103 |
| P1 (ship v1) | SS-07, SS-08, SS-09, SS-10 | 44 |
| P2 (v1-ready, opt-in/deferred) | SS-11, SS-12 | 21 |
| **Total** | | **168** |
