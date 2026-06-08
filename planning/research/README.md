# Research — evidence base

This directory holds the cited research that validates (or refutes) the
engine-specific capability claims in `planning/design/`. Until a claim here is
confirmed, the corresponding design assertion is tagged **[PROVISIONAL]**.

## Research pass 1 (COMPLETE, 2026-06-07)

| Report | Scope | Status |
|---|---|---|
| `bevy-capabilities.md` | Bevy: build/test/headless/determinism/replay/capture/lint/assets/introspect | ✅ done |
| `unity-capabilities.md` | Unity: same matrix; focus on `-nographics` vs capture conflict | ✅ done |
| `godot-capabilities.md` | Godot: same matrix; "between Bevy and Unity" hypothesis | ✅ done |
| `prior-art-and-precedents.md` | Prior art; determinism-in-games; LSP/Terraform/CRI precedents | ✅ done |
| `RECONCILIATION.md` | Synthesis: confirmed / refuted / newly-surfaced + design changes | ✅ done |

**Read `RECONCILIATION.md` first** — it is the synthesis that drove the design-doc
updates and Decisions 0002 (hybrid protocol + conformance) and 0003 (determinism tier).

## Pass 2 — AAA scope-expansion research (`aaa/`)

Feeds the brief/scope expansion into a "Dark Factory for AAA game development."
Each report covers one research *vector*. Builds on pass-1, does not contradict it.

| Date | Vector | Report | Status |
|---|---|---|---|
| 2026-06-07 | engineering | `aaa/engineering-disciplines.md` | draft |

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

## Answers (pass 1)

1. **Yes** — confirmed for Unity *and* Godot, sharpened with a fresh repro. Common case, not a Unity quirk.
2. **Feasible but DIY/opt-in for all three**; cross-platform *bitwise* determinism only via Rapier (Bevy). → determinism-tier dimension.
3. **Unity native** (new Input System); **Godot/Bevy DIY** on a native injection primitive.
4. **Holds 7/8 axes** — breaks on capture (Godot sits with Unity), better-than-predicted on lint + introspect.
5. **No** — the market quadrant is empty; the premise is validated. Reuse engine-native build runners + Rapier; build the protocol + conformance + semantic/replay layer.
6. **Yes, strongly** — and they're complementary. Hybrid: LSP negotiation + Terraform versioning/acceptance + CRI/CSI conformance; avoid Testcontainers' no-conformance trap.
