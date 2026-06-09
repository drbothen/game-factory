---
document_type: behavioral-contract
level: L3
version: "1.4"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/cinematics-virtual-production.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified:
  - pass: "Pass-28"
    reason: "I28-01 fix: replaced `human-gated` vocabulary on cinematic-director creative sign-off (postcondition 5, EC-004, Traceability DI-006) with D-013 creative-gate vocabulary (E-CIN-003, DI-007). The cinematic-director is an internal creative principal — not an external third-party — so ADR-0007 `human-gated` fidelity tier does not apply. Gating semantics preserved."
  - pass: "Pass-32"
    reason: "I-PASS32-01 fix: removed spurious DI-007 from Traceability L2 Domain Invariants row. The directed:true cinematic creative-gate is anchored to D-013 + E-CIN-003 and has no corresponding DI. DI-008 (engine-neutral spec layer) retained."
  - pass: "Pass-39"
    reason: "F39-02 fix: PC1 and EC-003 re-pointed from E-CIN-001 variant (unresolved asset ref — semantically wrong for temporal range) to E-CIN-005 (TimestampOutOfRange, dedicated registered code)."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.06.001: Sequence Graph Is Well-Formed, Engine-Agnostic, and Passes Structural Validation

## Description

The cinematic-director and cinematic-writer agents produce a `sequence-graph` artifact for
each cutscene or scripted cinematic sequence. This artifact is an engine-agnostic,
time-keyed, multi-track document encoding camera cuts, animation, facial lip-sync,
audio events, subtitle coverage, entity activation, and interaction events. The factory
validates structural properties: all asset refs resolve, subtitle coverage is complete
(every audio event with dialogue has a subtitle track), tracks are temporally well-formed
(events within [0, duration_seconds]), and the `directed` flag triggers the correct gate.
Crucially, for Bevy targets, the sequence-graph requires a BUILD-new Bevy sequence runtime
(no native Timeline equivalent exists in Bevy as of 2026); this is flagged in the
validation report.

## Preconditions

1. A `sequence-graph` artifact exists with `sequence_id`, `duration_seconds`, `tracks`,
   `asset_refs`, and `validation_required` fields populated.
2. The asset store is accessible for asset ref resolution.
3. The `sequence-graph` schema (v1.0 or later) is registered.
4. If the target engine adapter is Bevy: the `bevy-sequence-runtime` build target is
   declared in the game's `engine_runtime_requirements`. If not declared: validation
   report flags the Bevy sequence runtime gap.
5. `directed` field is present (`true` or `false`). Missing → schema error.

## Postconditions

1. **Schema validation**: all required track fields are present; timestamps are numbers ≥ 0
   and ≤ `duration_seconds`. Out-of-range timestamp → E-CIN-005 (TimestampOutOfRange).
2. **Asset ref resolution**: every ref in `asset_refs` and in track entries resolves to
   an existing asset in the asset store. Unresolved ref → E-CIN-001.
3. **Subtitle coverage**: for every audio event in `tracks.audio[]` that is tagged
   `dialog: true`, a corresponding subtitle entry exists in `tracks.subtitles[]` covering
   the same time window [time_s, end_s]. Missing subtitle → E-CIN-002.
4. **Audio sync tolerance**: for audio events, the `time_s` alignment tolerance is ≤ 50 ms
   from any corresponding animation or lip-sync event for the same actor ref. Misalignment
   > 50 ms → warning in report (not block, as timing adjustments happen in engine integration).
5. **Directed flag check**: if `directed: true`, the validation report records that a
   cinematic-director creative sign-off is REQUIRED before the sequence is accepted for
   the ship build. A creative gate checklist item is surfaced for the cinematic-director
   (D-013 creative gate — NOT the `human-gated` fidelity tier per ADR-0007, which is
   reserved for external third-party acts only). If no sign-off record exists: E-CIN-003
   raised in the context of the ship-build gate (not during development).
