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
  - .factory/planning/design/engine-adapter-protocol.md
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

# BC-1.13.003: ProfileUnavailable Is Caught and headless-compute Capabilities Continue

## Description

When a `ProfileUnavailable` error is returned for a render-profile capability
(capture), the factory core does NOT stop processing headless-compute capabilities
(build, test, runHeadless, lint, assetsValidate, introspect). Only the render-profile
capability is affected. This is the capability-independence guarantee: render-profile
unavailability has no lateral effect on headless-compute capabilities.

This BC codifies the specific independence guarantee illustrated in the worked
example in `protocol-schema.md §7`: "Meanwhile `test`/`build`/`introspect`
(headless-compute profile) proceed normally."

## Preconditions

1. A `ProfileUnavailable` error has been received for a render-profile capability.
2. One or more headless-compute capabilities are queued or in-flight.

## Postconditions

1. All headless-compute capabilities that were queued continue to execute normally.
2. The `ProfileUnavailable` error has no effect on the success/failure state of
   any headless-compute capability result.
3. The convergence report shows the render-profile capability as degraded AND the
   headless-compute capabilities as their actual status (pass/fail based on their
   own results).

## Invariants

1. The two execution profiles are independent: a failure in one profile never
   propagates to the other.
2. The render profile is the ONLY profile affected by `ProfileUnavailable`; all
   `headless-compute` capabilities are unaffected.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `capture/screenshot` returns ProfileUnavailable; `test` is in-flight | `test` completes normally and returns TestResult; only visual dimension is degraded |
| EC-002 | Both render and headless-compute profiles are unavailable | Separate errors for each; both the render-profile and headless-compute capabilities are CapabilityUnsupported or ProfileUnavailable; convergence report reflects both |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `capture/screenshot` returns ProfileUnavailable; then `test` is called | `test` returns normal TestResult | happy-path |
| `build` called after ProfileUnavailable | `build` returns normal BuildResult | happy-path |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-050 | headless-compute capabilities succeed after ProfileUnavailable is received | integration test: mock adapter returns ProfileUnavailable for capture, then assert build/test succeed |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — execution profile independence is required for the factory to maximize the headless-compute tier even when GPU is unavailable |
| L2 Domain Invariants | DI-001; DI-004 (capabilities are independently fidelity-graded and independently executed) |
| Architecture Module | Factory Core Pipeline Planner (Layer 2) (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.08.002 — depends on (ProfileUnavailable source)
- BC-1.13.002 — sibling (degradation of render dimension)

## Architecture Anchors

- `planning/design/protocol-schema.md#7-worked-example--capability-gap--graceful-degradation`
- `planning/design/engine-adapter-protocol.md#capabilities-the-fixed-surface-every-adapter-implements`
