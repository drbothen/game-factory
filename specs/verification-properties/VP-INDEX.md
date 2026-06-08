---
document_type: verification-property-index
level: L3
version: "1.3"
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

**Total: 10 VPs — 6 P0, 4 P1. 6 pure-sim (SS-05/SS-02), 4 genre-gated esports (SS-11).**

> **I4 — Priority-inversion rationale (VP-005/006/007/010 are P1 but guard P2 BCs).**
> VP-005, VP-006, VP-007, and VP-010 are assigned **P1** priority in this index, yet the
> BCs they guard (BC-13.02.001, BC-13.02.005) are classified **P2** (genre-gated lane,
> SS-11). This is intentional and not a contradiction. Rationale:
> (a) Formal rating-math and tournament-bracket properties are pure functions with no
>     genre-lane I/O dependencies; they can be proved independently of lane activation.
> (b) Proving these properties BEFORE the esports lane is activated de-risks the
>     high-stakes competitive-integrity surface at the point it is turned on.
> (c) The lane is deactivated by default (BC-13.01.002); zero artifacts are emitted
>     until it is activated. The formal proofs constitute pre-activation hardening.
> Scheduling rule: VP-005/006/007/010 are targeted at Phase-6 entry but are NOT
> blocking for P0 delivery. They become blocking for any release that activates the
> competitive/esports lane (SS-11). This ordering must be reflected in the wave-gate
> configuration when the esports lane is first activated.

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

## VP-TBD Convention (C2/C3 — Architecture Decision)

> **Decision: VP-TBD-NNN identifiers are BC-LOCAL by design.**
>
> VP-TBD-NNN labels are placeholder identifiers scoped to the BC that cites them.
> They are NOT globally unique identifiers. The same numeric suffix (e.g., VP-TBD-015)
> may appear in multiple BCs with entirely different meanings — each is an independent
> placeholder local to its citing document.
>
> **Canonical citation form:** `<BC-ID>/VP-TBD-NNN`
> When referencing a VP-TBD from outside its citing BC, always use the full qualified
> form (e.g., `BC-6.02.004/VP-TBD-015`, `BC-2.02.005/VP-TBD-015`). The numeric suffix
> alone is ambiguous without the BC qualifier. This makes apparent "collisions" between
> BCs intentional-and-documented rather than defects.
>
> **Rationale:** The BC corpus contains approximately 130 distinct VP-TBD-NNN labels
> across approximately 70 BCs, assigned locally within each BC. Global renumbering
> would require touching ~70 files and create significant new drift risk. The BC-local
> convention is cheaper, safer, and accurately reflects the scoped nature of these
> placeholder obligations.
>
> **What VP-TBD-NNN means inside a BC:** A VP-TBD-NNN in a BC's Verification Properties
> section is a named placeholder for a machine-checkable property that the BC author has
> identified but that has not yet been promoted to a formal VP catalog entry. The BC
> itself is the authoritative source of what that property is and how it should be
> verified. The numeric suffix is a local ordering label, not a global ID.
>
> **How VP-TBD obligations are resolved:** Each BC's own "Verification Properties"
> section defines the verification method for its VP-TBD-NNN entries. The formal VP
> catalog (VP-001..VP-010 above) is NOT required to list every BC-local VP-TBD —
> it covers only the properties selected for formal Phase-6 hardening. All other
> VP-TBD obligations are resolved within the BC that cites them.
>
> **Phase-6 promotion process:** A BC-local VP-TBD becomes a formal VP (VP-NNN) when:
> (a) the story-writer or formal-verifier confirms the property is a pure function with
>     no I/O, network, or hidden state; (b) a tractable proof strategy is identified;
>     (c) a violation would constitute a hard correctness defect (not a design divergence).
>     Promoted VPs are assigned the next VP-NNN number and added to this index, with the
>     BC-local VP-TBD label updated to cite the formal VP number.

---

## VP-TBD Cross-Cutting Registry (C2 — Selected Entries)

> **Scope of this table:** This table covers only the VP-TBD entries that:
> (a) span multiple BCs with the same underlying concern (cross-cutting), OR
> (b) are formal-promotion candidates tracked at the architecture level.
>
> **This table does NOT resolve every VP-TBD in the BC corpus.** The ~130 VP-TBD-NNN
> labels across ~70 BCs are resolved within their respective BC files. The completeness
> obligation lives inside each BC's Verification Properties section, not here.
>
> **Ruling on all entries below:** These VP-TBD references are non-formal lint, static
> analysis, schema validation, integration, and unit test checks that do not meet the
> formal VP selection criterion (pure function, no I/O, tractable formal proof). No
> critical invariant (CWE-602 security spine, DI-010 never-author) is left unresolvable:
> each entry is resolved to a specific verification method and lifecycle phase.

