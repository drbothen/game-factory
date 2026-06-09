---
document_type: verification-property
level: L3
version: "1.2"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-008
formal_method: Kani (harness)
priority: P0
owning_subsystem: SS-02
traces_to:
  - .factory/specs/behavioral-contracts/ss-03/BC-3.03.001.md
  - .factory/specs/behavioral-contracts/ss-03/BC-3.03.002.md
  - .factory/specs/domain-spec/invariants.md#DI-004
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-03/BC-3.03.001.md
  - .factory/specs/architecture/dtu-assessment.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§3
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
modified:
  - version: "1.1"
    date: 2026-06-08
    reason: "F36-01 fix — corrected ss-02/ → ss-03/ in traces_to (lines 14, 15) and inputs (line 19); BC-3.03.* files reside in ss-03/ (CAP-003 directory), not ss-02/ (CAP-002 directory). Aligns with VP-INDEX.md authoritative citation."
  - version: "1.2"
    date: 2026-06-08
    reason: "F37-03 fix — retitled and reframed to accurately state what this Kani harness proves (intra-process purity / referential transparency of the pure-sim step function), explicitly distinguishing this from the T1 bitwise CROSS-PLATFORM equality guarantee which is validated by the conformance suite (BC-3.03.003), not by this harness."
---

# VP-008: Pure-Sim Step Referential Transparency (Intra-Process Purity)

## Property Statement

The pure-sim step function is referentially transparent: calling `sim_step` twice
with identical inputs in the same process produces bitwise-identical outputs. This
is the intra-process purity property — it proves the absence of hidden mutable state,
uncontrolled randomness, or timing dependencies inside the pure-sim layer.

Formally: for all valid states `s` and inputs `i` (evaluated within a single process
and platform):

```
sim_step(s, i) == sim_step(s, i)
```

(two independent calls with identical arguments produce identical output.)

**Scope boundary (important):** This Kani harness proves INTRA-PROCESS referential
transparency only. It does NOT prove the T1 bitwise cross-platform equality guarantee
(identical results on x86-64 vs arm64 vs Windows) — that guarantee is validated by
the conformance suite via BC-3.03.003 (T1 exact snapshot-hash comparison on any OS/CPU).
The cross-platform T1 guarantee depends on engine-level determinism (Bevy+Rapier physics
canonical serialization, compiler codegen stability) that cannot be model-checked by
Kani in a single-platform harness.

## Formal Method Candidate

**Kani (model checking harness on simulation step function)**

Harness skeleton (per-step verification):
```rust
#[kani::proof]
fn verify_sim_step_determinism() {
    let state: SimState = kani::any();
    kani::assume(state.is_valid_t1_state()); // T1 = Bevy+Rapier pure-sim layer
    let input: SimInput = kani::any();
    // Two independent applications of the same pure step function (intra-process)
    let state_a = sim_step(state.clone(), input.clone());
    let state_b = sim_step(state, input);
    // Intra-process referential transparency: identical inputs → identical output
    assert_eq!(state_a, state_b);
}
```

**Constraint:** This VP applies only to the pure-sim step function (gameplay
logic, economy, FSM, AI BTs — the parts of the simulation that are pure and
isolated from engine physics). The T1 bitwise cross-platform equality guarantee
(identical hashes on Linux x86-64, macOS arm64, and Windows x86-64) is validated
by the conformance suite (BC-3.03.003) and DTU-01 (golden-state engine double),
NOT by this Kani harness. A reader should not conclude from VP-008 that the T1
cross-platform bitwise invariant is formally proven — it is validated by conformance
testing, not by this intra-process model-checking harness.

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
  mechanism; this VP validates the intra-process purity of the sim step function
  that the recording pipeline depends on.
- BC-3.03.002 (Replay execution returns identical sim state at T1 tier) — direct
  behavioral counterpart to the intra-process purity property.
- BC-3.03.003 (T1 exact snapshot-hash comparison, bitwise cross-platform) — the
  cross-platform T1 guarantee is validated HERE by the conformance suite, not by
  this VP. BC-3.03.003 EC-004 is the edge case that specifically tests cross-platform
  identical results; VP-008 does not cover that guarantee.
- DI-004 (determinism tier declared, never assumed) — this VP is the proof artifact
  for intra-process purity of T1 pure-sim code; the cross-platform tier claim is
  covered by the conformance suite.

## Purity Classification

**Pure Core.** The sim step function is a pure deterministic function by
architectural invariant (purity boundary is the core value proposition of the
Layer 2 / Layer 3 split). Any impurity is an architecture violation.
