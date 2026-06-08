---
document_type: adversarial-review
cycle: v0.1.0-greenfield
phase: 1d
pass: 3
date: 2026-06-08
verdict: FINDINGS
severity_summary: "1 critical / 4 important / 2 observation / 1 process-gap"
novelty: MEDIUM-HIGH
converged: false
clean_pass_count: 0
clean_passes_required: 3
---

# Phase-1d Adversarial Pass 3 — game-factory v0.1.0-greenfield

**VERDICT: FINDINGS** (1 critical, 4 important, 3 suggestion/observation) | Novelty: MEDIUM-HIGH | NOT CONVERGED

**Pass-2 count/anchor fixes re-verified CLEAN:** Grand total 179→178 correction, error-code total 134, priority 178/178, D-SEC anchor SS-06, DP-enforcement P0 CAP-011, "Bevy+Rapier" delexicalization, per-family error-code table, ADR-0006 degradation reconciliation — all held. New findings were in axes prior passes did not exercise: VP P0/P1 counts across VP-INDEX/ARCH-INDEX consistency, ARCH-INDEX risk mitigation SS-anchor correctness, dangling traces_to references, BC frontmatter schema completeness, BC H1↔INDEX title drift, and CI gate coverage gaps.

---

## Findings

| ID | Severity | Category | Location | Description | Owner | Resolution |
|----|----------|----------|----------|-------------|-------|------------|
| C1 | CRITICAL | count/consistency | `specs/verification-properties/VP-INDEX.md` L54 summary line; `specs/architecture/ARCH-INDEX.md` frontmatter | VP-INDEX.md summary line stated "Total: 10 VPs — 7 P0, 3 P1". ARCH-INDEX.md frontmatter stated `vp_p0: 6` and `vp_p1: 4`. VP-INDEX table rows counted 6 P0 rows and 4 P1 rows. Three-way inconsistency: VP-INDEX summary 7P0/3P1 vs ARCH-INDEX 6P0/4P1 vs actual table rows 6P0/4P1. | state-manager | RESOLVED: VP-INDEX.md summary line L54 corrected to "Total: 10 VPs — 6 P0, 4 P1". ARCH-INDEX.md frontmatter was already correct (vp_p0: 6, vp_p1: 4). VP-INDEX v1.2, ARCH-INDEX v1.4. All three sources now agree. |
| I1 | IMPORTANT | mis-anchor | `specs/architecture/ARCH-INDEX.md` Risk Register row R-017 | R-017 (kernel anti-cheat side-channel / rootkit risk) mitigation column cited SS-11 as the owning subsystem. SS-11 owns DI-011 (NFT/Web3). DI-010 (kernel anti-cheat never-author lint) is enforced by BC-1.15.002, which correctly targets SS-01 (Engine-Adapter Protocol). Wrong subsystem anchor in the risk register creates a false compliance trace. | architect | RESOLVED: ARCH-INDEX.md R-017 mitigation column corrected from SS-11 → SS-01. Mitigation note now cites BC-1.15.002 and VP-TBD-060/061. ARCH-INDEX v1.4. |
| I2 | IMPORTANT | dangling-ref | `specs/verification-properties/VP-INDEX.md` (multiple VP rows), `traces_to` fields across VPs | Several VP files and VP-INDEX rows contained `traces_to: verification-architecture.md` pointing to a file that did not exist. No verification-architecture document existed in `.factory/specs/architecture/`, making these traces non-resolving (dead references). | architect | RESOLVED: Authored `verification-architecture.md` (v1.0) defining the verification methodology, model-checking strategy, Kani/proptest scope, and VP-to-subsystem coverage model. Also authored `verification-coverage-matrix.md` (v1.0) mapping each VP to its owning subsystem, formal method, phase, and BC traces. Both files registered in ARCH-INDEX.md §6 (new "Verification Documents" section). All traces_to references now resolve. |
| I3 | IMPORTANT | schema-gap | `specs/behavioral-contracts/ss-04/` (all 15 BC files) | All 15 BCs under ss-04 (Asset Generation subsystem) used a stripped frontmatter schema — missing required fields: `version:`, `status:`, `producer:`, `timestamp:`, `phase:`, `inputs:`, `lifecycle_status:`. The ss-04 files used a minimalist 4-field frontmatter (subsystem/capability/priority/contract_id only). This violates the canonical BC schema established in Pass-1 (all other subsystems normalized to full schema). | PO | RESOLVED: All 15 ss-04 BC files normalized to canonical frontmatter schema. `traces_to` field also corrected to `domain-spec/L2-INDEX.md` (ss-04 files had a stale `traces_to: domain-spec/capabilities.md` reference). |
| I4 | IMPORTANT | title-drift | `specs/behavioral-contracts/BC-INDEX.md` (2 rows) | Two BC H1 headings diverged from their BC-INDEX title-column entries: (1) BC-1.15.002 H1 read "Kernel Anti-Cheat Never-Author Lint Gate" but BC-INDEX title column read "Kernel AC Exclusion Lint Gate"; (2) BC-4.03.004 H1 included a ship-block clause suffix that was absent from the BC-INDEX title column. In both cases the INDEX title was the shortened/incorrect version. | PO | RESOLVED: BC-INDEX.md rows for BC-1.15.002 and BC-4.03.004 updated to match their respective H1 titles exactly. BC-INDEX v1.4. |
| O1 | OBSERVATION | thesis-consistency | `specs/behavioral-contracts/ss-01/` (4 BC bodies), `specs/behavioral-contracts/ss-06/` (multiple BCs) | Engine names "Bevy" and "Rapier" appear in 4 L3 BC bodies under ss-01 and ss-06 as illustrative examples within adapter-behavior descriptions. DI-008 (engine-neutrality) was previously confirmed to apply to Layer-1/Layer-2 core+spec artifacts. L3 adapter-behavior BCs describe how a specific adapter must behave — naming the target engine is arguably the correct level of specificity for that layer. | architect | ADJUDICATED IN-BOUNDS by orchestrator: DI-008 engine-neutrality scope is Layer-1/Layer-2 core+spec artifacts only. L3 adapter-behavior BCs may name specific engines as illustrative examples because adapters are by definition engine-specific. No change to BC files. Decision recorded as D-014. Flagged for human ratification at Phase-1 gate. |
| O2 | OBSERVATION | spec-gap | `specs/behavioral-contracts/ss-04/` (all 15 BCs) | ss-04 BCs lacked `validation_method:` frontmatter field — no declared mechanism for how each BC would be verified. Other subsystems' BCs (especially ethics/compliance BCs) used the Verification Properties section as the validation declaration mechanism rather than a separate frontmatter field. | PO | RESOLVED via I3: Normalized ss-04 BCs to canonical schema (which does not include a `validation_method:` frontmatter field — this is not a required field per schema). DI-012 traceability row added to ss-04 BC L2-invariants traces section where applicable. Validation declared via the `Verification Properties` subsection within each BC body, consistent with ethics and compliance BCs. |
| O3 | OBSERVATION (process-gap) | ci-coverage | `scripts/check-spec-counts.sh` (v1.1), `.github/workflows/ci.yml` | CI count-gate (v1.1) covered 3 checks: (a) BC file count, (b) error-code count, (c) priority-field coverage. Three new defect classes found in Pass-3 (VP P0/P1 consistency, BC title sync, BC frontmatter schema) were not covered by the CI gate. These classes would re-emerge after any future spec edit without detection. | devops-engineer | RESOLVED at root cause: `check-spec-counts.sh` extended to v1.2 with 3 new checks: (d) VP P0/P1 count consistency (VP-INDEX summary line vs table rows vs ARCH-INDEX frontmatter), (e) BC H1↔BC-INDEX title sync (substring containment check, case-insensitive), (f) BC frontmatter-schema uniformity (required 6-field schema check). ALL 6 CHECKS GREEN after I3/I4 fixes. |

