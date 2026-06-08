---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/online-services-platform-distribution.md
  - .factory/planning/research/aaa/ratings-legal-compliance.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-08
capability: CAP-009
priority: P1
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

# BC-9.05.001: Store-Asset Spec Conformance Report Validates Required Storefronts Assets

## Description

Before a game build can be marked distribution-ready, the factory validates that all
required store assets (capsule images, screenshots, icons, promotional art, store
description text) conform to each target storefront's specification requirements for
dimensions, file format, size limits, and content policy constraints. Content-policy
judgments (e.g., "is this screenshot misleading?") are flagged for human review. Format/
dimension/size checks are machine-validatable. The factory emits a
`store-asset-spec-conformance-report` for each target platform.

## Preconditions

1. A `store-asset-manifest` exists for the game listing all store assets and their
   declared `asset_role` (e.g., `capsule_main`, `screenshot_1`, `icon_512`).
2. Store asset files are present at their declared paths.
3. A `store-asset-spec` for each `target_platform` exists in the factory config, declaring:
   - Per-`asset_role`: `required_dimensions`, `max_file_size_bytes`, `allowed_formats[]`,
     `machine_checkable: bool`, `policy_notes` (for human-review items).
4. For Steam: Steamworks store requirements loaded (capsule 460×215; main capsule 920×430;
   screenshots 1920×1080 preferred; no discount text / review scores / award claims in
   capsule text — machine-lintable per Steamworks rules).

## Behavior

1. For each `(asset_role, target_platform)` pair:
   - Check file exists at declared path; if missing: `result: FAIL` with reason "asset missing".
   - If `machine_checkable: true`:
     - Check actual dimensions match `required_dimensions`.
     - Check file size ≤ `max_file_size_bytes`.
     - Check file format is in `allowed_formats[]`.
     - For Steam capsule text: lint for forbidden content (review scores, discount text, award
       claims). Any match → `result: FAIL`.
     - All checks PASS → `result: PASS`.
     - Any check FAIL → `result: FAIL` with detail.
   - If `machine_checkable: false`:
     - `result: REQUIRES_HUMAN_REVIEW` with `policy_notes`.
2. Emit `store-asset-spec-conformance-report` (JSON):
   - `game_id`, `build_version`, `target_platform`, `run_timestamp`
   - `checks[]`: `{asset_role, result, detail, policy_notes}`
   - `summary`: `{total, pass, fail, requires_human_review}`
   - `overall_status`: `PASS | FAIL | PARTIAL`
3. Reports per platform are independent; multi-platform builds emit one report per platform.

## Postconditions

- Report exists at `.factory/artifacts/cert/<build_version>/store-asset-conformance-<platform>.json`.
- Every declared `(asset_role, target_platform)` pair has a result in the report.
- No `machine_checkable: true` check is emitted as `REQUIRES_HUMAN_REVIEW` (it must be
  either PASS or FAIL).
- `overall_status: FAIL` iff any check result is `FAIL`.
- `overall_status: PARTIAL` iff no FAILs and at least one `REQUIRES_HUMAN_REVIEW`.
- `overall_status: PASS` iff all checks are `PASS`.

## Invariants

- INV-1: Steam capsule text lint checks are always machine-checkable; they must never be
  emitted as `REQUIRES_HUMAN_REVIEW`.
- INV-2: The `store-asset-spec` for each platform is versioned; the conformance report
  records the spec version used.
- INV-3: A missing required asset is always `FAIL`, not `REQUIRES_HUMAN_REVIEW`.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Required capsule image missing entirely | `result: FAIL` with reason "asset missing" |
| EC-002 | Screenshot dimensions are 1280×720 when spec requires 1920×1080 | `result: FAIL` with reason "dimensions: expected 1920×1080, got 1280×720" |
| EC-003 | Steam capsule text contains "90% positive reviews" | `result: FAIL` with reason "Forbidden content: review score in capsule text (Steamworks policy)" |
| EC-004 | Icon file is PNG at correct dimensions but stored as JPEG extension | `result: FAIL` with reason "format: file extension says JPEG but content is PNG" (actual format check, not extension-only) |
| EC-005 | Policy check item ("is screenshot content appropriate?") | `result: REQUIRES_HUMAN_REVIEW` with `policy_notes: "Verify screenshot does not misrepresent game content (Steamworks policy)"` |
| EC-006 | No `store-asset-spec` exists for `target_platform` | Error `E-DIST-050`; conformance report not emitted |

## Canonical Test Vectors

| Asset | Check | Expected result |
|-------|-------|----------------|
| Steam capsule, correct dimensions, no forbidden text | Format + dimensions + text lint | `PASS` |
| Steam capsule, text includes "50% off" | Text lint | `FAIL` |
| Screenshot, 1280×720, spec requires 1920×1080 | Dimension check | `FAIL` |
| iOS App Store icon, 1024×1024 PNG, ≤4 MB | Format + dimensions + size | `PASS` |
| Missing main capsule | Existence check | `FAIL` |

## Verification Properties

- VP-DIST-016: No `machine_checkable: true` item is emitted as `REQUIRES_HUMAN_REVIEW`.
- VP-DIST-017: Steam capsule text lint always runs for Steam targets regardless of other check outcomes.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — store-asset spec conformance is an explicit requirement for distribution-readiness; machine-checkable store asset spec checks are part of the automatable prefix |
| L2 Invariants | DI-006 (human-gated tasks surfaced), DI-012 (declared validation method) |
| Research Grounding | online-services-platform-distribution.md §4.1 (Steam store page is human/web; capsule text lint: review scores/discount text/award claims are lintable); AAA-RECONCILIATION §5.9 (store-copywriter: "Steam capsule text linting — machine-lintable per Steamworks rules") |

## Related BCs

- BC-9.04.001 — Distribution-Release-Pipeline Artifact (consumes `store_asset_conformance_ref`)
- BC-9.06.002 — Human-Gated Store Publish Task (triggered when PARTIAL or after PASS)
