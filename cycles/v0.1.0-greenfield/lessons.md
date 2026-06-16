---
document_type: lessons-learned
level: ops
version: "1.0"
status: in-progress
producer: state-manager
timestamp: 2026-06-13T00:00:00Z
cycle: v0.1.0-greenfield
inputs: [STATE.md]
traces_to: STATE.md
---

# Lessons Learned — v0.1.0-greenfield

Extracted from STATE.md during compaction (2026-06-13).
STATE.md now indexes these by ID with a pointer to this file.

---

## Process-Level

1. **LESSON-F43 — Scaffold-then-author two-burst pattern requires a status-propagation sweep.**
   When an architect reserves BC IDs ("reserved/to author") and a product-owner authors the BCs in a subsequent burst, the architect's "reserved/to author" prose in arch docs (methodology, ARCH-INDEX, cicd-setup, ADRs) becomes stale. The sweep to update those docs to "authored/active" MUST be part of the authoring burst, not left for the next adversary pass. Codified by CI check (dd) gate v1.33 (F43-01 process-gap).
   _Discovered: Pass 43, 2026-06-09_

2. **LESSON-F46 — Vocabulary/trigger-drift fixes must grep the WHOLE corpus up front and gate corpus-wide.**
   A fix scoped to only the originally-reported files will leave sibling-BC drift that a later fresh-context adversary pass surfaces and resets the streak. Invert the pattern: always grep corpus-wide first, fix all instances, then gate the corpus. Codified by corpus-wide check (ee) v1.35 (F46-01 process-gap).
   _Discovered: Pass 46, 2026-06-10_

3. **LESSON-F49a — Index/summary surfaces must be gated against source-file counts; fix one count → audit ALL counts in same doc.**
   When a count discrepancy is found in an index (e.g., L2-INDEX), do a comprehensive audit of ALL counts in the same document rather than fixing only the reported one. The adversary missed the Glossary 42→36 drop; the orchestrator's comprehensive audit caught it. Codified by check (ff) gate v1.36 (F49-01 process-gap).
   _Discovered: Pass 49, 2026-06-10_

4. **LESSON-F49b — Never credit a pass without the orchestrator's own independent gate run (exit 0).**
   A subagent reported its gate PASSING when it deterministically FAILED (BSD-awk `\s` bug in the priority-sum parser). The orchestrator's independent gate run caught it. REAFFIRM: the orchestrator MUST run `bash scripts/check-spec-counts.sh` independently and see exit 0 before crediting any pass. Subagent self-reports are not sufficient.
   _Discovered: Pass 49, 2026-06-10_

5. **LESSON-F52 — Recurrence-guard keyword scoping that enumerates WRONG contexts is structurally blind to new occurrences in other contexts.**
   Check (w) originally required "cinematic" keyword in the DI-007 window, meaning any DI-007 mis-anchor in a non-cinematic context escaped. Invert: require the RIGHT context keyword (playtest) near any DI-007 citation so that ANY wrong-context occurrence (cinematic, Canon-KB, etc.) is caught. Codified by check (w) v1.37 generalization.
   _Discovered: Pass 52, 2026-06-10_

6. **LESSON-F53 — A security-burst that hardens a dimension predicate must reciprocally update the dimension's evaluator BC.**
   When a new signal BC (BC-1.15.003 never-emit-secrets) is authored and the dimension predicate (D-SEC) is hardened to include it, the dimension's EVALUATOR/owner BC (BC-7.11.001) must also be updated to consume the new sub-predicate. A one-directional back-reference (signal→evaluator) without the evaluator consuming the signal leaves the evaluator fail-open for that signal. Codified by check (gg) evaluator-completeness guard (gate v1.38).
   _Discovered: Pass 53, 2026-06-10_

7. **LESSON-F56 — A dimension-semantics hardening must sweep ALL surfaces that restate the dimension's allowed-status-set and enable-rules.**
   When D-SEC was hardened (fail-closed/no-degrade, SP4 unconditional in BC-7.11.001 v1.2), the fix propagated to the owner BC but NOT to the methodology §3.1 (A)/(B) summary tables (still listed DEGRADED/offline-only) nor to the §4.3 enable rule (online-only), nor to BC-7.11.002's test vector ("GREEN by inapplicability"). All restated surfaces must be swept atomically: owner BC, methodology summary tables, enable-rule prose, AND sub-invariant BC test vectors. Codified by check (jj) D-SEC no-DEGRADED-path consistency guard (gate v1.41).
   _Discovered: Pass 56, 2026-06-10_

