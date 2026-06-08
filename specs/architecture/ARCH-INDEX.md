---
document_type: architecture-index
level: L4
version: "1.2"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
deployment_topology: single-service
studio_roster_count: 66
vp_total: 10
vp_p0: 6
vp_p1: 4
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/prd.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/risks.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
  - .factory/planning/design/architecture.md
  - .factory/planning/design/engine-adapter-protocol.md
  - .factory/planning/decisions/0001-founding-engine-pair.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: .factory/specs/product-brief.md
---

# Architecture Index — game-factory

> **v1.2 — Phase-1d alignment.** BC count updated to 179 (was 168). Per-SS counts
> corrected: SS-01=41, SS-06=19, SS-09=14, SS-11=15. See subsystem-decomposition.md
> for full changelog. VP-INDEX updated with VP-TBD resolution table (I3).
> adapter-protocols.md §1.5 JSON-RPC collision resolved (C4): E-EAP-011 reassigned
> to -32009; E-EAP-012/013 registered. methodology-layer.md §2.5 DP table aligned
> to canonical prd-cap-011.md §11.3 (C1); §2.8 D-013 distinction clarified (I5).

> **Pass 2b complete.** This index now covers the full architecture surface:
> pass 1 (layered architecture, subsystem decomposition, DTU, ADRs),
> pass 2a (adapter protocols, methodology layer), and pass 2b (studio-of-agents
> routing model, verification properties for the pure-sim formal-hardening slice).

---

## Document Map

| File | What it contains | Tokens (est.) |
|------|-----------------|---------------|
| `ARCH-INDEX.md` (this file) | Subsystem Registry, ADR registry, VP registry, document map | ~500 |
| `layered-architecture.md` | 4-layer model, reuse/replace/adapt table, config/content seam | ~1,000 |
| `subsystem-decomposition.md` | SS-01..SS-12 definitions, BC→Subsystem assignment table (all 179), Directory→Subsystem alias table | ~1,400 |
| `dtu-assessment.md` | DTU analog: replay harness + conformance doubles; DTU_REQUIRED verdict | ~900 |
| `adapter-protocols.md` | Layer 3 adapter protocol spec: JSON-RPC transport, capability schema, fidelity grades, conformance suite, compatibility matrix | ~1,100 |
| `methodology-layer.md` | Layer 2 game methodology: sim-BC schema, design-intent contract, replay-regression contract, asset-provenance, 11-dim convergence criteria | ~1,100 |
| `studio-of-agents.md` | 66-role Studio-of-Agents roster; producer-orchestrator scheduling; cross-discipline DAG; change-propagation rules | ~1,200 |
| `adrs/ADR-0004-adapter-family-anti-lock-in.md` | Four-seam adapter family as primary anti-lock-in mechanism | ~400 |
| `adrs/ADR-0005-config-content-extraction-seam.md` | Extraction seam: spine vs quality-model at content/config boundary | ~400 |
| `adrs/ADR-0006-11-dimension-convergence-model.md` | 11-dim convergence model replacing vsdd 7-dim | ~350 |
| `adrs/ADR-0007-human-gated-fidelity-tier.md` | human-gated as a first-class fidelity value | ~350 |

### Verification Properties (`.factory/specs/verification-properties/`)

| File | VP | Short description |
|------|----|------------------|
| `VP-INDEX.md` | all | Master VP catalog; module coverage matrix |
| `VP-001-economy-conservation.md` | VP-001 | Economy resource conservation (no creation/destruction) |
| `VP-002-fsm-state-legality.md` | VP-002 | FSM: no invalid state or illegal transition reachable |
| `VP-003-balance-band-containment.md` | VP-003 | Balance metric within declared band after N steps |
| `VP-004-no-softlock-reachability.md` | VP-004 | Goal state reachable from any valid game state |
| `VP-005-elo-zero-sum.md` | VP-005 | Elo: winner gain equals loser loss (zero-sum) |
| `VP-006-glicko2-rd-decay.md` | VP-006 | Glicko-2: RD monotone decay and bounds |
| `VP-007-trueskill-monotonicity.md` | VP-007 | TrueSkill μ−3σ partial-order monotonicity |
| `VP-008-replay-determinism-equality.md` | VP-008 | T1 bitwise replay equality (pure-sim step function) |
| `VP-009-damage-io-matrix.md` | VP-009 | Damage output within declared I/O matrix bounds |
| `VP-010-tournament-bracket-progression.md` | VP-010 | Bracket combinatorics: progression correctness per format |

**VP counts:** 10 total — 6 P0 (VP-001, VP-002, VP-003, VP-004, VP-008, VP-009), 4 P1 (VP-005, VP-006, VP-007, VP-010).

**Studio roster:** 66 roles — 14 REUSE (vsdd infra), 18 ADAPT, 34 NEW. See `studio-of-agents.md`.

---

## Subsystem Registry

