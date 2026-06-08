# Unity Game Engine (C#) — Factory-Capability Research Report

**Scope:** Suitability of Unity for an automated, headless, CI-driven game-development factory, evaluated per the engine-adapter-protocol capability set.
**Date of findings:** As of June 2026. Unity landscape current to Unity 6.x LTS (6000.x) and Unity 2022.3 LTS.
**Citation discipline:** Official Unity docs distinguished from community/forum sources. Forum/staff statements flagged as such. Where evidence contradicts the requester's stated assumptions, this is called out explicitly under each section and in a dedicated summary.

---

## 1. `build` — Headless / CI Build

**Feasible? Yes. Native? Native.** **Fidelity: FULL.**

Unity has a first-class, officially documented CLI build path. The canonical pattern:

```bash
Unity -batchmode -nographics -quit \
  -projectPath /path/to/project \
  -logFile - \
  -executeMethod CiBuild.BuildLinuxHeadless
```

- `-batchmode` — runs the Editor with no GUI, suppresses dialogs (for automation/CI).
- `-quit` — quit after batch operations finish (see gotcha below re: async).
- `-nographics` — start with no graphics device (safe for *building*; problematic for *capture* — see §5).
- `-executeMethod Class.Method` — invoke a **static, public** method, typically in an Editor assembly (`Assets/Editor/`).

The build itself is performed by `UnityEditor.BuildPipeline.BuildPlayer(BuildPlayerOptions)`, which returns a `BuildReport` whose `summary.result` (`BuildResult.Succeeded` / `Failed`) you check and translate to an exit code. `BuildPipeline` is Editor-only (`UnityEditor` namespace), and calling `BuildPlayer` triggers a script reload (invalidates in-scope variables after the call).