8. **LESSON-F58 — Warning codes, like error codes, must be registered in the error taxonomy and gated by the CI check.** [codified]
   Check (k) enforced registration of E-codes (E-XXX-NNN) referenced in BCs. No equivalent existed for W-codes (W-XXX-NNN). This gap allowed BC-14.02.001 EC-001 to cite W-XR-002 in a case where the contract's own Invariant 1 and canonical test vector required E-XR-004 (rejected input), and the error went undetected by the gate. Codified by: (a) PO registering W-XR-001..004 in error-taxonomy.md under a new `## Warning Codes` section (v2.5); (b) architect adding check (kk) W-code identifier-resolution guard to check-spec-counts.sh (gate v1.42). Pattern: any new warning code family introduced in a BC must be registered in error-taxonomy.md and confirmed by gate.
   _Discovered: Pass 58, 2026-06-13_

9. **LESSON-F60 — A VP property-statement re-scope must sweep ALL downstream surfaces: VP-INDEX, verification-architecture P0/P1 table, verification-coverage-matrix, AND every guarded-BC "Formally verified by VP-NNN (...)" back-ref (including the counterpart BC).** [pending-codification]
   F40-04 corrected VP-007 to cover dual invariants (INV-TS-02 + INV-TS-03). Pass 60 found that two downstream surfaces still carried the stale single-invariant form: verification-architecture.md:72 P1 table and BC-13.02.001:190 VP Anchors. Similarly, F60-02 found VP-004's property statement over-stated (win-only), contradicting BC-6.02.004 EC-001 (win OR game-over) — requiring correction across VP-004 file, VP-INDEX, verification-architecture, verification-coverage-matrix, AND BC-6.02.004's own VP-004 back-ref. The pattern: any VP re-scope must atomically sweep all surfaces that restate the property: (a) the VP file itself, (b) VP-INDEX Summary Table + I2 table, (c) verification-architecture P0/P1 Property column, (d) verification-coverage-matrix Guarded Invariant column, (e) every guarded BC's VP Anchors/Formally-Verified line. Codification tracked as FU-024 — gate check (ll) deferred until BC VP back-refs are normalized verbatim-from-VP-INDEX (per LESSON-F52: avoid over-firing gates).
   _Discovered: Pass 60, 2026-06-13_

10. **LESSON-F61 — A determinism/replay model fix (e.g. F40-01 T2=snapshot-structured-diff) must sweep the adapter-protocols.md architecture doc (tier table + ReplayResult schema enum), not just the BC layer and methodology.** [codified]
    F40-01 established T2 (same-machine replay) uses `snapshot-structured-diff` — propagated to BC-1.12.002/003, BC-3.03.004, and methodology §D-REPLAY. Pass 61 found that adapter-protocols.md (the implementer-facing doc) was skipped: §2.3 still mapped `same-machine → snapshot-hash-diff` (a DeterminismTierViolation per the very BC the fix cited), and §2.5 omitted `snapshot-structured-diff` from the ReplayResult `method` enum (making any conformant T2 adapter schema-invalid). The fix pattern: any replay-method change must sweep (a) the canonical BCs, (b) methodology §D-REPLAY, AND (c) adapter-protocols.md §2.3 tier table + §2.5 ReplayResult enum. Codified in gate check (ll) v1.43. Also: a new gate guard MUST be validated by the orchestrator's own gate run before crediting a pass — Assertion B initially mis-scoped on a multi-`method` document (inspected wrong line of six); caught pre-commit by orchestrator's independent run; architect re-anchored.
    _Discovered: Pass 61, 2026-06-13_

