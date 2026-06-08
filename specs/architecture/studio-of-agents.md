---
document_type: architecture
level: L3
section: studio-of-agents
version: "1.3"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to:
  - ARCH-INDEX.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§5
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md#§6
  - .factory/specs/domain-spec/capabilities.md#CAP-005
inputs:
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/architecture/subsystem-decomposition.md
  - .factory/specs/architecture/layered-architecture.md
  - .factory/phase-0-ingestion/component-inventory.md
  - .factory/specs/prd.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Studio-of-Agents

> **v1.3 — Pass-13 adversarial defect C13-01 / I13-01 (online-services seam).**
> - **I13-01:** Role 58 (`backend-services-engineer`) owning subsystem corrected
>   SS-11 → SS-13 (Online-Services Adapter). Online-services is Tier-1 always-on;
>   SS-11 (Genre-Gated Lanes) is the wrong semantic home for always-on capabilities.
>   SS-13 is a new subsystem added in subsystem-decomposition.md v1.5.
> - **§3 SS-11 appearance count corrected 11→10** (role 58 no longer cross-listed
>   under SS-11). SS-13 row added (NEW=1, Total=1).
> - **§6 Tier 1 list annotation updated**: role 58 now listed under SS-13.
>
> **v1.2 — Pass-5 adversarial defect resolution (C1/I1 arithmetic).**
> - **C1:** §3 per-SS appearance counts fully recomputed from §2 roster (not patched).
>   SS-05 corrected: NEW 0→3 (systems-designer, economy-designer, combat-designer all
>   cross-list SS-04,SS-05), ADAPT stays 3, Total 3→6. SS-10 corrected: NEW 4→5
>   (narrative-designer, narrative-director, worldbuilder, loremaster, quest-designer),
>   Total 4→5. All other SS rows verified and unchanged.
> - **I1:** §6 Tier 1 count corrected 51→53 (roles 1–43,50–55,58–61 = 43+6+4 = 53);
>   Tier 2 count corrected 15→13 (roles 44–49,56–57,62–66 = 6+2+5 = 13). Partition
>   remains complete and disjoint (53+13=66). Summary line updated from "51+15=66"
>   to "53+13=66". Wrong "51 roles" label in §I2 fix-note also corrected.
>
> **v1.1 — Pass-4 adversarial defect resolution.**
> - **C1:** Resolved three-way internal count contradiction. Canonical roster is
>   57 NEW + 9 ADAPT = 66 game-discipline roles (all enumerated in §2 table). The
>   14 vsdd-factory infra REUSE agents are NOT part of the 66-role studio count;
>   they operate outside the roster. §1, §2, §3, and ARCH-INDEX now agree.
> - **I1:** `security-engineer` (role 55) owning subsystem corrected SS-05 → SS-06.
>   Its principal artifact `server-authority-invariant-suite` (BC-7.11.002..008) is
>   owned by SS-06 (Convergence Tracking Engine). §3 SS-05/SS-06 NEW counts adjusted.
> - **I2:** Roles 55/56/57 activation tier gap closed. `security-engineer` → Tier 1;
>   `anti-cheat-integrator` + `moderation-ops` → Tier 2. All 66 roles now partitioned.

> **Scope.** This document defines the 66-role Studio-of-Agents: the complete
> roster of game-discipline specialist agent roles, their extraction disposition
> (REUSE / NEW / ADAPT from vsdd-factory), their owning subsystem (SS-NN), and
> the producer-orchestrator scheduling model including the cross-discipline
> dependency DAG and handoff contracts.
>
> Source of record for the roster: RECONCILIATION §5.X.
> Source of record for subsystem assignments: ARCH-INDEX Subsystem Registry.

---

## 1. Role Extraction Disposition Summary

> **v1.1 canonical roster (C1 fix):** The 66-role studio roster consists exclusively
> of game-discipline specialist roles listed in §2. vsdd-factory infrastructure roles
> (orchestrator, adversary, state-manager, etc.) are sourced as REUSE from the vsdd
> engine and operate OUTSIDE this roster count — they are not game-discipline specialists
> and are not assigned to a game SS-NN. See §5 for the boundary.

| Disposition | Count | Description |
|-------------|-------|-------------|
| **NEW** | 57 | Net-new game-discipline specialists with no vsdd analog; pure game-domain roles. |
| **ADAPT** | 9 | vsdd-factory neutral agents reshaped to handle game contracts; mechanism unchanged, domain scope changed. (Roles 35–43 in §2.) |
| **Total (in-studio)** | 66 | All enumerated in the §2 roster table. |

