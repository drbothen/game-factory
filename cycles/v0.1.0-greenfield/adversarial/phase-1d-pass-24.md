---
document: adversarial-review
cycle: v0.1.0-greenfield
pass: 24
phase: 1d
date: 2026-06-08
verdict: FINDINGS
finding_summary: 0C / 1I / 3 obs
novelty: MEDIUM
clean_pass_counter_before: 0/3
clean_pass_counter_after: 0/3
candidate_clean_streak: 1
candidate_clean_restart: true
---

# Phase-1d Adversarial Pass 24 — VERDICT: FINDINGS (candidate clean #1 restart)

**Date:** 2026-06-08
**Verdict:** FINDINGS — 0 critical / 1 important / 3 observations
**Novelty:** MEDIUM
**Clean-pass counter:** 0/3 (reset; Pass-24 found a blocking I-class finding — streak restarts)
**Next pass:** Pass 25 (candidate clean #1 restart)

---

## Summary

Pass-24 was the first candidate clean pass after the streak reset caused by Pass-23.
A blocking IMPORTANT finding was discovered: the FU-009 defect class (SS-07→SS-06
owner-attribution mislabel in methodology-layer.md) that had been deferred as
non-blocking in Pass-22 was promoted to BLOCKING in Pass-24. The finding was
broader than the two prose lines originally noted — it encompassed 7 sites across
methodology-layer.md (prose lines ~105 and ~130, plus the §3.1 CI script comments
and convergence-report log lines at ~611 and ~616), plus version-changelog entries,
plus CI-script inline-comment label text. Additionally the BC range in the §3.1
dimension-owner section was corrected from "BC-7.01.001..BC-7.12.001" (which
incorrectly included the loop-engine BC-7.12.001) to "BC-7.01.001..BC-7.11.001".
All 7 sites were corrected. FU-009 is now CLOSED. Check (t) was added to guard
against recurrence. The streak remains at 0/3.

The three observations were non-blocking: (O24-01) the per-dimension §3 producing-
subsystem headers (e.g. "D-PLAY → SS-07") use legitimately different semantics
from owner-attribution and are correct as-is; (O24-02) ADR-0006/§3 fallback
semantics for missing convergence fields checked clean; (O24-03) other duplicated-
data tables spot-checked clean against their authoritative sources.

---

## Findings

### I24-01 (IMPORTANT) — SS-07→SS-06 Owner-Attribution Mislabel — RESOLVED

**Defect class:** methodology-layer prose (and related artefact lines) mislabeled
the BC-7.* dimension-evaluator/owner family as belonging to "SS-07" when the
authoritative owner is **SS-06** (Convergence Tracking Engine).

**Root cause:** The `ss-07/` directory name (Playtest Protocol) shares a numeric
prefix with the convergence-dimension BC-7.* series. Early prose was written using
the directory number rather than the subsystem alias. The two structured anchors
(BC frontmatter `subsystem: SS-06`, ARCH-INDEX registry) were always correct;
only the free-form prose and one range limit drifted.

**Instance inventory (7 sites corrected):**

| Site | Old text | Corrected to |
|------|----------|--------------|
| methodology-layer.md ~105 | "…dimension-owner (SS-07)…" | "…dimension-owner (SS-06)…" |
| methodology-layer.md ~130 | "owner BCs (SS-07)" | "owner BCs (SS-06)" |
| methodology-layer.md ~611 | "dimension-owner (SS-07)" in §3.1 CI comment | "dimension-owner (SS-06)" |
| methodology-layer.md ~616 | range "BC-7.01.001..BC-7.12.001" | "BC-7.01.001..BC-7.11.001" |
| methodology-layer.md ~616 | "owner BCs (SS-07)" in log line | "owner BCs (SS-06)" |
| methodology-layer.md changelog v1.9 entry | label text SS-07 | SS-06 |
| CI script comment label | "dimension-owner (SS-07)" | "dimension-owner (SS-06)" |

**BC range correction:** `BC-7.12.001` is the convergence loop engine (producer
in SS-07's D-PLAY dimension), NOT a dimension-owner BC. The dimension-owner family
runs BC-7.01.001 through BC-7.11.001 (11 dimension-owners; one per dimension,
excluding the loop engine).

**Authoritative references:** ARCH-INDEX.md Subsystem Registry (SS-06 = Convergence
Tracking Engine, SS-07 = Playtest Protocol); subsystem-decomposition.md SS-06/SS-07
entries; ADR-0006; BC-7.* frontmatter `subsystem: SS-06`.

**Resolution:** All 7 sites corrected. methodology-layer.md bumped to v1.9.

**Process-gap closed:** Check (t) added to check-spec-counts.sh (v1.22). The check
scans methodology-layer.md and all architecture/*.md files for the two compound
patterns that exclusively signal a false ownership claim:
- `dimension-owner (SS-0[^6]` — matches any owner attribution not to SS-06
- `owner BCs (SS-0[^6]` — matches any owner BCs attribution not to SS-06

Per-dimension `Subsystem: SS-07` producing-subsystem headers in §3 do NOT contain
either compound, so they are naturally excluded (no additional filter needed).

**Corpus sweep:** 4,145 lines scanned across architecture docs. 0 violations after
the fix. Check (t) exits 0.

**FU-009 status:** CLOSED. Was deferred as non-blocking in Pass-22; promoted to
blocking in Pass-24 because it directly mis-identifies the subsystem that owns
11 convergence-dimension BCs. Fixed before the clean-pass streak could be
established.

---

### O24-01 (OBS — non-blocking) — Per-Dimension §3 Producing-Subsystem Headers

The §3 per-dimension sections in methodology-layer.md use `Subsystem: SS-07`
(and similar) to denote the **PRODUCING** subsystem for each dimension — i.e. the
subsystem whose BCs generate the evaluated artifact. This is a legitimately
different semantic from OWNER (SS-06 evaluates the artifact; SS-07 produces it).
The dual-semantic is by design (ADR-0006 §3 structure). No change required.

Check (t) confirms this is safe: the producing-subsystem headers do not contain
the compound patterns `dimension-owner (SS-0` or `owner BCs (SS-0`, so they are
naturally excluded from the ownership guard.

---

### O24-02 (OBS — non-blocking) — ADR-0006/§3 Fallback Semantics

ADR-0006 §3 fallback for missing convergence-report fields (treat absent dimension
as GREEN) was verified consistent with methodology-layer §3 prose and BC-7.12.001
(loop engine) semantics. No contradiction found.

---

### O24-03 (OBS — non-blocking) — Duplicated-Data Tables Spot-Check

Cross-checked 3 additional duplicated-data tables (ARCH-INDEX subsystem roster vs
subsystem-decomposition.md; studio-of-agents §3 SS-06 count vs §2 roster; BC-INDEX
Summary table CAP-007/015 counts vs section row counts). All clean, 0 mismatches.

---

## Specification Changes This Pass

| File | Version | Change |
|------|---------|--------|
| `.factory/specs/architecture/methodology-layer.md` | v1.8 → **v1.9** | 7 SS-07→SS-06 corrections (prose ~105/130, §3.1 CI comments ~611, range ~616 BC-7.01..7.12→7.01..7.11, log ~616, changelog label); FU-009 closed |

---

## CI / Script Changes This Pass

| File | Version | Change |
|------|---------|--------|
| `scripts/check-spec-counts.sh` | v1.21 → **v1.22** | Check (t) added: BC-7.* owner-attribution guard — POSIX/BSD grep; scans methodology-layer.md + architecture/*.md for `dimension-owner (SS-0[^6]` and `owner BCs (SS-0[^6]`; blockquote/changelog lines excluded; positive-coverage log always printed |

---

## Verification

**CI gate:** check-spec-counts.sh **v1.22** — ALL CHECKS PASSED (checks a–t,
~28 sub-assertions). Exit code: 0.

Counts confirmed:
- BC files: **190**
- Error codes: **255** (246 active; E-GEN 9 retired)
- NFRs: **41**
- Priority P0/P1/P2: **126 / 42 / 22**
- Check (t) scan: 4,145 lines scanned, **0 violations**

---

## Follow-up Items Status

| ID | Status after Pass-24 |
|----|---------------------|
| FU-005 | ONGOING — 3 clean passes needed from Pass 25 |
| FU-006 | OPEN (non-blocking) — human ratification at Phase-1 gate |
| FU-007 | OPEN (non-blocking) |
| FU-008 | OPEN (non-blocking) |
| FU-009 | **CLOSED** — SS-07→SS-06 mislabel fixed (7 sites); methodology-layer v1.9; check t added |
