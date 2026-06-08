---
document_type: verification-property
level: L3
version: "1.0"
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
---

# VP-004: No-Softlock Reachability

## Property Statement

From any reachable valid game state, the declared goal state(s) remain reachable
within the declared horizon (measured in player actions). No valid execution path
leads to a state from which all goal states are permanently unreachable.

Formally: let `G` be the set of declared goal states and `R(s, H)` be the set of
states reachable from state `s` within H player actions. For all reachable states `s`:

```
R(s, H) ∩ G ≠ ∅
```

Equivalently: there is no reachable "dead" state from which the game is unwinnable.

## Formal Method Candidate

**Kani (bounded model checking)**

Proof harness skeleton:
```rust
#[kani::proof]
#[kani::unwind(HORIZON_BOUND)]
fn verify_no_softlock() {
    let state: GameState = kani::any();
    kani::assume(state.is_reachable_valid_state());
    // Assert: there EXISTS a sequence of player actions reaching a goal state
    // Kani verifies the negation: no path leads to a permanently stuck state.
    // Modeled as: if we reach a "dead" state, assert false.
    let result = explore_to_horizon(state, HORIZON_BOUND);
    assert!(!result.is_permanently_stuck());
}
```

**Feasibility caveat:** Full reachability proofs are undecidable in general. This
property is tractable only for bounded-horizon, finite-branching game graphs (det-sim
pilot: roguelike, factory/automation — small action space, bounded progression).
For open-world or high-branching games, this VP degrades to targeted softlock
scenario tests (property-based) on known high-risk progression chokepoints.

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
