# Decision 0003 — Determinism tier as a capability dimension

**Status:** Accepted
**Date:** 2026-06-07
**Driver:** `docs/research/prior-art-and-precedents.md` §2 + per-engine determinism findings + `RECONCILIATION.md` §C.1

## Context

The replay-regression model (game-factory's replacement for VSDD's DTU) depends
on deterministic re-execution: record input keyed by sim frame → replay → compare
state. Research established that **determinism is not uniform across engines** and
**not free on any of them**:

- **Bevy + Rapier:** cross-platform **bitwise** determinism (identical snapshot
  hash across OS/CPU/browser). Bevy core is non-deterministic by default (parallel
  ECS scheduling, hash iteration, FP) — determinism is earned via system ordering
  + `bevy_rand` + Rapier.
- **Unity (PhysX):** **same-machine** determinism only ("Enhanced Determinism" +
  fixed timestep + seeded RNG); NOT cross-CPU (SIMD/rounding).
- **Godot (Physics/Jolt):** fixed timestep + seeded PCG32 RNG, but **no physics
  determinism guarantee** at all.

None of the four protocol precedents (LSP/Terraform/CRI/Testcontainers) had to
model this — it is game-factory-specific.

## Decision

Add a **`determinism_tier`** field to the adapter capability schema, with three
tiers:

| Tier | Meaning | Example | Regression comparison method |
|---|---|---|---|
| `bitwise-cross-platform` | identical snapshot hash across OS/CPU | Bevy + Rapier | exact snapshot-hash diff |
| `same-machine` | reproducible on one pinned CI image only | Unity PhysX (Enhanced Determinism) | snapshot diff on pinned runner |
| `tolerance-only` | not reproducible; compare metrics within tolerance | Godot physics, FP-heavy sims | tolerance-window metric diff |

The replay-regression dimension **degrades by tier**: tier-1 adapters get exact
hash-diff regression; tier-2/3 fall back to tolerance-window comparison of
game-state metrics (positions, velocities, unit states) at given frames.

Adapters must also expose the three replay prerequisites for *any* tier:
**(a) fixed-timestep tick, (b) seeded/injectable RNG, (c) input injection at tick
boundaries.** An adapter lacking these declares `replay: none` and the regression
dimension falls back to human-playtest evidence.

## Consequences

- The conformance suite classifies and **verifies** each adapter's declared tier
  (e.g. tier-1 adapters must reproduce an identical snapshot hash across two
  different runners).
- The Bevy adapter's reference path should pair Bevy with **Rapier** to claim
  tier 1 — the strongest replay-regression guarantee available.
- Pilot-game selection bias toward tier-1-capable stacks (Bevy/Rapier
  deterministic-sim) is reinforced.

## Alternatives rejected

- **Assume uniform determinism:** false per research; would make tier-2/3
  adapters silently produce false regression failures.
- **Require tier 1 for all adapters:** would exclude Unity and Godot entirely.
