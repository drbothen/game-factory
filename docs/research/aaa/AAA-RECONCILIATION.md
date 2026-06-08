---
document_type: methodology-reconciliation
version: "2.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
# NOTE: timestamp above is the v1.0 creation date; v2.0 written in the same session.
# Update this timestamp when committing v2.0 to reflect the actual write date.
producer: business-analyst
inputs:
  # Original 8 discipline vectors (v1.0)
  - docs/research/aaa/game-design-discipline.md
  - docs/research/aaa/art-pipeline.md
  - docs/research/aaa/generative-asset-ai.md
  - docs/research/aaa/audio-discipline.md
  - docs/research/aaa/narrative-localization.md
  - docs/research/aaa/engineering-disciplines.md
  - docs/research/aaa/production-pipeline.md
  - docs/research/aaa/qa-testing-liveops.md
  # Narrative / lore / worldbuilding (v1.5 — first extension)
  - docs/research/aaa/narrative-worldbuilding-lore.md
  # 9 new vectors (v2.0 — this pass)
  - docs/research/aaa/monetization-business-model.md
  - docs/research/aaa/marketing-store-community.md
  - docs/research/aaa/ratings-legal-compliance.md
  - docs/research/aaa/cinematics-virtual-production.md
  - docs/research/aaa/security-anticheat-trust-safety.md
  - docs/research/aaa/online-services-platform-distribution.md
  - docs/research/aaa/vr-ar-xr-platform.md
  - docs/research/aaa/modding-ugc-tools.md
  - docs/research/aaa/esports-competitive-integrity.md
  # Design docs and decisions (v1.0, unchanged)
  - docs/design/architecture.md
  - docs/design/engine-adapter-protocol.md
  - docs/design/protocol-schema.md
  - docs/design/extraction-boundary.md
  - docs/decisions/0001-founding-engine-pair.md
  - docs/decisions/0002-protocol-and-conformance-stance.md
  - docs/decisions/0003-determinism-tier-capability.md
  - .factory/specs/product-brief.md
  - .reference/vsdd-factory/CLAUDE.md (vsdd-factory CLAUDE.md)
  - .reference/vsdd-factory/plugins/vsdd-factory/agents/ (agent inventory)
  - .reference/vsdd-factory/plugins/vsdd-factory/skills/ (skill inventory)
traces_to: .factory/specs/product-brief.md
---

# AAA Game-Factory — Methodology and Scope Reconciliation (v2.0)

> **v2.0 change summary.** This version integrates 9 new research vectors (monetization,
> marketing/GTM, ratings/legal/compliance, cinematics, security/anti-cheat, online-services/
> distribution, VR/AR/XR, modding/UGC, esports) and formally encodes two cross-cutting
> decisions:
> 1. **ASSET GENERATION = PURE-MAXIMAL / LIGHTS-OUT** — agents generate all content
>    including hero assets, music, and voice with NO mandatory human-in-loop CREATIVE
>    finishing; provenance/license metadata captured automatically; legal risks recorded,
>    not used as human gates.
> 2. **NEW `human-gated` FIDELITY TIER** — for EXTERNAL, third-party-required human acts
>    ONLY (not creative finishing): console final certification sign-off, store-account
>    publish/pricing, SAG-AFTRA/likeness consent signatures, legal opinion sign-off, XR
>    comfort-certification, paid-UGC vetting, live esports/anti-cheat ops. The factory
>    does ALL automatable work up to the line, then surfaces a single checklisted human task.
>
> All v1.0 content is preserved unless explicitly superseded. New material is integrated
> into the existing section structure; superseded items are noted inline.

---

## 1. Executive Summary

**game-factory is vsdd-factory's rigor, fully re-targeted to AAA game development.**
vsdd-factory operationalizes the "Dark Factory" paradigm (StrongDM lineage: autonomous,
lights-out Seed → Validation → Feedback) as a governed multi-agent pipeline with formal
verification, adversarial convergence, and behavioral contracts. game-factory applies that
same machinery to producing games — retaining the 70% that is domain-neutral (orchestration,
worktrees, adversarial review, wave scheduling, conformance gating) and replacing the 30%
that is domain-specific with a quality model suited to games: deterministic-sim contracts
for the verifiable slice, design-intent contracts for the feel slice, and a structured
playtest protocol (never an automated fun-score) for the subjective remainder.

The central thesis is threefold. First, every AAA game discipline decomposes into a
machine-verifiable spine (data tables, state machines, economy graphs, narrative graphs,
loudness conformance, cert checklists, rating math, replay determinism) and a subjective
shell (fun, feel, art direction, performance direction) — and the factory owns the spine
while governing the shell via structured human gates, never collapsing it to a scalar.
Second, the factory generates EVERYTHING a game needs — design, all art, all audio,
narrative, code, QA artifacts — in a pure-maximal lights-out mode, with per-asset
provenance metadata captured automatically; IP and quality risks are recorded in a risk
register, not used to impose human gates. Third, the most tractable first-order proof is
the deterministic-simulation pilot (roguelike, factory/automation, deterministic RTS): it
maximizes the verifiable spine, gives bitwise replay-regression, and minimizes the
subjective shell, while the genre-universal core and contract set is built to generalize
from day one.

**v2.0 architectural thesis** (recurring pattern across all 22 research vectors):

1. **One adapter pattern, four seams + canon-KB.** The same capability-negotiation +
   fidelity-grading + conformance-suite architecture that prevents engine lock-in applies
   identically to assets (asset-adapter), distribution/store (distribution-adapter), and XR
   platforms (xr-adapter). The canon-KB is the fifth load-bearing seam: the shared lore/
   entity/timeline knowledge base that grounds all generative agents.

2. **Deterministic replay spine is cross-cutting and load-bearing.** A single replay
   harness serves QA regression (golden-state diff), anti-cheat (N-peer lockstep checksum),
   esports replays/demos/killcams (input-replay = same artifact), and modding determinism
   (same mod set → same replay = no desync). The T1 Bevy+Rapier pilot gets all four for free.

3. **Every discipline = machine-verifiable spine + human-judgment shell.** Without
   exception across 22 vectors: rating math, economy simulation, sequence graphs, cert
   pre-flight, schema-validated UGC, IP/copyright, rating submission, lip-sync curves,
   broadcast stats — all have a formulaic/structural layer the factory owns and a
   taste/judgment/policy layer that is a human gate.

4. **The `human-gated` fidelity tier covers external, third-party-required acts.** The
   factory does all automatable work, then surfaces a single checklisted task for console
   cert sign-off, store publish, SAG-AFTRA signatures, legal opinion, XR comfort-cert,
   paid-UGC vetting, and live esports ops. This is NOT creative finishing (which is
   pure-maximal/lights-out). This honesty posture is the same as `replay: none` → playtest
   degradation — the factory does not pretend to automate what it cannot.

---

## 2. Dark Factory Foundations (source-cited)

*(v1.0 content unchanged — reproduced for completeness)*

