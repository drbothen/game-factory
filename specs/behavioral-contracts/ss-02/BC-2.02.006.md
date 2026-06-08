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
  - .factory/specs/domain-spec/processes.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/planning/decisions/0001-founding-engine-pair.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-002
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

# BC-2.02.006: Reference Mini-Game Acceptance Validation

## Description

As the final stage of adapter acceptance (after capability-gated conformance tests pass),
the conformance suite builds, runs, and tests a canonical reference mini-game through the
adapter under test. Success of the reference mini-game run is required for full adapter
acceptance. The reference mini-game is the same mini-game across all adapters, expressed in
engine-neutral spec, and provides an integration-level correctness signal that cannot be
detected by unit-level capability tests alone. A failure in the reference mini-game run
blocks acceptance even if all capability tests passed.

## Preconditions

1. All capability-gated conformance tests (BC-2.02.001) have passed for the adapter.
2. The capability-gated acceptance gate (BC-2.02.002) would accept the adapter based on
   capability tests alone.
3. The reference mini-game spec is available and has been translated to the adapter's
   target engine (this translation is a one-time step per engine, produced during adapter
   authoring).
4. The adapter's `build` and `test` capabilities are declared at `full` or `partial`
   fidelity (the mini-game requires both to run).

## Postconditions

1. The conformance runner invokes `build` on the reference mini-game via the adapter.
   - Build must succeed within the configured build timeout.

2. The conformance runner invokes `test` on the reference mini-game via the adapter,
   running its canonical test suite.
   - All reference mini-game tests must pass.

3. If both build and test succeed:
   - The adapter's accepted record is marked `reference_mini_game: passed`.
   - Acceptance is finalized.

4. If build or test fails:
   - The adapter's accepted record is marked `reference_mini_game: failed`.
   - Adapter status is set to `rejected` (regardless of capability test results).
   - Failure details (build log or failing test output) are included in the rejection report.

5. The reference mini-game used for validation is recorded by ID and version in the
   accepted record, ensuring future re-runs use the same mini-game spec.

## Invariants

1. **Reference mini-game is the same across all adapters:** The same mini-game spec is
   used for every adapter's acceptance validation. Engine-specific implementations are
   derived from the same spec; the spec itself is not modified per-adapter.
2. **Mini-game pass is required for full acceptance:** Capability tests alone are
   insufficient for full adapter acceptance. Both gates must pass.
3. **Build and test capabilities are prerequisites:** If the adapter does not have `build`
   and `test` at sufficient fidelity to run the mini-game, the mini-game step is skipped
   and the adapter's accepted record notes `reference_mini_game: skipped_insufficient_build_test`.
   This is not a rejection but the adapter is marked as not-fully-validated.
4. **Mini-game test suite is engine-neutral assertions:** The reference mini-game's test
   suite tests game-logic correctness (simulation state, win/loss conditions, entity counts)
   not engine-specific rendering or UI. This keeps the assertions portable.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Reference mini-game build fails but all capability tests passed | Adapter rejected due to mini-game build failure. Capability test results retained in report for diagnostic purposes. |
| EC-002 | Reference mini-game tests time out (engine hangs or infinite loop) | Treated as test failure; adapter rejected; timeout duration logged. |
| EC-003 | Adapter declares `build: partial`; reference mini-game requires `build: full` | Mini-game step skipped (`skipped_insufficient_build_test`); adapter accepted with caveat; convergence report notes unvalidated integration. |
| EC-004 | Reference mini-game spec version updated (new mini-game) | All existing adapters must re-run mini-game validation against new version before the factory considers them fully validated for the new spec version. |
| EC-005 | Two adapters both pass capability tests; one fails mini-game | The failing adapter is rejected; the passing adapter is accepted; they are independent registry entries. |
| EC-006 | Bevy adapter (founding pair) and Unity adapter (founding pair) — both must validate against the same mini-game spec | Both run the same spec via their respective engine implementations. This validates the Two-Adapter Rule (ADR-0001): if both pass, the spec is genuinely engine-neutral. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy adapter; capability tests all pass; reference mini-game builds and all game-logic tests pass | Accepted; `reference_mini_game: passed`. | happy-path |
| Unity adapter; capability tests all pass; reference mini-game build fails (missing asset path) | Rejected; `reference_mini_game: failed`; reason: build error with log. | error-path |
| Godot adapter; `build: partial`, `test: partial`; mini-game requires full build | Mini-game step skipped; adapter accepted with `reference_mini_game: skipped_insufficient_build_test`. | edge-case |
| Reference mini-game test: `assert entity_count("enemy") == 5 after frame 100` via Bevy adapter | Assertion passes; test recorded as pass. | happy-path (mini-game test) |
| Reference mini-game test: `assert entity_count("enemy") == 5 after frame 100` via Bevy adapter after gameplay bug introduced | Assertion fails; mini-game test fails; adapter rejected for this engine version. | regression detection |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-016 | An adapter with `reference_mini_game: failed` is never in the `accepted` registry state. | kani / static analysis |
| VP-TBD-017 | The reference mini-game used for acceptance is recorded by ID+version in the accepted record. | schema validation |
| VP-TBD-018 | The Two-Adapter Rule is exercised: both Bevy and Unity adapters are validated against the same mini-game spec version. | integration test (CI matrix) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC specifies the reference mini-game acceptance validation which is the integration-level acceptance gate named in PROC-002 Stage 5 and referenced in ADR-0002 as "acceptance tests exercise real engine build/test/replay through the real adapter." |
| L2 Domain Invariants | DI-001 (Factory Core Never Names a Specific Engine), DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance) |
| Architecture Module | SS-01 (Conformance Suite, Reference Mini-Game Registry — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-002 Stage 5 (Reference Mini-Game Validation) |
| ADRs | ADR-0002 §Decision point 2 (acceptance tests exercise real engine through real adapter), ADR-0001 (Two-Adapter Rule) |

## Related BCs

- BC-2.02.001 — depends on (must pass before mini-game runs)
- BC-2.02.002 — composes with (mini-game failure produces same rejection outcome)
- BC-2.02.004 — depends on (version check must pass before mini-game runs)

## Architecture Anchors

- `architecture/SS-01-conformance-suite.md` — Reference mini-game runner, spec registry
- `.factory/planning/decisions/0001-founding-engine-pair.md` — Two-Adapter Rule requiring Bevy+Unity both validate same mini-game

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-016 — no accepted record with failed mini-game
- VP-TBD-018 — two-adapter-rule CI matrix validation
