---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
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
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.06.001: Cert-Preflight and Distribution-Readiness Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #6:
cert-preflight + distribution-readiness. This dimension combines the machine-
checkable portion of certification pre-flight (55-80% of cert requirements per
platform) with the verified distribution pipeline (`distribution-release-pipeline`
CLIs: steamcmd, butler, fastlane) and the explicit surfacing of `human-gated`
task lists for console cert sign-off and store publish. The human-gated tasks
are NOT skipped — the factory completes all automatable work and surfaces the
terminal human task. DI-006 requires this.

## Preconditions

1. The `cert-preflight-checklist` artifact exists for each declared target platform.
2. The `distribution-release-pipeline` artifact exists with declared CLI commands
   (steamcmd/butler/fastlane as appropriate for target platforms).
3. The cert-preflight harness (wrapping GDK Submission Validator and per-platform
   public checklist items) is operational.
4. The `compliance-checklist` items that overlap with cert (IARC objective questions,
   content descriptors) have been auto-filled from game metadata.
5. The convergence-report has a writable `dimensions.cert_preflight` field.

## Postconditions

1. **GREEN:** All machine-checkable cert pre-flight items (55-80% per platform)
   PASS. Distribution CLIs execute without error (dry-run or sandbox run).
   `compliance-checklist` objective items auto-filled. `ratings-submission-manifest`
   generated. All `human-gated` task lists are emitted and visible in the
   convergence-report.
2. **DEGRADED (NDA'd platform):** Console platforms whose cert checklist content
   is NDA'd are evaluated against the studio's own NDA'd checklist. The dimension
   is DEGRADED if the studio's NDA checklist is not available; emits advisory.
3. **DEGRADED (human-gated pending):** The automatable prefix is complete. One or
   more `human-gated` tasks are pending (console cert sign-off, store publish
   account setup). The dimension is DEGRADED-PENDING, not BLOCKED. The factory
   has done its work; the human task is emitted.
4. **BLOCKED:** Distribution CLI fails (build upload error, auth failure). Machine-
   checkable cert items fail. Missing `cert-preflight-checklist` for a declared
   target platform.
5. `human-gated` tasks MUST be emitted even if the rest of the dimension is GREEN.
   Suppressing a `human-gated` task (DI-006) transitions the dimension to BLOCKED.

## Invariants

1. Human-gated tasks are surfaced, never suppressed (DI-006). The dimension cannot
   be GREEN with outstanding human-gated tasks unless those tasks are for a
   non-shipping platform.
2. The 55-80% machine-checkable fraction is declared per platform; the remaining
   fraction is always `human-gated` or NDA-gated. The factory never claims 100%
   automated cert.
3. Distribution CLIs (steamcmd/butler/fastlane) are verified against the actual
   CLI tool, not simulated. A dry-run or sandbox mode is acceptable if available.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Steam cert pre-flight passes but store publish account not set up | DEGRADED-PENDING; `human-gated` task emitted: "Set up Steam store page and publish account" |
| EC-002 | Console platform declared but GDK Submission Validator not available | DEGRADED (NDA'd); advisory: "GDK Validator not available; run manually against NDA checklist" |
| EC-003 | Distribution CLI authentication expires during CI run | BLOCKED; "steamcmd auth expired"; must be renewed before dimension can be GREEN |
| EC-004 | `human-gated` task list suppressed by a hook override | DI-006 violation; dimension transitions to BLOCKED; governance event fired |
| EC-005 | Game targets 3 platforms; 2 PASS preflight, 1 BLOCKED | Overall dimension = BLOCKED for the blocking platform; reported per-platform |
| EC-006 | No platforms declared (prototype/internal build) | DEGRADED with advisory: no platform targets declared; cert-preflight vacuously satisfied; distribution pipeline still required |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Steam target; preflight PASS; butler CLI ok; store publish human-gated emitted | cert-preflight = DEGRADED-PENDING (human-gated task outstanding) | happy-path |
| Steam + Nintendo Switch; Steam PASS; Switch NDA checklist unavailable | Steam = PASS; Switch = DEGRADED (NDA); overall = DEGRADED | edge-case (NDA) |
| steamcmd auth failure | cert-preflight = BLOCKED | error |
| human-gated task suppressed | cert-preflight = BLOCKED; DI-006 defect recorded | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-025 | Dimension is BLOCKED if any human-gated task is suppressed | kani (state machine: suppressed_human_gated_task → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #6 (cert-preflight + distribution-readiness) |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced not dropped), DI-012 |
| Architecture Module | convergence-tracker / cert-preflight-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Cert-Preflight and Distribution-Readiness Convergence Dimension
