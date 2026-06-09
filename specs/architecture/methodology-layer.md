---
document_type: architecture-section
level: L3
section: methodology-layer
version: "1.12"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1d
traces_to: ARCH-INDEX.md
traces_to_caps:
  - CAP-004
  - CAP-006
  - CAP-007
  - CAP-008
  - CAP-011
  - CAP-012
traces_to_adrs:
  - ADR-0006
inputs:
  - .factory/specs/architecture/ARCH-INDEX.md
  - .factory/specs/architecture/layered-architecture.md
  - .factory/specs/architecture/subsystem-decomposition.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/prd-supplements/prd-cap-006-007.md
  - .factory/specs/prd-supplements/prd-cap-011.md
  - .factory/specs/prd-supplements/prd-cap-008-012.md
  - .factory/specs/domain-spec/entities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/behavioral-contracts/BC-INDEX.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Game Methodology Layer (Layer 2)

> **v1.12 changes (Pass-40 F40-01 fix — T2 comparison method corrected to snapshot-structured-diff; F40-03 fix — playtest_delegation schema updated to structured form with delegated_claims[]):**
> - **F40-01 fixed:** `comparison_method` enum extended from 2 values to 3: `snapshot-hash-diff | snapshot-structured-diff | tolerance-window`. T1 = snapshot-hash-diff (same-platform bitwise); T2 = snapshot-structured-diff (pinned-runner, field-by-field — bitwise hash equality not guaranteed cross-platform); T3 = tolerance-window (unchanged). D-REPLAY pass predicate at §D-REPLAY corrected to state T2 = snapshot-structured-diff. BC-1.12.002 PC2 must be updated by PO to emit `comparison.method: "snapshot-structured-diff"` for T2.
> - **F40-03 fixed:** §2.2 design-intent-contract schema updated: scalar `playtest_delegation_note` field replaced by structured `playtest_delegation` section with required `delegated_claims[]` (matching BC-6.02.005 shape). The DI-012 / D-DOCS pass predicate at §D-DOCS updated to gate on the structured form being non-empty. This REFINES D-012's field name (playtest_delegation_note scalar → playtest_delegation structured section) while preserving D-012's intent.

> **v1.11 changes (Pass-31 I31-01 fix — Canon-KB seam ordinal fifth→sixth in §2.7 Purpose):**
> - **I31-01 fixed:** §2.7 canon-kb schema "Purpose" sentence corrected "fifth load-bearing seam"
>   → "sixth load-bearing seam". The product-brief §Overflow Context (line 111) and ADR-0004
>   both state "sixth"; the erroneous "fifth" was a residual from the Pass-14 O14-02 incomplete
>   propagation. The brief-citation ("product-brief §Overflow Context") is now accurate because
>   the brief actually says "sixth load-bearing seam" at that location.
> - **CI guard (o) extended (v1.25):** check (o) extended to gate the Canon-KB load-bearing-seam
>   ordinal. Any operative line referencing Canon-KB's load-bearing-seam ordinal must say "sixth".
>   FAIL on "fifth load-bearing seam" (or any ordinal other than "sixth" applied to
>   "load-bearing seam") in architecture spec files. Also asserts any `'<ordinal> load-bearing
>   seam'` quotation attributed to the product brief matches the brief's actual text ("sixth").

> **v1.10 changes (Pass-27 I27-01 fix — BC-8.08.004 mislabel in "Resolved in Pass-12" note; broadened CI guard (t)):**
> - **I27-01 fixed (dimension-owner mislabel, third instance of the class):** The "Resolved in
>   Pass-12" inline note (formerly line ~714) incorrectly called BC-8.08.004 the
>   "D-PLAY dimension owner" and referenced "SS-07/SS-08 interface". BC-8.08.004 is the
>   Human Playtest Sign-Off Gate — a D-PLAY status PRODUCER in SS-07 that feeds the D-PLAY
>   dimension owner BC-7.05.001 (SS-06). The note now correctly describes BC-8.08.004 as the
>   "D-PLAY status producer / SS-07 sign-off gate feeding the SS-06 dimension owner
>   BC-7.05.001". The spurious "SS-08" reference (a directory-name conflation) is also removed.
> - **CI guard (t) broadened (v1.23):** The prior v1.22 check matched only two narrow compound
>   patterns ("dimension-owner (SS-0X" and "owner BCs (SS-0X") and missed line-714-style phrasing
>   where "dimension owner" (space, no parenthetical) was used. The rewritten check (t) now covers
>   the full mis-attribution class: any operative line containing "dimension owner" or
>   "dimension-owner" (hyphen OR space variant) that also names a BC ID not of the form
>   BC-7.0[1-9].001 or BC-7.1[01].001 (the 11 dimension owners) FAILS; any such line that names
>   a subsystem other than SS-06 in an owner-attribution context also FAILS. Blockquote (">")
>   lines excluded. Calibrated against line 637 (correct SS-06 + BC-7.* owner — not flagged),
>   the producer table (lines 701-709 — uses "writes"/"maps", not "owner" — not flagged), and
>   per-dimension "Subsystem:" headers (no "dimension owner" phrase — not flagged). Script
>   version bumped to v1.23.

> **v1.9 changes (Pass-24 I24-01 fix — SS-06 owner-attribution for BC-7.* dimension-evaluator family):**
> - **I24-01 fixed (subsystem-label mis-anchor):** Several §3.1 operative passages and v1.4/v1.5
>   changelog notes incorrectly attributed OWNERSHIP of the BC-7.* dimension-evaluator family to
>   "SS-07". The correct owner is SS-06 (Convergence Tracking Engine), per ARCH-INDEX Subsystem
>   Registry (SS-06=CAP-007=BC-7.*), subsystem-decomposition (BC-7.* → SS-06), ADR-0006 §SS-06,
>   and every BC-7.* frontmatter declaring `subsystem: SS-06`. Root cause: BC-7.11.002..008
>   physically reside in the ss-07/ directory while their subsystem is SS-06 (documented
>   dir-vs-subsystem alias); the erroneous passages read the directory name as the owner.
>   CRITICAL DISTINCTION preserved: the per-dimension `Subsystem:` headers in §3 (e.g., D-PLAY
>   → SS-07, D-ETHICS → SS-09, D-SIM → SS-05) denote the EVALUATED/PRODUCING subsystem — a
>   legitimately different semantic from the OWNER of the evaluation BC. Those headers are
>   unchanged. Only the BC-7.* family OWNERSHIP attribution is corrected (lines ~105, ~130,
>   ~611, ~616). Also corrected: the BC-7.12.001 erroneous inclusion in the dimension-owner
>   range; BC-7.12.001 is the Convergence Loop Engine / release-gating rule, not a
>   dimension-owner. Range corrected to BC-7.01.001 through BC-7.11.001 (11 owners).
> - **CI guard added (t):** `scripts/check-spec-counts.sh` bumped to v1.22. Check (t) added:
>   BC-7.* owner-attribution guard — scans methodology-layer.md (and other architecture docs)
>   for any operative line containing the literal patterns `dimension-owner (SS-0` or
>   `owner BCs (SS-0` where the subsystem code is anything other than SS-06. Fails on
>   e.g. "SS-07 dimension-owner" or "owner BCs (SS-07)". The check is deliberately narrow
>   (matching only these two exact multi-word compound patterns) to avoid false positives on
>   the legitimate per-dimension `Subsystem: SS-07` producing-subsystem headers, which do not
>   contain "dimension-owner" or "owner BCs (SS-" phrasing. Changelog lines (starting `>`)
>   and blockquote lines are excluded. Positive-coverage log always printed.
>   Closes I24-01 recurrence risk. POSIX/BSD compatible.

