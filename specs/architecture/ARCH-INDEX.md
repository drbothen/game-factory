---
document_type: architecture-index
level: L4
version: "2.3"
status: draft
producer: architect
timestamp: 2026-06-09T00:00:00Z
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

> **v2.3 — Pass-44 OBS-44-A cosmetic: SS-13 Subsystem Registry priority annotation aligned with per-BC P0/P1 split.**
> - **OBS-44-A:** SS-13 Priority column annotated with per-BC split "9 P0 / 3 P1" to match the
>   parallel treatment of SS-09 (added in a prior pass). BC count table row already had "9 P0 + 3 P1" detail.
>
> **v2.2 — Pass-43 F43 status-propagation fix (F43-01/F43-03).**
> - **F43-01:** Risk Mitigations table rows for R-017, F42-SEC, F42-MOD updated: "reserved (PO
>   to author)" prose replaced with "authored / active" for BC-13.02.006, BC-13.03.005, BC-1.15.003.
>   Document Map ADR-0008 row description: "reserved BC-13.02.006" → "BC-13.02.006 (authored / active)".
> - **F43-03:** Added §F42 Security Contracts section with stable heading anchors (F42-01, F42-MOD,
>   F42-03) so the three new BCs' `§F42-*` traceability references resolve.
>
> **v2.1 — Pass-42 D-019 PO burst (3 new BCs authored; count surfaces updated; DI-013 added).**
> - **F42-01:** D-SEC convergence predicate (methodology-layer.md §D-SEC) hardened to
>   fail-closed. BC-13.03.005 (moderation-pipeline-contract, ss-13/, SS-11) and
>   BC-13.02.006 (anti-cheat-integration-adapter, ss-13/, SS-11) authored by PO. Both
>   BCs are now active signals in D-SEC. D-SEC is BLOCKED if either absent for applicable
>   game profiles.
> - **F42-02:** ADR-0008 authored: anti-cheat provider policy. Allowed set: {EAC, EOS,
>   BattlEye}. Rejected: Riot Vanguard (kernel-anomaly, not licensable, DI-010).
>   ADR Registry updated below.
> - **F42-03:** Never-emit-secrets output-bundle lint gate added to D-SEC predicate
>   (sub-predicate 4). BC-1.15.003 (never-emit-secrets, ss-01/, SS-01) authored by PO.
>   DI-013 added to invariants.md v1.2. E-SEC family registered in error-taxonomy.md.
> - **BC counts updated by PO:** Grand total 190 → **193**. SS-01=41→42, SS-11=15→17.
>   Priority subtotals: P0 126→127 (+BC-1.15.003), P2 22→24 (+BC-13.02.006, BC-13.03.005),
>   P1=42 unchanged. VP-TBD-324..327 reserved (4 IDs for 3 new BCs).
>
> **v1.9 — Pass-14 adversarial defect I14-02 (Document Map ADR-0004 row description).**
> - **I14-02:** Document Map row for `ADR-0004-adapter-family-anti-lock-in.md` (line ~127)
>   corrected "Four-seam adapter family" → "Five-seam adapter family". The ADR Registry
>   row (line ~202) was already correct; only the Document Map description was stale.
>   No remaining "four-seam"/"four adapter seam" occurrences in this file.
>
> **v1.8 — CAP-015 BCs delivered by PO; SS-13 count finalized.**
> - SS-13 BC count updated TBD → 12 (BC-15.01.001..BC-15.11.001; 9 P0 + 3 P1).
>   Grand total: 178 → **190**. Priority subtotals: P0 117→126, P1 39→42, P2=22. Sum: 190. ✓
>   subsystem-decomposition.md updated to v1.6. ARCH-INDEX BC count table updated.
>
> **v1.7 — Pass-13 adversarial defect C13-01 / I13-01 (online-services seam).**
> - **C13-01:** Added SS-13 (Online-Services Adapter, CAP-015) to Subsystem Registry.
>   Subsystem count 12 → 13. ADR-0004 title updated "Four-Seam" → "Five-Seam".
>   adapter-protocols.md updated to v1.2 (§6 online-services seam added).
>   studio-of-agents.md role 58 subsystem corrected SS-11 → SS-13.
>   DTU-08 subsystem corrected SS-11 → SS-13 in dtu-assessment.md.
>   Directory→Subsystem alias table extended with ss-15/ → SS-13.
> - **I13-01:** (same fix) studio-of-agents §3 SS-11 count corrected 11→10.
>   PO FLAG: capability count 14→15 (CAP-015 authored); BC total now 190.
>
> **v1.6 — Pass-6 adversarial defect resolution (I6-01 / O6-01).**
> - **I6-01:** BC priority subtotals corrected to frontmatter ground truth. The stale
>   P0=111/P1=45 values misattributed the 8 P0 dark-pattern/ethics BCs in SS-09
>   (CAP-011 BC-11.01.001/002/003, 11.02.001, 11.03.001/002/004/006 — all `priority: P0`
>   per D-008 decision) to the P1 bucket, and counted 2 SS-03 P1 BCs (BC-4.03.003,
>   BC-4.04.003) in P0. Corrected: P0=117, P1=39, P2=22. Sum: 178. ✓
> - **O6-01:** SS-09 Subsystem Registry Priority column changed from "P1" to "P0/P1
>   (split — 8 P0 / 6 P1; see CAP-011 priority rationale)" to prevent misreading as
>   all-P1.
> - **I6-01 (process):** check-spec-counts.sh check (i) rewritten to compute P0/P1/P2
>   from BC frontmatter at runtime (no hardcoded constants). New check (k) added:
>   error-identifier resolution — every E-[A-Z]+-[0-9]+ in BC files must resolve to a
>   registered code in error-taxonomy.md.
>
> **v1.5 — Pass-4 adversarial defect resolution.**
> - **C1:** Studio roster line corrected. Canonical: 57 NEW + 9 ADAPT = 66 game-discipline
>   roles. vsdd-factory infra agents (14 REUSE) are NOT counted in the 66; they operate
>   outside the roster. Previous "14 REUSE, 18 ADAPT, 34 NEW" was internally inconsistent
>   with the §2 table.
> - **C2:** Kani VP count corrected 3 → 4 in verification-coverage-matrix.md (VP-001,
>   VP-002, VP-004, VP-008 all use Kani).
> - **I1:** `security-engineer` (role 55) owning subsystem corrected SS-05 → SS-06 in
>   studio-of-agents.md. Principal artifact `server-authority-invariant-suite` is owned
>   by SS-06 per subsystem-decomposition and BC frontmatter.
> - **I2:** Activation tier gap closed — roles 55/56/57 now assigned: `security-engineer`
>   Tier 1, `anti-cheat-integrator`/`moderation-ops` Tier 2. All 66 roles partitioned.
> - **O1/O2:** check-spec-counts.sh extended with VP catalog consistency check (g);
>   stale "expected to FAIL" comments on checks (e)/(f) removed.

