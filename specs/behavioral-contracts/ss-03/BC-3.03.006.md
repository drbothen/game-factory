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
  - .factory/specs/domain-spec/differentiators.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
  - .factory/planning/research/aaa/qa-testing-liveops.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-02
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

# BC-3.03.006: Regression Detection at T1 (100-Percent Sensitivity for Injected Changes)

## Description

For T1 (bitwise-cross-platform) adapters, the replay regression pipeline detects 100% of
injected deterministic simulation changes at or before any configured checkpoint frame.
"Injected change" means any modification to the simulation code that produces a different
state at a checkpoint frame relative to the golden state, when replaying the same input
recording. This is the key success criterion from the product brief ("Injected sim
regression detected at T1 (bitwise): 100% on reference game") and is the foundation of
the replay-regression quality guarantee. It is achievable because T1 guarantees bitwise
identical simulation state for identical input + code — any code change that affects state
will change the hash.

## Preconditions

1. The adapter is T1 (`determinism_tier: bitwise-cross-platform`).
2. A golden state recording with snapshot hashes at configured checkpoint frames exists,
   captured at the known-good `code_commit_golden`.
3. A simulation code change has been applied at `code_commit_changed` — the code change
   produces a different simulation state at least at one frame at or before a checkpoint frame.
4. A replay has been run with the changed code against the same input recording (BC-3.03.002).
5. The hash comparison (BC-3.03.003) has produced a `regression_report`.

## Postconditions

1. For every simulation code change that produces different simulation state at or before
   a checkpoint frame: the `regression_report` verdict is `fail` with the earliest failing
   checkpoint identified.

2. For simulation code changes that produce no difference at any checkpoint frame (change
   is in a code path not exercised by the recording, or change only affects rendering):
   the `regression_report` verdict is `pass`. This is correct behavior (no simulation
   regression was introduced).

3. The checkpoint frame granularity is configurable. The maximum regression detection
   granularity equals the checkpoint interval (e.g., if checkpoints are every 10 frames,
   the system detects regressions to within 10 frames of their introduction).

4. The regression detection pipeline completes without manual intervention when run on CI:
   recording → replay → hash comparison → regression report is a fully automated pipeline.

## Invariants

1. **100% sensitivity at T1 for checkpointed state:** Given T1 guarantees, any simulation
   state change at a checkpoint frame produces a hash difference and is detected. There is
   no mechanism by which a state-affecting code change can produce a matching hash.
2. **Sensitivity is bounded by checkpoint density:** Only state changes at checkpoint frames
   are detected. A change that affects frames between checkpoints but resolves itself before
   the next checkpoint may not be detected. Operators must set checkpoint density appropriate
   to their regression requirements.
3. **False negative rate at T1 = 0% (for checkpointed state):** The hash comparison
   cannot produce a false `pass` for a genuine state difference at a checkpointed frame,
   given correct T1 simulation implementation.
4. **This guarantee is adapter-tier-specific:** The 100% sensitivity claim applies ONLY
   to T1 adapters. T2 and T3 adapters have lower sensitivity due to variance tolerance
   (T3) or runner constraints (T2).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Code change only affects a variable between checkpoints (change is transient; state recovers before next checkpoint) | `pass` (transient change not detectable; this is a checkpoint-density issue, not a T1 false negative). |
| EC-002 | Code change affects rendering shader, not simulation state | `pass` (rendering-only; simulation state identical). |
| EC-003 | Regression introduced in frame 1 (very early) | Detected at the first checkpoint frame after frame 1. |
| EC-004 | Multiple code changes in a single commit; some affect simulation, some don't | `fail` at the earliest checkpoint for the first state-affecting change; all other changes within the same replay are subsumed. |
| EC-005 | Checkpoint density is very low (e.g., only end-of-game state) | 100% detection for changes affecting the final state; changes between start and the checkpoint may not be detected if they resolve by the checkpoint. This is a configuration tradeoff. |
| EC-006 | T1 adapter's T1 guarantee is violated by an upstream engine bug (adapter was accepted as T1 but has a hash divergence) | FM-002: T1 regression. Detected when same code produces different hashes on two runs. Adapter tier must be downgraded. This is not a false negative of BC-3.03.006; it is an FM-002 event. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T1 Bevy+Rapier adapter; golden at commit A; replay at commit B where commit B changes enemy damage formula | `fail`; regression detected at first checkpoint after the damage formula is exercised. | regression detection (P0 target) |
| T1 adapter; commit B changes rendering color only | `pass`; simulation state hash unchanged. | no-regression (rendering-only) |
| T1 adapter; commit B introduces a 1-off in enemy health calculation at frame 5; checkpoint at frame 10 | `fail`; detected at frame 10. | regression detection (early) |
| T1 adapter; same commit as golden; replay | `pass`; all hashes match. | happy-path (baseline) |
| T1 adapter; commit B has transient change that resolves before checkpoint | `pass`; transient not detected (known limitation; acceptable at this checkpoint density). | edge-case (transient) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-034 | For T1 adapter: given a code change that produces different simulation state at frame F ≤ checkpoint, regression_report.verdict == `fail`. | integration test (inject known regression into reference game) |
| VP-TBD-035 | For T1 adapter: given same code as golden, regression_report.verdict == `pass`. | integration test (no-change baseline) |
| VP-TBD-036 | The 100% detection claim is validated by a test corpus: reference game with N injected regressions; all N detected at T1. | integration test (regression injection corpus) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC directly operationalizes the success criterion "Injected sim regression detected at T1 (bitwise): 100% on reference game" from the product brief §Success Criteria, which is the core quality guarantee of CAP-003. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed) |
| L2 Success Criterion | Brief §Success Criteria: "Replay-regression works: Injected sim regression detected at T1 (bitwise): 100% on reference game" |
| Architecture Module | SS-02 (Regression Comparator, CI Integration — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 full pipeline |
| ADRs | ADR-0003 |
| Differentiators | D-002 (Deterministic Replay Regression as First-Class Quality Gate) |

## Related BCs

- BC-3.03.003 — composes with (T1 hash comparison is the mechanism enabling this guarantee)
- BC-3.03.002 — depends on (replay must execute correctly for detection to work)
- BC-3.03.008 — depends on (golden state must exist and be valid)

## Architecture Anchors

- `architecture/SS-02-regression-comparator.md` — 100% sensitivity proof path (hash immutability + T1 guarantee)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-034 — regression detected for state-changing code changes
- VP-TBD-035 — no false positive for same-code replay
- VP-TBD-036 — injection corpus regression detection test
