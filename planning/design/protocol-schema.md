# Engine Adapter Protocol — Formal Schema v1.0 (draft)

> **Status:** Draft 1, 2026-06-07. Grounded in research pass 1 (`planning/research/`)
> and Decisions 0001–0003. This is the formal surface that Layer 1–2 (factory core)
> and Layer 4 (adapters) agree on. Command strings in the per-engine notes are
> illustrative; verify against version-tagged engine docs at implementation time.

## 0. Transport & framing

- **Wire format:** JSON-RPC 2.0 (Decision 0002 — parity with LSP and Bevy's BRP).
- **Transport:** the adapter runs as a **subprocess** of the core, speaking JSON-RPC
  over **stdio**, framed LSP-style with `Content-Length` headers. Rationale: any
  adapter can be written in any language (the Bevy adapter in Rust, the Unity
  adapter in C#/Node, the Godot adapter in GDScript/Python) without an FFI boundary,
  exactly as LSP language servers are polyglot.
- **Direction:** the **core is the client**, the **adapter is the server** (LSP
  roles). The core drives; the adapter executes engine operations and reports.
- Long operations are **async with progress** (`$/progress`) and **cancellable**
  (`$/cancelRequest`).

```
Content-Length: 123\r\n
\r\n
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}
```

## 1. Lifecycle

| Method | Dir | Kind | Purpose |
|---|---|---|---|
| `initialize` | core→adapter | request | handshake; exchange versions + capability manifest |
| `initialized` | core→adapter | notification | core ready; adapter may begin background work (e.g. project scan) |
| `capability/register` | adapter→core | notification | **dynamic registration** — adapter upgrades a capability after inspection |
| `capability/unregister` | adapter→core | notification | adapter downgrades a capability |
| `shutdown` | core→adapter | request | graceful stop; adapter flushes, stops accepting new work |
| `exit` | core→adapter | notification | terminate process |
| `$/progress` | adapter→core | notification | progress for a long request (carries `progressToken`) |
| `$/cancelRequest` | core→adapter | notification | cancel an in-flight request by `id` |
| `$/log` | adapter→core | notification | structured adapter log line (level, message, fields) |

### 1.1 `initialize`

**Request params:**
```jsonc
{
  "protocolVersion": "1.0",            // core's protocol version (semver)
  "coreVersion": "0.1.0",
  "projectPath": "/abs/path/to/game",  // the game project root
  "engineHint": "bevy",                // optional; adapter may self-detect
  "workspace": { "tmpDir": "/abs/tmp", "artifactDir": "/abs/artifacts" }
}
```

**Result:** the **Capability Manifest** (§2). If `protocolVersion` is incompatible
with the adapter, the adapter returns error `ProtocolVersionMismatch` (§5) with the
versions it supports — the core does not proceed.

### 1.2 Dynamic registration (LSP-borrowed)

A capability declared `partial`/`none` at `initialize` may be upgraded once the
adapter has inspected the project. Canonical example (from research): the Unity
adapter reports `replay: { fidelity: "none" }` initially, scans the project, finds
the **new Input System** package, then sends:

```jsonc
{ "method": "capability/register",
  "params": { "capability": "replay", "value": { "fidelity": "full", "method": "input-system-eventtrace" } } }
```

The core re-plans gates accordingly. This is what prevents lowest-common-denominator
design — capabilities are negotiated, not frozen.

## 2. Capability Manifest schema

Returned from `initialize`. This is the heart of capability negotiation.

```jsonc
{
  "engine": "bevy",
  "engineVersion": "0.18.1",          // exact, pinned (Bevy churn → mandatory)
  "adapterVersion": "1.0.0",
  "protocolVersion": "1.0",
  "determinismTier": "bitwise-cross-platform", // Decision 0003 enum (§4)

  "executionProfiles": {
    "headless-compute": { "available": true },
    "render": {
      "available": true,
      "windowless": true,                       // Bevy true; Unity/Godot false
      "requires": ["vulkan-software:lavapipe"],  // or ["xvfb","gl-software:llvmpipe"]
      "notes": "offscreen render-to-texture; needs a wgpu backend"
    }
  },

  "capabilities": {
    "build":          { "fidelity": "full" },
    "test":           { "fidelity": "full", "resultFormat": "junit-xml" },   // junit-xml | nunit3-xml | libtest-json
    "runHeadless":    { "fidelity": "full", "profile": "headless-compute" },
    "replay":         { "fidelity": "partial",
                        "prerequisites": ["fixed-timestep","seeded-rng","input-injection"],
                        "method": "ecs-tick-recorder" },
    "capture":        { "fidelity": "full", "profile": "render",
                        "modes": ["screenshot","frame-sequence"] },          // video via external encode
    "lint":           { "fidelity": "full" },
    "assetsValidate": { "fidelity": "partial", "method": "load-state-harness" },
    "introspect":     { "fidelity": "full", "method": "brp-jsonrpc" }
  }
}
```

**`fidelity` enum (every capability):** `full` | `partial` | `none`.
- `none` → the core must degrade the corresponding convergence dimension (e.g.
  `replay: none` → regression falls back to human-playtest evidence).
- `partial` → usable with documented limits (e.g. `assetsValidate: partial` =
  load-triggered assets only, not static "all references exist").

## 3. Capability methods

All capability methods accept an optional `progressToken` and an optional
`profile` override; all return a **normalized result** (§3.x). If a capability's
manifest fidelity is `none`, calling it returns error `CapabilityUnsupported`.

| Method | Returns | Profile |
|---|---|---|
| `build` | `BuildResult` | headless-compute |
| `test` | `TestResult` | headless-compute |
| `runHeadless` | `RunResult` | headless-compute |
| `replay/record` | `ReplayRecording` | (per game) |
| `replay/play` | `ReplayResult` | (per game) |
| `capture/screenshot` | `CaptureResult` | render |
| `capture/frames` | `CaptureResult` | render |
| `lint` | `LintResult` | headless-compute |
| `assets/validate` | `AssetValidateResult` | headless-compute |
| `introspect` | `IntrospectResult` | headless-compute |

### 3.1 `BuildResult`
```jsonc
{
  "status": "succeeded",                 // succeeded | failed
  "artifacts": [{ "path": "/abs/...", "platform": "linux-x86_64", "kind": "binary" }],
  "durationMs": 84211,
  "diagnostics": [{ "severity": "error", "message": "...", "file": "...", "line": 12 }],
  "log": "…tail of build log…"
}
```

### 3.2 `TestResult` (normalized — JUnit/NUnit/libtest all map to this)
```jsonc
{
  "suite": "sim.economy",
  "tests": [
    { "id": "economy::tax_applies_per_tick", "status": "pass",   // pass | fail | skip
      "durationMs": 3, "message": null, "assertion": null }
  ],
  "totals": { "pass": 41, "fail": 0, "skip": 2 },
  "sourceFormat": "junit-xml",           // what the adapter normalized FROM
  "capabilityFidelity": "full",
  "engine": "bevy"
}
```

### 3.3 `RunResult`
```jsonc
{ "exitStatus": "clean", "ticks": 3600, "durationMs": 60120, "log": "…" }   // clean | crashed | timeout
```

### 3.4 `ReplayRecording` / `ReplayResult`
```jsonc
// replay/record →
{ "recordingPath": "/abs/replays/run-001.replay",
  "ticks": 3600, "inputEvents": 812, "rngSeed": 1234567,
  "determinismTier": "bitwise-cross-platform" }

// replay/play (with a baseline to compare against) →
{ "mode": "play",
  "comparison": {
    "method": "snapshot-hash-diff",       // hash-diff (tier1) | tolerance-window (tier2/3)
    "passed": true,
    "baselineHash": "ab12…", "actualHash": "ab12…",
    "diffs": []                            // for tolerance: [{tick, field, expected, actual, delta, withinTolerance}]
  } }
```
The `comparison.method` is **dictated by `determinismTier`** (§4) — the core never
asks for `snapshot-hash-diff` from a `tolerance-only` adapter.

### 3.5 `CaptureResult`
```jsonc
{ "media": [{ "kind": "screenshot", "path": "/abs/shots/ac3.png", "width": 1920, "height": 1080 }],
  "profile": "render", "backend": "vulkan-software:lavapipe", "frameCount": 1 }
```

### 3.6 `LintResult`
```jsonc
{ "findings": [{ "severity": "warning", "code": "clippy::needless_clone",
                 "message": "…", "file": "src/sim.rs", "line": 88, "col": 17 }],
  "totals": { "error": 0, "warning": 3 } }
```

### 3.7 `AssetValidateResult`
```jsonc
{ "assets": [{ "path": "assets/hero.png", "status": "loaded", "error": null }],  // loaded | failed | skipped
  "totals": { "loaded": 240, "failed": 0, "skipped": 0 },
  "method": "load-state-harness", "note": "load-triggered assets only" }
```

### 3.8 `IntrospectResult` (normalized scene/entity tree)
```jsonc
{ "format": "ecs",                        // ecs (Bevy) | scene-tree (Godot/Unity) — both normalize to `root`
  "root": {
    "id": "0v1", "name": "Player",
    "components": [{ "type": "Transform", "value": { "x": 0, "y": 1, "z": 0 } }],
    "children": [ /* recursive */ ]
  },
  "source": "brp-jsonrpc" }
```

## 4. Determinism tier (Decision 0003)

`determinismTier` ∈ { `bitwise-cross-platform`, `same-machine`, `tolerance-only` }.

| Tier | Replay comparison the core will request | Example |
|---|---|---|
| `bitwise-cross-platform` | `snapshot-hash-diff` (exact) | Bevy + Rapier |
| `same-machine` | `snapshot-hash-diff` on a pinned runner only | Unity PhysX (Enhanced Determinism) |
| `tolerance-only` | `tolerance-window` metric diff | Godot physics, FP-heavy sims |

**Replay prerequisites** (declared in `capabilities.replay.prerequisites`, required
for any non-`none` replay fidelity): `fixed-timestep`, `seeded-rng`,
`input-injection`. An adapter missing any of the three declares `replay: none`.

## 5. Errors (JSON-RPC error codes)

Standard JSON-RPC codes (`-32600` etc.) plus the protocol's reserved range
`-32000…-32099`:

| Code | Name | Meaning |
|---|---|---|
| -32000 | `ProtocolVersionMismatch` | core/adapter protocol versions incompatible (carries supported range) |
| -32001 | `CapabilityUnsupported` | called a capability whose fidelity is `none` |
| -32002 | `ProfileUnavailable` | requested execution profile not available on this runner (e.g. no lavapipe) |
| -32003 | `EngineToolMissing` | required engine binary/tool/license not found (e.g. Unity license, export templates) |
| -32004 | `DeterminismTierViolation` | requested a comparison stricter than the declared tier supports |
| -32005 | `OperationFailed` | the engine operation ran but failed (build error, crash) — see result/data |
| -32006 | `Cancelled` | request cancelled via `$/cancelRequest` |

`CapabilityUnsupported` is the LSP-style graceful-degradation signal: the core
catches it and degrades the dimension rather than failing the pipeline.

## 6. Versioning & compatibility (Terraform-borrowed)

- `protocolVersion` is **semver**; breaking changes bump major.
- The core publishes a **compatibility matrix** (core version ↔ supported protocol
  majors), mirroring Terraform's CLI↔plugin-protocol matrix.
- Adapters pin **one** `engineVersion` (mandatory for Bevy given pre-1.0 churn; each
  engine minor release = a scheduled adapter-maintenance event).

## 7. Worked example — capability gap → graceful degradation

1. Core `initialize`s the Godot adapter. Manifest: `capture: { fidelity: "full",
   profile: "render" }`, `executionProfiles.render.requires: ["xvfb","vulkan-software:lavapipe"]`.
2. The CI runner has no xvfb. Core calls `capture/screenshot` → adapter returns
   `ProfileUnavailable`.
3. Core degrades the **visual** convergence dimension to "manual evidence required"
   and logs the dropped automation (no silent truncation), rather than failing.
4. Meanwhile `test`/`build`/`introspect` (headless-compute profile) proceed normally.

## 8. Open items (deferred to schema v1.1 / conformance design)

- Exact `$/progress` payload shape (percentage vs message-stream).
- Whether `capture/frames` returns inline frame paths or a manifest file for large
  sequences.
- Video: confirmed not native on any engine → modeled as `capture/frames` +
  external ffmpeg encode in Layer 2, not a protocol method. Revisit if an engine
  gains native video export.
- `introspect` query parameters (full dump vs targeted query/path) — Bevy BRP
  supports rich queries; normalize a subset across engines.
