---
document_type: research
vector: cinematics-virtual-production
version: "1.0"
status: draft
timestamp: 2026-06-08T00:00:00Z
producer: research-agent
project: game-factory (Dark Factory for AAA game development)
scope: >
  Cinematics, virtual production & performance capture for an engine-agnostic, lights-out
  AAA game factory. Covers cinematic types & pipeline; performance/facial capture & AI
  audio-driven lip-sync maturity; in-engine cinematic tooling per engine + an engine-agnostic
  cutscene/sequence schema (the analog of the narrative-graph); camera/cinematography
  automatability; virtual production realities. EXTENDS (does not duplicate): art-pipeline.md
  (animation/mocap §2.10), generative-asset-ai.md (AI animation/mocap §2.4, Audio2Face),
  narrative-worldbuilding-lore.md (cinematic-writer role §8), audio-discipline.md (VO/dialogue
  §1.3, SAG-AFTRA voice-consent gate §3.3), AAA-RECONCILIATION.md.
inputs:
  - planning/research/aaa/art-pipeline.md
  - planning/research/aaa/generative-asset-ai.md
  - planning/research/aaa/narrative-worldbuilding-lore.md
  - planning/research/aaa/audio-discipline.md
  - planning/research/aaa/AAA-RECONCILIATION.md
confidence_legend:
  VERIFIED: confirmed against a primary/official source (vendor docs, GitHub repo, engine docs), read directly this pass
  REPORTED: from a single secondary source or community knowledge; plausible, not independently confirmed
  UNVERIFIED: deep-research output that could NOT be primary-source-confirmed (esp. numeric stats); treat as hypothesis
sources:
  # Audio-driven facial / lip-sync (VERIFIED primary)
  - https://github.com/NVIDIA/Audio2Face-3D                                              # VERIFIED: repo, licenses (MIT SDK/UE/Maya plugins; Apache training; NVIDIA license NIM), outputs (mesh deform / joint / blendshape)
  - https://developer.nvidia.com/blog/nvidia-open-sources-audio2face-animation-model/    # VERIFIED: open-sourced 2025-09-24; UE5 plugin v2.5 (5.5/5.6), Maya plugin v2.0; offline + real-time; models regression v2.2 / diffusion v3.0
  - https://arxiv.org/abs/2508.16401                                                     # Audio2Face-3D technical paper (NVIDIA); ARKit blendshape decomposition
  - https://docs.nvidia.com/ace/ace-unreal-plugin/2.5/ace-unreal-plugin-animation.html   # ACE Unreal plugin: "Apply ACE Face Animations" node, ARKit-curve mapping to MetaHuman
  - https://developer.nvidia.com/ace-for-games                                           # NVIDIA ACE for Games (speech/intelligence/animation; on-device + cloud; NVIGI)
  - https://www.metahuman.com/releases/metahuman-5-7-is-now-available                    # VERIFIED: MetaHuman 5.7 shipped with UE 5.7 on 2025-11-12
  - https://dev.epicgames.com/documentation/metahuman/audio-driven-animation             # MetaHuman audio-driven animation (mood selection; Live Link real-time)
  - https://dev.epicgames.com/documentation/en-us/metahuman/metahuman-animator           # MetaHuman Animator (mono video / stereo HMC / audio; outputs MetaHuman facial-description curves ~ ARKit)
  - https://jaliresearch.com                                                             # VERIFIED (Tavily extract): JALI from audio+text+tags → editable animation curves; Maya 2020-2025 + UE5.0-5.6 + CLI; 12 language libraries; Cyberpunk 2077 (CDPR Dir. of Animation endorsement)
  - https://facewaretech.com/software/                                                   # VERIFIED (Tavily extract): Faceware = markerless VIDEO facial mocap (Studio real-time, Analyzer, Retargeter Maya/Max/MoBu plugin, Portal cloud, Shepherd) — NOT audio-driven
  - https://www.speech-graphics.com                                                      # VERIFIED (Tavily extract): SGX (production audio-to-face) + SG Com (runtime SDK, on-device) + Rapport; clients incl. Activision, PlayStation Studios, Naughty Dog (Last of Us Pt2), EA, WB Games, 343, Capcom, Bandai Namco
  # In-engine cinematic tooling (VERIFIED engine docs / primary)
  - https://docs.unity3d.com/Packages/com.unity.timeline@1.6/api/UnityEngine.Timeline.TimelineAsset.html  # VERIFIED: TimelineAsset is a PlayableAsset; TrackAsset houses clips (PlayableAssets); built-in MarkerTrack; SignalTrack/SignalEmitter→SignalReceiver
  - https://docs.unity3d.com/Packages/com.unity.cinemachine@2.3/                         # Cinemachine: virtual cameras, Body/Aim/Noise, Tracked Dolly, Group Composer, blends
  - https://dev.epicgames.com/documentation/unreal-engine/sequences-shots-and-takes-in-unreal-engine  # VERIFIED: Level Sequence; master sequence → Shots; possessables vs spawnables; camera-cut track; Take Recorder
  - https://docs.godotengine.org/en/stable/classes/class_animationplayer.html            # Godot AnimationPlayer (property/transform/method/audio tracks; Animation Libraries)
  - https://docs.godotengine.org/en/latest/tutorials/animation/animation_tree.html       # Godot AnimationTree (state machine + blending)
  - https://github.com/FEDE0D/godot-subtitles                                            # Godot community subtitle node (SRT → animation)
  - https://bevy.org/examples/animation/animation-graph/                                 # VERIFIED: Bevy native AnimationGraph (0.14+) — DAG of blend/add/clip nodes w/ weights (BLENDING, not sequencing)
  - https://docs.rs/bevy/latest/bevy/prelude/struct.AnimationGraph.html                  # Bevy AnimationGraph API
  - https://github.com/mbrea-c/bevy_animation_graph                                      # VERIFIED: 3rd-party bevy_animation_graph (state machines + graphical editor; alternative to bevy_animation)
  - https://crates.io/crates/bevy_tweening                                              # bevy_tweening (component/asset field tweening, easing, chaining) — event-driven, not timeline
  - https://github.com/bevyengine/bevy/issues/18159                                      # Bevy lacks a built-in Timeline/Sequencer-equivalent (community tracking)
  # Cross-engine / interchange
  - https://github.com/AcademySoftwareFoundation/OpenTimelineIO                          # VERIFIED: OTIO = editorial/EDL interchange (cut order, lengths, media refs); VFX/animation editorial — NOT real-time game cutscene runtime
  - https://opentimelineio.readthedocs.io/en/latest/                                     # OTIO docs
  - https://www.khronos.org/gltf/                                                        # glTF (animation channels; carries baked animation, not camera-cut/event sequencing)
  # Camera / cinematography automatability + virtual production
  - https://docs.unity3d.com/6000.4/Documentation/Manual/com.unity.cinemachine.html      # Cinemachine manual (procedural camera, composition rules)
