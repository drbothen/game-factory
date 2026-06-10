---
document_type: architecture-section
level: L4
section: verification-architecture
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
inputs:
  - .factory/specs/verification-properties/VP-INDEX.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/architecture/subsystem-decomposition.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
modified:
  - version: "1.1"
    date: 2026-06-10
    reason: "OBS-54-A fix — VP-009 title in P0 proofs table corrected from 'Damage I/O matrix row-sum correctness' to 'Damage I/O matrix range containment and split-damage sum — damage output within declared I/O matrix bounds' to match VP-INDEX:58 corrected title (F40-06 retitling); VP-008 description also corrected to match VP-INDEX current title."
---

# Verification Architecture

> **Scope.** This section describes the formal verification strategy for
> game-factory: which invariants are formally proven, which are property-tested,
> which are lint/schema-checked, and why each choice was made. It defines the
> pure-sim slice boundary, the tool assignments per proof class, and the Phase 5/6
> execution plan. The VP catalog and coverage matrix live in companion docs:
> `VP-INDEX.md` (master catalog) and `verification-coverage-matrix.md` (VP→BC mapping).

---

## 1. Verification Philosophy

game-factory uses a stratified verification model. Not every invariant needs a
formal proof; the selection criterion is whether a property is (a) pure, (b) the
proof technique is tractable, and (c) a violation constitutes a correctness defect
rather than a design divergence.

Three verification tiers are used:

| Tier | Method | Scope |
|------|--------|-------|
| **Formal (must prove)** | Kani model checking, proptest/Hypothesis | Pure-core functions: economy simulation, FSM transitions, replay step, rating math, tournament bracket combinatorics |
| **Property-based / fuzz (should prove)** | proptest, cargo-fuzz | Algebraic properties with large input domains where Kani bounds are too restrictive |
| **Test / lint / schema (test sufficient)** | TDD, static analysis, schema validation | Effectful shell code, cross-component integration, file I/O, network, database |

The boundary between tiers is the **purity boundary** (see Section 3).

---

## 2. Provable Properties Catalog

### P0 — Phase 5/6 mandatory proofs (block delivery)

| VP | Property | Formal Method | Owning Module | Owning SS |
|----|----------|---------------|---------------|-----------|
| VP-001 | Economy conservation — no resource creation/destruction outside declared faucets/sinks | Kani + proptest | Economy simulation core | SS-05 |
| VP-002 | FSM state legality — no invalid state or illegal transition reachable | Kani | FSM runtime | SS-05 |
| VP-003 | Balance band containment — metric stays within declared bounds after N steps | proptest | Economy simulation core | SS-05 |
| VP-004 | No-softlock reachability — goal state reachable from any valid game state | Kani (bounded) | Reachability / solvability engine | SS-05 |
| VP-008 | Pure-sim step referential transparency (intra-process purity) | Kani (harness) | Replay harness golden-state comparison | SS-02 |
| VP-009 | Damage I/O matrix range containment and split-damage sum — damage output within declared I/O matrix bounds | proptest | Economy simulation core | SS-05 |

### P1 — Phase 6 target proofs (genre-gated / conditional)

| VP | Property | Formal Method | Owning Module | Owning SS | Condition |
|----|----------|---------------|---------------|-----------|-----------|
| VP-005 | Elo zero-sum conservation — winner gain equals loser loss | proptest + algebraic | Rating-math library | SS-11 | Genre: competitive/esports |
| VP-006 | Glicko-2 RD monotone decay — RD strictly decreasing across rating periods | proptest | Rating-math library | SS-11 | Genre: competitive/esports |
| VP-007 | TrueSkill μ−3σ partial-order monotonicity | proptest | Rating-math library | SS-11 | Genre: competitive/esports |
| VP-010 | Tournament bracket progression correctness — every participant advances exactly once per round per format rules | proptest | Tournament bracket engine | SS-11 | Genre: esports / tournament modes |

**VP counts: 10 total — 6 P0 (VP-001, VP-002, VP-003, VP-004, VP-008, VP-009), 4 P1 (VP-005, VP-006, VP-007, VP-010).**

---

## 3. Pure-Sim Slice Boundary

The purity boundary is the architectural seam that makes formal verification tractable.

### Pure Core (formally verifiable)

Functions in the pure core satisfy all three conditions:
- Deterministic: same inputs always produce same outputs
- Side-effect-free: no I/O, no network, no database, no global state mutation
- Self-contained: no hidden randomness, no platform-dependent behavior

**Pure-core modules and their VPs:**

| Module | VPs | Notes |
|--------|-----|-------|
| Economy simulation step function | VP-001, VP-003, VP-009 | Resource pools + operations → new state |
| FSM runtime (state transition function) | VP-002 | (current_state, event) → next_state |
| Reachability / solvability engine | VP-004 | BFS/DFS over state graph; bounded by design |
| Replay step function (pure-sim layer) | VP-008 | Layer 2 step function only; engine physics excluded |
| Rating math library (Elo/Glicko-2/TrueSkill) | VP-005, VP-006, VP-007 | Float arithmetic; verified with proptest shrinking |
| Tournament bracket engine | VP-010 | Combinatoric advancement; pure data transformation |

### Effectful Shell (test sufficient, not formally proven)

Functions in the effectful shell involve I/O, network, or system state:

