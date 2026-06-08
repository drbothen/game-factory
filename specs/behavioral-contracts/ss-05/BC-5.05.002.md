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
  - .factory/planning/research/aaa/engineering-disciplines.md
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

# BC-5.05.002: Simulation Module Passes TDD Red Gate Before Production Code Exists

## Description

For every pure-sim code module (gameplay systems, economy, AI behavior trees, deterministic
sim logic), the factory enforces the TDD Red Gate: a failing test for the module's
behavioral contract must exist in the repository BEFORE the implementer writes any
production code. The hook chain verifies this by checking git history: a test commit
demonstrating RED (failing) must precede any production code commit for that story. This
is the game-factory analog of vsdd-factory's TDD Red Gate (RECONCILIATION §3, §4), retained
for the pure-sim slice.

## Preconditions

1. A story with `story_type: "pure-sim"` or equivalent flag exists in the story registry.
2. The story is assigned to a `module_type: "pure-sim"` code module.
3. A test-writer agent has been dispatched for the story.
4. The test-writer agent has produced a test file referencing the to-be-implemented
   behavioral contract (BC-S.SS.NNN) with at least one test function.
5. The test file has been committed to the story's git worktree.
6. The test suite runner (cargo test, pytest, or equivalent) is available in CI.

## Postconditions

1. The pre-commit hook (or CI gate) runs the test suite on the current state of the
   story worktree AFTER the test file is committed.
2. The hook asserts that the test run produces at least one FAILING test for the target
   module/story. If all tests pass at this stage: E-ENG-002 is raised — this indicates
   the test is not actually testing anything (trivially green without implementation).
3. The hook records the `red-gate-evidence` in the story's audit trail:
   - `test_commit_sha`: the commit SHA where failing tests were first committed
   - `failing_test_count`: number of failing tests at red-gate time
   - `story_id`: the story this applies to
   - `module_type`: must be "pure-sim"
4. The implementer may only write production code AFTER `red-gate-evidence` is recorded.
   Any production code commit that precedes `red-gate-evidence` is rejected by the
   pre-commit hook with E-ENG-002.
5. Once `red-gate-evidence` exists: the implementer writes production code to make the
   tests pass (GREEN). The CI gate verifies all tests pass before merge.

## Invariants

1. (DI-012) The TDD Red Gate is a required validation method for all pure-sim behavioral
   contracts. Bypassing it (e.g., committing production code without a prior test commit)
   is a hook-detectable defect.
2. Engine-bound modules (`module_type: "engine-bound"`) are EXEMPT from the TDD Red Gate.
   They require integration/manual testing by design.
3. The Red Gate applies per story, not per module. A single story may cover one or more
   methods/functions in a module; the gate requires at least one failing test per story.
4. Test files containing only `todo!()` / `pass` / no-op bodies (empty tests) do NOT
   satisfy the Red Gate. A failing test must actually fail due to missing implementation.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Test writer commits a test that asserts `assert!(true)` (always passes) | All tests green at Red Gate check; E-ENG-002 raised: Red Gate requires at least one failing test |
| EC-002 | Test writer commits test that fails due to compile error (not semantic failure) | Compile error counts as a RED gate evidence if the compile error is due to missing implementation (module not yet defined). If compile error is a test author bug, test-writer must fix it first |
| EC-003 | Implementer writes production code in the same commit as the test file | Pre-commit hook detects: production code + test in same commit; E-ENG-002: Red Gate requires a separate test commit before production code |
| EC-004 | Story is reclassified from pure-sim to engine-bound after Red Gate was recorded | Reclassification workflow required; existing Red Gate evidence is retained but marked "n/a" for the new classification |
| EC-005 | Test writer produces test for module A but story is scoped to module B | E-ENG-002 variant: test file does not reference the story's assigned module; test-writer must correct |
| EC-006 | All failing tests pass after first production code commit, but new requirements added to BC mid-story | New failing tests must be committed for new requirements before new production code; Red Gate applies per requirement, not per story lifetime |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Story with pure-sim module; test commit exists with 2 failing tests; implementer commits production code after test commit | Red Gate passes; production code commit accepted; CI proceeds to GREEN phase | happy-path |
| Story with pure-sim module; implementer commits production code with no prior test commit | E-ENG-002: production code commit precedes red-gate-evidence for story S-NNN | error |
| Test file committed with `assert!(true)` only | E-ENG-002: all tests pass at Red Gate time; failing test required | error |
| engine-bound module story; no test commit before production code | No Red Gate applied; engine-bound exempt; production code commit accepted | edge-case |
| Test commit with compile error due to missing module (implementation not yet written) | Red Gate passes (compile error = RED); red-gate-evidence recorded | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.05.003 | For all pure-sim stories, production code commit without prior test commit always raises E-ENG-002 | integration test: create story, commit production code first, assert hook rejects |
| VP-5.05.004 | Red Gate evidence is immutable after recording (append-only) | test: attempt to overwrite red-gate-evidence; assert rejected |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — simulation code modules are primary artifacts in CAP-005's "generates EVERYTHING a game needs — code artifacts" mandate; the TDD Red Gate is the machine-checkable production process contract for those modules per RECONCILIATION §4. |
| L2 Domain Invariants | DI-012 (every ContractArtifact has a declared validation method — TDD Red Gate IS the validation method for pure-sim code contracts) |
| Architecture Module | SS-TBD — TDD Red Gate hook; story audit trail; test runner |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.05.001 — composes with (pure-sim separation is precondition for Red Gate to be meaningful)

## Architecture Anchors

- `architecture/SS-TBD-engineering-pipeline.md` — TDD Red Gate hook, story audit trail

## Story Anchor

S-TBD — TDD Red Gate Enforcement for Pure-Sim Modules

## VP Anchors

- VP-5.05.003 — production-before-test rejection
- VP-5.05.004 — red-gate-evidence immutability
