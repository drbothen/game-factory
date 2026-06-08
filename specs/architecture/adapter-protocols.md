---
document_type: architecture-section
level: L3
section: adapter-protocols
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
traces_to_caps:
  - CAP-001
  - CAP-002
  - CAP-004
  - CAP-009
  - CAP-014
traces_to_adrs:
  - ADR-0002
  - ADR-0004
  - ADR-0007
inputs:
  - .factory/specs/architecture/ARCH-INDEX.md
  - .factory/specs/architecture/layered-architecture.md
  - .factory/specs/architecture/subsystem-decomposition.md
  - .factory/specs/architecture/adrs/ADR-0004-adapter-family-anti-lock-in.md
  - .factory/specs/architecture/adrs/ADR-0007-human-gated-fidelity-tier.md
  - .factory/planning/design/engine-adapter-protocol.md
  - .factory/planning/design/protocol-schema.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/prd-supplements/prd-cap-001.md
  - .factory/specs/prd-supplements/prd-cap-002-003.md
  - .factory/specs/prd-supplements/prd-cap-004.md
  - .factory/specs/prd-supplements/prd-cap-009-010.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Adapter Protocol Family

> **v1.1 changes (Phase-1d arch alignment — C4 JSON-RPC reconciliation):**
> - §1.5 error table: added `E-EAP Code` column mapping every JSON-RPC code to its
>   error-taxonomy E-EAP-NNN entry.
> - Added `-32009 KernelAntiCheatAttempted / E-EAP-011` row — this code was previously
>   colliding with `-32007 MalformedManifest`. Collision resolved by assigning
>   `KernelAntiCheatAttempted` to -32009 (next available in protocol-reserved range).
> - `-32007 MalformedManifest` retains its code; now registered as E-EAP-012.
> - `-32008 HumanGatedTaskPending` retains its code; now registered as E-EAP-013.

> **Pass 2a scope.** This document defines the four-seam adapter protocol as one
> coherent pattern and then shows how each seam instantiates that pattern with its
> own delta. The base protocol mechanics (transport, lifecycle, capability negotiation,
> fidelity model, versioning) are defined once here and are NOT repeated per seam.
> All four seams inherit these mechanics; each seam section describes only what
> differs from the base.

---

## 1. Base Protocol Pattern

All four adapter seams share one structural pattern, established in ADR-0002 and
ADR-0004:

> **Capability-negotiation manifest + fidelity grading + driver hook + conformance
> suite.**

A seam is not a custom protocol — it is an instantiation of this pattern
parameterized by its capability surface. The consequence stated in ADR-0004: adding
a new backend on any seam means "implement adapter + pass conformance for declared
capabilities. ZERO core changes."

---

### 1.1 Transport Framing

All adapters that run as subprocesses use **JSON-RPC 2.0 over stdio** with
**LSP-style Content-Length framing**:

```
Content-Length: <byte-count>\r\n
\r\n
{"jsonrpc":"2.0","id":<N>,"method":"<method>","params":{...}}
```

- The **core is the client**; the **adapter is the server** (LSP role convention).
- The core drives all requests; the adapter executes and reports.
- Long operations carry a `progressToken` and are cancellable via `$/cancelRequest`.
- Asynchronous notifications from adapter to core use `$/progress` (progress stream),
  `$/log` (structured log line), and seam-specific event notifications.

Asset-adapter and distribution-adapter may alternatively expose an HTTP/REST surface
for cloud-API backends; in that case the factory core acts as the HTTP client. The
**capability manifest schema and fidelity model are identical regardless of transport**.
The per-seam sections below note which transport applies.

---

### 1.2 LSP-Style Lifecycle

Every adapter that uses the stdio transport follows this lifecycle:

| Method | Direction | Kind | Purpose |
|--------|-----------|------|---------|
| `initialize` | core → adapter | request | Exchange protocol versions + return Capability Manifest |
| `initialized` | core → adapter | notification | Core ready; adapter may begin background work |
| `capability/register` | adapter → core | notification | Adapter upgrades a capability after project inspection |
| `capability/unregister` | adapter → core | notification | Adapter downgrades a capability |
| `shutdown` | core → adapter | request | Graceful stop; adapter flushes in-flight work |
| `exit` | core → adapter | notification | Terminate process |
| `$/progress` | adapter → core | notification | Progress on a long-running request |
| `$/cancelRequest` | core → adapter | notification | Cancel an in-flight request |
| `$/log` | adapter → core | notification | Structured log line |

