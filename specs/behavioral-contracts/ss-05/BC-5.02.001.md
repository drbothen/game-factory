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
subsystem: SS-04
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

# BC-5.02.001: Art Package (GLB) Passes Quality Gate and Carries Complete Provenance

## Description

Every art asset produced by the factory (3D mesh, texture, rig, animation clip, VFX
descriptor) is exported as a GLB package and must pass the quality gate before being
ingested into the asset store. The quality gate checks: topology well-formedness (no
non-manifold geometry), UV seam count within budget, PBR material completeness (albedo +
normal + ORM at minimum), polygon count within the `art-bible.spec` budget for the asset
class, and texel density conformance. Additionally, every GLB ingest requires an inseparable
`asset-provenance-sidecar` with all required fields present, including `disclosure_class`.
A GLB without a complete sidecar is never ingested, per DI-003.

## Preconditions

1. An `asset-generation-request` exists with `asset_class`, `risk_tier`, and `art_direction_refs[]`
   pointing to a valid `art-bible.spec`.
2. The `art-bible.spec` for this game specifies poly budget ranges per asset class, texel
   density standard (px/m), and PBR material requirements.
3. A GLB file exists at the generation output path, produced by the generation agent.
4. An `asset-provenance-sidecar` JSON file exists at `<glb_path>.provenance.json` with
   the following fields present and non-null: `generated_by_tool`, `generation_date`,
   `prompt_and_inputs_log`, `license_terms_snapshot`, `disclosure_class`.
5. The quality gate tooling (Blender Python API headless, or equivalent geometry validator)
   is available in the pipeline.

## Postconditions

1. The quality gate runs the following checks on the GLB file:
   a. **Topology**: no non-manifold edges or vertices (checked via geometry validator)
   b. **UV**: UV seams within declared budget in art-bible.spec (or default ≤ 100 seams for
      a standard prop)
   c. **PBR materials**: albedo map, normal map, and ORM (Occlusion/Roughness/Metalness)
      map present for each mesh
   d. **Polygon count**: within [min, max] declared for this `asset_class` in `art-bible.spec`
   e. **Texel density**: meets or exceeds the declared texel density standard (±20% tolerance)
2. **Provenance sidecar completeness check**: all required sidecar fields are present and
   non-null. `disclosure_class` must be one of: `"pre-generated"` | `"live-generated"` |
   `"procedural-exempt"`.
3. If ALL quality gate checks pass AND sidecar is complete:
   - Asset is ingested to asset store with status `"accepted"`.
   - `risk_tier` is recorded in asset store entry.
   - A `quality-gate-report` with status `"pass"` is emitted.
4. If any quality gate check fails:
   - E-ART-001 is raised per failing check.
   - Asset is NOT ingested.
   - Re-generation is triggered with adjusted parameters logged in `quality-gate-report`.
5. If sidecar is missing or any required field is null:
   - E-ART-002 is raised (DI-003 violation).
   - Asset is NOT ingested regardless of quality gate status.
   - This is a separate error from quality gate failure.
6. For Tier-2 and Tier-3 risk assets: quality gate failure DOES still produce a flag and
   re-generation attempt (pure-maximal principle), but asset is eventually ingested if
   re-generation also fails, with `status: "accepted-with-flags"` and flags recorded.
   Tier-1 assets: quality gate failure blocks ingestion until corrected.

## Invariants

1. (DI-003) An asset without a complete provenance sidecar is NEVER ingested. No exception.
   This invariant takes priority over the pure-maximal principle.
2. (DI-003) The `disclosure_class` field is always set at generation time, never retroactively.
3. Sidecar and GLB are always stored as an inseparable pair. Deleting one without the other
   is a defect flagged by the asset store integrity check.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | GLB contains a mesh with zero polygons (empty mesh from failed generation) | Topology check fails (degenerate); E-ART-001 raised; re-generation triggered |
| EC-002 | `disclosure_class` field present but set to an unknown value (e.g., "ai-generated") | E-ART-002 raised: unknown disclosure_class value; sidecar schema validation fails |
| EC-003 | Art-bible.spec declares poly budget for asset_class "hero_character" = [8000, 12000]; generated mesh has 15000 polys | Quality gate fails: poly count out of budget; E-ART-001; re-generation with budget constraint |
| EC-004 | PBR material present but albedo map is 1×1 pixel placeholder | Quality gate accepts (no minimum resolution declared in base schema); art-bible.spec may declare minimum resolution; if declared and violated, E-ART-001 |
| EC-005 | Tier-3 asset fails quality gate twice; re-generation also fails | Accepted with `status: "accepted-with-flags"`; flags include both failure reasons; recorded in quality-gate-report; downstream consumers notified |
| EC-006 | SAG-AFTRA consent required for voice asset (likeness_consent_ref != null in sidecar) | Separate human-gated SAG-AFTRA signature flow triggered; asset remains in "pending-consent" state; not usable in final build until consent obtained |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Valid GLB hero prop, poly count 2500 (budget 1000-5000), complete PBR, texel density 512 px/m (standard 512 px/m), complete sidecar with disclosure_class=pre-generated | quality-gate-report: pass; asset ingested with status=accepted | happy-path |
| Valid GLB but sidecar missing `disclosure_class` field | E-ART-002; asset NOT ingested regardless of quality gate | error |
| GLB with non-manifold edge in mesh 0 | E-ART-001: check=topology, mesh=0; re-generation triggered | error |
| Tier-2 asset, poly count 10× over budget, re-generate also fails | status=accepted-with-flags; both failures logged; report emitted | edge-case |
| Empty provenance sidecar file (all fields null) | E-ART-002; asset NOT ingested; error enumerates all missing fields | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.02.001 | For all assets, absence of complete sidecar always blocks ingestion (DI-003) | proptest: 1000 ingest attempts with missing sidecar fields; assert all blocked |
| VP-5.02.002 | GLB with valid topology and complete PBR and in-budget poly count and valid sidecar always produces accept status | proptest: generate valid GLB + sidecar corpus |
| VP-5.02.003 | Re-generation is always triggered on quality gate failure for Tier-1 assets (never silently accepted) | test: Tier-1 failure → re-generation event in audit log |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — art packages (GLB) are the primary art artifact produced by the Studio-of-Agents; this BC defines the machine-checkable production and ingest contract for that artifact class. |
| L2 Domain Invariants | DI-003 (Every Generated Asset Has a Complete Provenance Sidecar) |
| Architecture Module | SS-04 — art quality gate; asset ingest pipeline; provenance sidecar validator |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.02.002 — depends on (art-bible.spec defines budgets used by quality gate)
- BC-5.07.002 — depends on (cross-discipline dependency contract checks asset completeness)

## Architecture Anchors

- `architecture/SS-04-art-pipeline.md` — quality gate, GLB validation
- `architecture/SS-04-asset-store.md` — asset ingest, provenance check

## Story Anchor

S-TBD — Art Package Quality Gate and Ingest

## VP Anchors

- VP-5.02.001 — sidecar-completeness gate (DI-003)
- VP-5.02.002 — happy-path accept invariant
- VP-5.02.003 — Tier-1 re-generation trigger
