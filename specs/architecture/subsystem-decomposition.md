---
document_type: architecture-section
level: L4
section: subsystem-decomposition
version: "1.7"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
inputs:
  - .factory/specs/behavioral-contracts/BC-INDEX.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Subsystem Decomposition

> **v1.7 changes (Pass-31 I31-01 fix — Canon-KB seam ordinal fifth→sixth in SS-10 description):**
> - **I31-01 fixed:** SS-10 (Canon Knowledge-Base) description corrected "fifth load-bearing
>   seam" → "sixth load-bearing seam". The product-brief §Overflow Context (line 111) and
>   ADR-0004 both state Canon-KB is the sixth load-bearing seam (five adapter seams precede
>   it: engine/asset/distribution/XR/online-services). Root cause: Pass-14 O14-02 fix did
>   not propagate to this passage.

> **v1.6 changes (CAP-015 BCs delivered by PO — SS-13 count finalized):**
> - SS-13 BC count updated from TBD → 12 (BC-15.01.001..BC-15.11.001; 9 P0 + 3 P1).
>   Grand total updated 178 + TBD → **190**.
>   Priority subtotals: P0 117→126 (+9), P1 39→42 (+3), P2 22 (unchanged). Sum: 190. ✓
>   BC→Subsystem assignment table updated with explicit BC-15.* count and total.
>
> **v1.5 changes (Pass-13 adversarial defect C13-01 — online-services seam):**
> - **C13-01:** Added SS-13 (Online-Services Adapter, CAP-015) as a new subsystem.
>   Role 58 (`backend-services-engineer`) moved from SS-11 → SS-13 (I13-01 resolution:
>   online-services is Tier-1 always-on, not genre-gated; SS-11 owns only genre-gated lanes).
>   DTU-08 (Nakama BaaS Double) subsystem corrected SS-11 → SS-13.
>   BC-count total unchanged at 178 pending PO authoring of CAP-015 BCs.
>   SS-11 appearance count in §3 corrected 11→10; SS-13 added (1 appearance).
>   Alias table extended with `ss-15/` → SS-13 row.
>   ARCH-INDEX subsystem registry updated to 13 subsystems.
>
> **v1.4 changes (Pass-6 adversarial defect I6-01 / O6-01):**
> - **I6-01:** Priority subtotals corrected to frontmatter ground truth. The stale
>   P0=111/P1=45 values undercounted the 8 P0 dark-pattern/ethics BCs in SS-09
>   (BC-11.01.001/002/003, 11.02.001, 11.03.001/002/004/006 — all `priority: P0` per
>   D-008 decision) and overcounted P0 by 2 for SS-03 (BC-4.03.003/BC-4.04.003 are
>   `priority: P1` in frontmatter). New totals: P0=117 (SS-01=41, SS-02=9, SS-03=13,
>   SS-04=16, SS-05=11, SS-06=19, SS-09=8), P1=39 (SS-03=2, SS-07=5, SS-08=17,
>   SS-09=6, SS-10=9), P2=22 (SS-11=15, SS-12=7). Sum: 117+39+22=178. ✓
> - **O6-01:** SS-09 single-value "P1" label changed to "P0/P1 (split)" to reflect
>   that CAP-011 contains BCs at both priorities.
>
> **v1.3 changes (Pass-5 adversarial defect I3):**
> - **I3:** P0 subtotal corrected 112 → 111. The "+1 v1.1 SS-01" parenthetical in the
>   Subsystem Priority Summary double-counted the BC-1.15.002 addition — that BC is
>   already included in SS-01=41. Removed the parenthetical; P0 sum was
>   41+9+15+16+11+19 = 111 (now superseded by v1.4 correction above).
>
> **v1.1 changes (Phase-1d arch alignment):**
> - **I1:** BC→Subsystem table updated from 168 → 178 total. Added rows for BC-1.15.002
>   (SS-01, v1.1), BC-13.01.004 (SS-11, v1.1), BC-11.03.006 (SS-09, v1.2), and
>   BC-7.11.002..008 (SS-06, v1.2). Per-SS BC counts updated: SS-01=41, SS-06=19,
>   SS-09=14, SS-11=15.
> - **C2-01 (v1.2):** Grand total corrected 179 → 178. The previous "179" erroneously
>   counted BC-INDEX.md as a behavioral contract; per-subsystem counts already sum to
>   178 and were always correct. Only the TOTAL rows are changed.
> - **I1:** SS-09 language corrected from "five declared patterns" to "six declared
>   patterns" (DP-003 through DP-008 inclusive is six patterns).
> - **I6:** Added authoritative Directory→Subsystem Alias Table at end of document.
>   Establishes explicit mapping from `ss-NN/` directory names to SS-NN subsystem IDs
>   and documents all hazard rows (where directory suffix ≠ subsystem suffix).
> - **I1 note in preamble:** Added anchoring hazard warning directing readers to the
>   alias table.

