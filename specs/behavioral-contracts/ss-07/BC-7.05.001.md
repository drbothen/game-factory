---
document_type: behavioral-contract
level: L3
version: "1.3"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
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
modified:
  - pass: "Pass-11"
    reason: "F-11-01/F-11-02 status-value reconciliation: EC-001 BLOCKED-PENDING → BLOCKED (report-not-produced is a hard precondition gap, not a new state); EC-002 DEGRADED-ACCEPTED → DEGRADED (human override with documented rationale is exactly the DEGRADED definition). Both tokens were non-canonical per methodology-layer §3.1 v1.5 closed enum. Postcondition #2 DEGRADED-PENDING confirmed valid; D-PLAY allowed subset now includes DEGRADED-PENDING per methodology-layer §3.1 v1.5."
  - pass: "Pass-28"
    reason: "I28-01 fix: EC-006 replaced `human-gated task (DI-006)` vocabulary for the cinematic-director creative sign-off with D-013 creative-gate vocabulary (DI-007, E-CIN-003). The cinematic-director is an internal creative principal — not an external third-party — so ADR-0007 `human-gated` fidelity tier does not apply. The playtest dimension's own human gate (DI-007) is unaffected. Gating semantics preserved."
  - pass: "Pass-32"
    reason: "I-PASS32-01 fix: removed spurious DI-007 from EC-006 cinematic creative-gate description only. EC-006 now reads `D-013 creative gate (E-CIN-003 ...)`. All legitimate playtest DI-007 references retained: Invariant 1 (`DI-007: any automated fun-score = factory defect`), Postcondition 4, test vector row, and Traceability L2 Domain Invariants row are unchanged."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.05.001: Playtest-Satisfaction Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #5: playtest-satisfaction.
This dimension is the SOLE non-automatable dimension in the 11-dimension model —
it is always a mandatory human gate, with NO degradation path to an automated
alternative. It is GREEN when a qualified human (producer or director) has
reviewed the structured playtest convergence report and signed off. Any automated
"fun score" substituting for this sign-off is a DI-007 violation and a factory
defect. XR games require physical headset playtesting — a strictly harder boundary
than flat-screen (not degradable to screen-based testing).

## Preconditions

1. A `playtest-protocol` document exists declaring: research question, recruitment
   criteria, tasks, instruments (GEQ/PENS/SUS), and success thresholds.
2. A playable build exists that exercises the declared design-intent-contract
   delegated claims (from BC-6.02.005 `playtest_delegation` sections).
3. Playtest sessions have been executed with recruited human participants.
4. A 3-lens convergence report (say/do/behave data synthesized into structured
   GEQ/PENS/SUS results) has been produced by the `playtest-evaluator` agent.
5. A qualified human reviewer (producer or creative director) is available to
   review the convergence report and provide sign-off.

## Postconditions

1. **GREEN:** A qualified human has reviewed the playtest convergence report and
   provided explicit sign-off recorded in the convergence-report artifact with:
   reviewer identity, date, and explicit approval notation. The GEQ/PENS/SUS
   scores meet or exceed declared success thresholds.
2. **DEGRADED-PENDING:** Playtest has been scheduled; playable build is available;
   sessions not yet completed. The dimension is pending, not blocked. Release is
   blocked until sign-off is obtained, but the factory can continue other work.
3. **BLOCKED:** Playtest sessions completed but scores below declared thresholds
   AND qualified human has not approved a design revision plan. No automated
   metric can substitute for the sign-off.
4. **NO AUTOMATED DEGRADATION PATH:** An automated fun-score, sentiment analysis
   output, or engagement metric CANNOT satisfy this dimension. Any such automated
   signal emitted by an agent is logged as a DI-007 factory defect.

## Invariants

1. This dimension is ALWAYS a human gate. It cannot be automated, approximated,
   or skipped. DI-007: any automated fun-score = factory defect.
2. For XR games: the playtest MUST be conducted on actual XR hardware (headset).
   Screen-based simulation of XR does not satisfy this dimension for XR games.
3. The 3-lens data (say/do/behave) is the minimum required structure. Omitting
   any lens degrades the quality of the sign-off but does not invalidate it if
   the qualified human explicitly acknowledges the limitation in their sign-off.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Playtest conducted but convergence report not produced | BLOCKED; report production is a hard precondition for human review — dimension is blocked until the report exists |
| EC-002 | GEQ scores below threshold but human reviewer approves anyway with documented rationale | DEGRADED; human override with documented rationale is valid and is exactly the definition of DEGRADED; design revision loop recommended |
| EC-003 | Automated fun-score emitted by an analytics hook | Factory defect recorded; DI-007 violation; hook emitting fun-score is flagged for removal |
| EC-004 | XR game tested on PC screen instead of headset | Playtest does not satisfy this dimension for XR games; BLOCKED until headset playtest conducted |
| EC-005 | Playtest budget exhausted, no more sessions possible | BLOCKED; producer must decide to ship with incomplete playtest (recorded degradation) or fund additional sessions |
| EC-006 | `directed: true` cinematic requires separate creative sign-off | Cinematic creative sign-off is a separate D-013 creative gate (E-CIN-003 if absent at ship-build gate) — NOT a `human-gated` fidelity tier task (ADR-0007/DI-006); it does not substitute for playtest sign-off but is a required precondition for the ship build |
| EC-007 | Playtest sessions completed; sign-off given; then a major gameplay change is made | Playtest dimension reverts to DEGRADED-PENDING; new playtest session required for the changed gameplay area |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Playtest completed; GEQ ≥ thresholds; human sign-off recorded | playtest-satisfaction = GREEN | happy-path |
| Playtest completed; GEQ below threshold; no human sign-off | playtest-satisfaction = BLOCKED | error |
| Automated engagement-score submitted as playtest evidence | DI-007 factory defect; dimension remains BLOCKED | error (DI-007) |
| XR game; screen-based playtest conducted | playtest-satisfaction = BLOCKED for XR games | edge-case (XR) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-024 | Dimension cannot transition to GREEN without a human-authored sign-off record | kani (state machine: GREEN state requires human_sign_off = true in record; automated input cannot set human_sign_off) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #5 (playtest-satisfaction), which CAP-007 names as a required dimension |
| L2 Domain Invariants | DI-007 (playtest satisfaction is always a human gate; auto-fun-score = defect) |
| Architecture Module | convergence-tracker / playtest-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-6.02.005 — depends on (playtest delegation declarations define which claims this dimension evaluates)
- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Playtest-Satisfaction Convergence Dimension