> **vsdd-factory infra layer (not counted in 66):** 14 agents REUSE'd verbatim from
> vsdd-factory (orchestrator, adversary, state-manager, architect, implementer, test-writer,
> product-owner, formal-verifier, pr-manager, consistency-validator, research-agent,
> devops-engineer, demo-recorder, story-writer). These belong to Layer 1/Layer 2
> boundary and are activated by the pipeline engine — they are not game SS-NN owners.

Referencing RECONCILIATION §5 and component-inventory.md: the ADAPT set covers vsdd
agents whose mechanism is retained but whose scope shifts to game contracts —
`producer` → game-production-plan orchestration, `cert-owner` → platform cert, QA
roles → game-specific replay/balance/loc/compliance testing, `playtest-evaluator` →
3-lens convergence protocol. The NEW set is the complete game-discipline surface added
in v1.0/v1.5/v2.0 research integration.

---

## 2. Full Roster Table

> Column key — **Discipline:** domain grouping per RECONCILIATION §5.
> **SS-NN:** primary owning subsystem per ARCH-INDEX Subsystem Registry.
> **Disposition:** REUSE (from vsdd) / ADAPT (reshaped vsdd) / NEW (game-only).
> **Type:** S = Specialist, C = Catalyst/Shared (orchestrator role or cross-cutting).

