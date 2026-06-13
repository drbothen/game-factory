---
document_type: verification-property
level: L3
version: "1.2"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-004
formal_method: Kani (bounded)
priority: P0
owning_subsystem: SS-05
traces_to:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.004.md
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.002.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.004.md
  - .factory/specs/behavioral-contracts/ss-06/BC-6.02.002.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
modified:
  - version: "1.1"
    date: 2026-06-08
    reason: "F37-06 fix — added explicit soundness conditionality note in the harness section: the proof result is conditional on the fidelity of is_reachable_valid_state() as a characterization of true reachability, with the proptest fallback covering the gap."
  - version: "1.2"
    date: 2026-06-13
    reason: "F60-02 fix — corrected property statement to match BC-6.02.004 / BC-6.02.004/VP-TBD-015: the reachability target is the TERMINAL set (win-condition states ∪ declared game-over states), not win states alone. A softlock is a reachable non-terminal state with no path to ANY declared terminal. The prior over-strong 'G = win states only' formalization would flag valid loss-path designs (EC-001 PASS) as violations."
---

# VP-004: No-Softlock Reachability

## Property Statement

From any reachable non-terminal game state, at least one declared terminal state
remains reachable within the declared horizon (measured in player actions). No valid
execution path leads to a non-terminal state from which ALL declared terminals are
permanently unreachable.

A **terminal state** is any member of the declared terminal set `T = W ∪ GO`, where:
- `W` = declared win-condition states (the player achieves the declared goal)
- `GO` = declared game-over states (explicit failure terminals that end the game)

A **softlock** is a reachable non-terminal state `s ∉ T` such that `R(s, H) ∩ T = ∅`.

Formally: let `T = W ∪ GO` be the declared terminal set and `R(s, H)` be the set
of states reachable from state `s` within H player actions. For all reachable
non-terminal states `s ∉ T`:

```
R(s, H) ∩ T ≠ ∅
```

Equivalently: every reachable non-terminal state has a forward path to at least one
declared terminal (win OR game-over). A dead-end state whose only exit is a declared
game-over terminal is NOT a softlock (matches BC-6.02.004 EC-001 PASS); only a state
with NO path to ANY declared terminal (neither win nor game-over) is a softlock.

## Formal Method Candidate

**Kani (bounded model checking)**

Proof harness skeleton:
```rust
#[kani::proof]
#[kani::unwind(HORIZON_BOUND)]
fn verify_no_softlock() {
    let state: GameState = kani::any();
    kani::assume(state.is_reachable_valid_state());
    // Exclude terminal states from the softlock check (win OR game-over states
    // are declared terminals; softlock is undefined for terminal states).
    kani::assume(!state.is_terminal());  // T = W ∪ GO
    // Assert: there EXISTS a sequence of player actions reaching any declared
    // terminal (win-condition OR game-over state).
    // Kani verifies the negation: no path leads to a permanently stuck state
    // with no exit to any declared terminal.
    let result = explore_to_horizon(state, HORIZON_BOUND);
    assert!(!result.is_permanently_stuck());
    // Note: result.is_permanently_stuck() returns true only when the state has
    // no reachable terminal in T = W ∪ GO within HORIZON_BOUND. A state that
    // can only reach a game-over (loss) terminal returns false — NOT a softlock.
}
```

**Feasibility caveat:** Full reachability proofs are undecidable in general. This
property is tractable only for bounded-horizon, finite-branching game graphs (det-sim
pilot: roguelike, factory/automation — small action space, bounded progression).
For open-world or high-branching games, this VP degrades to targeted softlock
scenario tests (property-based) on known high-risk progression chokepoints.

**Soundness conditionality (F37-06):** The soundness of this proof result is conditional
on the fidelity of `is_reachable_valid_state()` as a characterization of true reachability:
an over-approximation (accepting unreachable states) risks spurious counterexamples on
states the game never actually reaches; an under-approximation (rejecting reachable states)
proves a weaker property than intended. The proptest fallback (generate random game states,
verify goal reachability from each) provides complementary coverage over concrete reachable
states and partially compensates for any predicate imprecision.

## Feasibility Assessment

**Feasibility: MEDIUM.** Tractable for the det-sim pilot genre (roguelike, management
sim) with small state graphs and bounded action sequences. Kani's bounded unwind
setting must be calibrated against the game's actual progression horizon. For games
with large state graphs, the property becomes a high-priority proptest target (generate
random game states; verify goal reachability from each). The formal proof is the P0
target for the pilot; the proptest fallback is acceptable for P1 genres.

## BC Traceability

- BC-6.02.004 (No-Softlock Invariant) — direct counterpart.
- BC-6.02.002 (Game Solvability Contract) — broader solvability; this VP covers the
  reachability sub-property.

## Purity Classification

**Pure Core.** The game state graph and action function are deterministic (T1/T2 tier
required). Goal state membership is a pure predicate. Horizon-bounded exploration is
a pure tree traversal.
