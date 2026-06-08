---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 10
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: MEDIUM-HIGH
converged: false
clean_pass_counter: 0/3
findings_summary: "0 critical, 3 important, 0 LOW observations"
---

# Phase-1d Adversarial Review — Pass 10 (candidate clean #1)

**Verdict:** FINDINGS (0 critical, 3 important)
**Novelty:** MEDIUM-HIGH — I-1 closes a fail-open cross-BC consumer/producer status-value mismatch introduced by the Pass-9 NFT fix; I-2 is a stale-prose defect class (already-resolved divergence falsely described as still-open); I-3 is SYSTEMIC (process-gap): the convergence-dimension status-value vocabulary had no canonical enum, allowing producers and consumers in different subsystems to use `AMBER` vs `GREEN/DEGRADED/DEGRADED-PENDING/BLOCKED` independently. I-3 required architect adjudication and a PO propagation sweep.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. All three importants resolved. Counter does not advance. Next = Pass 11 (candidate clean #1).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) → FINDINGS (0/3) → FINDINGS (0/3)

---

## Findings

### I-1 — NFT fail-open: producer/consumer status-value mismatch after Pass-9 fix (IMPORTANT)

**Class:** fail-open; cross-BC consumer/producer contract divergence
**Locus:** BC-10.01.001 (producer, SS-08 manifest assembler) and BC-10.06.001 (consumer, SS-08 distribution seam)
**Finding:** BC-10.01.001 was updated in Pass-9 to emit `status: auto_filled_partial_with_warnings` when the NFT override fires (new status value introduced by the NFT fail-closed fix). However, BC-10.06.001 Precondition only accepted `status: auto_filled_partial` — it did not know about the new `auto_filled_partial_with_warnings` variant. Result: a manifest produced with the NFT_PEGI18_OVERRIDE active would carry `auto_filled_partial_with_warnings`, which BC-10.06.001 would reject (fail-open) — the NFT-tainted manifest could be stranded or discarded at the DI-006/DI-011 fail-open gate without the appropriate escalation path.
**Related:** DI-006 / DI-011 fail-open; E-COMP-012 (NFT flag divergence, registered Pass-9).

**Resolution (RESOLVED):**
- BC-10.06.001 Precondition expanded to accept both `auto_filled_partial` AND `auto_filled_partial_with_warnings`; the `auto_filled_partial_with_warnings` variant triggers a mandatory Task A resolution gate (E-COMP-012 must be acknowledged before distribution is permitted).
- EC-006 (escalation contract entry) and VP-COMP-020 (verification property stub) added to the seam spec to formalize the mandatory escalation path.
- BC-10.06.001 bumped (new version).
- **CI gate:** no script change required; check (n) (status-value enum) covers the canonical set; new `auto_filled_partial_with_warnings` is an assembly-status value (not a convergence-dimension status value), so check (n) is unaffected.

---

### I-2 — Stale "Known consumer drift" note in methodology §3.0 (IMPORTANT)

**Class:** stale prose; false statement of open defect
**Locus:** methodology-layer.md §3.0, "Known consumer drift" subsection note
**Finding:** The note read: "The following BCs were found to use non-canonical field names and have not yet been updated: BC-9.04.001, BC-9.06.001, BC-9.06.002 (still use `dimensions.distribution_readiness`)." These BCs were corrected in Pass-9 (renamed to `dimensions.cert_preflight`). The note was not updated. A fresh-context reader would falsely believe these divergences remain open, undermining confidence in the spec's convergence state. A spec-under-adversarial-review cannot carry unresolved pointers to already-fixed defects as if they remain open.

**Resolution (RESOLVED):**
- Replaced the "Known consumer drift" note with a resolved-note: "All previously listed consumer-side field-name divergences (BC-9.04.001, BC-9.06.001, BC-9.06.002) were corrected in Pass-9. methodology-layer §3.0 is authoritative. CI check (m.ii) prevents recurrence."
- methodology-layer bumped to v1.4.

---

### I-3 — SYSTEMIC [process-gap]: convergence-dimension STATUS-VALUE vocabulary split (IMPORTANT)

**Class:** systemic; vocabulary fragmentation; cross-subsystem contract divergence
**Locus:** SS-07 consumers (BC-7.08.001), SS-09 producers (BC-9.01.001, BC-9.04.001, BC-9.06.001, BC-9.06.002), SS-10 producers (BC-10.02.001, BC-10.06.001), SS-11 (BC-11.01.002, BC-11.03.006), SS-13 (BC-13.01.004), and prd-cap-009-010.md
**Finding:** The convergence-report `dimensions.<field>` value vocabulary had no canonical enum defined anywhere in the spec. As a result, different subsystem owners used different value sets independently:
- SS-07 (owner of D-ETHICS convergence reporting): used `GREEN`, `DEGRADED`, `DEGRADED-PENDING`, `BLOCKED`
- SS-09/10/11 producers (cert_preflight, provenance_legal_compliance): wrote `AMBER` — a non-canonical intermediate value with no defined semantic
- D-ETHICS in BC-11.01.002/11.03.006: used binary `GREEN`/`BLOCKED` per the D-ETHICS-specific rule, but prd-cap-009-010.md line 339 retained `AMBER` for monetization_ethics
- BC-13.01.004: wrote `AMBER` for monetization_ethics transitions

Without a canonical enum, consumers (orchestration layer, analytics, convergence dashboard) cannot implement a finite state machine over dimension values; partial matches and silent AMBER→no-update paths are fail-open at the convergence aggregation layer. This is a systemic vocabulary gap that would cause Phase-3 wave-gate defects if not closed before story decomposition.

**Resolution (RESOLVED):**
- **Architect adjudication:** established the canonical status-value enum in methodology-layer.md §3.1 — new section "Canonical Convergence-Dimension Status-Value Enum". Enum: `{GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}` with per-dimension subsets. D-ETHICS is binary `{GREEN, BLOCKED}` (no intermediate DEGRADED states for ethics gate). All other dims may use all four values.
- **PO propagation:** 10 changes applied across spec artifacts:
  - BC-9.01.001: `cert_preflight` status `AMBER` → `DEGRADED-PENDING` (v bump)
  - BC-9.04.001: `cert_preflight` status `AMBER` → `DEGRADED-PENDING` (v bump)
  - BC-9.06.001: `cert_preflight` status `AMBER` → `DEGRADED-PENDING` (v bump)
  - BC-9.06.002: `cert_preflight` status `AMBER` → `DEGRADED-PENDING` (v bump)
  - BC-10.02.001: `provenance_legal_compliance` status `AMBER` → `DEGRADED-PENDING` (v bump)
  - BC-10.06.001: already updated for I-1; `cert_preflight` `AMBER` references corrected to `DEGRADED-PENDING`
  - BC-11.01.002: D-ETHICS `monetization_ethics` status `AMBER` → `BLOCKED` (binary enum; ethics gate is binary) (v bump)
  - BC-11.03.006: D-ETHICS `monetization_ethics` status `AMBER` → `BLOCKED` (v bump)
  - BC-13.01.004: `monetization_ethics` status `AMBER` → `BLOCKED` (v bump)
  - prd-cap-009-010.md line 339: `monetization_ethics` status `AMBER` → `BLOCKED` (v bump)
- **BC-7.08.001 v1.1:** D-ETHICS postconditions updated to reference methodology §3.1 binary enum; inline notation changed from "BINARY GREEN/BLOCKED" to canonical `{GREEN, BLOCKED}` with §3.1 cross-reference.
- **CI gate v1.10:** check (n) false-positive fix — frontmatter changelog `reason:` lines (YAML lifecycle prose inside `modified:` blocks) excluded from `dim_context_lines` before status-value extraction. Historical changelog prose such as "D-ETHICS is BINARY {GREEN, BLOCKED} per methodology-layer.md §3.1 (architect adjudication)" is NOT an operative dimension-status assignment; excluding it prevents false positives. Only operative BC body content (behavior steps, postconditions, invariants, test vectors) is scanned for non-canonical status values. The check still catches a genuine non-canonical value (e.g., `AMBER`) written in operative spec content.

**Files changed for I-3:** methodology-layer.md v1.4 (new §3.1), BC-9.01.001/9.04.001/9.06.001/9.06.002/10.02.001/10.06.001/11.01.002/11.03.006/13.01.004 (all bumped), BC-7.08.001 v1.1, prd-cap-009-010.md (bumped), scripts/check-spec-counts.sh v1.10.

---

## Verification Footer

**check-spec-counts.sh v1.10 ALL CHECKS PASSED**

Checks a–n (15 sub-assertions):
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
- (l) disclosure_class closed-enum: all BC declarations use canonical values — PASS
- (m.i) dimension field name count: 11 unique — PASS
- (m.ii) BC usage-site: all convergence-report dimension field references canonical — PASS
- (n) convergence-dimension status-value enum: 0 violations (changelog `reason:` lines excluded; AMBER removed from all operative spec content) — PASS

Exit code: 0
