---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 14
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: HIGH
converged: false
clean_pass_counter: 0/3
findings_summary: "2 critical, 3 important, 2 observations"
---

# Phase-1d Adversarial Review — Pass 14 (first audit of the new CAP-015 surface)

**Verdict:** FINDINGS (2 critical, 3 important, 2 observations)
**Novelty:** HIGH — C14-01 is a security-relevant error-code mis-citation in the new CAP-015/SS-13
surface: the E-OSVC family (built in Pass 13) had three cross-wired code assignments between BC-15.02.001
and BC-15.05.001, including E-OSVC-003 being cited as `UnsupportedAuthProvider` when the registry
registered it as `ScoreRejectedByServer`. E-OSVC-003 carries a D-SEC signal (server-authority guard
failure); any mis-citation of a D-SEC-bearing code is a security-relevant defect. C14-02 is a
process-gap: the CI check (k) only verified that error codes RESOLVE to a registered entry, but did not
verify that the BC parenthetical label matched the registered category name — the false-green that
allowed C14-01 to pass. I14-01/I14-02 surface residual "four adapter seams" prose surviving in eight or
more files after the Pass-13 five-seam reconciliation. I14-03 is an orphan fragment in BC-15.11.001's H1.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. All findings fully resolved. Counter does
not advance. Next = Pass 15 (candidate clean #1).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) →
FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3)

---

## Findings

### C14-01 (CRITICAL) — E-OSVC error-code mis-citations in new CAP-015 BCs (security-relevant)

**Class:** error-code mis-citation; security-relevant (D-SEC signal); false-green CI
**Locus:** BC-15.02.001 (cloud-save write); BC-15.05.001 (entitlement check); error-taxonomy.md E-OSVC registry
**Finding:** The new E-OSVC family (Pass 13) had 15 codes registered in error-taxonomy.md. Two BCs in
the new CAP-015 surface cross-wired codes from the registry:

1. **BC-15.02.001 (cloud-save write)** cited `E-OSVC-003 (UnsupportedAuthProvider)` as the error for
   unsupported authentication provider failure. But the E-OSVC registry had E-OSVC-003 registered as
   `ScoreRejectedByServer` — a leaderboard-authority rejection code bearing the D-SEC signal (server-
   authority enforcement). E-OSVC-003 is the leaderboard server-authority guard failure code; it has
   no semantic connection to authentication provider support. This was a citation collision: the cloud-
   save BC was reusing the wrong numeric slot.

2. **BC-15.05.001 (entitlement check)** cited:
   - `E-OSVC-004 (LobbyNotFound)` for the entitlement-server-rejected case
   - `E-OSVC-006 (LobbyJoinDenied)` for the offline-entitlement-fallback case
   Both E-OSVC-004 and E-OSVC-006 were matchmaking/lobby codes in the registry, not entitlement codes.
   The entitlement BC had been drafted against an earlier draft of the registry before the final lobby
   code assignments were made, leaving stale cross-wired citations.

**Security relevance:** E-OSVC-003 carries a D-SEC convergence dimension signal in BC-15.03.001
(leaderboard server-authority guard). A BC incorrectly citing E-OSVC-003 for a non-D-SEC fault class
could mislead security reviewers into believing the cloud-save path has server-authority guard
semantics when it does not — and conversely, obscure that the D-SEC signal originates from
the leaderboard path, not the cloud-save path.

**Resolution:** Error codes re-assigned and BCs updated to match the authoritative registry:

- **BC-15.02.001 (cloud-save write):** E-OSVC-003 citation replaced with **E-OSVC-013**
  (`UnsupportedAuthProvider` — registered as cloud-save auth provider not supported by the configured
  BaaS adapter). 3 citation sites updated (Precondition, Error-Case table, test vector).
- **BC-15.05.001 (entitlement check):** E-OSVC-004 citation replaced with **E-OSVC-014**
  (`EntitlementServerRejected` — registered as the entitlement server-side rejection code);
  E-OSVC-006 citation replaced with **E-OSVC-015** (`EntitlementCacheMiss` — registered as the offline
  entitlement cache miss / stale-fallback case). 5+ citation sites updated (Preconditions, Error-Case
  table, test vectors, invariants).