| ID | Name | Owned Capabilities | BC ID Range | Priority |
|----|------|--------------------|-------------|----------|
| SS-01 | Engine-Adapter Protocol | CAP-001, CAP-002 | BC-1.*, BC-2.* | P0 |
| SS-02 | Deterministic Replay Harness | CAP-003 | BC-3.* | P0 |
| SS-03 | Asset Generation Pipeline | CAP-004 | BC-4.* | P0 |
| SS-04 | Multi-Discipline Production | CAP-005 | BC-5.* | P0 |
| SS-05 | Simulation Quality Verification | CAP-006 | BC-6.* | P0 |
| SS-06 | Convergence Tracking Engine | CAP-007 | BC-7.* | P0 |
| SS-07 | Playtest Protocol | CAP-008 | BC-8.* | P1 |
| SS-08 | Cert and Distribution | CAP-009, CAP-010 | BC-9.*, BC-10.* | P1 |
| SS-09 | Monetization Ethics | CAP-011 | BC-11.* | P1 |
| SS-10 | Canon Knowledge-Base | CAP-012 | BC-12.* | P1 |
| SS-11 | Genre-Gated Lanes | CAP-013 | BC-13.* | P2 |
| SS-12 | XR Platform Seam | CAP-014 | BC-14.* | P2 |

**BC count by subsystem (v1.2 — 179 total):**

| Subsystem | BC Count | Change from v1.0 |
|-----------|----------|-----------------|
| SS-01 | 41 (34 CAP-001 + 6 CAP-002 + 1 BC-1.15.002) | +1 v1.1 |
| SS-02 | 9 | — |
| SS-03 | 15 | — |
| SS-04 | 16 | — |
| SS-05 | 11 | — |
| SS-06 | 19 (12 original + 7 BC-7.11.002..008) | +7 v1.2 |
| SS-07 | 5 | — |
| SS-08 | 17 (11 CAP-009 + 6 CAP-010) | — |
| SS-09 | 14 (13 original + 1 BC-11.03.006) | +1 v1.2 |
| SS-10 | 9 | — |
| SS-11 | 15 (14 original + 1 BC-13.01.004) | +1 v1.1 |
| SS-12 | 7 | — |
| **TOTAL** | **179** | **+11** |

---

## ADR Registry

| ID | Title | Status | File |
|----|-------|--------|------|
| ADR-0001 | Founding engine pair: Bevy + Unity | Accepted | `planning/decisions/0001-founding-engine-pair.md` |
| ADR-0002 | Protocol and conformance stance (hybrid LSP+Terraform+CRI) | Accepted | `planning/decisions/0002-protocol-and-conformance-stance.md` |
| ADR-0003 | Determinism tier as a capability dimension | Accepted | `planning/decisions/0003-determinism-tier-capability.md` |
| ADR-0004 | Four-seam adapter family as primary anti-lock-in mechanism | Draft | `adrs/ADR-0004-adapter-family-anti-lock-in.md` |
| ADR-0005 | Config/content extraction seam (spine vs quality-model) | Draft | `adrs/ADR-0005-config-content-extraction-seam.md` |
| ADR-0006 | 11-dimension convergence model | Draft | `adrs/ADR-0006-11-dimension-convergence-model.md` |
| ADR-0007 | human-gated as a first-class fidelity tier | Draft | `adrs/ADR-0007-human-gated-fidelity-tier.md` |

---

## Risk Mitigations (HIGH-impact R-NNN)

| Risk | Subsystem(s) | Architectural Mitigation |
|------|-------------|--------------------------|
| R-001 (copyright) | SS-03 | Auto-provenance sidecar with `human_modifications_log`; `copyrightability_assessment` at generation time |
| R-002 (indemnification) | SS-03 | Risk-tiered backend routing; sidecar records indemnification tier |
| R-003 (Suno/Udio) | SS-03 | DI-009 enforced at asset-adapter routing; policy blocklist hook |
| R-004 (SAG-AFTRA) | SS-03 | `likeness_consent_ref != null` → `human-gated` flow; non-suppressible hook |
| R-008 (determinism) | SS-02 | ADR-0003 tiered model; conformance verifies declared tier |
| R-010 (ethics/fun) | SS-06, SS-09 | DI-007 (playtest human gate); DI-005 (ethics contract mandatory) |
| R-013 (PEGI 2026) | SS-08 | `compliance-checklist` with min-rating rules; `content-descriptor-contract` |
| R-014 (EU AI Act) | SS-03, SS-08 | C2PA marks from provenance sidecar; 2026-08-02 hard deadline wired to distribution gate |
| R-015 (COPPA) | SS-08, SS-09 | Per-SDK consent flags in `privacy-config-contract`; `ad-monetization-spec` COPPA gate |
| R-017 (kernel AC) | SS-11 | DI-010 policy hook; anti-cheat = wrap-only; never autonomously authored |
