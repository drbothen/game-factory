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
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-TBD
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

# BC-1.05.001: build Capability Returns Normalized BuildResult

## Description

When the factory core calls the `build` capability method, the adapter invokes
the engine-native build command (e.g., `cargo build --release` for Bevy,
Unity batch-mode build for Unity, `--headless --export` for Godot) and returns
a normalized `BuildResult` object regardless of the underlying engine's native
build output format. The core consumes only the normalized result.

## Preconditions

1. The adapter's `build` capability has `fidelity: "full"` or `"partial"`.
2. The adapter has been successfully initialized with a valid `projectPath`.
3. The engine toolchain (compiler, SDK) is present and accessible.
4. The `build` request params include at minimum a `progressToken` (optional)
   and may include `platform` target and `kind` overrides.

## Postconditions

1. The adapter returns a `BuildResult` object with all of the following fields:
   - `status`: `"succeeded"` or `"failed"`
   - `artifacts`: array (may be empty on failure) of `{ path, platform, kind }` objects
     where `path` is an absolute path, `platform` is a target identifier string,
     `kind` is `"binary"`, `"library"`, `"bundle"`, or `"archive"`
   - `durationMs`: non-negative integer (milliseconds elapsed)
   - `diagnostics`: array of `{ severity, message, file, line }` objects;
     `severity` is `"error"`, `"warning"`, or `"info"`
   - `log`: string containing the tail of the build output (last ≤4096 characters)
2. On success, `artifacts` contains at least one entry pointing to an existing file.
3. On failure, `status` is `"failed"` and `diagnostics` contains at least one
   `"error"` severity entry identifying the failure cause.
4. All `artifact.path` values are absolute paths accessible from the core's perspective.

## Invariants

1. `durationMs` is always present and non-negative.
2. The `log` field is never absent; it may be an empty string if the build produced
   no output.
3. The result schema is identical across Bevy (Cargo), Unity (batchmode), and Godot
   (export) adapters — the core never inspects engine-native output format.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Build produces warnings but no errors | `status: "succeeded"`; diagnostics contains warning entries; artifacts populated |
| EC-002 | Build times out (exceeds declared build timeout) | Adapter returns `OperationFailed` (`-32005`) with `data.reason: "timeout"` and partial log |
| EC-003 | Engine toolchain is missing | Adapter returns `EngineToolMissing` (`-32003`) before attempting the build |
| EC-004 | `progressToken` provided | Adapter sends `$/progress` notifications during the build with the token; still returns BuildResult at completion |
| EC-005 | Platform target not supported by this adapter | `OperationFailed` with `data.reason: "unsupported-platform"` |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter, valid project, no errors | `{ status: "succeeded", artifacts: [{path: "/abs/target/release/game", platform: "linux-x86_64", kind: "binary"}], durationMs: 84211, diagnostics: [], log: "Finished release..." }` | happy-path |
| Unity adapter, project with compile error | `{ status: "failed", artifacts: [], durationMs: 12000, diagnostics: [{severity: "error", message: "CS0103: name 'Foo' not found", file: "Assets/Game.cs", line: 42}], log: "...error output..." }` | error |
| Adapter with missing engine binary | `EngineToolMissing` error (`-32003`) | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-018 | BuildResult always contains status, artifacts, durationMs, diagnostics, log | schema validation in conformance suite |
| VP-TBD-019 | On status: "succeeded", artifacts is non-empty and all paths exist | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — normalized build results allow the factory core to process build outcomes without engine-specific parsing |
| L2 Domain Invariants | DI-001 (engine-specific build commands are adapter-internal; core sees only BuildResult) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.05.002 — sibling (build failure case)
- BC-1.04.001 — depends on (build runs on headless-compute profile)

## Architecture Anchors

- `planning/design/protocol-schema.md#31-buildresult`
