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

# BC-1.06.003: test Capability Reports capabilityFidelity in TestResult

## Description

Every `TestResult` includes a `capabilityFidelity` field declaring whether the
test run was executed at `full` or `partial` capability. This field allows the
factory's convergence gate to calibrate how much trust to assign the result: a
`partial` fidelity result (e.g., only load-triggered tests, or partially parsed
output) is accepted but triggers a lower-confidence signal. The gate policy for
each convergence dimension specifies the minimum fidelity it requires.

## Preconditions

1. A `TestResult` is being produced by the adapter.
2. The adapter knows whether it ran tests at its declared `full` fidelity or at a
   reduced `partial` fidelity (e.g., because the output was partially parseable).

## Postconditions

1. Every `TestResult` includes `capabilityFidelity: "full" | "partial"`.
2. If the test run completed normally and all output was successfully normalized,
   `capabilityFidelity` is `"full"`.
3. If the test run completed but only a subset of results could be parsed (e.g.,
   malformed XML truncated partway), `capabilityFidelity` is `"partial"` and
   the `tests` array contains only the successfully parsed results.
4. The factory convergence gate reads `capabilityFidelity` and applies its policy:
   - `full` required by gate: `partial` result triggers a warning and gate proceeds
     with degraded confidence (not failure), but is noted in the convergence report.
   - `partial` acceptable: gate proceeds normally.

## Invariants

1. `capabilityFidelity` is always `"full"` or `"partial"`; it is never `"none"`
   (a `none` capability should have returned `CapabilityUnsupported` instead).
2. `capabilityFidelity: "full"` implies no known data loss in the normalization.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | XML cut off mid-record; 30 of 35 tests parsed | `capabilityFidelity: "partial"`, `tests` contains 30 entries, `totals` reflects those 30 |
| EC-002 | All tests run but runner emits no duration data | Adapter sets `durationMs: 0` for all tests; `capabilityFidelity: "full"` (no data loss, just missing optional field) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Full JUnit XML successfully parsed | `capabilityFidelity: "full"` | happy-path |
| Partial NUnit XML (35 tests, 30 parsed) | `capabilityFidelity: "partial"`, `tests` length = 30 | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-025 | capabilityFidelity is always one of {full, partial} | schema validation |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — capabilityFidelity in TestResult enables the declare-and-degrade quality model to apply at the individual test-run level |
| L2 Domain Invariants | DI-001; DI-004 (capability fidelity is declared, never assumed) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.06.001 — depends on (part of TestResult schema)

## Architecture Anchors

- `planning/design/protocol-schema.md#32-testresult-normalized`
