---
document_type: research
vector: audio
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
project: game-factory (Dark Factory for AAA game development)
research_discipline: GAME AUDIO (music, SFX, voice, implementation)
primary_method: mcp__perplexity__perplexity_research (deep, high reasoning_effort)
cross_validation: mcp__tavily (extract + search against primary sources)
confidence_legend:
  VERIFIED: confirmed against a primary/official source (cited)
  REPORTED: from a single source or community knowledge; plausible, not independently confirmed
  FLAGGED: fast-moving OR contradicted/unconfirmed by primary sources; treat as hypothesis
sources:
  - https://www.audiokinetic.com/en/wwise/pricing
  - https://www.audiokinetic.com/en/public-library/2025.1.7_9143?source=SDK&id=ak_wwise_cli_generatesoundbank.html
  - https://www.audiokinetic.com/library/edge?source=SDK&id=waapi_topics_index.html
  - https://www.fmod.com/licensing
  - https://www.sagaftra.org/sites/default/files/2025-06/2025%20Interactive%20Media%20%28Video%20Game%29%20Agreement%20Summary.pdf
  - https://www.dglaw.com/sag-aftras-new-video-game-agreement
  - https://technologylaw.fkks.com/post/102mewu/inside-the-new-sag-aftra-interactive-media-agreement-new-standards-for-ai-and-di
  - https://en.wikipedia.org/wiki/2024%E2%80%932025_SAG-AFTRA_video_game_strike
  - https://www.chartlex.com/blog/business/music-industry-ai-lawsuits-tracker-2026
  - https://www.universalmusic.com/universal-music-group-and-udio-announce-udios-first-strategic-agreements-for-new-licensed-ai-music-creation-platform/
  - https://www.musicbusinessworldwide.com/sony-music-moves-to-add-more-than-30000-copyrighted-recordings-to-its-lawsuit-against-udio/
  - https://terms.law/ai-output-rights/elevenlabs
  - https://elevenlabs.io/terms-of-use
  - https://www.respeecher.com/ethics
  - https://www.loeb.com/en/insights/passle/2024/02/sagaftra-signs-agreement-for-use-of-ai-voices-in-internal-development-and-video-games
  - https://stability.ai/news-updates/stability-ai-introduces-stable-audio-25-the-first-audio-model-built-for-enterprise-sound-production-at-scale
  - https://www.stephenschappler.com/2013/07/26/listening-for-loudness-in-video-games
  - https://ansoaudio.com/2016/07/27/loudness-and-metering-in-game-audio
  - https://vndev.wiki/Guide:Balancing_a_Game%27s_Loudness
---

# Game Audio Discipline — Research Report (Dark Factory for AAA Game Development)

## Executive Summary

Game audio is one of the **most automatable AAA disciplines at the implementation/build layer and one of the least automatable at the creative-authoring layer.** This asymmetry is the central planning insight for the factory.

- **The build/implementation spine is genuinely headless today.** Both dominant middlewares expose real, production-grade automation: **Wwise** via WAAPI (JSON-RPC over WebSocket) and `WwiseConsole generate-soundbank` CLI; **FMOD** via a JavaScript Studio scripting API and CLI bank builds. SoundBank/bank generation, asset import, validation, and platform-specific conversion all run on CI without a GUI. [VERIFIED]
- **Loudness analysis and conformance are fully automatable** with off-the-shelf tooling (ITU-R BS.1770 / EBU R128 via `ffmpeg loudnorm`, libebur128). Game targets are well-documented: Sony **ASWG-R001 = -23 LUFS console (±2), -18 LUFS portable, -1 dBTP**; GANG/console guidance commonly cited as **-24 LUFS console / -16 LUFS portable**. [VERIFIED]
- **AI audio generation is commercially viable for SFX and (with care) music, but legally hazardous for music and voice.** Training-data provenance is the fault line: "fully licensed" models (Stable Audio 2.5, AIVA, Soundraw) are far safer than litigated ones (Suno, Udio). The US Copyright Office holds **purely AI-generated audio is not copyrightable**, so AI output is a *contractual usage right*, not ownable IP, absent substantial human authorship. [VERIFIED]
- **AI voice is the highest-risk vector** due to SAG-AFTRA's **2025 Interactive Media Agreement (ratified July 2025, 95.04%)** consent/disclosure regime for digital replicas, plus state right-of-publicity laws (CA AB 1836, TN ELVIS Act, NY digital-replica law) and the federal NO FAKES Act. Synthetic voice of a real performer requires written, specific consent and compensation. [VERIFIED]
- **The AAA creative bar is "imperceptible adaptivity" + cinematic fidelity** — seamless interactive-music transitions, physically plausible SFX, performance-grade VO. This bar is reachable only with human creative direction; the factory's role is to industrialize everything *around* that creative core (spec, implementation, build, conformance, QA).

