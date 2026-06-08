---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-008
formal_method: Kani (harness)
priority: P0
owning_subsystem: SS-02
traces_to:
  - .factory/specs/behavioral-contracts/ss-02/BC-3.03.001.md
  - .factory/specs/behavioral-contracts/ss-02/BC-3.03.002.md
  - .factory/specs/domain-spec/invariants.md#DI-004
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-02/BC-3.03.001.md
  - .factory/specs/architecture/dtu-assessment.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§3
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-008: Replay Determinism Equality (T1 Bitwise)

## Property Statement

For a Tier-1 (T1) deterministic simulation engine, replaying the same input stream
from the same initial state must produce a bitwise-identical snapshot at every
simulation frame.

Formally: let `sim(state_0, inputs)` be the simulation function. For all valid
initial states `state_0` and all valid input streams `I`:

```
sim(state_0, I) = sim(state_0, I)
```

(two independent executions of the same function with the same inputs produce
identical output — bitwise equality, not approximate equality.)

Equivalently: the simulation function is a pure deterministic function with no
hidden state, thread scheduling dependency, or platform floating-point divergence.

## Formal Method Candidate

**Kani (model checking harness on simulation step function)**

Harness skeleton (per-step verification):
```rust
#[kani::proof]
fn verify_sim_step_determinism() {
    let state: SimState = kani::any();
    kani::assume(state.is_valid_t1_state()); // T1 = Bevy+Rapier
    let input: SimInput = kani::any();
    // Two independent applications of the same pure step function
    let state_a = sim_step(state.clone(), input.clone());
    let state_b = sim_step(state, input);
    // Bitwise equality: all fields identical
    assert_eq!(state_a, state_b);
}
```

**Constraint:** This VP applies only to the pure-sim step function (gameplay
logic, economy, FSM, AI BTs — the parts of the simulation that are pure and
isolated from engine physics). The Bevy+Rapier physics determinism guarantee
(T1 bitwise-cross-platform) is validated by the conformance suite (BC-2.02.001)
and DTU-01 (golden-state engine double), not by this Kani harness directly.

This VP covers the pure-sim Layer 2 step function; the engine integration is
covered by the conformance suite and replay harness DTU clone.

## Feasibility Assessment

**Feasibility: HIGH** for the pure-sim step function specifically. The pure-sim
layer (economy, FSM, AI BTs, ranking-system math) is exactly the purity-boundary
pure core by construction. Kani can exhaustively verify that a bounded step function
produces identical outputs for identical inputs — this is the baseline property of
any pure function and should hold trivially if the implementation is correctly
pure. Any failure of this VP indicates a purity violation (hidden state, randomness
leak, float non-determinism) that must be fixed as a P0 defect.

## BC Traceability

- BC-3.03.001 (Recording input stream keyed by sim frame) — foundational replay
  mechanism this VP validates the correctness invariant for.
- BC-3.03.002 (Replay execution returns identical sim state at T1 tier) — direct
  behavioral counterpart to this formal property.
- DI-004 (determinism tier declared, never assumed) — this VP is the proof artifact
  for T1 tier claims on pure-sim code.

## Purity Classification

**Pure Core.** The sim step function is a pure deterministic function by
architectural invariant (purity boundary is the core value proposition of the
Layer 2 / Layer 3 split). Any impurity is an architecture violation.
