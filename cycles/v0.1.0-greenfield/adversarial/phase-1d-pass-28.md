---
pass: 28
phase: 1d
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
low: 1
severity_summary: 0C / 1I / 1 LOW obs
novelty: MEDIUM
clean_pass_counter_before: "0/3"
clean_pass_counter_after: "0/3 (stays; orchestrator proactive 4-file class closure; restart at Pass 29)"
spec_stable: false
files_changed: [BC-5.06.001, BC-12.12.008, BC-7.04.001, BC-7.05.001, prd-cap-005.md, scripts/check-spec-counts.sh]
---

# Phase-1d Adversarial Pass 28 — Candidate Clean #1 — VERDICT: FINDINGS

**0 critical, 1 important (RESOLVED), 1 LOW observation (RESOLVED). Novelty: MEDIUM.**
**CLEAN-PASS COUNTER: stays 0/3 (findings resolved; class closure complete; restart at Pass 29).**

---

## Summary

Pass 28 was dispatched as candidate clean #1 of the counter-restart streak.
A fresh-context adversarial review identified a vocabulary misapplication:
the `human-gated` fidelity-tier vocabulary — reserved per D-005/ADR-0007 for
external third-party acts (SAG-AFTRA consent, console cert, store publish,
legal review) — was applied to the INTERNAL cinematic-director creative gate
(D-013 / DI-007), contradicting the methodology §2.8 definition,
ADR-0007, and the Pass-1 I5 error-taxonomy fix that established E-CIN-003 / DI-007
as the canonical vocabulary for that creative sign-off.

The adversary flagged 2 files. The orchestrator ran a proactive corpus sweep and
found the FULL defect class across 4 BC files. All 4 were remediated in one burst.

Additionally, O28-01 identified that the canonical prd-cap-005.md E-CIN-003 row
lacked the I5 enrichment present elsewhere; that gap was also closed in this pass.

A new CI guard (check u) was added to enforce the vocabulary separation going forward:
it flags `human-gated`, `DI-006`, or `-32008` in proximity to
`cinematic-director` / `creative-gate` context unless an external-act exemption
keyword (SAG-AFTRA, consent, likeness, cert, publish, legal-review) or an explicit
negation ("NOT the human-gated tier") is present. 0 violations on the post-fix corpus;
all legitimate human-gated uses (SAG-AFTRA, cert, publish) are preserved.

---

## Findings

### I28-01 (IMPORTANT, [process-gap]) — `human-gated` vocabulary misapplied to internal cinematic-director creative gate

**Files (adversary-flagged):** `.factory/specs/behavioral-contracts/ss-05/BC-5.06.001.md`,
`.factory/specs/behavioral-contracts/ss-12/BC-12.12.008.md`

**Files (orchestrator proactive sweep — full class):** additionally
`.factory/specs/behavioral-contracts/ss-07/BC-7.04.001.md`,
`.factory/specs/behavioral-contracts/ss-07/BC-7.05.001.md`

**Finding:** Four BC files applied `human-gated` tier vocabulary (and/or cited
DI-006 or error code E-CIN-002 / -32008) to the directed:true cinematic-director
creative sign-off gate (D-013). This contradicts:

- **methodology §2.8:** `human-gated` = external third-party acts (SAG-AFTRA, cert,
  publish, legal). The cinematic-director sign-off is an INTERNAL creative gate.
