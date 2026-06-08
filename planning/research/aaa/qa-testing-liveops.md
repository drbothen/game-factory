---
document_type: research
vector: qa-testing-liveops
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00
producer: research-agent
project_context: "game-factory re-scope to Dark Factory for AAA game development"
inputs:
  - planning/decisions/0003-determinism-tier-capability.md
  - planning/research/RECONCILIATION.md
  - planning/research/prior-art-and-precedents.md
  - .factory/specs/product-brief.md
sources:
  - "Sony PlayStation Partner crash/cert practice: https://bugnet.io/blog/crash-reporting-for-playstation-ps5-games"
  - "Microsoft Xbox certification requirements (GDK): https://learn.microsoft.com/en-us/gaming/gdk/docs/store/policies/console/certification-requirements"
  - "Microsoft XR-001 Title Stability: https://learn.microsoft.com/en-us/gaming/gdk/docs/store/policies/xr/xr001"
  - "Microsoft Submission Validator (GDK): https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/packaging/subval/submissionvalidator"
  - "Nintendo NOA Lot Check overview: https://nintendo.fandom.com/wiki/NOA_Lot_Check"
  - "Steam Deck compatibility/verification: https://partner.steamgames.com/doc/steamdeck/compat"
  - "Epic Games Store distribution requirements: https://dev.epicgames.com/docs/epic-games-store/requirements-guidelines/distribution-requirements/requirements-overview"
  - "Console porting/submission practitioner guide: https://room8studio.com/news/how-to-submit-game-to-store-from-the-first-attempt-game-porting-tips/"
  - "GameDriver 2023.04 release (engine support: Unity mature, Unreal 4.27/5.x, Godot Beta): https://www2.gamedriver.io/blog/blog/2023/april/202304-release"
  - "modl.ai testing tools (modl:test Unity/Unreal/custom-API; integrationless agents): https://modl.ai/game-testing-tools  and  https://modl.ai"
  - "WeTest survey of AI game-testing landscape (modl.ai Procedural Personas, Airtest/Poco, ML-Agents, Gauntlet): https://www.wetest.net/blog/game-ai-automated-testing-technology-evolution-market-analysis-1171.html"
  - "Rapier determinism docs: https://rapier.rs/docs/"
  - "PhysX determinism (NVIDIA forum): https://forums.developer.nvidia.com/t/once-and-for-all-is-physx-3-3-2-deterministic-when-using-a-fixed-time-step-on-the-same-machine/38405"
  - "Floating-point determinism (Bruce Dawson / RandomASCII): https://randomascii.wordpress.com/2013/07/16/floating-point-determinism/"
  - "Gaffer on Games floating-point determinism: https://gafferongames.com/post/floating_point_determinism/"
  - "Unity input recording/playback (FixedUpdate): https://discussions.unity.com/t/input-recording-playback/446532"
  - "Deterministic lockstep / rollback (coherence.io): https://docs.coherence.io/1.2/coherence-sdk-for-unity/input-prediction-and-rollback"
  - "Characterization / Golden Master testing: https://understandlegacycode.com/blog/characterization-tests-or-approval-tests/"
  - "Deterministic Simulation Testing (Antithesis): https://antithesis.com/docs/resources/deterministic_simulation_testing/"
  - "Tracy frame profiler: https://github.com/wolfpld/tracy"
  - "Soak testing methodology: https://www.testlio.com/blog/soak-testing-in-software-testing"
  - "Games User Research (Drachen, Mirza-Babaei, Nacke 2018) and Game Analytics (El-Nasr, Drachen, Canossa 2013) — discipline references"
  - "GameAnalytics: https://gameanalytics.com  | Unity Analytics/UGS: https://unity.com/products/analytics"
  - "Sentry: https://sentry.io | Firebase Crashlytics: https://firebase.google.com/products/crashlytics | Unity Cloud Diagnostics: https://unity.com/products/unity-cloud-diagnostics"
confidence: "HIGH on certification categories, determinism methodology, playtest/telemetry discipline; MEDIUM on exact cross-engine tool version/support (fast-moving — see flags)"
---

# QA, Testing, Certification & LiveOps — Research for the AAA Game Factory

> **Reading note.** This vector answers: *what must the factory PRODUCE, VERIFY, and OPERATE to ship AAA-grade games across any engine?* It deliberately separates **machine-verifiable** quality (deterministic-sim regression, perf budgets, cert checklists, telemetry coverage) from **human-judgment** quality (fun, feel, polish), and shows how structured playtest protocols + proxy metrics bridge the gap **without auto-scoring fun**. It ties directly to the repo's existing `determinism_tier` capability (Decision 0003).

---

## 1. Executive Summary

**The factory's QA/LiveOps spine is the natural home for the "game quality model" the brief requires.** vsdd-factory already supplies software-grade verification (TDD, adversarial review, formal hardening, convergence). Games add three things software does not have: (a) a **simulation** whose correctness is checked by deterministic replay rather than unit assertions, (b) a **certification** gate imposed by external platform holders, and (c) a **subjective quality dimension (fun/feel)** that no automated scorer can replace. The factory must contain all three as first-class, contract-bearing concerns.

