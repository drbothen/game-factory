---
document_type: behavioral-contract
level: L3
id: BC-4.01.001
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

# BC-4.01.001: AssetAdapter Declares a Valid `backend_class` from Canonical Taxonomy

## Description

Every AssetAdapter registered in the factory must declare a `backend_class` field from
the canonical six-value taxonomy. The factory's adapter registry rejects any adapter whose
`backend_class` is absent, null, or outside the allowed value set. This enforces the
structural contract that routing logic can always branch on a known, finite set of
automation-hostility levels.

## Preconditions

1. A new or updated AssetAdapter manifest is submitted to the factory adapter registry.
2. The manifest is a parseable document (YAML or JSON) with at least an `adapter_id`,
   `asset_classes[]`, and `backend_class` field.
3. The factory adapter registry is in an operational state and able to validate manifests.

## Behavior

1. The registry reads the `backend_class` field from the submitted manifest.
2. The registry validates `backend_class` against the canonical taxonomy:
   `{cloud-api, headless-cli, mcp-headless, mcp-gui, saas-ui, desktop-gui}`.
3. **Happy path:** `backend_class` is one of the six canonical values.
   - The adapter is accepted into the registry and marked `status: active`.
   - No error is emitted.
4. **Failure path A:** `backend_class` is missing or null.
   - The registry rejects the manifest with error `E-AAG-001` (sidecar: "backend_class is
     required; field absent or null").
   - The adapter is NOT added to the registry.
5. **Failure path B:** `backend_class` has a value not in the canonical taxonomy.
   - The registry rejects the manifest with error `E-AAG-002` (sidecar: "backend_class
     '<value>' is not a recognized taxonomy value").
   - The adapter is NOT added to the registry.

## Postconditions

- **Accept case:** The adapter registry contains an entry for the adapter with
  `backend_class` equal to the submitted value. The value is accessible to the routing
  policy at dispatch time.
- **Reject case:** The adapter registry does NOT contain an entry for the rejected adapter.
  The error code and message are recorded in the registry operation log.

## Invariants

- `backend_class` on an accepted adapter is immutable once registered; changing it requires
  de-registering and re-registering with a new adapter version.
- The set of valid `backend_class` values is closed; no additional values may be introduced
  without a schema version bump and a corresponding routing policy update.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `backend_class` field is present but value is empty string `""` | Reject with E-AAG-001 (treated as null/absent) |
| EC-002 | `backend_class` value uses wrong case, e.g. `"Cloud-API"` | Reject with E-AAG-002; taxonomy values are case-sensitive lowercase |
| EC-003 | Manifest is otherwise valid but includes an unrecognized field alongside a valid `backend_class` | Accept; unknown fields are ignored (forward-compatible) |
| EC-004 | Adapter re-submission with same `adapter_id` and valid `backend_class` but changed value | Reject unless submitted as an explicit version update; version bump required |
| EC-005 | Adapter declares `desktop-gui` as `backend_class` | Accept registration (valid taxonomy value); routing policy blocks automated dispatch separately (see BC-4.01.002) |

## Canonical Test Vectors

| Input `backend_class` | Expected outcome |
|-----------------------|-----------------|
| `"cloud-api"` | Accept |
| `"headless-cli"` | Accept |
| `"mcp-headless"` | Accept |
| `"mcp-gui"` | Accept |
| `"saas-ui"` | Accept |
| `"desktop-gui"` | Accept |
| `"rest-api"` | Reject E-AAG-002 |
| `null` | Reject E-AAG-001 |
| `""` | Reject E-AAG-001 |
| `"Cloud-API"` (wrong case) | Reject E-AAG-002 |

## Verification Properties

- **VP-4.01.001-a:** `∀ adapter ∈ registry: adapter.backend_class ∈ {cloud-api, headless-cli, mcp-headless, mcp-gui, saas-ui, desktop-gui}`
- **VP-4.01.001-b:** `∀ rejection: rejection.error_code ∈ {E-AAG-001, E-AAG-002}`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — this BC defines the structural precondition for all asset routing: a well-typed adapter taxonomy that the routing policy (BC-4.01.002) branches on. Without valid `backend_class` values, no deterministic routing is possible. |
| L2 Invariants | None directly governing taxonomy format; DI-012 (Every ContractArtifact Has a Declared Validation Method) — validation method is declared via the Verification Properties section (VP-4.01.001-a/b: property-based and unit tests) |
| L2 Processes | PROC-003 §Stage 2 (Backend Selection) |
| L2 Risks | R-005 (quality gap), R-009 (confabulation prevention via explicit allowed-values) |
| L2 Failure Modes | FM-004 (provenance missing — downstream; this BC is upstream prerequisite) |

## Related BCs

- **BC-4.01.002** (depends on): routing policy operates on the `backend_class` value declared here
- **BC-4.01.003** (depends on): ToS exclusion check reads `adapter_id`; `backend_class` is prerequisite for selection
- **BC-4.01.004** (depends on): music-route blocking reads `backend_class` and `asset_classes[]`

## Architecture Anchors

- Asset-adapter seam: RECONCILIATION §5A (asset-adapter: "N generative backends for one asset class")
- backend_class taxonomy: prd-supplements/prd-cap-004.md §8.1

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
