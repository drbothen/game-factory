# Cross-Cutting Foundations for an Engine-Agnostic Game-Development Factory

**Research date:** 2026-06-07
**Confidence:** HIGH on Areas 1 & 3 (multiple independent sources, official docs); HIGH on Area 2 (authoritative canonical sources).

---

## SECTION 1 — PRIOR ART (Game-Dev Automation)

### 1.1 Engine-specific CI/build tooling (mature, but siloed)

| Tool / Stack | Engines | What it does | What it does NOT do | Cross-engine? |
|---|---|---|---|---|
| **GameCI `unity-builder`** | **Unity only** | Dockerized Unity editor images; GitHub Actions / GitLab / CircleCI templates; multi-platform builds; can invoke Unity Test Runner | Unity-only (per FAQ); no higher-level test abstraction; not a CI server | No |
| **`godot-ci`** (abarichello) | **Godot only** | Docker Godot editor images; export + deploy to Pages/itch.io; needs `export_presets.cfg` | Export-focused; relies on GUT for tests; no AI/cross-engine API | No |
| **Unreal UBT/UAT/BuildGraph/Gauntlet** | **Unreal only** | Sophisticated in-house stack: compile, cook, package, dedicated-server, XML build graphs, Gauntlet multi-client/server test orchestration | Tightly coupled to Unreal concepts (cooking, maps); not generic | No |
| **Bevy CI templates** | **Bevy (via Cargo)** | Reuses standard Rust toolchain; build desktop + WASM; deploy via butler | No Bevy-specific framework; adapted generic Rust CI | No |

**Key finding:** Every major engine has a *viable but siloed* automation story. None spans more than its own engine.

### 1.2 Cross-engine TEST automation (partial coverage exists)

- **GameDriver** (commercial) — **Unity + Unreal**. "Write-once-run-anywhere" API with proprietary **HierarchyPath** query language. No Godot/Bevy; no build automation.
- **AltTester / AltUnity** (open) — Unity, **added Unreal in v2.2** (UE 5.3–5.5). Object-hierarchy inspection, record-and-replay. No Godot/Bevy; no build automation.
- **Airtest** (NetEase, open) — **engine-agnostic black-box** via image recognition + Poco UI hierarchy. No deep semantic access, no build orchestration.
- **T-Plan** (commercial) — black-box visual automation, GUI-level only.
- **modl.ai** (commercial) — **integrationless** AI QA agents: vision models + OCR play a build from natural-language tasks. Engine-independent because black-box. No build automation, no engine-neutral object API.

**Pattern:** cross-engine test coverage exists in two flavors — (a) **deep SDK** spanning *two* engines (Unity+Unreal), and (b) **shallow black-box** spanning *all* engines via pixels/UI. Nobody offers deep, semantic, multi-engine integration across all four targets.

### 1.3 AI/LLM-driven game dev & RL testing (research-stage, bespoke)

- **GameGPT** — LLM multi-agent game-dev framework; engine-agnostic only *conceptually*; would orchestrate existing CI, not replace it.
- **Voyager** — GPT-4 embodied agent in **Minecraft**; tightly coupled to Minecraft's API.
- **MarioGPT / GAN level generators** — PCG, single-genre; not engine-integrated.
- **Unity ML-Agents** — in-engine RL testing; **Unity-only**.
- **EA SEED RL playtesting** — curiosity-driven coverage agents; techniques tied to internal/Frostbite tooling, not a product.
- **Industry sentiment (2026 GDC):** ~36% use genAI, but **52% believe genAI has a negative impact**; only ~10–12% use it for PCG/content. Adoption in critical test/build paths remains cautious.

### 1.4 Record-and-replay as game regression testing

- Established (Airtest record/replay; AltTester record-to-code). **GameDriver.io** explicitly markets replay-based regression: capture a session, replay it, compare game-state metrics within tolerance.
- **Limits:** fragile to UI changes; per single instance; requires controlling non-determinism (recorded RNG seed, virtualized external inputs) — which is why Section 2 underpins this.

