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
  - .factory/planning/research/aaa/art-pipeline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-005
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

# BC-5.02.002: Art Bible Spec Provides Deterministic Generation Parameters

## Description

The art-director agent produces an `art-bible.spec` that fully parameterizes the visual
art pipeline: style profile, palette, material standards, texel density standard, polygon
budgets per asset class, shader template references, and the automation ceiling declaration.
This contract must be schema-valid and must provide sufficient parameters for the
asset-generation-orchestrator to make deterministic tool/backend routing decisions and for
the quality gate (BC-5.02.001) to evaluate against. The `art-bible.spec` is the authoritative
source for all art production parameters; no generation agent invents parameters absent
from the spec.

## Preconditions

1. A `GameSpec` exists with `genre_profile` and `art_direction_intent` fields (the latter
   may be prose; it seeds the art-director's generation).
2. The `art-bible.spec` schema (v1.0 or later) is registered in the schema registry.
3. The art-director agent has completed its generation pass.

## Postconditions

1. An `art-bible.spec` artifact exists with the following fields populated:
   - `style_profile`: one of the declared factory styles ("photorealistic-pbr", "stylized-pbr",
     "hand-painted", "cel-shaded", "voxel", "pixel-art", "custom") or a custom declaration
     with full parameter set
   - `palette`: array of hex color codes (minimum 3; maximum 32 for the declared palette)
   - `material_standards`: minimum required material channels per asset type
   - `texel_density_px_per_m`: number (default 512)
   - `poly_budgets`: map of `{asset_class → {min: number, max: number}}`; must include
     at minimum: "hero_character", "environment_prop", "background_element"
   - `shader_template_refs`: array of engine-neutral shader spec references
   - `automation_ceiling`: map of `{pipeline_stage → "auto" | "assist" | "human"}`
2. Schema validation passes (exit 0).
3. For each asset class listed in `poly_budgets`, `min ≤ max` and both are positive integers.
4. `texel_density_px_per_m` is a positive number ≥ 64.
5. An `art-bible-validation-report` is emitted with schema status and parameter completeness
   check.
6. If any required field is missing or invalid, E-ART-003 is raised; generation agents
   are blocked from requesting assets until the spec is corrected.

## Invariants

1. (DI-008) `shader_template_refs` must reference engine-neutral shader specs only. No
   engine-specific shader format (HLSL/GLSL/SpirV-specific shader file, Unity ShaderGraph
   asset, UE Material Blueprint) may appear as a `shader_template_ref` at the spec level.
2. The `art-bible.spec` is immutable once the design bundle is accepted. Changes require a
   formal art-bible revision; all dependent asset requests must be re-evaluated.
3. `poly_budgets` must cover all asset classes that appear in `asset-generation-requests`
   for this game. An asset-generation-request for an unknown asset class raises E-ART-003
   at request creation time.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Style profile declared as "custom" with incomplete parameter set | Schema requires `custom_params` object; if missing, E-ART-003 raised |
| EC-002 | poly_budgets min > max for "hero_character" | E-ART-003 raised; validation blocked |
| EC-003 | shader_template_refs contains a reference to a Unity ShaderGraph file | E-ART-003 raised: engine-specific shader ref detected; DI-008 violation |
| EC-004 | art-bible.spec revised after first asset batch generated | Revision workflow triggered; existing assets flagged for re-evaluation against new spec; producer notified |
| EC-005 | palette contains only 1 color | Schema minimum is 3; E-ART-003 raised |
| EC-006 | automation_ceiling declares all stages as "auto" | Valid declaration; downstream agents use automation_ceiling to select pipeline; no block |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Complete art-bible.spec: style_profile=stylized-pbr, palette=[#a1b2c3, #d4e5f6, #789012], all poly budgets with min<max, texel_density=512, engine-neutral shader refs | art-bible-validation-report: pass; art-director outputs accepted | happy-path |
| Missing `poly_budgets` field | E-ART-003: poly_budgets required field missing | error |
| poly_budgets.hero_character.min=5000, max=3000 | E-ART-003: min > max for hero_character | error |
| shader_template_refs: ["unity://ShaderGraph/PBR.shadergraph"] | E-ART-003: engine-specific shader ref; DI-008 violation | error |
| texel_density_px_per_m = 32 (below minimum 64) | E-ART-003: texel_density below minimum 64 | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.02.004 | For all valid art-bible.spec inputs, schema validator exits 0 | test corpus: 100 valid instances |
| VP-5.02.005 | For all shader_template_refs, absence of engine-specific keywords blocks validation | proptest: inject engine-specific terms, assert all rejected |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the art-bible.spec is the authoritative art direction artifact named in RECONCILIATION §5.1 and §6.1 as owned by the art-director agent role within CAP-005. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer) |
| Architecture Module | SS-TBD — art bible validator; art direction schema registry |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.02.001 — depends on (quality gate uses poly_budgets and texel_density from this spec)

## Architecture Anchors

- `architecture/SS-TBD-art-pipeline.md` — art-bible validation

## Story Anchor

S-TBD — Art Bible Spec Generation and Validation

## VP Anchors

- VP-5.02.004 — schema validity on valid inputs
- VP-5.02.005 — engine-specific shader ref rejection
