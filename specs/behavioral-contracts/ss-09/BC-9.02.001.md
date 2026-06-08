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
  - .factory/planning/design/engine-adapter-protocol.md
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

# BC-9.02.001: Distribution-Adapter Manifest Declares Valid Capabilities with Correct Fidelity Values

## Description

Every distribution adapter registered in the factory declares its capabilities (build,
upload, pre-cert-validate, store-publish, cert-sign-off) in a structured manifest. Each
capability declares a fidelity value from a four-value set: `full | partial | human-gated
| none`. The `human-gated` value means the factory's automatable prefix is complete and a
single checklisted human task is surfaced (DI-006). The factory adapter registry validates
the manifest on ingestion. This mirrors the engine-adapter pattern at the distribution seam.

## Preconditions

1. A new or updated DistributionAdapter manifest is submitted to the factory adapter registry.
2. The manifest is a parseable YAML or JSON document with at minimum: `adapter_id`,
   `target` (distribution platform), `capabilities` map.
3. The factory adapter registry is operational.

## Behavior

1. The registry reads the manifest's `capabilities` map.
2. For each declared capability:
   - Validate that the fidelity value is one of `{full, partial, human-gated, none}`.
   - Validate that any capability with `fidelity: human-gated` includes a `human_task`
     descriptor block with: `task_title`, `responsible_role`, `artifacts_required[]`,
     `success_criterion`.
3. **Accept path:** All capability fidelity values are valid AND all `human-gated`
   capabilities include a complete `human_task` descriptor.
   - Adapter is accepted into the registry.
4. **Reject path A:** Any capability declares a fidelity value outside the four-value set.
   - Reject with error `E-DIST-001`: "Invalid fidelity value '<value>' for capability
     '<capability>'; must be one of: full|partial|human-gated|none".
5. **Reject path B:** A capability declares `fidelity: human-gated` but lacks a
   `human_task` descriptor.
   - Reject with error `E-DIST-002`: "Capability '<capability>' declares human-gated
     fidelity but is missing required human_task descriptor block".
6. **Reject path C:** Required capabilities (`build`, `upload`) are absent.
   - Reject with error `E-DIST-003`: "Required capability '<capability>' is not declared".

## Postconditions

- **Accept case:** Registry contains a valid DistributionAdapter entry. The capability map
  with declared fidelity values is accessible to the distribution pipeline at dispatch time.
- **Reject case:** Registry does NOT contain the adapter. The error code and manifest path
  are logged.
- Every accepted adapter with `cert_sign_off: {fidelity: human-gated}` or
  `store_publish: {fidelity: human-gated}` has a corresponding `human_task` descriptor
  readable by PROC-006 (Human-Gated Task Surfacing).

## Invariants

- INV-1: Fidelity values on accepted adapters are immutable once registered; changing
  fidelity requires a version bump and re-registration.
- INV-2: `human-gated` is NOT a synonym for `partial`. `partial` means some automation
  is possible; `human-gated` means the factory's automatable prefix is complete and the
  remaining step is a declared external human act.
- INV-3: The four fidelity values are a closed set; additions require an adapter schema
  version bump.
- INV-4 (DI-006): Any capability with `fidelity: human-gated` MUST have a surfaceable
  human_task descriptor. Omitting it is a manifest validation error, not a silent gap.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `cert_sign_off` declared as `fidelity: full` (claiming full automation of console cert) | Reject with E-DIST-004: "cert_sign_off capability may not declare fidelity: full for console platforms; console cert is non-automatable by platform-holder design" |
| EC-002 | `store_publish` declared as `fidelity: full` for Steam | Accept; Steam's store page publish is user-controlled (not console-NDA-gated); the platform may allow full automation of depot upload but store page is human — platform config controls this |
| EC-003 | Adapter for `target: switch` declares any capability as `fidelity: full` | Accept registration; conformance suite will verify fidelity at runtime; NDA constraints are an operational matter |
| EC-004 | Adapter manifest is otherwise valid but includes extra fields | Accept; unknown fields are ignored (forward-compatible) |
| EC-005 | Two adapters declare the same `adapter_id` | Reject second submission with E-DIST-005: "adapter_id '<id>' already exists; use a version update path" |

## Canonical Test Vectors

| Manifest capability | `fidelity` value | human_task present | Expected outcome |
|--------------------|------------------|-------------------|-----------------|
| `upload`, Steam | `full` | N/A | Accept |
| `cert_sign_off`, Xbox | `human-gated` | yes | Accept |
| `cert_sign_off`, Xbox | `human-gated` | no | Reject E-DIST-002 |
| `cert_sign_off`, Xbox | `full` | N/A | Reject E-DIST-004 |
| `build` | `invalid-value` | N/A | Reject E-DIST-001 |

## Verification Properties

- VP-DIST-001: No accepted adapter has a `human-gated` capability without a `human_task` descriptor.
- VP-DIST-002: No console platform adapter (xbox, psn, switch) has `cert_sign_off: {fidelity: full}`.
- VP-DIST-003: Adapter fidelity values for accepted adapters are a strict subset of `{full, partial, human-gated, none}`.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — this BC defines the distribution-adapter capability negotiation protocol that is the platform-agnostic seam for distribution-readiness, mirroring the engine-adapter pattern |
| L2 Invariants | DI-002 (adapter conformance before acceptance), DI-006 (human-gated tasks surfaced) |
| Source Processes | PROC-001 §Stage 6, PROC-006 |
| Research Grounding | online-services-platform-distribution.md §7 (distribution-adapter mirrors engine-adapter; four fidelity values including `human-gated`), §4.6 (automatability matrix); AAA-RECONCILIATION §5A |

## Related BCs

- BC-9.01.001 — Cert Pre-Flight Checklist (consumes this adapter's capability declarations)
- BC-9.02.002 — Distribution-Adapter Conformance Suite (validates declared fidelity at runtime)
- BC-9.03.001 — steamcmd Depot Upload Execution (implements `upload: {fidelity: full}`)
- BC-9.06.001 — Human-Gated Console Cert Sign-Off (triggered by `cert_sign_off: {fidelity: human-gated}`)