---

## Resolution Summary

| Finding | Artifact Changed | New Version |
|---------|-----------------|-------------|
| C1 — VP-INDEX summary "7 P0, 3 P1" → "6 P0, 4 P1" | `VP-INDEX.md` | VP-INDEX v1.2 |
| I1 — ARCH-INDEX R-017 mitigation SS-11 → SS-01 | `ARCH-INDEX.md` | ARCH-INDEX v1.4 |
| I2 — dangling traces_to to verification-architecture.md | `verification-architecture.md` (new v1.0), `verification-coverage-matrix.md` (new v1.0), `ARCH-INDEX.md` §6 | verification-architecture v1.0, verification-coverage-matrix v1.0, ARCH-INDEX v1.4 |
| I3 — ss-04 BCs stripped frontmatter normalized | 15 BC files under `ss-04/` | (15 files updated) |
| I4 — BC H1↔INDEX title drift (2 BCs) | `BC-INDEX.md` rows for BC-1.15.002 and BC-4.03.004 | BC-INDEX v1.4 |
| O1 — engine names in L3 adapter BCs | No change — ADJUDICATED IN-BOUNDS; D-014 recorded | — |
| O2 — ss-04 BCs missing validation_method | Resolved via I3 frontmatter normalization; validation declared in BC body per canonical pattern | ss-04 BCs updated |
| O3 — CI gate coverage gaps | `scripts/check-spec-counts.sh` extended to v1.2 (+3 checks) | check-spec-counts.sh v1.2 |

