---
document_type: adversarial-review
cycle: v0.1.0-greenfield
phase: 1d
pass: 4
date: 2026-06-08
verdict: FINDINGS
severity_summary: "2 critical / 4 important / 5 observation/process-gap"
novelty: MODERATE-HIGH
converged: false
clean_pass_count: 0
clean_passes_required: 3
---

# Phase-1d Adversarial Pass 4 — game-factory v0.1.0-greenfield

**VERDICT: FINDINGS** (2 critical, 4 important, 5 observation/process-gap) | Novelty: MODERATE-HIGH | NOT CONVERGED

**Pass-3 fixes re-verified CLEAN:** VP-INDEX P0/P1 correction (6/4), ARCH-INDEX R-017 SS-anchor (SS-01), dangling traces_to references (verification-architecture.md + verification-coverage-matrix.md now exist), ss-04 BC frontmatter normalization, BC-INDEX title-drift fixes (BC-1.15.002 + BC-4.03.004), CI gate v1.2 (6 checks a-f) — all held. New findings were in under-audited artifacts: studio-of-agents roster arithmetic, the two new verification docs' per-tool counts, error-taxonomy stale residual total line, nfr-catalog Source column, and CI gate stale comments.

---

## Findings

| ID | Severity | Category | Location | Description | Owner | Resolution |
|----|----------|----------|----------|-------------|-------|------------|
| C1 | CRITICAL | count/consistency | `specs/architecture/studio-of-agents.md` §1, §2 table, §3 per-SS listings | Three-way roster count contradiction. §1 stated "14 REUSE / 18 ADAPT / 34 NEW = 66 total". Main agent table (§2) counted 57 NEW rows and 9 ADAPT rows (66 game-discipline roles). §3 per-SS running total stated "55 NEW / 16 ADAPT". Additionally §3 SS-04 listed 6 ADAPT entries but SS-04 architectural scope has 3 game-discipline ADAPTs; SS-08 listed 8 NEW but should be 10; SS-11 listed 8 NEW but should be 11. No consistent canonical count existed across the document. | architect | RESOLVED: Canonical composition set to **57 NEW + 9 ADAPT = 66 game-discipline roles**. The 14 REUSE vsdd-infra agents (orchestrator, state-manager, etc.) operate OUTSIDE the 66-count and are not in the studio roster table — they are infrastructure. §1 intro paragraph corrected to "57 NEW / 9 ADAPT = 66 game-discipline roles (14 vsdd-infra agents operate outside this count)". §2 table grand-total row verified: 57N + 9A = 66. §3 per-SS running total corrected to "57N / 9A"; latent per-SS errors also fixed (SS-04 ADAPT 6→3, SS-08 NEW 8→10, SS-11 NEW 8→11). studio-of-agents v1.1, ARCH-INDEX v1.5 (studio_roles: 66). |
| C2 | CRITICAL | count/consistency | `specs/architecture/verification-coverage-matrix.md` tool-summary table | Kani row stated count "3" but the Kani VP list in the same row enumerated VP-001, VP-002, VP-004, VP-008 — four distinct VPs. Count "3" also contradicted verification-architecture.md Kani VP Targets (4 VPs) and ARCH-INDEX check-g canonical expectation of 4. Both the table count cell and the narrative summary paragraph containing "Kani: 3" required correction. | architect | RESOLVED: verification-coverage-matrix.md Kani count corrected to **4** in both occurrences (tool-summary table count cell and narrative summary paragraph). All three sources now agree: verif-arch=4, verif-matrix=4, check-g expected=4. verification-coverage-matrix v1.1. |
| I1 | IMPORTANT | mis-anchor | `specs/architecture/studio-of-agents.md` §3 security-engineer role | security-engineer role anchored to SS-05 (Analytics) in the per-SS role listing. The principal artifact guarded by security-engineer is the server-authority-invariant-suite (BC-7.11.002..008), which belongs to SS-06 (Multiplayer/Networking). SS-05 has no security-specific BCs or VPs. This creates a false compliance trace between the role and its primary artifact cluster. | architect | RESOLVED: security-engineer role moved from SS-05 to SS-06 in §3. §3 SS-05 role count decremented by 1; §3 SS-06 role count incremented by 1. studio-of-agents v1.1 (bundled with C1 resolution). |
| I2 | IMPORTANT | spec-gap | `specs/architecture/studio-of-agents.md` §2 role table — roles 55/56/57 (security-engineer, anti-cheat-integrator, moderation-ops) | Roles 55, 56, and 57 carried no activation_tier column entry — left blank or omitted. All other 54 roles carried explicit Tier 1 or Tier 2 designations per the methodology-layer tier model. These three late-added roles (added during Pass-1 resolution) were never backfilled with tier assignments, breaking the invariant "all 66 roles partitioned by activation tier". The tier model (Tier 1 = always active from game-loop start; Tier 2 = activated when the relevant gameplay system is in scope) applies to all studio roles. | architect | RESOLVED: security-engineer→Tier 1 (always active; security must be on from day 1 of any pipeline run), anti-cheat-integrator→Tier 2 (activated when a multiplayer/competitive module is in scope), moderation-ops→Tier 2 (activated when user-generated content or community systems are in scope). Tier totals now: 51 Tier 1 + 15 Tier 2 = 66. studio-of-agents v1.1. |
| I3 | IMPORTANT | count/consistency | `specs/prd-supplements/error-taxonomy.md` summary table (pre-v1.4) | A stale contradictory total line remained from v1.1 era: "**Total: 137 error codes / 21 families**" — conflicting with the canonical v1.3 corrected total "**Total: 134 error codes / 22 families**". Two total lines co-existed in the document. Additionally a historical note about E-ETH was ambiguous: it stated "8 codes at v1.1" but the family grew; the current count (9 codes) was not made explicit. | PO | RESOLVED: Stale "137/21" total line removed. Single authoritative total line now reads "**Total: 134 error codes / 22 families (v1.4)**". E-ETH historical note clarified: "E-ETH had 8 codes at v1.1; current count is 9 (E-ETH-001..009)". error-taxonomy v1.4. |
| I4 | IMPORTANT | spec-gap | `specs/prd-supplements/nfr-catalog.md` — NFR-020 through NFR-035 (rows 21–35) | NFR-020 through NFR-035 (the 16 NFRs added in prd-revision via FU-002) all had an empty Source column. The Source column maps each NFR to its originating supplement section (prd-cap-*.md or a named FU). NFR-001..019 all carried "PRD §CAP-NNN" or equivalent Source values. The 16 new entries were left blank, breaking the traceability chain from NFR to supplement. | PO | RESOLVED: All 35 rows now carry a Source value. NFR-020..035 mapped to "prd-supplement §FU-002" (the supplement section that introduced numeric NFR targets for CAP-001–003, 006–007, 009–011, 013–014). nfr-catalog v1.2. |
| O1 | OBSERVATION (process-gap) | ci-coverage | `scripts/check-spec-counts.sh` v1.2 | CI gate did not validate per-tool arithmetic in the two new verification docs (C2 defect class). Kani count "3 vs 4" discrepancy would not have been caught by any existing check. Without check-g, the same class of per-tool count drift would re-emerge after any future edit to either verification doc. | devops-engineer | RESOLVED: check-spec-counts.sh extended to v1.3 with check (g) — VP catalog consistency across VP-INDEX + verification-architecture.md + verification-coverage-matrix.md + ARCH-INDEX frontmatter (total=10, P0/P1=6/4, Kani=4, proptest=7). ALL CHECKS PASSED (checks a-g, exit 0). |
| O2 | OBSERVATION (process-gap) | ci-coverage | `scripts/check-spec-counts.sh` v1.2 — internal comments | Script contained stale "EXPECTED TO FAIL — fix after I3" and "TODO: remove after pass-3" comments referring to pass-3 remediation that was already complete. These comments created false audit trail noise and could mislead future maintainers about what the script tests. | devops-engineer | RESOLVED: Stale comments removed. check-spec-counts.sh v1.3 (bundled with O1 resolution). |
| O3 | OBSERVATION (human-gate awareness) | dtu-framing | `specs/architecture/dtu-assessment.md` DTU-01..10 enumeration vs `specs/product-brief.md` §10 service list | DTU clone set (DTU-01..10 including Nakama, C2PA provenance, etc.) differs from the product-brief §10 enumeration of the 10 external services. Both lists enumerate 10 services but the names and groupings differ — e.g., the brief lists "compliance-ai-disclosure" as a single service while the DTU assessment splits it into separate provenance-sidecar + IARC clones. The DTU assessment's split is internally coherent with the architecture, but the framing divergence could cause confusion at the human gate. | human (gate) | FLAGGED for human gate awareness. No spec change required — DTU-01..10 enumeration is authoritative (post-architecture); product-brief §10 is the pre-architecture intent list. Discrepancy is expected and legitimate. Human should confirm at Phase-1 gate that DTU-01..10 is the operative enumeration. |
| O4 | OBSERVATION (re-verification) | thesis-consistency | `specs/architecture/adapter-protocols.md` — four-seam architecture | Four-seam architecture re-verified: exactly 4 adapter seams enumerated (engine-runtime, asset-generation, compliance, distribution). Each seam has 2 contract schemas = 8 total. Engine seam carries 8 declared capabilities (per adapter-protocols.md §2.1) while the other three seams carry fewer capabilities each — this asymmetry is architectural design intent (engine adapters are the most complex seam), not a defect. | architect | CLEAN — re-verified. No action required. |
| O5 | OBSERVATION (re-verification) | carryover-invariants | Multiple specs — D-010..D-013 adjudications; BC-1.15.002; BC-13.01.004 | D-010 (kernel anti-cheat never-author lint), D-011 (NFT/Web3 off-by-default), D-012 (playtest_delegation_note schema field), D-013 (creative-gate directed=true distinct from external-human-gate), BC-1.15.002 pattern list, BC-13.01.004 cert path — all re-checked. | architect | CLEAN — all carryover invariants held. No action required. |