provenance_note: >
  Written AFTER reading the project's repeated confabulation warnings (generative-asset-ai.md §8,
  audio-discipline.md methodology caveat, AAA-RECONCILIATION.md R-009): prior Perplexity
  sonar-deep-research passes FABRICATED case names, dollar figures, vendor product-version numbers,
  and named "standards." Accordingly, every load-bearing TOOL claim here (Audio2Face open-source
  date + license + output; MetaHuman 5.7 date + audio-driven capability; JALI Cyberpunk pipeline +
  language libraries + integration; Faceware vs Speech Graphics product nature; Unity Timeline /
  Unreal Sequencer / Godot / Bevy primitives; OpenTimelineIO scope) was verified DIRECTLY against
  its primary source via WebFetch / Tavily extract / official docs before being stated as fact.
  The deep-research procedural-CAMERA pass produced large amounts of confident PERCENTAGE STATISTICS
  ("92% correct framing," "30% time reduction," "65% of dialogue scenes," "<2% failure," "five
  critical roles") with NO traceable primary source — ALL such numbers are marked [UNVERIFIED] and
  must not be encoded as factory acceptance criteria. The substance that IS verifiable (which
  cinematography rules Cinemachine encodes; that LED-volume virtual production is physical/human-heavy)
  is retained and flagged accordingly.
---

# Cinematics, Virtual Production & Performance Capture — Research Report (Vector: cinematics-virtual-production)

> Scope: the cinematic discipline of AAA games — cutscenes, scripted sequences, in-engine
> cinematography, performance/facial capture, and audio-driven lip-sync — assessed for an
> engine-agnostic, lights-out factory. The keystone deliverable is an **engine-agnostic
> cutscene/sequence schema** (the cinematic analog of the narrative-graph) that the factory
> emits and per-engine adapters realize. EXTENDS the animation/mocap material in
> `art-pipeline.md §2.10` and `generative-asset-ai.md §2.4`, the VO/dialogue + SAG-AFTRA voice
> gate in `audio-discipline.md §1.3/§3.3`, and the `cinematic-writer` role in
> `narrative-worldbuilding-lore.md §8`. It does NOT re-derive the narrative-graph, dialogue-table,
> or asset-provenance machinery — it adds the *time-based staged-performance* layer above them.

---

## 1. Executive Summary

**Cinematics are a hybrid discipline whose pipeline cleanly bisects into a machine-orderable
"sequencing spine" the factory can generate and verify, and a "directed-performance shell" that
is human-craft — exactly the verifiable-spine / subjective-shell split the rest of the project
already uses.** The single most important factory insight is that **a cutscene is, structurally,
a time-keyed multi-track graph** (tracks of keyframes/clips over a shared timeline, with camera
cuts, events/signals, audio, and subtitles) — and that structure is **near-identical across every
engine's cutscene system** (Unity Timeline, Unreal Sequencer, Godot AnimationPlayer, Bevy's
nascent animation graph). That convergence makes a **portable `cutscene/sequence-graph` schema**
both achievable and the right keystone artifact — the direct cinematic analog of the
narrative-graph.

Key findings (all tool/date claims primary-source VERIFIED this pass; see §11):

