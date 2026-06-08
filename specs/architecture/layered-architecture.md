---
document_type: architecture-section
level: L4
section: layered-architecture
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
inputs:
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
  - .factory/planning/design/architecture.md
  - .factory/planning/design/extraction-boundary.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/product-brief.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Layered Architecture

> **Pass 1 scope.** This document defines the four layers and the
> reuse/replace/adapt disposition table grounded in
> `extraction-boundary-validated.md`. Adapter-protocol internals and
> methodology-layer internals are described at reference level here;
> full specs are deferred to architecture pass 2.

---

## Four-Layer Model

```
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 1 — CORE ORCHESTRATION ENGINE                             │
│  (extracted from vsdd-factory spine — REUSE)                     │
│                                                                  │
│  dispatcher binary · WASM hook chain · hook SDK/macros           │
│  lobster workflow DSL + parser · orchestrator agent              │
│  state manager · worktree/PR lifecycle · wave scheduling         │
│  adversarial review loop · telemetry sinks · context resolvers   │
│                                                                  │
│  Invariant: Layer 1 contains ZERO game knowledge.                │
│  Invariant: Layer 1 contains ZERO engine SDK imports.            │
├──────────────────────────────────────────────────────────────────┤
│  LAYER 2 — GAME METHODOLOGY LAYER                                │
│  (new — REPLACE vsdd quality model / ADAPT neutral agents)       │
│                                                                  │
│  game contract schemas (sim-BC, design-intent, replay-regression)│
│  11-dimension convergence model (reshapes vsdd 7-dim)            │
│  studio-of-agents roster (66 roles, game-domain specialists)     │
│  asset lane (asset generation + provenance pipeline)             │
│  playtest protocol (holdout replacement — human gate)            │
│  canon knowledge-base (fifth load-bearing seam)                  │
│  game-domain hook guards (REPLACE BC/VP guards)                  │
│  game workflow phases (ADAPT lobster phase files)                │
│                                                                  │
│  Invariant: Layer 2 is engine-neutral (no engine name/SDK).      │
│  Invariant: Game specs are engine-portable by construction (DI-008)│
├──────────────────────────────────────────────────────────────────┤
│  LAYER 3 — ENGINE ADAPTER PROTOCOL                               │
│  (new — the anti-lock-in seam; ADR-0002, ADR-0003)              │
│                                                                  │
│  JSON-RPC 2.0 stdio transport with Content-Length framing        │
│  capability manifest schema + fidelity grades (full/partial/none/│
│    human-gated)                                                  │
│  capability-gated conformance suite (CRI/CSI pattern)            │
│  determinism_tier capability field (ADR-0003)                    │
│  execution_profiles (headless-compute / render)                  │
│  compatibility matrix (core version ↔ protocol major version)   │
│  reference mini-game acceptance validator                        │
│                                                                  │
│  Invariant: Layers 1+2 talk ONLY to Layer 3 (never to Layer 4). │
│  Invariant: New engine = implement adapter + pass conformance.   │
│    ZERO core changes required.                                   │
├──────────────────────────────────────────────────────────────────┤
│  LAYER 4 — ENGINE ADAPTERS (one per engine/tool)                 │
│  (new — engine-bound, conformance-gated, swappable)              │
│                                                                  │
│  bevy-adapter   (T1: bitwise-cross-platform, BRP introspect)     │
│  unity-adapter  (T2: same-machine, xvfb render)                  │
│  godot-adapter  (T3: tolerance-only)                             │
│  [unreal-adapter — Tier 3 DEFERRED]                              │
│  [xr-adapter — seam reserved; implementation DEFERRED]          │
│  asset-adapter  (per generative backend: Tripo, ElevenLabs, etc.)│
│  distribution-adapter (steamcmd, butler, fastlane, GDK)          │
│                                                                  │
│  Invariant: All engine knowledge is quarantined in Layer 4.      │
│  Invariant: An adapter is not accepted without conformance pass. │
└──────────────────────────────────────────────────────────────────┘
```

---

## Reuse / Replace / Adapt Disposition Table

Source: `extraction-boundary-validated.md` §1 and §2.