> **Primary purpose of this document:** (1) define each subsystem with scope, layer
> assignment, and principal agents; (2) provide the BC→Subsystem assignment table
> resolving all SS-TBD placeholders in BC frontmatter; (3) provide the
> Directory→Subsystem alias table (authoritative anchor for I6).
>
> **Note on directory names.** The BC file tree uses `ss-01/`…`ss-14/` as navigability
> aliases for `CAP-001`…`CAP-014`. These directory names do NOT correspond to SS-NN IDs.
> The authoritative SS-NN assignments are in this document and in ARCH-INDEX.md.
> A separate mechanical pass will update the `subsystem:` frontmatter field in each BC
> file once this document is accepted.
>
> **IMPORTANT — directory-to-subsystem alias (I6 resolution):** Because CAP-NNN does not
> map 1:1 to SS-NN (CAP-001+002 → SS-01; CAP-009+010 → SS-08; all others 1:1 except
> the CAP numbering gap at SS-11/SS-12), the `ss-NN/` directory holding a BC file is
> NOT the same as the BC's `subsystem:` field. See the **Directory → Subsystem Alias
> Table** at the end of this document. Always resolve subsystem membership from that
> table or from the BC's own `subsystem:` frontmatter field — never from directory name
> alone.

---

## Subsystem Definitions

### SS-01 — Engine-Adapter Protocol

**Layer:** 3 + 4 (protocol layer + adapter implementations)
**Owned capabilities:** CAP-001, CAP-002
**BC count:** 41 (34 CAP-001 + 6 CAP-002 + 1 v1.1: BC-1.15.002 never-author enforcement)
**Priority:** P0

Owns the complete engine adapter protocol surface (JSON-RPC 2.0 transport, capability
manifest, fidelity grades, execution profiles, conformance suite) and the adapter
implementations for the founding pair (Bevy, Unity) and planned third (Godot).
Enforces DI-001 (core never names an engine) and DI-002 (conformance required before
acceptance). The two-adapter rule (ADR-0001) is a structural constraint on this
subsystem's design process.

**Principal agents:** `devops-engineer` (CI conformance runner), specialist adapter
implementers (one per engine), `consistency-validator` (manifest drift detection).

---

### SS-02 — Deterministic Replay Harness

**Layer:** 2 + 3 (methodology layer owns the harness contract; Layer 3 provides the
`replay` capability surface via the engine adapter protocol)
**Owned capabilities:** CAP-003
**BC count:** 9
**Priority:** P0

Owns input-stream recording keyed by sim frame, deterministic replay execution, and
state comparison using the tier-declared method (T1 exact snapshot-hash / T2
pinned-runner / T3 tolerance-window). Enforces DI-004 (tier declared, never assumed).
Golden-state bootstrap and invalidation protocol is a critical lifecycle concern.
The replay spine is cross-cutting: QA regression, esports demo export (BC-3.03.009),
anti-cheat proof-of-state — all served by the same harness.

**Principal agents:** `functional-qa`, replay-regression specialist, `formal-verifier`
(sim hardening scope only).

---

### SS-03 — Asset Generation Pipeline

**Layer:** 2 (methodology layer — asset-adapter is Layer 4)
**Owned capabilities:** CAP-004
**BC count:** 15
**Priority:** P0

