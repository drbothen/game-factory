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
priority: P0
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

# BC-1.14.002: Core Compatibility Matrix Maps Core Version to Supported Protocol Major Versions

## Description

The factory core maintains a machine-readable compatibility matrix that declares
which protocol major versions each core version supports. Before using any adapter,
the core checks whether the adapter's declared `protocolVersion` falls within the
compatibility matrix for the running core version. This is the Terraform-borrowed
compatibility matrix pattern (protocol-schema.md §6), which prevents silent
forward/backward compatibility failures.

## Preconditions

1. The factory core has been initialized.
2. A compatibility matrix file exists at a declared path within the factory core.
3. An adapter has returned a Capability Manifest with a `protocolVersion`.

## Postconditions

1. The core reads the compatibility matrix and determines whether the adapter's
   `protocolVersion` major number is in the set of supported protocol majors for
   the current core version.
2. If compatible: the core proceeds with the session.
3. If incompatible: the core refuses to use the adapter and emits a
   `ProtocolVersionMismatch`-equivalent diagnostic; it does NOT send an
   `initialized` notification.
4. The compatibility matrix is a static artifact versioned with the core; it is
   not dynamically computed.

## Invariants

1. The compatibility matrix always declares at least one supported protocol major.
2. The compatibility matrix is version-controlled alongside the factory core; it
   changes only with core releases.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Compatibility matrix file is missing | Core fails with a configuration error at startup; it does not attempt to connect to adapters |
| EC-002 | Adapter declares protocol `"1.1"` and core supports `["1"]` (major only) | Semver major match: compatible; minor versions within a major are backward-compatible |
| EC-003 | New core version drops support for protocol `"1.0"` | Matrix entry for the old core version still maps to `["1"]`; new core version lists `["2"]`; old adapters get ProtocolVersionMismatch |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Core v0.2.0 supports protocol majors `[1]`; adapter declares `protocolVersion: "1.0"` | Compatible; session proceeds | happy-path |
| Core v1.0.0 supports protocol majors `[2]`; adapter declares `protocolVersion: "1.0"` | Incompatible; core refuses adapter with diagnostic | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-052 | Compatibility matrix file exists and is parseable on core startup | startup check in conformance suite |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the core compatibility matrix is the Terraform-borrowed anti-drift mechanism for protocol evolution |
| L2 Domain Invariants | DI-002 (adapters must pass conformance — the compatibility matrix is part of the conformance gate) |
| Architecture Module | Factory Core (Layer 2) (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.002 — depends on (ProtocolVersionMismatch is triggered here)
- BC-1.14.001 — sibling (engine version pinning)

## Architecture Anchors

- `planning/design/protocol-schema.md#6-versioning--compatibility`
