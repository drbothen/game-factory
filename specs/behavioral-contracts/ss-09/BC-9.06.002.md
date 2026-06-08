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
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/domain-spec/processes.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
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

# BC-9.06.002: Human-Gated Store Publish and Pricing Task Is Surfaced After Upload, Never Auto-Published

## Description

For all distribution targets where store-page publishing and pricing configuration are
human-controlled web actions (Steam store page publish, iOS App Store "Submit for Review",
Google Play Production release, EGS Partner Center publish), the factory surfaces a
structured human-gated task after the automatable upload step completes. The factory
NEVER autonomously publishes a game page or sets pricing. This applies across PC, mobile,
and PC-marketplace targets. The human task is surfaced via the milestone gate mechanism
and recorded in the `distribution-release-pipeline`.

## Preconditions

1. A successful build-upload-record exists for a PC or mobile target (BC-9.03.001,
   BC-9.03.002, or BC-9.03.003 with `status: success`).
2. The distribution adapter for the target declares `store_publish: {fidelity: human-gated}`.
3. The `store-asset-spec-conformance-report` for the target exists (BC-9.05.001).

## Behavior

1. On receipt of a successful `build-upload-record`, the factory generates a
   `human-gated-store-publish-task` record:
   ```json
   {
     "task_id": "STORE-PUBLISH-<target>-<build_version>",
     "task_type": "store_page_publish",
     "target_platform": "<target>",
     "responsible_role": "release-engineer",
     "status": "outstanding",
     "task_title": "Store Page Publish and Pricing: <target> for <game_id> v<build_version>",
     "description": "The factory has uploaded the build to <target>. Complete the store page publish, set pricing/regional configuration, and submit for review where applicable.",
     "artifacts_required": [
       "build-upload-record: <path>",
       "store-asset-spec-conformance-report: <path>"
     ],
     "checklist": [
       "Verify store-asset-spec-conformance-report shows PASS or PARTIAL (human-review items addressed)",
       "Set pricing and regional configuration via <target> partner portal",
       "Configure store page visibility (coming soon / release date / immediate)",
       "Submit for review (if required: iOS App Review, Play Store review)",
       "Confirm public availability after review approval",
       "Mark this task complete in the distribution-release-pipeline"
     ],
     "success_criterion": "Game is publicly visible and purchasable on <target> storefront at declared price",
     "blocking": true
   }
   ```
2. Record is added to `distribution-release-pipeline.human_gated_tasks[]`.
3. Record is surfaced to the milestone gate mechanism.
4. `convergence-report.dimensions.distribution_readiness` remains `AMBER` until marked complete.
5. Factory NEVER calls any store-page-publish or pricing API autonomously.

## Postconditions

- `human-gated-store-publish-task` record exists for every PC/mobile target with a
  successful upload.
- Record has `status: outstanding` until human marks complete.
- No game is published to any storefront by an automated factory process.

## Invariants

- INV-1 (DI-006): Store publish task is NEVER suppressed for targets where store-page
  publish is human-controlled. A successful upload without a corresponding store-publish task
  in `human_gated_tasks[]` is a hook-detectable defect.
- INV-2: Only a human (release-engineer role) can set `status: complete`.
- INV-3: Pricing information is NEVER set, suggested, or recorded by the factory. The
  factory's role ends at build delivery; pricing is a business decision.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Upload failed (no successful upload record) | No store-publish task generated; task generation is triggered by successful upload only |
| EC-002 | Store-asset conformance report shows FAIL | Task is still generated; checklist item added: "Resolve store-asset conformance FAILs before publishing" |
| EC-003 | Target is itch.io (butler push succeeded) | Task generated for itch.io; notes that itch.io pricing/visibility is web-only; checklist: set access controls and pricing via itch.io dashboard |
| EC-004 | Same build published to Steam AND itch.io | Two separate tasks generated, one per target |

## Canonical Test Vectors

| Target | Upload record status | Task generated | Task type |
|--------|---------------------|----------------|-----------|
| steam | success | YES | store_page_publish |
| itchio | success | YES | store_page_publish |
| ios | success | YES | store_page_publish |
| steam | failed | NO | N/A |

## Verification Properties

- VP-DIST-018: Every successful build upload to a PC/mobile target has a corresponding
  `store_page_publish` entry in `human_gated_tasks[]`.
- VP-DIST-019: No factory process invokes store-page publish, pricing, or visibility APIs.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — capability text explicitly states "surfaces `human-gated` task lists for console cert sign-off and store publish" |
| L2 Invariants | DI-006 (human-gated tasks surfaced, not dropped) |
| Source Processes | PROC-006 (Human-Gated Task Surfacing) |
| Research Grounding | online-services-platform-distribution.md §4.1 (Steam: "store-page publish is human/web"), §4.2 (butler: pricing is human), §4.3 (fastlane: "Submit for Review is the human/web gate"); §4.6 (store publish = ❌ human for Steam/iOS) |

## Related BCs

- BC-9.03.001/002/003 — Distribution CLI upload BCs (provide `build-upload-record`)
- BC-9.06.001 — Human-Gated Console Cert Sign-Off (sibling)
- BC-9.04.001 — Distribution-Release-Pipeline Artifact