> **v1.8 changes (Pass-23 I23-01 fix — §3.1 table (A) DEGRADED row missing D-PLAY):**
> - **I23-01 fixed (intra-§3.1 cross-table contradiction):** Table (A) "Canonical Status-Value Enum"
>   DEGRADED row "Applicable Dimensions" cell omitted D-PLAY. Table (B) "Per-Dimension Allowed
>   Value Subsets" correctly lists D-PLAY = {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}. The
>   D-PLAY prose predicate (§3.D-PLAY DEGRADED predicate), BC-7.05.001 EC-002, and ADR-0006 §D-PLAY
>   column all confirm D-PLAY=DEGRADED is canonical (human override with documented rationale). Added
>   D-PLAY to table (A) DEGRADED row "Applicable Dimensions" cell. Full cross-check of all 4 status
>   values × 11 dimensions confirms this is the only discrepancy between tables (A) and (B).
>   No change to the actual per-dimension status model.
> - **CI guard added (s):** `scripts/check-spec-counts.sh` bumped to v1.21. Check (s) added:
>   §3.1 cross-table consistency — parses both §3.1 tables and asserts, for each of the 4 status
>   values, that {dimensions listing the value in Per-Dimension Subset table (B)} == {dimensions
>   in the value's "Applicable Dimensions" cell of Canonical Status-Value Enum table (A)}. FAIL
>   lists any mismatch. Closes the intra-§3.1 contradiction class (which checks (q) and (n.ii)
>   do not cover). POSIX/BSD-awk compatible. Green after this fix.

> **v1.7 changes (Pass-19 F1 fix — prose-restatement drift in Pass-12 changelog note):**
> - **F1 fixed (doc coherence):** The "Resolved in Pass-12" changelog note (line ~661) restated
>   D-PLAY's allowed-value set as "GREEN/DEGRADED-PENDING/BLOCKED", omitting DEGRADED. This
>   contradicted the canonical §3.1 Per-Dimension Allowed Value Subsets table (which correctly
>   lists D-PLAY = {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}), BC-8.08.004 postcondition #4
>   (sets D-PLAY=DEGRADED on CONDITIONAL/human-override), and BC-7.05.001 EC-002 (DEGRADED =
>   human override with documented rationale). The parenthetical now reads "(D-PLAY allows
>   GREEN/DEGRADED/DEGRADED-PENDING/BLOCKED)" matching the canonical §3.1 table. No change to
>   the model — this is a pure doc-coherence fix.
> - **Process-gap guard added (P19-01):** `scripts/check-spec-counts.sh` bumped to v1.19. Check
>   (q) added: flags any line outside the §3.1 canonical table that contains a per-dimension
>   allowed-value prose restatement of the pattern "D-<DIM> allows <TOKEN>/<TOKEN>/..." or
>   "(D-<DIM> allows ...)". These inline restatements are discouraged (see Convention below);
>   the check surfaces them so stale copies can be corrected. Green on the fixed corpus.
>   Convention: do not restate per-dimension allowed-value subsets in prose outside §3.1; if a
>   summary is needed, reference §3.1 by name rather than copying the token list inline.

> **v1.6 changes (Pass-12 F-12-02 fix — §3.1 PO Change List converted to past-tense; OBS-1):**
> - **OBS-1 fixed (doc currency):** The "PO Change List — Producer BCs Using Non-Canonical
>   AMBER" block (now "Resolved in Pass-10") was stale future-tense. The 9 entries in the
>   original list were all fixed by the Product Owner by Pass-10. The block has been
>   rewritten as a resolved historical record. BC-8.08.004 (D-PLAY; `playtest-satisfaction`
>   dimension values `green`/`red`/`amber`/`pending` in lowercase) was the one producer BC
>   MISSING from the original change list — it is the root cause of F-12-01 (false-green
>   in CI) and is being fixed by PO in Pass-12. A separate "Resolved in Pass-12" entry
>   documents it.
> - **F-12-02 fix (CI):** `scripts/check-spec-counts.sh` bumped to v1.12. Check (n.i) is now
>   case-insensitive at the detection/extraction layer: lowercase backtick-quoted tokens
>   (`green`, `red`, `amber`, `pending`, `degraded`, `blocked`) on dimension-context lines
>   are now extracted, folded to uppercase, and tested against the canonical enum. Tokens
>   that fold to a canonical value are flagged as "wrong-case form"; tokens that fold to a
>   known non-canonical status word (AMBER/RED/PENDING/YELLOW) are flagged as non-canonical
>   + wrong case. The canonical enum itself remains uppercase-only at the assertion layer.
>   A positive-coverage log line is also added to make a zero-scan run visible.

> **v1.5 changes (Pass-11 F-11-01/F-11-02 resolution — status-value model end-to-end reconciliation):**
> - **F-11-01 fixed (Direction A — widen DEGRADED-PENDING applicability):** §3.1 Per-Dimension
>   Allowed Value Subsets table for D-PLAY and D-PERF now include `DEGRADED-PENDING`. The
>   owner BCs (BC-7.05.001 postcon #2 + EC-007; BC-7.07.001 postcon #4 + #5 + EC-003) already
>   used DEGRADED-PENDING correctly — the §3.1 table was the inconsistency. DEGRADED-PENDING
>   means "factory automatable work is complete; a human or on-device act is outstanding." For
>   D-PLAY this is "playtest scheduled, not yet run"; for D-PERF this is "CPU gate GREEN, GPU/XR
>   hardware not yet available." Both are legitimate DEGRADED-PENDING cases. DI-007 is not
>   violated: DEGRADED-PENDING is not an automated fun-score substitution — it is an honest
>   statement that a real playtest has been scheduled but not yet completed. The canonical
>   DEGRADED-PENDING "Applicable Dimensions" table cell now includes D-PLAY and D-PERF. The
>   §3 D-PLAY prose ("No degradation") is updated to clarify that DEGRADED-PENDING (scheduled
>   but not yet run) is permitted; DEGRADED (automated substitute) is what is forbidden. The
>   ADR-0006 D-PLAY "Fallback on degradation" column is updated from "N/A — non-substitutable"
>   to "DEGRADED-PENDING: playtest scheduled, not yet completed." ADR-0006 D-PERF column
>   updated to name DEGRADED-PENDING explicitly for GPU/XR gate pending.
> - **F-11-02 fixed (non-canonical token elimination):** Three non-canonical tokens eliminated
>   from SS-06 owner BCs: BC-7.05.001 EC-001 `BLOCKED-PENDING` → `BLOCKED` (report not produced
>   is a hard precondition gap); BC-7.05.001 EC-002 `DEGRADED-ACCEPTED` → `DEGRADED` (human
>   override with documented rationale is the definition of DEGRADED); BC-7.08.001 EC-001
>   `DEGRADED-advisory` → `DEGRADED` (pre-deadline advisory is a partial-met DEGRADED state).
>   These three BCs are bumped to v1.1 / v1.2. The ONLY status tokens anywhere in
>   convergence-dimension context are now the 4 canonical values: GREEN, DEGRADED,
>   DEGRADED-PENDING, BLOCKED.
> - **check (n) extended:** scripts/check-spec-counts.sh v1.11 adds:
>   (n.ii) per-dimension subset enforcement — parses §3.1 per-dimension allowed subsets and
>   asserts each BC dimension-value assignment is legal for that specific dimension; catches
>   F-11-01-class regressions (enum-valid but dimension-illegal value).
>   (n.iii) bare table-cell token scan — widens token extraction to catch BLOCKED-PENDING /
>   DEGRADED-ACCEPTED / DEGRADED-advisory style tokens in markdown table cells without
>   backtick/verb anchors; catches F-11-02-class tokens. Changelog reason: lines remain
>   excluded. POSIX/BSD-grep compatible.

> **v1.4 changes (Pass-10 I-2/I-3 resolution — status-value enum + stale-note fix):**
> - **I-2 fixed:** The v1.3 "Known consumer drift (PO action required)" note (§3.0 table
>   below) that flagged BC-9.04.001/9.06.001/9.06.002 writing `distribution_readiness`
>   is now replaced with a resolved note. Pass-9 already renamed those three fields to
>   `cert_preflight`; the stale instruction has been removed.
> - **I-3 fixed (authority side):** Added §3.1 "Canonical Convergence-Dimension
>   Status-Value Enum" — the closed set of values that a
>   `convergence-report.dimensions.<field>` entry may hold, with per-value meanings and
>   per-dimension allowed subsets. Owner BCs (BC-7.06.001, BC-7.08.001, BC-7.10.001
>   and all other SS-06 dimension BCs) are the canonical authority; their vocabulary
>   (GREEN / DEGRADED / DEGRADED-PENDING / BLOCKED) is codified here. Producer BCs
>   in SS-09/10/11/13 that write `AMBER` for the intermediate state are non-canonical
>   and MUST be updated by PO (change list in §3.1). Added CI check (n) to
>   `scripts/check-spec-counts.sh` v1.9 to enforce this enum at usage-site.

> **v1.3 changes (Pass-9 O-2 resolution — canonical convergence-report dimension field names):**
> - **O-2 fixed:** Added §3.0 "Canonical Dimension Field Name Registry" — a central
>   authoritative table mapping each of the 11 convergence dimensions (D-SIM through
>   D-SEC) to its canonical `convergence-report.dimensions.<field>` JSON field name.
>   This table is the single source of truth for field naming; downstream BCs and
>   consumers must use these names. Deriving from existing pinned names (BC-7.01.001
>   `sim_spec`, BC-7.02.001 `tests_replay`, BC-7.06.001 `cert_preflight`,
>   BC-10.02.001 `provenance_legal_compliance`) and assigning canonical names for
>   the 7 dimensions that had no prior pin.
> - **O-2 drift flag (for PO):** SS-08 consumer BCs (BC-9.04.001, BC-9.06.001,
>   BC-9.06.002) write `dimensions.distribution_readiness` for D-CERT, which
>   contradicts the D-CERT canonical field `cert_preflight` defined in BC-7.06.001.
>   These three BCs are in PO's SS-08 scope. The canonical name is `cert_preflight`;
>   PO should update the three SS-08 consumer BCs to use `cert_preflight` in a
>   follow-up pass. The dimension is NOT in PO's current in-flight scope (ss-10/ss-13),
>   so this is a low-risk scheduling note.
> - **Reference from ARCH-INDEX.md:** Document Map entry for `methodology-layer.md`
>   now explicitly notes it contains the canonical dimension field name registry.

> **v1.2 changes (Pass-2 adversarial defect resolution):**
> - **I2-01 fixed:** §3.D-SEC `Subsystem` field corrected from `SS-04, SS-02` → `SS-06`
>   (Convergence Tracking Engine). BC-7.11.001 (D-SEC owner) and BC-7.11.002..008
>   (server-authority invariants) all declare `subsystem: SS-06`; subsystem-decomposition
>   assigns all BC-7.* to SS-06. The previous SS-04/SS-02 was an incorrect stale value.
> - **I2-04 fixed:** §2.3 replay-regression-contract example delexicalized: "T1 adapters
>   (Bevy+Rapier)" replaced with "a fully-deterministic T1 adapter" per DI-008 (no engine
>   names in Layer-2 artifacts). The engine-neutrality guarantee of this section is now
>   consistent with §0's declaration.
> - **S2-03:** §3.D-SEC degradation predicate is the authoritative rule (unchanged).
>   ADR-0006 table updated to match this document's semantics. Rule: degradation only
>   via explicit `online_features: false` (offline products); no degradation path for
>   online games with failing CWE-602 invariants.