| Component | Disposition | game-factory form |
|-----------|-------------|-------------------|
| **Dispatcher binary** (`crates/factory-dispatcher/`) | REUSE | Extracted verbatim — Layer 1 core |
| **Hook SDK + macros** (`crates/hook-sdk/`) | REUSE | Extracted verbatim — game guards compile against it |
| **Telemetry sinks** | REUSE | Extracted verbatim |
| **Context resolvers** (`crates/vsdd-context-resolvers/`) | REUSE (rename) | Drop "vsdd" prefix; mechanism unchanged |
| **Hook registry TOML schema** | REUSE schema / REPLACE row set | Keep schema; ship game guard set (sim-BC, replay-regression, asset-completeness, playtest-evidence) |
| **Neutral hook plugins** (worktree, wave-state, PR, telemetry, state-structure, artifact-path, etc.) | REUSE | Extracted verbatim |
| **VSDD-quality hook plugins** (regression-gate, adversary-convergence, burst-log) | ADAPT | Reshape gates: regression-gate → sim-contract + replay regression; convergence-guard → 11-dim game model |
| **Lobster DSL + parser** | REUSE | Extracted verbatim — Layer 1 |
| **Workflow scaffold** (repo-init → planning → spec → adversarial → wave → convergence → release) | REUSE | Scaffold untouched |
| **Phase sub-workflows** (phase-4 holdout, phase-6 formal-hardening) | REPLACE | phase-4 → playtest-protocol; phase-6 → sim-hardening (pure-sim slice only) |
| **DTU / gene-transfusion phase steps** | REPLACE | DTU → replay-regression-harness assessment; gene-transfusion → adapter-conformance-suite |
| **Convergence workflow step** | ADAPT | Keep loop engine + 3-CLEAN streak + novelty-decay; replace 7-dim definition with 11 game dims |
| **Orchestrator + sequences** | REUSE | Extracted; sequences re-pointed at game phases |
| **Agent routing table mechanism** | REUSE mechanism / ADAPT rows | Swap ~6 quality-role rows for game roles |
| **Neutral specialist agents** (architect, product-owner, story-writer, adversary, PR, state-manager, etc.) | REUSE | Extracted verbatim/lightly |
| **VSDD-quality agents** (formal-verifier, dtu-validator, holdout-evaluator) | REPLACE | → sim-formal-hardening; replay-regression-agent; playtest-evaluator |
| **Neutral skills** (~85 of 121 skills) | REUSE | Extracted |
| **Convergence skills** | ADAPT | Keep loop engine; edit dimension list |
| **VSDD-quality skills** (holdout-eval, dtu-create, dtu-validate, formal-verify) | REPLACE | → playtest-protocol, replay-regression-harness, sim-hardening |
| **TDD red-gate** | REUSE | Reused verbatim for pure-sim slice; defaults off for engine-bound code |
| **BC/VP protection hooks** | REPLACE | → sim-BC + design-intent-contract + replay-regression-contract guards |
| **Spec templates (structural)** | REUSE / ADAPT | Extract; convergence-report adapts to game dims |
| **Spec templates (quality)** | REPLACE | → game contract templates (sim-BC, design-intent, replay-regression, asset-provenance) |
| **Purity hook** | ADAPT | Kept for sim slice (pure-core/effectful boundary); not enforced on engine/render code |
| **Demo recorder** | ADAPT | Re-backed onto adapter `capture` command + ffmpeg fallback |
| **Operational CLIs** | REUSE | Extracted; `factory-replay` CLI aligns with replay-regression need |
| **Governance rules + policies mechanism** | REUSE | Swap BC/VP policy rows for game-contract policies |

---

## The Config/Content Seam

The extraction boundary is a **content/configuration boundary, not a code boundary**
(extraction-boundary-validated.md §2). The four declarative seam interfaces:

1. **`hooks-registry.toml` row set** — swap VSDD-quality rows for game-quality rows;
   no engine (dispatcher) change required.
2. **Lobster phase sub-workflow files** — replace two phase files (phase-4, phase-6)
   and the DTU/gene-transfusion assessment steps; the scaffold is untouched.
3. **Agent routing table rows** — swap ~6 role rows; mechanism untouched.
4. **Spec template + index data-model** — replace BC/VP/holdout/DTU template set and
   index schemas; keep the index mechanism.

**Consequence:** the Rust runtime (~80k LOC), lobster DSL parser, orchestrator, and all
state/worktree/PR/wave/adversarial machinery cross the boundary into game-factory Layer 1
untouched. The "~30% replace" is entirely concentrated in the quality-model content layer.

---

## Layer Dependency Rules

- Layer 1 → no external dependencies (pure infrastructure).
- Layer 2 → depends on Layer 1 (workflow + orchestration) and Layer 3 (protocol schema for
  engine capability negotiation). Never imports Layer 4 directly.
- Layer 3 → defines the adapter contract surface. No runtime dependency on any adapter.
- Layer 4 → implements Layer 3 contract. Depends on specific engine SDKs. Never imported
  by Layers 1–2.

---

## Pass 2 Scope (Reference)

Architecture pass 2 will provide:
- **Adapter Protocol Spec** — full Layer 3 capability schema, transport framing,
  error taxonomy, capability negotiation sequence, compatibility matrix format.
- **Methodology Layer Spec** — full Layer 2 contract schemas (sim-BC, design-intent,
  replay-regression, asset-provenance), 11-dim convergence criteria definitions,
  studio-of-agents routing, game workflow phase definitions.
- **Verification Coverage Matrix** — VP-to-module mapping for the pure-sim slice.