> **v1.4 — Pass-3 adversarial defect resolution.**
> - **I1 (Pass-3):** R-017 (kernel anti-cheat) risk mitigation row corrected from SS-11 → SS-01.
>   R-017/DI-010 is enforced by BC-1.15.002 (Engine-Adapter Protocol subsystem). SS-11 owns
>   DI-011 (NFT/web3), not DI-010. Mitigation note updated to cite VP-TBD-060/061.
> - **C1 (Pass-3):** VP counts in ARCH-INDEX line 93 were already correct (6 P0, 4 P1);
>   VP-INDEX.md summary line corrected from "7 P0, 3 P1" → "6 P0, 4 P1" (VP-INDEX v1.2).
> - **I2 (Pass-3):** Authored `verification-architecture.md` and `verification-coverage-matrix.md`
>   under `architecture/`. Resolves dangling `traces_to` reference in VP-INDEX.md.
> - **O3 (Pass-3):** `check-spec-counts.sh` extended with VP P0/P1 count assertion (check d),
>   BC H1↔BC-INDEX title sync (check e), and BC frontmatter-schema uniformity (check f).

> **v1.3 — Pass-2 adversarial defect resolution.**
> - **C2-01:** Grand total BC count corrected 179 → 178. BC-INDEX.md was not a BC;
>   per-subsystem counts (SS-01=41, SS-02=9, SS-03=15, SS-04=16, SS-05=11, SS-06=19,
>   SS-07=5, SS-08=17, SS-09=14, SS-10=9, SS-11=15, SS-12=7) are unchanged and already
>   sum to 178.
> - **I2-01:** D-SEC convergence dimension subsystem corrected from SS-04,SS-02 → SS-06
>   (Convergence Tracking Engine), aligning with BC-7.11.* frontmatter and
>   subsystem-decomposition assignment.
> - **I2-04:** Engine name "Bevy+Rapier" delexicalized in methodology-layer.md §2.3
>   (DI-008 compliance — no engine names in Layer-2 artifacts).
> - **S2-03:** D-SEC degradation rule unified: ADR-0006 fallback text reconciled to
>   match methodology-layer.md's authoritative `online_features:false` degradation rule.
> - **S2-02:** Count-consistency check script created at scripts/check-spec-counts.sh.

