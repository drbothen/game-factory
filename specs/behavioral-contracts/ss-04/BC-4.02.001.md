---
document_type: behavioral-contract
level: L3
id: BC-4.02.001
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/prd-supplements/prd-cap-004.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-03
capability: CAP-004
priority: P0
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

# BC-4.02.001: Every GenerationRequest Is Validated Against the Canonical Schema Before Dispatch

## Description

Before the asset-generation orchestrator dispatches any work to a backend adapter, the
GenerationRequest must pass schema validation against the canonical `generation-request`
schema. Schema-invalid requests are rejected synchronously with a structured error before
any backend contact occurs. This gate prevents malformed requests from producing assets
with incomplete provenance, incorrect risk tiers, or unresolved art-direction references.

## Preconditions

1. The factory has a canonical `generation-request` JSON Schema (or equivalent) loaded and
   immutable at orchestrator startup.
2. A GenerationRequest document has been submitted to the orchestrator.
3. The orchestrator is in an operational state.

## Behavior

1. On receipt of a GenerationRequest, the orchestrator immediately runs schema validation
   before any further processing.
2. Schema validation checks ALL required fields are present and of correct type:
   - `request_id`: UUID format
   - `asset_class`: one of `{prop, character_hero, character_npc, texture_material,
     terrain, vegetation, level_layout, concept_2d, animation_clip, rig, audio_music,
     audio_sfx, voice, narrative_text}`
   - `risk_tier`: integer `{1, 2, 3}`
   - `modality`: one of `{text_to_3d, image_to_3d, text_to_texture, text_to_image,
     video_to_mocap, procedural, text_to_motion, auto_rig, text_to_audio, text_to_voice}`
   - `prompt_inputs`: non-empty object (must have at least one field)
   - `art_direction_refs`: array (may be empty, but must be present; each ref must resolve
     to a Canon-KB entry if non-empty — checked as a secondary pass)
   - `output_formats`: non-empty array; each value in `{usd, glb, fbx, obj, wav, mp3,
     ogg, png, jpg, webp}`
   - `budget`: object with at minimum `polycount_max` for 3D modalities or `duration_max_s`
     for audio modalities
3. **Happy path:** All required fields are present, typed correctly, and inter-field
   consistency checks pass (e.g., `modality` is compatible with `asset_class`).
   - Schema validation emits `{valid: true}`.
   - The orchestrator proceeds to risk-tier assignment (BC-4.02.002) and backend selection.
4. **Failure path A:** One or more required fields are missing.
   - Reject with error `E-SVC-001` ("generation request schema invalid: missing required
     field(s): [list]").
   - Request is NOT dispatched.
5. **Failure path B:** A field value is of wrong type or outside allowed values.
   - Reject with error `E-SVC-002` ("generation request schema invalid: field '<name>'
     value '<value>' is not in allowed set / wrong type").
6. **Failure path C:** `art_direction_refs` contains IDs that do not resolve to any
   Canon-KB entry (secondary validation pass).
   - Reject with error `E-SVC-003` ("generation request art_direction_refs contain
     unresolved Canon-KB IDs: [list]").
   - This check is skipped if `art_direction_refs` is empty.
7. **Failure path D:** `modality` is incompatible with `asset_class`
   (e.g., `modality: auto_rig` with `asset_class: texture_material`).
   - Reject with error `E-SVC-004` ("generation request modality '<m>' is not valid for
     asset_class '<c>'").

## Postconditions

- **Valid request:** The request has a machine-readable `{valid: true, request_id: <uuid>}`
  validation receipt that is recorded alongside the request before dispatch.
- **Invalid request:** The request is in `status: rejected` with the error code and
  field details. The producer role receives notification. No backend was contacted.

## Invariants

- Schema validation always runs before any backend contact. No bypass path exists.
- The canonical schema is version-controlled and deployed with the factory; changes require
  a version bump and are backward-incompatible if fields are removed.
- `request_id` must be unique across all active requests; duplicate request_ids are rejected
  with `E-SVC-005`.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `risk_tier: "1"` (string instead of integer 1) | Reject E-SVC-002 |
| EC-002 | `art_direction_refs: []` (empty array) | Valid; secondary Canon-KB check is skipped |
| EC-003 | `art_direction_refs: ["canon-entity-999"]` where 999 does not exist | Reject E-SVC-003 |
| EC-004 | `output_formats: ["mp4"]` (not in allowed set) | Reject E-SVC-002 |
| EC-005 | `prompt_inputs: {}` (empty object) | Reject E-SVC-001 (empty prompt_inputs not allowed) |
| EC-006 | Request is otherwise valid but `request_id` duplicates an in-flight request | Reject E-SVC-005 |
| EC-007 | `modality: text_to_3d` with `asset_class: audio_music` | Reject E-SVC-004 (incompatible combination) |
| EC-008 | `budget` object is absent for a `text_to_3d` modality | Reject E-SVC-001 (budget required for 3D) |
| EC-009 | `budget.polycount_max` is present but 0 | Reject E-SVC-002 (polycount_max must be > 0) |

## Canonical Test Vectors

| Scenario | Expected |
|----------|---------|
| Fully valid 3D prop request | `{valid: true}`, dispatch proceeds |
| Valid music request with all required fields | `{valid: true}`, dispatch proceeds |
| Missing `asset_class` | E-SVC-001 |
| `risk_tier: 4` | E-SVC-002 |
| `modality: auto_rig`, `asset_class: audio_sfx` | E-SVC-004 |
| `art_direction_refs: ["nonexistent-id"]` | E-SVC-003 |
| Duplicate `request_id` | E-SVC-005 |

## Verification Properties

- **VP-4.02.001-a:** `∀ dispatch d: d.request.validation_receipt.valid = true`
- **VP-4.02.001-b:** `∀ rejected r: r.error_code ∈ {E-SVC-001, E-SVC-002, E-SVC-003, E-SVC-004, E-SVC-005}`
- **VP-4.02.001-c:** `∀ r1, r2 ∈ active_requests: r1.request_id ≠ r2.request_id`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — the GenerationRequest is the primary input artifact for the asset generation pipeline; this BC defines the structural contract that all requests must satisfy before generation begins. A malformed request cannot produce a compliant provenance sidecar (DI-003), making schema validation a precondition for the entire capability. |
| L2 Invariants | DI-003 (provenance completeness depends on well-formed request carrying prompt_inputs and art_direction_refs), DI-012 (contracts must declare validation method — this BC declares schema-validation as the method for GenerationRequest) |
| L2 Processes | PROC-003 §Stage 3 (Generation) — validation is the gate before generation |
| L2 Risks | R-009 (confabulation meta-risk — structured schema prevents agent confabulation in request construction) |
| L2 Entities | GenerationRequest |

## Related BCs

- **BC-4.02.002** (depends on this): risk-tier assignment runs after schema validation
- **BC-4.01.002** (depends on this): backend selection runs after schema validation
- **BC-4.03.001** (downstream): provenance sidecar populated from validated request fields

## Architecture Anchors

- RECONCILIATION §9 (Asset Generation Pipeline): generation-request schema sketch §7.1
- Domain entities: entities.md §GenerationRequest
- prd-supplements/prd-cap-004.md §8.3 (required sidecar fields — downstream of this contract)

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
