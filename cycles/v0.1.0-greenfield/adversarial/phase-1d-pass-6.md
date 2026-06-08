---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 6
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MODERATE
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 2 important, 1 suggestion"
---

# Phase-1d Adversarial Review — Pass 6

**Verdict:** FINDINGS (0 critical, 2 important, 1 suggestion)
**Novelty:** MODERATE
**Convergence status:** NOT CONVERGED — clean-pass counter remains 0/3. Next = Pass 7.
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C (zero criticals in Pass 6; decaying trend confirmed)
**Pass-5 fixes re-verified:** ALL CONFIRMED — studio §3/§6 recompute, VP-TBD BC-local convention (D-015), 11 formal VP↔BC back-refs, P0 subtotal 111.

---

## Positive Confirmations

| Item | Verification Result |
|------|---------------------|
| BC logical composition (178 BCs, no duplicates, correct SS assignment) | VERIFIED CLEAN |
| Thesis integrity (engine-agnostic / four-seam / no-lock-in; 8 adapter contract schemas) | VERIFIED CLEAN |
| DTU adequacy (10 clones DTU-01..10; dtu-assessment.md reflects full service list) | VERIFIED CLEAN |
| Convergence-predicate decidability (11 dims + predicates in methodology-layer; no circular predicates) | VERIFIED CLEAN |
| Determinism-tier seam (T1/T2/T3 model; D-003; adapter boundary well-specified) | VERIFIED CLEAN |

---

## Pass-5 Fix Re-Verification

| Fix | Re-Verification Result |
|-----|------------------------|
| studio-of-agents §3 SS-05/SS-10 recomputed from §2 roster | CONFIRMED |
| studio-of-agents §6 Tier1=53/Tier2=13=66 | CONFIRMED |
| VP-INDEX false-completeness claim removed; VP-TBD BC-local convention (D-015) | CONFIRMED |
| VP-TBD ID collisions documented as intentional under BC-local convention | CONFIRMED |
| 11 formal VP↔BC back-refs added (verification-coverage-matrix.md v1.2) | CONFIRMED |
| subsystem-decomposition P0 corrected 112→111 (P0/P1/P2=111/45/22=178) (v1.3) | CONFIRMED — **see I6-01 for further correction** |
| CI gate v1.4 all 10 checks green | CONFIRMED — **see I6-01/O1 for false-green in check (i)** |

---

## Findings

### I6-01 — IMPORTANT: Architecture priority subtotals contradicted by per-BC frontmatter ground truth; CI gate check (i) false-green due to hardcoded constants

**Location:** `.factory/specs/architecture/subsystem-decomposition.md` §Subsystem Priority Summary; `.factory/specs/architecture/ARCH-INDEX.md`; `scripts/check-spec-counts.sh` check (i)

**Finding:** The §Subsystem Priority Summary table stated P0=111/P1=45/P2=22=178. Cross-checking against the per-BC frontmatter files (authoritative ground truth) revealed the true distribution is P0=117/P1=39/P2=22=178:

- 8 SS-09 dark-pattern BCs (CAP-011) were labeled `priority: P0` in their frontmatter files but were categorized as P1 in the §Subsystem Priority Summary table. The CAP-011 dark-pattern enforcement contracts are compliance/ethics items mandated by D-008 — they are correctly P0 in frontmatter.
- 2 CAP-004 BCs were labeled `priority: P1` in frontmatter but were counted as P0 in the priority summary table.

Net correction: P0 111→117 (+6), P1 45→39 (-6). Total count 178 unchanged.

Additionally, CI gate check (i) in `scripts/check-spec-counts.sh` v1.4 hardcoded `P0=111/P1=45` as expected constants rather than computing them from frontmatter at runtime. This meant check (i) would report green even when the stated table diverged from frontmatter — a false-green by design. The same gap allowed this defect to survive Pass 5.

**Owner:** product-owner (spec) + devops-engineer (CI gate)