| Qualified VP-TBD ID | Citing BC | Property | Resolved Verification Method | Why Not Formal VP | Phase |
|---------------------|-----------|----------|------------------------------|-------------------|-------|
| BC-1.15.002/VP-TBD-060 | BC-1.15.002 | No kernel-mode driver entry point patterns in any generated source artifact | Static lint: pattern match over generated output bundle in CI (`E-EAP-011`) | Static analysis over file I/O; not a pure function | TDD / CI gate |
| BC-1.15.002/VP-TBD-061 | BC-1.15.002 | Kernel-mode build configs never appear in generated build scripts | Static lint: build config scanner in CI (`E-EAP-011`) | Static analysis over file system — not a pure function | TDD / CI gate |
| BC-13.01.004/VP-TBD-062 | BC-13.01.004 | Every initialized genre profile has explicit `nft_mechanics` and `web3_enabled` fields | Schema validation: assert fields present and boolean | Schema structural check, not a proof over a pure function | TDD / schema gate |
| BC-13.01.004/VP-TBD-063 | BC-13.01.004 | NFT/web3 fields are `false` in every project without `business-model-spec` opt-in | Property-based test: generate N random genre profiles without opt-in; assert fields false | Touches schema/filesystem context — classified as integration | TDD / proptest integration |
| BC-13.01.004/VP-TBD-064 | BC-13.01.004 | PEGI-18 minimum set in compliance checklist for any project with `nft_mechanics: true` | Integration test: compliance-checklist generation with opt-in project | Cross-component integration check involving multiple pipeline stages | Integration test |
| BC-11.03.006/VP-TBD-127 | BC-11.03.006 | Any `segmentation-ltv-spec` with a blocked vulnerability-proxy signal triggers `E-ETH-009` | Unit test: construct minimal spec with each blocked signal variant; assert violation fires | Pattern matching against a blocklist — unit test sufficient | TDD / unit test |
| BC-11.03.006/VP-TBD-128 | BC-11.03.006 | A composite score referencing two or more blocked signals is detected as a computed proxy | Unit test: construct composite with two blocked signals; assert `E-ETH-009 category: computed_proxy` | Signal composition analysis — unit test; could be promoted to proptest | TDD / unit test |
| BC-7.11.002/VP-TBD-200 | BC-7.11.002 | Every declared client input type has a server-side validation handler | Static analysis: `server-authority-spec.client_inputs[]` cross-referenced against server handler registry | Schema cross-reference with I/O — static analysis / integration | Static analysis |
| BC-7.11.003/VP-TBD-201 | BC-7.11.003 | Every declared input type has range, rate, and sequence constraints | Schema validation: assert no input type in `client_inputs[]` lacks all three constraint fields | Schema structural check | TDD / schema gate |
| BC-7.11.003/VP-TBD-202 | BC-7.11.003 | Out-of-range input is rejected without state mutation | Property-based test: inject 10,000 out-of-range inputs; assert server state unchanged | Integration test against live server-sim; state mutations involve I/O | Integration / proptest |
| BC-7.11.004/VP-TBD-203 | BC-7.11.004 | Re-submitting a consequence event with the same nonce is rejected without state change | Property-based test: for each consequence event type, submit twice; assert state mutated once | Integration test with nonce registry state — has I/O (nonce store lookup) | Integration / proptest |
| BC-7.11.005/VP-TBD-204 | BC-7.11.005 | Client game-state variable matches server authoritative value within one reconciliation cycle | Integration test: inject server correction; assert client matches within reconciliation frequency | Client-server interaction, inherently networked — integration | Integration test |
| BC-7.11.006/VP-TBD-205 | BC-7.11.006 | No entity state broadcast to a client when entity is outside declared AOI | Property-based test: place entities outside AOI; assert broadcast contains no state for them | Server broadcast logic with network I/O — integration | Integration / proptest |
| BC-7.11.007/VP-TBD-206 | BC-7.11.007 | Economy state consistent after any server crash point during a transaction | Fault injection test: interrupt transaction at every commit phase; assert consistent on recovery | Fault injection with database/transaction state — integration | Integration test |
| BC-7.11.007/VP-TBD-207 | BC-7.11.007 | Economy conservation holds across any sequence of N transactions | Property-based test: run N random economy transactions; assert sum conservation | Could be pure if economy state is extracted — candidate for Phase-6 proptest promotion | Integration / proptest (Phase-6 candidate) |
| BC-7.11.008/VP-TBD-208 | BC-7.11.008 | Entitlement-gated access bypassing entitlement store lookup triggers trust-client violation | Integration test: simulate client assertion path; assert `E-CONV-006` fired | Integration test with entitlement store mock | Integration test |
| BC-7.11.008/VP-TBD-209 | BC-7.11.008 | Entitlement store unavailability always triggers `deny_access` when `fallback = deny_access` | Integration test: kill entitlement store mock; assert access denied | Integration test with service mock | Integration test |

