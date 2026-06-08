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
subsystem: SS-05
capability: CAP-006
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

# BC-6.03.001: Replay-Regression Contract Linkage

## Description

Verifies that every active sim-BC (BC-6.01.xxx) is linked to at least one
replay-regression contract (as defined in CAP-003). The sim-BC defines WHAT
correctness means; the replay-regression contract verifies that correctness
is PRESERVED across code changes via the deterministic replay harness. This
linkage contract ensures the quality spine has no orphan sim-BCs — every
behavioral assertion is also protected by regression detection.

Additionally, this contract verifies that when a replay-regression contract's
golden state is re-generated (after an intentional behavior change), all linked
sim-BCs are re-evaluated against the new golden state before the new golden is
accepted.

## Preconditions

1. A BC-INDEX exists listing all active sim-BCs (BC-6.01.xxx and BC-6.02.xxx).
2. A replay-regression contract registry exists listing all active
   `replay-regression-contract` artifacts with their linked sim-BC IDs.
3. The replay harness (CAP-003) is operational for the declared determinism tier.
4. The linkage is declared in each sim-BC's `replay_regression_refs` field
   (a list of `replay-regression-contract` IDs that exercise this BC's
   correctness claims).

## Postconditions

1. For every active sim-BC S in BC-INDEX, there exists at least one
   `replay-regression-contract` R such that R declares S in its `linked_bcs`
   field. Any orphan sim-BC (no linked replay contract) is reported as a coverage
   defect.
2. For each sim-BC S linked to replay contract R: when R's replay is executed,
   the simulation state diff includes the observable outputs verified by S's
   test vectors. The replay validates S's postconditions at the relevant frames.
3. When a new golden state is generated for replay contract R (due to an
   intentional behavior change), all sim-BCs linked to R are re-run against
   the new sim state. All linked BCs must pass before the new golden is accepted.
4. The linkage check runs as a pre-merge CI gate. Merging a code change that
   breaks replay-regression without an explicit golden-state update is blocked.

## Invariants

1. No sim-BC is an orphan: every sim-BC that makes a behavioral claim must be
   exercised by replay-regression. The factory does not accept sim-BCs with
   zero replay linkage (DI-012 enforcement — validation method must be declared).
2. Golden state updates are intentional: the golden-state acceptance workflow
   requires explicit developer sign-off that the behavioral change is intended,
   not accidental.
3. Linkage is bidirectional: a replay-regression-contract also declares its
   linked_bcs; the BC-INDEX cross-validates both directions to prevent drift.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | New sim-BC authored without a replay-regression-contract yet created | BC is flagged as orphan; story-writer must create a replay contract before BC can be considered complete |
| EC-002 | Replay contract references a sim-BC that has been retired | Orphan replay linkage; advisory warning; replay contract may be updated to remove retired BC or retired with it |
| EC-003 | Single replay-regression-contract covers multiple sim-BCs | Valid and encouraged — a single replay scenario exercises economy + damage + FSM simultaneously; all linked BCs are re-validated when golden is updated |
| EC-004 | Sim-BC postcondition is only observable at a specific frame (not at scenario end) | Replay contract must declare a frame-checkpoint for that BC; golden state captures checkpoint frame |
| EC-005 | T3 (tolerance-window) replay tier — BC postcondition requires exact equality | T3 replay cannot satisfy exact-equality BCs; BC must either declare tolerance-window comparison or the adapter tier must be upgraded. Conflict is reported as a tier-mismatch defect. |
| EC-006 | Code change affects 10 sim-BCs all covered by one replay contract | All 10 BCs re-validated as part of one replay run; all must pass for merge to proceed |
| EC-007 | Golden state file missing (first run, no baseline) | Replay contract enters "record mode": first run records the baseline; BCs are validated on subsequent runs. First-record run is advisory (no pass/fail assertion). |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| BC-INDEX with 4 sim-BCs, all linked to replay contracts | Linkage check PASS; 0 orphans | happy-path |
| BC-INDEX with 5 sim-BCs, one orphan | Linkage check FAIL; "BC-6.01.003 has no replay-regression-contract linkage" | error |
| Golden state update for replay contract R001 with linked BCs [BC-6.01.001, BC-6.01.002] | Both BCs re-evaluated; both PASS; new golden accepted | happy-path (golden update) |
| Golden state update, BC-6.01.001 FAILS against new golden | New golden REJECTED; "BC-6.01.001 postcondition violated in new golden state — economy conservation broken" | error (golden rejection) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-018 | Every sim-BC in BC-INDEX has at least one replay contract in the replay registry | proptest / schema check (set-membership assertion; verifiable without domain simulation) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements "replay-regression contract linkage" as named in CAP-006's third contract layer |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | replay-linkage-validator (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.001 — depended on by (economy conservation must be linked to replay)
- BC-6.01.002 — depended on by (damage I/O must be linked to replay)
- BC-6.01.003 — depended on by (FSM legality must be linked to replay)
- BC-6.01.004 — depended on by (AI BT output must be linked to replay)
- BC-7.02.001 — depended on by (tests/replay convergence dimension evaluates this linkage)

## Architecture Anchors

- `architecture/SS-05-replay-linkage-validator.md` — replay linkage cross-reference validator

## Story Anchor

S-TBD — Replay-Regression Linkage Contract

## VP Anchors

- VP-TBD-018 — every sim-BC has at least one replay contract linkage
