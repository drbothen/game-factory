---
document_type: behavioral-contract
level: L3
id: BC-4.05.001
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

# BC-4.05.001: Ship Gate FAILS When Any Build Asset Has `commercial_use: false` or Unresolved Free-Tier Restriction

## Description

At ship-gate evaluation (convergence dimension #4 asset-completeness + convergence dimension
#6 cert-preflight/distribution-readiness), every asset in the proposed ship build is checked
for license compatibility with commercial distribution. An asset whose
`license_terms_snapshot.commercial_use = false` is explicitly incompatible with any shipped
product. An asset on a free tier with known commercial-use restrictions (e.g., Meshy free
plan: personal only; Midjourney free: non-commercial) also causes the gate to fail. This is
the "ship-bound-on-free/CC-BY-tier FAIL hook" mandated by the system prompt.

## Preconditions

1. A ship build candidate has been assembled (a complete list of asset store entries included
   in the build).
2. Every asset in the build has a provenance sidecar (enforced by BC-4.06.001 at ingest time).
3. The ship-gate license checker has access to the factory's `license-tier-compatibility-table`
   (a static lookup mapping `indemnification_tier + commercial_use flag` to `ship_eligible:
   true/false`).
4. The ship-gate runner has the complete build manifest.

## Behavior

1. The ship gate license checker iterates over every asset in the build.
2. For each asset, it reads the provenance sidecar field
   `license_terms_snapshot.commercial_use`.
3. **Per-asset check A — Commercial use explicitly false:**
   - If `commercial_use = false`: the asset is license-incompatible.
   - Add to violation list with error class `E-SHIP-001` ("asset '<id>' has
     commercial_use: false; not eligible for shipped product").
4. **Per-asset check B — Free-tier restriction flag:**
   - The sidecar may carry an optional `license_terms_snapshot.free_tier_restriction`
     field. If this field is present AND value is `"personal_only"` or `"non_commercial"`:
     the asset is license-incompatible.
   - Add to violation list with error class `E-SHIP-002` ("asset '<id>' has
     free_tier_restriction: '<value>'; not eligible for shipped product under commercial license").
5. **Per-asset check C — License tier is unknown:**
   - If `license_terms_snapshot.commercial_use` is null AND the adapter does not have a
     known commercial license (determined from the adapter registry's license declaration):
     the asset is flagged as `license_unresolved`.
   - Add to advisory list (not violation list); the ship gate does NOT fail on advisory-only
     items, but the quality-gate-report lists them for human review.
6. **Aggregation:**
   - If the violation list is empty: license check passes; ship gate proceeds.
   - If the violation list is non-empty: ship gate FAILS with error `E-SHIP-003`
     ("ship build contains <n> asset(s) with license violations; ship blocked until resolved").
   - A structured license-violation-report is emitted listing all violating asset IDs,
     their sidecar license fields, and the error class.

## Postconditions

- **No violations:** License check passes; ship gate records `license_check: pass`.
- **Violations present:** Ship gate is in `status: fail`. The license-violation-report
  lists all violating assets and error codes. The producer must either replace the
  assets with commercially-licensed versions or upgrade to a paid tier and re-ingest
  with updated sidecars.
- Every license check run is recorded with the build manifest hash and timestamp for
  audit trail.

## Invariants

- `commercial_use: false` is an absolute ship-gate failure; there is no override path.
- The license check is re-run on every ship-gate evaluation; it is NOT cached from a
  previous run.
- Assets with `commercial_use: null` (unresolved) do NOT fail the ship gate
  automatically but generate a mandatory advisory; the advisory is surfaced as a
  convergence report item under the `provenance/legal` dimension.
- Assets that pass the license check but have `copyrightability_assessment: unlikely`
  do NOT fail the ship gate (copyright ownership is a studio-legal decision per D-006).

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Tripo3D asset, `commercial_use: true` but `free_tier_restriction: "personal_only"` | Fail E-SHIP-002 |
| EC-002 | Meshy free plan asset, `commercial_use: false` | Fail E-SHIP-001 |
| EC-003 | Adobe Firefly asset on paid CC plan, `commercial_use: true`, no free_tier_restriction | Pass |
| EC-004 | Asset with `commercial_use: null` (adapter didn't record it at generation time) | Advisory (not fail); added to convergence report advisory |
| EC-005 | 50 assets fail; 2 advisories | Fail E-SHIP-003 with 50-item violation list; advisories listed separately |
| EC-006 | Producer replaces 3 violating assets with Firefly-generated versions; re-runs ship gate | Re-runs full check on new build manifest; if no violations remain, passes |
| EC-007 | Asset is CC-BY licensed (attribution required, commercial use allowed) | Passes ship gate (commercial_use: true); attribution requirement noted in advisory |
| EC-008 | Build contains a placeholder asset (never went through quality gate) | Blocked by BC-4.06.001 at ingest; should not reach ship gate; if it does, `commercial_use: null` → advisory |

## Canonical Test Vectors

| Asset sidecar `commercial_use` | `free_tier_restriction` | Expected ship gate result |
|-------------------------------|------------------------|--------------------------|
| `true` | absent | Pass |
| `false` | absent | Fail E-SHIP-001 |
| `true` | `"personal_only"` | Fail E-SHIP-002 |
| `true` | `"non_commercial"` | Fail E-SHIP-002 |
| `null` | absent | Advisory only (not fail) |
| `true` | `"attribution_required"` | Pass (advisory about attribution) |
| 50 assets: 48 pass, 2 fail | mixed | Fail E-SHIP-003 with 2-item violation list |

## Verification Properties

- **VP-4.05.001-a:** `∀ asset a in any shipped build: a.sidecar.license_terms_snapshot.commercial_use = true`
- **VP-4.05.001-b:** `∀ asset a in any shipped build: a.sidecar.license_terms_snapshot.free_tier_restriction ∉ {"personal_only", "non_commercial"}`
- **VP-4.05.001-c:** `ship_gate.result = "fail" ↔ ∃ asset a in build: a.sidecar.commercial_use = false ∨ a.sidecar.free_tier_restriction ∈ {"personal_only", "non_commercial"}`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — the "auto-provenance" component of CAP-004 specifically includes `license_terms_snapshot` in the sidecar (RECONCILIATION §9 sidecar field list). This BC is the ship-time enforcement that the license terms recorded in provenance are actually compatible with distribution. Without this gate, provenance data would be informational only; this BC makes it load-bearing. |
| L2 Invariants | DI-003 (provenance sidecar including license_terms_snapshot is required — this BC uses it as a gate at ship time); DI-012 (Every ContractArtifact Has a Declared Validation Method) — validation method is declared via the Verification Properties section |
| L2 Processes | PROC-003 §Stage 6 (Ingest — this BC fires at a later stage: ship gate) |
| L2 Risks | R-002 ("Training-data indemnification gap") — `commercial_use: false` is the primary R-002 signal in the sidecar; R-003 (music legal hazard — upstream blocked but this is the downstream belt) |
| L2 Failure Modes | FM-004 (provenance fields are the data this BC operates on) |
| L2 Entities | Asset, ProvenanceSidecar |

## Related BCs

- **BC-4.03.001** (dependency): `license_terms_snapshot` is a required sidecar field
- **BC-4.06.001** (complementary): ingest gate checks provenance schema; this BC checks license at ship time
- **BC-4.03.004** (sibling at ship gate): consent check runs in parallel with this license check

## Architecture Anchors

- RECONCILIATION §9 sidecar fields: `license_terms_snapshot: {commercial use, resale_allowed, attribution_required, indemnification tier}`
- generative-asset-ai.md §5.2: "Indemnification splits the market"; Midjourney "user assumes all legal risk"
- generative-asset-ai.md §5.5 (Risk-tier guidance): free/low-risk tiers for bulk content; Tier-3 requires indemnified tools

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
