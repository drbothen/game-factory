---
document_type: research
vector: art-pipeline
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
project: game-factory
scope: "Visual art & 3D asset-creation pipeline (traditional, non-generative-AI). Generative AI asset creation is covered by a separate vector."
research_discipline:
  primary_tool: perplexity_research (deep mode, high reasoning_effort)
  cross_validation: tavily_search
  mcp_calls_total: 8
  training_data_reliance: low
sources:
  # Pipeline stages (concept -> retopo)
  - https://www.gamedeveloper.com/art/five-secrets-of-game-art-direction
  - https://amist.co/concept-art-philosophy-deliverables-at-gamelynx/
  - https://www.resolutiongames.com/blog/from-sketching-to-rendering-a-look-at-how-concept-artists-work-at-resolution-games
  - https://retrostylegames.com/blog/hard-surface-modeling-from-basics-to-pro/
  - https://thundercloud-studio.com/article/topology-for-low-poly-game-characters/
  - https://www.topogun.com
  - https://3d-ace.com/blog/polygon-count-in-3d-modeling-for-game-assets/
  - https://www.cgspectrum.com/career-pathways/technical-artist
  - https://polycount.com/discussion/229850/do-you-need-smoothing-groups-if-you-have-normal-map
  # Character / rigging / animation
  - https://dev.epicgames.com/documentation/unreal-engine/hair-rendering-and-simulation-in-unreal-engine
  - https://dev.epicgames.com/documentation/unreal-engine/state-machines-in-unreal-engine
  - https://dev.epicgames.com/documentation/unreal-engine/setting-up-level-of-detail-for-grooms-in-unreal-engine
  - https://actorcore.reallusion.com/auto-rig
  - https://move.ai/blog
  - https://www.rokoko.com/products/vision
  - https://mocaponline.com/blogs/mocap-news/animation-retargeting-guide
  - https://www.beyondextent.com/deep-dives/trimsheets
  - https://www.adobe.com/learn/substance-3d-designer/web/the-pbr-guide-part-2
  # Headless / CLI automation
  - https://docs.blender.org/api/current/bpy.ops.export_scene.html
  - https://docs.blender.org/api/current/bpy.ops.uv.html
  - https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html
  - https://www.sidefx.com/products/houdini-engine/
  - https://www.sidefx.com/docs/houdini/tops/schedulers.html
  - https://www.sidefx.com/docs/houdini/hom/commandline.html
  - https://helpx.adobe.com/substance-3d-sat.html
  - https://helpx.adobe.com/substance-3d-sat/pysbs-python-api.html
  - https://helpx.adobe.com/substance-3d-sat/command-line-tools/sbsbaker/sbsbaker-example-command-lines.html
  - https://instalod.com
  - https://docs.instalod.io/Products/InstaLOD_Studio/Workflows/Batch_Process_Using_InstaLOD_Pipeline
  - https://documentation.simplygon.com/SimplygonSDK_10.2.11500.0/ue5/concepts/lodrecipes.html
  - https://marmoset.co/posts/python-scripting-toolbag/
  - https://marmoset.co/python/reference.html
  # Interchange & optimization
  - https://www.khronos.org/gltf/
  - https://github.com/KhronosGroup/glTF/tree/main/extensions
  - https://github.com/djeedai/bevy_hanabi
  - https://threedium.io/3d-model/props-environments
  - https://www.beyondextent.com/deep-dives/deepdive-texeldensity
  - https://rebusfarm.net/blog/texel-density-basics-every-artist-should-know
  - https://polycount.com/discussion/237029/breakdown-of-the-aaa-pipeline-for-game-ready-realistic-hero-props
  # VFX / technical art
  - https://docs.unity3d.com/Packages/com.unity.shadergraph@latest/
  - https://realtimevfx.com/t/unity-vfx-graph-and-shuriken/15033
  - https://discussions.unity.com/t/vertex-animation-textures-an-elegant-solution-for-baked-simulations-and-advanced-deforming-animation-openvat/1680369
  - https://www.vfxapprentice.com/blog/what-are-flipbooks-in-games
  - https://en.wikipedia.org/wiki/Standard_Portable_Intermediate_Representation
  # Style / genre variation
  - https://www.juegostudio.com/blog/2d-vs-3d-game-development
  - https://polycount.com/discussion/198277/thoughts-on-hand-painted-vs-stylized-pbr
  - https://cglearn.eu/pub/advanced-computer-graphics/non-photorealistic-rendering
  - https://community.foundry.com/discuss/topic/109667/amazing-in-depth-cel-shading-technique-in-guilty-gear-xrd
  - https://www.gamedeveloper.com/art/voxelart-styles-in-video-games
  - https://community.aseprite.org/t/how-likely-is-it-to-get-specific-workflow-tools/11303
