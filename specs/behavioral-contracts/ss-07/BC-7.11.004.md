---
document_type: behavioral-contract
level: L3
id: BC-7.11.004
version: "1.1"
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

# BC-7.11.004: Server-Authority Invariant — Replay-Attack Prevention

## Description

The server must prevent replay attacks: a replay attack is when a legitimate input
event (or sequence of events) is re-submitted by a client to illegitimately replay
a beneficial outcome (e.g., replaying a successful purchase transaction or a
kill-confirm event). This invariant requires that every input event carrying game-state
consequence is either: (a) idempotent by design (the outcome of re-applying it is
identical to applying it once), or (b) carries a monotonically-incrementing sequence
number, nonce, or timestamp that the server uses to detect and reject re-submission.

## Preconditions

1. Online features declared in game profile.
2. `server-authority-spec.replay_prevention_strategy` declared as one of
   `{nonce, sequence_number, server_timestamp_window}` for consequence-bearing events.
3. Consequence-bearing event types are declared in `server-authority-spec.consequence_events[]`.

## Postconditions

1. **PASS:** Every `consequence_event[]` type uses the declared replay-prevention
   strategy. Re-submission of a nonce/sequence already seen is rejected.
2. **FAIL:** A consequence-bearing event can be replayed to change server state
   (e.g., submitting the same purchase-confirm event twice results in double-crediting
   the player's inventory). Error: `E-CONV-006` `CWE-602: replay-attack path detected
   for event type '<type>'`.
3. **OFFLINE EXEMPTION:** No online features. INAPPLICABLE.

## Invariants

1. The nonce/sequence registry is server-side. Client-supplied nonces are checked
   against the server's seen-nonce set; a nonce already in the set is rejected.
2. Timestamps as replay prevention require a strict server-side validity window
   (typically ±30 seconds from server clock). Events outside the window are rejected.
3. Economy events (purchases, loot drops, crafting) are always consequence-bearing and
   must use replay prevention — they are never idempotent by design.
4. Movement events may be idempotent in some topologies (last-accepted-position model);
   this must be explicitly declared in the spec.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Client re-sends a purchase event with the same nonce (network retry) | Server rejects second submission; logs duplicate nonce; no double-credit |
| EC-002 | Client replays a kill-confirm event to inflate kill count | Server detects event ID already processed; rejects; kill count unchanged |
| EC-003 | Player connection drops and reconnects; client re-sends last N movement events | Acceptable if movement is idempotent (last-known-position model); acceptable if seq numbers allow gap recovery |
| EC-004 | Game event has no declared replay-prevention strategy | BLOCKED: consequence events without declared strategy are treated as a spec defect |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Purchase event submitted once with valid nonce | PASS: inventory credited once | happy-path |
| Same purchase event nonce re-submitted | FAIL: E-CONV-006 replay-attack; no second credit | error |
| Kill-confirm event with incrementing sequence number; replayed old seq | FAIL: E-CONV-006 replay-attack | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-203 | Re-submitting a consequence event with the same nonce is rejected without state change | Property-based test: for each consequence event type, submit twice with same nonce; assert state mutated exactly once |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — specifies the replay-attack prevention invariant of the `server-authority-invariant-suite` (CWE-602 spine) for D-SEC evaluation. |
| L2 Domain Invariants | DI-012 |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — evaluated by D-SEC dimension
- BC-7.11.002 — sibling (no-trust-client is the fundamental invariant)
- BC-7.11.007 — composes with (economy atomicity extends replay prevention to transaction integrity)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-203
