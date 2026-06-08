---
document_type: behavioral-contract
level: L3
id: BC-7.11.005
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1d
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
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

# BC-7.11.005: Server-Authority Invariant — Authoritative Reconciliation

## Description

When client-side state diverges from server-side authoritative state (as occurs
naturally in games with client-side prediction), the server must always win: the
server's authoritative state is pushed to the client, and the client discards its
local predicted state in favor of the server's authoritative value. This invariant
ensures that client-side simulation — a necessary UX feature for low-latency
responsiveness — cannot become a trust-client vulnerability.

This BC distinguishes between the three legitimate roles of client-side simulation:
(1) visual-only prediction (cosmetic, no game state), (2) predictive reconciliation
(predicted state is discarded on server correction), and (3) speculative execution
(input acknowledged but not committed until server confirms). All three are permitted.
What is forbidden is non-reconciling prediction where client state persists after
server contradiction.

## Preconditions

1. Online features declared in game profile.
2. `server-authority-spec.client_prediction_model` is declared as one of
   `{visual_only, predictive_reconciliation, speculative_execution, none}`.

## Postconditions

1. **PASS:** Client state is reconciled from server authoritative state at declared
   reconciliation frequency. Client state cannot persist against server contradiction.
2. **FAIL:** Client retains its local prediction after receiving a server state
   correction that contradicts it (reconciliation not implemented or suppressed).
   Error: `E-CONV-006` `CWE-602: client-state not reconciled from server authority`.
3. **OFFLINE EXEMPTION:** No online features. INAPPLICABLE.

## Invariants

1. Reconciliation frequency must be declared (e.g., every N ticks, every packet).
2. The reconciliation message is initiated by the server, not the client.
3. Cosmetic/visual-only prediction (animations, particle effects) is exempt —
   only game-state variables (position, health, inventory, score) require reconciliation.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Client predicts player moved north; server says no movement (player was stunned) | Server state pushed to client; client discards local prediction and shows correct position |
| EC-002 | Client has 80hp local prediction; server sends 60hp correction | Client displays 60hp; client does not retain 80hp |
| EC-003 | Visual effect (particle trail from predicted movement) persists for 1 frame after server correction | Permitted: cosmetic prediction is exempt from reconciliation requirement |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Server corrects client position after lag spike | Client shows server-authoritative position | happy-path |
| Client health local = 80, server correction = 60, client retains 80 | FAIL: E-CONV-006 reconciliation not applied | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-204 | Client game-state variable always matches server authoritative value within one reconciliation cycle | Integration test: inject server correction; assert client variable matches server within declared reconciliation frequency |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — specifies the authoritative reconciliation invariant of the `server-authority-invariant-suite` for D-SEC evaluation. |
| L2 Domain Invariants | DI-012 |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — evaluated by D-SEC dimension
- BC-7.11.002 — sibling (no-trust-client is the fundamental invariant)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-204
