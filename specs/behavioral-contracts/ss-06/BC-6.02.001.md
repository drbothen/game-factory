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
subsystem: SS-05
capability: CAP-006
priority: P0
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

# BC-6.02.001: Design Intent Reachability Contract

## Description

Verifies that every declared reachable game area, narrative branch, or game
state is actually reachable from the game's starting state via some valid input
sequence. Reachability is modeled over the game's state graph (nodes = game
states, edges = valid transitions). Unreachable declared states are a design
defect — the factory detects them via graph traversal, not gameplay observation.
This is a machine-verifiable design-intent assertion that does NOT cover
"whether the journey to reach a state is fun" (playtest-delegated).

## Preconditions

1. A `design-intent-contract` has been authored that declares the reachability
   target set: a list of game states (areas, narrative nodes, game-over conditions,
   progression milestones) that must be reachable from the initial state.
2. The game state is modeled as a finite-state graph in the spec: nodes are
   unique state identifiers, edges are valid input-triggered transitions declared
   in the `systems-spec` or `narrative-graph`.
3. The state graph can be exported or queried headlessly (no engine required for
   the structural reachability check; the engine is NOT invoked for this test).
4. The initial state is declared and unique.
5. The reachability target set is non-empty.

## Postconditions

1. For every state S in the declared reachability target set, there exists at
   least one path P from the initial state to S in the declared state graph.
   If no such path exists, the test fails with the unreachable state ID reported.
2. The reachability check is performed via BFS/DFS over the declared state graph —
   not via simulation playthrough (which would be non-exhaustive).
3. Any state reachable in the graph but NOT declared in the `systems-spec` is
   reported as an undeclared reachable state (a coverage gap, not a hard failure).
4. The reachability test completes within declared timeout (default: 60 seconds
   for graphs up to 10,000 nodes; configurable per game).

## Invariants

1. Reachability is assessed over the DECLARED state graph, not over arbitrary game
   simulation. Changes to the state graph spec trigger re-evaluation.
2. The reachability check is not exhaustive over all possible game states — it is
   exhaustive over the explicitly declared reachability target set.
3. This BC does NOT certify that a state is EASILY reachable or reachable within
   N steps — only that a valid path exists. Difficulty of reaching a state is a
   playtest concern (delegated per BC-6.02.005).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | State reachable only through a specific rare event sequence | Reachable via graph traversal; declared path documented in test output; no failure |
| EC-002 | State removed from spec but still in reachability target set | Build-time schema validation error: reachability target references a state not in the state graph |
| EC-003 | Cyclic state graph (A → B → A) | BFS correctly handles cycles via visited-set; terminates; no infinite loop |
| EC-004 | State graph with 10,000+ nodes | BFS completes within timeout; partial results reported if timeout exceeded; test fails with TIMEOUT status |
| EC-005 | All declared states are reachable (common case) | Test passes; summary reports: N states checked, all reachable |
| EC-006 | Empty reachability target set | Test passes vacuously; emits advisory: no reachability targets declared |
| EC-007 | State reachable only via a sequence that also visits a "game-over" terminal state first | If the state is reachable by ANY path (including paths that visit terminal states then continue via respawn), it is reachable; if game-over is truly terminal (no return), then the state is unreachable |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| State graph with 5 states, all reachable from initial | All 5 states reachable; PASS | happy-path |
| State graph with unreachable island (state D: no incoming edges) | D unreachable; FAIL with "state D has no path from initial state" | error |
| State graph with 10 states in a chain, target = last state | Reachable via path of length 10; PASS | edge-case |
| State graph with cycle A→B→A, target = B | Reachable in 1 hop; BFS terminates; PASS | edge-case (cycle) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-009 | BFS/DFS implementation terminates on any finite graph with cycles | proptest (generate random finite graphs; assert termination) |
| VP-TBD-010 | If state S is declared reachable, then the BFS path from initial to S is valid (each edge is a declared transition) | kani (path validity over bounded graph depth) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements "reachability" as named in CAP-006's "design-intent contracts (reachability, solvability, balance bands, no-softlock)" scope |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | design-intent-verifier (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.02.002 — composes with (solvability extends reachability: solvability = reaching the win-state)
- BC-6.02.004 — composes with (no-softlock = no unreachable progress states; different target set than general reachability)
- BC-6.02.005 — depends on (playtest delegation: this BC certifies structural reachability, not reachability quality)
- BC-7.01.001 — depended on by (sim/spec convergence requires this BC to pass)

## Architecture Anchors

- `architecture/SS-05-design-intent-verifier.md` — design intent verification module

## Story Anchor

S-TBD — Design Intent Reachability Contract

## VP Anchors

- VP-TBD-009 — BFS termination on cyclic finite graphs
- VP-TBD-010 — path validity for declared-reachable states
