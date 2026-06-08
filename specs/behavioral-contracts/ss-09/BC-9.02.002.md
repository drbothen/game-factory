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

# BC-9.02.002: Distribution-Adapter Conformance Suite Validates Declared Fidelity at Runtime

## Description

The factory runs a conformance suite against each DistributionAdapter before accepting it
for production use. The suite validates that declared fidelity values are accurate: a
capability declared `full` must execute its automatable workflow end-to-end against a
test target; `partial` must execute at least its defined partial workflow; `human-gated`
must complete the automatable prefix and emit a conformant human-task record. This mirrors
the engine-adapter conformance pattern (DI-002).

## Preconditions

1. A DistributionAdapter manifest has passed BC-9.02.001 (schema validation).
2. The conformance suite has a test configuration for the declared `target` platform.
3. For `full`/`partial` capabilities involving actual platform APIs: a sandboxed or
   test-account environment is configured (e.g., Steam partner test AppID, TestFlight
   slot, EGS sandbox).
4. For `human-gated` capabilities: the conformance suite has a human-task mock harness
   that verifies the task record is correctly emitted without actually performing the human step.

## Behavior

1. For each capability declared in the manifest:
   - Load the conformance test for `(target, capability, declared_fidelity)`.
   - If no conformance test exists for the combination: emit `SKIP` with reason "no
     conformance test for this (target, capability, fidelity) combination".
2. For `fidelity: full` capabilities:
   - Execute the full automation workflow against the test environment.
   - PASS iff the workflow completes without error and produces the expected output artifact.
3. For `fidelity: partial` capabilities:
   - Execute the declared partial workflow.
   - PASS iff the partial workflow completes and produces its declared output.
4. For `fidelity: human-gated` capabilities:
   - Execute the automatable prefix (e.g., build package, upload artifact).
   - Verify that a human-task record is emitted in the structured format (task_title,
     responsible_role, artifacts_required, success_criterion).
   - PASS iff automatable prefix completes AND human-task record is structurally valid.
   - The mock harness does NOT actually perform the human step.
5. Emit a conformance report: `{adapter_id, target, run_timestamp, results[]}`.
6. Adapter is accepted for production use only if all non-SKIP results are PASS.

## Postconditions

- Conformance report exists at `.factory/artifacts/distribution-adapter-conformance/
  <adapter_id>-<version>.json`.
- Adapter is marked `conformance_status: passed | failed | partial` in the registry.
- Adapters with `conformance_status: failed` cannot be used in production distribution
  pipelines.

## Invariants

- INV-1 (DI-002): No distribution adapter may be used in production without passing its
  conformance suite for all declared non-`none` capabilities.
- INV-2: Conformance is per-version; a version update requires a new conformance run.
- INV-3: The human-task mock harness validates structure, not content. Human task
  completion is verified at runtime (PROC-006), not in conformance.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Platform test environment unavailable (e.g., Steam sandbox down) | Affected tests SKIP with reason; conformance blocked until environment restored |
| EC-002 | Adapter declares `fidelity: none` for a capability | No conformance test run for that capability; it is excluded from the suite |
| EC-003 | New platform target with no conformance tests written yet | All capabilities SKIP; adapter conformance is `partial`; not accepted for production until tests are written |

## Canonical Test Vectors

| Capability | Declared fidelity | Conformance test outcome | Adapter status |
|-----------|-------------------|--------------------------|---------------|
| `upload`, Steam | `full` | Depot upload to test AppID succeeds | `passed` for this capability |
| `cert_sign_off`, Xbox | `human-gated` | Automatable prefix completes; human-task record is valid JSON | `passed` for this capability |
| `upload`, Steam | `full` | steamcmd returns non-zero exit code | `failed` for this capability |
| `store_publish`, Steam | `human-gated` | Automatable work done; human-task record missing `success_criterion` | `failed` (invalid task record structure) |

## Verification Properties

- VP-DIST-004: Every adapter in the production registry has `conformance_status: passed`.
- VP-DIST-005: No adapter with `conformance_status: failed` is dispatched by the distribution pipeline.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — this BC extends the adapter conformance pattern to the distribution seam, which is the load-bearing anti-drift mechanism for distribution-readiness |
| L2 Invariants | DI-002 (every adapter must pass conformance before acceptance), DI-006 (human-gated surfaced) |
| Research Grounding | online-services-platform-distribution.md §7 (conformance suite mirrors engine-adapter pattern); AAA-RECONCILIATION §5A |

## Related BCs

- BC-9.02.001 — Distribution-Adapter Manifest Validation (prerequisite)
- BC-9.03.001 through BC-9.03.003 — Verified Distribution CLI contracts (specify what `full` fidelity upload means)
