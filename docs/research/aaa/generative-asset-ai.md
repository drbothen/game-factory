---
document_type: research
vector: generative-asset-ai
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
title: "Generative & Procedural Asset Generation — State of the Art (2025–2026)"
project: game-factory
scope: "Dark Factory for AAA game development — engine-agnostic multi-agent autonomous asset generation"
sources:
  # Verified primary / authoritative (Tavily cross-validated)
  - https://www.copyright.gov/ai
  - https://www.copyright.gov/newsnet/2025/1060.html
  - https://www.skadden.com/insights/publications/2025/02/copyright-office-publishes-report
  - https://www.clearyiptechinsights.com/2025/03/thaler-v-perlmutter-further-confirms-human-authorship-required-for-copyright-protection
  - https://www.pinsentmasons.com/out-law/news/gettys-copyright-case-against-stability-ai-fails
  - https://newsroom.gettyimages.com/en/getty-images/getty-images-issues-statement-on-ruling-in-stability-ai-uk-litigation
  - https://www.lw.com/en/insights/getty-images-v-stability-ai-english-high-court-rejects-secondary-copyright-claim
  - https://legalmoveslawfirm.com/steam-ai-policy
  - https://www.gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam
  - https://business.adobe.com/products/firefly-business/firefly-ai-approach.html
  - https://www.fastcompany.com/90906560/adobe-feels-so-confident-its-firefly-generative-ai-wont-breach-copyright-itll-cover-your-legal-bills
  - https://www.chartlex.com/blog/business/music-industry-ai-lawsuits-tracker-2026
  - https://www.musicbusinessworldwide.com/universal-music-settles-udio-lawsuit-strikes-deal-for-licensed-ai-music-platform
  - https://www.dglaw.com/sag-aftras-new-video-game-agreement
  - https://www.sagaftra.org/sites/default/files/2025-06/2025%20Interactive%20Media%20%28Video%20Game%29%20Agreement%20Summary.pdf
  - https://en.wikipedia.org/wiki/2024%E2%80%932025_SAG-AFTRA_video_game_strike
  # 3D mesh / texture / tools
  - https://github.com/VAST-AI-Research/TripoSG
  - https://platform.tripo3d.ai/docs/changelog
  - https://github.com/Tencent-Hunyuan/Hunyuan3D-2
  - https://github.com/Stability-AI/stable-fast-3d
  - https://huggingface.co/stabilityai/stable-fast-3d
  - https://microsoft.github.io/TRELLIS.2/
  - https://www.meshy.ai/blog/mesh-topology
  - https://80.lv/articles/how-hyper3d-rodin-gen-2-5-is-bringing-production-level-control-to-ai-3d-generation
  - https://blogs.autodesk.com/media-and-entertainment/2026/03/04/introducing-wonder-3d-text-and-image-to-3d-in-flow-studio/
  - https://resources.nvidia.com/en-us-nim/nvidia-edify-unlocks-3d-generative-ai
  - https://experienceleague.adobe.com/en/docs/substance-3d-sampler/using/release-notes/version-4-4-substance-3d-sampler
  - https://www.cgchannel.com/2024/05/adobe-releases-substance-3d-sampler-4-4
  # 2D
  - https://bfl.ai/announcements/flux-1-kontext
  - https://arxiv.org/html/2506.15742v1
  - https://flowith.io/blog/flux-2-pro-vs-midjourney-v7-commercial-artists-full-control
  # Animation
  - https://cascadeur.com/blog/view/cascadeur-2025-2-brings-massive-ai-inbetweening-workflow-upgrades
  - https://www.rokoko.com/products/vision
  # Procedural
  - https://www.sidefx.com/products/houdini-engine/
  - https://developer.nvidia.com/blog/high-fidelity-3d-mesh-generation-at-scale-with-meshtron/
  - https://quadspinner.com/Gaea3
  - https://unity.com/products/speedtree
  - https://github.com/mxgmn/WaveFunctionCollapse
  - https://www.prometheanai.com
  - https://inworld.ai
provenance_note: >
  Tool-vendor specifics (model versions, mesh topology behavior, licensing, IP terms) were
  gathered via Perplexity sonar-deep-research (HIGH reasoning_effort) and CROSS-VALIDATED with
  Tavily web search. WARNING: the deep-research model FABRICATED several legal specifics
  (invented case names, dollar figures, vendor product-version numbers in the animation vector).
  All load-bearing legal, music, SAG-AFTRA, Getty, Steam, and Firefly claims in this report were
  replaced with Tavily-verified primary sources. Animation-vector vendor product-version numbers
  from deep research were discarded except where independently confirmed. See "Confidence &
  Fabrication Flags" and Research Methods sections.