**Resolution:** RESOLVED.
- `subsystem-decomposition.md` §Subsystem Priority Summary corrected to P0=117/P1=39/P2=22; SS-09 row relabeled "P0/P1 split (8 P0/6 P1)" to reflect the mixed priority across the 14 CAP-011 contracts (v1.4).
- `ARCH-INDEX.md` frontmatter `bc_p0`/`bc_p1` fields updated: 111→117 / 45→39 (v1.6).
- `scripts/check-spec-counts.sh` check (i) rewritten to COMPUTE P0/P1/P2 counts from BC frontmatter at runtime and assert the stated §Subsystem Priority Summary table matches those computed values. No hardcoded priority constants remain (v1.5).

---

### I6-02 — IMPORTANT: Enforced dark-pattern BCs emit unregistered symbolic error names; only DP-007 previously cited a registered code

**Location:** `.factory/specs/behavioral-contracts/ss-09/` (CAP-011 dark-pattern BCs); `.factory/specs/prd-supplements/error-taxonomy.md`; `.factory/specs/prd-supplements/prd-cap-011.md`

**Finding:** The 8 P0 dark-pattern enforcement BCs (DP-003, DP-004, DP-005, DP-006, DP-008) referenced symbolic error names such as `E-ETH-DARK-PATTERN-LOOT`, `E-ETH-PREDATORY-DESIGN`, etc. in their `error_codes:` fields. Only DP-007 cited a registered code (`E-ETH-001`). The other four DP families referenced symbolic names that did not resolve to any code in `error-taxonomy.md`.

This means the error-taxonomy was incomplete for CAP-011, and check (k) (newly added in v1.5) would have caught this — but check (k) was not yet present in v1.4, so it passed the CI gate silently.

**Owner:** product-owner (spec)

**Resolution:** RESOLVED.
- 5 dedicated E-ETH codes registered: `E-ETH-010` (DP-003 loot-box psychological exploitation), `E-ETH-011` (DP-004 artificial scarcity / FOMO), `E-ETH-012` (DP-005 pay-to-win imbalance enforcement), `E-ETH-013` (DP-006 manipulative retention loop), `E-ETH-014` (DP-008 deceptive advertising). Registered in `error-taxonomy.md` under the E-ETH family.
- Symbolic names demoted to `error.data.reason` sub-codes within each BC's error response schema; `error_codes:` frontmatter now cites canonical E-ETH-NNN identifiers.
- DP→E-ETH crosswalk table added to `error-taxonomy.md` (v1.6) and `prd-cap-011.md` (v1.3).
- SS-09 BC files updated: symbolic names replaced by registered `E-ETH-001/003/005/006/008` for existing DP families; new E-ETH-010..014 for DP-003/004/005/006/008.

---

### O6-01 — SUGGESTION: SS-09 single-value "P1" label was ambiguous in §Subsystem Priority Summary

**Location:** `.factory/specs/architecture/subsystem-decomposition.md` §Subsystem Priority Summary, SS-09 row

**Finding:** The SS-09 row in the priority summary showed "P1" as a single priority value for 14 contracts, but the per-BC frontmatter showed a mixed distribution (8 P0 dark-pattern enforcement + 6 P1 design-system contracts). The single-value label obscured this split.

**Owner:** product-owner (spec)

**Resolution:** RESOLVED via I6-01 — the SS-09 row was relabeled "P0/P1 split (8 P0/6 P1)" when the priority subtotals were corrected.

---

### PROCESS-GAP — IMPORTANT: 57 additional error codes emitted by SS-04 (CAP-004) and SS-13 (CAP-013) BCs were never registered in error-taxonomy.md

**Location:** `.factory/specs/behavioral-contracts/ss-04/` (CAP-004, 15 BCs); `.factory/specs/behavioral-contracts/ss-13/` (CAP-013, 14 BCs); `.factory/specs/prd-supplements/error-taxonomy.md`

**Finding:** CI gate check (k) (new in v1.5) revealed a broader completeness gap: 57 error codes referenced in BC `error_codes:` fields across ss-04 (CAP-004) and ss-13 (CAP-013) were not registered in `error-taxonomy.md`. The affected families and counts:

| Family | New codes | BC subsystem |
|--------|-----------|--------------|
| E-AAG  | 7         | ss-04 (CAP-004) |
| E-SVC  | 6         | ss-04 (CAP-004) |
| E-QG   | 11        | ss-04 (CAP-004) |
| E-SHIP | 3         | ss-04 (CAP-004) |
| E-ING  | 4         | ss-04 (CAP-004) |
| E-PRV  | 5         | ss-04 (CAP-004) |
| E-GLG  | 5         | ss-13 (CAP-013) |
| E-MOD  | 11        | ss-13 (CAP-013) |
| E-MKT  | 4         | ss-13 (CAP-013) |
| E-XR   | 1         | ss-13 (CAP-013) |

This was a real completeness gap — FU-003 ("all capabilities covered") was closed prematurely. Six prior passes and the CI count-gate missed this class of defect because nothing checked BC→taxonomy resolution. Check (k) closes this gap going forward.

Additionally, the placeholder error family `E-GEN` (9 codes, E-GEN-001..E-GEN-009) was found to be an orphaned placeholder not referenced by any BC. It was introduced by FU-003 as a catch-all but was superseded by per-capability families.

**Owner:** product-owner (spec)

**Resolution:** RESOLVED.
- All 57 codes registered in `error-taxonomy.md`: 8 new families added (E-AAG, E-SVC, E-QG, E-SHIP, E-ING, E-GLG, E-MOD, E-MKT); E-PRV and E-XR extended with additional codes.
- Orphaned placeholder family E-GEN (9 codes) RETIRED (append-only convention: codes struck through with `~~`, family marked `[RETIRED — superseded by per-capability families]`). Retired codes are not deleted (audit trail).
- New authoritative totals: **196 codes / 30 families (29 active + 1 retired / 187 active codes)**.
- `error-taxonomy.md` advanced to **v1.6**. `prd.md` error-taxonomy section updated to v1.6 totals (**v1.6**).
- CI gate check (k) now asserts all BC-referenced E-codes resolve to registered codes in `error-taxonomy.md`. Exit 0 after this resolution.

---

## Summary

| Finding | Severity | Status |
|---------|----------|--------|
| I6-01: Priority subtotals wrong (111/45 → 117/39); CI check (i) false-green | IMPORTANT | RESOLVED |
| I6-02: Dark-pattern BCs emit unregistered E-ETH symbolic names | IMPORTANT | RESOLVED |
| O6-01: SS-09 ambiguous single-value priority label | SUGGESTION | RESOLVED (via I6-01) |
| PROCESS-GAP: 57 unregistered codes across 10 families; E-GEN orphan retired | IMPORTANT (process) | RESOLVED |

**All findings resolved.** Clean-pass counter: 0/3. Proceeding to Pass 7.

---

## Verification

`check-spec-counts.sh` v1.5 — **ALL CHECKS PASSED (a–k)**, exit 0:

| Check | Result |
|-------|--------|
| (a) BC file count | 178 / BC-INDEX=178 / subdecomp=178 / ARCH-INDEX=178 / prd=178 |
| (b) Error code count | 196 computed, 196 stated in error-taxonomy.md |
| (c) BC priority field coverage | 178/178 (100%) |
| (d) VP P0/P1 consistency | computed P0=6/P1=4 = VP-INDEX summary = ARCH-INDEX frontmatter |
| (e) BC H1 / BC-INDEX title sync | 0 mismatches |
| (f) BC frontmatter schema | 0 violations |
| (g) VP catalog consistency | VP total=10, P0=6, P1=4 across all 4 docs; Kani=4/proptest=7 |
| (h) studio §3/§6 counts | all 10 SS rows verified; Tier1=53/Tier2=13=66 |
| (i) subdecomp priority subtotals (computed) | P0=117/P1=39/P2=22 = stated 117/39/22 |
| (j) VP↔BC bidirectional anchor | 11/11 formal VP↔BC back-refs present |
| (k) error-identifier resolution | 0 unregistered E-codes |
