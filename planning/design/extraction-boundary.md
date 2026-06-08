# Extraction Boundary — what comes from vsdd-factory

How big is the Option-C lift? Three buckets.

## → MOVE to the shared core (engine- AND game-neutral; the reusable ~70%)

- dispatcher binary + hook-chain framework (`crates/`, `hooks-registry.toml` model)
- agent framework + routing-table mechanism
- state-manager + `STATE.md` model + factory-artifacts worktree pattern
- lobster workflow runner + `.lobster` schema
- worktree / PR / squash-merge lifecycle (pr-manager, devops-engineer machinery)
- adversarial-review engine, consistency-validation
- planning / brief / research / story-decomposition / wave-scheduling skills

> The core extraction is the **riskiest single step**: engine-vs-methodology
> concerns are currently interleaved inside vsdd-factory (BCs, VPs, 7-dim
> convergence are baked into agents/skills, not isolated behind an interface).
> Doing this cleanly benefits vsdd-factory too — it clarifies the engine/methodology
> boundary that is presently blurred.

## ✋ STAYS in vsdd-factory (this is the VSDD *methodology* — do NOT drag into core)

- BC / VP schemas as currently defined; the 7-dimensional convergence definition
- formal-verify (Kani / cargo-fuzz / cargo-mutants), holdout-eval, DTU
- Rust-centric `verification-toolchains.yaml` / toolchain-provisioning specifics

## 🔨 BUILD NEW — game-factory methodology layer (Layer 2; the divergent ~30%)

- contract schemas: **Design Intent Contract** (feel; playtest-validated) +
  **Sim Behavioral Contract** (deterministic; adapter `test`/`replay`-validated)
- `playtest-evaluator` agent + protocol (replaces holdout-eval)
- replay-regression model (replaces DTU)
- asset lane (art/audio/anim as first-class story dependencies + adapter
  `assets_validate`)
- game convergence dimensions, each wired to declare-and-degrade against adapter
  fidelity
- game agents: `game-designer`, `level-designer`, `technical-artist`
- demo-recorder game backend (adapter `capture` + ffmpeg fallback)

## 🆕 BUILD NEW — adapter layer (Layers 3 + 4)

- the adapter protocol + result schema + capability-negotiation logic
- the conformance suite + reference mini-game (implemented once per engine)
- the two founding adapters (Bevy, Unity), then Godot

## Scope read

- **Riskiest:** core extraction (untangling vsdd-factory).
- **Most novel net-new:** adapter protocol + conformance suite.
- **Everything else:** recombination of existing machinery.
