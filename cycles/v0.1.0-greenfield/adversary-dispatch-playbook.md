---
document_type: adversary-dispatch-playbook
cycle: v0.1.0-greenfield
phase: phase-1d-adversarial
updated: 2026-06-13
---

# Adversary Dispatch Playbook — Phase-1d Convergence

## Purpose

Reusable dispatch template for each Phase-1d adversarial convergence pass (subagent_type: vsdd-factory:adversary). Read this + STATE.md ACTIVE SUB-LOOP to dispatch the next Pass-N. Goal: 3 CONSECUTIVE CLEAN passes (0 critical, 0 important; observations allowed).

---

## Dispatch Template (standing adversary prompt skeleton)

**Role:** FRESH-CONTEXT adversarial review of the game-factory Phase-1 spec package, Pass N. Has NOT seen prior passes. "Previously converged" does NOT mean "correct"; but an honest CLEAN verdict on a converged package is the RIGHT answer — do NOT manufacture findings.

### Spec Package Paths (under `.factory/specs/`)

- `prd.md` + `prd-supplements/`
- `domain-spec/` (L2-INDEX, 18 entities, 15 caps, 13 DI)
- `behavioral-contracts/` (193 BCs, BC-INDEX)
- `architecture/` (ARCH-INDEX, 13 subsystems, methodology-layer, studio-of-agents, ADRs incl ADR-0006/0008, adapter-protocols, nfr-catalog=41 NFRs, error-taxonomy=267 codes/34 families, subsystem-decomposition)
- `verification-properties/` (VP-INDEX, 10 VPs)

### Canonical Thesis (D-017)

Five ADAPTER seams: engine / asset / distribution / XR / online-services + Canon-KB (SS-10) sixth load-bearing (non-adapter) seam.

---

### DO NOT Re-Derive (machine-gated, gate v1.41)

These classes are fully covered by `scripts/check-spec-counts.sh` — do NOT spend adversary attention re-checking them:

- counts
- title-sync
- enums
- ordinals
- frontmatter path-existence
- no-variant
- D-SEC-contract-existence
- active-BC-stale-status
- genre-profile-trigger-validity (corpus-wide)
- L2-INDEX registry counts
- DI-007-context (general)
- D-SEC-evaluator-completeness
- economy-conservation-BC-routing
- visionOS/OpenXR-dedicated-code
- D-SEC-no-DEGRADED-path

**Update this list when new gate checks are added.**

---

### Accepted Conventions (ratified by prior passes — NOT defects, do NOT flag)

1. BC "Architecture Anchors" referencing `architecture/SS-NN-*.md` are intentional Phase-3 forward-references, not broken paths.
2. `ss-NN/` directory vs `SS-NN` subsystem-ID skew is governed by an authoritative alias table in `subsystem-decomposition.md` / ARCH-INDEX.

---

### Already-Swept Classes (assume sound unless concrete NEW file+line evidence)

The following classes were comprehensively audited in prior passes. Do NOT re-audit the whole class on a general basis — only flag if you have specific new file+line evidence:

- error-code-semantic-fit
- generic-vs-dedicated error-code routing (comprehensively audited all ~30 families)
- producer/consumer field-shape
- VP correctness
- NFR traceability/measurability
- lifecycle/idempotency/concurrency
- security/threat-model
- status-propagation
- DI-007 anchoring
- D-SEC evaluator completeness
- economy BC-routing
- index-registry counts

---

### Focus (high-value classes recent passes found)

Direct adversary attention toward:

- Wrong-but-existing BC-ID routing references (a BC that exists but is semantically wrong for the signal being routed)
- Consumer-assumes-nonexistent-producer-capability (a BC assumes the upstream produces a field/signal it does not declare)
- Evaluator/aggregator BC omitting a declared signal (a dimension evaluator fails to consume a signal explicitly declared by a source BC)
- Invariant cited in wrong semantic context (a pre/postcondition borrows from a sibling domain where it does not apply)
- Pre/postcondition non-entailment (postcondition does not logically follow from precondition under the stated inputs)
- Incomplete propagation of a prior fix across methodology summary tables + sibling/evaluator BCs

**Coverage rotation:** weight toward least-recently-examined subsystems. Track which subsystems were hit in the most recent 3 passes and rotate away from them.

---

### Mandatory FU-005 Targets (verify, flag only real regressions)

Each pass MUST verify these are still sound:

- D-010 (11-dim)
- D-011
- D-012 / D-018
- D-013
- D-017 (seams)
- D-019 (security)
- BC-1.15.002 / BC-1.15.003
- BC-13.01.004

---

### Output Format

For each finding:

```
ID: FNN-NN
Severity: CRITICAL | IMPORTANT | OBSERVATION
File(s) + lines: <path>:<line>
Description: <logical argument — not just "this looks wrong"; show the entailment chain>
Recommended route: product-owner | architect
[process-gap] — add this tag if the finding reveals a repeatable class of error not yet gated
```

End the report with one of:

```
VERDICT: CLEAN
```

or

```
VERDICT: FINDINGS (Nc/Ni/Mobs)
```

where Nc = critical count, Ni = important count, Mobs = observation count.

---

## Per-Pass Orchestration Recipe

What the orchestrator does each pass:

1. **Dispatch adversary** using the template above for the next Pass N (from STATE.md ACTIVE SUB-LOOP).

2. **Route verdict:**
   - If CLEAN: state-manager records CLEAN, counter +1; if 3/3 → CONVERGED (proceed to T10/T11/T12). Defer any observations to FUs (do NOT fix mid-streak).
   - If FINDINGS (>=1 critical/important): route fixes to product-owner (BC/PRD/error-taxonomy/invariants) and/or architect (architecture/methodology/ADR/CI-gate). Tell each they must NOT commit themselves. For a recurring class, instruct a COMPREHENSIVE audit (not just the flagged instance) + add a CI gate guard (architect). Counter resets to 0.

3. **Gate run (orchestrator-owned):** Run `bash scripts/check-spec-counts.sh` YOURSELF and confirm EXIT=0. Never credit a subagent's gate claim without running it yourself — LESSON-F49b.

4. **Commit (state-manager LAST):** commit gate-script changes on `main`; commit `.factory/` changes on `factory-artifacts`; push both. Update STATE.md: convergence table row, counter, next pass, version bumps, new FUs/lessons.

---

## Lessons That Shape Dispatch/Fix

See `.factory/cycles/v0.1.0-greenfield/lessons.md` — especially:

- **LESSON-F46:** vocabulary/trigger fixes must grep the WHOLE corpus, not just the owner BC.
- **LESSON-F49:** index/summary surfaces must be gated vs source; never let a count drift between index and corpus.
- **LESSON-F49b:** never credit a gate pass without the orchestrator's own green run.
- **LESSON-F52:** recurrence-guards must require the RIGHT context (not enumerate wrong ones).
- **LESSON-F53:** dimension-semantics fixes must sweep ALL methodology summary tables + sub-invariant BCs (not just the owner BC).
- **LESSON-F56:** a hardening fix in one BC (e.g., SP4 unconditional) MUST propagate to all methodology summary rows that enumerate allowed values for that dimension — this is now gated by check (jj).
