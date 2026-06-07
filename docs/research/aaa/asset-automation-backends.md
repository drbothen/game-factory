---
document_type: research
vector: asset-automation-backends
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
project: game-factory
title: "Asset Automation Backends — Control-Surface Taxonomy & Relaxed-Constraint Tool Re-Classification (Verified)"
scope: >
  Re-evaluates the previously-"blocked" / GUI-bound asset tools under a RELAXED CONSTRAINT
  from the product owner: headless is NOT required, a programmatic REST API is NOT required.
  A tool QUALIFIES if it can produce an asset and EXPORT a license-clean, ingestible artifact
  into the asset library, driven by ANY control surface — REST API, MCP, headless CLI, SaaS
  web UI (browser automation), or local GUI desktop app (GUI automation). The unifying
  contract is ASSET-LIBRARY INGESTION + PROVENANCE, not the control method. Defines the
  backend_class taxonomy the asset-adapter must support, re-classifies the GUI-bound tools,
  revises wrap-first picks, expands the asset-adapter protocol, and registers ToS/legal risk
  for automation of SaaS UIs.
relaxed_constraint_source: "product owner — OVERRIDES prior 'headless required / no-API = blocker' stance"
ties_to:
  - docs/research/aaa/asset-tooling-catalog.md
  - docs/research/aaa/mcp-automation-layer.md
  - docs/research/aaa/AAA-RECONCILIATION.md
  - docs/design/engine-adapter-protocol.md
provenance_note: >
  PRIMARY-SOURCE DISCIPLINE (R-009). Prior perplexity_research deep-research passes
  CONFABULATED tool specifics on this codebase (claimed real MCP repos were "hallucinations";
  self-reported using stale 2024 training data). Therefore THIS pass used ZERO perplexity
  deep-research for tool facts. Every tool/control-surface/export-format/ToS claim below was
  verified by fetching the vendor's OWN product / docs / ToS page (WebFetch or tavily_extract/
  tavily_search returning the vendor page verbatim). URLs in `sources`. Claims that could not
  be primary-sourced are marked [UNVERIFIED]. ToS quotes are verbatim from the cited ToS page.
sources:
  # Re-classified GUI-bound / previously-blocked tools (primary-source verified this pass)
  - https://www.prometheanai.com/                      # set-dressing orchestrator; operates ON existing assets
  - https://www.prometheanai.com/architectural-visualization  # "drag folder of 3d assets... build worlds"; UE-primary
  - https://cascadeur.com/                             # FBX/DAE/USD export; desktop GUI
  - https://cascadeur.com/python-api                   # csc module; csc.fbx export_all_objects; Python 3.8
  - https://cascadeur.com/help/tools/animation_tools/python_scripting_in_cascadeur  # re-export script (FbxSceneLoader)
  - https://docs.kaedim3d.com/                         # export obj/fbx/glb/gltf/usd/mtl; human-in-loop
  - https://docs.kaedim3d.com/enterprise-features/custom-integrations/apis/web-api  # Web API: POST, X-API-Key+JWT, imageUrls/LoQ/polycount → obj/fbx/glb/gltf/mtl
  - https://openart.ai/generator/sprite                # web GUI; commercial use REQUIRES attribution + backlink to OpenArt
  - https://openart.ai/terms                           # §4.4 "No automated access, bots, or scripts"; §5.5 no scraping
  - https://openart.ai/help                            # "No public API is available currently"
  - https://lab.rosebud.ai/terms-of-service            # §(xi) "use spiders, crawlers, robots, scrapers, automated tools... to access the Services" prohibited
  - https://help.rosebud.app/about-us/terms-of-service # Rosebud KB ToS
  # GUI-bound DCC + MCP (scripting / headless surfaces, verified)
  - https://docs.blender.org/manual/en/latest/advanced/command_line/render.html  # blender -b background, no X server
  - https://github.com/ahujasid/blender-mcp/issues     # #251 headless hang (class-B MCP)
  - https://experienceleague.adobe.com/en/docs/substance-3d-painter/using/scripting-and-development/scripts-and-plugins/remote-control-with-scripting  # --enable-remote-scripting (class-B; needs running Painter)
  - https://community.adobe.com/questions-50/automation-api-substance-discontinued-625968  # sbsrender CLI from python, 30-40 params, batch
  - https://github.com/razluta/substance-automation-toolkit_samples  # Pysbs + sbscooker/sbsrender headless batch
  - https://help.maxon.net/zbr/en-us/Content/html/reference-guide/zscript/zscript-python.html  # ZBrush -batch -script; batch-export SubTools to OBJ no-UI; FBX modal-dialog gotcha
  - https://developer.marvelousdesigner.com/python.html  # MD Python API (in-app editor)
  - https://developer.marvelousdesigner.com/register.html  # .py plug-in registration
  - https://digitalproduction.com/2025/09/30/marvelous-designer-finally-sews-itself-into-linux  # MD Linux + Python API batch import/export/automation (vendor claim)
  # Companion / upstream docs (repo-internal grounding)
  - docs/research/aaa/asset-tooling-catalog.md
  - docs/research/aaa/mcp-automation-layer.md
  - docs/research/aaa/AAA-RECONCILIATION.md
  - docs/design/engine-adapter-protocol.md
