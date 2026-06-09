---
document_type: adr
level: L4
adr_id: "ADR-0004"
version: "1.3"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md (§5A)
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/specs/product-brief.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0004 — Five-Seam Adapter Family as Primary Anti-Lock-In Mechanism

> **v1.3 — Pass-34 adversarial finding F34-04 (stale four-seam world in §Context and §Alternatives).**
> - **§Context:** Added online-services to the enumerated axes so the narrative
>   now matches the §Decision five-seam table. Previously said "three additional
>   orthogonal axes: generative asset backends, store/distribution platforms, and
>   XR runtimes" — omitting online-services. Now says "four additional orthogonal
>   axes: generative asset backends, store/distribution platforms, XR runtimes,
>   and online-services."
> - **§Alternatives Rejected:** "four separate conformance frameworks" corrected
>   to "five separate conformance frameworks" to match the five-seam model.
>
> **v1.2 — Pass-14 adversarial defect O14-02 (Canon-KB seam ordinal fix).**
> §Context incorrectly called Canon-KB "a fifth load-bearing seam" when there are five
> adapter seams (engine, asset, distribution, xr, online-services) making Canon-KB the
> sixth load-bearing seam. Corrected "fifth" → "sixth" at line ~39. The §Decision and
> §Consequences already correctly state "sixth load-bearing seam" (lines ~57-58, ~103);
> the §Context sentence was the only straggler.
>
> **v1.1 — Pass-13 adversarial defect C13-01 (five-seam reconciliation).**
> The previous title and body §Consequences were inconsistent: the title said
> "Four-Seam" but §Rationale bullet 4 already enumerated the online-services
> adapter as a fifth adapter seam, and the product brief §Overflow Context
> (Tier 1 — v1 ship prerequisite) lists `online-services adapter` as always-on.
> Reconciled: title updated to "Five-Seam"; §Decision table and §Consequences
> now explicitly enumerate the online-services seam (SS-13). Canon-KB
> distinction (load-bearing RAG seam, NOT an adapter seam) is preserved.

**Status:** Draft
**Date:** 2026-06-08
**Driver:** AAA-RECONCILIATION.md §5A; product-brief §Scope §Constraints

## Context

ADR-0001 and ADR-0002 established the engine adapter protocol (one seam). Research
across 22 AAA vectors confirmed the same lock-in problem exists on four additional
orthogonal axes: generative asset backends, store/distribution platforms, XR runtimes,
and online-services (BaaS capability surface: identity/saves/leaderboards/matchmaking/
entitlements). Additionally, the Canon Knowledge-Base emerged as a sixth load-bearing
seam (shared lore/entity/timeline RAG anchor). The question is whether each seam
requires a separate design or whether the same adapter pattern applies uniformly.

## Decision

The **same capability-negotiation + fidelity-grading + conformance-suite pattern**
(established for the engine adapter in ADR-0002) is applied uniformly to all five
adapter seams:

| Seam | Lock-in prevented | Fidelity values | Reference targets | Subsystem |
|------|------------------|-----------------|-------------------|-----------|
| **engine-adapter** | N engines for one game capability | `full` / `partial` / `none` | Bevy (T1), Unity (T2), Godot (T3); Unreal deferred | SS-01 |
| **asset-adapter** | N generative backends for one asset class | `full` / `partial` / `none`; `backend_class` taxonomy (Tier-1/2/3) | Tripo/Rodin, Stable Audio, ElevenLabs | SS-03 |
| **distribution-adapter** | N store/platform targets for one build | `full` / `partial` / `human-gated` / `none` | steamcmd (VERIFIED), butler (VERIFIED), fastlane (VERIFIED); console cert = `human-gated` | SS-08 |
| **xr-adapter** | N XR runtimes for one XR game | `full` / `partial/vendor` / `human-gated` / `none` | OpenXR 1.1 (Khronos CTS); visionOS = separate non-OpenXR backend | SS-12 |
| **online-services-adapter** | N BaaS backends for one online-services surface | `full` / `partial` / `human-gated` / `none` | Nakama (self-hostable Docker-in-CI reference); EOS, PlayFab as alternatives | SS-13 |

**Seam vs. load-bearing distinction.** The five entries above are adapter seams
(fidelity-graded, conformance-tested). **Canon-KB** is a sixth load-bearing seam
but is NOT an adapter seam — no fidelity grading applies; it is the shared RAG
grounding anchor. Its integrity constraints are enforced by SS-10. The term
"adapter seam" refers exclusively to the five rows above.

## Rationale

The capability-negotiation + fidelity-grading + conformance-suite pattern was validated
against the engine seam first (ADR-0002). Applying it uniformly across all five adapter
seams:

1. **Reduces conceptual surface area.** One pattern to learn; uniform tooling for
   conformance testing across all five seams.
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
   reference target (CI-testable via Docker-in-CI). This seam is Tier-1 (v1 ship
   prerequisite per product brief §Overflow Context §Tier 1 list). It is owned by
   SS-13 (Online-Services Adapter); see CAP-015.
5. **Anti-lock-in property is self-sealing across all five axes.** Adding a new BaaS
   backend (e.g., EOS) requires only: implement online-services adapter + pass
   online-services conformance suite. ZERO core changes.

## Consequences

- All five adapter seams require conformance suites. The engine-adapter conformance suite
  (CAP-002) is the P0 reference; asset/distribution/online-services/XR conformance
  suites follow the same five-part structure (§1.7 of adapter-protocols.md).
- Adding a new backend on any seam = implement adapter + pass conformance for
  declared capabilities. ZERO core changes.
- The XR seam (SS-12) is the only seam where implementation is deferred; the seam
  contract schema is defined now so no core change is needed when implementation begins.
- The online-services seam (SS-13) is Tier-1 (always-on, v1 ship prerequisite). Its
  reference implementation target is Nakama (self-hostable; Docker-in-CI feasible).
  No vendor lock-in: EOS, PlayFab, and custom BaaS implementations follow the same
  conformance path.
- UGC distribution (mod.io) follows the distribution-adapter pattern as a sibling
  adapter, genre-gated (SS-11).
- The Canon-KB (sixth load-bearing seam, NOT an adapter seam) is not affected by
  this ADR; its integrity constraints remain in SS-10.

## Alternatives Rejected

- **Per-seam custom pattern.** Each seam is genuinely different (engine capabilities
  vs asset modalities vs platform CLI tools vs XR runtimes vs online-services BaaS)
  but the lock-in structure is isomorphic; custom patterns would require five separate
  conformance frameworks rather than one parameterized by capability surface.
- **Seam-per-protocol.** gRPC for engine, REST for asset, CLI wrapper for distribution.
  This is implementation detail, not architecture. The seam contract is the protocol-
  independent capability surface; transport is an adapter concern.
