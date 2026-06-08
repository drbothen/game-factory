---
document_type: behavioral-contract
level: L3
id: BC-4.06.001
origin: greenfield
subsystem: SS-03
capability: CAP-004
priority: P0
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.06.001: Asset Store Ingest Requires Quality Gate Pass, Complete Sidecar, and Consent-Cleared Status

## Description

The asset store ingest hook is the final structural gate before an asset is admitted to
the factory's canonical asset store. Ingest requires three conditions simultaneously:
(1) quality gate has been evaluated and its result is either `pass` or `flagged-and-allowed`
(Tier-2/3 flag); (2) the provenance sidecar is schema-valid and complete (including
`disclosure_class`); and (3) the asset is not in `ship_blocked: true` state due to an
outstanding likeness consent task. An asset that fails any of these conditions is rejected
at the ingest boundary and does not enter the asset store.

## Preconditions

1. An asset has completed generation (a raw asset binary exists with an attached sidecar).
2. The quality gate has been run on the asset (BC-4.04.001, BC-4.04.002, or BC-4.04.003).
3. The provenance sidecar has been validated (BC-4.03.001, BC-4.03.002, BC-4.03.003).
4. The human-gated task system has been checked for outstanding consent tasks (BC-4.03.004).
5. The asset store ingest hook is running as part of the factory CI pipeline.

## Behavior

The ingest hook runs three pre-flight checks in order:

**Pre-flight check 1 — Quality Gate Result:**
- Read the asset's `quality_gate_status` field from the quality-gate-report.
- Allowed values for ingest: `pass` (all tiers), `flagged` (Tier-2/3 only).
- NOT allowed for ingest: `fail` (any tier with hard provenance failure), `not_run`
  (quality gate was skipped), `quality_blocked` (Tier-1 that failed after retries).
- **Pass:** quality_gate_ok = true.
- **Fail:** E-ING-001 ("asset quality_gate_status '<status>' not eligible for ingest").

**Pre-flight check 2 — Provenance Sidecar Completeness:**
- Validate the sidecar against the canonical `provenance-sidecar.schema.json`.
- All required fields present and non-null (except `likeness_consent_ref` which may be null).
- `disclosure_class` present and valid (one of three allowed values).
- `copyrightability_assessment` present and valid.
- **Pass:** sidecar_ok = true.
- **Fail:** E-ING-002 ("asset sidecar fails schema validation; missing or invalid fields: [list]").

