# game-factory — Architecture

> Design-phase document. Engine-specific claims here are cross-referenced to
> `docs/research/` once verified. Anything tagged **[PROVISIONAL]** is from
> design reasoning / memory and awaits research confirmation.

## Why a sibling, not a fork or a mode

Three options were considered for adding game-dev capability to the VSDD ecosystem:

- **A. A "game mode" inside vsdd-factory** — ❌ pollutes VSDD's verification-driven
  invariants with a fundamentally different (feel-driven) quality philosophy, and
  destabilizes an engine that is mid-convergence-cycle.
- **B. A hard fork** — ❌ inherits the entire engine (dispatcher, 52 hook plugins,
  release pipeline) and diverges forever; ~70% of the code would be duplicated
  maintenance.
- **C. A sibling that reuses the spine** — ✅ separate the domain-neutral
  orchestration engine from the domain profile; game-factory consumes the engine
  and replaces only the quality model (~30%).

This repo implements **Option C**.

## The split that makes Option C coherent

- **Engine-neutral & game-neutral (reusable spine, ~70%):** orchestration,
  planning, story decomposition, wave scheduling, adversarial review, PR/worktree
  lifecycle, state management, the dispatcher + hook chain, the workflow runner.
- **Game-specific but engine-neutral:** vision/mechanics/systems specs, design-intent
  contracts, deterministic-sim contracts, backlog, playtest protocols, narrative,
  balance math.
- **Engine-bound:** implementation code, assets in engine format, test-harness
  wiring, build config — quarantined in the adapter layer.

A consequence worth stating: the **spec layer is engine-portable by construction**.
A design can be re-targeted to another engine even though its code/assets cannot
port. That is the deepest form of no-lock-in.

## Four layers

```
┌─────────────────────────────────────────────────────────┐
│ 1. CORE ORCHESTRATION ENGINE  (extracted from vsdd-factory)│
│    dispatcher · hooks · agent framework · state · workflows│  engine-neutral AND game-neutral
│    adversarial review · PR/worktree lifecycle              │
├─────────────────────────────────────────────────────────┤
│ 2. GAME-FACTORY METHODOLOGY LAYER                          │
│    game agents · contract schemas · convergence dims ·     │  game-specific, engine-neutral
│    playtest/replay protocols · asset lane                  │
├─────────────────────────────────────────────────────────┤
│ 3. ENGINE ADAPTER PROTOCOL  (the anti-lock-in seam)       │
│    capability manifest · command templates · result schema │  the stable contract
├─────────────────────────────────────────────────────────┤
│ 4. ADAPTERS (plugins, one per engine)                     │
│    bevy · unity · godot · unreal · web · löve ...          │  engine-bound, swappable
└─────────────────────────────────────────────────────────┘
```

Layers 1–2 talk only to Layer 3. Layer 4 is where engine knowledge lives,
quarantined and conformance-gated. See
[`engine-adapter-protocol.md`](engine-adapter-protocol.md) for Layer 3/4 detail.

## How the quality model changes vs VSDD

| VSDD concept | game-factory replacement | Why |
|---|---|---|
| Behavioral Contract (deterministic, unit-testable) | **kept** for the deterministic-sim slice (economy, damage, save format, pathfinding, netcode) | maps cleanly |
| — | **Design Intent Contract** (new) | "feel" can't be an `assert_eq!`; validated by playtest evidence + metrics |
| Formal hardening (Kani/fuzz/mutants) | applies only to the pure-sim slice | most gameplay has nothing to prove |
| Holdout evaluation | **playtest protocol** (structured, metrics-based) | "is it fun" isn't a hidden unit test |
| DTU (clone third-party services) | **deterministic replay harness** (record input → replay → diff sim state) | regression detection for games |
| 7-dim convergence | re-shaped dims (see below) | game quality has different axes |
| Demo recorder (VHS/Playwright) | **adapter `capture` backend** + ffmpeg fallback | games need gameplay capture |
| — | **asset lane** (new) | art/audio/anim are first-class story dependencies, not code |

### Convergence dimensions (game-factory) **[PROVISIONAL]**

spec · sim-tests · implementation · **playtest/feel** · **frame-budget** (not
throughput) · **asset-completeness** · visual · docs.

Each dimension is wired to **declare-and-degrade** against adapter capability
fidelity: if an adapter reports `replay: none`, the regression dimension falls
back from automated replay-diff to human playtest evidence. The core never
*assumes* a capability — it negotiates.

## The two-adapter rule

An abstraction designed against one backend leaks that backend's assumptions.
Layer 3 is therefore designed against **two dissimilar adapters simultaneously**
(Bevy + Unity) before scaling. See decision 0001.

## Sequencing

1. **Extract** the engine-neutral core from vsdd-factory (also clarifies VSDD's
   own engine/methodology boundary). Riskiest single step.
2. **Design Layer 3** against Bevy + Unity together + write the conformance suite
   + reference mini-game. Most novel net-new work.
3. **Build Layer 2** (game methodology: contract schemas, convergence dims,
   playtest/replay protocols, asset lane).
4. **Pilot** on a real Bevy/Rust deterministic-sim game (max reuse of existing
   verification machinery), Unity adapter validated against conformance in parallel.
5. **Scale adapters** — Godot next; each new engine is "implement + pass
   conformance," never a core change.
