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
  - .factory/planning/research/aaa/qa-testing-liveops.md
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

# BC-9.01.002: Xbox GDK Submission Validator Integration in Cert Pre-Flight

## Description

For Xbox targets, the factory invokes the GDK Submission Validator as a first-class step
within the cert pre-flight harness. The Validator "automates basic quality checks on a
title or app package" so partners "self-diagnose before submitting for certification"
(verified: learn.microsoft.com GDK docs). Its structured output is parsed and merged into
the `cert-preflight-report`. Final certification remains a human-gated step surfaced
separately (BC-9.06.001).

## Preconditions

1. `target_platform == "xbox"`.
2. GDK Submission Validator binary is present at the path declared in
   `cert-preflight-config.gdk_submission_validator_path`.
3. A packaged Xbox game artifact exists (produced by GDK packaging tooling).
4. The factory CI worker has Windows (GDK tooling requirement).

## Behavior

1. The cert pre-flight harness detects `target_platform == "xbox"` and activates the GDK
   Submission Validator step.
2. Harness invokes the GDK Submission Validator against the packaged artifact, capturing
   stdout/stderr.
3. The Validator output is parsed: each check result is mapped to
   `{check_id, result: PASS|FAIL|WARNING, detail}`.
4. Validator FAIL results are ingested as `result: FAIL` in the `cert-preflight-report`.
5. Validator WARNING results are ingested as `result: REQUIRES_HUMAN_REVIEW` with the
   warning detail.
6. Validator PASS results are ingested as `result: PASS`.
7. Non-Validator Xbox checks (e.g., age-rating submission, Partner Center account setup,
   NDA'd cert requirements) are emitted as `result: REQUIRES_HUMAN_REVIEW`.
8. The overall `cert-preflight-report.overall_status` follows the rules of BC-9.01.001.

## Postconditions

- The `cert-preflight-report` for Xbox contains a `gdk_submission_validator_run` block:
  `{validator_version, invocation_args, raw_output_path, parsed_checks[]}`.
- Every GDK Submission Validator check result is present in `parsed_checks[]`.
- The report contains at least one `REQUIRES_HUMAN_REVIEW` entry for the final Xbox cert
  sign-off (the terminal human-gated step that the Validator does not replace).

## Invariants

- INV-1: The GDK Submission Validator is treated as one module within the broader
  cert pre-flight harness — its results are normalized to the same schema as non-Validator
  checks.
- INV-2: A passing Validator run does NOT constitute Xbox certification. The report always
  includes a `REQUIRES_HUMAN_REVIEW` for final Xbox certification sign-off.
- INV-3: Validator version is recorded in the report to ensure reproducibility.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | GDK Submission Validator exits with non-zero code (tool error, not check failure) | Harness records `validator_run_error` in report; affected checks emitted as SKIP; harness continues non-Validator checks |
| EC-002 | Validator output format changes between GDK versions | Harness parser logs a `parse_warning`; unparseable lines are appended as raw text under `unrecognized_output`; affected checks emitted as REQUIRES_HUMAN_REVIEW |
| EC-003 | Xbox target on a non-Windows CI worker | GDK Submission Validator checks are emitted as SKIP with reason "GDK tooling requires Windows CI worker" |
| EC-004 | Validator returns 0 failures, 0 warnings, 0 passes (empty output) | Treat as validator_run_error with reason "empty output" |

## Canonical Test Vectors

| Validator output | Expected report entry |
|-----------------|-----------------------|
| `XR-001: PASS — Title Stability verified` | `{check_id: "XR-001", result: "PASS", detail: "Title Stability verified"}` |
| `CERT-007: FAIL — Crash handler not registered` | `{check_id: "CERT-007", result: "FAIL", detail: "Crash handler not registered"}` |
| `CERT-099: WARNING — Achievement description missing localization` | `{check_id: "CERT-099", result: "REQUIRES_HUMAN_REVIEW", detail: "Achievement description missing localization"}` |
| Final cert sign-off (not a Validator check) | `{check_id: "XBOX-FINAL-CERT", result: "REQUIRES_HUMAN_REVIEW", detail: "Final Xbox certification sign-off must be completed via Partner Center"}` |

## Verification Properties

- VP-CERT-006: When GDK Submission Validator is invoked, its version is recorded in the report.
- VP-CERT-007: No GDK Submission Validator FAIL is silently converted to PASS or omitted.
- VP-CERT-008: Xbox `cert-preflight-report` always contains at least one REQUIRES_HUMAN_REVIEW
  entry for the final cert sign-off regardless of Validator outcome.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — this BC specializes the cert pre-flight harness for Xbox's GDK Submission Validator, which is the primary machine-checkable pre-cert tool for the Xbox platform |
| L2 Invariants | DI-006 (human-gated tasks surfaced, not dropped) |
| Research Grounding | online-services-platform-distribution.md §4.5 (GDK Submission Validator: "runs a series of basic quality checks"; "automates these checks and push them as early into the process as possible"; verified against learn.microsoft.com) |

## Related BCs

- BC-9.01.001 — Cert Pre-Flight Checklist (parent; this BC specializes it for Xbox)
- BC-9.06.001 — Human-Gated Console Cert Sign-Off Task Surfacing
