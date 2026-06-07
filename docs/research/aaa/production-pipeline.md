---
document_type: research
vector: production-pipeline
version: "1.0"
status: draft
timestamp: 2026-06-07
title: "AAA Production, Pipeline & Multi-Studio Coordination — mapped onto a multi-agent game factory"
project: game-factory (Dark Factory for AAA game development)
sources:
  - https://www.bain.com/insights/squeezed-in-the-middle-aaa-gaming-studios-must-adapt-gaming-report-2025/
  - https://kevurugames.com/blog/game-development-team-structure-average-team-sizes-and-production-statistics
  - https://www.youtube.com/watch?v=YH5W-Eb7GRc  # cross-functional / catalyst team model
  - https://www.gameindustrycareerguide.com/how-to-become-a-video-game-graphics-programmer/
  - https://www.perforce.com/solutions/game-development  # P4 (formerly Helix Core), 19/20 AAA
  - https://www.prnewswire.com/news-releases/perforce-launches-saas-offering-of-helix-core-version-control-302036677.html
  - https://get.assembla.com/blog/git-vs-perforce-game-development/
  - https://www.anchorpoint.app/blog/git-vs-perforce-for-game-development
  - https://blog.rime.red/git-lfs-or-perforce-for-unreal-in-2024/
  - https://bespokeci.dev/perforce-vs-git/
  - https://www.perforce.com/blog/vcs/ue5-update-perforce-streams
  - https://blog.connecterapp.com/evolution-of-dam-in-the-game-development-industry-8abce9c35bb7
  - https://blog.runevision.com/2024/10/procedural-game-progression-dependency.html
  - https://gamingbolt.com/call-of-duty-modern-warfare-3-seven-studios-involved-in-development
  - https://www.callofduty.com/uk/en/blog/2026/06/call-of-duty-modern-warfare-4-dmz-deep-dive
  - https://www.perforce.com/customers/case-studies/vcs/ubisoft
  - https://www.signiant.com/resources/customer-stories/creator-of-worlds-how-signiant-helps-power-ubisofts-global-game-development/
  - https://pubsonline.informs.org/doi/10.1287/orsc.2016.1062  # Ubisoft "Always Playable" routines study
  - https://gdcvault.com/play/1035373/Streamlining-Game-Development-Building-a
  - https://www.gamedeveloper.com/business/ubisoft-is-dismantling-its-studio-ecosystem-to-become-a-more-gamer-centric-company
  - "The Game Production Toolbox — Heather Maxwell Chandler"
  - "Agile Game Development with Scrum — Clinton Keith"
  - https://askagamedev.tumblr.com/post/105543803526/what-is-the-average-team-size-for-developing-a-aaa
---

# AAA Production, Pipeline & Multi-Studio Coordination

