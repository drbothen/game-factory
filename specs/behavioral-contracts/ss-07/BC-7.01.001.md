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
subsystem: SS-06
capability: CAP-007
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

# BC-7.01.001: Sim/Spec Convergence Dimension Evaluation

## Description

Defines the evaluation criteria, green/degraded/blocked states, and degradation
rules for convergence dimension #1: sim/spec. This dimension is GREEN when all
active sim-BCs (economy, damage, FSM, AI behavior, design-intent assertions,
replay linkage) pass their CI test suites in a headless environment. It degrades
by determinism tier and by the absence of replay capability. This is the primary
machine-verifiable quality dimension of the 11-dimension convergence model.

## Preconditions

1. All active sim-BCs in BC-INDEX (BC-6.01.xxx, BC-6.02.xxx, BC-6.03.001) are
   evaluable: their headless test runners can execute without GPU.
2. The engine adapter's declared determinism tier is known and loaded from the
   adapter manifest.
3. The CI environment has access to the latest game simulation code for the
   pure-sim slice.
4. The convergence report artifact (`convergence-report`) exists and has a
   writable `dimensions.sim_spec` field.

## Postconditions

1. **GREEN:** All active sim-BCs pass their test suites. Replay regression is
   linked (BC-6.03.001 PASS). No conservation/FSM/AI violations found.
2. **DEGRADED (tier-gated):** At least one sim-BC makes claims that require T1
   exact comparison but the adapter is T2 or T3. Degradation is declared with
   justification in the convergence-report. Sim-BCs with tolerance-window
   comparison pass at the declared tolerance.
3. **DEGRADED (no-replay):** Adapter declares `replay: none`. Dimension degrades
   to "sim-BCs pass headless + playtest evidence required" for the regression
   component. Declared degradation blocks the dimension from being GREEN but
   does not prevent release if the degradation is explicitly declared.
4. **BLOCKED:** At least one sim-BC is FAILING with no declared degradation
   path. This blocks the convergence loop (BC-7.12.001).

## Invariants

1. This dimension is evaluated on every convergence iteration. It cannot be
   skipped or marked waived without an explicit declared degradation entry in
   the convergence-report.
2. A DEGRADED state requires: (a) the degradation reason, (b) what was the
   best-achievable evaluation given the adapter's declared capabilities, and
   (c) what remains for human playtest validation.
3. The sim/spec dimension result is the authoritative gate for the machine-
   verifiable slice of quality — no other dimension can substitute for it.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | All sim-BCs pass but replay linkage has an orphan (BC-6.03.001 FAIL) | sim/spec dimension is DEGRADED; replay linkage gap reported; not BLOCKED unless declared critical |
| EC-002 | T1 adapter but floating-point economy resource (requires tolerance) | BC-6.01.001 declares tolerance; T1 exact hash still used for discrete resources; FP resources use declared ε; dimension is GREEN with documented FP exception |
| EC-003 | Sim-BC test suite is empty for a declared module | BLOCKED; empty test suite = no verification; missing coverage is a hard failure |
| EC-004 | Single sim-BC FAIL in a module not yet implemented | BLOCKED unless the story is in-progress and a declared WIP exception is logged in the convergence-report |
| EC-005 | Engine adapter not yet onboarded (no adapter manifest available) | BLOCKED; convergence cannot be evaluated without an adapter; pre-condition not met |
| EC-006 | All sim-BCs pass but balance band check (BC-6.02.003) is out of band | DEGRADED or BLOCKED depending on severity; declared in convergence-report |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| All 11 sim-BCs PASS; adapter T1; replay linkage complete | sim/spec dimension = GREEN | happy-path |
| 10 sim-BCs PASS, BC-6.01.001 FAIL (conservation violation) | sim/spec dimension = BLOCKED; convergence loop triggered | error |
| All sim-BCs PASS; adapter T2; BC makes T1 claim | sim/spec dimension = DEGRADED; degradation recorded | edge-case (tier) |
| Adapter declares replay:none | sim/spec = DEGRADED (no-replay); playtest evidence required for regression | edge-case (no-replay) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-020 | Dimension evaluation is monotonic: dimension never transitions from GREEN to DEGRADED without a code or configuration change | proptest (evaluation function given same inputs always returns same result) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #1 (sim/spec), which is one of the 11 dimensions CAP-007 declares it tracks and gates |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced not dropped — for degradation declarations), DI-012 (declared validation method) |
| Architecture Module | convergence-tracker (SS-06) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.001 through BC-6.04.001 — depended on by (these BCs must PASS for this dimension to be GREEN)
- BC-7.12.001 — depended on by (convergence loop engine reads this dimension's result)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md` — convergence tracking module

## Story Anchor

S-TBD — Sim/Spec Convergence Dimension

## VP Anchors

- VP-TBD-020 — dimension evaluation monotonicity
