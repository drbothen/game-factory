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

# BC-3.03.004: T2 Pinned-Runner Snapshot Diff (same-machine)

## Description

For adapters with `determinism_tier: same-machine` (T2, e.g., Unity PhysX with Enhanced
Determinism), the replay regression comparison is a full simulation state snapshot diff
executed on the same pinned CI runner image that was used to produce the golden state.
The comparison detects state changes between the golden run and the replay. Because T2
determinism is only guaranteed on the same machine configuration, the pinned-runner
constraint eliminates cross-machine floating-point variance from producing false positives.
Variance detected within the pinned runner is a genuine regression signal.

## Preconditions

1. The adapter's accepted record contains `determinism_tier: same-machine`.
2. The adapter's accepted record specifies a `pinned_runner_image_id` (CI runner image ID
   used for golden capture and required for regression replay).
3. A golden state recording with snapshot data exists at configured checkpoint frames,
   captured on `pinned_runner_image_id`.
4. The replay (BC-3.03.002) was executed on a runner matching `pinned_runner_image_id`.
5. The golden state was produced at a known-good `code_commit`.

## Postconditions

1. The comparison runner verifies that the replay was executed on a runner matching
   `pinned_runner_image_id` before proceeding. If the runner does not match, comparison
   is flagged `runner_mismatch: true` and treated as informational only (not a gate-blocking
   regression result).

2. For each checkpoint frame F present in both golden and replay:
   - The comparison function produces a structured diff of the deserialized simulation
     state snapshots at frame F.
   - The diff lists: added fields, removed fields, changed fields (with golden value and
     replay value for each).
   - If diff is empty: checkpoint F = `pass`.
   - If diff is non-empty: checkpoint F = `fail`; diff details recorded.

3. Overall verdict:
   - `pass`: all checkpoint diffs are empty.
   - `fail`: at least one checkpoint has non-empty diff. Earliest failing frame reported.

4. The regression report includes: `pinned_runner_image_id`, `runner_match: true/false`,
   per-checkpoint diff details, overall verdict, and `runner_mismatch` caveat if applicable.

## Invariants

1. **Runner pin enforcement:** Regression results from a non-matching runner are flagged
   and excluded from gating decisions. The factory never uses off-runner T2 comparison as
   a blocking quality gate.
2. **Same pinned runner for golden and replay:** The golden state must have been captured
   on the same `pinned_runner_image_id` that will be used for regression replay. A golden
   state captured on a different runner is not valid for T2 comparison.
3. **Structured diff, not hash:** T2 comparison uses a field-by-field structured diff, not
   a hash, because cross-platform hash equality is not guaranteed for T2. The diff provides
   richer diagnostic information than a hash.
4. **Pinned runner image is immutable:** The `pinned_runner_image_id` in the adapter's
   accepted record is the canonical runner for that adapter version. Runner image updates
   require re-running golden capture on the new image and updating the accepted record.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Replay run on wrong runner (different CPU arch than pinned) | Result flagged `runner_mismatch: true`; excluded from gating. Warning emitted. |
| EC-002 | Pinned runner image is retired or unavailable | Regression test cannot run on pinned runner; degrades to T3 tolerance comparison with note in convergence report. |
| EC-003 | Code change in physics integration produces different SIMD rounding on the pinned runner | Detected as diff; regression `fail` reported. |
| EC-004 | T2 adapter's golden was captured on pinned runner but the comparison runner has same CPU but different OS minor version | Runner match check uses `pinned_runner_image_id`; OS minor version difference = mismatch unless explicitly in the pinned image spec. |
| EC-005 | Floating-point value differs between runs on the same pinned runner (non-determinism on T2) | Detected as diff; signals that the T2 adapter has intra-runner non-determinism. Adapter re-conformance required; potential tier downgrade to T3. |
| EC-006 | Checkpoint has 1,000 differing fields | All fields listed in the diff; no truncation. Report may be large but must be complete. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T2 adapter; replay on pinned runner; same code as golden; no state change | `pass`; all diffs empty; `runner_match: true`. | happy-path |
| T2 adapter; replay on pinned runner; enemy AI pathfinding bug at frame 60 | `fail`; checkpoint at frame 100 shows diff on enemy position fields. | regression detection |
| T2 adapter; replay on non-pinned runner | `runner_mismatch: true`; result informational only; not a gate block. | edge-case |
| Pinned runner unavailable; T2 replay attempted | Degrade to T3; note in convergence report. | edge-case (degradation) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-028 | T2 comparison on non-matching runner never produces a gate-blocking regression result. | integration test |
| VP-TBD-029 | T2 comparison on matching runner detects state change equivalent to the injected simulation bug. | integration test with known injected regression |
| VP-TBD-030 | When pinned runner is unavailable, the system degrades to T3 without blocking on T2 runner requirement. | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies "T2: pinned-runner" comparison behavior, which is the T2 tier clause in CAP-003's tier-degraded comparison method description, grounded in ADR-0003's `same-machine` tier definition. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed) |
| Architecture Module | SS-TBD (Regression Comparator, CI Runner Registry — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 2-3 (T2 path: pinned runner + snapshot diff) |
| ADRs | ADR-0003 (T2 = `same-machine`; regression method = snapshot diff on pinned runner) |

## Related BCs

- BC-3.03.002 — depends on (replay produces snapshots on pinned runner)
- BC-3.03.003 — related to (T1 uses hash; T2 uses structured diff)
- BC-3.03.005 — related to (T2 can degrade to T3 when pinned runner unavailable)
- BC-3.03.008 — depends on (golden state pinned runner captured here)

## Architecture Anchors

- `architecture/SS-TBD-regression-comparator.md` — Structured diff algorithm, pinned runner validation

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-028 — runner-mismatch never blocks gate
- VP-TBD-029 — pinned-runner regression detection
