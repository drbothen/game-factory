---
document_type: adr
level: L4
adr_id: "ADR-0004"
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md (§5A)
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/specs/product-brief.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0004 — Four-Seam Adapter Family as Primary Anti-Lock-In Mechanism

**Status:** Draft
**Date:** 2026-06-08
**Driver:** AAA-RECONCILIATION.md §5A; product-brief §Scope §Constraints

## Context

ADR-0001 and ADR-0002 established the engine adapter protocol (one seam). Research
across 22 AAA vectors confirmed the same lock-in problem exists on three additional
orthogonal axes: generative asset backends, store/distribution platforms, and XR
runtimes. Additionally, the Canon Knowledge-Base emerged as a fifth load-bearing seam
(shared lore/entity/timeline RAG anchor). The question is whether each seam requires
a separate design or whether the same adapter pattern applies uniformly.

## Decision

The **same capability-negotiation + fidelity-grading + conformance-suite pattern**
(established for the engine adapter in ADR-0002) is applied uniformly to all four
adapter seams:

| Seam | Lock-in prevented | Fidelity values | Reference targets |
|------|------------------|-----------------|-------------------|
| **engine-adapter** | N engines for one game capability | `full` / `partial` / `none` | Bevy (T1), Unity (T2), Godot (T3); Unreal deferred |
| **asset-adapter** | N generative backends for one asset class | `full` / `partial` / `none`; `backend_class` taxonomy (Tier-1/2/3) | Tripo/Rodin, Stable Audio, ElevenLabs |
| **distribution-adapter** | N store/platform targets for one build | `full` / `partial` / `human-gated` / `none` | steamcmd (VERIFIED), butler (VERIFIED), fastlane (VERIFIED); console cert = `human-gated` |
| **xr-adapter** | N XR runtimes for one XR game | `full` / `partial/vendor` / `human-gated` / `none` | OpenXR 1.1 (Khronos CTS); visionOS = separate non-OpenXR backend |

**Canon-KB** is the fifth load-bearing seam. It is not an adapter seam (no fidelity
grading applies) but is architecturally load-bearing as the shared RAG grounding
anchor. Its integrity constraints are enforced by SS-10.

## Rationale

The capability-negotiation + fidelity-grading + conformance-suite pattern was validated
against the engine seam first (ADR-0002). Applying it uniformly across all seams:

1. **Reduces conceptual surface area.** One pattern to learn; uniform tooling for
   conformance testing across all four seams.
2. **Enables honest degradation across all axes.** The `human-gated` fidelity value
   (ADR-0007) applies identically to console cert, SAG-AFTRA consent, XR
   comfort-cert — all external human acts that have an automatable prefix the
   factory completes and a terminal step the factory cannot automate.
3. **Prevents cross-seam assumption leakage.** A distribution adapter declaring
   `console-cert: human-gated` and an engine adapter declaring `capture: partial`
   both use the same degradation model; the convergence engine (SS-06) reads fidelity
   grades uniformly.
4. **Online-services adapter** (BaaS capability surface: identity/saves/leaderboards/
   matchmaking/entitlements) follows the same pattern with Nakama as the self-hostable
   reference target (CI-testable via Docker-in-CI).

## Consequences

- All four seams require conformance suites. The engine-adapter conformance suite
  (CAP-002) is the P0 reference; asset/distribution/XR conformance suites follow
  the same structure.
- Adding a new backend on any seam = implement adapter + pass conformance for
  declared capabilities. ZERO core changes.
- The XR seam (SS-12) is the only seam where implementation is deferred; the seam
  contract schema is defined now so no core change is needed when implementation begins.
- UGC distribution (mod.io) follows the distribution-adapter pattern as a sibling
  adapter, genre-gated (SS-11).

## Alternatives Rejected

- **Per-seam custom pattern.** Each seam is genuinely different (engine capabilities
  vs asset modalities vs platform CLI tools vs XR runtimes) but the lock-in structure
  is isomorphic; custom patterns would require four separate conformance frameworks
  rather than one parameterized by capability surface.
- **Seam-per-protocol.** gRPC for engine, REST for asset, CLI wrapper for distribution.
  This is implementation detail, not architecture. The seam contract is the protocol-
  independent capability surface; transport is an adapter concern.
