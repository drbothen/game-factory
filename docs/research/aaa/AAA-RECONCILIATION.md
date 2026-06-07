---
document_type: methodology-reconciliation
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: business-analyst
inputs:
  - docs/research/aaa/game-design-discipline.md
  - docs/research/aaa/art-pipeline.md
  - docs/research/aaa/generative-asset-ai.md
  - docs/research/aaa/audio-discipline.md
  - docs/research/aaa/narrative-localization.md
  - docs/research/aaa/engineering-disciplines.md
  - docs/research/aaa/production-pipeline.md
  - docs/research/aaa/qa-testing-liveops.md
  - docs/research/RECONCILIATION.md
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

# AAA Game-Factory — Methodology and Scope Reconciliation

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
loudness conformance, cert checklists) and a subjective shell (fun, feel, art direction,
performance direction) — and the factory owns the spine while governing the shell via
structured human gates, never collapsing it to a scalar. Second, the factory generates
EVERYTHING a game needs — design, all art, all audio, narrative, code, QA artifacts — in a
pure-maximal lights-out mode, with per-asset provenance metadata captured automatically; IP
and quality risks are recorded in a risk register, not used to impose human gates. Third,
the most tractable first-order proof is the deterministic-simulation pilot (roguelike,
factory/automation, deterministic RTS): it maximizes the verifiable spine, gives bitwise
replay-regression, and minimizes the subjective shell, while the genre-universal core and
contract set is built to generalize from day one.

---

## 2. Dark Factory Foundations (source-cited)