**Pre-flight check 3 — Consent Clearance:**
- If `asset.ship_blocked = true` (outstanding `sag_aftra_consent_signature` task per BC-4.03.004):
  - Reject with E-ING-003 ("asset '<id>' has outstanding SAG-AFTRA consent task '<task_id>';
    cannot be ingested into asset store until consent is cleared").
  - Note: the asset may be held in a `pending_consent` state outside the asset store, but it
    CANNOT be in the canonical store until consent is resolved.
- If `asset.ship_blocked = false` or absent: consent_ok = true.

**Aggregation:**
- **All three pass:** Asset is admitted to the canonical asset store.
  - Asset is stored in canonical format (GLB for 3D; WAV/OGG for audio; PNG for 2D images).
  - Ingest event is logged with asset_id, sidecar hash, quality_gate_status, timestamp.
  - Tier-2/3 flagged assets are stored with a `quality_flagged: true` metadata field.
- **Any pre-flight check fails:** Asset is NOT admitted.
  - Asset remains in the generation pipeline's holding area with `status: ingest_rejected`.
  - Error code and details are recorded.
  - The producing agent is notified of the rejection reason.

## Postconditions

- **Ingested asset:** The asset store entry exists with:
  - The canonical-format asset binary (GLB / WAV / PNG per modality).
  - The complete, immutable provenance sidecar.
  - `quality_gate_status` in `{pass, flagged}`.
  - `ship_blocked: false` (or absent, which is treated as false).
  - An ingest timestamp and ingest_id.
- **Rejected asset:** No asset store entry exists. The asset remains external to the store.

## Invariants

- The ingest hook cannot be bypassed; there is no direct-write path to the asset store.
- An asset's provenance sidecar is immutable after ingest; changes to the asset require
  a new asset_id and a new ingest operation.
- The canonical format is non-negotiable: GLB for 3D (not OBJ, FBX-only, or proprietary);
  WAV for audio (before any engine-specific compression); PNG for 2D (lossless at ingest).
- `not_run` (quality gate was skipped) is always an ingest rejection. Quality gate cannot
  be bypassed.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Tier-1 3D mesh passes all quality gate checks | Ingested with `quality_gate_status: pass`; auto-ingest |
| EC-002 | Tier-2 character mesh fails topology check but passes all others | Ingested with `quality_gate_status: flagged`, `quality_flagged: true` |
| EC-003 | Tier-1 asset, quality_gate_status: fail (after retries), provenance complete | Rejected E-ING-001 (quality_blocked) |
| EC-004 | Asset with `disclosure_class: null` | Rejected E-ING-002 (sidecar schema invalid) |
| EC-005 | Voice asset with `ship_blocked: true` (outstanding consent) | Rejected E-ING-003 |
| EC-006 | Asset is in FBX format, requested GLB | Rejected E-ING-001 if format conversion was not performed upstream; normally the quality gate converts to GLB before the ingest check runs |
| EC-007 | Quality gate was not run (`quality_gate_status` field absent) | Rejected E-ING-001 (`not_run` state) |
| EC-008 | Re-ingest attempt on an existing asset_id (already in store) | Rejected E-ING-004 ("asset '<id>' already exists in store; use versioned re-submission to update") |

## Canonical Test Vectors

| Asset state | quality_gate_status | sidecar_valid | ship_blocked | Expected ingest result |
|------------|--------------------|--------------|--------------|-----------------------|
| Tier-1 prop | `pass` | yes | no | Ingested |
| Tier-2 character | `flagged` | yes | no | Ingested with quality_flagged |
| Tier-1 prop | `fail` | yes | no | Rejected E-ING-001 |
| Any asset | `pass` | no (disclosure_class null) | no | Rejected E-ING-002 |
| Voice asset | `pass` | yes | yes (consent outstanding) | Rejected E-ING-003 |
| Any asset | `not_run` | yes | no | Rejected E-ING-001 |
| Duplicate ID | `pass` | yes | no | Rejected E-ING-004 |

## Verification Properties

- **VP-4.06.001-a:** `∀ asset a ∈ asset_store: a.quality_gate_status ∈ {"pass", "flagged"}`
- **VP-4.06.001-b:** `∀ asset a ∈ asset_store: a.sidecar.schema_valid = true ∧ a.sidecar.disclosure_class ≠ null`
- **VP-4.06.001-c:** `∀ asset a ∈ asset_store: a.ship_blocked ≠ true`
- **VP-4.06.001-d:** `∀ asset a ∈ asset_store: a.quality_gate_report is present` (quality gate was not skipped)

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — the asset store ingest step is the culminating step of the CAP-004 asset generation pipeline (PROC-003 §Stage 6). This BC specifies the gate that determines whether the full pipeline's outputs are coherent and compliant. It directly enforces the success criterion "Generated assets with complete provenance sidecar: 100%; 0 missing disclosure_class." |
| L2 Invariants | **DI-003** ("Every Generated Asset Has a Complete Provenance Sidecar") — this BC is the ingest-time enforcement of DI-003, complementing BC-4.03.001 (generation-time enforcement) |
| L2 Processes | PROC-003 §Stage 6 (Ingest), PROC-006 (Human-Gated Task Surfacing — consent check) |
| L2 Risks | R-001, R-002, R-004, R-014 — all risks mitigated by provenance sidecar; ingest gate ensures provenance is actually present before store admission |
| L2 Failure Modes | **FM-004** ("Provenance Sidecar Missing at Ingest") — this BC is the detection and prevention mechanism for FM-004 at the ingest boundary |
| L2 Entities | Asset, ProvenanceSidecar |

## Related BCs

- **BC-4.03.001** (dependency): sidecar completeness enforced here
- **BC-4.03.002** (dependency): disclosure_class checked here
- **BC-4.03.004** (dependency): consent clearance checked here
- **BC-4.04.001**, **BC-4.04.002**, **BC-4.04.003** (dependency): quality_gate_status comes from these BCs
- **BC-4.05.001** (downstream): license check at ship gate; ingest is a prerequisite

## Architecture Anchors

- PROC-003 §Stage 6 (Ingest): "Asset stored in canonical format (GLB for 3D)"
- DI-003: invariants.md §DI-003
- RECONCILIATION §9 (Quality Gate): "pass + Tier-1: auto-ingest to asset store (GLB canonical format)"
- RECONCILIATION §7 (Convergence dimension #4 asset-completeness): "GLB packages schema-valid; provenance sidecars complete (including disclosure_class)"

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