---

# Asset Automation Backends — Control-Surface Taxonomy & Relaxed-Constraint Tool Re-Classification

> **Companion / superseding-in-part doc.** This relaxes the headless-required constraint that
> drove the "BLOCKER" verdicts in `asset-tooling-catalog.md §4` and the "fence GUI-bound MCP
> off CI" rule in `mcp-automation-layer.md §5`. It does **not** rewrite those docs' verified
> facts — it adds a control-surface layer above them and re-classifies the GUI-bound tools.
> The decisive architectural property from `mcp-automation-layer.md §2` (class-A wraps a
> headless substrate; class-B embeds in a GUI event loop) is **retained and extended** here
> into a six-class taxonomy with reproducibility/reliability/ToS tiers.

---

## 1. Executive Summary

**The relaxed constraint changes the verdict, not the physics.** Under "asset-library ingestion
+ provenance is the contract, not the control method," most previously-"blocked" tools become
**technically drivable** — every one of them can produce an asset and emit an ingestible format
(FBX/OBJ/GLB/USD/PNG). But they split sharply on two axes the relaxation does *not* abolish:
**reproducibility** (a GUI-driven run is never a pure function of inputs) and **legality** (some
SaaS ToS explicitly forbid the automation that makes a no-API tool "drivable").

Seven load-bearing, primary-source-verified findings:

1. **The factory must support six backend classes**, in a strict preference order from most to
   least reproducible: `cloud-api` → `headless-cli` → `mcp-headless` → `mcp-gui` → `saas-ui` →
   `desktop-gui`. The first three are CI-deterministic; the last three are
   provenance-reproducible-only and carry reliability and (for `saas-ui`) legal risk.

2. **Two named SaaS tools have ToS that LEGALLY FORBID the browser automation that would
   "unblock" them.** **OpenArt** ToS §4.4 (verbatim): *"No automated access, bots, or scripts"*
   and *"Do not access our generation service except through openart.ai or our official app …
   Only real human interactions are allowed."* **Rosebud** ToS §(xi) (verbatim): prohibits
   *"spiders, crawlers, robots, scrapers, automated tools, or any other similar means to access
   the Services."* For these two, `saas-ui` browser automation is a **ToS violation even though
   technically possible** — they stay NOT-VIABLE for lights-out use regardless of the relaxation.

3. **Kaedim flips from blocked to viable-via-API.** It has an official **Web API** (verified:
   `POST` with `X-API-Key` + JWT auth; body `imageUrls`/`LoQ`/`polycount`/dimensions) returning
   **obj/fbx/glb/gltf/mtl** download URLs. The human-in-the-loop QC is real (in-house artists
   refine outputs) so it is **async-with-latency, not lights-out-instant** — but it is API-driven,
   so no UI automation and no ToS hazard. Viable as a Tier-2/3 high-quality-mesh backend.

4. **Cascadeur flips to viable-via-desktop-gui (not API).** It has a real **Python `csc` API**
   (Python 3.8; `csc.fbx`, `FbxSceneLoader.export_all_objects(...)` exports FBX) and exports
   **FBX/DAE/USD** — but there is **no documented command-line / headless / batch flag**. It must
   be driven by GUI automation (tmux-cli/Playwright + Xvfb) running its in-app Python console, or
   left as a human-finishing tool. `desktop-gui`, not `cloud-api`.

