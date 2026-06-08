---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/planning/design/protocol-schema.md
  - .factory/planning/design/engine-adapter-protocol.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-1.02.001: initialize Handshake Returns Capability Manifest

## Description

When the factory core sends an `initialize` request to a newly spawned adapter,
the adapter responds with a fully populated Capability Manifest declaring the
engine identity, pinned version, protocol version, determinism tier, execution
profiles, and per-capability fidelity. The manifest is the single source of truth
for what the core may request from this adapter.

## Preconditions

1. The adapter process is running and connected to the core via stdio.
2. No previous `initialize` request has been sent in this session.
3. The core's `initialize` params include `protocolVersion` (semver string),
   `coreVersion` (semver string), `projectPath` (absolute path to game project),
   and `workspace.tmpDir` / `workspace.artifactDir` (absolute paths).
4. The `projectPath` directory exists and is readable by the adapter process.

## Postconditions

1. The adapter returns a JSON-RPC 2.0 success response whose `result` is a
   Capability Manifest object with all of the following fields populated:
   - `engine`: non-empty string identifier (e.g., `"bevy"`, `"unity"`, `"godot"`)
   - `engineVersion`: exact pinned version string (semver or build tag)
   - `adapterVersion`: semver string
   - `protocolVersion`: semver string matching or compatible with the core's requested version
   - `determinismTier`: one of `"bitwise-cross-platform"`, `"same-machine"`, `"tolerance-only"`
   - `executionProfiles`: object with keys `headless-compute` and `render`, each with `available: bool`
   - `capabilities`: object with at least the eight capability keys: `build`, `test`,
     `runHeadless`, `replay`, `capture`, `lint`, `assetsValidate`, `introspect`;
     each capability has a `fidelity` field of value `"full"`, `"partial"`, or `"none"`
2. The `render` execution profile's `requires` array lists all external dependencies
   needed to start the render profile (e.g., `"vulkan-software:lavapipe"`,
   `"xvfb"`, `"gl-software:llvmpipe"`).
3. After a successful `initialize` response, the adapter is ready to accept
   capability method calls.
4. The core sends an `initialized` notification immediately after receiving the
   manifest; the adapter may then begin any background initialization work
   (e.g., project scanning for dynamic capability upgrade).

## Invariants

1. The manifest fields `engine` and `engineVersion` are immutable for the lifetime
   of the session; they cannot change after `initialize`.
2. No capability method may be called before `initialize` completes successfully.
3. The `protocolVersion` in the response is a version the adapter supports; it is
   never a version not in the adapter's supported range.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `projectPath` exists but has no engine project files | Adapter returns manifest with all capabilities at `fidelity: "none"` if it cannot identify the project; does NOT error on `initialize` |
| EC-002 | `engineHint` param is provided but adapter self-identifies as a different engine | Adapter ignores `engineHint` and returns its own engine identity; `engineHint` is advisory only |
| EC-003 | `projectPath` directory does not exist | Adapter may return `initialize` success with all capabilities `fidelity: "none"` OR return an `OperationFailed` error; it MUST NOT crash silently |
| EC-004 | Core sends a second `initialize` request in the same session | Adapter returns `InvalidRequest` (`-32600`) — double initialize is not permitted |
| EC-005 | `workspace.tmpDir` does not exist | Adapter creates it or returns manifest with affected capabilities noted as degraded; does not crash |
| EC-006 | render profile `available: false` | Manifest is still valid; `capture` capability fidelity must be `"none"` when render profile is unavailable |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Valid `initialize` params with Bevy project path | Manifest with `engine: "bevy"`, `determinismTier: "bitwise-cross-platform"`, `capabilities.build.fidelity: "full"`, `executionProfiles.render.requires: ["vulkan-software:lavapipe"]` | happy-path |
| Valid `initialize` params with Unity project path | Manifest with `engine: "unity"`, `determinismTier: "same-machine"`, `capabilities.capture.fidelity: "partial"`, render profile notes xvfb requirement | happy-path |
| `initialize` with nonexistent `projectPath` | Response: manifest with all capabilities `fidelity: "none"` OR `OperationFailed` error; not a process crash | edge-case |
| Second `initialize` in same session | `{"jsonrpc":"2.0","id":2,"error":{"code":-32600,"message":"Invalid Request: already initialized"}}` | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-003 | Every Capability Manifest returned by `initialize` contains all 8 required capability keys | schema validation in conformance suite |
| VP-TBD-004 | `determinismTier` is always one of the three declared enum values | schema validation + proptest |
| VP-TBD-005 | If render profile `available: false`, capture capability fidelity is always `"none"` | conformance test: set render unavailable, assert capture fidelity |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the `initialize` handshake is the mechanism by which the factory learns what an engine can do without coupling to it by name |
| L2 Domain Invariants | DI-001 (core never names engine — engine identity is declared BY the adapter, not assumed by the core); DI-002 (conformance passes before acceptance — initialize is the first conformance step); DI-004 (determinismTier declared here, never assumed) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.01.001 — depends on (uses JSON-RPC 2.0 framing)
- BC-1.02.002 — sibling (protocol version mismatch case)
- BC-1.03.001 — depends on (dynamic registration upgrades capabilities declared here)
- BC-1.04.001 — composes with (execution profiles are part of this manifest)
- BC-1.12.001 — composes with (determinismTier is declared in this manifest)

## Architecture Anchors

- `planning/design/protocol-schema.md#1-lifecycle` — initialize request/response schema
- `planning/design/protocol-schema.md#2-capability-manifest-schema` — manifest shape
- `planning/design/engine-adapter-protocol.md#capabilities-the-fixed-surface-every-adapter-implements`

## Story Anchor

S-TBD — Adapter initialize handshake

## VP Anchors

- VP-TBD-003 — Manifest completeness
- VP-TBD-004 — DeterminismTier enum validity
