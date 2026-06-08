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

# BC-1.07.002: runHeadless Timeout and Crash Are Distinguished Exit Statuses

## Description

The `RunResult.exitStatus` field unambiguously distinguishes three exit conditions:
`"clean"` (game completed normally), `"crashed"` (game process exited with error),
and `"timeout"` (wall-clock limit elapsed). These distinct statuses enable the
factory to apply different remediation strategies: crashes trigger root-cause
analysis and may block convergence; timeouts trigger investigation of infinite loops
or performance regressions; clean exits proceed to downstream analysis.

## Preconditions

1. A `runHeadless` invocation has completed.
2. The game process has terminated by one of three means: natural exit, crash, or
   wall-clock timeout.

## Postconditions

1. `exitStatus: "clean"` if and only if the game process exited with code 0 within
   the tick/timeout bounds.
2. `exitStatus: "crashed"` if and only if the game process exited with a non-zero
   exit code (panic, exception, assert failure) regardless of elapsed time.
3. `exitStatus: "timeout"` if and only if `durationMs >= timeoutMs` and the game
   process had to be forcibly terminated.
4. No other value for `exitStatus` is valid.
5. When `exitStatus: "crashed"`, the `log` field contains whatever output the
   process emitted before crashing (including panic message for Rust/Bevy,
   exception trace for Unity/Godot).

## Invariants

1. Exactly one of {clean, crashed, timeout} is always returned; the statuses are
   mutually exclusive.
2. A process that times out is always forcibly killed before the response is sent.
3. `exitStatus: "clean"` is never returned if the process exited non-zero.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game exits with code 0 but emitted error logs | `exitStatus: "clean"` (exit code is authoritative); log contains the error output for inspection |
| EC-002 | Game exits with code 1 at exactly the timeout boundary | `exitStatus: "crashed"` (non-zero exit code takes priority over timeout) |
| EC-003 | Game process cannot be killed after timeout (stuck in kernel) | Adapter logs an error; marks `exitStatus: "timeout"` and proceeds after a secondary kill timeout (e.g., SIGKILL after SIGTERM fails) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Game exits cleanly after 3600 ticks | `exitStatus: "clean"`, `ticks: 3600` | happy-path |
| Game panics with `thread 'main' panicked at 'index out of bounds'` | `exitStatus: "crashed"`, `log` contains panic message | error |
| Game runs indefinitely; `timeoutMs: 5000` expires | `exitStatus: "timeout"`, `durationMs: >=5000` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-028 | exitStatus is always one of {clean, crashed, timeout} | schema validation |
| VP-TBD-029 | clean implies exit code 0; crashed implies exit code != 0 | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — distinct exit status codes are required for the factory pipeline to apply correct remediation per failure mode |
| L2 Domain Invariants | DI-001 |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.07.001 — depends on (RunResult schema)

## Architecture Anchors

- `planning/design/protocol-schema.md#33-runresult`