- **Audio-driven facial animation / lip-sync has crossed into production-grade automation and is
  the single most AI-generatable cinematic sub-task today.** Three independently-verified pillars:
  (1) **NVIDIA Audio2Face-3D was open-sourced 2025-09-24** (MIT-licensed SDK + Unreal 5.5/5.6 and
  Maya plugins; models on Hugging Face; offline OR real-time; outputs blendshape weights / joint
  transforms / mesh deltas, mapping to ARKit/MetaHuman). (2) **Epic MetaHuman Animator** (shipped
  through **MetaHuman 5.7 / UE 5.7 on 2025-11-12**) generates facial animation from **audio alone**
  with mood selection, real-time via Live Link. (3) **JALI** (Cyberpunk 2077's system, verified
  from CDPR's Director of Animation) turns **audio + text + tags → editable animation curves** in
  **12 languages**, Maya + UE5 + CLI. A fourth verified pillar, **Speech Graphics (SGX + SG Com
  runtime SDK)**, ships across a large AAA client roster (Naughty Dog, Activision, PlayStation
  Studios, EA, WB Games, 343). **Verdict: lip-sync from audio is HIGH automatability — wrap, don't
  build.**

- **Procedural / rules-based CAMERA work is MEDIUM automatability** — the *encodable* grammar of
  cinematography (180-degree rule, rule of thirds, headroom, eyeline, shot-type selection, framing,
  collision avoidance, dolly paths, blends) is already industrialized in **Unity Cinemachine** and
  reproducible elsewhere. But **directed cinematography — shot choice for emotional subtext,
  intentional rule-breaking, performance-aware blocking — is human-craft.** (Deep-research's
  specific automation-success percentages are **[UNVERIFIED]** and excluded.)

- **Full directed cinematic PERFORMANCE remains human-craft (LOW).** Body mocap of a *lead*
  performance, the acting choices in a hero cutscene, the *direction* of a scene — these are the
  irreducible creative core, and they inherit `audio-discipline.md`'s **SAG-AFTRA voice/likeness
  consent gate** and `generative-asset-ai.md`'s hero-character quality gap (R-004/R-005).

- **Virtual production (LED volumes / ICVFX, real-time camera tracking via Mo-Sys/Stype/ncam) is
  PHYSICAL and HUMAN-HEAVY and is therefore OUT OF SCOPE for a software factory.** It is a
  *production-stage* discipline (stagecraft, tracking technicians, virtual-art-director) — the
  factory's relevant overlap is only the *virtual camera + real-time engine* half, which is already
  covered by the in-engine cinematic tooling. The factory **records VP as a delivery option, does
  not build it.**

- **There is no existing portable in-engine cutscene format.** OpenTimelineIO is **editorial/EDL
  interchange** (cut order, durations, media references for VFX/film editorial), NOT a runtime
  game-cutscene representation; glTF carries *baked* animation channels but no camera-cut / event /
  subtitle sequencing; USD has layered scene assembly but no game-grade cutscene-event model. **The
  factory must BUILD a `sequence-graph` schema and per-engine adapters** — the same wrap-the-runtime /
  build-the-contract pattern as `material.semantic` and `narrative-graph`.

**Factory implication:** WRAP the audio-to-face engines (Audio2Face-3D / MetaHuman Animator / JALI /
Speech Graphics), WRAP each engine's native sequencer at the adapter layer, and BUILD the
engine-agnostic `cutscene-spec` + `sequence-graph` schema, the `lip-sync-pipeline` contract, the
`camera-rules` profile (encodable cinematography), and the machine-checkable sequence validators.
The factory **auto-generates the sequencing spine and the lip-sync; it human-gates the directed
performance.**

---

## 2. Cinematic Types & The Cinematic Pipeline

### 2.1 Taxonomy of cinematic content (the factory's output surface)

Like `narrative-worldbuilding-lore.md`'s game-text taxonomy, cinematics tier sharply by volume,
stakes, and AI-tractability. (Tractability ratings are grounded in §3–§5 below.)

| Cinematic type | What it is | Typical volume | Stakes | AI-tractability |
|---|---|---|---|---|
| **Pre-rendered (FMV) cutscenes** | Offline-rendered video baked to a movie file | Low count, very high cost | Highest fidelity | **LOW** as directed film; the *render* is automatable, the *direction* is not |
| **Real-time / in-engine hero cutscenes** | Scripted, directed sequences played by the engine | Med, high impact | High (story payoff) | **LOW–MED** — sequencing automatable; performance human-led |
| **Scripted ambient / environmental sequences** | Background staged events, idles, set-piece triggers | High | Low–Med | **MED–HIGH** — templatable; camera + timing automatable |
| **Dialogue scenes (conversation cameras)** | Two/over-the-shoulder/group framing over VO lines | **Very high** (esp. RPG) | Med | **HIGH** — encodable shot grammar + audio-driven lip-sync; this is the volume tier |
| **Systemic / procedural cinematics** | Runtime-assembled (e.g. kill-cams, replay cams, emergent) | Very high | Low | **HIGH** — rule-driven camera, no hand-direction |
| **Quick-Time Events (QTEs)** | Cinematic with timed input prompts | Low–Med | Med | **MED** — the cinematic is a cutscene + input-window data; structurally a sequence with interaction markers |
| **Scripted in-game moments / banters** | Lightweight staged beats inside gameplay | High | Low | **HIGH** — event-track + bark (ties to `audio-discipline` barks, `narrative` dialogue) |

**Key insight (mirrors the narrative vector):** the factory's *volume* is overwhelmingly in the
HIGH-tractability tiers (dialogue cameras, ambient/systemic sequences), and those are exactly where
audio-driven lip-sync + encodable camera grammar do the most work. **Hero directed cutscenes are
low-volume / high-stakes and stay human-led.**

### 2.2 The cinematic pipeline (stage breakdown)

Standard AAA cinematic production decomposes into well-defined stages, each with a deliverable and
an automatability rating (🟢 headless-automatable · 🟡 tool-assisted/human-directed · 🔴 human-craft).
This is the cinematic analog of `art-pipeline.md §2`.

| Stage | Deliverable | Automatability | Notes |
|---|---|---|---|
| **Script / beat → cinematic-spec** | Scene intent, beats, characters, location, dialogue refs | 🔴 authored → 🟢 captured | Owned by `cinematic-writer` (narrative §8); factory captures it as machine-readable `cinematic-spec` |
| **Previz / blocking** | Rough staging, camera blocking, timing | 🟡 | Rule-based first-pass automatable; directed blocking human. Deep-research AI-previz claims = [UNVERIFIED] |
| **Layout** | Final character/prop/camera placement in scene | 🟡 | Constraint-solvable for conversation/ambient; hero layout human |
| **Performance / animation** | Body + facial animation on rigs | 🔴 hero / 🟡 secondary | Body mocap of *lead* = human-craft; lip-sync = 🟢 (see §3) |
| **Cinematography (cameras)** | Camera cuts, moves, framing | 🟡 | Encodable grammar 🟢 (§5); directed shot choice 🔴 |
| **Staging / lighting** | Cinematic lighting, mood | 🟡 | Cinematic lighting is art-directed (ties to `art-pipeline` lighting); presets automatable |
| **Editing** | Shot order, timing, cut rhythm | 🟡 | Mechanical assembly automatable; cut *rhythm* is craft |
| **Audio / VO / lip-sync** | Dialogue, music sync, lip-sync | 🟢 sync / 🔴 performance | Lip-sync 🟢 (§3); VO performance human + SAG gate (`audio §3.3`) |
| **Subtitles / loc** | Timed captions per language | 🟢 | Ties to `narrative` loc-string-contract; timing automatable |
| **Integration / bake** | Sequence wired into engine, gameplay transitions | 🟢 | Adapter realizes the `sequence-graph` per engine |

**The bisection:** the *sequencing, assembly, lip-sync, subtitle-timing, camera-grammar, and
integration* stages are automatable (🟢/🟡); the *directed performance, cinematic lighting mood,
cut rhythm, and hero shot-choice* stages are human-craft (🔴). The factory owns the former and
human-gates the latter — recorded as a **`cinematic-directed` human-review flag**, parallel to the
playtest-satisfaction and audio-director gates.

---

## 3. Performance & Facial Capture + AI Lip-Sync (Maturity)

This is the most consequential and most AI-tractable part of the vector. All claims below were
primary-source-verified this pass (the deep-research narrative around them was confirmed, trimmed,
and corrected against vendor sources).

### 3.1 The two capture modalities

- **Body mocap** — optical (Vicon/OptiTrack) / inertial (Xsens) / markerless (Move.ai, Rokoko
  Vision). Already covered in `art-pipeline.md §2.10` and `generative-asset-ai.md §2.4`: markerless
  capture has collapsed the cost of locomotion/background motion (🟡 automatable with cleanup), but
  **lead cinematic performance capture is human-craft** (🔴). **This vector does not re-derive that.**
- **Facial capture** — split into two distinct sub-modalities that matter enormously for the factory:
  - **Video/marker-driven facial mocap** (performance-captured from an actor's face) — **human
    performance required**, factory wraps the solver. **Faceware** [VERIFIED]: markerless *video*
    facial mocap — *Studio* (real-time from live/recorded video), *Analyzer* (video → motion data),
    *Retargeter* (Maya/3ds Max/MotionBuilder plugin), *Portal* (AI cloud). **MetaHuman Animator** also
    supports video paths (stereo HMC / mono video from phone/webcam). These need an actor → 🔴/🟡.
  - **Audio-driven facial animation (AI lip-sync)** — generates the face **from the audio (and
    optionally text) alone, no actor** — this is the **🟢 AI-generatable breakthrough.**

### 3.2 Audio-driven lip-sync tool maturity (VERIFIED)

| Tool | Vendor | Input | Output (VERIFIED) | Real-time? | Engine/DCC integration | License / status | Maturity |
|---|---|---|---|---|---|---|---|
| **Audio2Face-3D** | NVIDIA | Audio (+emotion) | Blendshape weights / joint transforms / direct mesh deltas; maps to **ARKit / MetaHuman** | **Both** (offline + real-time stream) | **UE5 plugin v2.5 (5.5/5.6); Maya plugin v2.0; C++ SDK; NIM** | **Open-sourced 2025-09-24; MIT (SDK/UE/Maya); Apache (training); models on HF (regression v2.2, diffusion v3.0)** | **A — wrap** |
| **MetaHuman Animator** | Epic | **Audio alone**, OR mono video, OR stereo HMC | MetaHuman facial-description curves (≈ ARKit); mood selection (neutral/happy/sad/anger/etc.) | **Yes** (Live Link real-time; offline higher-fidelity) | Native Unreal; Live Link Face (iOS + Android); iPad USB-C external cam (5.7) | **Free w/ UE; MetaHuman 5.7 shipped 2025-11-12 w/ UE 5.7** | **A — wrap (UE-bound)** |
| **JALI** | JALI Research | **Audio + text + tags (or TTS)** | **Editable animation curves** (lip + jaw + tongue + brow + emotion) | Offline (authoring) | **Maya 2020-2025; UE 5.0-5.6 plugins; CLI** | Commercial license; **12 language libraries** | **A — wrap; AAA-proven (Cyberpunk 2077)** |
| **Speech Graphics — SGX** | Speech Graphics | Audio alone | Lip-sync + full nonverbal facial behavior | Offline (production) | Production pipeline | Commercial; **AAA roster: Naughty Dog, Activision, PlayStation Studios, EA, WB Games, 343, Capcom** | **A — wrap** |
| **Speech Graphics — SG Com** | Speech Graphics | Audio alone | Same, **runtime, on any device** | **Yes (runtime SDK)** | Engine-embeddable SDK | Commercial | **A — wrap (runtime)** |

**Cross-tool convergence (the factory-critical fact):** the de-facto output standard is **ARKit's
52 facial blendshapes** (and the MetaHuman facial-description curve set that aligns to it).
Audio2Face-3D, MetaHuman Animator, and ARKit-driven rigs all converge on this. **This means the
factory's lip-sync pipeline can target a single canonical facial-curve representation (ARKit-52 /
MetaHuman) and let adapters drive each engine's rig** — exactly analogous to glTF being the
canonical mesh contract.

### 3.3 Verdict on AI-generatability of facial/lip-sync

- **HIGH (🟢, wrap):** lip-sync and basic emotional facial animation **from audio (+text)** for
  dialogue scenes, ambient NPCs, systemic barks, and localized VO across many languages. This is the
  factory's biggest cinematic automation win — it directly automates the per-line facial animation
  that, at AAA volume (tens of thousands of lines), is otherwise enormous manual labor. JALI's
  Cyberpunk 2077 use ("expressive multilingual speech at unprecedented scale") is the proof point.
- **MED (🟡):** emotional *nuance* and *performance intent* on hero lines — the tools give a strong
  first pass with mood controls, but a hero cutscene's micro-expression acting is refined by humans.
  (MetaHuman's own docs note real-time mode lacks blinks/some head motion vs offline — a documented
  limitation, not marketing.)
- **LOW (🔴):** the *directed performance* of a lead character in a signature cinematic — body acting,
  timing, the actor's intent — stays human, and **any AI voice/likeness of a real performer is gated
  by SAG-AFTRA 2025 IMA + state right-of-publicity law** (inherit `audio-discipline.md §3.3`,
  R-004). Audio-driven *face* generated from a **synthetic or consented** voice is fine; cloning a
  real performer's *face* from their likeness without consent is the same gate as voice.

---

## 4. In-Engine Cinematic Tooling (per engine) + Engine-Agnostic Cutscene Schema

### 4.1 Per-engine cutscene systems (VERIFIED against engine docs)

| Engine | Cutscene system | Core primitives (VERIFIED) | Camera system | Data representation |
|---|---|---|---|---|
| **Unity** | **Timeline + Cinemachine** | `TimelineAsset` (a `PlayableAsset`) → `TrackAsset`s → clips (PlayableAssets); track types: **Animation, Audio, Activation, Control, Signal**; built-in **MarkerTrack**; **SignalTrack** with `SignalEmitter`→`SignalReceiver` for events | **Cinemachine**: virtual cameras (Body/Aim/Noise), Tracked Dolly (splines), **Group Composer**, blends; Cinemachine track in Timeline = camera cuts | Serialized Unity asset (`.playable`); references, not baked |
| **Unreal** | **Sequencer (Level Sequence) + Take Recorder** | Master `Level Sequence` → **Shots** (sub-sequences); object bindings as **possessables** (exist in level) vs **spawnables** (created for the sequence); per-object property tracks + keyframes; **camera-cut track** | Cine Camera Actors (focal length/aperture/DoF); camera-cut track selects active camera; spline camera moves; camera bind/attach | `.uasset` (Level Sequence); references objects/assets |
| **Godot 4** | **AnimationPlayer (+ AnimationTree)** — general-purpose, no dedicated cinematic tool | `AnimationPlayer` holds Animations = keyframe tracks over **any node property/transform**; **Call-Method tracks** (trigger script methods = events); **Audio tracks**; **Animation Libraries** (reuse); `AnimationTree` = state machine + blending for branching | No dedicated cinematic camera system; cameras animated as ordinary nodes via AnimationPlayer | Godot scene/resource (`.tscn`/`.res`); subtitles via community SRT plugin |
| **Bevy** | **No built-in sequencer/Timeline equivalent** (community-tracked gap) | **Native `AnimationGraph` (0.14+)**: DAG of **clip/blend/add** nodes with weights — for **blending, NOT timeline sequencing**; 3rd-party **`bevy_animation_graph`** adds state machines + a graphical editor; **`bevy_tweening`** = event-driven field tweening (no visual timeline) | No Cinemachine-equivalent; camera = ordinary ECS entity, animated/tweened manually | ECS components; no canonical cutscene asset |

### 4.2 The cross-engine convergence (why a portable schema works)

Despite different names, **the primitive set is the same everywhere** (this is the core finding):

| Universal cutscene primitive | Unity | Unreal | Godot | Bevy |
|---|---|---|---|---|
| **Timeline / playhead** | Timeline | Level Sequence | Animation length | (manual, via systems) |
| **Tracks** | TrackAsset | Sequencer tracks | AnimationPlayer tracks | (graph nodes / tweens) |
| **Keyframed property animation** | Animation track | property track | property/transform track | clip nodes |
| **Camera cuts** | Cinemachine track | camera-cut track | animated Camera node | manual |
| **Events / signals** | SignalEmitter→Receiver | event track / notifies | **Call-Method track** | event-driven (manual) |
| **Audio sync** | Audio track | audio track | Audio track | manual |
| **Object activation** | Activation track | spawnable lifecycle | visibility track | spawn/despawn systems |
| **Subtitles** | (custom) | (custom) | community SRT plugin | manual |

> **Caveat (VERIFIED):** Unity, Unreal, and Godot ship mature, equivalent-power systems. **Bevy is
> the outlier** — it has *blending* (AnimationGraph) but **no native timeline/sequencer**; the
> factory's Bevy adapter must **build a runtime sequence-player** that interprets the `sequence-graph`
> (driving tweens/animation-graph/ECS systems from the schema). This exactly parallels the
> Bevy-native-audio gap noted in `audio-discipline.md §2.4` and the determinism-tier outlier framing
> in AAA-RECONCILIATION — Bevy is the high-build adapter; Unity/Godot/Unreal are mostly wrap.

### 4.3 No existing portable cutscene format (VERIFIED) → BUILD the schema

- **OpenTimelineIO** [VERIFIED] is **editorial/EDL interchange** — cut order, clip durations,
  references to external media, for *film/VFX editorial* hand-off (FCP XML, AAF, CMX-3600 EDL). It
  is explicitly **not a media container and not a runtime evaluation model**. It can usefully
  represent the **editorial cut structure** of a cinematic (shot order/timing) but carries **no
  camera, no per-property animation evaluation, no engine events**. *Useful as an editorial
  sub-layer of the schema; not a substitute for it.*
- **glTF** carries baked animation channels (node TRS, morph weights) — it can deliver *baked*
  facial/body animation, but has **no camera-cut, event/signal, audio, or subtitle sequencing**.
- **USD** offers layered scene assembly + variants (pipeline backbone per `art-pipeline.md §4`) but
  **no game-grade cutscene-event/camera-cut model**.

**Conclusion:** as with shaders (`material.semantic`) and dialogue (`narrative-graph`), **there is no
portable runtime cinematic standard to wrap — the factory must BUILD a `sequence-graph` schema**
and per-engine adapters that realize it. OTIO is wrapped *inside* the schema for the editorial layer;
glTF is wrapped for baked-animation payloads.

### 4.4 The engine-agnostic `sequence-graph` schema (recommendation)

The cinematic analog of the narrative-graph: a **declarative, time-keyed, multi-track sequence
document** with stable IDs, that adapters compile to Timeline / Sequencer / AnimationPlayer / a Bevy
runtime player.

```yaml
sequence-graph:                    # one cutscene / scripted sequence
  id: uuid                         # stable content-addressable ID
  duration: seconds                # or frame count + fps
  fps: 30                          # authoring frame rate
  bindings:                        # logical actors/props/cameras → engine objects (possessable|spawnable)
    - { ref: "char.protagonist", kind: possessable, asset: <id> }
    - { ref: "cam.main",         kind: spawnable,   type: cine_camera }
  tracks:
    - track: { id, target_ref, type: animation }     # keyframed property/transform/skeletal anim (glTF payload or clip ref)
        clips: [ { start, end, anim_ref, blend_in, blend_out } ]
    - track: { type: camera_cut }                     # which camera is live when
        cuts: [ { start, end, camera_ref, shot_type, framing_rule_ref } ]   # shot_type/framing → camera-rules (§5)
    - track: { type: facial_lipsync }                 # audio-driven face (§3): canonical ARKit-52 / MetaHuman curves
        clips: [ { start, audio_ref, line_id, lipsync_source: audio2face|metahuman|jali|sg|baked, emotion } ]
    - track: { type: audio }                          # VO/music/SFX (ties to audio-discipline dialogue-table line IDs)
        clips: [ { start, audio_ref, line_id, bus } ]
    - track: { type: subtitle }                       # timed captions (ties to narrative loc-string-contract IDs)
        clips: [ { start, end, loc_key } ]
    - track: { type: event }                          # signals/method-calls/notifies (Unity Signal / Godot Call-Method / UE notify)
        markers: [ { time, event_id, params } ]
    - track: { type: activation }                     # show/hide / spawn / despawn
        spans: [ { ref, start, end } ]
    - track: { type: interaction }                    # QTE windows: input prompt + accept window + branch
        markers: [ { start, end, prompt, on_success, on_fail } ]
  transitions:                     # gameplay↔cinematic enter/exit (camera hand-off, state save/restore)
    enter: { blend, gameplay_state_capture }
    exit:  { blend, gameplay_state_restore, branch_on: event_id|null }
  directed: false                  # true = hero/human-directed (human-review gate flag)
```

Design rules (carried from the narrative-graph + material.semantic precedents):
1. **Stable IDs on every binding/track/clip** so adapters and validators can resolve references and
   renames don't break the sequence.
2. **Logical refs, not engine objects** — `bindings` map logical actors/cameras to each engine's
   possessable/spawnable model at adapter time.
3. **Canonical facial representation = ARKit-52 / MetaHuman curves** (§3.2) so lip-sync is portable.
4. **Audio/subtitle clips reference `dialogue-table` line IDs and `loc-string-contract` keys** —
   single source of truth shared with the audio and narrative vectors (no duplication).
5. **`directed` flag** routes hero cutscenes to the human-review gate; non-directed
   (dialogue/ambient/systemic) sequences auto-generate and auto-validate.

---

## 5. Camera Systems & Cinematography Automatability

### 5.1 The encodable grammar of cinematography (VERIFIED as Cinemachine features)

A real, bounded set of cinematography rules is **mathematically encodable** and already shipped in
Unity Cinemachine (and reproducible in any engine via the `camera-rules` profile):

| Rule | Encodable? | How (VERIFIED in Cinemachine) |
|---|---|---|
| **180-degree rule** | 🟢 Yes | Geometric constraint: keep camera on one side of the subject-axis |
| **Rule of thirds / framing** | 🟢 Yes | Framing offsets place subject in compositional zones (Framing Transposer / Composer) |
| **Headroom** | 🟢 Yes | Vertical-offset constraint |
| **Eyeline matching** | 🟢 Yes | Aim-at-target with consistent gaze across reversals |
| **Screen direction** | 🟢 Yes | Track subject orientation/motion vectors; generate reversals |
| **Shot types** (CU/MS/WS/OTS/two-shot) | 🟢 Yes | Distance/FOV presets + Group Composer for multi-subject |
| **Camera moves** (dolly/pan/tilt/zoom) | 🟢 Yes | Tracked Dolly along splines; keyframed FOV/transform |
| **Collision avoidance / occlusion** | 🟢 Yes | Raycast-based camera repositioning |
| **Blends / cuts** | 🟢 Yes | Priority-based virtual-camera blends with curves |

**This is the `camera-rules` artifact:** a declarative profile of encodable rules + shot-type
library that the camera-grammar generator uses to auto-place conversation/ambient/systemic cameras,
and that adapters compile to Cinemachine (Unity) or equivalent constraint logic (other engines).

### 5.2 What is NOT automatable (human-craft)

- **Directed shot choice for emotional subtext** — *which* of several "technically correct" shots
  serves the scene's emotion; when to break the rules (off-center for unease, crossed eyelines for
  disconnection). This requires narrative-context understanding that is human-craft.
