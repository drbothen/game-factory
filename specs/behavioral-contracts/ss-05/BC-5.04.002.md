---
document_type: behavioral-contract
level: L3
version: "1.3"
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
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified:
  - date: 2026-06-13
    version: "1.3"
    author: product-owner
    reason: "F59-01 OBS-20-B reciprocal reconciliation — clarified that CAP-012/SS-10 owns the authoritative Canon-KB store (entity registry, edge graph, timeline); this BC (CAP-005/SS-04) is the read/validation/integrity-check consumer view. Updated Invariant 2, Architecture Module, and Related BCs accordingly."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.04.002: Canon-KB Maintains Structural Integrity (Entity Ref + Timeline Consistency)

> **Canon-KB authority (OBS-20-B reciprocal):** The authoritative Canon-KB store — entity registry, edge graph, and timeline — is owned by CAP-012 / SS-10 (BC-12.12.002 entities, BC-12.12.003 edges, BC-12.12.004 timeline). This BC (CAP-005 / SS-04) is the narrative-grounding consumer / integrity-check view: it validates consistency of existing Canon-KB data but does not own or manage entity/timeline mutations.

## Description

The worldbuilder and loremaster agents maintain the Canon Knowledge-Base (Canon-KB), which
consists of an entity-registry, relationship-graph, timeline, naming-registry, and canon-
facts. The Canon-KB is the single source of truth for all narrative grounding. This BC
defines the machine-checkable structural properties: no dangling entity references in the
relationship graph, timeline events are temporally consistent (no logical paradoxes), and
all naming-registry entries follow the declared naming conventions. These are CI gates.
Creative quality (worldbuilding depth, prose quality) is a human gate via playtest.

## Preconditions

1. A Canon-KB exists as a structured artifact with the following components:
   - `entity_registry`: array of `{id, type, name, attributes}`
   - `relationship_graph`: array of `{subject_id, predicate, object_id}`
   - `timeline`: array of `{event_id, timestamp, event_description, entity_refs[]}`
   - `naming_registry`: array of `{registry_id, pattern, description, examples[]}`
   - `canon_facts`: array of `{fact_id, statement, entity_refs[], source_artifact_refs[]}`
2. The Canon-KB schema is registered in the schema registry.
3. At least one entity exists in the `entity_registry` (empty registry is valid only for
   a game with `genre_profile: "no-narrative"`).

## Postconditions

1. **Entity reference integrity check**: for every `subject_id` and `object_id` in
   `relationship_graph`, a matching entry exists in `entity_registry`. Dangling ref →
   E-NAR-003 raised per missing entity.
2. **Timeline entity ref check**: for every `entity_refs[]` entry in every `timeline`
   event, the referenced entity_id exists in `entity_registry`. Dangling ref → E-NAR-003.
3. **Timeline consistency check**: for all pairs of timeline events (A, B) where A and B
   share at least one entity_ref, and the relationship between them is declared as
   "before" or "after": timestamp(A) < timestamp(B) for "before". Violation → E-NAR-004.
   NOTE: timestamp may be relative (e.g., "era_1", "era_2") if the `timeline.timestamp_type`
   declares `"ordinal"`. In ordinal mode, consistency is checked as a topological sort of
   the partial order, not numeric comparison.
4. **Naming convention check**: every entity name in `entity_registry` is tested against
   the relevant `naming_registry` pattern (determined by entity type). Pattern is a regex
   or string template. Violation → warning (not block) unless the naming_registry entry
   has `enforce: true`, in which case it is a block.
5. **Canon fact entity ref check**: for every `entity_refs[]` entry in `canon_facts`,
   the entity_id exists in `entity_registry`. Dangling ref → E-NAR-003.
6. A `canon-kb-integrity-report` is emitted with: entity count, relationship count,
   timeline event count, naming violations (per entity), and all errors.
7. If any E-NAR-003 or E-NAR-004 errors: Canon-KB is rejected; all downstream artifacts
   that perform canon grounding checks (BC-5.04.001) are blocked until the KB is fixed.
