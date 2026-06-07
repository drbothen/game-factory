# Bevy Game Engine — Factory-Adapter Capability Research

**Subject:** Bevy game engine (Rust) — fitness for an automated, headless, CI-driven game-development factory
**Date of findings:** 2026-06-07. Bevy landscape moves fast; treat version-specific claims as "as of" this date.
**Current versions (verified):** Stable **0.18.1** (2026-03-04); **0.19.0-rc.2** (2026-05-22) in RC. Prior majors: 0.17 (late 2025), 0.16 (2025-04-24), 0.15 (2024-11-29). [crates.io, lib.rs]

> **Research-quality warning:** Perplexity's deep-research tool produced **substantial confabulation** on this topic — it invented APIs (`HeadlessPlugins`, `EasyScreenshotPlugin`, `AssetValidator` trait, `#[bevy_test]` macro, `bevy_test` crate, `App::update_n()`, `cargo bevy` subcommands, `bevy_ecs_lints`, `cargo hatchet`), invented case studies (Ubisoft/Frostbite/Amazon/ISO-26262), and falsely attributed Bevy's authorship to Embark Studios (Bevy was created by Carter Anderson / "cart"). **Every load-bearing claim below was re-verified against primary sources** (the actual Bevy GitHub example files, docs.rs API pages, and official migration guides). Where Perplexity contradicted primary sources, the primary source wins and is flagged.
>
> **Meta-lesson for the factory:** verify Bevy API claims against the actual example file in `github.com/bevyengine/bevy/blob/<version-tag>/examples/...` and `docs.rs/bevy/<exact-version>/...`, not against AI summarizers.

---

## 1. build — headless/CI build invocation

**Feasible: YES. Fidelity: FULL. Native.**

Bevy is a normal Rust crate; CI build is `cargo build` / `cargo build --release`. The factory-relevant lever is **Cargo feature flags** to strip rendering for faster, GPU-free builds:

- `cargo build --no-default-features --features <subset>` disables the default feature set (which pulls in `bevy_render`, `bevy_winit`, windowing, audio, etc.). [docs.rs/bevy feature list]
- Bevy's modular crate architecture (`bevy_render`, `bevy_window`, `bevy_winit`, `bevy_pbr`, `bevy_sprite`, `bevy_ui`, etc.) means you can compile a logic-only / server build with no graphics stack. The `examples/app/headless.rs` example is itself built with default features off and only `bevy_log` enabled.
- **Caveat:** transitive feature dependencies are real — some subsystems implicitly require others. You reconstruct the minimal feature set by trial; there is **no** `cargo bevy features` helper (confabulated).

**Verdict:** Native, full fidelity. `cargo build`, with `--no-default-features` as the documented headless lever.
Sources: https://docs.rs/bevy/latest/bevy/ ; https://github.com/bevyengine/bevy/blob/main/examples/app/headless.rs

---

## 2. test — framework + machine-readable output

**Feasible: YES. Fidelity: FULL (machine-readable via nextest). Native (Rust) + ecosystem (nextest).**

- **Framework:** Standard Rust `cargo test` / libtest. There is **no** official `bevy_test` crate or `#[bevy_test]` macro (confabulated). Bevy ECS tests construct an `App`, add systems/plugins, call `App::update()` one or more times, then assert on `World` state via `world.query::<&Component>()` / `world.resource::<R>()`. (`App::update_n()` does **not** exist as of 0.18 — confabulated; loop `update()`.)
- **Machine-readable output — two real paths:**
  1. **cargo-nextest (recommended for CI).** Produces **JUnit XML** via `[profile.ci.junit] path = "junit.xml"` in `.config/nextest.toml`. Each test binary → one `<testsuite>`, each test → one `<testcase>`. Nextest also has an experimental libtest-JSON message-format output. **Verified against nexte.st primary docs.** Cleanest schema for a factory harness.
  2. **libtest JSON directly:** `cargo test -- -Z unstable-options --format json` — works but is **nightly-gated and unstable**; nextest's JUnit is the more stable choice.
