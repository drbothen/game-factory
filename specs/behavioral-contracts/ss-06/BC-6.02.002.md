---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-006
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-6.02.002: Game Solvability Contract

## Description

Verifies that the game is solvable — that at least one valid path exists from
the initial game state to each declared win-condition state, using only actions
declared valid in the `design-intent-contract`. Solvability is the special case
of reachability (BC-6.02.001) applied to win-states. A game that is structurally
unsolvable is a critical design defect detectable before any human plays it.
This contract explicitly does NOT cover difficulty of solvability or player
skill requirement (playtest-delegated per BC-6.02.005).

## Preconditions

1. The `design-intent-contract` declares at least one win-condition state (the
   terminal success state(s) for the game or for a declared game segment).
2. The state graph representation used by BC-6.02.001 is available and includes
   win-condition states as declared graph nodes.
3. Win-condition states are declared as accepting/terminal nodes in the state
   graph; the graph query can identify them.
4. The game mechanics defining "what counts as a valid action" are encoded in
   the transitions of the state graph, not in engine-side code.
5. For procedurally-generated content (roguelikes, PCG levels), the solvability
   contract must be satisfied for: (a) each explicitly seeded reference run, and
   (b) a statistical sample of N randomly-seeded runs (N declared in the contract).

## Postconditions

1. For each declared win-condition state W, BFS/DFS from the initial state reaches
   W via a path that uses only declared valid transitions.
2. If the game has multiple win-condition states (multiple endings), each one is
   independently reachable.
3. For procedurally-generated levels: the fraction of seeded runs that produce a
   solvable level is ≥ declared_solvability_rate (e.g., 99.9%). Runs below the
   rate are reported as seed-specific defects.
4. The solvability check completes within declared timeout. If timeout exceeded,
   the test reports TIMEOUT (not PASS).

## Invariants

1. A win-condition state that is unreachable from the initial state is ALWAYS a
   defect — there is no degradation path for unsolvability.
2. For PCG levels: the declared solvability_rate is a hard minimum, not a target.
   Shipping a game with solvability_rate below declared value is a release blocker.
3. This contract does not verify that the game can be solved by a player of
   specific skill — only that the rules of the game do not structurally prevent
   reaching the win condition.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Win condition reachable only via a specific non-obvious sequence | Reachable via graph traversal; path logged in test output; PASS |
| EC-002 | Win condition requires resource X which only appears in certain branches | If there exists ANY branch where X is obtainable and the win condition is reachable, PASS |
| EC-003 | PCG roguelike level with seed=42 generates unsolvable floor | Seed=42 reported as solvability defect; other seeds may pass; aggregate rate tracked |
| EC-004 | Game with no declared win condition | Build-time error: `design-intent-contract` requires at least one win-condition declaration |
| EC-005 | Solvability path requires a specific random outcome (e.g., specific die roll) | If the random outcome is seeded and the winning path is accessible on at least one seed, the win condition is solvable; the contract declares a specific seed that demonstrates solvability |
| EC-006 | Win condition behind a paid DLC gate that is not activated | DLC content is a separate solvability context; base-game win condition must be solvable without DLC |
| EC-007 | Multiple win conditions, one is unreachable | FAIL with the unreachable win-condition ID; other win conditions' reachability is still reported |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Linear 5-state game, win condition at state 5 | Reachable via path [0→1→2→3→4→5]; PASS | happy-path |
| Branching game with 3 endings, all reachable | All 3 win states reachable; PASS | happy-path |
| Roguelike level seed=42, verified solvable | BFS finds solution path; PASS; path logged | edge-case (PCG) |
| Roguelike: 1000 random seeds, 999 solvable (99.9% ≥ declared 99.9%) | PASS; 1 defect seed reported | property-based (PCG) |
| Game with win condition behind unreachable gate | FAIL; "win-state GameOver_Victory has no valid path from initial state" | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-011 | For declared deterministic game: exactly one path must exist to each win state (for linear games) OR at least one (for branching games) | proptest (generate valid game-graph structures; assert solvability) |
| VP-TBD-012 | PCG solvability rate ≥ declared minimum over large sample | proptest with statistical assertion (rejection sampling test) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements "solvability" as named in CAP-006's design-intent contract scope |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | design-intent-verifier (SS-TBD; assigned by architect) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.02.001 — depends on (solvability is a special case of reachability targeting win states)
- BC-6.02.004 — composes with (no-softlock ensures player cannot reach a state where win condition becomes unreachable after initial reachability was valid)
- BC-6.02.005 — depends on (this certifies structural solvability; difficulty and path quality are playtest-delegated)
- BC-7.01.001 — depended on by (sim/spec convergence requires this BC to pass)

## Architecture Anchors

- `architecture/SS-TBD-design-intent-verifier.md` — design intent verification module

## Story Anchor

S-TBD — Game Solvability Contract

## VP Anchors

- VP-TBD-011 — solvability path existence
- VP-TBD-012 — PCG solvability rate
