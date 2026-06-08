---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
  - .factory/planning/research/aaa/qa-testing-liveops.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-003
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

# BC-3.03.003: T1 Exact Snapshot-Hash Comparison (bitwise-cross-platform)

## Description

For adapters with `determinism_tier: bitwise-cross-platform` (T1, e.g., Bevy+Rapier),
the replay regression comparison is an exact SHA-256 hash comparison of the full
simulation state snapshot at each configured checkpoint. If the replay snapshot hash
at any checkpoint differs from the golden snapshot hash, a regression is detected. The
comparison must produce the same result on any OS, CPU architecture, or machine — the
bitwise cross-platform guarantee eliminates runner variance as a false-positive source.
This provides 100% sensitivity for any deterministic change in simulation state at a
checked checkpoint frame.

## Preconditions

1. The adapter's accepted record contains `determinism_tier: bitwise-cross-platform`.
2. A golden state recording exists with sealed snapshot hashes at configured checkpoint frames.
3. A replay result (BC-3.03.002) is available from a run on the same recording.
4. The replay was executed on any machine (T1 does not require a pinned runner).
5. The golden state was produced by a prior accepted run at a known-good `code_commit`.

## Postconditions

1. For each checkpoint frame F present in both the golden state and the replay result:
   - The comparison function computes SHA-256 of the replay snapshot at F.
   - It compares to the golden snapshot hash for F.
   - If hashes are equal: checkpoint F = `pass`.
   - If hashes differ: checkpoint F = `fail`; diff detail includes: frame number, golden hash, replay hash, the changed simulation fields (from state deserialization).

2. The overall comparison result is:
   - `pass`: all checkpoint hashes match.
   - `fail`: at least one checkpoint hash differs. The earliest failing frame is reported.

3. The comparison result is independent of the machine that ran the replay — the same
   comparison result is produced on any OS/CPU for the same recording+golden+code_commit
   triple.

4. A `regression_report` is produced containing: recording_id, golden_state_version,
   code_commit, determinism_tier, per-checkpoint results, overall verdict, timestamp.

## Invariants

1. **Hash algorithm fixed:** The snapshot hash algorithm is SHA-256 (fixed, not configurable
   at runtime). A different hash algorithm requires a new BC version.
2. **Cross-platform determinism of the hash:** The snapshot serialization format is
   canonical (big-endian, sorted keys for maps, no floating-point-variance-introducing
   transforms). The hash of the same simulation state must be identical on all platforms.
3. **All checkpoints must match for pass:** A single differing checkpoint produces a
   `fail` verdict regardless of how many checkpoints matched.
4. **Golden hash is immutable:** The golden snapshot hashes are computed at golden-capture
   time and stored with the recording. They are never recomputed from current state during
   comparison.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Replay snapshot at frame F has one-bit difference from golden (injected regression) | `fail` at frame F; regression detected. |
| EC-002 | Checkpoint frames in golden and replay do not perfectly align (e.g., golden has frame 50 but replay only has frame 49) | `CHECKPOINT_MISMATCH` warning; comparison only on intersecting frames; if divergence exists, may be missed. Non-intersecting golden frames flagged. |
| EC-003 | Simulation snapshot is very large (millions of entities) | Hash computed on the canonical serialization of the full state; no partial hash. Performance may require snapshot streaming — but correctness is not affected. |
| EC-004 | Comparison run on a different OS than golden capture | Result must be identical (this is the T1 guarantee). If it is not, the adapter's T1 claim is invalid and must be downgraded. |
| EC-005 | Code change that only affects rendering, not simulation state | Simulation snapshot hash unchanged; `pass`. Rendering-only changes do not produce false regressions. |
| EC-006 | Multiple checkpoint frames all fail | Report shows all failing frames; earliest frame identified as regression introduction point. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T1 adapter; replay on same commit as golden; all checkpoint hashes match | `pass`; all checkpoints green. | happy-path |
| T1 adapter; replay with injected enemy HP bug at frame 30; checkpoint at frame 50 differs | `fail`; frame 50 diff reported; golden_hash != replay_hash. | regression detection |
| T1 adapter; same code; replay on Linux vs golden on macOS | `pass`; identical hashes (bitwise-cross-platform guarantee). | happy-path (cross-platform) |
| T1 adapter; rendering change only (no sim logic); replay vs golden | `pass`; sim snapshots identical. | edge-case (rendering-only change) |
| T1 adapter; one-bit flip in a single entity health value | `fail`; detected at the earliest checkpoint after frame of the flip. | regression detection (minimal injection) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-025 | T1 comparison produces identical result on Linux x86-64, macOS arm64, and Windows x86-64 for the same snapshot. | CI matrix integration test |
| VP-TBD-026 | Any deterministic state change at or before a checkpoint produces a hash difference (100% sensitivity at checkpoints). | proptest with injected state mutations |
| VP-TBD-027 | Rendering-only changes do not change the simulation snapshot hash. | integration test (rendering patch with no sim logic change) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies "T1: exact snapshot-hash" comparison behavior, which is the T1 tier clause in CAP-003's description of tier-degraded comparison methods. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed) |
| Architecture Module | SS-TBD (Regression Comparator — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 3 (Diff Evaluation — T1 path) |
| ADRs | ADR-0003 (T1 = `bitwise-cross-platform`; regression comparison method = exact snapshot-hash diff) |

## Related BCs

- BC-3.03.002 — depends on (replay produces the snapshots compared here)
- BC-3.03.006 — composes with (100% regression detection claim built on this comparison)
- BC-3.03.008 — depends on (golden state provides reference hashes)

## Architecture Anchors

- `architecture/SS-TBD-regression-comparator.md` — SHA-256 snapshot hash, canonical serialization format

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-025 — cross-platform identical comparison
- VP-TBD-026 — 100% sensitivity for deterministic changes at checkpoints