- **Bevy's own CI** runs tests via a custom xtask: `cargo run -p ci -- test` (verified in `.github/workflows/ci.yml`).

**Verdict:** Full fidelity. **Recommend cargo-nextest → JUnit XML** as the factory's machine-readable test contract; libtest-JSON is a fallback.
**Contradiction flag:** the claim that `cargo test --format json` is "effectively stable" is misleading — it remains nightly-unstable. The reliable machine-readable path is nextest JUnit.
Sources: https://nexte.st/docs/machine-readable/junit/ ; https://github.com/bevyengine/bevy/blob/main/.github/workflows/ci.yml ; https://docs.rs/bevy/latest/bevy/app/struct.App.html

---

## 3. run_headless + determinism

**Headless run: YES, FULL, native. Deterministic simulation: FEASIBLE but DIY + caveats.**

**Headless execution (verified against `examples/app/headless.rs`):**
- Pattern: `App::new().add_plugins(DefaultPlugins.set(ScheduleRunnerPlugin::run_once())).run();` or `ScheduleRunnerPlugin::run_loop(Duration::from_secs_f64(1.0/60.0))`.
- Example builds with default features OFF and only `bevy_log` — **no GPU, no window required** for logic-only. `ScheduleRunnerPlugin` replaces the winit event loop. First-class supported pattern.
- **There is no `HeadlessPlugins` plugin group** (confabulated). The real mechanism is `MinimalPlugins`, or `DefaultPlugins` with `ScheduleRunnerPlugin` + features stripped.

**Determinism primitives:**
- **Fixed timestep: NATIVE.** `FixedUpdate` schedule + `Time<Fixed>` resource; `Time::<Fixed>::from_hz(...)`. Sim systems go in `FixedUpdate` reading `Time<Fixed>`, not `Time<Virtual>`. [docs.rs/bevy/.../time/struct.Fixed.html]
- **Seeded RNG: DIY via standard ecosystem crate `bevy_rand` (+ `bevy_prng`).** Bevy ships no built-in global RNG. `bevy_rand` wraps the Rust `rand` ecosystem in ECS-friendly resource/component types with reflection + serialization (matters for rollback snapshots).
- **ECS execution determinism — IMPORTANT CAVEAT:** Bevy runs systems **in parallel and non-deterministically by default**. Official ECS docs: "By default, the execution of systems is parallel and not deterministic." You must impose order with `.before()`/`.after()`, `.chain()`, `configure_sets()`. Other non-determinism sources: hash-map/`HashSet` iteration order, query iteration order, `par_iter()` thread scheduling, FP variance across platforms. Deterministic lockstep is feasible — `bevy_ggrs` (GGRS rollback netcode) is the proof — but **engineering-intensive**, not free.

**Verdict:** Headless run = full/native. Fixed timestep = native. Seeded RNG = standard crate. **Deterministic simulation = feasible but DIY** — the factory cannot assume determinism by default; it must enforce system ordering, deterministic RNG seeding, avoid hash iteration in sim code. Cross-platform bit-exact determinism (FP) is hardest, may require fixed-point.
Sources: https://github.com/bevyengine/bevy/blob/main/examples/app/headless.rs ; https://docs.rs/bevy/latest/bevy/time/struct.Fixed.html ; https://docs.rs/bevy/latest/bevy/ecs/system/index.html ; https://docs.rs/bevy_rand/latest/bevy_rand/ ; https://github.com/gschup/bevy_ggrs

---

## 4. replay — input recording/playback

**Feasible: YES. Fidelity: PARTIAL/FULL depending on crate. NOT native — DIY-on-ECS or via ecosystem crate.**

- Bevy core has **no native input record/replay**. Build it on the ECS (capture input events per fixed tick into a serializable buffer; replay by injecting them) or use a crate.
- **`leafwing_input_playback` (Leafwing-Studios)** is purpose-built: `InputCapturePlugin` records keyboard/mouse/gamepad to `TimestampedInputs`, **serializes to disk**, `InputPlaybackPlugin` replays (with `PlaybackStrategy`); captures `AppExit` to auto-close TAS/test runs. Exactly a factory replay primitive.
- For deterministic rollback-style replay, **`bevy_ggrs`** provides input-driven state advancement + snapshot/restore.