| Component | Why Effectful | Verification Method |
|-----------|---------------|---------------------|
| Engine adapter (Layer 4) | Platform I/O, physics tick, GPU | DTU conformance suite + replay regression |
| Replay file I/O (recording/playback) | File read/write | TDD integration tests |
| Anti-cheat policy hook (BC-1.15.002) | File system scan over generated artifacts | Static lint (VP-TBD-060/061) |
| Entitlement store | Network I/O, external service | Integration tests with service mock |
| Nonce registry | Database read/write | Integration tests |
| Economy transaction persistence | Database + fault injection | Fault injection tests (VP-TBD-206) |

---

## 4. Verification Tooling

**Language:** Rust (engine core, sim engine, rating math).

| Tool | Role | VP Targets |
|------|------|-----------|
| **Kani** (bounded model checking) | Exhaustive proof over bounded input space; catches all reachable bad states within bound | VP-001, VP-002, VP-004, VP-008 |
| **proptest** (property-based testing) | Randomized + shrinking; covers large arithmetic domains; good for float invariants | VP-003, VP-005, VP-006, VP-007, VP-009, VP-010 |
| **cargo-fuzz / LibFuzzer** | Coverage-guided fuzzing for parsers and binary deserialization (replay file format, config YAML) | Replay parser, config parser (not enumerated as VP; part of TDD/fuzz harness) |
| **cargo-mutants** | Mutation testing to verify test suite kills mutations in pure-core modules | All pure-core modules after VP proofs pass |

**Kani constraints:**
- Bounded model checking; bit-width and loop-bound settings must be declared per harness
- State-space explosion risk for complex economy graphs; decompose into per-resource-class lemmas
- T1 step-function harness (VP-008): apply to pure-sim Layer 2 only; engine physics is out of scope

**proptest constraints:**
- Float arithmetic (Glicko-2, TrueSkill) requires careful NaN/Inf exclusion strategies
- Shrinking config must be tuned to prevent trivial counterexample collapse

---

## 5. VP-TBD Resolution: Non-Formal Check Registry

Several BCs cite VP-TBD-NNN identifiers that do not appear in the formal VP catalog.
These are **intentionally outside the formal catalog** because they involve I/O,
cross-component integration, or schema validation — not pure functions.

Full resolution table is in `VP-INDEX.md §VP-TBD Resolution Table`.

**Summary of why each class is excluded:**

| Class | Examples | Exclusion Reason |
|-------|---------|-----------------|
| Static lint / file system scan | VP-TBD-060/061 (anti-cheat pattern scan) | File I/O — not a pure function |
| Schema validation | VP-TBD-062/063/064 (NFT/web3 fields), VP-TBD-200/201 (server-authority inputs) | Schema/structural checks — unit test or CI gate sufficient |
| Integration (network/DB) | VP-TBD-202..209 | State mutation via I/O — effectful shell |
| Dark pattern detection | VP-TBD-127/128 (composite signal proxy) | Pattern matching over structured data — unit test; proptest promotion possible in Phase 6 |

**Phase-6 promotion candidates:** VP-TBD-207 (economy conservation across N transactions)
and VP-TBD-127/128 (dark pattern detection) may be promoted to VP-011..VP-013 in Phase 6
if the pure-sim slice boundary can be extended to exclude the I/O dependency.

---

## 6. Phase Assignment

| Phase | Verification Activity |
|-------|-----------------------|
| Phase 2–3 (TDD implementation) | TDD red-green-refactor for effectful shell; proptest integration for P1 candidates as development harnesses |
| Phase 5 (adversarial refinement) | module-criticality gate: CRITICAL modules (≥95% kill rate) must have proof harnesses scaffolded |
| Phase 6 (formal hardening) | P0 Kani proofs must pass; P1 proptest suites must pass; cargo-mutants must achieve ≥95% kill rate on pure-core modules |
| Phase 6 (genre-gated) | P1 VP proofs run only when genre profile activates the relevant lane (competitive/esports) |

---

## 7. Invariants Classified as Test-Sufficient (Not Formally Proven)

The following domain invariants are HIGH-importance but explicitly classified as
test-sufficient rather than formally proven, with justification:

| Invariant | Reason Not Formally Proven | Verification Method |
|-----------|---------------------------|---------------------|
| DI-001 (engine name isolation) | Architectural constraint enforced at compile boundary (no `use engine::*` in Layer 1-2 crates); static analysis via `cargo deny` + crate-level linting | CI lint gate |
| DI-002 (adapter conformance gate) | Integration check across adapter manifest + test runner; has I/O and runtime test execution | Conformance suite (TDD) |
| DI-003 (provenance sidecar completeness) | Schema validation over generated artifact output; file I/O | Schema validation CI gate |
| DI-005 (monetization constrained) | Cross-component ethics contract presence check; not a pure function | Integration test + ethics contract review |
| DI-006 (human gate surfaced) | Runtime event emission verification; has I/O to task surface | TDD + hook-based detection |
| DI-007 (playtest is human gate) | Definitionally a human-in-the-loop gate; cannot be formally proven | Architecture invariant + governance rule |
| DI-010 (no kernel AC authored) | File system / build output scan; has I/O | Static lint VP-TBD-060/061 |
| DI-011 (NFT off by default) | Schema field presence check; VP-TBD-062/063 | Schema validation |
| DI-012 (every contract has validation method) | Schema structural check; not a pure function over in-memory data alone | Schema validation CI gate |