> **v1.1 changes (Phase-1d arch alignment):**
> - **S3 fixed:** `inputs:` frontmatter: `prd-cap-012.md` (non-existent file) replaced
>   with `prd-cap-008-012.md` (the actual file where CAP-012 lives).
> - **C1 fixed:** §2.5 `monetization-ethics-contract` schema `forbidden_patterns` table
>   DP descriptions now exactly match the canonical prd-cap-011.md §11.3 meanings.
>   Previous values were drifted from canonical (wrong pattern-to-description mapping).
> - **I5 fixed:** §2.8 `sequence-graph` `directed: true` wording corrected to use
>   "cinematic-director creative gate" vocabulary, distinct from ADR-0007 `human-gated`
>   fidelity tier (which is reserved for external third-party acts only). D-013
>   distinction is now explicit. D-ASSET degraded predicate updated to match.

> **Pass 2a scope.** This document specifies the Layer-2 quality model: contract-type
> schemas, the 11-dimension convergence model with precise pass/degraded/blocked
> predicates, and the game workflow phase definitions that replace the vsdd-factory
> equivalents. Layer-2 is the REPLACE/ADAPT delta from vsdd; it is engine-neutral
> by construction (DI-008 — no engine names or SDK references appear in any Layer-2
> artifact).

---

## 1. Layer-2 Design Principle: REPLACE/ADAPT Delta

The extraction boundary (ADR-0005) places Layer-2 at the content/configuration
seam. Layer-2 specifies:

- **REPLACE:** vsdd's BC/VP schemas, holdout evaluation contract, DTU contract,
  7-dimension convergence definition, formal-hardening scope (Kani proofs on all
  modules).
- **ADAPT:** convergence loop engine (retaining 3-CLEAN streak, novelty-decay,
  declare-and-degrade); adversarial review loop; wave scheduling.
- **REUSE (unchanged):** orchestration spine, worktree/PR lifecycle, state manager,
  hook chain mechanism, agent framework.

**Layer-2 artifacts are engine-portable by construction (DI-008).** A spec artifact
that references `MonoBehaviour`, `bevy::prelude::*`, or any engine type name violates
DI-008 and is a structural defect detectable by the consistency-validator.

---

## 2. Contract-Type Schemas

Layer-2 replaces vsdd's BC/VP schema family with the following game contract types.
Each schema defines the fields that every instance of that contract type must
declare. The index mechanism (catalog + cross-doc consistency hook) is inherited
from vsdd; only the data model changes.

---

### 2.1 simulation-behavioral-contract

**Purpose.** Machine-verifiable assertions over serialized simulation state. The
direct replacement for vsdd's Behavioral Contract (BC). Every `simulation-bc`
assertion is validated by the engine adapter's `test` capability against the
pure-sim code slice.

**Required fields:**

```yaml
contract_type: simulation-behavioral-contract
id: SBC-NNN
title: "<human-readable title>"
subsystem: "SS-NN"
capability: "CAP-NNN"
priority: "P0 | P1 | P2"
status: "draft | active | superseded | withdrawn"

# The assertion
precondition: "<engine-neutral state description>"
action: "<engine-neutral trigger>"
postcondition: "<engine-neutral expected state>"
invariant_ref: "DI-NNN | null"         # domain invariant this BC enforces, if any

# Validation
validation_method: "tdd-red-gate | headless-test-runner | property-based | replay-regression"
engine_capability: "test | replay"     # which adapter capability validates this
determinism_tier_required: "bitwise-cross-platform | same-machine | tolerance-only | any"

# Traceability
traces_to: "<PRD section or capability ID>"
```

**Example scope.** Economy conservation invariants, damage I/O matrix correctness,
FSM state legality, AI behavior-tree determinism, server-authority invariants
(CWE-602 spine), rating-system math (Elo/Glicko-2/TrueSkill — the cleanest
formal-hardening targets in the corpus: pure functions, zero I/O).

---

### 2.2 design-intent-contract

**Purpose.** Captures the verifiable subset of design intent as typed assertions.
The remainder of design intent (feel, pacing, aesthetic direction) is explicitly
delegated to the playtest-protocol. Every design-intent-contract must include a
`playtest_delegation` section that explicitly names what it does NOT cover, with
structured per-claim entries (F40-03 — refined from scalar `playtest_delegation_note`).

**Required fields:**

```yaml
contract_type: design-intent-contract
id: DIC-NNN
title: "<human-readable title>"
subsystem: "SS-NN"
capability: "CAP-NNN"

# The verifiable assertions
reachability_assertions:
  - "<game state S is reachable from initial state via declared action set>"
solvability_assertion: "<game is completable from initial state | null if N/A>"
balance_band:
  metric: "<metric name, e.g. win_rate_band>"
  min: <numeric>
  max: <numeric>
no_softlock_invariant: "<predicate | null if N/A>"

# Explicit scope boundary — structured delegation section (DI-012 / BC-6.02.005)
playtest_delegation:
  delegated_claims:
    - claim: "<natural-language design intent assertion not machine-verifiable>"
      reason_not_machine_verifiable: "<one sentence explaining why this cannot be a sim-BC>"
      instrument: "<playtest instrument: GEQ | PENS | SUS | think-aloud | observation | null>"

# Validation
validation_method: "property-based | formal-kani | headless-test-runner"
traces_to: "<PRD section or capability ID>"
```

**Invariant.** A design-intent-contract without a non-empty `playtest_delegation`
section (≥1 entry in `delegated_claims[]`) is structurally invalid (DI-012).
The delegation section is not optional boilerplate — it is the explicit structured
declaration of what the factory cannot verify and what requires human judgment.
Each delegated claim carries `claim`, `reason_not_machine_verifiable`, and
(recommended) `instrument` fields per BC-6.02.005 postcondition #2.