---

# Generative & Procedural Asset Generation — State of the Art (2025–2026)

> Research vector for the game-factory re-scope ("Dark Factory for AAA"). Question being
> answered: **Can autonomous agents generate ALL of a game's assets, for ANY genre, at AAA
> quality, today?** Framed toward: what to WRAP (which APIs/models) vs build, and how outputs
> flow into an engine-agnostic asset pipeline.

---

## 1. Executive Summary

The 2025–2026 generative-asset landscape supports a **"generate-then-finish" factory**, not a
"generate-and-ship" factory. Across every modality, AI can produce *first-draft to mid-quality*
assets autonomously, but **AAA-bar final assets still require human (or much more sophisticated
agentic) cleanup** — with the cleanup cost varying dramatically by modality.

Key findings:

- **3D mesh generation is the most production-advanced generative modality.** Tools like Tripo
  v3.x, Hyper3D Rodin Gen-2.x, Tencent Hunyuan3D, Meshy 5, and Microsoft TRELLIS now produce
  textured, UV-unwrapped, PBR meshes in seconds, with **quad-topology modes** and **auto-rig**
  emerging. They are AAA-ready for **props, kitbash, background/set-dressing, and prototype/greybox
  assets**; they are *not* yet AAA-ready for **hero characters, animation-deformation-critical
  organic forms, or tight art-directed silhouettes** without retopo/cleanup.
- **Texture/material generation (Substance 3D Sampler text-to-texture, Polycam, Meshy texture
  mode)** is the **closest to "drop-in AAA"** for tileable surface materials — full PBR sets,
  4K, and (with Adobe Firefly) commercially-indemnified provenance.
- **2D concept art is fully production-integrated** as an *ideation/exploration* tool (FLUX,
  Midjourney v7, SDXL, Firefly). Final shippable 2D (UI, marketing, in-game sprites) is
  feasible but carries the **highest IP/consistency burden**.
- **AI animation/motion is the least mature for AAA hero work.** Markerless mocap (Move.ai,
  Rokoko Vision, DeepMotion) + physics-assisted keyframing (Cascadeur) + auto-rig (Mixamo,
  AccuRig, Meshy/Tripo) handle **locomotion, background NPCs, and cleanup** well, but **lead
  performance / emotional nuance remains human**.
- **Procedural generation (non-AI: Houdini, UE5 PCG, SpeedTree, Gaea) is the most
  production-proven, deterministic, AAA-trusted content lever** — and is the safest foundation
  for the factory's *structural* content. AI-hybrid PCG (NVIDIA Meshtron, Promethean AI) is
  emerging.
- **The single biggest cross-cutting risk is IP/copyright**, on two axes: (a) **copyrightability**
  — purely AI-generated assets may be uncopyrightable/public-domain in the US, threatening the
  *ownership* of factory output; and (b) **training-data infringement / indemnification gaps** —
  most generative-3D and open image models offer **no indemnification**, and music generators are
  in active, high-stakes litigation. **Audio/music/voice is the most legally hazardous modality.**

**Factory implication:** A viable "generate everything" factory wraps mature APIs (3D mesh,
texture, concept, mocap-cleanup, PCG) behind a **provenance- and license-tracking spine**, applies
**automated quality gates**, and **routes AAA-critical assets through a human-in-the-loop finishing
stage**. "Generate all assets" is feasible as *bulk + draft + procedural-structural*; it is NOT yet
feasible as *fully-autonomous, ship-ready, hero-tier* across all modalities.

---

## 2. Capability Matrix (modality × tool × quality × commercial/IP × API × maturity)

Maturity rating legend: **A = AAA-ready today (bulk/draft or final per notes)** · **B = needs human
cleanup** · **C = not viable for AAA autonomous output**. Quality is "raw output before cleanup."

### 2.1 Text/Image-to-3D Mesh

