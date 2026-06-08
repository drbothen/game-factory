---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 9
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MEDIUM
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 2 important, 4 LOW observations"
---

# Phase-1d Adversarial Review — Pass 9

**Verdict:** FINDINGS (0 critical, 2 important, 4 LOW observations)
**Novelty:** MEDIUM — both important findings are in the consumer-side cross-BC field-vocabulary class (same class as Pass-8 F8-01; new instances, not recurrences of F8-01 itself). The process-gap is identical: consumer BCs and CI can drift from producer and methodology-layer without a usage-site anchor check.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. Pass-9 is candidate clean #1 on the corrected spec (post-Pass-8 fixes). Both importants resolved; counter does not advance. Next = Pass 10 (candidate clean #1).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) → FINDINGS (0/3)

---

## Pass-8 Fix Re-Verification

All Pass-8 fixes confirmed clean:

- F8-01 `disclosure_class` enum contradiction: BC-10.05.001 v1.1 routes all three canonical values correctly; `dev-tool-only` absent; CI check (l) GREEN.
- O8-01 `asset_type` → `eu_scope_category`: field label correct with projection mapping; canonical `asset_class` in adapter-protocols.md unchanged.
- O8-02 DI-012/CWE-602 anchor note: present in BC-7.11.002 and BC-7.11.007 v1.1.
- CI gate v1.6 check (l) passes on full BC corpus: 0 non-canonical `disclosure_class` values.

---

## Findings

### I-1 — IMPORTANT: E-COMP-010 Semantic Overload in BC-10.05.001 INV-3 / VP-COMP-017

**Location:** `ss-10/BC-10.05.001.md` (consumer-side compliance manifest aggregation)
**Severity:** IMPORTANT
**Blocking:** Yes — must resolve before counter can advance
**Novel (not previously raised):** Yes

**Description:**

The Pass-8 fix introduced a subtle semantic overload. BC-10.05.001 now uses E-COMP-010 for two structurally different fault conditions:

1. **Missing required field** — the provenance sidecar lacks the `disclosure_class` field entirely. This is the original intent of E-COMP-010 in error-taxonomy.md: "required field absent from asset provenance sidecar".
2. **Out-of-vocabulary value** — the provenance sidecar includes a `disclosure_class` field, but its value is not a member of the canonical closed enum `{pre-generated, live-generated, procedural-exempt}`. This was introduced in the Pass-8 fix to handle the `dev-tool-only` → rejection path.

These are semantically distinct faults: (1) indicates a sidecar authoring defect; (2) indicates a vocabulary divergence defect. Sharing the same error code conflates them in downstream tooling (error logs, compliance dashboards, audit trails), violating the error-taxonomy principle of one-fault-per-code.

**Risk:** Compliance manifest tooling that routes on E-COMP-010 cannot distinguish "field missing" from "field present but illegal value" without re-inspecting the payload. For regulatory audit (EU AI Act Art.50 enforcement) this distinction is material: one is a production pipeline defect, the other is a vocabulary synchronization defect with different remediation owners.

**Resolution:** RESOLVED

- Registered a new, distinct error code **E-COMP-011** in error-taxonomy.md: "disclosure_class value out-of-vocabulary at manifest aggregation — sidecar field present but value not in canonical closed enum `{pre-generated, live-generated, procedural-exempt}`; fault class: vocabulary-divergence; owner: compliance-agent / asset-pipeline; remediation: resync sidecar authoring tool to canonical enum in BC-4.03.002".
- Updated **BC-10.05.001** (now **v1.2**): INV-3 now routes to `E-COMP-010 / BLOCKED` for missing-field and `E-COMP-011 / BLOCKED` for out-of-vocabulary value. VP-COMP-017 precondition table updated to cite both codes with distinct fault labels.
- **E-COMP-010** definition in error-taxonomy.md left unchanged — it retains its original "required field absent" semantics.
- error-taxonomy.md updated to **v1.7** (198 total codes / 30 families; 189 active + 9 retired E-GEN).

---

### I-2 — IMPORTANT (regulatory): NFT-Flag Seam Creates Under-Rated IARC Submission Path

**Location:** `ss-13/BC-13.01.004.md` (NFT/Web3 off-by-default) and `ss-10/BC-10.01.001.md` (IARC questionnaire submission)
**Severity:** IMPORTANT
**Blocking:** Yes — must resolve before counter can advance
**Novel (not previously raised):** Yes — the individual BCs were reviewed in prior passes; this finding concerns the cross-BC semantic seam between them

**Description:**

A logical seam exists between the two NFT-related flags in the schema:

- `nft_mechanics` — governs whether NFT/Web3 mechanics are present in gameplay (BC-13.01.004 enforcement key)
- `nft_blockchain` — governs whether blockchain/NFT is listed in the store distribution manifest (BC-10.01.001 PEGI-18 trigger key)

The problem: BC-10.01.001 (IARC questionnaire submission) triggers PEGI-18 content advisory **only** if `nft_blockchain: true`. BC-13.01.004 separately enforces the "off by default" rule for `nft_mechanics`, but does not feed any signal into the IARC questionnaire path.

