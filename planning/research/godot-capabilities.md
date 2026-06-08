# Godot Engine (4.x) — Factory-Adapter Capability Research

**Research date:** 2026-06-07
**Engine version scope:** Godot 4.x (4.2–4.4), GDScript + C# (.NET)
**Purpose:** Assess Godot as a third "engine adapter" alongside Bevy (compiled, code-first, ECS, trivial headless+capture) and Unity (editor-first, `-nographics` conflicts with capture). Hypothesis under test: *Godot sits between Bevy and Unity on every axis, making it the cheapest third adapter.*

All claims below distinguish **official Godot docs** from **community/third-party** sources, and **confirmed** from **inferred**. Version-volatile claims are date-stamped.

---

## 1. `build` — Headless/CI Export

**Feasible: YES. Fidelity: FULL. Native.**

- The export flags are `--export-release` and `--export-debug`; `--headless` is an **independent** display-server flag, not part of the export verb. Documented canonical form (official docs): `godot --headless --path /path/to/project --export-release "<preset name>" <output_path>`. ([docs.godotengine.org/exporting_projects](https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html))
- `--headless` is officially supported since Godot 4.0 to run "on any platform … on a machine that doesn't have a GPU or display server." ([docs.godotengine.org/exporting_for_dedicated_servers](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html))
- **Export-templates workflow caveat:** Templates (`.tpz` archive) MUST be pre-installed; export fails without them (official docs confirm requirement). There is **no documented CLI flag** to download/install templates (e.g. no `--install-templates`) — confirmed absent from official docs. CI practice is to unpack the `.tpz` into the templates directory (self-contained mode uses `editor_data/templates` next to the binary) or bake it into the runner image. This is a community-established pattern, not an official "CI recipe." ([yockyard.com Godot CI/CD](https://www.yockyard.com/post/setting-up-a-godot-cicd-server/), [TeamCity/JetBrains Godot CI](https://blog.jetbrains.com/teamcity/2024/10/automating-godot-game-builds-with-teamcity/))
- Works in Docker / GitHub Actions with no display server, confirmed by both official dedicated-server docs and multiple 2024–2026 CI walkthroughs.

**vs Bevy/Unity:** Bevy build is `cargo build` — trivially CI-native, nothing to install. Unity requires the full Editor + activated license + `-batchmode -quit -executeMethod BuildPipeline...`, plus license-server friction. **Godot lands between:** lighter than Unity (no license, no Editor GUI required at build time), heavier than Bevy (one out-of-band template-install step). **Hypothesis HOLDS.**

---

## 2. `test` — Test Frameworks & Machine-Readable Output

**Feasible: YES. Fidelity: FULL (GDScript) / FULL (C#). DIY-leaning (third-party frameworks, not engine-native).**

### GUT (GDScript) — bitwes/Gut
- Has a **CLI runner**: `addons/gut/gut_cmdln.gd`. Documented invocation: `godot -d -s --path $PWD addons/gut/gut_cmdln.gd` with options like `-gtest=`, `-gexit`. ([gut.readthedocs.io/Command-Line](https://gut.readthedocs.io/en/godot_3x/Command-Line.html))
- **JUnit XML: CONFIRMED.** README claims "Export results in standard JUnit XML format"; docs expose `-gjunit_xml_file` and `-gjunit_xml_timestamp`. ([github.com/bitwes/Gut](https://github.com/bitwes/Gut)) This is the key CI-friendly fact — machine-readable output exists natively in the framework.
- Runs under Godot CLI; `--headless` compatible in practice (community CI uses it). Note: the cited CLI doc page is the `godot_3x` branch; GUT does have an actively maintained Godot 4 line (verify the 4.x docs branch for any flag drift — minor risk).

### GoDotTest (C#) — chickensoft-games/GoDotTest
- C# test runner, **command-line capable**: tests run *inside the game* via `GoTest.RunTests(...)`, triggered by passing `--run-tests --quit-on-finish` to the Godot binary. Versioning: **use `> 1.0.0` for Godot 4.x**, `<= 1.0.0` for Godot 3.x. ([github.com/chickensoft-games/GoDotTest](https://github.com/chickensoft-games/GoDotTest), [NuGet Chickensoft.GoDotTest](https://www.nuget.org/packages/Chickensoft.GoDotTest/))
- Code coverage via coverlet (lcov) + reportgenerator — confirmed.
- **JUnit XML: UNCONFIRMED.** Sources confirm lcov coverage output but I could **not** verify native JUnit/xUnit XML emission from GoDotTest. Treat machine-readable test-result XML for C# as a gap to verify against the repo, or plan to shim it. (Standard `xUnit`/`NUnit` largely *don't* work in-engine because Godot manages the .NET runtime — Chickensoft explicitly recommends GoDotTest for this reason, so you likely can't fall back to the normal .NET `--logger junit` path.)
- Design note: GoDotTest "executes tests synchronously and in-order" inside the game — important for determinism, and it's the framework Chickensoft's CI-ready Godot-4 templates ship with.

**vs Bevy/Unity:** Bevy uses native `cargo test` (or `cargo nextest --message-format`) — first-class, structured output for free. Unity Test Framework (UTF) is editor-integrated and emits NUnit XML via `-runTests -testResults results.xml` — native but Editor-bound. **Godot lands between:** test frameworks are **third-party add-ons** (not engine-native like Unity's UTF, not language-native like Bevy's `cargo test`), but GUT's JUnit XML is solid. The C# JUnit-XML gap makes GDScript the safer test path for a Godot adapter. **Hypothesis HOLDS with a caveat** (test frameworks bolt-on rather than ship-in).

---

## 3. `run_headless` — Headless Mode & Determinism

**Feasible: YES (headless run). Determinism: PARTIAL — fixed-timestep YES, full reproducibility NOT GUARANTEED.**

- `--headless` runs game logic with no GPU/display, officially supported (4.0+). ([dedicated_servers docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html))
- **Fixed timestep: CONFIRMED native.** `_physics_process(delta)` runs at a fixed rate set by **Physics FPS / `physics_ticks_per_second`** (default 60). ([docs.godotengine.org/idle_and_physics_processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html), [physics_interpolation_introduction](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html))
- **Physics determinism: NOT GUARANTEED.** Official docs make **no** cross-run/cross-platform determinism claim for Godot Physics 2D/3D or Jolt, and don't address IEEE-754/float caveats. Long-horizon physics replay should be treated as **risky** without your own verification or state-snapshot approach. (Confirmed absence in docs.)
- **Seeded RNG: CONFIRMED reproducible within a build.** `RandomNumberGenerator` uses PCG32 with a settable `seed`; same seed + same call order → same sequence. **Caveat:** docs explicitly state the algorithm "is an implementation detail and may change in future Godot versions" — so cross-version (and unguaranteed cross-platform) RNG reproducibility is a risk. ([class_randomnumbergenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html), [random_number_generation](https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html))

**vs Bevy/Unity:** Bevy is the determinism champion — code-first, you control the schedule, fixed timestep, and can swap in deterministic math; headless is the default mode. Unity has fixed `FixedUpdate` + `Random.InitState(seed)` but PhysX determinism is famously non-guaranteed across platforms. **Godot lands between/with-Unity:** same fixed-timestep + seeded-RNG primitives as Unity, same "physics not guaranteed deterministic" caveat. Headless run itself is *cleaner* than Unity (true `--headless` vs Unity's awkward `-batchmode -nographics`). **Hypothesis HOLDS** (Godot ≈ Unity on physics determinism, better than Unity on headless ergonomics, worse than Bevy on both).

---

## 4. `replay` — Input Recording/Playback

**Feasible: YES. Fidelity: PARTIAL. DIY (no native record/replay).**

- **No native input record/replay system** in the engine — confirmed absence in official Input docs.
- Native **injection primitive exists**: `Input.parse_input_event(ev)` feeds synthetic `InputEvent`/`InputEventAction` objects into the input pipeline as if real. Capture via `_input(event)` / `_unhandled_input(event)`. ([docs.godotengine.org/inputevent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html))
- So record = log events from `_input` with tick indices; replay = re-inject via `parse_input_event` on the matching physics tick. Community plugins demonstrate exactly this (e.g. bitwes/GodotInputRecorder), but these are **third-party, not official**.
- **Determinism dependency:** input replay fidelity is bounded by §3 — replaying inputs reproduces a run only if physics + RNG are themselves controlled (snapshot-based replay is the robust fallback).

**vs Bevy/Unity:** Bevy — DIY but trivial in ECS (record/replay events or whole `World` state; the data-oriented model makes deterministic replay natural). Unity — DIY (Input System has no record/replay; community/asset-store tools fill the gap). **Godot lands between:** DIY like both, but Godot ships a clean, documented injection primitive (`parse_input_event`) that's arguably easier to drive than Unity's Input System, while lacking Bevy's whole-world snapshot ease. **Hypothesis HOLDS.**

---

## 5. `capture` — Screenshot/Video — ⚠ THE CRITICAL AXIS

**Feasible: YES *only with a renderer present*. In TRUE `--headless`: NONE. Workaround fidelity: FULL via software-GPU + virtual display.**

This is the most important finding for the adapter protocol.

- **Screenshot API (native, with renderer):** `await RenderingServer.frame_post_draw; get_viewport().get_texture().get_image().save_png(path)`. ([class_image](https://docs.godotengine.org/en/stable/classes/class_image.html), [shaggydev.com Godot screenshots 2025](https://shaggydev.com/2025/02/05/godot-screenshots/))
- **`--headless` DISABLES ALL RENDERING.** Official: "in headless mode … most functions from RenderingServer are disabled." The offscreen-rendering proposal states `--headless` "disables all rendering code." So `get_image()` in true headless returns **blank/garbage, not a real frame** — capture is **impossible** in `--headless`. ([class_renderingserver](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html), [godot-proposals#5790](https://github.com/godotengine/godot-proposals/issues/5790))
- **No native offscreen-render-in-headless flag** as of 4.3/4.4. No `--offscreen` / `--render-offscreen` / "rendering device in headless." It is **planned, no ETA** (godot-proposals discussion 4134 + issue 5790). Maintainers explicitly state there will be **no internal software renderer**; software rendering is expected to come from Mesa. ([godot-proposals#4134](https://github.com/godotengine/godot-proposals/discussions/4134))
- **The working CI capture pattern (FULL fidelity, today):** run Godot **NOT** `--headless`, under **Xvfb** (virtual X display) + **Mesa software driver** (lavapipe for Vulkan, or `LIBGL_ALWAYS_SOFTWARE=1` + llvmpipe for the Compatibility/OpenGL renderer; SwiftShader is an alternative). Godot then renders real frames to a virtual surface; `save_png()` works. This is exactly what **chickensoft-games/setup-godot** + GodotGame template do to run "visual tests in a headless environment." ([github.com/chickensoft-games/GodotGame](https://github.com/chickensoft-games/GodotGame), [godot-proposals#4335](https://github.com/godotengine/godot-proposals/discussions/4335))
- **Video:** Movie Maker mode (`--write-movie`, MJPEG/AVI or PNG-sequence+WAV) exists in 4.x but **also requires a real renderer** — same Xvfb+Mesa requirement; useless in true `--headless`. ([godotengine.org/movie-maker-mode](https://godotengine.org/article/movie-maker-mode-arrives-in-godot-4/))

**vs Bevy/Unity:** Bevy can render headlessly to an offscreen image target / `wgpu` (with software fallback) — capture is genuinely clean in headless. Unity: `-nographics` kills the GPU device so capture fails — the **classic conflict the prompt names**; Unity capture also needs Xvfb/GPU-runner workarounds. **Godot lands EXACTLY like Unity here, not between:** `--headless` and capture are mutually exclusive, and the workaround (Xvfb + software Mesa, drop the headless flag) is the *same shape* as Unity's. This is the **one axis where the "between" hypothesis is weakest** — Godot is no better than Unity on headless capture, and materially worse than Bevy. The adapter must encode "for capture, do NOT use `--headless`; provision Xvfb+lavapipe instead."

---

## 6. `lint` — GDScript & C# Static Analysis

**Feasible: YES. Fidelity: FULL (GDScript) / FULL via standard .NET (C#). Native to ecosystem (third-party but mature).**

- **gdtoolkit (Scony/godot-gdscript-toolkit): CONFIRMED Godot-4 support and actively maintained.** Current version **4.5.0 (released Oct 9, 2025)**; install `pip3 install "gdtoolkit==4.*"`. Provides **`gdlint`** (linter), **`gdformat`** (formatter), **`gdparse`** (parse tree), **`gdradon`** (cyclomatic complexity). Supports pre-commit hooks + GitHub Actions. ([github.com/Scony/godot-gdscript-toolkit](https://github.com/Scony/godot-gdscript-toolkit))
  - *Correction to a common stale claim:* the project **wiki** still says "Godot 3.x," but that text is outdated — the 4.x release line is real and current. Pin `gdtoolkit==4.*` for GDScript 2.0.
- **C#:** standard Roslyn analyzers + `dotnet format` work on Godot C# projects (they're SDK-style MSBuild projects). **No official Godot-specific Roslyn analyzer** is documented; Chickensoft ships community tooling/templates. Pure-CLI, no engine needed.

**vs Bevy/Unity:** Bevy — `cargo clippy` + `cargo fmt`, first-class, no engine. Unity — Roslyn analyzers work but C#-only; no equivalent of a dedicated GDScript linter because Unity has no scripting DSL. **Godot lands between/arguably ahead:** gdlint/gdformat give GDScript a clippy-class CLI lint+format story (closer to Bevy's ergonomics), and C# gets standard .NET tooling like Unity. Fully CLI, no Editor. **Hypothesis HOLDS (this is a Godot strength).**

---

## 7. `assets_validate` — Import Validation

**Feasible: YES (as a side-effect). Fidelity: PARTIAL. DIY validation; no dedicated "validate" command.**

- Import pipeline: source assets get per-asset `.import` metadata files; engine-native imported resources are cached under **`.godot/imported/`** (Godot 4 replaced Godot 3's `.import/` folder). ([docs.godotengine.org/import_process](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html))
- **No documented dedicated "validate imports" CLI flag.** Confirmed absent from official docs. The established pattern: run Godot **headless once** in CI to force (re)import — malformed assets print errors and the import populates `.godot/imported/`; a follow-up script that `load()`s key resources will surface import failures with non-zero exit. This is a **usage pattern, not a documented feature** (inferred from engine behavior).
- Importantly, import/validation **does not need a GPU** — it runs fine under true `--headless` (unlike capture), since it's resource processing, not rendering.

**vs Bevy/Unity:** Bevy — assets are loaded at runtime via `AssetServer`; "validation" = does it load (DIY, no import cache). Unity — heavy editor-driven `AssetDatabase` import with native validation hooks, but **Editor-bound and slow**. **Godot lands between:** it *has* a real import pipeline with `.import`/`.godot` cache (more than Bevy), but no dedicated validate command and runs headless cheaply (lighter than Unity's AssetDatabase). **Hypothesis HOLDS.**

---

## 8. `introspect` — Scene-Tree / Node Hierarchy Dump

**Feasible: YES. Fidelity: FULL. Native, works in `--headless`.**

- Native methods on `Node`: **`print_tree()`** (compact), **`print_tree_pretty()`** (formatted), plus `get_children()`, `get_class()`, `name` for custom traversal. Root via `get_tree().root` (≡ `/root`); current scene via `get_tree().current_scene`. ([scene_tree tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html), [class_node](https://docs.godotengine.org/en/stable/classes/class_node.html))
- Fully scriptable, no GUI, **works in true `--headless`** (it's data, not rendering). You can dump a JSON node hierarchy with a small autoload/`-s` script.

**vs Bevy/Unity:** Bevy — query the ECS `World`/entity-component archetypes (introspection via reflection/`bevy_reflect`; very powerful, code-first). Unity — `EditorUtility`/`SceneManager` traversal, mostly Editor-context for full fidelity. **Godot lands between/ahead:** built-in `print_tree_pretty()` + scriptable traversal in plain headless is *easier* than both for "dump the hierarchy." **Hypothesis HOLDS (Godot strength).**

---

## Hypothesis Scorecard: "Godot is between Bevy and Unity"

| Capability | Bevy | Unity | **Godot** | Verdict |
|---|---|---|---|---|
| build | Trivial (`cargo build`) | Heavy (Editor+license) | Light, native `--headless` export, one template-install step | **Between** ✓ |
| test | Native `cargo test` | Native UTF (NUnit XML), Editor-bound | Third-party GUT (JUnit XML ✓) / GoDotTest (XML unconfirmed) | **Between** ✓ |
| run_headless + determinism | Best (code-first, deterministic) | Fixed step, PhysX non-det | Fixed step ✓, physics non-det, RNG seeded ✓ | **Between/≈Unity** ✓ |
| replay | DIY, easy (snapshots) | DIY, harder | DIY, clean `parse_input_event` primitive | **Between** ✓ |
| **capture** | **Clean headless offscreen** | **`-nographics` conflicts; needs Xvfb/GPU** | **`--headless` = NO rendering; needs Xvfb+Mesa** | **≈ Unity, NOT between** ✗ |
| lint | `clippy`+`fmt` | Roslyn (C# only) | gdlint/gdformat ✓ + Roslyn | **Between/ahead** ✓ |
| assets_validate | Runtime load only | Heavy AssetDatabase | Real import pipeline, headless, no validate cmd | **Between** ✓ |
| introspect | ECS reflection | Editor-bound | Native `print_tree_pretty`, headless | **Between/ahead** ✓ |

**Hypothesis holds on 7 of 8 axes.** The single exception is the load-bearing one: **`capture`**, where Godot is *not* between Bevy and Unity — it sits squarely **with Unity** (true headless disables all rendering; you must drop `--headless` and provision a virtual display + software GPU). On three axes (lint, introspect, and arguably build) Godot is *better* than the "between" prediction.

---

## Bottom Line

**Godot is a genuinely factory-friendly third adapter — and largely the cheap one the hypothesis predicts — with exactly one expensive caveat that must be designed around explicitly.** Seven of the eight adapter capabilities are CI-clean today: headless export is native and lighter than Unity (only the out-of-band export-template install adds friction); GDScript gets first-class CLI lint/format (`gdtoolkit` 4.5.0) and JUnit-XML tests (GUT); scene-tree introspection and asset import both run in true `--headless`; and input replay rides a clean native injection primitive. Determinism mirrors Unity (fixed timestep + seeded PCG32 RNG, but no physics-determinism guarantee). The one place the "between Bevy and Unity" model breaks is **capture**: Godot's `--headless` disables *all* rendering (confirmed by official docs and the still-open offscreen-rendering proposal with no ETA), so screenshots/video are **impossible** in true headless and require the same Unity-grade workaround — run *without* `--headless` under Xvfb + Mesa software Vulkan (lavapipe), exactly as the `chickensoft-games/setup-godot` visual-test setup does. So Godot is the cheap third adapter **for everything except capture**, where it costs the same as Unity. The adapter protocol should encode a hard branch: capture/video mode provisions a virtual-display + software-GPU sidecar and never passes `--headless`, while build/test/introspect/assets_validate take the clean headless path. With that one branch, Godot is a low-friction, high-coverage third adapter.

---

### Flagged gaps / lower-confidence items

- **GoDotTest JUnit/xUnit XML output: UNCONFIRMED.** Confirmed lcov coverage; XML test-result emission not verified — verify against the repo before relying on it for C# CI result parsing.
- **gdtoolkit wiki vs releases conflict:** wiki text says "Godot 3.x" but releases (4.5.0, Oct 2025) support 4.x — resolved in favor of the release evidence; pin `gdtoolkit==4.*`.
- **GUT CLI flag page** cited is the `godot_3x` docs branch; the 4.x branch exists and is maintained — re-verify exact flag names against the 4.x docs if pinning a version.
- **Physics determinism:** no official guarantee for Godot Physics or Jolt; treat long-horizon physics replay as snapshot-based, not input-based.
