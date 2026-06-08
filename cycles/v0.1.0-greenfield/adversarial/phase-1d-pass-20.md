---
pass: 20
cycle: v0.1.0-greenfield
phase: 1d-adversarial
date: 2026-06-08
verdict: FINDINGS
critical: 0
important: 2
observations: 3
novelty: MEDIUM-HIGH
clean_pass_candidate: 1
clean_pass_counter_after: 0/3
note: orphaned-error-family class (E-KB/E-PLAY/E-REPLAY/E-NAR partial) fully reconciled; proactive sweep closed E-PLAY and E-REPLAY beyond adversary scope; check (r) reverse-coverage gate added; 213→255 error codes
---

# Phase-1d Adversarial Pass 20 — FINDINGS (0C / 2I / 3 obs)

**Verdict:** FINDINGS — Counter stays 0/3 (candidate clean #1 NOT awarded)
**Novelty:** MEDIUM-HIGH
**Note:** This pass exposed the last structural defect class in the error-taxonomy surface:
orphaned error families — families registered in the taxonomy but never cited by any BC.
Two adversary findings (E-KB family, E-NAR codes) plus orchestrator proactive closure of
E-PLAY and E-REPLAY (same class). All four families reconciled. Check (r) gates the whole
class permanently. 213→255 error codes (246 active across 30 active families + 9 retired
E-GEN; 31 total families).

---

## Findings

### F-20-01 — IMPORTANT (RESOLVED)

**Location:** `.factory/specs/prd-supplements/error-taxonomy.md` E-KB family;
`.factory/specs/behavioral-contracts/ss-12/` (CAP-012 Canon Knowledge-Base BCs)

**Finding:** The E-KB error family (CAP-012 Canon Knowledge-Base) was orphaned. All 9
ss-12 BCs emitted unregistered symbolic tokens (`GROUNDING_BYPASSED`, `CONTEXT_OVERFLOW`,
`CITATION_INVALID`, `TEMPORAL_VIOLATION`, `SCOPE_EXCEEDED`, etc.) rather than citing
registered E-KB-NNN codes. This is the same defect class as the E-ETH and E-OSVC
orphan-family remediation in prior passes. Zero BCs cited any E-KB code; the family was
registered but entirely disconnected from its owning subsystem's contracts.

**Root cause:** When CAP-012 BCs were authored, the E-KB family had only a skeletal
registry entry (E-KB-001..E-KB-004) covering basic grounding faults. The BCs were
authored against a richer set of fault conditions (grounding timeouts, chronological
reference violations, canon-scope exceeded, etc.) that had no corresponding registered
codes — so the authors fell back to symbolic token strings that were never registered.

**Resolution:**

1. **E-KB family expanded:** E-KB registry extended from 4 codes to cover all fault
   conditions actually emitted by ss-12 BCs. New codes registered:
   - `E-KB-005` — grounding timeout (CAP-012 KB query exceeded latency budget)
   - `E-KB-006` — chronological reference violation (event timestamp violates canon timeline)
   - `E-KB-007` — canon-scope exceeded (query references entity outside defined canon boundary)
   - `E-KB-008` — context-window overflow (KB context budget exhausted; partial grounding)
   - `E-KB-009` — citation invalid (cited canon source does not resolve in KB index)
   - `E-KB-010` — grounding bypassed (KB lookup skipped due to circuit-breaker tripped)
   - `E-KB-011` — temporal anchor missing (KB response lacks required temporal provenance)
   - `E-KB-012` — canon conflict (two canon sources assert contradictory facts for same entity)
   Additional codes for edge faults in BC-12.08.001, BC-12.09.001, BC-12.12.001..004:
   - `E-KB-013` through `E-KB-022` (10 codes covering: entanglement-graph cycle, invariant
     2/3 violation, concurrent-write conflict, snapshot-integrity hash mismatch, lore-graph
     orphan, retrieval-context poisoning, KB-rebuild timeout, schema-version mismatch,
     index-corruption detected, quota-exceeded on canon write)

2. **Symbolic→E-KB crosswalk added** to error-taxonomy.md: documents the mapping from
   prior symbolic names to the new registered codes (for traceability).

3. **ss-12 BCs updated:** All 9 BCs in `ss-12/` now cite registered E-KB-NNN codes.
   Symbolic token strings replaced with `E-KB-NNN (SymbolicName)` canonical form per
   error-taxonomy conventions. `error.data.reason` field carries the human-readable
   symbolic name as context; the machine-checkable identifier is the E-KB code.

**error-taxonomy.md:** bumped to **v2.0** (E-KB 4→22 codes, symbolic→E-KB crosswalk).
**Affected ss-12 BCs:** all 9 files bumped to v1.1 (first citation of registered E-KB codes).

---

### F-20-02 — IMPORTANT (RESOLVED)

**Location:** `.factory/specs/behavioral-contracts/ss-05/BC-5.04.001.md` and
`.factory/specs/behavioral-contracts/ss-05/BC-5.04.002.md`

**Finding:** Two BCs in ss-05 (CAP-005 Named Entity / Narrative System) cited
`E-NAR-003` ("narrative-variant generation failed") for two distinct fault conditions:
(a) an undeclared variable reference in a narrative template and (b) an invalid
naming-registry regex pattern. Both are legitimate error conditions that require a
separate registered code — `E-NAR-003` is semantically scoped to generation failures,
not validation faults. The overloading of one code for three distinct fault classes is
the same defect class as the E-COMP-010 overloading found in Pass-9 (I-2).

**Root cause:** At authoring time, the E-NAR family had only 4 codes (E-NAR-001..004)
and the author reached for the closest semantic fit rather than registering new codes.

**Resolution:**

1. `E-NAR-005` registered: "undeclared variable reference in narrative template" — cited
   by BC-5.04.001 for the template-variable fault condition.
2. `E-NAR-006` registered: "invalid naming-registry regex pattern" — cited by BC-5.04.002
   for the regex-validation fault condition.
3. BC-5.04.001 updated to cite `E-NAR-005` (was `E-NAR-003`); bumped to **v1.2**.
4. BC-5.04.002 updated to cite `E-NAR-006` (was `E-NAR-003`); bumped to **v1.2**.

**Corpus grep:** Searched all BCs for `E-NAR-003` to confirm no other overloaded
citations. Found 2 instances (the two BCs now remediated). No other citations remain.

---

### ORCHESTRATOR PROACTIVE SWEEP — E-PLAY and E-REPLAY (RESOLVED)

**Scope:** Break the one-orphan-family-per-pass tail by sweeping the full active-family
registry for any additional families matching the same orphaned-family defect class
before dispatching Pass 21.

**Families found orphaned (beyond adversary scope):**

**E-PLAY (CAP-008 Playtest / Session Analytics):** All ss-08 BCs emitted unregistered
symbolic tokens (`SESSION_INVALID`, `METRICS_TIMEOUT`, `CAPTURE_FAILED`, `PLAYTEST_QUOTA_EXCEEDED`,
etc.) rather than registered E-PLAY-NNN codes. Exact same defect class as F-20-01 (E-KB).

**Resolution (E-PLAY):**
- E-PLAY family codes audited and extended to cover all fault conditions in ss-08 BCs.
- Additional codes registered: E-PLAY-005 through E-PLAY-014 (10 new codes covering:
  session-quota exceeded, metrics-capture timeout, playtest-session invalid, replay-token
  expired, capture-buffer overflow, session-analytics schema error, playtest-delegate
  unreachable, metrics-aggregation conflict, session-evidence hash mismatch, playtest-
  budget exhausted).
- All ss-08 BCs updated to cite registered E-PLAY-NNN codes. Symbolic tokens replaced
  with canonical `E-PLAY-NNN (SymbolicName)` form.
- Affected ss-08 BCs: all files with prior symbolic tokens bumped to v1.1.

**E-REPLAY (CAP-003 Replay / Deterministic Verification):** All ss-03 BCs emitted
unregistered symbolic tokens (`REPLAY_DESYNC`, `SEED_MISMATCH`, `FRAME_HASH_MISMATCH`,
`TICK_OVERFLOW`, etc.) rather than registered E-REPLAY-NNN codes. Same defect class.

**Resolution (E-REPLAY):**
- E-REPLAY family codes audited and extended.
- Additional codes registered: E-REPLAY-005 through E-REPLAY-016 (12 new codes covering:
  replay-desync detected, seed mismatch, per-frame hash mismatch, tick-counter overflow,
  determinism-tier violation, replay-manifest corrupt, checkpoint-restore failed, replay-
  buffer underflow, divergence-threshold exceeded, replay-seed not found, cross-platform
  hash divergence, replay-compression error).
- All ss-03 BCs updated to cite registered E-REPLAY-NNN codes.
- Affected ss-03 BCs: all files with prior symbolic tokens bumped to v1.1.

**Note on E-GEN:** E-GEN remains correctly retired (9 codes struck through). Its orphan
status is expected and excluded from check (r) via the strikethrough-detection mechanism.
The 30 active families are all confirmed cited after this sweep.

---

### Process-Gap RESOLVED — check (r) reverse-coverage gate (whole class gated)

**Finding:** The check suite had no gate for orphaned error families. A family could be
registered in error-taxonomy.md but cited by zero BCs indefinitely without triggering a
CI failure. This allowed E-KB, E-PLAY, and E-REPLAY to survive Passes 1–19 undetected.

**Resolution:** Check **(r)** added to CI gate (v1.20):

- **Step 1:** Scans error-taxonomy.md for `~~E-FAMILY~~` strikethrough markup to build
  the retired-family set (currently: E-GEN only).
- **Step 2:** Parses the Family Registry table to extract all registered family names
  (matching `^E-[A-Z]+$`). Subtracts retired families to get active families.
- **Step 3:** For each active family, runs `grep -rl 'E-FAMILY-[0-9]' BC_DIR` and asserts
  the result is non-empty. Any family with zero BC citations is an **orphan** — FAIL.
- **Scope:** 30 active families; 1 retired (E-GEN, excluded). After remediation: all 30
  active families cited by ≥1 BC.
- **Positive-coverage log:** `Check (r): N non-retired error families, all cited by >=1 BC`
- **POSIX/BSD-grep compatible.** No grep -P.

CI gate bumped to **v1.20** (checks a–r, ~26 sub-assertions).
scripts/check-spec-counts.sh ALL CHECKS PASSED, exit 0.

---

### OBS-20-A — LOW (obs, RESOLVED)

**Location:** `.factory/specs/behavioral-contracts/ss-12/BC-12.12.004.md`
Invariant 2

**Finding:** Invariant 2 in BC-12.12.004 stated "ordinals unique" without qualification.
The BC's test vectors included a case where two concurrent writes with `concurrent: true`
are permitted to share ordinals — but Invariant 2 as written would flag that as a
violation.

**Resolution:** Invariant 2 reworded to: "ordinals unique unless both entries carry
`concurrent: true`". BC-12.12.004 bumped to **v1.1**.

---

### OBS-20-B — LOW (obs, RESOLVED)

**Location:** `.factory/specs/behavioral-contracts/ss-12/BC-12.01.001.md` and
`.factory/specs/architecture/ARCH-INDEX.md` CAP-012 / CAP-005 row

**Finding:** No explicit note in the CAP-012 BCs or ARCH-INDEX that the Canon Knowledge-
Base (CAP-012) is the authoritative timeline source, while CAP-005 Named Entity / Narrative
System produces a consumer view derived from it. A fresh-context reader sees two systems
with temporal data and may not know which is authoritative.

**Resolution:** Added a one-line note to BC-12.01.001 §Related-BCs:
`CAP-012 Canon-KB is the authoritative timeline source; CAP-005 Named Entity provides a consumer-facing derived view.`
BC-12.01.001 bumped to **v1.1**.

---

### OBS-20-C — LOW (obs, non-blocking)

**Location:** `.factory/specs/behavioral-contracts/ss-12/` (multiple BCs referencing
architecture anchors)

**Finding:** Several ss-12 BCs reference CAP-012 sub-components (KB index, lore-graph,
entanglement-graph) that are expected to be detailed in Phase-1a architecture artifacts.
These are architectural placeholder anchors consistent with how Phase-1 specs are
structured. The architecture artifacts will be produced in a dedicated pass.

**Adjudication:** Expected for Phase-1 spec layer. Phase-1a architecture will establish
the canonical sub-component definitions. No file changes required this pass.

---

## Count Impact

| Metric | Before | After |
|--------|--------|-------|
| Error codes (total defined) | 213 | 255 |
| Error codes (active / non-retired) | 204 | 246 |
| Error codes (retired E-GEN) | 9 | 9 |
| Total families | 31 | 31 |
| Active families | 30 | 30 |
| Retired families | 1 (E-GEN) | 1 (E-GEN) |
| BCs | 190 | 190 |
| NFRs | 41 | 41 |
| Priority P0/P1/P2 | 126/42/22 | 126/42/22 |
| Capabilities | 15 | 15 |
| Subsystems | 13 | 13 |

**New error codes registered this pass:** 42 codes across 4 families:
- E-KB: +18 codes (E-KB-005..E-KB-022)
- E-NAR: +2 codes (E-NAR-005..E-NAR-006)
- E-PLAY: +10 codes (E-PLAY-005..E-PLAY-014)
- E-REPLAY: +12 codes (E-REPLAY-005..E-REPLAY-016)

---

## Verification Footer

**CI gate:** scripts/check-spec-counts.sh **v1.20**
**Checks:** a–r (~26 sub-assertions)
**Result:** ALL CHECKS PASSED — exit 0
**Totals confirmed:**
- BCs: 190
- Error codes: 255 (246 active; E-GEN 9 codes retired)
- NFRs: 41
- Priority: P0=126 / P1=42 / P2=22
- Capabilities: 15
- Subsystems: 13

**Spec versions changed this pass:**
- error-taxonomy.md: v1.9 → **v2.0** (E-KB +18, E-NAR +2, E-PLAY +10, E-REPLAY +12;
  symbolic→E-KB crosswalk; 213→255 total defined codes, 246 active)
- BC-5.04.001.md: v1.1 → **v1.2** (E-NAR-003 overload → E-NAR-005 undeclared-variable)
- BC-5.04.002.md: v1.1 → **v1.2** (E-NAR-003 overload → E-NAR-006 invalid-regex)
- ss-12/ BCs (all 9): v1.0 → **v1.1** (symbolic tokens → registered E-KB-NNN codes;
  BC-12.12.004 additionally: Invariant 2 qualified for concurrent:true; BC-12.01.001
  additionally: authoritative-timeline note added)
- ss-08/ BCs (affected): bumped to **v1.1** (symbolic tokens → registered E-PLAY-NNN codes)
- ss-03/ BCs (affected): bumped to **v1.1** (symbolic tokens → registered E-REPLAY-NNN codes)
- BC-8.08.004.md: v1.3 → **v1.4** (no change this pass; confirmed clean during sweep)
- scripts/check-spec-counts.sh: v1.19 → **v1.20** (check r: error-family reverse coverage;
  30 active families validated, 0 orphans; 1 retired E-GEN excluded)
- prd.md: version bumped to reflect error code count 213→255 in §5 error taxonomy summary
- BC-INDEX.md: version bumped (no row changes; header confirmed correct post-sweep)

**Counter:** 0/3 clean passes. Next = Pass 21 (candidate clean #1 re-attempted with
orphaned-family class fully gated).
