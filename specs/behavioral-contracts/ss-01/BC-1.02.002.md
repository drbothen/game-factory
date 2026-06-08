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

# BC-1.02.002: Protocol Version Incompatibility Returns ProtocolVersionMismatch Error

## Description

If the core sends an `initialize` request with a `protocolVersion` that falls
outside the range supported by the adapter, the adapter must immediately return a
structured `ProtocolVersionMismatch` error containing the adapter's supported
version range. The core must not proceed with capability calls after receiving this
error.

## Preconditions

1. An `initialize` request has been sent by the core.
2. The `protocolVersion` field in the request params is a semver string.
3. The adapter has a declared supported protocol version range (e.g., `["1.0"]` or
   `["1.0", "1.1"]`).
4. The requested `protocolVersion` does not fall within the adapter's supported range.

## Postconditions

1. The adapter returns a JSON-RPC 2.0 error response with:
   - `error.code`: `-32000` (ProtocolVersionMismatch)
   - `error.message`: `"ProtocolVersionMismatch"`
   - `error.data.supported`: array of semver strings the adapter supports
   - `error.data.requested`: the `protocolVersion` string from the request
2. The adapter does NOT send an `initialized`-equivalent signal or any capability
   manifest.
3. The adapter remains in an uninitialized state; it may accept a corrected
   `initialize` request or wait for `exit`.
4. The core, upon receiving this error, logs the incompatibility and does NOT
   proceed with capability calls against this adapter in this session.

## Invariants

1. The `error.data.supported` array always contains at least one version string.
2. The adapter never returns a partial manifest alongside a ProtocolVersionMismatch
   error.
3. The core never calls capability methods after receiving ProtocolVersionMismatch.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Core requests protocol `"2.0"` but adapter only supports `"1.0"` | Error returned with `data.supported: ["1.0"]`, `data.requested: "2.0"` |
| EC-002 | Core requests protocol `"1.1"` and adapter supports `["1.0","1.1"]` | `initialize` succeeds normally — version is compatible |
| EC-003 | `protocolVersion` field is missing from `initialize` params | Adapter treats as incompatible (or interprets as `"0.0"`) and returns ProtocolVersionMismatch with `data.requested: null` |
| EC-004 | `protocolVersion` is not a valid semver string | Adapter returns `InvalidRequest` (`-32600`) rather than ProtocolVersionMismatch |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `initialize` with `protocolVersion: "99.0"` against adapter supporting `["1.0"]` | `{"error":{"code":-32000,"message":"ProtocolVersionMismatch","data":{"supported":["1.0"],"requested":"99.0"}}}` | error |
| `initialize` with `protocolVersion: "1.0"` against adapter supporting `["1.0"]` | Manifest returned successfully | happy-path |
| `initialize` with `protocolVersion: "1.1"` against adapter supporting `["1.0","1.1"]` | Manifest returned successfully | happy-path |
| `initialize` with missing `protocolVersion` field | ProtocolVersionMismatch with `data.requested: null` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-006 | ProtocolVersionMismatch always includes non-empty supported array | conformance test: send mismatched version, assert error structure |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — protocol version gating is required for the adapter pattern to remain stable as protocol versions evolve (Terraform-style compatibility matrix) |
| L2 Domain Invariants | DI-001 (core never couples to engine — version mismatch is caught before any engine-specific exchange); DI-002 (conformance cannot pass if versions are incompatible) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — sibling (the success case of initialize)
- BC-1.14.001 — composes with (adapter pins one engineVersion; protocol versioning is separate)
- BC-1.14.002 — composes with (compatibility matrix specifies which core versions accept which protocol majors)

## Architecture Anchors

- `planning/design/protocol-schema.md#5-errors-json-rpc-error-codes`
- `planning/design/protocol-schema.md#6-versioning--compatibility`

## Story Anchor

S-TBD — Protocol version handshake error handling