The following principles are inherited from the StrongDM Software Factory lineage
(https://factory.strongdm.ai), cited in the product brief and architecture document, and
now grounded against the eight AAA research vectors:

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

Every vsdd mechanism is mapped to its game-factory analog, with the research document
that grounds the mapping.

| vsdd Mechanism | game-factory Analog | Game-Dev Rationale | Research Grounding |
|---|---|---|---|
| **Behavioral Contract (BC)** | **Simulation Behavioral Contract** — economy invariants, damage I/O matrices, inventory save round-trip, ability/FSM legality; **Design Intent Contract** — verifiable subset of design intent (reachability, solvability, balance bands, no-softlock, conservation) | Every game genre has a numeric/graph spine that is machine-checkable (Tier-A artifacts per game-design-discipline.md); subjective shell is not | game-design-discipline.md §Design-Intent-as-Contract; engineering-disciplines.md §2.1 |
| **TDD Red Gate** | **Red Gate retained for pure-sim code** (gameplay systems, economy, AI behavior trees, networking determinism); degrades gracefully on engine-bound/rendering code | Gameplay systems reduce to pure data transforms that are unit-testable headless; rendering/feel code cannot be red-gated on feel | engineering-disciplines.md §2.1; qa-testing-liveops.md §3.1 |
| **DTU** | **Deterministic Replay-Regression Contract** — record input keyed by sim frame → replay → compare; comparison method degrades by `determinism_tier` (exact snapshot-hash for T1 / pinned-runner snapshot for T2 / tolerance-window metric diff for T3) | Games have no "third-party services" to clone; the regression surface is the simulation state trajectory over time; tier degradation is game-specific (Decision 0003) | qa-testing-liveops.md §4; RECONCILIATION.md §C.1; decisions/0003 |
| **Formal Hardening (Kani/fuzz/mutants)** | **Formal hardening restricted to pure-sim slice** — economy conservation proofs, invariant checking on deterministic state machines, property-based testing on balance/progression formulas | Most gameplay lacks properties amenable to model checking; the pure-sim slice (economy, ability cooldowns, inventory) has real mathematical invariants | game-design-discipline.md §Design-Intent-as-Contract; engineering-disciplines.md §2.1 |
| **Holdout Evaluation** | **Playtest Protocol** — structured human playtest + 3-lens convergence (say/do/behave); GEQ/PENS/SUS instruments; never auto-scored | "Is it fun" is not a hidden unit test; the same telemetry signal is ambiguous without self-report; fun is latent and multidimensional | qa-testing-liveops.md §5; architecture.md §How the quality model changes |
| **Adversarial Review** | **Adversarial Review retained** + **Design Adversary** (fresh-context review of design intent contracts for verifiable-vs-subjective split errors, over-specification, under-specification) | Specs in game dev span formal contracts and subjective intent; an adversary must check that the formal-vs-playtest boundary is drawn correctly, not just that contracts are consistent | game-design-discipline.md §R1; architecture.md |
| **7-Dimension Convergence** | **Reshaped convergence model** (see Section 7) — 9 dimensions including playtest-satisfaction, asset-completeness, cert-preflight, provenance/legal | Game quality has axes that software quality does not: asset completeness, playtest feel, platform cert, IP provenance | architecture.md §Convergence dimensions; qa-testing-liveops.md §11 |
| **Demo Recorder** | **Adapter `capture` backend** + ffmpeg fallback — gameplay video capture via `render` execution profile (xvfb+software-GPU for Unity/Godot; windowless+lavapipe for Bevy) | Games need gameplay capture as observable behavior evidence; engine headless flags conflict with rendering on every engine | engine-adapter-protocol.md §Capability matrix; RECONCILIATION.md §B.1 |
| **Holdout evaluator (strict info asymmetry)** | **Playtest evaluator** — structured protocol with predefined research questions, instruments, and a human sign-off gate | Human playtesters have information asymmetry with respect to implementation just as holdout evaluators do; they evaluate against the playtest-protocol spec | qa-testing-liveops.md §5.2; architecture.md |
| **Wave Scheduling** | **Wave Scheduling retained** — discipline-DAG-ordered waves (design → art → audio → engineering → QA) with cross-discipline dependency contracts at each edge | Game production is a federated DAG of discipline dependencies; multi-studio coordination is structurally identical to multi-agent coordination | production-pipeline.md §5.1, §7 |
| **PR / Worktree Lifecycle** | **Retained** — each story (game feature, asset batch, level, audio set) in its own worktree; pr-manager 9-step cycle; squash-merge to develop | No change needed; worktree isolation prevents cross-discipline contamination in the same way it prevents cross-feature contamination | extraction-boundary.md §MOVE |
| **Gene Transfusion** | **Adapter Conformance Suite** — a reference mini-game every adapter must pass; "implement adapter + pass conformance" is the bar; proven game patterns transfer across engine adapters | Engine adapters differ widely (compiled ECS vs editor-first vs scene-graph); conformance is the mechanism that makes n-engine support sustainable | engine-adapter-protocol.md §Conformance suite; decisions/0002 |
| **Semport** | **Adapter Semport** — engine version pinned in manifest; each engine minor release = scheduled adapter maintenance; compatibility matrix published | Bevy pre-1.0 quarterly API churn makes version pinning mandatory; Unity/Godot version sensitivity is real but lower | protocol-schema.md §6; RECONCILIATION.md §C.7 |
| **Hook Chain** | **Hook Chain retained** + game-domain hook plugins — asset-provenance-check (every generated asset has a sidecar), cert-preflight-gate, balance-band-check on merged data tables | The same governance mechanism applies; game-domain rules are expressed as additional hook plugins | vsdd-factory CLAUDE.md §Hooks |
| **BC/VP schema** | **BC → Simulation BC + Design Intent Contract; VP → Simulation VP + Replay-Regression Contract** | BC schema carries simulation invariants; Design Intent Contract carries the verifiable subset of feel/pacing/balance assertions with explicit delegation to playtest for the rest | extraction-boundary.md §STAYS in vsdd-factory; §BUILD NEW |
| **State Manager** | **Retained** — `.factory/STATE.md` plus game-specific decision log entries (engine decisions, genre decisions, determinism tier decisions) | No change needed; game-factory adds game-domain decisions but the mechanism is identical | vsdd-factory CLAUDE.md §State Manager |
| **Orchestrator** | **Retained as producer-agent** — the producer role in game production maps directly to the orchestrator: dependency DAG, wave scheduling, milestone gate enforcement | Production vector research confirms "producer = dispatcher"; the catalyst-specialist pool maps to shared specialist agents | production-pipeline.md §3 Mapping Principles |
| **Research Agent** | **Retained** — Perplexity/Tavily/Context7 for domain and technology research; grounded all 8 AAA vectors | Research discipline is domain-neutral; game-factory extends it to cover game-domain knowledge | research agents (all 8 AAA vectors) |
| **Accessibility Auditor** | **Retained + extended** — CVAA legal floor + GAG/XAG tier + colorblind/subtitle/remappability checks; partial auto-lint + checklist gate | Accessibility is the most machine-checkable design sub-discipline per game-design-discipline.md; CVAA is a legal requirement | game-design-discipline.md §Accessibility |
| **Consistency Validator** | **Retained + extended** — cross-discipline ID consistency (CAP-NNN across design/art/audio/engineering contracts); provenance-ledger completeness | Cross-discipline consistency is harder in games than in software because artifacts span code, data, art, audio, narrative | production-pipeline.md §5 |

---

## 5. New Disciplines and Agent Roles

The following disciplines are present in AAA game development but absent from vsdd-factory.
Each maps to one or more proposed specialist agents in the game-factory studio-of-agents.

### 5.1 Creative Direction / Art Direction
**Why new:** establishes the visual language, tone, and quality bar for all asset
generation; cannot be delegated to a generic implementer.
**Agent role:** `creative-director` (catalyst/shared) + `art-director` (catalyst/shared)
**Artifacts produced:** art bible (`art-bible.spec`), style-profile, visual targets
**Research grounding:** art-pipeline.md §2.1; production-pipeline.md §3

### 5.2 Game Design (Systems, Economy, Level, Content)
**Why new:** produces the verifiable spine — state machines, economy graphs, balance tables,
encounter graphs — that feeds all downstream behavioral contracts.
**Agent roles:** `systems-designer`, `economy-designer`, `combat-designer`,
`level-designer`, `encounter-designer`, `ux-accessibility-designer`
**Artifacts produced:** `design-spec`, `systems-spec`, `balance-data`, `economy-graph`,
`progression-spec`, `content-data`, `level-spec`, `ui-spec`, `accessibility-contract`,
`design-intent-contract`
**Research grounding:** game-design-discipline.md §Discipline Breakdown, §Factory Artifacts

### 5.3 Visual Art Generation (Concept, 3D Mesh, Texture, VFX)
**Why new:** generates all visual assets via generative AI + procedural tools, automatically
capturing provenance; routes by risk tier (Tier-1 auto-ingest, Tier-2/3 human finishing).
**Agent roles:** `concept-artist`, `env-modeler`, `prop-artist`, `char-modeler`,
`char-texture`, `vfx-artist`, `pipeline-ta` (technical artist, catalyst)
**Artifacts produced:** `asset-generation-request`, `asset-package` (GLB),
`asset-provenance-sidecar`, `material.semantic`, `vfx.spec`
**Research grounding:** generative-asset-ai.md §2, §7; art-pipeline.md §7

### 5.4 Character Art (Rig, Skin, Animation)
**Why new:** hero-character rig/skin/animation has distinct quality requirements and
distinct automation ceilings (auto-rig reliable for standard humanoids; hero facial rig
human-craft).
**Agent roles:** `char-rigger`, `char-ta` (catalyst), `animator`, `anim-ta` (catalyst)
**Artifacts produced:** `rig.skeleton`, `skin.weights`, `anim.clips`,
`anim-state-machine.spec`
**Research grounding:** art-pipeline.md §2.9, §2.10; generative-asset-ai.md §2.4

### 5.5 Audio (Music, SFX, Voice, Implementation)
**Why new:** audio has a dual structure — headless-automatable build spine (Wwise WAAPI /
FMOD CLI / ffmpeg loudnorm) and creative-subjective authoring core (composition,
performance direction, mix). Voice carries the highest legal risk (SAG-AFTRA 2025 IMA).
**Agent roles:** `audio-designer`, `composer`, `audio-implementer`, `voice-director`
(human-in-loop gate, not a generation agent)
**Artifacts produced:** `audio-design-spec`, `music-interactive-spec`, `sfx-manifest`,
`dialogue-table`, `bus-and-mix-spec`, `audio-build-manifest`, `loudness-spatial-profile`,
`audio-acceptance-report`, `ai-audio-provenance-ledger`
**Research grounding:** audio-discipline.md §6; §3

### 5.6 Narrative, Writing, and Localization
**Why new:** narrative graphs have machine-checkable structure (reachability, dead-ends,
placeholder validation) distinct from code; localization is a parallel pipeline with its
own QA checks and a continuous-loc CI requirement.
**Agent roles:** `narrative-designer`, `writer` (LLM-native; barks and dialog graphs),
`localization-engineer`
**Artifacts produced:** `narrative-graph` (canonical schema), `quest-schema`,
`bark-rules.schema`, `lore-bible`, `loc-string-contract` (ICU MessageFormat + XLIFF 2.0),
machine-check battery (branch-reachability, dead-end, string-coverage, pseudo-loc)
**Research grounding:** narrative-localization.md §7; §4

### 5.7 Asset Generation Pipeline (Provenance/License)
**Why new:** pure-maximal lights-out asset generation requires an automatic per-asset
provenance spine — tool, model version, prompt, generation lineage, license terms,
indemnification status, human-modifications log, consent references (SAG-AFTRA ICDR).
**Agent role:** `asset-generation-orchestrator` (coordinates modality-specific sub-agents;
runs QC gate; routes by risk tier)
**Artifacts produced:** `asset-generation-request.schema`, `asset-provenance-sidecar`
(mandatory on every generated asset), `quality-gate-report`
**Research grounding:** generative-asset-ai.md §7; audio-discipline.md §6.9

### 5.8 Production / DAM / Large-Binary VCS
**Why new:** game content includes large unmergeable binaries (Maya files, audio files,
level packages) that require Perforce/P4-style exclusive locking and narrow sync, plus a
DAM layer for "where-used" dependency propagation and review workflows.
**Agent role:** `producer` (= orchestrator for game production; milestone gate enforcement),
`cert-owner` (cert pre-flight tracking; shift-left from alpha)
**Artifacts produced:** `game-production-plan`, `milestone-gate` (hook-enforced
predicates), `cross-discipline-dependency-contract`, `dam-record` (asset registry +
where-used index), `derived-data-cache` (incremental cook/bake)
**Research grounding:** production-pipeline.md §4, §5, §6, §8

### 5.9 Platform Certification and Store Submission
**Why new:** console TRC/XR/Lotcheck and Steam certification impose a machine-checkable
checklist (55-80% pre-flightable per platform per qa-testing-liveops.md) that maps
naturally to a conformance suite pattern — but the test categories, rule versions, and
pass criteria are external and platform-specific.
**Agent role:** `cert-owner` (tracks evolving platform rule sets; runs pre-flight;
co-ordinates with QA)
**Artifacts produced:** `cert-preflight-checklist` (per-platform), `cert-submission-package`
**Research grounding:** qa-testing-liveops.md §6; engineering-disciplines.md §2.8

### 5.10 QA / Playtest / LiveOps
**Why new:** game QA decomposes into functional-regression (automated), cert-conformance
(automated), performance/soak (automated), and playtest/UX (human-gate). LiveOps adds a
continuous pipeline (patch cadence, A/B, telemetry, feature flags) the factory generates
as artifacts.
**Agent roles:** `functional-qa`, `compat-qa`, `balance-qa`, `localization-qa`,
`compliance-qa`, `accessibility-qa`, `playtest-evaluator` (human-gate; orchestrates
structured protocol; never auto-scores fun)
**Artifacts produced:** `replay-regression-contract`, `test-suite-manifest`,
`cert-preflight-checklist`, `perf-budget-contract`, `telemetry-event-taxonomy`,
`kpi-dashboard-spec`, `playtest-protocol`, `liveops-runbook`, `crash-reporting-wiring`
**Research grounding:** qa-testing-liveops.md §10; production-pipeline.md §3

---

## 6. New Artifact and Contract Taxonomy

The following contract/artifact types are implied by the AAA research and do not exist in
vsdd-factory. Each is engine-neutral by definition; engine adapters compile them into
engine-specific representations.

| Artifact / Contract Type | Description | Discipline Owner | Validation Method |
|---|---|---|---|
| **`design-intent-contract`** | The verifiable subset of design intent as typed assertions (reachability, solvability, conservation, balance bands, no-softlock, monotonic progression); remainder explicitly delegated to playtest-protocol | Systems designer | Simulation BC machinery + property-based testing |
| **`simulation-bc`** | Extension of vsdd BC for game simulation: economy invariants, damage I/O matrices, inventory save round-trip, ability/FSM state legality, nav A* optimality | Gameplay engineer + systems designer | TDD Red Gate + headless test runner |
| **`economy-balance-contract`** | Source/sink conservation invariants, win-rate band constraints, progression-curve smoothness, no-exploit-loop assertions on the economy graph | Economy designer | Machinations sim / property-based testing |
| **`narrative-graph-schema`** | Canonical directed branching graph (stable node IDs, conditional edges, variables, tags, audio refs, loc keys); adapter exporters to Ink/Yarn/articy/Unreal | Narrative designer | Branch-reachability, dead-end detection, variable consistency |
| **`loc-string-contract`** | Per-string ICU MessageFormat, stable ID, context metadata, char-limit, placeholder types, do-not-translate flags; export targets XLIFF 2.0 / gettext PO / engine tables | Localization engineer | String coverage, ICU placeholder parity, pseudo-loc overflow |
| **`asset-generation-request`** | Per-asset generation spec: class, genre context, risk tier, modality, prompt/inputs, art-direction refs, target engines, output formats, budget constraints, allowed tools | Asset generation orchestrator | Quality-gate report (topology, UV, PBR, provenance completeness) |
| **`asset-provenance-sidecar`** | Mandatory on every generated asset: tool + model version, generation date, prompt log, human-modifications log, license terms, indemnification status, training-data provenance, likeness-consent ref, risk tier, copyrightability assessment | Asset generation orchestrator | Schema validation; legal gate for Tier-2/3 assets |
| **`audio-build-manifest`** | Middleware (Wwise/FMOD/native), engine targets, platforms, languages, SoundBank/bank definitions; drives `WwiseConsole generate-soundbank` / FMOD CLI | Audio implementer | Bank build success; loudness/true-peak conformance |
| **`game-production-plan`** | Machine-readable plan: milestones (each with hook-enforced pass criteria), studio/agent-cluster scopes, dependency DAG, wave schedule, risk register | Producer / orchestrator | Milestone gate predicates; throughput measurement at vertical slice |
| **`milestone-gate`** | Hook-enforced predicate set per milestone (e.g., vertical-slice gate: `all_pipelines_exercised && quality_bar_met && throughput_measured`); anti-"bespoke-hack-slice" check | Producer / cert-owner | Hook chain enforcement |
| **`cross-discipline-dependency-contract`** | Typed contract per design→art / art→audio / art→engineering / engineering→QA edge: artifact format, budgets, naming conventions, acceptance criteria, propagation rules on change | Producer / discipline leads | Automated validation on merge; "where-used" propagation via DAM |
| **`replay-regression-contract`** | Per-scenario recorded input track (keyed by sim frame) + expected golden state; comparison method declared by determinism tier | Functional QA | Deterministic replay harness; tier-gated comparison |
| **`cert-preflight-checklist`** | Per-target-platform machine-checkable requirement set (crash/suspend-resume/save-atomicity/controller/network/shader/packaging) + pass/fail report | Cert-owner | Cert pre-flight harness; wraps vendor validators (GDK Submission Validator) |
| **`perf-budget-contract`** | Frame-time (CPU/GPU ms), 1%/0.1%-low thresholds, memory-soak limits, thermal limits vs pinned-runner baseline; GPU-time split to on-hardware gate | Performance QA | CI gate + profiler integration |
| **`playtest-protocol`** | Structured protocol: research question, recruitment criteria, tasks, instruments (GEQ/PENS/SUS), think-aloud plan, 3-lens convergence report; human sign-off mandatory | Playtest evaluator | Human gate — never auto-scored |
| **`telemetry-event-taxonomy`** | Generated, versioned event schema + instrumentation + ingestion validation + privacy policy; KPIs labeled explicitly "machine-verifiable health signals, NOT fun" | QA / analytics | Schema validation; event-precedence checks |
| **`art-bible.spec`** | Machine-readable art direction: style-profile, palette, material standards, texel-density targets, poly budgets per asset class, naming conventions | Art director | Asset QC gate compliance; cross-asset consistency |
| **`style-profile`** | Parameterizes the entire art pipeline: which stages run, which tools/presets are invoked, budget ranges, shader template, automation ceiling per stage | Art director | Asset generation request validation |
| **`music-interactive-spec`** | Layers/segments, states/transitions, sync points, RTPC→layer maps, stinger set, target loudness per cue; compiles to Wwise/FMOD/native | Composer + audio implementer | Bank build; loudness/true-peak conformance; coverage |
| **`liveops-runbook`** | Patch/content cadence plan, A/B experiment specs (hypothesis/success-criteria/power), feature-flag + remote-config wiring, live-event measurement plan | Liveops producer | Feature-flag state logged to telemetry; test server pre-rollout validation |

---

## 7. Reshaped Convergence Model

vsdd-factory uses 7 convergence dimensions. game-factory reshapes these to 9, reflecting
the additional quality axes games require. Every dimension degrades gracefully against
declared adapter capability fidelity (the declare-and-degrade principle).

| # | Dimension | Description | Gate Type | Degrades to |
|---|---|---|---|---|
| 1 | **sim/spec** | Simulation behavioral contracts pass headless (economy, damage, FSM, AI, netcode determinism) | CI gate (automated) | Tolerance-window if adapter is T2/T3; playtest evidence if `replay: none` |
| 2 | **tests/replay** | Replay-regression green at declared determinism tier; test suite manifest clean | CI gate (automated, tier-gated) | Pinned-runner snapshot (T2); tolerance-window (T3); human playtest evidence (T0) |
| 3 | **implementation** | Build passes; lint clean; architecture-separation rule (logic vs presentation) enforced | CI gate (automated) | No degradation — build is always a hard gate |
| 4 | **asset-completeness** | All asset-generation requests fulfilled; GLB packages schema-valid; provenance sidecars complete; quality-gate pass per risk tier | CI gate (automated) | Tier-1 auto-ingest; Tier-2/3 human finishing gate |
| 5 | **playtest-satisfaction** | Structured playtest protocol run; 3-lens convergence report reviewed; GEQ/PENS/SUS above targets; human signs fun/feel/polish verdict | **Human gate — mandatory and non-automatable** | No degradation — this gate cannot be automated; it is the explicit boundary |
| 6 | **cert-preflight** | Machine-checkable cert pre-flight passes for all target platforms (crash/suspend/save/controller/shader/packaging); human-judged cert items reviewed | CI gate (automated, 55-80%) + human review (remainder) | Partial if platform cert docs are NDA'd; flag remaining items for manual cert |
| 7 | **perf-budget** | Frame budget (CPU + draw-call count) within declared thresholds on pinned CI runner; memory soak passes; thermal within envelope on handheld targets | CI gate (automated for CPU-bound; on-hardware for GPU) | GPU-time moves to on-device gate; CPU-bound stays CI |
| 8 | **provenance/legal** | Every generated asset has a valid provenance sidecar; Tier-2/3 assets have indemnification or human-transformation log; SAG-AFTRA consent refs present for any voice/likeness | CI gate (schema validation) + legal review gate for Tier-3 | Schema only if legal review not yet scheduled; flag for legal gate |
| 9 | **docs** | All agent-produced artifacts have required frontmatter, input-hash, traces_to; design-intent contracts have explicit playtest-delegation notes for every non-verifiable claim | CI gate (automated schema validation) | Advisory if doc is supplementary |

**vs vsdd 7 dimensions:**
- **Retained:** spec (sim/spec #1), tests (#2), implementation (#3), docs (#9)
- **Replaced:** vsdd "performance" (throughput) → game "perf-budget" (frame budget, #7); vsdd "visual" (rendering golden-image) → partially absorbed into playtest-satisfaction (#5) and cert-preflight (#6)
- **Added:** asset-completeness (#4), playtest-satisfaction (#5, the key addition), cert-preflight (#6), provenance/legal (#8)

---

## 8. Quality-Model Delta vs VSDD

### What stays (direct carry-over)

- **Formal hardening** on the pure-simulation slice: property-based testing on economy
  invariants, conservation proofs, FSM legality proofs. Kani/fuzz/mutants apply to any
  pure-logic module with mathematical invariants. [engineering-disciplines.md §2.1]
- **Adversarial convergence** to 3 clean passes: specs and story implementations both
  require adversarial review with information asymmetry. game-factory adds a design
  adversary who specifically checks the verifiable/subjective boundary split.
  [vsdd-factory CLAUDE.md §BC-5.39.001]
- **Behavioral Contracts** for the deterministic-simulation slice: every game has a
  machine-checkable spine (Tier-A and Tier-B artifacts per game-design-discipline.md).
  BCs cover this slice with no change to the mechanism, only to the content.
  [architecture.md §How the quality model changes]
- **Wave scheduling, worktree/PR lifecycle, state management, hook chain:** all retained
  unchanged. The game disciplines are new lanes in the same wave DAG.

### What's added (game-specific)

- **Playtest protocol replacing holdout evaluation for the subjective slice.** Holdout
  evaluation uses information asymmetry to test hidden scenarios. Playtest protocol uses
  information asymmetry differently: playtesters evaluate against the playtest-protocol
  spec without implementation knowledge. The 3-lens model (say/do/behave) is the
  convergence criterion; structured instruments (GEQ/PENS/SUS) prevent collapse to a
  scalar. [qa-testing-liveops.md §5; architecture.md]
- **Deterministic replay harness as the DTU analog.** DTU clones third-party service
  boundaries; the replay harness records simulation trajectories. Both serve as regression
  detection mechanisms for behavior that cannot be fully specified in advance. The replay
  harness is tiered by engine determinism capability (Decision 0003).
  [qa-testing-liveops.md §4; decisions/0003]
- **Design adversary** reviewing design-intent contracts specifically for the
  verifiable/subjective boundary: are claims that should be automated actually in the
  playtest lane? Are claims that should be in the playtest lane incorrectly expressed as
  assertions? [game-design-discipline.md §R1]
- **Asset lane** as a first-class story dependency type: art/audio/animation are generated
  and tracked as story dependencies via the asset-generation-request / asset-package /
  asset-provenance-sidecar pipeline. [architecture.md; art-pipeline.md §7]
- **Cert-preflight engine** as a platform-conformance suite: the cert-preflight-checklist
  is the game analog of vsdd's conformance suite — machine-checkable platform rules that
  degrade gracefully when NDA'd. [qa-testing-liveops.md §6]

### What degrades by determinism tier / adapter capability

The key innovation is the declare-and-degrade principle applied to game-specific dimensions:

| Quality claim | T1 (Bevy+Rapier) | T2 (Unity PhysX) | T3 (Godot physics) | No replay |
|---|---|---|---|---|
| Regression detection | Exact snapshot-hash diff (strongest) | Pinned-runner snapshot diff | Tolerance-window metric diff | Human playtest evidence |
| Physics correctness | Bitwise-cross-platform proof | Same-machine proof | Tolerance-only | Design-intent contract only |
| Multiplayer determinism | N-peer checksum equality (reuses replay exactly) | Pinned-runner only | Tolerance-window | Not supportable |
| Formal hardening scope | Full pure-sim slice | Pure-sim excluding physics FP | Algebraic properties only | Design-intent assertions only |

---

## 9. Asset Lane Design (Pure-Maximal)

### The locked decision

ASSET GENERATION IS PURE-MAXIMAL / LIGHTS-OUT: agents generate everything a game needs
with no mandatory human-in-loop finishing. However, the factory automatically captures
per-asset provenance/license metadata as data, and IP/quality/legal risks are recorded in
the risk register — documented, not used to impose human gates.

### Autonomous generation pipeline

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

### Automatic provenance metadata (mandatory, not optional)

Every generated asset receives an `asset-provenance-sidecar` at generation time:
- `generated_by_tool`: name, vendor, model/weights version
- `generation_date`: timestamp
- `prompt_and_inputs_log`: full prompt + reference inputs (required for USCO 2025 + Steam disclosure)
- `human_modifications_log`: empty at generation; populated if a human transforms the asset (enables partial copyright claim)
- `license_terms_snapshot`: commercial use, resale, attribution, indemnification tier
- `training_data_provenance`: licensed / open / unknown
- `likeness_consent_ref`: null for non-likeness assets; consent document ID for any voice/face (SAG-AFTRA ICDR requirement)
- `risk_tier`: 1/2/3 (drives tool selection policy; recorded, not gated)
- `copyrightability_assessment`: likely/partial/unlikely (US USCO 2025 / Thaler standard)

[generative-asset-ai.md §7.2; audio-discipline.md §6.9]

### Engine-agnostic asset interchange

Runtime delivery: **GLB (glTF 2.0)** as the canonical engine-neutral asset contract.
Pipeline backbone: **OpenUSD** for scene assembly, variants, DCC interchange (convert to
GLB for delivery). Legacy bridge: **FBX** only where a tool emits nothing better (convert
downstream). Baked vertex caches: **Alembic** for cloth/sim where skeletal animation fails
(Unity plugin gap noted).

Shader/VFX portability: no cross-engine standard exists (SPIR-V/WGSL are GPU-API, not
material, intermediates). The factory produces a `material.semantic` (engine-neutral PBR
metal-rough + constrained KHR extension set) → compiled to per-engine adapters (Unreal
Material Editor, Unity Shader Graph, Bevy WGSL) by the engine adapter's material compiler.
[art-pipeline.md §4, §5]

---

## 10. Scope Recommendation

Based on synthesis of all 8 AAA research vectors plus the existing product brief and
design decisions, the following scope boundaries are recommended for the product brief
rewrite:

### In Scope (v1)

- **Engine-adapter protocol** (JSON-RPC 2.0 over stdio; LSP-style lifecycle + capability negotiation; Decision 0002) for Bevy, Unity, and Godot
- **Conformance suite + reference mini-game** (founding pair Bevy + Unity; Godot as cheap third adapter)
- **Reused orchestration spine** extracted from vsdd-factory (dispatcher, hook chain, agent framework, state, workflows, PR/worktree lifecycle, adversarial review)
- **Game methodology layer**: simulation behavioral contracts + design-intent contracts + deterministic replay-regression harness + playtest protocol + asset lane + reshaped 9-dimension convergence model
- **All-genre core contract set**: genre-universal artifact schemas (design-spec, systems-spec, balance-data, economy-graph, level-spec, narrative-graph, loc-string-contract, audio-build-manifest, art-bible, game-production-plan, cross-discipline-dependency-contract)
- **Asset generation pipeline** (pure-maximal): asset-generation-request schema, asset-provenance-sidecar (mandatory), quality-gate harness, risk-tier routing policy; wraps mature generative APIs (Tripo/Rodin/Meshy/Hunyuan for 3D, Substance Sampler for materials, FLUX/Firefly for 2D, Houdini/PCG/SpeedTree/WFC for procedural, ElevenLabs/Stable Audio 2.5 for audio)
- **Det-sim genre pilot**: one reference game (factory/automation, roguelike, or deterministic RTS) using Bevy + Rapier (T1 determinism); proves the factory end-to-end with the strongest replay-regression guarantee
- **Cert pre-flight checklist engine** (55-80% machine-checkable per platform): crash/suspend-resume/save-atomicity/controller/shader/packaging gates for PlayStation, Xbox, Nintendo, Steam
- **Playtest protocol harness**: structured protocol templates, GEQ/PENS/SUS instrument scaffolding, 3-lens convergence dashboard; human sign-off gate (non-automatable by design)
- **Telemetry event taxonomy** + liveops runbook generation: event schema, KPI dashboard spec, crash-reporting wiring, feature-flag integration
- **Accessibility contract**: GAG/XAG feature matrix + CVAA checklist; partial auto-lint + checklist gate
- **Audio build automation**: Wwise WAAPI + WwiseConsole CLI + FMOD CLI wrappers; loudness/true-peak conformance (ITU-R BS.1770 / EBU R128); audio-provenance-ledger
- **Narrative graph tooling**: branch-reachability, dead-end detection, variable consistency, string-coverage, ICU placeholder validation, pseudo-loc overflow checks; adapters to Ink/Yarn/articy

### Out of Scope (v1)

- Building a game engine (game-factory orchestrates existing engines)
- Unreal Engine adapter (genuine Tier-3 outlier; deferred until protocol is proven on Bevy/Unity/Godot per product brief)
- Automatically scoring subjective fun (the playtest-satisfaction dimension is a human gate by design; no automated fun-score ever)
- Real-time multiplayer netcode as a shipped product feature (deterministic-lockstep/rollback concepts used internally for replay; server-authoritative multiplayer at scale is a later tier)
- MMO-scale dedicated-server orchestration / anti-cheat infrastructure
- Runtime generative NPC dialogue as a shipping feature (latency 3-7s, cost $150K-$1.8M/month at AAA scale, localization explosion — authoring assist only per narrative-localization.md §3)
- Console devkit access or submission lab testing (cert pre-flight is designed as a shift-left; final cert lab requires NDA'd platform access)
- Strand-based hair grooms for real-time gameplay (runtime cost is "extremely expensive"; hair-card default per art-pipeline.md §2.7)
- Full studio asset management backend (P4/Helix integration modeled logically in the orchestrator; backend selection is a deployment decision)
- LiveOps A/B experiment execution infrastructure (runbook generated as artifact; execution platform is an integration point, not built)
- AI music using uncleared generators (Suno/Udio are litigation-exposed; factory defaults to licensed/royalty-free providers per audio-discipline.md §3.1)

---

## 11. Genre Strategy

### All-genre core (the universal contract set)

Every genre has a "numeric/graph spine the factory can generate and verify, surrounded by
a subjective shell it cannot" (game-design-discipline.md §Genre Variation). The genre-
universal core captures the spine in machine-checkable contracts and routes the subjective
shell to human-judged convergence dimensions:

- Design-intent contract (invariant assertions only; explicit playtest delegation for the rest)
- Simulation behavioral contracts (economy, damage, state machines, AI)
- Narrative-graph schema (all narrative-bearing genres)
- Loc-string contract (all genres with text/UI)
- Audio build manifest (all genres)
- Asset-generation-request + asset-provenance-sidecar (all genres)
- Cert-preflight checklist (all genres × all target platforms)
- Playtest protocol (all genres; instrument selection varies by genre)

### Genre-parameterized surface

The following vary by genre and are expressed as genre-profile parameters:

| Parameter | Example variation |
|---|---|
| `dominant_contract_type` | Det-sim: simulation BC dominant; Narrative: narrative-graph + quest-schema dominant; Fighting: frame-data contract + rollback-determinism contract dominant |
| `determinism_tier_target` | Det-sim pilot: T1 (Bevy+Rapier); RTS/fighting: T1 or T2; open-world RPG: T2/T3 |
| `replay_strictness` | T1: exact snapshot-hash; T2: pinned-runner; T3: tolerance-window |
| `playtest_instruments` | Action/feel genres: GEQ competence/tension + biometrics; Narrative: think-aloud + GEQ immersion; Sandbox: PENS autonomy |
| `asset_style_profile` | Photoreal-PBR (highest automation); low-poly/voxel (high automation); stylized/hand-painted (lower automation, more human review) |
| `audio_profile` | Loudness target (-23/-18 LUFS); voice-count budget; spatial backend; AI-music policy (licensed-only for ship) |
| `loc_profile` | Multiplayer: continuous-loc CI + pseudo-loc mandatory; RPG: branch-reachability + cultural review + full VO |
| `cert_targets` | PC: Steam/EGS; console: TRC/XR/Lotcheck per platform |

### Det-sim pilot: why this genre first

Deterministic-simulation genres (factory/automation, roguelike, deterministic RTS,
management sim, card/deckbuilder, idle/incremental, puzzle) have the largest verifiable
spine and smallest subjective shell among all genres. Specifically:

- The economy/production graph is Machinations-native and simulatable (balance-data contract)
- All core loop state is serializable and diffable (simulation BC)
- T1 determinism is achievable with Bevy + Rapier (Decision 0003)
- Replay-regression is exact snapshot-hash diff — the strongest possible regression guarantee
- Procedural content (dungeon/room generation, item pools, meta-unlock graphs) is
  seed-deterministic and machine-checkable
- Platform cert is simpler (typically PC-first; no haptics/adaptive-trigger requirements)
- The subjective shell (run-to-run fairness feel, escalation sense) is narrow and well-defined
  for structured playtest

This choice maximizes reuse of vsdd-factory's existing verification machinery while proving
the full end-to-end pipeline. Every other genre is an extension of this foundation.

---

## 12. Risk Register

The following risks are RECORDED (documented, non-blocking per the pure-maximal decision).
Each carries a brief mitigation note and is logged for tracking, not for imposing human
gates.

| ID | Risk | Category | Likelihood | Impact | Mitigation Note |
|---|---|---|---|---|---|
| R-001 | **Fully autonomous AI assets may be uncopyrightable / public-domain in the US** (USCO Jan 2025 report; Thaler v. Perlmutter D.C. Cir. Mar 2025: human authorship required for copyright) | Legal / IP | HIGH (confirmed) | HIGH | Record human-modifications-log on every asset; auto-populate copyrightability-assessment field; assets with empty modifications-log flagged as "likely uncopyrightable" in provenance sidecar. Studio can elect to humanize Tier-2/3 assets if ownership matters. |
| R-002 | **Training-data indemnification gap**: most generative-3D and open image models offer no indemnification; residual training-data litigation risk stays with studio even for Firefly-covered output assets | Legal / IP | MEDIUM | HIGH | Tool-selection policy routes IP-sensitive assets to indemnified providers (Adobe Firefly for 2D/texture; enterprise vendors for 3D). Provenance sidecar records indemnification tier. Risk documented; studio legal team reviews Tier-2/3 asset classes. |
| R-003 | **AI music legal hazard**: Suno/Udio litigation ongoing (Sony holdout; fair-use ruling expected summer 2026); Warner/UMG settled but walled-garden; raw-generator AAA shipping is legally premature | Legal / Audio | HIGH | HIGH | Factory defaults to fully-licensed models (Stable Audio 2.5, AIVA, Soundraw) only. Suno/Udio classified as non-ship until litigation resolves. Sony fair-use ruling (summer 2026) is a monitoring trigger. Provenance sidecar records litigation-status field. |
| R-004 | **SAG-AFTRA 2025 IMA voice consent requirement**: any AI voice of a covered performer requires written, separately-signed, specific consent + compensation; 12+ states have independent right-of-publicity laws | Legal / Audio | HIGH (for named performer voice) | HIGH | Default ship path = human VO or Replica Studios / Respeecher (consent-framework providers). AI voice for placeholder/scratch/prototyping only (no ship gate). Provenance sidecar requires likeness-consent-ref for any voice asset; null = non-performed synthetic voice only. |
| R-005 | **Hero-character autonomous quality gap**: 3D + rig + animation + face simultaneously at AAA bar is not achievable autonomously today (auto-retopo unreliable on hero faces; hero facial rig human-craft; lead performance human-led) | Quality | HIGH | HIGH (for hero-tier assets) | Asset risk-tier system routes hero characters to Tier-3 (documented, not gated). Quality-gate report flags topology/rig issues. Studio can elect human finishing. Factory generates best-available asset; provenance sidecar records quality-gate-pass/fail. |
| R-006 | **Steam AI-content disclosure requirement** (Jan 17 2026 rewrite): AI-generated content that ships (art/sound/etc.) must be disclosed on store page; live-generated AI requires developer attestation | Legal / Platform | HIGH (confirmed) | MEDIUM | Provenance sidecars feed an automatic store-disclosure manifest (AI-content summary for Steam page). Traditional PCG is explicitly exempt; factory flags generated vs procedural per asset. |
| R-007 | **Shader / VFX non-portability**: no engine-agnostic material/particle standard exists; SPIR-V/WGSL/Slang are GPU-API, not material, intermediates | Technical | HIGH | MEDIUM | `material.semantic` → per-engine adapter architecture. This is a build task, not a risk blocker. Flag in asset-bible: shader portability requires per-engine material compiler. |
| R-008 | **Determinism is opt-in on every engine; Godot/Bevy have distinct non-determinism sources** (Bevy parallel ECS hash iteration, Godot FP physics) | Technical | MEDIUM | HIGH (for replay regression) | Decision 0003: tiered determinism. T1 (Bevy+Rapier) is the pilot target. T2/T3 engines degrade replay to tolerance-window. Non-determinism sources documented per engine; mitigation ladder in qa-testing-liveops.md §4.3. |
| R-009 | **LLM / AI summarizer confabulation on fast-moving engine APIs**: research pass documented ~10 confabulated Bevy APIs; deep-research fabricated Wwise/FMOD licensing models, animation tool versions, legal case names | Technical / Process | HIGH | HIGH | Factory rule: every engine API claim verified against version-tagged primary docs. AI summarizers are not authoritative for engine APIs. Provenance principle: all research findings must cite a primary URL or be explicitly flagged as unverified. |
| R-010 | **"Fun" cannot be auto-scored — optimization toward a scalar risks compulsion-loop design** | Product / Ethics | MEDIUM | HIGH | Playtest-satisfaction dimension is a human gate by construction. KPI dashboard spec labels retention/monetization metrics as "machine-verifiable health signals, NOT fun." Factory explicitly does not produce a fun-score; any agent or hook that emits one is a defect. |
| R-011 | **Cross-engine deep test tier is unbuilt for Godot/Bevy**: GameDriver = Godot Beta / no Bevy; AltTester Unreal support unverified | Technical | HIGH | MEDIUM | Factory builds its own deep tier from the replay spine for Godot/Bevy. Black-box agent (modl.ai-style) wraps the shallow universal tier. Bevy BRP is a standout introspection asset for the deep tier. |
| R-012 | **Cert % estimates are directional, not audited; cert frameworks version frequently** (XR v16.0 Nov 2025); exact TRC/Lotcheck content is NDA'd | Platform / Legal | MEDIUM | MEDIUM | Cert pre-flight built against public categories + each studio's own NDA'd checklist. Re-validated per submission cycle. Cannot be a one-time build. |

---

## 13. Open Questions for the Human / Architect

The following questions cannot be resolved from existing artifacts alone. They require
human decisions before the product brief rewrite can finalize.

**OQ-001 (Scope — BLOCKING for brief rewrite):** The current product brief explicitly
excludes "generating game assets (art/audio/models)." The pure-maximal lights-out asset
generation decision reverses this. Does the brief rewrite make asset generation a first-
class In-Scope item, or does it remain a planned future capability? If in-scope, what is
the v1 depth — full stack (all modalities) or a prioritized subset (3D + audio SFX first)?

**OQ-002 (Asset legal gate policy):** Pure-maximal means no mandatory human finishing gate.
However, the provenance sidecar flags risk tiers. Should Tier-3 assets (hero characters,
key art, any voice) trigger an optional human-review recommendation rather than a hard gate?
Or is even a recommendation out of scope in the pure-maximal model?

**OQ-003 (Middleware licensing for audio):** Wwise free tier covers small-budget productions
(full platform, unlimited sounds); paid tiers start at $8,000. FMOD free covers <$200k
revenue / <$600k budget. For the factory to generate Wwise/FMOD projects as artifacts,
does each generated game carry its own middleware license? Or does the factory target only
Godot native audio (royalty-free, full automation) for v1 with Wwise/FMOD as an optional
integration?

**OQ-004 (Large-binary VCS model):** The production-pipeline research recommends a
Perforce/P4-style logical model (exclusive locks on unmergeable binaries, narrow/per-agent
sync, stream-style branching) for asset management at scale. Does the factory build this
as a first-class subsystem (significant scope), wrap an existing backend (Perforce SaaS /
Diversion / Unity Version Control), or defer to a deployment decision?

**OQ-005 (Multiplayer scope clarification):** The engineering research recommends
deterministic-lockstep/rollback as the first-class multiplayer lane (reuses replay
machinery almost verbatim). Should this be explicitly In-Scope for v1 as an optional
capability gate (alongside single-player as the default), or remain Out-of-Scope per the
current brief?

**OQ-006 (Cert lab access):** The cert pre-flight engine covers 55-80% of certification
requirements (machine-checkable). The remaining 20-45% requires NDA'd platform docs and
devkit access. What is the factory's model for the remainder — partnership with cert labs,
documentation-stub that studios fill in, or explicit Out-of-Scope?

**OQ-007 (Style-profile depth in v1):** The art pipeline research identifies style as
structural (photoreal-PBR = highest automation; hand-painted/pixel/NPR = lowest). Should
v1 implement multiple style profiles (e.g., photoreal-PBR + low-poly), or a single pilot
profile aligned with the det-sim genre (low-poly/voxel is most appropriate for
roguelike/management sim)?

---

## 14. Traceability — Source Map

| Section | Primary sources |
|---|---|
| §1 Executive Summary | product-brief.md; architecture.md; vsdd-factory CLAUDE.md |
| §2 Dark Factory Foundations | product-brief.md §Overflow Context; architecture.md §Why a sibling; vsdd-factory CLAUDE.md |
| §3 vsdd Rigor Inventory | vsdd-factory CLAUDE.md (full); agents/ inventory; skills/ inventory |
| §4 Mechanism Mapping | game-design-discipline.md; engineering-disciplines.md; qa-testing-liveops.md; architecture.md; decisions/ |
| §5 New Agent Roles | production-pipeline.md §3; art-pipeline.md §7; audio-discipline.md §6; narrative-localization.md §7; generative-asset-ai.md §7; engineering-disciplines.md §8; qa-testing-liveops.md §10 |
| §6 Artifact Taxonomy | game-design-discipline.md §9; art-pipeline.md §7; generative-asset-ai.md §7; audio-discipline.md §6; narrative-localization.md §7; production-pipeline.md §8; qa-testing-liveops.md §10 |
| §7 Convergence Model | architecture.md §Convergence dimensions; qa-testing-liveops.md §8; vsdd-factory CLAUDE.md |
| §8 Quality-Model Delta | architecture.md §How the quality model changes; extraction-boundary.md; qa-testing-liveops.md §5; game-design-discipline.md |
| §9 Asset Lane | generative-asset-ai.md §2, §4, §5, §6, §7; art-pipeline.md §4, §8; audio-discipline.md §3 |
| §10 Scope Recommendation | All 8 research vectors; product-brief.md §Scope; engineering-disciplines.md §5; narrative-localization.md §3; audio-discipline.md §3.3 |
| §11 Genre Strategy | game-design-discipline.md §Genre Variation Matrix; engineering-disciplines.md §7; qa-testing-liveops.md §9; decisions/0003 |
| §12 Risk Register | generative-asset-ai.md §5; audio-discipline.md §3; art-pipeline.md §9; engineering-disciplines.md §10; qa-testing-liveops.md §12; RECONCILIATION.md §C.8 |
| §13 Open Questions | production-pipeline.md §10; audio-discipline.md §8; art-pipeline.md §9; engineering-disciplines.md §10 |