**CAVEAT (version lag — flag):** `leafwing_input_playback` historically **trails the latest Bevy version by one or more releases**. Could not confirm exact current Bevy pin as of June 2026 (crates.io fetch failed) — treat 0.18/0.19 compatibility as *unverified, likely-lagging*. Confidence: MEDIUM. The factory may pin Bevy to the replay crate's supported version, or maintain its own thin ECS-based recorder (low effort: serialize `ButtonInput`/event state each `FixedUpdate` tick).

**Verdict:** Replay is **DIY-on-ECS**, well-supported by a dedicated crate, but crate version-lag is a real coupling risk. A self-built fixed-tick recorder is a robust fallback.
Sources: https://github.com/Leafwing-Studios/leafwing_input_playback ; https://github.com/gschup/bevy_ggrs

---

## 5. capture — screenshot/video/frame capture (especially WHILE headless)

**Assumption "Bevy can do headless + capture simultaneously via offscreen render" → CONFIRMED, with an important correction about HOW.**

**Feasible: YES — headless offscreen render-to-image is officially supported. Fidelity: FULL for stills; video = DIY (frame sequence → encoder). Native example exists.**

Verified directly against **`examples/app/headless_renderer.rs`** (primary source):
- Runs with **no window**: `WindowPlugin { primary_window: None, exit_condition: ExitCondition::DontExit }`, `.disable::<WinitPlugin>()` (comment: "WinitPlugin will panic in environments without a display server"), `ScheduleRunnerPlugin::run_loop(...)`.
- Renders to an **offscreen texture**: camera `RenderTarget::Image(...)`, target via `Image::new_target_texture(w, h, TextureFormat::Rgba8UnormSrgb, ...)` + `TextureUsages::COPY_SRC`.
- Reads pixels back via **manual GPU readback**: `ImageCopier` component, `encoder.copy_texture_to_buffer()`, `buffer_slice.map_async(MapMode::Read, ...)`, `render_device.poll(PollType::wait_indefinitely())`, then `image::save()` to PNG. It does **NOT** use the `Screenshot` component for this path (Perplexity claimed it did — wrong; `Screenshot` exists for windowed capture, the canonical headless example uses manual `ImageCopier` readback).

**CRITICAL CORRECTION to "no GPU":** Headless capture is **windowless, but NOT graphics-stack-less.** Offscreen render still requires a wgpu adapter/device — i.e., **a real GPU *or* a software Vulkan implementation (Mesa lavapipe/`lvp`)**. There is no zero-graphics render path. On a GPU-less CI runner you must install a software Vulkan ICD:
- Bevy's own CI does exactly this — runs screenshot/example tests on GPU-less GitHub Actions runners using **lavapipe** (software Vulkan), via a composite action (`./.github/actions/install-linux-deps`). wgpu targets Vulkan and binds lavapipe via the Vulkan loader (`VK_ICD_FILENAMES`/`VK_DRIVER_FILES`, optionally `WGPU_BACKEND=vulkan`).

**Verdict:** **Assumption holds — Bevy does headless + capture simultaneously via offscreen render-to-texture.** Caveat: needs a wgpu backend (real GPU or software lavapipe); plan CI to install lavapipe. Video is not native — emit a numbered frame sequence and pipe to ffmpeg. Performance under lavapipe is slow (software raster); fine for low-FPS capture/golden-image tests, not high-throughput.
**Key distinction vs Unity/Godot:** Bevy needs a software-GPU **but stays windowless** (no xvfb / virtual X display required — just the Vulkan ICD). Unity/Godot must *drop their headless flag* and run under xvfb + software GPU. So Bevy's capture is genuinely cleaner, but "headless = zero graphics" is still false.
**Contradiction flags:** (a) `EasyScreenshotPlugin` is fabricated; (b) headless example uses `ImageCopier`/manual readback, not `Screenshot::from_target(...)`; (c) "true headless needs no GPU" is FALSE — needs a software-or-hardware wgpu backend.
Sources: https://github.com/bevyengine/bevy/blob/main/examples/app/headless_renderer.rs ; https://github.com/bevyengine/bevy/blob/main/examples/app/headless.rs ; https://docs.rs/bevy/latest/bevy/render/view/window/screenshot/struct.Screenshot.html ; https://github.com/gfx-rs/wgpu

