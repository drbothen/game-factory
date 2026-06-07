# Engine Adapter Protocol (Layer 3)

> **The anti-lock-in seam.** The factory core (Layers 1–2) talks only to this
> protocol; it never imports an engine SDK or references an engine by name.
>
> ⚠️ **All engine-specific capability claims below are [PROVISIONAL]** — drawn
> from design reasoning / memory. They are being verified by the research pass in
> `docs/research/` (Bevy, Unity, Godot, prior-art). Do not treat the command
> strings or fidelity verdicts as authoritative until cross-referenced.

## Design pattern & precedents

Stable protocol + pluggable backends + capability negotiation + conformance
suite. Precedents (to be confirmed in research): **LSP**, **Terraform
providers**, **Kubernetes CRI/CSI**, **testcontainers**.

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
assumed "headless ⇒ capture"; Unity's `-nographics` breaks that — see matrix.)

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
  capture:         { fidelity: full,    cmd: "...--capture-frames",
                     method: offscreen-render }   # headless + capture COEXIST (verify)
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
  replay:          { fidelity: partial, driver: "drivers/InputReplay.cs" }
  capture:         { fidelity: partial, method: recorder-package,
                     conflict: "nographics disables render; capture needs a render target" }  # verify
  lint:            { fidelity: full,    cmd: "dotnet format --verify-no-changes" }
  assets_validate: { fidelity: full,    driver: "drivers/AssetImport.cs" }
  introspect:      { fidelity: partial, driver: "drivers/SceneDump.cs" }
```

## Capability matrix (the design-validation table) **[PROVISIONAL]**

| Axis | Bevy | Godot (planned) | Unity | What the protocol learns |
|---|---|---|---|---|
| Code model | compiled, code-first | scripted, scene-graph | editor-first, scene-graph | — |
| Test output | libtest JSON | JUnit XML (GUT) | NUnit XML | normalization is mandatory → fixed result schema |
| Headless + capture | coexist (offscreen) | partial (no render server in headless?) | conflict (`-nographics`) | `capture.fidelity` independent of `run_headless` |
| Determinism | native fixed timestep | physics tick + seeded RNG | must be configured | `determinism` is a declared property, never assumed |
| Introspect | native ECS dump | scene-tree (scriptable) | editor-script DIY | `introspect` is a capability, not a guarantee |
| Replay | clean (ECS resource) | input injection (DIY) | DIY input trace | `replay` needs a code-driver hook |

**Godot-between-the-extremes hypothesis:** Godot sits between Bevy and Unity on
every axis → cheapest third adapter. Being validated in `docs/research/`.

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

## Engine tiering (for adapter sequencing) **[PROVISIONAL]**

- **Tier 1 (easiest, most automated gates):** Bevy (reuses Rust verification),
  Godot (true headless, scriptable, free), Web/Phaser/PlayCanvas (trivial capture).
- **Tier 2:** Unity (excellent CLI batchmode + Test Framework; heavier, licensed).
- **Tier 3 (hardest headless/determinism/CLI):** Unreal — the genuine outlier,
  deferred until the protocol is proven.
