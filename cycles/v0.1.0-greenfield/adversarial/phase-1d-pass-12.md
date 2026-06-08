---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 12
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MEDIUM
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 2 important, 3 LOW observations"
---

# Phase-1d Adversarial Review — Pass 12 (candidate clean #1)

**Verdict:** FINDINGS (0 critical, 2 important, 3 LOW observations)
**Novelty:** MEDIUM — F-12-01 is a terminology/casing error introduced during Pass-10's
status-value canonicalization that survived Passes 10 and 11 because the CI check (n)
was case-sensitive (uppercase-only extraction). BC-8.08.004 used lowercase status tokens
(`green`, `red`, `amber`, `pending`) that are syntactically invisible to an uppercase-only
scan. F-12-02 is the corresponding CI process gap: check (n) itself was the blind spot.
Both are fix-introduced defects from Pass-10 scope.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. Both importants resolved.
Counter does not advance. Next = Pass 13.
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) →
FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3)

---

## Findings

### F-12-01 (IMPORTANT) — BC-8.08.004 lowercase D-PLAY status values defeat release gate

**Class:** fix-introduced terminology error; canonical-enum violation via wrong-case form
**Locus:** BC-8.08.004 (CAP-008 playtest, D-PLAY producer); postconditions PC-2/PC-3/PC-4;
invariant INV-3; error-condition rows EC-003/EC-006; test vectors; VP-2/VP-3 references
**Finding:** BC-8.08.004 was the one BC producer for D-PLAY that was NOT listed in the
§3.1 PO Change List when Pass-10 canonicalized the convergence-dimension status-value enum.
Consequently, all dimension status-value assignments in BC-8.08.004 remained as lowercase
tokens (`green`, `red`, `amber`, `pending`) rather than the canonical uppercase enum
`{GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}`. The mapping is:

| Lowercase token | Canonical enum value | Semantic justification |
|-----------------|---------------------|----------------------|
| `green` | `GREEN` | Playtest satisfaction met |
| `red` | `BLOCKED` | Playtest failed, gate blocked (owner BC-7.05.001 maps blocked-playtest → BLOCKED) |
| `amber` | `DEGRADED` | Playtest partial / satisfaction threshold not met |
| `pending` | `DEGRADED-PENDING` | Playtest queued but not yet executed (factory work done, on-device act outstanding; per D-PLAY owner BC-7.05.001 v1.1 which explicitly lists DEGRADED-PENDING as a legal D-PLAY value) |

The silent defeat is critical to the release-gate contract: BC-8.08.004 is the D-PLAY
producer; its postconditions feed the release-gate convergence check (BC-7.12.001). A
lowercase `green` in a machine-parsed convergence report would not match the enum string
`GREEN`, silently routing the record as unparseable/BLOCKED rather than passing the gate.
**Impact:** D-PLAY release gate silently misfires for any playtest report produced by
BC-8.08.004's postcondition path.
**Resolution:** Mapped all lowercase status tokens in BC-8.08.004 to canonical uppercase
equivalents across PC-2, PC-3, PC-4, INV-3, EC-003, EC-006, test vectors, and VP-2/VP-3
references. BC-8.08.004 version bumped to v1.2. No sibling drift found in other
CAP-008 BCs (BC-8.08.001/002/003 use prose fields, not convergence-report dimension
assignments; verified clean).

---

### F-12-02 (IMPORTANT, process-gap) — CI check (n) was case-blind; allowed lowercase tokens to evade 11 passes

**Class:** CI process gap; detection blind spot enabling F-12-01 recurrence class
**Locus:** `scripts/check-spec-counts.sh` check (n.i); all passes 1–11 CI runs
**Finding:** Check (n.i), added in v1.9 and extended in v1.10/v1.11, extracted
dimension-status assignments from BC files using a backtick-quoted token scan that
was uppercase-only. The extraction pattern matched `` `GREEN` ``, `` `BLOCKED` ``,
`` `DEGRADED` ``, `` `DEGRADED-PENDING` `` but not `` `green` ``, `` `red` ``,
`` `amber` ``, `` `pending` ``. Because BC-8.08.004 used lowercase tokens in
backtick form, they were silently skipped by the scan — the token was present in
dim_context_lines but the uppercase-only filter discarded it before membership
testing. All 11 previous passes produced a GREEN check (n) result despite the
live defect in BC-8.08.004.
**Impact:** Any BC that uses lowercase canonical-wrong-case or lowercase non-canonical
status tokens in convergence-dimension context evades the CI gate indefinitely.
**Resolution:** check (n.i) extraction is now case-INSENSITIVE. Implementation:
backtick-quoted tokens are extracted from dim_context_lines, folded to uppercase
(tr '[:lower:]' '[:upper:]'), then tested against the canonical enum. Behavior:
- Tokens folding to a canonical value (e.g., `green` → GREEN) are flagged as
  "wrong-case form of canonical value" — a BC update is required.
