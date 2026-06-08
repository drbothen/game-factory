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

# BC-1.11.001: introspect Returns Normalized IntrospectResult with Root Entity Tree

## Description

When the `introspect` capability is invoked, the adapter queries the running game's
internal state (scene graph, entity-component world, or scene tree) and returns a
normalized `IntrospectResult` with a recursive entity tree rooted at a common `root`
node. Both ECS world dumps (Bevy via BRP) and scene-tree formats (Godot/Unity) are
normalized to this common representation, allowing the factory core to reason about
game state without engine-specific knowledge.

## Preconditions

1. The adapter's `introspect` capability has `fidelity: "full"` or `"partial"`.
2. A game process is running (either via `runHeadless` or is running as part of a
   replay/test session).
3. The `introspect` request params may include:
   - `query`: optional path or filter expression to narrow the result
   - `maxDepth`: optional integer limiting recursion depth (default: unlimited)

## Postconditions

1. The adapter returns an `IntrospectResult` object with:
   - `format`: `"ecs"` (Bevy) or `"scene-tree"` (Godot/Unity)
   - `root`: a recursive entity node with:
     - `id`: string (unique entity/node identifier in this snapshot)
     - `name`: string (entity/node name, empty string if not named)
     - `components`: array of `{ type: string, value: object }` entries
     - `children`: array of recursive entity nodes (empty array if leaf)
   - `source`: string (the introspection method used, e.g., `"brp-jsonrpc"`,
     `"scene-dump"`)
2. The `root` node is always present, even if the world is empty (in which case
   `root.children` is `[]`).

## Invariants

1. `format` is always one of `"ecs"` or `"scene-tree"`; both map to the same
   `root`-based recursive structure.
2. `id` values within a single snapshot are unique.
3. The `IntrospectResult` is a point-in-time snapshot; it does not observe future
   state changes.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game world is empty (no entities/nodes) | `IntrospectResult` with `root` having empty `children: []` and `components: []` |
| EC-002 | `maxDepth: 1` specified | Only the root and its immediate children are included; deeper nodes are omitted |
| EC-003 | Entity has a component value that is not JSON-serializable | Adapter uses `{ "type": "...", "value": null }` and logs a warning; it does NOT error |
| EC-004 | Bevy BRP not running (game started without BRP feature) | `CapabilityUnsupported` or `OperationFailed` depending on whether this was detectable at initialization |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter, 1 Player entity with Transform | `{ format: "ecs", root: {id:"0v1", name:"Player", components:[{type:"Transform", value:{x:0,y:1,z:0}}], children:[]}, source:"brp-jsonrpc" }` | happy-path |
| Godot adapter, scene tree with 3 nodes | `{ format: "scene-tree", root: {id:"root", name:"Main", components:[], children:[...3 nodes...]}, source:"scene-dump" }` | happy-path |
| Empty ECS world | `{ format: "ecs", root: {id:"world", name:"", components:[], children:[]}, source:"brp-jsonrpc" }` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-040 | root is always present in IntrospectResult | schema validation |
| VP-TBD-041 | id values within a snapshot are unique | conformance test: check for duplicate ids |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — normalized game state introspection enables the factory to verify simulation state and implement scenario-driving without engine-specific code |
| L2 Domain Invariants | DI-001 (ECS world and scene tree are normalized to a common structure; core never distinguishes ECS vs scene-tree) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.11.002 — sibling (normalization of ECS vs scene-tree formats)

## Architecture Anchors

- `planning/design/protocol-schema.md#38-introspectresult-normalized-sceneentity-tree`
- `planning/design/engine-adapter-protocol.md#capability-matrix-research-confirmed-2026-06-07`