**Dynamic capability registration** (LSP-borrowed) is the key negotiation mechanism.
An adapter declares conservative fidelity at `initialize` time, then upgrades or
downgrades capabilities after inspecting the project or environment. The core
re-plans gates on receipt. This prevents lowest-common-denominator design: the
factory gets the best available capability from each backend rather than the worst
common subset.

---

### 1.3 Capability Manifest Schema

The `initialize` response returns a Capability Manifest. All four seams use a variant
of this top-level shape:

```jsonc
{
  "seam":            "<engine-adapter|asset-adapter|distribution-adapter|xr-adapter>",
  "targetId":        "<engine-name | backend-name | platform-name>",
  "targetVersion":   "<pinned version string>",          // mandatory; see §1.6
  "adapterVersion":  "<semver>",
  "protocolVersion": "<semver>",

  "capabilities": {
    "<capName>": {
      "fidelity": "<full|partial|none|human-gated>",
      // seam-specific fields follow (see per-seam sections)
    }
    // ...
  },

  // engine-adapter only:
  "determinismTier":  "<bitwise-cross-platform|same-machine|tolerance-only>",
  "executionProfiles": { ... }
}
```

**All fields are required** unless marked optional in a per-seam section. A manifest
missing required fields causes the core to return a `MalformedManifest` protocol error
and refuse to proceed.

---

### 1.4 Fidelity Grading Model

Every capability in every manifest carries exactly one fidelity value. Per ADR-0007,
the full enum is:

| Grade | Meaning | Hook behavior |
|-------|---------|---------------|
| `full` | Capability fully automated and verified by conformance | Proceeds without human intervention |
| `partial` | Capability automated with declared, documented limitations | Proceeds with degraded convergence signal; limitations must be stated in manifest |
| `none` | Capability not implemented by this adapter | Returns `CapabilityUnsupported`; pipeline degrades gracefully |
| `human-gated` | Automatable prefix complete; single checklisted human task surfaced | **Blocks progression** until human acknowledgment is recorded; suppression is a hook-detectable defect (DI-006) |

**Fidelity-to-convergence-dimension coupling.** The convergence engine (SS-06) reads
fidelity grades from all four seams as first-class signals. A dimension whose
underlying capability grade is `none` degrades to its declared fallback; a dimension
with an unacknowledged `human-gated` task is blocked. This is the mechanism by which
honest capability declarations drive honest convergence outcomes.

**`human-gated` is NOT a creative finishing gate.** Pure-maximal asset generation
(CAP-004) is lights-out. `human-gated` applies exclusively to external, third-party-
required human acts as enumerated in ADR-0007: console cert sign-off, store
publish/pricing, SAG-AFTRA consent, legal opinion, XR comfort-cert, paid-UGC vetting.

---

### 1.5 Protocol-Level Error Taxonomy

JSON-RPC 2.0 standard error codes (`-32600` range) plus the protocol-reserved range
`-32000` to `-32099`:

| Code | Name | E-EAP Code | Meaning |
|------|------|------------|---------|
| -32700 | `ParseError` | E-EAP-010 | JSON-RPC 2.0 standard: invalid JSON |
| -32600 | `InvalidRequest` | E-EAP-008 | JSON-RPC 2.0 standard: not a valid Request object |
| -32601 | `MethodNotFound` | E-EAP-009 | JSON-RPC 2.0 standard: method does not exist |
| -32602 | `InvalidParams` | — | JSON-RPC 2.0 standard: invalid method parameters |
| -32603 | `InternalError` | — | JSON-RPC 2.0 standard: internal adapter error |
| -32000 | `ProtocolVersionMismatch` | E-EAP-001 | Core/adapter protocol versions incompatible; response includes `supportedRange` |
| -32001 | `CapabilityUnsupported` | E-EAP-002 | Called a capability whose fidelity is `none`; core must degrade, not fail |
| -32002 | `ProfileUnavailable` | E-EAP-003 | Requested execution profile not available on this runner (e.g., no lavapipe on CI) |
| -32003 | `EngineToolMissing` | E-EAP-004 | Required binary, license, or tool not found (e.g., Unity license file, export templates) |
| -32004 | `DeterminismTierViolation` | E-EAP-005 | Core requested a comparison stricter than the declared tier supports |
| -32005 | `OperationFailed` | E-EAP-006 | Engine/tool operation ran but failed; see `data` for result detail |
| -32006 | `Cancelled` | E-EAP-007 | Request cancelled via `$/cancelRequest` |
| -32007 | `MalformedManifest` | E-EAP-012 | Manifest returned from `initialize` is missing required fields |
| -32008 | `HumanGatedTaskPending` | E-EAP-013 | Attempted to proceed past a `human-gated` boundary without acknowledgment (DI-006; ADR-0007) |
| -32009 | `KernelAntiCheatAttempted` | E-EAP-011 | Factory output artifact contains kernel-mode anti-cheat code pattern (DI-010 violation; BC-1.15.002) |

