---
document_type: verification-property-index
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to:
  - .factory/specs/architecture/ARCH-INDEX.md
  - .factory/specs/architecture/verification-architecture.md
inputs:
  - .factory/specs/architecture/subsystem-decomposition.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Verification Properties Index

> **Scope.** This index enumerates the formally verifiable properties in the
> pure-sim formal-hardening slice. These are the machine-provable properties
> targeted by Phase 6 (sim-hardening), distinct from the full BC set which
> includes properties validated by TDD, replay-regression, or playtest.
>
> **Selection criterion.** A property appears here only if:
> (1) it is a pure function with no I/O, network, or hidden state,
> (2) the proof technique is tractable at time of architecture, and
> (3) a violation would constitute a correctness defect in simulation or
> competitive integrity, not merely a design divergence.
>
> **Formal-method candidates:** Kani (bounded model checking) · proptest /
> Hypothesis (property-based testing with shrinking) · fuzz (cargo-fuzz /
> LibFuzzer) · algebraic proof (manual or Lean 4 for math invariants).

---

## Summary Table

| VP ID | Short Description | Formal Method | Phase | Owning SS | Traced BCs |
|-------|------------------|---------------|-------|-----------|-----------|
| VP-001 | Economy conservation (no creation/destruction) | Kani + proptest | P0 | SS-05 | BC-6.01.001 |
| VP-002 | FSM state legality (no invalid state reachable) | Kani | P0 | SS-05 | BC-6.01.003 |
| VP-003 | Balance band containment (metric within declared bounds) | proptest | P0 | SS-05 | BC-6.02.003 |
| VP-004 | No-softlock reachability (goal state reachable from any valid state) | Kani (bounded) | P0 | SS-05 | BC-6.02.004 |
| VP-005 | Elo zero-sum conservation | proptest + algebraic | P1 | SS-11 | BC-13.02.001 |
| VP-006 | Glicko-2 RD monotone decay (RD strictly decreasing across rating periods) | proptest | P1 | SS-11 | BC-13.02.001 |
| VP-007 | TrueSkill μ−3σ partial-order monotonicity | proptest | P1 | SS-11 | BC-13.02.001 |
| VP-008 | Replay determinism equality (T1 bitwise snapshot hash invariant) | Kani (harness) | P0 | SS-02 | BC-3.03.001, BC-3.03.002 |
| VP-009 | Damage I/O matrix row-sum correctness | proptest | P0 | SS-05 | BC-6.01.002 |
| VP-010 | Tournament bracket progression correctness (every participant advances exactly once per round per format rules) | proptest | P1 | SS-11 | BC-13.02.005 |

**Total: 10 VPs — 7 P0, 3 P1. 6 pure-sim (SS-05/SS-02), 4 genre-gated esports (SS-11).**

---

## Per-Module Coverage

| Module / Component | VP IDs | Tool Mix |
|-------------------|--------|----------|
| Economy simulation core (pure-sim) | VP-001, VP-003, VP-009 | Kani + proptest |
| FSM runtime (pure-sim) | VP-002 | Kani |
| Reachability / solvability engine | VP-004 | Kani (bounded) |
| Replay harness golden-state comparison | VP-008 | Kani harness |
| Rating-math library (Elo/Glicko-2/TrueSkill) | VP-005, VP-006, VP-007 | proptest + algebraic |
| Tournament bracket engine | VP-010 | proptest |

---

## VP Files

| File | VP |
|------|----|
| `VP-001-economy-conservation.md` | VP-001 |
| `VP-002-fsm-state-legality.md` | VP-002 |
| `VP-003-balance-band-containment.md` | VP-003 |
| `VP-004-no-softlock-reachability.md` | VP-004 |
| `VP-005-elo-zero-sum.md` | VP-005 |
| `VP-006-glicko2-rd-decay.md` | VP-006 |
| `VP-007-trueskill-monotonicity.md` | VP-007 |
| `VP-008-replay-determinism-equality.md` | VP-008 |
| `VP-009-damage-io-matrix.md` | VP-009 |
| `VP-010-tournament-bracket-progression.md` | VP-010 |
