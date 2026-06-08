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
  - .factory/planning/research/aaa/game-design-discipline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
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

# BC-5.01.002: Economy Graph Passes Balance-Band Invariants

## Description

The economy-designer agent produces an `economy-graph` artifact encoding a Machinations-
style source/sink graph with declared balance bands (e.g., "win-rate ∈ [45%, 55%]",
"currency net flow per session ∈ [-100, +100]"). The factory runs a simulation pass against
the graph and asserts each declared balance band. Conservation invariants (net-zero-sum flows)
are checked algebraically. Any band violation or conservation failure blocks the design bundle.

## Preconditions

1. A valid `economy-graph` artifact exists with `nodes`, `edges`, `balance_bands`, and
   `conservation_invariants` fields populated.
2. The economy simulation runner (wraps Machinations-class sim or equivalent) is available
   in the pipeline.
3. For each entry in `balance_bands`, the `check_method` is one of `"sim"` or `"formula"`;
   unknown methods are rejected at schema validation time.
4. For `"formula"` methods: the formula is an algebraic expression resolvable by the
   formula evaluator; all referenced variables are defined in the graph.

## Postconditions

1. For every entry in `balance_bands` with `check_method: "sim"`, the simulation runner
   executes the declared number of sim-steps (default: 1000) and measures the named metric.
   If the metric value at all measurement points lies within [min, max], the check passes.
2. For every entry in `balance_bands` with `check_method: "formula"`, the formula is
   evaluated with resolved graph parameters. If the result is within [min, max], check passes.
3. For every entry in `conservation_invariants`, the net flow across the declared boundary
   evaluates to 0 ± tolerance (default tolerance: 0.001 per unit step, configurable in GameSpec).
4. If ALL balance-band checks pass AND all conservation checks pass, the economy-graph
   validation report status is `"pass"` and the design bundle may proceed.
5. If any check fails, the validation report status is `"fail"` with per-band detail, and
   the design bundle is blocked. E-DES-003 or E-DES-004 is emitted per failing check.
6. A `balance-band-validation-report` is emitted regardless of pass/fail containing:
   metric names, measured values, declared bands, pass/fail per check, and sim seed used.

## Invariants

1. (DI-008) Economy graph uses engine-neutral node types only (source, sink, pool,
   converter, gate, drain). No engine-specific node types are recognized.
2. Balance bands may never be empty (a graph with no balance bands is not checkable and
   violates DI-012 — every ContractArtifact must have a declared validation method).
3. The sim seed is logged in the report for reproducibility. The same seed must produce
   the same measurement result on two consecutive runs of the same graph.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Economy graph has no edges (degenerate graph) | Schema validation catches: `edges` array empty is a structural error; E-DES-001 raised |
| EC-002 | Balance band `min > max` | Schema validation rejects; E-DES-001 raised with field=`balance_bands[N]` |
| EC-003 | Simulation runs 1000 steps and metric oscillates: sometimes inside band, sometimes outside | Check fails if any measurement is outside band; report flags oscillation pattern; E-DES-003 raised |
| EC-004 | Conservation invariant has a declared tolerance override of 0 | Formula check; if net flow != 0.0 exactly, E-DES-004 raised |
| EC-005 | Formula references an undefined variable | Formula evaluation error; E-DES-001 raised on the balance_band entry; sim check not attempted |
| EC-006 | Genre profile is "idle/incremental" — economy is intentionally asymmetric (prestige resets) | Prestige cycles must be declared as explicit conservation-invariant scope boundaries; without boundary declaration, check applies globally and would fail; designer must declare scope |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Economy graph: single source → pool → sink, equal flow rates, balance_band: currency_pool ∈ [0, 100], sim 1000 steps | All measurements 50 ± 5; pass; report emitted | happy-path |
| Economy graph: same as above but sink rate 10× source rate | Measurements fall to 0 by step 10, stay there; balance band [0, 100] — values in band (edge case: zero is in range) — PASS | edge-case |
| Economy graph: conservation_invariant "total_currency" with net inflow of +10/step (no sink) | Net flow = +10 per step; conservation fails; E-DES-004 raised | error |
| Balance band entry with min=0.6, max=0.4 | Schema rejects (min > max); E-DES-001 raised | error |
| Formula check: `win_rate = 0.5 + skill_delta * 0.05`, skill_delta declared = 0.0; band [0.45, 0.55] | win_rate = 0.5; in band; pass | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.01.004 | For all graphs with conservation_invariants declared, if net flow = 0 then conservation check passes | proptest over randomly generated balanced graphs |
| VP-5.01.005 | Sim runner with same seed produces identical measurement sequence (determinism) | Two-run comparison test: assert result equality |
| VP-5.01.006 | For all balance bands where min > max, schema validation rejects before sim runs | proptest: generate 1000 invalid band configs, assert all rejected at schema |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — this BC defines the machine-verifiable balance-band contract for the economy-graph, one of the primary named artifacts in CAP-005 ("balance data, economy graphs"). |
| L2 Domain Invariants | DI-008 (engine-portable spec layer), DI-012 (every ContractArtifact has declared validation method) |
| Architecture Module | SS-04 — economy-graph validator; sim runner (Machinations-class wrapper) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.01.001 — composes with (economy-graph is a sub-artifact of the design bundle)
- BC-5.07.002 — depends on (cross-discipline dependency contract checks economy-graph validity)

## Architecture Anchors

- `architecture/SS-04-economy-sim.md` — sim runner, balance-band check pipeline

## Story Anchor

S-TBD — Economy Graph Balance Validation

## VP Anchors

- VP-5.01.004 — conservation invariant correctness
- VP-5.01.005 — sim determinism
- VP-5.01.006 — schema rejection of malformed bands
