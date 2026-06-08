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
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: brownfield
extracted_from: ".reference/vsdd-factory/hooks/red-gate.sh"
subsystem: SS-05
capability: CAP-006
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

# BC-6.04.001: TDD Red Gate — Pure-Sim Slice Enforcement

## Description

Verifies that the TDD Red Gate (reused from vsdd-factory per
extraction-boundary-validated.md §3.1) is enforced on the pure-sim slice:
failing tests must exist before any implementation is written for simulation
code under a sim-BC. The Red Gate is opt-in via `.factory/red-gate-state.json`
mode=strict; it defaults to OFF for engine-bound/render code and ON for the
pure-sim slice. This contract asserts that the gate is active and operative for
the declared sim modules and that the gate cannot be bypassed without an explicit
and auditable override.

## Preconditions

1. `.factory/red-gate-state.json` exists with `mode: strict` configured for the
   pure-sim slice modules (economy-sim, combat-sim, entity-fsm,
   ai-behavior-tree, and any other module covered by a sim-BC).
2. The Red Gate hook (`hooks/red-gate.sh`) is registered in `hooks-registry.toml`
   and fires on pre-commit or pre-merge events for the sim slice crate boundaries.
3. The pure-sim slice is identifiable at the crate or module level — there is a
   declared boundary between pure-sim code and engine-bound code.
4. The test-writer agent has authored failing tests for the BC BEFORE the
   implementer agent writes production code (the Red Gate enforces this ordering).

## Postconditions

1. If an implementer commits sim-slice code when no corresponding failing test
   exists for the changed module, the Red Gate hook fires and blocks the commit
   with a machine-detectable rejection.
2. The Red Gate state is auditable: `.factory/red-gate-state.json` records
   the current mode per module and the last-verified timestamp.
3. Bypassing the Red Gate (by changing mode from `strict` to `off` for a
   sim-slice module) is detectable as a governance event in the telemetry stream
   and is reported as a policy violation in the docs convergence dimension
   (BC-7.09.001).
4. The Red Gate degrades gracefully: for engine-bound code (rendering, capture,
   physics integration), the gate is OFF by default and the absence of a failing
   test does not block. The degradation boundary is the declared sim-slice
   crate/module list.

## Invariants

1. The pure-sim slice (all modules covered by sim-BCs) always operates under
   strict Red Gate mode unless an explicit auditable override is declared and
   logged.
2. The Red Gate hook is TDD-generic and domain-agnostic (confirmed from
   extraction-boundary-validated.md §3.1: `red-gate.sh` is not coupled to BC
   schemas). It operates purely on test-existence-before-production-code ordering.
3. The degradation boundary (sim-slice vs engine-bound) is declared in a config
   file at crate/module granularity, not inferred from the hook.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Test-writer authors failing test; implementer writes passing implementation | Sequence correct; Red Gate satisfied; commit allowed |
| EC-002 | Implementer attempts to commit before test-writer has authored a test | Red Gate fires; commit blocked; error: "no failing test exists for modified sim-slice module" |
| EC-003 | Test-writer authors a test that immediately passes (was not actually failing) | Red Gate detects test was not failing before implementation; advisory warning; test-writer must fix the test |
| EC-004 | Engine-bound module modified with no failing test | Red Gate is OFF for engine-bound modules; no block; degradation boundary enforced |
| EC-005 | Red Gate mode set to `off` for an economy-sim module (override) | Governance event fired to telemetry; policy violation logged to docs dimension; adversarial review flagged |
| EC-006 | New sim-slice module added but not declared in red-gate-state.json | Module defaults to OFF; advisory warning: "new pure-sim module not registered in red-gate-state.json" |
| EC-007 | Test suite is empty (no tests at all for a sim module) | Red Gate treats absence of any tests as a failing-test-existence failure; blocks first implementation commit until at least one test is authored |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Implementer commits economy-sim code; test-writer previously authored failing test | Red Gate PASS; commit allowed | happy-path |
| Implementer commits economy-sim code; no failing test exists | Red Gate FAIL; commit blocked; "no failing test for economy-sim" | error |
| Engine-bound rendering code committed; no test | Red Gate degraded to OFF; commit allowed; no advisory | edge-case (degradation) |
| Red Gate mode changed to `off` for combat-sim | Governance event emitted; policy violation logged; adversary flagged | edge-case (override) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-019 | Red Gate hook returns BLOCK for any sim-slice commit with zero failing tests | kani (pure function: given sim-slice flag = true, test-exists = false → output = BLOCK) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC implements the "TDD Red Gate enforcement on the pure-sim slice" component of CAP-006, including the "reused from vsdd-factory, opt-in strict" qualifier |
| L2 Domain Invariants | DI-012 (every contract has a declared validation method) |
| Architecture Module | red-gate-hook (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.01.001 — depended on by (economy-sim coverage requires Red Gate active)
- BC-6.01.002 — depended on by (combat-sim coverage requires Red Gate active)
- BC-6.01.003 — depended on by (entity-fsm coverage requires Red Gate active)
- BC-6.01.004 — depended on by (AI BT coverage requires Red Gate active)
- BC-7.03.001 — depended on by (implementation convergence dimension checks Red Gate operative status)

## Architecture Anchors

- `architecture/SS-05-red-gate-hook.md` — Red Gate hook configuration and sim-slice boundary declaration

## Story Anchor

S-TBD — TDD Red Gate Pure-Sim Slice Configuration

## VP Anchors

- VP-TBD-019 — Red Gate blocks sim-slice commit with zero failing tests

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `.reference/vsdd-factory/hooks/red-gate.sh` |
| **Confidence** | high (extraction-boundary-validated.md §3.1 explicitly confirms REUSE disposition) |
| **Extraction Date** | 2026-06-07 |

#### Evidence Types Used

- **documentation**: extraction-boundary-validated.md §3.1 documents that `red-gate.sh` is TDD-generic, opt-in, and not BC-coupled
- **assertion**: "game-factory should REUSE red-gate verbatim for the deterministic-sim slice" per extraction-boundary-validated.md

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads `.factory/red-gate-state.json`; reads test existence from filesystem |
| **Global state access** | reads red-gate-state.json (configuration) |
| **Deterministic** | yes — given same red-gate-state.json and test files, produces same result |
| **Thread safety** | not applicable (shell script) |
| **Overall classification** | effectful shell (reads config + filesystem; no pure-function core) |

#### Refactoring Notes

The hook is a shell script, not a Rust crate. Extracting the pure decision logic
(given test-exists: bool, mode: Mode → decision: Allow|Block) as a pure function
would enable Kani verification of the gate logic. Recommended for formal hardening
of the governance path.
