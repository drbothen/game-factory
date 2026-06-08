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

# BC-1.12.003: DeterminismTierViolation Returned When Core Requests Stricter Comparison Than Tier Allows

## Description

If the factory core (or any caller) somehow requests a comparison method stricter
than the adapter's declared `determinismTier` supports, the adapter returns a
`DeterminismTierViolation` error (`-32004`) rather than silently attempting the
comparison and potentially returning a false result. This is a safety guard against
protocol misuse; correct core implementations prevent this case via BC-1.12.002,
but the adapter enforces it as a last line of defense.

## Preconditions

1. A `replay/play` request has been received with a `comparison.method` parameter.
2. The comparison method is stricter than the adapter's declared tier allows:
   - `"snapshot-hash-diff"` requested from a `"tolerance-only"` adapter
   - `"snapshot-hash-diff"` requested from a `"same-machine"` adapter on a
     cross-machine run (optional enforcement — adapter MAY detect this)

## Postconditions

1. The adapter returns a JSON-RPC 2.0 error response with:
   - `error.code`: `-32004` (DeterminismTierViolation)
   - `error.message`: `"DeterminismTierViolation"`
   - `error.data.requestedMethod`: the comparison method that was requested
   - `error.data.declaredTier`: the adapter's declared `determinismTier`
   - `error.data.supportedMethods`: array of comparison methods the adapter supports
2. No replay comparison is performed.
3. The adapter remains in a healthy state.

## Invariants

1. A `"tolerance-only"` adapter NEVER executes `"snapshot-hash-diff"` comparisons.
2. `DeterminismTierViolation` always includes `declaredTier` so the caller can
   diagnose the mismatch.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `"tolerance-window"` requested from T1 adapter | Valid; T1 adapter accepts requests for any method ≤ its tier; returns `tolerance-window` result |
| EC-002 | `"snapshot-hash-diff"` requested from T2 adapter (same-machine) | T2 adapter accepts `snapshot-hash-diff` but notes it only holds for pinned runner; this is NOT a violation |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `replay/play` with `comparison.method: "snapshot-hash-diff"` on `tolerance-only` adapter | `{"error":{"code":-32004,"message":"DeterminismTierViolation","data":{"requestedMethod":"snapshot-hash-diff","declaredTier":"tolerance-only","supportedMethods":["tolerance-window"]}}}` | error |
| `replay/play` with `comparison.method: "tolerance-window"` on T1 adapter | ReplayResult with `comparison.method: "tolerance-window"` | happy-path (degraded request allowed) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-046 | tolerance-only adapter always returns DeterminismTierViolation on snapshot-hash-diff request | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — DeterminismTierViolation is the adapter-level enforcement of DI-004, preventing silent false-positive regression results from tier mismatches |
| L2 Domain Invariants | DI-004 (determinism tier declared, never assumed — this BC is the enforcement of that invariant at the adapter level) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.12.001 — depends on (tier declared in manifest)
- BC-1.12.002 — composes with (core-side prevention is the primary path)

## Architecture Anchors

- `planning/design/protocol-schema.md#5-errors-json-rpc-error-codes`