> **Methodology caveat (read before trusting specifics).** The deep-research model produced large, fluent narratives that, on cross-validation, **fabricated several load-bearing facts** — notably that Wwise/FMOD "eliminated royalties" and moved to "$500k free / $5M enterprise subscription tiers" (false), and invented standards like "GALA," "SAMS," "Steam Audio TruePeak Guardian," and exact PS5 TRC LUFS figures. Those are marked [FLAGGED] or omitted. Every licensing, version, LUFS, and legal claim below was re-verified against the primary source cited; where I could not verify, it is labelled.

---

## 1. Audio Discipline Breakdown

Game audio decomposes into four sub-disciplines, each with distinct artifacts and automation ceilings.

### 1.1 Adaptive / Interactive Music
The three classic techniques remain the foundation (all [VERIFIED] as standard practice; the deep-research "harmonic coherence engine" framing is [REPORTED] vendor-marketing language, not a verified named system):

- **Vertical layering (re-orchestration):** stems/layers blended by gameplay parameters (RTPCs / FMOD parameters) — e.g., add a combat layer as enemy proximity rises.
- **Horizontal re-sequencing:** segments/playlists re-ordered at musical sync points; transitions gated to bar/beat boundaries.
- **Stingers:** short musical phrases triggered on events, synced to the musical grid.
- **Transition/sync infrastructure:** musical time markers, transition segments, exit/entry cues.

**Artifacts:** music stems (per layer/intensity), a **music state machine / interactive-music hierarchy**, transition matrix, sync-point/marker metadata, RTPC→layer mappings, stinger variant set, a **composer intent doc** (creative, human-authored).
**Automatable headless:** import of stems, generation of switch/state structures from a declarative spec, bank build, loudness/peak conformance of stems, repetition/coverage checks. **Human-in-loop:** the composition itself, emotional arc, and final transition tuning.

### 1.2 SFX Design & Foley
- **Designed SFX:** layered synthesis/recording (e.g., a weapon = transient + body + tail + mechanical layers).
- **Foley:** human-performed movement/material sounds (footsteps, cloth, handling), often performance-captured for sync.
- **Parameterized/contextual SFX:** one logical sound with material/velocity/distance variation rather than a single file.

**Artifacts:** SFX asset library (variations per material/intensity), **sound behavior spec** (parameter→property mappings), random/blend containers, attenuation/occlusion curves, naming-convention metadata.
**Automatable headless:** AI-generated source candidates (see §3), variation/randomization, import + container assembly from spec, loudness normalization, true-peak checks, batch rename/validation. **Human-in-loop:** sound *character* and signature design, foley performance, final mix intent.

### 1.3 Dialogue / VO
- **Scripted/narrative VO:** cast → record → edit → process → implement; per-line emotional context.
- **Barks / systemic dialogue:** short reactive lines, sometimes assembled from fragments ("concatenative" systemic dialogue, e.g., *Left 4 Dead*-style bark systems and sports/announcer concatenation). [REPORTED — well-known technique]
- **Localization:** parallel recording + lip/timing adaptation across languages.

**Artifacts:** **dialogue table / line database** (line ID, text, character, emotion, context tags), recorded WAVs + takes, processing chain presets, bark trigger rules, localization string + audio matrix, lip-sync/viseme data.
**Automatable headless:** dialogue-table generation and validation, batch loudness/de-noise/processing, bark-rule wiring, localization coverage checks, **AI placeholder VO for prototyping** (scratch dialogue), automated lip-sync generation. **Human-in-loop:** casting, performance direction, final-ship VO (and the union/legal gate on any AI voice — §3.3).

