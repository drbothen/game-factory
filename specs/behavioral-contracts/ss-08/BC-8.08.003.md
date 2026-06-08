---
document_type: behavioral-contract
level: L3
version: "1.2"
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

# BC-8.08.003: Playtest Convergence Report Generation (3-Lens Synthesis)

## Description

After all session evidence records are captured and the human evaluator has reviewed
the raw data, the factory generates a structured `playtest-convergence-report` artifact
that organizes the three-lens evidence (SAY/DO/BEHAVE) alongside the declared convergence
thresholds for each instrument. The report provides a structured presentation surface —
it does NOT compute a pass/fail verdict; that judgment belongs exclusively to the human
reviewer who will sign off in BC-8.08.004.

## Preconditions

1. At least one `session-evidence-record` with `status: captured` exists for the
   current playtest milestone session.
2. The `playtest-protocol` with `status: approved` is accessible (convergence thresholds
   are read from it).
3. The `playtest-evaluator` has invoked the convergence report generation command,
   signaling that evidence collection is complete for this session.
4. The session's `build_id_ref` matches the build that produced the captured evidence
   records (no cross-build contamination).

## Postconditions

1. A `playtest-convergence-report` document is generated containing:
   - `session_id` and `build_id_ref`
   - `participant_count`: total number of participants with complete or partial evidence
   - `say_section`: per-instrument, per-subscale data summary — mean and distribution of
     raw subscale scores across participants; scores presented alongside the declared
     `convergence_thresholds` for side-by-side comparison; NO automated pass/fail verdict
   - `do_section`: summary of telemetry events organized by task — task completion rates,
     dropout points, progression funnel, death/failure heatmap by location (if applicable);
     these are presented as observations, not conclusions
   - `behave_section`: if `behave_lane` data was captured for any participant — summary of
     signal patterns by session phase; if `behave_lane` was null for all participants, this
     section is omitted with a note
   - `convergence_threshold_comparison`: side-by-side table of declared thresholds vs.
     observed distributions — no verdict column; verdicts are filled by the human reviewer
   - `divergence_flags`: automatically detected cases where SAY, DO, and BEHAVE appear to
     point in different directions (e.g. DO shows high death rate but SAY shows high
     competence) — these are flagged as "investigate" items, not conclusions
2. Report `status` is set to `draft`, awaiting human evaluator review.
3. A human-gate task is emitted for the `playtest-evaluator` to review the report, fill in
   the `human_verdicts` section, and sign off (BC-8.08.004).
4. No field in the report contains a computed "fun score," "satisfaction score," or
   automated pass/fail verdict.

## Invariants

1. The `convergence_threshold_comparison` table MUST have no verdict column or computed
   outcome field (DI-007). It presents thresholds next to observations; the human fills
   verdicts.
2. `divergence_flags` are hypothesis-generating only — they are prefixed with
   "Investigate:" language, never "Failed:" or "Passed:".
3. The report must reference and be traceable to the approved `playtest-protocol` via
   `protocol_ref` — a report generated without a protocol reference is invalid.
4. Partial evidence records (EC-002 from BC-8.08.002) are included in `participant_count`
   with a note, not silently excluded.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Only 1 participant completed the session | Report generated with N=1 noted prominently; factory warns "N=1 is insufficient for reliable GUR findings; consider scheduling additional sessions" — but does not block generation |
| EC-002 | All evidence records have `say_lane.complete: false` | Report notes 100% partial instrument completion; recommends re-run; human evaluator retains ability to use the data at their discretion |
| EC-003 | SAY and DO data strongly diverge (e.g. low PENS competence but high task completion rate) | `divergence_flags` entry added: "Investigate: Low self-reported competence with high task completion — possible discrepancy between perceived and actual performance" |
| EC-004 | Report generation requested before session is marked complete | Factory returns E-PLAY-011 (`SESSION_NOT_COMPLETE`); convergence report may only be generated once the evaluator closes the session |
| EC-005 | Multiple sessions across different builds for the same milestone | Factory requires evaluator to specify which session to synthesize; cross-session aggregation across builds is NOT performed automatically (different builds = different context) |
| EC-006 | Convergence thresholds were not declared in the approved protocol | Report generated but `convergence_threshold_comparison` section contains a warning: "No thresholds declared in protocol — comparison not possible; human reviewer must apply judgment without declared baselines" |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| 8 participants, all complete, GEQ+PENS instruments, telemetry data present, thresholds declared | `playtest-convergence-report` with `say_section` (subscale distributions), `do_section` (task funnels), `convergence_threshold_comparison` (no verdict column), `divergence_flags: []`, `status: draft` | happy-path |
| 1 participant only | Report with N=1 warning, all sections populated, factory advisory note added; report still generated | edge-case (EC-001) |
| SAY shows PENS competence mean=2.1 (below threshold=3.5), DO shows 95% task completion | `divergence_flags`: `["Investigate: Low self-reported competence (PENS competence mean=2.1) vs. high task completion (95%) — investigate perception gap"]` | edge-case (EC-003) |
| Session not yet marked complete | E-PLAY-011 (`SESSION_NOT_COMPLETE`) | error (EC-004) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-1 | No field in any `playtest-convergence-report` has a key matching `*verdict*`, `*pass*`, `*fail*`, `fun_score`, or `satisfaction_score` — except in `human_verdicts` (which is authored by the human, not computed) | Schema validation + property-based test over all generated report structures |
| VP-2 | `convergence_threshold_comparison` rows contain `declared_threshold` and `observed_value` fields but no `result` field (enforces no auto-pass/fail) | Property-based test: for all valid reports, `convergence_threshold_comparison[*].result` must not exist |
| VP-3 | Every `playtest-convergence-report` has a `protocol_ref` field that resolves to an existing `playtest-protocol` with `status: approved` | Integration test: generate report and assert `artifact_store.exists(protocol_ref) && artifact_store.get(protocol_ref).status == approved` |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008 |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced), DI-007 (playtest satisfaction always a human gate) |
| Architecture Module | (filled by architect) |
| Stories | (filled by story-writer) |
| Capability Anchor Justification | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008. This BC covers the "convergence report" output that CAP-008 explicitly names as part of the capability's scope. |

## Related BCs

- BC-8.08.001 — depends on (protocol defines thresholds consumed here)
- BC-8.08.002 — depends on (session evidence records are this BC's primary input)
- BC-8.08.004 — feeds into (report is what the human sign-off gate reviews)

## Architecture Anchors

- `architecture/` — convergence report generator (filled by architect)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-1 — No automated verdict fields
- VP-2 — Threshold comparison has no result column
- VP-3 — Protocol reference integrity