**D-012 refinement note (F40-03).** The original D-012 decision named the field
`playtest_delegation_note` (scalar string). This schema now adopts the STRUCTURED
form `playtest_delegation.delegated_claims[]` from BC-6.02.005, which is richer and
operationally necessary: each delegated claim requires claim/reason/instrument that
a scalar note cannot carry. The intent of D-012 (explicit delegation boundary) is
fully preserved; only the field name and shape are refined.

---

### 2.3 replay-regression-contract

**Purpose.** Per-scenario recorded input track + golden expected state, used by the
deterministic replay harness (SS-02). The direct replacement for vsdd's DTU contract.

**Required fields:**

```yaml
contract_type: replay-regression-contract
id: RRC-NNN
title: "<human-readable title>"
subsystem: "SS-02"
scenario: "<description of the game scenario recorded>"

# Recording specification
determinism_tier: "bitwise-cross-platform | same-machine | tolerance-only"
recording_path: "<relative path to .replay file>"
golden_state_path: "<relative path to golden state snapshot | null if tolerance-only>"
tolerance_spec:
  applicable: <true | false>
  metrics: ["<metric-name>"]
  tolerance_window: { "<metric-name>": <epsilon-value> }

# Comparison method (dictated by determinism_tier)
# T1 (bitwise-cross-platform) → snapshot-hash-diff
# T2 (same-machine / pinned-runner) → snapshot-structured-diff (field-by-field; cross-platform hash equality not guaranteed)
# T3 (tolerance-only) → tolerance-window
comparison_method: "snapshot-hash-diff | snapshot-structured-diff | tolerance-window"

# Invalidation protocol
invalidation_triggers:
  - "<event that invalidates the golden state, e.g. sim-logic change>"
rebaseline_procedure: "<how to re-record and rebaseline>"

traces_to: "<SBC-NNN or DIC-NNN this regression guards>"
```

**Cross-cutting use.** The replay-regression-contract is structurally identical to
the esports `replay-format` artifact and the anti-cheat proof-of-state artifact —
the same harness serves all three use cases. A fully-deterministic T1 adapter
(`determinismTier: bitwise-cross-platform`) gets all three for free.

---

### 2.4 asset-provenance-sidecar

**Purpose.** Mandatory metadata record attached to every generated asset at generation
time. Defined here as a Layer-2 schema because it is populated by the asset-generation
orchestrator (Layer-2) before the asset-adapter writes it. The full field list is
also the source for the `ai-disclosure-manifest` and EU AI Act C2PA marks.

**Required fields** (none may be null except `likeness_consent_ref`):

```yaml
schema_type: asset-provenance-sidecar
asset_id: "<stable asset identifier>"
asset_class: "mesh3d | texture | audio.sfx | audio.music | audio.voice | image.concept | text.narrative"

generated_by_tool:         "<vendor/tool-name>"
model_version:             "<pinned model/weights version>"
generation_date:           "<ISO-8601>"
prompt_and_inputs_log:     "<full prompt + reference inputs>"
human_modifications_log:   []              # empty at generation; append on human transform
license_terms_snapshot:
  commercial_use: <true | false>
  indemnification_tier: "1 | 2 | 3"
training_data_provenance:  "licensed | open | unknown"
likeness_consent_ref:      null            # non-null triggers human-gated SAG-AFTRA flow (DI-006)
risk_tier:                 "1 | 2 | 3"
copyrightability_assessment: "likely | partial | unlikely"
disclosure_class:          "pre-generated | live-generated | procedural-exempt"
# disclosure_class values per Steam Jan 2026 rewrite and EU AI Act Art. 50:
# pre-generated = generated before shipping, baked into build
# live-generated = generated at runtime (triggers stronger disclosure requirements)
# procedural-exempt = traditional PCG (explicitly exempt per Steam policy)
```

**Conformance.** An asset that reaches the ingest gate without a complete sidecar
(any required field null or missing) is rejected by the asset-completeness hook
(D-ASSET convergence dimension gate). This is DI-003 enforcement.

---

### 2.5 monetization-ethics-contract

**Purpose.** Declares the constrained-optimization policy envelope for any game with
monetization. Mandatory when `business-model-spec` includes any non-premium mechanics.
Subject to mandatory adversarial review (D-ETHICS convergence dimension gate).

**Required fields:**

```yaml
contract_type: monetization-ethics-contract
id: MEC-NNN
game_id: "<game project identifier>"

allowed_mechanics: ["<mechanics list>"]     # e.g., cosmetic-dlc, battle-pass
forbidden_patterns:                         # factory-enforced never-list (six enforced patterns)
  - pattern: "DP-003"
    description: "Time-pressure purchase prompt during loss event (BC-11.03.003)"
  - pattern: "DP-004"
    description: "Pay-to-win in ranked/competitive mode (BC-11.03.002)"
  - pattern: "DP-005"
    description: "Loot boxes without odds disclosure (BC-11.03.001)"
  - pattern: "DP-006"
    description: "Miscategorized 'best value' bundle — dominated SKU labeled best value (BC-11.03.005)"
  - pattern: "DP-007"
    description: "Escalating offers on inferred high-vulnerability player — whale hunting (BC-11.03.006)"
  - pattern: "DP-008"
    description: "Loot box or gacha access for minors without spending control (BC-11.03.004)"

ltv_optimization_constraint:
  bounded: true                             # MUST be true; unbounded = factory defect (DI-005)
  constraint_description: "<declared bound on optimization objective>"

gacha_spec_ref: "<GCS-NNN | null>"          # required if gacha mechanics present
coppa_compliance_ref: "<PCC-NNN | null>"    # required if child-directed or ad-monetized

adversarial_review_required: true           # non-negotiable; false = structural defect
adversarial_review_evidence_ref: "<path | null>"  # populated after review pass
```

**Adversarial review gate.** A `monetization-ethics-contract` with
`adversarial_review_evidence_ref: null` blocks the D-ETHICS convergence dimension.
The adversary's task is specifically to verify that optimization is constrained and
that no forbidden pattern (DP-003 through DP-008) is present in the implementation.

---

### 2.6 cross-discipline-dependency-contract

**Purpose.** Typed contract per dependency edge between disciplines in the wave DAG.
Ensures that a downstream discipline (e.g., audio-implementer depending on
narrative-designer for dialogue tables) has a machine-checkable handoff predicate,
not just an informal dependency.

**Required fields:**

```yaml
contract_type: cross-discipline-dependency-contract
id: CDC-NNN
from_discipline: "<discipline or agent role>"
to_discipline: "<discipline or agent role>"
artifact_type: "<type of artifact being handed off>"
format: "<file format or schema reference>"

acceptance_criteria:
  - "<machine-checkable predicate>"
  - "<e.g., 'dialogue_table passes loc-string-contract schema validation'>"

budget_constraints:           # optional; for art handoff to engineering
  poly_budget: null
  texture_budget_bytes: null

naming_convention_ref: "<schema or regex | null>"
wave_ordering_constraint: "from_discipline MUST complete before to_discipline in wave N"
```

---

### 2.7 canon-kb schema

**Purpose.** The Canon Knowledge-Base is the sixth load-bearing seam (product-brief
§Overflow Context). It is the RAG grounding anchor for all generative agents. Its
structural integrity is machine-checkable; its narrative quality is human-judged.

**Top-level schema:**

```yaml
schema_type: canon-kb
game_id: "<game project identifier>"

entity_registry:             # typed list of all lore entities
  - id: "<CANON-NNN>"
    type: "character | faction | location | item | concept | event"
    name: "<canonical name>"
    aliases: []
    status: "active | deprecated | retconned"

relationship_graph:          # directed edges between entities
  - from: "<CANON-NNN>"
    to:   "<CANON-NNN>"
    relation: "<relation-type>"
    canon_status: "confirmed | disputed | retconned"

timeline:                    # ordered events; must be acyclically consistent
  - event_id: "<CANON-EVT-NNN>"
    timestamp: "<in-world timestamp>"
    participants: ["<CANON-NNN>"]
    canon_status: "confirmed | disputed"

naming_registry:             # phonotactic + style rules for generated names
  rules: ["<rule description>"]
  validated_names: []

canon_facts:                 # declarative assertions that all generative agents must respect
  - id: "<CANON-FACT-NNN>"
    assertion: "<statement>"
    source_entity_refs: ["<CANON-NNN>"]
```

