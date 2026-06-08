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

# BC-1.04.001: Every Adapter Declares headless-compute and render Execution Profiles

## Description

The Capability Manifest returned from `initialize` must always declare exactly
two execution profiles: `headless-compute` (for build, test, lint, introspect,
assets-validate, and run-headless operations — no GPU required) and `render`
(for capture operations — always requires a GPU backend). This two-profile model
is mandatory because research confirmed that `headless ⇒ capture` is false on
every supported engine; conflating the two profiles produces silent failures or
blank frames.

## Preconditions

1. The adapter has received an `initialize` request.
2. The adapter is implementing the Engine Adapter Protocol.

## Postconditions

1. The Capability Manifest's `executionProfiles` field contains:
   a. `headless-compute`: object with `available: bool`
   b. `render`: object with `available: bool`, `windowless: bool`, and
      `requires: string[]` (list of external dependencies)
2. The `headless-compute` profile is `available: true` unless the adapter
   lacks the engine binary entirely (in which case, all capabilities should
   also be `fidelity: "none"`).
3. The `render` profile's `available` field reflects whether the required GPU
   backend dependencies are present on the current runner.
4. Every capability in the manifest declares which profile it uses:
   - `headless-compute`: `build`, `test`, `runHeadless`, `lint`, `assetsValidate`, `introspect`
   - `render`: `capture`
   - `replay`: may use either profile (declared in the replay capability object)

## Invariants

1. The two-profile structure is never collapsed into one; no adapter declares a
   single "headless" profile that also covers capture.
2. The `windowless` field on `render` is `true` for Bevy (offscreen render-to-texture
   approach) and `false` for Unity and Godot (which require xvfb to create a virtual
   display).
3. If `render.available: false`, all capabilities that declare `profile: "render"`
   must have `fidelity: "none"`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Runner has no GPU and no xvfb | `render.available: false`; `capture` fidelity is `none`; `headless-compute` capabilities unaffected |
| EC-002 | Bevy adapter running without lavapipe installed | `render.available: false` until lavapipe is installed; manifest reflects this |
| EC-003 | Unity adapter attempting to use `-nographics` flag for capture | Adapter MUST NOT declare capture as available via headless-compute; Unity `-nographics` produces blank frames — this is the research-confirmed failure mode |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter on runner with lavapipe | `executionProfiles: { "headless-compute": { available: true }, "render": { available: true, windowless: true, requires: ["vulkan-software:lavapipe"] } }` | happy-path |
| Unity adapter on runner with xvfb | `executionProfiles: { "headless-compute": { available: true }, "render": { available: true, windowless: false, requires: ["xvfb", "gl-software:llvmpipe"] } }` | happy-path |
| Any adapter on runner with no GPU/xvfb | `executionProfiles.render.available: false`; `capabilities.capture.fidelity: "none"` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-014 | Every manifest has both headless-compute and render keys | schema validation in conformance suite |
| VP-TBD-015 | If render.available is false, capture fidelity is none | conformance test on manifests with render unavailable |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the two execution profiles are the foundational mechanism by which the factory avoids the research-confirmed "headless implies no capture" false assumption |
| L2 Domain Invariants | DI-001 (engine-specific GPU requirements are declared by the adapter, not assumed by the core); DI-004 (capture GPU requirements are declared, never assumed) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (execution profiles are part of the Capability Manifest)
- BC-1.04.002 — sibling (render profile GPU backend requirement detail)
- BC-1.08.002 — composes with (ProfileUnavailable when render absent)

## Architecture Anchors

- `planning/design/protocol-schema.md#2-capability-manifest-schema` — executionProfiles schema
- `planning/design/engine-adapter-protocol.md#capabilities-the-fixed-surface-every-adapter-implements`
- `planning/design/engine-adapter-protocol.md#capability-matrix-research-confirmed-2026-06-07` — capture/headless matrix
