---
document_type: behavioral-contract
level: L3
version: "1.2"
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
modified:
  - version: "1.2"
    date: 2026-06-16
    reason: "R-19 (Phase-1d audit): version bump to align with BC-1.02.001 v1.2 which now declares 'modes: array' as a mandatory capture capability field, closing the gap this BC's PC1 depended on."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-1.08.003: capture/frames Returns Ordered Frame Sequence Paths

## Description

When `capture/frames` is invoked on an adapter with an available render profile,
the adapter captures a sequence of frames from a game replay or real-time run,
writes them as numbered PNG files to the specified output directory, and returns
a `CaptureResult` with all frame paths in display order. The frame sequence is
the input for external video encoding (ffmpeg); video encoding is a Layer-2
factory concern, not an adapter concern.

## Preconditions

1. The adapter's `capture` capability has `fidelity: "full"` or `"partial"` and
   `modes` includes `"frame-sequence"`.
2. The `render` execution profile is available.
3. The `capture/frames` request params include:
   - `frameCount`: positive integer (number of frames to capture)
   - `frameRate`: integer frames-per-second (e.g., 30, 60)
   - `outputDir`: absolute path to output directory
   - `prefix`: filename prefix (e.g., `"frame_"`)
   - `replayPath` or `startTick`/`endTick`: how to position the game state

## Postconditions

1. The adapter returns a `CaptureResult` object with:
   - `media`: array of exactly `frameCount` entries, each:
     `{ kind: "screenshot", path: "<abs_path_to_PNG>", width: N, height: M }`
   - The entries are in ascending display order (frame 0 first, last frame last).
   - `profile`: `"render"`
   - `backend`: GPU backend string
   - `frameCount`: integer equal to the number of entries in `media`
2. All PNG files listed in `media` exist when the response is sent.
3. Filenames follow the pattern `<prefix><zero-padded-frame-number>.png`
   (e.g., `frame_0001.png`, `frame_0002.png`).

## Invariants

1. The `media` array length equals `frameCount` (unless an `OperationFailed` error
   is returned; partial frame sequences are not returned as success).
2. Frame order is display order, not filesystem sort order.
3. Video encoding from the frame sequence is done by the factory core (Layer 2),
   not by the adapter.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `frameCount: 1` | Equivalent to a single screenshot; still uses `capture/frames` endpoint; returns 1-entry media array |
| EC-002 | `frameCount: 0` | `InvalidRequest` error — at least 1 frame required |
| EC-003 | Disk fills up mid-capture | `OperationFailed` with `data.reason: "disk-full"` and the count of frames captured before failure |
| EC-004 | Game state is at wrong tick for requested frames | Adapter returns `OperationFailed` if it cannot position the game state; caller is responsible for seeking |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `frameCount: 30, frameRate: 30, outputDir: "/abs/capture", prefix: "frame_"` | `CaptureResult` with 30 entries `frame_0001.png...frame_0030.png`, all files exist | happy-path |
| `frameCount: 0` | `InvalidRequest` error | error |
| Disk fills at frame 15 of 30 | `OperationFailed` with `data.reason: "disk-full"`, partial capture info in data | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-034 | media.length == frameCount on success | conformance test |
| VP-TBD-035 | All paths in media exist as valid PNGs | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — frame sequence capture enables both visual regression testing and marketing asset generation (trailer-editor role) |
| L2 Domain Invariants | DI-001 |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.08.001 — sibling (single screenshot)
- BC-1.08.002 — depends on (ProfileUnavailable precondition)

## Architecture Anchors

- `planning/design/protocol-schema.md#35-captureresult`
