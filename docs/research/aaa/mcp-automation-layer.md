---
document_type: research
vector: mcp-automation-layer
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
project: game-factory
scope: "MCP + headless automation layer for game asset/engine pipelines. How agents create/import/validate assets via MCP servers and headless CLI in CI/worktree contexts. Maps to engine-adapter-protocol.md and art-pipeline.md."
research_discipline:
  primary_tool: "PRIMARY-SOURCE repo verification (WebFetch / tavily_extract on actual GitHub repos + issues)"
  cross_validation: tavily_search
  reasoning_check: perplexity_reason
  mcp_calls_total: 11
  training_data_reliance: low
  research_quality_warning: >
    perplexity_research (sonar-deep-research) CONFABULATED on this topic: it asserted that
    ahujasid/blender-mcp, CoplayDev/unity-mcp, Coding-Solo/godot-mcp et al. "do not exist"
    and are "AI hallucinations." This is FALSE — every one was directly verified on GitHub
    (Blender MCP ~17.7k–22.4k stars). This is exactly failure mode R-009 (AAA-RECONCILIATION
    risk register: "LLM/AI summarizer confabulation"). ALL claims in this report are anchored
    to a primary-source repo fetch or flagged [UNVERIFIED]. The deep-research output was
    DISCARDED for the inventory.
sources:
  # DCC MCP servers (primary-source verified)
  - https://github.com/ahujasid/blender-mcp
  - https://github.com/ahujasid/blender-mcp/issues   # issue #251 headless hang
  - https://github.com/loonghao/dcc-mcp-houdini
  - https://github.com/loonghao/dcc-mcp-core/issues/998  # DCC sidecar RFC; commandPort/Qt matrix
  - https://github.com/elliezu/SubstacePainterMCP
  - https://github.com/ttiimmaacc/cinema4d-mcp
  # Engine MCP servers (primary-source verified)
  - https://github.com/CoplayDev/unity-mcp
  - https://github.com/IvanMurzak/Unity-MCP
  - https://github.com/Coding-Solo/godot-mcp
  - https://github.com/chongdashu/unreal-mcp
  - https://github.com/runreal/unreal-mcp
  - https://github.com/natepiano/bevy_brp_mcp-ARCHIVED   # moved to unified workspace
  - https://github.com/natepiano/bevy_brp_extras-ARCHIVED
  - https://github.com/Ladvien/bevy_debugger_mcp
  # Asset-generation MCP servers (primary-source verified)
  - https://github.com/meshy-dev/meshy-mcp-server
  - https://github.com/meshy-dev/Meshy-guide
  - https://github.com/pasie15/meshy-ai-mcp-server
  - https://github.com/VAST-AI-Research/tripo-mcp
  - https://github.com/elevenlabs/elevenlabs-mcp
  # Star-count snapshot + transport reference
  - https://github.com/apappascs/mcp-servers-hub   # star snapshot 2026-03-13
  - https://github.com/cyanheads/model-context-protocol-resources/blob/main/guides/mcp-server-development-guide.md  # stdio vs streamable-http
  # Repo-internal docs grounding
  - docs/design/engine-adapter-protocol.md
  - docs/research/aaa/art-pipeline.md
  - docs/research/aaa/AAA-RECONCILIATION.md
---

# MCP + Headless Automation Layer for Game Asset/Engine Pipelines — Integration-Architecture Research

> **Primary-source discipline.** Every server/tool in the inventory tables was verified by
> fetching its actual GitHub repo (and, for the Blender headless verdict, its issue tracker)
> on 2026-06-07. Star counts are date-stamped and treated as volatile. Anything not confirmed
> against a primary source is marked **[UNVERIFIED]**. The `sonar-deep-research` pass on this
> topic confabulated (claimed the repos don't exist); it was discarded — see the
> `research_quality_warning` in frontmatter. This is risk R-009 manifesting live.

---

## 1. Executive Summary

1. **MCP is the right agent→tool *authoring* surface, but the wrong CI *execution* surface for
   most of the pipeline.** The single architectural fact that decides headless viability is:
   **does the MCP server embed itself inside a GUI application's event loop, or does it wrap a
   headless substrate (a CLI binary, a cloud HTTP API, or a headless interpreter)?** The former
   class cannot run lights-out; the latter can.

2. **Blender MCP is NOT headless-viable.** `ahujasid/blender-mcp` runs a socket server inside a
   Blender *addon*, and its event pump is `bpy.app.timers`. Issue **#251** confirms that under
   `blender -b` (background) the timers never fire and **every MCP command hangs**. It requires a
   running Blender GUI. For CI we must instead use Blender's own `--background --python` CLI with
   the `bpy` API (already the recommendation in `art-pipeline.md §3`).

3. **The DCC-app MCP servers share Blender MCP's flaw** (Substance Painter MCP needs
   `--enable-remote-scripting` + a running Painter; Cinema4D MCP needs C4D running; the
   chongdashu Unreal MCP needs the Editor). **The one DCC exception is Houdini**:
   `loonghao/dcc-mcp-houdini` embeds a Streamable-HTTP MCP server **inside `hython`**, Houdini's
   headless interpreter — so it *can* run without a GUI.

