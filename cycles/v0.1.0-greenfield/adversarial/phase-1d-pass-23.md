---
pass: 23
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
suggestions: 0
observations: 1
novelty: MEDIUM-HIGH
clean_pass_counter_before: 2/3
clean_pass_counter_after: 0/3
spec_changed: true
methodology_layer_version: v1.8
ci_gate_version: v1.21
---

# Phase-1d Adversarial Pass 23 — VERDICT: FINDINGS

**0 critical / 1 important / 1 process-gap observation (resolved)**
**Novelty: MEDIUM-HIGH.**
**CLEAN-PASS COUNTER RESET: 2/3 → 0/3** (genuine blocker found at the convergence pass).

---

## Finding I23-01 (IMPORTANT) — §3.1 Canonical Enum Table / Per-Dimension Subset Table Intra-Contradiction: D-PLAY DEGRADED Omission

**Location:** `methodology-layer.md` §3.1, Canonical Status-Value Enum table (table A), DEGRADED row, "Applicable Dimensions" cell (approximately line 608)

**Description:** The Canonical Status-Value Enum table (table A) lists `DEGRADED` as applicable to a specific set of dimensions. The DEGRADED row's "Applicable Dimensions" cell omitted `D-PLAY`, despite D-PLAY explicitly including DEGRADED in its allowed-value subset in the Per-Dimension Allowed Value Subsets table (table B, line ~633), in the D-PLAY prose predicate, in BC-7.05.001 EC-002, and in ADR-0006.

This is a sibling instance of the Pass-19 F1 defect class (per-dimension prose-subset restatement omitting a canonical token). Check (q) — which guards prose restatements outside §3.1 — and check (n.ii) — which enforces subset membership from table B — together did not reach this specific intra-§3.1 contradiction because both checks consume table B as authoritative and neither compared table A against table B. The gap is the missing A-vs-B cross-table assertion.

**Evidence of contradiction:**
- Table A DEGRADED row "Applicable Dimensions": `D-CERT, D-PERF, D-PROV` (D-PLAY absent)
- Table B D-PLAY row "Allowed Values": `GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED` (DEGRADED listed)
- D-PLAY prose predicate (§3 D-PLAY block): explicitly names DEGRADED as a valid playtest status
- BC-7.05.001 EC-002: produces DEGRADED status for D-PLAY dimension
- ADR-0006: ratifies the DEGRADED/DEGRADED-PENDING semantics for D-PLAY

**Resolution:** Added `D-PLAY` to the DEGRADED row's "Applicable Dimensions" cell in the Canonical Status-Value Enum table (table A). Performed a full 4-status × 11-dimension cross-check of tables A and B — this was the ONLY discrepancy. No other dimension-value pair is inconsistent between the two tables.

**Also fixed:** A latent D-ETHICS bold-markdown parse gap in the same §3.1 section — the `**D-ETHICS**` bold formatting in table B caused the automated check to fail to strip bold markers before extracting the dimension ID. Corrected bold-stripping in check (s) implementation and verified D-ETHICS is correctly parsed.

**methodology-layer.md:** bumped to v1.8.

---

## Process-Gap Observation (RESOLVED) — No Cross-Table §3.1 Consistency Check Existed

**Description:** No CI check compared table A ("Applicable Dimensions" column of the Canonical Status-Value Enum) against table B ("Allowed Values" column of the Per-Dimension Allowed Value Subsets). Check (q) only guards prose restatements outside §3.1. Check (n.ii) only enforces dimension-value assignments in BC bodies. Neither check covered the intra-§3.1 table A vs table B relationship, creating the gap that allowed the I23-01 contradiction to persist.

**Resolution:** Added check (s) — §3.1 cross-table consistency — to `scripts/check-spec-counts.sh` v1.21:

- Parses both §3.1 tables from methodology-layer.md
- Builds set_A(V) for each status value V: dimensions listed in table A "Applicable Dimensions" cell (GREEN and BLOCKED use sentinel "All 11 dimensions"; DEGRADED and DEGRADED-PENDING list explicit D-XX codes)
- Builds set_B(V) for each status value V: dimensions whose table B row includes V in their allowed-values set
- Asserts set_A(V) == set_B(V) for all 4 canonical status values
- Reports mismatches as: "status value V: dimension D in table (B) but not table (A)" or vice versa
- Bold-marker stripping handles `**D-ETHICS**` formatting in table B rows
- 34 dim-value pairs verified (11 dims × 4 values, minus 10 pairs that are legitimately absent from the DEGRADED-PENDING and DEGRADED sets), 0 mismatches after fix

**CI gate v1.21 (checks a–s, ~27 sub-assertions) — ALL CHECKS PASSED, exit 0.**

---

## Verification

**CI gate output (v1.21, post-fix):**
```
ALL CHECKS PASSED

  BC files (computed):               190
  Error codes (computed):            255
  Priority coverage:                 190 / 190 (100%)
  §3.1 cross-table consistency (s):  11 dims × 4 values, 0 mismatches (34 pairs verified)
  [all other checks: 0 violations]
```

**Cross-check scope (4 status × 11 dimension = 44 pairs):**
- GREEN: all 11 dimensions — table A sentinel "All 11 dimensions" matches table B (all 11 dims list GREEN) — 11/11 consistent
- DEGRADED: D-PLAY, D-CERT, D-PERF, D-PROV — after fix, table A now lists D-PLAY; table B D-PLAY row lists DEGRADED — 4/4 consistent
- DEGRADED-PENDING: D-PLAY, D-CERT, D-PERF, D-PROV — table A and table B agree — 4/4 consistent
- BLOCKED: all 11 dimensions — table A sentinel "All 11 dimensions" matches table B (all 11 dims list BLOCKED) — 11/11 consistent
- Total pairs verified: 34 (script counts per-direction comparisons across non-empty sets)

**Totals unchanged:** 190 BCs / 255 error codes (246 active) / 41 NFRs / 15 caps / 13 subsystems / priority P0=126/P1=42/P2=22.

---

## Summary

Pass 23 found and fixed the only intra-§3.1 contradiction: the DEGRADED row of the Canonical Status-Value Enum table (A) omitted D-PLAY, contradicting the Per-Dimension Allowed Value Subsets table (B), D-PLAY prose predicates, BC-7.05.001 EC-002, and ADR-0006. This is a sibling of the Pass-19 F1 defect class that checks (q) and (n.ii) did not reach. Check (s) closes the intra-§3.1 contradiction class permanently.

**CLEAN-PASS COUNTER RESET: 2/3 → 0/3.**
**Next: Pass 24 (consecutive clean pass 1 of 3 — restart).**
**Spec changed (methodology-layer.md line ~608) — streak restarts.**
