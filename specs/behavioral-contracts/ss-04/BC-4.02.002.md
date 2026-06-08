---
document_type: behavioral-contract
level: L3
id: BC-4.02.002
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

# BC-4.02.002: Risk Tier Is Assigned from Asset Class and Use-Case at Request Creation Time

## Description

Every GenerationRequest must have a `risk_tier` (integer 1, 2, or 3) assigned at request
creation time, before backend selection. The risk tier governs which backends are eligible
(Tier-1 tools only for Tier-1 assets), what provenance fields are mandatory, and what
post-generation handling (auto-ingest vs flag-for-record) applies. Risk tier is derived
deterministically from the `asset_class` and `use_case_context` fields of the request using
the canonical tier assignment policy defined in this BC.

## Preconditions

1. A GenerationRequest has passed schema validation (BC-4.02.001).
2. The request has a valid `asset_class` value.
3. The canonical risk-tier assignment policy table is loaded (see Behavior §2).

## Behavior

1. The orchestrator reads `asset_class` and optional `use_case_context` from the validated
   GenerationRequest.
2. The orchestrator applies the canonical tier assignment table:

   | `asset_class` | Default `use_case_context` | Default risk_tier |
   |--------------|---------------------------|-------------------|
   | `texture_material` | any | 1 |
   | `terrain` | any | 1 |
   | `vegetation` | any | 1 |
   | `level_layout` | any | 1 |
   | `prop` | `background`, `kitbash`, `filler` | 1 |
   | `prop` | `hero`, `signature` | 3 |
   | `prop` | (unspecified / other) | 2 |
   | `character_npc` | `background`, `crowd` | 1 |
   | `character_npc` | `secondary`, `named` | 2 |
   | `character_hero` | any | 3 |
   | `concept_2d` | `internal`, `draft` | 1 |
   | `concept_2d` | `final`, `marketing`, `shipping` | 2 |
   | `animation_clip` | `locomotion`, `background` | 1 |
   | `animation_clip` | `hero`, `cinematic` | 3 |
   | `rig` | any | 2 |
   | `audio_sfx` | any | 1 |
   | `audio_music` | any | 1 (only DI-009-compliant providers eligible, BC-4.01.004) |
   | `voice` | `synthetic_non_performer` | 1 |
   | `voice` | `named_performer_likeness` | 3 |
   | `voice` | (unspecified) | 2 |
   | `narrative_text` | any | 1 |

3. If the request already has a `risk_tier` field set by the requesting agent, the
   orchestrator validates that it matches the computed tier:
   - If they match: accept and proceed.
   - If they differ AND the request has an explicit `risk_tier_override_justification`
     field: accept the override; log a `WARN`-level audit entry with the justification.
   - If they differ AND no justification is present: reject with error `E-SVC-010`
     ("risk_tier mismatch: computed '<n>' but request specifies '<m>' with no justification").
4. The final `risk_tier` is written back to the request as an immutable field.

## Postconditions

- The request has `risk_tier` set to an integer in `{1, 2, 3}` and this field is immutable
  after this step.
- If the tier was computed (not overridden), the computation audit log records `asset_class`,
  `use_case_context`, and assigned `risk_tier`.
- If an override was accepted, the override justification is recorded in the request's
  audit trail.

## Invariants

- Risk tier is NEVER absent on a dispatched request; it is always one of `{1, 2, 3}`.
- The canonical tier assignment table is a factory constant; it is not configurable
  per-project.
- A Tier-3 request triggers downstream quality-gate behavior (flag for quality report,
  never auto-ingest without record) regardless of whether the asset eventually passes.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `asset_class: prop`, `use_case_context` absent | Default tier 2 (unspecified) |
| EC-002 | `asset_class: character_hero`, requester sets `risk_tier: 1` without justification | Reject E-SVC-010 (computed is 3) |
| EC-003 | `asset_class: character_hero`, requester sets `risk_tier: 1` WITH justification "prototype only, not shipped" | Override accepted, WARN logged |
| EC-004 | `asset_class: audio_music`, `use_case_context: hero_theme` | Tier 1 (music is always tier 1 for routing; DI-009-compliant only) |
| EC-005 | `asset_class: voice`, `use_case_context` absent | Default tier 2 |
| EC-006 | `asset_class: voice`, `use_case_context: named_performer_likeness` | Tier 3; triggers BC-4.03.004 likeness consent gate downstream |
| EC-007 | `asset_class: terrain` | Tier 1; auto-ingest eligible if quality gate passes |

## Canonical Test Vectors

| asset_class | use_case_context | Expected risk_tier |
|-------------|-----------------|-------------------|
| `texture_material` | `surface_detail` | 1 |
| `character_hero` | `protagonist` | 3 |
| `prop` | `kitbash` | 1 |
| `prop` | `signature_weapon` (maps to `hero`) | 3 |
| `audio_music` | `ambient_loop` | 1 |
| `voice` | `named_performer_likeness` | 3 |
| `voice` | `synthetic_non_performer` | 1 |
| `concept_2d` | `marketing` | 2 |
| `animation_clip` | `hero` | 3 |
| `narrative_text` | `quest_log` | 1 |

## Verification Properties

- **VP-4.02.002-a:** `∀ request r after tier assignment: r.risk_tier ∈ {1, 2, 3}`
- **VP-4.02.002-b:** `∀ request r: r.risk_tier is immutable after assignment`
- **VP-4.02.002-c:** `∀ character_hero request r: r.risk_tier = 3`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — the risk tier is the primary routing and provenance signal in the asset generation pipeline. It determines which backends are eligible (Tier-1 tools for Tier-1 assets), governs post-gate handling (auto-ingest vs flag), and feeds `risk_tier` into the mandatory provenance sidecar (BC-4.03.001). It is the operational encoding of D-006 (pure-maximal with recorded risks). |
| L2 Invariants | DI-003 (provenance sidecar must include risk_tier — this BC ensures it is computed and immutable before generation), DI-012 (Every ContractArtifact Has a Declared Validation Method) — validation method is declared via the Verification Properties section |
| L2 Processes | PROC-003 §Stage 1 (Risk Tier Assignment) |
| L2 Risks | R-001, R-002 (IP/copyright — tier 3 triggers human-modifications attention), R-005 (hero quality gap — tier 3 classification documents the gap) |
| L2 Entities | GenerationRequest |

## Related BCs

- **BC-4.02.001** (depends on): schema validation runs first; tier assignment uses `asset_class` field
- **BC-4.01.002** (downstream): backend selection uses risk_tier for allowable-tool constraint
- **BC-4.03.001** (downstream): provenance sidecar must record the assigned `risk_tier`
- **BC-4.03.004** (triggered by): `risk_tier: 3` + `voice` asset class with likeness triggers the consent gate

## Architecture Anchors

- RECONCILIATION §9 (Asset Lane §Risk Tier): "Tier-1 = licensed/indemnified tools. Tier-2 = some indemnification. Tier-3 = unindemnified."
- RECONCILIATION §9 (Quality Gate): "pass + Tier-1: auto-ingest. pass + Tier-2/3: flag for record; ingest anyway (pure-maximal decision)"
- Domain entities: entities.md §GenerationRequest, §AssetAdapter

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