**Licensing implications for CI (important caveat):** Unity *requires an activated license* in every mode, including batchmode — there is no free unlicensed CI mode. Every concurrent CI agent running the Editor must be covered by a seat (Personal, Pro, Enterprise) or a floating/**Build Server** license. Personal is permitted on CI subject to the revenue/funding cap (raised to **$200,000** with Unity 6). See §9 for the activation-method shift (serial CLI → `.ulf`/Licensing Client) which is the single biggest CI friction point.

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/BuildPipeline.BuildPlayer.html
- https://docs.unity3d.com/6000.4/Documentation/ScriptReference/BuildPipeline.html
- https://docs.unity3d.com/6000.0/Documentation/Manual/CommandLineArguments.html
- https://docs.unity3d.com/6000.4/Documentation/Manual/ManagingYourUnityLicense.html
- https://game.ci/docs/gitlab/activation/ (GameCI floating-license `UNITY_LICENSING_SERVER` pattern)

---

## 2. `test` — Unity Test Framework (UTF), CLI, Output Format

**Feasible? Yes. Native? Native (UTF package). Fidelity: FULL.**

Unity Test Framework supports **EditMode** and **PlayMode** tests, runnable from CLI:

```bash
Unity -runTests -batchmode \
  -projectPath /path/to/project \
  -testPlatform EditMode \
  -testResults /tmp/results.xml
```

- `-runTests` — start a UTF run as soon as the Editor loads.
- `-testPlatform EditMode|PlayMode` — selects the test category (or a build target for on-device PlayMode runs).
- `-testResults <file>` — output XML path (defaults to project root).
- Note: do **not** add `-quit` with `-runTests` — UTF manages its own lifecycle and exit.

**Output format — confirmed (resolves explicit question):** The results file is **NUnit 3 XML** (root `<test-run>` element). Unity's package docs say only "the XML format as defined by NUnit," deferring to NUnit's "Test Result XML Format" schema page — but Unity staff explicitly confirm: *"The generated TestResults.xml when running playmode and editmode tests is now updated to be in NUnit3 format."* Older Unity emitted an earlier format; modern UTF (the `com.unity.test-framework` 1.x/2.x packages) emits **NUnit v3**, not v2. Any CI consumer that parses NUnit 3 XML (Jenkins NUnit-3 plugin, TeamCity NUnit report processing) ingests it directly. You typically run EditMode and PlayMode as separate invocations producing separate XML files and glob over them.

**Sources:**
- https://docs.unity3d.com/Packages/com.unity.test-framework@2.0/manual/reference-command-line.html (official: "XML format as defined by NUnit")
- https://discussions.unity.com/t/nunit-test-runner-format/693148 (Unity staff: "updated to be in NUnit3 format")
- https://discussions.unity.com/t/unity-test-runner-xml-report-to-html/776201 (Unity staff: conformant to NUnit "Test Result XML Format" schema)
- https://game.ci/docs/github/test-runner/

---

## 3. `run_headless` — `-batchmode -nographics`, PlayMode Headless, Determinism

**Feasible? Yes for execution; PARTIAL for determinism.** **Native? Native execution; DIY determinism. Fidelity: PARTIAL.**

**Headless execution:** `-batchmode -nographics` runs the Editor/player without GUI or graphics device. Builds can also tick the Linux "Headless Mode"/dedicated-server build option, which strips X11 references entirely (assets are still included and loaded; only display is removed). PlayMode tests run headless under this combination.

**Determinism primitives (the substantive part):**

- **Fixed-timestep stepping** — `Time.fixedDeltaTime` sets the `FixedUpdate` interval (native, documented). `Time.captureDeltaTime` forces `Time.time`/`Time.deltaTime` to advance by a fixed increment independent of wall-clock (originally for constant-framerate capture; Unity staff confirm it yields "deterministic time-per-frame" usable beyond capture). `Time.captureFramerate` is the older equivalent. You can also disable auto-simulation and drive physics manually via `Physics.Simulate(fixedTimestep)`.
- **Seeded RNG** — `UnityEngine.Random.InitState(seed)` makes `Random.Range`/`Random.value` reproducible *for a given version/platform/build, given identical call ordering*. Caveat: ordering divergence (UI, effects, third-party assets calling Random) breaks the sequence; isolated `System.Random` streams are the common hardening.

**Determinism verdict — feasible but bounded (contradicts any assumption of "Unity is deterministic out of the box"):**
- **Same machine, same build, "Enable Enhanced Determinism" physics flag on:** *locally repeatable* simulation is achievable for short/medium runs with controlled stepping and seeding.
- **Cross-machine / cross-CPU (Intel vs AMD vs ARM):** Unity PhysX is **NOT** bit-deterministic — SIMD/floating-point differences cause divergence. NVIDIA's own KB historically states the PhysX SDK is not deterministic. True deterministic lockstep requires *replacing* PhysX with fixed-point math (e.g., TrueSync, `unity-deterministic-physics` soft-float DOTS Physics).

For a factory, the practical reading: **deterministic replay/verification on a single pinned CI image is achievable with DIY discipline (fixed timestep + seeded RNG + Enhanced Determinism + avoiding wall-clock/async ordering)**; bit-identical cross-runner determinism is not a native guarantee.

**Sources:**
- https://docs.unity3d.com/ScriptReference/Time-captureDeltaTime.html
- https://docs.unity3d.com/6000.4/Documentation/ScriptReference/Random.InitState.html
- https://docs.unity.cn/Manual/TimeFrameManagement.html
- https://discussions.unity.com/t/determinism-physx/866457 (Enhanced Determinism flag; not cross-CPU)
- https://discussions.unity.com/t/replaying-physics-same-results-each-time-or-different/617355 ("not deterministic, not even in the same machine")
- https://forums.developer.nvidia.com/t/once-and-for-all-is-physx-3-3-2-deterministic.../38405
- https://github.com/Kimbatt/unity-deterministic-physics (DIY deterministic alternative)

---

## 4. `replay` — Input Recording / Playback

**Feasible? Yes. Native? NATIVE (new Input System package). Fidelity: FULL (new) / NONE (legacy).**

This **confirms a native primitive exists** (relevant if assumed DIY-only):

- **`InputEventTrace`** (`UnityEngine.InputSystem.LowLevel`) — official API that records raw input events for later processing, with write-to-disk, load, and playback. This is the low-level recording mechanism.
- **`InputRecorder`** — official component wrapper around `InputEventTrace` providing record/playback from a GameObject with a custom inspector and save/load. Shipped in the Input System package samples and API.
- **`InputActionTrace`** — official, but traces *action-level* callbacks, not raw event replay; distinct from `InputEventTrace`.

**Caveat:** This is the **new Input System package** (`com.unity.inputsystem`). The **legacy Input Manager** (`Input.GetKey`/`GetAxis`) has **NO** documented recording/playback capability — there it is fully DIY. So fidelity is FULL only if the target project uses the new Input System. There is also a separate `com.unity.automated-testing` package with `RecordedPlayback` for higher-level UI automation.

**Sources:**
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.0/api/UnityEngine.InputSystem.LowLevel.InputEventTrace.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.3/api/UnityEngine.InputSystem.InputRecorder.html
- https://docs.unity3d.com/6000.4/Documentation/Manual/InputLegacy.html (legacy — no recording API)
- https://docs.unity3d.com/Packages/com.unity.automated-testing@0.8/manual/RecordedPlayback.html

---

## 5. `capture` — Screenshot / Video, and the `-nographics` Conflict

**Feasible? CONDITIONAL.** **Native API exists, but conflicts with headless. Fidelity: PARTIAL (and NONE under `-nographics`).**

### Assumption CONFIRMED, and sharpened.

The hypothesized conflict between `-nographics` and capture **is correct.** Evidence (official + corroborating forum/staff + a fresh June 2025 thread):

- `ScreenCapture.CaptureScreenshot` (official API) "captures the current rendered screen output... a screenshot of the final frame presented to the user, **not** a capture from a RenderTexture." Under `-nographics` there is **no framebuffer / no final presented frame**, so there is nothing to capture.
- Concrete reproduction (Tavily-corroborated): running `./game -batchmode -nographics` on a headless Linux box yields **gray/blank images**; a June 2025 thread is titled *"Linux Headless Rendering with -nographics Returns Black Frames."* Running with a real display or `xvfb` (without `-nographics`) is what works.
- **Unity Recorder** is worse for this use case: a Unity dev states Recorder "only captures editor windows," "won't capture build output nor is it runtime-enabled," and "there's nothing rendered in batch mode. Hence nothing to record." Recorder is effectively **unusable** in `-batchmode`/`-nographics`.

### Workarounds (verified):

1. **Drop `-nographics`; provide a virtual framebuffer.** On Linux CI, wrap the Editor/player in **`xvfb-run`** (e.g., `xvfb-run --auto-servernum --server-args='-screen 0 1920x1080x24' Unity -batchmode ...`). This gives Unity a graphics context so rendering and capture work. This is the dominant, working CI pattern.
2. **Render to a `RenderTexture` via `Camera.Render()`**, then `ReadPixels` → `Texture2D` → `EncodeToPNG`, instead of `ScreenCapture.CaptureScreenshot`. Unity staff recommend this for headless/no-framebuffer contexts (e.g., MR). But it **still needs a graphics device** — under pure `-nographics` with no GPU/xvfb, even RenderTexture allocation can fail; results are often gray (forum reports). A real or headless GPU + driver, or xvfb with software GL, is required.
3. **Video:** Recorder is out; capture an image sequence (RenderTexture per frame, optionally with `Time.captureFramerate`/`captureDeltaTime` for constant framerate) and encode externally with **ffmpeg**. Or feed RenderTexture frames to a third-party Asset Store recorder.

### Net for the factory: the `build`/`test` lane can safely use `-nographics`; the `capture` lane **must not** — it needs `-batchmode` *without* `-nographics`, plus xvfb (Linux) and ideally a GPU. **This is the single most important adapter-design constraint: headless-build config and capture config are mutually exclusive flag sets.**

**Sources:**
- https://docs.unity3d.com/6000.4/Documentation/ScriptReference/ScreenCapture.CaptureScreenshot.html
- https://discussions.unity.com/t/capture-screenshot-on-linux-headless-machine/203404 (gray images under `-nographics`; xvfb without `-nographics` works)
- "Linux Headless Rendering with -nographics Returns Black Frames" (Unity Discussions, 2025-06-23)
- https://discussions.unity.com/t/stop-batch-mode-builds-from-finishing.../1585101 (Unity dev: Recorder captures nothing in batch mode)
- https://discussions.unity.com/t/rendertexture-screenshots/335085 (Camera.Render → RenderTexture workaround)
- https://discussions.unity.com/t/running-ui-toolkit-with-unity-in-batch-mode-for-visual-test-in-the-ci/891977 (xvfb-run CI pattern)

---

## 6. `lint` — Roslyn Analyzers / `dotnet format`

**Feasible? Yes. Native? Native (analyzers) + DIY-adjacent (`dotnet format`). Fidelity: FULL.**

- **Roslyn analyzers & source generators** are officially supported (Unity Manual "Roslyn analyzers and source generators"). Analyzers are integrated into Unity's Roslyn-based compilation; diagnostics surface as Console warnings/errors. Configured via `.editorconfig` + ruleset files. Microsoft maintains `Microsoft.Unity.Analyzers` for Unity-specific patterns.
- **`dotnet format`** is not shipped/documented by Unity, but runs against Unity's **generated `.sln`/`.csproj`** files. In CI, regenerate project files (`-syncSolution` / editor integration), then `dotnet format <solution>.sln` as a lint/format step.
- **Important architectural caveat:** Unity does **not** build gameplay scripts with MSBuild/`dotnet build` — it uses its own internal Roslyn compilation pipeline over `Assets/`+`Packages/` with assembly definitions. The generated `.csproj`/`.sln` are **IDE/tooling artifacts** only. So treat `dotnet format` as a pure lint/format pass on shared source files — it is *not* Unity's actual compiler, and `.csproj` build-setting edits don't affect Unity's compilation.

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/roslyn-analyzers.html
- https://github.com/microsoft/Microsoft.Unity.Analyzers
- https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format
- https://discussions.unity.com/t/how-to-lint-unity-csharp-source/922408

---

## 7. `assets_validate` — AssetDatabase Import + Error Detection

**Feasible? Yes. Native? Native API; DIY error-detection wiring. Fidelity: FULL (partial ergonomics).**

Run a static method via `-executeMethod` in `-batchmode`:

- `AssetDatabase.Refresh()` — rescan project, import modified assets.
- `AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate)` — (re)import a specific asset.
- `AssetImporter.GetAtPath(path)` — inspect/enforce per-asset import settings.
- `AssetPostprocessor` callbacks (`OnPreprocessTexture`, `OnPostprocessModel`, etc.) — run custom validation rules during import.

**Caveat (the DIY part):** `ImportAsset` does **not** return a per-asset success/failure boolean. The idiomatic CI pattern is: validate in `AssetPostprocessor` / post-import logic, emit `Debug.LogError` on violations, and rely on Unity's batchmode behavior of returning a non-zero exit code on logged errors / uncaught exceptions. For robust CI you should set the exit code explicitly via `EditorApplication.Exit(code)` (see §9) rather than depend solely on implicit error-to-exit-code mapping.

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/AssetDatabase.ImportAsset.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/AssetDatabase.Refresh.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/AssetImporter.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/AssetPostprocessor.html

---

## 8. `introspect` — Dumping Scene Hierarchy / GameObject Tree

**Feasible? Yes. Native? Native. Fidelity: FULL.**

Fully supported programmatically; trivially scriptable in batchmode:

- `SceneManager.GetActiveScene()` / `GetSceneAt(i)` → `Scene.GetRootGameObjects()` for per-scene roots.
- Traverse via `Transform.childCount` + `Transform.GetChild(i)` (recursive); ascend via `Transform.parent`.
- `EditorSceneManager.OpenScene(path, OpenSceneMode.Single)` to open scenes in the Editor without Play Mode (ideal for batchmode introspection).
- `Resources.FindObjectsOfTypeAll<GameObject>()` for a global dump including disabled/editor-only objects; `GameObject.Find` / `FindGameObjectsWithTag` for targeted lookup.

A recursive dump emitting an indented tree (or JSON) of names/components/active-state is straightforward and serializes cleanly for factory verification.

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/SceneManagement.SceneManager.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/SceneManagement.Scene.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/SceneManagement.EditorSceneManager.OpenScene.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Transform.html
- https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Resources.FindObjectsOfTypeAll.html

---

## 9. Cross-Cutting Caveats — Licensing/Cost, Versions, Batchmode Gotchas

### Licensing / CI cost (the biggest factory friction)
- **A license is mandatory in every mode**, including batchmode. No free unlicensed CI.
- **Activation method has shifted.** Unity 6 and current 2022.3 LTS docs no longer promote `-serial -username -password` CLI activation; the supported model is **Unity Hub / Licensing Client + a `.ulf` license file** pre-provisioned on the agent (under `ProgramData/Unity` on Windows, `Library/Application Support/Unity` on macOS). GameCI's "manual activation file" flow matches this. **Inference (flagged): treat `-serial` CLI activation as legacy/fragile for new pipelines** — Unity has not published an explicit "removed in Unity 6" notice, but all current guidance routes through `.ulf`/Hub/floating server. For scale, use **Unity Build Server / floating licenses** (`UNITY_LICENSING_SERVER=ssl://...`), checking out per job and returning after.
- **Headless license activation gotcha:** activating with `-batchmode -nographics` historically hangs on an invisible license dialog ("This should not be called in batch mode" / timeout). Documented workaround: run activation under **xvfb** (without `-nographics`), then run the actual job. This compounds the §5 capture constraint — xvfb is needed both for license activation and for any rendering/capture.

### Version differences (Unity 6 vs 2022.3 LTS)
- **Unity 6 (6000.x)** is the current LTS line, released **2024**; **Unity 2022.3.x LTS** remains supported in parallel. Batchmode / `-executeMethod` / UTF mechanics are essentially identical across both — CI scripts port cleanly.
- **Unity Personal revenue/funding cap raised to $200,000** with Unity 6 (was $100k).
- **Runtime Fee fully CANCELLED** (official: "Unity has decided to cancel the Runtime Fee for gaming customers effective immediately"), reverting to seat-based subscriptions. No per-install/per-runtime billing affects a factory. (Pro/Enterprise saw subscription price increases instead: ~8% Jan 2025, further ~5% Jan 2026 on some plans.)

### Batchmode gotchas
- **`-quit` kills async/coroutines.** When the `-executeMethod` static method returns and `-quit` is present, Unity exits immediately — coroutines, `UnityWebRequest`, async asset ops will not complete. **Fix:** omit `-quit`, start the async work, and call `EditorApplication.Exit(code)` when done.
- **Use `EditorApplication.Exit(int)` for exit codes, not `Application.Quit()`.** `Application.Quit` is a runtime API and is unreliable for terminating the batchmode Editor or controlling exit code. CI convention: `0` = success, non-zero = failure; set it explicitly and catch exceptions to emit a deterministic failure code.

**Sources:**
- https://support.unity.com/hc/en-us/articles/30322080156692-Cancellation-of-the-Runtime-Fee-and-Pricing-Changes
- https://support.unity.com/hc/en-us/articles/360040693532- (`.ulf` license-file lifecycle)
- https://discussions.unity.com/t/use-coroutine-in-batchmode/194870 and https://discussions.unity.com/t/batch-mode-async-timeout-on-our-build-machine/845124 (`-quit` vs `EditorApplication.Exit`)
- https://discussions.unity.com/t/cant-get-license-in-headless-nographics-mode-timeout-error/669257 (xvfb license-activation workaround)
- https://unity.com/products/pricing-updates

---

## Capability Fidelity Summary

| Capability | Feasible | Native vs DIY | Fidelity | Key constraint |
|---|---|---|---|---|
| build | Yes | Native | **FULL** | License required even in batchmode |
| test | Yes | Native (UTF) | **FULL** | Output is **NUnit 3 XML** (confirmed) |
| run_headless | Yes | Native exec / DIY determinism | **PARTIAL** | PhysX not cross-machine deterministic; local determinism is DIY |
| replay | Yes | **Native** (new Input System) | **FULL** (new) / **NONE** (legacy) | Requires `com.unity.inputsystem`, not legacy Input Manager |
| capture | Conditional | Native API, conflicts headless | **PARTIAL** / **NONE** under `-nographics` | **`-nographics` breaks capture** — needs xvfb + no `-nographics` |
| lint | Yes | Native analyzers + `dotnet format` | **FULL** | `.csproj` is IDE-only, not Unity's compiler |
| assets_validate | Yes | Native API / DIY error wiring | **FULL** | `ImportAsset` has no success bool; wire via LogError + exit code |
| introspect | Yes | Native | **FULL** | Use `EditorSceneManager.OpenScene` in batchmode |

## Contradictions / confirmations vs stated assumptions

- **`-nographics` vs capture conflict: CONFIRMED and sharpened.** `-nographics` disables the graphics device/framebuffer; `ScreenCapture.CaptureScreenshot` produces gray/black/blank images, and Unity Recorder captures nothing in batch mode. Workaround is `xvfb` + `-batchmode` *without* `-nographics` (plus ideally a GPU), or `Camera.Render()`→RenderTexture→PNG which *still* needs a graphics context. A separate capture lane is mandatory.
- **Replay is NOT DIY-only (refinement):** Unity *does* have a native input record/playback primitive (`InputEventTrace`/`InputRecorder`) — but only via the new Input System package; the legacy Input Manager has none.
- **Determinism (refinement):** local single-image determinism is achievable with DIY discipline, but Unity is **not** deterministic out of the box and PhysX is not cross-CPU deterministic.

## Bottom line: how factory-friendly is Unity?

Unity is **moderately-to-strongly factory-friendly** for a headless, CI-driven pipeline — substantially better than most engines — but with two structural caveats the adapter must design around. On the positive side, six of eight capabilities are native and full-fidelity: batchmode builds (`BuildPipeline.BuildPlayer`), Unity Test Framework with standard **NUnit 3 XML** output, native input record/replay (new Input System), Roslyn-analyzer linting, AssetDatabase import validation, and programmatic scene introspection all work cleanly via `-batchmode -executeMethod`. The two real frictions are (1) the **headless-vs-capture conflict** — `-nographics` disables rendering, so the `capture` lane must run a *different* flag set (xvfb, no `-nographics`, ideally a GPU), forcing the adapter to model build/test and capture as distinct execution profiles; and (2) **licensing** — every CI agent needs an activated seat (`.ulf`/Build Server/floating), serial-CLI activation is legacy, and headless activation itself needs an xvfb workaround. Determinism is the soft spot: good enough for single-image replay/verification with DIY fixed-timestep + seeded-RNG discipline, but not bit-deterministic across runners. With the Runtime Fee cancelled and Unity 6 LTS stable, the cost/licensing model is predictable. **Net: design the Unity adapter with two execution profiles (headless-compute vs xvfb-render), pre-provision licenses on agent images, and treat determinism as a DIY contract rather than a native guarantee — under those terms Unity is a viable, well-documented factory target.**
