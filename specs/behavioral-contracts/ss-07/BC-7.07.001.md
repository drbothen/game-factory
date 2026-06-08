---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-007
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

# BC-7.07.001: Perf-Budget Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #7: perf-budget. This
dimension verifies that the game meets declared CPU frame-time, GPU frame-time,
memory-soak, and thermal budget thresholds from the `perf-budget-contract`. CPU-
bound gates run in CI (headless, no GPU). GPU-bound gates require on-hardware
execution with the `render` execution profile. XR games add per-eye frame-time,
reprojection-%, and motion-to-photon latency budgets — each requiring on-device
measurement with XR hardware.

## Preconditions

1. The `perf-budget-contract` artifact exists with declared thresholds for:
   - CPU frame-time (ms per frame at declared target platform)
   - 1% and 0.1% low frame-times (percentile lows)
   - Memory soak (peak heap + VRAM at declared scenario)
   - Thermal envelope (TDP % ceiling at sustained load)
   - (XR only) per-eye frame-time, reprojection-% ceiling, motion-to-photon
     ceiling (<20ms, per Meta VRC.Quest.Performance.1: ≥60fps / ≥30fps with AppSW)
2. A profiler integration is available that can export CPU/GPU/memory metrics to
   machine-readable format for the declared target hardware.
3. For GPU/XR gates: a physical device with the `render` execution profile is
   available in CI or in the on-hardware test environment.

## Postconditions

1. **GREEN (CI, CPU-bound):** CPU frame-time, 1%/0.1%-low, and memory-soak are
   within declared thresholds on the CI runner.
2. **GREEN (on-hardware, GPU-bound):** GPU frame-time is within declared threshold
   on the declared target GPU hardware, measured via the profiler integration.
3. **GREEN (on-device, XR):** Per-eye frame-time ≤ declared ceiling, reprojection-
   % ≤ declared ceiling, motion-to-photon ≤ 20ms on declared XR device.
4. **DEGRADED (GPU gate pending):** CPU gate is GREEN; GPU hardware not yet
   scheduled. Dimension is DEGRADED-PENDING; GPU gate must complete before GREEN.
5. **DEGRADED (XR gate pending):** XR hardware not available; XR perf gate is
   pending. DEGRADED until on-device run is completed.
6. **BLOCKED:** CPU frame-time exceeds declared threshold in CI. Memory soak
   exceeds limit. Any metric exceeds a `deny` threshold (vs a `warn` threshold).

## Invariants

1. CPU perf gates always run in CI — they do not require on-hardware.
2. GPU and XR perf gates require physical hardware with the `render` profile.
   They cannot be approximated by CPU emulation.
3. The `perf-budget-contract` is the single source of thresholds — the factory
   does not auto-tune thresholds to fit observed performance.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | CPU frame-time 1% low exactly equals declared threshold | GREEN — threshold is inclusive boundary |
| EC-002 | Memory soak exceeds threshold during level-load spike but not sustained | The perf-budget-contract declares whether soak is measured at peak or at steady-state; contract governs |
| EC-003 | XR game but XR hardware unavailable in CI | DEGRADED-PENDING; advisory: "XR perf gate requires on-device run on [device]; not yet scheduled" |
| EC-004 | Performance regression introduced by a dependency update | BLOCKED; regression must be resolved or the `perf-budget-contract` thresholds must be intentionally updated |
| EC-005 | GPU metrics not exportable from the engine adapter | DEGRADED (metrics unavailable); advisory; GPU gate is best-effort until profiler integration is wired |
| EC-006 | XR reprojection-% measured at 45% against ceiling of 20% | BLOCKED; exceeds ceiling; cannot ship with reprojection at this rate per VRC.Quest.Performance.1 |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| CPU frame=12ms (threshold=16ms); mem=1.2GB (threshold=2GB) | perf-budget = GREEN | happy-path |
| CPU frame=18ms (threshold=16ms) | perf-budget = BLOCKED; "CPU frame-time 18ms exceeds budget 16ms" | error |
| XR game; CPU GREEN; GPU hardware pending | perf-budget = DEGRADED-PENDING (GPU gate pending) | edge-case |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-026 | Dimension is BLOCKED if any declared `deny` threshold is exceeded | kani (threshold comparison function: metric > deny_threshold → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #7 (perf-budget) |
| L2 Domain Invariants | DI-012 |
| Architecture Module | convergence-tracker / perf-gate (SS-TBD) |
| Stories | S-TBD |

## Related BCs

- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-TBD-convergence-tracker.md`

## Story Anchor

S-TBD — Perf-Budget Convergence Dimension
