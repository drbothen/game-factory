---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-010
formal_method: proptest
priority: P1
owning_subsystem: SS-11
traces_to:
  - .factory/specs/behavioral-contracts/ss-13/BC-13.02.005.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-13/BC-13.02.005.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§5
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-010: Tournament Bracket Progression Correctness

## Property Statement

For each supported bracket format (single-elimination, double-elimination, Swiss,
round-robin, GSL), the following invariants hold after each round:

1. **Single-elim:** Each participant plays exactly once per round; exactly one player
   advances per match; final participant count halves each round (or padded with byes).
2. **Double-elim:** A participant is eliminated only after exactly two losses; the
   losers bracket contains exactly one fewer win than the winners bracket at each stage.
3. **Swiss:** No pair of participants plays each other more than once (no-rematch invariant).
4. **Round-robin:** Every participant plays every other participant exactly once.
5. **GSL (2-group winner/loser cross):** Correct cross-bracket seeding: winner of Group A
   plays loser of Group B, and vice versa.
6. **Match-result audit:** For all bracket formats, re-simulating the match input log
   must produce the same bracket progression outcome.

## Formal Method Candidate

**proptest (property-based testing)**

Strategy:
```rust
proptest! {
    #[test]
    fn single_elim_participant_count_halves(
        participants in vec(player_id_strategy(), 2usize..=64usize).prop_map(|mut v| {
            v.sort(); v.dedup(); v
        }),
    ) {
        let mut bracket = SingleEliminationBracket::new(participants.clone());
        let initial_count = participants.len();
        let mut count = initial_count;
        while !bracket.is_complete() {
            let round_results = play_round_randomly(&bracket);
            bracket.advance(round_results);
            let new_count = bracket.remaining_count();
            // Count must halve (approximately — with byes, floor(count/2))
            prop_assert!(new_count <= count / 2 + 1);
            count = new_count;
        }
        prop_assert_eq!(bracket.remaining_count(), 1); // one winner
    }
}
```

Similar strategies for Swiss (no-rematch), round-robin (all-pairs), double-elim
(two-loss elimination), and match-result audit (replay integrity).

## Feasibility Assessment

**Feasibility: HIGH.** Bracket algorithms are combinatorial, finite, and pure —
ideal proptest targets. The state space is small (participant ID sets, match result
booleans). The no-rematch invariant for Swiss is particularly well-suited to
property-based falsification. The match-result audit property (replay integrity)
reuses the replay spine (BC-3.03) and is verifiable against the deterministic
replay harness. Primary risk: edge cases with odd participant counts and bye
assignment logic; proptest's shrinking will find the minimal failing case.

## BC Traceability

- BC-13.02.005 (Tournament Mode Spec — Bracket Combinatorics and Match-Result Audit)
  — direct counterpart.

## Purity Classification

**Pure Core.** Bracket advancement function: `(BracketState, [MatchResult]) → BracketState`.
Pure function over a finite combinatorial structure; no I/O, no randomness in
the advancement logic itself (match outcomes are inputs).
