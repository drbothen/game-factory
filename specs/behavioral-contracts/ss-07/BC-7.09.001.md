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
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
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

# BC-7.09.001: Docs Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #9: docs. This
dimension verifies that all agent-produced artifacts have required frontmatter
fields (document_type, level, traces_to, input-hash), that design-intent
contracts include explicit `playtest_delegation` sections (BC-6.02.005), that
the `monetization-ethics-contract` adversarial review evidence is present (if
monetization is active), and that the `ai-disclosure-manifest` generation
evidence is logged. This dimension is a CI gate on documentation completeness;
it degrades to advisory for supplementary-only docs.

## Preconditions

1. A schema validator for factory artifact frontmatter is operational and can
   scan `.factory/specs/**/*.md` for required fields.
2. The BC-6.02.005 playtest delegation validator is operational.
3. If monetization is active: the adversarial review log for
   `monetization-ethics-contract` is accessible.

## Postconditions

1. **GREEN:** All factory artifacts have required frontmatter. All active
   `design-intent-contracts` have non-empty `playtest_delegation` sections.
   If monetization is present: `monetization-ethics-contract` adversarial review
   evidence is present and dated within the current cycle. Red Gate governance
   events (bypasses) are present in telemetry log.
2. **DEGRADED (supplementary):** Core artifact frontmatter is complete;
   supplementary documentation (README, architecture commentary) has gaps.
   Advisory only — does not block dimension.
3. **BLOCKED:** Required frontmatter fields missing on any primary artifact.
   Any active `design-intent-contract` without `playtest_delegation`. Missing
   adversarial review evidence for `monetization-ethics-contract` (if monetized).

## Invariants

1. The docs dimension is a structural completeness check, not a content quality
   check. Content quality is the domain of the adversarial review.
2. Missing frontmatter on a PRIMARY artifact is always BLOCKED. Missing
   frontmatter on a supplementary artifact is advisory.
3. `monetization-ethics-contract` adversarial review evidence must be from the
   current production cycle, not a stale prior cycle.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Artifact has all required fields but `input-hash` is the placeholder "[compute...]" | BLOCKED; input-hash must be computed, not left as placeholder |
| EC-002 | Non-monetized game; no `monetization-ethics-contract` | Docs dimension GREEN for this check (conditional on monetization active) |
| EC-003 | `playtest_delegation` has one entry with placeholder text | Advisory warning flagged; not hard BLOCKED (schema allows any non-empty string); adversarial review may flag |
| EC-004 | 50 artifacts, one has missing `traces_to` | BLOCKED; single frontmatter gap blocks the dimension |
| EC-005 | Adversarial review evidence for `monetization-ethics-contract` is 3 cycles old | BLOCKED (stale); adversarial review must be re-run in the current cycle |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| All artifacts frontmatter-valid; all design-intent-contracts have playtest_delegation | docs = GREEN | happy-path |
| One artifact missing `traces_to` | docs = BLOCKED; artifact ID listed | error |
| Monetized game; no adversarial review evidence for monetization-ethics-contract | docs = BLOCKED | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-028 | Schema validator correctly identifies missing required frontmatter fields | proptest (generate artifacts with partial frontmatter; assert validator rejects) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #9 (docs) |
| L2 Domain Invariants | DI-012 |
| Architecture Module | convergence-tracker / docs-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-6.02.005 — depends on (playtest delegation declaration is a docs dim check)
- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Docs Convergence Dimension
