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

# BC-8.08.005: Agent-Emitted Fun-Score Detection and Defect Surfacing

## Description

Any factory agent, hook, or pipeline step that emits a field with a name or semantic
meaning equivalent to a computed "fun score," "satisfaction score," or automated
playtest verdict is detected by the factory's hook chain and surfaced as a defect.
This is the enforcement complement to the human-gate sign-off: the factory prevents
circumvention from the automated side.

## Preconditions

1. The factory hook chain is active and monitoring artifact writes to the
   `.factory/` artifact store.
2. A factory process has produced or is attempting to write an artifact.

## Postconditions

1. If any artifact written by a factory agent (not a human reviewer) contains a field
   matching the fun-score detection ruleset (see Invariants), the hook chain intercepts
   the write and:
   - Rejects the artifact write with E-PLAY-014 (`FUN_SCORE_EMISSION_FORBIDDEN`)
   - Records a defect event: `{defect_type: fun_score_emission, artifact_path, agent_id,
     field_name, field_value_hash}`
   - Does NOT silently pass or log-only — the write is blocked
2. The defect event is surfaced in the next convergence report as an integrity violation.
3. The factory does not retroactively validate existing approved `playtest-signoff-record`s
   authored by human reviewers — the detection applies only to factory-generated artifacts,
   not human-authored content.

## Invariants

1. The fun-score detection ruleset covers at minimum:
   - Any field named: `fun_score`, `satisfaction_score`, `auto_verdict`, `playtest_verdict`,
     `predicted_satisfaction`, `feel_score`, `experience_score`, or any name matching
     the pattern `*_fun`, `*_feel`, `auto_*_verdict`
   - Any numeric field in a factory-generated artifact whose description/comment contains
     the words "fun" or "feel" as a score
   - Any boolean field named `playtest_passed` or `experience_passed` in a factory-generated
     artifact outside the `playtest-signoff-record` schema (the only legitimate location
     for a verdict is a human-authored sign-off record)
2. The detection hook must be BLOCKING, not advisory — a warn-only mode is not acceptable
   for DI-007 compliance.
3. The ruleset is extensible: new field patterns can be added without core changes (configuration-driven).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | A telemetry artifact contains a field named `frustration_signal` (a proxy metric, not a fun score) | NOT blocked — proxy metrics derived from DO lane telemetry (e.g. frustration signals, flow proxies) are permitted as observational data; only scalar "fun/satisfaction" verdicts are forbidden |
| EC-002 | A design-intent contract contains a `balance_score` field (a numeric game-balance metric) | NOT blocked — game design balance metrics are not playtest satisfaction scores; detection targets experiential verdict fields specifically |
| EC-003 | The hook detection ruleset itself has a misconfiguration that is too broad (blocking legitimate metric fields) | Factory provides a test harness for the detection ruleset so misconfiguration can be caught before deployment; false-positive override requires explicit human authorization per defect |
| EC-004 | A third-party tool integration writes a structured report with a field named `user_satisfaction_score` | Blocked with `FUN_SCORE_EMISSION_FORBIDDEN`; the integration is responsible for renaming the field before ingestion |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Agent writes artifact with field `fun_score: 7.3` | Write rejected: E-PLAY-014 (`FUN_SCORE_EMISSION_FORBIDDEN`); defect event recorded | error (DI-007 violation) |
| Agent writes artifact with field `frustration_signal: 0.82` (proxy metric) | Write accepted; no defect | happy-path (proxy metric, not verdict) |
| Human reviewer writes `playtest-signoff-record` with `verdict: SATISFIED` | Write accepted; this is the only legitimate satisfaction verdict field | happy-path (human-authored sign-off) |
| Third-party integration writes `user_satisfaction_score: 4.1` | Write rejected: E-PLAY-014 (`FUN_SCORE_EMISSION_FORBIDDEN`); defect event recorded | error (EC-004) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-1 | For all factory-generated artifacts (excluding `playtest-signoff-record`), no field matching the detection ruleset passes through the artifact store write path | Mutation test: inject field names from the ruleset into various artifact types; assert all are blocked |
| VP-2 | The detection hook operates in blocking mode — no artifact write with a matching field completes successfully | Integration test: instrument the artifact store write path; confirm no matching artifact reaches `status: written` |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008 |
| L2 Domain Invariants | DI-007 (playtest satisfaction is always a human gate — the absolute prohibition on auto-scoring) |
| Architecture Module | (filled by architect) |
| Stories | (filled by story-writer) |
| Capability Anchor Justification | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008. This BC enforces the machine side of CAP-008's "never auto-scores fun or feel" constraint — it is the detection and blocking mechanism for automated circumvention. |

## Related BCs

- BC-8.08.004 — composes with (sign-off gate is the human path; this BC guards the automated path)
- BC-8.08.001 — composes with (protocol generation is guarded; no fun-score may appear in protocol)

## Architecture Anchors

- `architecture/` — hook chain artifact validation (filled by architect)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-1 — Fun-score detection ruleset completeness
- VP-2 — Hook blocking mode