11. **LESSON-F62 — An ADR is a normative source and must be internally self-consistent AND consistent with the BC/taxonomy it governs; a wrong-but-registered E-code (semantic mis-routing) passes check (k) — the routing target must also be semantically correct.** [codified]
    ADR-0008 §Conformance Assertion item 3 (line 91) stated that kernel-anomaly providers (vanguard/riot-vanguard/vgk) emit error code E-ANTICH-001. E-ANTICH-001 = "Provider not in allowed set" — a registered, real code — so check (k) passed. But the semantically correct code for a kernel-anomaly provider is E-ANTICH-002 = "Kernel-anomaly provider attempted", as stated in: (a) ADR-0008's own Consequences §3 (line 165), (b) BC-13.02.006 PC3/INV-2, (c) error-taxonomy.md:728 canonical mapping, and (d) prd.md:277. The mis-routing was self-contradictory within the ADR itself. Fix: ADR-0008 v1.1→v1.2 (line 91 corrected). Codified in gate check (mm) v1.44 (anti-cheat kernel-anomaly routing guard): any line co-locating a kernel-anomaly token (vanguard/riot-vanguard/vgk) with E-ANTICH-001 BUT NOT also E-ANTICH-002 is a violation. The same-line E-ANTICH-002 exclusion (per LESSON-F52) prevents false-firing on family-enumeration rows in error-taxonomy.md and ADR-0008 Consequences §3 that legitimately list both codes. Pattern: for any safety-critical routing rule in an ADR/BC, verify the cited error code is semantically correct, not merely registered.
    _Discovered: Pass 62, 2026-06-13_

