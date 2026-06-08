---
document_type: domain-spec-section
level: L2
section: ubiquitous-language
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/architecture.md
  - .factory/planning/design/engine-adapter-protocol.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
---

# Ubiquitous Language — game-factory Domain Glossary

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.

## Factory Paradigm Terms

**Dark Factory** — A lights-out, autonomous production system operating the
Seed → Validation Harness → Feedback Loop paradigm. No step requires mandatory
human authorship except declared `human-gated` external acts.

**Seed** — The authoritative input artifact (game spec + design intent) from which
the factory generates all game artifacts. Analogous to vsdd-factory's product brief.

**Satisfaction** — The factory quality signal: the fraction of trajectories that
satisfy declared constraints. Replaces boolean pass/fail. Playtest satisfaction is
the non-automatable satisfaction dimension.

**Tokens as Fuel** — Agent compute (LLM token spend) is the cost unit. Wave
scheduling controls parallelism and budgets generation-then-validation cycles.

**Filesystem-as-Memory** — All factory state (specs, contracts, provenance, wave
plans, decisions) lives in versioned files. `.factory/` is the canonical state volume.

**Pure-Maximal** — The asset-generation policy: agents generate all content
(hero art, music, voice) with no mandatory human creative finishing. Legal and
quality risks are recorded in provenance metadata, not used to impose human gates.

## Adapter Architecture Terms

**Engine-Adapter Protocol** — Layer 3: the JSON-RPC 2.0 stable contract between
the factory core (Layers 1-2) and any engine backend (Layer 4). The core never
names a specific engine or imports an engine SDK; all engine knowledge is quarantined
in the adapter.

**Capability** (adapter sense) — A named, independently fidelity-graded operation
the adapter declares it can perform: `build`, `test`, `run_headless`, `replay`,
`capture`, `lint`, `assets_validate`, `introspect`. Never bundled.

**Fidelity Value** — The declared quality of a capability: `full` / `partial` /
`none` / `human-gated`. `human-gated` means the automatable prefix is complete and
one checklisted human task is surfaced, not silently skipped.

**Capability Negotiation** — The LSP-style handshake where an adapter declares its
`engineCapabilities` manifest and the core requests only what is supported.
Unsupported operations return an explicit error; graceful degradation, not
lowest-common-denominator.

**Conformance Suite** — The CRI/CSI-style capability-gated test battery that every
adapter must pass for its declared capabilities. "Implement adapter + pass
conformance" is the formal bar for adding any engine. The anti-drift mechanism.

**Declare-and-Degrade** — The protocol guarantee: the factory declares what it
needs; the adapter declares what it can deliver; the quality model degrades
gracefully to the best available fidelity rather than failing or assuming capability.

**Two-Adapter Rule** — The protocol is designed against two maximally dissimilar
adapters simultaneously (Bevy + Unity) to prevent single-backend assumptions leaking
into the neutral layer.

**Determinism Tier** — The declared strength of sim replay reproducibility.
T1 (`bitwise-cross-platform`) = identical snapshot hash across OS/CPU.
T2 (`same-machine`) = reproducible on one pinned CI image only.
T3 (`tolerance-only`) = compare metrics within tolerance window.

**Execution Profile** — One of two declared adapter modes: `headless-compute`
(build/test/introspect — true headless, no GPU required) and `render`
(capture/video — GPU backend always required, even if "headless" in other senses).

**Semport** — Version-pinned, conformance-gated adapter compatibility matrix.
Each adapter declares exactly one engine version; each engine minor release is
scheduled adapter maintenance.

## Game Quality Model Terms

**Simulation Behavioral Contract (sim-BC)** — Machine-checkable assertion over
serialized simulation state: economy invariants, damage I/O matrices, FSM legality,
AI behavior trees, netcode determinism. The verifiable spine of the quality model.