| # | Role | Discipline | SS-NN | Disposition | Type | Principal Artifacts |
|---|------|-----------|-------|-------------|------|---------------------|
| 1 | `creative-director` | Creative direction | SS-04 | NEW | C | `art-bible.spec`, `style-profile` |
| 2 | `art-director` | Art direction | SS-04 | NEW | C | `art-bible.spec`, visual targets |
| 3 | `systems-designer` | Game design | SS-04, SS-05 | NEW | S | `design-spec`, `systems-spec`, `design-intent-contract` |
| 4 | `economy-designer` | Game design | SS-04, SS-05 | NEW | S | `economy-graph`, `economy-balance-contract`, `sink-faucet-model` |
| 5 | `combat-designer` | Game design | SS-04, SS-05 | NEW | S | `systems-spec` (combat), `damage-io-matrix` |
| 6 | `level-designer` | Game design | SS-04 | NEW | S | `level-spec`, `content-data` |
| 7 | `encounter-designer` | Game design | SS-04 | NEW | S | `encounter-spec`, `content-data` |
| 8 | `ux-accessibility-designer` | Game design | SS-04 | NEW | S | `ui-spec`, `accessibility-contract` |
| 9 | `concept-artist` | Visual art | SS-03 | NEW | S | `asset-generation-request` (2D), `asset-provenance-sidecar` |
| 10 | `env-modeler` | Visual art | SS-03 | NEW | S | GLB environment packages, provenance sidecar |
| 11 | `prop-artist` | Visual art | SS-03 | NEW | S | GLB prop packages, provenance sidecar |
| 12 | `char-modeler` | Visual art | SS-03 | NEW | S | GLB character mesh, provenance sidecar |
| 13 | `char-texture` | Visual art | SS-03 | NEW | S | PBR texture sets, provenance sidecar |
| 14 | `vfx-artist` | Visual art | SS-03 | NEW | S | `vfx.spec`, particle systems |
| 15 | `pipeline-ta` | Technical art | SS-03, SS-04 | NEW | C | Asset pipeline tooling, importer config |
| 16 | `char-rigger` | Character art | SS-03 | NEW | S | `rig.skeleton`, `skin.weights` |
| 17 | `char-ta` | Character art | SS-03 | NEW | C | `anim-state-machine.spec` review |
| 18 | `animator` | Character art | SS-03 | NEW | S | `anim.clips` |
| 19 | `anim-ta` | Character art | SS-03 | NEW | C | Animation pipeline tooling |
| 20 | `audio-designer` | Audio | SS-03, SS-04 | NEW | S | `audio-design-spec`, `sfx-manifest` |
| 21 | `composer` | Audio | SS-03 | NEW | S | `music-interactive-spec`, AI audio generation |
| 22 | `audio-implementer` | Audio | SS-04 | NEW | S | `audio-build-manifest`, `bus-and-mix-spec`, middleware wiring |
| 23 | `voice-director` | Audio | SS-03 | NEW | C | `dialogue-table`, voice generation direction |
| 24 | `narrative-designer` | Narrative | SS-04, SS-10 | NEW | S | `narrative-graph`, `quest-schema` |
| 25 | `writer` | Narrative | SS-04 | NEW | S | `bark-rules.schema`, narrative text |
| 26 | `localization-engineer` | Narrative | SS-04 | NEW | S | `loc-string-contract`, XLIFF 2.0 export |
| 27 | `narrative-director` | Narrative / Lore | SS-10 | NEW | C | `story-structure-spec`, `narrative-arc-contract` |
| 28 | `worldbuilder` | Lore | SS-10 | NEW | S | `canon-kb` (entity-registry, relationship-graph, timeline) |
| 29 | `loremaster` | Lore | SS-10 | NEW | C | `canon-continuity-check-battery`, continuity audit |
| 30 | `quest-designer` | Narrative | SS-04, SS-10 | NEW | S | `quest-schema`, canon binding |
| 31 | `systemic-writer` | Narrative | SS-04 | NEW | S | `bark-rules.schema`, systemic dialogue |
| 32 | `cinematic-writer` | Narrative | SS-04 | NEW | S | `cinematic-spec`, dialogue |
| 33 | `copywriter` | Narrative / Marketing | SS-04, SS-08 | NEW | S | `store-text-bundle`, `press-kit` |
| 34 | `asset-generation-orchestrator` | Asset pipeline | SS-03 | NEW | C | `asset-generation-request`, `quality-gate-report`, risk-tier routing |
| 35 | `producer` | Production | SS-04, SS-06 | ADAPT | C | `game-production-plan`, `cross-discipline-dependency-contract`, wave schedule |
| 36 | `cert-owner` | Cert / compliance | SS-08 | ADAPT | C | `cert-preflight-checklist`, `distribution-release-pipeline` |
| 37 | `functional-qa` | QA | SS-05, SS-07 | ADAPT | S | `replay-regression-contract`, `test-suite-manifest` |
| 38 | `compat-qa` | QA | SS-05 | ADAPT | S | `perf-budget-contract`, compatibility matrix |
| 39 | `balance-qa` | QA | SS-05, SS-07 | ADAPT | S | Balance-band assertions, economy rebalance reports |
| 40 | `localization-qa` | QA | SS-04 | ADAPT | S | Pseudo-loc, coverage check, ICU parity |
| 41 | `compliance-qa` | QA | SS-08 | ADAPT | S | `compliance-checklist` verification |
| 42 | `accessibility-qa` | QA | SS-04 | ADAPT | S | GAG/XAG, CVAA checklist |
| 43 | `playtest-evaluator` | QA / Playtest | SS-07 | ADAPT | C | `playtest-protocol`, 3-lens convergence report, human-gate sign-off |
| 44 | `monetization-designer` | Monetization | SS-09 | NEW | S | `monetization-ethics-contract`, `iap-catalog`, `gacha-spec` |
| 45 | `economy-balancer` | Monetization | SS-09 | NEW | S | `live-economy-balance-contract`, `sink-faucet-model` |
| 46 | `trailer-editor` | Marketing | SS-08, SS-11 | NEW | S | `capture-recipe`, `marketing-asset-manifest` |
| 47 | `key-art-director` | Marketing | SS-08, SS-11 | NEW | C | Key art generation direction, `store-page-spec` visuals |
| 48 | `store-copywriter` | Marketing | SS-08, SS-11 | NEW | S | `store-page-spec` text, Steam capsule lint |
| 49 | `community-manager` | Marketing | SS-08, SS-11 | NEW | C | `campaign-beat-plan`; live engagement = human-gated |
| 50 | `compliance-officer` | Compliance | SS-08 | NEW | C | `compliance-checklist`, `ratings-submission-manifest`, `privacy-config-contract` |
| 51 | `ratings-submitter` | Compliance | SS-08 | NEW | S | `ai-disclosure-manifest`, `ratings-submission-manifest` |
| 52 | `cinematic-director` | Cinematics | SS-04 | NEW | C | `cinematic-spec`, `sequence-graph`; `directed:true` = human-gated |
| 53 | `camera-cinematography` | Cinematics | SS-04 | NEW | S | `camera-rules-profile` |
| 54 | `lipsync-animator` | Cinematics | SS-03 | NEW | S | `lip-sync-pipeline-contract` (ARKit-52 blendshapes) |
| 55 | `security-engineer` | Security | SS-06 | NEW | S | `security-requirements-contract`, `server-authority-invariant-suite` |
| 56 | `anti-cheat-integrator` | Security | SS-11 | NEW | S | `anti-cheat-integration-adapter` (EAC/EOS wrap-only) |
| 57 | `moderation-ops` | Security / Trust | SS-11 | NEW | C | `moderation-pipeline-contract`; judgment = human-gated |
| 58 | `backend-services-engineer` | Online services | SS-13 | NEW | S | `online-services-spec`, `remote-config-contract` |
| 59 | `platform-integrator` | Platform | SS-08 | NEW | S | `platform-integration-manifest` |
| 60 | `release-engineer` | Distribution | SS-08 | NEW | S | `distribution-release-pipeline` (steamcmd/butler/fastlane) |
| 61 | `liveops-sre` | LiveOps | SS-06, SS-08 | NEW | S | Crash-reporting symbol upload, feature-flag wiring, A/B runbooks |
| 62 | `xr-adapter-owner` | XR | SS-12 | NEW | C | `xr-adapter`, `xr-comfort-spec`; deferred platform tier |
| 63 | `mod-api-owner` | Modding | SS-11 | NEW | C | `mod-api-contract`, `ugc-content-schema` |
| 64 | `ugc-pipeline-engineer` | Modding | SS-11 | NEW | S | `ugc-distribution-adapter`, `mod-load-spec` |
| 65 | `ranking-systems-engineer` | Esports | SS-11 | NEW | S | `ranking-system-contract`, `matchmaking-fairness-invariants` |
| 66 | `spectator-tournament-engineer` | Esports | SS-11 | NEW | S | `replay-format`, `spectator-spec`, `tournament-mode-spec` |

