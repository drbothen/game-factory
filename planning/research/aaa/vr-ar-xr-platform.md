---
document_type: research
vector: vr-ar-xr-platform
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory — engine-agnostic lights-out Dark Factory for AAA game development that must SHIP games; core principle = NO LOCK-IN via adapter protocols"
inputs:
  - planning/research/aaa/engineering-disciplines.md
  - planning/research/aaa/qa-testing-liveops.md
  - planning/research/aaa/online-services-platform-distribution.md
  - planning/research/aaa/AAA-RECONCILIATION.md
  - planning/research/bevy-capabilities.md
  - planning/research/unity-capabilities.md
  - planning/research/godot-capabilities.md
  - .factory/specs/product-brief.md
  - planning/design/engine-adapter-protocol.md
sources:
  # OpenXR standard / conformance (primary, WebFetch-verified)
  - "Khronos OpenXR overview (royalty-free standard; loader+runtime; OpenXR 1.1; CTS on GitHub; Conformant Products directory) — https://www.khronos.org/openxr/"
  - "OpenXR registry / spec (Khronos) — https://registry.khronos.org/OpenXR/"
  - "OpenXR-CTS (conformance test suite) — https://github.com/KhronosGroup/OpenXR-CTS"
  # Engine XR (primary, WebFetch-verified)
  - "Unity OpenXR plugin package (com.unity.xr.openxr@1.17) — https://docs.unity3d.com/Packages/com.unity.xr.openxr@latest/"
  - "Unity XR Interaction Toolkit (com.unity.xr.interaction.toolkit@3.5) — https://docs.unity3d.com/Packages/com.unity.xr.interaction.toolkit@3.5/"
  - "Godot XR update Mar 2026 (Godot 4.6: OpenXR 1.1 fallback, AndroidXR official, Steam Frame) — https://godotengine.org/article/godot-xr-update-mar-2026/"
  - "Godot XR update May 2026 (OpenXR Vendors plugin 5.1; min Godot 4.6) — https://godotengine.org/article/godot-xr-update-may-2026/"
  - "bevy_mod_xr / bevy_oxr (community Bevy XR; v0.4.0 for Bevy 0.17, Oct 2025; no 1.0; experimental) — https://github.com/awtterpip/bevy_oxr , https://crates.io/crates/bevy_oxr"
  - "Unreal Engine OpenXR input (Epic docs) — https://dev.epicgames.com/documentation/unreal-engine/openxr-input-in-unreal-engine"
  - "Polyarc Unreal visionOS fork — https://polyarcgames.github.io"
  # Apple visionOS (primary, WebFetch-verified — NO OpenXR)
  - "Apple visionOS (SwiftUI / RealityKit / ARKit / Metal; no OpenXR) — https://developer.apple.com/visionos/"
  - "visionOS HIG (terminology: 'spatial computing app') — https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos"
  - "visionOS App Store submission — https://developer.apple.com/visionos/submit/"
  # Store cert / comfort / perf (primary + practitioner)
  - "Meta Quest publishing requirements (VRC) — https://developers.meta.com/horizon/resources/publish-quest-req/"
  - "Meta VRC.Quest.Performance.1 (60 fps min / 30 fps w/ AppSW; 72–120 Hz; OVR Metrics) — https://developers.meta.com/horizon/resources/vrc-quest-performance-1/"
  - "Meta App Lab → Horizon Store consolidation (Aug 5 2025) — https://developers.meta.com/horizon/blog/get-apps-ready-app-lab-meta-horizon-store-meta-quest-developers/ ; https://www.uploadvr.com/quest-app-lab-merged-into-meta-horizon-store/"
  - "Meta Application SpaceWarp — https://developers.meta.com/horizon/blog/introducing-application-spacewarp/"
  - "Steamworks SteamVR settings (VR launch option; OpenVR/OpenXR; store-page comfort/devices) — https://partner.steamgames.com/doc/features/steamvr/settings"
  - "Steam VR comfort rating (Green/Yellow/Red, self-reported) — https://steamcommunity.com/groups/VRComfortRating"
  - "Steam Frame hardware page — https://store.steampowered.com/hardware/steamframe"
  - "PSVR2 hardware (2000x2040/eye OLED, 90–120 Hz, eye-tracked foveated) — https://www.playstation.com/en-us/support/hardware/psvr2/"
confidence: >
  HIGH and primary-source-verified on: OpenXR architecture/version/conformance program; the per-engine XR support verdict
  (Unity OpenXR 1.17 + XRI 3.5 production; Godot 4.6 built-in OpenXR + Vendors 5.1 maturing; Bevy community-only experimental;
  Apple visionOS = no OpenXR); Meta VRC.Quest.Performance.1 numbers and App Lab merger; Steam self-reported comfort model.
  MEDIUM (NDA-gated, flagged [UNVERIFIED]): exact PSVR2 TRC frame-rate/comfort requirements; exact Apple spatial review criteria.
  The headset-required-human boundary (comfort/nausea/presence) is asserted on physiological grounds + platform docs.
research_quality_warning: >
  Prior perplexity passes in this project CONFABULATED specifics (engineering-disciplines.md header; online-services
  research_quality_warning; AAA-RECONCILIATION R-009). For THIS vector every load-bearing claim — OpenXR version/conformance,
  each engine's XR package + version, Apple's non-OpenXR stack, Meta's VRC frame-rate numbers + App Lab merger date — was
  re-verified by WebFetch against the primary vendor/Khronos doc. The deep-research drafts were used only as a scaffold; where
  a draft asserted a version or number, it was confirmed against the source before being stated here. Items that could NOT be
  primary-verified (NDA console internals, slow-evolving OpenXR experimental extensions) are marked [UNVERIFIED]. The single
  most over-stateable claim — Bevy XR maturity — was deliberately checked against the actual GitHub repo (v0.4.0 / Bevy 0.17 /
  no 1.0) and is reported as EXPERIMENTAL, not maturing.