- **Cut rhythm / pacing** — the *timing* of cuts to build tension is editorial craft.
- **Cinematic lighting mood** — art-directed (ties to `art-pipeline` lighting).
- **Performance-aware blocking** of a hero scene.

> **[UNVERIFIED] flag:** the deep-research camera pass asserted many precise success-rate statistics
> ("92% objectively-correct framing," "63% narratively-appropriate shot selection," "30% time
> reduction," "65% of conventional dialogue scenes," "<2% / <1% failure rates," "five critical VP
> roles," "fully-automated camera moves <20% of shots"). **None of these traced to a primary source;
> all are excluded as load-bearing facts** and must not become factory acceptance thresholds. The
> *directional* claim they support — encodable rules automate well, directed choice does not — is
> sound and corroborated by Cinemachine's own documented feature set, but the numbers are not.

### 5.3 Procedural-camera / AI-cinematography research (status: emerging, not production)

Academic work exists on **automatic cinematography** (toric-space camera models, camera-on-rails
optimization, ML shot-prediction from film corpora) and **script-to-shot-list / blocking** via LLMs.
[REPORTED, not production-verified] — these are research-grade, not adopted production tools, and the
deep-research pass's specifics here are unverifiable. **Factory stance: treat AI shot-list/blocking
as an *assist* research bet, not a v1 capability; the encodable Cinemachine-grammar path is the
verifiable automation.**

---

## 6. Virtual Production (LED Volumes, Camera Tracking) — Explicitly Out of Scope

Virtual production (ICVFX on LED volumes; real-time camera tracking via **Mo-Sys / Stype / ncam**;
virtual-art-director, tracking technicians, on-set real-time TDs) is a **physical, stagecraft,
human-heavy production discipline.** [REPORTED — vendor/industry consensus; deep-research's specific
staffing percentages are [UNVERIFIED].] A *software* factory cannot perform on-set camera operation,
LED-wall calibration, or physical tracking.

**The only factory-relevant overlap** is the *virtual* half — the real-time engine rendering the
virtual environment and the *virtual camera* — and that is **already covered by the in-engine
cinematic tooling (§4) and camera grammar (§5).** The factory therefore:
- **Records "virtual production / LED volume" as a delivery/target context** (a project profile
  flag), not a built capability.
- **OUT OF SCOPE:** LED-volume orchestration, physical camera tracking, on-set hardware. (Consistent
  with AAA-RECONCILIATION's exclusion of console devkit/cert-lab physical access.)

---

## 7. Automatable vs Human (consolidated)

| Cinematic work | Verdict | Mode |
|---|---|---|
| Audio-driven lip-sync (dialogue/ambient/barks, multilingual) | **🟢 HIGH** | generate via wrapped engine (A2F/MetaHuman/JALI/SG) → canonical ARKit curves → adapter |
| Subtitle/caption timing | **🟢 HIGH** | generate from VO + loc-string-contract |
| Conversation / ambient / systemic camera placement | **🟢 HIGH** | camera-rules grammar → adapter (Cinemachine etc.) |
| Cutscene assembly / sequencing / integration | **🟢 HIGH** | sequence-graph → per-engine adapter |
| Camera moves on rails, blends, cuts (mechanical) | **🟡 MED** | rule/spline-driven; directed rhythm human |
| Previz / blocking (first-pass) | **🟡 MED** | rule-based first pass; directed blocking human |
| Secondary-character facial nuance | **🟡 MED** | audio-driven + light human polish |
| Body mocap of lead performance | **🔴 LOW** | human performance (+ SAG gate); factory wraps solver/cleanup |
| Directed hero cutscene (shot choice, cut rhythm, acting) | **🔴 LOW** | human-led; `directed: true` review gate |
| Cinematic lighting mood | **🔴 LOW** | art-directed |
| Virtual production (LED/tracking) | **OUT OF SCOPE** | physical/human; recorded as target context only |

---

## 8. Genre Variation

Cinematic *load* varies enormously by genre even though the `sequence-graph` shape is constant.
(Extends the genre matrices in the design, narrative, and audio vectors.)

| Genre | Cinematic load | Dominant cinematic types | Lip-sync need | Camera automation fit |
|---|---|---|---|---|
| **Narrative RPG** (Witcher/BG3-like) | Massive | Hero cutscenes + huge dialogue-camera volume | **Very high** (multilingual, tens of thousands of lines → JALI/A2F class) | High for dialogue cams; hero cutscenes human-directed |
| **Cinematic action/adventure** (Naughty Dog-like) | Very high, hero-heavy | Pre-rendered-quality real-time hero cutscenes, set-pieces, QTEs | High; hero performance human (Speech Graphics-tier) | Medium; signature direction human |
| **Open-world** | High volume, lower per-scene | Ambient/systemic + dialogue cameras | High (volume) | High (systemic/conversation) |
| **Competitive multiplayer / MOBA** | Low | Intros, kill-cams, replay cameras, victory screens | Low | **High** — systemic/procedural cameras dominate |
| **Fighting** | Low–Med | Intro/win cinematics, super-move cams | Low–Med | High (canned, rule-driven) |
| **Deterministic-sim PILOT** (factory/automation, roguelike, det-RTS) | **Low** | Brief intros/outros, event stingers, replay/spectator cameras | **Low–none** (little VO) | **High** — minimal directed cinematics; mostly systemic/replay cameras |

**Pilot fit (reinforces AAA-RECONCILIATION §11):** the deterministic-sim pilot has the **smallest
cinematic surface** — minimal directed cutscenes, little/no VO-driven lip-sync, mostly
systemic/replay cameras. It proves the `sequence-graph` + `camera-rules` + adapter loop end-to-end
with almost **no human-directed-performance shell** — the cleanest possible first proof of the
cinematic vector, just as it is for the design/narrative/audio vectors.

---

## 9. Factory Artifacts / Contracts (net-new)

These extend, and do not duplicate, the narrative-graph / dialogue-table / asset-provenance /
art-bible contracts already defined in the prior vectors.

1. **`cinematic-spec`** — per-cinematic intent: scene, beats, characters/props/cameras involved,
   location ref, dialogue-line refs (→ `dialogue-table`), cinematic type (§2.1), `directed` flag,
   target engines. Authored by `cinematic-writer` (narrative §8), captured machine-readable. *Source
   of truth for the sequence below.*

2. **`sequence-graph.schema`** (THE KEYSTONE — §4.4) — the engine-agnostic, time-keyed, multi-track
   cutscene document (bindings, animation/camera-cut/facial-lipsync/audio/subtitle/event/activation/
   interaction tracks, gameplay transitions). Stable IDs; logical refs; ARKit-canonical facial
   curves; references dialogue-table + loc-string IDs. **Build; adapters realize it per engine
   (Timeline / Sequencer / AnimationPlayer / Bevy runtime player).** OTIO wrapped as editorial
   sub-layer; glTF wrapped for baked-animation payloads.

3. **`lip-sync-pipeline.contract`** — declarative: per audio line → facial-curve generation via a
   wrapped engine (`audio2face | metahuman | jali | speech_graphics | baked`), targeting the
   **canonical ARKit-52 / MetaHuman curve set**, with emotion/mood, language, and **provenance +
   likeness-consent fields** (inherits `asset-provenance-sidecar` + SAG-AFTRA gate from
   generative-asset-ai §7.2 / audio §3.3). Adapter applies curves to each engine's facial rig.

4. **`camera-rules.profile`** (§5.1) — declarative encodable-cinematography profile: shot-type
   library, framing/headroom/180-rule/eyeline/screen-direction constraints, blend defaults; drives
   the camera-grammar generator for conversation/ambient/systemic cameras; compiles to Cinemachine
   (Unity) / constraint logic (other engines).

5. **`sequence-validation.report`** — machine-checkable cinematic gates (§10).

6. **(shared, not new)** — references `dialogue-table` (audio), `loc-string-contract` (narrative),
   `asset-provenance-sidecar` (gen-AI), `art-bible.spec` lighting (art). No duplication.

**Wrap vs build:**
- **WRAP:** the audio-to-face engines (Audio2Face-3D, MetaHuman Animator, JALI, Speech Graphics
  SGX/SG Com); each engine's native sequencer + camera system *at the adapter layer* (Timeline+
  Cinemachine, Sequencer+Take Recorder, Godot AnimationPlayer+AnimationTree); OTIO for editorial;
  glTF for baked animation.
- **BUILD:** the `cinematic-spec` + `sequence-graph` schema, the `lip-sync-pipeline` contract + the
  canonical ARKit-curve representation + per-engine facial-rig adapters, the `camera-rules` profile +
  camera-grammar generator, the sequence validators, and — critically — **a Bevy runtime sequence
  player** (Bevy has no native sequencer).

---

## 10. AAA Acceptance Bar

A cinematic deliverable is "AAA-ready" when:

**Machine-checkable gates (🟢 — factory-enforced):**
- **Sequence integrity** — every `sequence-graph` binding/track/clip ref resolves; no dangling
  actor/camera/audio/loc references; clips within `[0, duration]`; no overlapping camera-cuts.
- **Lip-sync coverage** — every VO line in the sequence has facial curves generated (or explicitly
  marked silent); curves conform to the canonical ARKit-52/MetaHuman set.
- **Subtitle/loc coverage** — every spoken line has a timed caption per target language; no overflow
  (ties to narrative pseudo-loc / loc-string-contract).
- **Camera-rules conformance** — auto-placed cameras satisfy the declared `camera-rules` profile
  (180-rule, headroom, eyeline) for non-directed sequences.
- **Audio sync** — lip-sync/subtitle/event tracks aligned to audio within tolerance; loudness via
  `audio-discipline` conformance.
- **Gameplay transition validity** — enter/exit blends present; gameplay-state capture/restore
  declared; no softlock on cutscene skip/branch.
- **Provenance/consent** — facial/voice assets carry provenance sidecar; likeness-consent-ref present
  for any real-performer likeness (SAG-AFTRA gate).
- **Adapter realizability** — the sequence-graph compiles cleanly on every target engine adapter
  (incl. Bevy runtime player).

**Human-review gates (🔴 — flagged when `directed: true`):**
- Directed shot choice / cut rhythm "lands" (a `cinematic-directed` human gate, parallel to the
  playtest-satisfaction and audio-director gates — never auto-scored).
- Hero facial/body performance reads emotionally.
- Cinematic lighting mood is on-art-direction.

Recommended gate design: two-tier — automated sequence/lip-sync/camera-rules/coverage validator
(hard pass/fail), then a **human cinematic-director sign-off only on `directed` sequences**. The
automated tier is fully buildable from the sequence-graph; the craft tier stays human-in-loop and is
narrow (hero cutscenes only).

---

## 11. Open Questions & Risks

1. **[UNVERIFIED] camera-automation statistics.** The deep-research camera pass produced confident
   success-rate percentages with no traceable source. *Risk:* encoding them as acceptance thresholds.
   *Mitigation:* excluded; camera-rules conformance is gated on *rule satisfaction* (geometry), not
   on fabricated "narrative-appropriateness scores."
2. **Bevy cinematic gap is real and is a BUILD cost.** Bevy has blending (AnimationGraph) but **no
   native timeline/sequencer** (community-tracked). *Risk:* the Bevy adapter is the highest-effort
   cinematic adapter (must build a runtime sequence player). *Mitigation:* this parallels Bevy's
   native-audio and determinism-tier outlier status — pilot on Bevy proves the schema *can* drive a
   from-scratch player; Unity/Godot/Unreal are mostly wrap.
3. **Lip-sync engine lock-in / licensing.** Audio2Face-3D is MIT/open (low risk); JALI and Speech
   Graphics are commercial per-title licenses; MetaHuman Animator is UE-bound. *Risk:* per-game
   license cost + engine coupling (mirrors the audio-middleware OQ-003 in AAA-RECONCILIATION).
   *Mitigation:* canonical ARKit-curve representation decouples the *pipeline* from any one engine;
   Audio2Face-3D is the open default; others are pluggable sources. **Re-verify versions/licenses at
   integration time** (R-009 confabulation discipline).
4. **Hero directed performance is the irreducible human core.** Body acting + emotional nuance +
   cut rhythm in a signature cutscene won't autonomously hit the AAA bar (parallels hero-character
   R-005). *Mitigation:* `directed` flag + narrow human gate; factory auto-generates everything else.
