---
document_type: research
vector: asset-tooling-catalog
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
title: "Asset Tooling Integration Catalog — What the Factory Wraps (Verified)"
project: game-factory
scope: >
  Engine-agnostic (Bevy/Unity/Godot primary; Unreal deferred) multi-agent Dark Factory.
  Concrete "what we wrap" layer under generative-asset-ai.md (SOTA model survey) and
  AAA-RECONCILIATION.md (asset lane + provenance sidecar). Catalogs external tools/services
  the asset-generation-orchestrator can call HEADLESSLY, with primary-source-verified
  programmatic access, output formats, engine targets, license/IP terms, pricing, maturity,
  and the factory integration path per tool.
ties_to:
  - docs/research/aaa/generative-asset-ai.md
  - docs/research/aaa/AAA-RECONCILIATION.md
provenance_note: >
  PRIMARY-SOURCE DISCIPLINE. Prior research (generative-asset-ai.md §8) documented that the
  deep-research model FABRICATES specific tool/pricing/version/legal claims. During THIS pass,
  the perplexity_research deep-research call EXPLICITLY SELF-REPORTED it could not reach primary
  sources and was relying on 2024 training data — so its tool-specific assertions were DISCARDED.
  Every [VERIFIED] row below was confirmed by extracting the vendor's OWN site/docs/pricing page
  via Tavily extract or WebFetch (URLs in `sources`). Claims that could not be primary-sourced
  are marked [UNVERIFIED]. License/pricing terms are fast-moving — RE-VERIFY at integration time.
sources:
  # Primary vendor pages extracted/fetched this pass (VERIFIED)
  - https://autosprite.io
  - https://www.autosprite.io/pricing
  - https://www.autosprite.io/docs/api-characters
  - https://www.autosprite.io/sprite-sheet-generator
  - https://www.autosprite.io/docs/integration-unity-extension
  - https://www.meshy.ai/api
  - https://www.meshy.ai/pricing
  - https://docs.meshy.ai/en/api/introduction
  - https://docs.meshy.ai/en/api/ai
  - https://github.com/meshy-dev/meshy-mcp-server
  - https://www.tripo3d.ai/
  - https://www.tripo3d.ai/pricing
  - https://platform.tripo3d.ai/docs/introduction
  - https://conare.ai/marketplace/mcp/tripo-ai
  - https://www.sloyd.ai/
  - https://www.sloyd.ai/pricing
  - https://www.sloyd.ai/blog/api-integration-for-3d-models-across-platforms
  - https://hyper3d.ai/
  - https://www.scenario.com/
  - https://www.scenario.com/pricing
  - https://help.scenario.com/
  - https://sprite-ai.art/
  - https://leonardo.ai/api/
  - https://www.recraft.ai/
  - https://www.layer.ai/
  - https://elevenlabs.io/sound-effects
  - https://elevenlabs.io/pricing
  - https://suno.com/
  - https://aiva.ai/
  - https://lumalabs.ai/dream-machine/api
  - https://www.move.ai/
  - https://cascadeur.com/
  - https://www.convai.com/
  - https://inworld.ai/
  - https://www.rosebud.ai/
  - https://www.prometheanai.com/
  - https://www.worldlabs.ai/
  - https://stability.ai/license
  # Companion / upstream docs
  - docs/research/aaa/generative-asset-ai.md
  - docs/research/aaa/AAA-RECONCILIATION.md
---

# Asset Tooling Integration Catalog — What the Factory Wraps (Verified)

> This is the concrete **"what we wrap"** layer beneath `generative-asset-ai.md` (the SOTA
> *model* survey) and `AAA-RECONCILIATION.md` (the *asset lane + provenance sidecar* design).
> Where the model survey answered "can AI generate AAA assets?", this catalog answers the
> orchestration question: **exactly which tools can the `asset-generation-orchestrator` call,
> by what programmatic mechanism, with what license to ship the output?**

---

## 1. Executive Summary

**The factory can be built today as a wrap-only orchestrator for most modalities** — the
mature generative-asset vendors now ship **REST APIs and even official MCP servers**, and most
offer **engine-neutral exports** (GLB/FBX/OBJ/USDZ for 3D; PNG+atlas/JSON for 2D sprites;
WAV/MP3 for audio). Six load-bearing facts, all primary-source-verified this pass:

1. **3D is the most API-ready and most engine-agnostic modality.** Meshy and Tripo both expose
   full REST APIs **and official/community MCP servers**, export to FBX/OBJ/GLB/USDZ/STL/BLEND,
   and (on paid tiers) grant **full ownership** of generated models. Meshy's API even has
   dedicated `rigging` and `animation` endpoints. **This is the cleanest wrap in the catalog.**
2. **The user-named 2D sprite tool AutoSprite is a real, wrappable API** — it exposes a
   **REST API _and_ an MCP server on the Pro tier ($29/mo)**, outputs **PNG spritesheet + atlas
   (JSON) metadata**, ships a **Unity Extension**, and explicitly grants **commercial shipping
   rights** ("the spritesheets you generate are yours to ship… full releases"). It is the
   wrap-first pick for the narrow "single sprite → animated spritesheet" job. [VERIFIED]
3. **Several big-name tools are GUI/plugin-only or desktop-only = headless BLOCKERS.** Notably
   **Promethean AI** (desktop app + DCC/UE plugins; "primary integration is Unreal"; no clean
   headless REST API found — Unreal-adapter, deferred) and **Cascadeur** (desktop animation app;
   no public headless/CLI API found). These cannot be driven lights-out without UI automation.
