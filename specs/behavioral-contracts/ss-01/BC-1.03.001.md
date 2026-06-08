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
  - .factory/planning/design/engine-adapter-protocol.md
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

# BC-1.03.001: Adapter Upgrades a Capability via capability/register After Project Inspection

## Description

After the `initialized` notification is received, the adapter may inspect the
game project and discover capabilities that were initially declared at `partial`
or `none` fidelity. When such a capability becomes available, the adapter sends a
`capability/register` notification with the upgraded fidelity value and any
additional metadata. The canonical example is the Unity adapter initially
reporting `replay: { fidelity: "none" }`, then discovering the new Input System
package and upgrading to `replay: { fidelity: "full" }`. This prevents
lowest-common-denominator design without requiring upfront exhaustive project
scanning.

## Preconditions

1. The adapter has received and processed the `initialized` notification from the
   core.
2. The adapter has performed a project inspection (reading project manifests,
   package files, or source structure).
3. The project inspection reveals that a capability previously declared at `partial`
   or `none` is available at a higher fidelity.
4. The upgrade is from `none → partial`, `none → full`, or `partial → full` only
   (never a downgrade — downgrades use `capability/unregister`; see BC-1.03.002).

## Postconditions

1. The adapter sends a JSON-RPC 2.0 notification with:
   - `method`: `"capability/register"`
   - `params.capability`: the capability name string (e.g., `"replay"`)
   - `params.value`: an object with at minimum `fidelity: "full" | "partial"` and
     any method/prerequisites fields relevant to the capability
2. The core receives the notification and updates its internal capability model
   for this adapter session; the upgraded fidelity applies to all subsequent
   calls in this session.
3. The core re-plans any pending convergence dimension gates that depend on this
   capability; dimensions previously marked as degraded due to `none` fidelity
   are re-evaluated.
4. The core does NOT send a response to the `capability/register` notification
   (it is a one-way notification).

## Invariants

1. A `capability/register` notification only upgrades fidelity; it never reduces
   fidelity below the last declared value for that capability.
2. The capability name in `params.capability` is one of the eight canonical
   capability identifiers.
3. After `capability/register`, the session's effective manifest is the union of
   the original `initialize` manifest and all subsequent registrations/unregistrations.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `capability/register` sent for a capability already at `full` fidelity | Core ignores the duplicate registration (no change to capability model); no error |
| EC-002 | Adapter sends `capability/register` with a non-canonical capability name | Core logs an unknown capability warning; does not crash; the unknown capability is not added to the session manifest |
| EC-003 | Multiple `capability/register` notifications sent in sequence for different capabilities | Each is processed independently; all upgrades apply |
| EC-004 | `capability/register` arrives after `shutdown` was sent | Core ignores the registration (session is ending) |
| EC-005 | `capability/register` sent before `initialized` notification | Core returns `InvalidRequest` — registration is only valid post-initialization |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Unity adapter sends `capability/register` for `replay` with `fidelity: "full"` and `method: "input-system-eventtrace"` after finding new Input System | Core updates `replay` to `fidelity: "full"` for this session; subsequent `replay/record` calls are accepted | happy-path |
| Bevy adapter sends `capability/register` for `introspect` with `fidelity: "full"` and `method: "brp-jsonrpc"` | Core updates `introspect` to `full`; subsequent `introspect` calls use BRP | happy-path |
| `capability/register` for unknown capability name `"render_pipeline"` | Core logs warning; capability model unchanged | edge-case |
| `capability/register` after `shutdown` notification | Core ignores silently | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-009 | After capability/register, core capability model reflects the new fidelity | conformance test: register, then call the capability, assert it is accepted |
| VP-TBD-010 | capability/register never reduces fidelity | property: fidelity is monotonically non-decreasing per capability in a session |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — dynamic capability registration is the mechanism that prevents lowest-common-denominator adapter design while preserving engine agnosticism |
| L2 Domain Invariants | DI-001 (core never names engine — capability upgrades are engine-driven notifications, not core assumptions); DI-004 (determinismTier may be refined but not assumed) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (initial capability manifest from initialize)
- BC-1.03.002 — sibling (downgrade via capability/unregister)
- BC-1.03.003 — composes with (core re-plans gates after registration)

## Architecture Anchors

- `planning/design/protocol-schema.md#12-dynamic-registration-lsp-borrowed`
- `planning/design/engine-adapter-protocol.md#capabilities-the-fixed-surface-every-adapter-implements`