This creates a coverage gap: a project that sets `nft_mechanics: true` (unlocking NFT gameplay features) but leaves `nft_blockchain: false` (perhaps deploying NFTs on a chain not recognized as "blockchain" in the store metadata) would pass BC-13.01.004's default-off check but would **not** trigger the PEGI-18 advisory path in BC-10.01.001. IARC submissions under such a configuration would be under-rated — a regulatory defect.

**Risk:** Under-rated IARC submission for games with NFT mechanics. Regulatory non-compliance with PEGI-18 advisory requirements in jurisdictions that treat NFT/blockchain content uniformly. This is a P0 regulatory gap (D-008; CAP-011).

**Resolution:** RESOLVED

- **BC-10.01.001** updated to **v1.1**:
  - Added Precondition 4: "Read genre-profile NFT flags: both `nft_blockchain` and `nft_mechanics` inputs are consumed by this BC."
  - Added Behavior step 4: cross-field consistency check — if `nft_blockchain != nft_mechanics`, emit `E-COMP-012` ("NFT flag divergence: nft_blockchain and nft_mechanics must both be true or both false; divergent state indicates schema authoring inconsistency") and set `status: auto_filled_partial_with_warnings`.
  - Updated INV-2: PEGI-18 advisory applies if EITHER `nft_blockchain: true` OR `nft_mechanics: true` (fail-closed). Previously INV-2 keyed only on `nft_blockchain`.
  - `NFT_PEGI18_OVERRIDE` signal is always present in the output record when any NFT flag is active (either or both true).

- **BC-13.01.004** updated to **v1.1**:
  - Added Postcondition note: "When `nft_mechanics: true` is activated, consumers of the project schema MUST also set `nft_blockchain: true` to keep IARC PEGI-18 advisory path coherent. This BC does not enforce the consistency constraint — BC-10.01.001 INV-2 / step 4 enforce it. Cross-reference: BC-10.01.001."

- **error-taxonomy.md** updated to **v1.7**: registered **E-COMP-012** ("NFT flag divergence at IARC questionnaire submission — `nft_blockchain` and `nft_mechanics` are in inconsistent state; fault class: schema-authoring; owner: product-owner / compliance-agent; remediation: align both flags to match project NFT posture").

- New error code total: **198 codes / 30 families** (189 active + 9 retired E-GEN).

---

### O-1 — LOW: `eu_scope_category` JSON Comment Omitted `3d-mesh` Value

**Location:** `ss-10/BC-10.05.001.md` schema description
**Severity:** LOW (observation)
**Blocking:** No

**Description:**

The `eu_scope_category` schema description comment listed the allowed values as `image | audio | video | text` — omitting `3d-mesh`. The `3d-mesh` asset class is a valid `asset_class` projection from adapter-protocols.md and requires its own EU AI Act Art.50 disclosure handling (3D generative models are within Art.50 scope for visual AI-generated content in games).

**Resolution:** RESOLVED — added `3d-mesh` to the `eu_scope_category` allowed-values comment in BC-10.05.001 v1.2.

---

### O-2 — LOW (process-gap): Convergence-Dimension Field Names Under-Specified

**Location:** `methodology-layer.md`, `ss-09/BC-9.04.001.md`, `ss-09/BC-9.06.001.md`, `ss-09/BC-9.06.002.md`
**Severity:** LOW (observation — but surfaced a real contradiction in BC field names)
**Blocking:** No on its own; however the contradiction uncovered below is significant

**Description:**

The methodology-layer.md documented 11 convergence dimensions (D-SIM through D-CERT/D-DIST) but did not provide a canonical table of field names for use in convergence-report JSON payloads. This under-specification had already been exploited: three BCs in SS-09 used the non-canonical field name `dimensions.distribution_readiness` to refer to what the methodology-layer intended as the combined D-CERT (Cert-Preflight) + D-DIST (Distribution-Readiness) dimension.

The D-CERT and D-DIST dimensions were listed as separate dimensions in the methodology-layer dimension list, but the 11-count was maintained by merging them into a single convergence-report field `dimensions.cert_preflight`. This naming was never explicitly documented — it was implicit in the architecture, leading the BCs to invent `distribution_readiness` as a plausible but incorrect alternative.

**Resolution:** RESOLVED

- **methodology-layer.md** updated to **v1.3**: added **§3.0 Canonical Convergence-Report Dimension Field Name Registry** — a table with 11 rows, one per dimension, columns: Dimension ID | Dimension Title | `field_name` | Derivation | Owner BC.
  - Canonical field name for the D-CERT/D-DIST combined dimension: `dimensions.cert_preflight` (Cert-Preflight + Distribution-Readiness; dual-owned by BC-9.04.001 and BC-9.06.001/002).
  - All 11 canonical field names are distinct (uniqueness invariant documented in §3.0).
  - Count invariant: exactly 11 entries, each mapping to a unique field name.

