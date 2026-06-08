---
document_type: adversarial-review
cycle: v0.1.0-greenfield
pass: 18
phase: 1d
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
observations: 0
novelty: MEDIUM
clean_pass_counter: 0/3
candidate_clean: 1
---

# Phase-1d Adversarial Pass 18 (candidate clean #1) — VERDICT: FINDINGS (0C/1I) + ORCHESTRATOR PROACTIVE BATCH-FIX

**Verdict:** FINDINGS — 0 critical, 1 important, 0 observations  
**Novelty:** MEDIUM (stale count-summary line + orchestrator proactive closure of the entire per-cap count-summary class)  
**Clean-pass counter:** stays 0/3 (findings present; not a clean pass)  
**Next:** Pass 19 (candidate clean #1 re-attempt)

---

## Summary

Pass 18 is the second attempt at candidate clean #1. The adversary found one important
finding: nfr-catalog.md line ~92 stated "Total NFRs: 35" (the pre-CAP-015 count) while
the actual table contains 41 rows and prd.md §4 correctly states 41. The root cause is
the same class as Pass-17's F-17-01 — a count-summary line not updated when new rows
were added in a CAP-015 authoring burst. Additionally, the nfr-catalog v1.3 frontmatter
was already set but the changelog body had not been written, leaving an internal version
inconsistency.

The orchestrator initiated a proactive batch-fix sweep to close the entire
stale-count-summary class before Pass 19. The sweep found two more per-cap PRD supplement
count lines that had not yet been flagged: prd-cap-006-007.md "Total CAP-007 BCs: 12"
(table has 19 BCs; the 7 server-authority suite BCs BC-7.11.002..008 were added in
Pass-1 but the count line was not updated) and prd-cap-001.md "Total BCs in this batch:
34" (should be "Total CAP-001 BCs: 35" — BC-1.15.002 was added in an earlier burst but
the line was never updated, and the phrasing was also obsolete). Both were fixed. CI
check (a.iv) was added to gate the entire class going forward.

The combined resolution — I-18-01 fix + proactive sweep — means all per-cap PRD BC
total lines and the NFR triple-consistency check now pass CI gate v1.18 with 0
violations across 7 sub-assertions.

---

## Findings

### I-18-01 (IMPORTANT) — nfr-catalog.md stale NFR total + missing v1.3 changelog

**File:** `.factory/specs/prd-supplements/nfr-catalog.md` line ~92  
**Stated:** "Total NFRs in this catalog: 35"  
**Correct:** "Total NFRs in this catalog: 41"  
**Root cause:** The summary line was written when the catalog contained NFR-001..NFR-035
(35 NFRs). NFR-036..NFR-041 were added in the CAP-015 authoring burst (Pass-13) to cover
online-services latency and correctness requirements. The table itself was updated
correctly (41 rows), prd.md §4 parenthetical "(41 NFRs, NFR-001 through NFR-041)" was
correct, but the nfr-catalog.md summary count line was never bumped from 35 to 41.
Additionally, the nfr-catalog.md frontmatter set `version: "1.3"` but the changelog body
had no v1.3 entry, creating an internal version-prose inconsistency.

**Defect class:** Same class as F-17-01 — count-summary line not updated when rows were
added to a supplement table. The class is now fully enumerated and gated.

**Resolution:** RESOLVED
- nfr-catalog.md line ~92: "Total NFRs in this catalog: 35" → "Total NFRs in this catalog: 41"
- nfr-catalog.md updated summary text: "(NFR-001..NFR-019 from Phase 1a; NFR-020..NFR-035
  added in PRD revision v1.1 to close FU-002; NFR-036..NFR-041 added in v1.3 for CAP-015
  online-services)"
- nfr-catalog.md frontmatter version remains 1.3; v1.3 changelog entry added documenting
  the count correction.

**Process-gap closed:** CI check (a.iv) Sub-Check 2 (NFR triple-consistency) added in
v1.18 — asserts rows counted in nfr-catalog.md == "Total NFRs in this catalog: N" summary
line == prd.md §4 parenthetical "(N NFRs, NFR-001 through NFR-NNN)". All three values now
agree at 41. 2 NFR assertions validated, 0 violations.

---

## Orchestrator Proactive Sweep — Per-Cap PRD BC Total Class Closure

**Trigger:** To break the one-stale-count-per-pass tail pattern (F-17-01 in Pass 17,
I-18-01 in Pass 18), the orchestrator ran a proactive corpus sweep of all per-cap PRD
supplement count lines before dispatching Pass 19. Goal: enumerate and fix any remaining
instances so the entire class is gated by CI before the next pass.

**Sweep scope:** All `.factory/specs/prd-supplements/prd-cap-*.md` files, searching for
any "Total CAP-NNN BCs:" or "Total BCs in this batch:" lines.

**Instances found and fixed:**

### PROACTIVE-FIX-1 — prd-cap-006-007.md "Total CAP-007 BCs: 12" → 19

**File:** `.factory/specs/prd-supplements/prd-cap-006-007.md` line ~153 (original ~146)  
**Stated (pre-fix):** "Total CAP-007 BCs: 12"  
**Correct:** "Total CAP-007 BCs: 19"  
**Root cause:** The 7 server-authority invariant BCs (BC-7.11.002..BC-7.11.008) were added
in Pass-1 (the CAP-007 section of the pass-1 authoring burst). At that time, prd-cap-006-007.md
existed with a count of 12 (the original set: BC-7.01.001..BC-7.11.001 + BC-7.12.001).
The new 7 BCs were registered in BC-INDEX.md and in their ss-07/ files but the supplement's
own count-summary line was never updated. BC-INDEX.md CAP-007 header (now "19 BCs" per
the Pass-16 I-16-01 fix) is authoritative; the supplement line was stale by 7.  
**Resolution:** RESOLVED — line corrected to 19; v1.1 changelog entry added.

