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

# BC-3.03.002: Deterministic Replay Execution with Identical Tick Schedule

## Description

Given a sealed input recording (BC-3.03.001) and the simulation code at a specified commit,
the replay engine re-runs the simulation by injecting the recorded input events at their
recorded tick numbers. The tick schedule (fixed timestep, total frame count) must be
identical to the original recording. The replay engine does not introduce any new inputs,
does not skip ticks, and does not vary the RNG seed from the recorded initial seed. The
result of the replay is a simulation state trace that can be compared to golden state per
the adapter's determinism tier (BC-3.03.003 through BC-3.03.005).

## Preconditions

1. A sealed, non-`tampered`, non-`incomplete` input recording for the game exists with a
   known `recording_id`.
2. The simulation code to replay against is available at a specified `code_commit`.
3. The adapter used for replay is the same adapter family as the recording (same engine,
   compatible version per BC-2.02.004 versioning semantics).
4. The adapter's `determinism_tier` is known from its accepted record (DI-004).
5. The adapter declares `replay: full` or `replay: partial`.
6. The replay environment satisfies the tier constraints:
   - T1: any machine (bitwise-cross-platform)
   - T2: the pinned CI runner image specified in the adapter's accepted record
   - T3: any machine (tolerance-window comparison used)

## Postconditions

1. The replay engine initializes the simulation with the recording's `initial_rng_seed`
   and `tick_rate_hz` — identical to the original run.

2. For each frame F from `start_frame` to `end_frame` in the recording:
   - All input events from the recording's frame-F record are injected into the simulation
     at tick F.
   - No additional inputs are injected.
   - The tick is processed.

3. After each configured checkpoint frame, the simulation state is captured as a state
   snapshot.

4. The replay run completes without crashing.

5. The replay engine produces a `replay_result` record containing:
   - `recording_id`, `code_commit`, `adapter_id`, `engine_version`, `determinism_tier`
   - Per-checkpoint state snapshots (or snapshot hashes, depending on tier)
   - Replay start/end timestamps
   - Any errors or anomalies encountered

## Invariants

1. **Identical tick schedule:** The number of ticks executed in replay equals the number of
   ticks in the recording (`end_frame - start_frame + 1`). No ticks may be added or removed.
2. **No new inputs:** The replay engine must not inject any input not present in the
   recording. External input sources (user keyboard, network) are fully disconnected during
   replay.
3. **Seed fidelity:** The initial RNG seed and all recorded RNG seed forks are applied at
   the exact ticks they occurred in the recording.
4. **Engine version range:** Replay is only valid against the same engine version (or a
   minor-version range defined in the compatibility matrix). Replaying a recording from
   engine version X against engine version Y where Y is outside the valid range produces
   an `INCOMPATIBLE_REPLAY_ENGINE_VERSION` error, not a false regression signal.
5. **Tier constraint enforcement:** T2 replay on a non-pinned runner is allowed but the
   result is flagged `runner_not_pinned: true` and treated as informational (not a
   gate-blocking regression result).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Recording has a gap in frame numbers (frame 50 missing) | Replay aborted; error `RECORDING_FRAME_GAP`; result is invalid for regression use. |
| EC-002 | Simulation crashes during replay at frame N | Replay result marked `replay_crashed_at_frame: N`; all snapshots up to N retained; treated as regression signal (crash was not present in original). |
| EC-003 | External input source fires during replay (user presses key) | External inputs filtered and discarded; not injected into simulation. |
| EC-004 | Replaying against a different engine minor version than recording | Compatibility check per BC-2.02.004 semantics; proceed if within range; error if out of range. |
| EC-005 | Checkpoint configuration requests snapshots at every frame (full trace) | All frames captured; replay result is large but valid. |
| EC-006 | Recording has `fidelity: partial` | Replay proceeds at partial fidelity; comparison tier adjusted accordingly per BC-3.03.005. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Recording: 100 frames, 5 input events; code at commit A | Replay result: 100 ticks executed, 5 inputs injected at recorded frames, checkpoints captured. No crash. | happy-path |
| Recording with frame gap (frame 50 absent) | Error `RECORDING_FRAME_GAP`; replay aborted; no result usable for regression. | error |
| External keyboard input fires during replay | Input discarded; simulation state unaffected by external input. | edge-case |
| Replay requested for T2 adapter on non-pinned runner | Replay proceeds; result flagged `runner_not_pinned: true`. | edge-case |
| Recording from engine v0.15; replay with engine v0.16 (in-range per matrix) | Replay proceeds with compatibility note in result. | edge-case |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-022 | Replay injects exactly the inputs from the recording at the recorded frame numbers (no extras, no omissions). | integration test with known-input recording |
| VP-TBD-023 | Replay executes exactly `end_frame - start_frame + 1` ticks. | unit test / proptest |
| VP-TBD-024 | T1 replay on same code commit as recording produces identical simulation state at every checkpoint (bitwise identical). | integration test (T1 adapter reference game) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies "replays them deterministically," the core replay execution step that CAP-003 names as the second stage of the replay-regression pipeline. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed) |
| Architecture Module | SS-02 (Replay Engine — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 2 (Tier-Appropriate Replay) |
| ADRs | ADR-0003 (three replay prerequisites: fixed-timestep tick, seeded RNG, input injection) |

## Related BCs

- BC-3.03.001 — depends on (recording produced here is the input)
- BC-3.03.003 — depends on (T1 hash comparison uses replay snapshots)
- BC-3.03.004 — depends on (T2 diff comparison uses replay snapshots)
- BC-3.03.005 — depends on (T3 tolerance comparison uses replay metrics)
- BC-3.03.006 — depends on (regression detection uses replay result)

## Architecture Anchors

- `architecture/SS-02-replay-engine.md` — Tick schedule enforcement, input injection, external-input filtering

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-022 — replay input fidelity
- VP-TBD-023 — exact tick count
- VP-TBD-024 — T1 bitwise identical snapshots (same commit)
- Formally verified by VP-008 (Replay determinism equality — T1 bitwise snapshot hash) — see verification-properties/VP-008-replay-determinism-equality.md
