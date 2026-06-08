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

# BC-2.02.002: Conformance Acceptance Gate (Fail-Closed for Writes)

## Description

After the capability-gated conformance suite runs (BC-2.02.001), the factory evaluates the
results to determine whether the adapter is accepted. An adapter is accepted if and only if
all executed tests passed (or were intentionally skipped for `none`-declared capabilities).
Any executed test that fails causes the adapter to be rejected — it cannot be used in factory
production at any fidelity level for the failing capability. The gate is fail-closed: a failed
conformance run produces a rejected adapter state, not a degraded-but-usable state. This is
the operationalization of DI-002.

## Preconditions

1. The conformance suite run for the adapter has completed (BC-2.02.001 postconditions hold).
2. The conformance report is available with per-(capability, test) results: pass, fail, or skip.
3. The adapter's `engineCapabilities` manifest used for the run is the same manifest that will
   be presented during production use (no manifest substitution between conformance and use).
4. The factory's adapter registry is writable (to record the accepted/rejected state).

## Postconditions

1. If every executed test in the conformance report has result `pass`:
   - The adapter is written to the adapter registry with status `accepted`.
   - The adapter may be used in factory production for all capabilities that passed.
   - The accepted record includes: adapter ID, engine version, manifest hash, conformance suite
     version, pass timestamp, and per-capability pass/skip summary.

2. If any executed test has result `fail`:
   - The adapter is written to the adapter registry with status `rejected`.
   - The factory refuses to use the adapter in any production workflow.
   - The rejection record includes: adapter ID, failing capability, failing test IDs, failure
     details, and conformance suite version.
   - The rejection is irrevocable until the adapter fixes the failure and re-runs conformance.

3. The factory core enforces the accepted/rejected state at every point where an adapter would
   be selected for a production task: a rejected adapter is never selected, regardless of what
   capability it claims.

4. The acceptance decision is logged and auditable: the conformance report is retained with the
   acceptance record.

## Invariants

1. **No accepted-without-passing:** There is no code path through the factory that allows an
   adapter with status `rejected` (or without an `accepted` record) to be used in production.
2. **Fail-closed:** When the conformance result is ambiguous (run crashed, report missing,
   manifest hash mismatch), the adapter state defaults to `rejected`, not `accepted`.
3. **Immutable acceptance scope:** An adapter accepted for capabilities C₁...Cₙ is not
   authorized to use capabilities outside that accepted set, even if it dynamically registers
   new capabilities after acceptance.
4. **No acceptance at partial fidelity for a declared `full` capability that fails:** A
   capability declared `full` that fails its `full`-tier tests is rejected. Downgrade to
   `partial` requires re-declaring in the manifest and re-running conformance.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | All capability tests pass but one test fails on a capability declared `partial` | Adapter rejected for that capability. Partial declaration does not waive test passage. |
| EC-002 | Conformance suite run crashes mid-execution (process killed, OOM) | Fail-closed: adapter state = `rejected`. Incomplete run is not treated as partial acceptance. |
| EC-003 | Manifest hash at acceptance time differs from manifest hash at production use time | Factory detects manifest hash mismatch; re-runs conformance before use or refuses use. |
| EC-004 | Adapter was previously accepted, engine minor release updates the adapter | Adapter remains `accepted` for the prior version; the new version must re-run conformance (see BC-2.02.005). |
| EC-005 | All tests skipped (all capabilities `none`) | Adapter state = `rejected` with reason `no_capabilities_declared`. An adapter that claims nothing cannot be accepted. |
| EC-006 | Multiple adapters for the same engine at different versions | Each adapter+version pair is a distinct registry entry; acceptance is per-version. |
| EC-007 | Accepted adapter's conformance suite version is older than the current suite version | Adapter carries a `conformance_suite_version` field; the factory may emit a warning but does not auto-reject (see BC-2.02.005 for scheduled re-run policy). |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Conformance report: all tests for `build`, `test` = pass; `replay`, `capture` = skip (declared `none`) | Adapter accepted; status = `accepted`; accepted for `build`, `test`. | happy-path |
| Conformance report: `build` tests all pass; one `test` test fails | Adapter rejected; status = `rejected`; failure details list the failing `test` test. | error-path (fail gate) |
| Conformance suite run crashes after 3 of 10 tests (no complete report) | Adapter state = `rejected` (fail-closed); reason = `incomplete_run`. | error-path (crash) |
| Adapter was accepted; manifest is re-presented with a different hash | Factory detects hash mismatch; refuses use; flags for re-conformance. | edge-case |
| All capabilities declared `none`; all tests skipped | Adapter rejected; reason = `no_capabilities_declared`. | edge-case |
| Adapter for Bevy 0.15 accepted; Bevy 0.16 adapter submitted as new entry | New entry; 0.15 acceptance unaffected; 0.16 must pass conformance independently. | edge-case |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-005 | No production workflow dispatches to an adapter with registry status != `accepted`. | kani / static analysis of dispatch path |
| VP-TBD-006 | Fail-closed: any conformance run outcome other than "all executed tests passed" results in `rejected` status. | proptest (arbitrary report generator) |
| VP-TBD-007 | Acceptance record contains all required fields (adapter ID, engine version, manifest hash, conformance suite version, timestamp). | schema validation / manual |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC is the direct operationalization of "No engine adapter can be used without passing conformance," which is the central statement of CAP-002. |
| L2 Domain Invariants | DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance) |
| Architecture Module | SS-01 (Adapter Registry, Conformance Gate — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-002 Stage 6 (Acceptance — "All declared capabilities pass conformance → adapter accepted") |
| ADRs | ADR-0002 |

## Related BCs

- BC-2.02.001 — depends on (selection produces the report this gate evaluates)
- BC-2.02.003 — composes with (partial-fidelity rules determine per-test pass/fail before this gate evaluates)
- BC-2.02.004 — depends on (version compatibility determines whether this run's suite version is valid)

## Architecture Anchors

- `architecture/SS-01-conformance-suite.md` — Acceptance gate, adapter registry schema
- `.factory/planning/decisions/0002-protocol-and-conformance-stance.md` — ADR-0002 §Consequences ("'Implement adapter + pass conformance for declared capabilities' is the formal bar")

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-005 — no-rejected-adapter-in-production
- VP-TBD-006 — fail-closed gate
