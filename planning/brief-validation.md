---
document_type: brief-validation
level: ops
version: "2.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00
phase: 1a
inputs: [product-brief.md]
traces_to: .factory/specs/product-brief.md
validates_brief_version: "2.0"
---

# Brief Validation Report — game-factory (validates brief v2.0)

Fresh-context validation of `/Users/jmagady/Dev/game-factory/.factory/specs/product-brief.md`
(**v2.0, AAA scope**) against the `vsdd-factory:validate-brief` rubric. This report **supersedes
the prior v1 report** (which validated the earlier engine-agnostic-CI framing with a different
section structure and word profile).

**Context for judgment (applied throughout):**
- This is an L1 brief that **intentionally stays high-level** and points to the methodology charter
  `planning/research/aaa/AAA-RECONCILIATION.md` (v2.0) for detail. Absence of detailed requirements
  is **by design** (the VSDD pipeline crystallizes downstream) and is **NOT** flagged as a gap.
- The product is intrinsically about engine adapters, asset-gen tools, a JSON-RPC protocol, and game
  disciplines. Engine names (Bevy/Unity/Godot), tool/standard names, "JSON-RPC 2.0", "OpenXR",
  "glTF/USD", determinism tiers, and regulatory refs (EU AI Act Art.50, SAG-AFTRA, PEGI) are
  **capability/constraint-relevant**, not implementation leakage. Each is judged descriptive/constraint
  (acceptable) vs prescriptive impl-choice (flagged).
- Locked product decisions (NOT flaws): pure-maximal lights-out asset generation (no mandatory
  human-in-loop creative finishing); all-genre core + deterministic-sim pilot; the `human-gated` tier
  for external third-party acts; four adapter seams + canon-KB.
- "Overflow Context" is **exempt** from the core word/bloat limit.

## Section Assessment

| Section | Status | Finding |
|---------|--------|---------|
| What Is This? (L24–30) | PASS | 67 words. Crisp definition: "Dark Factory for AAA game development," lights-out, multi-agent, all-genre, AAA quality. Load-bearing defining property (engine/tool/platform-agnostic via four seams + canon-KB) stated. Points to authoritative charter. Non-vague. |
| Who Is It For? (L32–38) | PASS | 58 words. Three specific, requirement-generating personas, each with a concrete pain point (siloed per-engine CI; want adversarially-reviewed pipelines but lack team; black-box pixel/OCR tools). |
| Scope — In Scope (L42–50) | PASS | Seven bounded capabilities (orchestration spine, methodology layer, engine-adapter protocol+conformance, asset-gen, four seams, canon-KB, all-genre core+pilot). Capabilities not features/stories. Slightly above the 3–7 guideline ceiling but each is a distinct load-bearing seam; acceptable. |
| Scope — Out of Scope / Deferred (L52–62) | PASS | Three-bucket structure (Deferred-Tier-3 / OUT-never / Human-Gated). Each item carries rationale. Human-gated steps explicitly distinguished from "dropped" and from "creative finishing" — resolves the obvious contradiction risk against pure-maximal. |
| Success Criteria (L64–73) | PASS | 123 words. Six outcomes, all numeric/binary (≥3 adapters; runs on ≥2 engines; 100% T1 bitwise regression detection; ZERO core changes on onboarding; 100% provenance w/ 0 missing `disclosure_class`; pilot ships end-to-end). Measurable. |
| Constraints & Integration Points (L75–84) | PASS | 151 words. Eight actionable constraints, each with real cost-of-not-knowing (built-by-vsdd + Phase-0 extraction; pure-maximal IP/legal handling; monetization-ethics envelope; EU AI Act Art.50 deadline+C2PA; ToS-excluded tools; determinism tiers; capture-needs-GPU myth-buster; SAG-AFTRA consent flow). |
| Overflow Context (L86–139) | PASS (exempt) | 412 words. Carries charter pointer, lights-out principles, vsdd reuse/replace split, four-seam thesis, three-tier scope model, pilot bias, founding-pair rationale, evidence base. Correctly placed and exempt from core word/bloat limits. |

