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
  - .factory/planning/design/protocol-schema.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
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

# BC-1.10.002: partial Fidelity assetsValidate Declares Method and Coverage Limitation

## Description

When an adapter declares `assetsValidate` at `fidelity: "partial"` (the confirmed
fidelity for the founding engine adapters), the `AssetValidateResult` must declare
the specific method used and provide a plain-language description of what the method
covers and does not cover. This prevents the factory from treating a partial
validation as equivalent to full coverage, which would create silent quality gaps.

The canonical partial-fidelity case: Unity and Godot adapters validate only
load-triggered assets (those actually instantiated in a headless run), not assets
that are referenced in source but never loaded during the test run.

## Preconditions

1. The `assetsValidate` capability's declared fidelity is `"partial"`.
2. The adapter has completed an asset validation run.

## Postconditions

1. The `AssetValidateResult` includes:
   - `method`: non-null string describing the validation approach used
     (e.g., `"load-state-harness"`, `"project-import-scan-partial"`)
   - `note`: non-null string explaining what is NOT covered
     (e.g., `"load-triggered assets only; static references not checked"`)
2. Assets not covered by the partial method are reported as `status: "skipped"`.
3. The factory convergence gate reads `method` and `note` and includes them in
   the asset-completeness convergence dimension report.

## Invariants

1. A `"partial"` fidelity result always has `note != null`.
2. A `"full"` fidelity result must have no "skipped" assets due to coverage gaps
   (skipped may still occur for unsupported formats, but not for coverage gaps).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter upgrades to `full` via capability/register | Future calls return `note: null` and no coverage-gap skips |
| EC-002 | All assets happen to be load-triggered (100% coverage despite partial method) | Result still has `note` explaining the method limit; `skipped: 0` is acceptable |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter with partial assetsValidate | `{ method: "load-state-harness", note: "load-triggered assets only; static references not validated" }` | happy-path |
| Unity adapter after upgrade to full | `{ method: "project-import-scan", note: null }` | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-039 | partial fidelity result always has non-null note | schema + conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — coverage limitation declaration is part of the declare-and-degrade guarantee |
| L2 Domain Invariants | DI-001; DI-004 (partial coverage is declared, never assumed to be complete) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.10.001 — depends on (extends the assetsValidate result contract)

## Architecture Anchors

- `planning/design/protocol-schema.md#37-assetvalidateresult`