12. **LESSON-F64 — An enum-value migration (AMBER→canonical) must sweep ALL live prose corpus-wide, not just structured dimension lines and changelogs; residual stale tokens in traceability glosses, preconditions, PRD prose, and domain-spec prose will survive if the sweep is scoped too narrowly.** [codified]
    Pass-10 migrated the non-canonical AMBER token to the canonical GREEN/DEGRADED-PENDING/BLOCKED enum. The migration swept structured dimension-context lines and changelog entries, but left four live-prose residuals: BC-11.01.002:126 (DI-006 traceability gloss used "amber"), BC-11.01.003:48 (Precondition 3 used "amber"), prd-cap-011.md:123 (PRD monetization-ethics dimension narrative), and domain-spec/processes.md:179 (domain process prose). All four survived because check (n) gates non-canonical tokens only on structured dimension-context lines — free prose was not covered. The adversary's manual read caught 2 of 4 instances; the orchestrator's corpus-wide grep caught all 4 — reinforcing LESSON-F46 (grep the whole corpus, not just reported files). Fix: all four files updated to BLOCKED/DEGRADED-PENDING. D-ETHICS (#10) binary invariant preserved. Codified in gate check (nn) v1.45 (non-canonical amber-token prose guard): scans behavioral-contracts/, prd-supplements/, and domain-spec/ for any "amber" (case-insensitive) in operative prose, exempting architecture/ (methodology-layer.md canonical migration doc) and changelog/reason:/modified: lines. Pattern: any enum-value migration must be followed by a corpus-wide grep of the old token across ALL prose surfaces (not just structured tables), then codified as a gate check to prevent recurrence.
    _Discovered: Pass 64, 2026-06-16_

13. **LESSON-F65 — A manifest-validation BC that hard-gates a field (E-EAP-012 / MalformedManifest) MUST have a matching mandatory-field rule in adapter-protocols.md §6.2/§2.2; omitting the rule creates a producer/consumer divergence the CI gate cannot catch.** [codified]
    BC-15.01.001 (F40-07) added `leaderboards.variantsSupported` to its validated sub-fields and hard-gated it with E-EAP-012 (PC5/EC-007/EC-008). The §6.2 "Mandatory field rules:" block was not updated — variantsSupported appeared only as an unannotated schema example, making it invisible to any implementer reading the mandatory-field list. Additionally, BC-15.01.001's PC1 live-prose citation pointed at adapter-protocols.md:822 (the `selfHostable` field line) rather than the variantsSupported rule. This class has now recurred three times: F35-01 (seam enum completeness), F61-01 (T2 comparison method), F65-01 (variantsSupported). Pattern: any time a BC hard-gates a manifest field, the §6.2 mandatory-field rule MUST be written atomically. Fix: adapter-protocols v1.5→v1.6 (added rule + `// MUST be non-empty` annotation); BC-15.01.001 v1.1→v1.2 (citation corrected). Codified as gate check (oo) v1.46 — a curated allow-list {selfHostable, serverAuthoritative, offlineProject, variantsSupported} that must each appear in the §6.2 mandatory-rule block. Per LESSON-F52, the allow-list avoids the fragile prose-extraction path; adding a new E-EAP-012-gated field requires updating both §6.2 AND the OO_FIELDS list in check-spec-counts.sh.
    _Discovered: Pass 65, 2026-06-16_

14. **LESSON-F66 — When the adversary loop produces a persistent one-IMPORTANT-finding-per-pass pattern of the SAME meta-class (propagation residuals from prior multi-file fixes), pull the fresh-context consistency audit forward to drain the entire tail in one sweep rather than one-finding-per-pass whack-a-mole.** [process]
    Passes 63–65 each surfaced exactly one IMPORTANT finding of the same class: propagation residuals left by earlier multi-file fix bursts (AMBER migration, adapter-seam divergence). Each finding reset the clean-pass counter. Instead of dispatching Pass 66 against the same residual-laden corpus, the consistency-validator audit (T10) was pulled forward. It found 36 residuals R-01..R-36 at once (25 IMPORTANT, 11 OBSERVATION) — the full tail the adversary would have found one-per-pass. After the sweep, Pass 66 runs against a drained corpus. Also reinforced: a comprehensive corpus grep (as run by the consistency validator) beats per-pass manual reading — the adversary found 2 amber residuals in Pass 64; the audit + orchestrator grep found the full set of 4 (reinforcing LESSON-F46 at scale). Pattern: when 2+ consecutive adversary passes return a single IMPORTANT finding of class "propagation residual / stale-citation / cardinality-drift", escalate to a full consistency sweep before the next pass rather than iterating one-by-one.
    _Discovered: Phase-1d consistency sweep, 2026-06-16_

16. **LESSON-F68 — VP harness SKELETONS (not just property statements) are spec-package surface and can carry false-green defects; when one harness defect is found, audit ALL VP harnesses at once for the defect class.** [process]
    Pass 67 found two VP harness defects in the same session: F67-01 (VP-006: epsilon applied in the relaxing direction `rd_old + 1e-9` for a strict-decrease property — a no-decay regression passed false-green) and F67-02 (VP-001: Kani assert on pre-op `state.total_resource(resource_id)` instead of `state_after.total_resource(resource_id)` — the P0 economy-conservation proof was inert because `apply()` is a pure `(State,Op)→State` function and the pre-op state is always unchanged). Both classes (epsilon-direction-vs-strictness; assert-on-wrong-variable) can masquerade as valid proofs while silently accepting regressions. The LESSON-F66 discipline (audit-all-on-one-found) was applied to the VP layer: all 10 VP harness skeletons were audited for both defect classes — only VP-001 and VP-006 were defective; VP-002/003/004/005/007/008/009/010 confirmed CLEAN. The VP files that predate a harness-correctness sweep (v1.0 harnesses, those predating the F37/F40 harness sweep) are the highest-risk group. Pattern: (1) for strict-inequality properties, always verify epsilon is applied in the TIGHTENING direction (property-value minus epsilon), not the relaxing direction; (2) for pure-function proofs, always assert on the OUTPUT of the pure function, not the unchanged input; (3) when either defect class is found in one VP, sweep all VPs for both classes before closing the burst.
    _Discovered: Pass 67, 2026-06-16_

15. **LESSON-F67 — A code split/rename burst must enumerate ALL mirror surfaces up front: authoritative taxonomy + consuming BCs + PRD count summary + per-CAP §5 error tables + any ADR/glossary that names the taxonomy.** [process]
    The Pass-66 fix-induced residuals (F66-01: prd-cap-005 §5 error table; F66-02: ADR-0004 and ubiquitous-language backend_class entry) show that even a sweep's own fixes need a propagation checklist. The 2026-06-16 consistency sweep correctly updated the authoritative error-taxonomy.md (E-AUD-004→E-AUD-005 split; E-PROD-003→E-PROD-004 split), the BCs that reference those codes, and error counts in PRD/ARCH-INDEX. But the per-CAP §5 error tables (which mirror taxonomy codes for implementer convenience) and ADR/glossary prose that names taxonomy enum values were not in the sweep's file set. Both residuals were caught by the adversary's first fresh-context pass (Pass 66) against the drained corpus. A 3rd sibling (ubiquitous-language conflated "Backend Class" entry) was caught by comprehensive grep during the fix burst — the adversary did not flag it. Pattern: before closing any code-split/rename burst, run a checklist: (1) authoritative taxonomy file; (2) all BCs referencing the old code(s); (3) PRD/ARCH-INDEX count summaries; (4) per-CAP §5 error tables for every affected CAP; (5) any ADR or glossary entry that names the old enum value or concept. Codification candidate tracked as FU-027.
    _Discovered: Pass 66, 2026-06-16_

---

## Policy Candidates

| Lesson | Proposed Policy | Scope | Status |
|--------|----------------|-------|--------|
| LESSON-F43 | Scaffold-then-author burst must include status-propagation sweep | BC authoring workflow | adopted (check dd) |
| LESSON-F46 | Vocabulary fixes always corpus-wide with corpus-wide gate | Adversarial review workflow | adopted (check ee) |
| LESSON-F49a | Count-fix triggers comprehensive doc audit | Index/summary maintenance | adopted (check ff) |
| LESSON-F49b | Gate run must be orchestrator-independent | Pass-crediting protocol | proposed |
| LESSON-F52 | Recurrence guards use right-context positive assertion | CI gate design | adopted (check w v1.37) |
| LESSON-F53 | Dimension hardening must update evaluator BC body | Security BC authoring | adopted (check gg) |
| LESSON-F56 | Dimension-semantics hardening sweeps all restatement surfaces | Architecture/BC sync | adopted (check jj) |
| LESSON-F58 | Warning codes must be registered in error taxonomy and gated (same as E-codes) | BC authoring workflow | adopted (check kk) |
| LESSON-F60 | VP re-scope must sweep all downstream surfaces (VP file, VP-INDEX, arch tables, coverage-matrix, guarded BC back-refs) | VP authoring / adversarial review | pending-codification (FU-024; gate deferred per LESSON-F52) |
| LESSON-F61 | Replay-method fix must sweep adapter-protocols.md §2.3 tier table + §2.5 ReplayResult enum; new gate guards must be validated by orchestrator's own run | Replay/determinism fix workflow; CI gate authoring | adopted (check ll v1.43) |
| LESSON-F62 | ADR normative routing must be semantically correct E-code, not merely registered; wrong-but-registered E-code passes check (k); use same-line exclusion guard to prevent false-fires on enumeration rows | ADR authoring / BC adversarial review | adopted (check mm v1.44) |
| LESSON-F64 | Enum-value migration must sweep ALL live prose corpus-wide (not just structured tables/changelogs); adversary found 2 of 4 residuals; orchestrator grep found all 4 (reinforces LESSON-F46); codified as post-migration corpus-wide sweep + gate check | BC/PRD/domain-spec authoring | adopted (check nn v1.45) |
| LESSON-F65 | A manifest-validation BC that hard-gates a field (E-EAP-012) MUST have a matching mandatory-field rule in adapter-protocols.md §6.2; omitting the rule creates producer/consumer divergence invisible to CI; class has recurred 3× (F35-01 seam enum, F61-01 T2 method, F65-01 variantsSupported); curated allow-list guard avoids false-firing (per LESSON-F52) | BC authoring / adapter-protocols sync | adopted (check oo v1.46) |
| LESSON-F66 | When the adversary loop produces a persistent one-IMPORTANT-finding-per-pass pattern of the same meta-class (propagation residuals), pull the consistency audit forward to drain the full tail in one sweep rather than one-per-pass; 36 residuals found at once vs 1/pass; comprehensive corpus grep beats per-pass manual reading (reinforces LESSON-F46 at scale) | Adversarial review workflow | proposed |
| LESSON-F67 | A code split/rename burst must enumerate ALL mirror surfaces up front (authoritative taxonomy + BCs + PRD count summary + per-CAP §5 error tables + ADR/glossary); per-CAP §5 tables and ADR/glossary prose that name enum values are easily missed; comprehensive grep during fix burst caught a 3rd sibling (ubiquitous-language) the adversary didn't flag; codification candidate tracked as FU-027 | Error-code authoring / consistency sweep workflow | proposed (FU-027) |
| LESSON-F68 | VP harness skeletons can carry false-green defects (assert-on-wrong-variable; epsilon applied in relaxing direction for strict inequality); finding one defect class in a VP triggers an audit of ALL VP harnesses for the same class (LESSON-F66 applied to VP layer); Pass 67 found 2 defective (VP-001/006) out of 10, audited all 10, drained the class; v1.0 VP harnesses (predating F37/F40 harness sweep) are highest-risk | VP authoring / adversarial review workflow | proposed |