### 1.5 What does NOT exist (explicit gap)

1. **No CI tool natively understands all four engines' build pipelines** behind a unified API.
2. **No test SDK integrates deeply with Unity + Godot + Unreal + Bevy simultaneously** (GameDriver/AltTester stop at Unity+Unreal).
3. **No AI/LLM agent framework integrates all four at the engine level** (engine-agnostic AI tools are all black-box GUI-level).

> **There is no unified build-AND-test, engine-agnostic factory spanning Unity/Godot/Unreal/Bevy as of 2026.**

---

## SECTION 2 — DETERMINISM IN GAMES

### 2.1 Fixed timestep ("Fix Your Timestep")
Canonical: **Glenn Fiedler, Gaffer on Games.** Tying sim to render frame rate causes non-determinism; solution is a **fixed sim tick (~60 Hz)** decoupled from rendering via an **accumulator**. Three time domains: real / simulation / render. Render-side interpolation smooths the decoupling. **Input discipline:** sample inputs once at the start of each sim step; buffer transient events to the correct tick.
Source: gafferongames.com/post/deterministic_lockstep/

### 2.2 Deterministic lockstep (replays + netcode)
Transmit only **inputs**, not state; each client runs the sim independently, advancing a tick once all inputs arrive. Canonical RTS: Age of Empires II's 1500-archers GDC demo. RNG: single shared seed; all randomness from a deterministic PRNG advancing identically everywhere. Fighting games use **rollback netcode** (predict + rewind + resim).

### 2.3 Sources of non-determinism (and mitigations)
- **Floating point is the chief villain.** IEEE 754 permits implementation-specific rounding; transcendentals (`sin`/`cos`) aren't required to match across vendors; compiler reordering exploits non-associativity. 1-ULP differences cascade into desync.
- **Mitigation — fixed-point math** (e.g. Q16.16): integer arithmetic is bit-exact across platforms.
- **Physics engines:**
  - **Rapier** advertises **cross-platform bitwise determinism** (same version + initial conditions → identical snapshot hash across OS/CPU/browser). **Strong fit for Bevy** (rapier bevy plugin).
  - **Unity PhysX:** deterministic *same-machine only*; **NOT cross-platform** (SIMD/rounding). "Enhanced Determinism" helps same-machine only.
- **Other:** RNG overflow/bitwise differences; hash output variance; memory alignment; locale-dependent string compare.
Source: rapier.rs determinism docs; duality.ai/blog/game-engines-determinism

### 2.4 Input record-and-replay as regression testing
Two-phase: record stores inputs keyed by **sim frame number**; playback feeds them back, bypassing live input. Determinism guarantees identical results. Storage: delta-encode + bit-pack + RLE. Regression use: capture → re-run after change → compare game-state metrics within tolerance. Must control recorded RNG seed + virtualize external sources. Best designed in from the start.

### Section 2 implication for our design
The **replay-regression model is well-founded** but has a hard dependency: the engine adapter MUST expose **(a) a fixed-timestep tick, (b) seeded/injectable RNG, (c) input injection at tick boundaries.** Cross-platform bitwise determinism is *not* free — Rapier-class engines give it; PhysX-class give only same-machine. **→ The conformance suite should classify engines by a determinism TIER (bitwise-cross-platform / same-machine / tolerance-only) rather than assume uniform determinism.**

---

## SECTION 3 — PROTOCOL-DESIGN PRECEDENTS

| Precedent | Stable versioned protocol | Pluggable backends | Capability negotiation | Conformance suite |
|---|---|---|---|---|
| **LSP** | Yes (semver; 3.17/3.18) | Yes | **Yes — richest** (`clientCapabilities`/`serverCapabilities` + **dynamic registration**) | **No official suite** ← drift risk |
| **Terraform providers** | Yes (Plugin Protocol v5/v6, gRPC) | Yes (3rd-party gRPC) | **Static** (schemas) | **Yes — rigorous** (acceptance tests via real CLI, `TF_ACC`) |
| **Kubernetes CRI/CSI** | Yes (CRI v1 since 1.26; gRPC) | Yes | **Capability flags** at init | **Yes — strongest** (`critest`, `csi-sanity`) |
| **Testcontainers** | Partial (de facto Docker API) | Yes | Env checks, not formal | **No formal suite** ← cautionary |

