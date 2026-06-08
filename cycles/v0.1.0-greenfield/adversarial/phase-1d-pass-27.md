---
pass: 27
phase: 1d
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
low: 1
severity_summary: 0C / 1I / 1 LOW obs
novelty: MEDIUM
clean_pass_counter_before: "2/3"
clean_pass_counter_after: "0/3 (RESET)"
spec_stable: false
files_changed: [methodology-layer.md, scripts/check-spec-counts.sh]
---

# Phase-1d Adversarial Pass 27 — Candidate Clean #3 — VERDICT: FINDINGS

**0 critical, 1 important, 1 LOW observation. Novelty: MEDIUM.**
**CLEAN-PASS COUNTER RESET: 2/3 → 0/3.**
**3rd instance of the dimension-owner mislabel class found at the convergence pass.**

---

## Summary

Pass 27 was dispatched as the candidate convergence pass (consecutive clean #3 of 3).
A fresh-context adversarial review identified a surviving instance of the
dimension-owner mislabel class — the same defect class as I24-01, FU-009, and F15.

The finding (I27-01) was at methodology-layer.md line ~714: a "Resolved in Pass-12"
note mislabeled BC-8.08.004 as the "D-PLAY dimension owner, SS-07/SS-08 interface."
BC-8.08.004 is a PRODUCER (sign-off gate, SS-07); the D-PLAY dimension owner is
BC-7.05.001 (SS-06).

The check (t) phrasing from v1.22 only matched two narrow compound patterns
("dimension-owner (SS-0" and "owner BCs (SS-0"); line 714 used a different phrasing
("dimension owner, SS-07/SS-08 interface") that evaded both. Check (t) has been
broadened in v1.23 to trigger on ANY line containing "dimension owner" or
"dimension-owner" (space or hyphen, case-insensitive) and assert both:
  (t.i)  Any BC ID named must be a valid dimension-owner BC (BC-7.0[1-9].001,
         BC-7.10.001, or BC-7.11.001); non-owner BCs (BC-8.*, etc.) named as
         dimension owner FAIL.
  (t.ii) If any SS-NN reference appears but SS-06 is absent, FAIL.
  (t.iii) Retained: "owner BCs (SS-0X" where X != 6 compound pattern.

Orchestrator enumeration confirmed line 714 was the ONLY remaining instance:
line 637 is correct (SS-06 + BC-7.* — passes new check); lines 701-709 are a
producer table (no "dimension owner" phrase — not triggered).

The process gap is now comprehensively gated. 4,165 lines scanned, 0 violations
after the fix. Clean-pass counter resets to 0/3; Pass 28 begins the restart.

---

## Findings

### I27-01 (IMPORTANT, [process-gap]) — Dimension-owner mislabel at line 714

**File:** `.factory/specs/architecture/methodology-layer.md`, line ~714

**Finding:** A "Resolved in Pass-12" changelog note labeled BC-8.08.004 as the
"D-PLAY dimension owner, SS-07/SS-08 interface." This is incorrect:

- **BC-8.08.004** is the D-PLAY STATUS PRODUCER (sign-off gate in SS-07; produces
  the DEGRADED/GREEN/DEGRADED-PENDING/BLOCKED token that SS-06 consumes).
- **BC-7.05.001** is the D-PLAY DIMENSION OWNER (SS-06 Convergence Tracking Engine).
- **SS-07** is the Playtest Protocol subsystem (producer side), not SS-06 (owner side).
- **SS-08** reference was erroneous; BC-8.08.004 lives in ss-07/, not ss-08/.

Same class as I24-01/FU-009/F15 (dimension-owner attribution errors in methodology
prose). The Pass-24 check (t) v1.22 used two narrow compound patterns and did not
trigger on the "dimension owner, SS-07/SS-08 interface" phrasing at line 714.

**Resolution:** Line 714 corrected:
- "BC-8.08.004 as the D-PLAY dimension owner, SS-07/SS-08 interface"
  replaced with:
  "BC-8.08.004 = D-PLAY status PRODUCER / SS-07 sign-off gate (feeds SS-06 owner
  BC-7.05.001); 'SS-08' removed"
- methodology-layer bumped to **v1.10**.

**Process-gap resolution:** check (t) broadened from v1.22 → v1.23:
- Now triggers on ANY operative line containing "dimension owner" or "dimension-owner"
  (space or hyphen, case-insensitive).
- (t.i) Any BC ID on the triggered line must be a canonical dimension-owner BC
  (BC-7.0[1-9].001, BC-7.10.001, BC-7.11.001); a non-owner BC (BC-8.*, etc.) named
  as dimension owner is a FAIL.
- (t.ii) If any SS-NN reference appears on the triggered line but SS-06 is absent,
  FAIL (non-SS-06 attribution without SS-06 also named is a FAIL).
- (t.iii) Retained: "owner BCs (SS-0X" where X != 6 compound pattern.
- Blockquote lines (">") excluded throughout.
- Calibrated to zero false-positives on the post-fix corpus:
  - Line 637: "SS-06 … BC-7.* dimension owners" — SS-06 present, BC-7.* = owners;
    passes (t.i) and (t.ii).
  - Producer table lines 701-709: no "dimension owner" phrase — not triggered.
  - Per-dimension "Subsystem:" headers: no "dimension owner" phrase — not triggered.
- 4,165 lines scanned, 0 violations.
- CI gate bumped to **v1.23**.

**Defect class status:** Comprehensively gated. Would have caught line 714 pre-fix.

---

## Observations

### O27 (LOW, non-blocking) — VP-006 proptest property clause #1 comment scoping

**File:** `.factory/specs/verification-properties/VP-006.md`

**Observation:** VP-006's proptest strategy scopes property clause #1
(inactive-period RD-increase) to a Markdown comment block rather than the main
test body. This is a test-scoping choice by the VP author — the property is
declared but relegated to commentary, implying it is not currently exercised by
the active proptest suite.

**Assessment:** Non-blocking. A test-scoping choice in a VP doc is not a spec
contradiction. The property exists and is traceable. Whether it is exercised in
Phase 3 implementation is an implementation decision deferred to story decomposition.
No spec inconsistency present.

**Disposition:** Non-blocking observation. No file change.

---

## Verification

check-spec-counts.sh **v1.23** — ALL CHECKS PASSED (checks a–t, ~28 sub-assertions),
exit 0.

Totals confirmed unchanged:
- BCs: **190**
- Error codes: **255** (246 active / 9 retired)
- NFRs: **41**
- Priority: P0=**126** / P1=**42** / P2=**22**
- Caps: 15 / Subsystems: 13

---

## Gate Verdict

**FINDINGS — 0 critical, 1 important (RESOLVED), 1 LOW non-blocking observation.**

Clean-pass counter **RESET: 2/3 → 0/3** (3rd instance of dimension-owner mislabel
class found at convergence pass; streak restarts).

Spec changed: methodology-layer.md v1.10, CI gate v1.23.
Next: **Pass 28** (candidate clean #1, restart).