5. **SAG-AFTRA / likeness consent extends to FACE, not just voice.** Audio-driven *face* from a
   consented/synthetic voice is fine; an AI face matching a real performer's likeness is gated.
   *Mitigation:* likeness-consent-ref on facial assets; inherit audio §3.3 / R-004 gate.
6. **No portable runtime cutscene standard exists** (OTIO is editorial-only; glTF/USD don't sequence
   events/cameras). *Risk:* a "single portable cutscene file" is not wrappable. *Mitigation:* BUILD
   the schema; this is real engineering (like material.semantic), not a wrap.
7. **Virtual production is physical and out of scope** but studios may *expect* it. *Mitigation:*
   record LED-volume/VP as a target *context* flag; explicitly OUT OF SCOPE as a built capability.
8. **Procedural AI cinematography (shot-list/blocking from script) is research-grade, not
   production.** *Mitigation:* assist-only research bet; encodable Cinemachine grammar is the
   verifiable v1 path.

---

## 12. Sources

See YAML frontmatter `sources`. Primary-verified anchors (read directly this pass):
- **Audio-driven lip-sync [VERIFIED]:** NVIDIA Audio2Face-3D GitHub repo (licenses, outputs) + NVIDIA
  open-source blog (2025-09-24 date, UE5 v2.5 / Maya v2.0 plugins, offline+real-time, model versions);
  ACE Unreal-plugin animation docs (ARKit-curve → MetaHuman); MetaHuman 5.7 release page (2025-11-12)
  + audio-driven-animation docs; JALI Research site (Tavily extract: audio+text+tags→curves, Maya/UE5/
  CLI, 12 languages, Cyberpunk 2077 + CDPR Dir.-of-Animation endorsement); Faceware site (Tavily
  extract: video markerless mocap — Studio/Analyzer/Retargeter/Portal); Speech Graphics site (Tavily
  extract: SGX production + SG Com runtime SDK; AAA client roster).