**Six load-bearing findings:**

1. **A large fraction of AAA QA is already machine-checkable and should be automated by the factory as gates.** Public platform-cert practice and CI-vendor guidance converge on roughly **60–80% of technical certification requirements being pre-flightable in CI** (Sony ~60–65% machine-checkable; Xbox ~75–80% with the GDK **Submission Validator** catching ~80% of common failures pre-submission; Nintendo ~55–60% technical) [Microsoft GDK; bugnet.io; room8studio]. These percentages are vendor/practitioner estimates, not audited figures — treat as directional. The factory should ship a **cert pre-flight checklist engine** that runs these checks per target platform.

2. **No tool gives deep, semantic, cross-engine test automation across Unity + Godot + Unreal + Bevy.** Deep SDKs reach **two** engines at most (GameDriver: Unity mature, Unreal near-parity, **Godot Beta**, **no Bevy**) [gamedriver.io]. Engine-agnostic tools (modl.ai, Airtest/Poco) are **black-box** (vision/OCR/UI-hierarchy) [modl.ai; wetest.net]. This is the **same empty-quadrant gap** the repo's prior-art research already validated — and it is the factory's wedge. **Recommendation: a two-tier strategy — wrap engine-native test runners + the deterministic replay-regression spine as the *deep* tier; wrap one black-box agent (modl.ai-style) as the *shallow, universal* tier.**

3. **Deterministic replay-regression is the factory's analog to vsdd-factory's DTU, and it must degrade by determinism tier** (already encoded in Decision 0003). Record inputs keyed by sim frame → replay → compare. Tier-1 (Bevy+Rapier, cross-platform bitwise) gets exact **snapshot-hash / golden-master** diff; tier-2 (Unity PhysX, same-machine) gets snapshot diff on a **pinned CI runner**; tier-3 (Godot physics, FP-heavy) gets **tolerance-window** metric comparison. Confirmed against Rapier and PhysX primary sources [rapier.rs; NVIDIA forum; RandomASCII].

4. **"Fun" cannot and should not be auto-scored — and the factory must encode that as a hard boundary, not a TODO.** Fun is a latent, context-/goal-relative construct; the same telemetry signal (long session, high death rate) can mean immersion *or* grind/unfairness. The robust practice is **triangulation**: telemetry says *what* players did; structured playtests + validated instruments (GEQ, PENS, SUS) say *why* and *how it felt* [Games User Research; Game Analytics]. The factory bridges the gap with **structured playtest protocols + proxy metrics**, never with a "fun score."

5. **Performance is a machine-verifiable budget; "feel" is not.** Frame-time budgets (16.6 ms @ 60 fps / 33 ms @ 30 fps), 1%/0.1%-low FPS, memory soak (8–72 h endurance runs), and crash-free-session rate are objective CI gates [soak testing; Tracy]. Whether a tuned-but-on-budget game *feels* responsive remains a playtest judgment.

6. **LiveOps turns "ship" into a continuous pipeline.** Patch/content cadence, live A/B testing, feature flags/remote config, telemetry KPIs, and crash/error reporting (Sentry, Crashlytics, Cloud Diagnostics) are all automatable plumbing the factory should generate **as artifacts** — but cadence/tuning decisions stay human-in-loop.

---

## 2. AAA QA Discipline Breakdown

AAA QA is not one activity; the factory must model each as a distinct contract with its own verifiability profile.

| QA discipline | What it checks | Factory verifiability | Wrap vs build |
|---|---|---|---|
| **Functional QA** | Mechanics, progression, edge cases, no crashes/softlocks | Largely automatable via deterministic replay + scenario tests; some emergent cases need agents/humans | **Build** the replay-regression spine; **wrap** engine test runners |
| **Compatibility QA** | Hardware/driver/OS/resolution matrix (esp. PC) | Partly automatable (matrix CI on representative configs); long tail needs device labs | **Wrap** cloud device farms / CI matrix |
| **Compliance / certification QA** | Platform TRC/XR/Lotcheck conformance | 55–80% pre-flightable as checklist (see §6) | **Build** cert pre-flight; **wrap** vendor validators (e.g., GDK Submission Validator) |
| **Localization QA** | Text fit, encoding, culturalization, voice sync | Partly automatable (string-overflow, missing-key, glyph checks); linguistic/cultural review human | **Build** static loc checks; **human** for cultural review |
| **Performance / soak QA** | Frame budgets, memory leaks, thermals | Highly automatable as CI gates | **Build** perf gates; **wrap** profilers (Tracy/PIX/Unity Profiler) |
| **Playtest / UX QA** | Fun, feel, fairness, onboarding clarity | **Not** auto-scored; structured protocols + proxy metrics | **Build** protocol harness; **human** judgment |

