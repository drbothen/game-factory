---
document_type: architecture-section
level: L4
section: verification-coverage-matrix
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
inputs:
  - .factory/specs/verification-properties/VP-INDEX.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/verification-architecture.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Verification Coverage Matrix

> **Scope.** This matrix maps each formal VP to the BC(s) and domain invariant(s) it
> guards. It also records invariants that are deliberately NOT in the formal VP catalog,
> with explicit justification. The VP-INDEX.md is the authoritative VP catalog; this
> matrix is the traceability layer connecting VPs to their upstream sources.

---

## VP → BC / Domain Invariant Coverage

| VP | Phase | Formal Method | Owning SS | Module | Guarded BC(s) | Guarded Invariant(s) | Feasibility |
|----|-------|--------------|-----------|--------|--------------|---------------------|-------------|
| VP-001 | P0 | Kani + proptest | SS-05 | Economy simulation core | BC-6.01.001 | DI-012 (validation method declared) | HIGH |
| VP-002 | P0 | Kani | SS-05 | FSM runtime | BC-6.01.003 | DI-012 | HIGH |
| VP-003 | P0 | proptest | SS-05 | Economy simulation core | BC-6.02.003 | DI-012 | HIGH |
| VP-004 | P0 | Kani (bounded) | SS-05 | Reachability / solvability engine | BC-6.02.004 | DI-012 | MEDIUM (state-space bound required) |
| VP-005 | P1 | proptest + algebraic | SS-11 | Rating-math library | BC-13.02.001 | DI-012 | HIGH (float precision constraints) |
| VP-006 | P1 | proptest | SS-11 | Rating-math library | BC-13.02.001 | DI-012 | HIGH |
| VP-007 | P1 | proptest | SS-11 | Rating-math library | BC-13.02.001 | DI-012 | MEDIUM (partial order over floats; NaN exclusion required) |
| VP-008 | P0 | Kani (harness) | SS-02 | Replay harness golden-state comparison | BC-3.03.001, BC-3.03.002 | DI-004, DI-012 | HIGH (pure-sim Layer 2 only; engine physics excluded) |
| VP-009 | P0 | proptest | SS-05 | Economy simulation core | BC-6.01.002 | DI-012 | HIGH |
| VP-010 | P1 | proptest | SS-11 | Tournament bracket engine | BC-13.02.005 | DI-012 | HIGH |

**Totals: 10 VPs — Kani: 4 (VP-001 partial, VP-002, VP-004, VP-008), proptest: 7 (VP-001 partial, VP-003, VP-005, VP-006, VP-007, VP-009, VP-010), algebraic: 1 (VP-005 partial).**

Note: VP-001 uses Kani + proptest (counted under both); VP-005 uses proptest + algebraic proof.
(C2 fix v1.1: Kani count corrected 3 → 4 — VP-001, VP-002, VP-004, VP-008 are all Kani targets.)

| Tool | VP Count |
|------|---------|
| Kani | 4 (VP-001, VP-002, VP-004, VP-008) |
| proptest | 7 (VP-001, VP-003, VP-005, VP-006, VP-007, VP-009, VP-010) |
| Algebraic | 1 (VP-005) |
| Grand total VP rows | 10 |

---

## Per-Module Summary

| Module | VPs | Tools | Phase | Notes |
|--------|-----|-------|-------|-------|
| Economy simulation core | VP-001, VP-003, VP-009 | Kani + proptest | P0 | Three independent properties; decompose into per-resource-class lemmas for Kani |
| FSM runtime | VP-002 | Kani | P0 | State × Event → State transition function; bounded reachability |
| Reachability / solvability engine | VP-004 | Kani (bounded) | P0 | BFS/DFS bounded by declared max depth; state-space must be parameterised |
| Replay harness golden-state comparison | VP-008 | Kani | P0 | Pure-sim step function; engine physics excluded per VP-008 scope note |
| Rating-math library | VP-005, VP-006, VP-007 | proptest + algebraic | P1 | Genre-gated (competitive); float arithmetic requires NaN/Inf exclusion |
| Tournament bracket engine | VP-010 | proptest | P1 | Genre-gated (esports/tournament); combinatoric property |

---

## BC Coverage by Subsystem

### SS-02 — Deterministic Replay Harness

| BC | Formal VP | Non-Formal Check | Notes |
|----|-----------|-----------------|-------|
| BC-3.03.001 | VP-008 | — | Recording input stream keyed by sim frame |
| BC-3.03.002 | VP-008 | — | Replay execution returns identical sim state at T1 tier |
| Other BC-3.* | — | TDD integration | Replay file format, recording lifecycle, harness API |

### SS-05 — Simulation Quality Verification

