---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-002
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

# BC-2.02.001: Capability-Gated Conformance Test Selection

## Description

When the conformance suite is invoked for an adapter, it selects and runs exactly the
tests that correspond to the capabilities the adapter has declared in its
`engineCapabilities` manifest — no more, no fewer. Tests for capabilities declared as
`none` or omitted are skipped. Tests for capabilities declared as `full` or `partial`
are executed. This implements the CRI/CSI-style capability-gated conformance pattern from
ADR-0002 and is the foundation of the "pass conformance for what you claim" acceptance bar.

## Preconditions

1. An `engineCapabilities` manifest for the adapter under test has been produced and is
   accessible to the conformance runner (via the LSP-style negotiation handshake specified
   in CAP-001).
2. The manifest contains a map of capability names to fidelity values (`full`, `partial`,
   `none`, or `human-gated`) for at least one capability.
3. The conformance suite knows the full catalog of testable capabilities and the set of
   tests associated with each.
4. The conformance runner is invoked with the adapter's manifest path (or adapter endpoint)
   as its primary input.

## Postconditions

1. For every capability `C` declared as `full` or `partial` in the manifest: all tests in
   the conformance suite's test set for `C` are executed and their results recorded.
2. For every capability `C` declared as `none` or absent from the manifest: all tests in
   the conformance suite's test set for `C` are skipped (not executed), and the skip is
   recorded in the conformance report with reason `capability_not_declared`.
3. The conformance report contains exactly one result record per (capability, test) pair
   that was selected for execution, and exactly one skip record per (capability, test) pair
   that was skipped.
4. The selection logic is deterministic: given the same manifest, the same set of tests is
   always selected.
5. No test is executed for a capability the adapter did not declare.

## Invariants

1. **No capability invention:** The conformance runner never injects tests for capabilities
   not in the adapter's manifest. The factory core cannot demand a capability the adapter
   did not declare.
2. **No test omission for declared capabilities:** A capability declared at any non-`none`
   fidelity has all its registered tests executed without exception.
3. **Selection is manifest-driven, not adapter-id-driven:** Two adapters with identical
   manifests produce identical test selection sets, regardless of the adapter's engine name.
4. **Skip is explicit:** A capability skipped due to `none` declaration is distinguishable
   in the report from a test that was executed and passed. Absence is not success.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Manifest declares `replay: partial` (not `full`) | All replay tests are executed, but partial-fidelity tests use relaxed postconditions (see BC-2.02.003). |
| EC-002 | Manifest declares all capabilities as `none` | All tests skipped; conformance report contains only skip records. Adapter may not be accepted (handled by BC-2.02.002). |
| EC-003 | Manifest contains a capability name not in the suite's catalog | Unknown capability is logged as `unrecognized_capability`; no tests run for it; conformance proceeds for known capabilities. |
| EC-004 | Manifest is malformed or unparseable | Conformance run aborted with error `MANIFEST_PARSE_ERROR`; no tests executed; adapter is not accepted. |
| EC-005 | Capability declared as `human-gated` | The capability's tests are skipped with reason `human_gated_capability`; noted in report but not treated as a failure. |
| EC-006 | Dynamic capability registration arrives after initial manifest (LSP dynamic registration) | Suite re-evaluates test selection against the updated manifest before executing; both initial and dynamically registered capabilities are included. |
| EC-007 | Two capabilities share a test (e.g., `build` and `test` both require the build step) | Shared test executed once; result attributed to both capabilities. No duplicate execution. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Manifest: `{build: full, test: full, replay: none, capture: none}` | Tests executed: all `build` tests + all `test` tests. Tests skipped: all `replay` tests + all `capture` tests. | happy-path |
| Manifest: `{build: full, test: full, replay: full, capture: full, introspect: full}` | Tests executed: all tests for all five capabilities. No skips. | happy-path (full adapter) |
| Manifest: `{}` (empty, all capabilities absent) | All tests skipped. Report has only skip records. | edge-case |
| Manifest with `replay: partial` | All replay tests executed; result evaluation uses partial-fidelity rules per BC-2.02.003. | edge-case |
| Manifest with unknown capability `quantum_drive: full` | `quantum_drive` logged as unrecognized; no tests for it; known capabilities proceed normally. | edge-case |
| Malformed JSON manifest | Abort with `MANIFEST_PARSE_ERROR`; zero tests executed; adapter state = not-accepted. | error |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-001 | For any valid manifest M, the set of tests selected equals the union of test-sets for capabilities declared non-`none` in M. | proptest (manifest generator → selection set check) |
| VP-TBD-002 | For any valid manifest M, no test selected for capability C is executed when C is declared `none` in M. | proptest + manual |
| VP-TBD-003 | Selection is deterministic: same manifest input → same test set output (no randomness). | proptest (run selection twice, compare outputs) |
| VP-TBD-004 | An unknown capability in the manifest does not cause test execution or suite abort. | manual / integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC specifies the mechanism by which the conformance suite selects which tests to execute based on declared capabilities, which is the core capability-gated conformance behavior CAP-002 defines. |
| L2 Domain Invariants | DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance), DI-012 (Every ContractArtifact Has a Declared Validation Method) |
| Architecture Module | SS-01 (Conformance Suite — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-002 Stage 3 (Conformance Suite Run) |
| ADRs | ADR-0002 (Protocol & Conformance Stance — CRI/CSI capability-gated pattern) |

## Related BCs

- BC-2.02.002 — depends on (acceptance gate uses the test selection results produced here)
- BC-2.02.003 — composes with (partial-fidelity evaluation rules for selected tests)
- BC-2.02.004 — depends on (versioning ensures test catalog matches adapter protocol version)

## Architecture Anchors

- `architecture/SS-01-conformance-suite.md` — Conformance runner, test catalog, manifest parsing
- `.factory/planning/decisions/0002-protocol-and-conformance-stance.md` — CRI/CSI pattern rationale

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-001 — manifest-driven test selection completeness
- VP-TBD-002 — no-test-execution for none-declared capabilities
- VP-TBD-003 — deterministic selection
