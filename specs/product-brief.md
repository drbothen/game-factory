---
document_type: product-brief
level: L1
version: "1.0"
status: draft
producer: "human+planning-research"
timestamp: 2026-06-07T00:00:00
phase: 1a
inputs:
  - planning/research/RECONCILIATION.md
  - planning/research/bevy-capabilities.md
  - planning/research/unity-capabilities.md
  - planning/research/godot-capabilities.md
  - planning/research/prior-art-and-precedents.md
  - planning/design/architecture.md
  - planning/design/engine-adapter-protocol.md
  - planning/design/protocol-schema.md
  - planning/design/extraction-boundary.md
  - planning/decisions/0001-founding-engine-pair.md
  - planning/decisions/0002-protocol-and-conformance-stance.md
  - planning/decisions/0003-determinism-tier-capability.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: ""
---

# Product Brief: game-factory

## What Is This?

game-factory is an **engine-agnostic, multi-agent factory for game development**:
it turns an engine-neutral game specification into production-grade game code
across multiple engines (Bevy, Unity, Godot, …) via a pluggable engine-adapter
protocol. It is a sibling of vsdd-factory that reuses vsdd-factory's orchestration
spine but replaces its verification/quality model with one suited to games —
deterministic-simulation contracts that are machine-verifiable, plus design-intent
contracts validated by structured playtesting. The defining property is no engine
lock-in: the factory core never references a specific engine; every engine is a
swappable adapter that passes a conformance suite.

## Who Is It For?

| Persona | Pain Point | Current Workaround |
|---------|-----------|-------------------|
| Multi-engine studio tooling/platform teams | Maintain separate, siloed CI/test pipelines per engine; deepest cross-engine test SDKs cover only Unity+Unreal | Hand-rolled per-engine GitHub Actions (GameCI, godot-ci, UAT) with no shared abstraction or semantic test layer |
| Indie / small-studio tech leads shipping on one engine | Want rigorous, automated, spec-driven pipelines but lack the team to build TDD + regression + review infra | Manual playtesting, ad-hoc unit tests, no replay-regression, no adversarial spec review |
| Solo / AI-assisted game developers | Want spec-driven, test-backed game development with multi-agent automation, not black-box "AI plays the build" QA | Black-box tools (Airtest, modl.ai) that see pixels/OCR only, with no semantic engine access and no build integration |

## Scope

### In Scope

- **Engine-adapter protocol** — the stable anti-lock-in seam (JSON-RPC 2.0): capability
  negotiation, normalized result schemas, two execution profiles, determinism tiering.
- **Engine adapters** — founding pair Bevy + Unity (designed-against), then Godot, each
  implementing the protocol's eight capabilities at declared fidelity.
- **Conformance suite + reference mini-game** — the capability-gated, anti-drift
  mechanism every adapter must pass to be accepted.
- **Reused orchestration spine** — the engine- and game-neutral core extracted from
  vsdd-factory (dispatcher, hook chain, agent framework, state, workflows, PR/worktree
  lifecycle, adversarial review).
- **Game methodology layer** — design-intent contracts + simulation behavioral
  contracts, deterministic replay-regression, playtest protocols, an asset-tracking
  lane, and game-appropriate convergence dimensions.
- **Capability-driven graceful degradation** — gates that degrade by declared adapter
  capability/fidelity rather than assuming uniform engine support.

### Out of Scope

- Building a game *engine* (game-factory orchestrates existing engines, it is not one).
- Generating game *assets* (art/audio/models) — assets are tracked as story
  dependencies, not produced.
- Automatically scoring subjective "fun" — feel is validated by human playtest +
  metrics, never an automated fun-score.
- Unreal Engine support in v1 — the genuine Tier-3 outlier (headless/determinism/CLI
  friction); deferred until the protocol is proven on Bevy/Unity/Godot.
- Console/platform certification and store submission.
- Real-time multiplayer netcode as a product feature (deterministic-lockstep concepts
  are used *internally* for replay; shipping netcode is not a v1 capability).

## Success Criteria