Owns pure-maximal asset generation across all modalities (3D mesh, texture, audio,
music, voice, concept art, narrative text), the asset-adapter routing and fidelity
grading, backend blocklist enforcement (DI-009: Suno/Udio blocked), risk-tier
assignment, provenance sidecar population (DI-003: mandatory at generation time),
quality gate definitions per asset class, and asset store ingest gating.
Enforces R-001/R-002/R-003/R-004 mitigations (copyright, indemnification, Suno/Udio,
SAG-AFTRA). The `disclosure_class` field supports R-014 (EU AI Act Art. 50 C2PA marks).

**Principal agents:** `asset-generation-orchestrator`, `concept-artist`, `env-modeler`,
`prop-artist`, `char-modeler`, `char-texture`, `vfx-artist`, `composer`, `voice-director`.

---

### SS-04 — Multi-Discipline Production

**Layer:** 2 (methodology layer)
**Owned capabilities:** CAP-005
**BC count:** 16
**Priority:** P0

Owns the cross-discipline artifact production scope: design spec bundle, economy graph,
accessibility contract, art package + art bible, audio build manifest + provenance ledger,
narrative graph + canon-KB binding, gameplay code (gameplay-logic/pure-sim separation
contract), cinematics sequence graph + lip-sync pipeline, and cross-discipline dependency
contracts governing wave ordering. This is the "Studio-of-Agents" integration layer —
it does not own individual discipline artifacts but owns the dependency DAG and handoff
contracts that link them.

**Principal agents:** `producer`, all 66 studio roles (depending on active genre lanes),
wave scheduling orchestrator.

---

### SS-05 — Simulation Quality Verification

**Layer:** 2 (methodology layer — pure-sim slice)
**Owned capabilities:** CAP-006
**BC count:** 11
**Priority:** P0

Owns the machine-verifiable quality spine for game simulation: economy conservation
invariant, damage I/O matrix correctness, FSM state legality, AI behavior-tree
determinism, design-intent reachability, game solvability, balance bands, no-softlock
invariant, and TDD Red Gate enforcement for the pure-sim code slice. Distinct from
SS-02 (which owns the *replay mechanism*); SS-05 owns the *contract declarations* that
the replay harness verifies against. DI-012 (every contract has a declared validation
method) is enforced here.

**Principal agents:** `functional-qa`, `balance-qa`, `systems-designer`, `economy-designer`,
`implementer` (pure-sim), `test-writer` (pure-sim).

---

### SS-06 — Convergence Tracking Engine

**Layer:** 2 (methodology layer — convergence loop)
**Owned capabilities:** CAP-007
**BC count:** 19 (+7 v1.2: BC-7.11.002..008 server-authority invariant suite CWE-602)
**Priority:** P0

Owns the 11-dimension convergence evaluation and release-gating loop. The original 12
BCs map to convergence dimension evaluation contracts plus the release-gating rule.
BC-7.11.001 owns D-SEC dimension evaluation; BC-7.11.002..008 are the seven individual
server-authority invariants (CWE-602 spine) that D-SEC evaluates.
The convergence loop engine itself (novelty-decay, 3-CLEAN streak, dimension declarations)
is ADAPTED from vsdd-factory's 7-dim machinery (extraction-boundary-validated.md §3.2).
A release is blocked until all required dimensions are green or explicitly degraded to a
declared fallback. SS-06 is the structural integration of all other subsystems — it
reads convergence signals from SS-01 through SS-12 and gates the release.

**Principal agents:** `convergence-tracking` skill, adversary (monetization-ethics review),
`state-manager` (convergence state bookkeeping).

---

### SS-07 — Playtest Protocol

**Layer:** 2 (methodology layer — human gate)
**Owned capabilities:** CAP-008
**BC count:** 5
**Priority:** P1

Owns the structured human playtest protocol (3-lens: say/do/behave), GEQ/PENS/SUS
instrument scaffolding, evidence capture, convergence report synthesis, human sign-off
gate, and agent-fun-score detection (any auto-emitted fun score is a defect per DI-007).
This is the game-factory analog of vsdd-factory's holdout evaluator — but explicitly
not automated. The mandatory human sign-off (BC-8.08.004) is a non-suppressible hook.

