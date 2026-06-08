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
  - .factory/planning/design/architecture.md
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

# BC-1.15.001: Factory Core Source Artifacts Contain No Engine SDK Imports or Engine Name References

## Description

The factory core source code (Layers 1-2: dispatcher, hook SDK, pipeline planner,
wave scheduler, convergence tracker, orchestration workflows) must not import
any engine-specific SDK, reference any engine by name in code or configuration,
or contain logic that branches on engine identity. All engine knowledge is
quarantined in Layer-4 adapter implementations. This is the structural enforcement
of DI-001.

This is a code-level contract (verified by static analysis), not a runtime
behavioral contract. It is expressed as a BC because violation is observable and
machine-checkable via tooling (grep over source, dependency manifest analysis).

## Preconditions

1. A factory core release artifact (source tree or compiled binary manifest) is
   available for inspection.
2. The factory core version has a defined boundary (Layers 1-2 source paths).

## Postconditions

1. No source file in the factory core's Layer 1-2 paths contains:
   - An `import`, `use`, `require`, or `#include` of any of the following:
     `bevy`, `unity`, `godot`, `unreal`, `rapier`, `physx`, `jolt`,
     `cargo_nextest`, `gut`, `libtest`, `nunit`
   - A string literal matching any engine name: `"bevy"`, `"unity"`, `"godot"`,
     `"unreal"` (case-insensitive) in a non-comment, non-documentation context
   - A conditional branch that dispatches on engine name:
     `if engine == "bevy"`, `match engine_id`, `switch(engineName)`, etc.
2. The factory core's dependency manifests (`Cargo.toml`, `package.json`,
   `pyproject.toml`) do not list any engine SDK as a dependency.
3. A CI-enforced grep/lint check runs on every commit to the factory core and
   fails if any violation is introduced.

## Invariants

1. Engine name strings may only appear in Layer-4 adapter source files, adapter
   manifests (`.yaml`), and documentation.
2. The core may reference the abstract protocol concepts (`"engine"`, `"adapter"`,
   `"capability"`, `"fidelity"`) but never concrete engine identifiers.
3. The `engineHint` field in the `initialize` request is the only place where a
   human-supplied engine name string crosses into core code; it is treated as an
   opaque advisory string, never used to branch logic.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Capability Manifest parser contains `"bevy"` in a documentation comment | Comment content is excluded from the prohibition; only executable code and non-doc string literals are checked |
| EC-002 | An error message in core says `"Bevy adapter returned unexpected result"` | This is a violation — error messages may say "adapter" not "Bevy adapter"; the engine name must not appear |
| EC-003 | `initialize` params are logged with `engineHint: "bevy"` | Logging the opaque advisory hint is acceptable; branching on it is not |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `grep -rE "(bevy|unity|godot|unreal)" .factory/core/ --include="*.rs" --include="*.ts"` | Zero matches in non-documentation, non-adapter files | happy-path |
| `grep -rE "use bevy" .factory/core/` | Zero matches | happy-path |
| New core PR that adds `if adapter.engine == "bevy"` to pipeline planner | CI lint check fails | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-053 | Zero engine SDK imports in Layer 1-2 source | static analysis: grep over source tree in CI |
| VP-TBD-054 | Zero engine name string literals in Layer 1-2 executable code | static analysis: pattern match with exclusion of doc/comment contexts |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the factory's engine-agnostic thesis is only verifiable if the core source contains no engine-specific coupling; this BC provides the machine-checkable enforcement |
| L2 Domain Invariants | DI-001 (factory core never names a specific engine — THIS BC IS THE PRIMARY ENFORCEMENT OF DI-001); DI-008 (spec layer is engine-portable — the same principle applied to source code) |
| Architecture Module | Factory Core (Layers 1-2) (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (engine identity is declared by adapter, not assumed by core)

## Architecture Anchors

- `planning/design/architecture.md` — the Layer 1-2 / Layer 3-4 split
- `planning/design/engine-adapter-protocol.md` — "the anti-lock-in seam"
- `planning/decisions/0001-founding-engine-pair.md` — rationale for the two-adapter rule
- `planning/decisions/0002-protocol-and-conformance-stance.md`
