---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-002
formal_method: Kani
priority: P0
owning_subsystem: SS-05
traces_to:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.003.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.003.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-002: FSM State Legality

## Property Statement

For every game state machine (ability cooldowns, character state, item state, game-phase
state), the following properties hold for all reachable execution paths:

1. **No invalid state:** The FSM never occupies a state not declared in its state set.
2. **No illegal transition:** The FSM never executes a transition not declared in its
   transition function for the current state × input pair.
3. **Transition determinism:** Given the same state and the same input event, the FSM
   always produces the same next state.

Formally: let `S` be the declared state set and `δ: S × Input → S` the transition function.
For all execution sequences, every state `s_i` satisfies `s_i ∈ S`, and every transition
`(s_i, e_i) → s_{i+1}` satisfies `δ(s_i, e_i) = s_{i+1}`.

## Formal Method Candidate

**Kani (bounded model checking)**

Proof harness skeleton:
```rust
#[kani::proof]
fn verify_fsm_state_legality() {
    let state: FsmState = kani::any();
    kani::assume(state.is_declared_state()); // start from a known valid state
    let input: FsmInput = kani::any();
    let next_state = state.transition(input);
    // Property 1: result is a declared state
    assert!(next_state.is_declared_state());
    // Property 3: determinism (same input → same result)
    let next_state_2 = state.transition(input);
    assert_eq!(next_state, next_state_2);
}
```

Transition coverage: Kani exhausts all (state, input) pairs within the bounded model.
This is tractable for FSMs with small state counts (≤32 states, ≤16 input symbols);
larger FSMs are decomposed into sub-machine lemmas.

## Feasibility Assessment

**Feasibility: HIGH.** Game ability/item/phase FSMs are well-bounded by design (the
design-spec declares the state set explicitly). The transition function is a pure
`(State, Input) → State` function with no hidden state or side effects. Kani is
well-suited to finite-state enumeration problems. The main risk is FSMs with
continuous-valued guards (timers, health thresholds); mitigation is to abstract
continuous guards into discrete predicates for the Kani model.

## BC Traceability

- BC-6.01.003 (FSM State Legality Assertion) — this VP is the formal counterpart.
- BC-6.01.004 (AI Behavior-Tree Output Determinism) — BTs with finite-state backing
  are a sub-case of this VP.

## Purity Classification

**Pure Core.** FSM transition function: `(State, Input) → State`. No I/O, no time
reads, no random number generation in the transition logic itself. Timer-based
transitions are modeled as inputs, not side effects.