**Principal agents:** `playtest-evaluator`, `functional-qa`, `balance-qa`.

---

### SS-08 — Cert and Distribution

**Layer:** 2 + 4 (methodology layer owns the cert-preflight contracts; distribution
adapter is Layer 4)
**Owned capabilities:** CAP-009, CAP-010
**BC count:** 17 (11 + 6)
**Priority:** P1

Owns cert pre-flight (machine-checkable subset per platform), distribution CLI execution
(steamcmd/butler/fastlane), distribution-release-pipeline artifact, store-asset spec
conformance, human-gated task surfacing for console cert sign-off and store publish (DI-006),
and the full compliance pipeline: IARC auto-fill, compliance-checklist, privacy-config-contract,
legal-doc-set, and `ai-disclosure-manifest` (C2PA marks from provenance sidecar, R-014).
Enforces R-013 (PEGI 2026 content-descriptor min-rating rules) and R-015 (COPPA per-SDK
consent flags).

**Principal agents:** `cert-owner`, `compliance-officer`, `ratings-submitter`,
`release-engineer`, `platform-integrator`.

---

### SS-09 — Monetization Ethics

**Layer:** 2 (methodology layer — ethics enforcement)
**Owned capabilities:** CAP-011
**BC count:** 14 (+1 v1.2: BC-11.03.006 DP-007)
**Priority:** P0/P1 (split — 8 P0 / 6 P1; see CAP-011 priority rationale)

Owns the monetization-ethics-contract schema, default ethics envelope, mandatory adversarial
review gate, and all constrained-optimization invariants: no unconstrained LTV objective
(DI-005), economy-spine propagation, no-progression-deadlock-without-spend, and forbidden
dark-pattern enforcement (six declared enforced patterns: DP-003 through DP-008). Also owns gacha
EV/pity correctness and spend-concentration guardrail (Gini coefficient bound). This
subsystem applies to any game with monetization; ethics contract absence is a factory
defect when monetization is present.

**Principal agents:** `monetization-designer`, `economy-designer`, `economy-balancer`,
adversary (mandatory ethics review).

---

### SS-10 — Canon Knowledge-Base

**Layer:** 2 (methodology layer — lore/RAG spine)
**Owned capabilities:** CAP-012
**BC count:** 9
**Priority:** P1

Owns the Canon-KB structure (entity-registry, relationship-graph, timeline, naming-registry,
canon-facts), machine-checkable structural integrity (no dangling refs, timeline consistency,
phonotactic naming rules), retcon propagation (where-used impact analysis), and the
RAG-grounding contract ensuring all generative agents query the Canon-KB rather than
hallucinating lore. The Canon-KB is identified as the sixth load-bearing seam
(product-brief §Overflow Context).

**Principal agents:** `worldbuilder`, `loremaster`, `narrative-director`, `quest-designer`.

---

### SS-11 — Genre-Gated Lanes

**Layer:** 2 (methodology layer — genre activation)
**Owned capabilities:** CAP-013
**BC count:** 15 (+1 v1.1: BC-13.01.004 NFT/web3 off-by-default DI-011)
**Priority:** P2

Owns the genre-profile schema, inactive-lane zero-artifact guarantee, lane idempotency,
and four optional lanes: competitive-multiplayer/esports (ranking system, matchmaking,
replay export, spectator, tournament), modding/UGC (mod-API contract, UGC schema,
mod-load determinism, mod.io distribution adapter), marketing/GTM (store asset
conformance, marketing asset manifest), and a genre-profile activation router.
Inactive lanes impose zero constraints on the universal core. This subsystem is
Tier-2: v1-ready, genre-gated opt-in.

**Principal agents:** `ranking-systems-engineer`, `spectator-tournament-engineer`,
`mod-api-owner`, `ugc-pipeline-engineer`, `store-copywriter`, `trailer-editor`,
`key-art-director`.

