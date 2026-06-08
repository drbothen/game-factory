---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 5
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: HIGH
converged: false
clean_pass_counter: 0/3
findings_summary: "3 critical, 4 important, 1 suggestion"
---

# Phase-1d Adversarial Review — Pass 5

**Verdict:** FINDINGS (3 critical, 4 important, 1 suggestion)
**Novelty:** HIGH
**Convergence status:** NOT CONVERGED — clean-pass counter remains 0/3
**Pass-4 fixes re-verified:** ALL CONFIRMED WITH EXCEPTIONS — partial-propagation arithmetic drift found in studio §3 and §6; VP-INDEX false-completeness claim added by Pass-4 fix.

---

## Pass-4 Fix Re-Verification

| Fix | Re-Verification Result |
|-----|------------------------|
| studio-of-agents 3-way roster contradiction | CONFIRMED — §1/§2 canonical numbers correct |
| security-engineer SS-05→SS-06 anchor | CONFIRMED |
| roles 55/56/57 tier backfill | CONFIRMED |
| ARCH-INDEX studio_roles:66 | CONFIRMED |
| verification-coverage-matrix Kani 3→4 | CONFIRMED |
| error-taxonomy stale total removed | CONFIRMED |
| nfr-catalog Source column | CONFIRMED |
| CI gate v1.3 all 7 checks green | CONFIRMED |
| studio §3 per-SS counts after roster rebalance | PARTIAL — SS-05 and SS-10 cells not recomputed (C1) |
| VP-INDEX "resolves EVERY VP-TBD" claim | REGRESSION — false completeness claim introduced (C2) |

---

## Findings

### C1 — CRITICAL: studio §3 per-SS counts wrong after Pass-4 roster rebalance

**Location:** `.factory/specs/architecture/studio-of-agents.md` §3 per-SS appearance table
**Finding:** Pass-4 rebalanced the §2 roster (SS-04 ADAPT 6→3, SS-08 NEW 8→10, SS-11 NEW 8→11, security-engineer SS-05→SS-06). The §3 table was not fully recomputed from the revised §2 roster. Specific cells confirmed wrong:
- SS-05 row: stated 0/3/3 (ADAPT/NEW/Total) → correct value 3/3/6
- SS-10 row: stated total 4 → correct total 5

This is incomplete Pass-4 propagation — the §2 roster is authoritative but §3 did not track it.

**Owner:** product-owner / architect (spec)
**Resolution:** RESOLVED — Full §3 recompute performed from §2 roster using canonical counting rule (each role counted under every SS-NN listed). SS-05 corrected to 3/3/6; SS-10 corrected to 5. studio-of-agents advanced to **v1.2**.

---

### C2 — CRITICAL: VP-INDEX false completeness claim ("resolves EVERY VP-TBD reference")

**Location:** `.factory/specs/verification-properties/VP-INDEX.md` header section
**Finding:** Pass-4 introduced a statement claiming VP-INDEX "resolves EVERY VP-TBD reference in the specification." This is factually incorrect: there are approximately 130 BC-level citations in total, but VP-INDEX only listed ~18 selected entries in its VP-TBD Cross-Cutting Registry table. The claim overstates completeness and would mislead future reviewers and CI tooling.

**Owner:** product-owner / architect
**Resolution:** RESOLVED via ARCHITECT DECISION — VP-TBD-NNN labels are declared **BC-LOCAL** by design. The canonical form is `<BC-ID>/VP-TBD-NNN` (e.g., `BC-6.01.001/VP-TBD-001`). Under this convention:
- Each BC's own Verification Properties section resolves its VP-TBDs within that BC's scope.
- VP-INDEX is NOT required to enumerate all BC-local VP-TBDs globally.
- The false completeness claim ("resolves EVERY VP-TBD reference") was removed.
- VP-INDEX header replaced with: "VP-TBD Cross-Cutting Registry (selected cross-cutting entries only — per-BC VP-TBDs resolved locally within each BC's Verification Properties section)."
- Phase-6 promotion process documented: BC-local VP-TBD-NNN labels are promoted to canonical VP-NNN identifiers during Phase-6 formal hardening.
- **Decision recorded as D-015** (flagged for human awareness at Phase-1 gate).
- VP-INDEX advanced to **v1.3**.

