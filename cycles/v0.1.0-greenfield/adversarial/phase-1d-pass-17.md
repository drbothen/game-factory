---
document_type: adversarial-review
cycle: v0.1.0-greenfield
pass: 17
phase: 1d
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
observations: 2
novelty: LOW-MEDIUM
clean_pass_counter: 0/3
candidate_clean: 1
---

# Phase-1d Adversarial Pass 17 (candidate clean #1) — FINDINGS

**Verdict:** FINDINGS — 0 critical, 1 important, 2 observations  
**Novelty:** LOW-MEDIUM  
**Clean-pass counter:** stays 0/3 (findings present; not a clean pass)  
**Next:** Pass 18 (candidate clean #1 re-attempt)

---

## Summary

Pass 17 is the first attempt at a clean pass after the three-pass convergence run.
The single important finding is a stale BC grand-count integer in prd.md §8.1 —
a copy of the 189-active-error-codes figure that was never updated when the count
moved to 190. The process-gap: CI check (a) only matched the "Grand total: N BCs"
phrasing; the §8.1 prose used "All N behavioral contracts have been assigned", which
escaped all prior checks. Check (a.iii) closes this gap. Observations are non-blocking
methodology documentation notes.

---

## Findings

### F-17-01 (IMPORTANT) — prd.md §8.1 stale BC grand-count

**File:** `.factory/specs/prd.md` §8.1 line ~364  
**Stated:** "All 189 behavioral contracts have been assigned"  
**Correct:** "All 190 behavioral contracts have been assigned"  
**Root cause:** The integer 189 was the count of active error codes at the time the §8.1
prose was drafted (pre-CAP-015: 198 total codes, 189 active). It was never updated when
the BC total moved from 178 to 190 in Pass-13 (CAP-015 addition). The "Grand total: 190
BCs" line in the same document was correct; only this alternate-phrasing instance drifted.

**Other "178" / "189" / "N BCs" references audited:**
- 178 refs in changelog rows and historical prose are correctly scoped to pre-v1.9 versions;
  they are excluded by CI check (a.iii) exclusion rules 1–6 (changelog pipe-rows, blockquote
  lines, pre-vN labels, backfilled notes).
- The figure 189 appearing in error-taxonomy changelog as "189 active" refers to the active
  error code count (189 active codes at v1.7), which is a distinct metric from BC count.
  CI check (a.iii) exclusion rule 7 prevents this from matching (patterns require "behavioral
  contracts" or "BCs", not "error codes").
- All four target phrasings audited across prd.md, subsystem-decomposition.md, and
  ARCH-INDEX.md — only one match found; that match is the one corrected here.

**Resolution:** RESOLVED
- prd.md §8.1 line corrected: "All 189 behavioral contracts" → "All 190 behavioral contracts"
- prd.md frontmatter version bumped: 2.0 → 2.1
- prd.md changelog row v2.1 added: documents the correction and distinguishes the 189
  active-error-codes metric from the 190 BC grand total.
- BC count unchanged: 190.

**Process-gap closed:** CI check (a.iii) added in v1.17 — scans prd.md, subsystem-decomposition.md,
and ARCH-INDEX.md for four alternate BC-count phrasings and asserts each stated N equals the
computed BC file count. Seven false-positive exclusion rules prevent changelog prose, blockquotes,
historical version refs, transition arrows, and backfill notes from generating false failures.
Positive-coverage log always printed. One statement validated; zero violations after fix.

---

### OBS-17-1 (OBSERVATION, non-blocking) — methodology §3 dimension-subsystem label convention

**File:** `.factory/specs/architecture/methodology-layer.md` §3.0  
**Note:** The "Subsystem" column in the §3.0 dimension table names the source-domain subsystem
(e.g., D-CERT → SS-08/SS-09) while the §3.1 "Owner BC" column lists SS-07 evaluation-layer BCs
as owners. The dual meaning could confuse fresh-context readers.  
**Status:** Non-blocking. Deferred as FU-008 (opened Pass-11; confirmed still open). May fold
into a later doc-cleanup pass. No CI enforcement needed — the convention is deliberate, not a
drift error.

---

### OBS-17-2 (OBSERVATION, non-blocking) — broad positive verification pass

**Scope:** Full re-verification of the critical spec surfaces after Passes 14–16 fixes.  
**Result:** All clean:
- DI/CAP architecture: five-seam model fully consistent across ADR-0004 v1.2, adapter-protocols
  v1.2, capabilities.md, invariants.md, prd.md; no residual "four-seam" phrasing.
- Error taxonomy: 213 codes / 31 families (204 active; E-GEN 9 retired); all BC citations resolve.
- DTU assessment: 11 clones DTU-01..DTU-11; DTU-08 wired to CAP-015/SS-13; consistent.
- VP consistency: 10 VPs (6 P0, 4 P1); all formal VP↔BC back-references intact.
- Thesis: engine-agnostic / five-seam / no-lock-in — reaffirmed; no silent drop.
- Release-gate: priority distribution P0=126 / P1=42 / P2=22 — consistent across all index files.
- Testability: BC frontmatter schema coverage 190/190.
- Convergence-dimension status values: canonical enum {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}
  enforced; per-dimension subsets intact; no case-insensitive violations.

---

## Resolution Summary

| Finding | Severity | Resolved | Method |
|---------|----------|----------|--------|
| F-17-01 | IMPORTANT | YES | prd.md §8.1 "189"→"190"; frontmatter v2.0→v2.1; CI check a.iii added |
| OBS-17-1 | OBS | DEFERRED (FU-008) | Non-blocking; methodology §3 dual-meaning noted |
| OBS-17-2 | OBS | N/A | Positive verification pass — all clean |

---

## Verification

**CI gate:** `check-spec-counts.sh` v1.17  
**Checks:** a–p including a.ii (15 capability headers validated) and a.iii (1 alternate-phrasing
BC-count statement validated)  
**Sub-assertions:** 22  
**Exit code:** 0 (ALL CHECKS PASSED)  
**BC count:** 190 | **Error codes:** 213 | **Priority:** P0=126 / P1=42 / P2=22  

**Count-propagation sweep:**
- `prd.md` line ~364: updated (189→190), frontmatter v2.0→v2.1 — DONE
- `BC-INDEX.md` "Grand total: 190 behavioral contracts": already correct — no change
- `ARCH-INDEX.md` TOTAL row `**190**`: already correct — no change
- `subsystem-decomposition.md` "Grand total: **190**": already correct — no change
- No other operative prose with stale 189 BC-count phrasing found (sweep: CLEAN)