---

### SS-12 — XR Platform Seam

**Layer:** 3 (seam contract only; implementation Layer 4 DEFERRED)
**Owned capabilities:** CAP-014
**BC count:** 7
**Priority:** P2 (Tier 3 — seam reserved; implementation deferred)

Owns the XR adapter manifest schema, OpenXR capability fidelity grading (extension
namespace: KHR > EXT > vendor), XR seam isolation invariant (zero core changes on
XR adapter add/remove), XR performance budget schema, XR comfort spec (locomotion,
vignette, candidate rating), and human-gated comfort-cert (vestibular gate by
construction, DI-006). Apple Vision Pro is a separate non-OpenXR adapter target.
The seam contract (Layer 3 schema) is defined now so it does not require core changes
when implementation begins; the adapter implementation is deferred.

**Principal agents:** `xr-adapter-owner` (deferred).

---

### SS-13 — Online-Services Adapter

**Layer:** 3 + 4 (seam contract at Layer 3; adapter implementations at Layer 4)
**Owned capabilities:** CAP-015 (Online-Services Adapter)
**BC count:** 12 (BC-15.01.001..BC-15.11.001; 9 P0 + 3 P1; delivered by PO v1.6)
**Priority:** P1 (Tier 1 — v1 ship prerequisite; default-on for online-enabled titles;
  must be disableable for offline/single-player projects via `online_features: false`)

Owns the online-services adapter seam: the BaaS capability surface
(identity/saves/cloud-save, leaderboards, matchmaking, entitlements), the
online-services manifest schema, conformance suite, and reference adapter
implementations. This is the fifth adapter seam per ADR-0004 v1.1.

**Subsystem placement rationale (I13-01 resolution).** Online-services is Tier-1
always-on (product brief §Overflow Context §Tier 1 list) — it is NOT genre-gated.
SS-11 (Genre-Gated Lanes) exclusively owns opt-in activation of genre-specific
production lanes (competitive-multiplayer, modding/UGC, marketing, esports). Placing
an always-on capability there would violate SS-11's declared scope ("inactive lanes
impose zero constraints on the universal core") and would create a false implication
that online-services is opt-in. A new subsystem (SS-13) is the correct architectural
home. Expanding SS-01 (Engine-Adapter Protocol) was rejected: SS-01's scope is the
engine adapter protocol surface specifically; mixing engine and BaaS capability
surfaces would blur the seam boundaries that ADR-0004 establishes.

**Anti-lock-in thesis.** Nakama is the self-hostable reference target (Docker-in-CI
feasible; no BaaS lock-in). EOS and PlayFab follow the same adapter conformance path.
The online-services manifest schema declares per-capability fidelity grades using the
same model as all other seams (ADR-0004 v1.1).

**D-SEC convergence dimension.** Leaderboard integrity and entitlement integrity
fall under the existing D-SEC convergence dimension (server-authority invariants,
BC-7.11.*). The PO should reference BC-7.11.* rather than creating a duplicate
convergence dimension. The online-services conformance suite verifies that the BaaS
adapter enforces server-authority for leaderboard and entitlement operations; any
violations are reported through the D-SEC dimension (SS-06).

**Off-by-default for offline/single-player projects.** When `online_features: false`
in the project genre-profile, SS-13 is inactive and produces zero artifacts (mirror
of the inactive-lane invariant). The factory must not require BaaS configuration
for single-player or offline projects. The conformance suite must include a
`capabilities.identity: none` / `capabilities.leaderboards: none` path.

**Principal agents:** `backend-services-engineer` (role 58).

---

## BC to Subsystem Assignment Table

> This table is the authoritative resolution of all SS-TBD placeholders.
> A mechanical pass will apply `subsystem: SS-NN` to each BC file's frontmatter.
> BC directory names (ss-01/…ss-15/) are navigability aliases for CAP numbers only.
> Grand total: **190** (178 pre-CAP-015 + 12 CAP-015 BCs delivered by PO v1.6).
> CAP-015 BCs: BC-15.01.001..BC-15.11.001 (9 P0 + 3 P1) assigned to SS-13.