`CapabilityUnsupported` is the primary graceful-degradation signal. The core is
required to catch it and degrade the affected convergence dimension rather than
propagating a pipeline failure. Silent truncation (logging neither the degradation
nor the reason) is forbidden.

---

### 1.6 Versioning and Compatibility Matrix

- `protocolVersion` follows **semver**; breaking changes bump the major version.
- The core publishes a **Compatibility Matrix** (Terraform-borrowed) mapping core
  versions to supported protocol major versions:

```jsonc
{
  "compatibility-matrix": {
    "game-factory-core": {
      "0.1.x": { "supported-protocol-majors": ["1"] },
      "0.2.x": { "supported-protocol-majors": ["1", "2"] }
    }
  }
}
```

- Every adapter pins **exactly one** `targetVersion` in its manifest. Engine version
  pinning is mandatory (not advisory) because fast-moving targets — Bevy pre-1.0 with
  quarterly API churn, Unity release cadence — make floating-version adapters
  unreliable. Each engine minor release triggers a scheduled adapter-maintenance event.
- If the adapter's `protocolVersion` major is not in the core's supported set, the
  core returns `ProtocolVersionMismatch` during `initialize` and refuses to proceed.

---

### 1.7 Conformance Suite (CAP-002 Pattern)

Every seam has a conformance suite that gates adapter acceptance. The suite is
**capability-gated** (CRI/CSI-style): the suite runs only the test cases for
capabilities that the manifest declares. An adapter that declares `capture: full`
must pass the capture conformance cases; an adapter that declares `capture: none`
is not tested for capture.

**Structure of each seam's conformance suite:**

1. **Manifest validation** — required fields present, fidelity values are valid
   enum members, no contradictory declarations.
2. **Per-capability functional tests** — for each declared non-`none` capability,
   the suite exercises the happy path and at least one error path.
3. **Graceful degradation tests** — for each `none`-fidelity capability, the suite
   verifies that calling it returns `CapabilityUnsupported` (not a crash).
4. **`human-gated` surfacing tests** — for each `human-gated` capability, the suite
   verifies that the adapter surfaces the correct checklist item and does NOT attempt
   to complete the terminal step autonomously (DTU-07 pattern).
5. **Version and compatibility** — adapter reports correct `protocolVersion`; responds
   correctly to `ProtocolVersionMismatch` for an incompatible core.

The engine-adapter conformance suite (CAP-002) is the P0 reference implementation.
Asset, distribution, and XR conformance suites follow the same five-part structure.

---

## 2. Engine-Adapter Seam

**Lock-in prevented:** N different game engines for one game capability surface.
**Subsystem:** SS-01 (CAP-001 + CAP-002)
**Transport:** JSON-RPC 2.0 stdio (as defined in §1.1)

---

### 2.1 Engine-Adapter Capability Surface

The eight capabilities every engine adapter declares:

| Capability | What the adapter does | Typical profile |
|------------|-----------------------|-----------------|
| `build` | Headless CI build → artifact | headless-compute |
| `test` | Run engine test framework → normalized TestResult | headless-compute |
| `runHeadless` | Launch game deterministically, no display | headless-compute |
| `replay` | Record input stream → replay → assert sim state | headless-compute |
| `capture` | Screenshot / video frame grab | render |
| `lint` | Language static analysis → normalized LintResult | headless-compute |
| `assetsValidate` | Import + validate asset integrity | headless-compute |
| `introspect` | Dump scene graph / entities / config → normalized tree | headless-compute |

Capabilities are **independent and separately fidelity-graded**. They are never
bundled. Research confirmed that "headless implies capture" is false on all three
founding engines: Bevy requires lavapipe (software Vulkan); Unity requires xvfb
(dropping `-nographics`); Godot's `--headless` disables all rendering.

---

