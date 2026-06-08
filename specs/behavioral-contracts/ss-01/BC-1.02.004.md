---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/planning/design/protocol-schema.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
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

# BC-1.02.004: exit Notification Terminates the Adapter Process

## Description

When the factory core sends an `exit` notification (not a request — no response
is expected), the adapter process terminates immediately with exit code 0. The
`exit` notification is the only mechanism that terminates the adapter process.
The two-step `shutdown` then `exit` is the normal graceful sequence; an `exit`
without prior `shutdown` is also valid for force-termination.

## Preconditions

1. The adapter process is running.
2. The core sends a JSON-RPC 2.0 `exit` notification (no `id` field).

## Postconditions

1. The adapter process terminates with exit code 0 within 500 ms of receiving
   the `exit` notification.
2. No response is sent (notifications require no response).
3. All file handles and subprocess resources held by the adapter are released
   before exit.
4. If `exit` is received without a prior `shutdown`, the adapter exits immediately
   with exit code 1 (abnormal exit without proper shutdown handshake).

## Invariants

1. `exit` is always a notification; the adapter never expects a response to an
   `exit` message.
2. The adapter process does not linger after receiving `exit`; it terminates within
   the declared timeout.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `exit` received with no prior `shutdown` | Adapter exits with code 1; in-flight operations are abandoned (not completed) |
| EC-002 | `exit` received immediately after `shutdown` response | Adapter exits with code 0 within 500 ms |
| EC-003 | `exit` notification is malformed (has an `id` field) | Adapter ignores the `id` field and still exits — `exit` semantics take precedence |
| EC-004 | Core sends `exit` before `initialize` | Adapter exits immediately (it is a valid early exit) with code 1 |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `shutdown` followed by `exit` | Adapter exits with code 0 within 500 ms of exit notification | happy-path |
| `exit` without prior `shutdown` | Adapter exits with code 1 within 500 ms | edge-case |
| No messages after spawn — core closes stdin pipe | Adapter may exit with code 0 or 1; it must not hang indefinitely | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-008 | Adapter process terminates within 500 ms of exit notification | conformance test: send exit, assert process is gone within 500 ms |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the adapter process termination contract ensures factory orchestration can reliably clean up adapters |
| L2 Domain Invariants | DI-001 (adapter process lifecycle managed by the core without engine knowledge) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.003 — depends on (shutdown precedes exit in graceful flow)

## Architecture Anchors

- `planning/design/protocol-schema.md#1-lifecycle`