---

# VR / AR / XR as a Target Platform — Factory Vector Research

> **Vector.** Whether and how the game-factory should treat VR/AR/XR as a target *platform*, framed against the factory's
> no-lock-in adapter thesis. Central question: does the Khronos **OpenXR** standard give the factory a clean
> engine-agnostic **XR seam** (an `xr-adapter`) the same way the engine-adapter, asset-adapter, and distribution-adapter
> give it engine/asset/store seams? And: where is the **machine-checkable / headset-required-human** boundary for XR —
> the XR analog of the GPU/playtest boundary the rest of this research corpus already draws.
>
> **Builds on:** `engineering-disciplines.md` (testability tiers, perf budgets, the GPU/subjective boundary),
> `qa-testing-liveops.md` (cert pre-flight 55–80% machine-checkable, perf/soak gates, fun = human gate),
> `online-services-platform-distribution.md` (the distribution-adapter + the **`human-gated` fidelity tier** — which this
> vector reuses directly), `AAA-RECONCILIATION.md` (Unreal-deferred-tier precedent, R-009 confabulation rule), and the
> three engine-capability reports (Bevy/Unity/Godot).

---

## 1. Executive Summary

**OpenXR is a genuinely clean adapter seam — arguably the cleanest in the whole corpus** — but XR as a *target platform*
sits on the wrong side of the factory's hardest boundary: **the irreducible human/headset wall**. Five load-bearing findings:

1. **OpenXR maps almost perfectly onto the factory's adapter pattern.** It is a royalty-free Khronos standard with a
   **loader → runtime → API-layer** architecture: one application binary, written to the OpenXR API, runs against any
   conformant vendor runtime (Meta Quest, SteamVR, Windows MR, Pico, Monado, etc.) via the loader — exactly the
   "N-backends-for-one-capability" problem the engine-adapter and distribution-adapter already solve. OpenXR even ships a
   **Conformance Test Suite (CTS)** on GitHub and a public **Conformant Products** directory — a *machine-checkable
   conformance gate that already exists*, mirroring the factory's own conformance-suite philosophy. **Recommendation:
   model XR as an `xr-adapter` layered ON TOP OF the engine adapters, with OpenXR as the reference seam.** (§2)

2. **Per-engine XR support is sharply tiered — and it does NOT match the engine tiers the brief already uses.** Unity XR
   (OpenXR plugin 1.17 + XR Interaction Toolkit 3.5) is **production-grade**. Godot 4.6 has **built-in core OpenXR**
   (official, OpenXR 1.1 with 1.0 fallback) + an official **OpenXR Vendors plugin 5.1**, now **maturing→production**.
   **Bevy XR is community-only and EXPERIMENTAL** — `bevy_mod_xr`/`bevy_oxr` at v0.4.0 for Bevy 0.17 (Oct 2025), **no
   1.0, no official support, not upstreamed.** This inverts the pilot stack: the factory's tier-1-determinism pilot engine
   (Bevy) is the **weakest** XR engine. (§3)

3. **The machine-checkable / headset-required-human split is real, physiological, and unavoidable — XR's version of the
   GPU/playtest boundary.** *Machine-checkable headless or on-runtime:* OpenXR CTS conformance, frame-rate/refresh-rate
   conformance (Meta VRC.Quest.Performance.1 = **60 fps min, 30 fps with AppSW; 72/80/90/96/100/120 Hz** — primary-verified),
   reprojection/dropped-frame logging (OVR Metrics), stereo/multiview render correctness, motion-to-photon latency budget
   (<20 ms consensus). *Requires a physical headset + a human head:* **comfort, nausea/simulator-sickness, presence,
   sense of scale, locomotion tolerance, hand/eye-tracking *feel*.** No headless rig can certify "does this make a human
   sick" — this is strictly analogous to, and *stronger than*, the GPU/fun boundary. (§5, §6)

4. **XR platform stores add a comfort/cert layer that is partly the existing cert-preflight problem and partly a NEW
   human-judgment artifact.** Meta consolidated **App Lab into the Horizon Store (Aug 5 2025)** — there is now one VRC
   gate, with machine-checkable performance VRCs **plus** a developer-declared **comfort rating** (Comfortable / Moderate /
   Intense). Steam uses **self-reported comfort labels** (Green/Yellow/Red) and only requires a VR launch option + OpenVR/
   OpenXR. PSVR2 cert is **NDA-gated** (eye-tracked foveated rendering effectively expected; 90–120 Hz) [UNVERIFIED beyond
   public hardware specs]. Apple Vision Pro is a **separate, non-OpenXR world** (SwiftUI/RealityKit/ARKit/Metal; Apple even
   forbids the terms "VR/AR/XR/MR" — apps are "spatial computing apps"). (§4)

5. **Scope recommendation: XR is a DEFERRED PLATFORM TIER, behind Unreal in priority, surfaced now only as the
   `xr-adapter` SEAM + four contract schemas.** XR is not v1. It is *more* deferred than Unreal: Unreal is a deferred
   *engine* tier on the existing engine-adapter seam, whereas XR is a deferred *platform* tier whose acceptance bar centers
   on a boundary (headset comfort/nausea) the factory cannot automate at all, AND whose best-supported engines are the
   factory's *secondary* engines (Unity/Godot), not its tier-1 pilot engine (Bevy). The right v1 move is to **reserve the
   `xr-adapter` seam and define the four XR contracts** (`xr-adapter`, `xr-comfort-spec`, `xr-perf-budget`,
   `xr-interaction-spec`) so the architecture is XR-*ready*, without building XR support. (§11)