---

# AAA Visual Art & 3D Asset-Creation Pipeline — Research Report

> **Scope note.** This vector covers the *traditional, human-craft + procedural* art pipeline and which parts of it are scriptable/headless. Generative-AI asset synthesis (text-to-3D, diffusion texturing, neural retopo) is a **separate vector** and is deliberately excluded here except where it already sits inside a conventional tool (e.g., Substance smart-material assists).
>
> **Confidence flags.** Items marked **[FLAG]** are fast-moving or were inconclusive in public sources (most numeric budgets, validator thresholds, and per-engine VFX portability remain studio-proprietary). All version/capability claims are stamped *as of 2025-2026*.

---

## 1. Executive Summary

The modern AAA art pipeline is a deterministic-enough *assembly line* wrapped around a small number of irreducibly human-craft decision points. For a Dark Factory the strategic picture is:

1. **The pipeline decomposes into ~10 well-defined stages**, each producing a *named, inspectable artifact* (concept sheet → high-poly → low-poly → UVs → baked maps → texture set → rigged/skinned mesh → animation clips → LOD chain → engine-ready package). This stage/artifact structure is exactly the kind of contract spine vsdd-factory already orchestrates.

2. **A large fraction of the *mechanical* work is already headless/CLI-automatable today** — Blender `bpy --background`, Houdini `hython`/PDG/HDA, the Substance Automation Toolkit (`sbsbaker`/`sbscooker`/`sbsrender`/`pysbs`), and industrial mesh optimizers (Simplygon, InstaLOD) all run non-interactively over thousands of assets. Decimation, LOD generation, UV-unwrap (algorithmic), texture baking, map compression, format conversion, and validation are *batch operations*.

3. **The *creative* work resists full automation** — concept/art-direction, hero-asset sculpting, hand-painted texturing, UV-seam placement on hero assets, facial/anatomical topology, hair grooming, cloth styling, keyframe acting, and any IP-specific stylization remain human-craft (or human-directed). These are the human-in-loop nodes.

4. **For engine-agnostic delivery, the recommendation is clear: glTF 2.0 / GLB as the runtime delivery format, OpenUSD as the pipeline/scene-assembly backbone, FBX only as a legacy authoring bridge, Alembic for baked vertex caches.** glTF is the only open, Khronos-governed, natively-supported-everywhere runtime format (Bevy native, Godot native/recommended, Unity via UnityGLTF/glTFast). The factory should treat glTF/GLB as the canonical *contract* output and generate engine-specific projects from it.

5. **Shaders and real-time VFX are the LEAST portable layer** — there is *no* widely adopted engine-agnostic standard for materials, shader graphs, or particle graphs. SPIR-V/WGSL/Slang are *GPU-API* intermediates, not *material* intermediates. The factory must produce a **per-engine material/VFX adapter** rather than a single portable artifact, driving each engine's native node graph (Unreal Material Editor + Niagara, Unity Shader Graph + VFX Graph, Bevy WGSL + Hanabi) from a common semantic material description (PBR metal-rough + a constrained extension set).

6. **Style/genre is structural, not cosmetic.** Photoreal-PBR, stylized/hand-painted, pixel-art, low-poly, cel-shaded/anime, and voxel each change *which stages dominate, which tools are used, and how automatable the pipeline is.* Photoreal-PBR is the *most* automatable (procedural materials, baking, LOD); hand-painted/pixel/stylized are the *least* (bespoke mark-making, less proceduralism). The factory needs a **style-profile** that parameterizes the whole pipeline.

---

## 2. Pipeline Stage Breakdown (end-to-end)

Each stage lists: **deliverable artifact**, **standard tools**, **AAA acceptance signal**, and **automatability** (🟢 headless-automatable · 🟡 tool-assisted/human-directed · 🔴 human-craft).

### 2.1 Concept Art & Art Direction 🔴
- **Artifact:** art bible (visual language, palette, material callouts), mood boards, exploration sketches, turn-arounds, "in-game mock" composites, final asset sheets. A studied deliverable ladder: *brief → 5 rough explorations → continued explorations → in-game mock → front-pose line art → color comp → final asset sheet* (Gamelynx model).
- **Tools:** Photoshop, Miro (mood boards), Substance Designer (material studies), increasingly in-engine mocks.
- **Acceptance:** consistency with art bible; technical feasibility annotations (poly/texture/anim budgets baked in at concept stage); "reads in-game at gameplay camera & lighting."
- **Automatability:** Human-craft. The factory's role is to *enforce the deliverable schema* and capture budgets/constraints as machine-readable spec, not to generate the art (that's the gen-AI vector). Technical-artist involvement at concept stage is the canonical place where budgets become contracts. Source: gamedeveloper.com five-secrets, amist.co/Gamelynx, resolutiongames.com.