---

## 3. Disposition Breakdown by Subsystem

> **Counting rule.** Each role is counted under every SS-NN listed in its row (cross-listed
> roles appear more than once). Column totals therefore exceed 66; the "Total principal roles"
> column counts all appearances including cross-listed ones. The §2 table is the authoritative
> source — each row has exactly one disposition tag. Per-SS totals here reflect the set of
> roles that have responsibility in that subsystem (ADAPT: 9 unique roles; NEW: 57 unique roles).

| SS | Name | ADAPT | NEW | Total appearances |
|----|------|-------|-----|-------------------|
| SS-03 | Asset Generation Pipeline | 0 | 16 | 16 (cross-listed) |
| SS-04 | Multi-Discipline Production | 3 | 20 | 23 (cross-listed) |
| SS-05 | Simulation Quality Verification | 3 | 3 | 6 (cross-listed) |
| SS-06 | Convergence Tracking | 1 | 2 | 3 (cross-listed) |
| SS-07 | Playtest Protocol | 3 | 0 | 3 |
| SS-08 | Cert and Distribution | 2 | 10 | 12 (cross-listed) |
| SS-09 | Monetization Ethics | 0 | 2 | 2 |
| SS-10 | Canon Knowledge-Base | 0 | 5 | 5 (cross-listed) |
| SS-11 | Genre-Gated Lanes | 0 | 10 | 10 (cross-listed) |
| SS-12 | XR Platform Seam | 0 | 1 | 1 |
| SS-13 | Online-Services Adapter | 0 | 1 | 1 |

> Note: vsdd-factory infrastructure roles (orchestrator, adversary, architect,
> state-manager, implementer, test-writer, product-owner, formal-verifier, pr-manager,
> consistency-validator, research-agent, devops-engineer, demo-recorder, story-writer)
> are sourced as REUSE from the vsdd engine. They are NOT game-discipline specialists,
> are NOT assigned to a game SS-NN, and are NOT counted in the 66-role studio roster.
> See §5 for the Layer 1/Layer 2 boundary with vsdd-factory infrastructure agents.
> The ADAPT column above covers the 9 in-studio ADAPT roles (roles 35–43 in §2).
> (I1 fix v1.1: `security-engineer` role 55 moved from SS-05 → SS-06; SS-05 NEW 1→0 then
> corrected to 3 in v1.2 (C1) — systems-designer/economy-designer/combat-designer cross-list
> SS-04,SS-05. SS-06 NEW 1→2 in v1.1; unchanged in v1.2.)
> (I13-01 fix v1.3: `backend-services-engineer` role 58 moved from SS-11 → SS-13;
> SS-11 NEW 11→10; SS-13 added NEW=1.)