- **In-engine tooling [VERIFIED]:** Unity Timeline `TimelineAsset`/`TrackAsset` API (PlayableAsset,
  MarkerTrack, SignalTrack→SignalReceiver) + Cinemachine docs; Unreal Sequencer "Sequences, Shots and
  Takes" docs (Level Sequence, Shots, possessable/spawnable, camera-cut, Take Recorder); Godot
  AnimationPlayer + AnimationTree class docs (Call-Method track) + community subtitle node; Bevy
  native AnimationGraph example/API (0.14+ blend/add/clip DAG) + bevy_animation_graph repo +
  bevy_tweening + Bevy issue #18159 (no native sequencer).
- **Interchange [VERIFIED]:** OpenTimelineIO GitHub/docs (editorial/EDL interchange, not runtime);
  glTF (Khronos) baked-animation channels.
- **Camera/cinematography [partly VERIFIED, stats UNVERIFIED]:** Cinemachine manual (encodable rules:
  180/thirds/headroom/eyeline/Group Composer/Tracked Dolly/blends/collision). All success-rate
  PERCENTAGES from deep research = **[UNVERIFIED], excluded.** Academic automatic-cinematography +
  virtual-production framing = **[REPORTED]**, not production-verified.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep multi-source synthesis: (1) audio-driven facial/lip-sync tool landscape (A2F/ACE, MetaHuman Animator, JALI, Faceware, Speech Graphics); (2) per-engine in-engine cinematic tooling + cross-engine cutscene interchange; (3) procedural-camera / AI-cinematography / virtual-production automatability. All `reasoning_effort: high`, `strip_thinking: true`. **NOTE:** the camera pass produced unsourced success-rate statistics — treated as leads to FLAG, not facts. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no single-library API question in scope; engine docs verified via WebFetch/search) |