**Machine-checkable structural properties (enforced by SS-10):**
- No dangling entity refs in `relationship_graph` or `timeline.participants`.
- `timeline` is acyclically ordered (no event A precedes event B and B precedes A).
- `naming_registry` rules are satisfied by all names in `entity_registry`.
- No `canon_facts` assertion references a non-existent entity ID.

---

### 2.8 sequence-graph

**Purpose.** Engine-agnostic time-keyed multi-track cutscene document. Peer to
`narrative-graph`. Stable IDs enable engine-adapter-level import without core changes.

**Schema:**

```yaml
schema_type: sequence-graph
id: SG-NNN
title: "<scene title>"
duration_seconds: <number>
directed: <true | false>      # true → human cinematic-director sign-off gate

tracks:
  animation:   [{ asset_ref, entity_ref, start_s, end_s, clip_id }]
  camera_cut:  [{ shot_type, entity_ref, start_s, duration_s }]
  facial_lipsync: [{ entity_ref, audio_ref, method, start_s }]  # ARKit-52 blendshapes
  audio:       [{ asset_ref, bus, start_s, end_s }]
  subtitle:    [{ text_ref, lang, start_s, end_s }]
  event:       [{ event_type, payload, at_s }]
  activation:  [{ entity_ref, action, at_s }]

asset_refs: ["<all referenced asset IDs; must resolve in asset store>"]
```

**Machine-checkable properties:**
- All `asset_refs` resolve in the asset store (no dangling refs).
- Subtitle coverage: every audio track with dialogue has a subtitle track entry.
- Audio sync: `facial_lipsync[i].audio_ref` is present in `audio` track.
- `directed: true` surfaces a cinematic-director creative gate checklist item for
  cinematic sign-off. **D-013 distinction:** this is a creative finishing gate —
  it blocks completion of the cinematic sequence until a named cinematic director
  reviews and approves the shot sequence. This is distinct from and must not use
  the vocabulary of the `human-gated` fidelity tier (ADR-0007), which is reserved
  exclusively for external, third-party-required human acts (console cert sign-off,
  store publish, SAG-AFTRA IMA consent, XR comfort-cert, legal opinion). The
  cinematic director is an internal creative principal, not an external third party.
  The corresponding error code is `E-CIN-003` (cinematic-director sign-off absent),
  not `HumanGatedTaskPending` (-32008).

---

## 3. The 11 Convergence Dimensions

Defined in ADR-0006. This section provides the **precise pass / degraded / blocked
predicate** for each dimension. SS-06 (Convergence Tracking Engine) evaluates these
predicates and gates the release.

The convergence loop mechanics are **ADAPTED from vsdd** (not replaced):
- Novelty-decay assessment per dimension each evaluation cycle.
- **3-CLEAN streak required for convergence** (all 11 required dimensions green or
  explicitly degraded-and-acknowledged, for 3 consecutive evaluation cycles).
- Any dimension at `degraded` must document the explicit fallback and record human
  acknowledgment. Degraded-but-undocumented = blocked.
- Release is blocked until either convergence is reached or the human principal
  accepts a named degradation for each non-converged dimension.

---

### §3.0 Canonical Dimension Field Name Registry

**This table is the single source of truth for `convergence-report.dimensions.<field>` JSON
field names.** Every BC, consumer module, and implementation artifact that reads or writes a
convergence-report dimension MUST use the canonical field name from this table. Using a
non-canonical name is a latent producer/consumer drift defect (class O-2).

**Authority:** This table overrides any individual BC that names a field. Where an existing
BC already pinned a field name, this table adopts that name (marked "pinned by BC"). Where no
BC had pinned a name, this table assigns one (marked "assigned here"). Any consumer that
disagrees with an assigned name should raise a spec change request — not silently use a
different name.

**Referenced from:** ARCH-INDEX.md §Document Map (`methodology-layer.md` entry). Any
implementation or integration test that writes to `convergence-report.dimensions` must
validate field names against this table.

| Dim ID | Dimension Title | Canonical field name | Derivation | Owner BC |
|--------|----------------|----------------------|------------|----------|
| D-SIM | Sim/Spec | `sim_spec` | pinned by BC-7.01.001 | BC-7.01.001 |
| D-REPLAY | Tests/Replay Regression | `tests_replay` | pinned by BC-7.02.001 | BC-7.02.001 |
| D-IMPL | Implementation | `implementation` | assigned here (natural slug) | BC-7.03.001 |
| D-ASSET | Asset Completeness | `asset_completeness` | assigned here (natural slug) | BC-7.04.001 |
| D-PLAY | Playtest Satisfaction | `playtest_satisfaction` | assigned here (matches BC-7.05.001 title "Playtest-Satisfaction") | BC-7.05.001 |
| D-CERT | Cert-Preflight + Distribution-Readiness | `cert_preflight` | pinned by BC-7.06.001 | BC-7.06.001 |
| D-PERF | Performance Budget | `perf_budget` | assigned here (natural slug) | BC-7.07.001 |
| D-PROV | Provenance / Legal and Compliance | `provenance_legal_compliance` | pinned by consumer BCs (BC-10.02.001, BC-10.06.001); consistent with BC-7.08.001 semantic | BC-7.08.001 |
| D-DOCS | Documentation | `docs` | assigned here (natural slug) | BC-7.09.001 |
| D-ETHICS | Monetization Ethics | `monetization_ethics` | assigned here (natural slug) | BC-7.10.001 |
| D-SEC | Security Invariants | `security_invariants` | assigned here (natural slug) | BC-7.11.001 |

**Count invariant:** 11 unique field names, one per dimension. No two dimensions share a
field name. The check-spec-counts.sh check (m) asserts this invariant at CI time.

**Resolved in Pass-9:** BC-9.04.001, BC-9.06.001, and BC-9.06.002 now use
`convergence-report.dimensions.cert_preflight` (updated from the former non-canonical
`distribution_readiness`). No outstanding consumer drift for D-CERT field naming.

---

### §3.1 Canonical Convergence-Dimension Status-Value Enum

**This section is the single source of truth for every value a
`convergence-report.dimensions.<field>` entry may hold.** The canonical vocabulary
is the closed set used by the SS-06 dimension-owner BCs (BC-7.01.001 through
BC-7.11.001). Any producer BC in any other subsystem that writes a value outside
this enum is non-canonical and must be corrected.

**Authority:** This enum supersedes any divergent value in producer BCs. The owner
BCs (SS-06) are canonical authority; consumer/producer BCs in SS-09/10/11/13 are
subordinate consumers and must adopt this vocabulary.

#### Canonical Status-Value Enum

| Value | Meaning | Applicable Dimensions |
|-------|---------|----------------------|
| `GREEN` | All pass predicates satisfied; no outstanding gates. | All 11 dimensions (subject to per-dimension rules below) |
| `DEGRADED` | Pass preconditions partially met with an explicit, documented fallback; human acknowledgment recorded. Generic intermediate state when a degradation path exists. | D-SIM, D-REPLAY, D-ASSET, D-PLAY, D-CERT, D-PERF, D-PROV, D-SEC (offline only) |
| `DEGRADED-PENDING` | All automatable work is complete; one or more human or on-device acts are outstanding (e.g. console cert sign-off, attorney review, store publish, playtest session not yet run, GPU/XR hardware not yet available). Distinct from DEGRADED in that the factory has done its full automated share — only an external human act or on-device measurement remains. | D-CERT, D-PROV, D-PLAY, D-PERF |
| `BLOCKED` | A hard failure predicate is met; the dimension cannot proceed. A BLOCKED dimension halts release. | All 11 dimensions |

**Rationale for DEGRADED vs AMBER:** The dimension predicates throughout §3 and
ADR-0006 use the vocabulary "degraded predicate" / "blocked predicate". The owner
BCs (BC-7.06.001, BC-7.08.001, etc.) have always written `DEGRADED` and
`DEGRADED-PENDING`. `AMBER` is a producer-side drift that entered SS-09/10/11/13
BCs without authorization. It is NOT canonical. Producers writing `AMBER` for the
intermediate state MUST be updated to `DEGRADED` or `DEGRADED-PENDING` as
appropriate (see PO change list below). Choosing a single closed set ({GREEN,
DEGRADED, DEGRADED-PENDING, BLOCKED}) rather than collapsing DEGRADED and
DEGRADED-PENDING into one value preserves the actionable distinction between "degraded
with documented fallback" and "automatable work done, waiting on a specific named
human act" — the latter is required to implement DI-006 (human-gated tasks surfaced
not suppressed).

