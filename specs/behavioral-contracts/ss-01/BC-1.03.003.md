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
subsystem: SS-TBD
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

# BC-1.03.003: Core Re-Plans Gates After Capability Registration Change

## Description

When the factory core receives a `capability/register` or `capability/unregister`
notification, it immediately re-evaluates all pending convergence dimension gates
and pipeline steps that depend on the changed capability. Dimensions previously
degraded due to insufficient capability fidelity are re-enabled when capability
upgrades; dimensions previously enabled are degraded when capability downgrades.
No convergence dimension is ever silently bypassed.

## Preconditions

1. The core has a pending production pipeline with one or more convergence
   dimensions or capability method invocations queued.
2. A `capability/register` or `capability/unregister` notification has been
   received from the adapter.
3. At least one pending step depends on the capability that changed.

## Postconditions

1. For every pending step that depended on the changed capability:
   a. If fidelity increased (register): the step is re-enqueued at the higher
      fidelity level if it was previously degraded or skipped.
   b. If fidelity decreased (unregister to `none`): the step is removed from the
      active queue and the corresponding convergence dimension is marked as
      degraded with a logged reason; a human-visible note is emitted if the
      degradation affects a required convergence dimension.
2. The re-planning is atomic with respect to the capability notification: no
   race condition occurs between the notification and pipeline execution.
3. The pipeline does NOT fail; it continues with the updated capability set.
4. A `$/log` notification is emitted by the core recording the re-planning event:
   which capability changed, from which fidelity to which, and which convergence
   dimensions were affected.

## Invariants

1. A convergence dimension that requires fidelity `full` and receives `none` is
   always marked as degraded, never silently passed.
2. Re-planning never causes a dimension that was already green to become red
   unless the capability supporting it was just downgraded.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Capability upgrade arrives after a step using it has already completed successfully | No re-planning needed for completed steps; future invocations of the capability use the higher fidelity |
| EC-002 | Capability downgrade arrives while the capability is actively being used | In-flight usage completes at the old fidelity; subsequent invocations use the new fidelity |
| EC-003 | Multiple capability changes arrive in rapid succession | Each is processed in order; the final state reflects the last notification for each capability |
| EC-004 | No pending steps depend on the changed capability | Core logs the capability change; no pipeline re-planning occurs (no-op) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `replay` upgraded from `none` to `full`; replay-regression step was degraded to "human playtest required" | Replay-regression step is re-enabled; convergence dimension changes from degraded to active | happy-path |
| `capture` downgraded to `none` via unregister; visual-convergence step was active | Visual-convergence dimension marked as degraded; `$/log` notification emitted with reason | happy-path |
| Capability change with no pending steps | `$/log` emitted; no pipeline change | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-012 | After capability/register upgrade, previously-degraded dimension is re-enabled | integration test: mock adapter that upgrades capability after project scan |
| VP-TBD-013 | Convergence dimension is never silently bypassed on downgrade | property: for all (capability, dimension) pairs, downgrade to none always results in dimension.status in {degraded, blocked} |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — this BC ensures dynamic capability changes propagate correctly into the pipeline plan, upholding the engine-agnostic quality model |
| L2 Domain Invariants | DI-001; DI-006 (degraded dimensions are surfaced, not silently dropped) |
| Architecture Module | Engine Adapter Protocol Layer 3 + Factory Core Pipeline Planner (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.03.001 — depends on (register triggers re-planning)
- BC-1.03.002 — depends on (unregister triggers re-planning)
- BC-1.13.002 — composes with (core degrades dimension gracefully)

## Architecture Anchors

- `planning/design/protocol-schema.md#12-dynamic-registration-lsp-borrowed`
