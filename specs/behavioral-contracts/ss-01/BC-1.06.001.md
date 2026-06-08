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
  - .factory/planning/design/engine-adapter-protocol.md
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

# BC-1.06.001: test Capability Normalizes Engine-Native Format to TestResult

## Description

When the `test` capability is invoked, the adapter runs the engine-native test
framework (JUnit XML via cargo-nextest for Bevy, NUnit3 XML via Unity Test Framework
for Unity, JUnit XML via GUT for Godot) and normalizes the result to the canonical
`TestResult` schema. The factory core never parses engine-native test output formats.
This normalization is the contract surface that makes cross-engine test gating
possible.

## Preconditions

1. The adapter's `test` capability has `fidelity: "full"` or `"partial"`.
2. The test toolchain is present (cargo-nextest for Bevy, Unity batchmode for Unity,
   GUT CLI for Godot).
3. The test suite has been built (build capability succeeded or tests are embedded).
4. The `test` request params may include: `suite` (regex filter), `timeout_ms`,
   `progressToken`.

## Postconditions

1. The adapter returns a `TestResult` object with all fields:
   - `suite`: string identifying the test suite run (e.g., `"sim.economy"`)
   - `tests`: array of per-test objects each with:
     - `id`: unique test identifier string
     - `status`: `"pass"`, `"fail"`, or `"skip"`
     - `durationMs`: non-negative integer
     - `message`: string or null (failure message; null on pass/skip)
     - `assertion`: string or null (assertion text if available)
   - `totals`: object with `{ pass: N, fail: N, skip: N }` where N is non-negative integer
   - `sourceFormat`: string naming the native format normalized from (e.g., `"junit-xml"`, `"nunit3-xml"`, `"libtest-json"`)
   - `capabilityFidelity`: `"full"` or `"partial"` (the fidelity at which this result was produced)
   - `engine`: string (the engine identifier from the manifest)
2. `totals.pass + totals.fail + totals.skip` equals the length of the `tests` array.
3. If the test runner returned no tests (empty suite), `tests` is `[]` and all totals
   are 0; this is a valid result, not an error.

## Invariants

1. The `tests` array is always present; it is never absent or null.
2. `sourceFormat` accurately describes the native format the adapter normalized from.
3. The factory core never parses `sourceFormat`-specific data; it only consumes the
   normalized `TestResult`.
4. A test with `status: "fail"` always has a non-null `message`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Test suite filter matches zero tests | `TestResult` with `tests: []` and all totals 0; NOT an error |
| EC-002 | Engine-native test runner crashes before emitting any output | `OperationFailed` (`-32005`) with `data.reason: "crash"` |
| EC-003 | Native XML output is malformed (partial write on crash) | Adapter normalizes as many tests as parseable; remaining are reported as `skip` with `message: "parse-failure"`; `capabilityFidelity: "partial"` |
| EC-004 | Test runner times out | `OperationFailed` with `data.reason: "timeout"` and partial results if available |
| EC-005 | Unity test runner requires `-batchmode` and exits with warning about `PlayMode` tests | Adapter normalizes the result; warnings go into the `message` field of the relevant test |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter runs sim.economy tests, 41 pass, 2 skip, 0 fail | `{ suite: "sim.economy", tests: [...41 pass + 2 skip objects...], totals: {pass:41, fail:0, skip:2}, sourceFormat: "junit-xml", capabilityFidelity: "full", engine: "bevy" }` | happy-path |
| Unity adapter, 5 tests, 1 fails with assertion message | `{ tests: [...], totals: {pass:4, fail:1, skip:0}, sourceFormat: "nunit3-xml", ...}` with fail test having non-null message | error |
| GUT for Godot, empty suite | `{ suite: "...", tests: [], totals: {pass:0,fail:0,skip:0}, sourceFormat: "junit-xml", capabilityFidelity: "full", engine: "godot" }` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-021 | totals.pass + totals.fail + totals.skip = len(tests) | invariant check in schema validator |
| VP-TBD-022 | A fail test always has a non-null message | conformance test |
| VP-TBD-023 | sourceFormat reflects the actual native format parsed | conformance test: compare raw output with normalized result |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — normalized test results are the foundation of cross-engine test gating; without normalization each engine would require a bespoke parser in the core |
| L2 Domain Invariants | DI-001 (core never parses engine-native formats — normalization is adapter-internal) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.06.002 — sibling (per-test failure reporting)
- BC-1.06.003 — sibling (capabilityFidelity in TestResult)
- BC-1.04.001 — depends on (test runs on headless-compute profile)

## Architecture Anchors

- `planning/design/protocol-schema.md#32-testresult-normalized--junitnunitlibtest-all-map-to-this`
- `planning/design/engine-adapter-protocol.md#normalized-result-schema`