---

## 4. Producer-Orchestrator Scheduling Model

### 4.1 Role Types in the Scheduler

The studio uses two scheduling classes:

**Catalyst/Shared (C)** — Always-on; wired once at pipeline initialization; cross-discipline
arbiters. The `producer` holds the `game-production-plan` and the
`cross-discipline-dependency-contract` — the producer IS the scheduler.

**Specialist (S)** — Activated per wave according to the dependency DAG. Each specialist
runs within its wave, reads upstream handoff artifacts, produces its contracted outputs,
and commits to the worktree. The wave gate validates handoff artifact presence before
the next wave starts.

### 4.2 Cross-Discipline Dependency DAG

The canonical production order is a five-phase wave DAG grounded in
RECONCILIATION §4 mechanism mapping and §7 convergence model:

```
Wave 0 — Design Foundation
├── systems-designer (design-spec, systems-spec, balance-data, economy-graph,
│   progression-spec, content-data, level-specs, ui-spec, accessibility-contract,
│   design-intent-contracts)
├── economy-designer (economy-graph, economy-balance-contract)
├── narrative-designer (narrative-graph, quest-schema)
├── worldbuilder, loremaster (canon-kb — entity-registry, timeline, naming-registry)
├── narrative-director (story-structure-spec, narrative-arc-contract)
└── combat-designer, level-designer, encounter-designer, ux-accessibility-designer

  HANDOFF CONTRACT: design-spec-bundle validated; engine-neutral assertion by DI-008;
  canon-kb structural integrity (BC-12.12.007); all downstream disciplines gate on this.

Wave 1 — Art and Audio Generation
├── asset-generation-orchestrator (routes all requests via asset-adapter; tier-assigns)
├── concept-artist, env-modeler, prop-artist, char-modeler, char-texture, vfx-artist
│   → asset-generation-requests → [asset-adapter] → GLB packages + provenance sidecars
├── char-rigger, char-ta, animator, anim-ta (rig, skin.weights, anim.clips)
├── composer, audio-designer (music-interactive-spec, sfx-manifest)
├── voice-director (dialogue-table, voice generation; consent gate if likeness-ref != null)
└── audio-implementer (audio-build-manifest, middleware wiring)

  HANDOFF CONTRACT: all asset-provenance-sidecars complete with disclosure_class (DI-003);
  quality-gate-report pass per risk tier; GLB topology/UV/PBR validated; loudness conformance.

Wave 2 — Engineering Integration
├── implementer (pure-sim slice: economy, FSM, AI BTs, rating-system — TDD Red Gate)
├── test-writer (sim-BC tests, replay-regression-contract tests; failing tests first)
├── backend-services-engineer (online-services-spec, remote-config-contract)
├── platform-integrator (platform-integration-manifest)
├── security-engineer (server-authority-invariant-suite)
├── audio-implementer (bank build; loudness/true-peak CI gate)
├── lipsync-animator (lip-sync-pipeline-contract; ARKit-52 blendshapes)
└── cinematic-director, camera-cinematography (sequence-graph, camera-rules-profile)

  HANDOFF CONTRACT: build passes CI; TDD Red Gate cleared for pure-sim slice; replay-
  regression-contract authored and linked (BC-6.03.001); security-requirements-contract
  structural presence validated; all asset refs in sequence-graph resolve.

Wave 3 — QA, Balance, Compliance
├── functional-qa (replay-regression suite run at declared determinism tier)
├── balance-qa (balance-band assertions, economy rebalance, ranking-system math)
├── compat-qa (perf-budget-contract)
├── localization-qa (pseudo-loc, coverage, ICU parity)
├── accessibility-qa (GAG/XAG, CVAA)
├── compliance-qa (compliance-checklist, ratings-submission-manifest)
├── compliance-officer (IARC auto-fill, ai-disclosure-manifest, privacy-config-contract)
├── ratings-submitter (ratings-submission-manifest; terminal step = human-gated)
└── monetization-designer + economy-balancer (if monetization enabled; adversary review)

  HANDOFF CONTRACT: replay-regression green at declared tier; all BCs in sim-quality
  dimensions green; compliance-checklist populated; ai-disclosure-manifest generated;
  monetization-ethics-contract adversarially reviewed (if present).

Wave 4 — Distribution and Release Prep
├── cert-owner (cert-preflight-checklist; distribution-release-pipeline)
├── release-engineer (steamcmd/butler/fastlane CLIs; human-gated task list emitted)
├── trailer-editor (capture-recipe; marketing-asset-manifest)
├── store-copywriter + key-art-director (store-page-spec; Steam capsule lint)
├── community-manager (campaign-beat-plan)
└── liveops-sre (telemetry-event-taxonomy, kpi-dashboard-spec, crash-reporting-wiring)

  HANDOFF CONTRACT: distribution-release-pipeline CI-verified (CLI commands pass);
  human-gated task list surfaced for console cert + store publish (DI-006);
  store-page-spec machine-validated (dimensions, char limits, format).
```

