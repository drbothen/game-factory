# Research — evidence base

This directory holds the cited research that validates (or refutes) the
engine-specific capability claims in `docs/design/`. Until a claim here is
confirmed, the corresponding design assertion is tagged **[PROVISIONAL]**.

## Research pass 1 (in progress, launched 2026-06-07)

| Report | Scope | Status |
|---|---|---|
| `bevy-capabilities.md` | Bevy: build/test/headless/determinism/replay/capture/lint/assets/introspect | ⏳ running |
| `unity-capabilities.md` | Unity: same matrix; focus on `-nographics` vs capture conflict | ⏳ running |
| `godot-capabilities.md` | Godot: same matrix; "between Bevy and Unity" hypothesis | ⏳ running |
| `prior-art-and-precedents.md` | Prior art (engine-agnostic game CI/test/AI tooling); determinism-in-games; LSP/Terraform/CRI precedents | ⏳ running |

## Key questions these must answer

1. Is the **Unity `-nographics` vs capture conflict** real? (load-bearing for the
   protocol's "capability independence" design)
2. Can each engine do **deterministic headless simulation**? (underpins the
   replay-regression model)
3. Is **replay** native or DIY per engine?
4. Does the **"Godot is between Bevy and Unity"** hypothesis hold?
5. **Prior art:** is anyone already building an engine-agnostic game factory? What
   to reuse vs build?
6. Do the **LSP / Terraform / CRI** protocol precedents actually map to our design?