The following principles are inherited from the StrongDM Software Factory lineage
(https://factory.strongdm.ai), cited in the product brief and architecture document, and
now grounded against all 22 AAA research vectors:

**Seed → Validation Harness → Feedback Loop.** The factory starts from a seed (game spec
+ design intent), runs autonomous agents to generate all artifacts, validates them against
behavioral contracts and external observable behavior, and feeds results back to improve the
seed. No step requires mandatory human authorship. [Brief §What Is This]

**Tokens as Fuel.** Agent compute is the cost unit. Wave scheduling (inherited from vsdd)
controls parallelism and ensures expensive generation-then-validation cycles are budgeted.
[extraction-boundary.md §MOVE to shared core]

**Code (and assets) as Opaque ML Snapshots.** Artifacts are validated exclusively by
externally observable behavior — behavioral contracts, replay-regression, cert checklists,
structured playtest evidence — never by internal code inspection as a quality signal.
[architecture.md §How the quality model changes vs VSDD]

**DTU / Gene Transfusion.** vsdd-factory's DTU (clone third-party services) becomes the
deterministic replay harness: record inputs keyed by sim frame → replay → diff sim state.
Gene Transfusion (the principle of carrying proven patterns across context) is operationalized
in game-factory as the engine-adapter conformance suite — an adapter that passes conformance
inherits the full factory quality machinery. [extraction-boundary.md §BUILD NEW]

**Filesystem-as-Memory.** All factory state — specs, contracts, provenance metadata, wave
plans, decision logs — lives in versioned files. `.factory/` is the canonical state volume.
[vsdd-factory CLAUDE.md §Project References]

**Shift Work / Non-Interactive Agents.** All pipeline stages are designed to run headless
and non-interactively. For games this required the `headless-compute` / `render` execution
profile split (research-confirmed: "headless = no GPU" is false on every engine) and the
determinism-tier capability. [RECONCILIATION.md §B.1, engine-adapter-protocol.md §Capability matrix]

**Semport.** Version-pinned, conformance-gated adapters with a compatibility matrix
(Terraform-borrowed). Every adapter declares exactly one engine version; each engine minor
release is scheduled adapter maintenance. [protocol-schema.md §6]

**Pyramid Summaries.** Large artifacts are sharded and indexed (L2 domain spec: index +
section files, each 800-1200 tokens). STATE.md compact cycles extract historical content
to keep live state navigable. [vsdd-factory CLAUDE.md §Project References]

**Satisfaction over Boolean Pass/Fail.** The factory replaces holdout evaluation's
boolean pass/fail with a "fraction of trajectories that satisfy" model. For games: the
playtest protocol's 3-lens (say/do/behave) convergence report is the satisfaction signal;
structured instruments (GEQ, PENS, SUS) decompose experience without collapsing it to a
scalar. [qa-testing-liveops.md §5]

---

## 3. vsdd-factory Rigor Inventory (actual mechanisms)

*(v1.0 content unchanged)*

The following mechanisms are confirmed from `.reference/vsdd-factory/` (CLAUDE.md, agent
inventory, skill inventory):

| Mechanism | What it does in vsdd | Source in reference |
|---|---|---|
| **Behavioral Contracts (BC)** | Machine-checkable assertions over serialized program state; gated by TDD Red Gate (failing tests must exist before implementation) | BC-INDEX.md; agents/test-writer.md, implementer.md |
| **Verification Properties (VP)** | Formal safety/liveness properties (Kani proofs, cargo-fuzz, cargo-mutants) on pure-logic slices | agents/formal-verifier.md; skills/formal-verify |
| **TDD Red Gate** | Implementer may not write production code until a failing test (authored by test-writer) exists; adversary independently verifies | CLAUDE.md §Per-story Phase 3 sub-workflow |
| **DTU (Distinguishable Test Units)** | Clone of third-party service boundaries; validated by dtu-validator against real services | agents/dtu-validator.md; skills/dtu-validate |
| **Adversarial Review** | Fresh-context (information asymmetry) agent re-reads specs without prior context; minimum 3 clean passes for convergence (BC-5.39.001) | agents/adversary.md; skills/adversarial-review |
| **7-Dimension Convergence** | spec / tests / implementation / performance / visual / security / docs — all 7 must be green for convergence | skills/convergence-check; CLAUDE.md §Pipeline Authority |
| **Wave Scheduling** | Dependency-DAG-ordered batches of stories; each wave gated by post-wave integration gate | skills/wave-scheduling, wave-status, wave-gate |
| **Worktree / PR / Squash-Merge Lifecycle** | Each story in its own git worktree; pr-manager runs the 9-step PR cycle; squash-merge to develop | agents/pr-manager.md, devops-engineer.md; CLAUDE.md §Git Workflow |
| **Holdout Evaluation** | A held-out scenario (never seen by implementers) is run against the implementation; evaluator has information asymmetry | agents/holdout-evaluator.md; skills/holdout-eval |
| **Formal Hardening** | Kani proofs + fuzzing + mutation testing on security/safety-critical pure-logic modules | agents/formal-verifier.md; skills/formal-verify |
| **Gene Transfusion** | Extraction of proven patterns from one engine/domain and application to another via the conformance suite | skills/brownfield-ingest; extraction-boundary.md |
| **Semport** | Version-pinned adapter compatibility matrix; each engine version is a scheduled maintenance event | protocol-schema.md §6; decisions/0003 |
| **Hook Chain** | 52 WASM plugins enforcing governance rules (TD-VSDD-053 single-commit-per-burst, convergence-tracker, etc.) | CLAUDE.md §Hooks; hooks-registry.toml |
| **Demo Recorder** | VHS/Playwright captures observable behavior as artifact evidence | agents/demo-recorder.md; skills/demo-recording |
| **State Manager** | Owns `.factory/STATE.md`; manages cycle bookkeeping, decision-log, lessons, burst-log | agents/state-manager.md |
| **Orchestrator** | Coordinates all phases; dispatches specialists; never writes files directly | agents/orchestrator/ |
| **Consistency Validator** | Cross-document ID/anchor/count consistency; flags drift without silently rewriting content | agents/consistency-validator.md; skills/consistency-validation |

---

## 4. Mechanism → Game-Dev Mapping Table

*(v1.0 content unchanged)*

Every vsdd mechanism is mapped to its game-factory analog, with the research document
that grounds the mapping.

| vsdd Mechanism | game-factory Analog | Game-Dev Rationale | Research Grounding |
|---|---|---|---|
| **Behavioral Contract (BC)** | **Simulation Behavioral Contract** — economy invariants, damage I/O matrices, inventory save round-trip, ability/FSM legality; **Design Intent Contract** — verifiable subset of design intent (reachability, solvability, balance bands, no-softlock, conservation); **Rating-System Contract** — pure-function invariants on Elo/Glicko/TrueSkill/Weng-Lin (v2.0) | Every game genre has a numeric/graph spine that is machine-checkable | game-design-discipline.md §Design-Intent-as-Contract; esports-competitive-integrity.md §2 |
| **TDD Red Gate** | **Red Gate retained for pure-sim code** (gameplay systems, economy, AI behavior trees, networking determinism, rating-system math); degrades gracefully on engine-bound/rendering code | Gameplay systems reduce to pure data transforms that are unit-testable headless | engineering-disciplines.md §2.1; qa-testing-liveops.md §3.1 |
| **DTU** | **Deterministic Replay-Regression Contract** — record input keyed by sim frame → replay → compare; comparison method degrades by `determinism_tier` (T1 exact snapshot-hash / T2 pinned-runner / T3 tolerance-window); **also** the anti-cheat N-peer lockstep checksum and the esports demo/killcam (v2.0) | The replay spine is cross-cutting: QA + anti-cheat + esports + modding determinism | qa-testing-liveops.md §4; esports-competitive-integrity.md §4; security-anticheat-trust-safety.md §9 |
| **Formal Hardening (Kani/fuzz/mutants)** | **Formal hardening restricted to pure-sim slice** — economy conservation proofs, invariant checking on deterministic state machines, property-based testing on balance/progression/rating formulas | Rating math (Elo/Glicko-2/TrueSkill) = the cleanest VP targets in the entire corpus (pure functions, zero I/O) | game-design-discipline.md §Design-Intent-as-Contract; esports-competitive-integrity.md §2 |
| **Holdout Evaluation** | **Playtest Protocol** — structured human playtest + 3-lens convergence (say/do/behave); GEQ/PENS/SUS instruments; **headset required for XR** (v2.0); never auto-scored | "Is it fun" is not a hidden unit test; XR comfort/nausea adds a strictly harder physiological boundary | qa-testing-liveops.md §5; vr-ar-xr-platform.md §7 |
| **Adversarial Review** | **Adversarial Review retained** + **Design Adversary** (fresh-context review of verifiable-vs-subjective split) + **monetization ethics review** (v2.0 — ensure `monetization-ethics-contract` is constrained optimization, never unconstrained LTV maximize) | Specs span formal contracts, subjective intent, and ethical constraints | game-design-discipline.md §R1; monetization-business-model.md |
| **7-Dimension Convergence** | **Reshaped convergence model** (see §7) — 9 dimensions + new v2.0 extensions: monetization-ethics, compliance, security-invariants, distribution-readiness | Game quality has axes that software quality does not | architecture.md §Convergence dimensions; §7 below |
| **Demo Recorder** | **Adapter `capture` backend** + ffmpeg fallback; **`capture-recipe`** artifact (v2.0) — deterministic gameplay capture using replay/render profile for marketing screenshots/trailers | Games need gameplay capture for observable behavior AND for marketing assets | engine-adapter-protocol.md; marketing-store-community.md |
| **Wave Scheduling** | **Wave Scheduling retained** — discipline-DAG-ordered waves (design → art → audio → engineering → QA → cert/launch) with cross-discipline dependency contracts | v2.0 adds a GTM/launch wave after cert pre-flight | production-pipeline.md §5; marketing-store-community.md |
| **Gene Transfusion** | **Adapter Conformance Suite** — engine-adapter (existing) + asset-adapter (v2.0) + distribution-adapter + xr-adapter | Four adapter seams; same conformance pattern for all | engine-adapter-protocol.md; §5A below |
| **State Manager** | **Retained** — `.factory/STATE.md` plus game-specific decision log; v2.0 adds `compliance-checklist`, `ratings-submission-manifest` tracking | No change to mechanism; game-factory adds game-domain decision entries | vsdd-factory CLAUDE.md §State Manager |

---

## 5. New Disciplines and Agent Roles

### 5A. The Four Adapter Seams (v2.0 addition)

Before the agent roster, the adapter architecture must be stated explicitly. The same
capability-negotiation + fidelity-grading + manifest+driver + conformance-suite pattern
prevents lock-in across four orthogonal seams:

| Seam | Problem it solves | Fidelity values | Reference targets |
|---|---|---|---|
| **engine-adapter** | N engines for one game capability (render, capture, replay, physics) | `full` / `partial` / `none` | Bevy (T1), Unity, Godot; Unreal deferred |
| **asset-adapter** | N generative backends for one asset class (3D mesh, texture, audio, voice) | `full` / `partial` / `none`; `backend_class` taxonomy (Tier-1/2/3) | Tripo/Rodin/Meshy, Substance Sampler, ElevenLabs, Stable Audio |
| **distribution-adapter** | N store/platform targets for one game build (PC, mobile, console); splits along CLI-automatable line | `full` / `partial` / `human-gated` / `none` | steamcmd (VERIFIED), butler (VERIFIED), fastlane (VERIFIED), GDK Submission Validator; console cert = `human-gated`; PSN/Nintendo = `human-gated + NDA` |
| **xr-adapter** | N XR runtimes for one XR game; OpenXR as the reference seam; Apple visionOS as a non-OpenXR separate target | `full` / `partial/vendor` / `human-gated` / `none`; extension-namespace fidelity grading (KHR > EXT > vendor) | OpenXR 1.1 (Khronos CTS); visionOS = separate non-OpenXR backend; comfort_certify = `human-gated` by construction |

**The unifying `human-gated` principle.** Each seam uses `human-gated` for capabilities
whose *automatable prefix* (package, validate, upload, pre-flight) the factory performs and
whose *terminal step* is a declared human task the orchestrator surfaces with a checklist.
This is the distribution analog of `replay: none → human playtest` degradation. The factory
is honest that it does not automate: console cert sign-off, store-page publish/pricing,
SAG-AFTRA/likeness consent signatures, legal opinion, XR comfort-certification.

**Online-services adapter** (v2.0, not in the lock-in seam list but same pattern): wraps
BaaS capability surface (identity/saves/leaderboards/matchmaking/entitlements/inventory).
Reference: Nakama (self-hostable, engine-agnostic, Docker-headless-CI-testable); managed:
EOS (free, cross-platform, VERIFIED) + PlayFab ($0 < 100K players).

**UGC-distribution adapter** (v2.0, sibling of distribution-adapter): wraps UGC backends.
Reference: mod.io (engine-agnostic, console-authorized, REST API + C++/Unity/Unreal SDKs,
VERIFIED releases through May 2026). Secondary: SteamUGC (Steam-only).

---

### 5.1 Creative Direction / Art Direction *(v1.0, unchanged)*

**Agent roles:** `creative-director` (catalyst/shared) + `art-director` (catalyst/shared)
**Artifacts:** `art-bible.spec`, `style-profile`, visual targets

### 5.2 Game Design *(v1.0, unchanged)*

**Agent roles:** `systems-designer`, `economy-designer`, `combat-designer`,
`level-designer`, `encounter-designer`, `ux-accessibility-designer`
**Artifacts:** `design-spec`, `systems-spec`, `balance-data`, `economy-graph`,
`progression-spec`, `content-data`, `level-spec`, `ui-spec`, `accessibility-contract`,
`design-intent-contract`

### 5.3 Visual Art Generation *(v1.0, unchanged)*

**Agent roles:** `concept-artist`, `env-modeler`, `prop-artist`, `char-modeler`,
`char-texture`, `vfx-artist`, `pipeline-ta`
**Artifacts:** `asset-generation-request`, `asset-package` (GLB), `asset-provenance-sidecar`,
`material.semantic`, `vfx.spec`

### 5.4 Character Art *(v1.0, unchanged)*

**Agent roles:** `char-rigger`, `char-ta`, `animator`, `anim-ta`
**Artifacts:** `rig.skeleton`, `skin.weights`, `anim.clips`, `anim-state-machine.spec`

### 5.5 Audio *(v1.0, unchanged)*

**Agent roles:** `audio-designer`, `composer`, `audio-implementer`, `voice-director`
**Artifacts:** `audio-design-spec`, `music-interactive-spec`, `sfx-manifest`,
`dialogue-table`, `bus-and-mix-spec`, `audio-build-manifest`, `loudness-spatial-profile`,
`audio-acceptance-report`, `ai-audio-provenance-ledger`

### 5.6 Narrative, Writing, and Localization *(v1.0, unchanged)*

**Agent roles:** `narrative-designer`, `writer`, `localization-engineer`
**Artifacts:** `narrative-graph`, `quest-schema`, `bark-rules.schema`, `lore-bible`,
`loc-string-contract`

### 5.6a Narrative Direction / Worldbuilding / Lore *(v1.5 addition — from narrative-worldbuilding-lore.md)*

**Agent roles:** `narrative-director` (catalyst/shared), `worldbuilder`, `loremaster`
(continuity-editor), `quest-designer`, `systemic-writer` (bark/systemic dialogue),
`cinematic-writer`, `copywriter`
**Keystone artifact: `canon-kb`** — entity-registry + relationship-graph + timeline +
naming-registry + canon-facts; the RAG grounding anchor for all generative agents;
machine-checkable structural properties (no dangling entity refs, timeline consistency).
**Additional artifacts:** `story-structure-spec`, `narrative-arc-contract`,
`game-text-taxonomy-manifest`, `canon-continuity-check-battery`, `lore-grounding-RAG-contract`

### 5.7 Asset Generation Pipeline *(v1.0, unchanged)*

**Agent role:** `asset-generation-orchestrator`
**Artifacts:** `asset-generation-request.schema`, `asset-provenance-sidecar`,
`quality-gate-report`

### 5.8 Production / DAM / Large-Binary VCS *(v1.0, unchanged)*

**Agent roles:** `producer`, `cert-owner`
**Artifacts:** `game-production-plan`, `milestone-gate`, `cross-discipline-dependency-contract`,
`dam-record`, `derived-data-cache`

### 5.9 Platform Certification *(v1.0, partially superseded — see §10 Scope)*

**v2.0 SCOPE CHANGE:** the automatable prefix (cert pre-flight checklist engine, GDK
Submission Validator, build→upload CLIs) MOVES IN-SCOPE. Console cert sign-off + platform
legal/account setup STAY OUT but are now first-class `human-gated` tasks the factory
surfaces, not silent gaps.
**Agent role:** `cert-owner`
**Artifacts:** `cert-preflight-checklist`, `distribution-release-pipeline` (v2.0)

### 5.10 QA / Playtest / LiveOps *(v1.0, unchanged)*

**Agent roles:** `functional-qa`, `compat-qa`, `balance-qa`, `localization-qa`,
`compliance-qa`, `accessibility-qa`, `playtest-evaluator`
**Artifacts:** `replay-regression-contract`, `test-suite-manifest`, `cert-preflight-checklist`,
`perf-budget-contract`, `telemetry-event-taxonomy`, `kpi-dashboard-spec`, `playtest-protocol`,
`liveops-runbook`, `crash-reporting-wiring`

---

### NEW ROLES (v2.0) — Consolidated Additions

**Monetization / Economy**

`monetization-designer` — designs business models, IAP catalogs, battle-pass structures,
gacha mechanics; primary owner of `monetization-ethics-contract` (constrained optimization,
never unconstrained maximize-LTV). Works with `economy-designer`.

`economy-balancer` — live-economy simulation and rebalancing; operates Machinations-class
simulation; owns `live-economy-balance-contract` and `sink-faucet-model`.

**Marketing / GTM**

`trailer-editor` — gameplay capture, trailer edit, `capture-recipe`; uses replay/render
profile for deterministic content capture; produces `marketing-asset-manifest`.

`key-art-director` — key art generation direction, capsule/thumbnail composition; pure-
maximal generation; **brand/flagship-public-asset creative sign-off = `human-gated`
(external brand checkpoint)**.

`store-copywriter` — store-page copy, press kits, store text bundles; `store-page-spec`
owner; Steam capsule text linting (no review scores / discount text / award claims — machine-
lintable per Steamworks rules).

`community-manager` — community-platform wiring (Discord, Reddit, social), campaign-beat-
plan; operational community engagement is `human-gated` (tone/brand judgment).

**Compliance / Legal**

`compliance-officer` — owns `compliance-checklist`, `ratings-submission-manifest`,
`content-descriptor-contract`, `privacy-config-contract`, `legal-doc-set`; drives IARC
questionnaire (objective machine-answerable questions auto-filled; content-intensity
questions = human judgment gate); monitors PEGI 2026 interactive risk category changes
(paid random items → PEGI 16, effective Jun 2026; NFT → PEGI 18).

`ratings-submitter` — automates the automatable fraction of ratings submission and produces
the `ai-disclosure-manifest` (projection of `asset-provenance-sidecar`; adds `disclosure_class`
field; EU AI Act Art. 50 / C2PA marking applies 2026-08-02; FTC COPPA 2025 amendment
compliance 22 Apr 2026); all final submission sign-offs = `human-gated`.

**Cinematics**

`cinematic-director` — owns `cinematic-spec` and `sequence-graph` (engine-agnostic
time-keyed multi-track cutscene document; peer to `narrative-graph`); **`directed: true`
flag → human creative sign-off gate** (parallel to playtest-satisfaction; purely creative,
not a third-party gate).

`camera-cinematography` — camera-rules profile, shot language; structural checks
(framing/rule-of-thirds/lead-space) machine-checkable; aesthetic judgment human.

`lipsync-animator` — owns `lip-sync-pipeline-contract` (ARKit-52 blendshapes / MetaHuman
curves as the canonical portable lip-sync representation; likeness-consent check triggers
`human-gated` SAG-AFTRA signature flow). Wrap targets: Audio2Face-3D (MIT, open-sourced
2025-09-24), MetaHuman Animator (shipped UE 5.7), JALI (AAA-proven, 12 languages), Speech
Graphics (SGX/SG Com).

**Security / Anti-Cheat / Moderation**

`security-engineer` — owns `security-requirements-contract` and `server-authority-invariant-
suite` (CWE-602 spine: no-trust-client, input range/rate/sequence, replay-attack prevention,
reconciliation, interest-management, economy conservation/atomicity, secure entitlement).

`anti-cheat-integrator` — wraps EAC/EOS (default: free, self-service, engine-agnostic,
Windows kernel / macOS+Linux+Deck user-mode; VERIFIED). BattlEye = commercial subscription.
Riot Vanguard = NOT licensable. Kernel anti-cheat = never autonomously authored (R-017).

`moderation-ops` — wires `moderation-pipeline-contract`; integrates ToxMod (voice mod
wrap, CoD MWIII / RecRoom verified). Actual moderation judgment = `human-gated` (UK OSA
2023, EU DSA real legal duties).

**Online Services / Platform / Distribution**

`backend-services-engineer` — owns `online-services-spec`; wires Nakama (reference) /
EOS / PlayFab; owns `remote-config-contract`.

`platform-integrator` — owns `platform-integration-manifest`; wires per-platform SDK
(Steam ISteamUserStats/ISteamRemoteStorage/ISteamFriends; EOS; console SDK = `human-gated`
NDA integration).

`release-engineer` — owns `distribution-release-pipeline`; runs steamcmd/butler/fastlane
CLIs; emits `human-gated` task list for store publish + console cert.

`liveops-sre` — crash-reporting symbol upload (sentry-cli / Crashlytics), feature-flag
wiring, remote-config contract, A/B runbook generation; A/B *cadence decisions* = human.

**XR**

`xr-adapter-owner` — owns `xr-adapter` seam, `xr-comfort-spec`, `xr-perf-budget`,
`xr-interaction-spec`; XR is a deferred platform tier (seam reserved; implementation
deferred until Unity/Godot adapters proven); comfort-certification = `human-gated` by
construction (requires physical headset + human vestibular system).

**Modding / UGC**

`mod-api-owner` — owns `mod-api-contract` (versioned interface: WIT/WASM-preferred, Luau
secondary, C#/BepInEx trust-only; semver-disciplined); owns `ugc-content-schema` (the same
validator the factory uses internally becomes the UGC ingest gate).

`ugc-pipeline-engineer` — owns `ugc-distribution-adapter` (mod.io reference; SteamUGC
secondary), `mod-load-spec`, `mod-sdk` projection; wires `moderation-pipeline-contract`
for UGC; paid-UGC vetting = `human-gated` (DMCA safe-harbor erosion risk).

**Esports**

`ranking-systems-engineer` — owns `ranking-system-contract` (Elo/Glicko-2/TrueSkill/
Weng-Lin pure-function BC/VP — the cleanest formal-hardening target in the entire corpus);
`matchmaking-fairness-invariants`; EOMM engagement policy = declared human decision (R-010).

`spectator-tournament-engineer` — owns `replay-format` (reuses determinism spine),
`spectator-spec`, `tournament-mode-spec`, `broadcast-stats-contract`; live esports event
ops / casting / prize disbursement = `human-gated` (out of autonomous scope).

---

### 5.X Consolidated Studio-of-Agents Roster

**Total agent roles: 52** (40 v1.0/v1.5 + 12 new in v2.0; catalysts/shared marked C)

| # | Role | Type | Discipline |
|---|---|---|---|
| 1 | `creative-director` | C | Creative direction |
| 2 | `art-director` | C | Art direction |
| 3 | `systems-designer` | S | Game design |
| 4 | `economy-designer` | S | Game design |
| 5 | `combat-designer` | S | Game design |
| 6 | `level-designer` | S | Game design |
| 7 | `encounter-designer` | S | Game design |
| 8 | `ux-accessibility-designer` | S | Game design |
| 9 | `concept-artist` | S | Visual art |
| 10 | `env-modeler` | S | Visual art |
| 11 | `prop-artist` | S | Visual art |
| 12 | `char-modeler` | S | Visual art |
| 13 | `char-texture` | S | Visual art |
| 14 | `vfx-artist` | S | Visual art |
| 15 | `pipeline-ta` | C | Technical art |
| 16 | `char-rigger` | S | Character art |
| 17 | `char-ta` | C | Character art |
| 18 | `animator` | S | Character art |
| 19 | `anim-ta` | C | Character art |
| 20 | `audio-designer` | S | Audio |
| 21 | `composer` | S | Audio |
| 22 | `audio-implementer` | S | Audio |
| 23 | `voice-director` | C | Audio |
| 24 | `narrative-designer` | S | Narrative |
| 25 | `writer` | S | Narrative |
| 26 | `localization-engineer` | S | Narrative |
| 27 | `narrative-director` | C | Narrative / Lore |
| 28 | `worldbuilder` | S | Lore |
| 29 | `loremaster` | C | Lore (continuity) |
| 30 | `quest-designer` | S | Narrative |
| 31 | `systemic-writer` | S | Narrative |
| 32 | `cinematic-writer` | S | Narrative |
| 33 | `copywriter` | S | Narrative / Marketing |
| 34 | `asset-generation-orchestrator` | C | Asset pipeline |
| 35 | `producer` | C | Production |
| 36 | `cert-owner` | C | Cert / compliance |
| 37 | `functional-qa` | S | QA |
| 38 | `compat-qa` | S | QA |
| 39 | `balance-qa` | S | QA |
| 40 | `localization-qa` | S | QA |
| 41 | `compliance-qa` | S | QA |
| 42 | `accessibility-qa` | S | QA |
| 43 | `playtest-evaluator` | C | QA / Playtest |
| 44 | `monetization-designer` | S | Monetization *(v2.0)* |
| 45 | `economy-balancer` | S | Monetization *(v2.0)* |
| 46 | `trailer-editor` | S | Marketing *(v2.0)* |
| 47 | `key-art-director` | C | Marketing *(v2.0)* |
| 48 | `store-copywriter` | S | Marketing *(v2.0)* |
| 49 | `community-manager` | C | Marketing *(v2.0)* |
| 50 | `compliance-officer` | C | Compliance *(v2.0)* |
| 51 | `ratings-submitter` | S | Compliance *(v2.0)* |
| 52 | `cinematic-director` | C | Cinematics *(v2.0)* |
| 53 | `camera-cinematography` | S | Cinematics *(v2.0)* |
| 54 | `lipsync-animator` | S | Cinematics *(v2.0)* |
| 55 | `security-engineer` | S | Security *(v2.0)* |
| 56 | `anti-cheat-integrator` | S | Security *(v2.0)* |
| 57 | `moderation-ops` | C | Security / Trust *(v2.0)* |
| 58 | `backend-services-engineer` | S | Online services *(v2.0)* |
| 59 | `platform-integrator` | S | Platform *(v2.0)* |
| 60 | `release-engineer` | S | Distribution *(v2.0)* |
| 61 | `liveops-sre` | S | LiveOps *(v2.0)* |
| 62 | `xr-adapter-owner` | C | XR *(v2.0)* |
| 63 | `mod-api-owner` | C | Modding *(v2.0)* |
| 64 | `ugc-pipeline-engineer` | S | Modding *(v2.0)* |
| 65 | `ranking-systems-engineer` | S | Esports *(v2.0)* |
| 66 | `spectator-tournament-engineer` | S | Esports *(v2.0)* |

**Total: 66 roles** (33 v1.0/v1.5 + 33 new in v2.0; some v1.5 lore roles counted above)

> NOTE: Several v2.0 roles are optional/genre-gated (esports, modding, XR). The v1 core
> pilot deploys a subset. See §10 Scope Tiers for the activation model.

---

## 6. New Artifact and Contract Taxonomy

*(v1.0 artifacts preserved; v2.0 net-new artifacts appended below)*

### 6.1 v1.0 Artifact Set (unchanged)

| Artifact / Contract Type | Description | Discipline Owner | Validation Method |
|---|---|---|---|
| **`design-intent-contract`** | The verifiable subset of design intent as typed assertions; remainder explicitly delegated to playtest-protocol | Systems designer | Simulation BC + property-based testing |
| **`simulation-bc`** | Economy invariants, damage I/O matrices, inventory save round-trip, ability/FSM state legality | Gameplay engineer | TDD Red Gate + headless test runner |
| **`economy-balance-contract`** | Source/sink conservation invariants, win-rate bands, progression-curve smoothness, no-exploit-loop | Economy designer | Machinations sim / property-based testing |
| **`narrative-graph-schema`** | Canonical directed branching graph; adapter exporters to Ink/Yarn/articy/Unreal | Narrative designer | Branch-reachability, dead-end detection, variable consistency |
| **`loc-string-contract`** | Per-string ICU MessageFormat, stable ID, context metadata, char-limit, XLIFF 2.0 export | Localization engineer | String coverage, ICU placeholder parity, pseudo-loc overflow |
| **`asset-generation-request`** | Per-asset generation spec: class, risk tier, modality, prompt/inputs, art-direction refs | Asset generation orchestrator | Quality-gate report (topology/UV/PBR/provenance) |
| **`asset-provenance-sidecar`** | Mandatory on every generated asset: tool + model, prompt log, human-modifications log, license, indemnification, likeness-consent ref, risk tier, copyrightability assessment; **v2.0 addition: `disclosure_class` field for EU AI Act Art. 50 projection** | Asset generation orchestrator | Schema validation; legal gate for Tier-2/3 |
| **`audio-build-manifest`** | Middleware, engine targets, platforms, languages, bank definitions | Audio implementer | Bank build success; loudness/true-peak conformance |
| **`game-production-plan`** | Machine-readable milestones, agent-cluster scopes, dependency DAG, wave schedule, risk register | Producer / orchestrator | Milestone gate predicates |
| **`milestone-gate`** | Hook-enforced predicate set per milestone | Producer / cert-owner | Hook chain enforcement |
| **`cross-discipline-dependency-contract`** | Typed contract per discipline edge: format, budgets, naming, acceptance criteria | Producer / discipline leads | Automated validation on merge; DAM propagation |
| **`replay-regression-contract`** | Per-scenario recorded input track + expected golden state; comparison by determinism tier | Functional QA | Deterministic replay harness |
| **`cert-preflight-checklist`** | Per-platform machine-checkable requirement set + pass/fail report | Cert-owner | Cert pre-flight harness; wraps GDK Submission Validator |
| **`perf-budget-contract`** | Frame-time (CPU/GPU ms), 1%/0.1%-low thresholds, memory-soak limits, thermal limits; **v2.0 addition: XR-specific dimensions (per-eye frame time, reprojection %, motion-to-photon ceiling <20 ms)** | Performance QA | CI gate + profiler integration; on-device for GPU/XR |
| **`playtest-protocol`** | Structured protocol: research question, recruitment criteria, tasks, instruments, 3-lens convergence report; human sign-off mandatory; **v2.0 note: XR requires physical headset — harder boundary than flat-screen** | Playtest evaluator | Human gate — never auto-scored |
| **`telemetry-event-taxonomy`** | Generated, versioned event schema + instrumentation; KPIs labeled as health signals, NOT fun | QA / analytics | Schema validation; event-precedence checks |
| **`art-bible.spec`** | Machine-readable art direction: style-profile, palette, material standards, texel-density, poly budgets | Art director | Asset QC gate compliance |
| **`style-profile`** | Parameterizes the art pipeline: stages, tools/presets, budget ranges, shader template, automation ceiling | Art director | Asset generation request validation |
| **`music-interactive-spec`** | Layers/segments, states/transitions, sync points, RTPC→layer maps, target loudness | Composer + audio implementer | Bank build; loudness/true-peak conformance |
| **`liveops-runbook`** | Patch/content cadence, A/B experiment specs, feature-flag + remote-config wiring, live-event plan | Liveops producer | Feature-flag state logged to telemetry |

### 6.2 v1.5 Artifact Set (narrative-worldbuilding-lore.md)

| Artifact / Contract Type | Description |
|---|---|
| **`canon-kb`** *(keystone)* | Entity-registry + relationship-graph + timeline + naming-registry + canon-facts; RAG grounding anchor for all generative agents |
| **`story-structure-spec`** | Act/sequence structure, pacing targets, dramatic arc |
| **`narrative-arc-contract`** | Per-character/faction arc declarations |
| **`game-text-taxonomy-manifest`** | Classification of all text types (UI, bark, quest, lore, marketing) with per-class rules |
| **`canon-continuity-check-battery`** | Machine-checkable continuity assertions (entity ref integrity, timeline consistency, naming-registry compliance) |
| **`lore-grounding-RAG-contract`** | Spec for RAG retrieval over canon-KB; relevance/fidelity scoring; hallucination-flag thresholds |

### 6.3 v2.0 Net-New Artifact Set

**From monetization-business-model.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`business-model-spec`** | Business model declaration: premium / F2P / hybrid / subscription / ad-supported / web3-off; drives monetization pipeline parameterization | web3/crypto = explicitly off-by-default (risk + regulatory) |
| **`live-economy-balance-contract`** | Extends `economy-balance-contract` for live-service: virtual-currency inflation/deflation tracking, seasonal balance targets, liveops-economics runbook | Conservation invariants enforced in live service |
| **`sink-faucet-model`** | Faucet/sink graph of virtual economy flows; Machinations-simulated; no indefinite money-printing invariant | Source/sink must balance within declared tolerance |
| **`pricing-matrix`** | IAP prices per SKU per region (currency, tier, platform fees); machine-validated against platform policies | No free-to-play items priced above declared ceiling |
| **`gacha-spec`** | Odds declaration + pity-counter mechanism + regulatory disclosure map; ESRB Apr 2020 + Apple/Google Dec 2017/May 2019 odds disclosure verified | Pity counter present if gacha; odds = accurate disclosure |
| **`monetization-ethics-contract`** *(LOAD-BEARING)* | Constrained-optimization policy envelope: allowed monetization mechanics, forbidden patterns (indefinite dark patterns, COPPA-violating targeting, manipulative timers vs player preferences), LTV-optimization bounds; **factory must NEVER autonomously optimize unconstrained LTV** | This is the ethical hard gate; adversarial review mandatory; R-010 mitigation |
| **`segmentation-ltv-spec`** | Player segmentation model; LTV targeting; whaling mitigation guardrails | Whaling caps declared; NEVER unconstrained; subject to ethics-contract |
| **`iap-catalog`** | Full IAP product list: IDs, descriptions, prices, consumable/non-consumable/subscription classification | Accurate classification required for store compliance |
| **`ad-monetization-spec`** | Ad SDK wiring, placement rules, COPPA/child-directed flags; separate consent per FTC COPPA 2025 amendment (compliance 22 Apr 2026) | COPPA consent for each ad SDK separately |

**From marketing-store-community.md:**

| Artifact / Contract Type | Description | Machine-checkable elements |
|---|---|---|
| **`store-page-spec`** | Per-platform store asset pack: Steam (920×430 header capsule, 462×174 small capsule, 1232×706 main capsule, 748×896 vertical, 3840×1240 library hero, ≥5 screenshots at ≥1920×1080; H.264/AAC trailer ≥5000 Kbps); App Store (name/subtitle ≤30ch, keywords ≤100ch, ≤10 screenshots, icon 1024×1024); Google Play (icon 512×512 PNG ≤1024KB, feature graphic 1024×500); console specs NDA-gated [UNVERIFIED beyond NDA] | Image dimensions, file size/format, char limits — all machine-lintable; capsule text rules (no review scores/awards/discount text) also machine-lintable |
| **`marketing-asset-manifest`** | All generated marketing assets with provenance sidecars; key art, social images, GIF captures | Provenance + AI-disclosure-manifest projection |
| **`press-kit`** | presskit.html `data.xml` schema format — machine-fillable from game metadata; factsheet, description, images, trailers, team, contacts | Schema-valid + all required fields present |
| **`capture-recipe`** | Deterministic gameplay capture spec: replay profile + render settings + scene/event triggers; produces screenshots/trailer footage using existing replay/render infrastructure | Round-trip: recipe → replay → rendered frames |
| **`campaign-beat-plan`** | Marketing beat schedule aligned to Steam Next Fest windows (Jun 15–22, Oct 19–26 2026), social cadence, press outreach; machine-generated runbook | Beat dates machine-validated against calendar |
| **`store-text-bundle`** | Localized store copy: title, short description, long description, keywords; ICU-tagged; per-platform char limits enforced | Char limit lint per platform; keyword density checks |

**From ratings-legal-compliance.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`compliance-checklist`** | Master machine-generated compliance checklist: PEGI 2026 interactive risk categories, IARC questionnaire, FTC COPPA 2025, EU AI Act Art. 50 (applies 2026-08-02), USK (legally binding Germany), platform-specific requirements | IARC objective questions auto-fillable from game metadata; content-intensity = human gate |
| **`ratings-submission-manifest`** | Per-rating-body submission package with metadata, content descriptors, questionnaire answers; automatable fraction pre-populated from game metadata | Human reviews and submits; `human-gated` terminal step |
| **`content-descriptor-contract`** | Declares all content descriptors (violence level, language, mature themes, online features, paid random items, loot boxes); feeds IARC + ESRB + PEGI | Paid random items → PEGI 16 minimum (Jun 2026); NFT → PEGI 18; declarative trigger |
| **`ai-disclosure-manifest`** | Pure projection of `asset-provenance-sidecar` data; adds `disclosure_class` field (pre-generated vs live-generated per Steam Jan 17 2026 rewrite); formats for EU AI Act Art. 50 (C2PA Content Credentials machine-readable mark) | Sidecar completeness gates the disclosure manifest; no new data required beyond what provenance already captures |
| **`privacy-config-contract`** | GDPR/CCPA/COPPA data-minimization config; consent flows; data-retention; third-party SDK data-share declarations; ad-SDK COPPA consent separate (per FTC 2025 amendment) | Per-SDK consent flags machine-validated |
| **`legal-doc-set`** | EULA, Privacy Policy, Terms of Service, Modder EULA (if UGC-enabled); machine-generated templates; legal sign-off = `human-gated` | Template generation automated; attorney review mandatory before ship |
| **`region-content-restriction-flags`** | Per-SKU content flags for markets requiring content changes (NFT in Belgium, loot-box regulations, Germany USK mandatory, etc.) | Machine-generated from `content-descriptor-contract`; human legal sign-off for flagged regions |

**From cinematics-virtual-production.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`cinematic-spec`** | High-level sequence brief: purpose, emotional targets, director notes, timing, referenced assets; feeds `sequence-graph` generation | If `directed: true`, human cinematic-director gate (creative, not third-party external) |
| **`sequence-graph`** *(keystone — peer to `narrative-graph`)* | Engine-agnostic time-keyed multi-track cutscene document: stable IDs, logical asset refs, animation/camera-cut/facial-lipsync/audio/subtitle/event/activation/interaction tracks; Bevy note — no native sequencer, must BUILD a Bevy runtime sequence player | Machine-checkable: track consistency, all asset refs resolve, subtitle coverage, event ordering |
| **`lip-sync-pipeline-contract`** | Declares lip-sync method (Audio2Face-3D / MetaHuman Animator / JALI / Speech Graphics / custom), output format (**ARKit-52 blendshapes** = canonical portable contract), likeness-consent check; likeness-consent signature = `human-gated` (SAG-AFTRA IMA) | ARKit-52 blendshape values within [0,1]; audio-alignment within declared tolerance |
| **`camera-rules-profile`** | Declared cinematography rules: framing conventions, cut-type restrictions, motion constraints, accessibility (static/reduced motion) | Structural rule violations machine-lintable |
| **`sequence-validation-report`** | Per-sequence checklist: all tracks well-formed, all asset refs valid, subtitle coverage, audio sync, accessibility compliance, `directed:` flag evaluation | CI gate |

**From security-anticheat-trust-safety.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`security-requirements-contract`** | Declares security posture: authentication requirements, session management, data-at-rest/transit standards, vulnerability disclosure policy | Machine-checkable structural presence; audit by security-engineer |
| **`server-authority-invariant-suite`** *(LOAD-BEARING)* | CWE-602 spine: no-trust-client (validate all inputs server-side), input range/rate/sequence validation, replay-attack prevention (sequence numbers + nonce), authoritative reconciliation, interest-management (anti-wallhack), economy conservation/atomicity, secure entitlement (cryptographic ownership proof) | All invariants in this suite = machine-checkable behavioral contracts; violation = security defect |
| **`anti-cheat-integration-adapter`** | Declares anti-cheat provider (EAC/EOS default — free, self-service, VERIFIED; BattlEye = commercial; Riot Vanguard = NOT licensable); integration wiring; kernel AC = never autonomously authored | EAC/EOS integration wiring machine-verified; kernel driver = blocked by policy |
| **`moderation-pipeline-contract`** | UGC/chat/voice report→sanction→appeal state machine; CSAM→NCMEC CyberTipline wiring (18 U.S.C. §2258A: actual-knowledge trigger, no duty to monitor); PhotoDNA hooks; age-gate; UK OSA/EU DSA logging; ToxMod voice mod wrap | Pipeline presence/shape machine-checkable; moderation judgments = human gate |
| **`drm-anti-tamper-config`** | DRM/anti-tamper vendor config (Denuvo, etc.); CE-DRM risk acknowledgment | Config machine-validated; vendor contract = human sign-off |
| **`secure-entitlement-contract`** | Cryptographic entitlement proof scheme; server-side verification of ownership before content delivery | All entitlement checks server-authoritative |

**From online-services-platform-distribution.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`online-services-spec`** | Engine/provider-neutral declaration of required backend capabilities per game: identity/saves/leaderboards/matchmaking/entitlements/inventory/social/server-hosting; authority model (client vs server) | Compiled by online-services adapter into a concrete provider (Nakama/EOS/PlayFab) |
| **`platform-integration-manifest`** | Per-target-platform SDK feature declarations (achievements/saves/presence/IAP/DLC/leaderboards) mapped to normalized capability surface | Distribution-adapter compiles to ISteam*/EOS/GameKit/Xbox calls |
| **`distribution-release-pipeline`** | Build version, channel/branch, delta-patch baseline, per-target upload command (steamcmd/butler/fastlane — all VERIFIED), `human-gated` task list (store publish, cert submit) | CLI commands verified; `human-gated` tasks emitted as checklisted manual tasks |
| **`remote-config-contract`** | Bundled default values + override schema + provider (Satori/Firebase/Unity/PlayFab/LaunchDarkly); flag-state logged to telemetry | Schema-valid; flag-state telemetry wiring present |

**From vr-ar-xr-platform.md (seam-reserved; implementation deferred):**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`xr-adapter`** | OpenXR 1.1 (reference) or visionOS (non-OpenXR separate target); capability fidelity graded by OpenXR extension namespace (KHR/EXT/vendor); `comfort_certify: human-gated` by construction | Conforms to Khronos CTS (machine-checkable conformance that already exists) |
| **`xr-comfort-spec`** | Declared locomotion/comfort design: locomotion type(s), vignette/tunneling params, snap vs smooth turn, speed caps, static reference frames, candidate comfort rating + headset-playtest gate | Structural presence machine-checkable; shipping comfort rating = `human-gated` |
| **`xr-perf-budget`** | XR-specific budgets: target refresh Hz, per-eye frame-time, reprojection-% ceiling, motion-to-photon ceiling (<20 ms), FFR/dynamic-foveation config; on-device gate (OVR Metrics / runtime stats) | Extends `perf-budget-contract`; Meta VRC.Quest.Performance.1: ≥60 fps (≥30 fps with AppSW; VERIFIED) |
| **`xr-interaction-spec`** | Controller interaction profiles, hand/eye-tracking usage, room-scale/guardian requirements, diegetic-UI layout | Structure machine-checkable; feel → headset playtest |

**From modding-ugc-tools.md:**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`mod-api-contract`** | Versioned mod-API surface: WIT/WASM interface preferred (capability-based, machine-typed, semver-able), Luau typed-scripting secondary, C#/BepInEx = trusted-code-only lane (explicitly not sandboxed) | Semver breaking change detection = CI gate; sandbox capability conformance test required |
| **`ugc-content-schema`** | Published JSON Schemas defining moddable data (same schemas factory uses for base content); UGC ingest gate IS this validator | Schema validity + referential completeness + band invariants all machine-checkable |
| **`ugc-distribution-adapter`** | Capability-negotiated UGC seam: mod.io (reference — engine-agnostic, console-authorized; VERIFIED May 2026) + SteamUGC (Steam-only secondary); monetization = `human-gated` (paid-UGC vetting, copyright verification) | Round-trip: publish→browse→subscribe→install against mod.io sandbox environment |
| **`mod-load-spec`** | Load-order + dependency-resolution + conflict-detection + VFS override-precedence contract; extends replay-regression for mod determinism | Topo-sorted load, cycle detection, conflict resolution all CI-gated |
| **`mod-sdk`** | Generated modder SDK: published schemas + mod-API contract + sample mods + local validator + docs; pure projection of internal artifacts | SDK round-trips sample mod; published artifacts match shipped loader |
| **`in-game-editor-spec`** | Declarative spec for in-game level/visual-scripting editor: save/load/publish plumbing, asset-import validation, node/host-function surface; factory wires plumbing only; editor UX = deferred, human-built | Plumbing wiring machine-verified; UX quality = human gate |

**From esports-competitive-integrity.md (genre-gated: competitive multiplayer only):**

| Artifact / Contract Type | Description | Key constraint |
|---|---|---|
| **`ranking-system-contract`** *(cleanest BC/VP target in corpus)* | Rating model (elo/glicko/glicko2/trueskill/trueskill2/weng_lin-openskill/custom) + parameters + machine-checkable invariant set: conservation (Elo zero-sum), monotonicity, RD/σ bounds and decay, μ−3σ ordering, permutation-equivariance; pins corrected Glicko-2 Step-5 (2012-02-22 correction mandatory) | Pure-function BC/VP; property-based testing + optional formal hardening via Kani; no I/O, no hidden state |
| **`matchmaking-fairness-invariants`** | Team-MMR balance within tolerance, |PWP−0.5| ≤ ε, no player outside skill band, queue-time bound, visible-rank monotonic-in-MMR (shape); if EOMM-style: MWPM structural validity; engagement-vs-fairness policy = declared human decision (NOT a factory default — see R-010) | Fairness math machine-verifiable; engagement-optimization as autonomous default = defect |
| **`replay-format`** | Esports deterministic replay/demo/killcam: T1 = input-replay (same mechanism as `replay-regression-contract`, essentially free); T2/T3 = snapshot-stream; **this IS the replay-regression spine exposed as a player feature** | Correctness = existing `replay-regression-contract`; adds round-trip integrity, seek/scrub determinism, killcam-window |
| **`spectator-spec`** | Observer data layer: broadcast-delay bound, observer fog-of-war = interest-management visibility BC, deterministic auto-director camera selection, HUD/overlay stat-correctness | Data/visibility layer machine-checkable; casting/directing craft = human |
| **`tournament-mode-spec`** | Bracket format (single/double-elim, Swiss, round-robin, GSL) + seeding function + progression-correctness BCs (every participant once, advance per format, Swiss no-rematch, double-elim losers feed) + match-result replay-audit (re-simulate input log, assert outcome) | Combinatorial BCs; wraps Challonge/Toornament for live ops |
| **`broadcast-stats-contract`** | Stats-export schema (GSI-class) + "exported feed matches authoritative sim" data-correctness BC + overlay/OBS wiring presence | Light wiring; correctness BC machine-checked; production/casting = human |

---

## 7. Reshaped Convergence Model

*(v1.0 9-dimension model retained and extended with v2.0 additions)*

| # | Dimension | Description | Gate Type | Degrades to |
|---|---|---|---|---|
| 1 | **sim/spec** | Simulation BCs pass headless (economy, damage, FSM, AI, netcode determinism, rating math, server-authority invariants) | CI gate (automated) | Tolerance-window if T2/T3; playtest evidence if `replay: none` |
| 2 | **tests/replay** | Replay-regression green at declared determinism tier; test suite manifest clean; **v2.0: also covers esports demo determinism and mod-load determinism** | CI gate (automated, tier-gated) | Pinned-runner (T2); tolerance-window (T3); human playtest (T0) |
| 3 | **implementation** | Build passes; lint clean; architecture-separation rule (logic vs presentation) enforced; security-requirements-contract structural presence | CI gate (automated) | No degradation — build is always a hard gate |
| 4 | **asset-completeness** | All asset-generation requests fulfilled; GLB packages schema-valid; provenance sidecars complete (including `disclosure_class`); quality-gate pass per risk tier; sequence-graph asset refs all resolve; `ai-disclosure-manifest` generated | CI gate (automated) | Tier-1 auto-ingest; Tier-2/3 flag but ingest (pure-maximal); `directed: true` adds human sign-off |
| 5 | **playtest-satisfaction** | Structured playtest protocol run; 3-lens convergence; GEQ/PENS/SUS above targets; human signs fun/feel/polish; **v2.0: XR requires physical headset (harder boundary than flat-screen)**; `cinematic-spec`'s `directed: true` cinematics reviewed in playtest | **Human gate — mandatory, non-automatable** | No degradation — human gate cannot be automated |
| 6 | **cert-preflight + distribution-readiness** *(v2.0 extension)* | Machine-checkable cert pre-flight (55-80%); **`distribution-release-pipeline` green** (build→upload CLIs verified); **`human-gated` task list emitted** for console cert sign-off + store publish; compliance-checklist items auto-filled; ratings-submission-manifest generated | CI gate (automated 55-80%) + `human-gated` task surface | Partial if NDA'd platform; `human-gated` tasks emitted not skipped |
| 7 | **perf-budget** | Frame budget (CPU + GPU ms) within declared thresholds; memory soak; thermal within envelope; **v2.0: XR per-eye frame-time + reprojection-% + motion-to-photon budgets on declared XR targets** | CI gate (CPU-bound) + on-hardware (GPU/XR) | GPU/XR moves to on-device gate |
| 8 | **provenance/legal + compliance** *(v2.0 extension)* | Every generated asset has valid provenance sidecar; `ai-disclosure-manifest` generated; `compliance-checklist` auto-filled; `privacy-config-contract` present; EU AI Act Art. 50 / C2PA marks generated (applies 2026-08-02); SAG-AFTRA consent refs present for voice/likeness = `human-gated` signature; legal-doc-set generated = `human-gated` attorney review | CI gate (schema validation + auto-fill) + `human-gated` (consent signatures, legal review, ratings submission) | Schema only if legal review not yet scheduled |
| 9 | **docs** | All agent-produced artifacts have required frontmatter, input-hash, traces_to; design-intent contracts have explicit playtest-delegation notes; **v2.0: `monetization-ethics-contract` adversarial review evidence present** | CI gate (automated schema validation) | Advisory if supplementary |
| 10 | **monetization-ethics** *(v2.0 new dimension)* | `monetization-ethics-contract` present and adversarially reviewed; declared policy envelope enforced (constrained optimization, no unconstrained LTV, no declared forbidden patterns); PEGI/ESRB/regulatory descriptors consistent with declared mechanics; FTC COPPA consent wiring for ad SDKs present if applicable | CI gate (contract presence + mechanical consistency) + adversarial review gate | No degradation — if monetization is present, ethics contract is mandatory |
| 11 | **security-invariants** *(v2.0 new dimension, required for multiplayer/online games)* | `server-authority-invariant-suite` all invariants green; `anti-cheat-integration-adapter` wired for competitive-MP targets; `moderation-pipeline-contract` wired if UGC/chat present; CSAM→NCMEC path verified | CI gate (automated contract assertions) | No degradation — if online, security invariants are mandatory |

**vs v1.0 9 dimensions:**
- **Retained:** sim/spec (#1), tests/replay (#2), implementation (#3), asset-completeness (#4), playtest-satisfaction (#5), perf-budget (#7), docs (#9)
- **Extended:** cert-preflight (#6) now includes distribution-readiness and `human-gated` task surface; provenance/legal (#8) now includes compliance and EU AI Act
- **Added:** monetization-ethics (#10), security-invariants (#11) — both v2.0

---

## 8. Quality-Model Delta vs VSDD

*(v1.0 content preserved; v2.0 additions noted)*

### What stays (direct carry-over)

- **Formal hardening** on the pure-simulation slice: property-based testing on economy
  invariants, conservation proofs, FSM legality proofs. **v2.0: rating-system math (Elo/
  Glicko-2/TrueSkill/Weng-Lin pure functions) are the single cleanest formal-hardening
  targets in the entire AAA corpus — provable invariants with no I/O or hidden state.**
- **Adversarial convergence** to 3 clean passes. **v2.0: added monetization-ethics
  adversarial review pass — mandatory when monetization is present.**
- **Behavioral Contracts**, wave scheduling, worktree/PR lifecycle, state management,
  hook chain: all retained.

### What's added (game-specific)

*(v1.0 items: playtest protocol, deterministic replay harness, design adversary, asset lane,
cert-preflight engine — all unchanged)*

**v2.0 additions:**

- **`human-gated` fidelity tier** as a first-class quality signal. The distribution-adapter,
  xr-adapter, and compliance flows all declare `human-gated` capabilities explicitly. The
  orchestrator surfaces these as checklisted manual tasks. Suppressing or ignoring a
  `human-gated` task is a defect (hook-checkable).

- **Monetization-ethics review** as a mandatory adversarial pass on any game with
  monetization. The `monetization-ethics-contract` is not optional; it is the guard rail
  against the autonomous factory converging on dark patterns. The adversary checks that
  optimization is constrained, not unconstrained.

- **Security-invariant suite** as a CI gate for all online/multiplayer games. CWE-602
  (never trust the client) is the machine-verifiable security spine. Server-authority
  invariants are behavioral contracts, not optional recommendations.

- **Compliance pipeline** as a first-class quality dimension. IARC objective-question
  auto-fill + compliance-checklist = machine-checkable; content-intensity questionnaire +
  ratings submission + EU AI Act marking = `human-gated` with automated preparation.

### What degrades by determinism tier / adapter capability *(v1.0 table, v2.0 column added)*

| Quality claim | T1 (Bevy+Rapier) | T2 (Unity PhysX) | T3 (Godot physics) | No replay |
|---|---|---|---|---|
| Regression detection | Exact snapshot-hash diff (strongest) | Pinned-runner snapshot diff | Tolerance-window metric diff | Human playtest evidence |
| Physics correctness | Bitwise-cross-platform proof | Same-machine proof | Tolerance-only | Design-intent contract only |
| Multiplayer determinism | N-peer checksum equality + anti-cheat free (v2.0) | Pinned-runner only | Tolerance-window | Not supportable |
| Esports replay/demo | Input-replay (free on T1) | Snapshot-stream | Snapshot-stream | Not supportable |
| Mod-load determinism | Deterministic mod-replay (free on T1, v2.0) | Same mod set, pinned runner | Tolerance-window | Not verifiable |
| Formal hardening scope | Full pure-sim + rating math | Pure-sim excluding physics FP | Algebraic properties only | Design-intent assertions only |

---

## 9. Asset Lane Design (Pure-Maximal)

*(v1.0 content unchanged; v2.0 adds disclosure_class to provenance sidecar)*

### The locked decision

ASSET GENERATION IS PURE-MAXIMAL / LIGHTS-OUT: agents generate everything a game needs
with no mandatory human-in-loop CREATIVE finishing. However, the factory automatically
captures per-asset provenance/license metadata as data, and IP/quality/legal risks are
recorded in the risk register — documented, not used to impose human gates.

**v2.0 clarification on `human-gated` vs creative finishing.** The `human-gated` fidelity
tier introduced in v2.0 is EXCLUSIVELY for external, third-party-required acts. It does
NOT create a human gate for creative quality of assets. Hero assets, music, and voice are
generated lights-out. The only asset-related `human-gated` items are: SAG-AFTRA/likeness
consent signatures (per IMA 2025), legal-doc attorney review, and `directed: true` cinematic
sign-off (creative direction decision, not third-party-required — this is a catalyst
catalyst-call, not an external gate).

### Autonomous generation pipeline *(v1.0, unchanged)*

```
[game-production-plan + design-spec]
  → asset-generation-request (per asset; risk-tier assigned by class)
      → [Asset Generation Orchestrator]
          → modality-specific sub-agent selects tool by risk-tier policy
              Tier-1: Tripo/Rodin/Meshy (props), Substance Sampler (materials),
                      Houdini/PCG (terrain/scatter), SpeedTree (vegetation),
                      WFC/BSP (level layouts), ElevenLabs (SFX),
                      Stable Audio 2.5 / AIVA / Soundraw (music — licensed only),
                      Midjourney/FLUX (concept 2D)
              Tier-2: Firefly-indemnified tools preferred; heavy human-transform
              Tier-3: Firefly + human sign-off; AI voice requires consent gate
          → Raw Asset + asset-provenance-sidecar (generated automatically)
      → [Quality Gate] (topology/UV/PBR/loudness/provenance completeness)
          → pass + Tier-1: auto-ingest to asset store (GLB canonical format)
          → pass + Tier-2/3: flag for record; ingest anyway (pure-maximal decision)
          → fail: flag defect; re-generate with adjusted params
  → [Engine Adapter] → per-engine import config from GLB contract
```

### Automatic provenance metadata *(v1.0 + v2.0 addition)*

Every generated asset receives an `asset-provenance-sidecar` at generation time:
- `generated_by_tool`: name, vendor, model/weights version
- `generation_date`: timestamp
- `prompt_and_inputs_log`: full prompt + reference inputs
- `human_modifications_log`: empty at generation; populated if a human transforms the asset
- `license_terms_snapshot`: commercial use, resale, attribution, indemnification tier
- `training_data_provenance`: licensed / open / unknown
- `likeness_consent_ref`: null for non-likeness; consent document ID for any voice/face (SAG-AFTRA ICDR)
- `risk_tier`: 1/2/3
- `copyrightability_assessment`: likely/partial/unlikely
- **`disclosure_class`** *(v2.0 new field)*: `pre-generated` / `live-generated` / `procedural-exempt` per Steam AI disclosure policy (Jan 17 2026 rewrite); drives `ai-disclosure-manifest` generation; EU AI Act Art. 50 / C2PA machine-readable marking

### Engine-agnostic asset interchange *(v1.0, unchanged)*

Runtime delivery: **GLB (glTF 2.0)** as the canonical engine-neutral asset contract.
Pipeline backbone: **OpenUSD** for scene assembly, variants, DCC interchange.
Baked vertex caches: **Alembic** for cloth/sim.
Shader: `material.semantic` → per-engine adapter (no cross-engine standard; SPIR-V/WGSL are
GPU-API, not material, intermediates).
**v2.0 addition:** lip-sync portable contract: **ARKit-52 blendshapes / MetaHuman curves**
(declared in `lip-sync-pipeline-contract`; runtime-portable across Audio2Face-3D / MetaHuman
Animator / JALI / Speech Graphics).

---

## 10. Scope Recommendation — Three-Tier Model

*(v1.0 In Scope / Out of Scope superseded by the three-tier model below. v1.0 items are
re-classified; superseded lines are noted.)*

### Tier 1: v1 Core (Det-Sim Pilot + Universal Spine)

Everything in this tier is default-on and ship-prerequisite for the det-sim pilot.

- **Engine-adapter protocol** (JSON-RPC 2.0, LSP-style) for Bevy, Unity, Godot
- **Conformance suite + reference mini-game** (Bevy + Unity founding pair; Godot cheap third)
- **Reused orchestration spine** from vsdd-factory (dispatcher, hook chain, agent framework, state, workflows, PR/worktree lifecycle, adversarial review)
- **Game methodology layer**: simulation BCs + design-intent contracts + deterministic replay-regression harness + playtest protocol + asset lane + reshaped convergence model (11 dimensions)
- **All-genre core contract set**: design-spec, systems-spec, balance-data, economy-graph, level-spec, narrative-graph, loc-string-contract, audio-build-manifest, art-bible, game-production-plan, cross-discipline-dependency-contract
- **Asset generation pipeline** (pure-maximal): asset-generation-request schema, asset-provenance-sidecar (mandatory, including `disclosure_class`), quality-gate harness, risk-tier routing policy
- **Det-sim genre pilot**: one reference game using Bevy + Rapier (T1 determinism); proves factory end-to-end with strongest replay-regression guarantee
- **Cert pre-flight engine + distribution-readiness** (v2.0 scope change): cert-preflight-checklist (55-80% machine-checkable per platform); `distribution-release-pipeline` with verified CLIs (steamcmd, butler, fastlane); `human-gated` task list emitted for console cert + store publish
- **Playtest protocol harness**: structured protocol templates, GEQ/PENS/SUS scaffolding, 3-lens dashboard; human sign-off gate
- **Telemetry + liveops plumbing**: telemetry-event-taxonomy, kpi-dashboard-spec, crash-reporting-wiring (sentry-cli / Crashlytics symbol upload per build), remote-config-contract (Satori/Firebase default)
- **Accessibility contract**: GAG/XAG feature matrix + CVAA checklist
- **Audio build automation**: Wwise WAAPI + FMOD CLI; loudness/true-peak (ITU-R BS.1770)
- **Narrative graph tooling**: branch-reachability, dead-end detection, variable consistency, ICU placeholder, pseudo-loc; canon-KB schema
- **Compliance pipeline** (v2.0 scope change): IARC objective-question auto-fill, `compliance-checklist` generation, `ai-disclosure-manifest` from provenance sidecar (EU AI Act Art. 50 marks applies 2026-08-02), `privacy-config-contract`, `legal-doc-set` template generation; ratings submission terminal step = `human-gated`
- **Security-requirements-contract + server-authority-invariant-suite** (v2.0): required for any online/multiplayer game; CWE-602 machine-verifiable spine
- **Online-services adapter** (v2.0): online-services-spec + platform-integration-manifest; Nakama reference (Docker-headless CI-testable); EOS managed adapter
- **Ranking-system-contract** (v2.0 — v1 universal, genre-neutral): rating-math BC/VP (cleanest formal-hardening target); seed-deterministic leaderboard for det-sim pilot
- **Replay-format** (v2.0 — already exists as replay-regression-contract, just named): esports-compatible deterministic demo exposed as a player feature; free on T1

### Tier 2: Optional, Genre-Gated (enable per genre-profile parameter)

These capabilities are v1-ready but not default-on; each requires explicit genre opt-in.

- **Competitive multiplayer / esports lane**: `matchmaking-fairness-invariants`, `spectator-spec`, `tournament-mode-spec`, `broadcast-stats-contract`; competitive anti-cheat integration (wrap EAC/EOS); requires competitive-multiplayer genre profile; live event ops / casting / prize disbursement = `human-gated` (out of autonomous scope always)
- **Modding / UGC enablement**: `mod-api-contract`, `ugc-content-schema`, `ugc-distribution-adapter` (mod.io reference), `mod-load-spec`, `mod-sdk`; `moderation-pipeline-contract` reused for UGC; paid UGC monetization = `human-gated` (copyright vetting); in-game editor = deferred
- **Monetization mechanics**: business-model-spec, `monetization-ethics-contract` (mandatory when monetization present), `sink-faucet-model`, `pricing-matrix`, `gacha-spec`, `iap-catalog`; `live-economy-balance-contract`; FTC COPPA consent for ad SDKs if applicable
- **Marketing / GTM lane**: `store-page-spec` (Steam/mobile specs machine-validated; console = NDA-gated), `marketing-asset-manifest`, `press-kit` (presskit.html data.xml), `capture-recipe`, `campaign-beat-plan`; brand flagship-asset sign-off = `human-gated`
- **Multiplayer tiers**: dedicated-server orchestration (Nakama/GameLift/AMS wrap); server-authoritative netcode patterns; rollback (GGPO) and deterministic lockstep are the natural fit (reuse T1 determinism spine); real-time server-authoritative netcode at scale = later tier per engineering-disciplines.md

### Tier 3: Deferred Platform Tier (seam reserved; implementation not built)

These have reserved adapter seams and defined contract schemas in v1, but no implementation.

- **Unreal Engine adapter**: deferred until engine-adapter protocol proven on Bevy/Unity/Godot; the seam exists; Unreal is a legitimate future adapter target
- **VR/AR/XR**: deferred platform tier — `xr-adapter` seam reserved, four XR contracts defined (xr-adapter, xr-comfort-spec, xr-perf-budget, xr-interaction-spec); OpenXR 1.1 as reference; visionOS = separate non-OpenXR target; Bevy XR = experimental community crate (v0.4.0, no 1.0) — do NOT target via Bevy pilot; implementation must wait for Unity/Godot adapters; comfort/nausea certification = headset-required `human-gated` by construction (physiological, not aesthetic)
- **MMO-scale dedicated-server orchestration / anti-cheat infrastructure**: reserved; wrap GameLift/AMS; never build server infra or kernel AC
- **Runtime generative NPC dialogue as a shipping feature**: deferred (3-7s latency, $150K-$1.8M/month AAA cost, localization explosion per narrative-localization.md §3); authoring assist only

**Explicitly out of scope (never):**
- Building a game engine
- Automatically scoring subjective fun (playtest-satisfaction dimension is a human gate by construction; any agent or hook that emits a fun-score is a defect)
- AI music using uncleared generators (Suno/Udio litigation-exposed; factory defaults to licensed providers)
- Unconstrained LTV optimization (monetization-ethics-contract prohibits this by definition)
- Autonomously running esports events, administering prize pools, or operating live anti-cheat ops

---

## 11. Genre Strategy

*(v1.0 content retained; v2.0 genre-parameterized additions noted)*

### All-genre core *(v1.0, unchanged)*

Every genre has a "numeric/graph spine the factory can generate and verify, surrounded by
a subjective shell it cannot." The genre-universal core:

- Design-intent contract (invariant assertions only; explicit playtest delegation for the rest)
- Simulation behavioral contracts (economy, damage, state machines, AI)
- Narrative-graph schema (all narrative-bearing genres)
- Loc-string contract (all genres with text/UI)
- Audio build manifest (all genres)
- Asset-generation-request + asset-provenance-sidecar (all genres)
- Cert-preflight checklist (all genres × all target platforms)
- Playtest protocol (all genres; instrument selection varies)
- **v2.0: compliance-checklist + ratings-submission-manifest (all genres × all markets)**
- **v2.0: ranking-system-contract (any genre with a leaderboard)**
- **v2.0: security-requirements-contract (any genre with online features)**

### Genre-parameterized surface *(v1.0 + v2.0 additions)*

| Parameter | Example variation |
|---|---|
| `dominant_contract_type` | Det-sim: simulation BC dominant; Narrative: narrative-graph dominant; Fighting: frame-data + rollback; Competitive: matchmaking-fairness-invariants + ranking-system-contract |
| `determinism_tier_target` | Det-sim pilot: T1 (Bevy+Rapier); RTS/fighting: T1 or T2; open-world RPG: T2/T3 |
| `replay_strictness` | T1: exact snapshot-hash; T2: pinned-runner; T3: tolerance-window |
| `playtest_instruments` | Action/feel: GEQ competence/tension; Narrative: think-aloud + GEQ immersion; Sandbox: PENS autonomy; XR: headset-comfort battery (mandatory) |
| `asset_style_profile` | Photoreal-PBR (highest automation); low-poly/voxel (high automation); stylized (lower automation) |
| `audio_profile` | Loudness target, voice-count budget, spatial backend, AI-music policy |
| `loc_profile` | Multiplayer: continuous-loc CI + pseudo-loc mandatory; RPG: full VO + cultural review |
| `cert_targets` | PC: Steam/EGS; console: TRC/XR/Lotcheck; mobile: App Review/Play |
| `monetization_model` | None (premium); cosmetic-DLC (lowest risk for det-sim pilot); F2P/gacha (triggers monetization-ethics-contract + PEGI 16+ mandatory) |
| `modding_enabled` | false (default det-sim pilot); true (design architecture in from day one; data-mods free) |
| `esports_enabled` | false (default); true (competitive-genre only; triggers matchmaking-fairness + spectator + AC integration) |
| `xr_target` | none (default); openxr (deferred Tier 3); visionos (deferred Tier 3 non-OpenXR) |

### Det-sim pilot: why this genre first *(v1.0, unchanged)*

Deterministic-simulation genres (factory/automation, roguelike, deterministic RTS,
management sim, card/deckbuilder) have the largest verifiable spine and smallest subjective
shell. The economy/production graph is Machinations-native, all core loop state is
serializable and diffable, T1 determinism achievable with Bevy + Rapier, replay-regression
is exact snapshot-hash diff, procedural content is seed-deterministic, platform cert is
simpler (PC-first), and the subjective shell is narrow.

**v2.0 pilot clarifications:**
- `monetization_model = premium` or cosmetic-DLC — lowest regulatory complexity; avoids PEGI 16+ trigger; no monetization-ethics-contract complexity in v1 unless opted in
- `modding_enabled = false` for pilot; data-driven architecture designed in so schema publication is marginal work when enabled
- `esports_enabled = false`; optional seed-deterministic leaderboard demonstrates ranking-system-contract BC for free
- `xr_target = none`; XR is Tier 3 deferred and requires Unity/Godot adapters first (Bevy XR is experimental)

---

## 12. Risk Register

*(v1.0 R-001 through R-012 retained and updated; R-013 through R-017+ from v2.0 vectors
added. All risks RECORDED per pure-maximal decision; none are blocking gates.)*

| ID | Risk | Category | Likelihood | Impact | Mitigation Note |
|---|---|---|---|---|---|
| R-001 | **Fully autonomous AI assets may be uncopyrightable in the US** (USCO Jan 2025; Thaler v. Perlmutter D.C. Cir. Mar 2025: human authorship required) | Legal / IP | HIGH (confirmed) | HIGH | Record human-modifications-log on every asset; auto-populate copyrightability-assessment; empty-log assets flagged "likely uncopyrightable" in sidecar. Studio elects to humanize Tier-2/3 if ownership matters. |
| R-002 | **Training-data indemnification gap**: most generative-3D and open image models have no indemnification | Legal / IP | MEDIUM | HIGH | Route IP-sensitive assets to indemnified providers (Adobe Firefly). Sidecar records indemnification tier. Studio legal reviews Tier-2/3 asset classes. |
| R-003 | **AI music legal hazard**: Suno/Udio litigation ongoing (Sony holdout; fair-use ruling expected summer 2026) | Legal / Audio | HIGH | HIGH | Factory defaults to licensed models (Stable Audio 2.5, AIVA, Soundraw). Suno/Udio = non-ship until litigation resolves. Sony fair-use ruling (summer 2026) is monitoring trigger. |
| R-004 | **SAG-AFTRA 2025 IMA voice consent requirement**: any AI voice of a covered performer requires written, separately-signed, specific consent + compensation | Legal / Audio | HIGH (for named performer voice) | HIGH | Default ship = human VO or Replica/Respeecher (consent-framework providers). AI voice = placeholder only. Provenance sidecar requires likeness-consent-ref for any voice. `human-gated` signature flow triggered when likeness-consent-ref != null. |
| R-005 | **Hero-character autonomous quality gap**: 3D + rig + animation + face simultaneously at AAA bar not achievable autonomously today | Quality | HIGH | HIGH (hero-tier) | Asset risk-tier system routes hero characters to Tier-3 (documented, not gated). Quality-gate report flags topology/rig issues. Factory generates best-available; sidecar records quality-gate-pass/fail. |
| R-006 | **Steam AI-content disclosure requirement** (Jan 17 2026 rewrite): AI-generated content must be disclosed; live-generated AI requires developer attestation | Legal / Platform | HIGH (confirmed) | MEDIUM | Provenance sidecars feed automatic `ai-disclosure-manifest` (pre-generated / live-generated / procedural-exempt classification per Jan 2026 policy). Traditional PCG explicitly exempt. |
| R-007 | **Shader / VFX non-portability**: no engine-agnostic material standard | Technical | HIGH | MEDIUM | `material.semantic` → per-engine adapter architecture. Build task, not risk blocker. |
| R-008 | **Determinism is opt-in on every engine**: Godot/Bevy have distinct non-determinism sources | Technical | MEDIUM | HIGH | Decision 0003: tiered determinism. T1 pilot. T2/T3 degrade replay. Non-determinism sources documented per engine. |
| R-009 | **LLM/AI confabulation on fast-moving APIs and legal specifics**: multiple research passes in this project confabulated engine APIs, distribution tool names, EOMM formulas, and distribution CLIs | Technical / Process | HIGH | HIGH | Factory rule: every load-bearing claim verified against version-tagged primary docs. All 9 new vectors explicitly discarded confabulated passes; claims re-anchored to WebFetch/Tavily-verified primary sources. `R-009` is the standing confabulation meta-risk for this project. |
| R-010 | **"Fun" cannot be auto-scored — and engagement-optimization without ethics constraint risks compulsion-loop / dark-pattern design** | Product / Ethics | MEDIUM | HIGH | Playtest-satisfaction dimension is a human gate. `monetization-ethics-contract` is mandatory when monetization is present; adversarially reviewed. EOMM engagement-as-autonomous-objective is a declared factory defect (§10 Tier 1 "never"). |
| R-011 | **Cross-engine deep test tier unbuilt for Godot/Bevy**: GameDriver = Godot Beta / no Bevy | Technical | HIGH | MEDIUM | Factory builds its own deep tier from the replay spine for Godot/Bevy. Bevy BRP is a standout introspection asset. |
| R-012 | **Cert % estimates are directional, not audited; cert frameworks version frequently** (XR v16.0 Nov 2025); exact TRC/Lotcheck content is NDA'd | Platform / Legal | MEDIUM | MEDIUM | Cert pre-flight built against public categories + each studio's own NDA'd checklist. Re-validated per submission cycle. |
| R-013 | **PEGI 2026 interactive risk category changes**: paid random items → PEGI 16 minimum (Jun 2026); NFT → PEGI 18; limited-time offers → PEGI 12; unrestricted comms → PEGI 18 | Legal / Platform | HIGH (confirmed, primary-verified) | HIGH | `content-descriptor-contract` declares mechanics; `compliance-checklist` auto-triggers minimum-rating rules. Det-sim pilot with premium/cosmetic-DLC model = no trigger. Gacha/paid-random = flag immediately. NFT = off-by-default per factory policy. |
| R-014 | **EU AI Act Article 50 machine-readable marking applies 2026-08-02**: AI-generated audio/image/video/text must carry machine-readable marks (C2PA Content Credentials) | Legal / Compliance | HIGH (confirmed, primary-verified) | HIGH (if shipping post-Aug 2026) | `ai-disclosure-manifest` generated from provenance sidecar; C2PA marks embedded at generation. `disclosure_class` field in sidecar is the data source. Compliance date is a hard deadline in the distribution pipeline. |
| R-015 | **FTC COPPA 2025 amendment**: effective 23 Jun 2025; compliance 22 Apr 2026; separate parental consent required for each third-party ad SDK | Legal / Compliance | HIGH (confirmed, primary-verified) | HIGH (for games with children audience or ad SDKs) | `privacy-config-contract` includes per-ad-SDK COPPA consent flags. `ad-monetization-spec` COPPA flags machine-validated. `human-gated` attorney review before any child-directed deployment. |
| R-016 | **AI research confabulation of legal/vendor specifics** (meta-risk; overlaps R-009): regulations, platform policies, and vendor terms change faster than training data; multiple vectors showed confabulation on compliance specifics | Technical / Legal | HIGH | HIGH | Every compliance claim in this document is either (a) primary-source-verified with inline citation or (b) flagged [UNVERIFIED]. Compliance-checklist auto-generation must be re-verified each release cycle against live regulatory and platform docs. This is R-009 applied specifically to the legal/compliance domain. |
| R-017 | **Kernel anti-cheat autonomous authoring is beyond factory scope and post-CrowdStrike the Microsoft/Linux ecosystem is actively moving security out of kernel** | Technical / Security | HIGH | HIGH (for competitive-MP) | Anti-cheat = wrap-only (EAC/EOS default; BattlEye commercial; Riot Vanguard NOT licensable). Kernel drivers: factory never autonomously authors. Competitive-MP depends on `human-gated` live AC ops (ban waves, cat-and-mouse) which stay out of autonomous scope. |

---

## 13. Open Questions for the Human / Architect

*(v1.0 OQ-001 through OQ-007 updated for v2.0; new questions added)*

**OQ-001 (RESOLVED by pure-maximal decision):** Asset generation is a first-class In-Scope
item in v1. The pure-maximal / lights-out decision encodes this. The v1 depth covers all
modalities (3D, audio SFX, music, voice placeholder, concept 2D, narrative text).

**OQ-002 (RESOLVED by pure-maximal decision):** Tier-3 assets trigger a recommendation
in the provenance sidecar (quality-gate-pass/fail, risk-tier, copyrightability-assessment)
but no mandatory finishing gate. Studio may elect human finishing; factory does not impose it.

**OQ-003 (Middleware licensing for audio — still open):** Does each generated game carry
its own Wwise/FMOD license, or does the factory target Godot native audio for v1?

**OQ-004 (Large-binary VCS model — still open):** Build as first-class subsystem, wrap
existing backend (Perforce SaaS / Diversion / Unity Version Control), or defer?

**OQ-005 (Multiplayer scope — still open, partially resolved):** Deterministic-lockstep/
rollback is the first-class optional multiplayer lane (Tier 2, genre-gated). Should real-
time server-authoritative netcode beyond lockstep be In-Scope for v1 as an optional gate?

**OQ-006 (Cert lab access — still open):** The `human-gated` distribution-adapter handles
this; the remaining question is whether the factory builds a cert-lab partnership model or
provides a documentation-stub for studios to fill in.

**OQ-007 (Style-profile depth in v1 — still open):** Single pilot profile (low-poly/voxel
for roguelike/management sim) vs multiple profiles?

**OQ-008 (mod.io pricing tiers — new):** Only "free within limits" verified; console/
Embed Hub/white-label = premium tiers with unverified rate card. Confirm pricing model
before budget-committing to modding pipeline.

**OQ-009 (Bevy sequencer build decision — new):** Cinematics require an engine-agnostic
`sequence-graph` with a Bevy runtime sequence player (no native sequencer in Bevy). Does
the factory build this for v1, or are cinematics Tier 2 (deferred for non-Bevy engines)?

**OQ-010 (EOMM engagement policy disclosure — new):** If the factory ships a matchmaking
system, the `matchmaking-fairness-invariants` spec requires the engagement-vs-fairness
policy to be a declared human decision. Who is the accountable human for this declaration
per game?

---

## 14. Traceability — Source Map

| Section | Primary sources (v2.0) |
|---|---|
| §1 Executive Summary | product-brief.md; architecture.md; all 22 research vectors |
| §2 Dark Factory Foundations | product-brief.md §Overflow Context; architecture.md; vsdd-factory CLAUDE.md |
| §3 vsdd Rigor Inventory | vsdd-factory CLAUDE.md (full); agents/ inventory; skills/ inventory |
| §4 Mechanism Mapping | game-design-discipline.md; engineering-disciplines.md; qa-testing-liveops.md; architecture.md; decisions/; esports-competitive-integrity.md §2; monetization-business-model.md |
| §5 Agent Roles + Adapter Seams | production-pipeline.md §3; all 22 research vectors; online-services-platform-distribution.md §7; vr-ar-xr-platform.md §2; modding-ugc-tools.md §2 |
| §6 Artifact Taxonomy | All 22 research vectors; esports-competitive-integrity.md §10; modding-ugc-tools.md §9; online-services-platform-distribution.md §10; vr-ar-xr-platform.md §11; ratings-legal-compliance.md; monetization-business-model.md; marketing-store-community.md; cinematics-virtual-production.md §6; security-anticheat-trust-safety.md §10 |
| §7 Convergence Model | architecture.md §Convergence dimensions; qa-testing-liveops.md §8; vsdd-factory CLAUDE.md; ratings-legal-compliance.md; monetization-business-model.md; security-anticheat-trust-safety.md |
| §8 Quality-Model Delta | architecture.md §How the quality model changes; extraction-boundary.md; qa-testing-liveops.md §5; game-design-discipline.md; esports-competitive-integrity.md §2; vr-ar-xr-platform.md §7 |
| §9 Asset Lane | generative-asset-ai.md §2,§4-7; art-pipeline.md §4,§8; audio-discipline.md §3; cinematics-virtual-production.md §5 |
| §10 Scope Tiers | All 22 research vectors; online-services-platform-distribution.md §12; vr-ar-xr-platform.md §12; modding-ugc-tools.md §10; esports-competitive-integrity.md §12; ratings-legal-compliance.md |
| §11 Genre Strategy | game-design-discipline.md §Genre Variation Matrix; engineering-disciplines.md §7; qa-testing-liveops.md §9; decisions/0003; monetization-business-model.md; modding-ugc-tools.md §7; esports-competitive-integrity.md §9 |
| §12 Risk Register | All 22 research vectors; ratings-legal-compliance.md (R-013, R-014, R-015); security-anticheat-trust-safety.md (R-017); monetization-business-model.md (R-010 extension); online-services-platform-distribution.md (R-009 extension); generative-asset-ai.md §5; audio-discipline.md §3 |
| §13 Open Questions | New vectors + remaining v1.0 open questions |