### 2.2 Engine-Adapter Manifest Delta

Fields additional to the base manifest schema:

```jsonc
{
  // engine-adapter-specific additions to base manifest:
  "determinismTier": "bitwise-cross-platform | same-machine | tolerance-only",

  "executionProfiles": {
    "headless-compute": {
      "available": true
    },
    "render": {
      "available": true,
      "windowless": true,                       // Bevy: true; Unity/Godot: false
      "requires": ["vulkan-software:lavapipe"], // OR ["xvfb", "gl-software:llvmpipe"]
      "notes": "<adapter-specific note>"
    }
  },

  "capabilities": {
    "build":          { "fidelity": "full" },
    "test":           { "fidelity": "full",
                        "resultFormat": "junit-xml | nunit3-xml | libtest-json" },
    "runHeadless":    { "fidelity": "full", "profile": "headless-compute" },
    "replay":         { "fidelity": "full | partial | none",
                        "prerequisites": ["fixed-timestep", "seeded-rng", "input-injection"],
                        "method": "<replay-method-string>" },
    "capture":        { "fidelity": "full | partial | none",
                        "profile": "render",
                        "modes": ["screenshot", "frame-sequence"] },
    "lint":           { "fidelity": "full",
                        "cmd": "<lint-command>" },
    "assetsValidate": { "fidelity": "full | partial",
                        "method": "<validation-method-string>" },
    "introspect":     { "fidelity": "full | partial",
                        "method": "brp-jsonrpc | ecs-world-dump | scene-tree-script" }
  }
}
```

---

### 2.3 Determinism Tier (ADR-0003)

`determinismTier` is an engine-adapter-only field. It drives the replay comparison
method the core selects:

| Tier | Replay comparison method | Reference engine |
|------|--------------------------|-----------------|
| `bitwise-cross-platform` | `snapshot-hash-diff` (exact, across any runner) | Bevy + Rapier |
| `same-machine` | `snapshot-hash-diff` on pinned CI runner only | Unity PhysX (Enhanced Determinism) |
| `tolerance-only` | `tolerance-window` metric diff | Godot physics; FP-heavy sims |

**Replay prerequisites.** For any `replay` fidelity other than `none`, the manifest
must declare all three prerequisites: `fixed-timestep`, `seeded-rng`,
`input-injection`. An adapter missing any of the three must declare `replay: none`,
which degrades the D-REPLAY convergence dimension to human playtest evidence.

---

### 2.4 Per-Engine Deltas (Founding Trio)

| Field | Bevy adapter | Unity adapter | Godot adapter |
|-------|-------------|---------------|----------------|
| `determinismTier` | `bitwise-cross-platform` (with Rapier) | `same-machine` (PhysX Enhanced Determinism) | `tolerance-only` |
| `render.windowless` | `true` (offscreen wgpu offscreen-render-to-texture) | `false` (must drop `-nographics`; use xvfb) | `false` (must drop `--headless`; use xvfb) |
| `render.requires` | `["vulkan-software:lavapipe"]` | `["xvfb", "gl-software:llvmpipe"]` | `["xvfb", "gl-software:llvmpipe"]` |
| `replay.fidelity` | `full` (DIY on ECS; `leafwing_input_playback`) | `full` with new Input System; `none` with legacy | `partial` (DIY via `parse_input_event`) |
| `replay.method` | `ecs-tick-recorder` | `input-system-eventtrace` | `scene-tree-input-replay` |
| `introspect.method` | `brp-jsonrpc` (standout: native BRP) | `scene-tree-script` (editor-script DIY) | `scene-tree-print` (native `print_tree_pretty`) |
| `test.resultFormat` | `libtest-json` (nextest primary) | `nunit3-xml` | `junit-xml` (GUT) |
| Engine-specific note | Pre-1.0 churn: pin exact version; budget per-release migration | Per-CI-agent licensing required (`.ulf` / Build Server / floating) | True headless; capture is the exception (same pattern as Unity) |

**Unity dynamic registration example.** The Unity adapter reports
`replay: { fidelity: "none" }` at `initialize` (cannot know whether the project uses
new or legacy Input System). After project inspection, if the new Input System package
is present, the adapter sends `capability/register` upgrading `replay` to
`{ fidelity: "full", method: "input-system-eventtrace" }`. The core re-plans the
D-REPLAY gate accordingly.

---

### 2.5 Normalized Result Schemas

