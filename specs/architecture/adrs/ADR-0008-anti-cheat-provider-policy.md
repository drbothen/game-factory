---
document_type: adr
level: L4
adr_id: "ADR-0008"
version: "1.1"
status: draft
producer: architect
timestamp: 2026-06-09T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0008 — Anti-Cheat Provider Policy: Allowed User-Space Providers; Kernel-Anomaly Providers Rejected

**Status:** Draft
**Date:** 2026-06-09
**Driver:** D-SEC defect F42-02 (anti-cheat-integration-adapter BC absent; D-SEC predicate fail-open); DI-010; R-017

## Context

The factory supports competitive-multiplayer games requiring anti-cheat integration
(SS-11 Genre-Gated Lanes, competitive-MP lane). DI-010 establishes that the factory
never autonomously authors kernel-mode anti-cheat drivers. BC-1.15.002 enforces
this at the factory output level for all generated artifacts.

However, no architectural policy document previously enumerated the allowed vs
rejected anti-cheat providers at the integration level. The `anti-cheat-integrator`
role (studio-of-agents.md role 56, SS-11, Tier 2) was defined with the label
"EAC/EOS wrap-only" but without a formal policy specifying:

- Which user-space providers are accepted
- Which providers are rejected, and why
- The basis for rejection (kernel-anomaly, licensing, post-CrowdStrike security posture)
- How conformance verifies provider compliance

This gap meant the D-SEC convergence dimension's anti-cheat predicate was fail-open:
the moderation-pipeline-contract BC and the anti-cheat-integration-adapter BC were
both absent, referenced only as role labels in the studio-of-agents.md. The gate
did not have a defining BC to evaluate against.

This ADR formalizes the anti-cheat provider policy so that:
1. The BC for `anti-cheat-integration-adapter` conformance (BC-13.02.006, ss-13/,
   authored / active) has an architectural basis in this ADR.
2. The D-SEC predicate can reference a formal provider policy (not just a role label).
3. The policy is auditable and change-controlled.

## Decision

### Allowed User-Space Providers

The factory permits integration with the following anti-cheat providers:

| Provider | Reason Permitted | Integration Mode |
|----------|-----------------|-----------------|
| Easy Anti-Cheat (EAC) | Epic Games SDK; user-mode service; widely adopted; DI-010-compliant | Wrap-only: SDK API calls to user-mode service; no kernel driver authored |
| Epic Online Services (EOS) with EAC | Same SDK ecosystem as EAC; EOS bundles EAC with additional platform services | Wrap-only: as above |
| BattlEye | Commercial user-space offering; deterministic allowable integration path; has a commercial licensing route | Wrap-only: commercial SDK license required; vendor SDK calls only |

These providers expose a user-mode SDK that the factory's integration scaffolding wraps.
The factory does not author the provider's service binary, driver, or kernel component.

### Rejected Providers

The following provider is explicitly rejected:

| Provider | Rejection Reason | Architectural Basis |
|----------|-----------------|---------------------|
| Riot Vanguard | Kernel-anomaly provider: requires a ring-0 kernel driver (vgk.sys) running at all times; not licensable to third-party products (Riot Games ToS); post-CrowdStrike posture classifies always-on ring-0 drivers as unacceptable systemic risk | DI-010 (never autonomously author kernel anti-cheat); R-017 (kernel AC risk); Brief §Out of Scope ("Riot Vanguard not licensable") |

Any provider requiring a ring-0 kernel driver as a mandatory runtime component of
game distribution is classified as a kernel-anomaly provider and is rejected under
this policy, regardless of whether the factory authors the driver or bundles a
vendor-supplied binary.

### Conformance Assertion

The `anti-cheat-integration-adapter` behavioral contract (BC-13.02.006, ss-13/,
authored / active) MUST assert:

1. `anti_cheat_provider` is declared in the project configuration.
2. `anti_cheat_provider` value is a member of the allowed set:
   `{eac, eos, battleye}` (case-insensitive).
3. Any value mapping to a kernel-anomaly provider (currently: `vanguard`,
   `riot-vanguard`, `vgk`) causes the conformance gate to emit error code
   E-ANTICH-001 (registered in error-taxonomy.md) and block integration scaffolding generation.
4. Integration scaffolding produced by the factory contains no ring-0 driver
   compilation targets (verified jointly with BC-1.15.002).

## Rationale

### Why reject Riot Vanguard specifically?

1. **Not licensable.** The product brief §Out of Scope explicitly states Riot
   Vanguard is not licensable to third-party products. Architectural policy
   must be consistent with contractual/licensing reality.

