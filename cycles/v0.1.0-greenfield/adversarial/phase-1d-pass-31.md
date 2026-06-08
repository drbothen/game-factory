---
cycle: v0.1.0-greenfield
document: phase-1d-adversarial-pass
pass: 31
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
suggestions: 0
novelty: MODERATE-HIGH
clean_pass_counter_before: 2
clean_pass_counter_after: 0
counter_note: "4th near-convergence reset — CLEAN-PASS COUNTER RESET 2/3 → 0/3"
---

# Phase-1d Adversarial Pass 31 (candidate clean #3)

**VERDICT: FINDINGS (0 critical, 1 important)**
**Novelty: MODERATE-HIGH**
**CLEAN-PASS COUNTER RESET 2/3 → 0/3** (4th near-convergence reset)

---

## Findings

### I31-01 (IMPORTANT, process-gap) — Canon-KB "load-bearing seam" ORDINAL drift

**Defect class:** Seam-ordinal stale phrasing — "fifth load-bearing seam" vs authoritative "sixth"
**Novelty:** MODERATE-HIGH — distinct from the "four adapter seam" → "five adapter seam" class gated by check (o); this class describes the Canon-KB seam's position among ALL load-bearing seams (adapter seams 1–5 + Canon-KB = 6th)
**Instance count:** 5 operative files at time of detection; class fully enumerated and gated

**Root cause:**
The product brief (product-brief.md:111) and PRD (prd.md:63), ADR-0004, and L2-INDEX all establish that the Canon-KB seam is the **sixth** load-bearing non-adapter seam: five adapter seams (engine / asset / compliance / analytics-passthrough / online-services) + the Canon-KB contextual seam = six total. Pass-14 O14-02 fixed ADR-0004 line 39 "fifth"→"sixth". However, the fix did not fully propagate — five operative files continued to describe Canon-KB as the "fifth load-bearing seam" and two of those files falsely cited the brief as supporting "fifth" (brief in fact says "sixth").

**Files with violations at detection:**

| File | Line(s) | Stale phrasing |
|------|---------|----------------|
| `.factory/specs/architecture/layered-architecture.md` | ~53 | "fifth load-bearing seam" |
| `.factory/specs/architecture/methodology-layer.md` | ~506 | "fifth load-bearing seam" |
| `.factory/specs/architecture/subsystem-decomposition.md` | ~283 | "fifth load-bearing seam" |
| `.factory/specs/domain-spec/capabilities.md` | ~158 | "fifth load-bearing seam" |
| `.factory/specs/prd-supplements/prd-cap-008-012.md` | ~58, ~61 | "fifth load-bearing seam" |

Two of the above files also contained a false brief-citation claiming the brief says "fifth" (in fact product-brief.md:111 says "sixth").

**Resolution:**
All five files corrected to "sixth load-bearing seam"; false brief-citations replaced with accurate anchor references (file:line). Version bumps applied:

| File | Version bump |
|------|-------------|
| `layered-architecture.md` | v1.0 → v1.1 |
| `methodology-layer.md` | v1.10 → v1.11 |
| `subsystem-decomposition.md` | v1.6 → v1.7 |
| `capabilities.md` | v1.1 → v1.2 |
| `prd-cap-008-012.md` | v1.0 → v1.1 |

**Process-gap RESOLVED:** Check (o.ii) added to `scripts/check-spec-counts.sh` (v1.24 → v1.25):

- Scans 28 operative files for any `<ordinal> load-bearing seam` phrase referencing Canon-KB
- FAILS if ordinal is "fifth" (or any ordinal other than "sixth")
- FAILS if file contains a false brief-citation claiming "fifth"
- 28 files scanned, 0 violations post-fix

CI gate v1.25. Check (o.ii) anchored alongside existing check (o) (four-adapter-seam guard).

---

## Observations / Non-Blocking

_(none this pass)_

---

## Convergence Status

**CLEAN-PASS COUNTER RESET: 2/3 → 0/3** (4th reset at near-convergence)

Spec changed (5 files + CI gate): streak restarts. Next = Pass 32 (candidate clean #1, restart).

---

## Verification Footer

- Script: `scripts/check-spec-counts.sh` v1.25
- Result: ALL CHECKS PASSED (checks a–u + o.ii, ~30 sub-assertions), exit 0
- Totals confirmed: BC=190, error codes=255 (246 active), NFRs=41, priority P0=126/P1=42/P2=22
- Pass-31 spec changes propagation-swept: 28 files scanned by check (o.ii), 0 violations
