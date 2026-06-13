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
