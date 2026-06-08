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

# BC-5.07.002: Cross-Discipline Dependency Acceptance Criteria Are Machine-Checked on Handoff

## Description

When a producing discipline delivers artifacts to a consuming discipline (e.g., art delivers
GLB packages to engineering for engine import), the factory runs the acceptance criteria
declared in the `cross-discipline-dependency-contract` against the delivered artifacts.
All acceptance criteria of type `schema_valid`, `bc_pass`, `format_check`, `budget_check`,
and `naming_check` are machine-executed. The handoff is rejected if any criterion fails;
the consumer discipline's wave is blocked until the producer resolves the failures. This is
the central enforcement mechanism for cross-discipline quality at the integration seam.

## Preconditions

1. A `cross-discipline-dependency-contract` exists between the producer and consumer
   discipline (BC-5.07.001 postconditions have been met: contract is valid and acknowledged).
2. The producer discipline has produced its deliverable artifact set for the current wave.
3. The deliverable artifact set is staged in the factory handoff staging area (a designated
   path in the factory file system, separate from the in-progress workspace).
4. The acceptance criteria in the contract are all of machine-executable types (see
   postcondition #1 for the list of valid types; human-judgment criteria must be flagged
   as `check_type: "human-gate"` and are not executed here).

## Postconditions

1. For each acceptance criterion in the contract's `acceptance_criteria` array:
   - `schema_valid`: the artifact at the declared path is validated against the schema
     referenced in the criterion. Pass → criterion green. Fail → E-PROD-002 per criterion.
   - `bc_pass`: the declared BC is run against the artifact. Pass → criterion green.
     Fail → E-PROD-002 per criterion with BC ID and failure detail.
   - `format_check`: the artifact format matches the declared encoding and version. Mismatch
     → E-PROD-002.
   - `budget_check`: the artifact's declared budget field (e.g., poly_count, bank_size_mb)
     is within the contract's declared budget constraint. Violation → E-PROD-002.
   - `naming_check`: the artifact's file/asset name matches the declared naming convention
     pattern (regex). Mismatch → E-PROD-002.
   - `human-gate`: logged as a pending human review task; not machine-executed; does not
     block the automated gate but is tracked as an open milestone item.
2. If ALL machine-executable criteria pass:
   - A `handoff-acceptance-report` with status `"pass"` is emitted.
   - The deliverable artifacts are transferred to the consumer discipline's input staging area.
   - The consumer discipline wave may proceed.
3. If ANY criterion fails:
   - A `handoff-acceptance-report` with status `"fail"` and per-criterion detail is emitted.
   - Artifacts are NOT transferred.
   - E-PROD-002 is raised for each failing criterion.
   - Producer discipline is notified; consumer discipline wave remains blocked.
4. For `change_propagation_policy: "blocking"` contracts: if the producer modifies a
   previously-accepted deliverable, the acceptance check re-runs automatically and the
   consumer is notified of re-validation.

## Invariants

1. (DI-012) Every acceptance criterion must have a declared `check_type`. A criterion
   with no check_type is a schema error in the dependency contract.
2. The handoff staging area is immutable from the consumer's perspective once acceptance
   passes. The producer may not overwrite accepted artifacts without triggering a contract
   revision (which re-runs acceptance).
3. The `handoff-acceptance-report` is a permanent audit record. It is stored in
   `.factory/audit/handoff-reports/<contract_id>/<wave_id>.json`.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Art delivers 48 of 50 required GLB packages; contract requires all 50 | `bc_pass` criterion for BC-5.02.001 fails for missing assets; E-PROD-002 raised; handoff rejected |
| EC-002 | Engineering wave imports art successfully but discovers an asset was accepted with wrong bone naming convention | Naming check should have caught this in acceptance criteria; if naming_check was present and passed, the contract's naming pattern was insufficient; contract revision required |
| EC-003 | Budget constraint in contract specifies poly budget but art was produced before budget was declared (contract revision occurred) | Re-acceptance run triggered; artifacts checked against new budget; if fail: E-PROD-002; producer must re-deliver within budget |
| EC-004 | Audio delivers banks with correct schema but loudness is 2.5 dB above target (E-AUD-002 in BC-5.03.001) | `bc_pass` criterion for BC-5.03.001 fails; E-PROD-002 raised; audio must fix loudness before handoff |
| EC-005 | Acceptance criteria list contains zero machine-executable criteria (all human-gate) | No machine checks run; human-gate tasks surfaced; handoff report status "pending-human-review"; artifacts transferred to consumer staging pending human gates |
| EC-006 | Producer delivers artifact with correct schema but incorrect encoding (e.g., JSON delivered as BSON) | `format_check` criterion fails: encoding mismatch; E-PROD-002 |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Art delivers 50 GLB packages, all schema-valid, all naming correct, all within budget, BC-5.02.001 passes | handoff-acceptance-report: pass; artifacts transferred to engineering staging | happy-path |
| Art delivers package with poly count 20% over budget_check limit | E-PROD-002: criterion budget_check.poly_count failed: actual=12000, limit=10000 | error |
| Naming check: contract requires "prop_<name>_lod<n>.glb"; asset named "asset_castle.glb" | E-PROD-002: naming_check failed: 'asset_castle.glb' does not match pattern 'prop_*_lod*.glb' | error |
| Audio handoff with bc_pass criterion for BC-5.03.001, bank loudness -20 LUFS (target -23 ±2) | E-PROD-002: bc_pass BC-5.03.001 failed: loudness -20 LUFS outside -23±2 LUFS | error |
| All criteria human-gate type | Handoff report: pending-human-review; all human tasks surfaced; no block | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.07.003 | For all handoff events, a failing acceptance criterion always prevents artifact transfer | integration test: inject failing artifact; assert transfer blocked |
| VP-5.07.004 | handoff-acceptance-report is written to audit log on every handoff attempt regardless of pass/fail | integration test: force both pass and fail; assert report exists in audit path |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — this BC enforces the cross-discipline-dependency-contract acceptance criteria at handoff time, which is the machine-verifiable spine of RECONCILIATION §6.1's "Automated validation on merge; DAM propagation" validation method for that artifact. |
| L2 Domain Invariants | DI-012 (every ContractArtifact has declared validation method) |
| Architecture Module | SS-04 — acceptance criteria runner; handoff staging; audit log writer |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.07.001 — depends on (contract must be declared before this check runs)
- BC-5.02.001 — referenced by (bc_pass criterion may reference this BC)
- BC-5.03.001 — referenced by (bc_pass criterion may reference this BC)

## Architecture Anchors

- `architecture/SS-04-production-orchestration.md` — acceptance criteria runner, handoff staging

## Story Anchor

S-TBD — Cross-Discipline Handoff Acceptance Criteria Execution

## VP Anchors

- VP-5.07.003 — failing criterion blocks transfer
- VP-5.07.004 — audit log always written