| Tavily tavily_extract | 3 | Direct primary-source extraction: jaliresearch.com (input/output, platforms, languages, Cyberpunk endorsement); facewaretech.com/software (product nature = video mocap); speech-graphics.com (SGX/SG Com + AAA client roster). |
| Tavily tavily_search | 0 | — |
| WebFetch | 3 | Primary verification: NVIDIA Audio2Face-3D GitHub (licenses, outputs, integrations); NVIDIA open-source blog (date, plugin versions, modes, model versions); MetaHuman audio-driven docs (attempted; ToC-only → fell back to WebSearch on metahuman.com release page). |
| WebSearch | 5 | Verified: MetaHuman 5.7 release (2025-11-12, audio-driven, Live Link iOS/Android); bevy_animation_graph (state machines + editor); Bevy native AnimationGraph (0.14 blend/add/clip DAG); OpenTimelineIO scope (editorial/EDL, not runtime); Unity Timeline asset model (TimelineAsset/TrackAsset/MarkerTrack/Signal). |
| Training data | ~1 area | Cinematic pipeline-stage taxonomy + cinematography-rule names (180-rule, eyeline, etc.) — well-established craft, used only to structure §2/§5; each rule anchored to Cinemachine's documented feature set where it bears weight. |

**Total MCP tool calls:** 6 (3 perplexity_research + 3 tavily_extract) + 3 WebFetch + 5 WebSearch =
14 external retrievals; **≥1 perplexity_research satisfies the PRIMARY-TOOL mandate.**
**Training data reliance:** low — every load-bearing tool/date/output/integration claim was verified
DIRECTLY against its primary source (GitHub repos, vendor sites, engine docs) per the project's
explicit prior-confabulation discipline; the deep-research camera pass's unsourced statistics were
detected and marked **[UNVERIFIED]**; framework/taxonomy is the only training-data contribution.
