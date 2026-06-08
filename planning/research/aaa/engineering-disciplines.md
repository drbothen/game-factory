---
document_type: research
vector: engineering
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
sources:
  # Networking frameworks (well-cited, primary repos/docs)
  - https://docs.unity3d.com/Packages/com.unity.netcode.gameobjects@latest/
  - https://www.photonengine.com/quantum
  - https://heroiclabs.com/docs/nakama/getting-started/architecture/
  - https://github.com/cBournhonesque/lightyear
  - https://github.com/gschup/bevy_ggrs
  - https://www.hankruiger.com/posts/adding-networked-multiplayer-to-my-game-with-bevy-replicon/
  - https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
  - https://johanhelsing.studio/posts/extreme-bevy
  - https://yal.cc/preparing-your-game-for-deterministic-netcode/
  - https://ruoyusun.com/2019/03/29/game-networking-2.html
  # Determinism & lockstep (prior-art canon)
  - https://gafferongames.com/post/deterministic_lockstep/
  - https://rapier.rs
  # Headless logic testing (real, verified)
  - https://docs.unity3d.com/Packages/com.unity.test-framework@2.0/manual/edit-mode-vs-play-mode-tests.html
  - https://dev.epicgames.com/documentation/unreal-engine/gauntlet-automation-framework-in-unreal-engine
  - https://github.com/bitwes/Gut
  - https://bevy-cheatbook.github.io/patterns/system-tests.html
  - https://saltares.com/run-automated-tests-for-your-godot-game-on-ci
  - https://www.gamedeveloper.com/programming/separation-of-gameplay
  # AI / navmesh / behavior trees (real libraries)
  - https://github.com/behaviortree/behaviortree.cpp
  - https://github.com/recastnavigation/recastnavigation
  - https://lisyarus.github.io/blog/posts/behavior-trees.html
  # Architecture (ECS)
  - https://github.com/sandermertens/flecs
  - https://github.com/skypjack/entt
  - https://discussions.unity.com/t/unit-test-with-dots-project/770264
  # Performance & profiling
  - https://unity.com/how-to/best-practices-for-profiling-game-performance
  - https://thegamedev.guru/unity-performance/draw-call-optimization/
  - https://docs.flaxengine.com/manual/editor/profiling/tracy.html
  - https://developer.nvidia.com/blog/in-game-gpu-profiling-for-dx12-using-setbackgroundprocessingmode/
  - https://forums.unrealengine.com/t/community-tutorial-performance-profiling-with-unreal-insights-basics
  # Certification / AAA bar
  - https://learn.microsoft.com/en-us/gaming/gdk/docs/store/policies/console/console-certification-requirements-and-tests?view=gdk-2604
  - https://www.ixiegaming.com/blog/console-compliance-testing/
  - https://nintendo.fandom.com/wiki/NOA_Lot_Check
  - https://pinglestudio.com/blog/porting/standards-of-game-platforms-you-should-know-before-porting-playstation
  # Market / cost context
  - https://unity.com/resources/gaming-report
  - https://www.statista.com/statistics/259577/us-single-player-vs-multiplayer-frequency-among-gamers/
  - https://www.yudiz.com/insights/cost-of-multiplayer-game-development/
  - https://vsquad.art/blog/what-is-a-aaa-game-the-reality-of-the-aaa-game-budget
---

# AAA Engineering & Technical Disciplines — Factory Vector Research