6. **Bevy engine gap flag**: if any target engine adapter is Bevy AND the sequence-graph
   uses in-engine timeline tracks, the validation report includes:
   `"bevy_sequencer_gap": true, "required_build": "bevy-sequence-runtime"`. This is
   informational (not a block) during spec phase; it becomes a BUILD requirement tracked
   by the architect.
7. A `sequence-validation-report` is emitted with per-check status, error list, and
   Bevy gap flag.

## Invariants

1. (DI-008) The sequence-graph uses engine-agnostic track types only. No engine-specific
   timeline type (Unity TimelineAsset, Unreal Level Sequence, Godot AnimationPlayer track
   by engine class name) may appear in the schema.
2. Every `actor_ref` in animation or facial_lipsync tracks must resolve to an entity in
   the Canon-KB (same entity-ref integrity as BC-5.04.001). Dangling actor_ref → E-CIN-001.
3. The `directed` flag is immutable once set. Changing from `directed: false` to
   `directed: true` after the sequence is accepted requires a revision workflow.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Sequence has no subtitle track at all (game is narration-free) | If no `dialog: true` audio events, subtitle coverage check trivially passes; report notes "no dialogue" |
| EC-002 | Bevy is the only target engine and no `bevy-sequence-runtime` is declared | Validation report: bevy_sequencer_gap=true, required_build=bevy-sequence-runtime; report is a warning; architect notified; not a spec-phase block |
| EC-003 | Audio event at timestamp 95s in a 90s sequence | E-CIN-005: timestamp 95s out of range [0, 90s]; schema check |
| EC-004 | directed=true, sign-off record exists from cinematic-director but is marked "pending" | Ship-build gate: sign-off must be in status "signed"; "pending" does not pass the gate; creative-gate checklist item remains open (E-CIN-003) |
| EC-005 | Animation track references actor_id "hero_1" not in Canon-KB | E-CIN-001: actor_ref 'hero_1' not in Canon-KB |
| EC-006 | Audio event tagged `dialog: true` has a subtitle but the subtitle time window misses the first 0.5 s of the audio | Warning (not block): subtitle coverage gap of 0.5 s noted in report |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| 30s sequence, all asset refs resolve, 2 dialog audio events with matching subtitle windows, directed=false | sequence-validation-report: all pass; bevy_sequencer_gap: false (if not Bevy) | happy-path |
| Asset ref "mesh_castle.glb" not in asset store | E-CIN-001: unresolved asset ref mesh_castle.glb | error |
| Dialog audio event with no matching subtitle | E-CIN-002: dialog event at t=5s has no subtitle coverage | error |
| directed=true, no sign-off record | sequence-validation-report: spec checks pass; sign-off task surfaced; ship-build gate blocked until signed | edge-case |
| Bevy target, no bevy-sequence-runtime declared | Validation report: bevy_sequencer_gap=true; spec accepted; architect notified | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.06.001 | For all sequences, subtitle coverage check correctly identifies all dialog events without matching subtitle windows | proptest: generate sequences with random dialog/subtitle overlap patterns |
| VP-5.06.002 | Asset ref resolution: every unresolved ref always raises E-CIN-001 | proptest: inject unresolved refs; assert error rate = 100% |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the sequence-graph is listed in RECONCILIATION §6.3 (cinematics-virtual-production.md additions) as the keystone cinematic artifact produced by the cinematic-director agent within CAP-005. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer) |
| Architecture Module | SS-04 — sequence graph validator; Bevy sequence runtime (BUILD-new); Canon-KB entity query |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.06.002 — composes with (lip-sync contract is a track in the sequence-graph)
- BC-5.04.002 — depends on (Canon-KB for actor_ref resolution)

## Architecture Anchors

- `architecture/SS-04-cinematics-pipeline.md` — sequence-graph schema, validation, Bevy runtime gap

## Story Anchor

S-TBD — Sequence Graph Structural Validation

## VP Anchors

- VP-5.06.001 — subtitle coverage completeness
- VP-5.06.002 — unresolved asset ref detection