2. **Kernel-anomaly classification.** Post-CrowdStrike (July 2024), the
   security posture of the industry has materially shifted: always-on ring-0
   drivers are recognized as a systemic stability risk. The factory's
   engine-agnostic, no-lock-in thesis is incompatible with depending on a
   non-licensable ring-0 component as a required runtime artifact.

3. **DI-010 consistency.** DI-010 says "Kernel Anti-Cheat Is Never Autonomously
   Authored." Bundling a vendor's ring-0 kernel driver as a factory-produced
   integration artifact would require the factory to produce a binary that
   executes at ring-0 on player machines — which violates the spirit of
   DI-010 even if the driver source is not authored by the factory.

### Why allow BattlEye alongside EAC/EOS?

BattlEye's user-space integration path is well-defined and commercially available.
While BattlEye's backend service also has a kernel component on some platforms,
its integration with game studios follows a standard SDK model where the game
executable loads a user-mode SDK library. The factory wraps this SDK; it does not
author the BattlEye kernel component. This is structurally identical to the EAC
integration model.

### Why wrap-only?

Wrap-only integration means:
- The factory produces a factory-generated integration scaffold that calls
  the provider's user-mode SDK API.
- The provider's service binary, cloud service, and (where applicable) kernel
  component are vendor-supplied and not generated by the factory.
- The factory CI gate (BC-1.15.002) verifies the output bundle contains no
  kernel driver code, regardless of provider.

This approach is consistent with DI-010 and with the five-seam adapter model
(ADR-0004): the anti-cheat provider is treated as an external service with a
declared conformance contract, not an internal component.

## Fidelity Model

Anti-cheat integration fidelity uses the standard adapter fidelity model:

| Fidelity | Meaning |
|----------|---------|
| `full` | Anti-cheat provider SDK wired; integration scaffolding generated; conformance verified |
| `partial` | Anti-cheat provider declared but scaffolding generation not yet complete |
| `none` | No anti-cheat integration (offline/single-player games) |
| `human-gated` | N/A — not applicable (anti-cheat integration does not require a third-party human sign-off in the ADR-0007 sense) |

When `none` (no anti-cheat), the D-SEC anti-cheat predicate degrades gracefully:
the competitive-MP lane is inactive, so the anti-cheat conformance requirement
does not apply.

## Consequences

1. The `anti-cheat-integration-adapter` BC (BC-13.02.006, authored / active)
   uses this ADR as its architectural anchor. This ADR provides the allowed-provider
   set and rejection rationale.

2. The D-SEC convergence dimension pass predicate (methodology-layer.md §D-SEC)
   is updated to reference `anti-cheat-integration-adapter` BC conformance as
   a required signal for competitive-MP targets (alongside the existing
   `server-authority-invariant-suite` and `moderation-pipeline-contract` signals).

3. The error code family E-ANTICH (registered in error-taxonomy.md; BC-13.02.006
   authored / active) covers: provider not in allowed set (E-ANTICH-001), kernel-anomaly
   provider attempted (E-ANTICH-002), provider declaration absent when competitive
   lane is active (E-ANTICH-003).

4. The studio-of-agents.md `anti-cheat-integrator` role (role 56) references this
   ADR as the authoritative provider policy document.

## Alternatives Rejected

- **List only EAC/EOS; exclude BattlEye** — BattlEye has a functional user-mode
  SDK integration model and commercially available licensing. Excluding it without
  cause would unnecessarily restrict competitive-MP game targets that use BattlEye
  as their anti-cheat. The DI-010 concern is satisfied by the wrap-only constraint.

- **Policy-by-capability-declaration only** — Relying solely on `anti_cheat_provider`
  field in adapter manifest without a formal enumerated allowlist would allow
  kernel-anomaly providers to be declared without a gate rejecting them. The
  explicit allowlist and rejection list are necessary for fail-closed behavior.

- **Block all anti-cheat** — Outside the product brief scope. Competitive-MP games
  legitimately require anti-cheat. The factory supports this use case with
  appropriate constraints.

## Change Log

| Version | Change |
|---------|--------|
| 1.0 | Initial authoring. Pass-42 F42-02 architectural basis. BC-13.02.006 authored / active. E-ANTICH error family registered in error-taxonomy.md. |
| 1.1 | Pass-43 F43-01: swept stale "reserved/to author" prose. All references to BC-13.02.006 and E-ANTICH updated to reflect authored/active status. |