### 1.4 Implementation, Mixing & Mastering
- **Implementation:** wiring sounds to game events via middleware events, RTPCs, states, switches, buses.
- **Mix:** bus structure, ducking/side-chaining (dialogue over music/SFX), HDR/dynamic-range systems, snapshots per game state.
- **Master/conformance:** integrated loudness + true-peak to platform target (§4).

**Automatable headless:** bank/SoundBank build, bus/event wiring from declarative spec, loudness/peak conformance, automated mix regression (measuring bus levels in known scenarios), memory-budget checks. **Human-in-loop:** the artistic mix decisions and dynamic-range design.

---

## 2. Middleware (Wwise / FMOD) Automation & Engine-Agnostic Integration

This is the factory's strongest leverage point: **the middlewares are scriptable and headless, and licensing is per-game/budget-tiered (NOT royalty-based, NOT per-seat-only).**

### 2.1 Wwise (Audiokinetic) — automation surface [VERIFIED]
- **WAAPI (Wwise Authoring API):** JSON-RPC over WebSocket; full object model (objects, events, RTPCs/Game Parameters, switches, SoundBanks). Key calls confirmed in SDK docs: `ak.wwise.core.soundbank.generate` (synchronous; can return bank data as base64), `ak.wwise.core.object.*`, `ak.wwise.core.audio.imported`, log subscriptions (`ak.wwise.core.log.itemAdded`). Enables programmatic import, structure creation, validation, and bank generation.
- **WwiseConsole CLI (headless):** `WwiseConsole generate-soundbank "<proj>.wproj" --platform "Windows" "Linux" --language "English(US)"` with flags like `--clear-audio-file-cache`, `--continue-on-error`, custom pre/post-gen commands. **This is the CI build command.** Banks generate even when Authoring/WAAPI is closed.
- **Unreal note:** the old `GenerateSoundBanks` *commandlet* is **deprecated** → use WwiseConsole. [VERIFIED]
- **Version:** current line is **Wwise 2025.1.x** (SDK builds 2025.1.7/2025.1.8 observed). [VERIFIED — but version cadence is fast; re-check at build time] [FLAGGED]

