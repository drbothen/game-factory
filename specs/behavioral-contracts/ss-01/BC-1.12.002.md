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

# BC-1.12.002: Core Selects Replay Comparison Method from Declared determinismTier

## Description

When the factory core requests a replay comparison, it selects the comparison
method based solely on the adapter's declared `determinismTier` — never on an
assumption or higher-order default. This is the runtime enforcement of the
declare-and-degrade contract for determinism: a lower-tier adapter never receives
a stricter comparison request than it supports.

## Preconditions

1. The adapter has declared a `determinismTier` in its Capability Manifest.
2. The factory core is preparing a `replay/play` request.

## Postconditions

1. If `determinismTier` is `"bitwise-cross-platform"` (T1): the core requests
   `comparison.method: "snapshot-hash-diff"` — bitwise hash equality across any
   runner.
2. If `determinismTier` is `"same-machine"` (T2): the core requests
   `comparison.method: "snapshot-hash-diff"` BUT only on a pinned runner image;
   the core enforces that T2 replay requests are only dispatched to the matching
   pinned runner.
3. If `determinismTier` is `"tolerance-only"` (T3): the core requests
   `comparison.method: "tolerance-window"` — metric-based comparison with declared
   tolerance bands.
4. The core NEVER sends `snapshot-hash-diff` to a `"tolerance-only"` adapter.
5. The comparison method used is recorded in the replay regression report.

## Invariants

1. The comparison method is always a deterministic function of the declared tier;
   no run-time override is possible by the pipeline planner without changing the
   manifest.
2. Downgrading from `snapshot-hash-diff` to `tolerance-window` (T1→T3) is only
   valid if the tier was explicitly downgraded; the core never silently falls back.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | T2 adapter but no pinned runner available in current CI environment | Core falls back to T3 comparison method and records the degradation in the convergence report (explicitly, not silently) |
| EC-002 | T1 adapter but `replay` capability declared `fidelity: "none"` | Core does not issue a replay request at all; replay dimension degrades to playtest evidence |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T1 adapter, replay/play invoked | `comparison.method: "snapshot-hash-diff"` in ReplayResult | happy-path |
| T3 adapter, replay/play invoked | `comparison.method: "tolerance-window"` in ReplayResult | happy-path |
| T2 adapter with no pinned runner | Core records T2→T3 degradation in convergence report | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-045 | snapshot-hash-diff is never sent to a tolerance-only adapter | unit test of core replay dispatch logic |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — core-side tier-to-method selection is the implementation of the declare-and-degrade pattern for the replay/determinism axis |
| L2 Domain Invariants | DI-004 (tier governs comparison method; factory never assumes a tier) |
| Architecture Module | Factory Core Pipeline Planner (Layer 2) (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.12.001 — depends on (tier is declared in the manifest)
- BC-1.12.003 — composes with (DeterminismTierViolation when stricter comparison requested)

## Architecture Anchors

- `planning/design/protocol-schema.md#4-determinism-tier-decision-0003`