| Tool | Vendor | Latest (verified) | Modality | Raw quality / topology | UV+PBR | Rig-ready | Commercial/IP | API | Maturity |
|---|---|---|---|---|---|---|---|---|---|
| **Tripo (Tripo3D)** | VAST AI / Tripo | v3.0 beta (2025-08); v3.1 referenced | text+img→3D | Sharp geo, hard-surface improved, 4K PBR; quad option | Yes, auto-UV + 4K PBR | Auto-rig tab | Paid tier = full commercial; raw-model resale often restricted (verify ToS) | Yes (platform.tripo3d.ai) | **A (props/draft) / B (hero)** |
| **Hyper3D Rodin (Deemos)** | Deemos | Gen-2.5 | text+img→3D | "Quad mode" = production topology w/ edge loops; "Raw" = faster triangle soup; geometry presets | Yes, HD PBR | Topology-aware (rig-ready quad) | Paid commercial; verify resale terms | Yes | **A (props/draft) / B (hero)** |
| **Meshy** | Meshy AI | v5 / 2.5+ era | text+img→3D | AI retopology → quad, optimized polycount; hybrid topology presets for games | Yes, efficient UV + PBR | Auto-rig (humanoid) | Paid = commercial; free = personal only; no resale of raw model | Yes | **A (props/draft) / B (hero)** |
| **Hunyuan3D** | Tencent | 2.x / 3.0 | text+img→3D | 50k–1.5M polys; 4K PBR w/ better lighting handling | Yes, 4K PBR | Partial | Open weights (check Tencent license; some non-commercial / regional clauses) | Self-host + API | **A (props) / B (hero)** |
| **Stable Fast 3D / SPAR3D** | Stability AI | SF3D / Stable Point-Aware 3D | img→3D | Fast (<1s), UV-unwrapped, textured; lower fidelity | Yes | No | Stability Community/Enterprise license; **no indemnification** | Self-host (HF) | **B** |
| **TRELLIS** | Microsoft | TRELLIS / TRELLIS.2 | text+img→3D | Strong geometry; research-grade | Yes | No | MIT-ish research license (verify); **no indemnification** | Self-host | **B** |
| **Edify 3D** | NVIDIA | Edify 3D (Omniverse/NIM) | text→3D | High fidelity, enterprise; pipeline-oriented | Yes, PBR | Pipeline | Enterprise license; provenance-focused | NIM/Omniverse API | **A (enterprise) / B** |
| **Wonder 3D (Flow Studio)** | Autodesk | 2026-03 launch | text+img→3D | Conceptualization-focused; has Remesh, animation-apply | Yes | Apply-animation | Autodesk commercial | Flow Studio | **B (concept)** |
| **Project Neo** | Adobe | beta | text→3D (precise) | Vector/precise 3D ideation, not asset-final | Limited | No | Adobe terms | Adobe | **C (ideation only)** |

### 2.2 Text-to-Texture / PBR Material

| Tool | Vendor | Output | Quality | IP/commercial | API | Maturity |
|---|---|---|---|---|---|---|
| **Substance 3D Sampler — Text-to-Texture / Text-to-Pattern / Image-to-Texture** | Adobe | Tileable materials, 4 variations; **full PBR** when combined w/ Sampler workflow | High, tileable, 4K achievable; **beta** | Adobe Firefly-backed = **commercially-safe + indemnified** (CC plans) | Firefly Services API | **A (materials)** |
| **Meshy / Tripo texture mode** | Meshy/Tripo | PBR set on mesh | Good; per-mesh | Per-platform paid commercial | Yes | **A (draft) / B** |
| **Polycam AI texture** | Polycam | Texture/material | Good | Paid commercial | Yes | **B** |
| **Materialize / ArmorLab / Dream Textures** | OSS | PBR from image / SD-driven | Varies | OSS; output IP depends on underlying model | Self-host | **B** |

### 2.3 2D Concept / Sprite / Texture

| Tool | Vendor | Modality | Consistency tooling | IP/indemnification | API | Maturity |
|---|---|---|---|---|---|---|
| **FLUX.1 (dev/pro) / FLUX.1 Kontext / FLUX 2 Pro** | Black Forest Labs | text→img, in-context edit | **Kontext = char/style consistency, local edit**; LoRA, ControlNet | Commercial license; **no broad indemnification** | Yes (BFL, fal, Replicate) | **A (concept) / B (final)** |
| **Midjourney v7** | Midjourney | text→img | Omni-ref consistency; closed pipeline | **No indemnification; user assumes risk** | Limited | **A (concept) / B** |
| **SDXL / SD 3.5** | Stability | text→img | ControlNet, IP-Adapter, LoRA (full control) | Community/Enterprise; **no indemnification** | Self-host | **A (concept) / B** |
| **Adobe Firefly (Image)** | Adobe | text→img | Custom Models, structure ref | **Commercially-safe + indemnified** | Firefly Services | **A (final-safer)** |
| **Scenario.gg / Leonardo / Recraft** | various | text→img, game-tuned | Per-IP LoRA, style locks | Paid commercial; indemnification varies | Yes | **A (concept) / B** |

