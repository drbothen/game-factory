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
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/processes.md
  - .factory/planning/research/aaa/production-pipeline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.07.003: Wave Schedule Respects Discipline-DAG Ordering and Emits Blocked-Wave Signals

## Description

The producer-orchestrator agent maintains a `game-production-plan` with a wave schedule
computed from the discipline dependency DAG. When a wave is ready to start, the factory
checks that all waves in its DAG predecessor set have completed their discipline deliveries
and passed handoff acceptance (BC-5.07.001 and BC-5.07.002). If a predecessor wave has not
completed, the dependent wave is blocked and a `blocked-wave-signal` is emitted to the
producer-orchestrator so that human and automated remediation can be triggered. Waves are
never silently skipped or started out of order.

## Preconditions

1. A `game-production-plan` artifact exists with:
   - `waves`: ordered array of wave definitions, each with `wave_id`, `disciplines[]`,
     and `prerequisite_wave_ids[]`
   - `discipline_dag`: the dependency graph used to derive wave ordering
2. The wave schedule has been computed from the discipline DAG (topological sort) and
   stored in `game-production-plan.wave_schedule`.
3. The dependency DAG is acyclic (verified at plan creation time by BC-5.07.001 precondition).
4. The factory wave-gate hook is registered and active.

## Postconditions

1. When the factory attempts to start wave W:
   a. For each `prerequisite_wave_id` P in W's `prerequisite_wave_ids[]`:
      - P must have status `"completed"` in the wave registry.
      - P must have a `handoff-acceptance-report` with status `"pass"` for all of P's
        discipline deliveries that feed W. If not: E-PROD-003 raised.
   b. If all prerequisites are complete and passed: W is started; its status transitions
      to `"in-progress"` in the wave registry.
2. If any prerequisite is not complete or its handoff report is missing or failed:
   - E-PROD-003 is raised with `wave_id` = W and `dep_wave_id` = the blocking predecessor.
   - A `blocked-wave-signal` is emitted containing: `blocked_wave_id`, `blocking_wave_id`,
     `blocking_reason` (incomplete | handoff-failed | contract-missing), and `timestamp`.
   - W remains in status `"blocked"` in the wave registry.
3. The producer-orchestrator receives the `blocked-wave-signal` and may trigger either:
   - Remediation actions (request re-delivery from producer discipline), OR
   - Scope adjustment (defer blocked stories to a future wave with producer acknowledgment).
4. The wave registry is updated on every status transition; status history is append-only.
5. A `wave-schedule-status-report` is emitted on each wave start attempt, showing the
   status of all waves and their predecessors.

## Invariants

1. Waves are never started out of topological order. Even if all prerequisites happen to
   be "complete" at an unexpected time, the wave-gate enforces the declared order.
2. (DI-006 analog) Blocked-wave signals are never silently dropped. If a wave is blocked,
   a signal is emitted to the producer-orchestrator; the block is visible in the
   `wave-schedule-status-report`.
3. The wave schedule (topological order) is computed once from the discipline DAG and
   stored. It is not recomputed mid-production unless a formal plan revision is initiated.
   Ad-hoc reordering is rejected as a defect.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Wave W has no prerequisites (it is a root wave, e.g., design wave) | No predecessor checks needed; W starts immediately; blocked-wave-signal not emitted |
| EC-002 | Prerequisite wave P is "completed" but its handoff-acceptance-report is missing from the audit log | E-PROD-003: handoff report for wave P not found; wave W blocked; audit gap reported |
| EC-003 | Two waves W1 and W2 both declare no prerequisites and both attempt to start simultaneously | Both start in parallel (no mutual dependency); wave registry records both as in-progress |
| EC-004 | Prerequisite wave P is completed with handoff status "partial" (some artifacts accepted, some rejected) | E-PROD-003: partial handoff not accepted as a predecessor completion; P must achieve full "pass" before W starts |
| EC-005 | Plan revision reduces the number of waves mid-production (scope cut) | Revision workflow triggered; affected downstream waves re-evaluated against new plan; waves that depended on cut waves are re-scheduled or cancelled |
| EC-006 | Wave W starts successfully but a predecessor's accepted artifacts are subsequently found to be incorrect (post-hoc discovery) | The wave-gate cannot retroactively block a started wave; the discovery creates a defect report; remediation handled via the dependency contract change-propagation-policy for the next wave |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Production plan with 3 waves: W1 (design), W2 (art, prereq W1), W3 (engineering, prereq W2); W1 completed with pass; W2 starts | W2 start permitted; wave registry: W2=in-progress | happy-path |
| W2 attempts to start while W1 status=in-progress (not completed) | E-PROD-003: W1 not complete; blocked-wave-signal emitted for W2; W2 status=blocked | error |
| W2 completed but handoff-acceptance-report for W2→W3 has status fail | E-PROD-003: W2 handoff failed; W3 blocked | error |
| Root wave W1 (no prerequisites) starts | No predecessor checks; W1 starts immediately | edge-case |
| W1 and W2 both have no prerequisites; parallel start | Both start; wave registry: W1=in-progress, W2=in-progress | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.07.005 | For all waves with prerequisite_wave_ids, wave start is always blocked if any predecessor is not completed | proptest: generate wave schedules with random completion states; assert blocking logic |
| VP-5.07.006 | blocked-wave-signal is always emitted when a wave is blocked | integration test: force blocked condition; assert signal in producer-orchestrator inbox |
| VP-5.07.007 | Wave status history is append-only (no status can be overwritten) | test: attempt status overwrite; assert rejected |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the game-production-plan and wave schedule are named in RECONCILIATION §5.8 and PROC-001 as the producer-owned coordination artifacts for CAP-005's multi-discipline production workflow; this BC defines their machine-checkable ordering contract. |
| L2 Domain Invariants | DI-006 (blocked signals surfaced not silently dropped) |
| Architecture Module | SS-04 — wave-gate hook; wave registry; producer-orchestrator; game-production-plan |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.07.001 — depends on (dependency contracts must be declared before wave start)
- BC-5.07.002 — depends on (handoff acceptance must pass before wave start)

## Architecture Anchors

- `architecture/SS-04-production-orchestration.md` — wave registry, wave-gate hook, blocked-wave-signal

## Story Anchor

S-TBD — Wave Schedule DAG Ordering Enforcement

## VP Anchors

- VP-5.07.005 — predecessor completion enforcement
- VP-5.07.006 — blocked-wave signal emission
- VP-5.07.007 — wave status append-only