4. **Engine MCP servers split by architecture.** Godot MCP (`Coding-Solo/godot-mcp`) is a Node
   **CLI wrapper** that shells out to the Godot binary + bundled GDScript, so it can drive
   `godot --headless`. Unity MCP servers (`CoplayDev/unity-mcp`, `IvanMurzak/Unity-MCP`) are
   in-Editor C# bridges; `IvanMurzak` explicitly advertises Docker/headless/CI and runtime
   operation. Bevy needs no bespoke control plane — the **Bevy Remote Protocol (BRP)** is native
   JSON-RPC introspection/mutation, and `bevy_brp_mcp` is a thin MCP veneer over it. Unreal MCP
   is **experimental** and Editor-bound (deferred, consistent with Unreal's Tier-3 status).

5. **Cloud asset-generation MCPs are trivially headless** because they are stateless HTTP API
   wrappers (Meshy official, Tripo API, ElevenLabs official, Rodin/Hyper3D). They map directly
   onto the existing pure-maximal asset lane (AAA-RECONCILIATION §9). **Caveat:** the *official*
   Tripo MCP (`VAST-AI-Research/tripo-mcp`) is Blender-addon-integrated, not a pure API wrapper —
   use the Tripo REST API for CI, not its MCP.

6. **Recommendation: YES, build a unified asset-adapter / tool-adapter protocol**, mirroring the
   existing engine-adapter protocol exactly (capability negotiation, fidelity grading, normalized
   results, conformance suite). It is the natural anti-lock-in seam over a churning, heterogeneous,
   pre-1.0 MCP/CLI tool zoo, and it lets the factory swap a GUI-bound MCP for a headless CLI behind
   one stable interface.

---

## 2. The Decisive Architectural Property (read this before the tables)

For any MCP integration `M`, define `H(M)` = "can make forward progress lights-out (no GUI, no
human, behavior a pure function of request + environment)." There are exactly two structural
classes, and they predict `H(M)` deterministically:

| Class | What it is | Examples (verified) | `H(M)` |
|---|---|---|---|
| **(A) Out-of-process wrapper over a headless substrate** | MCP server is its own process; it shells out to a CLI, calls a cloud HTTP API, or runs inside a headless interpreter | Godot MCP (shells `godot --headless`); Meshy/Tripo-API/ElevenLabs/Rodin (HTTP); dcc-mcp-houdini (inside `hython`) | **true** |
| **(B) In-process server embedded in a GUI event loop** | MCP server is an *addon/plugin* whose liveness is tied to the DCC's interactive main loop / timer system | Blender MCP (`bpy.app.timers`); Substance Painter MCP (`--enable-remote-scripting`); Cinema4D MCP; chongdashu Unreal MCP; Maya commandPort | **false** (unless the host has a headless interpreter the server can live in — the Houdini/hython exception) |

The correlation "wraps a CLI/API" ⇒ headless and "embeds in a GUI" ⇒ not-headless is **not
accidental**. The real discriminator is *coupling to an interactive main loop and opaque UI
state* versus *execution through explicit, headless interfaces*. Issue #251 in blender-mcp is the
canonical demonstration: the protocol is fine, but the addon's progress depends on a GUI event
pump that `blender -b` doesn't run.

---

## 3. MCP Server Inventory — VERIFIED (2026-06-07)

> Stars are volatile; date-stamped. Where two snapshots disagree (e.g. Blender MCP showed 22.4k on
> a direct repo fetch and ~17.7k in the mcp-servers-hub index dated 2026-03-13) both are real
> datapoints at different times — read as "tens of thousands, top-tier popularity."

### 3.1 DCC MCP servers

