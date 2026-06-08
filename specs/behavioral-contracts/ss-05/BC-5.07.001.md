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
  - .factory/specs/domain-spec/processes.md
  - .factory/planning/research/aaa/production-pipeline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
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

# BC-5.07.001: Cross-Discipline Dependency Contract Is Declared Before Dependent Wave Begins

## Description

The producer-orchestrator agent creates a `cross-discipline-dependency-contract` for each
typed handoff between disciplines (e.g., design→art, art→engineering, narrative→engineering).
This contract declares the artifact types, format requirements, budget constraints, naming
conventions, and acceptance criteria that the consumer discipline requires. The factory
enforces that no dependent discipline wave begins before its upstream dependency contract
is declared, schema-valid, and acknowledged by both the producer and consumer agent
clusters. This prevents silent mid-wave surprises when a consumer receives an artifact
that doesn't meet its requirements.

## Preconditions

1. A `game-production-plan` exists with a `discipline_dag` that lists all discipline
   dependencies as `{producer: discipline, consumer: discipline}` pairs.
2. For each dependency pair, the producer-orchestrator agent has been dispatched.
3. The `cross-discipline-dependency-contract` schema (v1.0 or later) is registered.
4. The consumer discipline's wave start is pending (not yet initiated).

## Postconditions

1. Before the consumer discipline's wave start command is issued, the factory checks that
   a `cross-discipline-dependency-contract` exists for every `{producer, consumer}` pair
   involving the consumer discipline.
2. Each contract must pass schema validation (exit 0 on schema validator).
3. The contract must be acknowledged by the producer discipline's lead agent (recorded as
   a `producer_ack: {agent_id, timestamp}` in the contract's metadata).
4. The contract must be acknowledged by the consumer discipline's lead agent (recorded as
   a `consumer_ack: {agent_id, timestamp}` in the contract's metadata).
5. If any dependency contract is missing, schema-invalid, or missing either acknowledgment:
   E-PROD-001 is raised; the consumer discipline wave is blocked until resolved.
6. A `dependency-contract-readiness-report` is emitted before each wave start, listing all
   dependency contracts, their validation status, and acknowledgment status.
7. Once all contracts for a wave are validated and acknowledged, the wave start is permitted.

## Invariants

1. (DI-006 analog) Dependency contracts are never silently bypassed. The wave-gate hook
   checks contract presence and acknowledgment for every discipline dependency before
   allowing wave start.
2. A dependency contract is immutable once acknowledged. Changes after acknowledgment
   require a contract revision, which re-triggers acknowledgment from both parties and
   re-validation.
3. The `change_propagation_policy` field in the contract declares how upstream changes
   are handled: `"blocking"` (consumer wave halted until re-validation), `"advisory"`
   (warning surfaced; consumer proceeds), or `"deferred"` (change queued for next wave).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Discipline DAG has a cycle (design depends on narrative depends on design) | DAG validation detects cycle; E-PROD-003 raised at game-production-plan validation time; plan rejected before any wave begins |
| EC-002 | Producer discipline produces its artifacts but the contract was declared with wrong format requirements | Contract revision triggered; consumer discipline wave blocked; E-PROD-002 raised at acceptance check time (BC-5.07.002) |
| EC-003 | Consumer agent acknowledges contract without reading it (auto-ack) | Acknowledgment is recorded; factory does not verify whether the agent "read" it; auto-ack is valid; contract obligations are enforced at artifact handoff (BC-5.07.002) |
| EC-004 | New discipline added to game mid-production (e.g., esports lane activated) | New dependency contracts required for all new discipline edges; existing waves not affected; new waves blocked until contracts declared |
| EC-005 | Contract declared with `change_propagation_policy: "blocking"` and upstream artifact changes | Consumer wave halted; E-PROD-002 at change detection; re-validation required; producer must re-acknowledge |
| EC-006 | No dependency contracts needed (single-discipline game, e.g., pure puzzle with no art/audio) | `discipline_dag` has no edges; dependency contract check trivially passes; wave start permitted |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Art wave starting; design→art contract exists, schema-valid, both acknowledged | dependency-contract-readiness-report: pass; art wave start permitted | happy-path |
| Art wave starting; design→art contract missing | E-PROD-001: missing cross-discipline-dependency-contract from design to art | error |
| Art wave starting; design→art contract exists but consumer (art) ack missing | E-PROD-001: consumer ack missing for design→art contract | error |
| DAG has cycle (design→art→design) | E-PROD-003: cycle detected in discipline DAG; plan rejected | error |
| Single-discipline puzzle game; no DAG edges | dependency-contract-readiness-report: no dependencies; wave start permitted | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.07.001 | For all consumer discipline waves, absence of any required dependency contract always raises E-PROD-001 | proptest: generate discipline DAGs with random edge sets; assert contract checks enforce all edges |
| VP-5.07.002 | DAG cycle detection correctly identifies all cyclic dependencies | proptest: generate random directed graphs including cyclic examples; assert cycle detection |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the cross-discipline-dependency-contract is named in RECONCILIATION §5.8 and §6.1 as owned by the producer/orchestrator and is the central new artifact for multi-discipline coordination in CAP-005. |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced — dependency blocks are equivalent surface), DI-012 (every ContractArtifact has declared validation method) |
| Architecture Module | SS-04 — producer-orchestrator; dependency contract schema registry; wave-gate hook |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.07.002 — composes with (this BC gates contract declaration; BC-5.07.002 gates artifact handoff)
- BC-5.07.003 — composes with (wave schedule checks dependency readiness per this BC)

## Architecture Anchors

- `architecture/SS-04-production-orchestration.md` — dependency contract management, wave gate

## Story Anchor

S-TBD — Cross-Discipline Dependency Contract Declaration Gate

## VP Anchors

- VP-5.07.001 — contract presence enforcement
- VP-5.07.002 — DAG cycle detection