### 2.4 Animation / Motion / Rigging

| Tool | Vendor | Function | Output | Quality for AAA | Pricing (verified consumer) | Maturity |
|---|---|---|---|---|---|---|
| **Cascadeur** | Nekki | AI-assisted keyframe, AI Inbetweening, AI Root Motion (style transfer), physics, quadruped autopose, UE Live Link | FBX | **Strong for cleanup/blocking/locomotion**; hero = human | Indie ~$99/yr | **A (assist/cleanup) / B (hero)** |
| **Move.ai** | Move.ai | Markerless video→mocap (multi-cam, single-cam) | FBX/USD | Good for locomotion; fine hand/face weaker | ~$144/yr (8 min tiers) | **A (locomotion) / B** |
| **Rokoko Vision** | Rokoko | Free webcam/video markerless mocap | FBX/BVH | Indie-grade; cleanup needed | Free / suit upsell | **B** |
| **DeepMotion** | DeepMotion | Video→mocap, animate-3D | FBX/BVH | Mid; combat/athletic tuned | Subscription | **B** |
| **Mixamo** | Adobe | Auto-rig + library (humanoid) | FBX | Solid base humanoid rig; legacy | Free | **A (base rig) / B** |
| **AccuRig / ActorCore** | Reallusion | Auto-rig + pre-rigged library | FBX/USD | Good for real-time; humanoid | Free (AccuRig) / paid | **A (base rig)** |
| **Audio2Face** | NVIDIA | Audio→facial animation | USD/blendshapes | Strong lip-sync; emotional nuance limited | NIM/Omniverse | **A (secondary) / B (hero)** |
| **Anything World** | Anything World | Prompt-based rig for non-standard anatomy | varies | Functional base, needs refinement | API | **B** |

### 2.5 Procedural (non-AI + AI-hybrid)

| Tool | Vendor | Generates | Maturity for AAA | License | Engine-agnostic? |
|---|---|---|---|---|---|
| **Houdini + PDG/TOPs + Houdini Engine** | SideFX | Geometry, terrain, destruction, procedural rig, batch | **A (production-proven)** | Workstation mid-$thousands/yr; **Houdini Engine free for UE/Unity** (needs 1 paid author seat) | **High** (FBX/USD + HDA) |
| **UE5 PCG Framework + Geometry Script + PCG Biome** | Epic | Worlds, scatter, biomes, runtime PCG | **A (production-ready in UE5.7)** | UE EULA | Engine-specific (patterns portable) |
| **SpeedTree** | Unity | Procedural vegetation + runtime SDK | **A (industry standard)** | Per-seat/title commercial | **High** (mesh+SDK) |
| **Gaea / World Machine** | QuadSpinner / Stephen Schmitt | Terrain heightfields/masks | **A** | Tiered (free→enterprise); Gaea 3.0 adds **native USD** | **High** (RAW16/PNG/USD) |
| **WFC / BSP / noise / dungeon algos** | OSS | Tile/level/dungeon layouts | **A (with engineering)** | OSS | **High** (portable code) |
| **NVIDIA Meshtron** | NVIDIA | Autoregressive mesh gen (≤64K faces, quad ratio control) from point clouds | **Emerging (B)** | SDK | Mesh-format export |
| **Promethean AI** | Promethean | AI environment set-dressing / prop placement | **Emerging (B)** | Subscription | DCC/UE oriented |
| **Inworld AI** | Inworld | Runtime NPC dialogue/voice/behavior | **A (runtime narrative)** | ~$15/M chars | SDK (engine adapters) |

---

## 3. What's AAA-Ready Today vs Human-Cleanup vs Not-Viable

### AAA-ready TODAY (autonomous bulk/draft, or final per note)
- **Tileable PBR materials** via Substance 3D Sampler text-to-texture (final, and Firefly-indemnified).
- **Props, kitbash pieces, background/set-dressing 3D meshes** via Tripo/Rodin/Meshy/Hunyuan (final
  for non-hero; near-final with light cleanup).
