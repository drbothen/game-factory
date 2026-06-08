---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-005
formal_method: proptest + algebraic
priority: P1
owning_subsystem: SS-11
traces_to:
  - .factory/specs/behavioral-contracts/ss-13/BC-13.02.001.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-13/BC-13.02.001.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§5
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-005: Elo Zero-Sum Conservation

## Property Statement

For any Elo rating update over a match between players A and B, the total rating
points in the system are conserved: the rating gained by the winner equals the
rating lost by the loser.

Formally: let `Δ_A` and `Δ_B` be the rating changes for players A and B respectively
after a match. For all valid match outcomes:

```
Δ_A + Δ_B = 0
```

Equivalently: `rating_A_after + rating_B_after = rating_A_before + rating_B_before`.

## Formal Method Candidate

**Primary: proptest (property-based)**

Strategy:
```rust
proptest! {
    #[test]
    fn elo_zero_sum(
        rating_a in 0f64..=3000f64,
        rating_b in 0f64..=3000f64,
        k_factor in 1f64..=64f64,
        outcome in 0u8..=2u8, // 0=A wins, 1=B wins, 2=draw
    ) {
        let (delta_a, delta_b) = elo_update(rating_a, rating_b, k_factor, outcome);
        prop_assert!(
            (delta_a + delta_b).abs() < 1e-9,
            "zero-sum violated: delta_A={}, delta_B={}", delta_a, delta_b
        );
    }
}
```

**Secondary: algebraic proof** — The Elo update formula is:
`Δ_A = K * (S_A - E_A)`, `Δ_B = K * (S_B - E_B)`.
By construction: `S_A + S_B = 1` (match outcome totals to 1), and
`E_A + E_B = 1` (logistic expected scores sum to 1 by definition).
Therefore: `Δ_A + Δ_B = K * ((S_A + S_B) - (E_A + E_B)) = K * (1 - 1) = 0`. QED.

The algebraic proof is complete; proptest confirms the implementation matches the formula.

## Feasibility Assessment

**Feasibility: VERY HIGH.** The algebraic proof is trivial (see above). The Elo rating
update function is a pure mathematical function with no I/O, no hidden state, and
closed-form arithmetic. proptest is lightweight; the algebraic proof is the definitive
verification. Primary constraint: floating-point precision — the property holds exactly
in exact arithmetic and within epsilon in floating-point; the test asserts `abs < 1e-9`.

## BC Traceability

- BC-13.02.001 (Ranking System Contract — Pure-Function Math Invariants) — VP-005
  covers the Elo zero-sum clause of that BC.

## Purity Classification

**Pure Core (ideal VP target).** The Elo update is a pure function:
`(f64, f64, f64, Outcome) → (f64, f64)`. No I/O, no randomness, no hidden state.
RECONCILIATION §8 identifies rating-system math as "the cleanest formal-hardening
target in the entire AAA corpus."
