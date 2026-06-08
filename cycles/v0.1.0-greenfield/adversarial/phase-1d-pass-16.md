---
document_type: adversarial-review
cycle: v0.1.0-greenfield
pass: 16
phase: 1d
role: adversary
date: 2026-06-08
verdict: FINDINGS
clean_pass_candidate: 1
novelty: MODERATE
findings_summary: "0 critical / 1 important / 2 observations"
counter_after: 0/3
---

# Phase-1d Adversarial Pass 16 (candidate clean #1) — VERDICT: FINDINGS

**Verdict:** FINDINGS (0 critical, 1 important, 2 observations)
**Novelty:** MODERATE — single isolated count-drift defect class; 2 instances found; class fully enumerated.
**Counter:** 0/3 (stays at 0; not a clean pass)
**Next:** Pass 17 (candidate clean #1 re-attempted)

---

## Finding Summary

| ID | Severity | Description | Resolution |
|----|----------|-------------|------------|
| I-16-01 | IMPORTANT | BC-INDEX.md per-capability section-header counts stale for CAP-007 and CAP-015 | RESOLVED — headers corrected; BC-INDEX v1.7 |
| process-gap | PROCESS | CI check (a) validated grand-total only; per-capability section header counts not checked | RESOLVED — check (a.ii) added; CI gate v1.16 |
| O-16-01 | OBS | prd.md "12 original" wording (historical reference to CAP-001..014 initial count) | NON-BLOCKING — historical wording correct in context; no change required |
| O-16-02 | OBS | ss-NN directory-alias naming convention could confuse readers who conflate capability numbers with architecture subsystem IDs | NON-BLOCKING — existing note in BC-INDEX header adequately clarifies; no change required |

---

## I-16-01 (IMPORTANT): Stale Per-Capability BC-Count Headers in BC-INDEX.md

### Finding

Two `## CAP-NNN — <name> — N BCs` section headers in BC-INDEX.md contained stale
counts that did not match the actual number of BC table rows in their respective
sections:

- **CAP-007** header stated `"12 BCs"` above a table containing **19 rows**
  (CAP-007 was 12 BCs at initial authoring; count grew to 19 across successive
  passes but the H2 header was not updated when rows were added)
- **CAP-015** header stated `"11 BCs"` above a table containing **12 rows**
  (CAP-015 was added in Pass-13 with 12 BCs; the header was written as "11 BCs"
  at initial authoring)

The grand total line (`**Grand total: 190 behavioral contracts**`) was correct
throughout, as were all downstream counts (ARCH-INDEX, subsystem-decomposition,
PRD). The drift was isolated to the two H2 section headers — a presentational
layer that CI check (a) did not reach.

**Corpus sweep:** All 15 capability section headers audited. Only CAP-007 and
CAP-015 were stale. No other headers exhibited count drift.

### Resolution

Headers corrected:

| Capability | Old Header | New Header |
|------------|-----------|------------|
| CAP-007 | `## CAP-007 — 11-Dimension Convergence Tracking (P0) — 12 BCs` | `## CAP-007 — 11-Dimension Convergence Tracking (P0) — 19 BCs` |
| CAP-015 | `## CAP-015 — Online-Services Adapter (P1, Tier 1) — 11 BCs` | `## CAP-015 — Online-Services Adapter (P1, Tier 1) — 12 BCs` |

BC-INDEX.md version bumped **v1.6 → v1.7**.

No other spec files required changes (grand total, Summary table, ARCH-INDEX,
subsystem-decomposition, PRD all stated 190 and remained correct).

---

## Process-Gap Resolution: CI Check (a.ii) Added

### Gap

CI check (a) validated only the grand-total BC count against four stated-total
locations (BC-INDEX grand-total line, subsystem-decomposition, ARCH-INDEX, PRD).
It did not parse the per-capability `## CAP-NNN — <name> — N BCs` section headers
or verify that each header's stated N matched the actual row count in that
capability's section table.

This allowed both stale headers (CAP-007 and CAP-015) to survive passes 1–15
undetected despite the grand-total checks all passing green.

### Resolution: Check (a.ii)

`scripts/check-spec-counts.sh` v1.16 adds **check (a.ii)**:

- For each `## CAP-NNN — <name> — N BCs` H2 header in BC-INDEX.md, parses the
  stated N using POSIX awk (`match($0, /[0-9]+ BCs$/)`)
- Counts the actual `| BC-NN.NN.NNN |` rows in that capability's section (up to
  the next `## ` header)
- FAIL if stated header N != counted rows
- Optionally cross-checks the BC-INDEX Summary table BC-Count cell for triple
  consistency (first integer in field 4 of the matching `| CAP-NNN` row)
- Positive-coverage log always printed: `"Check (a.ii): N capability section
  headers validated against section row counts."`
- POSIX/BSD-awk/grep compatible (no grep -P)
- **Checked 15 headers** post-fix; all passed

CI gate bumped **v1.15 → v1.16** (checks a–p including new a.ii; 21 sub-assertions
total).

---

## O-16-01 (OBS, NON-BLOCKING): prd.md "12 original" Historical Wording

prd.md contains wording referencing "12 original" capabilities in a historical
context (pre-CAP-015 addition). This is accurate historical prose describing the
state before Pass-13 scope expansion. No change required; wording is correct in
context.

---

## O-16-02 (OBS, NON-BLOCKING): ss-NN Directory-Alias Naming Convention

The BC-INDEX header note clarifies that `ss-NN` directory names mirror capability
numbers for navigability only and are not architecture subsystem IDs. The note is
adequate for fresh-context readers. No additional clarification needed.

---

## Verification Footer

**CI gate:** `scripts/check-spec-counts.sh` v1.16
**Result:** ALL CHECKS PASSED (checks a–p including a.ii; 21 sub-assertions); exit 0
**Totals verified:** BC=190, error codes=213, caps=15, subsystems=13, priority P0=126/P1=42/P2=22
**Check (a.ii) coverage:** 15 capability section headers validated; 0 mismatches post-fix
**Check (p) coverage:** 39 cross-references validated; 0 mismatches

**Defect class enumeration:** P16-01 (stale per-capability H2 section-header count)
— exactly 2 instances found (CAP-007, CAP-015); both fixed; corpus sweep of all
15 headers confirms class fully enumerated.