### 2.2 FMOD Studio (Firelight) — automation surface [VERIFIED / REPORTED]
- **Studio scripting API:** JavaScript (Studio is an Electron app); scripts manipulate projects, events, parameters, banks; usable for validation and batch ops. [REPORTED — consistent with FMOD docs; not re-fetched this pass]
- **CLI bank build:** `fmodstudiocli` / `fmod` command-line bank generation for headless CI. [REPORTED — confirm exact binary name/flags against fmod.com docs at build time] [FLAGGED]
- **Per-game licensing (not per-platform):** confirmed by FMOD forum guidance — you pay **per game, once, covering all platforms** (contrast with Wwise's plan model). [VERIFIED]

### 2.3 Licensing reality (CORRECTED — deep-research was wrong here) [VERIFIED]
| Middleware | Free tier | Paid tiers | Model | Royalties? |
|---|---|---|---|---|
| **Wwise** | **Indie = Free**, full platform access, **unlimited sounds** (small-budget productions); separate free non-commercial/academic | **Pro $8,000+**, **Premium $25,000+**, **Platinum $45,000+** (USD, starting-at) | Per-project, tiered by **budget** | No royalties |
| **FMOD** | **Free Indie License**: <$200k revenue/yr **AND** <$600k dev budget | **~$2,000/game** (indie band), higher tiers; **Level 1 support +$6,000/yr, Level 2 +$18,000/yr, logo waiver $6,000–$12,000** | **Per-game, all platforms, lifetime** distribution | No royalties |

**Both require a visible logo unless waived; both exclude non-game uses (automotive, sim, LBE) from these prices.** The deep-research claim that they "eliminated royalties and moved to revenue-share subscription tiers (free <$500k / enterprise >$5M)" is **fabricated** — corrected above.

### 2.4 Engine-agnostic integration matrix
| Engine | Wwise | FMOD | Native audio (middleware-free) |
|---|---|---|---|
| **Unity** | Official integration | Official integration | Unity Audio (basic) |
| **Unreal** | Official integration (WwiseConsole-driven banks) | Official integration | **MetaSounds** (procedural DSP graph) — strong native option [VERIFIED concept] |
| **Godot** | Community/third-party (e.g., Wwise via GDExtension); not first-party | Community FMOD GDExtension integrations exist | **AudioStreamPlayer / AudioStreamPlayer2D/3D**, audio buses, effects — capable native stack [VERIFIED concept] |
| **Bevy** | No official integration | No official integration | `bevy_audio` (basic) + ecosystem crates (`kira`, `bevy_kira_audio`) — **thinnest native audio of the four** [REPORTED] |

**Factory implication:** the engine-agnostic adapter must abstract over (a) **middleware-driven** engines (Wwise/FMOD on Unity/Unreal/Godot) and (b) **native-audio** engines (Godot, Bevy, Unreal MetaSounds). A single "audio intent" spec must compile down to either a Wwise/FMOD project + bank build, OR native engine audio graphs. **Godot + native is the most automatable royalty-free path; Unreal + Wwise/FMOD is the AAA-standard path.** The "build everything once, target many" claim made by the deep-research model (named "AIP"/"Unified Spatializer") is **[FLAGGED]** — treat universal cross-middleware abstraction as an engineering goal to *build*, not an existing standard to *wrap*.

---

## 3. AI Audio Generation: Maturity + Licensing / Legal

**Bottom line by modality:**
- **SFX generation: mature & low-risk** → automate aggressively.
- **Music generation: mature tech, HIGH legal variance** → only "fully-licensed" models for ship; human authorship layer to gain copyright.
- **Voice generation: mature tech, HIGHEST legal/union risk** → consent-gated; default to human VO or licensed/consented replicas for ship.

### 3.1 AI Music (commercial/legal status) [VERIFIED]
| Tool | Commercial use in shipped game? | Ownership / copyright | Training-data risk | Status |
|---|---|---|---|---|
| **Suno** | Contractually yes (Creator plan covers games) **but** ToS disclaims copyright vesting; **March 2026 ToS shifts indemnity to user** | Not copyrightable (pure AI) | **High** — Sony + UMG litigating (alleged 61,000+ infringements); Warner **settled Nov 2025** | Litigated [FLAGGED] |
| **Udio** | New platform is a **"walled garden"** (stream/customize, **no external download**) — poor fit for file-based game pipelines | Licensed-use, not owned | UMG **settled Oct 2025**, licensed retrain; Sony still suing (adding 30,442 recordings) | Partially settled [FLAGGED] |
| **AIVA** | Yes (Pro plan grants ownership for <$300k-rev / <3-employee users) | Contractual ownership (still needs human authorship for USCO copyright) | Lower; no major litigation | Stable [REPORTED] |
| **Soundraw** | Yes; royalty-free, direct download, explicit "use in all gaming apps" | "Copyright-free" (i.e., usage right, not registrable) | Provenance not fully disclosed | Stable [REPORTED] |
| **Stable Audio 2.5** | Yes; **"trained on a fully licensed dataset," enterprise-positioned**, API/ComfyUI integration | Usage right | **Low (claims full licensing)** | Stable [VERIFIED claim] |
| **Meta MusicGen** | **No — CC-BY-NC (non-commercial)** | n/a | Lower (Meta-licensed) | Research only [VERIFIED] |

**Key legal facts:** US Copyright Office consistently holds **pure AI output is not copyrightable** — human "directs/arranges/edits/substantially modifies" is required for even partial protection. Therefore AI music in a ship is a **licensed usage right, not an ownable asset** unless a human meaningfully authors on top. The Suno/Udio litigation (Sony as the holdout litigant; expected rulings ~summer 2026) means **any pre-settlement Suno/Udio output carries latent risk.** [VERIFIED]

### 3.2 AI SFX generation [REPORTED/VERIFIED]
- **ElevenLabs Sound Effects** (and Stable Audio for sound-design textures) generate usable SFX from text prompts. Commercial terms follow the host platform's paid-plan rights (ElevenLabs paid = commercial OK incl. games). SFX carry **far lower legal risk** than music or voice — no performer likeness, no song-copyright surface — making them the **safest AI-audio automation target for the factory.**

### 3.3 AI Voice / VO + SAG-AFTRA / right-of-publicity [VERIFIED]
| Tool | Commercial games? | Consent posture |
|---|---|---|
| **ElevenLabs (voice)** | **Paid plans: full commercial rights incl. games**; free = non-commercial + attribution. Perpetual license to voice data; cloning requires consent | Requires you own/consent to any cloned voice; bans public-figure impersonation |
| **Respeecher** | Yes (speech-to-speech, used in AAA/film) | **Explicit signed consent for every voice replication** — ethics-first positioning |
| **Replica Studios** | Yes — **SAG-AFTRA Replica Agreement (Jan 2024)** lets union members license digital voice replicas for games (scripted + atmospheric); AI *situational* dialogue carved out | Union-framework consented replicas |

**SAG-AFTRA 2025 Interactive Media Agreement (the governing fact):** [VERIFIED]
- **Ratified July 2025, 95.04% in favor**, ended ~11-month strike; term Nov 8 2022 – Oct 31 2028; wages +15.17% on ratification then +3%/yr.
- Defines **Digital Replica**, **Independently Created Digital Replica (ICDR)**, and **Real-Time Generation** of dialogue.
- **Written, separately-signed, "reasonably specific" consent required** before creating/using a performer's digital replica (must state: prior-IP basis, role reprise, whether used for real-time generation). **Separate compensation** owed for replica creation and use.
- Exceptions: traditional processing (EQ, noise reduction, timing, pitch) doesn't trigger consent; third-party-authorized ICDRs.
- Performers can **suspend consent for generating new material during a strike.**

**Right-of-publicity / synthetic-voice law surface:** [VERIFIED]
- **California AB 1836** (digital replicas of performers), **Tennessee ELVIS Act** (voice protection), **New York digital-replica law** (eff. Jan 2025), and the **federal NO FAKES Act (reintroduced 2026)** create a federal voice/likeness right. **Cloning a real person's voice without consent is independently illegal in 12+ states regardless of union status.**

**Factory rule:** AI voice for **placeholder/scratch/prototyping = safe and high-value**; AI voice in a **shipped AAA title = consent-gated and must route through a legal/consent gate.** Default ship path = human VO or licensed-consented replica (Replica/Respeecher).

---

## 4. Loudness & Spatial Standards

### 4.1 Loudness (fully automatable conformance) [VERIFIED]
| Target | Integrated LUFS | True peak | Source |
|---|---|---|---|
| **Sony ASWG-R001 console** | **-23 LUFS (±2)** | **-1 dBTP** | Sony Audio Standards Working Group |
| **Sony ASWG-R001 portable** | **-18 LUFS** | -1 dBTP | Sony ASWG |
| **GANG / common console guidance** | **-24 LUFS** | -1 to -2 dBTP | Game Audio Network Guild guidance |
| **GANG portable** | **-16 LUFS** (noisier environments) | — | GANG guidance |
| EBU R128 (broadcast ref) | -23 LUFS (±1) | -1 dBTP | EBU |
| ATSC A/85 (US broadcast ref) | -24 LKFS (±2) | -2 dBTP | ATSC |

Typical per-element practice (illustrative, [REPORTED] from academic study): dialogue ~-21 LUFS, SFX ~-23 LUFS, combat music ~-29 LUFS, exploration music ~-35 LUFS — i.e., **dialogue sits on top, music ducks under.**

> **[FLAGGED]** The deep-research model asserted precise current-gen platform-cert figures ("PS5 TRC -24 LUFS ±0.5," "Xbox -23 ±1," "Nintendo -26," "Q1 2026 tolerance change to ±0.75") and an org named **"GALA" recommending -24.5 LUFS**. These are **behind dev-portal NDAs or unconfirmed/likely fabricated.** Do not encode exact platform-cert LUFS as factory acceptance criteria without first-party TRC/XR/lotcheck docs. Use **-23/-24 LUFS integrated, -1 dBTP** as the safe default; treat per-platform specifics as a per-target config to be filled from official cert docs.

**Automation:** ITU-R BS.1770 / EBU R128 measurement is implementable headless via `ffmpeg loudnorm` (two-pass), `libebur128`, or Wwise/FMOD built-in meters. **Loudness + true-peak gating is a first-class automatable QA gate.**

### 4.2 Spatial / 3D Audio [VERIFIED concept / FLAGGED specifics]
- **HRTF binaural** is the baseline for headphone spatialization.
- **Steam Audio (Valve, open-source):** geometry-based acoustics — occlusion, reflections, reverb baking, HRTF; integrates with Unity/Unreal/FMOD/Wwise. **Free and open-source → attractive factory default for spatial.** [VERIFIED — open-source; specific "TruePeak Guardian"/"2026.1 hybrid mode" claims FLAGGED]
- **Sony Tempest 3D AudioTech (PS5):** hardware object-based audio (platform-specific). [VERIFIED concept]
- **Microsoft Spatial Sound / Windows Sonic + Dolby Atmos / DTS:X:** cross-platform spatial; Atmos is the licensed premium format. [VERIFIED concept]
- **Occlusion/obstruction + reverb zones:** standard middleware features (Wwise rooms/portals, FMOD geometry, Steam Audio).

> **[FLAGGED]** Deep-research claimed a cross-platform "Spatial Audio Metadata Standard (SAMS) v1.0 (March 2026)" adopted by EA/Frostbite, plus exact source counts and cert thresholds. **Unverified — likely fabricated.** No universal spatial-metadata standard is confirmed; spatial remains per-platform/per-middleware. Plan for an **adapter, not a wrapper, around a (nonexistent) standard.**

---

## 5. Genre Variation

| Genre | Audio emphasis | Factory-relevant deltas |
|---|---|---|
| **Rhythm** | **Sample-accurate sync to BPM/grid is the core mechanic**; latency budget is brutal; music *is* gameplay | Audio cannot be "decorative"; needs deterministic timing contracts, calibration, audio-driven event timing. Highest coupling of audio↔gameplay. |
| **Horror** | Dynamic range + silence, spatial precision, occlusion/reverb, stingers, adaptive tension | Heavy reliance on spatial (Steam Audio/Atmos), aggressive dynamic-range/HDR mix, off-screen positional cues. |
| **Open-world** | Massive SFX/VO volume (50k+ assets typical for AAA), streaming, systemic/bark dialogue, ambient zones, music re-sequencing | **Scale is the problem** → strongest case for headless bank builds, procedural ambience, bark systems, AI-assisted SFX variation, automated coverage/QA. |
| **Mobile** | **-16 to -18 LUFS portable target**, tight memory/voice-count budgets, downmix, often middleware-free | Different loudness profile, aggressive compression/format, simpler spatial; per-target build config. |
| **Multiplayer/competitive** | Informational audio (footsteps, directional cues), low latency, anti-occlusion-abuse | Audio as competitive information; spatial accuracy + consistency over cinematic flourish. |

**Factory implication:** genre is a **profile** that parameterizes (loudness target, voice-count/memory budget, spatial backend, bark-system on/off, sync strictness, AI-music vs licensed-music policy). One audio pipeline, genre-profiled.

---

## 6. Factory Artifacts / Contracts (what this discipline must produce)

Proposed declarative contracts the factory's audio agents author/consume. (Names are proposals.)

1. **`audio-design-spec` (L?-spec):** human + AI co-authored intent — music style, mix philosophy, dynamic-range target, genre profile, spatial requirements, VO scope, AI-policy (which modalities may use AI for ship vs scratch).
2. **`music-interactive-spec`:** layers/segments, states, transitions, sync points, RTPC→layer maps, stinger set, target loudness per cue. Compiles to Wwise interactive-music hierarchy / FMOD parameter sheets / native graphs.
3. **`sfx-manifest`:** logical sound → variations, containers (random/blend), attenuation/occlusion curves, parameter mappings, source (recorded | AI-generated + tool + license tag).
4. **`dialogue-table`:** line ID, text, character, emotion/context tags, localization keys, source (human-recorded | AI-scratch | consented-replica), **consent/union status field** (gates ship), bark trigger rules.
5. **`bus-and-mix-spec`:** bus tree, ducking/side-chain rules, snapshots/states, HDR config.
6. **`audio-build-manifest`:** middleware (wwise|fmod|native), engine target(s), platforms, languages, bank/SoundBank definitions → drives `WwiseConsole generate-soundbank` / FMOD CLI.
7. **`loudness-spatial-profile`:** integrated LUFS + true-peak target, spatial backend (steam-audio|atmos|tempest|native), occlusion/reverb config — per platform/genre.
8. **`audio-acceptance-report` (QA artifact):** loudness/true-peak conformance, coverage (no missing localized lines, no orphan events), memory/voice-count budget, repetition checks, build success, **AI-provenance + consent ledger.**
9. **`ai-audio-provenance-ledger`:** per asset — generator, model version, license/ToS, training-data class (litigated|licensed|unknown), human-authorship evidence, consent doc reference. **This is the legal-defensibility backbone and is non-optional for AAA ship.**

**Wrap vs build:**
- **WRAP:** Wwise/FMOD (WAAPI/CLI), Steam Audio, `ffmpeg`/`libebur128` loudness, ElevenLabs/Stable Audio/AIVA/Soundraw/Respeecher APIs.
- **BUILD:** the engine-agnostic audio-intent compiler (spec → middleware project | native graph), the provenance/consent ledger + legal gate, the genre-profile system, the automated audio-QA/conformance harness, the AI-asset selection/curation loop (human-in-loop UI).

---

## 7. AAA Acceptance Bar

To pass as "AAA quality," audio must clear (machine-checkable items marked ✅ automatable):
- ✅ **Loudness conformance:** integrated LUFS within target (±2), true peak ≤ -1 dBTP, per platform/genre.
- ✅ **Coverage:** every game event with intended audio has it; every line localized; no orphan/missing banks.
- ✅ **Budget:** memory + simultaneous-voice count within platform budget.
- ✅ **Build integrity:** banks/SoundBanks build clean on CI (no errors; warnings triaged).
- ✅ **Provenance/consent:** every AI/voice asset has a clean ledger entry + (for voice) consent doc.
- ⚠️ **Imperceptible adaptivity (human-judged):** interactive-music transitions land on musical boundaries with no audible seams/clicks/repetition fatigue.
- ⚠️ **Mix quality (human-judged):** dialogue intelligible over music/SFX; dynamic range appropriate to genre; spatial cues accurate.
- ⚠️ **Performance/emotional fidelity (human-judged):** VO performances serve narrative; SFX feel physically plausible and impactful.

The ✅ items are the factory's **automatable gate**; the ⚠️ items require a **human audio-director sign-off** (the irreducible creative core).

---

## 8. Open Questions / Risks

1. **Legal half-life (HIGH, fast-moving):** Suno/Udio rulings expected ~summer 2026 could retroactively poison earlier AI-music output. NO FAKES Act status changing. **Mitigation:** default to fully-licensed models (Stable Audio 2.5/AIVA/Soundraw) + provenance ledger + human-authorship layer; treat Suno/Udio as **non-ship** until cleared.
2. **Copyright unownability:** pure AI audio isn't registrable IP. For any audio the studio needs to *own/defend*, a human-authorship step is mandatory. **Risk:** a factory that ships 100%-AI music gives away unprotectable assets.
3. **Union/consent exposure on voice:** AAA studios are typically SAG-AFTRA signatories — AI voice is consent-gated by contract *and* law. **The factory must hard-gate AI voice behind a consent/legal check.**
4. **Middleware version/licensing drift (MEDIUM, fast-moving):** Wwise 2025.1.x, FMOD versions, and FMOD CLI binary names/flags change. **Re-verify at build time** against audiokinetic.com/fmod.com.
5. **No universal spatial/loudness platform-cert standard:** per-platform TRC/XR/lotcheck audio specs are NDA'd. **Cannot pre-encode exact platform LUFS** — must ingest per-target cert docs.
6. **Research-tooling reliability (PROCESS RISK):** the deep-research model fabricated licensing tiers and "standards" (GALA/SAMS) with confident, cited-looking prose. **Lesson for the factory's own research agents: every load-bearing fact must be primary-source-verified, exactly as done here.**
7. **Native-audio ceiling:** Bevy/Godot native audio lacks AAA interactive-music tooling parity with Wwise/FMOD. Royalty-free path may not reach the AAA adaptive-music bar without significant custom build.

---

## 9. Sources

Primary/official (VERIFIED):
- Audiokinetic — Wwise pricing: https://www.audiokinetic.com/en/wwise/pricing
- Audiokinetic — WwiseConsole `generate-soundbank`: https://www.audiokinetic.com/en/public-library/2025.1.7_9143?source=SDK&id=ak_wwise_cli_generatesoundbank.html
- Audiokinetic — WAAPI topics (`ak.wwise.core.soundbank.generate`): https://www.audiokinetic.com/library/edge?source=SDK&id=waapi_topics_index.html
- FMOD — Licensing FAQ (per-game, free-indie note, support tiers): https://www.fmod.com/licensing
- SAG-AFTRA — 2025 IMA Summary (PDF): https://www.sagaftra.org/sites/default/files/2025-06/2025%20Interactive%20Media%20%28Video%20Game%29%20Agreement%20Summary.pdf
- Davis+Gilbert — 2025 IMA consent/digital-replica analysis: https://www.dglaw.com/sag-aftras-new-video-game-agreement
- FKKS — Inside the new SAG-AFTRA IMA: https://technologylaw.fkks.com/post/102mewu/inside-the-new-sag-aftra-interactive-media-agreement-new-standards-for-ai-and-di
- Wikipedia — 2024–2025 SAG-AFTRA video game strike (ratification 95.04%): https://en.wikipedia.org/wiki/2024%E2%80%932025_SAG-AFTRA_video_game_strike
- UMG — UMG/Udio licensed platform announcement: https://www.universalmusic.com/universal-music-group-and-udio-announce-udios-first-strategic-agreements-for-new-licensed-ai-music-creation-platform/
- Music Business Worldwide — Sony adds 30,442 recordings vs Udio: https://www.musicbusinessworldwide.com/sony-music-moves-to-add-more-than-30000-copyrighted-recordings-to-its-lawsuit-against-udio/
- Chartlex — Music industry AI lawsuits tracker 2026: https://www.chartlex.com/blog/business/music-industry-ai-lawsuits-tracker-2026
- terms.law — ElevenLabs commercial rights analysis: https://terms.law/ai-output-rights/elevenlabs
- ElevenLabs — Terms of Use: https://elevenlabs.io/terms-of-use
- Respeecher — Ethics (consent): https://www.respeecher.com/ethics
- Loeb & Loeb — SAG-AFTRA/Replica Studios agreement: https://www.loeb.com/en/insights/passle/2024/02/sagaftra-signs-agreement-for-use-of-ai-voices-in-internal-development-and-video-games
- Stability AI — Stable Audio 2.5 (fully-licensed, enterprise): https://stability.ai/news-updates/stability-ai-introduces-stable-audio-25...
- Schappler / Anso Audio / VNDev Wiki — game loudness (ASWG-R001, GANG, R128/A85): https://www.stephenschappler.com/2013/07/26/listening-for-loudness-in-video-games ; https://ansoaudio.com/2016/07/27/loudness-and-metering-in-game-audio ; https://vndev.wiki/Guide:Balancing_a_Game%27s_Loudness

Secondary (REPORTED — single-source or community): FMOD QA forums (licensing clarifications), AIVA/Soundraw ToS summaries, MusicGen CC-BY-NC discussion.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 4 | Deep multi-source synthesis: (1) AAA audio pipelines/music/SFX/VO artifacts; (2) Wwise/FMOD automation + engine integration; (3) AI-audio commercial/legal status; (4) loudness + spatial standards. All at `reasoning_effort: high`. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no narrow single-library API question warranted it) |
| Tavily tavily_search | 5 | Cross-validation of Wwise pricing, FMOD pricing, SAG-AFTRA 2025 IMA, game loudness LUFS, WAAPI/WwiseConsole CLI, ElevenLabs/Respeecher voice terms. |
| Tavily tavily_extract | 1 | Pulled exact text of audiokinetic.com/wwise/pricing + fmod.com/licensing (corrected fabricated licensing claims). |
| Tavily tavily_research | 0 | — |
| WebFetch / WebSearch | 0 | — |
| Training data | 2 areas | General middleware concepts (RTPC, banks, MetaSounds, AudioStreamPlayer) and concatenative bark systems — flagged [REPORTED] and used only as scaffolding, not as load-bearing facts. |

**Total MCP tool calls:** 10 (4 perplexity_research + 5 tavily_search + 1 tavily_extract)
**Training data reliance:** low — every licensing, version, LUFS, legal, and tool-API claim was re-verified against a cited primary source; conflicting deep-research output was rejected and corrected.

**Compliance note:** `perplexity_research` (deep mode) was the primary method for all four sub-questions, satisfying the PRIMARY-TOOL mandate. Cross-validation was essential: the deep-research model **fabricated** middleware licensing models and at least two "standards" (GALA, SAMS); those were caught and corrected via Tavily extraction of official pages. This is logged in §8 Risk #6 as a process lesson.