- **ADR-0007:** `human-gated` vocabulary is reserved for external gating events.
  D-013 / DI-007 ("directed:true sequence requires cinematic-director
  creative-gate approval") governs internal creative review. These are distinct tiers.
- **Pass-1 I5 fix:** the original E-CIN-002 error code was replaced with E-CIN-003
  ("cinematic-director creative-gate rejected") after the adversary identified that
  E-CIN-002 modeled the cinematic-director as a human-gated external actor, when it
  is actually an internal creative quality gate. The I5 fix established E-CIN-003 +
  DI-007 as canonical vocabulary. This fix propagated into error-taxonomy.md and some
  BCs but was never applied to the producer-side BCs (BC-5.06.001, BC-12.12.008)
  or the dimension-owner BCs (BC-7.04.001, BC-7.05.001).

**Defect:** Each of the 4 BCs used `human-gated` framing, cited DI-006 (external
human-gate design invariant) instead of DI-007 (creative-gate design invariant),
and/or used E-CIN-002 (-32008) instead of E-CIN-003 in the creative-gate error path.

**Resolution — 4 BCs updated:**

- **BC-5.06.001 v1.2:** replaced `human-gated` + DI-006 + E-CIN-002/-32008 in the
  cinematic-director sign-off block with `creative-gate` + DI-007 + E-CIN-003.
  Legitimate SAG-AFTRA/voice-talent consent language elsewhere in the file is
  preserved and untouched.

- **BC-12.12.008 v1.2:** same substitution — `human-gated` + DI-006 →
  `creative-gate` + DI-007 + E-CIN-003 for the directed:true sign-off path.

- **BC-7.04.001 v1.1:** methodology dimension-gate producer BC; replaced
  `human-gated` + DI-006 in the convergence-report predicate with `creative-gate`
  + DI-007 + E-CIN-003.

- **BC-7.05.001 v1.2:** D-PLAY dimension owner BC; replaced `human-gated` + DI-006
  in the directed:true EC-002 error path with `creative-gate` + DI-007 + E-CIN-003.

**Gating semantics preserved:** The sign-off gate itself (directed:true sequence
requires cinematic-director approval before delivery) is unchanged. Only the
vocabulary tier classification and cited invariant/error code are corrected.

**Legitimate human-gated uses preserved:** SAG-AFTRA consent, voice-talent rights,
console cert, store publish, legal-review references remain `human-gated` + DI-006
throughout. The check (u) exemption rules ensure they continue to pass.

**Process-gap resolution:** check (u) added to check-spec-counts.sh v1.24:
- Scans all BC files for `human-gated`, `DI-006`, or `-32008` tokens in lines
  that are within cinematic-director / creative-gate context (within ±5 lines of
  `cinematic-director`, `creative.gate`, `creative_gate`, `D-CIN`, or `directed:true`
  keywords).
- Exempt if the same proximity context contains an external-act keyword:
  SAG-AFTRA, consent, likeness, cert, publish, legal-review, or an explicit
  negation phrase ("NOT the human-gated tier").
- 26,461 BC lines scanned; 5 creative-gate-context lines validated; 0 violations.
- CI gate bumped to **v1.24**.

**Defect class status:** Comprehensively gated. Would have caught all 4 instances
pre-fix. Legitimate human-gated uses unaffected.

---

## Observations

### O28-01 (LOW, RESOLVED) — prd-cap-005.md canonical E-CIN-003 row lacked I5 enrichment

**File:** `.factory/specs/prd/prd-cap-005.md`

**Observation:** The prd-cap-005.md error-table row for E-CIN-003 ("cinematic-director
creative-gate rejected") existed but retained the pre-I5 sparse format — it did not
include the enriched description and DI-007 cross-reference added to error-taxonomy.md
and the relevant BCs during the Pass-1 I5 fix burst.

**Resolution:** prd-cap-005.md E-CIN-003 row enriched to match the error-taxonomy.md
canonical entry verbatim (description: "cinematic-director creative-gate rejected;
directed:true delivery halted"; invariant: DI-007; references: D-013). prd-cap-005
bumped to **v1.1**.

---

## Verification

check-spec-counts.sh **v1.24** — ALL CHECKS PASSED (checks a–u, ~29 sub-assertions),
exit 0.

Totals confirmed unchanged:
- BCs: **190**
- Error codes: **255** (246 active / 9 retired)
- NFRs: **41**
- Priority: P0=**126** / P1=**42** / P2=**22**
- Caps: 15 / Subsystems: 13

---

## Gate Verdict

**FINDINGS — 0 critical, 1 important (RESOLVED), 1 LOW observation (RESOLVED).**
**Orchestrator proactive: full 4-file class closure in one burst.**

Clean-pass counter **stays 0/3** (findings found and resolved; Pass 28 was not a
clean pass). Next: **Pass 29** (candidate clean #1, restart).

Spec changed: BC-5.06.001 v1.2, BC-12.12.008 v1.2, BC-7.04.001 v1.1,
BC-7.05.001 v1.2, prd-cap-005.md v1.1, CI gate v1.24.