---

## 6. lint — clippy/format

**Feasible: YES. Fidelity: FULL. Native (standard Rust tooling).**

- `cargo clippy` and `cargo fmt` — standard Rust. No special Bevy lint crate required. **`bevy_ecs_lints` and `cargo bevy lint` do NOT exist** (confabulated).
- Bevy's repo enforces fmt + clippy via its xtask: `cargo run -p ci -- lints`. There IS a real, separate **`bevy_lint`** tool (the Bevy Linter, part of `bevy_cli`) offering Bevy-specific lints — optional, not required. (Distinct from the fabricated `bevy_ecs_lints`.)
- Matches the factory's own existing gate philosophy (`cargo fmt --check --all && cargo clippy --workspace --all-targets -- -D warnings`).

**Verdict:** Full fidelity, native, trivially integrable.
Sources: https://github.com/bevyengine/bevy/blob/main/.github/workflows/ci.yml ; standard Rust clippy/rustfmt docs.

---

## 7. assets_validate — asset import validation

**Feasible: YES, but DIY. Fidelity: PARTIAL. NOT a build-time native validator.**

- Bevy's `AssetServer` loads assets **asynchronously** and emits **warnings/errors at runtime**, not at build time. A failed load does not hard-fail the app by default. **There is NO `AssetValidator` trait / `AssetPlugin { validator: ... }` API** (fabricated).
- Real mechanisms to compose into a validation harness:
  - **`AssetServer::load` + `LoadState`** — poll `asset_server.get_load_state(handle)`; assert all reach `LoadState::Loaded` (fail on `LoadState::Failed`) inside a **headless test app** (`App::update()` loop until settled). Genuine "do all assets load without error" CI coverage.
  - **Asset processing pipeline / `.meta` files** — `AssetProcessor` (processed-assets mode) converts/validates at process time, writes `.meta` (RON) sidecars. Real but opt-in, still runtime/processing not compile-time.
- Because asset paths can be constructed dynamically, **static "all referenced assets exist" verification is not possible** in general — only assets actually triggered for load.

**Verdict:** Partial. The factory must **build its own asset-validation test** (headless app loads every asset dir entry, asserts `LoadState::Loaded`). No native build-time validator.
Sources: https://docs.rs/bevy/latest/bevy/asset/

---

## 8. introspect — dumping ECS world / entity-component state

**Feasible: YES. Fidelity: FULL. NATIVE — a standout strength.**

