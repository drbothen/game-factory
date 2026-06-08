---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-006
formal_method: proptest
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

# VP-006: Glicko-2 RD Monotone Decay

## Property Statement

In Glicko-2, a player's Rating Deviation (RD) must be non-decreasing over inactive
rating periods (no games played) and must decrease after each game played. Specifically:

1. **Inactive period RD increase:** `RD'(inactive) ≥ RD` (uncertainty grows with inactivity).
2. **Active period RD decrease (after sufficient games):** After playing one or more
   rated games in a period, `RD' ≤ RD_inactive` (uncertainty reduced by evidence).
3. **RD floor:** `RD ≥ RD_min` at all times (declared minimum confidence bound).
4. **RD ceiling:** `RD ≤ RD_max` at all times (declared maximum uncertainty cap).

**Implementation note:** The RECONCILIATION document mandates the corrected Glicko-2
Step-5 formula (2012-02-22 correction). This VP must be verified against the corrected
formula; the pre-2012 formula has a known sign error in Step 5 that produces incorrect
RD updates. Any implementation using the pre-correction formula fails this VP.

## Formal Method Candidate

**proptest**

Strategy:
```rust
proptest! {
    #[test]
    fn glicko2_rd_decay_on_activity(
        rating in -3f64..=3f64,          // Glicko-2 scale (μ)
        rd in RD_MIN..=RD_MAX,           // current RD (φ)
        volatility in 0.01f64..=0.2f64,  // σ
        game_results in vec(game_result_strategy(), 1..=20),
    ) {
        let rd_inactive = glicko2_inactive_period_rd(rd, volatility);
        let (_, rd_new, _) = glicko2_update(rating, rd_inactive, volatility, &game_results);
        // After games: RD must decrease from inactive level
        prop_assert!(rd_new <= rd_inactive + 1e-9);
        // RD floor and ceiling
        prop_assert!(rd_new >= RD_MIN);
        prop_assert!(rd_new <= RD_MAX);
    }
}
```

## Feasibility Assessment

**Feasibility: HIGH.** Glicko-2 is a pure function over floating-point scalars with
well-defined algebraic bounds. The corrected formula is documented. The primary risk
is floating-point precision at boundary conditions (RD near RD_min). proptest with
epsilon tolerances handles this cleanly. The RD ceiling case is trivially verifiable.
The RD floor case requires that RD_min is declared in the `ranking-system-contract`
as a parameter, not hardcoded.

## BC Traceability

- BC-13.02.001 — VP-006 covers the "RD monotone decay and bounds" clause.

## Purity Classification

**Pure Core.** Glicko-2 update: `(μ, φ, σ, [GameResult]) → (μ', φ', σ')`.
Pure function, no I/O, no hidden state.