---

## 2. OpenXR as the XR-Adapter Seam

**Verdict: OpenXR is a clean, natural `xr-adapter` seam.** Primary-verified against khronos.org/openxr and the registry.

### 2.1 Architecture maps 1:1 onto the factory's adapter pattern

OpenXR (royalty-free Khronos open standard, current spec **OpenXR 1.1**) defines a three-layer model:

| OpenXR layer | Role | Factory analog |
|---|---|---|
| **Application** (writes to OpenXR API) | engine/game code, runtime-agnostic | the *game* / engine output |
| **OpenXR loader** | discovers + binds the active vendor runtime at `xrCreateInstance` | the **adapter dispatch** layer |
| **Vendor runtime** (Meta, SteamVR, WMR, Pico, Monado…) | actual hardware/compositor integration | the **per-backend driver** |

A single binary written to **core OpenXR** runs across **all conformant runtimes** unmodified — this is precisely the
no-lock-in property the engine-adapter and distribution-adapter exist to provide. The loader's runtime discovery (env vars
/ registry) is the same shape as the factory's capability dispatch.

### 2.2 Capability negotiation is already built in (and graded) — like the factory's

OpenXR separates **core** functionality from **extensions**, and apps must **query extension availability at runtime and
degrade gracefully** — *the exact "declare-and-degrade" discipline the factory already uses.* Extension namespaces encode
a maturity ladder the factory can read directly:

- **`XR_KHR_*`** — Khronos-ratified (candidate for core inclusion)
- **`XR_EXT_*`** — multi-vendor (e.g. `XR_EXT_hand_tracking`, `XR_EXT_eye_gaze_interaction`)
- **vendor:** `XR_FB_*` (Meta, e.g. `XR_FB_passthrough`, `XR_FB_foveation`), `XR_MSFT_*`, `XR_HTC_*`, `XR_META_*`

This is a ready-made **fidelity grading**: an `xr-adapter` capability declares `full` (core or ratified ext),
`partial`/`vendor` (vendor ext, single-platform), or `none` (absent) — identical to the engine-adapter's
`full`/`partial`/`none` and the distribution-adapter's `human-gated` tier.

### 2.3 OpenXR conformance = a machine-checkable gate that ALREADY EXISTS

Khronos ships the **OpenXR Conformance Test Suite (CTS)** publicly on GitHub and maintains a **Conformant Products**
directory (adopters program). Vendors self-test with the CTS, submit XML logs, and are certified. **This is structurally
identical to the factory's own adapter conformance suite** — and it means the *runtime* side of XR conformance is already
machine-verifiable by a Khronos-maintained harness the factory can wrap rather than build. (Caveat from the research:
extension conformance is *elective* and the CTS validates API contract, **not** real-world performance or comfort — so CTS
green ≠ shippable XR experience. That gap is exactly the human boundary in §6.)

### 2.4 The one big hole in the seam: Apple

**Apple Vision Pro / visionOS does NOT support OpenXR** (primary-verified at developer.apple.com/visionos: the stack is
**SwiftUI + RealityKit + ARKit + Metal**, no OpenXR reference anywhere). visionOS is a **parallel, proprietary XR world**:
no OpenXR runtime, Metal-only (no Vulkan; Godot needs MoltenVK), Apple-specific input, and Apple even **prohibits the
terms VR/AR/XR/MR** in favor of "spatial computing app." **Implication for the seam:** the `xr-adapter` is clean for the
*OpenXR world* (Quest / SteamVR / WMR / Pico / Android XR), but **Apple Vision Pro is a second, non-OpenXR backend** that
must be modeled as its own adapter target (via engine bridges — Unity PolySpatial, or Unreal's third-party Polyarc fork),
much like a console is a distinct distribution target. This is the XR analog of "console cert is its own NDA world."

---

## 3. Engine XR Support Matrix

Per-engine verdict, each package/version **WebFetch-verified against the primary source as of June 2026**. Fast-moving —
re-verify per release (XR packages churn like netcode crates per `engineering-disciplines.md` §5).

| Engine | OpenXR support | Key packages (verified) | visionOS / Apple | Maturity verdict |
|---|---|---|---|---|
| **Unity** | **Yes, primary backend** | **Unity OpenXR plugin `com.unity.xr.openxr` v1.17**; **XR Interaction Toolkit v3.5**; XR Plugin Management | **Yes, via PolySpatial** (separate Apple path; Dynamically Foveated Rendering + passthrough exposed) | **PRODUCTION** — the mature reference XR engine |
| **Godot** | **Yes, built into 4.x core** | **Godot 4.6 core OpenXR** (initializes **OpenXR 1.1**, falls back to **1.0**); official **OpenXR Vendors plugin v5.1** (Meta/Android XR ext; min Godot 4.6); **official AndroidXR** (4.6); runs on **Steam Frame** | **Partial/awkward** — Metal-only forces MoltenVK; community workarounds, no first-class path | **MATURING → PRODUCTION** — credible open-source XR engine; rapid 2026 progress |
| **Bevy** | **Community-only, no official support** | **`bevy_mod_xr` / `bevy_oxr` v0.4.0 for Bevy 0.17** (Oct 2025); **no 1.0**; "planned to be upstreamed" but **not yet**; older `blaind/bevy_openxr` effectively **dormant** | None (no path) | **EXPERIMENTAL** — proof-of-concept; not production-ready; **do not overstate** |
| **Unreal** | **Yes, OpenXR plugin** (mature; deferred in this project) | UE OpenXR plugin + interaction profiles; high-fidelity VR | **Yes, via third-party Polyarc fork** (FFR, multiview, layered targets) | **PRODUCTION** (but Unreal is a deferred *engine* tier here) |

**Load-bearing implication — the XR/engine-tier inversion.** The brief's pilot stack is **Bevy + Rapier (tier-1
determinism)** precisely because Bevy is the most factory-friendly for *headless automation* (BRP introspection, clean
windowless capture). But for **XR**, Bevy is the **weakest** engine — XR support is an experimental community crate with no
1.0. The two best XR engines (Unity, Godot) are the factory's *secondary/third* adapters. So XR support and the
det-sim pilot pull in **opposite engine directions**. This is a strong argument for XR being a *later* tier that rides the
Unity/Godot adapters once those are proven, **not** something the Bevy-first pilot should attempt.

