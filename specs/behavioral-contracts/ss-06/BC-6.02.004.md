---
document_type: behavioral-contract
level: L3
version: "1.1"
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
modified:
  - version: "1.1"
    date: 2026-06-13
    author: architect
    reason: "F60-02 VP-004 back-ref consistency fix — updated VP-004 parenthetical to match corrected property statement (every reachable non-terminal state has a forward path to a declared terminal: win OR game-over; not win-only)"
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-6.02.004: No-Softlock Invariant

## Description

Verifies that no reachable game state is a softlock — a state from which the
declared win conditions are all unreachable, but the game has not yet triggered
a declared game-over condition. A softlock strands the player in an unwinnable
but non-terminated game state, requiring an external reset. This contract
performs state-space exploration over the declared state graph to find reachable
states with no outgoing path to any win condition. A softlock found by this
contract is a critical design defect.

## Preconditions

1. The `design-intent-contract` declares: (a) the set of win-condition states,
   (b) the set of declared game-over states (terminal failure states), and
   (c) the complete state transition graph (shared with BC-6.02.001 and
   BC-6.02.002).
2. A softlock is defined as: a reachable state S such that:
   - S is NOT a win-condition state
   - S is NOT a game-over state (declared failure terminal)
   - No path from S reaches any win-condition state via declared transitions
3. The state graph must be finite and declared; infinite state spaces must be
   bounded by the `design-intent-contract` with a declared bound.
4. Respawn mechanics and recovery paths are declared as explicit transitions in
   the state graph (e.g., `Die → Respawn` transition exists if the game has
   respawn).
5. The same state graph tooling used by BC-6.02.001 is available.

## Postconditions

1. The no-softlock check performs: (a) compute all states reachable from initial
   state, (b) for each reachable non-terminal state, check if any win condition
   is reachable from it via forward BFS/DFS. If not, it is a softlock.
2. Zero softlock states are found in the declared state graph. Any softlock
   detected is reported as a FAIL with the softlock state ID and the last valid
   path that reaches it.
3. The check completes within declared timeout (default: 5 minutes per 10,000
   reachable states).
4. States that are softlocks only if the player makes specific "irreversible"
   choices (e.g., sells a key item) must be declared as acknowledged softlock
   risks in the `design-intent-contract` with a mitigation (e.g., "key item
   cannot be sold" enforced as a sim-BC or "New Game+" recovery path declared").

## Invariants

1. A softlock detected in the declared state graph is ALWAYS a defect. There is
   no tolerance or degradation for softlocks — they are deterministic structural
   failures.
2. The state graph used for softlock detection is identical to the state graph
   used for reachability (BC-6.02.001) and solvability (BC-6.02.002).
3. A state that is a softlock only due to probabilistic bad luck (e.g., a 0.001%
   chance resource spawn that never occurs) is captured by the PCG solvability
   rate check in BC-6.02.002, not this contract. This contract covers structural
   (deterministic) softlocks.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Dead-end state with a game-over exit (correct design) | Not a softlock — game-over is a declared terminal; the state has an exit; PASS |
| EC-002 | Dead-end state with no exits at all (no game-over, no win) | Softlock — reported as FAIL with state ID; infinite stall state |
| EC-003 | State that requires an item to exit, but the item was already consumed irreversibly | Softlock — reported; `design-intent-contract` must either prevent item consumption or declare a recovery path |
| EC-004 | Large game with 50,000 reachable states | Timeout-aware BFS; progressive results reported; TIMEOUT status if not complete; advisory for incomplete check |
| EC-005 | Softlock acknowledged in `design-intent-contract` with explicit mitigation | Not a FAIL — acknowledged softlock risk with mitigation is a PASS (mitigation is validated separately) |
| EC-006 | Game with multiple parallel state dimensions (inventory + location + quest) | Cross-product state graph; softlock detection runs on the full cross-product; complexity declared and bounded |
| EC-007 | State reachable only from another softlock state | Both states are softlocks; reported as a cluster; the entry point to the cluster is the primary defect |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| State graph with all non-terminal states having paths to win condition | Zero softlocks found; PASS | happy-path |
| State graph with state D reachable but no path to win or game-over from D | FAIL; "softlock detected: state D — reachable from initial but no exit to win or game-over" | error |
| State graph with acknowledged softlock A in contract, mitigation = "NewGamePlus" | PASS; acknowledged softlock A noted with mitigation | edge-case (acknowledged) |
| State graph where game-over state has no outgoing edges (true terminal) | Game-over is not a softlock; PASS | edge-case (terminal) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-015 | Every reachable non-terminal state has a forward path to at least one win or game-over condition | kani (bounded reachability over finite state space) |
| VP-TBD-016 | Softlock detection terminates on any finite state graph | proptest (random finite graph; assert BFS terminates) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements "no-softlock" as named in CAP-006's design-intent contract scope |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | design-intent-verifier (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.003 — composes with (FSM legality ensures no illegal states exist; no-softlock builds on legal state graph)
- BC-6.02.001 — depends on (reachability check identifies which states are reachable; softlock check examines only reachable states)
- BC-6.02.002 — composes with (solvability checks win-state reachability from initial; no-softlock checks win-state reachability from every reachable state)
- BC-7.01.001 — depended on by (sim/spec convergence requires this BC to pass)

## Architecture Anchors

- `architecture/SS-05-design-intent-verifier.md` — design intent verification module

## Story Anchor

S-TBD — No-Softlock Design Intent Contract

## VP Anchors

- VP-TBD-015 — every reachable non-terminal state has a forward exit
- VP-TBD-016 — softlock detection terminates on finite graphs
- Formally verified by VP-004 (No-softlock reachability — every reachable non-terminal state has a forward path to a declared terminal: win OR game-over; F60-02) — see verification-properties/VP-004-no-softlock-reachability.md
