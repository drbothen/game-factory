---
document_type: adversarial-review
cycle: v0.1.0-greenfield
pass: 15
phase: 1d
label: "candidate clean #1"
verdict: FINDINGS
severity_summary: "1 CRITICAL / 1 IMPORTANT / 1 process-gap observation"
novelty: MODERATE-HIGH
clean_pass_counter_before: 0/3
clean_pass_counter_after: 0/3
date: 2026-06-08
defect_class: "cross-BC dimension-owner mis-anchor (Related-BCs cited wrong SS-07 BC ID)"
defect_class_fully_enumerated: true
known_instances: 2
ci_gate_version: v1.15
---

# Phase-1d Adversarial Pass 15 — FINDINGS (candidate clean #1)

**Verdict:** FINDINGS — 1 CRITICAL, 1 IMPORTANT, 1 process-gap observation.
All findings RESOLVED in this pass. Counter stays **0/3** (findings in a candidate-clean pass reset clean-pass progress). Next pass: **Pass 16 (candidate clean #1)**.

---

## Finding F15-01 (CRITICAL) — Cross-BC Mis-Anchor: BC-9.01.001 Related-BCs

**Severity:** CRITICAL
**Finding class:** cross-BC dimension-owner mis-anchor (Related-BCs cited wrong SS-07 BC ID)
**Location:** `ss-09/BC-9.01.001.md` — Related BCs section

**Description:**
BC-9.01.001 (Cert Pre-Flight Checklist) cited `BC-7.05.001` (Playtest-Satisfaction Convergence
Dimension Evaluation) with the inline description "Cert Pre-Flight Convergence Dimension
Evaluation". The description unambiguously identifies the **cert** dimension owner (D-CERT); the
correct citation is `BC-7.06.001` (Cert-Preflight and Distribution-Readiness Convergence Dimension
Evaluation). BC-7.05.001 owns the **playtest** dimension (D-PLAY) — entirely different.

This is a CRITICAL mis-anchor because a consumer reading the Related-BCs would follow the link to
the wrong dimension-owner BC, producing wrong traceability for cert-preflight convergence tracking.
D-SEC signal: this cross-references the cert submission gate — citing the wrong owner collapses the
cert-dimension trace chain.

**Resolution:** ID corrected BC-7.05.001 → BC-7.06.001 in Related-BCs section of BC-9.01.001.
Version bumped: **BC-9.01.001 v1.2**. No content change beyond the ID fix.

**Corpus sweep:** grep'd all 190 BC files for Related-BCs lines citing BC-7.05.001 or BC-7.07.001
with cert-dimension keywords. Confirmed: no other instances of this mis-anchor class in the corpus
(only BC-9.01.001 and BC-8.08.004 were affected — both enumerated here; defect class fully enumerated).

---

## Finding F15-02 (IMPORTANT) — Cross-BC Mis-Anchor: BC-8.08.004 Related-BCs

**Severity:** IMPORTANT
**Finding class:** cross-BC dimension-owner mis-anchor (Related-BCs cited wrong SS-07 BC ID)
**Location:** `ss-08/BC-8.08.004.md` — Related BCs section

**Description:**
BC-8.08.004 (Human Playtest Sign-Off Gate) cited `BC-7.07.001` (Perf-Budget Convergence Dimension
Evaluation) with the inline description including "playtest-satisfaction is one of 11 dimensions".
The description unambiguously identifies the **playtest** dimension owner (D-PLAY); the correct
citation is `BC-7.05.001` (Playtest-Satisfaction Convergence Dimension Evaluation). BC-7.07.001
owns the **perf-budget** dimension (D-PERF) — entirely different.

Classified IMPORTANT (not CRITICAL) because the BC's own body correctly describes the playtest
dimension throughout; the mis-anchor is in the Related-BCs cross-reference only. No operative
behavioral semantics were compromised. However, a downstream reader following the cross-reference
would arrive at the wrong dimension-owner BC.

**Resolution:** ID corrected BC-7.07.001 → BC-7.05.001 in Related-BCs section of BC-8.08.004.
Version bumped: **BC-8.08.004 v1.3**. No content change beyond the ID fix.

**Corpus sweep:** confirmed in tandem with F15-01 sweep — BC-8.08.004 was the only instance of
the playtest-vs-perf-budget mis-anchor. Defect class fully enumerated: exactly 2 instances total
in the 190-BC corpus.

---

## Process-Gap Observation (RESOLVED) — CI Check (e) Did Not Catch Cross-Reference IDs

**Severity:** process-gap (observation)
**Finding class:** CI false-green class: check (e) only validated a BC's own H1 title vs its own
BC-INDEX row; it did not scan Related-BCs prose for cross-reference ID consistency.

**Description:**
Both F15-01 and F15-02 survived Passes 1–14 because no existing CI check validated whether the
BC-ID cited in a Related-BCs entry was consistent with the inline description on that citation line.
Check (e) validates H1 ↔ BC-INDEX title sync for the BC's own title. Checks (k.i)/(k.ii) validate
error-code labels. No check validated dimension-owner cross-reference ID accuracy.

**Resolution:** Added **check (p)** to `check-spec-counts.sh` v1.15:

- Scope: Related-BCs citation lines citing any of the 11 SS-07 dimension-owner BCs
  (BC-7.01.001..BC-7.11.001).
- Mechanism: For each such citation, extract the inline description; test it against a
  keyword→owner map of DISTINCTIVE compound dimension keywords (e.g., "cert-preflight",
  "playtest-satisfaction", "perf-budget", "tests/replay", "sim/spec", "provenance/legal",
  "asset-completeness", "monetization-ethics", "security-invariants", "docs convergence").
  If the description contains a keyword that maps to a DIFFERENT dimension-owner BC than
  the one cited, FAIL with the citing BC, cited ID, inline description, and expected owner.
- False-positive avoidance: only compound/distinctive forms are used as triggers; single
  words ("playtest", "cert", "perf") are excluded. Scope is limited to SS-07 dimension-owner
  citations (BC-7.01.001..BC-7.11.001) to avoid flagging legitimate paraphrases in other contexts.
- Positive-coverage log: "Check (p): N cross-references validated." always printed.
- **Validation run:** 39 SS-07 dimension-owner citations validated across 190 BCs; 0 mismatches
  confirmed post-fix. Both F15-01 and F15-02 mis-anchors would have been caught by check (p)
  in their pre-fix state.

---

## Verification Footer

- **CI gate:** `check-spec-counts.sh` **v1.15** — ALL CHECKS PASSED (checks a–p, 20 sub-assertions), exit 0.
- **BC count:** 190 (unchanged)
- **Error codes:** 213 total (204 active; E-GEN 9 retired) (unchanged)
- **Priority:** P0=126 / P1=42 / P2=22 (unchanged)
- **Caps / Subsystems:** 15 caps / 13 subsystems (unchanged)
- **BCs updated this pass:** BC-9.01.001 → v1.2; BC-8.08.004 → v1.3
- **CI gate updated this pass:** check-spec-counts.sh → v1.15 (check p added)
- **Check (p) coverage:** 39 SS-07 dimension-owner citations validated, 0 violations

---

## Pass-15 Post-Resolution Checklist

- [x] F15-01 RESOLVED: BC-9.01.001 v1.2 — BC-7.05.001 → BC-7.06.001
- [x] F15-02 RESOLVED: BC-8.08.004 v1.3 — BC-7.07.001 → BC-7.05.001
- [x] Process-gap RESOLVED: check (p) added; 39 citations validated, 0 violations
- [x] Corpus sweep: exactly 2 instances of mis-anchor class; defect class fully enumerated
- [x] CI gate v1.15 ALL CHECKS PASSED (a–p), exit 0
- [x] STATE.md updated; Pass-15 row added; counter stays 0/3
- [x] phase-1-log.md appended with Pass-15 row
