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
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/domain-spec/processes.md
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

# BC-9.06.001: Human-Gated Console Cert Sign-Off Task Is Surfaced with Checklist, Never Suppressed

## Description

Console certification sign-off (Xbox, PlayStation, Nintendo) is an irreducibly human
external act that the factory cannot automate — it requires NDA'd toolchains, devkit
access, and platform-holder review. The factory completes its entire automatable prefix
(cert pre-flight, build packaging, Submission Validator for Xbox, build upload where
automatable) and then surfaces a structured, checklisted human task for the cert sign-off.
The task must appear in the `distribution-release-pipeline.human_gated_tasks[]` and in
the milestone gate. Suppression is a hook-detectable defect (DI-006).

## Preconditions

1. `target_platform` is a console platform (`{xbox, psn, switch}`).
2. The distribution adapter for the target declares `cert_sign_off: {fidelity: human-gated}`
   with a complete `human_task` descriptor (BC-9.02.001).
3. The cert pre-flight harness has run (BC-9.01.001) and the report exists.
4. Any automatable distribution steps for the target have completed or are in progress.

## Behavior

1. When the cert pre-flight harness produces a report with
   `overall_status: PASS | PARTIAL` for a console target, the factory generates a
   `human-gated-cert-task` record:
   ```json
   {
     "task_id": "CERT-HUMAN-<platform>-<build_version>",
     "task_type": "console_cert_sign_off",
     "target_platform": "<platform>",
     "responsible_role": "cert-owner",
     "status": "outstanding",
     "task_title": "Console Certification Sign-Off: <platform> for <game_id> v<build_version>",
     "description": "Complete the console certification submission and sign-off for <platform>. The factory has completed all automatable pre-flight checks. This step requires access to the <platform> partner portal and devkit.",
     "artifacts_required": [
       "cert-preflight-report: <path>",
       "build-upload-record (if applicable): <path>",
       "distribution-release-pipeline: <path>"
     ],
     "checklist": [
       "Verify cert-preflight-report shows no automatable FAIL results",
       "Submit build via platform partner portal",
       "Track certification review status",
       "Confirm platform certification pass",
       "Update distribution-release-pipeline human_gated_tasks[].status to 'complete'"
     ],
     "success_criterion": "Platform holder has issued a cert pass confirmation for <platform>/<game_id>/v<build_version>",
     "blocking": true
   }
   ```
2. This record is added to `distribution-release-pipeline.human_gated_tasks[]`.
3. The record is surfaced to the milestone gate mechanism.
4. The `convergence-report.dimensions.distribution_readiness` remains `AMBER` (not
   `GREEN`) until the task is marked `status: complete` by the cert-owner.
5. The factory NEVER marks this task `status: complete` autonomously. Only the cert-owner
   (human) can do so.

## Postconditions

- `human-gated-cert-task` record exists in the `distribution-release-pipeline` for every
  console target.
- The record has `status: outstanding` until a human marks it `status: complete`.
- The milestone gate reflects the outstanding task.
- `convergence-report.dimensions.distribution_readiness != GREEN` while the task is outstanding.

## Invariants

- INV-1 (DI-006): Console cert sign-off task is NEVER suppressed. A console-targeted
  distribution pipeline that lacks this task in `human_gated_tasks[]` is a hook-detectable
  defect.
- INV-2: Only a human (cert-owner role) can transition `status: outstanding → complete`.
  No pipeline agent, hook, or automated process may set this field to `complete`.
- INV-3: The task record contains all artifacts required for the human to perform the
  sign-off without needing to search the filesystem.
- INV-4: The task is generated even if the cert pre-flight report shows `overall_status: FAIL`.
  A failing pre-flight does not suppress the task; it adds urgency context to the checklist.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Cert pre-flight report has `overall_status: FAIL` | Task is still generated; checklist item added: "Resolve cert-preflight FAIL items before submitting"; task status remains `outstanding` |
| EC-002 | Adapter declares `cert_sign_off: {fidelity: none}` (explicitly not supporting cert) | No human-gated cert task generated for this adapter; distribution pipeline notes `cert_sign_off: not_applicable` |
| EC-003 | cert-owner attempts to mark task complete before cert pre-flight resolves all FAILs | Factory emits a warning: "cert-preflight-report contains unresolved FAILs; completing cert task may risk submission failure"; warning does NOT block the human from marking complete (the human decides) |
| EC-004 | Same build re-submitted to same platform after cert failure | New task record generated with `retry_count: N`; original task record preserved with `status: failed` |

## Canonical Test Vectors

| Platform | Pre-flight status | Task generated | Task status |
|---------|------------------|----------------|-------------|
| xbox | PARTIAL | YES | outstanding |
| psn | PASS | YES | outstanding |
| switch | FAIL | YES | outstanding (with FAIL context) |
| steam | PARTIAL | NO | N/A (not console; BC-9.06.002 applies) |

## Verification Properties

- VP-CERT-009: Every console-targeted `distribution-release-pipeline` has at least one
  `task_type: console_cert_sign_off` entry in `human_gated_tasks[]`.
- VP-CERT-010: No `console_cert_sign_off` task has `status: complete` without a human
  having set it (audit trail of who set it must exist).

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — explicit capability text: "surfaces `human-gated` task lists for console cert sign-off and store publish. Console cert sign-off is never automated." |
| L2 Invariants | DI-006 (human-gated tasks surfaced, not dropped — this BC is the primary enforcer of DI-006 for the cert seam) |
| Source Processes | PROC-006 (Human-Gated Task Surfacing — all 4 stages of this process apply here) |
| Research Grounding | AAA-RECONCILIATION §5A ("human-gated for console cert sign-off, store-page publish"); online-services-platform-distribution.md §4.5 ("Console cert = human, by platform-holder design") |

## Related BCs

- BC-9.01.001 — Cert Pre-Flight Checklist (precondition; provides the cert report)
- BC-9.04.001 — Distribution-Release-Pipeline Artifact (contains `human_gated_tasks[]`)
- BC-9.06.002 — Human-Gated Store Publish Task (sibling; same pattern for store-page publish)