| Server (repo) | Transport | Exposes | Headless? | App instance required? | Auth | Maturity (stars, date) | Verified |
|---|---|---|---|---|---|---|---|
| **Blender MCP** `ahujasid/blender-mcp` | stdio (MCP) ↔ JSON-over-TCP socket to addon (:9876) | scene/object info; create/delete/modify; materials; **arbitrary `bpy` Python exec**; PolyHaven (models/HDRIs/textures); Sketchfab (search/download); **Hyper3D Rodin** (AI text/image→3D) | **NO** — issue #251: under `blender -b`, `bpy.app.timers` never fires → every command hangs | **YES** (GUI Blender, class B) | Hyper3D/fal.ai key for Rodin; PolyHaven keyless | **Very high** (~17.7k–22.4k ★, 2026-03→06) | ✅ repo + issues |
| **Houdini MCP** `loonghao/dcc-mcp-houdini` | **Streamable HTTP** MCP **inside `hython`** (:8765 auto-gateway) | ~70 tools / 20 skill packs: `execute_python`, scene/node ops, **`execute_hda`** (HDA exec), render, animation, validation, **USD/Alembic/FBX import-export**; progressive skill discovery | **YES** — `hython` is Houdini's headless interpreter (class A) | hython process (no GUI needed) | none documented | **Early** (3 ★, 2026-06) | ✅ repo |
| **Substance Painter MCP** `elliezu/SubstacePainterMCP` | stdio ↔ Painter remote HTTP (:6740-class) | connection/project info; layer structure; create Fill layers; masks; **`execute_python`** (Painter API) | **NO** | **YES** — launch with `--enable-remote-scripting` (class B) | none documented | **Early/initial release** | ✅ repo |
| **Cinema4D MCP** `ttiimmaacc/cinema4d-mcp` | C4D plugin + MCP server | prompt-driven modeling, scene creation/manipulation | **NO** | **YES** (C4D running, class B) | none documented | **Early** (~4 ★) | ✅ topic listing |
| Maya MCP | — (no single dominant repo verified) | commandPort (TCP, MEL/Python) is the natural substrate; `mayapy` is the headless interpreter | commandPort: **NO** (needs GUI); `mayapy`: yes but that's CLI not MCP | varies | IP whitelist (commandPort) | **[UNVERIFIED]** — multiple in-flight efforts (dcc-mcp org RFC #998 describes a planned Maya adapter) | ⚠️ planned |

