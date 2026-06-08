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

# BC-1.03.002: Adapter Downgrades a Capability via capability/unregister

## Description

If an adapter discovers that a capability previously declared at `full` or
`partial` is no longer available (e.g., a required tool is absent on the current
runner, or the project structure changed), it sends a `capability/unregister`
notification to downgrade the capability. The core updates its capability model
and adjusts any dependent convergence dimension gates accordingly, triggering
graceful degradation rather than a pipeline failure.

## Preconditions

1. The adapter has been successfully initialized and the capability in question
   was previously declared or registered at `full` or `partial` fidelity.
2. The adapter has detected that the capability is no longer available at its
   currently declared fidelity.
3. The adapter sends a `capability/unregister` notification.

## Postconditions

1. The adapter sends a JSON-RPC 2.0 notification with:
   - `method`: `"capability/unregister"`
   - `params.capability`: the capability name string
   - `params.reason`: human-readable string explaining why fidelity was reduced
   - `params.newFidelity`: the degraded fidelity value (`"partial"` or `"none"`)
2. The core updates its capability model: the capability's effective fidelity
   for this session is set to `params.newFidelity`.
3. The core re-plans convergence dimensions that depended on the now-downgraded
   capability; affected dimensions are set to degraded status (not pipeline failure).
4. Subsequent calls to the downgraded capability at its previous fidelity level
   return `CapabilityUnsupported` if fidelity is now `"none"`, or succeed with
   reduced guarantees if `"partial"`.

## Invariants

1. `capability/unregister` always specifies a `newFidelity`; it never leaves
   fidelity state undefined.
2. A capability cannot be downgraded below `none`.
3. The core does not send a response to `capability/unregister` (it is a notification).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `capability/unregister` for a capability already at `none` | Core logs warning; no state change; no error |
| EC-002 | `capability/unregister` sent without `reason` field | Core accepts the downgrade; `reason` is optional for programmatic consumption |
| EC-003 | `capability/unregister` during an active operation on that capability | Core marks capability as downgrading; the in-flight operation completes with its existing contract; future calls use the new fidelity |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Godot adapter sends `capability/unregister` for `capture` with `newFidelity: "none"` and `reason: "xvfb not available on runner"` | Core sets capture fidelity to none; visual convergence dimension set to degraded; next `capture/screenshot` call returns CapabilityUnsupported | happy-path |
| `capability/unregister` for `build` with `newFidelity: "none"` | Core marks build as unavailable; build convergence dimension set to blocked | error (partial-system) |
| `capability/unregister` for capability already at `none` | Core logs warning; no state change | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-011 | After capability/unregister to none, calling the capability returns CapabilityUnsupported | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — capability downgrade via unregister enables the declare-and-degrade pattern rather than silent failure |
| L2 Domain Invariants | DI-001; DI-006 (human-gated tasks surfaced when degradation occurs, not silently dropped) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.03.001 — sibling (upgrade via register)
- BC-1.13.001 — composes with (CapabilityUnsupported follows from none fidelity)
- BC-1.13.002 — composes with (core degrades dimension after unregister)

## Architecture Anchors

- `planning/design/protocol-schema.md#1-lifecycle`