### 3.1 LSP — gold standard for capability negotiation
`initialize` exchanges client+server capabilities; unsupported requests return explicit errors (graceful degradation, avoids lowest-common-denominator). **Dynamic registration:** capabilities can change after init. **Weakness to learn from: no official conformance suite — a genuine drift vulnerability. Do not copy this.**

### 3.2 Terraform — conformance/acceptance-testing exemplar
Versioned gRPC plugin protocol (v5/v6) with explicit CLI↔protocol compat matrix. Capabilities **STATIC** via schemas. **Acceptance tests** run *real* plan/apply/destroy against *real* infra through the *real* CLI. **Lesson: test the observable outcome through the real interface, not protocol messages.**

### 3.3 Kubernetes CRI/CSI — conformance-suite exemplar (LOAD-BEARING)
Hard version gates (CRI v1 required since 1.26). **Two-layer conformance:** `critest` (validates lifecycle against kubelet expectations) + `csi-sanity` (simulates orchestrator, capability-flag-gated). **Drivers declare capability flags; the harness selectively enables only the tests for declared capabilities** — backends differ but are held to whatever they claim. **Lesson: declared-capability + capability-gated conformance is exactly how you let backends differ while preventing drift.**

### 3.4 Testcontainers — cautionary "no formal conformance" case
Works *only because* it standardizes on one de facto backend (Docker). No `critest`-style suite; relies on env checks + Ryuk reaper. **Lesson: for genuinely heterogeneous backends (our four engines + heterogeneous determinism), "common API + env checks, no conformance" is insufficient — you need CRI/Terraform-style conformance.**

---

## BOTTOM LINE

### (a) Is anyone already doing this? What gap would we fill?

**No one is building an engine-agnostic build-AND-test factory across Unity/Godot/Unreal/Bevy.** The market is sharply stratified: build CI is mature but **single-engine**; test SDKs top out at **two engines** (Unity+Unreal); engine-agnostic testing exists only **black-box** (pixels/OCR, no semantic state, no build integration); AI/LLM game agents are research-stage and single-environment.

**The gap is genuinely open:** a unified protocol providing **both build and *semantic/deterministic* test/replay across all four engines**. **Reuse vs build:** reuse the *engine-native* build runners (GameCI, godot-ci, UAT, Cargo) and Rapier-class determinism — wrap them, don't reinvent; **build** the adapter protocol + conformance suite + the semantic/replay layer for Godot and Bevy (where no deep SDK exists).

### (b) Does the LSP / Terraform / CRI / Testcontainers analogy hold?

**Yes — strongly, and the four are complementary:**
- **LSP → capability negotiation** (+ dynamic registration, explicit "unsupported" errors). *But its missing conformance suite is a drift risk — don't copy that.*
- **Terraform → versioned protocol + acceptance testing** through the real adapter, CI-matrixed across engine versions.
- **CRI/CSI → the conformance suite that prevents drift** (LOAD-BEARING): declare capability flags + capability-gated conformance.
- **Testcontainers → anti-pattern** (no conformance = drift; only works for homogeneous Docker backend).

**Refined design recommendation:** a **hybrid** — LSP-style dynamic capability negotiation, on a Terraform-style versioned protocol, gated by a CRI/CSI-style capability-declared conformance suite, avoiding the Testcontainers no-conformance trap. **Add a determinism-tier classification (Section 2) to the capability schema** — the game-specific dimension none of the four precedents had to model.

---

### Caveats
- Section 1 prior-art cites tools by canonical repo/name (the deep-research run's URL map wasn't retained per-claim); named repos are directly verifiable.
- LSP "no official conformance suite" is a negative finding (high confidence but inherently harder to prove).
- `critest`'s precise validation coverage is partly inferred from the CRI spec.
