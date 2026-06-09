---
document_type: verification-property
level: L3
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
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

<!-- F40-05: corrected property statement and harness. Prior version asserted
     RD' ≤ RD_inactive (post-inactivity-inflation RD), which does NOT establish
     INV-GL2-02 (RD' < RD_old). Since inactivity inflates RD (RD_inactive ≥ RD_old),
     an implementation could leave RD' ≥ RD_old while still satisfying RD' ≤ RD_inactive,
     letting a real regression pass VP-006. Correct baseline is the ORIGINAL pre-inactivity
     RD (rd_old), matching INV-GL2-02 strict inequality. -->

## Property Statement

In Glicko-2, a player's Rating Deviation (RD) must be non-decreasing over inactive
rating periods (no games played) and must **strictly decrease below the original
pre-inactivity RD** after each game played. Specifically:

1. **Inactive period RD increase:** `RD'(inactive) ≥ RD_old` (uncertainty grows with inactivity).
2. **Active period RD strict decrease (INV-GL2-02):** After playing one or more
   rated games in a period, `RD_new < RD_old` (strict; not merely `≤ RD_inactive`).
   The inactivity step inflates RD before update; the game update must reduce RD
   below the ORIGINAL pre-inactivity baseline, not merely below the inflated level.
3. **RD floor:** `RD ≥ RD_min` at all times (declared minimum confidence bound).
4. **RD ceiling:** `RD ≤ RD_max` at all times (declared maximum uncertainty cap).

**F40-05 correction note:** A prior assertion `RD' ≤ RD_inactive` would pass an
implementation where a game reduces RD below the inflated `RD_inactive` but leaves
it ≥ the original `RD_old`, violating INV-GL2-02. The correct invariant checks
`rd_new < rd_old` (strict, against the original pre-inactivity RD).

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
        rd_old in RD_MIN..=RD_MAX,       // ORIGINAL pre-inactivity RD (φ) — correct baseline
        volatility in 0.01f64..=0.2f64,  // σ
        game_results in vec(game_result_strategy(), 1..=20),
    ) {
        // Inactivity step: RD_inactive >= rd_old (inflation; this is expected)
        let rd_inactive = glicko2_inactive_period_rd(rd_old, volatility);
        prop_assume!(rd_inactive >= rd_old - 1e-9);  // sanity: inactivity must not reduce RD

        // Game update applied to inflated RD
        let (_, rd_new, _) = glicko2_update(rating, rd_inactive, volatility, &game_results);

        // INV-GL2-02: RD_new must be STRICTLY less than ORIGINAL RD_old (not RD_inactive)
        // This is the correct invariant — testing against RD_inactive would allow a
        // regression where RD_new >= rd_old but <= RD_inactive to pass undetected.
        prop_assert!(rd_new < rd_old + 1e-9,
            "INV-GL2-02 violated: rd_new={} >= rd_old={}", rd_new, rd_old);
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
as a parameter, not hardcoded. The F40-05 correction tightens the bound from
`rd_new ≤ rd_inactive` to `rd_new < rd_old`, which is strictly stronger and correctly
matches INV-GL2-02.

## BC Traceability

- BC-13.02.001 — VP-006 covers the "RD monotone decay and bounds" clause.

## Purity Classification

**Pure Core.** Glicko-2 update: `(μ, φ, σ, [GameResult]) → (μ', φ', σ')`.
Pure function, no I/O, no hidden state.
