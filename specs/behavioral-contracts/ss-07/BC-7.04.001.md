---
document_type: behavioral-contract
level: L3
version: "1.2"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-06
capability: CAP-007
priority: P0
lifecycle_status: active
introduced: v0.1.0
modified:
  - pass: "Pass-28"
    reason: "I28-01 fix: replaced `human-gated task (DI-006)` vocabulary for the directed:true cinematic creative sign-off (postcondition 3, test vector, Traceability) with D-013 creative-gate vocabulary (creative-gate checklist item, E-CIN-003, DI-007). The D-ASSET dimension remains DEGRADED while creative sign-off is pending — gating semantics preserved. ADR-0007 `human-gated` fidelity tier is reserved for external third-party acts only."
  - pass: "Pass-32"
    reason: "I-PASS32-01 fix: removed spurious DI-007 from cinematic creative-gate contexts. Postcondition 3 was `D-013/DI-007 creative gate` — corrected to `D-013 creative gate`. Traceability L2 Domain Invariants row removed DI-007 (cinematic creative gate is anchored to D-013 + E-CIN-003; it has no corresponding DI). DI-003 and DI-012 retained."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.04.001: Asset-Completeness Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #4: asset-completeness.
This dimension is GREEN when all asset-generation requests are fulfilled, all
asset packages are schema-valid, all provenance sidecars are complete (including
`disclosure_class`), quality-gate reports pass per risk tier, all sequence-graph
asset references resolve, and the `ai-disclosure-manifest` has been generated.
Degrades gracefully for Tier-2/3 assets (pure-maximal: flag-but-ingest) and for
assets with `directed: true` cinematics (adds human sign-off gate).

## Preconditions

1. The `game-production-plan` declares all `asset-generation-requests` for the
   current production milestone.
2. The asset store has a registry of ingested assets with schema-valid GLB packages
   and provenance sidecars.
3. The quality-gate report per asset is available (topology/UV/PBR/loudness/
   provenance completeness checks).
4. The `sequence-graph` (if present) lists asset references; the asset store
   can validate that each reference resolves.
5. The `ai-disclosure-manifest` generation pipeline is operational.

## Postconditions

1. **GREEN:** All requested assets are ingested, schema-valid, provenance-complete
   (including `disclosure_class`), and quality-gate reports pass. All
   sequence-graph asset refs resolve. `ai-disclosure-manifest` generated.
2. **DEGRADED (Tier-2/3 flag-but-ingest):** Assets flagged with Tier-2/3 risk are
   ingested per pure-maximal policy. Quality-gate failures for Tier-2/3 are noted
   in the convergence-report but do not block GREEN. Tier-1 failures DO block.
3. **DEGRADED (directed: true):** Cinematic assets with `directed: true` flag
   require cinematic-director creative sign-off (D-013 creative gate). The dimension
   is DEGRADED until sign-off is recorded; a creative-gate checklist item is surfaced
   (E-CIN-003 if absent at ship-build gate). This is a D-013 creative gate —
   NOT a `human-gated` fidelity tier task per ADR-0007/DI-006.
4. **BLOCKED:** Any Tier-1 asset fails quality-gate without a declared fallback.
   Missing `disclosure_class` on any asset. Missing `ai-disclosure-manifest`.

## Invariants

1. Zero assets may be ingested without a provenance sidecar including `disclosure_class`
   (DI-003). This is a hard invariant — no degradation path.
2. The `ai-disclosure-manifest` is derived from provenance sidecars — no new data
   is required; missing manifest means the generation pipeline failed, not a data gap.
3. Tier-1 asset quality-gate failures are always BLOCKED; Tier-2/3 are flag-but-ingest.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Asset generation tool outage; 5 assets not generated | BLOCKED if the assets are Tier-1; DEGRADED if Tier-2/3 with fallback declared |
| EC-002 | Sequence-graph references an asset by ID that was deleted from asset store | BLOCKED; broken reference is a hard asset-completeness failure |
| EC-003 | Provenance sidecar present but `disclosure_class` field is null | BLOCKED; DI-003 prohibits null disclosure_class |
| EC-004 | `ai-disclosure-manifest` not yet generated (pipeline not yet run) | BLOCKED; manifest generation is a required output before asset-completeness is GREEN |
| EC-005 | All assets present and valid but quality-gate ran 48h ago (stale) | Advisory: quality-gate results are stale; re-run recommended; not a hard block unless declared staleness policy exists |
| EC-006 | No assets declared in game-production-plan (trivial/prototype game) | DEGRADED with advisory: no assets declared; dimension vacuously satisfied for production assets; manifest still required even if empty |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| 50 assets, all Tier-1, all quality-gate PASS, provenance complete | asset-completeness = GREEN | happy-path |
| 50 assets: 48 PASS, 2 Tier-1 FAIL quality-gate | BLOCKED; "2 Tier-1 assets failed quality-gate" | error |
| 50 assets: 48 PASS, 2 Tier-2 FAIL quality-gate | DEGRADED; "2 Tier-2 assets flagged; ingested per pure-maximal policy" | edge-case (Tier-2) |
| 50 assets complete; 1 cinematic with directed:true pending sign-off | DEGRADED; creative-gate checklist item surfaced for cinematic-director (E-CIN-003 at ship-build gate) | edge-case (directed) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-023 | Asset without `disclosure_class` is always BLOCKED regardless of risk tier | kani (provenance-check function: disclosure_class == null → BLOCK) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #4 (asset-completeness) |
| L2 Domain Invariants | DI-003 (every generated asset has complete provenance sidecar), DI-012 |
| Architecture Module | convergence-tracker / asset-completeness-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.08.001 — related to (provenance/legal dimension also checks provenance sidecar completeness; the two dimensions share the same data)
- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Asset-Completeness Convergence Dimension