**Status legend:** PASS = complete & well-specified · FAIL = missing/incomplete · WEAK = lacks
specificity/testable criteria · BLOATED = exceeds scope, split/condense.

## Check-by-Check Results

### 1. Structure Check — PASS
All required sections present with substantive content: What Is This? (≥2 sentences), Who Is It For?
(3 personas w/ pain), In Scope (7, within spirit of 3–7), Out of Scope (multiple exclusions),
Success Criteria (6 measurable), Constraints (8). Frontmatter complete (document_type, level, version,
status, producer, inputs, traces_to present).

### 2. Quality Check — PASS
- **Specificity:** No vague filler ("various users," "performant," "improve things"). Claims are
  concrete and engine/standard-anchored.
- **Measurability:** All six success criteria carry numeric or binary targets.
- **Non-contradiction:** The highest-risk pair — *pure-maximal lights-out asset gen* (L47, "NO mandatory
  human creative finishing") vs *human-gated external steps* (L59–62) — is **explicitly reconciled**:
  human-gated = external third-party acts ONLY (cert sign-off, store publish, SAG-AFTRA signature),
  never creative quality (L78, L113). Similarly, "esports/anti-cheat" appears under OUT-never (L57),
  Human-Gated ops (L62), AND Tier-2 opt-in (Overflow L121) — reconciled by the OUT line scoping it to
  *running live esports/events* and *kernel anti-cheat authoring* specifically, distinct from a genre-gated
  competitive lane. These are clarifying distinctions, not contradictions.
- **Persona clarity:** Personas are requirement-generating (multi-studio platform teams; indie/small-studio
  tech leads; solo/AI-assisted developers), not generic "developers."
- **Constraint actionability:** Every constraint would cause implementation failure or compliance exposure
  if missed (e.g., EU AI Act Art.50 2026-08-02 deadline L80; "capture requires GPU" myth-buster L83).

### 3. Bloat Check — PASS
- **Core word count (excl. Overflow):** ~605 words of section content (≈624 counting headings/blanks).
  Largest single core section = Scope at 206 words. Every core section is **well under** the 500-word
  ideal ceiling and far under the 800-word PRD-creep alarm. No single core section is bloated.
- **Narrative padding:** Business justification / competitive thesis / scope-tier tables / founding-pair
  rationale correctly confined to Overflow Context. Core sections stay declarative.
- **Requirements leakage:** No FR-XXX numbered requirements, no acceptance criteria, no ADR-style
  decisions inlined in core. Decision/charter references (0001/0002/0003, AAA-RECONCILIATION) are pointers.
- **Token estimate:** see Bloat Score below.

### 4. Implementation-Leakage Check — PASS (with INFO notes)
Judged case by case per the supplied context. Capability/constraint-relevant naming is acceptable;
prescriptive impl-choice is flagged.
- L46 "JSON-RPC 2.0" + "Bevy + Unity founding pair; Godot third" (In-Scope) — **capability-defining**.
  The neutral protocol and the founding adapter pair ARE the anti-lock-in product. Acceptable.
- L48 "engine / asset / distribution (`human-gated`) / XR" seams — **capability-defining** (the four
  seams are the product's structure). Acceptable.
- L68 engine names in Success Criteria (≥3: Bevy, Unity, Godot) — **capability-defining** (the metric
  literally counts conformant adapters). Acceptable.
- L82 "T1 Bevy+Rapier (bitwise), T2 Unity PhysX (pinned-runner), T3 Godot (tolerance-window)"
  (Constraints) — **INFO (F1).** Determinism tiers are a success criterion and load-bearing, and this
  sits in Constraints (warning tier) with cost-of-not-knowing. But naming **Rapier** and **PhysX** as the
  determinism backends edges toward prescriptive. Acceptable at brief stage; flag for the architect to
  confirm these are hard constraints (sole viable bitwise/pinned paths) vs implementation choices.
- L80 "C2PA marks," "`ai-disclosure-manifest`" / L84 SAG-AFTRA flow — **constraint/compliance-relevant**
  (regulatory + contractual). Acceptable.
- L81 "Suno/Udio (litigation), Riot Vanguard, kernel AC drivers" — **constraint-relevant** (ToS/policy
  exclusions with rationale). Acceptable.
No prescriptive web/framework/cloud tech (React, Postgres, AWS, Docker, etc.) appears anywhere.

### 5. Information-Density Check — PASS (<5 instances)
Prose is dense and declarative. Heavy use of em-dashes, parentheticals, and inline-code identifiers is
**compression, not padding**. No conversational filler, no redundant-pair phrases, no wordy multi-word
substitutions ("in order to," "due to the fact that"). No weakening hedges; voice is assertive
("load-bearing," "is a factory defect," "is false"). Instance count well under the 5-instance threshold.

### 6. Completeness Check — PASS
Not a placeholder. ~1,037 body words (≫150-word floor). No section is TBD/TODO-only. The lone
unresolved token is `input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"` (L18),
a deliberate frontmatter placeholder resolved at pipeline ingest — not a content gap. `traces_to: ""`
(L19) is empty, expected for an L1 entry artifact (nothing upstream to trace to).

### Market-Intelligence Cross-Check — PASS
Audience/pain claims are grounded in the brief's own research base (AAA-RECONCILIATION, per-engine
capability reports, prior-art survey). Risks are surfaced rather than hidden: IP/legal (pure-maximal),
Unity licensing implied via tiers, Bevy pre-1.0 churn (Overflow founding-pair rationale), ToS-excluded
tools, EU AI Act exposure, SAG-AFTRA consent. No unconfirmed pain asserted as fact.

## Bloat Score

**Core words (excl. Overflow): ~605–624 / 500 ideal** — slightly over the 500 ideal, **well under** the
800 flag threshold → **OK.**
**Total body tokens: ~1,379–1,444 / ~1,500 budget** — **OK** (headroom remains).
- Core sections only: ~605–624 words ≈ ~805–830 tokens.
- Overflow Context (exempt): 412 words ≈ ~548 tokens.
- Frontmatter adds the remainder toward the PO-reported ~1,444 total.
- Independent verification confirms the PO's reported figures (core ≈629 words / ~838 tokens; total
  ≈1,444 tokens) are accurate to within rounding.

