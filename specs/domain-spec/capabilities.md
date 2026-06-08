---
document_type: domain-spec-section
level: L2
section: capabilities
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/architecture.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
---

# Domain Capabilities

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> Capabilities model WHAT the system does (domain level), not HOW it is implemented.

## Anchor Justification

Each capability below states its grounding in the product brief or charter.
Capabilities are engine-independent; the adapter seams enforce this.

---

## CAP-001 — Engine-Agnostic Game Build and Test (P0)

The factory builds, tests, runs, introspects, and captures gameplay from any supported
engine via the Engine Adapter Protocol, without naming or coupling to any specific engine
in the factory core.

CAP-001 covers the full engine adapter protocol surface because the product brief declares
"engine-agnostic via four adapter seams" as the primary thesis, grounded in Brief §What
Is This and §Success Criteria ("New engine/tool/platform onboarding cost: implement adapter
+ pass conformance; ZERO core changes").

## CAP-002 — Engine Adapter Conformance Gating (P0)

The factory validates every engine adapter against the conformance suite for its declared
capabilities before accepting it. No engine adapter can be used without passing conformance.

CAP-002 covers conformance gating because the product brief and ADR-0002 establish
"conformance suite is the anti-drift mechanism" as load-bearing. Referenced in Brief §Success
Criteria and RECONCILIATION §5A.

## CAP-003 — Determinism-Tier-Governed Replay Regression (P0)

The factory records game input streams keyed by simulation frame, replays them
deterministically, and compares resulting simulation state against golden references. The
comparison method degrades by the engine adapter's declared determinism tier (T1: exact
snapshot-hash; T2: pinned-runner; T3: tolerance-window).

CAP-003 covers deterministic replay because it is the game-factory analog of vsdd-factory's
DTU and the load-bearing regression signal. Grounded in Brief §In Scope ("replay-regression"),
§Success Criteria ("Injected sim regression detected at T1 (bitwise): 100%"), and ADR-0003.

## CAP-004 — Pure-Maximal Asset Generation with Auto-Provenance (P0)

The factory generates all game assets (3D meshes, textures, audio, music, voice, concept
art, narrative text) via agent-driven generation pipelines with no mandatory human creative
finishing step. Every generated asset receives a complete provenance sidecar at generation
time, including `disclosure_class`.

CAP-004 covers asset generation because the product brief declares "pure-maximal + auto-
provenance" as a core constraint and success criterion ("Generated assets with complete
provenance sidecar: 100%; 0 missing `disclosure_class`"). Grounded in Brief §In Scope,
§Constraints, and RECONCILIATION §9.

## CAP-005 — Multi-Discipline Game Artifact Production (P0)

The factory produces all artifacts a game requires across all disciplines (design specs,
balance data, economy graphs, level specs, narrative graphs, audio build manifests, art
bibles, code, QA artifacts) via the 66-role Studio-of-Agents.

CAP-005 covers the full studio-of-agents production scope because the product brief states
"generates EVERYTHING a game needs — design, art, audio, narrative, code, QA artifacts".
Grounded in Brief §What Is This and RECONCILIATION §5.

## CAP-006 — Contract-Driven Simulation Quality Verification (P0)

The factory verifies game simulation correctness via machine-checkable behavioral contracts:
simulation BCs (economy, damage, FSM, AI), design-intent contracts (reachability, balance
bands, no-softlock), and replay-regression contracts. All governed by TDD Red Gate on the
pure-sim slice.

CAP-006 covers the simulation quality spine because it is the machine-verifiable core
replacing vsdd-factory's BCs for the game domain. Grounded in Brief §In Scope ("simulation
BCs, design-intent contracts"), architecture.md §Quality model, and RECONCILIATION §4.

## CAP-007 — 11-Dimension Convergence Tracking (P0)

The factory tracks and gates production progress across 11 convergence dimensions: sim/spec,
tests/replay, implementation, asset-completeness, playtest-satisfaction, cert-preflight+
distribution-readiness, perf-budget, provenance/legal+compliance, docs, monetization-ethics,
security-invariants. Release is blocked until all required dimensions are green or explicitly
degraded to a declared fallback.

CAP-007 covers convergence because the product brief names the 11-dimension convergence model
as part of the "game methodology layer" (Brief §In Scope) and RECONCILIATION §7 defines all
11 dimensions as load-bearing.

## CAP-008 — Structured Playtest Protocol (P1)

The factory runs structured human playtest sessions using the 3-lens convergence protocol
(say/do/behave), GEQ/PENS/SUS instruments, and produces a convergence report. This is a
mandatory human gate; the factory provides protocol scaffolding and evidence recording but
never auto-scores fun or feel.

CAP-008 covers playtest because it is the non-automatable holdout analog and a required
convergence dimension. Grounded in Brief §In Scope and RECONCILIATION §4 (Holdout →
Playtest Protocol).

