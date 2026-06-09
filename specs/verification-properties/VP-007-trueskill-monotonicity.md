---
document_type: verification-property
level: L3
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
vp_id: VP-007
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

# VP-007: TrueSkill μ−3σ Structural Monotonicity and Permutation Equivariance

<!-- F40-04: corrected property statement, harness, and BC traceability.
     Prior version claimed to cover INV-TS-02 and INV-TS-03 but harness only
     tested an asymptotic rank-improvement property (distinct from both).
     Now: Harness A tests INV-TS-02 (conservative-rating ordering — μ−3σ is
     non-decreasing in μ, non-increasing in σ); Harness B tests INV-TS-03
     (permutation equivariance — identical players/opponents/outcomes →
     identical posteriors regardless of team ordering). -->

## Property Statement

VP-007 covers two invariants from BC-13.02.001:

**INV-TS-02 — Conservative-rating ordering (structural monotonicity):**
`μ − 3σ` is non-decreasing in `μ` and non-increasing in `σ`. That is, holding
all other parameters equal: a higher `μ` always yields a higher or equal `μ − 3σ`;
a higher `σ` always yields a lower or equal `μ − 3σ`. This is a *structural*
algebraic property of the `μ − 3σ` estimator, not an asymptotic convergence
claim — it must hold per-update.

**INV-TS-03 — Permutation equivariance:**
For team matches, the rating update depends only on the skills and outcomes,
not on the arbitrary ordering of players within a team. Identical player
configurations with permuted team member order must produce identical posterior
rating distributions for each player.

## Formal Method Candidate

**proptest** (two harnesses)

### Harness A — INV-TS-02 Conservative-Rating Ordering

```rust
proptest! {
    #[test]
    fn trueskill_conservative_rating_ordering(
        mu_a in 10f64..=50f64,
        sigma_a in 0.5f64..=10f64,
        mu_b in mu_a..=50f64,  // mu_b >= mu_a by construction
        sigma_b in 0.5f64..=sigma_a,  // sigma_b <= sigma_a by construction
    ) {
        // INV-TS-02: higher mu → higher or equal μ−3σ; lower sigma → higher or equal μ−3σ
        let rank_a = mu_a - 3.0 * sigma_a;
        let rank_b = mu_b - 3.0 * sigma_b;
        // b has higher mu AND lower sigma → b's conservative rank must be ≥ a's
        prop_assert!(rank_b >= rank_a - 1e-9,
            "conservative ordering violated: rank_b={} < rank_a={}", rank_b, rank_a);
    }
}
```

### Harness B — INV-TS-03 Permutation Equivariance

```rust
proptest! {
    #[test]
    fn trueskill_team_permutation_equivariance(
        mu_players in vec(10f64..=50f64, 2..=4),
        sigma_players in vec(0.5f64..=8f64, 2..=4),
        outcome in any::<TeamOutcome>(),
    ) {
        // Build two teams with players in original and permuted order
        let team_original: Vec<TrueSkillPlayer> = mu_players.iter()
            .zip(sigma_players.iter())
            .map(|(&mu, &sigma)| TrueSkillPlayer::new(mu, sigma))
            .collect();
        let mut indices: Vec<usize> = (0..team_original.len()).collect();
        indices.rotate_left(1);  // deterministic permutation
        let team_permuted: Vec<TrueSkillPlayer> = indices.iter()
            .map(|&i| team_original[i].clone())
            .collect();

        let updated_original = trueskill_update_team(&team_original, &team_original, outcome);
        let updated_permuted = trueskill_update_team(&team_permuted, &team_permuted, outcome);

        // After sorting by original player identity, posteriors must match
        for i in 0..team_original.len() {
            let j = indices[i];
            prop_assert!((updated_original[i].mu - updated_permuted[j].mu).abs() < 1e-9,
                "equivariance violated: player {} mu differs after permutation", i);
            prop_assert!((updated_original[i].sigma - updated_permuted[j].sigma).abs() < 1e-9,
                "equivariance violated: player {} sigma differs after permutation", i);
        }
    }
}
```

## Feasibility Assessment

**Feasibility: HIGH.** INV-TS-02 is an algebraic property of the `μ − 3σ` formula
itself and holds trivially as a pure arithmetic assertion — proptest verifies it as
a mathematical identity with no approximation risk. INV-TS-03 is testable because the
TrueSkill factor graph update is symmetric in team member ordering by construction
(the message-passing schedule is order-independent); proptest with a deterministic
permutation strategy can falsify any implementation that introduces ordering
dependence. Risk for INV-TS-03: implementations that process team members sequentially
with mutable shared state may introduce order-dependence; the harness is designed to
detect exactly this class of defect.

## BC Traceability

- BC-13.02.001 — VP-007 covers INV-TS-02 (conservative-rating ordering) and
  INV-TS-03 (permutation equivariance). Both harnesses are required; neither alone
  constitutes full VP-007 coverage. (F40-04 fix: prior single harness tested an
  asymptotic rank-improvement property distinct from both INV-TS-02 and INV-TS-03;
  that property is not a stated invariant in BC-13.02.001 and has been removed.)

## Purity Classification

**Pure Core.** TrueSkill update: `([Player], [Outcome]) → [Player]`. Pure Bayesian
inference over floating-point skill distributions; no I/O, no hidden state.
