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
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/processes.md
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
modified:
  - version: "1.2"
    date: 2026-06-08
    reason: "F37-03 fix — corrected VP-008 back-reference to accurately describe what VP-008 proves (intra-process purity of pure-sim step function), distinguishing it from the T1 bitwise cross-platform guarantee which is validated by the conformance suite (BC-3.03.003)."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-3.03.001: Input Stream Recording Keyed by Sim Frame

## Description

During a game run, the replay recorder captures a complete, ordered input stream where
every discrete input event (player action, AI command, RNG seed invocation, network
message receive) is tagged with the sim frame tick number at which it occurred. The
resulting recording is a deterministic description of everything external to the simulation
that affected its state, keyed by frame. This recording is the ground truth for all
subsequent replay and regression operations (BC-3.03.002 through BC-3.03.008). Recording
does not modify simulation behavior.

## Preconditions

1. The adapter under record declares `replay: full` or `replay: partial` in its
   `engineCapabilities` manifest (recording is not possible for `replay: none`).
2. The adapter exposes the three replay prerequisites: (a) fixed-timestep tick, (b)
   seeded/injectable RNG, (c) input injection points at tick boundaries (ADR-0003).
3. A game session is running or about to run in a mode that enables recording.
4. The recording session is assigned a unique `recording_id` before the session starts.
5. The game's `initial_rng_seed` is captured before the first tick.

## Postconditions

1. For every sim frame tick F during the recorded session:
   - All input events that occurred at tick F are captured with: event type, event payload,
     tick number F, and event source (player input, AI, network, RNG-seed-fork).
   - The tick F record is written to the recording stream before tick F+1 begins processing.

2. The recording includes a header with: `recording_id`, `game_id`, `adapter_id`,
   `engine_version`, `determinism_tier`, `initial_rng_seed`, `tick_rate_hz`,
   `start_frame`, `end_frame`.

3. The recording is a complete, append-only stream: no tick F entry is modified after it
   is written. The stream is sealed at session end with a `recording_sealed` event
   containing a checksum of the entire stream.

4. Recording does not add or remove ticks from the simulation; the tick schedule is
   identical to an unrecorded run.

5. The sealed recording is accessible via a stable `recording_id` URI for replay
   and regression operations.

## Invariants

1. **Frame-keyed completeness:** Every input event that affects simulation state must be
   recorded. An event that affects sim state but is not recorded is a recording defect
   that will cause replay divergence.
2. **Tick boundary discipline:** All inputs for frame F are recorded atomically as the
   frame-F record before F+1 begins. No input for frame F is recorded after frame F+1
   has started.
3. **Immutability after seal:** A sealed recording is immutable. Any modification attempt
   after sealing is rejected with an error and the recording is marked `tampered`.
4. **Non-interference:** Recording adds no determinism-affecting side effects to the
   simulation. If the simulation produces hash H without recording, it must produce the
   same hash H with recording (on a T1 adapter).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Zero input events in a tick (no player input that tick) | Tick record written with empty events list. Frame number is still recorded. |
| EC-002 | Recording process crashes mid-session | Partial recording marked `incomplete`; cannot be used for regression (only for diagnostic). End frame = last successfully written tick. |
| EC-003 | Multiple simultaneous input sources in the same tick (player + AI + network) | All sources recorded in deterministic order within the tick record. Order is fixed (e.g., by source type enum). |
| EC-004 | RNG seed fork (new RNG stream spawned during gameplay) | Fork event recorded with: parent RNG ID, child RNG ID, child seed, fork tick. |
| EC-005 | Very long session (10,000+ frames) | Recording stream is chunked into fixed-size segments; seal checksum covers all segments. |
| EC-006 | Adapter declares `replay: partial`; recording still attempted | Recording proceeds; but per BC-2.02.003 the adapter's replay fidelity is `partial`. Recording completeness may be limited to the partial-tier input sources only; documented in recording header as `fidelity: partial`. |
| EC-007 | Recording is requested on an adapter with `replay: none` | Recording returns E-REPLAY-008 (`REPLAY_CAPABILITY_NONE`); no recording started. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| 100-frame game session, Bevy T1 adapter, 5 player input events at frames 10, 20, 30, 40, 50 | Recording with 100 tick records; 5 have non-empty events; sealed with checksum. | happy-path |
| 100-frame session; no input events | Recording with 100 tick records all with empty events; valid sealed recording. | edge-case (no input) |
| Request recording on adapter with `replay: none` | E-REPLAY-008 (`REPLAY_CAPABILITY_NONE`); no recording file created. | error |
| RNG seed fork at frame 42 | Frame 42 record contains: player events (if any) + RNG-fork event with parent/child/seed. | edge-case |
| Session with 10,000 frames; all frames recorded | Chunked recording with seal covering all chunks; accessible via `recording_id`. | edge-case (large) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-019 | Non-interference: T1 adapter simulation hash is identical with and without recording enabled. | proptest (run N times with/without recording, compare hashes) |
| VP-TBD-020 | Every input event present in an unrecorded run is present in the recorded stream at the correct tick. | integration test with known-input scenario |
| VP-TBD-021 | Sealed recording is immutable: modification attempt after sealing returns error and marks recording `tampered`. | unit test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies the input stream recording step that CAP-003 describes as "records game input streams keyed by simulation frame," which is the first stage of the replay-regression pipeline. |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed), DI-012 (Every ContractArtifact Has a Declared Validation Method) |
| Architecture Module | SS-02 (Replay Recorder — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 1 (Input Recording) |
| ADRs | ADR-0003 (determinism tier + three replay prerequisites) |

## Related BCs

- BC-3.03.002 — depends on (replay uses the recording produced here)
- BC-3.03.003, BC-3.03.004, BC-3.03.005 — depends on (tier-specific comparison uses recording)
- BC-3.03.006 — depends on (regression detection uses recording)
- BC-3.03.008 — composes with (golden state is captured alongside recording)

## Architecture Anchors

- `architecture/SS-02-replay-recorder.md` — Recording stream format, tick-keyed event schema
- `.factory/planning/decisions/0003-determinism-tier-capability.md` — Three replay prerequisites

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-019 — non-interference with simulation hash
- VP-TBD-020 — input event completeness
- Formally verified by VP-008 (Pure-sim step referential transparency — intra-process purity of the pure-sim step function) — see verification-properties/VP-008-replay-determinism-equality.md. Note: VP-008 does NOT verify the T1 bitwise CROSS-PLATFORM equality guarantee; that guarantee is validated by the conformance suite (BC-3.03.003 EC-004).
