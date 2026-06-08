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

# BC-1.13.001: Calling a none-Fidelity Capability Returns CapabilityUnsupported

## Description

When the factory core calls any capability method on an adapter that has declared
`fidelity: "none"` for that capability, the adapter immediately returns a
`CapabilityUnsupported` error (`-32001`) without attempting the operation. This
is the LSP-style graceful-degradation signal: the core catches it, degrades the
corresponding convergence dimension, and does not fail the pipeline.

## Preconditions

1. The adapter has declared `fidelity: "none"` for a specific capability in its
   manifest (either at `initialize` or via `capability/unregister`).
2. The factory core sends a method call for that capability (e.g., calling
   `introspect` when introspect fidelity is `"none"`).

## Postconditions

1. The adapter returns a JSON-RPC 2.0 error response with:
   - `error.code`: `-32001` (CapabilityUnsupported)
   - `error.message`: `"CapabilityUnsupported"`
   - `error.data.capability`: the capability name (e.g., `"introspect"`)
   - `error.data.declaredFidelity`: `"none"`
2. No operation is performed; no engine process is launched.
3. The adapter remains in a healthy state and can serve subsequent requests.

## Invariants

1. A capability with `fidelity: "none"` ALWAYS returns `CapabilityUnsupported`
   when called; it never silently succeeds or returns an empty result.
2. The error includes the capability name so the caller can log precisely which
   capability was unavailable.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | All eight capabilities are `fidelity: "none"` | Each call returns CapabilityUnsupported; the adapter is essentially a null adapter |
| EC-002 | `fidelity: "partial"` capability called | NOT a CapabilityUnsupported case; `partial` capabilities execute with documented limitations |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `introspect` called on adapter with `introspect.fidelity: "none"` | `{"error":{"code":-32001,"message":"CapabilityUnsupported","data":{"capability":"introspect","declaredFidelity":"none"}}}` | error |
| `build` called on adapter with `build.fidelity: "full"` | BuildResult returned normally | happy-path |
| `capture/screenshot` called on adapter with `capture.fidelity: "none"` | CapabilityUnsupported error | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-047 | Every none-fidelity capability call returns CapabilityUnsupported | conformance test for all 8 capabilities |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — CapabilityUnsupported is the explicit, machine-processable signal that enables graceful degradation without pipeline failure |
| L2 Domain Invariants | DI-001; DI-004 (fidelity is declared; none-fidelity is enforced, not silently ignored) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.13.002 — composes with (core degrades dimension on this error)
- BC-1.03.002 — depends on (unregister can set fidelity to none)

## Architecture Anchors

- `planning/design/protocol-schema.md#5-errors-json-rpc-error-codes`
