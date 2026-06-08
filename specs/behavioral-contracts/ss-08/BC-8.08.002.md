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

# BC-8.08.002: 3-Lens Evidence Capture (Say/Do/Behave) During Playtest Session

## Description

During an active playtest session, the factory provides three structured evidence-capture
lanes — SAY (verbal/survey), DO (observable actions/telemetry), and BEHAVE
(physiological/biometric signals, if available) — each with a defined schema. The factory
instruments the DO and BEHAVE lanes automatically from telemetry and optional sensor
integrations; the SAY lane is captured via structured forms provided to the human
evaluator. All three lanes are stored as session evidence records with provenance.

## Preconditions

1. A `playtest-protocol` with `status: approved` exists for the current milestone.
2. A playtest session has been initiated by the `playtest-evaluator` and assigned a
   `session_id`.
3. The playable build referenced by `build_id_ref` in the protocol is running and
   accessible to participants.
4. The `telemetry-event-taxonomy` for the game is schema-valid and wired to the build
   (session-level events emit correctly, per `test-suite-manifest` passing).

## Postconditions

1. For each participant in the session, the factory creates a `session-evidence-record`
   containing:
   - `participant_id` (anonymized or pseudonymized — never PII stored in factory artifacts)
   - `session_id` reference
   - `say_lane`: structured survey/questionnaire responses for each instrument in
     `playtest-protocol.instruments` — data stored as raw instrument scale values (e.g.
     GEQ 7-point scale per subscale), NOT collapsed to a scalar
   - `do_lane`: timestamped telemetry events from the session, tagged by task and participant
   - `behave_lane`: if biometric capture was configured (`biometric_sensors_available: true`
     in session config), structured signal data (HR, EDA, eye-gaze vectors); field is `null`
     if biometric capture was not configured — absence is not an error
2. `session-evidence-record.status` is set to `captured`, pending convergence synthesis.
3. Each instrument's raw subscale scores are preserved without aggregation — no mean
   across subscales, no "overall" scalar computed at capture time.
4. The factory emits a human-gate task to the `playtest-evaluator` to review the raw
   evidence and produce the convergence report (per BC-8.08.003).

## Invariants

1. Instrument data MUST be stored as raw subscale vectors, never collapsed to a scalar
   at capture time (DI-007). Example: GEQ must store competence/immersion/flow/tension/
   affect subscores separately, not a single "GEQ score."
2. `participant_id` must be a pseudonymous token — no real names, email addresses, or
   other direct identifiers may appear in `session-evidence-record` artifacts.
3. The `do_lane` telemetry must be tagged with the `task_id` from the approved protocol's
   `session_tasks` list so post-hoc analysis can segment by task.
4. Evidence records are append-only during the session; records may not be retroactively
   modified after `session.status` transitions to `complete`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Telemetry drops out mid-session (connectivity loss or crash) | DO lane records partial data up to the dropout with `do_lane.partial: true` annotation; session continues if possible; partial evidence is not automatically discarded |
| EC-002 | Participant does not complete all instrument questions | SAY lane stored as partial with `say_lane.complete: false`; missing items flagged per-item; human evaluator is notified and must decide whether to include the record in analysis |
| EC-003 | Biometric capture device fails mid-session | BEHAVE lane transitions to `null` with `behave_lane.capture_error: <reason>`; session continues with DO+SAY lanes |
| EC-004 | Session is started before build is verified running | Factory returns E-PLAY-009 (`BUILD_NOT_RUNNING`); session record is not created until build is confirmed active |
| EC-005 | Same participant attempts to submit instrument responses twice (UI error / double-submit) | Second submission is rejected with E-PLAY-010 (`DUPLICATE_PARTICIPANT_SUBMISSION`); first record retained |
| EC-006 | Session involves a minor (age < 13 in COPPA jurisdiction) | Factory refuses to capture biometric data and enforces `say_lane.coppa_compliant: true` mode (requires parent/guardian consent token in session config); if consent token absent, session for that participant is blocked |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Session with 5 participants, GEQ+PENS instruments, telemetry active, no biometrics | 5 `session-evidence-record`s with `say_lane` (GEQ/PENS subscale vectors), `do_lane` (timestamped events), `behave_lane: null`; all `status: captured` | happy-path |
| Telemetry drops at T+300s during session (EC-001) | `session-evidence-record` with `do_lane.partial: true`, events up to T+300s captured, session not aborted | edge-case |
| Participant submits GEQ partial (7/28 items answered) | Record created with `say_lane.complete: false`, flagged items listed, human evaluator notified | edge-case (EC-002) |
| Build crashes before session start | E-PLAY-009 (`BUILD_NOT_RUNNING`); no session record created | error (EC-004) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-1 | For all `session-evidence-record` artifacts, `say_lane` contains no field with name matching `*_score` (scalar aggregates) — only raw subscale values | Property-based test over generated records: schema validation rejects scalar fields |
| VP-2 | For all `session-evidence-record` artifacts, `participant_id` matches a pseudonymous ID pattern (no email, name, or UUID derived from PII) | Schema validation + unit test over ID generation function |
| VP-3 | No `session-evidence-record` is modified after its session transitions to `complete` | Immutability integration test: attempt to write a record after `session.status = complete`; assert error returned |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008 |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced), DI-007 (playtest satisfaction always a human gate) |
| Architecture Module | (filled by architect) |
| Stories | (filled by story-writer) |
| Capability Anchor Justification | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008. This BC specifies what the factory must PROVIDE for evidence recording during a session — exactly CAP-008's "evidence recording" function. |

## Related BCs

- BC-8.08.001 — depends on (approved protocol is prerequisite; instruments list drives capture schema)
- BC-8.08.003 — feeds into (evidence records are synthesized into the convergence report)
- BC-8.08.004 — upstream of (human sign-off is based on evidence reviewed in convergence report)

## Architecture Anchors

- `architecture/` — session evidence store (filled by architect)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-1 — No scalar aggregates in captured instrument data
- VP-2 — Participant pseudonymity
- VP-3 — Evidence record immutability after session close