- **Registry and PRD were correct** — the error-taxonomy.md E-OSVC family had the right codes registered
  at the right slots; only the BCs drifted. No double-claims remain after the re-citation.

**Verification:** post-fix grep confirmed no BC file contains E-OSVC-003, E-OSVC-004, or E-OSVC-006 in
a cloud-save or entitlement context. E-OSVC-003 is now cited only in BC-15.03.001 (leaderboard) which
correctly carries the D-SEC signal. 32 total E-OSVC citations validated, 0 contradictions.

---

### C14-02 (CRITICAL, process-gap) — CI check (k) only verified code RESOLVES, not label-vs-category match

**Class:** process-gap; CI false-green; recurrence vector
**Locus:** scripts/check-spec-counts.sh check (k); C14-01 was the manifestation
**Finding:** CI check (k.i) asserted that every E-[A-Z]+-[0-9]+ token referenced in any BC file must
resolve to a registered code in error-taxonomy.md — i.e., the code slot must exist. It did NOT assert
that the parenthetical label appended to the citation (e.g., `(UnsupportedAuthProvider)`) matched the
registered category name or short description. This created a false-green: BC-15.02.001 cited
`E-OSVC-003 (UnsupportedAuthProvider)` — E-OSVC-003 was a valid registered slot, so check (k.i)
passed, but the label was wrong (E-OSVC-003 = `ScoreRejectedByServer`, not `UnsupportedAuthProvider`).
This same gap could allow any label to be silently mismatched against any registered code.

**Resolution:** Check (k.ii) added to check-spec-counts.sh (v1.14):

- **Scope:** E-EAP and E-OSVC families only (scoped to avoid false positives on families with looser
  label conventions or abbreviated labels). These two families were authored with consistent CamelCase
  parenthetical labels that directly correspond to the registered `category:` / short description field.
- **E-EAP:** exact CamelCase match (normalized — strip whitespace, compare case-insensitively after
  CamelCase normalization).
- **E-OSVC:** significant words from the BC parenthetical label must appear in the registered short
  description (word-overlap check; tolerates minor word-order variation).
- **Exclusions:** changelog/reason: lines excluded (same as check k.i and n exclusion patterns);
  lines containing `mis-citation` changelog prose excluded to avoid false positives on this pass's
  own documentation.
- **Positive-coverage log:** always prints "Check (k.ii) passed: N E-EAP/E-OSVC citations validated,
  0 label contradictions" on success. Zero-scan runs are visible.

**Verification:** check-spec-counts.sh v1.14 ALL CHECKS PASSED (a–o incl k.ii label-match + o
seam-count), exit 0. 32 E-OSVC citations validated, 0 contradictions.

---

### I14-01 (IMPORTANT) — Residual "four adapter seams" prose in 8+ files after five-seam reconciliation

**Class:** partial-fix regression; prose inconsistency; thesis integrity
**Locus:** domain-spec/capabilities.md, domain-spec/invariants.md, domain-spec/L2-INDEX.md, prd.md,
prd-supplements/prd-cap-002-003.md, specs/product-brief.md, planning/research/aaa/AAA-RECONCILIATION.md,
planning/market-intel-assessment.md, planning/design/brief-validation.md
**Finding:** Pass 13's C13-01 resolution correctly updated adapter-protocols.md §6 to define five seams
and reconciled ADR-0004's title to "Five-Seam Adapter Model." However, eight or more files still
contained references to "four adapter seams," "four-seam adapter model," or the older four-seam
enumeration (engine/asset/compliance/analytics) without the fifth seam (online-services). Specific
instances:

- `domain-spec/capabilities.md`: "engine-agnostic / four-seam / no-lock-in" in capability summary prose
- `domain-spec/invariants.md`: INV-5 seam-count reference "four adapter seams"
- `domain-spec/L2-INDEX.md`: seam-count summary line "4 adapter seams"
- `prd.md`: product overview section "four-seam adapter architecture"
- `prd-supplements/prd-cap-002-003.md`: seam reference in cap cross-reference section
- `specs/product-brief.md`: lines 29, 48, 71, and 109-111 all cited "four adapter seams" or the
  four-seam enumeration without online-services
- `planning/research/aaa/AAA-RECONCILIATION.md`: vector summary "four-seam" adapter model
- `planning/market-intel-assessment.md`: competitive differentiation section "four adapter seams"
- `planning/design/brief-validation.md`: brief-validation summary "four-seam" reference