| BC ID Range | Count | Assigned Subsystem | Rationale |
|-------------|-------|--------------------|-----------|
| BC-1.01.001 – BC-1.15.001 | 34 | **SS-01** | CAP-001 = engine adapter protocol surface |
| BC-1.15.002 | 1 | **SS-01** | CAP-001; v1.1 add: never-author enforcement DI-010 |
| BC-2.02.001 – BC-2.02.006 | 6 | **SS-01** | CAP-002 = conformance gating (protocol quality gate) |
| BC-3.03.001 – BC-3.03.009 | 9 | **SS-02** | CAP-003 = deterministic replay harness |
| BC-4.01.001 – BC-4.06.001 | 15 | **SS-03** | CAP-004 = asset generation pipeline |
| BC-5.01.001 – BC-5.07.003 | 16 | **SS-04** | CAP-005 = multi-discipline production |
| BC-6.01.001 – BC-6.04.001 | 11 | **SS-05** | CAP-006 = simulation quality verification |
| BC-7.01.001 – BC-7.12.001 | 12 | **SS-06** | CAP-007 = convergence tracking engine (original 12) |
| BC-7.11.002 – BC-7.11.008 | 7 | **SS-06** | CAP-007; v1.2 add: server-authority invariant suite CWE-602 (dir: ss-07/) |
| BC-8.08.001 – BC-8.08.005 | 5 | **SS-07** | CAP-008 = playtest protocol |
| BC-9.01.001 – BC-9.06.002 | 11 | **SS-08** | CAP-009 = cert + distribution |
| BC-10.01.001 – BC-10.06.001 | 6 | **SS-08** | CAP-010 = compliance pipeline (co-owned with cert) |
| BC-11.01.001 – BC-11.04.002 | 13 | **SS-09** | CAP-011 = monetization ethics (original 13) |
| BC-11.03.006 | 1 | **SS-09** | CAP-011; v1.2 add: DP-007 predatory targeting enforcement (dir: ss-11/) |
| BC-12.12.001 – BC-12.12.009 | 9 | **SS-10** | CAP-012 = canon knowledge-base |
| BC-13.01.001 – BC-13.04.002 | 14 | **SS-11** | CAP-013 = genre-gated lanes (original 14) |
| BC-13.01.004 | 1 | **SS-11** | CAP-013; v1.1 add: NFT/web3 off-by-default DI-011 (dir: ss-13/) |
| BC-14.01.001 – BC-14.02.003 | 7 | **SS-12** | CAP-014 = XR platform seam |
| BC-15.01.001 – BC-15.11.001 | 12 | **SS-13** | CAP-015 = Online-Services Adapter (9 P0 + 3 P1; delivered by PO v1.6) |
| **TOTAL** | **190** | | 178 pre-CAP-015 + 12 CAP-015 BCs |

---

## Subsystem Grouping Rationale

**CAP-001 + CAP-002 grouped into SS-01.** Conformance gating (CAP-002) is structurally
part of the engine adapter protocol system, not a separate subsystem. The 6 conformance
BCs describe quality gates on the protocol layer, not a standalone service boundary.
Grouping reduces subsystem count from 14 to 12 without losing traceability.

**CAP-009 + CAP-010 grouped into SS-08.** Cert pre-flight (CAP-009) and compliance
pipeline (CAP-010) are co-owned by the same principal agents (`cert-owner`,
`compliance-officer`) and share the human-gated task surfacing pattern (DI-006).
Compliance artifacts (IARC, ratings submission manifest, AI disclosure) are prerequisites
for distribution. A single subsystem boundary is cleaner than two with overlapping owners.

**CAP-015 maps 1:1 to SS-13 (Online-Services Adapter).** Online-services is Tier-1
always-on and is NOT genre-gated, making SS-11 an incorrect home. A dedicated SS-13
preserves the seam boundary established by ADR-0004 v1.1 (each adapter seam has its
own subsystem: engine→SS-01, asset→SS-03, distribution→SS-08, XR→SS-12, online-services→SS-13).

