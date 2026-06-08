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
  - .factory/planning/research/aaa/online-services-platform-distribution.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-08
capability: CAP-009
priority: P1
lifecycle_status: active
introduced: v0.1.0
modified:
  - version: "1.1"
    date: 2026-06-08
    by: product-owner
    reason: "Canonicalize convergence-report dimension field name: dimensions.distribution_readiness → dimensions.cert_preflight per methodology-layer.md §3.0 (D-CERT canonical field). distribution_readiness is semantically subsumed by D-CERT which is titled 'Cert-Preflight + Distribution-Readiness'."
  - version: "1.2"
    date: 2026-06-08
    by: product-owner
    reason: "Pass-10 I-3: replace non-canonical AMBER with DEGRADED-PENDING for cert_preflight dimension status per methodology-layer.md §3.1 canonical enum {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-9.04.001: Distribution-Release-Pipeline Artifact Is Structurally Complete and Version-Stamped

## Description

The `distribution-release-pipeline` is a first-class factory artifact that records the
complete release execution plan and outcome for a game build: which distribution adapters
were invoked, which CLI commands ran, which build-upload-records were produced, the cert
pre-flight status, outstanding human-gated tasks, and the release version stamp. It is
the authoritative provenance record for "how did this build reach its distribution targets."
The artifact must be structurally valid and complete before the D-CERT (cert-preflight +
distribution-readiness) convergence dimension can advance past DEGRADED-PENDING.

## Preconditions

1. At least one distribution adapter has been invoked for the current build version.
2. A `cert-preflight-report` for the build version exists (BC-9.01.001).
3. All build-upload-records for the current build version are finalized (success or failed).
4. The `convergence-report` for the game exists with a writable
   `dimensions.cert_preflight` field.

## Behavior

1. Factory assembles the `distribution-release-pipeline` artifact from:
   - `game_id`, `build_version`, `release_channel` (`{dev|beta|release}`)
   - `cert_preflight_ref`: reference to the `cert-preflight-report` artifact path
   - `adapters_invoked[]`: for each adapter: `{target, adapter_id, actions[],
     upload_records[], fidelity_map}`
   - `human_gated_tasks[]`: list of all outstanding human-gated task records across
     adapters and cert (populated from BC-9.06.001 and BC-9.06.002 records)
   - `store_asset_conformance_ref`: reference to the `store-asset-spec-conformance-report`
     artifact (BC-9.05.001)
   - `overall_distribution_status`: computed as:
     - `COMPLETE` iff all adapters succeeded AND all human-gated tasks are marked complete
     - `PARTIAL` iff at least one adapter succeeded AND outstanding human-gated tasks exist
     - `FAILED` iff any required adapter failed
     - `PENDING` iff any adapter has not yet run
   - `pipeline_timestamp`, `pipeline_version`
2. Emit the artifact to `.factory/artifacts/distribution/<game_id>/<build_version>/
   distribution-release-pipeline.json`.
3. Validate the artifact against `distribution-release-pipeline-v1.schema.json`.
4. Update `convergence-report.dimensions.cert_preflight`:
   - `COMPLETE` → `GREEN`
   - `PARTIAL` → `DEGRADED-PENDING`
   - `FAILED` → `BLOCKED`
   - `PENDING` → `DEGRADED-PENDING`

## Postconditions

- `distribution-release-pipeline.json` exists and validates against the schema.
- Every adapter that was invoked has a corresponding entry in `adapters_invoked[]`.
- Every outstanding human-gated task is listed in `human_gated_tasks[]` — none are silently
  omitted (DI-006).
- `convergence-report.dimensions.cert_preflight` reflects the computed status.

## Invariants

- INV-1: The artifact is immutable once `overall_distribution_status: COMPLETE`; only
  `PENDING` and `PARTIAL` artifacts can be updated.
- INV-2 (DI-006): The `human_gated_tasks[]` array is NEVER empty when there are outstanding
  human-gated distribution steps. Suppression is a hook-detectable defect.
- INV-3: The artifact includes a `pipeline_version` field referencing the schema version
  to ensure forward-compatible parsing.
- INV-4: The `cert_preflight_ref` must point to an actual `cert-preflight-report` artifact;
  a dangling reference is a schema validation error.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | No adapters invoked yet for this build version | `overall_distribution_status: PENDING`; `adapters_invoked: []`; `cert_preflight: DEGRADED-PENDING` |
| EC-002 | All adapters succeeded but human-gated tasks not yet completed | `overall_distribution_status: PARTIAL`; tasks listed in `human_gated_tasks[]` |
| EC-003 | cert-preflight-report missing for build version | Schema validation fails; artifact not emitted; error `E-DIST-040`  |
| EC-004 | Two builds of the same version (rebuild) | New pipeline artifact overwrites previous if status was not `COMPLETE`; version-conflict error if previous was `COMPLETE` |

## Canonical Test Vectors

| State | Expected `overall_distribution_status` | Expected dim |
|-------|---------------------------------------|--------------|
| All adapters PASS, all human tasks complete | `COMPLETE` | `GREEN` |
| Steam upload PASS, Xbox cert human-gated pending | `PARTIAL` | `DEGRADED-PENDING` |
| Steam upload FAIL | `FAILED` | `BLOCKED` |
| No adapters run yet | `PENDING` | `DEGRADED-PENDING` |

## Verification Properties

- VP-DIST-014: `distribution-release-pipeline.json` passes schema validation for every accepted build.
- VP-DIST-015: No `overall_distribution_status: COMPLETE` artifact exists with non-empty
  `human_gated_tasks[]` entries that are not marked `status: complete`.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — the distribution-release-pipeline artifact is the explicit output named in the capability definition ("generates the distribution release pipeline") |
| L2 Invariants | DI-006 (human-gated tasks listed, not dropped), DI-012 (declared validation method) |
| Source Processes | PROC-001 §Stage 6, PROC-006 |
| Research Grounding | AAA-RECONCILIATION §5.9, §5A; online-services-platform-distribution.md §7 |

## Related BCs

- BC-9.01.001 — Cert Pre-Flight Checklist (provides `cert_preflight_ref`)
- BC-9.03.001/002/003 — Distribution CLI executions (provide `upload_records`)
- BC-9.05.001 — Store-Asset Spec Conformance (provides `store_asset_conformance_ref`)
- BC-9.06.001, BC-9.06.002 — Human-Gated Terminal Steps (populate `human_gated_tasks[]`)
