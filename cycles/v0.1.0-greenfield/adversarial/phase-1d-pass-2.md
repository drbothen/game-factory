---
document_type: adversarial-review
cycle: v0.1.0-greenfield
phase: 1d
pass: 2
date: 2026-06-08
verdict: FINDINGS
severity_summary: "3 critical / 4 important / 3 suggestion"
novelty: HIGH
converged: false
clean_pass_count: 0
clean_passes_required: 3
---

# Phase-1d Adversarial Pass 2 — game-factory v0.1.0-greenfield

**VERDICT: FINDINGS** (3 critical, 4 important, 3 suggestion) | Novelty: HIGH | NOT CONVERGED

**Pass-1 content fixes re-verified CLEAN:** JSON-RPC collision resolution, DP-mapping alignment, E-PRV family definition, VP-TBD resolution table, D-013 creative-gate disambiguation, dir→subsystem alias table — all held. New findings are in the count/anchor integrity drift class (partial-fix regression category).

---

## Findings

| ID | Severity | Category | Location | Description | Owner | Resolution |
|----|----------|----------|----------|-------------|-------|------------|
| C2-01 | CRITICAL | count | `specs/behavioral-contracts/BC-INDEX.md`, `specs/prd.md`, `specs/architecture/subsystem-decomposition.md`, `specs/architecture/ARCH-INDEX.md` | Grand total stated as 179 BCs; actual BC file count is 178. The 179 figure erroneously counted BC-INDEX.md itself as a BC file. | state-manager | RESOLVED: corrected to 178 in BC-INDEX.md, prd.md, subsystem-decomposition.md, ARCH-INDEX.md |
| C2-02 | CRITICAL | count | `specs/prd-supplements/error-taxonomy.md`, `specs/prd.md` | Error-code total stated as 143 (Pass-1 stated) or 141 (inconsistent secondary reference); actual distinct E-FAMILY-NNN identifiers: 134. Overcounting traced to family-summary table rows and change-note lines being included in manual tallies. | PO | RESOLVED: corrected to 134 in error-taxonomy.md and prd.md |
| C2-03 | CRITICAL | count | `specs/behavioral-contracts/` (all BCs), `specs/prd.md` | prd.md claim "all 179 BCs have priority field" was false: (a) stated total was wrong (179 vs 178), (b) only 134 of the 178 BC files had the priority field backfilled after Pass-1 S1 partial fix; 44 BCs remained without a `priority:` frontmatter field. | PO | RESOLVED: 44 BC files backfilled with appropriate P0/P1/P2 priority; now 178/178 have priority |
| I2-01 | IMPORTANT | mis-anchor | `specs/architecture/subsystem-decomposition.md`, `specs/behavioral-contracts/` | D-SEC subsystem anchor cited as SS-04 (in subsystem-decomposition narrative) and SS-02 (in a secondary reference); the BCs for D-SEC server-authority enforcement (BC-7.11.002..008) correctly target SS-06. Three-way inconsistency: SS-04 / SS-02 / SS-06 for the same logical subsystem role. | architect | RESOLVED: methodology-layer D-SEC anchor corrected to SS-06 throughout; SS-04/SS-02 phantom references removed |
| I2-02 | IMPORTANT | contradiction | `specs/prd-supplements/prd-cap-011.md`, `specs/behavioral-contracts/BC-INDEX.md`, BC frontmatter for CAP-011 BCs | DP-enforcement priority conflict: prd-cap-011 stated compliance-critical CAP-011 BCs as P0; BC-INDEX priority column showed P1 for the same BCs; BC frontmatter files also showed P1. Three sources, two values. | PO | RESOLVED: authoritative P0 set for all compliance-critical CAP-011 BCs; prd-cap-011, BC-INDEX priority column, and BC frontmatter files updated to P0 consistently |
| I2-03 | IMPORTANT | count | `specs/prd.md` §1.0 summary section | prd.md §1.0 summary still read "170 BCs" (the pre-Pass-1 total), while body sections correctly reflected 178 after count corrections in C2-01. Header/body count divergence within the same file. | PO | RESOLVED: prd.md §1.0 updated to 178 |
| I2-04 | IMPORTANT | thesis-leak | `specs/architecture/methodology-layer.md` Layer-2 section | The string "Bevy+Rapier" appeared in methodology-layer.md within the Layer-2 description, naming a concrete engine pair in a layer that must remain engine-agnostic (DI-008). This violates the founding engine-agnostic thesis. DI-008 itself was intact but the prose example leaked implementation-specific names. | architect | RESOLVED: "Bevy+Rapier" delexicalized to generic engine-adapter vocabulary; DI-008 intact and unmodified |
| S2-01 | SUGGESTION | auditability | `specs/prd-supplements/error-taxonomy.md` | Error-taxonomy total count was unauditable: the file listed families and codes but provided no per-family code-count subtotal table, making it impossible to verify the stated total without manually re-counting every code identifier. | PO | RESOLVED: per-family code-count summary table added (columns: Family, Code Range, Count); all family subtotals sum to 134 |
| S2-02 | SUGGESTION | process-gap | `scripts/` (new), `.github/workflows/ci.yml` | No automated count-consistency gate existed; count drift (C2-01, C2-02, C2-03) could recur without detection. Manual spec reviews are the only backstop — insufficient for a spec corpus of this size. | devops-engineer | RESOLVED at root cause: `scripts/check-spec-counts.sh` created (v1.1); wired into CI lint job as "Spec count consistency (S2-02)" step; verifies BC file count, error-code count, and priority-field coverage against stated totals; exits non-zero on any drift. Currently GREEN (BC=178, error codes=134, priority 178/178). |
| S2-03 | SUGGESTION | spec-alignment | `specs/architecture/adrs/ADR-0006.md`, `specs/architecture/methodology-layer.md` | ADR-0006 degradation semantics mismatched methodology-layer: ADR-0006 described a degradation path that methodology-layer did not acknowledge; the methodology layer described online-build behavior as always-full, which contradicted ADR-0006's offline degradation path. Two authoritative documents with different models for the same runtime behavior. | architect | RESOLVED: ADR-0006 reconciled to match methodology-layer: online builds = no degradation (full pipeline always available); offline-only path = graceful degradation as described in ADR-0006; distinction now explicit in both documents |

