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

# BC-1.14.001: Adapter Pins Exactly One engineVersion in the Capability Manifest

## Description

Every Capability Manifest must include an `engineVersion` field set to exactly
one pinned version string (semver or engine-specific build tag). Adapters do NOT
declare a version range; they declare the exact version they were built against.
This is the "Semport" principle (protocol-schema.md §6): each engine minor release
is a scheduled adapter maintenance event. Pinning prevents the adapter from silently
serving a different engine version than it was tested against.

This constraint is especially critical for Bevy (pre-1.0, ~quarterly breaking
changes) and Unity (per-CI-agent licensing tied to specific versions).

## Preconditions

1. The adapter is preparing the Capability Manifest.
2. The adapter has been built against a specific engine version.

## Postconditions

1. The manifest's `engineVersion` field is a non-empty string representing the exact
   pinned engine version (e.g., `"0.18.1"` for Bevy, `"6000.1.12f1"` for Unity,
   `"4.3.3"` for Godot).
2. The version string is not a range, a glob, or a floating reference like `"latest"`.
3. The manifest's `adapterVersion` field is a semver string for the adapter itself.

## Invariants

1. `engineVersion` is session-immutable; it cannot change after `initialize`.
2. The adapter will not run against a different engine version than the one declared.
3. If the engine binary version does not match `engineVersion`, the adapter returns
   `EngineToolMissing` (`-32003`) or `OperationFailed` before any capability calls succeed.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter detects engine binary version does not match declared `engineVersion` | Adapter returns `EngineToolMissing` or `OperationFailed` with a mismatch message; it does not silently continue with the wrong version |
| EC-002 | `engineVersion` field is an empty string | Conformance suite rejects the manifest; this is a schema violation |
| EC-003 | Bevy minor release changes BRP API | Adapter author updates `engineVersion` and re-runs conformance; this is the Semport maintenance event |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy 0.18.1 adapter | `"engineVersion": "0.18.1"` in manifest | happy-path |
| Unity 6000.1.12f1 adapter | `"engineVersion": "6000.1.12f1"` in manifest | happy-path |
| Adapter with `"engineVersion": "latest"` | Conformance suite fails: version must be pinned | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-051 | engineVersion is non-empty and not a floating reference | schema validation + conformance test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — pinned engine versions are the Semport mechanism that prevents silent adapter drift after engine releases |
| L2 Domain Invariants | DI-001; DI-002 (conformance is version-specific; a drifted adapter fails conformance) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (engineVersion is in the Capability Manifest)
- BC-1.14.002 — sibling (core compatibility matrix)

## Architecture Anchors

- `planning/design/protocol-schema.md#6-versioning--compatibility`
- `planning/design/engine-adapter-protocol.md#engine-specific-operational-notes`