## CAP-009 — Cert Pre-Flight and Distribution-Readiness (P1)

The factory runs machine-checkable certification pre-flight (55-80% of cert requirements
per platform), executes verified distribution CLIs (steamcmd, butler, fastlane), generates
the distribution release pipeline, and surfaces `human-gated` task lists for console cert
sign-off and store publish. Console cert sign-off is never automated.

CAP-009 covers distribution-readiness because the v2.0 scope change explicitly moved cert
pre-flight in-scope as a P0 convergence dimension. Grounded in Brief §In Scope, RECONCILIATION
§5.9 and §10 Tier 1.

## CAP-010 — Compliance Pipeline and AI Disclosure (P1)

The factory auto-fills IARC objective questionnaire answers from game metadata, generates
`compliance-checklist`, `privacy-config-contract`, `legal-doc-set` templates, and emits the
`ai-disclosure-manifest` (projection of provenance sidecars with C2PA marks, per EU AI Act
Art. 50). Ratings submission terminal step is `human-gated`.

CAP-010 covers compliance because EU AI Act Art. 50 (applies 2026-08-02), PEGI 2026 changes,
and FTC COPPA 2025 create non-optional compliance obligations. Grounded in Brief §Constraints
and RECONCILIATION §12 (R-013, R-014, R-015) and §10 Tier 1.

## CAP-011 — Monetization Ethics Enforcement (P1)

The factory produces a `monetization-ethics-contract` for any game with monetization,
enforces constrained-optimization policy (no unconstrained LTV maximization, no declared
forbidden dark patterns), and subjects the contract to mandatory adversarial review.
Autonomous LTV maximization without a declared ethics contract is a factory defect.

CAP-011 covers monetization ethics because the product brief explicitly names this as a
constraint ("constrained optimization only; unconstrained LTV maximize is a factory defect").
Grounded in Brief §Constraints and RECONCILIATION §8, §12 R-010.

## CAP-012 — Canon Knowledge-Base Grounding (P1)

The factory maintains a Canon Knowledge-Base (entity-registry + relationship-graph +
timeline + naming-registry + canon-facts) with machine-checkable structural integrity
(no dangling entity refs, timeline consistency). All generative agents RAG over the
Canon-KB.

CAP-012 covers the Canon-KB because it is described as "the fifth load-bearing seam" in
the product brief (Brief §Overflow Context) and RECONCILIATION §5.6a.

## CAP-013 — Genre-Gated Optional Lane Activation (P2)

The factory activates genre-specific production lanes (competitive multiplayer / esports,
modding/UGC, monetization mechanics, marketing/GTM) via genre profile parameters, without
affecting the universal core. Inactive lanes produce no artifacts and impose no constraints.

CAP-013 covers genre-gated lanes because the three-tier scope model establishes these as
v1-ready but not default-on. Grounded in RECONCILIATION §10 Tier 2.

## CAP-014 — XR Platform Seam (P2, Tier 3 Deferred)

The factory provides the XR adapter seam (contract schema, capability definitions,
fidelity model) so that an XR runtime can be added without core changes. Implementation
is deferred until Unity/Godot adapters are proven.

CAP-014 covers the XR seam because the product brief declares "seam reserved; impl deferred"
for XR (Brief §Scope: Out of Scope / Deferred). Grounded in RECONCILIATION §5A and §10 Tier 3.

## CAP-015 — Online-Services Adapter (P1, Tier 1)

**Subsystem: SS-13**

The factory integrates with Backend-as-a-Service (BaaS) platforms via the online-services
adapter seam, providing a capability surface for: player identity (account creation,
authentication, session token management), cloud save (per-player persistence with
conflict resolution), leaderboards (server-authoritative score submission with variant
support), matchmaking (lobby lifecycle, player matching), entitlements (server-authoritative
purchase verification, DLC unlock, human-gated platform-store-review path), and remote
config (feature-flag fetch with contract binding). The reference implementation targets
Nakama (self-hostable, Docker-in-CI via DTU-08); EOS and PlayFab follow as alternative
adapters. Offline/single-player projects may disable all online services via
`online_features: false` in the project genre-profile, producing zero BaaS configuration
artifacts without pipeline failure.

CAP-015 covers online services as a Tier-1 (v1 ship prerequisite) because:
(1) the five-seam adapter architecture (ADR-0004) explicitly reserves the online-services
seam as a first-class anti-lock-in boundary (adapter-protocols.md §6, Pass-13 adversarial
defect C13-01); (2) competitive multiplayer and live-service games require BaaS as a
foundational dependency; (3) server-authority enforcement for leaderboards and entitlements
is required by the D-SEC convergence dimension (BC-7.11.002, BC-7.11.008). Grounded in
adapter-protocols.md §6 (five-seam reconciliation) and the Tier-1 ship prerequisite posture.