### 2.2 3D Modeling — Hard-Surface vs Organic 🟡
- **Artifact:** blockout → high-poly base → clean low-poly mesh (game-ready). Hard-surface = precise box/CAD-style, sharp edges, clean edge flow for UVs; organic = sculpt-first, edge loops following anatomy for deformation. Many assets are hybrid (armored character).
- **Tools:** Blender, Maya, 3ds Max (hard-surface); ZBrush (organic, **2026** version streamlines retopo); Substance 3D Modeler (voxel+poly hybrid).
- **Acceptance:** clean edge flow, correct silhouette, watertight where required, no non-manifold geometry, no n-gons in deforming areas, uniform scale.
- **Automatability:** Blockout & primitive ops scriptable; hero sculpting and edge-flow decisions human-craft. Decimation/remesh (Blender modifiers, ZRemesher) are batchable.

### 2.3 High-Poly Sculpting → Low-Poly 🟡
- **Artifact:** subdivided high-poly (detail source) + matched low-poly (bake target). Strategic detail placement so high-frequency detail bakes to normal maps cleanly; negative space for AO capture.
- **Tools:** ZBrush (industry standard), Blender sculpt, Mudbox.
- **Acceptance:** detail that survives normal-map baking; correct height/depth direction; sealed mesh.
- **Automatability:** sculpting = human; *deletion of subdiv levels, ZRemesher base, decimation* = scriptable.

### 2.4 Retopology 🟡
- **Artifact:** optimized quad/tri topology, polygon-budget-compliant, edge loops following form & deformation.
- **Tools:** ZBrush 2026 retopo tools, TopoGun, Maya Quad Draw, Blender (RetopoFlow). Auto-retopo (ZRemesher, InstaLOD, QuadRemesher) for non-hero or LOD use.
- **Acceptance:** clean deformation under extreme poses; loops at joints/face; budget compliance.
- **Automatability:** **Auto-retopo is reliable for props/environment & LODs (🟢)** but **hero characters/faces remain human-craft (🔴)** because deformation quality depends on intentional loop placement.

### 2.5 UV Unwrapping & Texel Density 🟡
- **Artifact:** UV layout(s), packed shells, target texel density (industry std ≈ **512 px/m** for next-gen background; **1024 px/m** for hero assets per Polycount/practitioner consensus — **[FLAG]** numbers are conventions not formal standards).
- **Tools:** Blender Smart UV Project / UVPackmaster, RizomUV, Maya, Headus UVLayout, TexTools (3ds Max).
- **Acceptance:** uniform texel density across the asset, minimal stretching, sensible seam hiding, efficient packing, correct overlap rules (intentional mirroring OK, accidental overlap rejected).
- **Automatability:** **Algorithmic unwrap (Smart UV Project, RizomUV auto) + packing is fully scriptable (🟢)** for tiling/trim/modular assets; **hero-asset seam placement is human-directed (🟡)**.

### 2.6 PBR Texturing & Materials 🟡
- **Artifact:** baked map set (normal, AO, curvature, position, thickness, color-ID) + authored PBR texture set (base color/albedo, metallic, roughness, normal, height, emissive) per material, exported per-engine preset.
- **Tools:** Substance 3D Painter (texturing), Substance 3D Designer (procedural/tiling materials & smart materials), Marmoset Toolbag (baking), Mari (film-grade), 3DCoat (hand-painted/stylized).
- **Acceptance:** physically plausible albedo/specular ranges, layered roughness, smart-mask-driven wear in plausible locations, consistency with material library.
- **Automatability:** **Baking + smart-material application + map export are headless via Substance Automation Toolkit (🟢)**; **hero/IP-specific hand-painting is human-craft (🔴)**. Photoreal benefits hugely from procedural materials; hand-painted does not.

### 2.7 Character Art — Skin / Hair / Cloth 🔴/🟡
- **Skin:** multi-map authoring (albedo, normal, roughness, AO, thickness/subsurface-color) feeding subsurface-scattering skin shaders + micro-normal/micro-roughness. Acceptance is de-facto (no single formal standard) — believable SSS + consistent specular.
- **Hair:** two paradigms — **hair cards** (textured planes, performant, default for gameplay) vs **strand-based grooms** (Unreal groom system; physically accurate but *"extremely expensive for real-time gameplay,"* must be LOD-controlled or reserved for cinematics). Hair-card creation = 2D concept → 3D strand volumes → bake to cards (normal/alpha/AO).
- **Cloth:** Marvelous Designer for garment authoring/sim; offline sim must be reduced/approximated to in-engine runtime cloth (Chaos Cloth etc.) + proxy meshes.
- **Automatability:** card-bake steps scriptable; grooming/cloth-styling human-craft.