- **Greybox / prototype / blockout 3D** for any genre — high volume, low risk.
- **Concept art / mood boards / style exploration** (all 2D tools) — this is *already standard* in AAA.
- **Procedural structural content**: terrain (Gaea/Houdini), vegetation (SpeedTree), world scatter
  & biomes (UE5 PCG), dungeon/level layouts (WFC/BSP) — deterministic, trusted, shippable.
- **Base humanoid rigs** (Mixamo/AccuRig) and **locomotion/background mocap** (Move.ai + Cascadeur cleanup).
- **Runtime NPC dialogue/behavior** (Inworld) where the studio accepts the model.

### Needs HUMAN CLEANUP (draft → finish)
- **Hero/character 3D meshes** — retopo, UV refinement, art-direction silhouette fidelity, rig weighting.
- **Animation-deformation-critical organic forms** — edge loops around faces/joints.
- **Final shippable 2D** (UI, key art, consistent character sheets across a game) — consistency +
  IP scrubbing + art-direction lock.
- **Mocap fine motion** — hands, fingers, facial micro-expression, stylized/non-human motion.
- **AI-hybrid procedural mesh** (Meshtron, Kiss3DGen-class) — integration + validation still maturing.

### NOT VIABLE for autonomous AAA output (today)
- **Hero character full performance** (emotional acting, signature movement) — human-led.
- **Fully autonomous ship-ready music** — **active litigation + indemnification withdrawal** make
  it a legal hazard, not a quality one (see §5).
- **AI voice of identifiable performers** without consent — contractually + legally gated (SAG-AFTRA).
- **Precise 3D ideation tools (Project Neo)** as asset-final output.

---

## 4. Procedural Generation Landscape (deep)

Procedural generation is the **most reliable lever** for a "generate everything" factory because it
is **deterministic, controllable, reproducible (seed-based), and legally clean** (no training-data
provenance issue for classical PCG; Steam explicitly *exempts* traditional procedural generation
from AI-disclosure).

- **Houdini (PDG/TOPs, Houdini Engine):** the engine-agnostic procedural hub. HDAs author once,
  cook in UE/Unity or bake to FBX/USD. **Houdini Engine is free for UE & Unity commercial use**
  (needs ≥1 paid author seat). Best fit for the factory's geometry/terrain/destruction backbone and
  for *generating tools*, not just assets.
- **UE5 PCG Framework:** **production-ready in UE 5.7**, runtime-capable (Witcher 4 tech demo shows
  ~71µs/frame budgets), with PCG Biome Core/Sample plugins. Engine-specific, but design patterns are
  portable to an engine-agnostic core.
- **SpeedTree (Unity-owned):** industry-standard procedural vegetation with runtime SDK — wrap directly.
- **Gaea / World Machine:** terrain heightfields/masks; **Gaea 3.0 (mid-2026) adds native USD**, which
  matters for an engine-agnostic USD-centric pipeline.
- **Classical algorithms (WFC, BSP, DFS, cellular automata, Perlin/fractal noise):** OSS, portable,
  deterministic — ideal to build into the factory's own engine-agnostic generation library.
- **AI-hybrid (emerging):** NVIDIA **Meshtron** (autoregressive mesh, quad-ratio + face-count control,
  ≤64K faces from point clouds); **Promethean AI** (AI set-dressing); RL-driven level design and
  Kiss3DGen-class 2D-diffusion-to-3D remain **research/early-adopter**, not yet AAA-trusted.

**Factory pattern:** deterministic PCG = structural backbone (worlds, terrain, scatter, levels);
generative AI = *assets that fill the structure* (props, textures, characters); AI-hybrid PCG =
opportunistic acceleration with human review. Keep PCG algorithms in an **engine-agnostic core**
with thin per-engine adapters (USD/FBX + HDA + SDK).

---

## 5. IP / Legal / Licensing Risk Analysis (CRITICAL — verified)

This is the load-bearing section. **All claims below are Tavily-verified against primary sources;
deep-research hallucinations were discarded.**

### 5.1 Copyrightability of AI-generated assets (US) — the *ownership* risk
- **US Copyright Office, Report Part 2 (Jan 29, 2025):** outputs of generative AI are copyrightable
  **only where a human determined sufficient expressive elements**. **Mere prompts — even detailed
  ones — do NOT yield copyright.** Human-perceptible inputs, and creative arrangement/modification of
  AI output, *can* be protected (the human-authored portion). Part 3 (training) pre-published May 9, 2025.
- **Thaler v. Perlmutter (D.C. Cir., Mar 18, 2025):** affirmed — a work needs a **human author**;
  AI-as-sole-author is unregistrable.
