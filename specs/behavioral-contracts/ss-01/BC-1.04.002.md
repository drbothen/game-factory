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

# BC-1.04.002: render Profile Declares GPU Backend Requirements

## Description

The `render` execution profile in the Capability Manifest must explicitly list
the GPU backend dependencies required to activate it. This allows the factory
orchestration layer to provision the correct runner environment for capture
operations, and to surface a `ProfileUnavailable` error with actionable
remediation information when the environment is missing the required backends.
The exact backend requirements differ per engine and are engine-adapter responsibility.

## Preconditions

1. The adapter is preparing the Capability Manifest.
2. The adapter knows which GPU backend it requires for the render profile.

## Postconditions

1. The render profile object includes a non-empty `requires` array listing one or
   more of the following (engine-specific):
   - Bevy: `["vulkan-software:lavapipe"]` (offscreen wgpu with software Vulkan)
   - Unity: `["xvfb", "gl-software:llvmpipe"]` (virtual framebuffer + Mesa software GPU)
   - Godot: `["xvfb", "vulkan-software:lavapipe"]` or `["xvfb", "gl-software:llvmpipe"]`
2. If `render.available: true`, the adapter has verified at initialization time that
   all items in `requires` are present on the current runner.
3. If `render.available: false`, the `requires` array is still populated to indicate
   what is missing, enabling targeted provisioning by CI/CD.
4. The `windowless` field is set per engine architecture:
   - `true` for Bevy: offscreen render-to-texture, no virtual display needed
   - `false` for Unity and Godot: virtual display (xvfb) is required

## Invariants

1. The `requires` array is never empty; at minimum it names the GPU backend class.
2. Bevy's render profile NEVER requires xvfb (it is windowless by design).
3. Unity and Godot render profiles ALWAYS require a virtual display (xvfb or
   equivalent) because their headless flag disables rendering.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | CI runner has xvfb but no Mesa/llvmpipe | Unity/Godot render profile available: false; requires lists both missing items |
| EC-002 | CI runner has lavapipe but no xvfb | Bevy render profile may be available: true; Unity/Godot render profiles are unavailable |
| EC-003 | Novel GPU backend not in the known list | Adapter may declare custom requires string; core logs it but does not error |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter manifest | `render: { available: true, windowless: true, requires: ["vulkan-software:lavapipe"] }` | happy-path |
| Unity adapter manifest | `render: { available: true, windowless: false, requires: ["xvfb", "gl-software:llvmpipe"] }` | happy-path |
| Bevy adapter on a runner missing lavapipe | `render: { available: false, windowless: true, requires: ["vulkan-software:lavapipe"] }` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-016 | render.requires is never empty | schema validation |
| VP-TBD-017 | windowless: true implies xvfb is not in requires | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — explicit GPU backend requirements allow CI to provision correctly for capture, avoiding silent failures |
| L2 Domain Invariants | DI-001 (GPU requirements are adapter-declared, not core-assumed); DI-004 (execution profile availability is declared, never assumed) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.04.001 — composes with (this BC adds detail to the render profile)
- BC-1.08.002 — depends on (ProfileUnavailable uses requires to report missing deps)

## Architecture Anchors

- `planning/design/engine-adapter-protocol.md#capability-matrix-research-confirmed-2026-06-07`
- `planning/design/protocol-schema.md#2-capability-manifest-schema`