### Post-Resolution Metrics

| Metric | After Pass 2 | After Pass 3 |
|--------|-------------|-------------|
| PRD version | v1.3 | v1.3 (unchanged) |
| BC-INDEX version | v1.3 | v1.4 |
| Error-taxonomy version | v1.3 | v1.3 (unchanged) |
| Error families | 22 | 22 (unchanged) |
| Error codes (actual) | 134 | 134 (unchanged) |
| BCs total | 178 | 178 (unchanged) |
| BC priority coverage | 178/178 (100%) | 178/178 (100%) |
| VP-INDEX version | v1.1 | v1.2 |
| VP P0/P1 (corrected) | 7P0/3P1 (wrong) | 6 P0, 4 P1 (correct) |
| ARCH-INDEX version | v1.3 | v1.4 |
| ADR-0006 version | v1.1 | v1.1 (unchanged) |
| Methodology-layer version | v1.2 | v1.2 (unchanged) |
| Subsystem-decomposition version | v1.2 | v1.2 (unchanged) |
| verification-architecture.md | absent | v1.0 (new) |
| verification-coverage-matrix.md | absent | v1.0 (new) |
| CI count-gate checks | 3 (a/b/c) | 6 (a/b/c/d/e/f) — GREEN |

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

--- (d) VP P0/P1 count consistency ---
    Computed P0 (VP-INDEX table rows): 6
    Computed P1 (VP-INDEX table rows): 4
    Stated P0 (VP-INDEX summary line): 6
    Stated P1 (VP-INDEX summary line): 4
    Stated P0 (ARCH-INDEX vp_p0):      6
    Stated P1 (ARCH-INDEX vp_p1):      4

  OK [VP P0 / VP-INDEX summary line]: 6 == 6  (VP-INDEX.md)
  OK [VP P1 / VP-INDEX summary line]: 4 == 4  (VP-INDEX.md)
  OK [VP P0 / ARCH-INDEX frontmatter]: 6 == 6  (ARCH-INDEX.md)
  OK [VP P1 / ARCH-INDEX frontmatter]: 4 == 4  (ARCH-INDEX.md)

--- (e) BC H1 <-> BC-INDEX title sync ---
    BC files checked against BC-INDEX: 178
    Title mismatches found: 0

--- (f) BC frontmatter-schema uniformity ---
    BC files checked for schema fields: 178
    BC files with schema violations: 0

=== SUMMARY ===
ALL CHECKS PASSED

  BC files (computed):               178
  Error codes (computed):            134
  Priority coverage:                 178 / 178 (100%)
  VP P0 (computed from table):       6
  VP P1 (computed from table):       4
  BC H1/INDEX title sync:            178 checked, 0 mismatches
  BC frontmatter schema:             178 checked, 0 violations
```

Exit code: 0 — ALL CHECKS PASSED (check-spec-counts.sh v1.2, 6 checks)

---

## Pass 3 Status

- Clean pass: NO (1C / 4I / 3 obs-suggestion findings raised)
- All findings resolved: YES
- Clean-pass counter: 0/3 (Pass 3 had findings; no clean pass credit)
- Next action: Phase-1d Pass 4 (fresh-context re-review; same scope). First candidate for a clean pass. Need 3 consecutive clean passes.
