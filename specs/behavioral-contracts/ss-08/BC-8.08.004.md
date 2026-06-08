---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/processes.md
  - .factory/planning/research/aaa/qa-testing-liveops.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-07
capability: CAP-008
priority: P1
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

# BC-8.08.004: Human Playtest Sign-Off Gate (Mandatory, Non-Substitutable)

## Description

The `playtest-satisfaction` convergence dimension is gated by mandatory human sign-off
on the completed `playtest-convergence-report`. The factory enforces this gate: no
automated process, agent output, or computed metric may substitute for or bypass the
human signature. The factory emits the gate task, tracks its completion state, and
propagates the signed result to the convergence tracker — but the judgment itself is
always human-authored.

## Preconditions

1. A `playtest-convergence-report` with `status: draft` exists for the current milestone.
2. A human-gate task has been emitted to the `playtest-evaluator` role (and optionally
   `producer` or `director`) per DI-006.
3. The assigned human reviewer has been identified (not anonymous — the factory requires
   a named `reviewer_id` for the sign-off record).
4. The `playtest-protocol.status` is `approved` (ensures the session was conducted under
   a reviewed protocol, not an ad-hoc one).

## Postconditions

1. When the human reviewer completes sign-off, the factory records a
   `playtest-signoff-record` containing:
   - `reviewer_id`: the named human who signed (a real identity, not an agent)
   - `timestamp`: ISO-8601 timestamp of the sign-off act
   - `verdict`: `SATISFIED` | `NOT_SATISFIED` | `CONDITIONAL` (where CONDITIONAL
     requires a `conditions_for_satisfaction` text field authored by the reviewer)
   - `human_verdicts_summary`: free-text authored by the reviewer — their synthesis of
     the convergence report findings and rationale for the verdict
   - `report_ref`: reference to the `playtest-convergence-report` this sign-off covers
   - `protocol_ref`: reference to the `playtest-protocol` this sign-off covers
2. If `verdict: SATISFIED`, the `playtest-satisfaction` convergence dimension is updated
   to `green` in the 11-dimension tracker.
3. If `verdict: NOT_SATISFIED`, the `playtest-satisfaction` convergence dimension is set
   to `red` and the convergence tracker surfaces a blocking item: design revision loop
   required (next step: revise design-intent contracts, re-build, re-playtest).
4. If `verdict: CONDITIONAL`, the dimension is set to `amber` with the conditions recorded;
   resolution requires either a delta-playtest verifying the conditions or a human override
   with justification.
5. The factory-emitted human-gate task transitions to `complete` only when the
   `playtest-signoff-record` is created with a `reviewer_id` that is a human (validated
   against the allowed-human-reviewer list for the project).

## Invariants

1. The `reviewer_id` in a `playtest-signoff-record` MUST NOT be an agent ID, a
   computed value, or the factory system itself (DI-007). The factory enforces this
   via allowlist: only human-declared reviewer IDs may sign off.
2. The `verdict` field MUST be authored by the human — it cannot be populated by any
   factory process, computed from instrument scores, or pre-filled. A sign-off record
   with an auto-populated verdict is structurally invalid.
3. The `playtest-satisfaction` convergence dimension MUST remain in `pending` state
   until a valid `playtest-signoff-record` exists for the current milestone build. The
   factory MUST NOT advance this dimension by any other means.
4. If any `human-gated` task for playtest sign-off has been suppressed, bypassed, or
   silently dropped, the hook chain must detect and surface this as a defect (DI-006).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | An agent (automated process) attempts to create a `playtest-signoff-record` | Factory rejects with `AGENT_SIGN_OFF_FORBIDDEN` error; the attempt is logged as a security/integrity event; the gate remains open |
| EC-002 | Human reviewer requests to modify the convergence report before signing | Reviewer may annotate the report (append `human_annotations`) but may not modify the captured evidence sections; the `human_verdicts` section is theirs to author |
| EC-003 | No human reviewer has been assigned to the gate task | Gate task remains open; convergence dimension remains `pending`; factory emits a reminder at next milestone gate evaluation |
| EC-004 | Reviewer signs off with `CONDITIONAL` but no `conditions_for_satisfaction` text | Factory returns `CONDITIONS_REQUIRED_FOR_CONDITIONAL_VERDICT`; sign-off not accepted until conditions are authored |
| EC-005 | Design revision loop triggered (NOT_SATISFIED verdict) and a new playtest is run on the revised build | A new `playtest-protocol`, `session-evidence-record`s, and `playtest-convergence-report` must be generated for the new build; the previous NOT_SATISFIED record is retained and linked via `previous_iteration_ref` |
| EC-006 | Production milestone gate (MilestoneGate) is evaluated while `playtest-satisfaction` is `pending` | Milestone gate MUST block on `playtest-satisfaction = pending`; no path to cert/release without playtest sign-off |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Human reviewer signs off `verdict: SATISFIED`, `human_verdicts_summary` authored | `playtest-signoff-record` created; `playtest-satisfaction` dimension → `green`; human-gate task → `complete` | happy-path |
| Human reviewer signs off `verdict: NOT_SATISFIED` | `playtest-signoff-record` created; dimension → `red`; design revision loop blocked item surfaced; human-gate task → `complete` | happy-path (negative verdict) |
| Agent process attempts to POST a `playtest-signoff-record` | Error: `AGENT_SIGN_OFF_FORBIDDEN`; gate remains open; security event logged | error (EC-001) |
| `CONDITIONAL` verdict submitted without `conditions_for_satisfaction` | Error: `CONDITIONS_REQUIRED_FOR_CONDITIONAL_VERDICT` | error (EC-004) |
| MilestoneGate evaluated when playtest still `pending` | Milestone gate blocks; `playtest_satisfaction_unresolved` blocking item listed | error (EC-006) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-1 | For all `playtest-signoff-record`s, `reviewer_id` is in the project's human-reviewer allowlist and not in the agent-id registry | Validation test: attempt to create sign-off with agent ID; assert rejection |
| VP-2 | The `playtest-satisfaction` convergence dimension can only transition from `pending` to `green`/`red`/`amber` via a valid `playtest-signoff-record`; all other transition attempts are rejected | State-machine property test: exhaustive test of all possible transition triggers; only `playtest-signoff-record` creation is a valid trigger |
| VP-3 | If any `human-gated` playtest task is suppressed and the convergence dimension transitions to `green` without a sign-off record, the hook chain must produce a defect event within one wave | Integration test: suppress human gate; run wave gate; assert defect event emitted |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008 |
| L2 Domain Invariants | DI-006 (human-gated tasks must not be silently dropped), DI-007 (playtest satisfaction is always a human gate) |
| Architecture Module | (filled by architect) |
| Stories | (filled by story-writer) |
| Capability Anchor Justification | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008. This BC is the direct enforcement of the "mandatory human gate" clause in CAP-008: "mandatory human gate; the factory ... never auto-scores fun or feel." |

## Related BCs

- BC-8.08.001 — upstream (protocol scaffold is what this gate verifies compliance with)
- BC-8.08.002 — upstream (evidence captured here is reviewed at sign-off)
- BC-8.08.003 — depends on (convergence report is what the human reviews)
- BC-7.07.001 — composes with (11-dimension convergence tracker; playtest-satisfaction is one of 11 dimensions) — cross-capability

## Architecture Anchors

- `architecture/` — human gate enforcement subsystem (filled by architect)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-1 — Human reviewer allowlist enforcement
- VP-2 — Dimension state machine gate constraint
- VP-3 — Hook chain defect detection for suppressed human gate
