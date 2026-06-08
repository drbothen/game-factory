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

# BC-1.13.002: Core Degrades Convergence Dimension on CapabilityUnsupported Without Pipeline Failure

## Description

When the factory core receives a `CapabilityUnsupported` error from an adapter,
it degrades the affected convergence dimension to its declared fallback state —
it does NOT fail the pipeline. The degradation is logged, recorded in the
convergence report, and surfaced to the producer as a dimension that requires
manual evidence or human gate. This is the core-side implementation of the
declare-and-degrade pattern: the protocol is honest about what it cannot automate.

This BC covers the canonical example from `protocol-schema.md §7`: Godot adapter
on a CI runner with no xvfb returns `ProfileUnavailable` → core degrades visual
convergence dimension to "manual evidence required" → build/test/introspect continue.

## Preconditions

1. The factory core has received a `CapabilityUnsupported` (`-32001`) or
   `ProfileUnavailable` (`-32002`) error from an adapter.
2. The core has a convergence dimension associated with the failed capability.
3. The production pipeline is in progress.

## Postconditions

1. The pipeline does NOT halt or fail due to the error.
2. The convergence dimension associated with the capability is set to
   `status: "degraded"` with:
   - `reason`: human-readable string explaining why the dimension degraded
   - `fallback`: the fallback method declared for this dimension (e.g.,
     `"manual playtest evidence"`, `"human visual review"`, `"N/A for this engine"`)
3. A `$/log` notification (or equivalent pipeline log entry) records:
   - Which capability was unavailable
   - Which convergence dimension was affected
   - What the fallback is
4. All other capabilities (unaffected by this error) continue to function normally.
5. The convergence report includes the degraded dimension with its fallback status.

## Invariants

1. `CapabilityUnsupported` NEVER causes an unhandled exception or pipeline halt in
   the core.
2. A degraded dimension is always visible in the convergence report; it is never
   silently omitted.
3. The fallback for a `none`-fidelity capability is determined by the capability's
   role in the convergence model (specified in the factory's convergence dimension
   mapping table, a Layer-2 concern).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | All 8 capabilities are `none` on an adapter | All relevant convergence dimensions are degraded; the pipeline produces a convergence report noting full degradation; no crash |
| EC-002 | `build` capability is `none` | Build convergence dimension blocked (cannot produce a game artifact); this is a terminal degradation — the pipeline cannot proceed past the build stage, but the error is reported cleanly |
| EC-003 | `capture` is `none` but `test` and `build` are `full` | Only visual/capture convergence dimension degrades; test and build proceed normally |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `capture` returns ProfileUnavailable | Convergence dimension `visual` set to `{ status: "degraded", reason: "render profile unavailable", fallback: "manual visual review" }`; build/test continue | happy-path |
| `introspect` returns CapabilityUnsupported | Convergence dimension `scene-validation` set to degraded; other capabilities continue | happy-path |
| `build` returns CapabilityUnsupported | Convergence dimension `build` set to `{ status: "blocked" }`; pipeline cleanly reports the block | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-048 | CapabilityUnsupported never causes pipeline halt | integration test: configure adapter with all none, run pipeline, assert clean convergence report |
| VP-TBD-049 | Degraded dimension is always present in convergence report | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — core-side graceful degradation is the implementation of the "declare-and-degrade" principle central to the engine-agnostic design |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced not dropped — degraded dimensions surface fallback requirements); DI-001 |
| Architecture Module | Factory Core Pipeline Planner (Layer 2) (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.13.001 — depends on (CapabilityUnsupported is the trigger)
- BC-1.13.003 — sibling (headless-compute continues after ProfileUnavailable)
- BC-1.08.002 — depends on (ProfileUnavailable is a specific source of this degradation)

## Architecture Anchors

- `planning/design/engine-adapter-protocol.md#7-worked-example--capability-gap--graceful-degradation`