---

## Resolution Summary

| Finding | Artifact Changed | New Version |
|---------|-----------------|-------------|
| C2-01 — grand total 179→178 | `BC-INDEX.md`, `prd.md`, `subsystem-decomposition.md`, `ARCH-INDEX.md` | BC-INDEX v1.3 / prd.md v1.3 / subsystem-decomp v1.2 / ARCH-INDEX v1.3 |
| C2-02 — error-code total 143/141→134 | `error-taxonomy.md`, `prd.md` | error-taxonomy v1.3 / prd.md v1.3 |
| C2-03 — priority 134/178→178/178 | 44 BC frontmatter files | (44 files updated) |
| I2-01 — D-SEC SS-04/SS-02→SS-06 | `methodology-layer.md`, `subsystem-decomposition.md` | methodology-layer v1.2 |
| I2-02 — DP-enforcement priority P0 CAP-011 | `prd-cap-011.md`, `BC-INDEX.md`, CAP-011 BC frontmatter | prd-cap-011 updated / BC-INDEX v1.3 |
| I2-03 — prd.md §1.0 "170 BCs"→"178 BCs" | `prd.md` | prd.md v1.3 |
| I2-04 — "Bevy+Rapier" delexicalized | `methodology-layer.md` | methodology-layer v1.2 |
| S2-01 — per-family code-count table | `error-taxonomy.md` | error-taxonomy v1.3 |
| S2-02 — CI count-gate | `scripts/check-spec-counts.sh` (new v1.1), `.github/workflows/ci.yml` | new file / ci.yml updated |
| S2-03 — ADR-0006 degradation reconciled | `ADR-0006.md`, `methodology-layer.md` | ADR-0006 v1.1 / methodology-layer v1.2 |

### Post-Resolution Metrics

| Metric | After Pass 1 | After Pass 2 |
|--------|-------------|-------------|
| PRD version | v1.2 | v1.3 |
| Error-taxonomy version | v1.2 | v1.3 |
| Error families | 22 | 22 (unchanged) |
| Error codes (actual) | 143 (stated, overcounted) | 134 (verified correct) |
| BCs total | 179 (stated, overcounted) | 178 (verified correct) |
| BC priority coverage | partial (S1 incomplete) | 178/178 (100%) |
| ADR-0006 version | v1.0 | v1.1 |
| Methodology-layer version | v1.1 | v1.2 |
| BC-INDEX version | v1.2 | v1.3 |
| ARCH-INDEX version | v1.2 | v1.3 |
| CI count-gate | absent | GREEN (scripts/check-spec-counts.sh wired) |

---

## Verification

```
=== check-spec-counts.sh — game-factory spec consistency ===

--- (a) Behavioral Contract file count ---
    Computed BC file count: 178
    Stated in BC-INDEX.md:               178
    Stated in subsystem-decomposition.md: 178
    Stated in ARCH-INDEX.md:              178
    Stated in prd.md:                     178

  OK [BC total / BC-INDEX]: 178 == 178  (BC-INDEX.md)
  OK [BC total / subsystem-decomp]: 178 == 178  (subsystem-decomposition.md)
  OK [BC total / ARCH-INDEX]: 178 == 178  (ARCH-INDEX.md)
  OK [BC total / prd.md]: 178 == 178  (prd.md)
--- (b) Error code count ---
    Computed error code count: 134
    Stated in error-taxonomy.md: 134

  OK [Error code total / error-taxonomy]: 134 == 134  (error-taxonomy.md)
--- (c) BC priority field coverage ---
    BC files with priority: field:    178 / 178
    BC files missing priority: field: 0

=== SUMMARY ===
ALL CHECKS PASSED

  BC files (computed):     178
  Error codes (computed):  134
  Priority coverage:       178 / 178 (100%)
```

Exit code: 0 — ALL CHECKS PASSED

---

## Pass 2 Status

- Clean pass: NO (10 findings raised)
- All findings resolved: YES
- Clean-pass counter: 0/3 (Pass 2 had findings; no clean pass credit)
- Next action: Phase-1d Pass 3 (fresh-context re-review; same scope). Need 3 consecutive clean passes.