---

### C3 — CRITICAL: VP-TBD ID collisions across BCs (same NNN = different properties)

**Location:** Multiple BC files + `.factory/specs/verification-properties/VP-INDEX.md`
**Finding:** Multiple BCs use identical VP-TBD-NNN numbers (e.g., both BC-6.01.001 and BC-3.03.001 each have a VP-TBD-001). Under a hypothetical global-namespace assumption these would collide.

**Owner:** architect
**Resolution:** RESOLVED — Collisions are **intentional and documented** under the BC-local convention established by C2/D-015. Under the canonical form `<BC-ID>/VP-TBD-NNN`, each VP-TBD is scoped to its BC, so BC-6.01.001/VP-TBD-001 and BC-3.03.001/VP-TBD-001 are distinct identifiers. No global renumbering required. Convention documented in VP-INDEX v1.3.

---

### I1 — IMPORTANT: studio §6 tier subtotals wrong (51/15 → 53/13)

**Location:** `.factory/specs/architecture/studio-of-agents.md` §6
**Finding:** Pass-4 roster changes (security-engineer reclassified T1, anti-cheat-integrator T2, moderation-ops T2; 51T1+15T2=66 stated) were not propagated to §6. After Pass-4 rebalance the canonical values are Tier 1 = 53, Tier 2 = 13 (sum = 66). The §6 table stated 51 and 15.

**Owner:** product-owner / architect
**Resolution:** RESOLVED — §6 corrected to Tier 1=53, Tier 2=13, sum=66. Covered by studio-of-agents **v1.2**.

---

### I2 — IMPORTANT: formal VPs VP-001..010 anchored one-directionally (no BC cited VP-00x back)

**Location:** Multiple BC files + `.factory/specs/verification-properties/VP-INDEX.md`
**Finding:** VP-INDEX traces VPs to BCs (VP→BC direction exists), but the guarded BC files did not cite the VP back (missing BC→VP direction). Without bidirectional anchoring, orphan VP references are undetectable and CI tooling cannot verify coverage.

**Owner:** product-owner
**Resolution:** RESOLVED — 11 formal-VP back-references added across 9 BCs:
- BC-6.01.001 → VP-001
- BC-6.01.002 → VP-009
- BC-6.01.003 → VP-002
- BC-6.02.003 → VP-003
- BC-6.02.004 → VP-004
- BC-3.03.001 → VP-008
- BC-3.03.002 → VP-008
- BC-13.02.001 → VP-005, VP-006, VP-007 (3 back-refs in one BC)
- BC-13.02.005 → VP-010

VP-TBD labels in BC Verification Properties sections are NOT modified (those remain BC-local per D-015). verification-coverage-matrix advanced to **v1.2**.

---

### I3 — IMPORTANT: subsystem-decomposition P0 subtotal 112 vs component count 111 (phantom +1)

**Location:** `.factory/specs/architecture/subsystem-decomposition.md` §Subsystem Priority Summary
**Finding:** The P0 subtotal row stated 112, but summing per-SS P0 BC counts yields 111. A phantom +1 existed in the stated subtotal (likely a carry-over arithmetic error from an earlier pass).

**Owner:** product-owner / architect
**Resolution:** RESOLVED — P0 corrected from 112 to 111. Priority Summary now: P0=111 / P1=45 / P2=22 / Grand total=178. Cross-checked: 111+45+22=178. subsystem-decomposition advanced to **v1.3**.

---

### I4 — IMPORTANT: VP priority-inversion (P1 esports VPs guard P2 CAP-013 BCs)

**Location:** `.factory/specs/verification-properties/VP-INDEX.md` + `.factory/specs/architecture/verification-coverage-matrix.md`
**Finding:** VP-005, VP-006, VP-007 are marked P1 (esports). BC-13.02.001 and BC-13.02.005 (CAP-013 cross-play/platform-services) are marked P2. A VP with higher priority than the BC it guards is a priority-inversion: it implies more rigorous verification is scheduled earlier than the feature itself ships.