**Formal VP catalog total: 10 VPs (unchanged). Cross-cutting VP-TBD entries tracked here: 18 (using qualified BC-ID/VP-TBD-NNN form). The remaining ~112 VP-TBD obligations are resolved within their respective BC Verification Properties sections.**

> **Phase-6 promotion candidates:** BC-7.11.007/VP-TBD-207 (economy conservation across
> N transactions) and BC-11.03.006/VP-TBD-127/128 (dark pattern detection) are the
> strongest candidates for promotion to formal proptest VPs (VP-011, VP-012, VP-013) in
> Phase 6 if the pure-sim slice boundary can be drawn to exclude I/O. This decision is
> deferred to the story-writer / formal-verifier at Phase 6 entry.

---

## I2 — Formal VP → Guarded BC Back-Reference Pairs

> **I2 resolution.** Formal VPs (VP-001..VP-010) anchor to their guarded BCs
> one-directionally from this index. The bidirectional anchor requires each guarded BC
> to also cite its VP-00x in its own Verification Properties / VP-Anchors section.
> The following table is the authoritative (VP → BC) pair list for PO to add back-references.
>
> **PO action required:** For each row below, open the named BC file and add a
> `VP-Anchors:` entry (or equivalent back-reference field) citing the VP ID. The exact
> field name is whatever the BC template uses for verification anchors; if no such field
> exists, add a "Formal VP" row in the Verification Properties section with text:
> "Formally verified by [VP-ID] ([short description])."

| Formal VP | Short Description | Guarded BC(s) | BC File(s) | PO Action |
|-----------|------------------|--------------|------------|-----------|
| VP-001 | Economy conservation | BC-6.01.001 | `ss-06/BC-6.01.001.md` | Add back-ref: "Formally verified by VP-001 (Economy conservation — no creation/destruction)" |
| VP-002 | FSM state legality | BC-6.01.003 | `ss-06/BC-6.01.003.md` | Add back-ref: "Formally verified by VP-002 (FSM state legality — no invalid state reachable)" |
| VP-003 | Balance band containment | BC-6.02.003 | `ss-06/BC-6.02.003.md` | Add back-ref: "Formally verified by VP-003 (Balance band containment — metric within declared bounds)" |
| VP-004 | No-softlock reachability | BC-6.02.004 | `ss-06/BC-6.02.004.md` | Add back-ref: "Formally verified by VP-004 (No-softlock reachability — goal state reachable from any valid state)" |
| VP-005 | Elo zero-sum conservation | BC-13.02.001 | `ss-13/BC-13.02.001.md` | Add back-ref: "Formally verified by VP-005 (Elo zero-sum conservation)" |
| VP-006 | Glicko-2 RD monotone decay | BC-13.02.001 | `ss-13/BC-13.02.001.md` | Add back-ref: "Formally verified by VP-006 (Glicko-2 RD monotone decay)" |
| VP-007 | TrueSkill μ−3σ partial-order monotonicity | BC-13.02.001 | `ss-13/BC-13.02.001.md` | Add back-ref: "Formally verified by VP-007 (TrueSkill μ−3σ partial-order monotonicity)" |
| VP-008 | Replay determinism equality | BC-3.03.001, BC-3.03.002 | `ss-03/BC-3.03.001.md`, `ss-03/BC-3.03.002.md` | Add back-ref: "Formally verified by VP-008 (Replay determinism equality — T1 bitwise snapshot hash)" |
| VP-009 | Damage I/O matrix row-sum correctness | BC-6.01.002 | `ss-06/BC-6.01.002.md` | Add back-ref: "Formally verified by VP-009 (Damage I/O matrix row-sum correctness)" |
| VP-010 | Tournament bracket progression correctness | BC-13.02.005 | `ss-13/BC-13.02.005.md` | Add back-ref: "Formally verified by VP-010 (Tournament bracket progression correctness)" |

> Note: BC-13.02.001 receives three back-references (VP-005, VP-006, VP-007) because all
> three rating-math VPs guard the same BC. The BC should list all three in its VP-Anchors
> section. Directory paths use the ss-NN/ navigability alias convention (see
> subsystem-decomposition.md Directory→Subsystem Alias Table for resolution).