- Tokens folding to a known non-canonical status word (AMBER, RED, PENDING, YELLOW)
  are flagged as "non-canonical + wrong case" — both vocabulary and casing are wrong.
- Tokens whose uppercased form is neither canonical nor known non-canonical are
  silently dropped (avoids false positives on field names like `playtest-satisfaction`,
  `convergence-report`, etc. — ~41 BCs use lowercase for non-dimension things).
Anchoring to dim_context_lines (unchanged from v1.9) ensures only dimension-context
lines are scanned, preventing false positives from the ~41 BCs with legitimate
lowercase usage (severity colors, lint status, UI labels, asset status fields).
Check (n) v1.12 also adds a positive-coverage log line: "Check (n) passed:
N dimension-status assignments validated across M BCs" to make a zero-scan run
visible. CI gate v1.12: checks a–n, 17 sub-assertions.

---

## Observations (non-blocking)

### OBS-1 (RESOLVED) — methodology §3.1 "PO Change List" future-tense stale prose

**Class:** stale prose; future-tense voice after changes were applied
**Locus:** methodology-layer.md §3.1 "PO Change List" header and preamble prose
**Finding:** The §3.1 "PO Change List" heading and introductory sentence used future-tense
language ("PO must apply the following changes...") which was accurate before Pass-10
but became stale once the changes were applied. Pass-10 did not convert the prose to
past-tense. A fresh-context reader sees an unresolved action item.
**Resolution:** §3.1 "PO Change List" section header converted to "PO Changes Applied
(Resolved Pass-10)"; preamble converted to past-tense ("PO applied the following
changes during Pass-10"). Added a one-line note referencing Pass-12 BC-8.08.004 fix
("BC-8.08.004 lowercase tokens corrected Pass-12"). methodology-layer.md version bumped
to v1.6.

### OBS-2 (non-blocking) — BC-7.12.001 precondition notation looseness

**Class:** documentation looseness; no functional defect
**Locus:** BC-7.12.001 (release-gate consumer BC) precondition list
**Finding:** BC-7.12.001 lists as a precondition "all upstream dimension producers have
emitted a convergence-report entry" without specifying the required status-value type
(GREEN vs. any non-BLOCKED). A strict reader could construct a scenario where a
DEGRADED status satisfies the precondition literal while the gate business rule requires
GREEN. The gate body itself is correct (it checks for GREEN explicitly), so this is
notation looseness only, not a functional bug.
**Disposition:** Non-blocking observation. May be addressed in a doc-cleanup pass.
Does not advance or reset the clean-pass counter.

### OBS-3 (non-blocking) — check (e) BC↔index title sync uses lenient substring match

**Class:** CI lenience; borderline false-negative risk
**Locus:** `scripts/check-spec-counts.sh` check (e) BC H1 ↔ BC-INDEX title sync
**Finding:** Check (e) uses a substring match (grep -F) rather than an exact equality
comparison when verifying that a BC's H1 title matches its BC-INDEX entry. A title that
is a prefix of another title would pass the check incorrectly. Current corpus has no
such collision, but the pattern allows silent drift as BCs accumulate.
**Disposition:** Non-blocking observation. Exact-match upgrade is a low-priority CI
hardening item. Does not advance or reset the clean-pass counter.

---

## Verification

**CI gate:** `scripts/check-spec-counts.sh` v1.12 — ALL CHECKS PASSED (checks a–n,
17 sub-assertions including case-insensitive n.i + positive-coverage log + n.ii + n.iii),
exit 0.

**Scope of changes this pass:**
- BC-8.08.004 v1.2 — lowercase D-PLAY status tokens mapped to canonical uppercase
  across PC-2/PC-3/PC-4, INV-3, EC-003/EC-006, test vectors, VP-2/VP-3
- methodology-layer.md v1.6 — §3.1 "PO Change List" converted to past-tense + Pass-12 note
- scripts/check-spec-counts.sh v1.12 — check (n.i) case-insensitive + coverage log

**Sibling drift verification:** No other CAP-008 BCs (BC-8.08.001/002/003) use
convergence-dimension status assignments — confirmed clean. No other BC files use
lowercase backtick-quoted status tokens in dimension context — scan completed.

**No spec counts changed this pass.** BC count = 178, VP count = 10, error codes = 198,
priority split P0=117/P1=39/P2=22 — all unchanged. BC-INDEX unchanged. ARCH-INDEX
unchanged. CI check (a)–(m) all still GREEN; check (n) now also GREEN after BC-8.08.004
fix + case-insensitive extraction.