#### Per-Dimension Allowed Value Subsets

| Dim | Allowed Values | Rationale |
|-----|---------------|-----------|
| D-SIM | GREEN, DEGRADED, BLOCKED | Degradation path: tolerance-only tier or waived low-priority SBCs. |
| D-REPLAY | GREEN, DEGRADED, BLOCKED | Degradation path: `replay: none` adapter with playtest evidence. |
| D-IMPL | GREEN, BLOCKED | No degradation path defined; CI either passes or fails. |
| D-ASSET | GREEN, DEGRADED, BLOCKED | Degradation path: placeholder assets with documented gaps. |
| D-PLAY | GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED | DEGRADED-PENDING: playtest scheduled; playable build available; sessions not yet completed. DEGRADED: playtest run, scores below threshold, but human reviewer has approved with documented rationale (human override). No automated fun-score substitution ever permitted (DI-007). |
| D-CERT | GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED | DEGRADED for NDA-gated platform or no platforms declared. DEGRADED-PENDING when automatable prefix complete but human-gated tasks outstanding. |
| D-PERF | GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED | DEGRADED-PENDING: CPU gate is GREEN; GPU/XR hardware not yet available for on-device measurement. DEGRADED: GPU metrics unavailable from engine adapter; best-effort advisory. |
| D-PROV | GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED | DEGRADED-PENDING when schema checks pass but consent/legal tasks outstanding. |
| D-DOCS | GREEN, BLOCKED | No degradation path defined. |
| **D-ETHICS** | **GREEN, BLOCKED** | **Binary. No degradation path. DI-005: unconstrained LTV = factory defect. If monetization is active, the ethics contract must be present and clean-reviewed — no intermediate fallback. See ADR-0006.** |
| D-SEC | GREEN, DEGRADED (offline only), BLOCKED | DEGRADED only when `online_features: false` explicitly declared. Online games: no degradation path. |

**D-ETHICS binary decision (adjudication):** BC-7.10.001 states "NO DEGRADATION
PATH" and DI-005 defines unconstrained LTV optimization as a factory defect. An
intermediate `DEGRADED` state for ethics would create a path to ship a game with an
unreviewed ethics contract in degraded mode — this contradicts the adversarial-review
mandate. Therefore D-ETHICS permits only {GREEN, BLOCKED}. Any producer BC (such
as BC-11.01.002, BC-11.03.006) that writes an intermediate value for
`monetization_ethics` is writing a BUG: the intermediate state before adversarial
review is complete should be `BLOCKED` (not DEGRADED/AMBER), because the review is
not optional and cannot be deferred.

#### Resolved in Pass-10 — Producer BCs Using Non-Canonical `AMBER`

**Resolved in Pass-10:** The following producer BCs were updated by the Product Owner to
replace non-canonical `AMBER` with the correct canonical value per the §3.1 enum. CI
check (n) (added in v1.9 of check-spec-counts.sh) became green after these updates.

| BC | Field | Old Value | New Value | Notes |
|----|-------|-----------|-----------|-------|
| BC-9.01.001 | `convergence-report.dimensions.cert_preflight` | `AMBER` | `DEGRADED-PENDING` | "Awaiting human review / human-gated tasks outstanding" maps to DEGRADED-PENDING per D-CERT allowed set. |
| BC-9.04.001 | `convergence-report.dimensions.cert_preflight` | `AMBER` | `DEGRADED-PENDING` | PARTIAL/PENDING overall states → dimension is DEGRADED-PENDING (automatable work done, human tasks outstanding). |
| BC-9.06.001 | `convergence-report.dimensions.cert_preflight` | `AMBER` | `DEGRADED-PENDING` | Dimension remains non-GREEN while human-gated console cert task outstanding; canonical value is DEGRADED-PENDING. |
| BC-9.06.002 | `convergence-report.dimensions.cert_preflight` | `AMBER` | `DEGRADED-PENDING` | Same as BC-9.06.001; store-publish human task → DEGRADED-PENDING. |
| BC-10.02.001 | `convergence-report.dimensions.provenance_legal_compliance` | `AMBER` | `DEGRADED-PENDING` | Schema-GREEN + human-gated items pending → DEGRADED-PENDING per D-PROV allowed set. |
| BC-10.06.001 | `convergence-report.dimensions.provenance_legal_compliance` | `AMBER` | `DEGRADED-PENDING` | Human legal/consent tasks outstanding → DEGRADED-PENDING. |
| BC-11.01.002 | `convergence-report.dimensions.monetization_ethics` | `AMBER` | `BLOCKED` | D-ETHICS is binary. "Contract present, adversarial review not yet complete" is BLOCKED, not a degradation. DI-005. |
| BC-11.03.006 | `convergence-report.dimensions.monetization_ethics` | `AMBER` | `BLOCKED` | D-ETHICS is binary. Flagged-pending-review intermediate state is BLOCKED. |
| BC-13.01.004 | `convergence-report.dimensions.cert_preflight` | `AMBER` | `DEGRADED-PENDING` | NFT/web3 console policy check pending human review → DEGRADED-PENDING. |
| prd-cap-009-010.md §11.2 line ~339 | prose reference `provenance_legal_compliance` must be at least `AMBER` | `AMBER` | `DEGRADED-PENDING` | Updated prose to: "must be at least `DEGRADED-PENDING`". |

#### Resolved in Pass-12 — BC-8.08.004 Lowercase D-PLAY Status Values

**Resolved in Pass-12:** BC-8.08.004 (`playtest-satisfaction` D-PLAY status producer;
SS-07 sign-off gate feeding the SS-06 dimension owner BC-7.05.001) was absent from the Pass-10 change list above — it was the root
cause of F-12-01 (CI false-green that survived 11 adversarial passes). Unlike the
Pass-10 BCs which used uppercase `AMBER`, BC-8.08.004 used **lowercase** status tokens
(`green`, `red`, `amber`, `pending`) which were structurally invisible to check (n)'s
uppercase-only extraction (F-12-02). The Product Owner updated BC-8.08.004 to use
uppercase canonical values: `GREEN`, `RED`→`BLOCKED`, and `PENDING`→`DEGRADED-PENDING`
(D-PLAY allows GREEN/DEGRADED/DEGRADED-PENDING/BLOCKED per §3.1; scheduled but not yet run). CI check (n) was
simultaneously extended (v1.12) to be case-insensitive at the detection layer to prevent
recurrence.

---

### D-SIM: Simulation / Spec

**ID:** D-SIM | **Automated:** Yes | **Subsystem:** SS-05

**Pass predicate:** All `simulation-behavioral-contract` assertions green on the
`test` adapter capability for the declared pure-sim code slice; all
`design-intent-contract` reachability, solvability, no-softlock, and balance-band
assertions pass; server-authority-invariant-suite (CWE-602) all green.

**Degraded predicate:** `determinismTier = tolerance-only` for the active adapter
AND all tolerance-window assertions pass within declared epsilon; OR a declared
subset of low-priority SBCs are waived with documented rationale and human ACK.

**Blocked predicate:** Any P0 SBC fails; any server-authority invariant fails;
any design-intent reachability assertion fails; or `determinismTier` undeclared
(defaults to `tolerance-only` per DI-004, which may trigger degraded).

---

### D-REPLAY: Tests / Replay Regression

**ID:** D-REPLAY | **Automated:** Yes (tier-dependent) | **Subsystem:** SS-02

**Pass predicate:** All `replay-regression-contract` scenarios pass their declared
comparison method; comparison method matches adapter's `determinismTier`
(T1 = snapshot-hash-diff, T2 = pinned-runner snapshot-structured-diff, T3 = tolerance-window).
T2 uses structured field-by-field diff, not a bitwise hash, because cross-platform hash
equality is not guaranteed for pinned-runner adapters (F40-01).

**Degraded predicate:** Adapter declares `replay: none` → D-REPLAY degrades to
"playtest evidence required"; structured playtest provides regression evidence per
playtest-protocol. OR T2 adapter but CI runner is not pinned — degrades until runner
is pinned.