**Design Intent Contract** — Verifiable subset of design intent encoded as typed
assertions (reachability, solvability, balance bands, no-softlock, conservation).
The remainder is explicitly delegated to the playtest protocol.

**Replay-Regression Contract** — Per-scenario recorded input track + expected golden
state. Comparison method degrades by determinism tier. The game-factory analog of
vsdd-factory's DTU.

**Playtest Protocol** — Structured human playtest with 3-lens convergence
(say/do/behave), GEQ/PENS/SUS instruments. The non-automatable quality dimension.
Never auto-scored. The game-factory analog of holdout evaluation.

**Convergence** — The 11-dimension quality state a game build must reach before
release. Dimensions: sim/spec, tests/replay, implementation, asset-completeness,
playtest-satisfaction, cert-preflight+distribution-readiness, perf-budget,
provenance/legal+compliance, docs, monetization-ethics, security-invariants.

**Monetization-Ethics Contract** — The constrained-optimization policy envelope
declaring allowed monetization mechanics, forbidden dark patterns, and LTV
optimization bounds. Autonomous unconstrained LTV maximization is a factory defect.

**Server-Authority Invariant Suite** — The CWE-602 machine-verifiable security spine
for online/multiplayer games: no-trust-client, input validation, replay-attack
prevention, economy conservation/atomicity, secure entitlement.

## Asset Domain Terms

**Asset Provenance Sidecar** — Mandatory metadata record attached to every generated
asset: tool, model, prompt log, human-modifications log, license terms,
training-data provenance, likeness-consent ref, risk tier, copyrightability
assessment, and `disclosure_class`.

**Disclosure Class** — Classification of AI-generated content per EU AI Act Art. 50
and Steam policy: `pre-generated` / `live-generated` / `procedural-exempt`.
Feeds the `ai-disclosure-manifest`.

**Backend Class** (asset adapter sense) — Tier-1/2/3 risk classification of an
asset generation provider: Tier-1 = licensed/indemnified, auto-ingest;
Tier-2 = some indemnification, flagged but ingested; Tier-3 = unindemnified,
flagged with copyrightability-assessment.

**Quality-Gate Report** — Per-asset validation output: topology, UV, PBR,
loudness, and provenance completeness checks. Tier-1 auto-ingest on pass; all
tiers ingest (pure-maximal); fail triggers re-generation.

## Production Domain Terms

**Discipline** — A coherent body of game development work (game design, visual art,
audio, narrative, engineering, QA, etc.) decomposed into agent roles.

**Studio-of-Agents** — The 66-role agent roster covering all AAA disciplines.
Each role owns a defined artifact set. Catalyst (C) roles coordinate; Specialist (S)
roles produce.

**Canon Knowledge-Base (Canon-KB)** — Entity-registry + relationship-graph +
timeline + naming-registry + canon-facts. The RAG grounding anchor for all
generative agents. Structural machine-checkable properties: no dangling entity refs,
timeline consistency.

**Wave** — A dependency-DAG-ordered batch of stories. Each wave is gated by a
post-wave integration gate before the next wave begins.

**Milestone Gate** — Hook-enforced predicate set per production milestone.

**Cross-Discipline Dependency Contract** — Typed contract per discipline edge:
format, budgets, naming conventions, acceptance criteria. Validated automatically
on merge.

**Human-Gated** — A fidelity value and production status meaning: the factory has
completed all automatable work; a single checklisted human task is surfaced for an
external, third-party-required act. Suppressing or silently skipping a human-gated
task is a hook-detectable defect.

**Reference Game** — The pilot game built to prove end-to-end factory operation.
Parameters: Bevy + Rapier (T1), deterministic-simulation genre, premium monetization,
modding off, esports off, XR none.

**Genre Profile** — The parameterized set of contract activations for a game
genre: `dominant_contract_type`, `determinism_tier_target`, `replay_strictness`,
`playtest_instruments`, `monetization_model`, `modding_enabled`, `esports_enabled`,
`xr_target`.