**Org pattern (for the factory's agent design):** real studios separate "developers write unit/component tests; QA specialists write scenario/e2e tests; user researchers run playtests." The factory should mirror this as **distinct agent roles + distinct artifact types**, not one monolithic "tester" agent. Test isolation, flakiness control (replace fixed `WaitForSeconds`-style waits with state-polling), and per-run state reset are universal pain points the factory must bake in from the start [Unity UTF guidance].

---

## 3. Automated / AI Game-Testing Landscape (Wrap vs Build)

### 3.1 Engine-native test frameworks (WRAP these)

| Engine | Native framework | Headless CI | Normalized result format | Maturity |
|---|---|---|---|---|
| **Unity** | Unity Test Framework (NUnit; **EditMode** = no runtime, fast / **PlayMode** = full runtime). CLI = Unity Test Runner (UTR). Native input record/replay via new Input System (`InputEventTrace`/`InputRecorder`). | Yes (needs display emulation; drop `-nographics` for capture) | NUnit3 XML / JUnit XML | **Mature** |
| **Godot** | **GUT** (GDScript, in-editor plugin) and **GdUnit4** (GDScript+C#, gdextension, headless-first, process-isolation). | Yes (`--headless` + display server config) | JUnit XML | **Maturing** (community-driven; the "weakest link" professionally) |
| **Bevy** | Standard Rust `cargo test` + **cargo-nextest** (stable JUnit XML; libtest-JSON is nightly-only); headless `App` test harness; `bevy_rand` for seeded RNG. | Yes (windowless + wgpu/lavapipe backend) | JUnit (via nextest) | **Sparse** engine-specific harness; relies on Rust ecosystem |
| **Unreal** | Automation System (C++/Python, Editor + Runtime modes) + **Gauntlet** (multi-client/server scale + perf, powers Fortnite). | Yes (AutomationTool) | Custom (normalize to JUnit) | **Mature** but steep |

> Aligns with repo `RECONCILIATION.md`: normalize all to **JUnit/NUnit-family XML**. This is the factory's `test` capability output schema.

### 3.2 Cross-engine UI/automation SDKs (deep-but-narrow)

- **GameDriver** — proprietary **HierarchyPath** query language (XPath-for-scenes); can read AND mutate game state. **Verified support (official blog, 2023.04):** Unity (best-in-class), Unreal 4.27/5.0/5.1 (approaching parity), **Godot = Beta**, plus VR/console targets. **No Bevy.** [gamedriver.io] — *corrects* the over-optimistic "Godot 4.0+ native" claim from one secondary summarizer.
- **AltTester / AltUnity** (open-core) — embeds AltServer in the runtime, exposes scene hierarchy over a network API (C#/Python/Java clients). Repo prior-art records **Unreal added in v2.2 (UE 5.3–5.5)**; primary-source confirmation of the v2.x Unreal claim was **not cleanly re-verified in this pass** — **FLAG: verify against AltTester changelog before relying on it.** Bevy unsupported.

### 3.3 Black-box / engine-agnostic (shallow-but-universal)

- **modl.ai (`modl:test`)** — official page (2025): now **integrationless** — "no SDKs, plugins, or code changes; AI agents test externally, analyzing what's on screen and sending simulated inputs like a player," using **vision models + LLM reasoning + a skill library + Procedural Personas** (parameterized player archetypes). Detects visual glitches, missing assets, perf drops, logic bugs; emits bug reports with severity. **Stated platform compatibility: Unity, Unreal, custom engines via API.** [modl.ai] — *modl's own page does not list Godot/Bevy; treat any "Godot support" claim as unconfirmed.*
- **Airtest + Poco (NetEase)** — image-recognition + UI-hierarchy, engine-agnostic black-box [wetest.net].
- **Regression via pixels/OCR** — visual regression with perceptual-diff + tolerance thresholds and region-of-interest masking (ignore particles, compare HUD). Useful where semantic access is absent (esp. Godot/Bevy) but fragile.

### 3.4 AI-agent playtesting / RL test agents (mostly research → early-adoption)

- **Unity ML-Agents** — RL toolkit; can be **repurposed** as coverage/regression agents (record demonstrations → test scripts). **Unity-only.** Training cost is high; best on subsystems, not whole-game.
- **EA SEED** — curiosity-driven RL coverage agents; **research framework**, requires per-game state/action engineering; not a product.
- **modl.ai Procedural Personas; Ubisoft La Forge ML bots** — production-adjacent but bespoke/vendor [wetest.net; GDC].
- **LLM playtesting agents (2023–2025)** — generate test cases from NL, interpret footage; **hallucinate game elements** — assistive, not autonomous. (Mirrors the repo's own meta-lesson: AI summarizers confabulate engine APIs; verify against primary sources.)

### 3.5 Wrap-vs-build verdict for this vector

| Layer | Decision | Rationale |
|---|---|---|
| Engine-native unit/component tests | **WRAP** (UTF, GUT/GdUnit4, nextest, Unreal Automation/Gauntlet) | Mature, engine-owned; normalize to JUnit |
| Deep semantic + replay regression | **BUILD** (the factory's differentiator) | No tool spans all four engines; this is the empty quadrant |
| Shallow universal black-box agent | **WRAP one** (modl.ai-style or Airtest) | Cheap universal coverage incl. Godot/Bevy where deep SDKs don't reach |
| Perf/soak | **WRAP** profilers, **BUILD** the gates | Profilers exist; budget enforcement is the factory's job |
| Cert pre-flight | **BUILD** checklist engine, **WRAP** vendor validators | Vendor validators (GDK) are platform-specific |

---

## 4. Deterministic Replay-Regression (tie to determinism tiers)

This is the centerpiece and connects directly to **Decision 0003**.

### 4.1 The mechanism
Record **inputs keyed by sim frame** (sample once per fixed tick; record inside `FixedUpdate`/equivalent, NOT the render frame) → replay by injecting recorded inputs at tick boundaries → compare resulting game state. Prerequisites the adapter MUST expose (already in repo schema): **(a) fixed-timestep tick, (b) seeded/injectable RNG, (c) input injection at tick boundaries** [Unity input record/playback; Gaffer on Games].

### 4.2 Comparison method degrades by determinism tier (Decision 0003)

| Tier | Determinism guarantee | Example stack | Regression comparison | Source |
|---|---|---|---|---|
| `bitwise-cross-platform` | identical snapshot hash across OS/CPU | **Bevy + Rapier** | **golden-master / snapshot-hash diff** (exact) | rapier.rs (advertises cross-platform bitwise determinism) |
| `same-machine` | reproducible on one pinned image only | **Unity PhysX** ("Enhanced Determinism" + fixed timestep + re-created scene) | snapshot diff on **pinned CI runner** | NVIDIA forum (PhysX deterministic same-machine, *not* cross-HW) |
| `tolerance-only` | not reproducible bitwise | **Godot physics / FP-heavy sims** | **tolerance-window** metric diff (positions/velocities/unit-states ± epsilon at chosen frames) | RandomASCII / Gaffer FP determinism |

If an adapter lacks (a)-(c), it declares `replay: none` and regression falls back to **human-playtest evidence** (Decision 0003).

### 4.3 Sources of non-determinism the factory must control
Floating point (IEEE-754 rounding, x87 80-bit vs SSE 64-bit, compiler reordering — `/fp:strict`, `-ffp-contract`); transcendentals not vendor-matched; unseeded/over-consumed RNG; hash-iteration order (Bevy parallel ECS); dynamic spawn/destroy timing; memory-layout/cache effects; locale string compare [RandomASCII; Gaffer]. **Mitigation ladder:** fixed-point (Q16.16) for sim-critical math (also reported 3–5× faster), deterministic allocators, per-stream seeded RNG advanced by frame count.

### 4.4 Golden-master / characterization testing as the regression idiom
The general-software pattern **Characterization / Approval / Golden-Master / Snapshot testing** is the right frame: capture interesting outputs over varied inputs, build a regression net, diff future runs [understandlegacycode]. For games, "output" = serialized deterministically-relevant state (positions, velocities, collision/unit states) in a diffable format, **excluding** transient/render-only fields. **Desync diagnosis** needs first-class tooling: per-frame **checksums** to find the exact divergence frame + visual diffing [coherence.io]. **Deterministic Simulation Testing (DST)** (FoundationDB/Antithesis lineage — pluggable clocks/threads/RNG) is the maturity target for making rare bugs reproducible [Antithesis]. **Flakiness is the enemy:** tier-2/3 tolerance windows must be calibrated to avoid both false desyncs and masked regressions.

---

## 5. Playtest Protocols & Fun-Proxy Metrics (bridging without auto-scoring)

### 5.1 Why fun cannot be auto-scored (and the factory encodes this as a boundary)
Fun is a **latent, multidimensional, context- and goal-relative** construct overlapping enjoyment, flow, competence, tension, relatedness. The *same* telemetry signal is ambiguous: a long session = immersion **or** grind/sunk-cost; high death rate = satisfying mastery **or** unfair wall; arousal spike = excitement **or** fear/frustration. Any "fun score" embeds normative assumptions and invites optimization toward compulsion loops — an ethical/regulatory hazard. Therefore **fun stays human-judged by design** [Games User Research].

### 5.2 Structured human protocols (the factory orchestrates, humans judge)
- **Games User Research (GUR)** discipline; **structured > ad-hoc** (predefined research questions, recruitment criteria, tasks, analysis).
- **RITE** (Rapid Iterative Testing & Evaluation): fix-as-you-observe, team-consensus on issue reality, fast loops.
- **Formal usability / UX playtests** at vertical-slice/alpha/beta milestones.
- **Telemetry-instrumented playtests** + **remote playtests** (bridge small-n qualitative ↔ large-n live).
- **Think-aloud** (concurrent + retrospective) — recovers the *interpretive layer* (was a death "my fault" or "cheap"?).
- **Validated instruments** (decompose experience; do NOT output a single fun number): **GEQ** (competence/immersion/flow/tension/affect), **PENS** (autonomy/competence/relatedness per self-determination theory), **SUS** (usability).
- **Biometrics** (HR, EDA, eye-tracking, facial coding) — moment-to-moment *intensity* markers; ambiguous without self-report; lab-only.

### 5.3 Proxy metrics (machine-verifiable, interpreted by humans)
Retention (D1/D7/D30), session length/frequency, churn + leading indicators, **progression funnels** (drop-off localization), **difficulty/death heatmaps**, constructed **frustration signals** (rage-quit after a specific failure, rapid settings-toggling) and **flow proxies** (sustained play, self-initiated "one more level"). **Critical discipline:** proxies are **hypotheses about experience that must be validated against self-report**, never inherent truths.

### 5.4 The bridge (this is the factory's contract)
**Three-lens model: what players SAY (interviews/think-aloud/surveys) + what they DO (telemetry) + how the game BEHAVES (perf/crash).** When all three converge ("boss feels unfair" + death-rate spike + no perf issue) → act. When they diverge → investigate. **The factory's role:** instrument the telemetry, run/track the structured protocols, surface the convergence — and **hand the fun/feel verdict to a human gate.** It must NOT collapse this into a scalar.

---

## 6. Platform Certification & Store Requirements

Exact TRC/XR/Lotcheck text is **under NDA**; categories below are from public/vendor sources. The factory ships a **per-platform cert pre-flight checklist engine**.

### 6.1 What each platform requires (public categories)

| Platform | Framework | Representative categories | Machine-checkable share (vendor/practitioner est.) | Source |
|---|---|---|---|---|
| **Sony PlayStation** | **TRC** (~350+ reqs, all-pass, no partial credit) | Stability/no-crash (incl. disc-eject, account-switch, rest-mode), atomic save data, **rest/suspend-resume**, controller disconnect/reconnect + haptics/adaptive triggers, standardized **error messaging**, **trophies**, store/entitlements/PS+; **regional product codes** (Americas/Europe/Japan), GPP, symbol upload for retail crash symbolication | **~60–65%** | bugnet.io; room8studio |
| **Microsoft Xbox** | **XR** (v16.0, Nov 2025; policy + technical + product-component) | **XR-001 Title Stability** (start/responsive/clean-shutdown; suspend-resume incl. Connected Standby; >20s unresponsive = fail; >2min load w/o indicator = fail; no data loss), network resilience, controller, save/Smart-Delivery cross-gen, accessibility, achievements | **~75–80%** (GDK **Submission Validator** auto-runs at `makepkg pack`, catches ~80% of common failures) | learn.microsoft.com (XR-001, cert reqs, Submission Validator) |
| **Nintendo** | **Lotcheck** (NOA Lot Check) | Technical (stability, frame/mem budgets, **sleep/wake**, save integrity, Joy-Con/motion/HD-Rumble/IR, eShop/NSO) **+ content & culturalization review** (family-friendly content, localization). **~30-day pre-release submission window** | **~55–60% technical** (rest is content/creative review) | nintendo.fandom NOA Lot Check; room8studio |
| **PC — Steam** | Steamworks reqs + **Steam Deck Verified** | Steamworks API integration (auth, cloud saves, achievements); Deck: Steam Input/controller, perf consistency, input latency, display/resolution handling, audio | **~70–75%** of Deck verification | partner.steamgames.com/doc/steamdeck/compat |
| **PC — Epic** | EGS distribution reqs | Security/integrity, **Epic Online Services SDK**, auth/account, storefront/entitlements, Windows compatibility | **~65–70%** | dev.epicgames.com |
| **Age rating** | **IARC** questionnaire → ESRB/PEGI/etc. | Single questionnaire → multi-territory ratings; **largely automatable** (questionnaire), content disclosure human-completed | High (questionnaire) | globalratings.com |

> **All percentages are estimates from vendor docs / CI-vendor blogs / practitioner write-ups, not audited measurements. Flag as directional.** Cert frameworks version frequently (XR v16.0 dated Nov 2025) — **fast-moving; re-verify per submission.**

### 6.2 What a CI pipeline can pre-flight (the factory's cert gate)
Crash-under-adverse-input (disconnect controller, eject disc, force rest/suspend at arbitrary states), atomic-save verification (write-temp-then-rename under simulated power loss), suspend/resume state-restoration sequences, network packet-loss/latency/disconnect handling, frame-time budget conformance during scripted runs, shader-variant compilation across graphics APIs, asset-compression/naming/packaging checks, achievement/trophy API conformance, store-entitlement flow tests, symbol-archival per build [bugnet.io; Microsoft GDK; CircleCI mobile CI guidance].

### 6.3 What stays human in cert
Error-message *appropriateness/tone*, trophy/achievement *meaningfulness*, visual *polish*/flicker/animation-quality judgments, content appropriateness & culturalization (esp. Nintendo), HIG adherence nuance.

---

## 7. Telemetry & LiveOps

### 7.1 Telemetry/analytics pipeline (factory generates this as artifacts)
**Event taxonomy** (lifecycle / session / progression / economy / combat / social / technical) → instrumentation (named events + params + build/schema version) → batched ingestion → schema validation & QA (e.g., every `level_complete` preceded by `level_start`; non-negative balances) → warehouse → dashboards. Privacy/compliance (GDPR/COPPA): pseudonymize IDs, minimize PII, retention policy. Platforms to wrap: **GameAnalytics, Unity Analytics/UGS, deltaDNA** [gameanalytics.com; unity.com].

**Core KPIs:** DAU/MAU (+ ratio = stickiness), retention D1/D7/D30, ARPU/ARPPU, conversion, LTV, funnel completion, crash-free-session rate. **These are machine-verifiable health signals — NOT fun.** Ethics-conscious framing: treat monetization KPIs as **constraints alongside** experiential quality, not as proxies for player happiness.

### 7.2 LiveOps & post-launch
- **Patch/content cadence** — telemetry-informed (content-consumption rate, funnel bottlenecks); patch-validation tests on test servers before rollout.
- **Live A/B testing** — randomized variant assignment; clear hypotheses + success criteria; adequate power; correct for multiple comparisons; can include experiential outcomes (PENS/GEQ subscales), not just retention.
- **Live events/seasons** — measure participation/uplift/event-retention via telemetry; gauge fatigue/FOMO via post-event surveys (human).
- **Feature flags / remote config** — LaunchDarkly / UGS / in-house; **flag state must be logged into telemetry** so cohorts are separable; enables soft-launch and instant rollback.
- **Crash/error reporting** — **Sentry, Backtrace (Sauce Labs), Unity Cloud Diagnostics, Firebase Crashlytics, GameBench**; crash-free-session rate is a hard hygiene gate (its failure is sufficient for churn even if design is great) [sentry.io; firebase Crashlytics].

### 7.3 Performance / soak / stress (machine-verifiable)
Frame budgets: 16.6 ms @ 60 fps, 33 ms @ 30 fps; **1%/0.1%-low FPS** (slowest frames — perceived hitching) [perf talks]. **Memory soak/endurance**: 8–72 h runs watching leaks/fragmentation (Unity GC Used vs Reserved; the "blue section" non-last allocations) [Testlio soak; Unity mem-profiler]. **Server load/stress** for online. **Automated perf regression gates** in CI (baseline + flag regressions) [Tracy; PIX/RenderDoc/Unity Profiler]. **Thermals** on handhelds (Steam Deck/Switch). Note: 75% of PS5 players reportedly pick performance mode — perf budgets are a top-tier acceptance concern. **Boundary:** budgets are objective; whether on-budget *feels* smooth is a playtest judgment.

---

## 8. Machine-Verifiable vs Human-Judgment Matrix

| Quality dimension | Verification | Factory mechanism | Gate type |
|---|---|---|---|
| Simulation correctness / regression | **Machine** (tier-dependent) | Deterministic replay → hash diff (T1) / pinned-runner diff (T2) / tolerance diff (T3) | CI gate |
| No-crash under adverse input | **Machine** | Cert pre-flight scenarios | CI gate |
| Perf budgets (frame/mem/soak/thermal) | **Machine** | Profiler-wrapped CI gates | CI gate |
| Cert checklist (TRC/XR/Lotcheck technical) | **Machine** (55–80%) | Cert pre-flight engine + wrapped vendor validators | CI gate |
| Telemetry coverage / event-taxonomy integrity | **Machine** | Schema validation, event-precedence checks | CI gate |
| Crash-free-session rate (live) | **Machine** | Wrapped crash reporters | LiveOps SLO |
| Functional coverage (emergent cases) | **Mixed** | Black-box AI agent (modl.ai-style) + RL coverage agents | Advisory + human triage |
| Onboarding clarity / usability | **Human** (structured) | RITE + usability playtests + SUS | Human gate |
| Fun / feel / flow / fairness | **Human** (triangulated) | 3-lens (say/do/behave) + GEQ/PENS + proxy metrics | **Human gate — never auto-scored** |
| Polish / visual quality / animation | **Human** | Playtest + visual-regression *assist* | Human gate |
| Content appropriateness / culturalization | **Human** | Loc/content review (esp. Nintendo) | Human gate |

---

## 9. Genre Variation

| Genre | Determinism tier fit | QA emphasis shift | Fun-proxy emphasis |
|---|---|---|---|
| **RTS / deterministic-sim** | T1 ideal (lockstep replays demand it) | Heavy replay-regression; desync tooling critical | Match-balance, comeback potential |
| **Fighting** | T1/rollback (GGPO) | Frame-perfect input replay; rollback resim correctness | Input-latency feel, hit-confirm fairness |
| **FPS / action** | T2 typical (Unity/PhysX) | Perf budgets + hit-reg + soak; pinned-runner regression | TTK feel, responsiveness |
| **Open-world / RPG** | T2/T3; FP-heavy | Coverage agents + funnels + soak (long sessions); tolerance regression | Progression pacing, quest funnels |
| **Narrative / adventure** | T3 acceptable | Branch coverage, softlock detection; retention is a poor success proxy | Emotional arc (think-aloud/biometrics), not retention |
| **Puzzle / casual / mobile** | T2/T3 | Funnel/onboarding clarity; A/B heavy | Early-level funnel, tutorial comprehension |
| **Live-service / F2P** | varies | LiveOps spine dominant; live A/B, events, economy health | Retention + fairness (avoid dark-pattern optimization) |
| **Sandbox / creative** | T3 | Stability/soak; goal-relative success | Autonomy (PENS) — retention/progression mislead |

**Implication:** the factory's acceptance criteria must be **genre-parameterized**. Retention is a *valid* proxy for live-service but a *misleading* one for narrative/sandbox — the factory must not hard-code one success function.

---

## 10. Factory Artifacts / Contracts This Discipline Implies

The factory should **produce and verify** these as first-class artifacts:

1. **`replay-regression-contract`** — per-scenario recorded input track (keyed by sim frame) + expected golden state (hash for T1; snapshot for T2; tolerance window + epsilon for T3). The DTU-analog. **Gated by `determinism_tier`.**
2. **`determinism-tier-declaration`** (exists, Decision 0003) — adapter declares tier + replay prerequisites (fixed tick / seeded RNG / input injection); conformance suite **verifies** it (T1 must reproduce identical hash across two runners).
3. **`test-suite-manifest`** — normalized JUnit/NUnit-XML results from wrapped engine-native runners (UTF/GUT/GdUnit4/nextest/Unreal Automation).
4. **`cert-preflight-checklist`** — per-target-platform machine-checkable requirement set (crash/suspend-resume/save-atomicity/controller/network/shader/packaging) + pass/fail report; wraps vendor validators (GDK Submission Validator) where available.
5. **`perf-budget-contract`** — frame-time (CPU/GPU ms) + 1%/0.1%-low thresholds + memory-soak duration/leak limits + thermal limits; CI gate with baseline + regression detection.
6. **`telemetry-event-taxonomy`** — generated, versioned event schema + instrumentation + ingestion validation (event-precedence, balance-sanity). Includes privacy/retention policy.
7. **`kpi-dashboard-spec`** — DAU/MAU, retention, funnels, ARPU/ARPPU, conversion, crash-free rate — **labeled machine-verifiable, explicitly NOT fun.**
8. **`playtest-protocol`** — structured protocol artifact (research question, recruitment, tasks, instruments GEQ/PENS/SUS, think-aloud plan) + a **3-lens convergence report** that the **human gate** signs.
9. **`liveops-runbook`** — patch/content cadence plan, A/B experiment specs (hypothesis/success-criteria/power), feature-flag + remote-config wiring (flag-state logged to telemetry), live-event measurement plan.
10. **`crash-reporting-wiring`** — Sentry/Crashlytics/Cloud-Diagnostics integration + symbol-archival-per-build + crash-free-session SLO.

---

## 11. AAA Acceptance Bar

A genre-/platform-parameterized gate. To claim "AAA-ready," a factory output must clear:

- **Determinism/regression:** declared tier verified by conformance; replay-regression green at the tier-appropriate strictness (exact hash for T1; pinned-runner snapshot for T2; calibrated tolerance for T3). Zero unexplained desyncs.
- **Stability:** no crash/softlock under the cert adverse-input battery; crash-free-session rate above platform SLO.
- **Performance:** frame budget met for the target mode (60 fps perf / 30 fps quality) incl. 1%/0.1%-low thresholds; passes 8–72 h soak with no leak; within thermal envelope on handheld targets.
- **Certification:** **0 failures** on the machine-checkable cert pre-flight for each target platform (Sony all-pass model leaves no partial credit); human-judged cert items reviewed.
- **Telemetry:** event-taxonomy schema-valid; required KPI coverage instrumented; crash reporting + symbolication wired.
- **Experiential (HUMAN gate):** structured playtest run; 3-lens convergence reviewed; usability (SUS) and need-satisfaction (PENS) above target; **a human signs the fun/feel/polish verdict.** This gate is **mandatory and non-automatable** — it is the explicit boundary of the machine-verifiable pipeline.

---

## 12. Open Questions & Risks

1. **Cross-engine deep-test tier is genuinely unbuilt for Godot/Bevy.** GameDriver = Godot Beta / no Bevy; AltTester = no Bevy. The factory's deep tier for Godot/Bevy is **build-from-scratch on the replay spine** (Bevy's **BRP** introspection is an asset here, per repo research). **Risk:** scope/cost.
2. **AltTester v2.x Unreal support unverified this pass** — confirm against changelog before architecture relies on it.
3. **Cert % estimates are directional, not audited**, and frameworks version frequently (XR v16.0 Nov-2025). NDA blocks exact requirement text — the pre-flight engine must be built against *categories* + each studio's own NDA'd checklist, and **re-validated per submission cycle**. Fast-moving.
4. **Tolerance-window calibration (T2/T3)** is a flakiness minefield — too tight = false desyncs, too loose = masked regressions. Needs a principled epsilon-selection method (validate against human-confirmed regressions).
5. **modl.ai-style black-box agents** give breadth but **shallow** signal (no deep state assertions) and add a vendor dependency + cost; bug-triage (real defect vs intended behavior) still needs humans.
6. **Fun-gate human-in-loop is a throughput bottleneck** by design. The factory must make it *cheap and structured* (protocol templates, instrument automation, convergence dashboards) without ever tempting an auto-score — the precise anti-pattern this vector forbids.
7. **Telemetry ethics / dark-pattern risk** — optimizing KPIs (ARPU/retention) can degrade player welfare; the factory should encode monetization KPIs as constraints, not objectives.
8. **DST maturity** (pluggable clocks/threads/RNG) is the long-term target for rare-bug reproducibility but is non-trivial to retrofit per engine.

---

## 13. Sources

See YAML `sources` block (front-matter) for full URL list. Key primary/authoritative sources:

- **Certification:** Microsoft GDK cert reqs + XR-001 + Submission Validator (learn.microsoft.com); Sony cert/crash practice (bugnet.io); Nintendo NOA Lot Check (nintendo.fandom); Steam Deck compat (partner.steamgames.com); Epic EGS reqs (dev.epicgames.com); IARC (globalratings.com); practitioner submission guide (room8studio.com).
- **Tool support (primary, cross-validated):** GameDriver 2023.04 release blog (engine support matrix); modl.ai official tools page + site (integrationless agents, platform compat); WeTest AI-testing landscape survey.
- **Determinism:** rapier.rs (cross-platform bitwise); NVIDIA PhysX determinism forum; RandomASCII + Gaffer on Games (FP determinism); Unity input record/playback; coherence.io (rollback/lockstep); understandlegacycode (characterization/golden-master); Antithesis (DST).
- **Perf/soak:** Testlio (soak), Tracy (profiling), Unity memory-profiler discussions.
- **Playtest/telemetry:** *Games User Research* (Drachen/Mirza-Babaei/Nacke 2018), *Game Analytics* (El-Nasr/Drachen/Canossa 2013); GameAnalytics, Unity Analytics/UGS, deltaDNA; Sentry, Firebase Crashlytics, Unity Cloud Diagnostics.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 5 | Deep multi-source synthesis on: (1) AAA QA + automated/AI test tooling, (2) platform certification (TRC/XR/Lotcheck/Steam/Epic) machine-vs-human, (3) test-automation tool/engine support matrix, (4) playtest protocols + fun-proxy metrics + telemetry/LiveOps, (5) deterministic replay-regression + perf/soak. All `reasoning_effort: high`, `strip_thinking: true`. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — |
| Tavily tavily_search | 3 | Primary-source cross-validation of fast-moving tool claims: AltTester engine support, GameDriver engine support (confirmed Godot=Beta, no Bevy), modl.ai platform compat (confirmed Unity/Unreal/custom-API, integrationless). Corrected over-optimistic secondary-summarizer claims. |
| Tavily tavily_research | 0 | — |
| Tavily tavily_extract | 0 | — |
| WebFetch / WebSearch | 0 | — |
| Repo files (Read/Grep/Glob) | ~8 | Grounded determinism tiers (Decision 0003), RECONCILIATION, prior-art, product-brief — to tie replay-regression to existing capability schema. |
| Training data | 2 areas | Games-QA discipline framing + general CI patterns — corroborated by cited sources; flagged where vendor estimates (cert %) are non-audited. |

**Total MCP tool calls:** 8 (5 `perplexity_research` + 3 `tavily_search`)
**Training data reliance:** low — every load-bearing claim is sourced to a cited URL or repo artifact; cert percentages explicitly flagged as vendor/practitioner estimates; one Perplexity tool-support claim (GameDriver Godot, modl.ai Godot) was overridden by primary-source Tavily cross-validation; AltTester-Unreal-v2.x flagged as un-reverified.

**Note on a deviation:** the first `perplexity_research` QA-tooling call initially returned a training-cutoff disclaimer (refused to assert "2025-2026" state); it was re-run with a reframed, web-forcing system prompt that produced fully-sourced output. This is why the QA-tooling topic shows two underlying calls folded into the "5" count.
