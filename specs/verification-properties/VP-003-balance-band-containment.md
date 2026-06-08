---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-003
formal_method: proptest
priority: P0
owning_subsystem: SS-05
traces_to:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.003.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.003.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§4
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-003: Balance Band Containment

## Property Statement

For every declared balance metric (win rate, progression rate, resource accumulation rate,
damage output per second, time-to-kill), after N simulation steps starting from any valid
initial state, the metric value lies within the declared `[lo, hi]` balance band.

Formally: let `M` be the set of declared balance metrics, each with bounds `[lo_m, hi_m]`.
For all valid initial states `s_0` and all N ≤ declared_simulation_horizon:

```
∀ m ∈ M: lo_m ≤ metric_m(sim(s_0, N)) ≤ hi_m
```

## Formal Method Candidate

**proptest (property-based testing with shrinking)**

Strategy skeleton:
```rust
proptest! {
    #[test]
    fn balance_bands_hold(
        initial_state in valid_initial_state_strategy(),
        n_steps in 1usize..=SIMULATION_HORIZON,
    ) {
        let final_state = simulate(initial_state, n_steps);
        for metric in DECLARED_BALANCE_METRICS {
            let value = metric.compute(&final_state);
            prop_assert!(
                value >= metric.lo && value <= metric.hi,
                "metric {} = {} outside band [{}, {}]",
                metric.name, value, metric.lo, metric.hi
            );
        }
    }
}
```

proptest is preferred over Kani here because balance metrics involve floating-point
accumulation over many steps; proptest's shrinking finds minimal failing cases, and
the property is amenable to statistical falsification.

## Feasibility Assessment

**Feasibility: MEDIUM-HIGH.** Pure simulation: no I/O. The risk is that balance
bands may be too tight (false-positive failures due to legitimate edge cases) or
too wide (no real test value). Mitigation: balance bands are authored in the
`economy-balance-contract` by the economy-designer as first-class artifacts, not
inferred. The `balance-qa` agent is responsible for calibrating band values during
Wave 3. If a metric is not amenable to proptest (e.g., it depends on player-choice
distributions), it is delegated to playtest-protocol per BC-6.02.005.

## BC Traceability

- BC-6.02.003 (Balance Band Invariant) — this VP is the formal counterpart.
- BC-6.02.005 (Playtest Delegation Declaration) — metrics outside the pure-sim
  domain are explicitly delegated.

## Purity Classification

**Pure Core.** Balance metric computation is a pure function of simulation state.
The simulation engine is deterministic (T1 or T2 tier). Band bounds are constants
declared in `economy-balance-contract`.