**Resolution:** All instances updated to "five adapter seams (engine/asset/distribution/XR/online-services)"
or equivalent in context. Specific updates:

- **capabilities.md**: seam summary updated to five-seam with full enumeration
- **invariants.md**: INV-5 seam count reference updated to five adapter seams
- **L2-INDEX.md**: seam-count summary line updated "4 adapter seams" → "5 adapter seams"
- **prd.md**: product overview seam reference updated; v2.0 (Pass-14 prose sweep)
- **prd-cap-002-003.md**: seam cross-reference updated; v1.1
- **product-brief.md**: lines 29, 48, 71, and 109-111 updated to five-seam with canonical enumeration;
  v2.2
- **planning docs (AAA-RECONCILIATION, market-intel, brief-validation)**: all four-seam references
  updated; these are planning/research docs so version not bumped, content corrected in place

Canon-KB is noted as the sixth load-bearing seam where mentioned; the five-seam enumeration in
adapter-protocols.md §6 covers the five formal adapter seams.

---

### I14-02 (IMPORTANT) — ARCH-INDEX intra-document contradiction (line 127 four-seam vs line 202 five-seam)

**Class:** intra-document contradiction; architecture doc inconsistency
**Locus:** specs/architecture/ARCH-INDEX.md lines ~127 and ~202
**Finding:** ARCH-INDEX.md contained two seam-count references with contradictory values:
- Line ~127 (§ Design Principles summary): "four adapter seams" — the old value from before Pass 13
- Line ~202 (§ CAP-015 / SS-13 entry): "five-seam adapter model" — the Pass-13-updated value

The §CAP-015 section was updated in Pass 13 but the §Design Principles section was missed, creating an
internal contradiction within the same document: a reader scanning top-to-bottom would encounter the
old four-seam claim before the five-seam claim.

**Resolution:** ARCH-INDEX.md line ~127 updated: "four adapter seams" → "five adapter seams
(engine/asset/compliance/analytics/online-services)." ARCH-INDEX.md v1.9.

---

### I14-03 (IMPORTANT) — BC-15.11.001 H1 orphan fragment "(100-Token Active Cap)" unspecified in body

**Class:** orphan H1 fragment; specification incompleteness
**Locus:** specs/behavioral-contracts/ss-15/BC-15.11.001.md (BaaS-swap guarantee)
**Finding:** BC-15.11.001's H1 heading read:
  `# BC-15.11.001: BaaS-Swap Guarantee (100-Token Active Cap)`
The parenthetical "(100-Token Active Cap)" appeared in the heading but was not defined, explained, or
referenced anywhere in the BC body (no Preconditions entry, no behavior step, no test vector, no
invariant, no glossary note). No other BC in the spec uses a "100-Token Active Cap" concept. The phrase
appeared to be a stale fragment from an earlier draft. BC-INDEX.md row for BC-15.11.001 also included
the fragment in its title column.

**Resolution:**
- BC-15.11.001 H1 updated: `# BC-15.11.001: BaaS-Swap Guarantee` (fragment removed)
- BC-INDEX.md row for BC-15.11.001 title column updated to match (removing the fragment)
- BC-INDEX.md v1.6

---

## Observations (Resolved)

### O14-01 (RESOLVED) — No CI guard against seam-count prose regression

**Class:** CI gap; process hardening
**Finding:** After Pass 13's five-seam reconciliation, there was no automated check that would prevent
a future edit from reintroducing "four adapter seam" / "four-seam adapter" prose in scoped spec files.
The label-match gap (C14-02) was a direct demonstration of how a plausible-sounding-but-wrong citation
can survive CI. A seam-count check has the same structure: a plausible-but-wrong count survives grep-
level checks if no explicit assertion exists.

**Resolution:** Check (o) added to check-spec-counts.sh v1.14:
- Scoped to ARCH-INDEX.md, ADR-0004.md, capabilities.md, invariants.md, prd.md, product-brief.md
- FAIL if any scoped file contains "four adapter seam" or "four-seam adapter" (case-insensitive) in
  operative content (changelog/reason: lines excluded)
- Will go green after I14-01 prose sweep; stays red until all scoped files are updated

