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
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/game-design-discipline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.01.001: Design Artifact Stack Produces Valid, Engine-Neutral Spec Bundle

## Description

The systems-designer, economy-designer, level-designer, and related design agents produce
a validated, engine-neutral design artifact bundle (design-spec + systems-spec + balance-data
+ economy-graph + progression-spec + content-data + level-specs + ui-spec + accessibility-
contract + design-intent-contracts). Every sub-artifact must pass its schema validator. No
artifact in the bundle may contain engine-specific implementation constructs. The bundle is
the authoritative input for downstream disciplines (art, audio, narrative, engineering,
cinematics) and is consumed through the cross-discipline dependency contract.

## Preconditions

1. A valid `GameSpec` entity exists with `genre_profile`, `game_id`, and at minimum one
   entry in `target_engines[]`.
2. The factory has resolved the genre profile to a design agent cluster configuration.
3. A `design-spec` schema (v1.0 or later) is registered in the schema registry.
4. All sub-artifact schemas (systems-spec, economy-graph, level-spec, etc.) are registered.
5. No prior design artifact bundle exists for this game, OR an explicit revision workflow
   has been initiated (mutations go through the revision process, not silent overwrite).

## Postconditions

1. A `design-spec` document exists at the designated output path with all required
   sub-artifact refs populated.
2. Every sub-artifact referenced in the `design-spec` passes JSON Schema validation against
   its registered schema version. Schema validator exits 0.
3. The `engine_neutral: true` field is set on the `design-spec` and all sub-artifacts.
4. A lint check for engine-specific terms runs across all artifacts and reports zero
   violations. Checked terms include at minimum: `MonoBehaviour`, `ECS`, `GameObject`,
   `prefab`, `ScriptableObject`, `DataAsset`, `Blueprint`, `UObject`, `Node` (when used
   as engine-specific class reference), Bevy `Component`/`System` type names.
5. A `design-artifact-validation-report` is emitted with per-artifact pass/fail status,
   schema version used, and timestamp.
6. If any sub-artifact fails schema validation, the bundle is NOT emitted; an E-DES-001
   error is raised for each failing artifact.
7. If any engine-specific term is detected, E-DES-002 is raised; the bundle is NOT emitted
   until the violation is resolved.

## Invariants

1. (DI-008) No engine-specific construct appears in any design artifact at any point during
   generation or validation. The invariant is checked by lint before emit, not just at review.
2. The `design-spec` always references every required sub-artifact type. A bundle missing
   any required artifact type is structurally invalid.
3. Schema version pinning: each sub-artifact carries `schema_version` in its root; this
   version must match the registered schema in the factory schema registry. Schema drift
   between artifact version and registry version is a broken defect.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Sub-artifact schema version in artifact does not match registry version | E-DES-001 raised; validation blocked; schema migration must be run first |
| EC-002 | Genre profile requires a level-spec but level-designer agent times out | Bundle is not emitted; blocked artifact list surfaced; producer notified via milestone gate |
| EC-003 | Design-intent-contract references a simulation BC that does not yet exist | E-DES-001 raised on the design-intent-contract; ref is flagged as TBD; bundle marked "incomplete — pending BC" |
| EC-004 | Engine-specific term appears in `intent_prose` field (prose, not schema-bound data) | Warning issued (not a block); prose fields are not subject to engine-neutral lint; DI-008 scoped to typed schema fields |
| EC-005 | Revision of existing bundle: new economy-graph version fails balance-band check | E-DES-003 raised; prior bundle version retained; new version rejected until balance-band fixed |
| EC-006 | accessibility-contract field omitted (agent error) | E-DES-001 raised with field=`accessibility_contract_ref`; bundle blocked |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Valid `GameSpec` for roguelike with all sub-artifacts well-formed, no engine terms | `design-artifact-validation-report` with all pass, `engine_neutral: true`, exit 0 | happy-path |
| `systems-spec` missing `state_machines` array | E-DES-001 on systems-spec at `state_machines`; bundle not emitted | error |
| `economy-graph` with `MonoBehaviour` in a node label | E-DES-002 with field=`nodes[2].label`; bundle not emitted | error |
| Empty `level_specs` array when genre_profile = "roguelike" | E-DES-001 on design-spec at `level_specs`; bundle not emitted | edge-case |
| Valid bundle with `intent_prose` containing "Bevy ECS" | Warning issued (not block); bundle emitted; report flags prose warning | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.01.001 | For all valid GameSpec inputs, if all sub-artifacts are schema-valid and engine-neutral, the bundle is emitted exactly once | proptest (property-based testing over generated GameSpec instances) |
| VP-5.01.002 | For all bundles, `engine_neutral: true` iff lint reports zero violations | proptest |
| VP-5.01.003 | Schema validator never produces false negatives (valid artifact accepted when invalid) | schema test corpus: 100 invalid variants each artifact type, 100 valid variants |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — this BC defines the machine-checkable production contract for the core design discipline artifact stack, which is the primary artifact output of CAP-005's "generates EVERYTHING a game needs — design... artifacts" mandate. |
| L2 Domain Invariants | DI-008 (Factory Core Spec Layer Is Engine-Portable by Construction) |
| Architecture Module | SS-04 — game design artifact generator; design-spec schema registry |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.01.002 — composes with (economy-graph is a sub-artifact of the design bundle)
- BC-5.01.003 — composes with (accessibility-contract is a sub-artifact of the design bundle)
- BC-5.07.001 — depends on (cross-discipline dependency contract consumes this bundle)

## Architecture Anchors

- `architecture/SS-04-game-design.md` — design agent cluster, schema registry
- `architecture/SS-04-design-intent-contracts.md` — design-intent-contract specification

## Story Anchor

S-TBD — Design Artifact Stack Generation

## VP Anchors

- VP-5.01.001 — bundle-emission invariant (proptest)
- VP-5.01.002 — engine-neutral iff lint-clean (proptest)
- VP-5.01.003 — schema validator false-negative rate (test corpus)
