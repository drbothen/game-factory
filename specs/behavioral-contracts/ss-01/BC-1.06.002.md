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

# BC-1.06.002: Test Failure Cases Reported Per-Test with status fail and message

## Description

Each failed test in the normalized `TestResult` is reported individually with
`status: "fail"` and a non-null `message` field explaining the failure. Aggregated
"some tests failed" without per-test detail is not acceptable. This per-test
granularity is required for the factory's Red Gate and convergence tracking to
identify which behavioral contracts are violated.

## Preconditions

1. The `test` capability has been invoked.
2. The engine test runner has completed and at least one test failed.
3. The engine-native output contains per-test failure information (message, assertion,
   or stack trace).

## Postconditions

1. Every test with `status: "fail"` in the `tests` array has:
   - `message`: non-null string describing why the test failed (may be the raw
     assertion output, error message, or exception trace)
   - `assertion`: string or null (the specific assertion text if available from
     the native format)
2. `totals.fail` accurately reflects the count of tests with `status: "fail"` in
   the `tests` array.
3. The `message` for a failing test is never the empty string; if the native format
   provides no message, the adapter substitutes `"test failed (no message from runner)"`.

## Invariants

1. A test entry with `status: "fail"` always has `message != null`.
2. A test entry with `status: "pass"` or `"skip"` has `message: null` unless it
   contains diagnostic notes (in which case a non-null message is acceptable).
3. `totals.fail` equals the count of `{status: "fail"}` entries in `tests`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Engine runner emits only exit code (no per-test output) | Adapter synthesizes a single fail entry with `id: "unknown"` and `message: "test runner exited with non-zero code; no per-test detail available"`; `capabilityFidelity: "partial"` |
| EC-002 | Test failed with a stack trace longer than 4096 characters | Adapter truncates the message to 4096 characters and appends `"...[truncated]"` |
| EC-003 | Multiple tests with the same `id` in native output | Adapter deduplicates or suffixes with an index; `id` values in the output are unique |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy test: `economy::tax_applies_per_tick` fails with assertion `"expected 10, got 9"` | `{ id: "economy::tax_applies_per_tick", status: "fail", message: "assertion failed: expected 10, got 9", assertion: "assert_eq!(10, actual_tax)" }` | happy-path |
| Unity NUnit test fails with null output | `{ status: "fail", message: "test failed (no message from runner)" }` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-024 | For all fail entries, message is non-null and non-empty | property-based test over all possible TestResult values |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — per-test failure messages are required for the factory's behavioral contract enforcement loop |
| L2 Domain Invariants | DI-001; DI-012 (every contract must have a declared validation method — per-test granularity is that method for test-based contracts) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.06.001 — depends on (part of the TestResult schema)
- BC-1.06.003 — sibling

## Architecture Anchors

- `planning/design/protocol-schema.md#32-testresult-normalized`
