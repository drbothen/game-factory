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

# BC-1.08.002: capture Returns ProfileUnavailable When render Profile Is Absent

## Description

When any `capture/*` method is called and the `render` execution profile is
unavailable (no GPU backend, no xvfb), the adapter returns a `ProfileUnavailable`
error (`-32002`) immediately without attempting to run the capture operation. This
is the research-confirmed failure mode: on Unity, running capture under `-nographics`
silently produces blank frames; on Godot, `--headless` disables all rendering. The
`ProfileUnavailable` error enables the factory to degrade the visual convergence
dimension gracefully rather than accepting silently broken screenshots.

This BC covers the FM-003 failure mode (Capture-Profile GPU Unavailable).

## Preconditions

1. A `capture/screenshot` or `capture/frames` request has been received.
2. The `render` execution profile's `available` field is `false` (determined at
   initialization or via `capability/unregister`).

## Postconditions

1. The adapter returns a JSON-RPC 2.0 error response with:
   - `error.code`: `-32002` (ProfileUnavailable)
   - `error.message`: `"ProfileUnavailable"`
   - `error.data.profile`: `"render"`
   - `error.data.requires`: copy of the `render.requires` array from the manifest
     (e.g., `["vulkan-software:lavapipe"]` or `["xvfb", "gl-software:llvmpipe"]`)
   - `error.data.hint`: human-readable remediation hint (e.g.,
     `"Install lavapipe (libvulkan-software) and re-run with render profile"`)
2. No screenshot or frame file is created.
3. The adapter remains in a healthy state; headless-compute capabilities continue
   to function normally.

## Invariants

1. `ProfileUnavailable` is the ONLY response to `capture/*` when the render
   profile is unavailable; the adapter never attempts capture and returns a blank
   or corrupt file.
2. After `ProfileUnavailable`, the adapter does NOT downgrade or alter other
   capabilities; only the capture operation is refused.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | render profile was previously available but `capability/unregister` was sent for it | Subsequent capture calls return `ProfileUnavailable` |
| EC-002 | `capture/screenshot` called when adapter manifest shows `capture.fidelity: "none"` | Adapter should have returned `CapabilityUnsupported` at the capability check; if somehow reached, `ProfileUnavailable` is also acceptable |
| EC-003 | CI runner provisions GPU after adapter has been initialized | Adapter cannot change profile availability mid-session; it may send `capability/register` to upgrade capture if it detects the change |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `capture/screenshot` on adapter with `render.available: false` | `{"error":{"code":-32002,"message":"ProfileUnavailable","data":{"profile":"render","requires":["vulkan-software:lavapipe"],"hint":"Install lavapipe..."}}}` | error |
| `capture/frames` on same adapter | Same `ProfileUnavailable` error | error |
| `build` called on same adapter after ProfileUnavailable | BuildResult returned normally (headless-compute unaffected) | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-032 | ProfileUnavailable always includes data.profile, data.requires, data.hint | conformance test |
| VP-TBD-033 | No file is created when ProfileUnavailable is returned | conformance test: check output directory after error |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — explicit ProfileUnavailable prevents the research-confirmed silent blank-frame failure mode on Unity/Godot |
| L2 Domain Invariants | DI-001; DI-004 (render profile availability is declared, not assumed); DI-006 (failure to capture is surfaced explicitly, not silently dropped) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.08.001 — sibling (capture success case)
- BC-1.04.001 — depends on (render profile declaration)
- BC-1.13.002 — composes with (core degrades visual dimension on this error)
- BC-1.13.003 — composes with (headless-compute continues after this error)

## Architecture Anchors

- `planning/design/protocol-schema.md#5-errors-json-rpc-error-codes`
- `planning/design/engine-adapter-protocol.md#7-worked-example--capability-gap--graceful-degradation`
- `planning/design/engine-adapter-protocol.md#capability-matrix-research-confirmed-2026-06-07`
