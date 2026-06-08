---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 11
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MEDIUM
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 2 important, 3 LOW observations"
---

# Phase-1d Adversarial Review — Pass 11 (candidate clean #1)

**Verdict:** FINDINGS (0 critical, 2 important, 3 LOW observations)
**Novelty:** MEDIUM — F-11-01 and F-11-02 are fix-introduced inconsistencies from Pass-10's §3.1 status-value enum work. F-11-01 is a subset-table/owner-BC/consumer-BC/prose three-way divergence on which dimensions are permitted to use DEGRADED-PENDING. F-11-02 is a bare non-canonical token residue in SS-07 owner BCs: three tokens (BLOCKED-PENDING, DEGRADED-ACCEPTED, DEGRADED-advisory) that were present before the canonical enum was introduced and survived Pass-10 because check (n) v1.10 did not scan bare table-cell tokens in dimension context.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. Both importants resolved. Counter does not advance. Next = Pass 12 (candidate clean #1 re-attempt).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3)

---

## Findings

### F-11-01 (IMPORTANT) — DEGRADED-PENDING dimension-subset inconsistency

**Class:** fix-introduced inconsistency; subset-table / owner-BC / consumer-BC / prose four-way divergence
**Locus:** methodology-layer.md §3.1 "Per-Dimension Allowed Value Subsets" table; owner BCs BC-7.05.001 (D-PLAY) and BC-7.07.001 (D-PERF); consumer BC BC-7.12.001; §3 prose; ADR-0006 fallback column
**Finding:** Pass-10 established the canonical §3.1 status-value enum and a per-dimension subset table. The subset table stated that DEGRADED-PENDING was permitted only for D-CERT and D-PROV (the "factory work done, human/on-device act outstanding" rationale dimensions). However:
- Owner BC-7.05.001 (D-PLAY: playtest satisfaction) uses DEGRADED-PENDING in its postcondition (playtest delegation queued but not yet executed — factory work done, on-device act outstanding); the subset table said D-PLAY={GREEN, BLOCKED}.
- Owner BC-7.07.001 (D-PERF: performance budget) uses DEGRADED-PENDING in its postcondition (perf benchmarks queued but device not yet run — factory work done, on-device act outstanding); the subset table said D-PERF={GREEN, DEGRADED, BLOCKED}.
- Consumer BC-7.12.001 (convergence aggregator) accepts DEGRADED-PENDING from all reporting dimensions, including D-PLAY and D-PERF.
- §3 prose described DEGRADED-PENDING as "awaiting human/certification/external-device act" without scoping it to specific dimensions.
- ADR-0006 fallback column listed D-PLAY and D-PERF as having only GREEN/BLOCKED fallback outcomes, inconsistent with DEGRADED-PENDING being a real postcondition in those BCs.
Result: the §3.1 subset table was inconsistent with at least three BCs (two owner, one consumer) and two prose/ADR sections. CI check (n.ii) would flag this on the next run.

**Resolution (RESOLVED) — Direction A: widen DEGRADED-PENDING to permit D-PLAY and D-PERF.**

Rationale: DEGRADED-PENDING means "factory work done, human/on-device act outstanding." This is the correct semantic for D-PLAY (playtest delegation queued but not yet executed) and D-PERF (perf benchmarks queued, on-device run not yet executed). Restricting DEGRADED-PENDING to D-CERT/D-PROV only was overly narrow and inconsistent with the documented owner BC behavior. DI-007 (factory is the producer of all convergence-report fields; only factory-completable acts are required before DEGRADED-PENDING) is satisfied: playtesting can be delegated (DI-009) and perf benchmarks can be queued by the factory.

Changes applied:
- **methodology-layer.md §3.1 subset table:** D-PLAY allowed values expanded from `{GREEN, BLOCKED}` to `{GREEN, DEGRADED-PENDING, BLOCKED}`. D-PERF allowed values expanded from `{GREEN, DEGRADED, BLOCKED}` to `{GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}`. Final DEGRADED-PENDING legality: D-PLAY, D-CERT, D-PERF, D-PROV. methodology-layer bumped to **v1.5**.
- **methodology-layer.md §3 prose:** DEGRADED-PENDING description updated to reflect the four permitted dimensions and the factory-work-done / human-or-device-act-outstanding semantic.
- **ADR-0006 v1.2:** fallback columns for D-PLAY and D-PERF updated to include DEGRADED-PENDING as a valid non-fallback postcondition; fallback behavior (BLOCKED) remains for unresolvable pending states.
- **BC-7.05.001 v1.1 (owner D-PLAY):** version bumped; postcondition DEGRADED-PENDING annotation cross-references §3.1 (D-PLAY subset now correct).
- **BC-7.07.001 v1.1 (owner D-PERF):** version bumped; postcondition DEGRADED-PENDING annotation cross-references §3.1 (D-PERF subset now correct).
- **BC-7.12.001 v1.1 (consumer convergence aggregator):** version bumped; precondition list of accepted DEGRADED-PENDING-capable dimensions updated to enumerate all four: D-PLAY, D-CERT, D-PERF, D-PROV.