### PROACTIVE-FIX-2 — prd-cap-001.md "Total BCs in this batch: 34" → canonical "Total CAP-001 BCs: 35"

**File:** `.factory/specs/prd-supplements/prd-cap-001.md` line ~76 (original)  
**Stated (pre-fix):** "Total BCs in this batch: 34" (obsolete phrasing)  
**Correct:** "Total CAP-001 BCs: 35 (34 original + BC-1.15.002 added v1.1)"  
**Root cause 1 (count):** BC-1.15.002 (kernel-anti-cheat never-author lint, DI-010) was
added in the prd-revision burst (Step 7 of Phase-1). The supplement was written with 34
BCs; BC-1.15.002 was registered in BC-INDEX.md and in ss-01/ but the supplement total
line was never updated from 34 to 35.  
**Root cause 2 (phrasing):** The original phrasing "Total BCs in this batch: 34" uses
the obsolete ambiguous form that CI check (a.iv) flags as an advisory (cannot determine
which CAP is being summarized without the explicit "CAP-NNN" identifier). Migrated to
canonical "Total CAP-001 BCs: 35 (...)" form.  
**Resolution:** RESOLVED — line corrected to canonical form with count 35; v1.1 changelog
entry added.

---

## Process-Gap Resolution — Check (a.iv) Added

**Gap:** CI checks (a), (a.ii), (a.iii) collectively validated the BC grand total (190)
and BC-INDEX section headers (all 15 caps). However, neither check validated the per-cap
count-summary lines inside individual prd-cap-*.md supplement files. These lines can drift
independently of the BC-INDEX headers (as demonstrated by PROACTIVE-FIX-1 and
PROACTIVE-FIX-2, which were not caught by any prior CI check).

**Resolution:** Check (a.iv) added to `check-spec-counts.sh` v1.18:

Sub-Check 1 — Per-cap PRD BC totals:
- Scans all prd-cap-*.md supplement files for "Total CAP-NNN BCs: N" lines (primary
  canonical form) and "Total CAP-NNN BCs ...: N" (annotation suffix form).
- For each match, sources the authoritative per-cap count from the BC-INDEX.md H2
  "## CAP-NNN — N BCs" header (already validated by check a.ii, so trustworthy).
- FAIL if stated N != BC-INDEX authoritative N.
- Also detects obsolete "Total BCs in this batch: N" phrasing and reports it as an
  advisory (ambiguous capability mapping — PO should migrate to canonical form).
- False-positive exclusions: skip lines starting with "|", ">", or containing "reason:";
  pattern requires literal "BCs".

Sub-Check 2 — NFR triple-consistency:
- (i) Counts actual "| NFR-NNN" table rows in nfr-catalog.md.
- (ii) Parses "Total NFRs in this catalog: N" summary line in nfr-catalog.md.
- (iii) Parses "(N NFRs, NFR-001 through NFR-NNN)" in prd.md §4 prose.
- Asserts all three values agree. Catches the "35 vs 41" class where rows were added
  (e.g., NFR-036..041 for CAP-015) but the summary line was not updated.
- False-positive exclusion: prd.md parse anchors to "NFRs, NFR-001 through" so changelog
  delta lines ("+16 NFRs", "19 NFRs") do not match.

**Validation run (v1.18):** 5 per-cap PRD BC totals + 2 NFR total checks = 7 assertions,
0 violations. ALL CHECKS PASSED exit 0.

---

## Resolution Summary

| Finding / Action | Severity | Resolved | Method |
|-----------------|----------|----------|--------|
| I-18-01 nfr-catalog.md "Total NFRs: 35" → 41 + v1.3 changelog | IMPORTANT | YES | nfr-catalog.md v1.3 summary line corrected; v1.3 changelog body written |
| PROACTIVE-FIX-1 prd-cap-006-007.md CAP-007 total "12"→"19" | PROACTIVE | YES | prd-cap-006-007.md v1.1; BC-7.11.002..008 server-authority suite reflected |
| PROACTIVE-FIX-2 prd-cap-001.md "batch:34"→"CAP-001 BCs:35" | PROACTIVE | YES | prd-cap-001.md v1.1; BC-1.15.002 counted; canonical phrasing adopted |
| Process-gap: no CI gate on per-cap supplement count lines | PROCESS-GAP | RESOLVED | check (a.iv) added — 7 checks, 0 violations |

---

## Verification

**CI gate:** `check-spec-counts.sh` v1.18  
**Checks:** a–p including a.ii (15 capability headers validated), a.iii (1 alternate-phrasing
BC-count statement validated), and a.iv (5 per-cap PRD BC totals + 2 NFR triple-consistency
checks)  
**Sub-assertions:** ~24  
**Exit code:** 0 (ALL CHECKS PASSED)  
**BC count:** 190 | **Error codes:** 213 | **NFRs:** 41 | **Priority:** P0=126 / P1=42 / P2=22

**Count-propagation sweep (a.iv sub-assertions validated):**
- `nfr-catalog.md` line ~92: updated (35→41), v1.3 changelog written — DONE
- `prd-cap-006-007.md` line ~153: updated (12→19), v1.1 changelog written — DONE
- `prd-cap-001.md` line ~76: updated (34→35, phrasing migrated), v1.1 changelog written — DONE
- `BC-INDEX.md` CAP-007 "19 BCs" header: already correct (fixed Pass-16) — no change
- `prd.md` §4 "(41 NFRs, NFR-001 through NFR-041)": already correct — no change
- No other per-cap total lines with stale counts found (sweep: CLEAN)