All capabilities return normalized result objects. Layers 1-2 consume only these shapes;
they never touch engine-native formats.

**TestResult** (JUnit XML / NUnit 3 XML / libtest-JSON all normalize to this):
```jsonc
{
  "suite": "<suite-name>",
  "tests": [
    { "id": "<test-id>", "status": "pass|fail|skip",
      "durationMs": 0, "message": null, "assertion": null }
  ],
  "totals": { "pass": 0, "fail": 0, "skip": 0 },
  "sourceFormat": "junit-xml | nunit3-xml | libtest-json",
  "capabilityFidelity": "full | partial",
  "engine": "<engine-name>"
}
```

**ReplayResult** (comparison method dictated by `determinismTier`):
```jsonc
{
  "mode": "play",
  "comparison": {
    "method": "snapshot-hash-diff | tolerance-window",
    "passed": true,
    "baselineHash": "<hash>",           // hash-diff only
    "actualHash": "<hash>",             // hash-diff only
    "diffs": []                         // tolerance-window: [{tick, field, expected, actual, delta, withinTolerance}]
  }
}
```

**IntrospectResult** (ECS world-dump and scene-tree both normalize to `root`):
```jsonc
{
  "format": "ecs | scene-tree",
  "root": {
    "id": "<entity-id>", "name": "<name>",
    "components": [{ "type": "<TypeName>", "value": { /* ... */ } }],
    "children": [ /* recursive same shape */ ]
  },
  "source": "brp-jsonrpc | scene-tree-print | scene-tree-script"
}
```

---

## 3. Asset-Adapter Seam

**Lock-in prevented:** N generative AI backends for one asset class.
**Subsystem:** SS-03 (CAP-004)
**Transport:** HTTP/REST or subprocess JSON-RPC, per backend (see §3.1)

---

### 3.1 Transport Note

Generative asset backends are cloud APIs. The factory core acts as the HTTP client;
the asset-adapter is a thin driver that wraps the external API and returns a normalized
response including the mandatory provenance sidecar. The JSON-RPC lifecycle (§1.2)
does not apply to asset-adapters — there is no subprocess to `initialize`. Instead,
the adapter exposes a `capabilities()` endpoint / function that returns its capability
manifest.

---

### 3.2 Backend-Class Taxonomy

Every asset-adapter manifest declares a `backend_class` that encodes the automation
and legal risk profile of the backend:

| backend_class | Meaning | Indemnification | Examples |
|---------------|---------|-----------------|---------|
| `cloud-api` | Fully automated REST/gRPC API; no human in the loop | Varies | Tripo, Rodin, ElevenLabs, Stable Audio |
| `headless-cli` | Local CLI tool, no display required | Varies | Houdini CLI, ffmpeg, SpeedTree CLI |
| `mcp-headless` | MCP server backend, fully automated | Varies | Custom MCP generation tool |
| `mcp-gui` | MCP server with a required GUI session | None automated | GUI tool wrapped via MCP |
| `saas-ui` | SaaS requiring a browser UI session | Varies | Tools with no API |
| `desktop-gui` | Local desktop application, GUI required | Varies | Photoshop (no API) |

**Preference ordering.** The asset routing policy prefers backends in this order:
`cloud-api` > `headless-cli` > `mcp-headless` > `mcp-gui` > `saas-ui` > `desktop-gui`.
Backends requiring a GUI session (`mcp-gui`, `saas-ui`, `desktop-gui`) cannot
participate in headless CI pipelines; they are valid for human-triggered asset
generation passes only.

---

### 3.3 Asset-Adapter Capability Surface

Each asset-adapter manifest declares capabilities per **asset modality**:

| Capability | Asset class | Typical fidelity |
|------------|-------------|-----------------|
| `generate.mesh3d` | 3D mesh (GLB) | full (Tripo/Rodin) or partial (lower-tier) |
| `generate.texture` | Texture maps (PBR set) | full or partial |
| `generate.audio.sfx` | Sound effects | full |
| `generate.audio.music` | Music | full (licensed providers only; blocked = none per DI-009) |
| `generate.audio.voice` | Voice/dialogue | full or human-gated (SAG-AFTRA consent path) |
| `generate.image.concept` | Concept art / 2D image | full or partial |
| `generate.text.narrative` | Narrative text | full |

---

### 3.4 Provenance Sidecar Requirement

Every asset-adapter response **must** include a provenance sidecar alongside the
generated asset. This is non-negotiable per DI-003. Any asset-adapter that returns
an asset without a complete sidecar is non-conformant.