## Itemized Findings

| ID | Severity | Line | Finding | Suggested Fix |
|----|----------|------|---------|---------------|
| F1 | Info (non-blocking) | L82 | Determinism-tier constraint names specific physics backends — Rapier (Bevy, bitwise) and PhysX (Unity, pinned-runner). Mildly prescriptive for an L1 brief. | Acceptable at brief stage. Have the architect confirm Rapier/PhysX are hard constraints (sole viable paths for the stated tier) vs implementation choices; if the latter, soften to "a deterministic fixed-step physics backend (e.g., Rapier)." Non-blocking. |
| F2 | Info (non-blocking) | L18 | `input-hash` is an unresolved placeholder `[compute via bin/compute-input-hash...]`. | None needed now — resolved at pipeline ingest by design. Listed for traceability. |
| F3 | Info (non-blocking) | L18–84 | Core word count (~605–624) is marginally above the 500-word *ideal* (under the 800 flag). Driven by 7 In-Scope items + 8 Constraints + 6 success rows. | Optional only. If trimming is ever desired, the XR seam line (L48) and the ToS-excluded-tools constraint (L81) could move to Overflow without losing core meaning. Not required; total token budget is healthy. |

No CRITICAL, FAIL, WEAK, or BLOATED findings. No actionable findings block the human approval gate.

## Overall: VALID