> **Confabulation-watch (R-009 applied):** the deep-research draft over-claimed Bevy XR ("significant technical capability",
> theoretical ECS advantages). The GitHub repo says otherwise: v0.4.0, Bevy 0.17, no 1.0, README warns to build in release
> for acceptable perf, minimal docs. Reported here as **experimental**, full stop.

---

## 4. XR Platforms, Stores & Certification

XR shipping adds a **platform/store layer** that partly reuses the existing `cert-preflight-checklist` (machine-checkable
half) and partly introduces a **new comfort-rating human gate**. Primary-verified where marked.

| Platform | Store / cert | Machine-checkable requirements | Human / declared requirements |
|---|---|---|---|
| **Meta Quest (Horizon Store)** | **VRC** (Virtual Reality Checks); **App Lab merged into Horizon Store Aug 5 2025** — one unified gate (verified) | **VRC.Quest.Performance.1**: **≥60 fps** (≥30 fps with AppSW); refresh **72/80/90/96/100/120 Hz**; tested via **OVR Metrics** log analysis (verified). Other VRCs: head-tracked graphics within ~4 s or loading indicator; render-scale floor; functional/input/asset checks | **Comfort rating** (Comfortable/Moderate/Intense) = **developer-declared**, not machine-verified; content/privacy policy review |
| **SteamVR** | Steamworks: requires **≥1 VR launch option** + OpenVR/OpenXR SDK; store-page VR support fields | Light — no enforced frame-rate gate; Asynchronous Reprojection / Motion Smoothing handled by runtime | **Comfort rating self-reported** (Green/Yellow/Red); device/room-scale support is developer-described (verified) |
| **PSVR2 (Sony)** | **TRC** (NDA-gated) | Hardware: **2000×2040/eye OLED, 90–120 Hz** (verified); **eye-tracked foveated rendering** effectively expected; consistent frame delivery | Comfort/locomotion options evaluated in Sony QA playtest; exact TRC text **[UNVERIFIED]** (NDA) |
| **Apple Vision Pro / visionOS** | App Store review + visionOS HIG | Spatial/Metal rendering correctness; latency | **"Spatial computing app" terminology mandated**; immersion/comfort HIG review; **non-OpenXR stack** (verified). Exact spatial review criteria **[UNVERIFIED]** |
| **Pico / Android XR** | Pico Store / Play (Android XR) | OpenXR-based; perf/packaging | comfort + content review |

**Two structural facts for the factory:**
- **The frame-rate/reprojection half of XR cert is machine-checkable** and folds into the existing
  `cert-preflight-checklist` + `perf-budget-contract` (Meta even publishes the exact numbers and the OVR Metrics method).
- **The comfort-rating half is a declared, human-judged label** that maps onto the **`human-gated` fidelity tier** already
  invented in `online-services-platform-distribution.md` §7.2 — the `xr-adapter`'s `comfort_certify` capability is
  `human-gated` by construction (a human in a headset declares/validates it), exactly like console cert sign-off.

---

## 5. XR-Specific Design (Comfort, Locomotion, Interaction)

XR introduces design constraints with **no flat-screen analog**, and they bifurcate cleanly into *specifiable/checkable*
vs *only-feelable*:

**Locomotion & motion-sickness mitigation (the dominant comfort axis).**
- **Mechanisms** (specifiable as data): teleport vs smooth locomotion; **vignette/tunneling** on smooth-move; snap-turn vs
  smooth-turn; speed caps; static reference frames (cockpits, "comfort nests"). The *presence/absence and parameters* of
  these are a **machine-checkable interaction spec**; whether they *actually prevent nausea in a given human* is **not**.