---

### O14-02 (RESOLVED) — ADR-0004 line 39 canon-KB described as "fifth" seam when it is the sixth

**Class:** seam numbering inconsistency in ADR context
**Locus:** specs/architecture/adrs/ADR-0004.md line ~39
**Finding:** ADR-0004 v1.1 (Pass 13 update) correctly enumerated five formal adapter seams and
reconciled its title from "Four-Seam" to "Five-Seam Adapter Model." However, line ~39 in the ADR
Consequences or Context section referred to the canon-KB as the "fifth load-bearing seam" — but after
the five-seam formal model, canon-KB is the sixth seam (five formal + canon-KB as the sixth).

**Resolution:** ADR-0004 line ~39 updated: "fifth" → "sixth" seam reference for canon-KB. ADR-0004 v1.2.
ADR-0004 is now fully internally consistent: five formal adapter seams enumerated, canon-KB
acknowledged as the sixth load-bearing seam.

---

## Resolution Summary

| Finding | Severity | Root Cause | Resolution | Files Changed |
|---------|----------|------------|------------|---------------|
| C14-01 | CRITICAL | E-OSVC-003/004/006 cross-wired citations in BC-15.02.001 and BC-15.05.001; registry was correct, BCs drifted | BC-15.02.001: E-OSVC-003→013 (3 sites); BC-15.05.001: E-OSVC-004→014, E-OSVC-006→015 (5+ sites) | BC-15.02.001, BC-15.05.001 |
| C14-02 | CRITICAL (process) | CI check (k) verified code resolves but not label-vs-category match; false-green hid C14-01 | Added check (k.ii) — E-EAP/E-OSVC label-match sub-check (exact CamelCase for E-EAP; word-overlap for E-OSVC); positive-coverage log | scripts/check-spec-counts.sh (v1.13→v1.14) |
| I14-01 | IMPORTANT | Residual "four adapter seams" prose in 8+ files after Pass-13 five-seam reconciliation | Updated all instances to "five adapter seams (engine/asset/distribution/XR/online-services)" across capabilities.md, invariants.md, L2-INDEX.md, prd.md, prd-cap-002-003.md, product-brief.md (lines 29/48/71/109-111), AAA-RECONCILIATION.md, market-intel-assessment.md, brief-validation.md | capabilities.md (v1.1), invariants.md (v1.1), L2-INDEX.md (v1.1), prd.md (v2.0), prd-cap-002-003.md (v1.1), product-brief.md (v2.2), planning docs |
| I14-02 | IMPORTANT | ARCH-INDEX intra-doc contradiction line 127 four-seam vs line 202 five-seam | Line 127 updated to five-seam | ARCH-INDEX.md (v1.8→v1.9) |
| I14-03 | IMPORTANT | BC-15.11.001 H1 fragment "(100-Token Active Cap)" unspecified in body | Removed from H1 + BC-INDEX title column | BC-15.11.001, BC-INDEX.md (v1.5→v1.6) |
| O14-01 | OBS | No CI seam-count prose guard after five-seam reconciliation | Added check (o): FAIL on "four adapter seam"/"four-seam adapter" in scoped spec files | scripts/check-spec-counts.sh (v1.14) |
| O14-02 | OBS | ADR-0004 line 39 canon-KB described as "fifth" seam (should be sixth after five formal seams) | "fifth" → "sixth" for canon-KB in ADR-0004 | ADR-0004.md (v1.1→v1.2) |

**Counter:** 0/3 clean passes. Pass 14 found 2 critical + 3 important (all resolved). Counter does not advance.
**Next action:** Pass 15 — candidate clean #1. Full CAP-015 surface has now been audited (Pass 13 built
it; Pass 14 fixed E-OSVC mis-citations and residual prose). Pass 15 will be the first truly clean
candidate after the complete CAP-015/SS-13 surface stabilization.

---

## Verification

**check-spec-counts.sh v1.14 ALL CHECKS PASSED** (checks a–o inclusive; k.ii label-match + o
seam-count added this pass), exit 0.
BC=190, error codes=213, priority P0=126/P1=42/P2=22.
32 E-OSVC citations validated by check (k.ii), 0 label contradictions.
Check (o): 0 stale "four adapter seam" occurrences in scoped spec files.
