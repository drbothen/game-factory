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

# BC-1.02.003: shutdown Request Flushes In-Flight Work and Stops Accepting New Requests

## Description

When the factory core sends a `shutdown` request to an adapter, the adapter
completes any in-flight operations, returns a success response to the shutdown
request, and then stops accepting new capability method calls. The adapter
remains alive until the core sends an `exit` notification. This mirrors the LSP
shutdown-then-exit two-step.

## Preconditions

1. The adapter has been successfully initialized (received `initialize` and
   `initialized` notification).
2. The core sends a JSON-RPC 2.0 `shutdown` request.
3. Zero or more capability operations may be in-flight at the time shutdown is sent.

## Postconditions

1. The adapter completes all in-flight operations that were started before the
   `shutdown` request was received (or returns `Cancelled` for each if the in-flight
   operation is cancelled via `$/cancelRequest` before shutdown completes).
2. The adapter returns a JSON-RPC 2.0 success response to the `shutdown` request
   with `result: null`.
3. After sending the shutdown response, the adapter rejects any new capability
   method calls with `InvalidRequest` (`-32600`), message `"Adapter is shutting down"`.
4. The adapter does NOT terminate its process after `shutdown`; it waits for `exit`.
5. The `shutdown` response is sent within a declared timeout
   (default: 30 seconds; configurable via workspace settings).

## Invariants

1. A `shutdown` response is always sent before the adapter stops processing requests.
2. The adapter never terminates its process on `shutdown` alone — only `exit` terminates.
3. In-flight operations that complete after `shutdown` is received still deliver their
   responses before the adapter stops accepting new work.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `shutdown` received with no in-flight operations | Adapter returns `result: null` immediately |
| EC-002 | `shutdown` received while a long build is running | Adapter lets the build complete, then responds to shutdown (OR cancels the build if `$/cancelRequest` was also sent) |
| EC-003 | Capability call arrives after shutdown response was sent | Adapter returns `InvalidRequest` (`-32600`) with `"Adapter is shutting down"` |
| EC-004 | Core sends `shutdown` before `initialize` completes | Adapter returns `InvalidRequest` — cannot shutdown before initialization |
| EC-005 | In-flight operation exceeds 30-second shutdown timeout | Adapter cancels the in-flight operation, returns its Cancelled error, then responds to shutdown |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `shutdown` with no in-flight ops | `{"jsonrpc":"2.0","id":N,"result":null}` | happy-path |
| Capability call sent after shutdown response | `{"error":{"code":-32600,"message":"Invalid Request: Adapter is shutting down"}}` | error |
| `shutdown` while build is running | Build completes (or is cancelled), then `{"result":null}` for shutdown | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-007 | shutdown always returns result: null, never an error (except if not yet initialized) | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — clean adapter lifecycle shutdown is required for the factory's pipeline to reliably orchestrate adapter processes |
| L2 Domain Invariants | DI-001 (core orchestrates adapter lifecycle without engine-specific logic) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (shutdown is only valid after initialize succeeds)
- BC-1.02.004 — sibling (exit terminates the process; shutdown is separate)

## Architecture Anchors

- `planning/design/protocol-schema.md#1-lifecycle`
