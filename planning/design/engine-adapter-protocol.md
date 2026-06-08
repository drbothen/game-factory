# Engine Adapter Protocol (Layer 3)

> **The anti-lock-in seam.** The factory core (Layers 1–2) talks only to this
> protocol; it never imports an engine SDK or references an engine by name.
>
> ✅ **Research pass 1 complete (2026-06-07).** The capability claims below are now
> reconciled against cited research — see `planning/research/RECONCILIATION.md`. Command
> strings remain illustrative sketches (verify against version-tagged engine docs at
> implementation time — AI summarizers confabulate fast-moving engine APIs; see the
> Bevy report's research-quality warning). Fidelity verdicts and the capture/
> determinism findings are research-backed.

## Design pattern & precedents

Stable protocol + pluggable backends + capability negotiation + conformance suite.
**Stance decided (Decision 0002):** a **hybrid** — LSP-style dynamic capability
negotiation + Terraform-style versioned protocol & acceptance tests through the real
adapter + **CRI/CSI-style capability-gated conformance suite** (the load-bearing
anti-drift mechanism). **Testcontainers is the rejected anti-pattern** (no
conformance works only for a homogeneous single backend). Transport favored:
JSON-RPC 2.0 (parity with LSP + Bevy's BRP).

## Capabilities (the fixed surface every adapter implements)

| Capability | What the adapter does | Output |
|---|---|---|
| `build` | headless/CI build → artifact | artifact path + status |
| `test` | run engine test framework | **normalized result schema** (below) |
| `run_headless` | launch game deterministically, no display | exit status + logs |
| `replay` | record input stream → replay → assert sim state | sim-state diff |
| `capture` | screenshot / video / frame grab | media file(s) |
| `lint` | language static analysis | normalized findings |
| `assets_validate` | import + validate asset integrity | import-error list |
| `introspect` | dump scene graph / entities / config | structured tree |

**Capabilities are independent and fidelity-graded** (`full` / `partial` /
`none`). They are NEVER bundled. (Designing against Bevy alone would have wrongly
assumed "headless ⇒ capture"; Unity's `-nographics` AND Godot's `--headless` both
break that — confirmed by research. See matrix.)

Two capability-schema fields were added after research (see Decisions 0002/0003):

- **`determinism_tier`** — `bitwise-cross-platform` (Bevy+Rapier) /
  `same-machine` (Unity PhysX) / `tolerance-only` (Godot, FP-heavy). The
  replay-regression dimension degrades by tier (exact snapshot-hash diff →
  tolerance-window metric diff). Replay also requires three prerequisites for any
  tier: fixed-timestep tick, seeded/injectable RNG, input injection at tick
  boundaries.
- **`execution_profiles`** — every adapter declares two: `headless-compute`
  (build/test/introspect/assets — true headless, cheap) and `render` (capture/
  video). Confirmed by research: capture needs a GPU backend on **all** engines
  ("headless = no GPU" is false everywhere). Bevy's render profile is
  **windowless + software Vulkan (lavapipe)**; Unity/Godot's render profile is
  **xvfb + software GPU, headless flag dropped**.

## Manifest format (declarative + escape hatch)

Mirrors vsdd-factory's `hooks-registry.toml` + WASM split: YAML manifest for the
~80% (commands), a code driver for the ~20% needing logic (parsing output,
orchestrating replay).

### Bevy adapter (sketch) **[PROVISIONAL]**

```yaml
engine: bevy
language: rust
capabilities:
  build:           { fidelity: full,    cmd: "cargo build --release" }
  test:            { fidelity: full,    cmd: "cargo nextest run --message-format json",
                     result_format: libtest-json }
  run_headless:    { fidelity: full,    cmd: "cargo run --features headless --",
                     determinism: native-fixed-timestep }
  replay:          { fidelity: full,    driver: "drivers/replay.rs" }
  capture:         { fidelity: full,    profile: render,                 # windowless, but needs lavapipe (software Vulkan)
                     method: offscreen-render-imagecopier }              # confirmed: headless+capture coexist, GPU backend required
  introspect:      { fidelity: full,    method: brp-jsonrpc }            # Bevy Remote Protocol — standout asset
  determinism_tier: bitwise-cross-platform   # with Rapier physics
  lint:            { fidelity: full,    cmd: "cargo clippy -- -D warnings" }
  assets_validate: { fidelity: partial, driver: "drivers/assets.rs" }
  introspect:      { fidelity: full,    method: ecs-world-dump }
```

### Unity adapter (sketch) **[PROVISIONAL]**

```yaml
engine: unity
language: csharp
capabilities:
  build:           { fidelity: full,    cmd: "Unity -batchmode -quit -executeMethod BuildScript.Build" }
  test:            { fidelity: full,    cmd: "Unity -batchmode -runTests -testResults {out}.xml",
                     result_format: nunit-xml }
  run_headless:    { fidelity: full,    cmd: "Unity -batchmode -nographics",
                     determinism: configured-fixed-timestep }
  replay:          { fidelity: full,    method: input-system-eventtrace,    # native (new Input System); none on legacy
                     note: "InputEventTrace/InputRecorder; legacy Input Manager = none" }
  capture:         { fidelity: partial, profile: render,                    # render profile only
                     method: rendertexture-readback,
                     conflict: "nographics → blank; render profile = xvfb + software GPU, no -nographics" }
  lint:            { fidelity: full,    cmd: "dotnet format --verify-no-changes" }
  assets_validate: { fidelity: full,    driver: "drivers/AssetImport.cs" }
  introspect:      { fidelity: partial, driver: "drivers/SceneDump.cs" }
```

## Capability matrix (research-confirmed, 2026-06-07)

| Axis | Bevy | Godot | Unity | What the protocol learns |
|---|---|---|---|---|
| Code model | compiled, code-first | scripted, scene-graph | editor-first, scene-graph | — |
| Test output | JUnit XML (nextest); libtest-JSON fallback | JUnit XML (GUT); C# XML unconfirmed | NUnit3 XML | normalization mandatory → fixed result schema (JUnit/NUnit family) |
| Capture + headless | windowless offscreen, **needs lavapipe** | **`--headless` disables ALL rendering** → xvfb+Mesa | **`-nographics` → blank** → xvfb, drop flag | `capture` ⊥ `run_headless`; capture needs a GPU backend everywhere |
| Determinism tier | **bitwise-cross-platform** (Rapier) | tolerance-only (no physics guarantee) | same-machine (PhysX) | `determinism_tier` declared, never assumed (Decision 0003) |
| Introspect | **native BRP (JSON-RPC)** | native `print_tree_pretty`, headless | editor-script DIY | `introspect` is a graded capability |
| Replay | DIY-on-ECS (`leafwing_input_playback`/crate) | DIY via `parse_input_event` | **native** (`InputEventTrace`, new Input System) | `replay` fidelity varies; needs a driver hook |
| Build | `cargo` (trivial) | `--headless --export` + template install | Editor + **license** + batchmode | reuse engine-native runners, don't reinvent |

**Godot-between-the-extremes hypothesis: HELD on 7/8 axes.** The exception is
**capture**, where Godot sits *with* Unity (headless disables rendering), not
between. On lint + introspect Godot is *better* than the between-prediction. Godot
remains the cheap third adapter for everything except capture. (Full detail:
`planning/research/godot-capabilities.md`.)

**Engine-specific operational notes:**
- **Unity:** per-CI-agent **licensing** is a real constraint (`.ulf`/Build Server/
  floating; headless activation needs xvfb). Replay is native only with the *new*
  Input System (legacy Input Manager has none).
- **Bevy:** pre-1.0 **API churn** (~quarterly breaking changes; BRP methods renamed
  in 0.17) + ecosystem-crate version lag — pin an exact version, budget per-release
  migration. Use **BRP** as the introspection/scenario-driving backbone. Pair with
  **Rapier** to claim determinism tier 1.

## Normalized result schema

Every adapter, whatever its native format, emits this shape; Layers 1–2 consume
only this:

```jsonc
{
  "suite": "sim.economy",
  "tests": [
    { "id": "...", "status": "pass|fail|skip", "duration_ms": 0,
      "message": null, "assertion": "..." }
  ],
  "totals": { "pass": 0, "fail": 0, "skip": 0 },
  "capability_fidelity": "full",   // tells the gate how much to trust the result
  "engine": "unity"
}
```

## Conformance suite (anti-rot insurance)

"Support many engines" decays the moment adapters drift. Mitigation (borrowed
from CSI/Terraform): a **reference mini-game + adapter conformance test suite**.
To be an accepted adapter you implement the protocol and pass conformance for the
capabilities you declare. New engine = implement adapter + go green on
conformance. This is the mechanism that makes "as many engines as we can"
sustainable rather than aspirational.

## Engine tiering (for adapter sequencing) — research-confirmed

- **Tier 1 (easiest, most automated gates):** Bevy (pure-Cargo build/test/lint,
  native BRP introspection, windowless capture, tier-1 determinism via Rapier —
  but pre-1.0 churn), Godot (true headless, scriptable, free, gdtoolkit lint),
  Web/Phaser/PlayCanvas (trivial capture).
- **Tier 2:** Unity (excellent CLI batchmode + UTF/NUnit3; heavier, **per-agent
  licensing**, capture needs xvfb).
- **Tier 3 (hardest headless/determinism/CLI):** Unreal — the genuine outlier,
  deferred until the protocol is proven.

> All three Tier-1/2 engines confirmed factory-viable. The two universal
> design constraints they share: (1) capture needs a GPU backend + a separate
> execution profile; (2) determinism is opt-in/DIY, with cross-platform bitwise
> determinism available only via Rapier (Bevy).