**Blocked predicate:** Adapter declares `replay: partial` but the partial
prerequisites (`fixed-timestep`, `seeded-rng`, `input-injection`) are not met;
OR replay regression returns hash mismatch on a T1 adapter (this is a sim defect,
not a degradation).

---

### D-IMPL: Implementation

**ID:** D-IMPL | **Automated:** Yes | **Subsystem:** SS-04

**Pass predicate:** Build succeeds on all target platforms; lint is clean; no
engine-SDK import or engine name reference in Layer-1/2 source artifacts (DI-001
enforcement); `security-requirements-contract` structurally present for any
online/multiplayer build; architecture-separation rule (pure-sim logic vs engine-bound
code) passes consistency-validator.

**Degraded:** No degradation — build pass and DI-001 compliance are hard gates.

**Blocked predicate:** Build fails; DI-001 violation detected; lint errors
(not warnings) present; or `security-requirements-contract` absent for an online
build.

---

### D-ASSET: Asset Completeness

**ID:** D-ASSET | **Automated:** Yes | **Subsystem:** SS-03

**Pass predicate:** All `asset-generation-request` items fulfilled; all assets have
valid `asset-provenance-sidecar` with `disclosure_class` non-null (DI-003); all
asset packages pass quality gate (topology/UV/PBR/loudness per asset class);
all `sequence-graph` and `narrative-graph` asset refs resolve in asset store;
`ai-disclosure-manifest` generated.

**Degraded predicate:** Placeholder assets declared for documented gaps with
human-ACK; quality-gate failed on Tier-2/3 risk assets but ingested per pure-maximal
policy with risk recorded in sidecar; `directed: true` cinematic awaiting
cinematic-director creative sign-off (surfaced as a creative gate checklist item,
not a third-party external act; this is NOT the `human-gated` fidelity tier of
ADR-0007, which is reserved for external third-party acts such as console cert
sign-off and SAG-AFTRA consent — see D-013 distinction in §2.8).

**Blocked predicate:** Any asset missing a sidecar (DI-003 violation); any
asset-generation-request item unfulfilled with no placeholder declared; any
`disclosure_class: null` when EU AI Act Art. 50 deadline (2026-08-02) has passed.

---

### D-PLAY: Playtest / Feel

**ID:** D-PLAY | **Automated:** Never | **Subsystem:** SS-07

**Pass predicate:** Structured playtest protocol run with declared recruitment
criteria and task set; 3-lens convergence report (say / do / behave) completed;
GEQ / PENS / SUS instrument scores meet declared targets; human sign-off recorded
by a named human principal.

**DEGRADED-PENDING predicate:** Playtest has been scheduled; playable build is available;
sessions not yet completed. The dimension is pending, not blocked. Release is blocked
until human sign-off is obtained, but the factory can continue other convergence work.
This is the correct state when a real playtest is imminent but incomplete — NOT a degradation
of the quality bar. Major gameplay change after sign-off also reverts to DEGRADED-PENDING.

**DEGRADED predicate:** Playtest sessions completed; human reviewer has approved with
documented rationale despite scores below declared thresholds (human override). This is
valid — human principal judgment supersedes metric thresholds when explicitly recorded.

**No automated DEGRADED path:** Any automated metric, agent fun-score, or synthetic
playtest evidence substituted for the structured protocol is a factory defect (DI-007).
The distinction is critical: DEGRADED-PENDING means "a real human playtest is scheduled
but not yet run"; it does NOT mean "an automated score is substituting for the playtest."

**Blocked predicate:** Playtest protocol not run and not scheduled; human sign-off absent
with no DEGRADED-PENDING declaration; any agent or hook emitting an automated fun-score
in the playtest-satisfaction dimension (defect per DI-007).

**XR note.** For XR targets, D-PLAY requires physical headset sessions. This is a
harder boundary than flat-screen: motion sickness cannot be evaluated without the
headset. The playtest protocol must include the `xr-comfort-battery` instrument set.

---

### D-CERT: Cert-Preflight and Distribution-Readiness

**ID:** D-CERT | **Automated:** Partial + human-gated terminal steps | **Subsystem:** SS-08

**Pass predicate:** Machine-checkable cert pre-flight passes for all declared target
platforms (estimated 55-80% coverage); `distribution-release-pipeline` artifact
generated and all verified CLIs (steamcmd / butler / fastlane) execute successfully
in dry-run mode; all `human-gated` cert and store-publish tasks acknowledged by a
named human principal.

**Degraded predicate:** NDA-gated platform (console) cert pre-flight partially
complete; `human-gated` checklist items emitted but not yet acknowledged (surfaced,
not silent — DI-006 compliant); IARC objective questions auto-filled; content-intensity
questions deferred with documented schedule.

**Blocked predicate:** Any `human-gated` distribution task suppressed or
auto-completed without acknowledgment (DI-006 violation); cert pre-flight returning
failures on non-NDA categories; distribution CLI dry-run failing; compliance-checklist
items with hard deadlines unmet (e.g., EU AI Act 2026-08-02 if applicable).

---

### D-PERF: Performance Budget

**ID:** D-PERF | **Automated:** Yes (CPU-bound) + on-device (GPU/XR) | **Subsystem:** SS-04

**Pass predicate:** Frame time (CPU + GPU ms) within `perf-budget-contract`
thresholds on all declared target hardware; 1%/0.1%-low frame time within declared
bound; memory soak within limit; thermal within envelope on declared target device.

**DEGRADED-PENDING predicate:** CPU gate is GREEN; GPU or XR hardware not yet available
for on-device measurement. The factory has completed all CPU-bound automated work; the
GPU/XR gate is outstanding pending hardware availability. This is the canonical state for
"CPU GREEN, GPU/XR gate not yet scheduled." Major GPU regression after prior GREEN also
reverts to DEGRADED-PENDING until re-measurement.

**DEGRADED predicate:** GPU metrics not exportable from the engine adapter (best-effort
advisory); CPU gate passes; manual profiler evidence provided with declared methodology
as substitute. This is the weaker path (metrics approximated, not measured).

**Blocked predicate:** CPU frame time gate fails in CI; memory soak exceeds limit;
`perf-budget-contract` absent; XR targets active without per-eye frame-time budget
declared.

---

### D-PROV: Provenance / Legal and Compliance

**ID:** D-PROV | **Automated:** Yes + human-gated for legal terminal steps | **Subsystem:** SS-03, SS-08

**Pass predicate:** Every generated asset has valid sidecar (DI-003); `ai-disclosure-manifest`
generated with `disclosure_class` for every asset; `compliance-checklist` auto-filled
and passing; `privacy-config-contract` present; C2PA marks embedded on all applicable
assets (EU AI Act Art. 50, once 2026-08-02 deadline active); SAG-AFTRA consent refs
present for all voice/likeness assets with `likeness_consent_ref != null`; `legal-doc-set`
template generated; all `human-gated` legal sign-offs acknowledged.

**Degraded predicate:** Legal review scheduled but not yet complete; `human-gated`
legal sign-off checklist items surfaced and acknowledged as pending; sidecar schema
valid but `copyrightability_assessment: unlikely` assets flagged in risk register
(pure-maximal policy: recorded, not blocked).

**Blocked predicate:** Any asset missing sidecar; any `disclosure_class: null` at
the 2026-08-02 deadline; SAG-AFTRA human-gated consent task auto-completed or
suppressed (DI-006 violation); PEGI 2026 minimum-rating rule triggered by
`content-descriptor-contract` field and compliance-checklist not updated.

---

### D-DOCS: Documentation

**ID:** D-DOCS | **Automated:** Yes (structural) | **Subsystem:** SS-04

**Pass predicate:** All agent-produced contract artifacts have required frontmatter
fields (`id`, `traces_to`, `validation_method`, `status`); all
`design-intent-contract` instances have a non-empty `playtest_delegation` section
containing ≥1 entry in `delegated_claims[]` (DI-012 / BC-6.02.005; F40-03 —
structured form replaces former scalar `playtest_delegation_note`);
`monetization-ethics-contract` adversarial review evidence present (when
monetization is declared).

**Degraded predicate:** Supplementary/non-contract documentation missing; doc
structural check advisory for non-gating artifacts.

**Blocked predicate:** Any P0/P1 `simulation-behavioral-contract` or
`design-intent-contract` missing `validation_method` or `traces_to`; any
`monetization-ethics-contract` missing `adversarial_review_evidence_ref` when
`adversarial_review_required: true`.

