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
subsystem: SS-TBD
capability: CAP-007
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

# BC-7.02.001: Tests/Replay Convergence Dimension Evaluation

## Description

Defines the evaluation criteria, green/degraded/blocked states, and degradation
rules for convergence dimension #2: tests/replay. This dimension is GREEN when
the replay-regression test suite is clean at the adapter's declared determinism
tier, the test suite manifest is complete (all sim-BC-linked scenarios are covered),
and mod-load determinism (if mods enabled) and esports demo determinism (if
esports enabled) are also verified. Degrades by tier from T1 (bitwise) to T2
(pinned-runner) to T3 (tolerance-window) to human-playtest (no-replay).

## Preconditions

1. At least one `replay-regression-contract` exists with a golden state on file.
2. The engine adapter's `replay` capability is declared (fidelity = full, partial,
   or none) in the adapter manifest.
3. The replay harness (CAP-003) is operational and can execute the replay contracts
   for the declared determinism tier.
4. The test suite manifest (`test-suite-manifest`) exists and lists all
   declared test scenarios with pass/fail state.
5. The convergence-report has a writable `dimensions.tests_replay` field.

## Postconditions

1. **GREEN (T1):** All replay-regression contracts produce an identical snapshot
   hash on any CI runner (bitwise reproducibility confirmed). Test suite manifest
   is clean. Zero new failures since last golden.
2. **GREEN (T2):** All replay-regression contracts produce an identical snapshot
   diff on the declared pinned CI runner. Bitwise cross-platform not required.
3. **GREEN (T3):** All replay-regression contracts produce metric outputs within
   declared tolerance windows. No bitwise or pinned-runner requirement.
4. **DEGRADED (human-playtest fallback):** Adapter declares `replay: none`. No
   automated replay regression possible. Dimension degrades to human playtest
   evidence (session evidence logged in convergence-report). Dimension cannot
   be GREEN.
5. **BLOCKED:** A previously-green replay contract now produces a divergent
   diff (unexpected regression). Regression is NOT a DEGRADED state — it is
   a BLOCKED state requiring root-cause analysis before convergence proceeds.

## Invariants

1. An unexpected replay regression is always BLOCKED — there is no tolerance
   for undeclared behavioral changes in the replay spine.
2. An intentional golden state update (declared behavior change) transitions
   the dimension from BLOCKED to GREEN after all linked sim-BCs pass against
   the new golden.
3. The test suite manifest is the exhaustive list of declared scenarios; gaps
   between the manifest and the actual replay contracts are a coverage defect.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | New replay contract added but golden state not yet recorded | Dimension = DEGRADED (first-record mode); advisory logged; first run records baseline |
| EC-002 | Pinned CI runner is unavailable (T2 tier) | Dimension = DEGRADED (runner unavailable); noted in convergence-report; T3 tolerance fallback attempted if declared |
| EC-003 | T1 replay produces different hash on ARM vs x86 | T1 tier violated; adapter must be downgraded to T2; BLOCKED until tier declaration updated |
| EC-004 | Mod-load determinism check (mods enabled) produces different load order | Dimension BLOCKED; mod-load-spec violation; root-cause in load-order algorithm |
| EC-005 | Esports demo replay diverges (esports enabled) | Dimension BLOCKED; demo-replay is same spine as replay-regression; same root-cause analysis |
| EC-006 | Test suite manifest empty | BLOCKED; no scenarios declared = no tests = dimension cannot be GREEN |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T1 adapter, all replay contracts match golden | tests/replay = GREEN | happy-path |
| T1 adapter, one replay contract diverges from golden | tests/replay = BLOCKED; regression details reported | error |
| T3 adapter, all contracts within tolerance | tests/replay = GREEN (T3) | edge-case (T3) |
| replay:none adapter | tests/replay = DEGRADED; playtest evidence required | edge-case (no-replay) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-021 | Unexpected divergence always maps to BLOCKED (never DEGRADED) | kani (dimension evaluation function; divergence input → BLOCKED output) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #2 (tests/replay) |
| L2 Domain Invariants | DI-004 (determinism tier declared, never assumed), DI-012 |
| Architecture Module | convergence-tracker (SS-TBD) |
| Stories | S-TBD |

## Related BCs

- BC-6.03.001 — depends on (replay linkage check is part of this dimension)
- BC-7.12.001 — depended on by (convergence loop engine reads this dimension)

## Architecture Anchors

- `architecture/SS-TBD-convergence-tracker.md`

## Story Anchor

S-TBD — Tests/Replay Convergence Dimension
