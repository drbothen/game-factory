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
subsystem: SS-TBD
capability: CAP-001
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

# BC-1.10.001: assetsValidate Returns AssetValidateResult with Per-Asset Status

## Description

When the `assetsValidate` capability is invoked, the adapter attempts to import
and validate each asset referenced in the game project and returns an
`AssetValidateResult` with a per-asset status: `"loaded"`, `"failed"`, or
`"skipped"`. This validates that assets are correctly formatted and importable
by the engine. For adapters with `partial` fidelity, only load-triggered assets
(those actually instantiated during a headless run) are validated.

## Preconditions

1. The adapter's `assetsValidate` capability has `fidelity: "full"` or `"partial"`.
2. The engine binary and asset import pipeline are available.
3. The `assetsValidate` request params may include:
   - `assetPaths`: optional list of specific assets to validate (null = all)
   - `timeoutMs`: maximum time to allow

## Postconditions

1. The adapter returns an `AssetValidateResult` object with:
   - `assets`: array of per-asset objects each with:
     - `path`: string (asset file path relative to project root)
     - `status`: `"loaded"`, `"failed"`, or `"skipped"`
     - `error`: string or null (error message if `status: "failed"`; null otherwise)
   - `totals`: object with `{ loaded: N, failed: N, skipped: N }` where N ≥ 0
   - `method`: string (the import method used, e.g., `"load-state-harness"`,
     `"project-import-scan"`)
   - `note`: string or null (describes coverage limitations for partial fidelity)
2. For `fidelity: "partial"` results, `note` is non-null and describes what
   coverage limitation applies.
3. `totals.loaded + totals.failed + totals.skipped` equals `assets.length`.

## Invariants

1. An asset with `status: "failed"` always has a non-null `error` field.
2. An asset with `status: "loaded"` has `error: null`.
3. `totals` is always consistent with `assets` contents.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | No assets in project | `AssetValidateResult` with `assets: []` and all-zero totals |
| EC-002 | Asset file missing on disk | `status: "failed"`, `error: "file not found"` |
| EC-003 | Asset format not recognized by engine | `status: "failed"`, `error: "unsupported format: .xyz"` |
| EC-004 | `fidelity: "partial"` adapter (load-triggered only) | `note` explains coverage; assets not load-triggered are `status: "skipped"` |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter, 240 assets, all load | `{ assets: [...240 loaded...], totals:{loaded:240,failed:0,skipped:0}, method:"load-state-harness", note:null }` | happy-path |
| Unity adapter (partial fidelity), 50 load-triggered, 190 skipped | `{ totals:{loaded:50,failed:0,skipped:190}, note:"load-triggered assets only; static references not validated" }` | edge-case |
| Missing texture file | `{ assets: [{path:"assets/hero.png", status:"failed", error:"file not found"}], ... }` | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-037 | totals is consistent with assets array | invariant check |
| VP-TBD-038 | partial fidelity result always includes non-null note | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — asset validation is part of the engine adapter protocol surface ensuring build-time asset integrity checks are engine-agnostic |
| L2 Domain Invariants | DI-001; DI-003 (asset integrity is partially checked here; full provenance is a CAP-004 concern) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.10.002 — sibling (partial fidelity coverage declaration)

## Architecture Anchors

- `planning/design/protocol-schema.md#37-assetvalidateresult`
