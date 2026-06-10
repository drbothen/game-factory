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
  - .factory/specs/domain-spec/failure-modes.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
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
    date: 2026-06-10
    reason: "F54-02 fix (option b) — golden capture postconditions updated to document the optional shadow tolerance_spec for T2 goldens, enabling coherent T2→T3 degradation (BC-3.03.004 EC-002). Without shadow tolerances, T2→T3 degradation blocks with E-REPLAY-002 (T3_DEGRADATION_MISSING_TOLERANCE_SPEC). Added EC-007 clarification for T2 shadow tolerance capture."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-3.03.008: Golden State Bootstrap and Invalidation Protocol

## Description

The golden state (reference snapshots or metrics against which regression is compared)
must be bootstrapped from an explicit, authorized baseline run, and must be invalidated
and re-captured when the game spec changes in a way that intentionally changes simulation
behavior. This BC governs: when golden state is first created, what constitutes a valid
golden state, who can authorize re-capture, and when the factory must block replay
regression because golden state is absent or invalidated. Without this protocol, the
regression system has no reliable baseline and produces noise.

## Preconditions

1. The adapter has `replay: full` or `replay: partial` and has passed conformance (CAP-002).
2. A golden-state bootstrap is either:
   (a) being initiated for the first time for this game+adapter pair, or
   (b) being re-initiated due to an authorized invalidation.

## Postconditions for Golden State Capture

1. An authorized agent (producer role or automated pipeline with producer-role token)
   initiates golden state capture at a named `golden_baseline_name` and records:
   - The `code_commit` at capture time
   - The `recording_id` used for the golden run
   - The `adapter_id` and `engine_version`
   - The `determinism_tier`
   - For T1: SHA-256 snapshot hashes at each checkpoint frame
   - For T2: serialized snapshot data at each checkpoint frame + `pinned_runner_image_id`;
     optionally, per-metric `tolerance_spec` (shadow tolerances) may be declared at capture
     time to enable T3 degradation if the pinned runner later becomes unavailable. Shadow
     tolerances are not required; if absent and the pinned runner is retired, T2→T3
     degradation blocks with E-REPLAY-002 (`T3_DEGRADATION_MISSING_TOLERANCE_SPEC`)
     per BC-3.03.004 EC-002.
   - For T3: metric values at each checkpoint frame + tolerance specs
   - `authorized_by`: the user or automation token that initiated capture
   - `captured_at` timestamp
   - `golden_state_id`: unique ID

2. The golden state record is written as immutable once sealed (same seal semantics as
   recording per BC-3.03.001 postcondition 3).

3. The golden state is associated with a specific `recording_id`; that recording is
   the canonical input for future replay regression runs against this golden state.

## Postconditions for Invalidation

1. An invalidation event occurs when one of these conditions is true:
   - A design-intent change explicitly modifies expected simulation behavior
     (e.g., enemy damage formula changed by design, not by bug)
   - The game spec version is bumped in a way that changes simulation correctness targets
   - The adapter's engine version changes beyond the compatibility window
   - An explicit invalidation is authorized by the producer role

2. When a golden state is invalidated:
   - Status is set to `invalidated`; reason is recorded.
   - Replay regression for this game+adapter pair is blocked with E-REPLAY-011
     (`GOLDEN_STATE_INVALIDATED`) until a new golden state is captured.
   - The invalidated record is retained for audit (not deleted).

3. When golden state is absent (never captured or invalidated with no replacement):
   - Replay regression returns E-REPLAY-012 (`GOLDEN_STATE_ABSENT`).
   - The `tests/replay` dimension is set to `blocked: golden_state_required`.
   - A checklisted task is generated: "Bootstrap golden state for [game_id] + [adapter_id]."

## Invariants

1. **Golden state absence is visible:** A missing golden state is never silently treated
   as `pass`. Absence produces a `blocked` dimension state, not a passing regression.
2. **Invalidation requires authorization:** Automated code changes cannot self-authorize
   golden state invalidation. An explicit producer-role decision is required to invalidate
   (the decision may be automated in a gated pipeline with producer-role token, but the
   decision logic must be declared).
3. **Golden state is immutable after sealing:** Once sealed, no field can be modified.
   Modifications require invalidation of the current golden state and creation of a new one.