> **Scope.** This report covers the *production vector* of AAA game development — studio anatomy, milestones, cross-discipline pipelines, version control / asset management at scale, and multi-studio coordination — and synthesizes how each decomposes into **agent roles**, **dependency contracts**, and **schedulable waves** for the game-factory orchestrator (which reuses vsdd-factory's dispatcher, agents, hook chain, state, workflows, and PR/worktree lifecycle).
>
> **Fast-moving flag.** Perforce rebranded *Helix Core → P4* and *Helix DAM → P4 DAM* (2024–2025). Diversion's feature set and Unity Version Control's positioning shift frequently. Studio org charts (Ubisoft "creative houses" reorg, 2025) are in flux. Verify product names and org structures at build time.

---

## 1. Executive Summary

AAA games are built by **federated programs**, not single teams: a lead studio owns vision + core tech, and a wider ring of internal partner studios + external vendors take **bounded slices** of content, features, ports, and support, all integrating into one shipping branch under shared conventions and a shared version-control depot. Two structural truths dominate and map cleanly onto a multi-agent factory:

1. **The industry has already moved from discipline silos to cross-functional, outcome-owned feature teams** (a "combat experience team," not "the animation team"), backed by a **catalyst/specialist pool** of scarce experts (shader, physics, narrative) that get "air-dropped" into feature teams on demand. This is *exactly* a studio-of-agents topology: persistent feature-team agent clusters + a shared specialist agent pool the orchestrator schedules.

2. **Production is run as agile-inside / milestone-outside.** Sprints and playable builds drive day-to-day work; a contractual milestone ladder (prototype → proof-of-concept → first playable → **vertical slice** → alpha/feature-lock → content-lock → beta → release candidate → gold → certification) gates funding, quality, and scope. **Vertical slice is the pivotal gate** — it is a *production* prototype proving the studio can build the game *repeatably* at quality/schedule/budget, not just that the idea is fun.

**Headcount reality (cross-validated):** Art 30–50%, Engineering 20–35%, QA 10–20%, Design 5–15%, Production 5–10% of team. Art is the largest cost center and the largest outsourcing surface — which tells the factory where to invest agent parallelism and where human-in-loop review concentrates.

**Top recommendation for the factory:** model the game production plan as a **DAG of discipline contracts scheduled in waves**, with a **Perforce/P4-style locking + narrow-sync asset model** for large binaries, a **DAM layer for asset discovery + "where-used" dependency propagation**, and **milestone gates as hook-enforced acceptance checks**. The cross-discipline dependency contract (design→art→audio→engineering→QA) is the central new artifact this vector demands.

---

## 2. AAA Studio Anatomy

### 2.1 Disciplines (five clusters)

| Cluster | Sub-disciplines / roles |
|---|---|
| **Creative / Content** | Concept art; environment art (modelers, prop, lighting); character art (modeler, texture, rigger, char-TA); animation; VFX; technical art (pipeline-TA, shader-TA, anim-TA, tools-TA); narrative design; audio (music, SFX, dialogue, implementation) |
| **Engineering** | Engine (core systems, platform, rendering); graphics/shaders; gameplay (combat, physics, systems); AI; networking/online; audio programming; tools/pipeline; **build & release engineering** |
| **Design** | Systems design; combat design; economy design; level design (mission, open-world, encounter); narrative design; **UX/UI** (interface, controls, accessibility) |
| **Production / Management** | Producers (associate → senior → exec); project/resource management; release management; certification owner; live-ops producer |
| **QA + Support** | Functional QA; compatibility; balance; localization; **accessibility**; narrative/audio QA; compliance/cert QA; playtest research; community; user research; data/analytics |

### 2.2 Headcount ratios (well-documented; cross-validated across two independent sources)

| Discipline | Share of team |
|---|---|
| Art (2D/3D/anim/VFX) | **30–50%** (largest) |
| Engineering | **20–35%** |
| QA | **10–20%** |
| Design | **5–15%** |
| Production / management | **5–10%** |

Scale: a "$50M-budget" AAA title runs ~100–200 in production; mega-budget franchises (GTA, Red Dead ~1,000, Assassin's Creed, Destiny) have no practical cap. Teams **swell after vertical-slice approval** (start ~20 in pre-production) and **scale down post-content-lock** — a critical signal for the factory's wave scheduler: parallelism should ramp at the same inflection point.

### 2.3 Organizational model: silos → cross-functional feature teams + catalyst pool

- **Old model:** discipline silos with sequential hand-offs (concept→model→rig→animate→integrate). Each hand-off loses intent and adds rework.
- **Modern model:** **feature/outcome teams** of ~5–9 spanning art+eng+design(+audio/narrative) owning a deliverable end-to-end (combat, enemies, missions/expeditions, meta/economy, foundations/tech, multiplayer). Teams are measured on **outcome quality**, not output volume.
- **Catalyst / specialist model:** scarce experts (advanced shaders, physics, narrative) are **shared resources air-dropped** into feature teams as needed, not embedded full-time. Central tech/art leadership enforces consistency via lightweight governance + standards.

> **Factory implication:** This *is* the multi-agent topology. Feature-team agent clusters = persistent worktree-scoped agent groups; the catalyst pool = a shared specialist-agent pool the orchestrator dispatches on demand; central governance = the hook chain + standards-validator agents enforcing cross-team consistency.

---

## 3. Discipline → Agent-Role Mapping (recommended)

Each discipline becomes one or more **specialized agents** with a typed input/output contract. Feature-team clusters bundle agents; the catalyst pool is shared.

| Discipline | Agent role(s) | Consumes (input contract) | Produces (output artifact) | Automatable today | Human-in-loop |
|---|---|---|---|---|---|
| **Creative direction** | `art-director`, `creative-director` (catalyst) | brief, pillars, references | art bible / style guide, visual targets | partial (synthesis) | **yes** — taste/IP sign-off |
| **Concept art** | `concept-artist` | brief, art bible | concept sheets (style, mood, silhouettes) | **high** (gen-AI) | review gate |
| **Environment art** | `env-modeler`, `prop-artist`, `lighting-artist` | concept, level greybox, budgets (poly/texel/LOD) | meshes, materials, lighting setups | high (gen + procedural) | quality review |
| **Character art** | `char-modeler`, `char-texture`, `char-rigger`, `char-TA` | concept, rig standard, skeleton spec | model, textures, rig, blendshapes | medium-high | rig validation |
| **Animation** | `animator`, `anim-TA` (catalyst) | rig, mocap/locomotion spec | anim clips, state machines, retargets | medium | feel/polish review |
| **VFX** | `vfx-artist` | gameplay events, budgets | particle systems, shaders | medium | review |
| **Technical art** | `pipeline-TA`, `shader-TA`, `tools-TA` (catalyst) | asset specs, engine constraints | shaders, export/import tools, validators | high | engineering review |
| **Audio** | `audio-designer`, `composer`, `audio-implementer` | events, narrative, scenes | SFX, music stems, middleware banks | medium | creative review |
| **Narrative** | `narrative-designer`, `writer` | premise, branching spec | script, dialogue trees, barks | high (LLM-native) | editorial gate |
| **Systems/Combat/Economy design** | `systems-designer`, `combat-designer`, `economy-designer` | pillars, metrics targets | tuning data, system specs, balance tables | high | playtest validation |
| **Level design** | `mission-designer`, `openworld-designer`, `encounter-designer` | systems, art kit, beats | greyboxes, encounter graphs, mission flow | high | playtest validation |
| **UX/UI** | `ux-designer`, `accessibility-designer` | flows, platform reqs | HUD, menus, control schemes, a11y options | high | usability review |
| **Engineering** | `gameplay-eng`, `engine-eng`, `graphics-eng`, `ai-eng`, `net-eng`, `tools-eng` (catalyst) | design specs, asset contracts | systems code, tools, integrations | high (vsdd spine) | code review (hook) |
| **Build & release** | `build-engineer`, `release-manager` | source + assets | cooked builds, packages, cert submissions | **high** | gold/cert sign-off |
| **QA** | `functional-qa`, `compat-qa`, `balance-qa`, `localization-qa`, `compliance-qa`, `accessibility-qa` | builds, test plans, TRC/TCR/XR | bug DB, triage, compliance reports | high | severity adjudication |
| **Production** | `producer`/orchestrator, `cert-owner`, `liveops-producer` | plan, dependency graph, milestones | schedules, wave plans, milestone gates | the orchestrator itself | program decisions |

**Mapping principles:**
1. **Producer = orchestrator.** The producer role is literally the dispatcher: it owns the dependency DAG, schedules waves, runs milestone gates, manages risk.
2. **Catalyst specialists = shared agent pool**, invoked across feature clusters rather than duplicated.
3. **Art is the parallelism sweet spot** (largest share, most outsourced, most gen-AI-tractable) — but also where review human-in-loop concentrates.
4. **Engineering rides the existing vsdd spine** (dispatcher/agents/hooks/PR-worktree) almost unchanged; the new work is the *content* disciplines and their contracts.

---

## 4. Production Milestones & Gates

Hybrid model: **agile sprints inside, contractual milestones outside.** Funding is released per accepted milestone — vague criteria cause disputes, so the factory must make acceptance **machine-checkable**.

| # | Milestone | "Done" / pass criteria | Key deliverable | Factory gate (hook-enforced) |
|---|---|---|---|---|
| 1 | **Prototype** | Core-loop assumptions validated; high-risk questions answered; throwaway OK | playable spike + learnings doc | `core_loop_validated == true` |
| 2 | **Proof-of-concept** | Tech + design + market feasibility proven at project-relevant scale | PoC build + feasibility/cost report | `feasibility_signed` |
| 3 | **First playable** | Core loop end-to-end in an integrated segment; identity legible | 1–2 levels, representative (not final) art/audio | `core_loop_e2e && identity_stated` |
| 4 | **Vertical slice** ⭐ | One slice at/near shipping quality across **all** major systems; **all pipelines exercised end-to-end**; throughput measured ("how long to build the 2nd thing") | polished slice + pipeline docs + revised schedule | `all_pipelines_exercised && quality_bar_met && throughput_measured` |
| 5 | **Alpha / feature-lock** | All features implemented + integrated; game playable start→finish (rough); **no new features after this** | feature-complete build + triaged bug DB | `feature_complete && playable_e2e && feature_lock` |
| 6 | **Content-complete / content-lock** | Every planned level/mission/cutscene present + accessible; no placeholders in main path | content-complete build + content inventory | `content_inventory_complete` |
| 7 | **Beta** | Content + features at near-shippable quality; only fixes/tuning/polish remain; external test-ready | beta build + bug metrics + balance data | `content_lock && stability_threshold` |
| 8 | **Release candidate** | No known shipping blockers; perf/memory within budget; loc complete | RC build per platform | `zero_blockers && perf_budget_met` |
| 9 | **Gold master** | All critical/high bugs resolved-or-accepted; platform reqs satisfied; ready to submit/manufacture | gold binaries + known-issues list | `release_criteria_pass` |
| 10 | **Certification (cert)** | Passes platform TRC (Sony) / TCR (Microsoft) / XR–Lotcheck (Nintendo) | cert submission package + compliance results | `cert_checklist_pass` (shift-left from alpha) |

**Critical insights for the factory:**
- **Vertical slice is the load-bearing gate.** It is the moment the factory proves its *own pipeline throughput* — measure "time to build the second thing" and feed it back into the wave scheduler's estimates. Overproduced vertical slices (bespoke hacks that don't scale) are the recurring cautionary tale; the factory must validate the slice was built with **production pipelines**, not one-off hacks.
- **"Code-complete" is a "polite fiction"** — prefer "done-done-done" (implemented + tested + deployable). The factory should never gate on "code written"; gate on integrated, tested, playable functionality.
- **Certification must shift-left** — bake TRC/TCR/XR checks into QA agents from alpha onward, with a dedicated `cert-owner` agent tracking the evolving rulebook. Don't tack it on at gold.

---

## 5. Cross-Discipline Dependency & Pipeline Model

### 5.1 The content pipeline (the canonical dependency chain)

```
brief/pillars
   → creative direction (art bible, pillars)
      → concept art
         → 3D modeling → rigging → animation
                       → texturing → materials
            ↘ (parallel) audio design / VFX / narrative
               → engine integration (cook/bake)
                  → QA (functional + compliance)
                     → milestone gate
```

Design feeds art **and** engineering; art feeds engineering; audio/narrative run partly in parallel but depend on scenes/events from design+engineering; QA consumes everything. **Changes propagate downstream** via the dependency graph: change a shared material → re-cook dependents; change a rig → re-export + re-import all dependent animations; change a gameplay system → recompile/validate dependent blueprints/prefabs.

### 5.2 Build pipeline at scale

- **Asset cooking/baking:** transform source assets → platform-optimized engine-ready formats (mesh/LOD optimization, texture compression BCn/ASTC + mips, lightmap/GI bake, audio/anim/shader compilation). In **Unreal**, cooking → pak files; the **Derived Data Cache (DDC)** stores intermediate results (compiled shaders, compressed textures) so the team reuses one person's bake.
- **Incremental builds:** only changed items + their dependents rebuild (driven by the dependency graph + DDC).
- **Build farms / distributed compile:** **Incredibuild**, **FASTBuild** parallelize C++ compile (and some asset processing) across clusters.
- **CI orchestration:** Jenkins/TeamCity/custom → compile + multi-platform cook + automated tests. **Nightly builds** = full multi-platform packages off integration branch, the stable QA + profiling baseline.

> **Factory implication:** The factory's hook chain already does CI-style gating. Add **asset-aware incrementality** — the orchestrator must own a dependency graph so it only re-runs the *affected* agents/cooks when an upstream artifact changes, and a **shared derived-data cache** so agent-produced bakes are reused across waves.

---

## 6. Asset & Version-Control Management at Scale

### 6.1 Recommendation for large binaries: Perforce/P4-style centralized model (validated)

**Perforce P4 (formerly Helix Core) is the de-facto AAA standard — used by 19 of the top 20 AAA studios** (Perforce's own materials + independent hosts; cross-validated across ≥4 sources). It wins for binary-heavy, multi-TB/petabyte, thousand-user pipelines because:

| Property | Why it matters for AAA | Git + Git-LFS comparison |
|---|---|---|
| **Centralized single source of truth** | Producers/build/QA want one canonical depot; artists sync only what they need | Git is distributed = full clones, slow/costly at hundreds of GB–TB |
| **Exclusive file locking (first-class)** | Unmergeable binaries (Maya .mb/.ma, level/material/rig files) — without locking, concurrent edits silently lose work | Git-LFS locking is a bolt-on extension; discipline/host support varies |
| **Streams** | First-class branching with workspace views + "merge-down/copy-up" flow; used by Epic for UE5 | Git branching flexible but no enforced flow/stream-type for huge binary repos |
| **Scale** | Markets 10,000+ concurrent commits, thousands of users, petabytes | Viable with sparse-checkout + tuning, but higher-maintenance at true AAA scale |
| **Narrow/partial sync default** | "Choose a stream → get just your files" is operable by non-technical artists | Git sparse-checkout/partial-clone more complex, fragile with LFS |

**Alternatives & where they fit:**
- **Git + Git-LFS** — pointers for large files on an LFS server; viable for small/mid teams and code-heavy projects staying in the Git/DevOps ecosystem; higher-maintenance at AAA binary scale.
- **Diversion** — Perforce-style UX + locking + narrow sync over a Git/LFS backend; bridge for teams wanting Git infra with artist-friendly workflows. *(Public docs sparse — verify current features with vendor; partly inferred.)*
- **Unity Version Control (formerly Plastic SCM)** — large-binary + locking + partial workspaces as core design goals; strong for Unity-centric studios; growing AA/large-indie adoption but not at Perforce's AAA dominance.

**Factory recommendation:** adopt a **Perforce/P4-style logical model** for the asset substrate — *exclusive locks on unmergeable binaries, narrow/per-agent sync, stream-style branching, single canonical depot* — regardless of the literal backend. The vsdd spine's PR/worktree lifecycle handles code (Git-native); **content needs a locking + narrow-sync layer** the orchestrator owns so two content-agents never silently clobber the same binary.

### 6.2 DAM (Digital Asset Management)

A **DAM** catalogs non-code assets (models, textures, anims, audio, VFX, UI, marketing) with metadata, preview, search, **"where-used" queries**, and review/approval workflows — typically *on top of* the VCS. **P4 DAM (formerly Helix DAM)** sits on P4; third-party DAMs (e.g., Connecter) integrate with DCC tools.

> **Factory implication:** The DAM is the **asset registry + dependency index** the orchestrator queries to (a) discover/reuse existing agent-produced assets, (b) run "where-used" to compute downstream re-cook/re-validate fan-out, and (c) drive review-gate workflows. The dependency graph (design→art→audio→eng) is materialized here.

---

## 7. Multi-Studio Coordination Patterns

Both **Call of Duty** and **Assassin's Creed** run as **federated programs**: lead studio(s) own vision + core tech; satellite internal studios + vendors take bounded slices under shared conventions and one shipping branch.

- **Call of Duty:** lead studio (Infinity Ward / Treyarch / Sledgehammer) + support studios (Raven, Beenox, High Moon, Demonware for backend/services). MW3 publicly credited **seven studios**; MW4 "led by Infinity Ward with support from High Moon, Raven, Sledgehammer, Treyarch." Implies a **centralized standards layer** — shared engine/build, common asset conventions, strict integration milestones so multi-studio work lands in one branch.
- **Assassin's Creed / Ubisoft:** explicit **hub-and-spoke** — some studios specialize in **tech/engine** (e.g., Winnipeg), others in content; coordination across **2,000+ developers** on a **scalable VCS** (Perforce case study) + high-intensity global transfer tooling (**Signiant**). The "Always Playable" study documents deliberate **recombination of routines/artifacts** to balance efficiency vs flexibility. (Ubisoft is reorganizing into "creative houses" — structure in flux.)

**What gets outsourced** (industry-standard, inferred from coordination infra): environment + character art, animation/mocap cleanup, cinematics, QA, porting/platform adaptation, co-development of bounded feature slices or content tranches. Art is the dominant outsourcing surface.

**How hand-offs are managed** (the spec layer that makes vendor work integrable):
- standardized **3D content conventions** + **data-exchange protocols** (directly sourced);
- **asset naming conventions**, file-format + **scale/unit** rules, **poly/texel/LOD budgets**, **rig/skeleton rules**, export/import rules, **technical art-direction notes**, **milestone acceptance criteria**, **engine-import + in-game-behavior validation checklists** (industry-standard practice; exact titles not attributed to a specific franchise in available sources).
- All backed by **version-control integration** so external work lands in the canonical depot, and **change-control around shared engine branches** with integration gates + cross-site syncs.

> **Factory implication:** A "studio" in the factory = a **scoped agent cluster** (own worktree/stream, own budget envelope, own slice of the dependency DAG). The hand-off spec layer = the **cross-discipline dependency contract** (below). The orchestrator is the cross-studio producer: it owns the integration gates and resolves blockers before they hit mainline. Multi-studio coordination and multi-agent orchestration are the *same problem* — bounded slices + shared conventions + integration gates + a single canonical depot.

---

## 8. Factory Artifacts / Contracts This Vector Implies

### 8.1 Game Production Plan (the master artifact)
A machine-readable plan the orchestrator schedules. Sketch:
```yaml
production_plan:
  title, pillars, target_platforms, quality_bar
  milestones: [prototype, poc, first_playable, vertical_slice, alpha,
               content_lock, beta, rc, gold, cert]   # each w/ pass_criteria
  studios:            # scoped agent clusters
    - id, scope (DAG-subgraph), stream/worktree, budget_envelope, vendor?:bool
  dependency_graph:   # the DAG of discipline contracts (see 8.3)
  waves:              # orchestrator-computed schedule
    - wave_n: [agent_tasks...]  # respecting dependency edges + locks
  risk_register:      # see 8.5
  acceptance_gates:   # hook-enforced per milestone
```

### 8.2 Milestone Gate (hook-enforced)
Each milestone = a hook-checkable predicate set (Section 4, last column). Vertical-slice gate additionally asserts **pipelines exercised end-to-end** and **throughput measured** (anti-"bespoke-hack-slice" check).

### 8.3 Cross-Discipline Dependency Contract (the central new artifact)
A typed contract per edge in the design→art→audio→eng→QA DAG. Per contract:
```yaml
dependency_contract:
  producer_discipline, consumer_discipline
  artifact: {type, format, naming_convention}
  spec:        # the hand-off specification
    budgets: {poly, texel, lod, memory}
    rig/skeleton_rules, scale_units, export_import_rules
    tech_art_direction_notes
  acceptance_criteria: [...]      # machine-checkable
  validation_checklist: [...]     # engine-import + in-game behavior
  on_change: re_cook|re_export|re_validate downstream   # propagation rule
```
This doubles as the **vendor/external-studio hand-off contract** and the **inter-agent interface**.

### 8.4 DAM Model (asset registry + dependency index)
```yaml
asset_record:
  id, type, version, author_agent, status (draft|review|approved)
  metadata: {tags, license, source_studio}
  storage: {stream/depot_path, lock_holder?}   # Perforce-style locking
  where_used: [downstream_asset_ids]            # propagation fan-out
  review_workflow: {gate, approver}
```

### 8.5 Risk / Dependency Register
Per-studio dependency ownership, integration-gate status, change-control on shared branches, blocker escalation — the orchestrator's program-management state.

---

## 9. AAA Acceptance Bar

A "AAA quality" gate the factory must enforce, not just "it runs":
- **Vertical slice proves repeatable production** — built with real pipelines, throughput measured, not one-off hacks.
- **Feature-lock at alpha; content-lock before beta** — strictly enforced; no feature creep past alpha.
- **"Done-done-done"** (implemented + tested + deployable) — never gate on "code written."
- **Cert shifted left** — TRC/TCR/XR compliance validated from alpha, owned by a `cert-owner` agent.
- **Cross-discipline coherence** — visual/audio/code consistency enforced by catalyst-governance agents + the hook chain (the "single art bible / single tech standard" function).
- **Perf/memory within platform budget** at RC; localization + accessibility complete; **zero known shipping blockers** at gold.

---

## 10. Open Questions & Risks

1. **Locking layer for content.** vsdd's Git-native PR/worktree lifecycle handles code; **unmergeable binaries need an exclusive-lock + narrow-sync layer**. Build (Perforce-style) vs wrap (Diversion/UVC/Git-LFS-locks) is an open architecture decision. *(Recommend: model the locking semantics in the orchestrator regardless of backend.)*
2. **Automatable-today vs human-in-loop boundary.** Art/narrative/design generation is increasingly LLM/gen-AI-tractable; **taste, IP, and feel sign-offs remain human**. Where exactly the review gates sit per discipline needs calibration against the AAA acceptance bar.
3. **Vertical-slice throughput as a first-class metric.** The factory's wave estimates depend on measuring "time to build the second thing." How is this instrumented across heterogeneous content agents?
4. **Derived-data / asset cache.** A shared cook/bake cache (Unreal DDC analog) is implied for incremental re-runs — does the factory build one or wrap engine-native DDC?
5. **Sourcing gaps (flagged inconclusive):** exact franchise-specific hand-off *document titles/templates* (asset spec, tech-art-direction doc, validation checklist) are **industry-standard but not directly attributed** to CoD/AC in available sources — inferred from the coordination infrastructure (shared conventions, protocols, VCS, transfer tooling). Internal multi-studio *operating models* are largely non-public.
6. **Org-structure churn.** Ubisoft "creative houses" reorg and industry-wide 2024–2026 layoffs mean the *org* mapping is a moving target; the *functional* discipline→agent mapping is more stable.

---

## 11. Sources

See YAML frontmatter `sources` for the full URL list. Key load-bearing citations:
- **Headcount ratios** (cross-validated): Kevuri Games team-structure breakdown; deep-research synthesis (Art 30–50% / Eng 20–35% / QA 10–20% / Design 5–15% / Prod 5–10%); Ask-a-Game-Dev on team swell at vertical slice.
- **Cross-functional + catalyst team model:** GDC-style talk (YouTube YH5W-Eb7GRc); Bain "Squeezed in the Middle" 2025.
- **Milestones / methodology:** Chandler *Game Production Toolbox*; Keith *Agile Game Development with Scrum*; Deviant Legal milestone-schedule analysis; Pingle/GameMaker pipeline overviews; iXie console-compliance/cert guidance.
- **Version control (cross-validated, ≥4 sources):** Perforce game-development page + PRNewswire (19/20 AAA, P4/Helix rebrand, petabytes); Assembla, Anchorpoint, rime.red, bespokeci Git-vs-Perforce comparisons; Perforce UE5 Streams blog.
- **DAM / dependency graphs:** Connecter DAM evolution; P4 DAM; Rune Skovbo Johansen dependency-graph article.
- **Multi-studio:** GamingBolt (MW3 seven studios); CoD MW4 blog; Perforce Ubisoft case study (2,000+ devs); Signiant Ubisoft transfer story; INFORMS "Always Playable" Ubisoft routines study; GDC streamlining-pipeline talk; GameDeveloper Ubisoft creative-houses reorg.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 4 | Deep multi-source synthesis: (1) studio anatomy/roles/headcount, (2) milestones & methodology, (3) pipeline/asset-mgmt/version-control, (4) multi-studio coordination & outsourcing |
| Perplexity perplexity_ask | 2 | Focused syntheses of the two largest deep-research outputs (version-control/DAM/build pipelines; multi-studio coordination) with high search context |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Context7 | 0 | No library-API questions in this production/process vector |
| Tavily tavily_search | 2 | Cross-validated headcount ratios + Perforce "19/20 AAA" claim against independent sources |
| Tavily tavily_extract | 0 | — |
| WebFetch / WebSearch | 0 | — |
| Training data | 2 areas | Diversion feature specifics (sparse public docs — flagged inferred); generic agile/SDLC framing (corroborated by sourced material) |

**Total MCP tool calls:** 8 (4 perplexity_research + 2 perplexity_ask + 2 tavily_search)
**Training data reliance:** low — every load-bearing claim is web-sourced; the two flagged areas (Diversion specifics, generic agile framing) are explicitly marked as inferred/corroborated. Two headline claims (headcount ratios, Perforce 19/20) independently cross-validated via Tavily.
