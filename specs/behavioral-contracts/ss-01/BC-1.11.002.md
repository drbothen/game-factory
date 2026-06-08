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

# BC-1.11.002: introspect Normalizes ECS World-Dump and Scene-Tree Formats to Common root

## Description

Bevy's introspection output (ECS world dump via BRP, or `leafwing-input-playback`
entity inspection) and Godot/Unity's introspection output (scene tree via
`print_tree_pretty`, `SceneDump.cs`) are structurally different, but both
normalize to the same `{ id, name, components, children }` recursive root.
This contract specifies the mapping rules so the factory core never branches on
`format: "ecs"` vs `format: "scene-tree"`.

## Preconditions

1. An `IntrospectResult` is being produced by an adapter.
2. The adapter's underlying engine uses either ECS or scene-tree representation.

## Postconditions

1. For ECS (Bevy):
   - Each ECS entity becomes a node with `id` = Bevy entity ID string (e.g., `"0v1"`),
     `name` = entity name or empty string if unnamed, `components` = array of
     component type/value pairs, `children` = child entities in the hierarchy.
2. For scene-tree (Godot/Unity):
   - Each scene node becomes a node with `id` = node path or unique ID,
     `name` = node name, `components` = array of attached components/scripts,
     `children` = child nodes.
3. In both cases, the factory core can traverse the `root.children` recursion
   without knowing whether it is traversing an ECS hierarchy or a scene tree.
4. Component `type` is always the engine's canonical type name (e.g.,
   `"bevy_transform::components::transform::Transform"`,
   `"UnityEngine.Transform"`); it is NOT normalized to a cross-engine name
   (that is a future Layer-2 concern).

## Invariants

1. The `id` field is unique within a snapshot regardless of engine.
2. `components` is always an array (may be empty).
3. `children` is always an array (may be empty).
4. The `format` field correctly identifies the native representation.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Unity GameObject has no attached components | `components: []` — valid |
| EC-002 | Bevy entity has no name (unnamed entities are common) | `name: ""` — empty string, not null |
| EC-003 | Component value cannot be serialized to JSON | `value: null` with a logged warning; `type` still present |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy: entity `0v1` named "Player" with Transform | `{ id:"0v1", name:"Player", components:[{type:"bevy_transform...::Transform", value:{...}}], children:[] }` | happy-path |
| Godot: root node "Main" with two child nodes "Player" and "Enemy" | `{ id:"/root/Main", name:"Main", components:[], children:[{id:"/root/Main/Player",...},{id:"/root/Main/Enemy",...}] }` | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-042 | Core traversal code handles both ecs and scene-tree without branching on format | integration test with mock adapters of each type |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — unified introspect normalization enforces DI-001 at the data structure level |
| L2 Domain Invariants | DI-001 (core never branches on engine-specific data structures) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.11.001 — depends on (this BC specifies the normalization rules for IntrospectResult)

## Architecture Anchors

- `planning/design/protocol-schema.md#38-introspectresult-normalized-sceneentity-tree`
