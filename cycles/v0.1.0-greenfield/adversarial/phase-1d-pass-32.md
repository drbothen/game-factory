---
cycle: v0.1.0-greenfield
document: phase-1d-adversarial-pass
pass: 32
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
suggestions: 0
novelty: MEDIUM-HIGH
clean_pass_counter_before: 0
clean_pass_counter_after: 0
counter_note: "All findings RESOLVED. Counter stays 0/3 (findings pass; restart pending Pass 33)."
---

# Phase-1d Adversarial Pass 32 (candidate clean #1)

**VERDICT: FINDINGS (0 critical, 1 important, 2 observations) — ALL RESOLVED**
**Novelty: MEDIUM-HIGH**
**CLEAN-PASS COUNTER: 0/3** (findings resolved; counter does NOT increment; restart pending Pass 33)

---

## Findings

### I-PASS32-01 (IMPORTANT, fix-induced regression) — Spurious DI-007 grafted onto cinematic creative gate in 4 BCs

**Defect class:** Fix-induced regression from the Pass-28 I28-01 fix. The Pass-28 fix correctly replaced `human-gated`/`DI-006`/`-32008` vocabulary with `creative-gate`/`DI-007`/`E-CIN-003` in cinematic contexts — but this introduced DI-007 as a cinematic creative-gate anchor, which is equally wrong. DI-007 = "Playtest Satisfaction Is Always a Human Gate" (BC-8.08.004/BC-7.05.001/BC-8.08.005 enforcer set). The cinematic creative gate is governed by D-013 + E-CIN-003 with NO DI anchor.

**Novelty:** MEDIUM-HIGH — sibling regression of the I28-01 fix class; not reached by check (u) because (u) guards against `human-gated`/DI-006 in cinematic context, not against `DI-007` in cinematic context.

**Instance count:** 4 operative BC files (fully enumerated; class closed by check (w)).

**Affected locations:**
- `BC-7.04.001` (v1.1 → v1.2): Postcondition 3 read `D-013/DI-007 creative gate` — corrected to `D-013 creative gate`. Traceability L2 Domain Invariants row removed DI-007 (cinematic creative gate is anchored to D-013 + E-CIN-003; it has no corresponding DI). DI-003 and DI-012 retained.
- `BC-5.06.001` (v1.2 → v1.3): Traceability L2 Domain Invariants row contained DI-007 from the Pass-28 pass-through — removed. DI-008 (engine-neutral spec layer) retained. D-013/E-CIN-003 references preserved.
- `BC-7.05.001` (v1.2 → v1.3): EC-006 cinematic creative-gate description contained `DI-007` — removed (was: `D-013 creative gate (DI-007, E-CIN-003 ...)`; corrected to `D-013 creative gate (E-CIN-003 ...)`). All legitimate playtest DI-007 references preserved: Invariant 1 (`DI-007: any automated fun-score = factory defect`), Postcondition 4, test vector row, Traceability L2 Domain Invariants row — untouched.
- `BC-12.12.008` (v1.2 → v1.3): EC-003 cinematic creative-gate description contained `D-013/DI-007` — corrected to `D-013/E-CIN-003`. The legitimate loremaster DI-006 references (postcondition 2, invariant 1) are untouched.

**Resolution:** RESOLVED. D-013 and E-CIN-003 retained in all four BCs. All legitimate playtest/XR DI-007 usages preserved. Check (w) added (see Process Gap below).

---

### O-PASS32-01 (LOW observation) — prd.md §8.4 ledger missing v2.0 entry; family-count typo 34→30

**Location:** `prd.md` line ~404, §8.4 Error Taxonomy — Updated (v2.0) ledger entry.

**Defect:** The v2.0 ledger entry stated "34 active families" — contradicting the authoritative count of 30 active families (prd.md:233, prd.md:270, error-taxonomy.md:806). The entry also lacked a v2.0 ledger row in the §8 changelog table.

**Resolution:** RESOLVED this commit. Typo corrected: "34 active families" → "30 active families". Changelog row v2.3 added to §8 changelog table. prd.md bumped v2.2 → v2.3.

---

### O-PASS32-02 (LOW observation) — check-spec-counts.sh v1.24 check (u) comment text mis-attributed DI-007

**Location:** `scripts/check-spec-counts.sh`, check (u) block comment.

**Defect:** The comment inside check (u) said `DI-007` where it should have said `D-013` when describing the cinematic creative gate. This is the comment that describes what IS a cinematic creative gate context — it was referencing the wrong invariant dimension.

**Resolution:** RESOLVED this commit. Comment corrected: `D-013` is the cinematic creative gate dimension; `DI-007` is the playtest invariant. Gate version bumped v1.24 → v1.26 (v1.25 was the Canon-KB ordinal guard from Pass-31; this is the check (w) addition).

---

## Process Gap — Check (w) Added

**Gap:** No CI gate checked for DI-007 cited in proximity to cinematic/creative-gate context keywords (`D-013`, `E-CIN-003`, `cinematic-director`, `directed:true`, `creative gate`). This allowed the I-PASS32-01 regression class to persist undetected across Pass-29/30/31.

**Resolution:** Check (w) added to `check-spec-counts.sh` v1.26 — scans all BC files for lines that contain `DI-007` AND a cinematic-creative-gate context keyword. Exempts legitimate playtest/XR DI-007 usages (lines containing `playtest`, `fun-score`, `playtest-satisfaction`, `BC-8.08`). Broader DI↔BC bidirectional check deliberately NOT added — false-positive risk on analogical DI usages like XR-comfort DI-007.

**Verification:** 0 violations found after applying the 4-BC fix. All legitimate playtest DI-007 usages (BC-7.05.001 Invariant 1, BC-8.08.004, BC-8.08.005, and any XR comfort references) are correctly exempted.

---

## Verification

**Gate:** `scripts/check-spec-counts.sh` v1.26 — ALL CHECKS PASSED (checks a–w + o.ii, ~31 sub-assertions), exit 0.

**Spec totals confirmed by gate:**
- BC count: 190 (computed == stated in BC-INDEX / ARCH-INDEX / prd.md / subsystem-decomposition)
- Error codes: 255 (246 active + 9 retired E-GEN)
- NFRs: 41
- Priority: P0=126 / P1=42 / P2=22
- Active error families: 30 (+ 1 retired E-GEN = 31 registered total)
- Subsystems: 13

**Version bumps this pass:**
- `BC-7.04.001` v1.1 → v1.2
- `BC-5.06.001` v1.2 → v1.3
- `BC-7.05.001` v1.2 → v1.3
- `BC-12.12.008` v1.2 → v1.3
- `prd.md` v2.2 → v2.3 (typo fix + changelog row)
- `check-spec-counts.sh` v1.25 → v1.26 (check w added + comment fix)
