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
  - .factory/planning/decisions/0003-determinism-tier-capability.md
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

# BC-1.12.001: Adapter Declares determinismTier in Capability Manifest

## Description

Every Capability Manifest returned from `initialize` must include a
`determinismTier` field set to exactly one of the three declared tier values.
This field governs how the factory selects the replay comparison method for that
adapter's sessions. An undeclared or invalid tier is treated as `"tolerance-only"`.
This enforces DI-004: determinism tier is never assumed by the factory; it is
always declared by the adapter.

Research basis (Decision 0003, `planning/decisions/0003-determinism-tier-capability.md`):
- Bevy + Rapier: bitwise-cross-platform (deterministic hash across OS/CPU)
- Unity + PhysX with Enhanced Determinism: same-machine (hash only on pinned runner)
- Godot (any physics): tolerance-only (FP non-determinism, no guarantee)

## Preconditions

1. The adapter is preparing the Capability Manifest for the `initialize` response.

## Postconditions

1. The manifest includes `"determinismTier"` at the top level with one of:
   - `"bitwise-cross-platform"` (T1): adapter guarantees identical simulation
     snapshot hash across different OS/CPU combinations
   - `"same-machine"` (T2): adapter guarantees hash reproducibility only on the
     same pinned runner image
   - `"tolerance-only"` (T3): no hash-level guarantee; replay comparison uses
     a tolerance-window metric diff
2. If the adapter is uncertain about its tier (e.g., unknown engine version),
   it declares `"tolerance-only"`.
3. The `determinismTier` value cannot be changed mid-session; it is session-immutable.

## Invariants

1. `determinismTier` is always one of the three declared string values.
2. An adapter declaring `"bitwise-cross-platform"` must have passed a cross-machine
   hash-equality conformance test before being accepted.
3. The factory never upgrades an adapter's tier by assumption; only explicit
   `capability/register` can change tier (if such an extension is added in a
   future protocol version).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Adapter omits `determinismTier` field | Factory defaults to `"tolerance-only"` and logs a warning; does not reject the manifest |
| EC-002 | Adapter declares `"bitwise-cross-platform"` but has not been tested | Conformance suite verifies the claim before the adapter is accepted; invalid claim is a conformance failure |
| EC-003 | Unity adapter using Legacy Input Manager (no replay support) | `determinismTier: "same-machine"` is still valid; the tier is about physics/sim, not about replay input method |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy + Rapier adapter manifest | `"determinismTier": "bitwise-cross-platform"` | happy-path |
| Unity + PhysX adapter manifest | `"determinismTier": "same-machine"` | happy-path |
| Godot adapter manifest | `"determinismTier": "tolerance-only"` | happy-path |
| Manifest with missing determinismTier | Factory sets effective tier to `"tolerance-only"` with warning | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-043 | determinismTier is always one of the three declared enum values | schema validation |
| VP-TBD-044 | bitwise-cross-platform adapters produce identical hashes across two different CI runners | conformance test (Decision 0003) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — determinism tier declaration is part of the adapter protocol surface that enables the factory's replay-regression system to select the correct comparison method |
| L2 Domain Invariants | DI-004 (determinism tier is declared, never assumed — this BC is the primary enforcement of DI-004 at the adapter layer) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (determinismTier is in the Capability Manifest)
- BC-1.12.002 — composes with (core uses tier to select comparison method)
- BC-1.12.003 — composes with (DeterminismTierViolation enforcement)

## Architecture Anchors

- `planning/design/protocol-schema.md#4-determinism-tier-decision-0003`
- `planning/decisions/0003-determinism-tier-capability.md`
