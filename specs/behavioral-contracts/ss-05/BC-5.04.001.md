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
  - .factory/planning/research/aaa/narrative-worldbuilding-lore.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-005
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

# BC-5.04.001: Narrative Graph Is Reachable, Dead-End-Free, and Canon-Grounded

## Description

The narrative-designer and writer agents produce a `narrative-graph` artifact encoding the
game's branching dialogue and quest structure as a directed graph. The factory validates
this graph for: (1) reachability — every non-start node is reachable from start, (2)
dead-end freedom — every leaf node is classified as an intentional end node (not an
unintended dead-end), (3) variable consistency — all referenced variables are declared in
the `variables` field, and (4) canon grounding — all entity references in node content
resolve to valid `CanonKBEntry` IDs. These are CI gates run on every merge. This BC
defines only the machine-checkable structural properties; quality of writing is a playtest
gate (CAP-008).

## Preconditions

1. A `narrative-graph` artifact exists with `nodes`, `edges`, `variables`, and
   `export_targets` fields populated.
2. The Canon-KB (BC-5.04.002) exists and is accessible to the graph validator.
3. The `narrative-graph` schema is registered in the schema registry.
4. At least one node has `type: "start"` and at least one node has `type: "end"`.
5. `reachability_check_required: true` and `dead_end_check_required: true` are set
   (default true; may be explicitly overridden to false only for test/stub graphs
   marked `status: "stub"`).

## Postconditions

1. **Reachability check**: a BFS/DFS from the start node classifies all nodes as
   reachable or unreachable. Any node with zero incoming edges that is NOT the start
   node is flagged as unreachable → E-NAR-002 raised per unreachable node.
2. **Dead-end check**: any node with zero outgoing edges that is NOT declared `type: "end"`
   is flagged as an unintended dead-end → E-NAR-001 raised per dead-end node.
3. **Variable consistency check**: every variable referenced in a `condition` or `content_ref`
   field is present in the `variables` array. Undeclared variable → E-NAR-003 variant raised.
4. **Canon grounding check**: every `canon_entity_refs[]` entry in every node resolves to
   an existing `CanonKBEntry.id` in the current Canon-KB. Dangling reference → E-NAR-003
   raised per dangling ref.
5. A `narrative-graph-validation-report` is emitted with: reachability pass/fail, dead-end
   pass/fail, canon grounding pass/fail, counts of errors per category.
6. If all four checks pass: graph is accepted; export targets (Ink/Yarn/Articy) may be
   generated from the graph.
7. If any check fails: graph is rejected; export targets are NOT generated; errors must
   be resolved before graph is accepted.

## Invariants

1. (DI-008) The narrative graph uses engine-neutral node types only (start, dialogue, choice,
   event, end). No engine-specific sequencing construct (Unreal Blueprint node, Unity
   Playable Asset, Godot AnimationPlayer signal) may appear as a node type.
2. Every node that is a leaf (no outgoing edges) MUST be declared `type: "end"`. This is
   the machine-enforced definition of "intended end"; the designer must explicitly mark ends.
3. Canon grounding is a hard gate. A narrative that references non-existent entities
   undermines worldbuilding consistency (Canon-KB is the single source of truth per DI-008
   analog for narrative).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Graph has only one node (start = end) | Reachability: trivially passes. Dead-end: the start node has no outgoing edges; must be declared `type: "end"` for it to pass dead-end check. If not declared end → E-NAR-001 |
| EC-002 | Choice node with 10 branches, 2 of which are dead-ends | E-NAR-001 for each dead-end branch node; graph rejected |
| EC-003 | Node references CanonKBEntry.id that existed at graph creation but was deleted from Canon-KB by a lore revision | E-NAR-003: dangling entity ref; Canon-KB deletion workflow must update all referencing graphs |
| EC-004 | `reachability_check_required: false` on a stub graph | No reachability or dead-end checks run; only schema validation and variable consistency run; stub graphs not eligible for export target generation |
| EC-005 | Two start nodes | Schema validation rejects: exactly one start node required |
| EC-006 | Cycle in dialogue graph (player can loop infinitely) | Reachability: all nodes in cycle are reachable; dead-end: no dead-ends in cycle. Cycle itself is valid (infinite loops are intentional in some dialogue structures); cycles are not flagged |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Linear graph: start → dialogue → choice → [end-A, end-B], all entity refs in Canon-KB, all variables declared | Validation report: all pass; graph accepted; Ink export generated | happy-path |
| Same graph but one choice branch has no outgoing edge and `type: "dialogue"` (not "end") | E-NAR-001: node '<id>' dead-end (not declared end); graph rejected | error |
| Dialogue node references `entity_id: "faction_001"` not in Canon-KB | E-NAR-003: dangling entity ref faction_001; graph rejected | error |
| Start node with no outgoing edges, declared `type: "end"` | Validation passes (trivially complete graph) | edge-case |
| Node references variable `$player_level` not in `variables` array | E-NAR-003 variant: undeclared variable $player_level | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.04.001 | For all graphs, every non-start node with zero incoming edges is classified unreachable | proptest: generate graphs with random node counts; inject isolated nodes; assert E-NAR-002 |
| VP-5.04.002 | For all graphs, every leaf node classified as dead-end iff not declared type=end | proptest: generate graphs; vary end declarations |
| VP-5.04.003 | For all graphs, all canon_entity_refs resolve iff entity exists in Canon-KB at check time | proptest: vary Canon-KB contents |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the narrative-graph is named as a primary artifact in RECONCILIATION §5.6 and §6.1 as owned by the narrative-designer agent; this BC defines its machine-checkable structural validation contract. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer) |
| Architecture Module | SS-TBD — narrative graph validator; Canon-KB query interface |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.04.002 — depends on (Canon-KB must be valid for canon grounding check)
- BC-5.07.002 — depends on (cross-discipline dependency contract checks narrative graph acceptance)

## Architecture Anchors

- `architecture/SS-TBD-narrative-pipeline.md` — narrative graph validator, graph export

## Story Anchor

S-TBD — Narrative Graph Structural Validation

## VP Anchors

- VP-5.04.001 — reachability unreachable-node detection
- VP-5.04.002 — dead-end classification
- VP-5.04.003 — canon-grounding check
