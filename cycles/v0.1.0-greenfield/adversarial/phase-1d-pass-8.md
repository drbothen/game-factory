---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 8
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MEDIUM
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 1 important, 2 LOW observations"
---

# Phase-1d Adversarial Review — Pass 8

**Verdict:** FINDINGS (0 critical, 1 important, 2 LOW observations)
**Novelty:** MEDIUM — one genuine new axis (consumer-side closed-enum vocabulary drift undetectable by producer-side CI)
**Convergence status:** CONSECUTIVE-CLEAN COUNTER RESET — Pass 7 was clean (counter had reached 1/3); Pass 8 probed the ss-10 compliance corner and found a genuine consumer-side closed-enum contradiction. Counter resets to 0/3. Next = Pass 9 (candidate clean #1).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset)

---

## Pass-7 Fix Re-Verification

Pass 7 was CLEAN — no fixes to re-verify. The spec was stable through that pass.
Pass-7 clean status is now historical: spec changed in Pass 8 (BC-10.05.001 v1.1,
BC-13.04.001 v1.2, BC-7.11.002/007 v1.1), so the consecutive-clean counter restarts.

---

## Findings

### F8-01 — IMPORTANT: `disclosure_class` Closed-Enum Contradiction (Consumer vs. Producer)

**Location:** `ss-10/BC-10.05.001.md` (consumer); canonical source `ss-04/BC-4.03.002.md` (producer)
**Severity:** IMPORTANT
**Blocking:** Yes — must resolve before counter can advance
**Novel (not previously raised):** Yes

**Description:**

The producer BC (BC-4.03.002) declares a closed enum for `disclosure_class`:
`{pre-generated, live-generated, procedural-exempt}` — enforced by E-PRV-011 which
rejects any out-of-vocabulary value. The consumer BC (BC-10.05.001) contained two
violations:

1. Used `dev-tool-only` — a non-canonical value. This was a research-source
   transcription error: copilot/code-generation tools never enter the asset pipeline
   and have no provenance sidecar; they cannot produce a `disclosure_class` value.
   `dev-tool-only` is therefore both non-canonical and semantically incoherent in an
   EU AI Act Art.50 disclosure manifest context.

2. Omitted `procedural-exempt` from its invariant / exception-condition routing,
   meaning assets whose sidecar carries `disclosure_class: procedural-exempt` would
   be silently misclassified at the Art.50 compliance manifest step.

**Risk:** Silent misclassification in EU AI Act Art.50 disclosure manifest. A
`procedural-exempt` asset (e.g., procedurally-generated terrain) would either be
incorrectly flagged as requiring disclosure or dropped from routing with no error.
Neither outcome is acceptable for P0 regulatory compliance (CAP-011 / D-008).

**Resolution:** RESOLVED

- `dev-tool-only` replaced with `procedural-exempt` throughout BC-10.05.001.
- INV-3 and EC-001 now route all three canonical values explicitly:
  `pre-generated` → disclosure line emitted; `live-generated` → disclosure line emitted;
  `procedural-exempt` → exempt path, no disclosure line required.
- Out-of-vocabulary value → `E-COMP-010 / BLOCKED` (enforcement consistent with
  producer E-PRV-011 rejection policy).
- `BC-10.05.001` updated to **v1.1**.

Sweep also caught `BC-13.04.001` using informal `ai_generated` instead of canonical
`disclosure_class` vocab in a summary note:
- Replaced with canonical `ai-disclosure` reference (the field label, not a
  disclosure_class value token); `BC-13.04.001` updated to **v1.2**.

**Process-gap remediation:** Producer-side CI (check a–k) could not see consumer-side
enum vocabulary because it only validated registered error codes and BC structure —
it had no cross-BC vocabulary contract check. Closed by CI check (l) in
`check-spec-counts.sh v1.6`: derives canonical set programmatically from BC-4.03.002
at runtime and scans ALL BCs for non-canonical `disclosure_class` enum declarations.

---

### O8-01 — LOW: `BC-10.05.001` `asset_type` vs Canonical Sidecar `asset_class` Field Name

**Location:** `ss-10/BC-10.05.001.md`
**Severity:** LOW (observation)
**Blocking:** No

**Description:** BC-10.05.001 used the field label `asset_type` (with values
image/audio/video/text/3d-mesh) in its schema description. The canonical provenance
sidecar schema (adapter-protocols.md) uses `asset_class`. The two sets of values are
projection-compatible but the label divergence could mislead implementers.

**Resolution:** RESOLVED

Renamed field label to `eu_scope_category` with an explicit documented projection
mapping from the canonical `asset_class` values. This makes clear that the EU-scope
categorisation is a derived view over the canonical sidecar field, not a duplicate
or replacement. The canonical `asset_class` field is preserved unchanged in
adapter-protocols.md.

---

### O8-02 — LOW: `BC-7.11.002` / `BC-7.11.007` Missing L2 Anchor Note for CWE-602

**Location:** `ss-07/BC-7.11.002.md`, `ss-07/BC-7.11.007.md`
**Severity:** LOW (observation)
**Blocking:** No

**Description:** Both BCs cite DI-012 as the sole L2 domain-invariant anchor for
their server-authority requirement. CWE-602 (Client-Side Enforcement of Server-Side
Security) does not have a dedicated DI anchor in the domain spec. A reader could
question whether the DI citation is correct or an approximation.

**Resolution:** RESOLVED

Added a one-line clarifying note to both BCs: "CWE-602 server-authority has no
dedicated DI entry; DI-012 (the applicable meta-invariant for implementation-source
authority enforcement) is the correct and intentional anchor." This closes the
documentation ambiguity without creating a new DI or modifying the domain spec.

- `BC-7.11.002` updated to **v1.1**.
- `BC-7.11.007` updated to **v1.1**.

---

## Spec State After Pass-8 Fixes

| Document | Version After Pass 8 |
|----------|----------------------|
| `ss-10/BC-10.05.001.md` | v1.1 |
| `ss-13/BC-13.04.001.md` | v1.2 |
| `ss-07/BC-7.11.002.md` | v1.1 |
| `ss-07/BC-7.11.007.md` | v1.1 |
| `scripts/check-spec-counts.sh` | v1.6 (12 checks a–l) |

All other spec files unchanged from Pass-7 state.

---

## Verification Footer

`check-spec-counts.sh v1.6` ALL 12 CHECKS PASSED (a–l), exit 0.
0 non-canonical `disclosure_class` values in corpus (check l GREEN).
CI gate now enforces the closed-enum contract at every push.

---

## Summary

| Dimension | Result |
|-----------|--------|
| Critical findings | 0 |
| Important findings | 1 (F8-01 — disclosure_class enum contradiction; RESOLVED) |
| LOW observations | 2 (O8-01, O8-02 — BOTH RESOLVED) |
| Blocking issues | 0 (all findings resolved) |
| Clean-pass counter | **RESET: 1/3 → 0/3** |
| Spec stability | CHANGED — 4 BC files updated, CI gate v1.6 |
| Next action | Pass 9 (consecutive clean pass 1 of 3 — restart) |