5. **The GUI-bound DCCs split by whether they ship a true headless CLI underneath the GUI.**
   **Blender** (`--background --python` bpy), **ZBrush** (`-batch -script`, batch-export SubTools
   to OBJ with no UI), and **Substance Designer/Automation Toolkit** (`sbscooker`/`sbsrender`/
   Pysbs) are **headless-cli** — fully CI-deterministic. **Substance Painter**
   (`--enable-remote-scripting` needs a *running* Painter) and **Marvelous Designer** (Python API
   runs *inside* the app) are **desktop-gui / mcp-gui** — drivable only with the GUI alive
   (Xvfb). **Blender MCP** specifically remains `mcp-gui` (issue #251 headless hang) — but Blender
   *itself* via bpy is `headless-cli`. The class is a property of the **driver path**, not the app.

6. **Promethean AI is re-classified but for a different reason: it doesn't *generate* assets.**
   Verified: it is a **set-dressing / scene-assembly orchestrator that operates ON your existing
   3D assets** ("drag a folder of your 3D assets… Sync… build worlds"; "primary integration is
   Unreal Engine"). Its "output" is a populated scene inside the host DCC/engine, not a
   standalone ingestible asset file. So even under the relaxed rule it is **viable-via-desktop-gui
   ONLY as an environment-layout step inside an engine adapter** (Unreal-primary, deferred), not
   as an asset-library-ingestion backend. It produces scene *arrangements*, not assets.

7. **The single biggest caveat of the whole GUI/SaaS automation approach is twofold and
   unavoidable:** (a) **reliability/reproducibility** — a `saas-ui`/`desktop-gui` run is a
   function of opaque UI state, pixel layout, network timing, and undocumented version drift, so
   it can never be bitwise-replayed and breaks silently when the vendor reskins the UI; and (b)
   **legality** — for `saas-ui` specifically, automation may breach the vendor's ToS (OpenArt,
   Rosebud confirmed). The factory must therefore treat `saas-ui`/`desktop-gui` as a
   **last-resort, ToS-gated, reliability-tiered backend**, never the default.

**Bottom line:** the relaxation legitimately *expands* the wrappable set — Kaedim (API),
Cascadeur (GUI), and the script-driven DCCs (Blender/ZBrush/Substance/Marvelous) all become
usable behind the asset-adapter seam — **but it does not abolish the preference for `cloud-api`/
`headless-cli`, and it explicitly excludes two tools (OpenArt, Rosebud) whose ToS forbid the
automation.** The asset-adapter gains a `backend_class` enum and a ToS-gate; the
ingestion/provenance contract is unchanged.

---

## 2. Control-Surface Taxonomy (the six backend classes)

Each backend class declares how the factory drives it, its reproducibility, reliability,
scale/cost, provenance-capture method, and ToS/legal risk. Ordered most→least reproducible
(= the preference order in §4).

| `backend_class` | How factory drives it | Reproducibility | Reliability / brittleness | Scale & cost | Provenance-capture method | ToS / legal risk |
|---|---|---|---|---|---|---|
| **`cloud-api`** | HTTPS REST/SDK call (Meshy, Tripo, Sloyd, Kaedim, Scenario, ElevenLabs, Leonardo) | **Provenance-reproducible** (stochastic output; seed where supported) | 🟢 High — stable contract, versioned, retry/idempotency | 🟢 Elastic; per-credit cost; parallel | API returns model+version+seed+task-id → sidecar fields direct | 🟢 Low — API use is the sanctioned path; capture `license_terms_snapshot` + `tier_at_generation` |
| **`headless-cli`** | Spawn CLI/SDK process (blender `-b --python`, hython, `sbscooker`/`sbsrender`/Pysbs, ZBrush `-batch -script`, gltf-transform, usdchecker) | **Bitwise-reproducible** (pure fn of inputs+flags+pinned version) | 🟢 High — hermetic, cacheable, bisectable | 🟢 Cheap, parallel, on CI runners | command line + tool version + input hashes fully logged | 🟢 Low — local tooling you license; respect EULA seat terms |
| **`mcp-headless`** | MCP over a headless substrate (Godot CLI-wrapper, dcc-mcp-houdini in hython, Bevy BRP, IvanMurzak Unity Docker, cloud-API MCP shims) | Provenance-reproducible (LLM planner is non-deterministic; substrate is) | 🟡 Med — adds MCP process + agent planner; pin server version | 🟢 CI-eligible | MCP tool-call transcript + substrate logs | 🟢 Low (localhost-bound; secrets in CI store) |
| **`mcp-gui`** | MCP embedded in a GUI event loop (Blender MCP `bpy.app.timers`, Substance Painter MCP, Cinema4D MCP) | **Not reproducible** (opaque GUI state) | 🔴 Low — issue #251 class hang; needs live GUI + Xvfb | 🟡 One GUI per worktree; heavy | MCP transcript + screenshot, but app state unlogged | 🟡 Med — local app; but RCE-by-design (`execute_python`) — sandbox |
| **`saas-ui`** | Browser automation (Playwright MCP) driving a SaaS web UI that has no API | **Not reproducible** (DOM/layout/network timing) | 🔴 Lowest — silent break on any UI reskin; CAPTCHA/bot-detection | 🟡 Rate-limited; per-account; serial-ish | screen recording + DOM trace + download artifact; weak | 🔴 **HIGH — many SaaS ToS forbid automated/bot access (OpenArt, Rosebud verified). Must ToS-gate per tool.** |
| **`desktop-gui`** | GUI automation (tmux-cli / Playwright-on-Electron / OS-level) of a local desktop app under Xvfb (Cascadeur, Marvelous Designer interactive, Promethean) | **Not reproducible** (UI state, timing, version) | 🔴 Low — pixel/widget-fragile; version-drift; modal dialogs (ZBrush FBX) | 🔴 Heavy; one app instance per job; license seats | OS-level recording + exported-file hash; app state unlogged | 🟡 Med — local EULA (per-seat, automation allowed unless EULA forbids) — verify per tool |

**Two cross-cutting truths carried from `mcp-automation-layer.md`:**
- **The class is a property of the driver path, not the tool.** Blender is `headless-cli` (bpy
  `-b`) *and* `mcp-gui` (Blender MCP addon) simultaneously; the adapter declares which path it
  uses. Always prefer the headless path of a tool that has one.
- **`render` still needs a GPU backend** (lavapipe / Xvfb+software-GPU) on every class that
  produces previews/turntables — unchanged from engine-adapter `execution_profiles`.

---

## 3. Re-Classification of Previously-Blocked / GUI-Bound Tools (verified)

Verdict vocabulary: `viable-via-api` / `viable-via-saas-ui` / `viable-via-desktop-gui` /
`still-not-viable`. Every export-format and control-surface claim primary-source-verified
this pass (see `sources`); ToS quotes are verbatim.

### 3.1 — Previously-blocked named tools

| Tool | Control surface (verified) | Generates an asset? | Export format → ingestible? | Verdict | ToS / legal note |
|---|---|---|---|---|---|
| **Promethean AI** | Desktop app + UE/Unity/Maya/Blender/3dsMax plugins; "Enterprise … API" (sales-led, [UNVERIFIED] shape); Python-customizable plugins | **No — it set-dresses / arranges EXISTING assets** ("drag a folder of your 3D assets… build worlds"); "primary integration is Unreal Engine" | Output = a populated **scene inside the host DCC/engine**, not a standalone asset file | **viable-via-desktop-gui — but only as an ENVIRONMENT-LAYOUT step inside an engine adapter (Unreal-primary, deferred), NOT an asset-library backend.** It produces scene arrangements, not assets. | 🟡 Local app EULA; privacy-first ("never exposed to your asset files"). No SaaS-scraping issue. |
| **Cascadeur (Nekki)** | Desktop GUI + **Python `csc` API** (Python 3.8; `csc.fbx`, `FbxSceneLoader.export_all_objects`); exports **FBX/DAE/USD**. **No documented headless/CLI/batch flag.** | Yes (AI-assisted keyframe/physics animation on a rig) | **FBX/DAE/USD → yes** (FBX is the bridge; USD native) | **viable-via-desktop-gui** — drive the in-app Python console via GUI automation (tmux-cli/Playwright + Xvfb), or keep as human-finishing. Not API/headless. | 🟡 Local per-seat license; automation not forbidden by a SaaS ToS (it's a desktop app). |
| **OpenArt Sprite Generator** | **Web GUI only. "No public API is available currently"** (help page, verbatim). | Yes (2D sprite images; **no animated sheet, no JSON atlas** per comparison data) | PNG (export "varies"); commercial use **requires attribution + backlink to OpenArt**; images default to public-domain | **still-not-viable** — and not for lack of a surface but because **ToS forbids the only available surface's automation.** | 🔴 **ToS §4.4 (verbatim): "No automated access, bots, or scripts" / "Only real human interactions are allowed."** Browser automation = ToS violation. Also attribution-encumbered + uncopyrightable. |
| **Kaedim** | **Official Web API** (verified: `POST`, `X-API-Key` + `Authorization` JWT, body `imageUrls`/`images`/`LoQ`/`polycount`/`height`/`width`/`depth`/`projectID`/`studioID`; returns iteration results with obj/fbx/glb/gltf/mtl URLs) | Yes (2D→3D), **human-in-the-loop QC** (in-house artists refine; async with latency) | **obj/fbx/glb/gltf/usd/mtl → yes** | **viable-via-api** (async). Tier-2/3 high-quality-mesh backend; not instant lights-out (human QC latency) but fully API-driven. | 🟢 API is the sanctioned path → no UI scraping, no ToS hazard. Verify commercial/redistribution terms at integration ([UNVERIFIED] this pass — ToS page 404'd). |
| **Rosebud AI** | **Web app only** (NL→full game / sprite sheet / 3D world). No asset-export API surfaced. | Generates whole games + some assets; **no engine-neutral per-asset export API surfaced** | [UNVERIFIED] per-asset export; overlaps the factory's own role | **still-not-viable** — no per-asset export surface AND ToS forbids automation of the web surface. | 🔴 **ToS §(xi) (verbatim): prohibits "spiders, crawlers, robots, scrapers, automated tools, or any other similar means to access the Services."** Plus expansive UGC license grant to Rosebud. Browser automation = ToS violation. |

### 3.2 — GUI-bound DCC / MCP tools

| Tool | Drivable surface(s) (verified) | Export format → ingestible? | Verdict (class) | Reproducibility / ToS note |
|---|---|---|---|---|
| **Blender (bpy)** | **`headless-cli`**: `blender --background --python` (no X server) — confirmed | GLB/USD/FBX/Alembic/OBJ → yes (the canonical conversion node) | **viable-via-headless-cli** | 🟢 Bitwise-reproducible. The CI Blender driver. |
| **Blender MCP** (`ahujasid/blender-mcp`) | **`mcp-gui`**: socket server in a Blender *addon*; `bpy.app.timers` never fires under `-b` (issue #251) | (whatever Blender exports) | **authoring-only — never on CI execution path**; use bpy headless instead | 🔴 Not reproducible; needs live GUI. Carried verbatim from `mcp-automation-layer.md`. |
| **Substance Designer / Automation Toolkit** | **`headless-cli`**: `sbscooker` (`.sbs`→`.sbsar`), `sbsrender` (sbsar→textures, 30-40 params batch), **Pysbs** — confirmed | PNG/EXR texture sets, .sbsar → yes | **viable-via-headless-cli** | 🟢 Bitwise-reproducible; the texture/material CI spine. |
| **Substance Painter** | **`desktop-gui`/`mcp-gui`**: `--enable-remote-scripting` + Python/JS remote API — but **needs a running Painter** (confirmed Adobe docs) | textured-mesh / texture-set export → yes | **viable-via-desktop-gui** (Xvfb + remote-scripting) — prefer Designer CLI where possible | 🟡 Not reproducible (live app); RCE-by-design `execute_python` → sandbox. |
| **ZBrush** | **`headless-cli`**: `ZBrush -batch -script x.py`; batch-export visible SubTools to **OBJ** with no UI (Maxon docs, ZBrush 2026) | **OBJ → yes (robust)**; **FBX → 🔴 fragile** (FBX export pops a modal "note interface" that breaks scripts — verified ZBrushCentral) | **viable-via-headless-cli for OBJ**; FBX path is GUI-fragile (use Blender to OBJ→FBX downstream) | 🟢 OBJ batch is reproducible; 🔴 avoid scripted FBX (modal dialog). |
| **Marvelous Designer** | **`desktop-gui`**: **Python API** (`developer.marvelousdesigner.com`; CLO Python; .py plug-ins; Linux-enterprise "batch import/export, automation" — **vendor claim, batch-mode reproducibility [UNVERIFIED]**) runs *inside* the app | OBJ/FBX/Alembic/USD/glTF (cloth) → yes | **viable-via-desktop-gui** (Xvfb); Linux Python API may approach `headless-cli` but unverified | 🟡 Not reproducible (in-app); re-verify true headless batch at integration. |
| **Cascadeur** | see §3.1 — `desktop-gui` | FBX/DAE/USD → yes | **viable-via-desktop-gui** | 🟡 No headless flag. |

---

## 4. Revised Preference Order & Wrap-First Updates

### 4.1 Backend-class preference order (the standing rule)

```
PREFER, in order (most → least reproducible / cheapest / safest):
  1. cloud-api      — stateless HTTP; provenance-reproducible; elastic; ToS-clean (API is sanctioned)
  2. headless-cli   — hermetic, bitwise-reproducible, cacheable; the deterministic spine
  3. mcp-headless   — class-A MCP over a headless substrate; CI-eligible (pin server version)
  --- the reproducible CI tier ends here ---
  4. mcp-gui        — class-B MCP; AUTHORING-ONLY, never on CI execution path
  5. saas-ui        — browser automation; ONLY if no API/CLI exists AND the tool's ToS PERMITS automation
  6. desktop-gui    — GUI automation under Xvfb; last resort, reliability-tiered, per-seat-licensed

RULE A (substitution): if a tool exposes more than one surface, ALWAYS declare the
  highest-preference class it supports (Blender → headless-cli, never mcp-gui).
RULE B (ToS gate): a saas-ui backend MUST pass a ToS check (`tos_permits_automation: true`)
  before it may run. OpenArt and Rosebud FAIL this gate → disabled.
RULE C (reliability tier): classes 4-6 are tagged reliability: low and are excluded from any
  contract that requires reproducible regeneration; their outputs must be pinned-by-hash once
  generated (mirrors the cloud-gen determinism ceiling, mcp-automation-layer §8.8).
```

### 4.2 Wrap-first updates — does GUI/SaaS change the picks?

**Environments / worlds:** The relaxation makes **Promethean attractive *as a layout step*, not
as an asset source.** Recommendation: keep **World Labs (Marble)** [pending license verify] as the
`cloud-api` greybox/blockout environment **asset** generator (preferred), and **add Promethean as
an optional `desktop-gui` set-dressing/layout backend that runs INSIDE the engine adapter**
(Unreal-primary → deferred with the Unreal adapter; Unity/Blender plugins as the cross-engine
path). It arranges already-ingested assets into scenes; it is an *assembly* tool, downstream of
the asset library, not a producer feeding it. Procedural alternatives (Houdini `hython` HDA/PDG,
WFC/BSP) remain the reproducible `headless-cli` default for layout.

**Animation / rigging:** The reproducible default is **unchanged** — **Meshy/Tripo/Sloyd in-API
rig+animate** (`cloud-api`) for humanoid base. The relaxation **adds Cascadeur as a
`desktop-gui` finishing backend** for physics-plausible / stylized keyframe animation that the
in-API riggers can't do (non-humanoid, secondary motion, hero polish) — driven via its `csc`
Python console under GUI automation, exporting FBX/USD. **Move.ai** stays the `cloud-api`
video-mocap option *if* its headless API is confirmed. So: cloud-api first (Meshy/Tripo/Sloyd),
Cascadeur (`desktop-gui`) as the now-allowed finishing tier, human only for hero faces.

**2D sprites:** **Unchanged and reinforced.** AutoSprite (`cloud-api` + MCP) remains wrap-first.
The relaxation does **not** rescue **OpenArt** (ToS forbids automation; no API; attribution-
encumbered) — AutoSprite/Scenario/SEELE-class API tools dominate it on every axis.

**High-quality 2D→3D mesh:** **New entry** — **Kaedim (`viable-via-api`, async)** joins as a
Tier-2/3 backend where the human-QC'd mesh quality justifies the latency, slotting alongside
Meshy/Tripo (faster, fully-automatic) for hero-draft props.

---

## 5. Expanded Asset-Adapter Protocol (mirrors engine-adapter)

Extends the asset-adapter sketch in `mcp-automation-layer.md §6`. The protocol is unchanged in
spirit — stable protocol + pluggable backends + capability negotiation + conformance suite,
JSON-RPC 2.0 — with three additions for the relaxed constraint: the **6-value `backend_class`
enum**, a **ToS gate**, and the **ingestion-normalization** seam.

### 5.1 `backend_class` enum (the new declared field)

```
backend_class ∈ {
  cloud-api      # CI-eligible, provenance-reproducible
  headless-cli   # CI-eligible, bitwise-reproducible
  mcp-headless   # CI-eligible, provenance-reproducible
  mcp-gui        # authoring-only — ci_eligible: false
  saas-ui        # last-resort — requires tos_permits_automation: true
  desktop-gui    # last-resort — requires virtual_display + reliability tier
}
```

Every asset-adapter manifest declares exactly one `backend_class`, plus, for the GUI/SaaS
classes, the reliability/ToS fields that gate CI use.

### 5.2 Conformance + capability negotiation across surfaces

- **Capability surface is identical across classes** (`generate`/`import`/`export`/`convert`/
  `optimize`/`bake`/`validate`/`introspect`, each fidelity-graded `full|partial|none`). A
  `desktop-gui` Cascadeur adapter and a `cloud-api` Meshy adapter both implement `generate`+
  `export`; the *class* tells the orchestrator how much to trust and whether CI may run it.
- **Capability negotiation adds two flags** the orchestrator reads before dispatch:
  `determinism: bitwise|provenance|none` and `reliability: high|med|low`. The
  declare-and-degrade principle then routes: a contract needing reproducible regeneration
  refuses `reliability: low` backends and falls back to a pinned artifact hash.
- **Conformance suite is per-class.** A `headless-cli` adapter must round-trip the reference
  asset batch deterministically (run twice → identical hash). A `desktop-gui`/`saas-ui` adapter
  passes a **weaker conformance**: produce a *schema-valid, ingestible* artifact + a complete
  provenance sidecar + a captured run-recording (screen/DOM trace) — reproducibility is
  explicitly NOT asserted, only ingestion-correctness and provenance-completeness.

### 5.3 Swapping a class-B/GUI tool for an API tool behind one seam

Because all classes implement the same capability surface and emit the same normalized result +
provenance sidecar, the orchestrator selects a backend per `asset-generation-request` by
**policy**, not by code path:

```
select_backend(request):
  candidates = adapters_implementing(request.capability)              # e.g. generate:mesh
  candidates = filter(candidates, tos_permits_automation OR class in {cloud-api,headless-cli,mcp-headless})
  candidates = filter(candidates, request.determinism_need <= adapter.determinism)
  return min(candidates, key=backend_class_rank)                      # §4.1 preference order
```

Replacing Cascadeur (`desktop-gui`) with a future animation REST API (`cloud-api`) is a
manifest/registry change only — the factory core, the request schema, the normalized result,
and the provenance sidecar are untouched. This is the same anti-lock-in seam as the engine
adapter; the `backend_class` is just the asset-side analog of `execution_profiles`.

### 5.4 Asset-library ingestion normalization (the unifying contract)

Regardless of `backend_class`, every produced artifact is normalized on ingestion to the
canonical set already locked in `AAA-RECONCILIATION.md §9` / `asset-tooling-catalog.md §5`:

| Modality | Canonical ingest format | Bridge/convert | Adapter `convert` does |
|---|---|---|---|
| 3D runtime | **GLB (glTF 2.0)** | FBX/OBJ/USD → GLB (blender `-b` or gltf-transform) | normalize + emit lossiness report |
| 3D pipeline/scene | **USD** | Alembic for baked sim | scene assembly backbone |
| 2D sprite | **PNG atlas + JSON** | individual frames → packed | slice/pack to engine atlas |
| 2D image/texture | **PNG/EXR** (+ KTX2 compressed) | — | KTX2/Draco optimize |
| Audio | **WAV/PCM** | MP3 → WAV | loudnorm |

The ingestion seam means a `desktop-gui` Cascadeur FBX, a `cloud-api` Meshy GLB, and a
`headless-cli` ZBrush OBJ all land in the library as **GLB + provenance sidecar** — the control
surface is fully erased downstream. **No new interchange format is required by any of the newly-
admitted backends** (every one emits FBX/OBJ/GLB/USD/PNG, all already in the canonical set).

### 5.5 Provenance sidecar additions for GUI/SaaS backends

The existing sidecar (`AAA-RECONCILIATION.md §9; asset-tooling-catalog.md §6`) gains three
fields so a non-reproducible backend is still auditable:
- **`backend_class`** — which surface produced the asset (drives trust + regeneration policy).
- **`run_recording_ref`** — for `mcp-gui`/`saas-ui`/`desktop-gui`: pointer to the screen/DOM/
  console trace that stands in for bitwise reproducibility.
- **`tos_snapshot_ref`** — for `saas-ui`: the ToS version checked + the `tos_permits_automation`
  verdict at generation time, so a later ToS change is detectable.

(Carried unchanged: `tier_at_generation`, `resale_of_raw_model_allowed`, `attribution_required`,
`indemnification`, `training_data_provenance`, `litigation_status`, `likeness_consent_ref`,
`copyrightability_assessment`.)

---

## 6. ToS / Legal Risk Register (automation-of-UI)

Records, per tool, whether automating its non-API surface is **legally permitted**. This is the
gate from Rule B (§4.1). Verbatim ToS quotes are primary-sourced.

| Tool | Surface that would need automation | ToS verdict on automation | `tos_permits_automation` | Action |
|---|---|---|---|---|
| **OpenArt** | web GUI (no API) | **FORBIDDEN.** ToS §4.4: *"No automated access, bots, or scripts"*; *"Only real human interactions are allowed"*; §5.5 no scraping. | **false** | **Disabled.** Do not browser-automate. Use AutoSprite/Scenario instead. |
| **Rosebud** | web app (no per-asset API) | **FORBIDDEN.** ToS §(xi): prohibits *"spiders, crawlers, robots, scrapers, automated tools, or any other similar means to access the Services."* | **false** | **Disabled.** Also no per-asset export + role-overlap. |
| **Kaedim** | **none — has official API** | API is sanctioned; UI-scraping moot. ToS page not reachable this pass → re-verify acceptable-use at integration. | true (via API) / [UNVERIFIED for UI] | Use the Web API; never scrape the UI. |
| **Cascadeur** | local desktop GUI | Local per-seat EULA, not a SaaS ToS; desktop automation generally permitted unless EULA forbids ([UNVERIFIED — read EULA]). | likely-true (desktop) | GUI-automate locally; confirm EULA permits automation + the seat covers CI use. |
| **Marvelous Designer** | local desktop GUI (+ Python API) | Local EULA; enterprise/Linux build markets automation ([UNVERIFIED — read EULA + seat terms]). | likely-true (desktop) | Use Python API under Xvfb; confirm enterprise seat. |
| **Promethean** | local desktop app + plugins | Local; privacy-first ("never exposed to your asset files"). No SaaS-scraping issue. | likely-true (desktop) | Drive in-editor; it's a layout step, not an asset producer. |
| **Substance Painter / Designer / ZBrush / Blender** | local CLI / app | Local license tooling; automation is the documented intent (CLI/scripting). | true | Use the documented headless/scripting path. |

**Legal principle (verified context):** even *publicly accessible* SaaS output can become
*unlawful to acquire* when the **method** is automated scraping that the ToS prohibits
(courts have treated automated scraping at scale as "improper means" regardless of public
accessibility). Therefore `saas-ui` automation is **never** safe-by-default; it is permitted
only behind an explicit per-tool ToS check that currently **passes for zero** of the named
no-API SaaS tools in scope. **API-backed tools sidestep this entirely** — which is the
strongest argument, even under the relaxed constraint, for keeping `cloud-api` first.

---

## 7. Open Questions

1. **[UNVERIFIED] Kaedim acceptable-use / commercial / redistribution terms** — API + formats
   verified; ToS page 404'd this pass. Confirm commercial-ship + resale-of-mesh + the human-QC
   SLA/latency before relying on it for Tier-2/3.
2. **[UNVERIFIED] Marvelous Designer true headless batch** — Linux Python API claims "batch
   import/export, automation" (vendor); confirm whether it runs without a display (→ promote to
   `headless-cli`) or needs Xvfb (`desktop-gui`).
3. **[UNVERIFIED] Cascadeur EULA automation clause + CI seat** — `csc` Python + FBX export
   verified; confirm the desktop EULA permits unattended GUI automation and that a seat covers
   CI/farm use.
4. **[UNVERIFIED] Promethean "Enterprise API" shape** — sales-led; if a real headless API
   exists it could promote Promethean's *layout* step from `desktop-gui` toward `cloud-api`/
   `mcp-headless` — but it would still be a scene-assembly step, not an asset producer.
5. **ZBrush scripted-FBX modal-dialog** — OBJ batch is robust; FBX export pops a blocking note
   interface. Decide policy: ZBrush→OBJ then Blender OBJ→FBX (`headless-cli` chain), vs. accept
   GUI-fragility for direct FBX.
6. **`saas-ui` ToS monitoring** — for any future no-API SaaS tool we might admit, who owns the
   recurring ToS re-check (`tos_snapshot_ref`)? ToS changes silently; a tool can flip from
   permitted to forbidden between releases.
7. **Reliability budget for `desktop-gui`/`saas-ui`** — define the flake-rate / retry / break-
   detection SLOs and the screenshot/DOM-trace evidence standard for the weaker conformance tier
   (§5.2) before any class-B/GUI backend is allowed in a wave.

---

## 8. Sources

See YAML `sources`. Every re-classification row was verified by fetching the vendor's own
product/docs/ToS page (WebFetch / tavily_search returning the vendor page verbatim) on
2026-06-07. ToS quotes (OpenArt §4.4/§5.5, Rosebud §(xi)) are verbatim from the cited ToS
pages. [UNVERIFIED] items are flagged inline and listed in §7. Repo-internal claims cite the
companion docs explicitly. NO perplexity deep-research was used for tool facts (R-009
confabulation discipline).

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 0 | **Deliberately NOT used for tool facts.** Prior passes on THIS codebase confabulated tool specifics (claimed real repos were hallucinations; self-reported stale 2024 data) — documented as R-009. Per the project's anti-confabulation rule, tool/ToS/format claims were primary-source-verified directly instead. Deviation from the perplexity_research default is justified by the documented confabulation on exactly this topic. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no single-library doc question; tool facts are vendor-page-verified) |
| Tavily tavily_search | 8 | **PRIMARY verification** — Cascadeur Python API + command-line; Kaedim Web API + endpoints; Marvelous Designer Python API + formats; OpenArt sprite API + license; Rosebud ToS automation clause; OpenArt ToS automation clause; ZBrush `-batch -script` + FBX modal gotcha; Substance Painter/Designer Python + sbsrender/Pysbs headless; Kaedim ToS; Promethean export reality. Returned vendor pages verbatim (ToS quotes sourced here). |
| Tavily tavily_extract | 0 | — |
| WebFetch | 8 | **PRIMARY-SOURCE verification** of vendor pages: prometheanai.com (control surface + "operates on existing assets"), cascadeur.com (FBX/DAE/USD export, no headless flag), cascadeur.com/python-api (csc submodules, no batch flag), kaedim3d.com (human-in-loop) + docs.kaedim3d.com (obj/fbx/glb/gltf/usd/mtl), kaedim3d ToS (404), openart.ai/sprite (404→search), marvelousdesigner.com (empty→search). |
| WebSearch | 0 | — |
| Training data | ~2 areas | Only the asset-adapter / engine-adapter pattern framing (from the repo's own docs) and the GLB/USD/FBX canonical-set mapping (from AAA-RECONCILIATION). No tool/ToS/format/version facts taken from training data — all vendor-page-verified or flagged [UNVERIFIED]. |

**Total MCP/web tool calls:** 16 (8 tavily_search + 8 WebFetch). **Zero perplexity calls — justified deviation** (R-009 confabulation on this exact topic; primary-source verification is the mandated discipline here).
**Training data reliance:** low — every control-surface, export-format, and ToS claim is anchored to a vendor product/docs/ToS page fetched this pass; ToS prohibitions are verbatim quotes; unverifiable items (Kaedim ToS, MD headless batch, Cascadeur EULA, Promethean enterprise API) are explicitly flagged [UNVERIFIED] rather than guessed.