**Mandatory sidecar fields** (all must be non-null; `disclosure_class` added in v2.0):

```jsonc
{
  "generated_by_tool":         "<vendor/tool-name>",
  "model_version":             "<pinned model/weights version>",
  "generation_date":           "<ISO-8601 timestamp>",
  "prompt_and_inputs_log":     "<full prompt + reference inputs>",
  "human_modifications_log":   [],              // empty at generation; populated on human transform
  "license_terms_snapshot":    { "commercial_use": true, "indemnification_tier": "1|2|3" },
  "training_data_provenance":  "licensed | open | unknown",
  "likeness_consent_ref":      null,            // non-null → triggers human-gated SAG-AFTRA flow
  "risk_tier":                 "1 | 2 | 3",
  "copyrightability_assessment": "likely | partial | unlikely",
  "disclosure_class":          "pre-generated | live-generated | procedural-exempt"
}
```

**`disclosure_class` drives `ai-disclosure-manifest` generation** (D-PROV convergence
dimension). It maps to Steam AI disclosure categories (Jan 2026 rewrite) and supports
EU AI Act Art. 50 C2PA marking (mandatory 2026-08-02).

---

### 3.5 Asset-Adapter Fidelity Deltas

| Capability | full conditions | partial conditions | none conditions | human-gated trigger |
|------------|----------------|-------------------|-----------------|---------------------|
| `generate.audio.music` | Licensed backend (Stable Audio, AIVA, Soundraw) | Limited duration / stems only | Backend is Suno/Udio (DI-009 block) or any unlicensed provider | — |
| `generate.audio.voice` | Non-likeness voice; consent-framework provider | Accent/style limitations | — | `likeness_consent_ref != null` → SAG-AFTRA IMA signature required |
| `generate.mesh3d` | Tier-1 backend; full PBR GLB output | Partial topology / UV unwrap | Backend unavailable | — |

**SAG-AFTRA consent path.** When `likeness_consent_ref != null` in the generation
request, the adapter must declare `generate.audio.voice: human-gated` for that
asset. The factory surfaces the consent signature checklist task (DI-006). The
adapter may NOT proceed to generation until the consent reference is populated with
a valid consent document ID.

---

## 4. Distribution-Adapter Seam

**Lock-in prevented:** N store / platform targets for one game build.
**Subsystem:** SS-08 (CAP-009 + CAP-010)
**Transport:** CLI subprocess (non-interactive) or REST API, per target

---

### 4.1 Distribution-Adapter Capability Surface

Each distribution-adapter declares per-target capabilities:

| Capability | What it does | Fidelity range |
|------------|-------------|----------------|
| `build.package` | Produce platform-ready build package | full or partial |
| `upload.depot` | Upload build to platform depot/channel | full or partial |
| `cert.preflight` | Run machine-checkable cert pre-flight | full or partial |
| `cert.submit` | Submit for final platform certification | human-gated (always) |
| `store.publish` | Publish listing + pricing to store | human-gated (always) |
| `store.assets` | Upload store assets (capsules, screenshots, trailer) | full or partial |
| `compliance.iarc` | Auto-fill IARC questionnaire | full (objective questions) or partial |
| `compliance.ratings-submit` | Submit ratings to rating body | human-gated (terminal sign-off) |

**Human-gated terminal steps.** The following distribution capabilities are
`human-gated` by structural necessity — they require a human actor (console
platform account, store account, or legal signatory) and cannot ever become `full`:

- `cert.submit` — console platform cert sign-off (PSN / Nintendo / Xbox NDA-gated)
- `store.publish` — store page publish and pricing (all platforms)
- `compliance.ratings-submit` — ratings submission terminal sign-off
- Platform account setup (PSN / Nintendo developer account) — surfaces as a checklist
  item, not a distribution capability

---

### 4.2 CLI Prefix Declarations

For CLI-based distribution adapters, the manifest declares the CLI executable and
non-interactive invocation pattern. All three verified CLIs use non-interactive modes
that are CI-safe:

| Platform | CLI prefix | Non-interactive flag | Verified |
|----------|-----------|---------------------|---------|
| Steam | `steamcmd` | `+login <user> +run_app_build +quit` | Yes |
| itch.io | `butler` | `push <dir> <target>` | Yes |
| iOS/Android | `fastlane` | `deliver` / `supply` (CI lane) | Yes |
| Xbox | `gdksubmissionvalidator` | CLI validation only; submission portal = human-gated | Yes (preflight only) |