---

### D-ETHICS: Monetization Ethics

**ID:** D-ETHICS | **Automated:** Contract presence + adversarial review | **Subsystem:** SS-09

**Pass predicate:** `monetization-ethics-contract` present with `bounded: true` LTV
constraint; no forbidden pattern (DP-003 through DP-008) detectable in
implementation; adversarial review complete with `adversarial_review_evidence_ref`
populated; PEGI/ESRB/regulatory descriptors consistent with declared mechanics;
COPPA consent wiring present for ad SDKs if `ad-monetization-spec` present.

**Degraded:** No degradation — if monetization is present, D-ETHICS is mandatory
(DI-005). A game with declared monetization mechanics and no `monetization-ethics-contract`
is not a degraded state — it is blocked.

**Blocked predicate:** Monetization present and `monetization-ethics-contract`
absent; `bounded: false` LTV constraint (DI-005 violation); any forbidden DP-NNN
pattern detected; adversarial review not completed.

---

### D-SEC: Security Invariants

**ID:** D-SEC | **Automated:** Yes (required for online games) | **Subsystem:** SS-06

**Pass predicate:** `server-authority-invariant-suite` (CWE-602 spine) all assertions
green: no-trust-client, input range/rate/sequence validation, replay-attack prevention,
authoritative reconciliation, interest-management, economy conservation/atomicity,
secure entitlement. Anti-cheat adapter wired for competitive-MP targets. Moderation
pipeline wired if UGC/chat present.

**Degraded predicate:** Applicable only for non-online, non-multiplayer games where
`security-requirements-contract` is absent by design (premium single-player, offline).
Degradation must be declared explicitly with `online_features: false`.

**Blocked predicate:** Online/multiplayer game without `server-authority-invariant-suite`;
any CWE-602 invariant failing; kernel anti-cheat authored autonomously (DI-010 violation);
`moderation-pipeline-contract` absent for a game with UGC/chat.

---

## 4. Game Workflow Phase Definitions

The Layer-1 pipeline scaffold (repo-init → planning → spec → adversarial loop →
wave delivery → convergence → release) is REUSED untouched. The following phases
are REPLACED or ADAPTED:

---

### 4.1 Phase 4: Playtest Protocol (REPLACES Phase-4 Holdout Evaluation)

**vsdd equivalent replaced:** `phase-4-holdout-evaluation.lobster`
**Replacement:** `phase-4-playtest-protocol.lobster`

**How it differs from holdout evaluation:**

| Aspect | vsdd Holdout Evaluation | game-factory Playtest Protocol |
|--------|------------------------|-------------------------------|
| Agent | `holdout-evaluator` (automated, information asymmetry) | `playtest-evaluator` (structured human gate coordinator) |
| Execution | Fully automated; evaluator runs held-out scenarios | Requires human participants; factory structures protocol |
| Output | Pass/fail + confidence interval | 3-lens convergence report (say/do/behave) + GEQ/PENS/SUS scores |
| Automation | Automated held-out scenario execution | Never automated; any fun-score automation = defect (DI-007) |
| Gate type | Automated CI gate | Human sign-off gate |
| Degradation | Not applicable | Not applicable — D-PLAY is non-substitutable |

**Phase steps:**
1. `playtest-evaluator` generates playtest protocol document (research question,
   recruitment criteria, task set, instrument selection).
2. Protocol is validated by `functional-qa` and `balance-qa` for coverage.
3. Human participants complete sessions using the structured protocol.
4. `playtest-evaluator` synthesizes the 3-lens convergence report.
5. Human principal reviews report and signs off (or flags for additional sessions).
6. Sign-off recorded in factory state; D-PLAY gate clears.

**XR extension.** For XR targets, phase 4 requires physical headset sessions and
the `xr-comfort-battery` instrument set. This adds a time constraint not present in
flat-screen playtest — physical sessions cannot be parallelized beyond headset count.

---

### 4.2 Phase 6: Sim Hardening (REPLACES Phase-6 Formal Hardening)

**vsdd equivalent replaced:** `phase-6-formal-hardening.lobster`
**Replacement:** `phase-6-sim-hardening.lobster`

**Key distinction from vsdd formal hardening:** Formal verification tools (Kani,
cargo-fuzz, cargo-mutants) are NOT applied to the entire codebase. They are
**scoped to the pure-sim slice only** — deterministic pure functions with no I/O,
no engine SDK calls, no global state.

**Pure-sim slice definition.** Code eligible for formal hardening:
- Economy simulation logic (conservation invariants, no-infinite-money proofs).
- Rating-system math (Elo, Glicko-2, TrueSkill, Weng-Lin — pure functions, the
  cleanest formal-hardening targets in the corpus per AAA-RECONCILIATION §4).
- State machine legality proofs (FSM invariants).
- Balance/progression formula correctness (property-based testing).
- Server-authority invariant assertions (CWE-602 spine — pure predicates over
  serialized state).

**Code NOT eligible for sim hardening (engine-bound code):**
- Engine-adapter implementations (Layer-4) — engine SDK calls.
- Rendering / graphics pipelines — GPU/driver non-determinism.
- Platform SDK integrations — external I/O.
- Asset generation drivers — external API calls.

**Phase steps:**
1. `formal-verifier` (game edition) identifies the pure-sim slice boundary.
2. Property-based tests (Hypothesis / proptest) written for all balance/progression
   formulas.
3. Kani proof harnesses written for economy conservation invariants.
4. Kani proof harnesses written for rating-system math invariants.
5. Cargo-fuzz or equivalent run on FSM input parsing.
6. All pure-sim slice proofs pass; results recorded in convergence state.
7. D-SIM gate updated with formal evidence.

---

### 4.3 Convergence Loop (ADAPT — Loop Engine REUSE, Dimensions REPLACE)

**vsdd equivalent:** convergence-tracking skill + 7-dimension definitions.
**Disposition:** ADAPT (loop engine + 3-CLEAN streak + novelty-decay REUSE;
dimension list REPLACE with 11 game dimensions).

**Loop mechanics (extracted verbatim from vsdd):**
- Each evaluation cycle assesses all 11 dimensions against their pass/degraded/blocked
  predicates (defined in §3 above).
- **Novelty-decay** tracks whether each dimension is still producing new findings;
  a dimension with no new findings for N consecutive cycles is declared stale.
- **3-CLEAN streak:** convergence is declared when all required dimensions are green
  (pass or degraded-and-acknowledged) for 3 consecutive evaluation cycles.
- Any dimension at `blocked` resets the streak for the entire release.

**Declare-and-degrade rule (game extension).** Convergence dimensions are wired to
adapter fidelity declarations:
- If `replay: none` → D-REPLAY degrades automatically to playtest evidence.
- If `capture: none` → D-ASSET capture-recipe evidence degrades to manual captures.
- If `cert.submit: human-gated` → D-CERT is blocked until acknowledgment.
- The core never assumes a capability; it reads the manifest and degrades accordingly.

**Dimension enable/disable by game profile.** Inactive genre lanes do not add
dimensions. D-ETHICS is enabled when any monetization mechanics are declared.
D-SEC is enabled when any online/multiplayer features are declared. All other
dimensions are always active regardless of genre.

---

### 4.4 Phase-1 Spec Steps: Replay-Regression Assessment (REPLACES DTU/Gene-Transfusion)

**vsdd equivalent replaced:** DTU assessment step + gene-transfusion assessment step.
**Replacement:** `replay-regression-harness-assessment.lobster` step in phase-1.

**What the replacement assesses:**
1. For each declared engine adapter: which `determinismTier` is achievable?
2. What golden-state or tolerance-window strategy is appropriate?
3. Which game scenarios require `replay-regression-contract` records?
4. Are replay prerequisites (fixed-timestep, seeded-rng, input-injection) met by
   the declared adapter configuration?

**Output artifact:** `replay-regression-harness-assessment.md` — analogous in
structure to vsdd's `dtu-assessment.md` but assessing the replay harness rather
than external service clones.

The gene-transfusion step (identifying reference implementations to translate) is
replaced by the `adapter-conformance-suite` assessment: for each engine, does the
reference mini-game conformance suite exist? Which conformance cases are covered?
This is the mechanism by which proven adapter patterns are carried across engine
implementations.
