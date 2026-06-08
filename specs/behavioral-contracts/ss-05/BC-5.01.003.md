---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/game-design-discipline.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.01.003: Accessibility Contract Satisfies CVAA / GAG / XAG Checklist

## Description

The ux-accessibility-designer agent produces an `accessibility-contract` artifact declaring
the game's accessibility feature matrix mapped to Game Accessibility Guidelines (GAG),
Xbox Accessibility Guidelines (XAG), and CVAA legal floor. The factory runs a checklist
validation: CVAA-required features are hard gates (legal floor); GAG/XAG items at a
declared tier are checked for presence. Features that require human/disabled-player
testing are flagged as human-gate items, not automated checks. The contract must declare
which tier (basic/intermediate/advanced) of GAG the game targets.

## Preconditions

1. An `accessibility-contract` artifact exists with:
   - `cvaa_required` array listing required CVAA features for in-game communications
     (if game has text/voice chat post-2018; else empty array is valid)
   - `gag_tier` field set to one of: "basic" | "intermediate" | "advanced"
   - `feature_matrix` array with entries `{feature_id, gag_id|xag_id, automated_check, present: bool}`
2. The accessibility feature schema is registered in the schema registry.
3. The game's `GameSpec.in_game_comms` field declares whether the game has qualifying
   in-game communications (determines CVAA applicability).

## Postconditions

1. Schema validation passes on the `accessibility-contract` (exit 0 on schema validator).
2. For every CVAA-required feature in `cvaa_required`, the `feature_matrix` contains a
   matching entry with `present: true`. Any CVAA feature marked `present: false` or
   missing from `feature_matrix` raises E-DES-005 (broken severity; legal floor).
3. For every GAG feature at or below the declared `gag_tier`, the `feature_matrix`
   contains a matching entry. Absent entries at or below tier raise E-DES-005 (broken).
4. Features with `automated_check: false` are logged as human-gate items in the
   `accessibility-validation-report`; they are NOT treated as passing or failing
   automatically — they require disabled-player playtest evidence.
5. An `accessibility-validation-report` is emitted with: tier declared, CVAA status
   (all present / missing list), GAG status per tier level, human-gate item list.
6. The design bundle may proceed when all automated checks pass. Human-gate items
   remain as open milestone-gate items until playtest evidence is provided.

## Invariants

1. CVAA-required features are always a hard gate. They cannot be downgraded to advisory.
   If `GameSpec.in_game_comms = true`, CVAA compliance is non-negotiable at this tier.
2. The `gag_tier` declaration is immutable once the design bundle is accepted. Downgrading
   the tier after acceptance requires a design revision workflow.
3. Features that require dynamic UI evaluation (e.g., colorblind simulation in running game)
   are always `automated_check: false`. The factory does not auto-pass dynamic accessibility
   features.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game has no in-game communications; CVAA not applicable | `cvaa_required: []` is valid; CVAA section in report shows "not applicable"; no CVAA gate |
| EC-002 | GAG feature listed at "advanced" tier but game declares "basic" tier | Feature is outside declared scope; not checked; report notes out-of-scope features as informational |
| EC-003 | `automated_check: true` for a feature that requires dynamic UI evaluation (e.g., high-contrast mode present in code) | Schema validation accepts it; but the feature is still tested by the automated check tooling; contrast ratio is measurable from static spec if declared as a param value |
| EC-004 | XAG-107 (operate via input mechanism of choice) declared `present: false` when `gag_tier: basic` | E-DES-005 raised: XAG-107 / GAG equivalent is basic-tier; must be present at basic tier |
| EC-005 | Feature matrix contains a feature_id not recognized in GAG or XAG registries | Warning in report (not block); custom features are allowed but are not machine-checkable against external standards |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| accessibility-contract, gag_tier=basic, all basic-tier features present=true, no in-game comms | All checks pass; report: CVAA N/A, GAG basic fully covered; human-gate list empty | happy-path |
| gag_tier=basic, XAG-107 equivalent feature missing from matrix | E-DES-005: feature 'input-remappability' at basic tier not present; report status=fail | error |
| in_game_comms=true, cvaa_required=['text-chat-accessible'], feature_matrix missing text-chat-accessible | E-DES-005: CVAA required feature 'text-chat-accessible' absent; legal floor violation | error |
| gag_tier=intermediate, 3 features have automated_check=false | Report: 3 human-gate items; automated checks all pass; design bundle proceeds; milestone gate notes 3 pending human items | edge-case |
| Schema-invalid: gag_tier='premium' (unknown value) | E-DES-001: gag_tier must be one of basic/intermediate/advanced | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.01.007 | For all contracts with in_game_comms=true, all cvaa_required features must be present=true for report to pass | proptest |
| VP-5.01.008 | Human-gate items in report are a subset of features with automated_check=false | proptest |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the accessibility-contract is a named design artifact in CAP-005's artifact taxonomy (RECONCILIATION §5.2, §6.1) and is part of the design discipline artifact bundle. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer), DI-006 (human-gated tasks surfaced not dropped) |
| Architecture Module | SS-04 — accessibility contract validator; GAG/XAG feature registry |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.01.001 — composes with (accessibility-contract is sub-artifact of design bundle)

## Architecture Anchors

- `architecture/SS-04-accessibility-checker.md`

## Story Anchor

S-TBD — Accessibility Contract Validation

## VP Anchors

- VP-5.01.007 — CVAA hard-gate completeness
- VP-5.01.008 — human-gate item accuracy