### 2.8 Environment Art, Props & Modular Kits 🟡
- **Artifact:** modular kit pieces on a power-of-2 grid (64/128/256/512 units), trim sheets, tiling materials, hero props (10k–50k tris per Digital Foundry-cited convention — **[FLAG]**), set dressing.
- **Tools:** Blender/Maya/3ds Max + Houdini (procedural buildings/scatter), Substance for trims/tiles.
- **Acceptance:** grid-snapping, draw-call efficiency via shared atlases/trim sheets, batchable instances, consistent texel density.
- **Automatability:** **High — modular kit assembly, scatter, and trim-based texturing are Houdini-HDA/PDG-procedural (🟢).** This is the single most automatable *content-volume* stage.

### 2.9 Rigging & Skinning 🟡
- **Artifact:** skeleton, skin weights, blend shapes (facial), physics/cloth proxies, control rig.
- **Tools:** Maya (dominant in AAA), Blender Rigify; auto-rig: Maya HumanIK/Quick Rig, Reallusion **AccuRig** (free auto-rig), Mixamo, Rigify.
- **Acceptance:** clean deformation, no candy-wrap/collapse at joints, game-skeleton compliance, weight normalization.
- **Automatability:** **Auto-rigging of standard humanoid/biped is reliable (🟢)** (AccuRig/HumanIK/Mixamo); **hero facial rigs & bespoke creatures remain human-craft (🔴)**; weight-painting cleanup is human-directed (🟡).

### 2.10 Animation 🟡/🔴
- **Artifact:** animation clips, blend spaces, **animation state machines** (engine-side), IK setups, root-motion data.
- **Tools:** Maya, Blender; mocap: Vicon/Xsens (optical/inertial), markerless **Move.ai**, **Rokoko Vision**; **Cascadeur** (physics-assisted keyframe); retargeting in DCC + engine.
- **Acceptance:** believable weight/timing, clean retarget to game skeleton, responsive IK/root-motion in gameplay.
- **Automatability:** **Mocap capture + retarget + cleanup-pass is increasingly automatable (🟡)** (markerless capture has collapsed the cost); **hero/cinematic keyframe acting is human-craft (🔴)**. State machines are authored but their *structure* is automatable scaffolding.

### 2.11 VFX & Technical Art 🟡 (engine-specific)
- **Artifact:** particle systems, materials/shaders, vertex-animation-textures (VAT), flipbooks, baked Houdini sims.
- **Tools:** Unreal **Niagara** (GPU, data-channels, effect-type/quality multipliers, distance culling), Unity **VFX Graph** (GPU) vs legacy **Shuriken** (CPU), Godot 4 GPU particles (CPU frozen/compat-only), Bevy **Hanabi** (GPU, ECS). Houdini authors pyro/fluids → baked to engine. Shaders: Unreal Material Editor, Unity Shader Graph, Bevy WGSL.
- **Acceptance:** within GPU/perf budget, scales across quality tiers, distance-culled.
- **Automatability:** **Baked representations (VAT, flipbooks) are pipeline-automatable (🟢)**; **live shader/particle graphs are per-engine and the hardest to make portable (🔴)** — see §4.

### 2.12 LODs & Real-Time Optimization 🟢
- **Artifact:** LOD chain, compressed textures, atlases, draw-call-optimized batches.
- **Tools:** Simplygon (LOD "recipes"), InstaLOD (batch pipeline), Unreal auto-LOD, Blender decimate, gltfpack/meshopt.
- **Automatability:** **Fully headless/batch (🟢).** This is the most thoroughly industrialized stage.

---

## 3. DCC Toolchain — Headless / CLI Automatability per Tool