---

## Resolution Summary

| Finding | Artifact Changed | New Version |
|---------|-----------------|-------------|
| C1 — studio roster 3-way contradiction (§1 14R/18A/34N, §2 57N+9A, §3 55N/16A) | `studio-of-agents.md` §1/§2/§3; `ARCH-INDEX.md` frontmatter studio_roles | studio-of-agents v1.1, ARCH-INDEX v1.5 |
| C2 — verification-coverage-matrix Kani count "3" → "4" | `verification-coverage-matrix.md` tool-summary table + narrative paragraph | verification-coverage-matrix v1.1 |
| I1 — security-engineer role anchor SS-05 → SS-06 | `studio-of-agents.md` §3 SS-05/SS-06 counts | studio-of-agents v1.1 (bundled with C1) |
| I2 — roles 55/56/57 tier assignments backfilled (Tier 1/2/2) | `studio-of-agents.md` §2 role table tier column | studio-of-agents v1.1 (bundled with C1) |
| I3 — error-taxonomy stale "137/21" total line removed; single canonical "134/22" | `error-taxonomy.md` summary table | error-taxonomy v1.4 |
| I4 — nfr-catalog NFR-020..035 Source column populated (§FU-002) | `nfr-catalog.md` rows 21–35 | nfr-catalog v1.2 |
| O1 — CI gate check (g) VP catalog consistency | `scripts/check-spec-counts.sh` | check-spec-counts.sh v1.3 |
| O2 — CI gate stale comments removed | `scripts/check-spec-counts.sh` | check-spec-counts.sh v1.3 (bundled with O1) |
| O3 — DTU clone enumeration framing divergence | No spec change — FLAGGED for human gate | — |
| O4 — four-seam re-verification | No change — CLEAN | — |
| O5 — carryover invariants re-verification | No change — CLEAN | — |

