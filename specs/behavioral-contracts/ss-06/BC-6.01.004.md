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

# BC-6.01.004: AI Behavior-Tree Output Determinism

## Description

Verifies that the game AI's behavior tree (BT) produces a deterministic,
spec-declared action selection for each (world-state, entity-state, seed)
triple. The behavior tree evaluates a declared set of conditions against the
serialized world state and selects an action; this contract asserts that the
selected action matches the declared expected action for each test vector, and
that evaluation is deterministic when seeded. This applies to the pure-sim AI
evaluation slice — not to the perception/pathfinding layer (which may be
engine-bound).

## Preconditions

1. The behavior tree structure is declared in the `systems-spec`: nodes are
   composites (Sequence, Selector, Parallel), decorators, and leaf actions with
   declared input conditions and output action types.
2. The AI evaluation function is a pure function of (world_state_snapshot,
   entity_state_snapshot, seed) — no I/O, no hidden time-based state.
3. A canonical test vector table exists mapping (world_state_type,
   entity_state_type, seed) to expected_action for representative scenarios.
4. If the AI uses any stochastic selection (random action from tied candidates),
   the stochastic selection must accept a seed parameter; test vectors specify
   the seed.
5. The world-state and entity-state snapshots are subsets of the serialized sim
   snapshot (observable and diffable).
6. TDD Red Gate is active on the AI behavior tree evaluation module.

## Postconditions

1. For every test vector `(world_state, entity_state, seed) -> expected_action`,
   the behavior tree evaluator returns `expected_action`.
2. Calling the BT evaluator twice with identical inputs and seed returns an
   identical action selection — no non-determinism from hidden clocks, thread
   scheduling, or non-seeded randomness.
3. The BT evaluator never panics for any declared valid (world_state, entity_state)
   input pair, even if the BT evaluation produces an unexpected action (failure is
   an Err return, not a panic).
4. If the BT is updated, existing test vectors continue to pass (regression
   guarantee) OR new test vectors are explicitly added/modified with documented
   rationale (BC-6.03.001 replay linkage triggers re-validation).

## Invariants

1. BT evaluation is a pure function of inputs: same inputs, same output, always.
2. The declared behavior tree structure in the spec is the authoritative source of
   expected behavior — the test vectors are derived from the spec, not the code.
3. BT evaluation never produces an action type not declared in the action taxonomy
   of the `systems-spec`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | World state has multiple valid triggers, BT is a Selector — first valid child wins | Deterministic selection: leftmost (in spec declaration order) valid child's action returned |
| EC-002 | All BT branches fail conditions (no valid action) | BT returns Failure status with Idle or declared fallback action; no panic |
| EC-003 | BT evaluation with max-depth recursion (deeply nested Sequence) | Evaluation completes within declared stack depth; no stack overflow; result matches spec |
| EC-004 | Stochastic BT action selection with seed=42 | Fixed seed produces fixed selection; calling again with seed=42 produces same result |
| EC-005 | BT evaluation called on an entity in a terminal FSM state (e.g., Dead) | Returns declared terminal-state action (typically Idle or None); no evaluation error |
| EC-006 | World state snapshot is the empty state (no entities, no resources) | BT evaluates to fallback action without error; vacuous conditions in Selector produce Failure |
| EC-007 | BT with a Parallel node where branches have conflicting resource use | Parallel node outputs the highest-priority branch's action; conflict resolution is declared in spec |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| world={enemies_nearby: false}, entity={hp_pct: 1.0}, seed=0 | action=Patrol | happy-path |
| world={enemies_nearby: true, enemy_distance: 5}, entity={hp_pct: 0.8}, seed=0 | action=AttackNearest | happy-path |
| world={enemies_nearby: true, enemy_distance: 5}, entity={hp_pct: 0.1}, seed=0 | action=Flee | edge-case (low HP fallback) |
| world={}, entity={}, seed=0 | action=Idle (declared fallback) | edge-case (empty state) |
| (same inputs as first row, repeated call) | action=Patrol (identical) | determinism verification |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-007 | BT evaluation is deterministic: f(ws, es, s) called twice returns equal output | proptest (pair-call with fixed seed) |
| VP-TBD-008 | BT evaluation never produces an undeclared action type | kani (action type is an enum; exhaustive action set is bounded) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements the "AI behavior trees" sub-type of simulation behavioral contracts explicitly named in CAP-006 |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | ai-behavior-tree (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.003 — composes with (FSM state legality constrains which AI actions are valid in each entity state)
- BC-6.03.001 — depends on (replay regression must re-validate BT decisions across code changes)
- BC-7.01.001 — depended on by (sim/spec convergence dimension requires this BC to pass)

## Architecture Anchors

- `architecture/SS-05-ai-behavior-tree.md` — AI BT evaluation module (to be created by architect)

## Story Anchor

S-TBD — AI Behavior-Tree Sim Contract

## VP Anchors

- VP-TBD-007 — BT evaluation determinism
- VP-TBD-008 — no undeclared action type produced
