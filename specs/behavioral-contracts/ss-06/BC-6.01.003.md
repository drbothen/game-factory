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
subsystem: SS-TBD
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

# BC-6.01.003: FSM State Legality Assertion

## Description

Verifies that the game's finite state machine (FSM) — covering entity lifecycle,
ability states, game-phase transitions, and any declared FSM in the system spec
— never enters an illegal state and never makes an illegal transition. A state is
illegal if it is not declared in the `systems-spec` or `design-spec` FSM
definition. A transition is illegal if it is not declared as a valid transition
from the current state given the input event. This contract applies to all FSMs
in the pure-sim slice (entity FSMs, ability FSMs, game-phase FSM); it does NOT
apply to engine-side animation state machines.

## Preconditions

1. The FSM is declared in the `systems-spec` or `design-spec` as an explicit
   state transition table: `(current_state, input_event) -> next_state` with
   a declared set of valid states and valid transitions.
2. The FSM implementation is in the pure-sim slice (no engine I/O, no rendering).
3. The FSM state is part of the serialized simulation snapshot — every FSM state
   transition is observable in the snapshot diff.
4. An exhaustive list of declared valid states exists in the spec at BC authoring
   time. New states added to the implementation must be added to the spec first
   (Red Gate applies).
5. TDD Red Gate is active on the FSM module (strict mode).

## Postconditions

1. At every simulated frame, every FSM instance is in a state that appears in
   the declared valid-states set. No FSM instance is ever in an undeclared state.
2. Every FSM transition executed during the test run corresponds to a declared
   valid transition in the spec. An undeclared transition attempt produces a
   machine-detectable error (assertion failure, panic, or error return) — NOT
   a silent invalid transition.
3. The test suite includes at least one test for each declared transition in the
   FSM (transition coverage ≥ 100% of declared transitions).
4. The test suite includes at least one test for each declared invalid transition
   attempt — verifying that it is rejected (EC-004).
5. FSM state at the start of each replay frame matches the FSM state in the
   golden snapshot (wired to BC-6.03.001 replay linkage).

## Invariants

1. The current_state of every FSM instance is always a member of the declared
   valid-state set. This invariant is checked on every state transition, not just
   at test boundaries.
2. Transitions are deterministic: given (current_state, input_event), the next_state
   is uniquely determined by the declaration (no hidden branching based on
   undeclared context).
3. FSM declarations in the spec are the authoritative source of truth — implementation
   cannot introduce new states without a corresponding spec update.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | FSM receives an input event that is valid in a DIFFERENT state but not the current state | Transition rejected; current state unchanged; machine-detectable error returned |
| EC-002 | FSM receives an input event not listed in the transitions table at all | Transition rejected; current state unchanged; machine-detectable error with event ID logged |
| EC-003 | Multiple FSM instances receive conflicting input events in the same frame | Each FSM instance transitions independently; no cross-contamination between instances |
| EC-004 | Attempt to force FSM into an undeclared state via direct state mutation | State mutation bypassing the transition function is rejected by the type system or panics; FSM state is a sealed type |
| EC-005 | FSM with a single state (trivially valid — no transitions possible) | Zero transition tests; FSM vacuously passes; the single state is the only valid state |
| EC-006 | Terminal state (no outgoing transitions) receives an input event | Input event is rejected; state unchanged; terminal-state-rejection is a declared behavior in the spec |
| EC-007 | Cyclic FSM transitions (A → B → A) exercised in proptest | No infinite loop; prop test terminates after declared max-depth; cycle is a valid structural property |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Entity FSM in Idle, receives AttackInput | Transition to Attacking; postconditions met | happy-path |
| Entity FSM in Attacking, receives AttackInput (already attacking) | Transition rejected; stays in Attacking; error returned | edge-case |
| Entity FSM in Dying (terminal), receives AttackInput | Input rejected; stays in Dying; terminal-state-rejection behavior verified | edge-case (terminal) |
| Game-phase FSM: MainMenu → Playing → Paused → Playing → GameOver | All transitions valid per declaration; each state in valid-state set | happy-path |
| Ability FSM with undeclared event "SomeRandomEvent" | Error returned; state unchanged | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-005 | Every reachable FSM state is in the declared valid-state set | kani (reachability on bounded FSM depth) |
| VP-TBD-006 | No undeclared transition ever succeeds — all undeclared (state, event) pairs return Err | kani (exhaustive over declared state × event space) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements the "FSM" sub-type of simulation behavioral contracts explicitly named in CAP-006 as "ability/FSM state legality" |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | entity-fsm (SS-TBD; assigned by architect) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.002 — composes with (death-state transition is triggered when damage reduces HP to 0, linking FSM and damage)
- BC-6.02.004 — composes with (no-softlock depends on FSM not having unreachable terminal states)
- BC-6.03.001 — depends on (replay regression re-validates FSM state sequence across code changes)
- BC-7.01.001 — depended on by (sim/spec dim requires this BC to pass)

## Architecture Anchors

- `architecture/SS-TBD-entity-fsm.md` — entity FSM module (to be created by architect)

## Story Anchor

S-TBD — FSM Legality Sim Contract

## VP Anchors

- VP-TBD-005 — every reachable FSM state is declared valid
- VP-TBD-006 — no undeclared transition ever succeeds
