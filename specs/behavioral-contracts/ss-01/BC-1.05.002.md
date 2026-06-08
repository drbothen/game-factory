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

# BC-1.05.002: build Failure Returns OperationFailed with Diagnostics

## Description

When the engine build process runs but fails (compiler error, link error, export
failure), the adapter returns an `OperationFailed` JSON-RPC error with structured
diagnostic data. This is distinct from `EngineToolMissing` (where the build
command could not even be invoked) and from a successful `BuildResult` with
`status: "failed"`. The distinction enables the factory to correctly route build
failures: tool-missing is a runner provisioning issue; OperationFailed is a
source code issue.

**Resolution of ambiguity:** `BuildResult` with `status: "failed"` is returned
when the adapter can produce a structured result (Cargo/MSBuild/GDScript compile
errors with file/line information). `OperationFailed` error is returned when the
adapter cannot produce a structured result (e.g., the build runner crashed, the
engine process exited with a signal, or timed out without structured output).

## Preconditions

1. The `build` capability has been invoked.
2. The engine build process started but terminated abnormally (non-zero exit with
   no structured diagnostics parseable), OR the build process timed out, OR the
   build runner itself crashed.

## Postconditions

1. The adapter returns a JSON-RPC 2.0 error response with:
   - `error.code`: `-32005` (OperationFailed)
   - `error.message`: `"OperationFailed"`
   - `error.data.reason`: one of `"crash"`, `"timeout"`, `"signal"`, `"unstructured-failure"`
   - `error.data.exitCode`: integer or null (if unavailable)
   - `error.data.log`: string with available output (may be truncated to last 4096 chars)
2. No `BuildResult` is returned alongside the error.
3. The adapter remains in a healthy state and can accept subsequent requests.

## Invariants

1. `OperationFailed` is never returned for a build that produced parseable structured
   diagnostics — those use `BuildResult` with `status: "failed"`.
2. `error.data.log` is always present; it may be empty if no output was captured.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Build times out | `OperationFailed` with `reason: "timeout"` and partial log |
| EC-002 | Build process killed by OOM | `OperationFailed` with `reason: "signal"` and `exitCode: -9` (or equivalent) |
| EC-003 | Cargo exits with code 1 and emits JSON error objects | Adapter parses JSON errors into `BuildResult.diagnostics` and returns `BuildResult` with `status: "failed"` (NOT OperationFailed) |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Build process killed by SIGKILL | `{"error":{"code":-32005,"data":{"reason":"signal","exitCode":-9,"log":"...partial output..."}}}` | error |
| Build timeout exceeded | `{"error":{"code":-32005,"data":{"reason":"timeout","exitCode":null,"log":"..."}}}` | error |
| Cargo compile error with JSON diagnostic output | `BuildResult` with `status: "failed"` and populated `diagnostics` array (not OperationFailed) | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-020 | OperationFailed always includes data.reason and data.log | conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — distinguishing structured build failure from abnormal process termination allows the factory pipeline to apply different remediation strategies |
| L2 Domain Invariants | DI-001 |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.05.001 — sibling (success and structured failure case)

## Architecture Anchors

- `planning/design/protocol-schema.md#5-errors-json-rpc-error-codes`