> **Vector:** Engineering & technical disciplines of the *game code itself* (gameplay,
> rendering, physics, AI, networking, tools, build/platform, performance) — distinct
> from the factory's own orchestration infra. **Builds directly on** the capability-axis
> research already in `planning/research/{bevy,unity,godot}-capabilities.md` and the design
> decisions in `planning/design/` and `planning/decisions/`. Where this report touches the eight
> protocol capabilities (build/test/replay/capture/introspect/determinism), it defers to
> those files and does not re-derive them.
>
> **Research-quality warning (READ FIRST).** The deep-research pass on the *disciplines
> overview* produced a heavily synthesized, largely **uncited** answer with several
> **confabulated tool names** ("GauntletCE", "Project Genesys Test", "ServerGhost",
> "Tree Designer Pro", "GoalState Validator", "AI Director Tester", "Determinism
> Debugger", "Material Quality Manufacturing"). Its numeric coverage percentages
> ("95% automatable", "35% of rendering automatable") are **model estimates, not measured
> data** — they are used here only as **directional ordering**, never as ground truth.
> Every load-bearing tool/claim below was cross-checked against the *well-cited*
> networking, performance, and certification passes (which cite real repos/docs). Tools
> are only named here if a primary URL was verified. **Fast-moving areas are flagged.**

---

## 1. Executive Summary

The central finding for the factory is that **AAA game engineering splits cleanly into
three testability tiers**, and the split is *architectural, not aesthetic* — it follows
the boundary between simulation state and pixels, which the factory can exploit directly:

1. **Cleanly contract-testable headless (no GPU, deterministic):** gameplay systems
   (economy, damage, inventory, abilities, state machines), **simulation-side physics**
   (collision/rigid-body *numerics*, given fixed-point or pinned FP), **symbolic game AI**
   (behavior trees, GOAP, utility scoring, A*/navmesh *graph* queries), and the
   **state-synchronization core of networking** (lockstep/rollback determinism, predict/
   reconcile convergence). These reduce to `assert`-style behavioral contracts over
   serialized world state and are runnable in CI by the thousand. This is the factory's
   strongest, largest territory — and it maps directly onto VSDD's existing
   Behavioral-Contract machinery.

2. **Measurable headless but tolerance/hardware-qualified:** performance budgets
   (frame-time of CPU-bound systems, memory high-water-mark, **draw-call/batch counts** —
   the *logical* count, not GPU time), and **tolerance-tier physics/AI** on engines
   without bitwise determinism. Automatable as **threshold gates**, but the threshold
   must be declared against a pinned runner (ties directly to the existing
   `determinism_tier` and `execution_profiles` capability fields).

3. **Needs a GPU / playable build / is subjective:** rendering & graphics output (final
   pixels, lighting/GI look, shader *visual* correctness, temporal stability), GPU
   frame-time, "game feel," fun, balance-as-experienced, and editor/tooling UX. These
   fall to the **Design-Intent-Contract + playtest-protocol** lane (already defined in
   `architecture.md`) plus golden-image diffing on the `render` execution profile.

Three scope decisions fall out of this for the brief expansion:

- **Networking/multiplayer should be IN SCOPE but TIERED, not default-on.** Multiplayer
  carries a verified **2.5–5× cost/risk multiplier** (yudiz; Unity 2026 report), yet
  the *deterministic-lockstep/rollback* family (Photon Quantum, `bevy_ggrs`, Fusion
  rollback) is **uniquely factory-friendly**: it demands the exact same fixed-tick +
  seeded-RNG + input-injection discipline the replay-regression model already requires,
  and it tests **headless with in-process virtual clients**. Recommendation: support
  single-player as the default lane; offer deterministic-lockstep/rollback as a
  *first-class, well-tested* multiplayer lane; treat large-scale server-authoritative
  replication (Nakama-class dedicated servers, MMO scale) as a later, human-in-loop tier.

- **Rendering is a gate, not a generator-target, for v1.** The factory can *verify*
  rendering against budgets and golden images, and *generate* shaders/materials as
  artifacts, but final visual acceptance stays human-in-loop (Design-Intent Contract).

- **The AAA acceptance bar is partly a hard, automatable spec** (platform certification —
  crash-free, suspend/resume, save-data integrity, controller hot-plug, error messaging —
  is a concrete checklist from Microsoft GDK / Sony TRC / Nintendo Lotcheck) **and partly
  subjective** (polish, feel). The automatable half is a major factory artifact: a
  **certification-conformance contract suite** distinct from gameplay tests.

---

## 2. Engineering Discipline Breakdown

Each discipline below is tagged with its **testability tier** (Headless-Contract /
Tolerance-Threshold / GPU-or-Subjective) and its **automate-today vs human-in-loop**
posture, framed for what the factory must *produce* (artifacts) and *check* (contracts).

### 2.1 Gameplay Programming & Game Systems — `Headless-Contract` (strongest fit)
Covers economy/resource flows, damage/combat math, inventory & item rules, ability/skill
systems (cooldowns, resource cost, timing), and gameplay state machines (combat ↔ explore
↔ dialogue). **Correctness is internal data consistency, not pixels** — a damage number
is correct when the underlying health delta matches spec, with no display needed.

- **Contract-ability:** very high. Economy → conservation invariants ("gold never
  decreases without a matching debit"); damage → input→output matrices + property-based
  testing over modifier permutations; inventory → save/load round-trip binary-equivalence;
  abilities/state machines → event-sequence tests asserting only legal transitions, no
  deadlocks. These are precisely VSDD Behavioral Contracts.
- **Automate today:** the large majority of *technical* correctness. **Human-in-loop:**
  whether the (correct) numbers are *fun/balanced* — that is the Design-Intent Contract +
  playtest lane.
- **Real tooling:** engine-native test frameworks (Unity UTF EditMode, `cargo test` on
  Bevy systems, GUT for Godot) + standard property-based testing libs. *(The overview
  pass's "StateSmith/YarnSpinner as test generators" and genetic-algorithm test-evolution
  claims are unverified — treat as aspirational.)*

### 2.2 Engine/Runtime Architecture — `Headless-Contract` (and a testability *lever*)
The ECS/data-oriented vs OOP-actor/node choice (detailed in §3). Key factory finding:
**architecture is not just a thing to test — it is a lever on how testable everything
else is.** Data-oriented separation of data (components) from behavior (systems) makes
game logic into pure-ish functions over state, which is *inherently* more unit-testable
and more naturally deterministic. This is corroborated by Bevy's documented system-test
pattern (bevy-cheatbook) and Unity DOTS unit-testing threads.
- **Automate today:** system-ordering/scheduling invariants, archetype/query correctness,
  data-transformation determinism. **Human-in-loop:** complex multi-system concurrency
  timing under real load.

### 2.3 Rendering & Graphics Programming — `GPU-or-Subjective` (weakest fit)
Render pipelines, shaders, lighting/GI, post-processing, anti-aliasing, LOD/culling.
This is the discipline most resistant to machine-checkable contracts: identical inputs
produce *different* outputs across GPU vendors/drivers/FP, and final acceptance is a
perceptual/artistic judgment.
- **Partially contract-able:** *algorithmic* sub-stages — frustum/occlusion-cull math,
  vertex-skinning/transform matrices, shader *compilation* success — validate headlessly
  against ground truth. *Visual* correctness needs a GPU (render execution profile) +
  **golden-image / perceptual-diff** (SSIM-class) with tolerance bands; it remains
  flaky across hardware.
- **Automate today:** regression-catching (golden image on a pinned GPU runner), budget
  enforcement. **Human-in-loop:** artistic intent, "does it look right." Maps to the
  factory's `capture` capability + Design-Intent Contract; **do not** make pixel-perfect
  output a generation target in v1.

### 2.4 Physics Simulation — `Headless-Contract` *if* determinism is engineered, else `Tolerance-Threshold`
Collision detection, rigid-body dynamics, constraints/joints, cloth/soft-body. The
numerics are deterministic *math*, which is highly contract-able **headless on CPU**
(energy/momentum conservation within tolerance, collision normals vs analytic ground
truth, bit-identical trajectories under controlled FP). **But** this is gated entirely by
the **determinism tier already decided in Decision 0003**: Rapier = bitwise-cross-platform
(exact hash-diff contracts); PhysX = same-machine only; Godot/Jolt = tolerance-only.
GPU-accelerated physics drops to tolerance-or-worse.
- **Automate today:** CPU-solver behavioral contracts, determinism-tier conformance.
  **Human-in-loop:** "feels wrong despite being mathematically correct" plausibility.
- This report **reinforces, does not modify**, Decision 0003. The new framing: physics
  has *layered* contracts — bitwise (network-critical), tolerance (visual), behavioral
  (gameplay) — and the factory picks the layer by declared tier.

### 2.5 Game AI — split by paradigm
- **Symbolic AI (behavior trees, GOAP, utility AI) → `Headless-Contract`.** BT execution
  validates against the designer's decision graph (all condition nodes evaluated,
  composites sequence correctly, blackboard consistency); GOAP planners check optimal
  action-sequence vs reference solution; utility AI validates *selection distributions*
  statistically. Pathfinding/navmesh is *coordinate data, not rendered paths* → A*
  optimality + collision-free path contracts. **Real, verified libraries:**
  `behaviortree.CPP`, `recastnavigation` (Recast/Detour), Unity NavMesh, Unreal Behavior
  Trees. All testable headless.
- **ML agents (RL/NN policies) → `GPU-or-Subjective`.** Emergent, resist formal spec;
  guardrail/regression-style checks only. Unity ML-Agents is real but Unity-only and
  training-heavy; **out of scope for early factory generation**, candidate for synthetic-
  playtest *tooling* later.

### 2.6 Networking & Multiplayer — split by architecture (see §5 for scope decision)
- **Deterministic lockstep / rollback (Quantum, `bevy_ggrs`, Fusion rollback) →
  `Headless-Contract`, exceptionally well-fit.** Only inputs cross the wire; each peer is
  the same deterministic sim consuming the same input stream → you can run **N virtual
  clients in one process**, feed a recorded input log, and assert identical frame
  checksums. This *is* the replay-regression harness with extra peers.
- **Client-server replication (Netcode for GameObjects/Entities, Lightyear,
  bevy_replicon, Godot MultiplayerSynchronizer, Nakama) → `Tolerance-Threshold` to
  `Headless-Contract`.** Predict/reconcile convergence and replication correctness test
  headless with in-process server+client worlds and **injected latency/jitter/loss**
  (Unity Network Simulator, Lightyear's link conditioner). Large-scale (hundreds of
  clients, MMO) and anti-cheat/security stay human-in-loop.

### 2.7 Tools & Editor Programming — `GPU-or-Subjective` (mostly out of scope)
Custom editors, inspectors, content pipelines. Logic *under* a tool can be unit-tested;
the **editor UX itself is interactive and subjective**. The factory's relationship to
editors is via `introspect` (scene-graph/ECS dump) and `assets_validate`, already
specified. Recommendation: the factory **consumes** editor introspection, does not
**generate** editor tooling in v1.

### 2.8 Build Systems & Platform/Console Abstraction — `Tolerance-Threshold` (highly automatable)
Headless/CI builds, multi-platform packaging, console abstraction. This is **already
solved per-engine** (prior-art: GameCI, godot-ci, UAT, Cargo) and wrapped by the adapter
`build` capability. The net-new factory contribution is the **platform-certification
conformance suite** (§7, §8) — the machine-checkable subset of TRC/XR/Lotcheck.

### 2.9 Performance Budgets & Profiling — `Tolerance-Threshold` (see §6)
Frame budget, memory, draw calls. **The CPU-bound and logical-count metrics are
CI-automatable; GPU-time is not** without target hardware. This is a *threshold-gate*
discipline, mapping to the existing `frame-budget` convergence dimension.

---

## 3. ECS / Architecture Variation Across Engines

The founding engine pair (Decision 0001) deliberately spans the architectural extremes,
and that contrast directly shapes headless logic-testability:

| Engine | Model | Data↔behavior separation | Headless logic-test ergonomics | Determinism control |
|---|---|---|---|---|
| **Bevy** | **ECS (data-oriented)** | Strong — components are plain data, systems are functions | **Best.** `App::new()` → add systems → `update()` → assert on `World` (bevy-cheatbook system-test pattern). Pure `cargo test`. | Highest — you own the schedule; opt-in determinism + Rapier (tier 1) |
| **Unity** | **Hybrid** — GameObject/MonoBehaviour (OOP) **+ DOTS/ECS** | Mixed. GameObject couples state+behavior+scene; DOTS separates them | GameObject logic needs PlayMode or careful MonoBehaviour mocking; DOTS supports multi-World unit tests (DOTS unit-test threads). EditMode for pure C#. | DOTS more deterministic than GameObject; PhysX same-machine only |
| **Godot** | **Scene-graph / nodes (OOP)** | Weak by default — nodes mix data+behavior+hierarchy | DIY discipline: keep logic in plain `RefCounted`/resources, test via GUT headless. Node logic often needs the tree. | Fixed timestep + seeded PCG32; no physics-determinism guarantee (tolerance tier) |
| *(ext)* flecs / EnTT | ECS libraries | Strong | Library-level unit tests | Manual |

**Load-bearing factory implication:** the architecture choice is a **first-class lever
on contract-ability**. Data-oriented engines (Bevy, Unity DOTS) let the factory generate
*pure simulation systems* that are trivially unit-testable headless and deterministic;
OOP-actor/node engines (Unity GameObject, Godot nodes) require the factory to **enforce a
"separation of gameplay logic from presentation" pattern** (the canonical
gamedeveloper.com "Separation of Gameplay" article; Unity "separation of logic and
GameObjects" threads) so logic can be lifted out of the scene graph and tested without a
GPU. **This becomes a generation constraint the factory imposes**, not an engine
property it inherits — and it is the single highest-leverage architectural rule the
factory can enforce to keep the Headless-Contract tier as large as possible across all
engines. It does **not** contradict the engine-neutral spine; it is a Layer-2
methodology rule expressed through the adapter.

---

## 4. Testability / Contract-ability Per Discipline (the core deliverable)

| Discipline | Headless sim (no GPU) | Needs GPU / playable | Subjective / human-in-loop | Primary contract form |
|---|---|---|---|---|
| Gameplay systems (economy/damage/inventory/abilities/FSM) | ✅ **dominant** | — | balance/fun only | Behavioral Contract (invariants, I/O matrices, FSM legality, save round-trip) |
| Engine/runtime architecture | ✅ scheduling/query/transform | concurrency under load | — | Structural invariants, data-transform determinism |
| Rendering / shaders / lighting | algorithmic stages only | ✅ **visual output** | ✅ artistic intent | Golden-image / perceptual-diff (tolerance) + Design-Intent |
| Physics (CPU solver) | ✅ (tier-gated) | GPU physics | "feels wrong" | Layered: bitwise / tolerance / behavioral (per `determinism_tier`) |
| AI — symbolic (BT/GOAP/utility/navmesh) | ✅ | — | perceived "intelligence/fairness" | Decision-graph conformance, A* optimality, distribution tests |
| AI — ML/RL | partial (guardrails) | training/eval | ✅ | Regression/guardrail only |
| Networking — lockstep/rollback | ✅ **in-process N-client + checksum** | — | perceived latency | Determinism contract = replay-regression + peers |
| Networking — client-server replication | ✅ convergence w/ injected conditions | large-scale | latency feel, anti-cheat | Predict/reconcile convergence, replication correctness |
| Tools / editor | logic-under-tool only | — | ✅ **UX** | (consume via introspect; not a gen target) |
| Build / platform / cert | ✅ build + cert-checklist subset | on-device cert | publisher sign-off | Cert-conformance contract (§7) |
| Performance budgets | ✅ CPU-time, memory HWM, draw-call **count** | ✅ **GPU-time**, bandwidth | — | Threshold gate vs pinned-runner baseline |

**Verified headless-logic-test substrate (real, primary-sourced):**
- **Unity:** Test Framework **EditMode** (no PlayMode/GPU) for pure C# logic; PlayMode
  headless under `-batchmode -nographics` for sim. (UTF docs.)
- **Unreal:** **Gauntlet** automation framework — real, documented, orchestrates
  headless/dedicated-server sessions and multi-client tests. (Epic docs.)
- **Godot:** **GUT** headless CLI (JUnit XML) — real. (bitwes/Gut; saltares CI guide.)
- **Bevy:** `cargo test` over systems via `App`/`World` — real, documented pattern.
  (bevy-cheatbook system-tests.)
- **Cross-cutting practice:** **"separate game simulation from rendering"** is the
  industry-standard enabler (gamedeveloper.com Separation of Gameplay) — and it is *the
  same precondition* rollback netcode requires, so the factory gets multiplayer-readiness
  and headless-testability from one architectural rule.

---

## 5. Networking / Multiplayer — Scope Decision Input

**Market reality (verified):** ~53% of gamers spend the majority of their time in
**single-player** (Statista), yet online multiplayer is the most-adopted feature among
surveyed developers (~83%, Unity 2026 Gaming Report). Multiplayer is a major value driver
*and* a major cost/risk driver.

**Cost/risk (verified):** adding networking is a **~2.5–5× cost multiplier** vs the
single-player equivalent (yudiz; corroborated across sources), dominated by
predict/reconcile, security/anti-cheat, network-condition resilience, and
desync-debugging (often 30–40% of networking time). **Deterministic approaches
(Quantum, GGRS) cut the multiplier ~30–40%** by eliminating bespoke netcode — at the
price of requiring a fully deterministic sim.

**Framework testability (verified per-framework):**

| Framework | Engine | Model | Headless / in-process test | Notes |
|---|---|---|---|---|
| **Photon Quantum** | Unity | **Deterministic lockstep** | ✅ excellent — input-replay = regression test; logic-frame dumps; N virtual clients in-process | "100% deterministic"; requires fixed-point, fixed-step sim |
| **bevy_ggrs** (GGRS/GGPO) | Bevy | **P2P rollback** | ✅ excellent — frame checksums pinpoint desync frame; deterministic by construction | Selective world snapshot; matchbox/WebRTC transport |
| **Photon Fusion** | Unity | Server-auth + rollback option | ✅ good — checksum desync detection; headless server config | Server/host-authoritative |
| **Netcode for Entities** | Unity DOTS | Server-auth + client prediction (ghosts) | ✅ good — **multi-world in one process**; deterministic DOTS | Best Unity option for scale + testability |
| **Netcode for GameObjects** | Unity | Server-authoritative | ◑ moderate — multi-instance, custom harness; `-batchmode` headless server (now free tier) | Industry-standard pattern |
| **Lightyear** | Bevy | Server-auth (+ optional client-auth per entity) | ✅ good — in-process virtual client/server; Rust proptest; link conditioner | Compile-time component checks |
| **bevy_replicon** | Bevy | Server→client replication | ✅ good — emulated server + clients in test; **single-player mode** reuses same code path | Opt-in replication |
| **Godot high-level MP** | Godot | Client-server / listen-server | ◑ moderate — `--headless` server; multi-instance editor; ENet/WebRTC/WebSocket | Node-based (Spawner/Synchronizer) |
| **Nakama** (Heroic Labs) | engine-agnostic backend | Server-authoritative service | ◑ integration-test via Docker + Go tests; orchestrates headless game-server instances | Separate backend, not in-engine netcode |

**Recommendation for the brief:**
1. **Single-player is the default lane.** No networking assumed; maximizes the
   Headless-Contract tier and minimizes cost.
2. **Deterministic lockstep / rollback is the FIRST-CLASS multiplayer lane.** It reuses
   the *existing* replay-regression machinery (fixed tick + seeded RNG + input injection
   from Decision 0003) almost verbatim — multiplayer determinism contracts ≈ replay
   contracts with N peers + checksum equality. Bevy+`bevy_ggrs`+Rapier (tier-1
   determinism) is the natural reference path; Quantum is the Unity analog.
3. **Server-authoritative replication is a SECOND tier** — supported, tested headless
   with injected network conditions and in-process server/client worlds, but flagged as
   higher cost and with security/anti-cheat/large-scale explicitly **human-in-loop**.
4. **Dedicated-server orchestration / MMO scale (Nakama-class) is a LATER tier.**

This makes networking *in scope* without forcing the cost multiplier onto every game, and
it leans on the determinism tier the architecture already models. **Flag:** netcode
frameworks (esp. Bevy ecosystem) move fast; pin versions and re-verify per release.

---

## 6. Performance Budget Standards

**Frame-time budgets (verified):** 30 fps = 33.33 ms, 60 fps = 16.66 ms, 120 fps = 8.33 ms.
Practitioners reserve headroom (mobile commonly ~30–35% idle for thermal) so *practical*
targets run tighter than the theoretical ceiling. *(The overview pass's specific "35%
universal" figure is one source's rule of thumb — treat as illustrative, not a standard.)*

**Typical CPU frame breakdown (directional, from profiling-practice sources):** gameplay
logic ~30–40%; render-thread/draw-call prep ~20–30%; physics ~15–25%; animation ~15–25%;
AI a slice of gameplay (~10–15% of that). **GPU** is the usual AAA bottleneck (vertex /
pixel / memory bandwidth).

**Memory / draw-call / poly (2026, directional):** AAA PC trending to **32 GB RAM** and
**12–16 GB+ VRAM**; current consoles are fixed unified pools (Xbox Series X 16 GB shared).
Draw-call efficiency dominates (batching, instancing, SRP Batcher/GPU Resident Drawer);
"4 small meshes cost more than one consolidated mesh" is the canonical lesson. *(Exact
per-tier numbers vary widely by genre/title — flag as soft.)*

**CI-automatable vs hardware-bound (the factory-critical distinction, verified):**

| Metric | CI-automatable headless? | How |
|---|---|---|
| CPU-system frame time (gameplay/physics/AI logic) | ✅ yes | headless run + profiler API capture; consistent across HW |
| Memory high-water-mark / leak detection | ✅ yes | Unity Memory Profiler / Unreal mem tracking / Tracy callstacks |
| Draw-call **count**, batch/set-pass stats (logical) | ✅ yes | Unity Frame Debugger API / Unreal Insights — count, not GPU time |
| **GPU frame time**, memory bandwidth, shader compile, cache | ❌ no | requires target GPU; thermal/driver dependent (NVIDIA `SetBackgroundProcessingMode` for stable measurement) |
| Frame-rate as experienced (VSync, present) | ❌ misleading headless | on-device only |

**Real profilers (verified):** Unity Profiler + **Profile Analyzer** (baseline diff),
**Unreal Insights**, **Tracy** (CPU/threads/memory/locks), **micro-profiler**, **PIX**,
**RenderDoc**, NVIDIA Nsight / `SetBackgroundProcessingMode`. **Factory artifact:**
a **performance-budget contract** = declared thresholds (CPU-time per system, memory HWM,
draw-call ceiling) checked headless against a **pinned-runner baseline**, with GPU-time
flagged as a `render`-profile / on-hardware gate. This is exactly the existing
`frame-budget` convergence dimension made concrete.

---

## 7. Genre Variation

The discipline mix and the size of the Headless-Contract tier vary sharply by genre,
which the factory must model (genre is a knob on *which contracts dominate*):

| Genre | Dominant disciplines | Determinism need | Headless-contract share | Notes |
|---|---|---|---|---|
| **Turn-based / strategy / RTS** | gameplay systems, symbolic AI, (lockstep) net | High (RTS lockstep) | **Highest** — almost pure sim | Ideal pilot genre; AoE-class lockstep is the determinism canon |
| **Fighting** | frame-precise combat FSM, **rollback net**, physics | Very high (rollback) | High | Rollback = determinism contract; "feel" via playtest |
| **Card / puzzle / sim / management / roguelike** | gameplay systems, economy, PCG | Medium | **Highest** | Logic-heavy, render-light → maximal factory fit |
| **FPS / action** | gameplay, physics, AI, networking, rendering | Medium–high (netcode) | Medium | Rendering + feel raise human-in-loop share |
| **Open-world / RPG** | all of the above + streaming, content volume | Medium | Medium-low | Content *volume* + asset lane dominate; perf/streaming gates critical |
| **Racing / sports** | physics (vehicle), netcode, rendering | High (replay/net) | Medium | Deterministic physics central |
| **Narrative / walking-sim** | dialogue FSM, scripting, rendering | Low | Medium (logic) / low (whole) | Feel + visuals dominate acceptance |

**Implication:** the factory's *cleanest early wins* are **logic-dense, render-light,
determinism-friendly genres** (turn-based, strategy/RTS, card/sim/roguelike, fighting),
which is consistent with the existing pilot bias toward tier-1 deterministic-sim stacks
(Decision 0003). Open-world/RPG and visually-driven genres push work into the
asset-lane + Design-Intent + render-gate lanes and should come later.

---

## 8. Factory Artifacts / Contracts This Discipline Implies

New or sharpened artifacts the engineering vector requires (additive to existing Layer-2):

1. **Simulation Behavioral Contract** *(extends VSDD's Behavioral Contract)* — economy
   invariants, damage I/O matrices, inventory save round-trip, ability/FSM legality
   graphs. Headless, deterministic, the factory's bread-and-butter.
2. **Determinism / Replay-Regression Contract** *(exists — Decision 0003)* — reaffirmed;
   extends to multiplayer as **N-peer checksum-equality** for lockstep/rollback.
3. **Networking-Convergence Contract** *(new)* — predict/reconcile bounded drift,
   replication correctness, behavior under **injected latency/jitter/loss**; runs with
   in-process server+client worlds.
4. **Performance-Budget Contract** *(extends `frame-budget` dim)* — declared
   CPU-time/memory-HWM/draw-call thresholds vs pinned-runner baseline; GPU-time split to
   a `render`-profile/on-hardware gate.
5. **Symbolic-AI Behavioral Contract** *(new)* — BT decision-graph conformance, GOAP
   plan-optimality, navmesh/A* path-validity + optimality, utility-selection
   distribution tests. Headless.
6. **Rendering Golden-Image / Perceptual-Diff Contract** *(extends `capture`)* — tolerance
   visual-regression on the `render` profile + Design-Intent Contract for artistic intent.
7. **Platform-Certification Conformance Suite** *(new, high-value)* — the
   machine-checkable subset of Microsoft GDK XR / Sony TRC / Nintendo Lotcheck:
   crash-free operation, **suspend/resume**, **save-data integrity**, **controller
   disconnect/hot-plug**, memory limits, **error-message compliance**, age-rating presence.
   A distinct contract family from gameplay tests; partly automatable in CI, partly
   manual-cert (flag which).
8. **Architecture-Separation Rule** *(new generation constraint)* — the factory enforces
   logic↔presentation separation so OOP-actor/node engines stay in the Headless-Contract
   tier; expressed as a Layer-2 methodology rule via the adapter.

All of these ride the **existing capability-graded, declare-and-degrade** machinery: a
contract degrades to the next tier (exact→tolerance→playtest) based on the adapter's
declared fidelity/determinism, never assuming a capability.

---

## 9. AAA Acceptance Bar

The bar is **bimodal — a hard automatable spec plus a soft subjective spec** — and the
factory must treat the two halves differently:

**Hard / automatable (a real checklist, primary-sourced):** platform **certification** is
a concrete, enumerable gate every shipping AAA console title must pass —
**Microsoft GDK certification requirements (XR)**, **Sony TRC**, **Nintendo Lotcheck**.
Categories include: crash-free operation, **suspend/resume & sleep behavior**, **save-data
integrity** (incl. corruption/full-storage handling), **controller disconnect/reconnect**,
memory/resource limits, **standardized error messaging**, age-rating compliance, and store
metadata. A large fraction is **checkable in CI** (crash sweeps, save round-trips,
controller hot-plug simulation, error-string presence); the remainder
(on-device cert lab, subjective polish review) is **manual cert**. This is the
certification-conformance contract suite (§8.7).

**Soft / subjective (Design-Intent + playtest):** "AAA quality" technically also means
**stable target frame rate** (60 fps, or stable 30), **low crash rate**, **fast load
times**, **high content volume**, and **polish/feel** — and commercially it means a
200–600+ person, multi-year, $50M–$300M+ production tier (VSQUAD). The
performance/stability sub-bar is automatable (§6); polish, feel, fun, and artistic
quality stay human-in-loop via the Design-Intent Contract + structured playtest protocol
already in `architecture.md`.

**Factory framing:** the acceptance bar is **not monolithic**. The factory can *fully
own* the certification + performance + simulation-correctness portions as machine-checked
gates, and must *defer* the perceptual/feel portion to human-validated Design-Intent
evidence. This is the same VSDD→game-factory quality-model split, now concretely
populated for the engineering vector.

---

## 10. Open Questions & Risks

1. **Overview-pass confabulation (HIGH).** The disciplines-overview deep-research answer
   was largely uncited and invented tool names and precise percentages. All concrete
   tool/practice claims here were re-anchored to the well-cited passes; **the percentages
   in this report are directional only.** Re-verify any specific tool before building on it.
2. **Engine API/netcode churn (HIGH, fast-moving).** Bevy pre-1.0 (~quarterly breaks) and
   its netcode crates (`bevy_ggrs`, Lightyear, `bevy_replicon`) lag/drift; Unity DOTS +
   Netcode for Entities still maturing. Pin versions; treat each release as adapter
   maintenance (consistent with the Bevy report's warning).
3. **OOP-engine logic extraction (MEDIUM).** The "separation of gameplay" rule is
   industry best practice but **not enforced by Godot/Unity-GameObject**; whether the
   factory can reliably *generate* code that honors it across engines is unproven and a
   key feasibility question for keeping the headless tier large.
4. **Rendering acceptance (MEDIUM).** Golden-image diffing is cross-hardware flaky; the
   threshold-band approach needs a pinned `render` runner and will still need human
   sign-off. Quantify acceptable tolerance per engine before committing.
5. **Multiplayer scope creep (MEDIUM).** Even tiered, networking risks pulling the factory
   toward server infra/anti-cheat (out of scope). Hold the line at deterministic-lockstep/
   rollback for v1; gate replication/dedicated-server behind explicit opt-in.
6. **Certification suite completeness (MEDIUM).** GDK XR is public and concrete; **Sony
   TRC and Nintendo Lotcheck details are under NDA** — the public checklist is partial.
   The automatable cert subset must be built from public + licensed docs and will be
   incomplete without devkit access.
7. **GPU-bound metrics (LOW, by design).** GPU-time/bandwidth are inherently on-hardware;
   accept this and route them to the `render`/on-device gate rather than chasing headless
   approximations.

---

## 11. Sources

Primary, verified (see YAML frontmatter for full list). Highlights by claim class:

- **Networking frameworks & architectures:** Unity Netcode docs; Photon Quantum/Fusion
  pages; Heroic Labs Nakama architecture docs; `cBournhonesque/lightyear`,
  `gschup/bevy_ggrs` repos; bevy_replicon write-up; Godot high-level multiplayer docs;
  johanhelsing "Extreme Bevy"; yal.cc deterministic-netcode; ruoyusun netcode series.
- **Determinism canon:** Gaffer on Games deterministic-lockstep; rapier.rs.
- **Headless logic testing (verified real):** Unity UTF EditMode-vs-PlayMode docs; Epic
  **Gauntlet** docs; `bitwes/Gut`; bevy-cheatbook system-tests; saltares Godot-CI guide;
  gamedeveloper.com "Separation of Gameplay."
- **AI libraries (verified real):** `behaviortree/behaviortree.cpp`;
  `recastnavigation/recastnavigation`; lisyarus behavior-trees.
- **Architecture/ECS:** `sandermertens/flecs`; `skypjack/entt`; Unity DOTS unit-test thread.
- **Performance/profiling:** Unity profiling best-practices; thegamedev.guru draw-call
  optimization; Tracy docs (Flax); NVIDIA `SetBackgroundProcessingMode`; Unreal Insights.
- **Certification / AAA bar:** Microsoft GDK certification requirements (XR); ixiegaming
  console-compliance; Nintendo Lotcheck (fandom); Pingle PlayStation porting standards.
- **Market/cost:** Unity 2026 Gaming Report; Statista single-vs-multiplayer; yudiz
  multiplayer cost; VSQUAD AAA-budget.

**Cross-references (in-repo, built upon, not contradicted):**
`planning/research/{bevy,unity,godot}-capabilities.md`,
`planning/research/prior-art-and-precedents.md`, `planning/research/RECONCILIATION.md`,
`planning/design/{architecture,engine-adapter-protocol}.md`,
`planning/decisions/{0001,0002,0003}-*.md`.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 4 | Deep passes (high reasoning_effort): (1) engineering disciplines × headless-testability; (2) networking/multiplayer frameworks, testability, cost; (3) performance budgets + ECS architecture + AI tooling; (4) console certification (TRC/XR/Lotcheck) + real headless logic-test frameworks |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (library API depth not needed beyond prior repo research) |
| Tavily tavily_search | 1 | Genre variation + AAA technical-standard cross-check |
| Tavily tavily_research | 0 | — |
| Tavily tavily_extract | 0 | — |
| WebFetch / WebSearch | 0 | — |
| Training data | ~2 areas | Framing the discipline taxonomy and tier model; all specific tool/claim anchored to cited passes |

**Total MCP tool calls:** 5 (4 perplexity_research + 1 tavily_search)
**Training data reliance:** low-to-medium — taxonomy/structure from model knowledge; all
load-bearing tool names, frameworks, certification categories, and cost/market figures
sourced from cited research. **The disciplines-overview pass was substantially
confabulated and is explicitly down-weighted** (see header warning); its tool names were
discarded unless independently verified, and its percentages are used only as directional
ordering.
