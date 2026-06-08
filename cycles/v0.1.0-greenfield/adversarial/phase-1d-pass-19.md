---
pass: 19
cycle: v0.1.0-greenfield
phase: 1d-adversarial
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 1
observations: 2
novelty: LOW-MEDIUM
clean_pass_candidate: 1
clean_pass_counter_after: 0/3
note: count-summary class fully gated — no count finding this pass; proactive Pass-18 closure held
---

# Phase-1d Adversarial Pass 19 — FINDINGS (0C / 1I / 2 obs)

**Verdict:** FINDINGS — Counter stays 0/3 (candidate clean #1 NOT awarded)
**Novelty:** LOW-MEDIUM
**Note:** Count-summary class fully gated (check a.iv). No count finding this pass — proactive
Pass-18 closure held. Finding class: per-dimension prose restatement omitting a canonical token.

---

## Findings

### F1 — IMPORTANT (RESOLVED)

**Location:** `.factory/specs/architecture/methodology-layer.md` line ~661
(Pass-12 changelog note, §3.1 PO Change List entry)

**Finding:** The Pass-12 changelog note restated the D-PLAY allowed-value set as
`GREEN/DEGRADED-PENDING/BLOCKED`, omitting `DEGRADED`. This contradicted:
- The canonical §3.1 Per-Dimension Allowed Value Subsets table (line ~616), which
  lists D-PLAY = `{GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}` (widened in Pass-11
  Direction A to add DEGRADED-PENDING; DEGRADED was always present)
- §3 D-PLAY prose describing the full allowed set
- BC-8.08.004 PC4 (D-PLAY producer postcondition)
- BC-7.05.001 EC-002 (D-PLAY dimension-owner error condition)

**Root cause:** Pass-12 changelog narrative described the widening of DEGRADED-PENDING
to D-PLAY but inadvertently dropped DEGRADED from the enumeration in that prose note,
making it appear the allowed set shrank to three tokens.

**Resolution:** Corrected the Pass-12 changelog note token list from
`GREEN/DEGRADED-PENDING/BLOCKED` to `GREEN/DEGRADED/DEGRADED-PENDING/BLOCKED` per §3.1.
methodology-layer bumped to **v1.7**.

**Corpus grep:** Searched all methodology-layer.md operative content for
`D-PLAY allows` and `D-PLAY.*allows`. Confirmed exactly 1 instance (the corrected
changelog note). No other prose restatements of D-PLAY's allowed set found outside §3.1.

**process-gap RESOLVED:** This was the 3rd instance of a per-dimension prose-subset
restatement drifting from the §3.1 canonical table (Pass-11 F-11-01: §3.1 table vs
owner-BC usage; Pass-12 F-12-01: BC-8.08.004 lowercase tokens; Pass-19 F1: changelog
note omitting DEGRADED). Check **(q)** added to CI gate:

- Scans `methodology-layer.md` operative content (non-table, non-comment lines) for
  patterns matching `D-<DIM> allows <TOKEN>/<TOKEN>/...` and
  `(D-<DIM> allows <tokens>)`.
- For each match, parses the stated token set.
- Asserts the stated set **equals** the §3.1 canonical allowed subset for that
  dimension (reuses the `DIM_ALLOWED_MAP` built by check n.ii).
- FAIL if any token is missing from the stated set or extra tokens appear that are
  not in §3.1.
- Advisory if the dimension ID does not appear in the §3.1 table (unknown dim).
- Positive-coverage log: `Check (q): N prose restatements validated.`
- 1 restatement validated this pass (the corrected changelog note).
- **POSIX/BSD-grep/awk compatible (no grep -P).**

CI gate bumped to **v1.19** (checks a–q, ~25 sub-assertions). scripts/check-spec-counts.sh
ALL CHECKS PASSED, exit 0.

---

### O1 — LOW (obs, preempted — convention documented)

**Location:** `.factory/specs/architecture/adapter-protocols.md` §2.3

**Finding:** Wire-protocol field `determinismTier` (camelCase) vs convergence-record
field `determinism_tier` (snake_case) — two documents use different naming conventions
for what appears to be the same concept. A fresh-context reader might flag this as a
naming inconsistency.

**Adjudication:** Deliberate convention. Wire format (JSON-RPC 2.0 `params` object)
uses camelCase per JSON community convention; internal record fields use snake_case per
Rust/Python struct convention. The split is architectural, not accidental.

**Resolution:** Added a one-line clarifying note in adapter-protocols.md §2.3:
`# Wire fields use camelCase (JSON convention); record fields use snake_case (Rust/Python convention).`
adapter-protocols bumped to **v1.3**.

No CI gate change needed (naming convention; not a count or enum constraint).

---

### O2 — LOW (obs, non-blocking — pre-assignment state)

**Location:** Multiple BC files using `VP-TBD-NNN` placeholder identifiers

**Finding:** Several VP-TBD identifiers (e.g., BC-6.01.001/VP-TBD-001,
BC-8.08.004/VP-TBD-002) appear in multiple BCs. A fresh-context reader might
question whether these represent distinct VPs or collisions.

**Adjudication:** Known pre-assignment state. D-015 (accepted 2026-06-08) establishes
that VP-TBD-NNN are BC-local placeholders; the canonical form is `<BC-ID>/VP-TBD-NNN`;
Phase-6 formal hardening promotes BC-local VP-TBDs to canonical VP-NNN identifiers.
ID "reuse" across BCs is expected — each is scoped to its owning BC.

**Resolution:** Non-blocking. Tracking note added to O2 record only. The VP-TBD →
VP-NNN assignment pass is gated to Phase-6 per D-015. No file changes required.

---

## Verification Footer

**CI gate:** scripts/check-spec-counts.sh **v1.19**
**Checks:** a–q (~25 sub-assertions)
**Result:** ALL CHECKS PASSED — exit 0
**Totals confirmed:**
- BCs: 190
- Error codes: 213 (204 active; E-GEN 9 codes retired)
- NFRs: 41
- Priority: P0=126 / P1=42 / P2=22
- Capabilities: 15
- Subsystems: 13

**Spec versions changed this pass:**
- methodology-layer.md: v1.6 → **v1.7** (F1: corrected D-PLAY allowed-set in Pass-12
  changelog note from `GREEN/DEGRADED-PENDING/BLOCKED` to `GREEN/DEGRADED/DEGRADED-PENDING/BLOCKED`)
- adapter-protocols.md: v1.2 → **v1.3** (O1: camelCase/snake_case convention note in §2.3)
- scripts/check-spec-counts.sh: v1.18 → **v1.19** (check q: per-dimension prose
  restatement guard; 1 restatement validated, 0 violations)

**Counter:** 0/3 clean passes. Next = Pass 20 (candidate clean #1 re-attempted).
