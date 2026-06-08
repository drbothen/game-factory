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

# BC-1.07.001: runHeadless Runs Game Process Without Display and Returns RunResult

## Description

When the `runHeadless` capability is invoked, the adapter launches the game process
in headless mode (no display, no GPU) using the `headless-compute` execution profile,
runs it for a declared number of ticks or a timeout, then terminates it and returns
a normalized `RunResult`. This is the foundational capability for simulation testing
and replay-regression setup; it does NOT require the render profile.

## Preconditions

1. The adapter's `runHeadless` capability has `fidelity: "full"` or `"partial"`.
2. The engine binary is built (build capability has succeeded).
3. The `runHeadless` request params include at minimum:
   - `ticks`: integer or null (null = run until natural exit or timeout)
   - `timeoutMs`: integer (maximum wall-clock time to allow)
   - `rngSeed`: integer or null (if null, adapter uses a default seed)
4. The `headless-compute` execution profile is available.

## Postconditions

1. The adapter returns a `RunResult` object with:
   - `exitStatus`: `"clean"`, `"crashed"`, or `"timeout"`
   - `ticks`: non-negative integer (number of simulation ticks completed)
   - `durationMs`: non-negative integer (wall-clock elapsed)
   - `log`: string (tail of process output, up to 4096 chars)
2. If `ticks` param was provided and the game ran the full tick count, `exitStatus` is `"clean"`.
3. If the game process crashed (non-zero exit due to panic/exception), `exitStatus` is `"crashed"`.
4. If `timeoutMs` elapsed before completion, `exitStatus` is `"timeout"`.

## Invariants

1. `runHeadless` NEVER requires or starts the render execution profile.
2. The process launched does not create a visible window or allocate a GPU context
   (except on engines where headless is natively enforced).
3. `durationMs` is always non-negative.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Engine process exits immediately (e.g., startup crash) | `exitStatus: "crashed"`, `ticks: 0`, `log` contains startup output |
| EC-002 | `ticks: null` with no natural exit within timeoutMs | `exitStatus: "timeout"` |
| EC-003 | `rngSeed` not provided (null) | Adapter uses a deterministic default seed (e.g., 0); documents this in capability metadata |
| EC-004 | Unity with `-nographics` flag (confirmed by research to work for sim) | `exitStatus: "clean"` if sim completes; `-nographics` is valid for run_headless (not for capture) |
| EC-005 | Godot with `--headless` flag | `exitStatus: "clean"` if sim completes; valid for run_headless (not for capture) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter, `ticks: 3600`, `rngSeed: 1234567`, `timeoutMs: 60000` | `{ exitStatus: "clean", ticks: 3600, durationMs: ~60000, log: "..." }` | happy-path |
| Game process panics on tick 100 | `{ exitStatus: "crashed", ticks: 100, durationMs: ..., log: "thread 'main' panicked at ..." }` | error |
| `timeoutMs: 1000` with game that runs indefinitely | `{ exitStatus: "timeout", ticks: ~100, durationMs: 1000, log: "..." }` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-026 | RunResult always has exitStatus in {clean, crashed, timeout} | schema validation |
| VP-TBD-027 | runHeadless never launches a render profile process | conformance test: check no GPU/xvfb processes spawned |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — headless game execution is the foundation for sim testing and replay-regression across all engines |
| L2 Domain Invariants | DI-001; DI-004 (headless execution is profile-declared, not assumed to work without GPU) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.07.002 — sibling (timeout and crash distinction)
- BC-1.04.001 — depends on (headless-compute profile)

## Architecture Anchors

- `planning/design/protocol-schema.md#33-runresult`