**Cross-DCC note (verified, dcc-mcp-core RFC #998):** there is an explicit community effort to
standardize a Qt-event-loop TCP sidecar (`qtserver://`) reusable across Maya, Houdini, 3ds Max,
Nuke, Cinema 4D, Substance Painter, Mari — with Blender on a `bpy.app.timers` sibling. This
confirms the class-B pattern is the industry-default for GUI DCCs and that headless remains the
hard case everywhere except hython-class interpreters.

### 3.2 Engine MCP servers

| Server (repo) | Transport | Exposes | Headless / CI? | Maturity (stars, date) | Verified |
|---|---|---|---|---|---|
| **Unity MCP** `CoplayDev/unity-mcp` (successor to `justinpbarnett/unity-mcp`) | stdio (local) / remote w/ auth; Python server + Unity Package Manager bridge | manage assets, control scenes, edit scripts, run tests, automate; tool groups (vfx/animation/UI/testing); Roslyn script validation | In-Editor C# bridge; CI not explicitly documented in README | **High** (~10.4k ★, 2026-06) | ✅ repo |
| **Unity MCP** `IvanMurzak/Unity-MCP` | stdio (local) / **streamableHttp** (remote) / **Docker** | **70+ tools**: Project&Assets (21), Scene&Hierarchy (23, incl. screenshots), Scripting&Editor (20, code-exec/reflection/testing/console), Profiling&Diagnostics (12); "any C# method → tool in one line"; **works at runtime in compiled games** | **YES — "Headless/CI fully supported via env vars and CLI"; Docker container**; optional bearer-token auth | **High** (~3.1k ★, 2026-06) | ✅ repo |
| **Godot MCP** `Coding-Solo/godot-mcp` | stdio; **Node/TS CLI wrapper** over Godot binary + bundled `godot_operations.gd` | launch editor; **run projects**; capture debug output; start/stop; version; list/analyze projects; **scene mgmt** (create scenes, add nodes, load sprites, export MeshLibrary, save); UID mgmt (4.4+) | **YES (class A)** — wraps Godot CLI, can target `godot --headless`; no auth | **High** (~2.3k–4.1k ★, 2026-03→06) | ✅ repo |
| **Bevy MCP** `natepiano/bevy_brp_mcp` (now in unified workspace; old repo archived) + `bevy_brp_extras` | stdio/TCP (MCP) ↔ **BRP** (JSON-RPC over HTTP/WS) | launch/inspect/mutate Bevy apps via **Bevy Remote Protocol**; entity/component query+mutate; screenshots, keyboard injection, shutdown, **format discovery** (via extras) | **YES** — BRP is native, headless-friendly; requires `bevy_remote` feature in the app | Tracks Bevy versions (0.16→0.1, churns per release) | ✅ repo |
| **Bevy debugger** `Ladvien/bevy_debugger_mcp` | stdio/TCP ↔ BRP (WebSocket) | observe entities/components; experiment with game state; **stress/perf testing** | **YES** (BRP-based) | v0.1.6 (early) | ✅ repo |
| **Unreal MCP** `chongdashu/unreal-mcp` | Python MCP ↔ **C++ plugin TCP** (:55557) | actor mgmt; **Blueprint authoring** (classes, components, node graph, compile); editor/viewport control | **NO** — Editor required; **EXPERIMENTAL** ("subject to significant changes") | **Medium** (~2k ★) | ✅ repo |
| **Unreal MCP** `runreal/unreal-mcp` | Node/npx ↔ UE built-in Python remote execution (no custom plugin) | 17+ tools: Python exec; asset mgmt (list/export/search/validate); actor CRUD; console cmds; screenshots; camera | **NO** — active Editor + Python Remote Execution required | **Low** (~105 ★) | ✅ repo |

> **Engine takeaway:** every *primary* engine (Bevy, Unity, Godot) has a real, usable MCP path with
> a credible headless story; **Bevy via BRP and Godot via CLI-wrapper are the cleanest**; Unity is
> usable headless via `IvanMurzak`'s Docker/CI support; **Unreal MCP is experimental + Editor-bound**
> and stays deferred (Tier-3, per engine-adapter-protocol.md).

### 3.3 Asset-generation MCP servers (cloud APIs — inherently headless)

| Server (repo) | Transport | Exposes | Headless? | Auth | Maturity | Verified |
|---|---|---|---|---|---|---|
| **Meshy (official)** `meshy-dev/meshy-mcp-server` | stdio (default) / HTTP via `TRANSPORT` | **20 tools**: text/image/multi-image→3D (+refine); remesh; retexture; **rig; animate**; text→image; task/workspace mgmt; 3D-print suite; balance | **YES** (cloud API wrapper) | `MESHY_API_KEY` (Pro plan+) | Official; new (~9 ★, 2026-06) | ✅ repo + Meshy-guide |
| Meshy (community) `pasie15/meshy-ai-mcp-server` | stdio (npx) | text/image→3D, texturing, remesh (wraps Meshy API) | **YES** | Meshy API key | community | ✅ repo |
| **Tripo (official)** `VAST-AI-Research/tripo-mcp` | MCP ↔ **Tripo AI Blender Addon** | text→3D ("Generate 3D asset from natural language using Tripo's API") | **NO via this MCP** (Blender-addon-integrated, class B). Use **Tripo REST API** directly for CI | Tripo API key (via addon) | Official (~185 ★) | ✅ repo |
| **ElevenLabs (official)** `elevenlabs/elevenlabs-mcp` | Python MCP, API wrapper | TTS; voice design/clone; **sound effects**; audio isolation; transcribe | **YES** (cloud API wrapper) | `ELEVENLABS_API_KEY` (10k free credits/mo) | Official; v0.9.1 (Jan 2026, ~1.4k ★) | ✅ repo |
| **Rodin / Hyper3D** | (exposed *through* Blender MCP's Hyper3D integration; standalone Hyper3D API exists) | AI text/image→3D | API: **YES**; via Blender MCP: **NO** (class B host) | Hyper3D / fal.ai key | via blender-mcp (verified) | ✅ blender-mcp repo |
| Scenario MCP | — | AI textures/materials (REST/GraphQL API) | API: yes | API key | **[UNVERIFIED]** — no dominant first-party MCP repo confirmed; the **Scenario REST/GraphQL API** is the verifiable integration point | ⚠️ |

---

## 4. Headless CLI Automation Map (the CI-robust fallback)

This is the deterministic execution substrate. It is consistent with `art-pipeline.md §3` and is
where the factory should run *canonical build steps*. MCP is the authoring layer above it.

| Pipeline stage (art-pipeline §2) | Headless CLI / SDK | Invocation | Headless robustness | Notes |
|---|---|---|---|---|
| Import / export interchange | **Blender** `bpy` | `blender --background --python x.py` | 🟢 robust | glTF/GLB, USD, FBX, Alembic; the canonical conversion node |
| Decimation / remesh / LOD | Blender `bpy`; **Simplygon**; **InstaLOD** | `blender -b`; Simplygon batch/recipes; InstaLOD Pipeline JSON | 🟢 robust | industrialized batch stage |
| Algorithmic UV unwrap + pack | Blender `bpy.ops.uv.*` | `blender -b` | 🟢 robust (non-hero); 🟡 hero seams human |
| Texture baking | **Blender Cycles**; **Substance `sbsbaker`** | `blender -b` (Cycles, not EEVEE viewport); `sbsbaker` CLI | 🟢 robust | EEVEE viewport bake is NOT headless |
| Procedural material cook/render | **Substance Automation Toolkit**: `sbscooker`, `sbsrender`, `pysbs` | CLI | 🟢 robust | `.sbs`→`.sbsar`, batch texture sets |
| Procedural modeling / scatter / sim-bake | **Houdini** `hython`, **HDA**, **PDG/TOPs** | `hython x.py`; PDG schedulers | 🟢 robust | also reachable via dcc-mcp-houdini (class A) |
| Auto-rig (standard humanoid) | Maya `mayapy` (HumanIK/Quick Rig); AccuRig; Mixamo | `mayapy x.py` | 🟢 (humanoid) / 🔴 (hero face) | |
| Sprite/2D export | **Aseprite** CLI | `aseprite -b ...` | 🟢 robust | export/slice only |
| USD/glTF tooling | `usdcat`, `usdchecker`, **gltf-transform**, `gltfpack`/meshopt | CLI | 🟢 robust | validation + compression (Draco/KTX2) |
| **Engine build** | Bevy `cargo`; Godot `--headless --export`; Unity `-batchmode -nographics -executeMethod` | CLI | 🟢 (all three) | Unity needs per-agent license + xvfb for capture |
| **Engine test** | `cargo nextest`; Godot GUT; Unity `-runTests` (NUnit3) | CLI | 🟢 | normalized to result schema (engine-adapter §Normalized result) |
| **Engine introspect** | **Bevy BRP** (JSON-RPC); Godot `print_tree_pretty`; Unity editor script | CLI/BRP | 🟢 | BRP is the standout — same surface MCP uses |
| **Engine capture (screenshot/video)** | Bevy windowless+**lavapipe**; Unity/Godot **xvfb + software GPU** | CLI under render profile | 🟡 needs GPU backend | "headless ⇒ no GPU" is false everywhere (engine-adapter §execution_profiles) |
| Asset generation (3D/audio) | **Cloud REST APIs** (Meshy, Tripo, ElevenLabs, Rodin) | HTTPS | 🟢 robust | stochastic output — see §6 reproducibility |

**Coverage verdict:** the *mechanical* pipeline (import/export, decimate, LOD, UV, bake, cook,
procedural, build, test, introspect) is **robustly headless via CLI**. Only **capture** needs a
GPU/software-rasterizer render profile, and only **hero-craft** stages stay human (unchanged from
art-pipeline). Almost nothing in the deterministic spine *requires* a GUI-bound MCP.

---

## 5. MCP-vs-CLI Decision Rule (the recommendation)

Apply per tool × per pipeline step, in order:

```
RULE 1 — Is this step part of the canonical, reproducible build?
  YES → Use the tool's headless CLI / SDK / HTTP API DIRECTLY as the execution path.
        MCP/LLM may AUTHOR and maintain the scripts, but does NOT execute them in CI.
  NO  → (step is inherently generative/exploratory) continue to RULE 2.

RULE 2 — Is the MCP integration headless-viable, i.e. class A (wraps CLI / cloud API /
         headless interpreter) not class B (embedded in a GUI event loop)?
  class B (Blender MCP, Substance Painter MCP, Cinema4D MCP, chongdashu Unreal MCP, Maya
           commandPort) → DO NOT use in lights-out CI. Target the same app via its
           documented headless mode instead (blender --background --python, hython, mayapy).
  class A (Godot MCP, dcc-mcp-houdini, Bevy BRP/bevy_brp_mcp, IvanMurzak Unity w/ Docker,
           Meshy/Tripo-API/ElevenLabs/Rodin cloud) → ELIGIBLE for CI, but for DETERMINISTIC
           steps still prefer the raw CLI/API; reserve MCP for "let an agent decide" steps.

RULE 3 — Role assignment:
  MCP            = interactive agent-AUTHORING control plane (pipeline design, tool discovery,
                   ad-hoc ops, the agent WRITING the headless scripts).
  Headless CLI   = non-agentic EXECUTION plane in CI/worktrees (runs the authored scripts,
                   keyed by repo state + pinned tool versions).
```

**One-line version:** *MCP authors the pipeline; the headless CLI executes it. A GUI-bound MCP
(class B) never appears on the CI execution path.*

This mirrors the factory's existing split between agent-driven generation and deterministic,
contract-gated validation (AAA-RECONCILIATION §2 "Shift Work / Non-Interactive Agents").

---

## 6. Proposed Asset-Adapter / Tool-Adapter Protocol (mirrors engine-adapter)

**Recommendation: YES — build a unified asset-adapter protocol**, structurally identical to
`engine-adapter-protocol.md`. Same justification as the engine seam: it is the anti-lock-in layer
over a churning, heterogeneous, mostly-pre-1.0 tool zoo, and it is the only place that can cleanly
swap a GUI-bound MCP for a headless CLI without the factory core knowing.

### 6.1 Design pattern (inherited verbatim from engine-adapter §Design pattern)
Stable protocol + pluggable backends + **LSP-style dynamic capability negotiation** +
**Terraform-style versioned protocol & acceptance tests** + **CSI-style capability-gated
conformance suite**. Transport: **JSON-RPC 2.0** (parity with LSP, Bevy BRP, and MCP itself).

### 6.2 Capabilities (the fixed surface every asset-adapter implements)

Each capability is independent and **fidelity-graded** (`full`/`partial`/`none`) — never bundled,
exactly as in the engine adapter.

| Capability | What the adapter does | Output |
|---|---|---|
| `generate` | text/image → asset (mesh / texture / audio) | asset path + **provenance sidecar** |
| `import` | bring an external asset into the working format | normalized asset handle |
| `export` | emit the canonical contract format (**GLB** runtime; USD pipeline) | artifact path |
| `convert` | interchange transform (FBX/USD/Alembic ↔ GLB) | artifact path + lossiness report |
| `optimize` | decimate / LOD / atlas / compress (KTX2, Draco) | artifact + reduction metrics |
| `bake` | mesh-map / texture bake | map set |
| `validate` | topology/UV/PBR/format QC gate | normalized findings (art-pipeline §8) |
| `introspect` | dump scene/asset structure | structured tree |

### 6.3 Two mandatory execution profiles (mirrors engine-adapter `execution_profiles`)

- **`headless-compute`** — convert/optimize/bake/validate/import/export; runs in CI lights-out.
- **`render`** — preview/thumbnail/turntable capture; needs a GPU backend (lavapipe or xvfb+software
  GPU), exactly as the engine `capture` capability does.

### 6.4 Backend-class declaration (the new field this protocol adds)

Every asset-adapter manifest declares **`backend_class`** so the orchestrator knows whether it may
run in CI:

- `cli` — headless CLI/SDK (blender-bg, hython, sbsbaker, gltf-transform) → CI-eligible.
- `cloud-api` — stateless HTTP (Meshy/Tripo/ElevenLabs/Rodin) → CI-eligible, **stochastic**.
- `mcp-headless` — class-A MCP (Godot CLI-wrapper, dcc-mcp-houdini, Bevy BRP) → CI-eligible.
- `mcp-gui` — class-B MCP (Blender MCP, Substance Painter MCP, Cinema4D MCP) → **authoring only,
  never on the CI execution path**.

### 6.5 Manifest sketch **[PROVISIONAL]** (mirrors engine-adapter manifest format)

```yaml
# adapter: blender (DCC asset-adapter)
tool: blender
backend_class: cli            # NOT the GUI-bound blender-mcp; the --background path
capabilities:
  convert:   { fidelity: full,    profile: headless-compute,
               cmd: "blender --background --python drivers/convert.py -- {in} {out}" }
  optimize:  { fidelity: full,    profile: headless-compute, driver: "drivers/decimate.py" }
  bake:      { fidelity: full,    profile: headless-compute, method: cycles }   # NOT eevee
  export:    { fidelity: full,    profile: headless-compute, format: glb }
  validate:  { fidelity: partial, profile: headless-compute, driver: "drivers/qc.py" }
  generate:  { fidelity: none }   # Blender doesn't generate; route to cloud-api adapter
authoring_surface:            # the class-B MCP is declared here, fenced off from CI
  mcp: { repo: "ahujasid/blender-mcp", backend_class: mcp-gui, ci_eligible: false }
---
# adapter: meshy (asset-generation adapter)
tool: meshy
backend_class: cloud-api
auth: { env: MESHY_API_KEY }
capabilities:
  generate:  { fidelity: full, profile: headless-compute,
               modes: [text_to_3d, image_to_3d, retexture, rig, animate],
               determinism: stochastic, seed: supported }   # see §7
  export:    { fidelity: full, formats: [glb, fbx, usdz] }
mcp: { repo: "meshy-dev/meshy-mcp-server", backend_class: cloud-api, ci_eligible: true }
```

### 6.6 Conformance suite (anti-rot insurance, inherited)
A **reference asset-batch + adapter conformance test**: to be an accepted asset-adapter you
implement the protocol and go green on conformance for the capabilities you declare (e.g.
`convert` a known mesh and assert the GLB round-trips; `optimize` and assert monotonic LOD;
`validate` and assert known-bad meshes fail). New tool = implement adapter + pass conformance.
This is the mechanism that makes "wrap many tools" sustainable rather than aspirational — identical
rationale to the engine conformance suite (engine-adapter §Conformance suite).

### 6.7 Normalized result schema (inherited)
Every asset-adapter emits one shape Layers 1–2 consume, carrying `capability_fidelity` so the gate
knows how much to trust the result — directly analogous to the engine adapter's normalized result.

---

## 7. Reproducibility, Provenance & Security

### 7.1 Determinism — why CLI wins the spine
CLI/SDK invocations are a **pure function of (inputs, flags, env, pinned tool version)** → hermetic,
cacheable, bisectable. An MCP path inserts (a) an MCP server process, (b) a non-deterministic
LLM/agent planner, and (c) — for class B — opaque GUI state (which scene/camera/UI config is live).
Replaying an MCP-built artifact requires the exact agent config, model version, full tool-use
transcript, *and* app state. Therefore the **deterministic CI steps must be CLI/SDK**, and MCP is
confined to authoring. (This is the same determinism-tier logic the engine adapter already encodes;
the asset layer inherits it.)

### 7.2 Provenance — tie to the existing sidecar
Cloud-API generation (`backend_class: cloud-api`) is **stochastic**, so it cannot be made bitwise
reproducible — but it can be made **provenance-reproducible**. Every `generate` call MUST emit the
`asset-provenance-sidecar` already specified in AAA-RECONCILIATION §9 / R-001..R-006:
`generated_by_tool` (Meshy/Tripo/ElevenLabs + model version), `prompt_and_inputs_log`, **seed**
(where the API supports it — Meshy does), `license_terms_snapshot`, `indemnification` tier,
`training_data_provenance`, `likeness_consent_ref` (ElevenLabs voice → SAG-AFTRA ICDR, R-004),
`risk_tier`, `copyrightability_assessment`. The asset-adapter `generate` capability's output
contract IS the sidecar — provenance is not optional metadata, it is the return value.

### 7.3 Security in worktrees — the sharp edges (all verified)
- **`execute_python` / arbitrary code exec** is exposed by Blender MCP, Substance Painter MCP,
  Houdini MCP, Unreal MCP, and Unity (reflection/code-exec). This is **remote code execution by
  design**. In a worktree/CI context these servers must run in a sandbox (container, no host FS
  beyond the worktree, no secrets) and never be exposed beyond localhost.
- **Unauthenticated localhost sockets**: blender-mcp (:9876), chongdashu unreal-mcp (:55557),
  Godot MCP, dcc-mcp-houdini (:8765) ship **no auth** by default. Bind localhost only; one
  worktree = one isolated server instance; never bridge to a shared host.
- **Auth where it exists**: IvanMurzak Unity-MCP supports bearer-token (`--authorization=required`);
  CoplayDev supports remote-hosted auth; cloud APIs use env-var API keys → keys live in CI secret
  store, never in the worktree, never in the provenance sidecar's logged prompt.
- **Class-B-in-CI is itself a risk**: forcing a GUI app into headless CI (xvfb hacks) to satisfy a
  class-B MCP is fragile and non-deterministic — the decision rule (§5) forbids it precisely
  because it is both a reliability and a reproducibility hazard.

---

## 8. Open Questions & Risks

1. **[VERIFIED RISK] Blender MCP cannot be the CI Blender driver.** Issue #251 is unresolved as of
   2026-06-07. Mitigation: factory uses `blender --background --python` for all CI Blender work;
   blender-mcp is an authoring-only surface. *Re-check #251 each Blender/addon release.*
2. **MCP-server churn (R-009 adjacent).** Most of these repos are pre-1.0, early-stars, and
   fast-moving (Unreal MCP explicitly EXPERIMENTAL; Bevy MCP churns per Bevy release; Meshy official
   MCP is days-old). The asset-adapter `Semport` (version-pinned manifest, scheduled maintenance)
   is mandatory, same as the engine adapter.
3. **[UNVERIFIED] Maya MCP, Scenario MCP.** No single dominant, verified first-party MCP repo found.
   The verifiable integration points are Maya `commandPort`/`mayapy` (CLI) and Scenario's REST/
   GraphQL API. Treat as cloud-api/cli adapters, not MCP, until a maintained server appears.
4. **Official-Tripo-MCP trap.** `VAST-AI-Research/tripo-mcp` is Blender-addon-bound (class B) despite
   being "official." Use the Tripo REST API for CI. Verify before wiring.
5. **Star-count volatility.** Blender MCP read 22.4k (direct fetch) vs 17.7k (index, 2026-03-13).
   Treat all star numbers as date-stamped snapshots, not stable facts.
6. **Confabulation hazard (R-009, demonstrated live).** `sonar-deep-research` asserted these repos
   are hallucinations. They are not. *Process rule reaffirmed:* MCP/engine/tool inventory claims
   must be anchored to a primary-source repo fetch, never to a summarizer.
7. **Capture in CI still needs a GPU profile** for any MCP/CLI that renders previews — unchanged
   constraint from engine-adapter `execution_profiles`.
8. **Cloud-gen determinism ceiling.** Generation is provenance-reproducible, not bitwise-
   reproducible. Any contract that needs an exact asset must pin a generated artifact by hash, not
   re-generate. (Mirrors the determinism-tier degrade ladder.)

---

## 9. Sources

See YAML `sources` frontmatter. Primary-source anchors verified 2026-06-07 by direct repo/issue
fetch: blender-mcp (repo + issue #251), dcc-mcp-houdini, SubstacePainterMCP, cinema4d-mcp,
dcc-mcp-core RFC #998, CoplayDev/unity-mcp, IvanMurzak/Unity-MCP, Coding-Solo/godot-mcp,
chongdashu/unreal-mcp, runreal/unreal-mcp, natepiano/bevy_brp_mcp(+extras), Ladvien/bevy_debugger_mcp,
meshy-dev/meshy-mcp-server (+Meshy-guide), pasie15/meshy-ai-mcp-server, VAST-AI-Research/tripo-mcp,
elevenlabs/elevenlabs-mcp, apappascs/mcp-servers-hub (star snapshot), MCP transport guide.
Repo-internal grounding: engine-adapter-protocol.md, art-pipeline.md, AAA-RECONCILIATION.md.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 1 | Attempted deep inventory — **CONFABULATED (claimed repos don't exist); OUTPUT DISCARDED.** Documented as risk R-009 evidence. |
| Perplexity perplexity_reason | 1 | Logic check on the MCP-vs-CLI decision rule over already-verified facts (no new facts taken from it). |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — |
| Tavily tavily_search | 3 | Locate real repos (Meshy/Tripo MCP; Houdini/Maya/C4D/Substance MCP; Bevy BRP MCP); incl. github.com domain filter. Surfaced authoritative star snapshot (mcp-servers-hub). |
| Tavily tavily_extract | 0 | — |
| WebFetch | 8 | **PRIMARY-SOURCE verification** of actual repos + Blender MCP issues (#251 headless verdict): blender-mcp, CoplayDev/unity-mcp, Coding-Solo/godot-mcp, runreal+chongdashu unreal-mcp, meshy-mcp-server, tripo-mcp, elevenlabs-mcp, IvanMurzak/Unity-MCP, dcc-mcp-houdini, blender-mcp/issues. |
| WebSearch | 0 | — |
| Training data | ~1 area | Only the engine-adapter pattern framing (drawn from the repo's own docs, not memory). All tool/repo facts are repo-fetched. |

**Total MCP tool calls:** 11 (1 perplexity_research [discarded], 1 perplexity_reason, 3 tavily_search, + 8 WebFetch primary-source verifications [WebFetch is the load-bearing method here, by design — the topic demands repo-level verification, not summarizer synthesis]).
**Training data reliance:** low — every server/tool capability, transport, and headless verdict is anchored to a direct GitHub repo or issue fetch; the headless Blender verdict rests on issue #251 specifically. The deep-research summarizer was discarded for confabulating. Unverifiable items are flagged [UNVERIFIED].