---

### F-11-02 (IMPORTANT) — Bare non-canonical status tokens in SS-07 owner BCs

**Class:** bare non-canonical token residue; pre-enum vocabulary surviving the Pass-10 sweep
**Locus:** BC-7.05.001 (D-PLAY owner), BC-7.07.001 (D-PERF owner), BC-7.08.001 (D-ETHICS owner)
**Finding:** Three non-canonical bare tokens remained in SS-07 owner BC dimension-context lines after the Pass-10 canonical-enum propagation sweep. They appeared as bare (unquoted) text in markdown table cells, not backtick-quoted or in verb phrases, so they were not caught by check (n.i)'s extraction patterns:
- BC-7.05.001: `BLOCKED-PENDING` (table cell, "playtest blocked pending content flag resolution") — non-canonical; maps to `BLOCKED`.
- BC-7.08.001: `DEGRADED-advisory` (table cell, "ethics monitor degraded-advisory level") — non-canonical; maps to `DEGRADED`.
- BC-7.05.001 also had: `DEGRADED-ACCEPTED` (table cell, "playtest result degraded-accepted by product owner waiver") — non-canonical; maps to `DEGRADED`.
These tokens had clear semantic mappings to canonical values and did not represent new semantics. Retaining them would cause CI check (n.iii) v1.11 failures on future passes.

**Resolution (RESOLVED):**
- **BC-7.05.001 v1.1** (already bumped for F-11-01): bare tokens `BLOCKED-PENDING` → `BLOCKED` and `DEGRADED-ACCEPTED` → `DEGRADED` replaced in all dimension-context table cells. Notes clarifying the mapping added in parenthetical inline prose where semantic precision is needed.
- **BC-7.08.001 v1.2:** bare token `DEGRADED-advisory` → `DEGRADED` replaced in all dimension-context table cells. Parenthetical clarification retained.
- **BC-7.12.001 v1.1** (already bumped for F-11-01): consumer aggregator postcondition tables verified clean — no bare non-canonical tokens.
- **BC-7.07.001 v1.1** (already bumped for F-11-01): verified clean; DEGRADED-PENDING was correctly backtick-quoted and canonical.

---

### O-1 (LOW, deferred) — Methodology §3 dimension "Subsystem" field dual-meaning clarification

**Locus:** methodology-layer.md §3 dimension table, "Subsystem" column header
**Observation:** The §3.0 dimension table has a column labeled "Subsystem" that names the source-domain subsystem (e.g., D-CERT is anchored to SS-08/SS-09) AND implicitly doubles as the owner-BC subsystem anchor. However, the §3.1 per-dimension subset table's "Owner BC" column names SS-07 evaluation-layer BCs (BC-7.05.001, BC-7.07.001, etc.) as owner BCs for dimensions whose §3.0 "Subsystem" column lists their source domain (SS-08, SS-06, etc.). A fresh-context reader sees "Subsystem = SS-08" and may assume SS-08 BCs own the convergence-reporting contract, but BC-7.XX.001 is the actual owner. A one-line clarifying note under the column header would resolve the ambiguity.
**Status:** Non-blocking; recorded as FU-008 for optional doc-cleanup in a future pass.

### O-2 (LOW, deferred) — SS-01 and SS-02 convergence dimension scoping comment

**Locus:** methodology-layer.md §3.0 dimension table, D-IMPL and D-DOCS rows
**Observation:** D-IMPL (implementation completeness) and D-DOCS (documentation) are the two dimensions not covered by the "distinctive dim fields" filter in CI check (n)'s anchor logic (the script deliberately excludes generic English words "implementation" and "docs" from the dim_field_pattern). The §3.0 table does not have a note explaining this CI-scoping choice. A brief explanatory comment in methodology-layer.md §3.0 (or in the CI script comment) would prevent a future maintainer from adding "implementation" or "docs" as a prose-trigger field and accidentally triggering false positives. Sampled SS-01 and SS-02 BCs: all clean (no AMBER or non-canonical values in any dimension-context lines).
**Status:** Non-blocking; deferred for doc-cleanup.