### Post-Resolution Metrics

| Metric | After Pass 3 | After Pass 4 |
|--------|-------------|-------------|
| PRD version | v1.3 | v1.3 (unchanged) |
| BC-INDEX version | v1.4 | v1.4 (unchanged) |
| Error-taxonomy version | v1.3 | v1.4 |
| Error families | 22 | 22 (unchanged) |
| Error codes (actual) | 134 | 134 (unchanged) |
| BCs total | 178 | 178 (unchanged) |
| BC priority coverage | 178/178 (100%) | 178/178 (100%) |
| VP-INDEX version | v1.2 | v1.2 (unchanged) |
| VP P0/P1 | 6 P0 / 4 P1 | 6 P0 / 4 P1 (unchanged) |
| ARCH-INDEX version | v1.4 | v1.5 |
| studio-of-agents version | v1.0 | v1.1 |
| Studio roles canonical | 14R/18A/34N (wrong) | 57 NEW + 9 ADAPT = 66 (correct) |
| Tier coverage | 63/66 (3 unassigned) | 66/66 (51 T1 + 15 T2) |
| verification-coverage-matrix version | v1.0 | v1.1 |
| error-taxonomy version | v1.3 | v1.4 |
| nfr-catalog version | v1.1 | v1.2 |
| NFRs total | 35 | 35 (unchanged) |
| CI count-gate checks | 6 (a-f) | 7 (a-g) — GREEN |

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