**Console cert sign-off and PSN/Nintendo submission are NDA-gated.** No CLI
automation beyond cert pre-flight is possible. The distribution adapter surfaces
these as `human-gated` checklist items; it must not attempt autonomous completion.

---

### 4.3 Distribution-Adapter Manifest Delta

```jsonc
{
  "seam": "distribution-adapter",
  "targetId":      "<steam|itchio|ios|android|xbox|psn|switch>",
  "targetVersion": "<platform-SDK-or-CLI-version>",

  "capabilities": {
    "build.package":          { "fidelity": "full | partial",
                                "cli": "<command-template>" },
    "upload.depot":           { "fidelity": "full",
                                "cli_prefix": "steamcmd | butler | fastlane" },
    "cert.preflight":         { "fidelity": "full | partial",
                                "coverage_pct": 75,           // estimated % of cert items checkable
                                "notes": "<unchecked categories>" },
    "cert.submit":            { "fidelity": "human-gated",
                                "checklist_item": "<platform>-cert-sign-off" },
    "store.publish":          { "fidelity": "human-gated",
                                "checklist_item": "<platform>-store-publish" },
    "store.assets":           { "fidelity": "full | partial",
                                "asset_spec_ref": "<store-page-spec link>" },
    "compliance.iarc":        { "fidelity": "full",
                                "coverage": "objective-questions-only" },
    "compliance.ratings-submit": { "fidelity": "human-gated",
                                    "checklist_item": "<body>-ratings-sign-off" }
  }
}
```

---

### 4.4 Human-Gated Task Surfacing Contract

When the factory reaches a `human-gated` distribution capability:

1. The adapter returns the capability result with `fidelity: human-gated` and a
   `checklist_item` key identifying the required human action.
2. The core records an open human-gated task in the convergence tracker (SS-06).
   The D-CERT convergence dimension is marked blocked until the task is acknowledged.
3. The human completes the action externally and records acknowledgment in the factory.
4. The core marks the task complete and unblocks D-CERT.
5. **Suppression is a defect.** Any adapter path that returns success without
   surfacing the checklist item (auto-completing the human step) fails the
   `human-gated` conformance case (DTU-07 pattern).

---

## 5. XR-Adapter Seam

**Lock-in prevented:** N XR runtimes for one XR game.
**Subsystem:** SS-12 (CAP-014) — **seam contract defined; implementation DEFERRED**
**Transport:** JSON-RPC 2.0 stdio (same as engine-adapter)

> **Implementation status.** The XR seam contract schema is defined here so that
> the Layer-3 protocol surface is stable before implementation begins. No XR adapter
> implementation is built in v1. The seam can be added without any core change.

---

### 5.1 XR-Adapter Capability Surface

| Capability | What it does | Fidelity range |
|------------|-------------|----------------|
| `xr.session` | Initialize / manage OpenXR session lifecycle | full or partial |
| `xr.render` | Stereoscopic per-eye render (frame submission) | full or partial |
| `xr.input` | Controller / hand / eye tracking input | full or partial |
| `xr.spatial` | Room-scale / guardian / passthrough | full, partial, or none |
| `xr.comfort_certify` | XR comfort / comfort-cert evaluation | human-gated (always) |
| `xr.cts` | Run Khronos OpenXR CTS conformance suite | full or none |

---

### 5.2 OpenXR Extension Namespace Fidelity Grading

For OpenXR adapters, per-extension capabilities are graded by Khronos extension
namespace:

| Namespace | Fidelity value | Meaning |
|-----------|---------------|---------|
| `KHR` (Khronos ratified) | `full` | Cross-vendor, stable, CTS-covered |
| `EXT` (multi-vendor) | `partial` | Broadly supported but not ratified |
| `vendor` (e.g., `XR_FB_`, `XR_MSFT_`) | `partial/vendor` | Vendor-specific; may not port |

**Apple Vision Pro** is a separate, non-OpenXR adapter target. visionOS uses
`ARKit` / `RealityKit` / `CompositorServices` and does not implement the OpenXR API.
It is treated as an independent adapter with its own capability manifest.

---

### 5.3 XR Comfort Certification Gate

`xr.comfort_certify` is `human-gated` by physical necessity: comfort/nausea
certification requires a human wearing the headset. The vestibular system cannot
be simulated. This is not a creative finishing gate — it is a physiological
constraint. The `human-gated` tier applies (DI-006).