- **Why it matters:** vestibular-visual mismatch (the eyes see motion the inner ear doesn't feel) drives simulator
  sickness. This is **physiological** — it cannot be evaluated without a real head in a real headset.

**Comfort ratings.** Comfortable / Moderate / Intense (Meta) or Green/Yellow/Red (Steam). The factory can **derive a
*candidate* rating from the interaction spec** (e.g. "smooth locomotion + no vignette ⇒ likely ≥ Moderate") as a heuristic,
but the **shipping rating is a human gate** — and mis-rating drives refunds/negative reviews, so it is load-bearing.

**Interaction paradigms (specifiable structure, human-judged feel).**
- **Controllers** (per-platform interaction profiles — OpenXR normalizes bindings across Quest/Index/etc.).
- **Hand tracking** (`XR_EXT_hand_tracking`, 25-joint model) — structure checkable; *ergonomic feel* not.
- **Eye tracking** (`XR_EXT_eye_gaze_interaction`; drives foveation + gaze UI) — present/absent checkable; *calibration
  feel* not.
- **Room-scale / guardian / boundary** — play-area shape + boundary handling is specifiable; whether a mechanic "fits" a
  2m×2m guardian is a playtest judgment.
- **Diegetic UI** — XR strongly prefers in-world UI (wrist menus, world-space panels) over screen-space HUDs; this is a
  **design-intent constraint** the factory can encode in the interaction spec, but "is it readable/comfortable" is human.

**Mapping to existing machinery:** all of the *structural* parts are **Design-Intent-Contract** territory
(`engineering-disciplines.md` / `game-design-discipline.md`); all of the *feel/nausea/presence* parts are
**playtest-protocol** territory (`qa-testing-liveops.md` §5) — **with the added, hard constraint that the playtest
REQUIRES a physical headset**, narrowing the human gate further than flat-screen playtest.

---

## 6. XR Performance Budgets (Machine-Checkable)

XR perf is **stricter and more machine-checkable** than flat-screen perf — the budgets are externally imposed by physiology
and the runtime, and the runtime *measures them for you*. This is the strongest factory-fit area in the whole vector.

| Budget | Value (verified where cited) | Machine-checkable? | How |
|---|---|---|---|
| **Frame-rate floor** | Meta: **≥60 fps**, **≥30 fps with AppSW** (VRC.Quest.Perf.1, verified); native targets **72/80/90/96/100/120 Hz** | **YES** | OVR Metrics log analysis; runtime frame stats |
| **Refresh-rate / display Hz** | 72–120 Hz (Quest); PSVR2 90–120 Hz; **90 Hz = comfort floor** consensus | **YES** | runtime-reported |
| **Motion-to-photon latency** | **<20 ms** industry consensus to avoid sickness | **YES (on hardware)** | end-to-end latency measurement; on-device |
| **Reprojection / dropped frames** | AppSW (Meta, half-rate + motion vectors), Asynchronous Reprojection / Motion Smoothing (SteamVR), reprojection (PSVR2) | **YES** | runtime reports reprojected-frame %, "stale" frames |
| **Stereo / multiview render** | two eye buffers; multiview/single-pass-stereo correctness | **YES (render profile)** | golden-image per eye + structural checks |
| **Foveated rendering** | **FFR** (fixed, no eye-tracking, broadly available) vs **eye-tracked/dynamic** (Quest Pro/PSVR2 w/ eye tracking) | **PARTIAL** | presence/config checkable; *perceptual quality* human |

**Key distinctions, verified/clarified:**
- **Fixed-foveated rendering (FFR)** needs **no eye tracking** — static peripheral down-res; broadly supported; ~30–45%
  GPU savings (vendor figures, directional). **Eye-tracked/dynamic foveated rendering** follows gaze, needs <~20 ms
  eye-tracking latency, gives larger savings (~50–60% vendor figures) but is **hardware-gated** (Quest Pro/PSVR2/Varjo).
- **The XR perf budget is a HARD, runtime-measured gate** — closer to a cert requirement than flat-screen perf. It folds
  directly into the existing **`perf-budget-contract`** (`engineering-disciplines.md` §6 / `qa-testing-liveops.md` §10.5),
  but with XR-specific dimensions (per-eye frame time, reprojection %, motion-to-photon) **and the caveat that the
  measurement requires the actual headset+runtime** — i.e. it is an *on-device* gate, like GPU-time, not a pure-headless CI
  gate. (CTS conformance and stereo-render structural checks *can* run without a headset against a software runtime like
  Monado; the *comfort-relevant* perf numbers cannot.)

---

## 7. The Headset-Required Human Testing Boundary (be honest)

**This is the load-bearing constraint of the whole vector. XR cannot be fully headless — and the human part is *more*
irreducible than flat-screen "fun," because it is physiological, not aesthetic.**

| Concern | Verifiable without a headset? | Mechanism |
|---|---|---|
| OpenXR CTS conformance (runtime side) | **Yes** (Khronos CTS; software runtime e.g. Monado) | wrap CTS |
| Stereo/multiview render correctness, swapchain, layer composition | **Yes** (render profile, software runtime) | golden-image per eye + structural |
| Frame-rate / reprojection / motion-to-photon budgets | **On-device only** (needs real runtime+HMD for comfort-relevant numbers) | OVR Metrics / runtime stats on hardware |
| Interaction-spec structure (locomotion options present, bindings mapped, diegetic UI exists) | **Yes** (spec + introspection) | Design-Intent Contract |
| **Comfort / simulator-sickness / nausea** | **NO — physical headset + human head required** | structured headset playtest |
| **Presence / immersion / sense of scale** | **NO — headset + human required** | structured headset playtest |
| **Hand/eye-tracking ergonomic feel** | **NO — headset + human required** | structured headset playtest |
| Comfort rating (shipping label) | **NO — human-declared/validated** | `human-gated` |

**The analogy, stated precisely:** flat-screen development has the **GPU/playtest boundary** — pixels + feel need a GPU and
a human. XR has a **strictly larger** boundary: it needs a **GPU *and* a head-mounted display *and* a human vestibular
system**. You can headless-check OpenXR conformance and render structure, but **you cannot headless-check whether an
experience makes a person sick or feels present.** Any claim that the factory "ships XR lights-out" would be dishonest at
exactly this boundary — the same honesty the `replay: none → human playtest` and `store_submit: human-gated` degradations
already model. **The factory must declare comfort/presence as a headset-required human gate, by construction.**

---

## 8. MR / AR (Passthrough, Anchors, Planes, ARKit/ARCore)

Mixed/augmented reality is **more fragmented than VR** and **less OpenXR-standardized**:

- **Passthrough** (video see-through MR): Meta `XR_FB_passthrough` (vendor); a slow-moving `XR_EXTX_passthrough`
  experimental multi-vendor effort [UNVERIFIED current status]; Apple visionOS does passthrough via its own Metal pipeline
  (non-OpenXR). **No clean cross-vendor passthrough standard yet** — passthrough is a **vendor-extension / per-platform**
  capability in the `xr-adapter`.
- **Spatial anchors / persistence:** `XR_MSFT_spatial_anchor` → evolving `XR_EXT_*`; Meta Presence Platform; Apple ARKit
  world anchors. Interface partly standardized; **quality/persistence/sharing are platform-specific** and often need cloud
  infra outside OpenXR.
- **Plane detection / scene understanding:** `XR_MSFT_scene_understanding` / plane-detection extensions; Apple ARKit
  Scene Reconstruction; **ARCore** (Android phone AR) and **ARKit** (iOS phone AR) are **entirely separate mobile-AR
  stacks**, not OpenXR.
- **Implication:** AR/MR is a **second, messier sub-seam**. For the factory, MR-on-OpenXR (Quest passthrough) is a
  vendor-extension tier of the `xr-adapter`; **phone AR (ARKit/ARCore) and Apple visionOS are separate non-OpenXR
  targets** that would each need their own adapter — strengthening the "defer XR, and defer AR even harder" recommendation.

---

## 9. Automatable vs Human (XR)

| Concern | Automatable (factory owns) | Human / headset-gated |
|---|---|---|
| OpenXR conformance (runtime) | **wrap Khronos CTS**; assert green | — |
| Stereo/multiview render correctness | golden-image per eye (render profile, software runtime) | artistic/visual sign-off |
| XR perf budgets | frame-rate/reprojection/latency gates **on device** | "does it *feel* smooth in-headset" |
| Interaction spec structure | locomotion options, bindings, diegetic-UI presence (Design-Intent Contract) | interaction *feel*, reachability in real play-space |
| Comfort / nausea / presence | derive a *candidate* comfort rating heuristically | **headset playtest + human verdict (mandatory)** |
| Store cert (XR) | machine-checkable VRC perf subset → `cert-preflight-checklist` | comfort rating, content review, console TRC sign-off |
| Build/package/upload to XR store | reuse distribution-adapter (Quest = Android pkg + Meta dashboard) | store publish, comfort-label submit (`human-gated`) |

**The clean line (same shape as every other vector):** *conformance, render structure, and perf budgets are machine-checkable;
comfort, nausea, presence, and the shipping comfort rating are headset-required human gates.* XR just moves the human-gate
boundary **outward** (adds the HMD + vestibular requirement on top of GPU + human).

---

## 10. Genre Variation

| Genre | XR fit / typical comfort tier | Notes for the factory |
|---|---|---|
| **Seated/cockpit (sim, racing, space)** | Comfortable–Moderate; static reference frame mitigates sickness | Best XR-comfort genre; locomotion largely absent; closest to flat-screen testability |
| **Room-scale / physical (rhythm, sport, puzzle)** | Comfortable; natural movement, no artificial locomotion | Low sickness; high dependence on play-space + hand-tracking *feel* (human) |
| **Smooth-locomotion FPS / action-adventure** | Moderate–Intense; smooth move = highest sickness risk | Comfort-mitigation spec (vignette, snap-turn, teleport) is mandatory; heavy headset playtest |
| **Strategy / god-game / tabletop-in-VR** | Comfortable; world-space board, no locomotion | Logic-dense + render-light → otherwise factory-friendly, but still headset-comfort-gated |
| **MR / AR (passthrough, tabletop AR)** | varies; passthrough reduces VR sickness | Vendor-extension fragmentation (Quest vs visionOS vs ARCore/ARKit) dominates |
| **Det-sim pilot genres (roguelike/factory/RTS) in XR** | usually *not* native XR genres | The factory's pilot genres are **flat-screen-first**; XR is not their natural target — reinforces deferral |

**Implication:** the factory's pilot bias (det-sim, Bevy, flat-screen) and XR's strengths (room-scale/cockpit, Unity/Godot,
comfort-gated) are **largely disjoint**. XR genre fit is another vote for treating XR as a later, Unity/Godot-rooted tier.

---

## 11. Factory Artifacts / Contracts This Vector Implies

Four new contracts, mirroring the existing adapter+contract pattern. **Define the SEAM + schemas in v1; implement later.**

1. **`xr-adapter`** *(new seam, layered on engine adapters)* — declares the XR backend (`openxr` reference | `visionos`
   non-OpenXR | future) and capability surface with **OpenXR-namespace-derived fidelity grading**:
   ```yaml
   # xr-adapter manifest (sketch)
   backend: openxr            # | visionos (non-OpenXR, separate target)
   engine: unity              # rides the engine-adapter (Unity prod | Godot maturing | Bevy experimental)
   openxr_version: "1.1"
   conformance: { suite: khronos-cts, status: wrap }   # machine-checkable, Khronos-maintained
   capabilities:
     stereo_render:    { fidelity: full }                       # core
     controllers:      { fidelity: full,    api: interaction_profiles }
     hand_tracking:    { fidelity: partial, ext: XR_EXT_hand_tracking }
     eye_tracking:     { fidelity: partial, ext: XR_EXT_eye_gaze_interaction }
     passthrough:      { fidelity: vendor,  ext: XR_FB_passthrough }   # MR, vendor-locked
     foveation:        { fidelity: partial, kind: fixed|eye-tracked }
     spatial_anchors:  { fidelity: partial }
     comfort_certify:  { fidelity: human-gated }                # headset+human, by construction
   ```
2. **`xr-comfort-spec`** *(new)* — declared locomotion/comfort design: locomotion type(s), vignette/tunneling params,
   snap vs smooth turn, speed caps, static reference frames, candidate comfort rating + the **headset-playtest gate** that
   validates the shipping rating. Structure machine-checkable; rating `human-gated`.
3. **`xr-perf-budget`** *(extends `perf-budget-contract`)* — XR-specific budgets: target refresh Hz, per-eye frame-time,
   reprojection-% ceiling, motion-to-photon ceiling (<20 ms), FFR/dynamic-foveation config. **On-device gate** (runtime
   stats / OVR Metrics), with CTS + stereo-structure checks runnable headless on a software runtime.
4. **`xr-interaction-spec`** *(extends Design-Intent Contract)* — controller interaction profiles, hand/eye-tracking
   usage, room-scale/guardian requirements, diegetic-UI layout. Structure checkable; *feel* → headset playtest.

All ride the existing **declare-and-degrade** machinery: `full → partial/vendor → human-gated → none`, and the orchestrator
surfaces headset-required steps as **checklisted human tasks** (reusing the distribution-adapter's `human-gated` mechanism).

---

## 12. Scope Recommendation (in / deferred-tier)

**Recommendation: XR is a DEFERRED PLATFORM TIER — reserve the `xr-adapter` seam + define the four XR contracts in v1, but
build NO XR support in v1.** XR is **more deferred than Unreal**, for three independent reasons:

1. **The acceptance bar centers on an un-automatable boundary.** XR's defining quality gate (comfort/nausea/presence) is
   **headset-required human** — the factory's hardest wall, *stronger* than the GPU/fun wall it already defers on. A
   lights-out factory cannot honestly certify XR comfort; it can only emit a headset-playtest task. (§7)
2. **XR's best engines are the factory's secondary engines.** XR is production-grade on **Unity** and maturing on
   **Godot**, but **experimental on Bevy** — the factory's tier-1-determinism pilot engine. XR therefore can't ride the
   det-sim/Bevy pilot; it must wait for the Unity/Godot adapters to be proven. (§3)
3. **Genre/seam disjointness.** The pilot genres (det-sim, flat-screen) and XR's strengths (room-scale/cockpit) barely
   overlap; AR/MR adds a second, *non-OpenXR-fragmented* sub-seam (visionOS, ARKit/ARCore) that is even less ready. (§8, §10)

**What v1 SHOULD do (cheap, high-leverage, keeps the no-lock-in thesis honest):**
- **Reserve the `xr-adapter` seam** as a first-class adapter type alongside engine/asset/distribution adapters, with
  **OpenXR as the reference backend** and **visionOS flagged as a separate non-OpenXR target**.
- **Define the four contract schemas** (`xr-adapter`, `xr-comfort-spec`, `xr-perf-budget`, `xr-interaction-spec`) so the
  architecture is XR-*ready* and the comfort/headset boundary is modeled (via the existing `human-gated` tier) before any
  XR code is written.
- **Reuse, don't rebuild:** when XR is implemented, **wrap the Khronos OpenXR CTS** (conformance), **wrap OVR Metrics /
  runtime stats** (perf), and **ride the Unity/Godot engine adapters + the distribution-adapter** (Quest = Android package
  + Meta dashboard). The only net-new factory build is the **comfort/interaction Design-Intent contracts + the
  headset-playtest gate**.

**What v1 should NOT do:** build a Bevy XR adapter (experimental crate, no 1.0); attempt headless comfort/nausea
certification (impossible); target Apple visionOS (separate non-OpenXR world); or treat XR as a default platform for the
det-sim pilot.

**Net brief delta:** add **"XR / OpenXR"** to the brief's deferred-tier list *alongside* Unreal, but with an explicit note
that XR is a deferred **platform** tier (headset-comfort-gated, Unity/Godot-rooted) — distinct from Unreal's deferred
**engine** tier — and that the `xr-adapter` seam + four XR contracts are **reserved/specified in v1** to preserve the
no-lock-in architecture. This is the same "specify the seam, defer the implementation" honesty the distribution-adapter's
`human-gated` console tier already established.

---

## 13. Open Questions & Risks

1. **Headless comfort certification is impossible (HIGH, by design).** Comfort/nausea/presence need a physical headset +
   human. The factory must model this as a hard human gate; any attempt to approximate it headless is a defect (XR analog
   of R-010 "no auto fun-score"). **Mitigation:** `comfort_certify: human-gated`; emit headset-playtest task.
2. **XR/engine-tier inversion (HIGH).** Best XR engines (Unity/Godot) ≠ pilot engine (Bevy). XR can't ride the det-sim
   pilot. **Mitigation:** defer XR until Unity/Godot adapters are proven; never gate XR on Bevy.
3. **Apple visionOS is a separate non-OpenXR world (HIGH, verified).** No OpenXR, Metal-only, Apple-specific stack +
   terminology. **Mitigation:** model visionOS as a distinct adapter target (like a console); not part of the OpenXR seam.
4. **Vendor-extension fragmentation (MEDIUM, verified).** Passthrough/anchors/eye-tracked-foveation are vendor-locked
   (`XR_FB_*`, `XR_META_*`); CTS validates API contract, **not** perf/comfort. **Mitigation:** fidelity-grade per
   extension namespace; never assume parity across runtimes.
5. **Fast-moving XR packages (MEDIUM).** Unity OpenXR 1.17 / XRI 3.5, Godot 4.6 + Vendors 5.1, `bevy_mod_xr` 0.4.0 all
   churn (Bevy crate especially, tied to pre-1.0 Bevy). **Mitigation:** pin + re-verify per release, like netcode crates.
6. **NDA-gated console XR (MEDIUM).** PSVR2 TRC (eye-tracked foveation, frame-rate, comfort) is NDA; only public hardware
   specs verified. **Mitigation:** mark [UNVERIFIED]; build against public categories + licensed docs, like console cert.
7. **AR/MR is even less ready than VR (MEDIUM).** Phone AR (ARKit/ARCore) and visionOS are non-OpenXR; passthrough has no
   ratified cross-vendor standard. **Mitigation:** defer AR/MR harder than VR; treat as separate future sub-seams.

---

## 14. Sources

See YAML frontmatter for the full URL list. Verification highlights by claim class:

- **OpenXR standard/conformance (WebFetch-verified):** khronos.org/openxr — royalty-free open standard; loader+runtime
  architecture; **OpenXR 1.1**; **CTS on GitHub**; **Conformant Products** directory; conformant runtimes incl. Quest,
  SteamVR, Vive, HoloLens, Pico.
- **Engine XR (WebFetch-verified):** Unity OpenXR plugin **1.17** + XRI **3.5**; Godot **4.6** core OpenXR (1.1 w/ 1.0
  fallback) + **AndroidXR official** + **Steam Frame** (godot Mar-2026 update) + **OpenXR Vendors 5.1** (May-2026 update);
  **`bevy_mod_xr`/`bevy_oxr` v0.4.0 for Bevy 0.17, no 1.0, experimental** (GitHub); Unreal OpenXR (Epic docs) + Polyarc
  visionOS fork.
- **Apple visionOS (WebFetch-verified, NO OpenXR):** developer.apple.com/visionos — SwiftUI/RealityKit/ARKit/Metal; HIG
  "spatial computing app" terminology.
- **Store cert/perf (primary + practitioner):** Meta **VRC.Quest.Performance.1** (≥60 fps / ≥30 fps AppSW; 72–120 Hz; OVR
  Metrics) WebFetch-verified; **App Lab → Horizon Store merger Aug 5 2025** (Meta blog + UploadVR); Meta Application
  SpaceWarp blog; Steamworks SteamVR settings (VR launch option, OpenVR/OpenXR, store-page comfort/devices); Steam comfort
  rating (Green/Yellow/Red, self-reported); PSVR2 hardware (PlayStation support page).

**Cross-references (in-repo, built upon, not contradicted):**
`planning/research/aaa/{engineering-disciplines,qa-testing-liveops,online-services-platform-distribution}.md`,
`planning/research/aaa/AAA-RECONCILIATION.md`, `planning/research/{bevy,unity,godot}-capabilities.md`,
`planning/design/engine-adapter-protocol.md`, `.factory/specs/product-brief.md`.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep passes (reasoning_effort: high, strip_thinking): (1) OpenXR architecture/conformance/extensions/Apple/foveation; (2) per-engine XR support (Unity/Godot/Bevy/Unreal) + visionOS; (3) XR store cert/comfort/perf (Meta/Steam/PSVR2/Apple). Used as SCAFFOLD; every load-bearing claim re-verified below. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (vendor/Khronos docs are the authority; verified via WebFetch) |
| Tavily tavily_extract / search | 0 | — |
| **WebFetch** | 7 | **Primary-source verification of every load-bearing claim:** khronos.org/openxr (standard+CTS+1.1); developer.apple.com/visionos (no OpenXR); Unity OpenXR plugin (1.17); Godot Mar-2026 update (4.6/AndroidXR/Steam Frame); Godot May-2026 update (Vendors 5.1); github.com/awtterpip/bevy_oxr (v0.4.0/Bevy 0.17/no 1.0/experimental); Meta VRC.Quest.Performance.1 (60 fps/AppSW/72–120 Hz/OVR Metrics). |
| WebSearch | 0 | — |
| Repo files (Read) | 6 | Grounded against engineering-disciplines, qa-testing-liveops, online-services-platform-distribution, AAA-RECONCILIATION, the three engine-capability reports, product-brief — to mirror the adapter pattern, the GPU/playtest boundary, the `human-gated` tier, and the Unreal-deferral precedent. |
| Training data | ~2 areas | XR design taxonomy (locomotion/comfort/diegetic-UI) + the machine-vs-human framing — structure only; all specific versions, numbers, and standards verified against primary sources. |

**Total MCP tool calls:** 3 (3 perplexity_research) + **7 WebFetch primary-source verifications**
**Training data reliance:** low — the deep-research passes were treated as scaffolds, not ground truth (prior passes in
this project confabulated). **Every load-bearing claim** — OpenXR version/architecture/conformance, each engine's XR
package + version + maturity, Apple's non-OpenXR stack, Meta's VRC frame-rate numbers + App Lab merger — was WebFetch-verified
against the primary Khronos/vendor doc. NDA-gated console internals and slow-moving experimental OpenXR extensions are
marked **[UNVERIFIED]** rather than guessed. The most over-stateable claim (Bevy XR maturity) was deliberately checked
against the actual repo and reported as **experimental**.