--- (g) VP catalog consistency ---
    VP-INDEX total stated:          10
    VP-INDEX P0 stated:             6
    VP-INDEX P1 stated:             4
    verif-arch total stated:        10
    verif-arch P0 stated:           6
    verif-arch P1 stated:           4
    verif-matrix grand total:       10
    ARCH-INDEX vp_total:            10
    Expected: total=10  P0=6  P1=4

  OK [VP total / VP-INDEX summary]: 10 == 10  (VP-INDEX.md)
  OK [VP P0 / VP-INDEX summary (g)]: 6 == 6  (VP-INDEX.md)
  OK [VP P1 / VP-INDEX summary (g)]: 4 == 4  (VP-INDEX.md)
  OK [VP total / verification-architecture]: 10 == 10  (verification-architecture.md)
  OK [VP P0 / verification-architecture]: 6 == 6  (verification-architecture.md)
  OK [VP P1 / verification-architecture]: 4 == 4  (verification-architecture.md)
  OK [VP grand total / verification-coverage-matrix]: 10 == 10  (verification-coverage-matrix.md)
  OK [VP total / ARCH-INDEX vp_total]: 10 == 10  (ARCH-INDEX.md)

    Kani VP count (verif-arch VP Targets): 4  (expected: 4)
    Kani VP count (verif-matrix table):    4  (expected: 4)
    proptest VP count (verif-matrix):      7  (expected: 7)
    Note: proptest=7 because VP-001 is dual-counted (Kani+proptest).

  OK [Kani VP count / verif-arch VP Targets column]: 4 == 4  (verification-architecture.md)
  OK [Kani VP count / verif-matrix tool table]: 4 == 4  (verification-coverage-matrix.md)
  OK [proptest VP count / verif-matrix tool table]: 7 == 7  (verification-coverage-matrix.md)

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

Exit code: 0 — ALL CHECKS PASSED (check-spec-counts.sh v1.3, 7 checks a-g)

---

## Pass 4 Status

- Clean pass: NO (2C / 4I / 5 obs/process-gap findings raised)
- All findings resolved: YES
- Clean-pass counter: 0/3 (Pass 4 had findings; no clean pass credit)
- Next action: Phase-1d Pass 5 (fresh-context re-review; same scope). Need 3 consecutive clean passes.