**All other capabilities map 1:1 to a subsystem.**

---

## Directory → Subsystem Alias Table (I6 — Authoritative)

> **Purpose.** BC directory names (`ss-NN/`) are navigability aliases for CAP numbers,
> NOT subsystem IDs. This table is the authoritative resolution of the off-by-one that
> arises because two capability pairs share a subsystem (CAP-001+002 → SS-01;
> CAP-009+010 → SS-08). Always use this table (or the BC's own `subsystem:` frontmatter)
> to determine which SS-NN owns a BC. Never infer subsystem from directory name alone.
>
> **Anchoring rule.** BC frontmatter `subsystem:` field is the per-BC source of truth.
> This table is the aggregate reference. ARCH-INDEX.md §Subsystem Registry is the
> authoritative subsystem name and ID register. Any discrepancy between these three
> sources is a consistency defect to be fixed in the next architecture pass.

| BC Directory | CAP(s) in that directory | Resolves to Subsystem | Notes |
|-------------|--------------------------|----------------------|-------|
| `ss-01/` | CAP-001 | **SS-01** (Engine-Adapter Protocol) | |
| `ss-02/` | CAP-002 | **SS-01** (Engine-Adapter Protocol) | CAP-002 is conformance gating, co-owned in SS-01 |
| `ss-03/` | CAP-003 | **SS-02** (Deterministic Replay Harness) | |
| `ss-04/` | CAP-004 | **SS-03** (Asset Generation Pipeline) | |
| `ss-05/` | CAP-005 | **SS-04** (Multi-Discipline Production) | |
| `ss-06/` | CAP-006 | **SS-05** (Simulation Quality Verification) | |
| `ss-07/` | CAP-007 | **SS-06** (Convergence Tracking Engine) | BC-7.11.002..008 are in ss-07/ but subsystem=SS-06 |
| `ss-08/` | CAP-008 | **SS-07** (Playtest Protocol) | |
| `ss-09/` | CAP-009 | **SS-08** (Cert and Distribution) | |
| `ss-10/` | CAP-010 | **SS-08** (Cert and Distribution) | CAP-010 compliance pipeline is co-owned in SS-08 |
| `ss-11/` | CAP-011 | **SS-09** (Monetization Ethics) | BC-11.03.006 is in ss-11/ and subsystem=SS-09 ✓ |
| `ss-12/` | CAP-012 | **SS-10** (Canon Knowledge-Base) | |
| `ss-13/` | CAP-013 | **SS-11** (Genre-Gated Lanes) | BC-13.01.004 is in ss-13/ and subsystem=SS-11 ✓ |
| `ss-14/` | CAP-014 | **SS-12** (XR Platform Seam) | |
| `ss-15/` | CAP-015 | **SS-13** (Online-Services Adapter) | New v1.5; online-services is always-on Tier-1, not genre-gated |

**Key hazard rows** (where directory ≠ subsystem suffix):

| BC | Directory | Correct `subsystem:` field |
|----|-----------|---------------------------|
| BC-2.02.001–006 | `ss-02/` | `SS-01` |
| BC-7.11.001–008 | `ss-07/` | `SS-06` |
| BC-10.01.001–006 | `ss-10/` | `SS-08` |

---

## Subsystem Priority Summary

| Priority | Subsystems | BC Count |
|----------|-----------|----------|
| P0 (must ship v1) | SS-01, SS-02, SS-03, SS-04, SS-05, SS-06, SS-09 (partial), **SS-13 (partial)** | 126 (SS-01=41, SS-02=9, SS-03=13, SS-04=16, SS-05=11, SS-06=19, SS-09=8, **SS-13=9**) |
| P1 (ship v1) | SS-03 (partial), SS-07, SS-08, SS-09 (partial), SS-10, **SS-13 (partial)** | 42 (SS-03=2, SS-07=5, SS-08=17, SS-09=6, SS-10=9, **SS-13=3**) |
| P2 (v1-ready, opt-in/deferred) | SS-11, SS-12 | 22 (SS-11=15, SS-12=7) |
| **Total** | | **190** |