**Checklist item emitted:** `<platform>-xr-comfort-cert` (e.g.,
`meta-quest-xr-comfort-cert`, `visionos-xr-comfort-cert`).

---

### 5.4 XR Adapter Manifest Delta

```jsonc
{
  "seam":          "xr-adapter",
  "targetId":      "openxr-1.1 | visionos",
  "targetVersion": "<OpenXR-spec-version | visionOS-SDK-version>",

  "openxrExtensions": {
    "KHR": ["XR_KHR_composition_layer_depth"],    // example
    "EXT": ["XR_EXT_hand_tracking"],              // example
    "vendor": ["XR_FB_foveation"]                 // example
  },

  "capabilities": {
    "xr.session":         { "fidelity": "full" },
    "xr.render":          { "fidelity": "full",
                            "minRefreshHz": 90,
                            "perEyeFrameTimeBudgetMs": 11.1 },
    "xr.input":           { "fidelity": "full | partial",
                            "profiles": ["<controller-profile-paths>"] },
    "xr.spatial":         { "fidelity": "full | partial | none" },
    "xr.comfort_certify": { "fidelity": "human-gated",
                            "checklist_item": "<platform>-xr-comfort-cert" },
    "xr.cts":             { "fidelity": "full | none",
                            "ctsVersion": "<Khronos-CTS-version>" }
  }
}
```

---

## 6. Conformance Hooks: CAP-002 Gating Each Seam

CAP-002 defines conformance gating. The same pattern applies to all four seams.
An adapter is **not accepted** until it passes conformance for its declared
capabilities. The hook chain enforces this gate:

| Hook event | Trigger | Enforcement |
|------------|---------|-------------|
| `pre-adapter-accept` | Adapter declares itself ready | Runs conformance suite for all non-`none` capabilities; blocks on any failure |
| `post-capability-register` | Adapter sends `capability/register` | Re-runs conformance for the upgraded capability only |
| `ci-adapter-drift` | Scheduled or on CI | Runs conformance suite on pinned adapter version; flags any regression |

**Human-gated conformance.** For `human-gated` capabilities, the conformance test
does NOT simulate the human action. It tests that:
1. The adapter returns `human-gated` fidelity (not `full` or `partial`).
2. The `checklist_item` key is present and non-empty.
3. Calling the capability does not autonomously complete the terminal step.

---

## 7. Compatibility Matrix Format

The core publishes a compatibility matrix file at a well-known path
(`.factory/adapter-compatibility-matrix.json`):

```jsonc
{
  "schema_version": "1",
  "core_version": "<semver>",
  "seams": {
    "engine-adapter": {
      "protocol_major": "1",
      "min_adapter_version": "1.0.0",
      "accepted_engines": {
        "bevy":  { "tested_versions": ["0.18.x"], "tier": "T1", "status": "accepted" },
        "unity": { "tested_versions": ["6000.0.x"], "tier": "T2", "status": "accepted" },
        "godot": { "tested_versions": ["4.3.x"], "tier": "T3", "status": "accepted" },
        "unreal":{ "tested_versions": [], "status": "deferred" }
      }
    },
    "asset-adapter": {
      "protocol_major": "1",
      "accepted_backends": {
        "tripo":          { "status": "accepted", "asset_classes": ["mesh3d"] },
        "stable-audio":   { "status": "accepted", "asset_classes": ["audio.music"] },
        "elevenlabs":     { "status": "accepted", "asset_classes": ["audio.voice"] },
        "suno":           { "status": "blocked",  "reason": "DI-009-litigation-exposure" },
        "udio":           { "status": "blocked",  "reason": "DI-009-litigation-exposure" }
      }
    },
    "distribution-adapter": {
      "protocol_major": "1",
      "accepted_targets": {
        "steam":   { "cli": "steamcmd", "status": "accepted" },
        "itchio":  { "cli": "butler",   "status": "accepted" },
        "ios":     { "cli": "fastlane", "status": "accepted" },
        "android": { "cli": "fastlane", "status": "accepted" }
      }
    },
    "xr-adapter": {
      "protocol_major": "1",
      "accepted_targets": {
        "openxr-1.1": { "status": "seam-defined-implementation-deferred" },
        "visionos":   { "status": "seam-defined-implementation-deferred" }
      }
    }
  }
}
```