| BC | Formal VP | Non-Formal Check | Notes |
|----|-----------|-----------------|-------|
| BC-6.01.001 | VP-001 | — | Economy conservation invariant |
| BC-6.01.002 | VP-009 | — | Damage I/O matrix bounds |
| BC-6.01.003 | VP-002 | — | FSM state legality |
| BC-6.02.003 | VP-003 | — | Balance band containment |
| BC-6.02.004 | VP-004 | — | No-softlock reachability |
| Other BC-6.* | — | TDD | Simulation setup, balance methodology, reporting |

### SS-11 — Genre-Gated Lanes (competitive/esports)

| BC | Formal VP | Non-Formal Check | Notes |
|----|-----------|-----------------|-------|
| BC-13.02.001 | VP-005, VP-006, VP-007 | — | Rating system math properties (Elo, Glicko-2, TrueSkill) |
| BC-13.02.005 | VP-010 | — | Tournament bracket progression correctness |
| BC-13.01.004 | — | VP-TBD-062/063/064 (schema) | NFT/web3 field schema; not formally proven |
| Other BC-13.* | — | TDD integration | Genre profile lifecycle, esports platform integration |

### SS-01 — Engine-Adapter Protocol

| BC | Formal VP | Non-Formal Check | Notes |
|----|-----------|-----------------|-------|
| BC-1.15.002 | — | VP-TBD-060/061 (static lint) | Kernel anti-cheat policy: no kernel-mode patterns in generated output; enforces DI-010/R-017 |
| Other BC-1.*, BC-2.* | — | TDD + conformance suite | Adapter protocol, capability schema, conformance verification |

### SS-06 — Convergence Tracking Engine

| BC | Formal VP | Non-Formal Check | Notes |
|----|-----------|-----------------|-------|
| BC-7.11.002..008 | — | VP-TBD-200..209 (integration/proptest) | Server-authority, anti-cheat, entitlement gating, AOI, economy transaction integrity |
| Other BC-7.* | — | TDD | Convergence tracking lifecycle, 11-dimension reporting |

---

## Deliberately Unguarded Invariants — Justification

These domain invariants have no formal VP and no VP-TBD entry in the formal catalog.
Each is either (a) an architectural constraint enforced at compile-time, (b) a governance
rule with no tractable formal proof, or (c) a schema/integration check classified as
test-sufficient. All are covered by the non-formal verification tier.

| Invariant | Coverage | Formal VP | Justification for Exclusion |
|-----------|----------|-----------|----------------------------|
| DI-001 (engine name isolation) | CI lint gate (`cargo deny` + layer boundary analysis) | None | Architectural compile-time constraint; enforced by crate boundary, not a runtime proof target |
| DI-002 (adapter conformance gate) | Conformance suite (TDD integration) | None | Runtime integration check across adapter + test runner; has I/O |
| DI-003 (provenance sidecar completeness) | Schema validation CI gate | None | Schema structural check over generated file output; I/O-dependent |
| DI-005 (monetization constrained) | Ethics contract review + integration test | None | Cross-component governance gate; not a pure function |
| DI-006 (human gate surfaced) | TDD + hook-detection | None | Runtime event emission with task-surface I/O; not formally provable |
| DI-007 (playtest is human gate) | Architecture invariant + governance | None | Definitionally human-in-the-loop; cannot be formally proven |
| DI-008 (spec layer engine-portable) | CI lint + layer boundary enforcement | None | Enforced at compile/lint time; no runtime proof target |
| DI-009 (Suno/Udio blocked) | Routing policy blocklist + CI gate | None | Policy enforcement over configuration; not a pure function |
| DI-010 (no kernel AC authored) | Static lint VP-TBD-060/061 | None | File system scan over generated artifacts; I/O-dependent; enforced by BC-1.15.002/R-017 mitigation (SS-01) |
| DI-011 (NFT off by default) | Schema validation VP-TBD-062/063 | None | Schema field presence check; I/O-dependent |
| DI-012 (validation method declared) | Schema validation CI gate | None | Schema structural check; contracts can only be validated via document inspection, not pure function proof |

---

## Coverage Gaps and Phase-6 Promotion Candidates

| Candidate | Current Status | Promotion Condition |
|-----------|---------------|---------------------|
| VP-TBD-207 (economy conservation across N transactions) | Integration / proptest | Promote to VP-011 if economy transaction state can be extracted as pure function excluding DB I/O |
| VP-TBD-127/128 (dark pattern detection — blocked signal proxy) | Unit test | Promote to VP-012/013 if signal composition analysis can be proven over in-memory spec structure |

Both candidates are deferred to story-writer / formal-verifier at Phase 6 entry per VP-INDEX.md §VP-TBD Resolution Table.
