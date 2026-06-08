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
priority: P0
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

# BC-6.01.002: Damage I/O Matrix Correctness

## Description

Verifies that the game's damage system produces correct HP-delta outputs for all
declared attacker/defender/modifier combinations. For each row in the declared
damage I/O matrix (attacker type × defender type × modifiers → expected HP delta
and clamped result), the simulation must produce exactly the declared output.
This contract covers the pure-function core of the damage calculation: it
explicitly excludes rendering, animation, and hit-detection (which are engine-bound
and not part of the pure-sim slice).

## Preconditions

1. A `simulation-bc` has been authored declaring the damage I/O matrix: for each
   `(attacker_type, defender_type, modifier_set, base_damage)` tuple, the
   expected `hp_delta` and clamped HP value are declared.
2. The damage calculation function is a pure function: given the same inputs, it
   always returns the same output, with no I/O, no global mutable state, and no
   random draws except from an explicitly-seeded RNG.
3. If randomized damage (crit/miss) is used, the RNG must accept a seed parameter;
   the I/O matrix test vectors specify both the seed and expected output.
4. The sim-code path for damage calculation is identifiable as a distinct module
   or crate boundary (enabling Red Gate and formal verification targeting).
5. TDD Red Gate is active on the damage-calc module (strict mode).

## Postconditions

1. For every row `(attacker_type, defender_type, modifier_set, base_damage, seed)` in
   the I/O matrix, the simulation produces `hp_delta` equal to the declared expected
   value (exact integer equality for deterministic damage; within declared ε for
   probabilistic damage with stated seed).
2. HP values are clamped to `[0, max_hp]` — damage cannot produce negative HP or HP
   exceeding the maximum. Any computation that would exceed bounds is clamped, not wrapped.
3. A test exists for each row in the declared I/O matrix. If no I/O matrix has been
   declared, the build fails with a schema validation error (DI-012: every contract
   requires a declared validation method).
4. If a modifier combination is missing from the I/O matrix but the game code accepts
   it as a valid combination, a build-time warning is emitted and the gap is logged
   as a coverage defect.

## Invariants

1. The pure damage function is deterministic given the same seed: calling it twice with
   identical inputs returns identical outputs.
2. HP cannot go below 0 or above declared max_hp as a result of damage application.
3. The test vectors are the authoritative source of expected values — they are not
   derived from the implementation (to prevent tautological tests).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Attacker with +50% damage modifier vs defender with -50% damage resistance | Modifiers compose multiplicatively per declared formula; result matches I/O matrix entry |
| EC-002 | Damage exactly equals current HP (killing blow) | hp_delta = current_hp; result HP = 0; death-state transition triggered (if FSM is in scope of this BC) |
| EC-003 | Overkill damage (damage > current HP) | hp_delta = current_hp (clamped); result HP = 0; excess damage does NOT propagate unless declared |
| EC-004 | Zero damage after all reductions applied (fully resisted) | hp_delta = 0; HP unchanged; no death-state transition |
| EC-005 | Healing expressed as negative damage | If healing is declared as negative damage in the I/O matrix, postcondition applies with reversed sign; HP clamped to max_hp |
| EC-006 | I/O matrix row with seed = null (non-random damage) | Pure deterministic calculation; no RNG involved; exact equality test |
| EC-007 | Attacker/defender type combination not declared in I/O matrix | Returns declared default formula result; emits coverage-gap warning; does NOT panic in production |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| attacker=Sword(base=10), defender=Unarmored, mods=[], seed=null | hp_delta=10; result_hp=max_hp-10 | happy-path |
| attacker=Sword(base=10), defender=HeavyArmor(resist=0.5), mods=[], seed=null | hp_delta=5; result_hp=max_hp-5 | happy-path |
| attacker=Crit(base=10, crit_mult=2.0), defender=Unarmored, mods=[], seed=42 | hp_delta=20 (crit triggered at seed=42); result_hp=max_hp-20 | property-based |
| attacker=Sword(base=100), defender=Unarmored(hp=30), mods=[], seed=null | hp_delta=30 (clamped); result_hp=0 | edge-case (overkill) |
| attacker=Sword(base=10), defender=FullResist(resist=1.0), mods=[], seed=null | hp_delta=0; result_hp=max_hp | edge-case (full resist) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-003 | hp_delta is always in [0, current_hp] for damage (no negative hp, no over-kill propagation) | kani (bounded model check on the pure damage function) |
| VP-TBD-004 | Damage function is deterministic given seed: f(inputs, seed) called twice returns identical hp_delta | proptest (pair-call test with fixed seed) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements the "damage I/O matrices" sub-type of simulation behavioral contracts explicitly named in CAP-006 |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | combat-sim (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.001 — related to (economy conservation uses same sim-BC pattern; damage is a resource-consumption operation)
- BC-6.01.003 — composes with (FSM legality governs state transitions triggered by death/damage thresholds)
- BC-6.03.001 — depends on (replay regression re-validates this contract across code changes)
- BC-7.01.001 — depended on by (sim/spec dim requires this BC to pass)

## Architecture Anchors

- `architecture/SS-05-combat-sim.md` — combat simulation module (to be created by architect)

## Story Anchor

S-TBD — Damage I/O Sim Contract

## VP Anchors

- VP-TBD-003 — hp_delta clamping invariant
- VP-TBD-004 — damage function determinism
