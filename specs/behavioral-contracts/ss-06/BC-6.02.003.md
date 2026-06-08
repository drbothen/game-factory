---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-05
capability: CAP-006
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-6.02.003: Balance Band Invariant

## Description

Verifies that the game's declared balance targets — win-rate bands, progression
curve bounds, damage/reward ratios — fall within the numerically declared
tolerance envelopes when simulated at declared scenario parameters. Balance is
machine-checkable as a statistical assertion over simulation outcomes: the
factory runs a headless simulation of N game instances across declared build
configurations and checks that outcome metrics (win rate, completion time,
resource accumulation rate) fall within declared [lower, upper] bounds.
Balance QUALITY ("is it fun?") is explicitly delegated to Playtest (BC-6.02.005).

## Preconditions

1. The `design-intent-contract` declares at least one balance band: a (metric,
   lower_bound, upper_bound, scenario, N_samples) tuple. Examples:
   - (win_rate, 0.45, 0.55, 2-player_symmetric_match, N=1000)
   - (avg_completion_time_seconds, 1800, 5400, standard_run, N=100)
   - (resource_per_minute, 5.0, 15.0, early_game_scenario, N=100)
2. A headless simulation runner exists that can execute N game instances with
   declared parameters (scenario, seed sequence, configuration) without GPU.
3. The simulation runner outputs serialized outcome metrics per run (win/loss,
   completion time, resource accumulated, etc.) to a machine-readable format.
4. The declared scenario is reproducible: the same scenario seed sequence
   produces the same outcome distribution (T1 tier: bitwise; T2: pinned-runner).
5. Balance bands are declared in the `economy-balance-contract` or
   `design-intent-contract`; absent declaration defaults to no balance check.

## Postconditions

1. For each declared balance band (metric, lower, upper, scenario, N):
   - mean(metric over N runs) is in [lower, upper], OR
   - percentile_N (declared percentile, default p50) is in [lower, upper].
   Either criterion is declared per band; both are not required simultaneously.
2. The balance simulation completes within declared timeout (default 10 minutes
   for N=1000 at T1 determinism; configurable per game complexity).
3. Out-of-band results are reported with: metric value, declared band, deviation,
   the 10 most influential seed runs, and a suggested re-balance note.
4. Balance band violations block the sim/spec convergence dimension (BC-7.01.001)
   unless explicitly accepted as a declared degradation with justification in the
   `convergence-report`.

## Invariants

1. Balance bands are statistical assertions, not per-run assertions — a single
   outlier run does not fail the band unless it shifts the aggregate metric
   outside the declared range.
2. Balance bands in the spec are the authoritative declared targets — the factory
   does NOT auto-adjust bands to fit simulation results.
3. Changes to balance parameters (damage numbers, economy flows) trigger
   re-validation of all affected balance bands.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Win rate is exactly on the boundary (e.g., 0.45 exactly = lower_bound) | PASS — boundary is inclusive |
| EC-002 | Simulation shows high variance (σ > band width) | Band violation; high-variance flag; out-of-band result reported with variance metric |
| EC-003 | One player strategy dominates (win rate >> 0.55 for one build) | Band violation; dominant-strategy flag; reported as balance defect |
| EC-004 | N=1 (single run declaration) | Mean == the single run result; band check is deterministic; PASS if in band |
| EC-005 | Balance band for a scenario with RNG (roguelike run) | RNG seeded with a declared seed sequence; simulation is reproducible; band check meaningful |
| EC-006 | Declared balance band is impossible (lower > upper) | Build-time schema validation error; band is rejected at spec-validation time |
| EC-007 | Balance band metric requires engine capture (e.g., visual score) | Metric is not eligible for sim-BC balance band; must be delegated to playtest (BC-6.02.005) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Symmetric 2-player game, N=1000, win_rate band=[0.45, 0.55] | win_rate=0.502; PASS | happy-path |
| Lopsided game, win_rate measured=0.75 against band=[0.45, 0.55] | FAIL; "win_rate 0.75 exceeds upper_bound 0.55"; balance defect reported | error |
| Roguelike avg_completion_time band=[1800s, 5400s], N=100 | mean_time=2700s; PASS | happy-path |
| Band=[0.50, 0.50] (no variance allowed), run=0.501 | FAIL; boundary exclusive behavior? — spec declares inclusive; 0.501 > 0.50 = FAIL | edge-case (tight band) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-013 | Band-check function is monotonic: widening the band can only turn FAIL into PASS, never the reverse | proptest (generate random bands and metrics; assert monotonicity) |
| VP-TBD-014 | Balance simulation with T1 determinism produces identical metrics for identical seed sequences | proptest (pair-run comparison) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements "balance bands" as named in CAP-006's design-intent contract scope |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | design-intent-verifier / balance-sim (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.001 — composes with (economy conservation is a precondition for meaningful balance bands — a non-conserving economy has undefined balance)
- BC-6.02.005 — depends on (balance band covers numerical verification; balance QUALITY is playtest-delegated)
- BC-7.01.001 — depended on by (sim/spec convergence requires this BC to pass)

## Architecture Anchors

- `architecture/SS-05-design-intent-verifier.md` — design intent and balance verification module

## Story Anchor

S-TBD — Balance Band Design Intent Contract

## VP Anchors

- VP-TBD-013 — band-check monotonicity
- VP-TBD-014 — balance simulation determinism