> **v1.2 — Phase-1d alignment.** BC count updated (was 168). Per-SS counts
> corrected: SS-01=41, SS-06=19, SS-09=14, SS-11=15. VP-INDEX updated with
> VP-TBD resolution table (I3). adapter-protocols.md §1.5 JSON-RPC collision
> resolved (C4). methodology-layer.md §2.5 DP table aligned to prd-cap-011.md
> §11.3 (C1); §2.8 D-013 distinction clarified (I5).

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
| `subsystem-decomposition.md` | SS-01..SS-13 definitions, BC→Subsystem assignment table (193 total), Directory→Subsystem alias table | ~1,600 |
| `dtu-assessment.md` | DTU analog: replay harness + conformance doubles; DTU_REQUIRED verdict | ~900 |
| `adapter-protocols.md` | Layer 3 adapter protocol spec: JSON-RPC transport, capability schema, fidelity grades, conformance suite, compatibility matrix; v1.2: §6 online-services seam (SS-13) added | ~1,500 |
| `methodology-layer.md` | Layer 2 game methodology: sim-BC schema, design-intent contract, replay-regression contract, asset-provenance, 11-dim convergence criteria; **§3.0 = canonical `convergence-report.dimensions.<field>` name registry (single source of truth for all 11 dimension field names)** | ~1,200 |
| `studio-of-agents.md` | 66-role Studio-of-Agents roster; producer-orchestrator scheduling; cross-discipline DAG; change-propagation rules | ~1,200 |
| `adrs/ADR-0004-adapter-family-anti-lock-in.md` | Five-seam adapter family as primary anti-lock-in mechanism | ~400 |
| `adrs/ADR-0005-config-content-extraction-seam.md` | Extraction seam: spine vs quality-model at content/config boundary | ~400 |
| `adrs/ADR-0006-11-dimension-convergence-model.md` | 11-dim convergence model replacing vsdd 7-dim | ~350 |
| `adrs/ADR-0007-human-gated-fidelity-tier.md` | human-gated as a first-class fidelity value | ~350 |
| `adrs/ADR-0008-anti-cheat-provider-policy.md` | Anti-cheat provider policy: allowed set {EAC, EOS, BattlEye}; Riot Vanguard rejected; kernel-anomaly rationale; conformance assertion for BC-13.02.006 (authored / active) | ~600 |
| `verification-architecture.md` | Verification strategy: provable-properties catalog, P0/P1 assignment, tool mapping (Kani/proptest), pure-sim slice boundary, VP-TBD rationale | ~1,000 |
| `verification-coverage-matrix.md` | VP→BC/invariant coverage matrix; per-VP tool/phase/module assignments; explicitly-unguarded invariant justifications | ~700 |

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

**Studio roster:** 66 roles — 57 NEW + 9 ADAPT (all game-discipline; enumerated in §2 of `studio-of-agents.md`). vsdd-factory infra agents (14 REUSE: orchestrator, adversary, state-manager, etc.) operate outside this roster count. See `studio-of-agents.md` §1 and §5.

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
| SS-09 | Monetization Ethics | CAP-011 | BC-11.* | P0/P1 (split — 8 P0 / 6 P1; see CAP-011 priority rationale) |
| SS-10 | Canon Knowledge-Base | CAP-012 | BC-12.* | P1 |
| SS-11 | Genre-Gated Lanes | CAP-013 | BC-13.* | P2 |
| SS-12 | XR Platform Seam | CAP-014 | BC-14.* | P2 |
| SS-13 | Online-Services Adapter | CAP-015 | BC-15.* | P1 (Tier-1 always-on; disableable for offline projects; split — 9 P0 / 3 P1 per BC) |

**BC count by subsystem (v2.0 — 193 total):**

| Subsystem | BC Count | Change from v1.0 |
|-----------|----------|-----------------|
| SS-01 | 42 (34 CAP-001 + 6 CAP-002 + 1 BC-1.15.002 + 1 BC-1.15.003) | +1 v1.1, +1 v2.0 |
| SS-02 | 9 | — |
| SS-03 | 15 | — |
| SS-04 | 16 | — |
| SS-05 | 11 | — |
| SS-06 | 19 (12 original + 7 BC-7.11.002..008) | +7 v1.2 |
| SS-07 | 5 | — |
| SS-08 | 17 (11 CAP-009 + 6 CAP-010) | — |
| SS-09 | 14 (13 original + 1 BC-11.03.006) | +1 v1.2 |
| SS-10 | 9 | — |
| SS-11 | 17 (14 original + 1 BC-13.01.004 + 1 BC-13.02.006 + 1 BC-13.03.005) | +1 v1.1, +2 v2.0 |
| SS-12 | 7 | — |
| SS-13 | 12 (BC-15.01.001..BC-15.11.001; 9 P0 + 3 P1) | +12 v1.8 |
| **TOTAL** | **193** | +3 from Pass-42 security burst (v2.0) |

---

## ADR Registry