Genre-gated agents (`ranking-systems-engineer`, `spectator-tournament-engineer`,
`mod-api-owner`, `ugc-pipeline-engineer`, `anti-cheat-integrator`, `moderation-ops`,
`xr-adapter-owner`) are activated only when the genre-profile declares the corresponding
lane. Inactive agents produce zero artifacts (BC-13.01.002 inactive-lane guarantee).

### 4.3 Change-Propagation Rules

| Upstream change | Propagates to | Gate |
|----------------|--------------|------|
| `design-spec` modified | All Wave 1+ consumers via cross-discipline-dependency-contract | Dependency contract re-validated on merge |
| `canon-kb` entity added/modified | Narrative graph, quest schema, bark rules, RAG contract | BC-12.12.008 retcon propagation: where-used impact analysis |
| Asset GLB modified | All sequence-graph refs | sequence-validation-report re-run |
| `economy-graph` modified | Balance-band assertions, sin/faucet model, leaderboard seeds | Balance-qa re-run; economy conservation VP re-evaluated |
| `ranking-system-contract` modified | Matchmaking fairness invariants, tournament BCs | Ranking-system math VPs re-verified |
| Engine adapter version bump | Conformance suite re-run for affected capabilities | BC-2.02.005 anti-drift scheduled check |

---

## 5. Boundary with vsdd-Factory Infrastructure Agents

Game-discipline specialist agents (this document) run INSIDE the wave-DAG orchestrated
by the vsdd-factory infrastructure agents (Layer 1, not enumerated here):

- `orchestrator` dispatches waves; reads `game-production-plan` from `producer`.
- `state-manager` bookmarks wave state; game-domain decision log entries added.
- `adversary` reviews game-discipline outputs at convergence; `monetization-ethics-contract`
  adversarial pass is mandatory when monetization present.
- `consistency-validator` cross-checks IDs, BC anchors, VP anchors across all game artifacts.
- `pr-manager` runs the 9-step PR lifecycle for each story worktree.

These agents are REUSE from vsdd-factory and are not counted in the 66-role studio roster.

---

## 6. Activation Model (Scope Tiers)

> **v1.1 (I2 fix):** Roles 55–57 were previously unassigned to a tier. They are now
> explicitly placed: `security-engineer` is Tier 1 (always-on; server-authority
> invariants are required for all online titles), `anti-cheat-integrator` and
> `moderation-ops` are Tier 2 (genre-gated; online/multiplayer only). All 66 roles
> are now covered with no gaps or overlaps.

| Tier | Activated agents | Rationale |
|------|-----------------|-----------|
| **Tier 1 — v1 Core** | Roles 1–43, 50–55, 58–61 (53 roles) | Det-sim pilot universal spine; includes `security-engineer` (always-on for server-authority invariant suite, required for all online titles) and `backend-services-engineer` (SS-13 — always-on for projects with online_features: true; inactive for offline/single-player projects) |
| **Tier 2 — Genre-Gated** | Roles 44–49, 56–57, 62–66 (13 roles) | Optional; activated per genre-profile. `anti-cheat-integrator` (role 56): online/competitive only; `moderation-ops` (role 57): online/UGC/multiplayer only; monetization/marketing/esports/modding/XR as before |
| **Tier 3 — Deferred** | `xr-adapter-owner` (role 62) implementation | Seam reserved; build deferred |

> Tier 1 + Tier 2 = 53 + 13 = 66. All roles accounted for.
>
> The det-sim pilot (Bevy, premium/cosmetic-DLC, no UGC, no esports) deploys
> approximately 40 active specialists plus all catalysts from Tier 1.
