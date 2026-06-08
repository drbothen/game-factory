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

# BC-1.08.001: capture/screenshot on render Profile Returns CaptureResult with media Path

## Description

When `capture/screenshot` is invoked and the `render` execution profile is
available, the adapter launches the game using the render profile (with GPU
backend), captures a single frame as a PNG file, and returns a normalized
`CaptureResult` containing the absolute path to the screenshot, its dimensions,
and the backend used. This capability requires the render profile; it NEVER
succeeds using the headless-compute profile.

## Preconditions

1. The adapter's `capture` capability has `fidelity: "full"` or `"partial"`.
2. The `render` execution profile is `available: true` (GPU backend present).
3. The `capture/screenshot` request params include:
   - `scenePath` or `replayFrame`: a reference to the game state to capture
   - `width` and `height` (optional; defaults to 1920×1080)
   - `outputDir`: absolute directory where the screenshot file will be written
   - `progressToken` (optional)

## Postconditions

1. The adapter returns a `CaptureResult` object with:
   - `media`: array containing exactly one entry:
     `{ kind: "screenshot", path: "<abs_path>", width: N, height: M }`
     where `path` is an absolute path to an existing PNG file
   - `profile`: `"render"`
   - `backend`: string identifying the GPU backend used (e.g.,
     `"vulkan-software:lavapipe"`, `"gl-software:llvmpipe"`)
   - `frameCount`: `1`
2. The file at `media[0].path` exists and is a valid PNG file when the response
   is sent.
3. `width` and `height` reflect the actual dimensions of the captured image.

## Invariants

1. `capture/screenshot` always uses the `render` profile; it never succeeds on
   `headless-compute`.
2. The output file is always a PNG; no other format is used for screenshots.
3. `frameCount` is always `1` for screenshot operations.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | GPU backend produces an all-black frame (common misconfiguration) | Adapter returns CaptureResult with valid PNG; it is the caller's responsibility to detect blank frames (e.g., via perceptual hash); adapter does NOT error on black frames |
| EC-002 | `outputDir` does not exist | Adapter creates it; if creation fails, returns `OperationFailed` with `data.reason: "output-dir-unavailable"` |
| EC-003 | Requested scene state is not reachable (replay required) | Adapter returns `OperationFailed` with appropriate reason; the scene state must be set up by the caller before invoking capture |
| EC-004 | Width/height not specified | Adapter defaults to 1920×1080 |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter, render profile available, valid game state | `{ media: [{kind:"screenshot", path:"/abs/shots/001.png", width:1920, height:1080}], profile:"render", backend:"vulkan-software:lavapipe", frameCount:1 }` | happy-path |
| `outputDir` does not exist and creation fails | `OperationFailed` with `data.reason: "output-dir-unavailable"` | error |
| Width=2560, height=1440 specified | `media[0].width: 2560, media[0].height: 1440` | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-030 | Screenshot path exists as a valid PNG after CaptureResult is returned | conformance test: capture, then assert file exists and is valid PNG |
| VP-TBD-031 | capture/screenshot always reports profile: "render" | schema validation |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — gameplay capture is part of the engine adapter protocol surface, enabling visual evidence and marketing asset capture |
| L2 Domain Invariants | DI-001 (GPU backend requirements are adapter-internal; core sees only CaptureResult) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.08.002 — sibling (ProfileUnavailable when render absent)
- BC-1.08.003 — sibling (frame sequence capture)
- BC-1.04.001 — depends on (render execution profile)
- BC-1.04.002 — depends on (GPU backend requirements in render profile)

## Architecture Anchors

- `planning/design/protocol-schema.md#35-captureresult`
- `planning/design/engine-adapter-protocol.md#capability-matrix-research-confirmed-2026-06-07`