| ID | Title | Status | File |
|----|-------|--------|------|
| ADR-0001 | Founding engine pair: Bevy + Unity | Accepted | `planning/decisions/0001-founding-engine-pair.md` |
| ADR-0002 | Protocol and conformance stance (hybrid LSP+Terraform+CRI) | Accepted | `planning/decisions/0002-protocol-and-conformance-stance.md` |
| ADR-0003 | Determinism tier as a capability dimension | Accepted | `planning/decisions/0003-determinism-tier-capability.md` |
| ADR-0004 | Five-seam adapter family as primary anti-lock-in mechanism (v1.1: reconciled from four-seam; online-services seam SS-13 added) | Draft | `adrs/ADR-0004-adapter-family-anti-lock-in.md` |
| ADR-0005 | Config/content extraction seam (spine vs quality-model) | Draft | `adrs/ADR-0005-config-content-extraction-seam.md` |
| ADR-0006 | 11-dimension convergence model | Draft | `adrs/ADR-0006-11-dimension-convergence-model.md` |
| ADR-0007 | human-gated as a first-class fidelity tier | Draft | `adrs/ADR-0007-human-gated-fidelity-tier.md` |
| ADR-0008 | Anti-cheat provider policy: allowed user-space {EAC, EOS, BattlEye}; kernel-anomaly providers (Riot Vanguard) rejected per DI-010 and R-017 | Draft | `adrs/ADR-0008-anti-cheat-provider-policy.md` |

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
| R-017 (kernel AC) | SS-01, SS-11 | DI-010 policy hook; anti-cheat = wrap-only; never autonomously authored (enforced via BC-1.15.002 VP-TBD-060/061); ADR-0008 formalizes allowed provider set {EAC, EOS, BattlEye} and rejects Riot Vanguard; BC-13.02.006 (anti-cheat-integration-adapter) authored / active |
| F42-SEC (secrets in output) | SS-01 | DI-013 (never-emit-secrets invariant; registered in domain-spec/invariants.md v1.2); output-bundle lint gate in cicd-setup.md §Output-Bundle Secrets Gate; D-SEC sub-predicate 4; BC-1.15.003 (never-emit-secrets) authored / active; E-SEC family registered |
| F42-MOD (moderation absent) | SS-11, SS-06 | 18 U.S.C. §2258A CSAM→NCMEC obligation; D-SEC fail-closed when `moderation-pipeline-contract` absent for UGC/chat games; BC-13.03.005 (moderation-pipeline-contract) authored / active; E-TMOD family registered |

---

## F42 Security Contracts (Pass-42)

The following section provides stable anchor targets for the three D-SEC security BCs
authored in the Pass-42 PO burst. BC files reference these anchors for traceability.

### F42-01 — Anti-Cheat Integration Adapter (BC-13.02.006) {#F42-01}

**BC:** BC-13.02.006 — `anti-cheat-integration-adapter` — authored / active.
**Subsystem:** SS-11 (Genre-Gated Lanes), directory `ss-13/`.
**D-SEC role:** Sub-predicate 2 — competitive-MP lane: anti-cheat provider must be
in the allowed set `{eac, eos, battleye}` per ADR-0008. Gate BLOCKED if absent or
provider outside allowed set.
**Error family:** E-ANTICH (registered in error-taxonomy.md).
**Architectural basis:** ADR-0008 (Anti-Cheat Provider Policy).

### F42-MOD — Moderation Pipeline Contract (BC-13.03.005) {#F42-MOD}

**BC:** BC-13.03.005 — `moderation-pipeline-contract` — authored / active.
**Subsystem:** SS-11 (Genre-Gated Lanes), directory `ss-13/`.
**D-SEC role:** Sub-predicate 3 — UGC/chat lane: moderation pipeline must be present
and pass conformance. CSAM → NCMEC reporting path verified (18 U.S.C. §2258A).
Gate BLOCKED if moderation absent when UGC/chat features active.
**Error family:** E-TMOD (registered in error-taxonomy.md).

### F42-03 — Never-Emit-Secrets Output-Bundle Gate (BC-1.15.003) {#F42-03}

**BC:** BC-1.15.003 — `never-emit-secrets` — authored / active.
**Subsystem:** SS-01 (Engine-Adapter Protocol), directory `ss-01/`.
**D-SEC role:** Sub-predicate 4 — all games: generated output bundle must pass
secret-pattern/entropy scan (DI-013). Gate BLOCKED if scan exits non-zero.
**Error family:** E-SEC (registered in error-taxonomy.md).
**CI job:** `CI / output-bundle-secrets-scan` (see cicd-setup.md §Output-Bundle Secrets Gate).
**Invariant:** DI-013 (registered in domain-spec/invariants.md v1.2).