### O-3 (LOW, deferred) — ADR-0006 dimension-scope table column ordering

**Locus:** ADR-0006.md, per-dimension fallback table
**Observation:** The ADR-0006 per-dimension table was updated in this pass for F-11-01 (D-PLAY and D-PERF DEGRADED-PENDING added). The table column ordering (Dimension | Default GREEN | DEGRADED-PENDING path | Fallback BLOCKED) is internally consistent but differs slightly from the §3.1 subset table's column ordering (Dimension | Allowed Values | Rationale). A future alignment pass could unify column headings for readability. Non-blocking.
**Status:** Non-blocking; deferred for doc-cleanup. May fold into FU-008 or a separate ADR cleanup pass.

---

## Process Gap — CI check (n.ii) and (n.iii) Recurrence Prevention

The two importants in this pass reveal that the v1.10 CI gate had two gaps:
1. (n.ii) gap: no per-dimension subset enforcement — the flat canonical enum was checked, but dimension-specific subset tables were not enforced. A value valid in the flat enum could be written for a dimension that does not permit it.
2. (n.iii) gap: no bare table-cell token scan — non-canonical hyphenated tokens written as unquoted bare text in markdown table cells in dimension context were not detected.

**Resolution (RESOLVED):** check-spec-counts.sh extended to v1.11:
- **(n.ii)** per-dimension subset enforcement: parses the §3.1 "Per-Dimension Allowed Value Subsets" table from methodology-layer.md; builds a dimension→allowed-value-set map; for each BC line that both names a specific dimension (by field name or D-XX ID) and contains a status value, asserts the value is in that dimension's allowed subset. Catches F-11-01-class regressions.
- **(n.iii)** bare table-cell token scan: widens BC scan to catch hyphenated non-canonical tokens (BLOCKED-PENDING, DEGRADED-ACCEPTED, DEGRADED-advisory pattern: [A-Z][A-Z]+-[A-Z][A-Za-z]+) in dimension-context lines; excludes canonical enum members, changelog reason: lines, known spec identifier prefixes (VP-*, BC-*, ADR-*, etc.), and known legitimate hyphenated compounds (SAG-AFTRA, AI-generated, CPU-bound, etc.). Catches F-11-02-class tokens.
- Both sub-checks exclude changelog `reason:` lines (same as v1.10 fix).
- POSIX/BSD-grep compatible; no grep -P.

---

## Verification Footer

**check-spec-counts.sh v1.11 ALL CHECKS PASSED**

Checks a–n (16 sub-assertions):
- (a) BC file count: 178 computed == 178 stated — PASS
- (b) Error code count: 198 computed == 198 stated — PASS
- (c) BC priority field coverage: 178/178 — PASS
- (d) VP P0/P1 consistency: P0=6/P1=4 across VP-INDEX + ARCH-INDEX — PASS
- (e) BC H1 ↔ BC-INDEX title sync: 178 checked, 0 mismatches — PASS
- (f) BC frontmatter-schema uniformity: 178 checked, 0 violations — PASS
- (g) VP catalog consistency: total=10, P0=6, P1=4, Kani=4, proptest=7 — PASS
- (h) studio-of-agents §3 per-SS appearance counts + §6 tier subtotals — PASS
- (i) subsystem-decomposition priority subtotals P0=117/P1=39/P2=22 — PASS
- (j) VP ↔ BC bidirectional anchor: all 11 formal VP back-refs present — PASS
- (k) error-identifier resolution: all BC E-codes registered — PASS
- (l) disclosure_class closed-enum: all BC enum declarations use canonical values — PASS
- (m.i) dimension field name count: 11 unique — PASS
- (m.ii) BC usage-site: all convergence-report dimension field references canonical — PASS
- (n.i) convergence-dimension status-value enum: 0 violations (changelog reason: lines excluded) — PASS
- (n.ii) per-dimension subset enforcement: 0 violations (DEGRADED-PENDING widened to D-PLAY + D-PERF; subset table reconciled with owner/consumer BCs) — PASS
- (n.iii) bare table-cell token scan: 0 violations (BLOCKED-PENDING/DEGRADED-ACCEPTED/DEGRADED-advisory mapped to canonical) — PASS

Exit code: 0
