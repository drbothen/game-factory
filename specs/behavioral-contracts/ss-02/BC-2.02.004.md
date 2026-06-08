---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-002
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

# BC-2.02.004: Conformance Suite Versioning and Core-Adapter Compatibility Matrix

## Description

The conformance suite carries an explicit version number, and the factory core maintains a
published compatibility matrix mapping each conformance suite version to the adapter protocol
versions it validates. An adapter may only be accepted using a conformance suite version that
is compatible with both its declared protocol version and the factory core's current protocol
version. This implements the Terraform-style versioning pattern from ADR-0002, ensuring
acceptance tests exercise the real protocol contract rather than a stale snapshot of it.

## Preconditions

1. A compatibility matrix exists and is accessible to the conformance runner and to the
   adapter registry. The matrix maps `(core_protocol_version, adapter_protocol_version)` →
   `conformance_suite_version_range [min, max]`.
2. The adapter under test declares a `protocol_version` in its manifest.
3. The factory core knows its own `core_protocol_version`.
4. The conformance runner knows its own `conformance_suite_version`.

## Postconditions

1. Before executing any tests, the conformance runner checks that its
   `conformance_suite_version` falls within the `[min, max]` range from the compatibility
   matrix for the given `(core_protocol_version, adapter_protocol_version)` pair.

2. If the version check passes: conformance proceeds normally. The accepted record stores
   the `conformance_suite_version` used.

3. If `conformance_suite_version < matrix_min` (suite is too old):
   - Conformance aborted with error `SUITE_TOO_OLD`.
   - Adapter not accepted.

4. If `conformance_suite_version > matrix_max` (suite is ahead of the protocol):
   - Conformance aborted with error `SUITE_TOO_NEW`.
   - Adapter not accepted.

5. If the `(core_protocol_version, adapter_protocol_version)` pair does not appear in the
   compatibility matrix:
   - Conformance aborted with error `INCOMPATIBLE_PROTOCOL_VERSIONS`.
   - The specific versions are logged; the pair must be added to the matrix by a protocol
     maintainer.

6. The accepted record always includes the exact `core_protocol_version`,
   `adapter_protocol_version`, and `conformance_suite_version` used at acceptance time.

## Invariants

1. **Version-locked acceptance:** An adapter accepted at (core-v1, adapter-v1, suite-v3) is
   only valid when the factory core is at core-v1 and the adapter presents adapter-v1.
   Protocol version upgrades require re-acceptance.
2. **Matrix is append-only:** New (core, adapter, suite) tuples are added to the
   compatibility matrix; existing entries are never removed (to allow historical audit).
   Superseded versions are marked `deprecated` in the matrix but remain readable.
3. **No implicit latest:** The conformance runner never assumes "latest suite = correct."
   It always validates against the explicit matrix entry.
4. **Two-adapter validation:** The matrix must have been validated against two maximally
   dissimilar adapters (per ADR-0001 Two-Adapter Rule) before a new protocol version entry
   is published. A matrix entry validated against only one adapter is marked
   `single_adapter_validated: true` and may not block production use but emits a warning.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter declares `protocol_version: "1.0"` but factory core is at `"1.1"` with no matrix entry for this pair | `INCOMPATIBLE_PROTOCOL_VERSIONS`; adapter must update to `"1.1"` or the matrix must add a backward-compat entry. |
| EC-002 | Conformance suite is one minor version ahead of matrix_max | `SUITE_TOO_NEW`; abort. The protocol team must update the matrix to include the new suite version. |
| EC-003 | Matrix entry exists but is marked `deprecated` | Conformance proceeds (backward compat preserved); warning emitted in report: `deprecated_compatibility_entry`. |
| EC-004 | Adapter and core are both at the same version; matrix entry exists; tests all pass | Normal acceptance path. No edge-case behavior. |
| EC-005 | Adapter was accepted with suite-v3; factory core upgrades to core-v2 which requires suite-v4+ | Existing accepted record is no longer valid for core-v2; re-run required. Factory detects version mismatch at dispatch time (not at acceptance time). |
| EC-006 | Multiple adapters for different engines on the same protocol version | Each adapter runs against the same suite version (same matrix entry). Separate accepted records. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| core-v1, adapter-v1, suite-v3 — matrix says [v2, v4] for (core-v1, adapter-v1) | Conformance proceeds normally. | happy-path |
| core-v1, adapter-v1, suite-v1 — matrix says [v2, v4] | `SUITE_TOO_OLD`; abort; not accepted. | error |
| core-v1, adapter-v1, suite-v5 — matrix says [v2, v4] | `SUITE_TOO_NEW`; abort; not accepted. | error |
| core-v1, adapter-v2 — pair not in matrix | `INCOMPATIBLE_PROTOCOL_VERSIONS`; abort; not accepted. | error |
| Matrix entry deprecated; suite in range | Accepted with warning `deprecated_compatibility_entry`. | edge-case |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-011 | No adapter is accepted when its protocol version is not in the compatibility matrix. | proptest / integration test |
| VP-TBD-012 | No adapter is accepted when suite version is outside the matrix range for its protocol pair. | proptest |
| VP-TBD-013 | Accepted record always contains all three version fields. | schema validation |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC specifies the versioning/acceptance pattern from ADR-0002 (Terraform-style), which is the "versioning/acceptance" aspect of the conformance gating capability. |
| L2 Domain Invariants | DI-001 (Factory Core Never Names a Specific Engine), DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance) |
| Architecture Module | SS-TBD (Conformance Suite, Protocol Version Registry — filled by architect) |
| Stories | (filled by story-writer) |
| ADRs | ADR-0002 §Decision point 2 (Versioning + acceptance testing — Terraform-style) |

## Related BCs

- BC-2.02.001 — depends on (test selection happens only after version check passes)
- BC-2.02.002 — depends on (acceptance gate runs only after version check passes)
- BC-2.02.005 — related to (scheduled re-run triggered by engine release may hit version boundary)

## Architecture Anchors

- `architecture/SS-TBD-conformance-suite.md` — Compatibility matrix schema, version validation

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-011 — incompatible-protocol-version rejection
- VP-TBD-012 — out-of-range suite version rejection