| Outcome | Metric | Target |
|---------|--------|--------|
| Engine-agnostic by construction | Engine adapters passing the conformance suite | ≥ 3 (Bevy, Unity, Godot) |
| Core is genuinely engine/methodology-neutral | VSDD-specific dependencies remaining in the extracted core | 0 (core builds + passes conformance with no vsdd-methodology coupling) |
| One spec → many engines | A reference game built end-to-end through the factory from a single engine-neutral spec | runs on ≥ 2 engines |
| Replay-regression actually catches regressions | Injected simulation regression detected at tier-1 (bitwise) determinism | 100% detection on the reference game |
| No-lock-in is sustainable, not aspirational | New-engine onboarding cost | adding an engine = "implement adapter + pass conformance," with **zero** changes to the factory core |

## Constraints & Integration Points

- **Built BY vsdd-factory via greenfield + Phase-0 extraction** — vsdd-factory greenfields
  the new layers (methodology, protocol, adapters) and runs a Phase-0 brownfield ingestion
  of vsdd-factory's own engine-neutral core to identify and extract the reusable spine
  (see `planning/design/extraction-boundary.md`).
- **Adapter protocol = JSON-RPC 2.0 over stdio**, LSP-style lifecycle + dynamic capability
  registration (`planning/design/protocol-schema.md`).
- **Conformance is load-bearing** — hybrid stance: LSP-style negotiation + Terraform-style
  versioning/acceptance + CRI/CSI-style capability-gated conformance; the Testcontainers
  "no conformance" approach is explicitly rejected (Decision 0002).
- **Capture requires a GPU backend on every engine** — "headless = no GPU" is false; capture
  runs a separate `render` execution profile (Bevy windowless+lavapipe; Unity/Godot
  xvfb+software-GPU). Confirmed by research.
- **Determinism is opt-in and tiered** — cross-platform *bitwise* determinism only via Rapier
  (Bevy); replay-regression strictness degrades by declared `determinism_tier` (Decision 0003).
- **Engine operational constraints** — Unity requires a per-CI-agent license; Bevy's pre-1.0
  API churn requires pinned engine versions + per-release adapter maintenance.
- **Verify engine APIs against version-tagged primary docs** — AI summarizers confabulate
  fast-moving engine APIs (documented in `planning/research/bevy-capabilities.md`).

## Overflow Context (Optional — Reference Only)

**Why this is viable (market gap).** Research pass 1 confirmed no engine-agnostic
build-AND-test factory spans Unity/Godot/Unreal/Bevy as of 2026: build CI is mature but
single-engine; the deepest cross-engine test SDKs (GameDriver, AltTester) reach only two
engines; engine-agnostic testing exists only black-box (pixels/OCR). The target quadrant —
unified build + *semantic/deterministic* test/replay across engines — is empty. Full prior-art
survey: `planning/research/prior-art-and-precedents.md`.

**Founding-pair rationale (Decision 0001).** The protocol is designed against Bevy + Unity
because they are maximally dissimilar (compiled-code-first vs editor/GUI-first;
windowless-capture vs `-nographics`-conflict). Godot then interpolates (validated: it sits
between the two on 7/8 capability axes). The two-adapter rule prevents single-backend
assumptions leaking into the "neutral" protocol.

**Architecture (four layers).** (1) core orchestration engine [extracted], (2) game
methodology layer, (3) engine-adapter protocol, (4) adapters. Full detail in
`planning/design/architecture.md`. Quality-model delta vs VSDD: BCs kept for the
deterministic-sim slice; new Design Intent Contracts for feel; holdout-eval → playtest
protocol; DTU → deterministic replay harness; formal hardening applies only to the pure-sim
slice; new asset lane; reshaped convergence dimensions.

**Reuse vs build.** Reuse engine-native build runners (GameCI, godot-ci, UAT, Cargo) and
Rapier-class determinism — wrap, don't reinvent. Build the protocol, the conformance suite,
and the semantic/replay layer (especially for Godot/Bevy where no deep SDK exists).

**Research evidence base.** Per-engine capability reports + reconciliation:
`planning/research/{bevy,unity,godot}-capabilities.md`, `prior-art-and-precedents.md`,
`RECONCILIATION.md`. Decisions: `planning/decisions/000{1,2,3}.md`.

**Pilot bias.** First reference game should be a Bevy/Rapier deterministic-simulation genre
(factory/automation, roguelike, sim, deterministic RTS) — tier-1 determinism gives the
strongest replay-regression and maximum reuse of vsdd-factory's existing verification
machinery.