| Tool | Headless entrypoint | What automates well (🟢) | What still needs GUI/human (🔴/🟡) |
|---|---|---|---|
| **Blender** | `blender --background --python script.py` (`bpy`) | Import/export **glTF, FBX, USD**; decimate/voxel-remesh; **algorithmic UV unwrap** (Smart UV Project, `bpy.ops.uv.*`); **texture baking via Cycles** (Cycles runs headless; EEVEE viewport rendering does *not*); batch collection export; geometry-node parameter sweeps; modifier application. | Artistic seam placement on hero assets; sculpting; any operator needing viewport context. |
| **Houdini** | `hython`; **HDAs**; **PDG/TOPs** dependency graph + schedulers (local/farm) | Procedural modeling (buildings, scatter, modular kits), sims (pyro/fluids/RBD) → bake to mesh/texture/VAT; **farm-scale distributed processing**; Houdini Engine embeds HDAs in Unreal/Unity. SideFX Labs adds optimization HDAs. | Authoring the procedural network itself (one-time human/TA effort); art-directing the result. |
| **Substance Automation Toolkit (SAT)** | CLI: `sbsbaker`, `sbscooker`, `sbsrender`; **`pysbs`** Python API | **Mesh-map baking** (`sbsbaker`), cooking `.sbs`→`.sbsar`, **batch rendering whole texture sets** for large asset libraries headlessly, parameter-driven material variants. | Authoring the smart-material/`.sbs` graph (TA effort); hero hand-painting (Painter, more GUI-bound). |
| **Substance 3D Painter** | Python API (mostly bound to app instance) | Scripted export presets, batch export, project setup. | Interactive hand-painting; not a pure OS-level CLI. |
| **Simplygon** | SDK + **Batch utility**, **LOD recipes**, UE5 integration | **Mesh decimation, LOD-chain generation, material/atlas baking, remeshing/aggregation** — designed for batch. | Choosing reduction targets/thresholds (config, one-time). |
| **InstaLOD** | **InstaLOD Pipeline** (CLI/JSON), headless-Maya integration | Batch optimize/remesh/bake/LOD; pipeline JSON jobs. | Same — recipe authoring. |
| **Maya** | `maya -batch`, `mayapy`, MEL/Python | Scripted import/export, rigging ops, skinning, rendering; integrates with Simplygon/InstaLOD headlessly. | Hero rigging, animation acting, weight-paint finesse. |
| **Marmoset Toolbag** | Python API + community batch-bake scripts | Batch baking/rendering. | Automation bound to an active app instance, not pure CLI. |
| **ZBrush** | Limited scripting (ZScript); **GUI-bound** | ZRemesher/decimation within sessions. | Sculpting and retopo are interactive — **🔴 least automatable major tool**. |
| **Marvelous Designer** | Scripting limited | Some batch sim. | Garment design = human-craft. |
| **Aseprite** | **CLI** (`aseprite -b ...`) export/slice/scale | Batch sprite-sheet export, slicing, format conversion. | Pixel-art drawing = human-craft. |

**Key takeaway:** The factory should **wrap, not build** — Blender (`bpy`), Houdini (PDG/HDA), the Substance Automation Toolkit, and Simplygon/InstaLOD are *designed* as headless workers and form a ready-made automation substrate. The engineering effort is in **robust presets + procedural containers + orchestration** (predictable, repeatable, CI-driven runs), not in reinventing geometry/texture algorithms.

---

## 4. Engine-Agnostic Asset Interchange (glTF / USD / FBX / Alembic)

