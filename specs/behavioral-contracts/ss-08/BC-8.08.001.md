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

# BC-8.08.001: Playtest Protocol Document Scaffold Generation

## Description

When a playable build reaches the playtest milestone, the factory generates a complete,
structured `playtest-protocol` artifact containing the research question, recruitment
criteria, session tasks, instrument selection (GEQ/PENS/SUS), think-aloud plan, and
success thresholds. This document is what the human playtest evaluator uses to run the
session — the factory owns its structure and completeness; the human owns execution.

## Preconditions

1. A `GameSpec` with `genre_profile` populated exists and is in production.
2. The playtest milestone gate has been reached (a playable build exists and is archived
   with a stable build ID).
3. No prior `playtest-protocol` artifact for this milestone exists with
   `status: approved`; a new one is being generated or regenerating a `draft`.
4. The 11-dimension convergence tracker reports the `playtest-satisfaction` dimension
   as `pending` or `not-started` (i.e., has not yet been signed off).

## Postconditions

1. A `playtest-protocol` document is written to the factory artifact store with all
   mandatory sections populated:
   - `research_question`: a single, specific, testable question about the experience
   - `target_participant_count`: integer ≥ 5 (per GUR discipline minimum for qualitative)
   - `recruitment_criteria`: at minimum `genre_familiarity_tier` and `platform` fields
   - `session_tasks`: ordered list of ≥ 1 discrete task, each with a time budget
   - `instruments`: at minimum one of {GEQ, PENS, SUS}; must include SUS if usability
     is a stated research concern
   - `think_aloud_type`: `concurrent` | `retrospective` | `both`
   - `convergence_thresholds`: per-instrument passing threshold declared before session
     (e.g. `pens_competence_min: 3.5`, `sus_score_min: 68`)
   - `build_id_ref`: reference to the exact build being tested
2. Document `status` is set to `draft`, awaiting human evaluator review before approval.
3. The factory emits a human-gate task for the `playtest-evaluator` role to review and
   approve the protocol, per DI-006.
4. No fun-score field or automated satisfaction scalar is present anywhere in the document.

## Invariants

1. The `playtest-protocol` document MUST NOT contain any automated scoring computation,
   "fun score" field, or predicted satisfaction value (DI-007). The factory generates
   structure; it never pre-fills a verdict.
2. Convergence thresholds are declared BEFORE the session begins and recorded in the
   document at generation time — not post-hoc.
3. The `build_id_ref` field must reference an archived, reproducible build (not
   "latest").
4. The `instruments` list must be non-empty and must include only validated instruments
   from the approved set: {GEQ, PENS, SUS}. Custom ad-hoc instruments are disallowed
   at this factory layer (they may be added by the human evaluator as supplementary).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `genre_profile.playtest_instruments` is empty in the GameSpec | Factory defaults to `[GEQ, PENS, SUS]` and adds a warning annotation to the document noting the default was applied |
| EC-002 | The playable build has not been archived (no stable `build_id`) | Factory refuses to generate the protocol; emits a blocking human-gate task to the producer to archive the build first |
| EC-003 | A `playtest-protocol` with `status: approved` already exists for this milestone | Factory does NOT overwrite the approved protocol; returns an error: `PLAYTEST_PROTOCOL_ALREADY_APPROVED` |
| EC-004 | `target_participant_count` derived from genre profile is 0 or less | Factory clamps to minimum of 5 and emits a warning |
| EC-005 | XR game (`xr_target != none`) at playtest milestone | Factory adds `headset_required: true`, `comfort_cert_note: "XR comfort / nausea boundary requires physical headset and vestibular response — cannot be simulated"`, and requires a separate `xr_comfort_cert_human_gate` task to be emitted |
| EC-006 | Multiple simultaneous playtest protocol generation requests for the same milestone | Only one request proceeds; subsequent requests receive `PLAYTEST_PROTOCOL_IN_PROGRESS` error |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `GameSpec{genre=roguelike, xr_target=none, playtest_instruments=[GEQ,PENS]}` | `playtest-protocol` doc with `instruments: [GEQ, PENS]`, `status: draft`, no fun-score field, human-gate task emitted | happy-path |
| `GameSpec{genre=puzzle, playtest_instruments=[]}` | `playtest-protocol` doc with `instruments: [GEQ, PENS, SUS]`, warning annotation `DEFAULT_INSTRUMENTS_APPLIED`, status `draft` | edge-case (EC-001) |
| `GameSpec{genre=vr-action, xr_target=openxr}` | `playtest-protocol` with `headset_required: true`, `comfort_cert_note` populated, two human-gate tasks emitted (evaluator review + xr_comfort) | edge-case (EC-005) |
| Build not yet archived when milestone reached | Error: `BUILD_NOT_ARCHIVED`; blocking human-gate task to producer | error (EC-002) |
| Protocol already `status: approved` for this milestone | Error: `PLAYTEST_PROTOCOL_ALREADY_APPROVED`; no write occurs | error (EC-003) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-1 | Every generated `playtest-protocol` document must have zero fields named `fun_score`, `satisfaction_score`, `auto_verdict`, or any field whose value is a computed scalar representing playtest outcome | Static schema validation + property-based test over all valid GameSpec inputs |
| VP-2 | `convergence_thresholds` must be present and non-empty whenever `instruments` is non-empty | Property-based test: for all valid protocol documents, `instruments.len > 0 → convergence_thresholds.len > 0` |
| VP-3 | `build_id_ref` must reference an archived build that exists in the artifact store | Integration test: generate protocol and assert `artifact_store.exists(build_id_ref)` |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008 |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced, not silently dropped), DI-007 (playtest satisfaction is always a human gate) |
| Architecture Module | (filled by architect) |
| Stories | (filled by story-writer) |
| Capability Anchor Justification | CAP-008 ("Structured Playtest Protocol") per capabilities.md §CAP-008. This BC specifies what the factory must PROVIDE as a protocol document, which is directly what CAP-008 defines: "provides protocol scaffolding and evidence recording." |

## Related BCs

- BC-8.08.002 — depends on (evidence recording during session; protocol scaffold is prerequisite)
- BC-8.08.003 — depends on (convergence report generation; protocol defines thresholds consumed here)
- BC-8.08.004 — composes with (human sign-off gate; protocol document is what is signed)

## Architecture Anchors

- `architecture/` — playtest protocol subsystem (filled by architect)

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-1 — No automated fun-score in generated protocol
- VP-2 — Convergence thresholds present when instruments present
- VP-3 — Build reference integrity
