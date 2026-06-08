---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: brownfield
extracted_from: ".reference/vsdd-factory/skills/convergence-check"
subsystem: SS-06
capability: CAP-007
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.12.001: Convergence Loop Engine and Release-Gating Rule

## Description

Defines the release-gating rule and the convergence loop engine behavior
(reused from vsdd-factory per extraction-boundary-validated.md §3.2). The
convergence loop engine evaluates all 11 dimensions, applies novelty-decay to
repeated findings, and requires 3 consecutive clean evaluations before declaring
convergence. Release is blocked until all required dimensions are GREEN or
explicitly DEGRADED to a declared fallback. No dimension may be BLOCKED at release.
The 3-clean-streak and novelty-decay mechanisms are the same as vsdd-factory's
convergence; only the dimension set is replaced.

## Preconditions

1. All 11 dimension BCs (BC-7.01.001 through BC-7.11.001) have been evaluated
   and their results are available in the `convergence-report`.
2. The adversarial review pipeline is operational (each convergence iteration
   runs a fresh-context adversarial pass).
3. The novelty-decay classifier can mark adversarial findings as novel or non-novel
   based on prior finding history in the current cycle.
4. A `convergence-streak-state.json` file tracks the number of consecutive clean
   evaluations in the current cycle.
5. The release decision is a machine-checked gate, not a human judgment (unless
   a human-gated dimension is pending, which produces a DEGRADED-PENDING state
   not a machine override).

## Postconditions

1. **CONVERGENCE ACHIEVED:** All 11 applicable dimensions are GREEN or
   DEGRADED (with explicit declared fallback). Three consecutive clean evaluations
   have been completed (no new findings in adversarial review; no dim transitions
   from GREEN/DEGRADED to BLOCKED). `convergence-streak-state.json` records
   streak=3. Release is unblocked.
2. **CONVERGENCE ITERATION:** One or more dimensions are BLOCKED or the adversarial
   review found novel findings. The loop iterates: defects are addressed, dimensions
   re-evaluated, adversarial review re-run. Streak counter resets on any novel finding.
3. **DEGRADATION ACCEPTED:** A dimension is in DEGRADED state with an explicit
   declared fallback entry in the convergence-report. DEGRADED dimensions count as
   satisfied for the purpose of release gating. The fallback must be substantive
   (not just "acknowledged").
4. **RELEASE BLOCKED:** Any dimension is BLOCKED with no declared degradation.
   The release-gate hook fires and prevents the release pipeline from proceeding.
5. **NOVELTY DECAY:** A repeated adversarial finding (identical finding text to a
   prior pass, same artifact, same location) is marked non-novel. Non-novel findings
   do NOT reset the streak counter. This prevents convergence stall on known
   acknowledged issues.

## Invariants

1. The release-gate is a hard check: no BLOCKED dimension may exist at release time.
   No human can override a BLOCKED machine gate without a declared degradation.
2. Three clean streaks are required. Two clean iterations is NOT convergence.
3. Novelty-decay requires the prior finding to be EXACTLY the same (same artifact,
   same description). A finding with any substantive difference is treated as novel.
4. The adversarial review runs with information asymmetry: the adversary reads specs
   without prior context from the current cycle. This is the same protocol as
   vsdd-factory (reused from extraction-boundary-validated.md §3.2).
5. The convergence loop is stateful: `convergence-streak-state.json` is the
   authoritative source of streak count. Restarting the state file resets convergence.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Streak=2, adversarial review finds a novel finding | Streak resets to 0; finding logged; iteration continues |
| EC-002 | Streak=2, adversarial review finds the same finding as pass 1 (non-novel) | Non-novel finding; streak does NOT reset; streak stays at 2; next clean pass achieves convergence |
| EC-003 | A dimension transitions from GREEN to BLOCKED between iteration 2 and 3 | Streak resets to 0; the regression is the priority defect |
| EC-004 | Playtest-satisfaction dimension is DEGRADED-PENDING (human gate outstanding) | Release is blocked until human sign-off; but playtest-pending is DEGRADED not BLOCKED; the factory can complete other convergence work |
| EC-005 | All dims GREEN; adversarial review finds a MEDIUM finding, not in any dim | Medium finding does NOT block convergence unless it affects a specific dim. Logged in convergence-report; must be resolved or accepted |
| EC-006 | `convergence-streak-state.json` file is missing | Streak treated as 0; fresh start; iteration must reach 3 again; not an error |
| EC-007 | Human overrides a BLOCKED dimension without declaring a fallback | DI-006 / governance violation; human override without fallback declaration = factory defect; blocked |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| All 11 dims GREEN; 3 clean adversarial passes; no novel findings | CONVERGENCE ACHIEVED; release unblocked | happy-path |
| All dims GREEN; pass 2 finds novel finding; pass 3 clean | Streak reset to 0 after pass 2; streak at 1 after pass 3; NOT convergence yet | edge-case |
| 10 dims GREEN; dim 7 BLOCKED (perf); no declared fallback | RELEASE BLOCKED; dim 7 must be resolved or degradation declared | error |
| Dim 5 (playtest) DEGRADED-PENDING; all others GREEN; streak=3 | CONVERGENCE DEGRADED (playtest pending); release blocked until human sign-off | edge-case (human-gate) |
| Same finding in passes 1 and 2 (non-novel) | Non-novel; streak continues; pass 2 counts as clean for streak | edge-case (novelty-decay) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-031 | Release gate is BLOCKED if any required dimension is BLOCKED | kani (gate function: any(blocked_dims) → RELEASE_BLOCKED) |
| VP-TBD-032 | Streak counter never exceeds 3 before convergence is declared | kani (state machine: streak >= 3 AND no blocked dims → convergence, not streak=4) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the convergence loop engine and release-gating rule which is the core mechanism CAP-007 declares it provides |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced), DI-012 |
| Architecture Module | convergence-tracker / convergence-loop-engine (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.01.001 through BC-7.11.001 — depends on (all 11 dimension results feed into this loop)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md` — convergence loop engine implementation

## Story Anchor

S-TBD — Convergence Loop Engine and Release-Gating Rule

## VP Anchors

- VP-TBD-031 — release gate blocks on any BLOCKED dimension
- VP-TBD-032 — streak counter semantics

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `.reference/vsdd-factory/skills/convergence-check` |
| **Confidence** | high (extraction-boundary-validated.md §3.2 explicitly documents ADAPT split: loop engine REUSED, dimension set REPLACED) |
| **Extraction Date** | 2026-06-07 |

#### Evidence Types Used

- **documentation**: extraction-boundary-validated.md §3.2 documents that the "convergence-loop engine, novelty-decay assessment, and 3-CLEAN streak protocol are neutral and REUSED"
- **documentation**: AAA-RECONCILIATION.md §4 documents the mapping: "7-Dimension Convergence → Reshaped convergence model (see §7)"

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads convergence-report; reads adversarial review outputs; writes convergence-streak-state.json |
| **Global state access** | reads/writes convergence-streak-state.json |
| **Deterministic** | yes — given same dimension results and same prior-finding history, produces same convergence decision |
| **Thread safety** | not applicable (sequential evaluation; one convergence check at a time) |
| **Overall classification** | effectful shell (reads/writes state files; core decision logic is pure) |

#### Refactoring Notes

The convergence decision logic (given dim-results[] and streak-state → decision:
CONVERGED|ITERATE|BLOCKED) is a pure function extractable for Kani verification.
The I/O (reading dim results from report, writing streak state) is the effectful
shell. Extracting the pure core enables formal verification of the release-gate
invariant (VP-TBD-031).
