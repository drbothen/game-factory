---
document_type: behavioral-contract
level: L3
id: BC-7.11.008
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1d
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-06
capability: CAP-007
priority: P0
lifecycle_status: active
introduced: v0.1.0-prd-rev-1d
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.11.008: Server-Authority Invariant — Secure Entitlement Verification

## Description

Entitlements (DLC ownership, premium-tier access, cosmetic unlocks, season pass) must
be verified server-side from an authoritative entitlement store before any entitlement-
gated content is served or game-state effect is applied. A client claiming an entitlement
("I own this DLC", "I have premium tier") must never be trusted without server-side
verification. This is a CWE-602 application to entitlement: client-side entitlement
bypasses (modified clients that remove DRM checks) are the most common exploitation
path for paid content.

The entitlement store is the single source of truth: it is populated from the platform's
IAP receipt validation / store SDK (Steam, PSN, Xbox, App Store, etc.) and never from
client-side assertions.

## Preconditions

1. Game declares any entitlement-gated content in its profile (`entitlements: [...]`).
2. `server-authority-spec.entitlement_store` is declared, specifying the backend
   verification source for each entitlement type.
3. Server has access to the platform SDK receipt verification endpoint.

## Postconditions

1. **PASS:** Every entitlement-gated content access is preceded by a server-side
   entitlement lookup in the authoritative entitlement store. Client assertion of
   entitlement is never used as the access gate.
2. **FAIL — trust-client entitlement:** A client asserts entitlement ownership (e.g.,
   client sends `{dlc_id: "expansion_01", owned: true}`) and the server grants access
   without verifying against the entitlement store. Error: `E-CONV-006` `CWE-602:
   entitlement trust-client — '<entitlement_id>' granted without server-side verification`.
3. **FAIL — entitlement store unreachable (degraded mode):** Entitlement store is
   temporarily unavailable. Behavior is declared in `server-authority-spec.entitlement_
   fallback` — must be one of `{deny_access, cached_with_ttl, human_gated_override}`.
   The default is `deny_access` (fail-closed). Fail-open is a BLOCKED configuration.
4. **OFFLINE EXEMPTION:** No entitlement-gated content or fully offline game. INAPPLICABLE.

## Invariants

1. Entitlement store queries are server-initiated, not client-triggered.
2. The entitlement store is populated by platform SDK receipt validation — never by
   client-supplied purchase receipts processed without platform verification.
3. Fail-closed is the default entitlement-store-unavailability behavior. A configuration
   declaring `entitlement_fallback: open` (fail-open) is a BLOCKED configuration.
4. Cached entitlement TTL must be declared in the spec. Indefinitely-cached entitlements
   are treated as a verification gap and flagged for adversarial review.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Player purchases DLC on Steam; receipt validated by Steam SDK on server | PASS: entitlement granted from Steam's authoritative receipt |
| EC-002 | Modified client removes DRM check and sends `dlc_owned: true` in client request | FAIL: server does not use client assertion; entitlement store says `false`; access denied |
| EC-003 | Entitlement store temporarily unavailable; `fallback: deny_access` declared | Access denied with a user-facing message; fail-closed; incident logged |
| EC-004 | Entitlement store temporarily unavailable; `fallback: open` declared in spec | BLOCKED: fail-open configuration is not a valid spec value; spec fails validation |
| EC-005 | Free content; no entitlement gate | PASS: no entitlement verification needed for non-gated content |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Server verifies DLC from Steam receipt; entitlement present | PASS: access granted | happy-path |
| Client asserts `dlc_owned: true`; server grants without store check | FAIL: E-CONV-006 entitlement trust-client | error |
| Entitlement store unavailable; fallback = deny | Access denied; fail-closed | degraded |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-208 | Any entitlement-gated access that bypasses entitlement store lookup is detected as a trust-client violation | Integration test: intercept entitlement query call; simulate client assertion path; assert E-CONV-006 fired |
| VP-TBD-209 | Entitlement store unavailability always triggers deny_access when fallback = deny_access | Integration test: kill entitlement store mock; assert access denied for gated content |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — specifies the secure entitlement verification invariant of the `server-authority-invariant-suite` for D-SEC evaluation. |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced, not dropped — entitlement override requires human gate), DI-012 |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — evaluated by D-SEC dimension
- BC-7.11.002 — sibling (no-trust-client is the fundamental invariant; this BC applies it to entitlement)
- BC-7.11.004 — composes with (replay-attack prevention applies to purchase events that create entitlements)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-208, VP-TBD-209