4. **Recording used for golden state is pinned:** The `recording_id` associated with a
   golden state must remain accessible for as long as the golden state is valid. If the
   recording is deleted, the golden state is automatically invalidated.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | First pipeline run for a new game; golden state not yet captured | `GOLDEN_STATE_ABSENT`; bootstrap task generated; regression blocked. |
| EC-002 | Game spec updated with a deliberate balance change (enemy HP ×2 by design) | Producer invalidates golden state; re-capture required; regression blocked until new golden state captured and approved. |
| EC-003 | Code bug fixed: golden state was captured when the bug was present; now the "correct" state differs from golden | Producer must decide: the golden state is the baseline. If the fix is intentional, invalidate and re-capture. If the fix reveals a dormant bug in the golden, the same applies. |
| EC-004 | Automated pipeline attempts to re-capture golden state without producer-role token | Rejected: E-REPLAY-013 (`UNAUTHORIZED_GOLDEN_STATE_CAPTURE`). |
| EC-005 | Recording associated with a golden state is deleted (storage expiry) | Golden state automatically invalidated; `tests/replay` dimension blocked; task generated to re-capture recording + golden state. |
| EC-006 | Multiple golden states exist for the same game+adapter pair (history) | Only the most recent `active` golden state is used for regression. Prior golden states are retained as `superseded` for audit. |
| EC-007 | T2 adapter; golden state was captured on pinned runner A; pinned runner A is decommissioned | Golden state remains valid for history but T2 regression is no longer executable. If the golden was captured with shadow `tolerance_spec`, T2→T3 degradation proceeds per BC-3.03.004 EC-002. If no shadow tolerances were declared, degradation blocks with E-REPLAY-002 (`T3_DEGRADATION_MISSING_TOLERANCE_SPEC`). Resolution: update adapter's accepted record with a replacement pinned runner and re-capture golden, OR re-capture golden with shadow tolerances to unlock degradation path. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| First run for game G, adapter A; no golden state | E-REPLAY-012 (`GOLDEN_STATE_ABSENT`); bootstrap task generated; regression blocked. | happy-path (first run) |
| Producer bootstraps golden state at commit X; all checkpoints captured | Golden state created with status `active`; `golden_state_id` assigned; regression pipeline unlocked. | happy-path (bootstrap) |
| Design change: balance update; producer invalidates golden state | Status = `invalidated`; E-REPLAY-011 (`GOLDEN_STATE_INVALIDATED`) on next regression attempt; new bootstrap task generated. | happy-path (invalidation) |
| Automated agent attempts golden re-capture without producer token | E-REPLAY-013 (`UNAUTHORIZED_GOLDEN_STATE_CAPTURE`). | error (auth) |
| Associated recording deleted | Golden state auto-invalidated; dimension blocked. | edge-case |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-040 | Absent golden state never produces regression `pass` verdict. | unit test |
| VP-TBD-041 | Invalidated golden state blocks regression with `GOLDEN_STATE_INVALIDATED` error. | unit test |
| VP-TBD-042 | Golden state capture requires producer-role authorization; unauthorized capture is rejected. | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies the golden state lifecycle that CAP-003 references in "compares resulting simulation state against golden references." Golden state management is a necessary precondition for all comparison BCs (BC-3.03.003–005). |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed), DI-012 (Every ContractArtifact Has a Declared Validation Method) |
| L2 Failure Modes | FM-002 (Determinism Regression T1 Tier — golden state is the baseline that detects FM-002) |
| Architecture Module | SS-02 (Golden State Registry — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 1 (Golden sim state captured at designated checkpoints) |
| ADRs | ADR-0003 |

## Related BCs

- BC-3.03.003 — depends on (T1 comparison reads golden hashes)
- BC-3.03.004 — depends on (T2 comparison reads golden snapshots)
- BC-3.03.005 — depends on (T3 comparison reads golden metrics + tolerance specs)
- BC-3.03.001 — composes with (recording is captured alongside golden state)
- BC-3.03.006 — depends on (100% detection claim requires valid golden state)

## Architecture Anchors

- `architecture/SS-02-golden-state-registry.md` — Golden state schema, authorization, invalidation lifecycle

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-040 — absent golden never produces pass
- VP-TBD-041 — invalidated golden blocks regression
- VP-TBD-042 — producer-role authorization required
