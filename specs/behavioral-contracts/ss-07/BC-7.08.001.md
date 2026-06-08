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
subsystem: SS-TBD
capability: CAP-007
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

# BC-7.08.001: Provenance/Legal and Compliance Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #8:
provenance/legal + compliance. This dimension combines asset provenance sidecar
completeness (DI-003), EU AI Act Art. 50 / C2PA mark generation,
`compliance-checklist` auto-fill, `privacy-config-contract` presence, and
`ai-disclosure-manifest` generation. Human-gated items include SAG-AFTRA consent
signatures, legal-doc attorney review, and ratings submission. The EU AI Act Art. 50
hard deadline is 2026-08-02. Missing compliance artifacts before this date are BLOCKED
for any game shipping after that date.

## Preconditions

1. All generated assets have `asset-provenance-sidecar` with `disclosure_class`.
2. The `compliance-checklist` generation pipeline is operational (auto-fills
   IARC objective questions from game metadata).
3. The `ai-disclosure-manifest` generation pipeline is operational (projects from
   provenance sidecars; adds C2PA Content Credentials marks per EU AI Act Art. 50).
4. The `privacy-config-contract` exists with per-SDK COPPA consent flags
   (FTC COPPA 2025 amendment, compliance date 22 Apr 2026).
5. For voice/likeness assets: `likeness_consent_ref` fields are populated where
   applicable.

## Postconditions

1. **GREEN (schema):** All provenance sidecars present and schema-valid with
   `disclosure_class`. `ai-disclosure-manifest` generated. `compliance-checklist`
   auto-filled for all objective items. `privacy-config-contract` present.
   `legal-doc-set` templates generated.
2. **GREEN (full):** Schema GREEN + all human-gated items complete:
   SAG-AFTRA consent signatures obtained for applicable assets, legal-doc attorney
   review signed off, ratings submission manifest reviewed and submitted.
3. **DEGRADED (human-gated pending):** Schema checks GREEN; human-gated items
   (consent signatures, attorney review, ratings submission) pending. The factory
   has completed all automatable work; `human-gated` task lists are emitted.
4. **BLOCKED:** Any provenance sidecar missing `disclosure_class` (DI-003).
   `ai-disclosure-manifest` not generated. `compliance-checklist` gaps in
   objective items. `privacy-config-contract` missing per-ad-SDK COPPA flags.
5. **Time-gated BLOCKED:** For games shipping on or after 2026-08-02:
   EU AI Act Art. 50 C2PA marks must be embedded in the `ai-disclosure-manifest`.
   Missing C2PA marks for post-deadline shipping = BLOCKED.

## Invariants

1. Zero assets without `disclosure_class` — DI-003 is a hard invariant.
2. EU AI Act Art. 50 C2PA marks are required for any game shipping after 2026-08-02
   that contains AI-generated content. No degradation.
3. FTC COPPA 2025 per-ad-SDK consent flags required if any ad SDKs are present
   and the game may have children users (compliance date 22 Apr 2026 — already
   past; must be current for any new build).
4. Human-gated items are surfaced not suppressed (DI-006).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game shipping 2026-07-01 (before EU AI Act date) | C2PA marks recommended but not yet required; DEGRADED-advisory for pre-deadline; BLOCKED if shipping post-deadline with same build |
| EC-002 | Voice asset with `likeness_consent_ref` = null (no named performer) | Schema valid; no SAG-AFTRA gate triggered; PASS for this field |
| EC-003 | `legal-doc-set` templates generated but attorney review not scheduled | DEGRADED-PENDING; human-gated task emitted: "Schedule attorney review of EULA/Privacy Policy before ship" |
| EC-004 | IARC content-intensity question (not auto-fillable) in compliance-checklist | Item marked as human-judgment-required; `human-gated` task emitted; not a BLOCKED state |
| EC-005 | `privacy-config-contract` missing COPPA flag for a declared ad SDK | BLOCKED; each ad SDK must have an explicit COPPA consent flag per FTC 2025 amendment |
| EC-006 | NFT mechanics declared in `content-descriptor-contract` | PEGI 18 minimum-rating flag triggered; `compliance-checklist` updated; DI-011 policy check run |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| All sidecars complete; AI manifest generated; no voice likeness; legal pending | provenance/legal = DEGRADED-PENDING (attorney review pending) | happy-path |
| One sidecar missing `disclosure_class` | provenance/legal = BLOCKED; DI-003 violation | error |
| Game shipping post-2026-08-02; no C2PA marks in ai-disclosure-manifest | provenance/legal = BLOCKED; "EU AI Act Art. 50 C2PA marks required" | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-027 | Missing `disclosure_class` on any asset always maps to BLOCKED | kani (provenance scan: any null disclosure_class → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #8 (provenance/legal + compliance) |
| L2 Domain Invariants | DI-003 (every generated asset has complete provenance sidecar), DI-006 (human-gated tasks surfaced), DI-012 |
| Architecture Module | convergence-tracker / provenance-compliance-gate (SS-TBD) |
| Stories | S-TBD |

## Related BCs

- BC-7.04.001 — related to (asset-completeness also checks provenance sidecar completeness; the two dims share data)
- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-TBD-convergence-tracker.md`

## Story Anchor

S-TBD — Provenance/Legal and Compliance Convergence Dimension
