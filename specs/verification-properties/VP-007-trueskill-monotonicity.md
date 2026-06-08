---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
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

# VP-007: TrueSkill μ−3σ Partial-Order Monotonicity

## Property Statement

TrueSkill's conservative skill estimate `μ − 3σ` (the displayed rank) must be
monotonically consistent with match outcomes: a player who wins against a stronger
opponent (higher `μ`) must receive a positive update to `μ − 3σ` over time.

More precisely, the **partial-order invariant**: if player A consistently beats
player B over a sequence of matches, then after sufficient rating updates:
`μ_A − 3σ_A > μ_B − 3σ_B`.

Additionally, the **permutation-equivariance invariant** must hold for team matches:
the rating update depends only on the skills and outcomes, not on the arbitrary
ordering of players within a team.

## Formal Method Candidate

**proptest**

Strategy:
```rust
proptest! {
    #[test]
    fn trueskill_winner_rank_improves(
        mu_a in 10f64..=50f64,
        sigma_a in 0.5f64..=10f64,
        mu_b in 10f64..=50f64,
        sigma_b in 0.5f64..=10f64,
        n_matches in 5usize..=20usize,
    ) {
        // A wins all matches against B
        let mut a = TrueSkillPlayer::new(mu_a, sigma_a);
        let mut b = TrueSkillPlayer::new(mu_b, sigma_b);
        for _ in 0..n_matches {
            trueskill_update_1v1(&mut a, &mut b, Outcome::AWins);
        }
        let rank_a_final = a.mu - 3.0 * a.sigma;
        // A's rank must improve relative to initial
        let rank_a_initial = mu_a - 3.0 * sigma_a;
        prop_assert!(rank_a_final > rank_a_initial,
            "rank did not improve: {} <= {}", rank_a_final, rank_a_initial);
    }
}
```

## Feasibility Assessment

**Feasibility: HIGH.** TrueSkill is a Bayesian inference model; the μ−3σ partial-order
property is a well-documented design goal of the system. proptest falsification is
appropriate because the property holds asymptotically (after sufficient matches), not
per-match. The permutation-equivariance property is testable with fixed team-size
permutation strategies. Risk: if the implementation uses approximations to the
TrueSkill factor graph (common in open-source implementations), the approximation
error may require relaxed bounds on the monotonicity assertion.

## BC Traceability

- BC-13.02.001 — VP-007 covers the "μ−3σ ordering" and "permutation-equivariance"
  clauses.

## Purity Classification

**Pure Core.** TrueSkill update: `([Player], [Outcome]) → [Player]`. Pure Bayesian
inference over floating-point skill distributions; no I/O, no hidden state.
