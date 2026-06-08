---
document_type: verification-property-index
level: L3
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
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

---

## VP-TBD Resolution Table (I3 — Non-Formal Check Registry)

> **I3 reconciliation.** Several BCs added in PRD v1.1 and v1.2 cite VP-TBD-NNN
> identifiers that do not appear in the formal VP catalog above. This section
> explicitly resolves every VP-TBD reference and explains why each is intentionally
> outside the formal catalog.
>
> **Ruling:** The VP-TBD-NNN references in these BCs are **non-formal lint, static
> analysis, schema validation, integration, and unit test checks** that do not meet
> the formal VP selection criterion (pure function, no I/O, tractable formal proof).
> They are machine-checkable BCs validated by TDD/static-analysis/integration — not
> Phase-6 formal hardening targets. No critical invariant (CWE-602 security spine,
> DI-010 never-author) is left unresolvable: each VP-TBD below is resolved to a
> specific verification method and lifecycle phase.

| VP-TBD ID | Citing BC | Property | Resolved Verification Method | Why Not Formal VP | Phase |
|-----------|-----------|----------|------------------------------|-------------------|-------|
| VP-TBD-060 | BC-1.15.002 | No kernel-mode driver entry point patterns in any generated source artifact | Static lint: pattern match over generated output bundle in CI (`E-EAP-011`) | Static analysis over file I/O; not a pure function — intentionally outside formal catalog | TDD / CI gate |
| VP-TBD-061 | BC-1.15.002 | Kernel-mode build configs never appear in generated build scripts | Static lint: build config scanner in CI (`E-EAP-011`) | Static analysis over file system — not a pure function | TDD / CI gate |
| VP-TBD-062 | BC-13.01.004 | Every initialized genre profile has explicit `nft_mechanics` and `web3_enabled` fields | Schema validation: assert fields present and boolean | Schema structural check, not a proof over a pure function | TDD / schema gate |
| VP-TBD-063 | BC-13.01.004 | NFT/web3 fields are `false` in every project without `business-model-spec` opt-in | Property-based test: generate N random genre profiles without opt-in; assert fields false | Could be proptest but touches schema/filesystem context — classified as integration | TDD / proptest integration |
| VP-TBD-064 | BC-13.01.004 | PEGI-18 minimum set in compliance checklist for any project with `nft_mechanics: true` | Integration test: compliance-checklist generation with opt-in project | Cross-component integration check involving multiple pipeline stages | Integration test |
| VP-TBD-127 | BC-11.03.006 | Any `segmentation-ltv-spec` with a blocked vulnerability-proxy signal triggers `E-ETH-009` | Unit test: construct minimal spec with each blocked signal variant; assert violation fires | Document analysis with pattern matching against a blocklist — unit test sufficient; pure enough for proptest if desired in Phase 6 | TDD / unit test |
| VP-TBD-128 | BC-11.03.006 | A composite score referencing two or more blocked signals is detected as a computed proxy | Unit test: construct composite with two blocked signals; assert `E-ETH-009 category: computed_proxy` | Signal composition analysis over structured data — unit test; could be promoted to proptest | TDD / unit test |
| VP-TBD-200 | BC-7.11.002 | Every declared client input type has a server-side validation handler | Static analysis: `server-authority-spec.client_inputs[]` cross-referenced against server handler registry | Schema cross-reference with I/O — static analysis / integration | Static analysis |
| VP-TBD-201 | BC-7.11.003 | Every declared input type has range, rate, and sequence constraints | Schema validation: assert no input type in `client_inputs[]` lacks all three constraint fields | Schema structural check | TDD / schema gate |
| VP-TBD-202 | BC-7.11.003 | Out-of-range input is rejected without state mutation | Property-based test: inject 10,000 out-of-range inputs; assert server state unchanged | Integration test against live server-sim; state mutations involve I/O — not pure function | Integration / proptest |
| VP-TBD-203 | BC-7.11.004 | Re-submitting a consequence event with the same nonce is rejected without state change | Property-based test: for each consequence event type, submit twice; assert state mutated once | Integration test with nonce registry state — has I/O (nonce store lookup) | Integration / proptest |
| VP-TBD-204 | BC-7.11.005 | Client game-state variable matches server authoritative value within one reconciliation cycle | Integration test: inject server correction; assert client matches within reconciliation frequency | Client-server interaction, inherently networked — integration | Integration test |
| VP-TBD-205 | BC-7.11.006 | No entity state broadcast to a client when entity is outside declared AOI | Property-based test: place entities outside AOI; assert broadcast contains no state for them | Server broadcast logic with network I/O — integration | Integration / proptest |
| VP-TBD-206 | BC-7.11.007 | Economy state consistent after any server crash point during a transaction | Fault injection test: interrupt transaction at every commit phase; assert consistent on recovery | Fault injection with database/transaction state — integration | Integration test |
| VP-TBD-207 | BC-7.11.007 | Economy conservation holds across any sequence of N transactions | Property-based test: run N random economy transactions; assert sum conservation | Could be pure if economy state is extracted — candidate for Phase-6 proptest promotion; currently integration | Integration / proptest (Phase-6 candidate) |
| VP-TBD-208 | BC-7.11.008 | Entitlement-gated access bypassing entitlement store lookup triggers trust-client violation | Integration test: simulate client assertion path; assert `E-CONV-006` fired | Integration test with entitlement store mock | Integration test |
| VP-TBD-209 | BC-7.11.008 | Entitlement store unavailability always triggers `deny_access` when `fallback = deny_access` | Integration test: kill entitlement store mock; assert access denied | Integration test with service mock | Integration test |

**Formal VP catalog total: 10 VPs (unchanged). Non-formal check registry: 18 VP-TBD entries (all resolved above).**

> **Phase-6 promotion candidates:** VP-TBD-207 (economy conservation across N transactions)
> and VP-TBD-127/128 (dark pattern detection) are the strongest candidates for promotion
> to formal proptest VPs (VP-011, VP-012, VP-013) in Phase 6 if the pure-sim slice boundary
> can be drawn to exclude I/O. This decision is deferred to the story-writer / formal-verifier
> at Phase 6 entry.