- **BC-9.04.001** updated to **v1.1**: renamed `dimensions.distribution_readiness` → `dimensions.cert_preflight` throughout.
- **BC-9.06.001** updated to **v1.1**: renamed `dimensions.distribution_readiness` → `dimensions.cert_preflight` throughout.
- **BC-9.06.002** updated to **v1.1**: renamed `dimensions.distribution_readiness` → `dimensions.cert_preflight` throughout.

- **CI gate** extended to **v1.8** (check m, both sub-assertions):
  - **(m.i)** Parses §3.0 table from methodology-layer.md; asserts field count = 11 and all names unique.
  - **(m.ii)** Scans all BC bodies for `convergence[-_]report.dimensions.<field>`, `` `dimensions.<field>` ``, and whitespace-prefixed `.dimensions.<field>` tokens; asserts every `<field>` is in the canonical set. Directly prevents the O-2 usage-site class. `scripts/check-spec-counts.sh` updated to v1.8.

- **ARCH-INDEX.md** updated: methodology-layer reference updated to v1.3.

---

### O-3 — LOW: Determinism Tier Annotation Consistency

**Location:** Various BCs in SS-06, SS-09
**Severity:** LOW (observation)
**Blocking:** No

**Description:**

Spot-checked determinism tier annotations across SS-06 (simulation fidelity) and SS-09 (ethics/dark-pattern) BCs against the D-003 tier definitions (T1: bit-exact replay, T2: behavioral equivalent, T3: non-deterministic). All annotations found consistent with D-003. No violations detected.

**Resolution:** N/A — verified clean.

---

### O-4 — LOW: `disclosure_class` Chained-Routing Chain Completeness

**Location:** `ss-10/BC-10.05.001.md` post-Pass-8 / post-I-1-fix state
**Severity:** LOW (observation)
**Blocking:** No

**Description:**

Re-verified the full disclosure_class routing chain after I-1 fix: `pre-generated` → disclosure line emitted; `live-generated` → disclosure line emitted; `procedural-exempt` → exempt path, no disclosure line; field absent → E-COMP-010 / BLOCKED; out-of-vocabulary → E-COMP-011 / BLOCKED. All five branches present and exhaustive. DI coverage for remaining BCs also spot-checked — no gaps.

**Resolution:** N/A — verified clean.

---

## New Error Codes This Pass

| Code | Family | Description | Status |
|------|--------|-------------|--------|
| E-COMP-011 | E-COMP | disclosure_class value out-of-vocabulary at manifest aggregation | active |
| E-COMP-012 | E-COMP | NFT flag divergence: nft_blockchain / nft_mechanics inconsistent state | active |

**Error code total after Pass 9:** 198 codes / 30 families (189 active + 9 retired E-GEN)
(Prior: 196 codes / 30 families / 187 active — +2 this pass)

---

## Spec State After Pass-9 Fixes

| Document | Version After Pass 9 |
|----------|----------------------|
| `prd-supplements/error-taxonomy.md` | v1.7 (198 codes / 30 families / 189 active) |
| `ss-10/BC-10.05.001.md` | v1.2 |
| `ss-10/BC-10.01.001.md` | v1.1 |
| `ss-13/BC-13.01.004.md` | v1.1 |
| `specs/architecture/methodology-layer.md` | v1.3 (+§3.0 canonical dimension field table) |
| `specs/architecture/ARCH-INDEX.md` | updated (methodology-layer ref v1.3) |
| `ss-09/BC-9.04.001.md` | v1.1 |
| `ss-09/BC-9.06.001.md` | v1.1 |
| `ss-09/BC-9.06.002.md` | v1.1 |
| `scripts/check-spec-counts.sh` | v1.8 (checks a–m, 14 sub-assertions incl. m.i uniqueness + m.ii BC usage-site) |

All other spec files unchanged from Pass-8 state.

---

## Verification Footer

`check-spec-counts.sh v1.8` ALL CHECKS PASSED (a–m including m.i uniqueness + m.ii BC usage-site), exit 0.
BC count: 178. Error codes: 198. Priority: P0=117 / P1=39 / P2=22.
`disclosure_class` canonical enum: GREEN (0 non-canonical values). Dimension field names: 11 unique. BC usage-site non-canonical references: 0.

---

## Summary

| Dimension | Result |
|-----------|--------|
| Critical findings | 0 |
| Important findings | 2 (I-1: E-COMP-010 semantic overload → E-COMP-011 registered; I-2: NFT→PEGI-18 seam fail-closed → E-COMP-012 registered; BOTH RESOLVED) |
| LOW observations | 4 (O-1: eu_scope_category 3d-mesh; O-2: dimension field canonicalization + BCs renamed; O-3: determinism tiers CLEAN; O-4: disclosure_class chain CLEAN) |
| Blocking issues | 0 (all findings resolved) |
| Clean-pass counter | **STAYS 0/3** (findings were present; counter does not advance despite full resolution — must achieve clean pass with 0 important findings to increment) |
| Spec stability | CHANGED — 9 spec files updated; CI gate v1.8 |
| Next action | Pass 10 (candidate clean #1) |