8. Naming warnings (non-enforced): KB is accepted; warnings recorded in report.

## Invariants

1. Entity IDs are globally unique within the Canon-KB. Duplicate `entry_id` values in
   `entity_registry` are a schema validation error.
2. Every entity referenced for narrative grounding MUST already exist in the CAP-012-owned
   Canon-KB entity registry (BC-12.12.002). This BC rejects references to undefined entity
   IDs (raises E-NAR-003) but does not itself create, assign, or manage entity IDs — that
   authority belongs exclusively to CAP-012 / SS-10.
3. Timeline events are never deleted; they are marked `status: "retconned"` with
   `replaced_by_event_id` if superseded (append-only ID protection per VSDD policy).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Relationship graph edge references an entity that was deleted from registry | E-NAR-003: dangling relationship ref; loremaster must remove or update the relationship |
| EC-002 | Timeline uses ordinal timestamps; topological sort has a cycle (event A "before" B and B "before" A) | E-NAR-004: timeline cycle detected between event A and event B |
| EC-003 | Canon-KB has zero entities (empty game with no narrative, genre=no-narrative) | Integrity checks trivially pass; all arrays empty; report emitted with all counts=0 |
| EC-004 | Naming convention pattern regex is invalid syntax | Schema validation rejects the naming_registry entry; E-NAR-006 raised |
| EC-005 | Entity name "Zephyr_001" violates naming_registry pattern requiring no underscores, but `enforce: false` | Warning in report; KB accepted; downstream generation agents see the warning |
| EC-006 | New entity added to registry but old relationship edge still references the old entity ID under a different ID | E-NAR-003 for the stale relationship edge |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Canon-KB: 3 entities, 2 relationships (all refs valid), 4 timeline events (consistent timestamps), naming conventions satisfied | canon-kb-integrity-report: all pass; KB accepted | happy-path |
| Relationship edge with object_id "faction_deleted" not in entity_registry | E-NAR-003: dangling ref faction_deleted in relationship graph | error |
| Timeline event A "before" B and B "before" A (cycle in ordinal timeline) | E-NAR-004: cycle between event_A and event_B | error |
| Empty KB for genre=no-narrative | All integrity checks pass trivially; report: entity_count=0 | edge-case |
| Entity name violates non-enforced pattern | Warning in report; KB accepted | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.04.004 | For all Canon-KBs, every relationship edge with valid subject and object IDs always passes entity-ref check | proptest: generate KB with random valid/invalid refs |
| VP-5.04.005 | Ordinal timeline topological sort correctly detects cycles | proptest: generate random directed acyclic + cyclic graphs; assert cycle detection accuracy |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the canon-kb is listed as the "keystone artifact" in RECONCILIATION §5.6a and is a primary artifact in CAP-005's "generates EVERYTHING a game needs — narrative" mandate. This BC defines its structural integrity contract. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer) |
| Architecture Module | SS-04 — Canon-KB integrity validator / consistency checker (read view over the CAP-012-owned entity registry & timeline store; SS-04 does not own the registry) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.04.001 — depends on this (narrative graph grounding checks query this KB)
- BC-12.12.002 — authoritative owner of the entity registry that this BC reads/validates (consumer/validation view of authoritative store; CAP-012 / SS-10)
- BC-12.12.003 — authoritative owner of the relationship/edge graph that this BC validates (consumer/validation view of authoritative store; CAP-012 / SS-10)
- BC-12.12.004 — authoritative owner of the timeline that this BC validates for consistency (consumer/validation view of authoritative store; CAP-012 / SS-10)

## Architecture Anchors

- `architecture/SS-04-canon-kb.md` — Canon-KB data model and integrity checker

## Story Anchor

S-TBD — Canon-KB Structural Integrity Validation

## VP Anchors

- VP-5.04.004 — entity ref integrity
- VP-5.04.005 — ordinal timeline cycle detection