**Owner:** architect
**Resolution:** RESOLVED — Rationale note added to VP-INDEX and verification-coverage-matrix: VP-005..007 are pre-activation hardening properties. These VPs guard the cross-platform protocol contracts which must satisfy esports-grade determinism from the moment CAP-013 lanes are activated (P2 wave), not after. Priority-inversion is intentional: it is not P0-blocking and it is not release-blocking for any P0/P1 wave; it only blocks activation of the CAP-013 lane (P2). Added explicit annotation: "Blocks lane activation (P2 wave), not P0/P1 release." VP-INDEX **v1.3** and verification-coverage-matrix **v1.2**.

---

### O1 — SUGGESTION (process-gap): CI gate did not validate studio §3/§6 arithmetic, subdecomp subtotals, or VP↔BC bidirectional anchors

**Location:** `scripts/check-spec-counts.sh` (CI gate)
**Finding:** The defects in C1 (studio §3/§6 arithmetic) and I3 (subdecomp P0 subtotal) and I2 (missing VP↔BC back-refs) all survived prior passes because CI was not checking them. The gate at v1.3 had 7 check classes (a–g); none of them covered these three drift classes.

**Owner:** devops-engineer / orchestrator
**Resolution:** RESOLVED — check-spec-counts.sh extended to **v1.4** with three new check classes:
- (h) studio-of-agents §3 per-SS appearance counts (recomputed from §2 roster expected values; §6 tier subtotals Tier 1=53, Tier 2=13, sum=66)
- (i) subsystem-decomposition §Subsystem Priority Summary subtotals (P0=111, P1=45, P2=22, grand total=178)
- (j) VP↔BC bidirectional anchor (all 11 formal-VP back-refs, 10 VP-ID/BC-file pairs)

CI gate v1.4 now has **10 check classes (a–j)**. ALL GREEN verified.

---

## Verification Footer

```
check-spec-counts.sh v1.4 — ALL CHECKS PASSED (exit 0)

Checks executed (a–j):
  (a) BC file count:                    178 files == stated 178 (BC-INDEX, subdecomp, ARCH-INDEX, prd.md)
  (b) Error code count:                 134 codes == stated 134 (error-taxonomy.md)
  (c) BC priority field coverage:       178/178 (100%) — 0 missing
  (d) VP P0/P1 count consistency:       P0=6, P1=4 (VP-INDEX summary + ARCH-INDEX frontmatter)
  (e) BC H1 <-> BC-INDEX title sync:    0 mismatches
  (f) BC frontmatter-schema uniformity: 0 violations
  (g) VP catalog consistency:           total=10, P0=6, P1=4 (VP-INDEX, verif-arch, verif-matrix, ARCH-INDEX); Kani=4, proptest=7
  (h) studio §3/§6:                     SS-03=16 SS-04=23 SS-05=6 SS-06=3 SS-07=3 SS-08=12 SS-09=2 SS-10=5 SS-11=11 SS-12=1; Tier1=53 Tier2=13 sum=66
  (i) subdecomp priority subtotals:     P0=111, P1=45, P2=22, sum=178 == grand total 178
  (j) VP↔BC bidirectional anchor:       11/11 back-refs present (VP-001..010 all cited in guarded BCs)
```

**Spec versions after Pass-5 resolution:**

| Document | Version |
|----------|---------|
| prd.md | v1.3 (unchanged) |
| BC-INDEX.md | v1.4 (unchanged) |
| error-taxonomy.md | v1.4 (unchanged) |
| subsystem-decomposition.md | **v1.3** (P0 112→111) |
| ARCH-INDEX.md | v1.5 (unchanged) |
| VP-INDEX.md | **v1.3** (VP-TBD BC-local convention, D-015, I2/I4 rationale notes) |
| methodology-layer.md | v1.2 (unchanged) |
| studio-of-agents.md | **v1.2** (§3 SS-05/SS-10 recomputed; §6 Tier1=53/Tier2=13) |
| verification-architecture.md | v1.0 (unchanged) |
| verification-coverage-matrix.md | **v1.2** (11 VP back-ref entries + I4 rationale note) |
| nfr-catalog.md | v1.2 (unchanged) |
| CI gate (check-spec-counts.sh) | **v1.4** (checks a–j; 10 check classes) |