4. **Licensing is the single biggest gotcha, on two specific axes the provenance sidecar must
   capture:** (a) **free tiers frequently strip commercial rights or downgrade to CC BY** — e.g.
   **Meshy free tier = CC BY 4.0** (attribution required) vs paid = full ownership; **Sloyd**
   gates **redistribution/reselling** behind the Pro tier; (b) **resale of the raw model file**
   is often restricted even when *use-in-game* is allowed. **The factory must store the exact
   tier-at-generation, not just the tool name.**
5. **MCP servers already exist for the 3D and 2D-sprite wrap targets** — official Meshy MCP
   (`@meshy-ai/meshy-mcp-server`), AutoSprite MCP (Pro tier), and community Tripo MCP
   (`tripo-ai-mcp-server`). MCP-architecture depth is handed to the companion
   `mcp-automation` research doc; this catalog only enumerates which exist (§7).
6. **Audio/voice remains the legal-hazard lane** (consistent with `generative-asset-ai.md` §5.4
   and `AAA-RECONCILIATION.md` R-003/R-004). ElevenLabs SFX/music is commercially licensed on
   paid tiers and has an API, but raw AI **music** (Suno) and **voice cloning** stay
   litigation/consent-gated; the factory defaults to licensed/royalty-free providers (AIVA Pro
   grants full copyright; Stable Audio under Stability's license) and treats Suno as non-ship.

**Bottom line:** a wrap-only asset factory is viable now for **3D props/characters, 2D sprites,
2D concept/texture, and SFX**, with clean engine-neutral exports. The wrappable spine is
Meshy/Tripo (3D) + AutoSprite/Scenario (2D) + ElevenLabs (SFX) + licensed-music providers,
all fronted by a provenance/license sidecar that records the **exact paid tier** used.

---

## 2. Verified Capability / Integration Matrix

Legend — **Access:** `REST` (HTTP API) · `SDK` (official lib) · `MCP` (Model Context Protocol
server) · `Plugin` (engine/DCC plugin) · `Desktop` (GUI app, no headless API found) ·
`SelfHost` (open weights). **Maturity:** A = production-API-ready · B = usable, caveats ·
C = not wrappable headlessly today. **VS** = verification status. All license/pricing
**RE-VERIFY at integration time** (fast-moving).

### 2.1 — 2D Sprites / Sheets

| Tool | Access | Output formats | Engine targets | Commercial / IP / ownership | Pricing (API/MCP tier) | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|---|
| **AutoSprite** (autosprite.io) | **REST + MCP** + Unity Extension | **PNG spritesheet + atlas (JSON)**; individual frames in ZIP | Unity, Godot, GameMaker, Phaser, Astrocade, RPG Maker ("virtually any engine") | "Spritesheets you generate are **yours to ship**… prototypes, early access, **full releases**." Character consistency preserved across frames. Ownership not contradicted on site. | Free (daily credits, PNG+atlas); Starter $12/mo; **Pro $29/mo = API + MCP**; Enterprise custom | **A** | Pro-tier API: create character (base image) → request moveset/animations → poll → download PNG sheet + atlas. MCP server available for agent tool-calling. Map atlas → engine importer (Unity Extension auto-slices; Godot SpriteFrames; generic PNG+JSON). | **VERIFIED** |
| **Scenario** (scenario.com) | **REST API** (12 KB-articles) + SDKs + webhooks + Unity plugin | 2D: PNG/JPEG/WebP/**SVG**; video MP4/MOV/WebM/GIF; audio WAV/MP3; 3D GLB/OBJ/FBX/STL/VOX w/ PBR | Unity, Unreal, "any standard pipeline" | **Paid = full commercial license + you own output** (use/modify/ship/sell/royalty-free). Free = personal/eval only. SOC2 Type II; "your IP stays yours", not used to train, no cross-customer sharing. Custom-trained per-IP models (LoRA), 8-direction spritesheet app. | Free 50 credits; paid tiers (annual −33%); API on paid | **A** | Train per-IP style/character model (10–30 imgs) → API generate with style lock → 8-direction sprite app for character sheets → PNG/SVG + (optional) 3D GLB. Strong IP-governance story for Tier-2 assets. | **VERIFIED** |
| **Sprite-AI** (sprite-ai.art) | Web app; **"API docs" link present** (endpoints unverified) | Pixel-art sprites (formats unverified; likely PNG); export Q in FAQ | Godot referenced; engine list unverified | **Paid (Creator $8/mo) = "Full commercial license"**, sprites stay private. Free tier (15 gens). | Creator $8/mo; Studio $24–39/mo; Production tier | **B** | If REST API confirmed: text→pixel-sprite + animation. Low-res pixel niche. **API surface not yet primary-verified** — confirm at integration. | **PARTIAL** (commercial license + API-docs link verified; endpoint shape [UNVERIFIED]) |
| **Leonardo.ai** | **REST API** ($5 free credit; PAYG + custom) | Image, image-to-image, **image-to-video**; exportable production code | Engine-neutral (raster) | Commercial use on paid (indemnification not asserted on API page). Fine-tune + 3D-texture-from-OBJ (per seed; texture-pipeline [UNVERIFIED] this pass). | API: $5 free credit, pay-as-you-go, custom plans | **A** (2D) | Wrap PAYG image API for concept/texture/UI ideation. Usage metering built in. Treat as concept/draft (Tier-1/internal) — IP-indemnity not claimed. | **VERIFIED** (API + pricing); texture-from-OBJ [UNVERIFIED] |
| **OpenArt Sprite Generator** | Web app (GUI) | Sprite images (formats [UNVERIFIED]) | — | [UNVERIFIED] | — | **C** (no API confirmed) | No headless API surfaced. **BLOCKER** unless API found. | [UNVERIFIED] |
| **Layer.ai** ("AI OS for creative teams") | Enterprise platform; "direct engine sync"; model-agnostic (149+ models per seed) | Images/variants; engine sync (formats [UNVERIFIED]) | "Direct engine sync" (Unity partnership per seed) | Enterprise; brand-compliance focus. **No public self-serve API confirmed** — sales-led. | Enterprise (contact) | **B** | Enterprise integration, not a self-serve API. Possible Tier-2 brand-consistency lane via partnership; not lights-out without an exposed API. | **PARTIAL** (platform verified; public API [UNVERIFIED]) |

### 2.2 — 3D Models / Props / Characters

| Tool | Access | Output formats | Engine targets | Commercial / IP / ownership | Pricing (API tier) | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|---|
| **Meshy** | **REST API + official MCP** (`@meshy-ai/meshy-mcp-server`, npm/github.com/meshy-dev) + Blender/Unity/Godot/Unreal/Roblox/Omniverse/Maya/3dsMax plugins | Download: **FBX, OBJ, USDZ, GLB, STL, BLEND**; texturing accepts FBX/OBJ/STL/GLTF/GLB | Unity, Godot, **Unreal**, Omniverse, Roblox, Maya/Blender/3dsMax | **Premium = you own all assets, full rights to distribute and sell.** Free = **CC BY 4.0 (attribution)**. Ownership conditioned on not infringing input copyrights. | API requires **Pro tier+**; credits: 5/untextured mesh, 10/texture; Studio/Enterprise for volume | **A** | Best wrap. Endpoints: Text-to-3D v2, Image-to-3D, Multi-Image-to-3D, **Remesh** (topology/polycount), **Rigging** (humanoid skeleton), **Animation**, **Retexture**, **Convert**, **Resize**, Balance. MCP for agent tool-calling; webhooks for async. → GLB canonical → engine adapter. | **VERIFIED** |
| **Tripo (Tripo3D)** | **REST API** + **community MCP** (`tripo-ai-mcp-server`) + Blender/Unity/Unreal/ComfyUI/Cocos/Godot plugins | GLB/FBX/USDZ (Convert endpoint: USDZ/FBX w/ params); stylization (lego/voxel) | Unity, **Unreal**, Godot, Cocos, Blender, ComfyUI | Paid (Pro $11.94/mo … Max $44.90 … Team $54.93/seat) = **"Private models & commercial use"**. Free = **Public models, CC BY 4.0**, limited downloads. Resale-of-raw [verify ToS]. | Pro $11.94/mo (3000 cr ≈120 models); API via platform.tripo3d.ai (credits) | **A** | Endpoints: Task, Generation, **Texture**, **Mesh Editing**, **Animation**, **Post Process**, Convert, Import Model. Batch NPC variants (Team: batch ≤30, bulk export). MCP for agent flow. → GLB/FBX → adapter. | **VERIFIED** |
| **Sloyd.ai** | **REST API** (Bearer auth; template+parameters+format JSON body) + **SDK for runtime generation** (custom plans) + Unity/Unreal/Blender plugins | **.obj, .glb, .stl** (FBX per docs/blog); auto **UV + LOD**; manifold | Unity, Unreal, Blender | **Plus $15/mo = commercial license** (games/art/web/app/video). **Redistribution + reselling = Pro $50/mo only.** Free/guest = limited, no redistribution. Parametric+AI → clean predictable topology. | Plus $15/mo (commercial, unlimited exports); Pro $50/mo (redistribution); SDK on custom | **A** | Parametric REST: `template: 'furniture/chair'`, params (style/material/dims), `format: glb`, `optimization: {lod, textureResolution}`. **Runtime SDK** = in-game generation. Best for clean-topology props/variations. → GLB → adapter. | **VERIFIED** |
| **Hyper3D Rodin (Deemos)** | **REST API (Business plan only)** | **.obj, .fbx, .glb** (3D editing: parts/refine/modify) | Engine-neutral (3D) | Commercial on paid (resale terms [verify]). Gen-2.5 quad/topology presets (per `generative-asset-ai.md`). | Creator $24/mo (no API); **Business $120/mo = API access** | **A** (Business) | API on Business tier only. High-control quad topology for props/hero-draft. → GLB/FBX → adapter. Re-verify API endpoint shape at integration. | **VERIFIED** (API gated to Business; OBJ/FBX/GLB) |
| **Stability — Stable Fast 3D / SPAR3D / TRELLIS-class** | **SelfHost** (open weights, HF) + Stability API | GLB/textured mesh (UV-unwrapped) | Engine-neutral | **Stability Community License = FREE for orgs <$1M annual revenue** (commercial use allowed); ≥$1M = Enterprise. **No indemnification.** | Free <$1M rev; Enterprise custom | **B** | Self-host SF3D for fast img→3D (Tier-1 bulk/draft). No vendor indemnity → keep to low-IP-risk classes. Microsoft **TRELLIS** = self-host research license [verify exact terms]. | **VERIFIED** (Community License <$1M); TRELLIS exact license [UNVERIFIED] |
| **Tencent Hunyuan3D** | **SelfHost** + API | mesh + 4K PBR | Engine-neutral | Open weights — **Tencent license has non-commercial/regional clauses [verify]**. | Self-host / API | **B** | Self-host for props; **license clauses must be legal-reviewed** before ship. | **PARTIAL** (per prior research; exact license [UNVERIFIED]) |
| **Kaedim** | Web app, **human-in-the-loop** pipeline (image→3D w/ human cleanup) | Game-ready mesh (formats [UNVERIFIED]) | Unity/Unreal targeted (per market) | [UNVERIFIED]; human-in-loop = **not lights-out by design** | [UNVERIFIED] | **C** (for lights-out) | Human-in-loop contradicts lights-out; API existence [UNVERIFIED]. Not a v1 wrap target. | [UNVERIFIED] |
| **Luma AI (Dream Machine)** | **REST API** (lumalabs.ai/dream-machine/api) | Image/**video** (3D capture separate); third-party models routed | Engine-neutral (media) | Commercial use on paid plans (Plus $30/mo+). Indemnity not asserted. | Plus $30 / Pro $90 / Ultra $300; API | **A** (media) | Wrap for video/cinematic + image; NeRF/Gaussian-splat capture is a separate product line [verify export]. Concept/marketing lane. | **VERIFIED** (API + pricing + commercial-on-paid) |

### 2.3 — Environments / Worlds

| Tool | Access | Output formats | Engine targets | Commercial / IP | Pricing | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|---|
| **Promethean AI** | **Desktop app + open-source plugins** (Unreal/Unity/3dsMax/Maya/Blender); Python-customizable enterprise | Operates *on* your existing assets (set-dressing/placement); no headless export API found | **"Primary integration is Unreal"**; Unity + DCC plugins | Subscription; "never exposed to your asset files" (privacy-first); operates on user-owned assets | Subscription (enterprise custom) | **C** (lights-out) | **Unreal-adapter (DEFERRED).** Desktop/DCC-bound; no clean headless REST API → cannot drive lights-out without UI automation or Python-in-editor. Catalog as deferred. | **VERIFIED** (desktop/plugin-only; UE-primary) |
| **World Labs (Marble)** | **API** (listed) + Spark | "Various 2D and 3D formats" export (specific list [UNVERIFIED]) | "Seamless integration into workflows/pipelines" | [UNVERIFIED — confirm commercial terms] | [UNVERIFIED] | **B** | Text/image/video/360→explorable 3D world. API exists; **export-format list + license must be primary-verified** before wrap. Promising for greybox/blockout environments. | **PARTIAL** (API + multi-format export claimed; specifics [UNVERIFIED]) |

### 2.4 — Animation / Rigging / Mocap

| Tool | Access | Output formats | Engine targets | Commercial / IP | Pricing | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|---|
| **Meshy / Tripo / Sloyd auto-rig + animation** | **REST** (see §2.2) | Rigged GLB/FBX + anim | Unity/Godot/Unreal | Per §2.2 (paid = owned) | Per §2.2 | **A** (humanoid base) | **Already wrapped via 3D endpoints** — Meshy `rigging`+`animation`, Tripo `Animation`, Sloyd AI rigging/animation/text-to-motion. Use these for base-humanoid auto-rig in the same call chain. | **VERIFIED** |
| **Move.ai** | "Developers" section present; primary path = phone/video upload → mocap; **public REST API surface [UNVERIFIED]** | FBX/USD (per prior research; site confirms 3D motion data) | Engine-neutral mocap | Commercial per plan [verify] | Per plan [verify] | **B** | Markerless video→mocap for locomotion/crowd. **Confirm whether headless API exists vs upload-portal** before wrapping. | **PARTIAL** (product verified; headless API [UNVERIFIED]) |
| **Cascadeur (Nekki)** | **Desktop app** (Unreal/Unity/Maya/Blender/3dsMax/Mixamo/Houdini interop); no public headless/CLI API found | FBX | Engine-neutral via FBX | Indie ~$99/yr (per prior research) | Desktop license | **C** (lights-out) | **BLOCKER for lights-out** — GUI-first; AI-assisted keyframe/inbetween is interactive. Human-assist tool, not headless. Could be human-finishing-stage only. | **VERIFIED** (desktop-only; no API found) |
| **Reallusion AccuRig / ActorCore** | Desktop (AccuRig free auto-rig); ActorCore library; **API [UNVERIFIED]** | FBX/USD | Engine-neutral | AccuRig free; ActorCore paid library [verify ship terms] | Free (AccuRig) | **B** | Auto-rig humanoid base; **likely desktop, not headless** — confirm. Prefer Meshy/Tripo in-API rigging for lights-out. | **PARTIAL** |
| **Ready Player Me** | **Avatar REST API + SDKs** (web/Unity/Unreal/web; per seed & market) | **GLB** avatars | Unity, Unreal, web, many | Developer-platform; commercial use under RPM terms [verify ToS specifics] | Free dev tier + usage [verify] | **B** | Programmatic avatar GLB generation — strong for NPC/player avatars. **Re-verify current API + license** (site fetch failed this pass). | **PARTIAL** (API/SDK + GLB known; current terms [UNVERIFIED] this pass) |

### 2.5 — Audio (SFX / Music / Voice)

| Tool | Access | Output formats | Commercial / IP | Pricing (API tier) | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|
| **ElevenLabs (SFX + Voice + Music)** | **REST API** (Text-to-SFX API, TTS, Music) | WAV/PCM 44.1kHz (Pro), MP3 192kbps | **Commercial License on Starter ($6/mo)+; "Music commercial use" on Starter+.** Voice cloning = consent-gated (SAG-AFTRA risk). | Free 10k cr; Starter $6 (commercial); Creator $11; **Pro $99 = 44.1kHz PCM via API** | **A** (SFX) | Wrap Text-to-SFX API for the SFX lane (Tier-1). 44.1kHz PCM API on Pro. **SFX = safe wrap; voice = consent gate** (sidecar `likeness_consent_ref`). | **VERIFIED** |
| **Suno** | API (per market); Studio DAW | Audio + stems (Pro) | **Paid (Pro) = full commercial rights, royalty-free, you own output.** BUT litigation-exposed (Warner settled; Sony litigating). | Free 10/day; Pro 500 songs/mo commercial; Premier 2000 | **B legally** | **NON-SHIP per `AAA-RECONCILIATION.md` R-003** despite vendor granting rights — training-data litigation unresolved. Scratch/proto only; never ship lane. | **VERIFIED** (commercial rights asserted); ship-safety = NO (legal) |
| **AIVA** | Web app + "download any file format"; **API [UNVERIFIED]** | WAV + all formats; MIDI influence input | **Pro plan = YOU own full copyright forever, full monetization, no credit.** Free = non-commercial + attribution. | Free €0; Pro (paid) = copyright owned by you | **A** (license) | **Licensed-music wrap-first** — clean copyright story (Pro = you own it). Confirm headless API vs web-only before lights-out wrap. Trusted clients (NVIDIA/TED). | **VERIFIED** (license); headless API [UNVERIFIED] |
| **Stable Audio (2.x/3.0)** | **SelfHost / Stability API** | Audio (WAV) | **Stability Community License free <$1M rev** (commercial); no indemnification. | Free <$1M rev; Enterprise | **B** | Self-host/API licensed-music lane for <$1M studios. No indemnity → log provenance. | **VERIFIED** (Community License covers Stable Audio) |
| **Mubert** | API (per market) | Audio stream/WAV | Royalty-free model [verify current ToS] | API tiers [verify] | **B** | Royalty-free generative music lane; **verify current API + license** before wrap. | [UNVERIFIED] this pass |

### 2.6 — NPC / Dialogue (runtime)

| Tool | Access | Engine targets | Commercial / IP | Pricing | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|---|
| **Convai** | **Open APIs + plugins** (Unity, Unreal, 3JS, PlayCanvas); SDKs, docs | Unity, Unreal, web | Runtime service; 65+ langs, 500+ voices | Free tier (per seed) [verify current] | **A** (runtime) | Runtime NPC dialogue/voice/lipsync/animation via SDK. **Runtime feature, not asset-gen** — out of v1 ship-scope per brief (runtime generative NPC deferred) but wrappable for authoring/proto. | **VERIFIED** (open APIs + Unity/Unreal SDK) |
| **Inworld AI** | **Realtime API + SDKs** (now pivoted to voice: TTS-2/STT/Router/Agent Runtime) | Engine-neutral (voice/runtime) | Runtime service license | Get-started-free + Contact Sales | **A** (runtime voice) | Now a **realtime voice/TTS platform** (was Character Engine). Runtime, not offline asset-gen. Same scope caveat as Convai. | **VERIFIED** (now voice-Realtime-API platform) |

### 2.7 — Full-Game / No-Code

| Tool | Access | Output | Commercial / IP | Maturity | Factory integration path | VS |
|---|---|---|---|---|---|---|
| **Rosebud AI** | Web app (NL→game; "vibe coding"; 3D games/worlds) | Playable web game + assets (export/API [UNVERIFIED]) | [UNVERIFIED] | **C** (for factory) | NL→full-game is a *competitor paradigm*, not a wrappable asset tool. No engine-neutral asset export API surfaced. **Not a wrap target** — overlaps the factory's own role. | **PARTIAL** (product verified; asset-export API [UNVERIFIED]) |

---

## 3. Per-Category Wrap-First Recommendations

Constraints applied: **(a) must have a programmatic API/SDK/MCP** (lights-out), **(b)
engine-neutral export**, **(c) shippable commercial license on a paid tier.**

| Category | Wrap FIRST | Why (one line) | Backup / notes |
|---|---|---|---|
| **2D sprites/sheets** | **AutoSprite** | Only tool that does the exact "single sprite → animated spritesheet + engine atlas" job AND ships **REST + MCP + Unity Extension** with explicit shipping rights. | **Scenario** for per-IP style-consistent character sheets (full ownership, SOC2) when consistency/IP-governance matters. |
| **2D concept / texture / UI** | **Scenario** | Full commercial license + you-own-output + per-IP LoRA training + REST/SDK/webhooks + 2D & 3D export. | **Leonardo** (PAYG concept), **Recraft** (design-grade) — both concept/draft (no indemnity asserted). |
| **3D props / characters** | **Meshy** | Official **MCP + REST**, broadest export (FBX/OBJ/USDZ/GLB/STL/BLEND), in-API rig+animate, paid = full ownership. | **Tripo** (cheaper entry $11.94, batch NPC variants, community MCP); **Sloyd** for clean parametric topology + runtime SDK. |
| **Clean-topology / parametric props** | **Sloyd** | Parametric+AI = predictable game-ready topology, auto-UV+LOD, REST + runtime SDK. | Reselling needs Pro $50/mo tier — gate in provenance. |
| **Environments / worlds** | **World Labs (Marble)** *(pending license verify)* | Only engine-neutral API-exposed world generator found; multi-format 3D export. | **Promethean = Unreal-adapter (DEFERRED)**, desktop-bound. |
| **Animation / rigging** | **Meshy / Tripo in-API rig+animate** | Reuses the same 3D wrap; no separate desktop tool needed for humanoid base. | **Move.ai** for video-mocap *if* headless API confirmed; Cascadeur/AccuRig = human-finishing only. |
| **SFX** | **ElevenLabs Text-to-SFX API** | REST API, commercial license on $6 Starter, 44.1kHz PCM on Pro. | — |
| **Music (ship-safe)** | **AIVA (Pro)** + **Stable Audio** | AIVA Pro = you own full copyright; Stable Audio under Community License — **both ship-safe vs Suno.** | Confirm AIVA headless API; **Suno = NON-SHIP** (R-003). |
| **NPC dialogue (runtime)** | **Convai** *(authoring/proto only)* | Open APIs + Unity/Unreal SDK + free tier. | Runtime generative NPC is **out of v1 ship-scope** per brief. |
| **Full-game no-code** | **none** | Rosebud/Ludus are competitor paradigms, not wrappable asset APIs. | — |

---

## 4. API-Availability Gaps / Blockers

> **RELAXED-CONSTRAINT UPDATE (2026-06-07).** The product owner has relaxed the "headless
> required / no-API = blocker" stance: a tool now QUALIFIES if it can produce an asset and
> EXPORT a license-clean, ingestible artifact via ANY control surface (REST API, MCP, headless
> CLI, SaaS web UI via browser automation, or local desktop GUI via GUI automation). The
> unifying contract is **asset-library ingestion + provenance, not the control method.** Under
> this rule the "hard blockers" below are RE-CLASSIFIED. Full analysis, control-surface
> taxonomy (`backend_class`), verbatim ToS quotes, and the expanded asset-adapter protocol are
> in the companion doc **`asset-automation-backends.md`**. Summary of the flips (all primary-
> source-verified there):
>
> - **Kaedim → viable-via-API.** Official Web API verified (`POST`, `X-API-Key`+JWT, returns
>   obj/fbx/glb/gltf/mtl). Human-QC makes it async-with-latency, not instant — but API-driven
>   (no UI scraping, no ToS hazard). Tier-2/3 high-quality-mesh backend.
> - **Cascadeur → viable-via-desktop-gui.** Real Python `csc` API (FBX/DAE/USD export) but **no
>   headless/CLI flag** → drive its in-app Python console via GUI automation + Xvfb, or keep as
>   human-finishing. Now an allowed animation-finishing backend.
> - **Promethean AI → viable-via-desktop-gui, but as a SCENE-LAYOUT step, not an asset source.**
>   Verified: it set-dresses/arranges your EXISTING assets ("drag a folder of your 3D assets…
>   build worlds"; UE-primary); it produces scene arrangements, not standalone assets. Belongs
>   inside the engine adapter (Unreal-primary, deferred), downstream of the asset library.
> - **OpenArt → STILL not viable.** Not for lack of a surface but because its ToS **forbids the
>   only surface's automation**: ToS §4.4 (verbatim) *"No automated access, bots, or scripts" /
>   "Only real human interactions are allowed"*; no public API. Browser automation = ToS
>   violation. Also attribution-encumbered + uncopyrightable.
> - **Rosebud → STILL not viable.** No per-asset export API AND ToS §(xi) (verbatim) prohibits
>   *"spiders, crawlers, robots, scrapers, automated tools… to access the Services."*
> - **GUI-bound DCCs split by driver path:** Blender (`-b --python` bpy), ZBrush (`-batch
>   -script`, OBJ batch), and Substance Designer (`sbscooker`/`sbsrender`/Pysbs) are
>   **headless-cli** (reproducible); Substance Painter (`--enable-remote-scripting`, needs live
>   app) and Marvelous Designer (in-app Python) are **desktop-gui**.

**Hard blockers for lights-out (no headless API found this pass) — see relaxed re-classification above:**
- **Promethean AI** — desktop app + DCC/UE plugins, Python-in-editor only; **Unreal-adapter, DEFERRED**. RE-CLASSIFIED: viable-via-desktop-gui as a scene-layout step (not an asset producer).
- **Cascadeur** — desktop animation app; no public CLI/headless API. RE-CLASSIFIED: viable-via-desktop-gui (Python `csc` console + GUI automation) — now an allowed animation-finishing backend.
- **OpenArt Sprite Generator** — web GUI; no API surfaced. STILL NOT VIABLE: ToS forbids automation of its only surface.
- **Rosebud AI** — full-game web tool; no engine-neutral asset-export API; overlaps factory role. STILL NOT VIABLE: no per-asset export + ToS forbids automation.
- **Kaedim** — human-in-the-loop by design (contradicts lights-out). RE-CLASSIFIED: viable-via-API (async; official Web API verified → obj/fbx/glb/gltf/mtl).

**Soft blockers (API claimed/likely but not primary-verified this pass — confirm before wrap):**
- **World Labs (Marble)** export-format list + commercial license.
- **Move.ai** headless API vs upload-portal.
- **Ready Player Me** current API + license (site fetch failed this pass).
- **AIVA** / **Mubert** headless API surface.
- **Layer.ai** / **Sprite-AI** public self-serve API shape.
- **Recraft** API license/indemnity specifics (API marketed; terms [UNVERIFIED]).
- **Adobe Firefly Services / Substance 3D Sampler text-to-texture** — indemnification + API
  asserted in prior research (`generative-asset-ai.md` §2.2/§5.2) but **NOT re-verified against
  Adobe's own page this pass** → carry as [UNVERIFIED-THIS-PASS]; it remains the best
  *indemnified* 2D/texture option if confirmed.

---

## 5. Engine-Agnostic Export Reconciliation

Confirms the `AAA-RECONCILIATION.md` §9 interchange decision (GLB canonical, USD backbone, FBX
bridge) against what the verified tools actually emit:

| Interchange | Tools that natively emit it (verified) | Factory use |
|---|---|---|
| **GLB / glTF 2.0** (canonical runtime) | Meshy, Tripo, Sloyd, Hyper3D, Scenario, Stability SF3D, Ready Player Me, World Labs (claimed) | **Primary target** — every 3D wrap emits GLB. Adapter ingests GLB → engine. |
| **FBX** (bridge) | Meshy, Tripo, Sloyd, Hyper3D, Scenario, Move.ai, Cascadeur, AccuRig | Convert downstream; needed for some rigs/anim. |
| **USDZ / USD** | Meshy (USDZ), Tripo (Convert→USDZ), Move.ai/AccuRig (USD) | USD backbone for scene assembly per reconciliation. |
| **OBJ / STL** | Meshy, Tripo, Sloyd, Hyper3D, Scenario, Stability | Static props / 3D-print path. |
| **PNG spritesheet + atlas (JSON)** | **AutoSprite**, Scenario, Sprite-AI | 2D sprite lane → Unity Sprite Editor / Godot SpriteFrames. **This is the 2D-equivalent of GLB.** |
| **PNG/SVG/WebP** (2D) | Scenario (incl SVG), Leonardo, Recraft | Concept/UI/texture. |
| **WAV / MP3 / PCM** | ElevenLabs (WAV/PCM 44.1k), AIVA (WAV+all), Stable Audio, Suno | Audio lane → engine audio import. |

**Finding:** every recommended wrap-first tool emits a format already in the reconciliation's
canonical set. **No new interchange format is required** — the existing GLB-canonical /
USD-backbone / FBX-bridge / PNG+atlas-for-2D / WAV-for-audio spine fully covers the verified
wrap targets. Shader/material non-portability (R-007) is unchanged — `material.semantic`
per-engine compilation still required.

---

## 6. Provenance / License Implications (feeds the sidecar)

The verified license findings impose **concrete fields** the `asset-provenance-sidecar`
(`AAA-RECONCILIATION.md` §9 / `generative-asset-ai.md` §7.2) must capture — beyond tool name:

1. **`tier_at_generation` (NEW, mandatory).** Ownership flips on tier: **Meshy free = CC BY 4.0
   (attribution); paid = full ownership.** Tripo free = CC BY 4.0 public; paid = private+commercial.
   Sloyd commercial = Plus; **redistribution/reselling = Pro only.** The sidecar MUST record the
   exact paid tier active at generation, or the studio cannot prove its ship rights.
2. **`resale_of_raw_model_allowed` (NEW boolean).** Distinguish *use-in-game* (broadly allowed on
   paid) from *reselling the raw mesh/sheet file* (gated — Sloyd Pro; Meshy premium yes; Tripo
   verify). Asset-store redistribution is a separate right.
3. **`attribution_required`.** True for Meshy/Tripo free (CC BY 4.0), AIVA free, Sprite-AI free.
4. **`indemnification`.** None asserted by Meshy/Tripo/Sloyd/Hyper3D/Stability/Scenario/Leonardo
   on verified pages. **Adobe Firefly is the only indemnified option** (per prior research,
   re-verify). Default = `none` for the 3D/2D wrap spine → keep to Tier-1/low-IP classes or
   heavy human-transform for Tier-2/3 (consistent with R-001/R-002).
5. **`training_data_provenance`.** Scenario asserts your data isn't used to train + no
   cross-customer sharing (strong for IP-sensitive). Open-weights (Stability/Hunyuan/TRELLIS) =
   `open`, license-reviewed.
6. **`litigation_status`.** Suno = exposed → NON-SHIP flag (R-003). ElevenLabs voice → consent
   gate (R-004, `likeness_consent_ref`).
7. **`copyrightability_assessment`.** Unchanged from R-001: empty `human_modifications_log` ⇒
   "likely uncopyrightable (US)". Pure-API wrap output is maximally exposed to this — the more
   autonomous the wrap, the weaker the copyright. Tier-2/3 ownership requires logged human transform.

**Single biggest licensing gotcha (return-line answer):** **Free tiers silently strip commercial
ownership / impose CC BY 4.0 attribution (or block resale).** A factory that defaults to free
tiers to save credits would generate **un-shippable or attribution-encumbered** assets while the
provenance sidecar — if it only logs the tool name — would *falsely* imply clean rights. The fix
is mandatory `tier_at_generation` + `resale_of_raw_model_allowed` capture and a hook that **fails
any ship-bound asset generated on a free/CC-BY tier.**

---

## 7. MCP Servers (cross-cut — hand depth to `mcp-automation` doc)

Verified MCP servers among wrap targets (enumeration only; architecture → companion doc):

| Tool | MCP server | Status | Source |
|---|---|---|---|
| **Meshy** | `@meshy-ai/meshy-mcp-server` (npm) | **Official**, open-source (github.com/meshy-dev). Tools: `meshy_text_to_3d`, `meshy_image_to_3d`, `meshy_remesh`, `meshy_retexture`, `meshy_rig`, `meshy_animate`, image-gen. Also ships `meshy-3d-agent` skill pack + `llms.txt`. | docs.meshy.ai/en/api/ai; github.com/meshy-dev/meshy-mcp-server |
| **AutoSprite** | AutoSprite MCP (`/docs/mcp`) | **Official**, Pro-tier ($29/mo) feature. | autosprite.io/pricing; /docs/mcp |
| **Tripo** | `tripo-ai-mcp-server` (npm) | **Community** (text/image/multiview→3D, animation, stylization, task status). | conare.ai/marketplace/mcp/tripo-ai |
| **Meshy (community alt)** | `pasie15/meshy-ai-mcp-server` | Community (predates/parallels official). | github.com/pasie15/meshy-ai-mcp-server |

No verified first-party MCP found this pass for Scenario, Sloyd, Hyper3D, Leonardo, ElevenLabs,
AIVA, Convai, Inworld — wrap those via their REST APIs (or build thin MCP shims). MCP-vs-REST
selection, auth/secret handling, and headless orchestration patterns are deferred to the
`mcp-automation` research doc.

---

## 8. Open Questions / Risks

1. **[UNVERIFIED-THIS-PASS] Adobe Firefly / Substance 3D Sampler** — the only *indemnified* 2D/
   texture option per prior research; re-verify API + indemnification against Adobe's own page
   before relying on it for Tier-2/3. (Highest-value unverified item.)
2. **World Labs (Marble) license + export list** — promising engine-neutral world generator;
   blocked on primary license/format verification.
3. **Ready Player Me / Move.ai / AIVA / Mubert headless API** — products verified, but
   confirm true headless (REST) access vs upload-portal/web-only before counting them lights-out.
4. **Resale-of-raw-model terms vary per vendor and change often** — Sloyd gates it to Pro; Meshy
   premium grants it; Tripo/Hyper3D unverified. Legal must snapshot each ToS at integration.
5. **No indemnification across the 3D/2D wrap spine** (except Firefly) — residual training-data
   litigation risk stays with the studio (R-002). Caps the wrap-only model to Tier-1 + human-
   transformed Tier-2 for IP-sensitive titles.
6. **Desktop-only animation tools (Cascadeur, AccuRig)** leave a gap for non-humanoid / stylized
   rigs that the in-API riggers (Meshy/Tripo) don't cover — may force human-finishing or
   UI-automation for those specific assets.
7. **Fast-moving pricing/tiers** — every dollar figure and tier name here is a 2026-06 snapshot;
   re-verify at integration (Tripo/Meshy iterate monthly).
8. **Convai/Inworld are runtime, not offline asset-gen** — wrappable for authoring/proto but
   runtime generative NPC dialogue is explicitly **out of v1 ship-scope** (brief; reconciliation §10).

---

## 9. Sources

See YAML `sources`. Every [VERIFIED] row was confirmed by extracting the vendor's own
site/docs/pricing page (Tavily extract / WebFetch) this pass. [UNVERIFIED] / [PARTIAL] items
are flagged inline and listed in §4 and §8. Prior-research-sourced claims cite
`generative-asset-ai.md` / `AAA-RECONCILIATION.md` explicitly.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 1 | Attempted deep multi-source sweep of 19 secondary tools (Sloyd/Kaedim/Recraft/Firefly/Stable Audio/AIVA/Mubert/Cascadeur/Move.ai/AccuRig/RPM/Polycam/Luma/Convai/Inworld/TRELLIS/etc). **Model self-reported it could NOT reach primary sources and was using 2024 training data — its tool-specific claims were DISCARDED** per the project's anti-confabulation rule; only used to enumerate which tools to verify directly. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no single-library doc question in scope) |
| Tavily tavily_extract | 6 | **PRIMARY verification** — extracted vendor pages: autosprite.io + pricing, meshy.ai/api + pricing + docs (incl MCP/AI page), tripo3d.ai + pricing + platform docs, sloyd.ai + pricing, scenario.com + pricing + KB, leonardo.ai/api, elevenlabs SFX + pricing, hyper3d.ai, recraft, layer.ai, sprite-ai.art, suno.com, aiva.ai, move.ai, cascadeur.com, convai.com, inworld.ai, rosebud.ai, prometheanai.com, worldlabs.ai, stability.ai/license, lumalabs dream-machine/api. |
| Tavily tavily_search | 3 | MCP-server existence (Meshy/Tripo official+community), AutoSprite API+MCP confirmation, Sloyd REST API shape + commercial license. |
| WebFetch | 1 | autosprite.io/docs/api-characters — confirm REST endpoints + MCP integration page. |
| Training data | ~3 areas | Format conventions (GLB/FBX/USD/PNG-atlas) and a few prior-research carry-forwards (Hunyuan/TRELLIS/Move.ai-FBX) — all flagged [UNVERIFIED] or cited to generative-asset-ai.md where not re-verified this pass. No pricing/version numbers taken from training data. |

**Total MCP tool calls:** 11 (1 perplexity_research [discarded for content] + 6 tavily_extract + 3 tavily_search + 1 WebFetch).
**Training data reliance:** low — every shippable claim (API existence, output formats, license tier, pricing, MCP availability) was confirmed against the vendor's own page; the one deep-research call was explicitly discarded after it self-reported no primary-source access, and unverifiable items are marked [UNVERIFIED]/[PARTIAL] rather than guessed.
