---
document_type: behavioral-contract
level: L3
id: BC-7.11.002
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1d
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-06
capability: CAP-007
priority: P0
lifecycle_status: active
introduced: v0.1.0-prd-rev-1d
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.11.002: Server-Authority Invariant — No-Trust-Client (CWE-602 Core)

## Description

For any game with online features, the server (authoritative game simulation) must
never accept a client-supplied value as ground truth for any game-state mutation.
Every client input that results in a state change must be re-evaluated by the server
using the server's own simulation state. This is the primary CWE-602 invariant. A
"trust-client" path is one where a client-supplied outcome (position, damage, score,
inventory delta) is applied to server state without server-side re-evaluation. Such
paths enable cheating via modified clients, replay attacks, and state forgery.

This BC specifies the testable assertion that must be verified by the
`server-authority-invariant-suite` referenced by BC-7.11.001 (D-SEC dimension).

## Preconditions

1. The game declares `online_features` in its profile (not offline-only).
2. A `server-authority-spec` artifact exists declaring the authoritative state model
   and the list of game-state variables managed by the server.
3. The server game loop implementation is available for assertion testing
   (runs headless, server-side logic only).

## Postconditions

1. **PASS:** For every client input type declared in `server-authority-spec.client_inputs[]`,
   the server has a corresponding validation handler that re-evaluates the input
   using server state before applying any state mutation.
2. **FAIL:** A client-input handler applies a client-supplied outcome directly to
   server state without re-evaluation (e.g., client sends `{delta_health: -50}` and
   server applies it without re-computing damage from server-side physics). Error:
   `E-CONV-006` with detail `CWE-602: no-trust-client invariant violated for input
   type '<input_type>'.`
3. **OFFLINE EXEMPTION:** Game declares no online features. Invariant is INAPPLICABLE.

## Invariants

1. "Re-evaluation" means the server computes the outcome from its own state using the
   input event (e.g., "player fired at location X, Y, Z at timestamp T"), not from
   a client-supplied outcome ("player scored a hit with 50 damage").
2. Network-position prediction / client-side prediction that is CORRECTED by server
   reconciliation is permitted — the client's predicted state is local only and the
   server's authoritative state overwrites it. This is NOT a trust-client violation.
3. Server-side event timestamps received from client are always treated as approximate
   and validated against server clock with acceptable drift tolerance (see BC-7.11.004
   for replay-attack prevention, which extends this invariant to timestamps).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Client sends move command; server applies client-side movement physics | FAIL: server must re-run movement physics from its authoritative state |
| EC-002 | Client-side prediction + server reconciliation (e.g., Valve GoldSrc lag comp) | PASS: client prediction is corrected by server; no trust-client violation |
| EC-003 | Server accepts client-supplied `score_delta` directly (e.g., arcade leaderboard) | FAIL: score must be computed server-side from events, not accepted as a delta |
| EC-004 | Peer-to-peer game (no central server) | INAPPLICABLE: this invariant applies to client-server topology; P2P games require separate trust model (out of scope for this BC) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Server receives `{event: "move", destination: {x,y}}` and re-runs movement from server pos | PASS: no-trust-client maintained | happy-path |
| Server receives `{event: "hit", damage: 50}` and applies 50 damage without re-computing | FAIL: E-CONV-006 `CWE-602 no-trust-client` | error |
| Offline single-player game | INAPPLICABLE: D-SEC = GREEN by inapplicability | inapplicable |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-200 | For every declared client input type, a server-side validation handler exists that re-evaluates from server state | Static analysis: `server-authority-spec.client_inputs[]` cross-referenced against server handler registry; missing handlers = failure |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC specifies one of the seven invariants that compose the `server-authority-invariant-suite` evaluated by convergence dimension D-SEC (BC-7.11.001). The CWE-602 server-authority model is the backbone of the D-SEC dimension. |
| L2 Domain Invariants | DI-012 (Every ContractArtifact Has a Declared Validation Method) |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — this BC is one of seven invariants evaluated by the D-SEC dimension
- BC-7.11.003 — composes with (input range/rate/sequence validation extends this BC)
- BC-7.11.004 — composes with (replay-attack prevention is a temporal extension of this invariant)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC — `server-authority-invariant-suite (CWE-602 spine)`
- CWE-602 — Client-Side Enforcement of Server-Side Security

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-200
