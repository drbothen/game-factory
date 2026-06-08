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
subsystem: SS-TBD
capability: CAP-002
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

# BC-2.02.003: Fidelity-Declared Conformance (Partial-Pass Semantics)

## Description

When an adapter declares a capability at `partial` fidelity, the conformance suite evaluates
that capability's tests against relaxed postconditions (partial-tier test set), not the
full-tier postconditions. A `partial`-fidelity capability that passes its partial-tier tests
is accepted at partial fidelity — the adapter may use that capability in production but the
factory records the fidelity level and degrades its quality model accordingly. A `full`-fidelity
declaration requires the full-tier test set; failure to pass the full-tier tests for a `full`
declaration results in rejection (not downgrade). Fidelity is declared, tested, and recorded —
never silently assumed.

## Preconditions

1. The adapter's manifest declares at least one capability with fidelity `partial`.
2. The conformance suite has a defined `partial`-tier test set for that capability (a subset
   of the `full`-tier tests that validates the capability's partial behavior).
3. The conformance runner knows which tests belong to the `full` tier and which to the
   `partial` tier for each capability.

## Postconditions

1. For a capability declared `partial`:
   - Only the `partial`-tier tests for that capability are executed.
   - `full`-tier-only tests are skipped with reason `partial_fidelity_scope`.
   - If all `partial`-tier tests pass, the capability is accepted at `partial` fidelity.
   - The accepted record stores `fidelity: partial` for that capability.

2. For a capability declared `full`:
   - All `full`-tier tests (which include the `partial`-tier tests as a subset) are executed.
   - Failure of any `full`-tier test results in rejection, not downgrade to `partial`.

3. The factory records per-capability fidelity in the adapter's accepted record and uses
   that fidelity level to select the appropriate quality model at runtime (e.g., a `partial`
   `replay` capability triggers the tolerance-window comparison path, not the hash-diff path).

4. The fidelity level is surfaced in the convergence report when an adapter with `partial`
   capabilities is in use — the factory never silently presents partial-fidelity results
   as full-fidelity.

## Invariants

1. **No silent fidelity assumption:** The factory never infers fidelity from capability
   behavior at runtime. Fidelity is always read from the accepted record.
2. **No downgrade on full-declaration failure:** A `full`-declared capability that fails
   its `full`-tier tests is rejected, not silently downgraded to `partial` and accepted.
   Downgrade requires explicit manifest amendment and re-run.
3. **Partial does not imply broken:** A `partial`-fidelity capability is genuinely available
   for use; the factory uses it with appropriate quality model selection.
4. **Fidelity propagates to quality model:** Every consumer of adapter capabilities reads
   the fidelity from the accepted record and selects the appropriate comparison/validation
   method. Hard-coding `full` fidelity assumptions in consumers is a factory defect.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter declares `replay: partial` but partial-tier tests don't exist in the suite | Suite error: `PARTIAL_TIER_TESTS_MISSING`; capability cannot be validated; treated as `none` for acceptance purposes. |
| EC-002 | Adapter declares `replay: full` but only passes the partial-tier subset of tests | Rejected (not downgraded). The `full` declaration required all full-tier tests. |
| EC-003 | Adapter declares `capture: partial`; factory core needs `capture: full` for a task | Factory selects next-best fallback (human-gated or skip) for that task; logs capability shortfall. |
| EC-004 | Two adapters: one `build: full`, one `build: partial` — both accepted; factory must choose | Factory selects the higher-fidelity accepted adapter when both are eligible for a task. |
| EC-005 | `partial`-tier tests pass but the adapter's behavior at runtime degrades further than declared | This is FM-001 (capability drift); detected by scheduled re-run (BC-2.02.005). The BC cannot prevent runtime drift; it can only ensure the declaration was honest at acceptance time. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Manifest: `{replay: partial}`; partial-tier replay tests: all pass | Accepted with `fidelity: partial` for `replay`. Full-tier replay tests skipped. | happy-path |
| Manifest: `{replay: full}`; partial-tier tests pass; one full-tier test fails | Rejected. `full` declaration failed its full-tier tests. No downgrade. | error-path |
| Manifest: `{capture: partial}`; partial-tier tests: all pass | Accepted with `fidelity: partial` for `capture`. Factory will use tolerance-window capture path. | happy-path |
| Manifest: `{replay: partial}`; partial-tier test set missing from suite | `PARTIAL_TIER_TESTS_MISSING` error; capability treated as `none`. | error |
| Two adapters accepted: A (`build: full`), B (`build: partial`); task requires `build` | Factory selects A (higher fidelity). | edge-case |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-008 | A capability declared `full` that fails any full-tier test is never recorded with status `accepted`. | kani / proptest |
| VP-TBD-009 | Every runtime consumer of a capability reads fidelity from the accepted record; no hard-coded `full` assumption exists. | static analysis / code review |
| VP-TBD-010 | The convergence report explicitly labels partial-fidelity results as partial, not as full. | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC specifies the fidelity-declared conformance semantics (partial vs full), which is the "fidelity-graded" conformance behavior named in CAP-002's "fidelity-declared conformance" description. |
| L2 Domain Invariants | DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance) |
| Architecture Module | SS-TBD (Conformance Suite, Adapter Registry — filled by architect) |
| Stories | (filled by story-writer) |
| ADRs | ADR-0002 (graceful degradation, not lowest-common-denominator) |

## Related BCs

- BC-2.02.001 — depends on (test selection feeds this evaluation)
- BC-2.02.002 — composes with (this BC's pass/fail evaluation feeds the acceptance gate)
- BC-3.03.003, BC-3.03.004, BC-3.03.005 — related to (replay fidelity drives tier selection in CAP-003)

## Architecture Anchors

- `architecture/SS-TBD-conformance-suite.md` — Full vs partial tier test sets, fidelity propagation

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-008 — full-declaration failure is rejection not downgrade
- VP-TBD-009 — no hard-coded fidelity in consumers