1. **Bevy Remote Protocol (BRP) — the killer feature for a factory.** A native **JSON-RPC 2.0** server over HTTP exposing the live ECS world for query/mutation by an external process. `RemotePlugin` (core) + `RemoteHttpPlugin` (HTTP transport). **Introduced in Bevy 0.15** (Nov 2024).
   - **API-CHURN ALERT — method names RENAMED in 0.17:**
     - **0.15–0.16 (slash-namespaced):** `bevy/query`, `bevy/get`, `bevy/list`, `bevy/spawn`, `bevy/insert`, `bevy/remove`, `bevy/destroy`, `bevy/reparent`, `registry/schema`, `bevy/get+watch`, `bevy/list+watch`.
     - **0.17+ (PR #19377, dot-namespaced):** `world.query`, `world.get_components`, `world.list_components`, `world.spawn_entity`, `world.insert_components`, `world.remove_components`, `world.despawn_entity` (note `destroy`→`despawn`), `world.reparent_entities`, `world.mutate_components`, resource variants, `registry.schema`, `rpc.discover`, plus `+watch` streaming variants.
   - Exactly what a factory wants: programmatically query entity/component state of a running headless game over a stable wire protocol, assert on it, drive scenarios. Default HTTP port commonly **15702** (ecosystem convention, not a hard guarantee).
2. **`bevy_reflect`** — runtime reflection over components/types; foundation under BRP + scene serialization.
3. **Scene serialization** — `DynamicScene` / `DynamicSceneBuilder` serializes the World (or subset) to **RON** — human-readable, diffable world dump (great for golden-snapshot tests).
4. **Inspector crates** (interactive, optional): `bevy-inspector-egui`; for headless/programmatic use, BRP is the right tool.

**Verdict:** Full fidelity, native. **BRP makes Bevy unusually factory-friendly for introspection** — a JSON-RPC interface to the live ECS is precisely the machine-readable hook an automated factory needs. The 0.17 method rename is the main version-pin gotcha.
Sources: https://docs.rs/bevy/0.18.1/bevy/remote/builtin_methods/index.html ; https://bevy.org/learn/migration-guides/0-16-to-0-17/ ; https://bevy.org/news/bevy-0-15/ ; https://docs.rs/bevy_remote ; https://docs.rs/bevy/latest/bevy/reflect/ ; https://docs.rs/bevy/latest/bevy/scene/

---

## Major caveats & API-churn risk

1. **Rapid API churn is the #1 risk.** Bevy is pre-1.0 and ships breaking changes **every ~3 months**. Verified examples in 0.15→0.18: BRP methods renamed (0.17); `Parent`→`ChildOf`; `EventWriter::send`→`write`; buffered `Event`→`Message`; `Query::to_readonly`→`as_readonly`; `Trigger::entity`→`target`; easing-function changes flagged as determinism-affecting. **An engine-adapter must pin an exact Bevy version and budget per-release migration.** Every minor version is a potential adapter break.
2. **Ecosystem crates lag core.** `bevy_ggrs`, `bevy_rand`, `leafwing_input_playback`, `leafwing-input-manager` each trail latest Bevy by 0–2 releases. The factory's effective Bevy version is gated by the *slowest* required crate (likely the replay crate). Confidence on exact pins: MEDIUM.
3. **Capture needs a graphics backend.** Headless ≠ GPU-less. Install **lavapipe** (software Vulkan). Software raster is slow — golden-image/low-FPS only.
4. **Determinism is opt-in, not default.** Parallel scheduling + hash iteration + FP make Bevy non-deterministic out of the box. Cross-platform bit-exact is hard (may need fixed-point).
5. **Asset validation is DIY.** No native build-time validator; build a load-state test harness.

---

## Bottom line: how factory-friendly is Bevy?

**Bevy is surprisingly factory-friendly — arguably more so than most game engines — for the *mechanics* of automation, but it demands disciplined version-pinning and non-trivial DIY glue.** Build/test/lint are pure-Rust and effectively free (full fidelity via `cargo` + nextest JUnit + clippy/fmt). Headless run is first-class (`ScheduleRunnerPlugin`, no window/GPU for logic-only). Two standout strengths: **(a) the Bevy Remote Protocol**, a native JSON-RPC introspection interface almost purpose-built for an external automated harness, and **(b) confirmed headless offscreen render-to-texture capture** — provided CI ships a software Vulkan backend (lavapipe), and notably without needing a virtual display (windowless). The weaker DIY-on-ECS areas: **replay** (`leafwing_input_playback` or a fixed-tick recorder), **deterministic simulation** (feasible via `bevy_ggrs` + `bevy_rand`, but opt-in and engineering-heavy), and **asset validation** (no native build-time validator). The dominant risk is **pre-1.0 API churn** (~quarterly breaking changes, verified BRP/ECS renames within 0.15→0.18) plus **ecosystem-crate version lag** — so the Bevy adapter should pin one exact version, wrap BRP and the example-derived headless/capture patterns behind the adapter boundary, and treat each Bevy minor release as a scheduled adapter-maintenance event.