- **Implication for the factory:** *fully autonomous* AI assets may be **uncopyrightable / effectively
  public domain in the US** — a strategic problem for a studio that wants to *own* its IP. The factory
  must **inject and log meaningful human creative control + substantive modification** on any asset
  where ownership matters (hero characters, key art, signature designs), and can treat bulk
  props/textures as lower-ownership-risk.

### 5.2 Training-data provenance & indemnification — the *infringement* risk
- **Getty Images v. Stability AI (UK High Court, Nov 4, 2025):** Getty's **copyright claim FAILED**;
  only **limited trademark** infringement upheld (Getty watermarks appearing in outputs). This is the
  first major UK ruling — **narrow win for AI developers on copyright**, but signals output-watermark/
  trademark exposure. (A parallel US case continues.) Net: training-on-copyright is **legally
  unresolved**, not settled-safe.
- **Indemnification splits the market:**
  - **OFFERED (wrap these for IP-sensitive assets):** **Adobe Firefly** (trained on licensed Adobe
    Stock + public domain/open; **IP indemnification on paid Creative Cloud plans**, marketed
    "commercially safe"). Enterprise vendors (Microsoft, Shutterstock, Getty's own generator) offer
    conditional coverage.
  - **NOT OFFERED (higher risk):** **Midjourney** (user assumes all legal risk), **Stable Diffusion /
    Stability**, most **open 3D models** (TRELLIS, SF3D, Hunyuan), **FLUX** (commercial license but no
    broad indemnity). Use these for *concept/draft/internal* or for assets that get heavily
    human-transformed.

### 5.3 Storefront / platform policies
- **Steam (Valve):** AI-content disclosure required since 2024; **rewritten Jan 17, 2026** to draw a
  clear line — **AI used purely as a dev/efficiency tool (e.g., coding assistants) is exempt**, but
  **AI-generated content that ships (art/sound/etc.)** must be disclosed (pre-generated and
  live-generated categories). **Traditional procedural generation is exempt.** Disclosures appear on
  the store page. Live-generated AI requires the dev to attest it won't produce illegal/prohibited content.
- **Console makers / mobile:** disclosure regimes are tightening and **fragmented**; expect
  per-platform manifests. (Specific 2026 console-policy details from deep research were unverifiable
  and are flagged as low-confidence — do not rely on them.)

### 5.4 Audio / music / voice — the most hazardous modality (verified)
- **Music generators are in active, high-stakes litigation, BUT major settlements are landing:**
  - **UMG settled with Udio (Oct 29, 2025)** — compensatory payment + **licensing deal + joint
    "walled-garden" AI music platform launching 2026** with artist opt-in/compensation; Udio's
    existing product fingerprinted/filtered during transition.
  - **Warner settled with Suno (Nov 25, 2025)** — payment + licensing partnership; Suno acquired
    Songkick; **new licensed models 2026 with download caps + opt-in voice/likeness**.
  - **Sony is still litigating** both; a **fair-use ruling is expected summer 2026** (pivotal precedent).
  - A separate **AFM (musicians' union) lawsuit** challenges the label settlements.
- **Net for factory:** AI music is moving toward **licensed walled-garden platforms** — wrapping a
  *raw* generator (unlicensed Suno/Udio output) for shipped AAA music is **legally premature**. Prefer
  licensed/royalty-free providers or in-house-trained models; treat AI music as **note-only** (a
  separate agent vector goes deeper).
- **Voice (ElevenLabs etc.):** technically excellent, but **performer-likeness is contractually gated**.
- **SAG-AFTRA 2025 Interactive Media Agreement (ratified Jul 9, 2025, 95% in favor; term to Oct 31,
  2028):** establishes **digital-replica** rules. Producers MAY create **"Independently Created Digital
  Replicas" (ICDR)** — including by **prompting a generative AI tool with the performer's name** — but
  **separate, written, clear, conspicuous, specific consent is required** (with limited exceptions), at
  negotiated rates. Signatories include Activision, EA, Epic, Take-Two, WB Games, Disney. **Any AI
  voice/likeness of a covered performer requires consent + compensation.**

### 5.5 Risk-tier guidance for the factory
| Risk tier | Asset classes | Generation policy |
|---|---|---|
| **Tier 1 (low)** | Background textures, kitbash props, crowd/filler 3D, terrain, scatter | Non-indemnified generative + PCG OK; log provenance |
| **Tier 2 (medium)** | Final environment art, secondary characters, UI art | Prefer indemnified (Firefly) or heavy human transform; copyrightability log |
| **Tier 3 (high)** | Hero characters, key art, signature IP, any music/voice | Human-led + indemnified tools only; explicit consent for any likeness; full audit trail |

---

## 6. Pipeline Integration

**Output formats are converging on glTF/GLB, FBX, USD, OBJ.** USD is the strongest spine for an
**engine-agnostic** factory (Omniverse, Gaea 3.0 USD, Houdini USD, NVIDIA Edify). Recommended flow:

```
[Generation Request] → [Model/Tool Adapter (wrapped API)] → [Raw Asset + Provenance Metadata]
   → [Automated QC Gate] → (pass) → [Canonical USD/GLB in asset store]
                          → (fail/Tier≥2) → [Human-in-loop Finishing] → [QC re-gate] → [store]
   → [Engine Adapter: UE / Unity / custom] (FBX/USD/GLB + materials)
```

Integration concerns to design for:
- **Topology/UV/PBR validation** before ingest (quad ratio, manifold, polycount budget per platform,
  UV distortion, PBR-channel coherence).
- **Rig/skeleton mapping** to a canonical skeleton (retarget to UE Manny / studio standard).
- **Material standardization** (canonical PBR channel set; tileable validation).
- **Cleanup-cost estimation** per asset → routes Tier-2/3 to humans automatically.
- **Determinism for PCG** (seed capture) so generations are reproducible/auditable.

---

## 7. Factory Artifacts / Contracts (proposed)

These are the schemas the factory needs so "generate all assets" is *governable*.

### 7.1 Generation Request schema (sketch)
```yaml
generation_request:
  id: uuid
  asset_class: [prop|character_hero|character_npc|texture_material|terrain|vegetation|
                level_layout|concept_2d|animation_clip|rig|audio_music|audio_sfx|voice]
  genre_context: string
  risk_tier: [1|2|3]            # drives tool selection + human-gate policy
  modality: [text_to_3d|image_to_3d|text_to_texture|text_to_image|video_to_mocap|
             procedural|text_to_motion|auto_rig]
  prompt / inputs: {...}
  art_direction_refs: [asset_ids]   # for consistency
  target_engines: [unreal|unity|custom]
  output_formats: [usd|glb|fbx|obj]
  budget: {polycount_max, texture_res, faces, quad_ratio}
  tool_preference / allowed_tools: [...]   # constrained by risk_tier (see §5.5)
```

### 7.2 Asset Provenance / License metadata (MANDATORY — sidecar on every asset)
```yaml
asset_provenance:
  asset_id: uuid
  generated_by_tool: {name, vendor, version}
  generation_date: timestamp
  model_version / weights_id: string
  prompt_and_inputs_log: {...}        # required for copyrightability + Steam/SAG audits
  human_modifications_log: [...]      # required to claim copyright (USCO 2025)
  license_terms_snapshot: {commercial, resale_allowed, attribution_required}
  indemnification: [none|adobe_firefly|enterprise]   # propagate IP risk
  training_data_provenance: [licensed|open|unknown]
  likeness_consent_ref: id|null       # required if any performer likeness (SAG-AFTRA)
  risk_tier: [1|2|3]
  copyrightability_assessment: [likely|partial|unlikely]
```

### 7.3 Quality-Gate criteria (per modality)
```yaml
quality_gate:
  3d_mesh: {manifold: true, polycount<=budget, uv_distortion<=thresh,
            pbr_channels_complete: true, quad_ratio>=thresh_if_animated,
            silhouette_match_to_ref>=score}
  texture_material: {tileable: true, full_pbr_set: true, resolution>=target, seam_free: true}
  concept_2d: {consistency_to_style_ref>=score, ip_scrub_pass: true, resolution>=target}
  animation: {foot_sliding<=thresh, interpenetration: none,
              retarget_clean: true, hero_requires_human: true}
  procedural: {deterministic_seed_logged: true, within_design_constraints: true}
  cross_cutting: {provenance_complete: true, license_compatible_with_risk_tier: true,
                  likeness_consent_present_if_required: true}
```

A failed gate (or risk_tier ≥ 2) routes to human finishing; a passed Tier-1 asset is auto-ingested.

---

## 8. Confidence & Fabrication Flags

- **HIGH confidence (primary-source verified):** USCO 2025 positions; Thaler ruling; Getty v.
  Stability UK ruling (Getty lost copyright); Steam Jan 2026 policy; Adobe Firefly indemnification;
  Suno/Udio settlements + Sony ongoing; SAG-AFTRA 2025 IMA (ICDR, consent); Substance 3D Sampler 4.4
  text-to-texture; FLUX.1 Kontext; Cascadeur 2025.2/.3/2026.1 AI features; Rokoko Vision free; UE5.7
  PCG production-ready; Houdini Engine free for UE/Unity; NVIDIA Meshtron; Gaea 3.0 USD; SpeedTree.
- **MEDIUM confidence (deep-research, partially cross-checked):** specific 3D-tool topology/PBR
  behaviors and polycount ranges (Tripo/Rodin/Hunyuan/Meshy); 3D licensing/resale nuances (verify each
  vendor ToS at integration time — fast-moving).
- **LOW confidence / DISCARDED:** The legal deep-research pass **fabricated** invented case names
  ("Nexus Interactive Terrain System," "Chronicles of Solara," "Rogers v. Suno"), specific dollar
  indemnification caps, a fake "September 2025 USCO policy statement," and console-policy specifics —
  **all discarded.** The **animation deep-research pass fabricated vendor product versions** ("Move.ai
  Studio Edition 4.2," "DeepMotion Action Studio 6.0," "MotionGen Pro 3.1," accuracy benchmarks,
  pricing) — **discarded; replaced with Tavily-verified facts only.** Treat any animation/legal number
  not in the HIGH-confidence list as unverified.

---

## 9. Open Questions / Risks

1. **Ownership vs autonomy tension:** the more autonomous the generation, the *less copyrightable* the
   output (US). How much human-in-the-loop is the minimum to secure IP on Tier-2/3 assets? (Needs legal review.)
2. **Indemnification coverage gap:** no vendor covers **training-data litigation** liability — only
   *output* infringement. Residual risk stays with the studio even for Firefly. Mitigation: prefer
   licensed/in-house models for hero/Tier-3.
3. **Hero-character autonomous quality** is the hardest unsolved bar — 3D + rig + animation + face all
   simultaneously. Likely human-led for the foreseeable horizon.
4. **AI music is legally frozen** for raw-generator AAA shipping; track Sony fair-use ruling (summer
   2026) and the UMG-Udio / Warner-Suno licensed platforms.
5. **Fast-moving versions:** 3D tools iterate monthly; re-verify versions, licensing, and indemnity at
   integration time, not from this snapshot.
6. **Engine-agnostic glue:** USD is the best spine, but rig/material standardization across UE/Unity/
   custom remains nontrivial integration work.
7. **Cleanup-cost economics:** the factory's ROI depends on *cleanup cost per asset class*. Tier-1 is
   clearly net-positive; Tier-3 may cost more in cleanup+legal than it saves. Needs measurement.

---

## 10. Sources

See YAML frontmatter `sources` for the full verified URL list. Primary authoritative sources
(copyright.gov, SAG-AFTRA, Getty newsroom, Adobe, Steam policy coverage, Music lawsuit trackers,
vendor changelogs) were used to override deep-research model output wherever they conflicted.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 6 | Deep multi-source synthesis: (1) text/img-to-3D mesh tools, (2) text-to-texture/PBR, (3) 2D concept art + consistency + IP, (4) AI animation/mocap/rigging, (5) procedural generation landscape, (6) IP/legal/licensing landscape. All HIGH/medium reasoning_effort. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no library-API question in scope) |
| Tavily tavily_search | 7 | **Cross-validation of every load-bearing legal/fast-moving claim:** USCO 2025 report, Getty v Stability outcome, Steam AI policy, Adobe Firefly indemnification, Suno/Udio lawsuits+settlements, SAG-AFTRA 2025 IMA, 3D-tool versions, Cascadeur/Move.ai/Rokoko, FLUX/Midjourney, Substance Sampler 4.4. |
| Tavily tavily_research | 0 | — |
| Tavily tavily_extract | 0 | — |
| Tavily tavily_crawl | 0 | — |
| WebFetch | 0 | — |
| WebSearch | 0 | — |
| Training data | ~2 areas | Only for well-known tool existence/format conventions (USD/FBX/GLB, ControlNet/LoRA mechanics) — flagged; no version numbers from training data. |

**Total MCP tool calls:** 13 (6 perplexity_research + 7 tavily_search)
**Training data reliance:** low — every fast-moving/legal claim cross-validated against primary web
sources; deep-research fabrications were detected via Tavily and explicitly discarded (see §8).
