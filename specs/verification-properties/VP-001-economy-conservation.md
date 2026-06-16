---
document_type: verification-property
level: L3
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-001
formal_method: Kani + proptest
priority: P0
owning_subsystem: SS-05
traces_to:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.001.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.001.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§4
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
modified:
  - version: "1.1"
    date: 2026-06-16
    reason: "F67-02 fix — corrected Kani harness assertion from state.total_resource(resource_id) (pre-op state, vacuously always equal to total_before) to state_after.total_resource(resource_id) (post-op result). Prior assertion made the P0 economy-conservation proof inert: since apply() is a pure (State,Op)→State function, asserting on the unmodified pre-op state was a tautology. Fix ensures the proof actually verifies conservation on the output state."
---

# VP-001: Economy Conservation Invariant

## Property Statement

For every economy simulation step, the total quantity of each conserved resource
class must be identical before and after the step. No economy operation may create
or destroy conserved resources outside declared faucet (source) or sink points.

Formally: let `total(R, s)` = sum of resource R across all inventories and pools
in simulation state `s`. For any conserved resource R and valid transition
`s → s'` that is NOT a declared faucet or sink:

```
total(R, s) == total(R, s')
```

For declared faucet transitions: `total(R, s') == total(R, s) + faucet_amount`.
For declared sink transitions: `total(R, s') == total(R, s) - sink_amount`.

## Formal Method Candidate

**Primary: Kani (bounded model checking)**

Kani proof harness skeleton:
```rust
#[kani::proof]
fn verify_economy_conservation() {
    let mut state: EconomyState = kani::any();
    kani::assume(state.is_valid());
    let resource_id: ResourceId = kani::any();
    kani::assume(!state.is_faucet_or_sink(resource_id));
    let total_before = state.total_resource(resource_id);
    let op: EconomyOp = kani::any();
    kani::assume(op.is_conserved_transfer());
    let state_after = state.apply(op);
    assert_eq!(state_after.total_resource(resource_id), total_before);
}
```

**Secondary: proptest (property-based testing)**

Generate random valid economy states and random valid (non-faucet/sink) operations;
assert conservation after each. Complements Kani with larger input space coverage.

## Feasibility Assessment

**Feasibility: HIGH.** Economy state is a pure data structure (resource pools, inventories,
pending transactions). No I/O, no randomness in the transition function (by definition of
a conserved economy). The transition function is a pure `(State, Op) → State` function.
Kani bounded model checking with modest bit-width (u64 resource counts) is tractable.
The primary risk is state-space explosion for complex economy graphs; mitigation is to
decompose into per-resource-class lemmas. proptest provides fast feedback during development.

## BC Traceability

- BC-6.01.001 (Economy Conservation Invariant) — this VP is the formal proof counterpart
  to the BC's machine-checkable assertion.

## Purity Classification

**Pure Core.** The economy simulation step is a deterministic, side-effect-free function.
Input: economy state snapshot. Output: new economy state snapshot. Zero I/O, zero network,
zero database reads within the transition function itself.
