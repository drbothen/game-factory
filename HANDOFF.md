# Session Handoff — game-factory

> Paste the **Handoff Prompt** below into a fresh Claude Code session opened with
> `cwd = /Users/jmagady/Dev/game-factory`. Everything after it is reference detail.

---

## ▶ Handoff Prompt (copy-paste this)

```
You are the vsdd-factory orchestrator. We are building `game-factory` — an
engine-agnostic, multi-agent factory for game development — as a PRODUCT, using
vsdd-factory's full VSDD protocol. This repo (game-factory) is the workspace; it is
the product being built. The vsdd-factory plugin is installed + enabled at operator
level (vsdd-factory@claude-mp, rc.20), so all `vsdd-factory:*` agents and skills are
available here.

Read these first, in order:
  1. .factory/specs/product-brief.md   (the VSDD entry artifact)
  2. docs/research/RECONCILIATION.md    (research synthesis driving the design)
  3. docs/decisions/0001..0003          (founding pair / conformance / determinism tier)
  4. docs/design/architecture.md, protocol-schema.md, extraction-boundary.md

Locked decisions:
  - Authoring depth = brief + research only. The pipeline crystallizes everything
    downstream (domain spec, PRD, behavioral contracts, architecture, VPs, stories).
  - Build mode = greenfield (new layers) + Phase-0 brownfield extraction of
    vsdd-factory's own engine-neutral spine (source repo at ../vsdd-factory).
  - Founding adapter pair = Bevy + Unity; Godot is the cheap third adapter.
  - Adapter protocol = JSON-RPC 2.0 over stdio (LSP-style lifecycle + dynamic
    capability registration).
  - Conformance stance = hybrid: LSP negotiation + Terraform versioning/acceptance +
    CRI/CSI capability-gated conformance suite (Testcontainers no-conformance = rejected).

Critical clarity: building game-factory is building SOFTWARE (Rust + orchestration),
so vsdd-factory's STANDARD verification model applies (formal hardening, adversarial
review, convergence). The game-dev quality model (playtest protocols, replay-
regression, design-intent contracts) is a FEATURE game-factory will contain — NOT the
method used to build game-factory itself.

Operating discipline: you are the ORCHESTRATOR. Delegate every artifact to the
correct specialist agent via the Agent tool; do NOT hand-author spec content. Enforce
every quality gate and human approval gate.

Next step: run `/vsdd-factory:validate-brief` against .factory/specs/product-brief.md,
fix any gaps/bloat, then present the brief for the human approval gate. Do NOT start
the heavier preflight + Phase 0 run until the human approves.
```

---

## Reference detail

### What game-factory is

An engine-agnostic multi-agent factory that turns an engine-neutral game spec into
production-grade game code across multiple engines (Bevy, Unity, Godot, …) via a
pluggable engine-adapter protocol. It is a **sibling of vsdd-factory** (Option C):
reuse vsdd-factory's orchestration spine, replace its verification/quality model with
a game-appropriate one. The defining property is **no engine lock-in** — the factory
core never names a specific engine; each engine is a swappable, conformance-gated
adapter.

### Current state (as of this handoff)

- **Repo:** https://github.com/drbothen/game-factory (public, default branch `main`).
- **Input package complete and committed (4 commits):**
  - `.factory/specs/product-brief.md` — VSDD entry artifact (conforms to vsdd-factory's
    product-brief template).
  - `docs/research/` — 5 docs: per-engine capability reports (Bevy/Unity/Godot),
    prior-art + protocol precedents, and `RECONCILIATION.md` (read first).
  - `docs/design/` — architecture, engine-adapter-protocol, protocol-schema v1.0 draft,
    extraction-boundary.
  - `docs/decisions/` — ADRs 0001 (founding pair), 0002 (protocol+conformance), 0003
    (determinism tier).
- **Pipeline not yet started.** No `.factory/` orphan-branch worktree set up yet; no
  preflight; no Phase 0. The brief has NOT yet been validated or approved.

### Key research conclusions (already cited, don't re-derive)

- **Market gap is real:** no engine-agnostic build-AND-test factory spans
  Unity/Godot/Unreal/Bevy as of 2026. Deepest cross-engine test SDKs reach only two
  engines; engine-agnostic testing exists only black-box (pixels/OCR). → GO.
- **Capture needs a GPU backend on every engine** ("headless = no GPU" is false). Capture
  runs a separate `render` execution profile. Bevy = windowless + lavapipe; Unity/Godot =
  xvfb + software GPU, headless flag dropped.
- **Determinism is opt-in/tiered.** Cross-platform *bitwise* determinism only via Rapier
  (Bevy). `determinism_tier` ∈ {bitwise-cross-platform, same-machine, tolerance-only};
  replay-regression strictness degrades by tier.
- **Reuse engine-native build runners** (GameCI, godot-ci, UAT, Cargo) + Rapier — wrap,
  don't reinvent. Build the protocol + conformance suite + semantic/replay layer.
- **Verify engine APIs against version-tagged primary docs** — AI summarizers confabulate
  fast-moving engine APIs (see `docs/research/bevy-capabilities.md`).

### The VSDD pipeline path (greenfield + Phase-0 extraction)

1. `validate-brief` → fix gaps/bloat → **human brief-approval gate**.
2. Pre-pipeline preflight (toolchain/LLM/MCP) + set up game-factory's `.factory/`
   worktree properly (devops-engineer / state-manager).
3. Market-intel gate — largely pre-satisfied by `docs/research/prior-art-and-precedents.md`
   (empty-quadrant GO); the agent formalizes it.
4. **Phase 0 — extraction ingestion:** brownfield-ingest vsdd-factory's own engine-neutral
   core (../vsdd-factory) to drive the extraction boundary.
5. **Phase 1 — spec crystallization:** architect / product-owner / business-analyst produce
   domain spec, PRD, behavioral contracts, architecture, VPs — using `docs/design` +
   `docs/decisions` as authoritative inputs.
6. **Phase 1d → 2 → 3 → …** adversarial spec review → story decomposition → TDD build →
   convergence.

### Plugin / environment notes

- vsdd-factory plugin: installed + enabled at operator level (`vsdd-factory@claude-mp`,
  cache has rc.18/rc.19/**rc.20**). Available in any session — no per-repo install.
- We intentionally use the **released** plugin (rc.20) to build game-factory, NOT the
  develop dev-copy in ../vsdd-factory/plugins.
- Source engine repo for Phase-0 extraction: `../vsdd-factory` (drbothen/vsdd-factory).