### Recommendation
| Layer | Recommended format | Rationale |
|---|---|---|
| **Runtime delivery (the factory's canonical output contract)** | **glTF 2.0 / GLB** | Only open, Khronos-governed, royalty-free format with *native* support across target engines. Bevy: native glTF loader. Godot: glTF is the *recommended* import format, native. Unity: via glTFast/UnityGLTF (not built-in but mature). PBR metal-rough is the spec core. Extensions cover advanced needs: `KHR_materials_clearcoat/sheen/transmission/volume/variants`, `KHR_texture_basisu` (KTX2 + Basis Universal supercompression, stays compressed in GPU memory), `KHR_draco_mesh_compression` (now GPU-accel decode in several engines). GLB packs JSON+binary+textures into one file. |
| **Pipeline / scene-assembly backbone** | **OpenUSD** | Pixar/AOUSD standard; backbone of NVIDIA Omniverse, Apple USDZ, increasingly Unreal/Unity *pipelines*. **Not yet a runtime delivery format** — use it for layered scene assembly, variants, and DCC interchange, then *flatten/convert to glTF for delivery*. Blender can act as a headless USD↔glTF conversion node. |
| **Legacy authoring bridge (animation/rigging)** | **FBX** | Still indispensable for skeletal animation/cinematic interchange, but: **proprietary (Autodesk), closed spec, SDK licensing friction, version-regression fragility, breaks on complex procedural deformation** (e.g., 3ds Max Path Deform keyframes lost on export). Use only where a tool emits nothing better; convert to glTF downstream. FBX→glTF converters with animation preservation are maturing. |
| **Baked vertex caches** | **Alembic** | Gold standard for point-cache/baked deforming geometry (cloth, complex sims) where skeletal animation can't represent it. **UE5 native import; Unity needs third-party plugins** (integration gap). Pixar Hydra is an emerging USD-native alternative but less mature. |

### Engine support matrix (as of 2025-2026)
| Format | Bevy | Unity | Godot 4 |
|---|---|---|---|
| glTF/GLB | **Native** (recommended) | glTFast/UnityGLTF (mature, not built-in) | **Native, recommended** |
| FBX | via conversion | **Native** (Autodesk SDK) | Import (converts to glTF-like) |
| USD | nascent | pipeline/plugin | nascent |
| Alembic | nascent | plugin | limited |

**Factory implication:** Emit **GLB as the canonical, engine-neutral asset contract** (geometry + PBR materials + skeletal animation + KTX2/Basis textures + Draco/meshopt). Keep an **optional USD layer** for scene assembly. Generate per-engine import projects/configs from the GLB contract. Treat FBX/Alembic as adapters at the edges.

---

## 5. Optimization & Budget Standards

- **Texel density:** practitioner consensus **512 px/m (5.12 px/cm) background props, 1024 px/m hero** for PS5/Xbox Series X/high-end PC. Uniformity across an asset matters *more* than the absolute number. **[FLAG] — convention, not a published formal standard; treat as configurable per project.**
- **Polygon budgets [FLAG — anecdotal, project-specific]:** main characters ~12k–15k+ tris; hero props 10k–50k tris; weapons 3k–6k tris. *No source publishes authoritative AAA budgets;* efficiency + silhouette preservation are the real criteria. The factory should make budgets **configurable spec inputs**, not hardcoded.
- **Texture compression:** **BC7** (desktop), **ASTC** (mobile/cross-platform, tunable block sizes 4×4→...), **Basis Universal / KTX2** (`KHR_texture_basisu`) for transcode-to-any-GPU + GPU-resident compression. ASTC often beats BC7 at equal ratio on normal maps/noisy content.
- **Mesh compression:** Draco (`KHR_draco_mesh_compression`), meshopt/gltfpack.
- **Draw calls / batching:** modular assets sharing atlases/trim sheets batch onto fewer draw calls; instancing for scatter. The dominant lever for environment-scale performance.
- **LODs:** hierarchical LOD chains, auto-generated (Simplygon recipes / InstaLOD / engine auto-LOD); per-platform distance thresholds are **[FLAG] proprietary**.

---

## 6. Art-Style / Genre Variation

Style is **structural** — it re-weights stages, swaps tools, and changes automatability.

| Style | Pipeline shift | Key tools | Automatability |
|---|---|---|---|
| **Photoreal PBR** (shooters, open-world) | Full high→low→bake→PBR; heavy proceduralism; ray tracing. | ZBrush, Substance, Houdini | **Highest** — procedural tiling materials, baking, auto-LOD all apply. |
| **Stylized / hand-painted** (MOBA, fantasy) | May *bypass* normal/specular; paint albedo with baked-in lighting; value/shape-driven. | Substance + **3DCoat**, hand-paint | **Low** — bespoke mark-making; *more* artist judgment per asset; procedural noise less useful. **Not cheaper than realism at AAA quality.** |
| **Cel-shaded / anime / NPR** (Genshin, Guilty Gear Xrd) | Conventional 3D meshes/UVs **+ custom NPR shaders**: ramp/band shading, tuned specular, outline (inverted-hull / screen-space edge). PBR data may feed cel ramps. | Maya/Blender + engine NPR shaders | **Medium** — meshing is normal; *shader stylization is automatable scaffolding*, ramp tuning is art-directed. |
| **Low-poly / flat-shaded** | Minimal/no bake; flat colors, often vertex-color or tiny atlas. | Blender | **High** — geometry-light, atlas-simple, very scriptable. |
| **Pixel art / 2D** | Sprite sheets, tilemaps, resolution planning; no 3D mesh pipeline. | **Aseprite** (CLI-scriptable export/slice) | Mixed — **export/slicing automatable**, drawing human-craft. |
| **Voxel** | Voxel modeling, often auto-meshed. | MagicaVoxel | **High** — algorithmic meshing/export. |
| **2.5D** | 2D assets in 3D space or vice versa; hybrid. | mixed | Mixed. |

**Factory implication:** a **`style-profile` parameter** must drive: which stages run, which tools/presets are invoked, budget ranges, shader template, and *how much can be automated vs flagged for human craft.* Photoreal and low-poly/voxel are the high-automation profiles; hand-painted/pixel/heavily-stylized are human-craft-heavy.

---

## 7. Factory Artifacts / Contracts This Discipline Implies

The art discipline maps cleanly onto a vsdd-style spec/contract spine. Proposed artifacts:

1. **`art-bible.spec`** — machine-readable art direction: style-profile, palette, material standards, texel-density targets, poly budgets per asset class, naming conventions, folder structure. *Source of truth for all downstream gates.*
2. **`asset-request.contract`** — per-asset spec: class (character/prop/env/VFX), budgets, target style-profile, required maps, LOD count, target engines, watertight/deforming flag.
3. **`concept.deliverable`** — concept sheet + turn-around + in-game mock + annotations (schema-validated against the deliverable ladder). *Human-produced, factory-validated.*
4. **Stage intermediate artifacts** (each inspectable/gateable): `highpoly.mesh`, `lowpoly.mesh`, `uv.layout`, `bake.maps` (normal/AO/curvature/ID/position/thickness), `texture.set` (PBR maps per engine preset), `rig.skeleton` + `skin.weights`, `anim.clips` + `state-machine.spec`, `lod.chain`.
5. **`material.semantic`** — engine-neutral PBR material description (metal-rough + constrained KHR extension set) → compiled to per-engine adapters (Unreal Material, Unity Shader Graph, Bevy WGSL). *Required because shaders aren't portable.*
6. **`vfx.spec`** — semantic VFX description → per-engine adapter (Niagara / VFX Graph / Hanabi) + baked fallback (VAT/flipbook) where portability matters.
7. **`asset.package` (GLB)** — the canonical engine-neutral delivery contract: geometry + materials + skeletal anim + KTX2/Basis textures + Draco/meshopt + LODs, plus optional USD scene layer.
8. **`validation.report`** — automated QA gate results (see §8).
9. **Per-engine project adapters** — generate Bevy/Unity/Godot import configs from the GLB contract.

**Wrap vs build:** *Wrap* Blender(`bpy`), Houdini(PDG/HDA), Substance(SAT), Simplygon/InstaLOD, Aseprite-CLI as headless stage-runners. *Build* the **orchestration, contract schemas, style-profile system, semantic material/VFX adapters, and the validation gate**. Do **not** build geometry/texture algorithms.

---

## 8. AAA Acceptance Bar (Quality Gates)

Public sources confirm AAA studios use **automated validation extensively** (Unreal has built-in validation frameworks triggered in-pipeline; Unity uses `AssetPostprocessor` scripts; tools like Game Asset Optimizer check polycounts/UVs/materials against engine constraints) **but keep specific thresholds proprietary [FLAG].** A defensible factory gate, assembled from documented criteria:

**Automatable technical gates (🟢 — the factory can enforce these):**
- Polygon/triangle count within budget (per asset class & LOD).
- No non-manifold geometry; watertight where required (rigged meshes need clean topology; static props *may* use floating geometry — gate must be class-aware).
- UV: no accidental overlap (intentional mirroring allowed), uniform texel density within tolerance, packing efficiency, correct UV set count.
- Texture: power-of-2 dimensions, correct compression format per platform, correct color space (sRGB vs linear), mipmaps present/disabled per type.
- Naming-convention & folder-structure compliance.
- Valid LOD chain present; LODs reduce monotonically.
- Material count / draw-call budget; atlas usage.
- Format validity (GLB parses, extensions resolve).
- Scale/transform correctness (uniform scale, applied transforms, origin).

**Human-review gates (🔴 — flagged for art lead):**
- Silhouette reads at gameplay distance & in-engine lighting.
- Deformation quality under extreme poses (joints/face).
- Stylistic consistency with art bible / IP.
- Hair/cloth believability; SSS/skin plausibility.
- "Looks right in-game" — the canonical *game art looks different in the build* check.

**Recommended gate design:** two-tier — a **green-light automated validator** (hard pass/fail on technical criteria) followed by a **human art-QA sign-off** on craft criteria. The automated tier is fully buildable today from `bpy`/engine-SDK introspection; the craft tier stays human-in-loop.

---

## 9. Open Questions & Risks

1. **[FLAG] Numeric budgets are proprietary.** No public source gives authoritative per-class poly/texel/LOD-distance numbers. *Risk:* the factory's defaults will be anecdotal. *Mitigation:* make all budgets configurable spec inputs; seed with published conventions; let studios calibrate.
2. **Shader & VFX non-portability is the hardest problem.** No engine-agnostic material/particle standard exists; SPIR-V/WGSL/Slang are GPU-API, not material, intermediates. *Risk:* a "single portable shader" is not achievable. *Mitigation:* semantic material/VFX description → per-engine adapter + baked fallbacks (VAT/flipbook). This is real engineering, not a wrap.
3. **Hero-craft stages resist automation.** Concept, hero sculpt, hand-paint, facial rig, grooming, cloth styling, keyframe acting. *Risk:* over-promising "generates everything." *Mitigation:* explicit human-in-loop nodes; the gen-AI vector may shift some boundaries but craft QA stays human.
4. **Strand hair & high-fidelity cloth are runtime-expensive.** Unreal grooms are "extremely expensive for real-time gameplay." *Risk:* AAA fidelity vs performance budget conflict. *Mitigation:* hair-card / proxy defaults, groom only for cinematics with aggressive LOD.
5. **FBX fragility & Unity Alembic gap.** Version regressions, lost procedural deformation, Unity's third-party Alembic dependency. *Mitigation:* glTF-canonical, FBX only as edge adapter.
6. **USD-as-delivery is not ready.** USD is a pipeline backbone, not a runtime format for games yet. *Don't* deliver USD to engines; convert to glTF.
7. **Style-profile combinatorics.** Each style changes the whole pipeline; building/validating all profiles is large scope. *Mitigation:* ship photoreal-PBR + low-poly first (highest automation), add stylized/pixel/NPR later.
8. **ZBrush/Marvelous are GUI-bound.** The two least-scriptable major tools sit on the hero-craft path. *Risk:* automation can't reach them. *Mitigation:* route hero sculpt/garment work to human-in-loop; use auto-retopo/auto-rig for the rest.

---

## 10. Sources

See YAML `sources` frontmatter for the consolidated list. Primary-source anchors by topic:
- **Interchange:** Khronos glTF spec & extensions registry; engine docs (Bevy `bevy_hanabi`, Godot glTF docs, Unity glTFast).
- **Headless automation:** Blender Python API docs (`bpy.ops.export_scene`, `bpy.ops.uv`, scene_gltf2 manual); SideFX Houdini Engine / TOPs schedulers / HOM commandline; Adobe Substance Automation Toolkit (`sbsbaker`/`pysbs`) help pages; Simplygon LOD-recipe docs; InstaLOD pipeline docs; Marmoset Python reference.
- **Budgets/texel density:** Polycount AAA hero-prop breakdown; Beyond Extent & RebusFarm texel-density guides; threedium.io environment standards (512 px/m).
- **Character/rig/anim:** Epic hair-rendering/groom-LOD/state-machine docs; Reallusion AccuRig; Move.ai; Rokoko Vision; mocap retargeting guide; Beyond Extent trim sheets; Adobe PBR Guide Pt.2.
- **VFX/tech-art:** Unity Shader Graph & VFX-Graph-vs-Shuriken; OpenVAT discussion; vfxapprentice flipbooks; SPIR-V (Wikipedia) — cited specifically to establish that GPU-API intermediates are *not* material intermediates.
- **Style/genre:** Juego 2D-vs-3D; Polycount hand-painted-vs-stylized-PBR; cglearn NPR; Foundry Guilty Gear Xrd cel-shading; gamedeveloper voxel-art; Aseprite workflow.

> **Tool/version caveat:** ZBrush 2026, Substance 3D Painter 12.0 (Mar 2026), and engine versions are stated as reported by 2025-2026 sources; verify exact build numbers against vendor release notes before pinning in pipeline configs.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 6 | Deep multi-source synthesis on: (1) concept→retopo stages, (2) character/rig/anim, (3) headless/CLI automatability per DCC tool, (4) glTF/USD/FBX interchange + optimization budgets, (5) VFX/technical-art + shader portability, (6) art-style/genre variation + acceptance bar. All `reasoning_effort=high`, `strip_thinking=true`. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — |
| Tavily tavily_search | 2 | Cross-validate (a) Blender bpy headless glTF/decimate/bake automation, (b) AAA poly-budget & texel-density (512/1024 px/m) standards. Confirmed Perplexity findings against Blender API docs, Polycount, Beyond Extent, threedium. |
| Tavily tavily_research | 0 | — |
| Tavily tavily_extract | 0 | — |
| WebFetch | 0 | — |
| WebSearch | 0 | — |
| Training data | ~2 areas | Organizing framework (pipeline stage taxonomy) and vsdd-factory contract framing — flagged as synthesis, all factual claims sourced. |

**Total MCP tool calls:** 8 (6 perplexity_research + 2 tavily_search)
**Training data reliance:** low — every capability/format/tool claim is web-sourced and citation-anchored; numeric budgets explicitly **[FLAG]**ged as anecdotal/proprietary; framework/taxonomy is the only training-data contribution.
