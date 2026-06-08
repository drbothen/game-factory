---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-06
capability: CAP-007
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

# BC-7.03.001: Implementation Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #3: implementation.
This dimension is GREEN when: the game build passes CI (engine adapter `build`
and `test` capabilities succeed), lint is clean, the architecture-separation rule
(logic vs presentation, pure-sim vs engine-bound) is enforced by the hook chain,
and the `security-requirements-contract` structural presence is verified. This
is the one convergence dimension with NO degradation path — a failing build
always blocks release.

## Preconditions

1. The engine adapter's `build` and `test` capabilities are available (fidelity
   != none).
2. The lint configuration (`cargo clippy` or engine-specific linter) is configured
   and runnable in CI.
3. The architecture-separation rule is encoded as a hook or linter plugin:
   pure-sim modules may not import engine SDK types; engine-bound modules may not
   contain gameplay logic.
4. The `security-requirements-contract` artifact exists (schema validation, not
   content audit — content is the security-invariants dimension BC-7.11.001).
5. The Red Gate state is verifiable (BC-6.04.001 operative).

## Postconditions

1. **GREEN:** Build succeeds (zero compilation errors), lint is clean (zero
   clippy-deny violations), architecture-separation rule passes (zero
   cross-boundary imports), `security-requirements-contract` is structurally
   present with required fields.
2. **BLOCKED:** Any of the above fails. Build failure, lint-deny violations,
   architecture-separation violations, or missing `security-requirements-contract`
   each independently block this dimension.
3. **No DEGRADED state exists.** The build is either passing or failing. Degrading
   a failing build is never valid — it would mean shipping broken code.

## Invariants

1. This dimension has no degradation path. A BLOCKED implementation dimension
   means release is blocked, period.
2. Lint warnings that are not `deny` level do not block the dimension; they are
   reported as advisory in the convergence-report.
3. Architecture-separation violations are treated as lint-deny violations — they
   block the dimension.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Build passes but lint has 1 clippy-deny violation | BLOCKED by lint; build success insufficient |
| EC-002 | Pure-sim module imports one engine type as a type alias | Architecture separation violation; BLOCKED; the alias does not exempt the import |
| EC-003 | `security-requirements-contract` present but frontmatter is malformed | Structural presence check fails; BLOCKED; schema validation error |
| EC-004 | Engine adapter `test` capability returns partial (some tests fail) | BLOCKED; partial test pass does not satisfy implementation dimension |
| EC-005 | Red Gate was bypassed for one commit | Implementation dimension records Red Gate bypass as an advisory note; governance event logged; not itself a BLOCKED state for this dimension (governance defect is recorded separately) |
| EC-006 | Godot adapter uses GDScript for a pure-logic module | Architecture-separation rule applies by language as well as imports; GDScript gameplay logic in non-engine-bound module = violation |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Build PASS, lint clean, arch-sep clean, security-contract present | implementation = GREEN | happy-path |
| Build PASS, lint has 1 deny violation | implementation = BLOCKED; "lint: clippy::unwrap_used in economy-sim/main.rs:42" | error |
| Build PASS, lint clean, engine import in pure-sim module | implementation = BLOCKED; "arch-separation: engine::Transform imported in economy-sim" | error |
| Build FAIL | implementation = BLOCKED; build errors listed | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-022 | Implementation dimension is GREEN only if all four sub-checks pass | kani (logical AND over sub-check results) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #3 (implementation) |
| L2 Domain Invariants | DI-001 (factory core never names a specific engine — enforced by arch-separation hook), DI-012 |
| Architecture Module | convergence-tracker (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-6.04.001 — related to (Red Gate operative status is an implementation-dim input)
- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Implementation Convergence Dimension
