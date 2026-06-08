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
  - .factory/specs/domain-spec/processes.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
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

# BC-3.03.007: Replay-None Graceful Degradation to Playtest Evidence

## Description

When an adapter declares `replay: none` (it lacks a fixed-timestep tick, injectable RNG,
or input injection at tick boundaries), the replay-regression dimension is unavailable for
that adapter. The factory gracefully degrades the `tests/replay` convergence dimension for
that adapter to `human-playtest-evidence-required` — requiring manual playtest sign-off in
place of automated regression. This is not a factory error; it is the correct behavior for
a class of engines that cannot support automated regression. The degradation is declared
and visible in the convergence report; it is never silent.

## Preconditions

1. The adapter's manifest declares `replay: none`.
2. A production workflow that would normally run replay regression is dispatched for this
   adapter.
3. The 11-dimension convergence model's `tests/replay` dimension is being evaluated.

## Postconditions

1. The replay-regression pipeline is not invoked for this adapter. No recording is
   attempted, no replay is executed, no regression comparison is run.

2. The `tests/replay` convergence dimension for this game+adapter pair is set to status
   `degraded: human-playtest-evidence-required`.

3. A human-gated task is generated per DI-006: "Replay-regression unavailable for adapter
   [adapter_id]; manual playtest evidence required for tests/replay convergence dimension."
   The task specifies: what evidence is required, who must provide it, and what the
   acceptance criterion is.

4. The convergence report clearly labels the `tests/replay` dimension as `degraded` with
   reason `replay_none` and the adapter ID. It does not mark this dimension as `pass` or
   hide the degradation.

5. Release is not blocked by the absence of automated replay regression, provided the
   human-gated playtest task is completed and the dimension is marked `degraded` with
   explicit acceptance.

6. If a `replay: none` adapter is later upgraded to `replay: partial` or `replay: full`
   and passes conformance, the `tests/replay` dimension automatically upgrades from
   `degraded` to the appropriate automated regression method on the next run.

## Invariants

1. **Degradation is always explicit:** A `replay: none` adapter never silently produces a
   `pass` for the `tests/replay` dimension. Silence is not success.
2. **Human gate surfaced per DI-006:** The human-gated task is always generated when
   `replay: none` is detected. It cannot be suppressed by factory configuration.
3. **No automated score replaces human evidence:** When degraded, an automated fallback
   metric (e.g., crash rate, CI test coverage) may supplement but never replaces the
   human playtest gate for this dimension. (DI-007 principle applied here.)
4. **Degradation is per adapter-game pair:** Degradation of `tests/replay` for one
   adapter does not affect other adapters' replay regression pipelines.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter has `replay: none` but a prior golden state exists (adapter was previously `replay: partial`) | Golden state is retained for archival; new regression run is not executed; dimension is degraded with note that prior golden state exists but is not usable with current `replay: none`. |
| EC-002 | Human-gated playtest evidence is provided and marked complete | `tests/replay` dimension status updated to `degraded: accepted` with human sign-off artifact reference. Release gate satisfied for this dimension. |
| EC-003 | Game has `replay: none` adapter but no monetization or esports features; playtest evidence easily obtained | Normal human gate path; no special handling. |
| EC-004 | Adapter upgraded from `replay: none` to `replay: partial` after a factory sprint | On next pipeline run, the degradation is lifted; the automated regression path is invoked; no lingering human gate. |
| EC-005 | Multiple adapters in a project; one is `replay: none`, others are T1/T2/T3 | Degradation applies only to the `replay: none` adapter's pipeline; other adapters run automated regression normally. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Adapter manifest: `{replay: none}`; replay regression triggered | No recording started; `tests/replay` dimension = `degraded: human-playtest-evidence-required`; human-gated task generated. | happy-path (degradation) |
| `replay: none` adapter; human playtest evidence submitted and accepted | Dimension = `degraded: accepted`; release gate satisfied for this dimension. | happy-path (resolution) |
| `replay: none` adapter upgraded to `replay: partial`; conformance passed; replay regression triggered | Automated regression runs normally; degradation lifted. | happy-path (upgrade) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-037 | When adapter has `replay: none`, the replay regression pipeline is never invoked. | integration test |
| VP-TBD-038 | When adapter has `replay: none`, the human-gated task is always generated (DI-006 compliance). | integration test |
| VP-TBD-039 | `tests/replay` dimension is never marked `pass` when adapter has `replay: none` without an accepted human-gate sign-off. | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies the "replay: none → degrade to human-playtest evidence" fallback described in ADR-0003 ("An adapter lacking these declares `replay: none` and the regression dimension falls back to human-playtest evidence") and in PROC-004 Stage 4 (Degradation). |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed), DI-006 (Human-Gated Tasks Are Surfaced Not Silently Dropped) |
| Architecture Module | SS-TBD (Replay Engine, Convergence Tracker — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 Stage 4 (Degradation), PROC-006 (Human-Gated Task Surfacing) |
| ADRs | ADR-0003 §Consequences ("adapter lacking these declares `replay: none`") |

## Related BCs

- BC-3.03.001 — related to (recording not invoked when replay: none)
- BC-3.03.002 — related to (replay not invoked when replay: none)

## Architecture Anchors

- `architecture/SS-TBD-convergence-tracker.md` — `tests/replay` dimension degradation handling
- `architecture/SS-TBD-replay-engine.md` — Graceful skip for replay: none

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-037 — no regression pipeline invocation for replay: none
- VP-TBD-038 — human-gated task always generated
