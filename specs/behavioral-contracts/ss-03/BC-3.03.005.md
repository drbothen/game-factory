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
subsystem: SS-02
capability: CAP-003
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

# BC-3.03.005: T3 Tolerance-Window Metric Comparison (tolerance-only)

## Description

For adapters with `determinism_tier: tolerance-only` (T3, e.g., Godot with Jolt physics
or floating-point-heavy simulations), the replay regression comparison evaluates a set of
named game-state metrics against tolerance windows defined in the golden state. The
comparison does not require bitwise equality or a pinned runner; instead it checks that
each metric's value is within its declared tolerance band. A metric value outside its
tolerance window indicates a regression. This is the coarsest comparison tier and has
lower sensitivity to small perturbations, but it can run on any machine and handles the
inherent floating-point variance of T3 engines.

## Preconditions

1. The adapter's accepted record contains `determinism_tier: tolerance-only`.
2. A golden state recording exists with metric values at configured checkpoint frames.
3. Each metric in the golden state has an associated `tolerance_spec`:
   - `metric_name`: name of the metric (e.g., `enemy_position_x`, `player_health`,
     `entity_count_enemies`)
   - `tolerance_type`: `absolute` (±N units) or `relative` (±N%)
   - `tolerance_value`: the allowed deviation magnitude
4. The replay result (BC-3.03.002) is available with the same metrics captured at the
   same checkpoint frames.
5. Tolerance specs are declared in the golden state at golden-capture time; they are not
   retroactively adjusted after a regression is detected.

## Postconditions

1. For each checkpoint frame F and each metric M in the tolerance spec:
   - `delta = |replay_value(M, F) - golden_value(M, F)|`
   - For `absolute`: pass iff `delta <= tolerance_value`.
   - For `relative` with `golden_value != 0`: pass iff `delta / |golden_value| <= tolerance_value`.
   - For `relative` with `golden_value == 0`: pass iff `replay_value == 0`.
   - If pass: metric M at frame F = `pass`.
   - If fail: metric M at frame F = `fail`; record `golden_value`, `replay_value`, `delta`,
     `tolerance_spec`.

2. Overall verdict:
   - `pass`: all (metric, frame) pairs pass.
   - `fail`: at least one (metric, frame) pair fails. All failing pairs reported.

3. The regression report includes: per-metric per-frame results, tolerance specs applied,
   overall verdict, and `determinism_tier: tolerance-only` (to signal to consumers that
   this is the coarsest comparison method).

4. The comparison result is machine-independent (no runner constraint).

## Invariants

1. **Tolerance specs are golden-state-anchored:** Tolerances are set at golden-capture
   time and are immutable during comparison. They cannot be widened post-hoc to make a
   failing comparison pass.
2. **Metric catalog is exhaustive at capture time:** All metrics required for regression
   detection must be declared in the tolerance spec before the golden state is captured.
   A metric not in the tolerance spec produces no signal if it regresses.
3. **Fail is still a regression:** A T3 failure (metric outside tolerance) is a genuine
   regression signal. The tolerance window accounts for expected variance, not for
   unrelated bugs. Tolerances must be set conservatively enough to detect meaningful
   gameplay regressions.
4. **No tier inflation:** T3 results are clearly labelled `determinism_tier: tolerance-only`
   in all reports. They are never presented as equivalent to T1 hash-match results.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `golden_value = 0` for a relative-tolerance metric | Comparison uses `replay_value == 0` as pass condition (zero tolerance for zero baseline). |
| EC-002 | A metric regresses by exactly the tolerance value (delta == tolerance_value) | Pass (boundary is inclusive: `delta <= tolerance_value`). |
| EC-003 | A metric regresses by tolerance_value + ε (just outside tolerance) | Fail; delta logged. |
| EC-004 | A new metric exists in replay that was not in the golden tolerance spec | The new metric is captured but not evaluated (no tolerance spec exists for it). Logged as `unchecked_metric`. |
| EC-005 | An entity that existed in the golden state is absent from the replay state | The metric for that entity (e.g., `enemy_4_health`) has `replay_value = null`. Treated as out-of-tolerance fail. |
| EC-006 | T2 comparison degrades to T3 (pinned runner unavailable per BC-3.03.004 EC-002) | T3 comparison executed; result labeled `degraded_from_T2`; note added to convergence report. |
| EC-007 | All metrics pass but by design the tolerance is very wide (poor test sensitivity) | Passes; but the warning that T3 has lower sensitivity is in the comparison tier label. Tolerance spec quality is an authoring concern, not a BC concern. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T3 adapter; replay; `enemy_position_x` golden=100.0, replay=100.3, tolerance=±1.0 | Pass. | happy-path |
| T3 adapter; replay; `player_health` golden=100, replay=50, tolerance=±5 | Fail; delta=50 > tolerance=5. | regression detection |
| T3 adapter; `enemy_position_x` golden=0.0, tolerance=relative ±5% | Comparison: `replay_value == 0` as pass condition. | edge-case (zero baseline) |
| T3 adapter; delta == tolerance exactly | Pass (boundary inclusive). | edge-case |
| T3 adapter; metric `boss_health` present in replay but absent from tolerance spec | Logged as `unchecked_metric`; not evaluated. | edge-case |
| T3 degraded from T2 (pinned runner unavailable) | T3 comparison runs; result labeled `degraded_from_T2`. | edge-case (degradation) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-031 | For `absolute` tolerance: pass iff delta <= tolerance_value; fail otherwise. | proptest (exhaustive delta/tolerance pairs) |
| VP-TBD-032 | For `relative` tolerance with non-zero golden: pass iff delta/golden <= tolerance_value. | proptest |
| VP-TBD-033 | Tolerance spec is read from the golden state; no runtime tolerance modification is possible. | unit test / code review |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies "T3: tolerance-window" comparison behavior, which is the T3 tier clause in CAP-003's tier-degraded comparison description, grounded in ADR-0003's `tolerance-only` tier. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed) |
| Architecture Module | SS-02 (Regression Comparator — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 2-3 (T3 path: any machine + tolerance-window comparison) |
| ADRs | ADR-0003 (T3 = `tolerance-only`; regression method = tolerance-window metric diff) |

## Related BCs

- BC-3.03.002 — depends on (replay produces metrics at checkpoint frames)
- BC-3.03.003 — related to (T1 counterpart, higher sensitivity)
- BC-3.03.004 — related to (T2 degrades to T3 when pinned runner unavailable)
- BC-3.03.008 — depends on (golden state holds tolerance specs)

## Architecture Anchors

- `architecture/SS-02-regression-comparator.md` — Tolerance window evaluation, metric schema

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-031 — absolute tolerance boundary
- VP-TBD-032 — relative tolerance boundary
