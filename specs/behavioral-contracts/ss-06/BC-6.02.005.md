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
subsystem: SS-05
capability: CAP-006
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

# BC-6.02.005: Playtest Delegation Declaration

## Description

Verifies that every `design-intent-contract` includes an explicit, non-empty
playtest delegation section declaring which design intent claims are NOT
machine-verifiable and are instead delegated to the Playtest Protocol (CAP-008).
This contract is a meta-contract: it does not verify game behavior but verifies
that the boundary between machine-verifiable and human-verifiable intent is
formally declared and complete. An absent or empty delegation section means the
design intent contract is structurally invalid — silent omission of the
human-judgment boundary is a factory defect (DI-007 enforcement).

## Preconditions

1. At least one `design-intent-contract` exists for the game.
2. The factory has a schema validation step for `design-intent-contract`
   documents that checks for required sections.
3. The playtest delegation section is a declared, named section in the
   `design-intent-contract` schema with at least one required field:
   `delegated_claims` (a list of natural-language claims delegated to
   playtest, with instrument assignment where possible).

## Postconditions

1. Every `design-intent-contract` in the game production has a non-empty
   `playtest_delegation` section containing at least one delegated claim.
2. Each delegated claim entry includes:
   - `claim`: the natural-language design intent assertion (e.g., "the
     movement controls feel responsive and satisfying")
   - `reason_not_machine_verifiable`: one sentence explaining why this
     cannot be a sim-BC (e.g., "subjective feel cannot be reduced to
     a numerical assertion without collapsing it to an invalid proxy")
   - `instrument` (optional but recommended): the playtest instrument
     that will assess this claim (GEQ/PENS/SUS/think-aloud/observation)
3. Schema validation of the `design-intent-contract` fails if
   `playtest_delegation` is missing or empty.
4. The existence and completeness of this section is verified in the docs
   convergence dimension (BC-7.09.001) as a CI gate.

## Invariants

1. No `design-intent-contract` may have an empty `playtest_delegation`
   section — the boundary between machine-verifiable and human-verifiable
   design intent must always be declared explicitly. This enforces DI-007
   (playtest satisfaction is always a human gate, never collapsed to an
   automated scalar).
2. The factory never auto-populates `playtest_delegation` with placeholder
   entries — every entry must be a substantive claim authored by the
   game-design agent.
3. Adding a machine-verifiable check for a previously-delegated claim is
   a valid improvement: the claim moves from `playtest_delegation` to a
   sim-BC. The `playtest_delegation` section shrinks; it never becomes
   empty unless all design intent is machine-verifiable (never true for
   any non-trivial game).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `design-intent-contract` missing `playtest_delegation` section entirely | Schema validation error at contract-validation gate; production pipeline halted |
| EC-002 | `playtest_delegation` section present but empty list | Schema validation error: at least one delegated claim required |
| EC-003 | A delegated claim's `reason_not_machine_verifiable` is a single word (too vague) | Schema warns; claim is accepted but flagged for design-adversary review |
| EC-004 | Same claim appears both as a sim-BC and in `playtest_delegation` | Advisory warning: claim is covered twice; not a hard error; design-adversary reviews overlap |
| EC-005 | Game design agent adds a "fun score" claim to machine-verifiable section | Factory defect: any automated fun-score claim is a DI-007 violation; schema-level check blocks it |
| EC-006 | `instrument` field not provided for any delegated claim | PASS with advisory: instrument assignment recommended for reproducible playtest; not a hard error |
| EC-007 | Design intent contract covers a single pure-mechanical system with no subjective elements | `playtest_delegation` must still contain at least one entry — even pure-mechanical systems benefit from "does this mechanic communicate its intent clearly to the player?" |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `design-intent-contract` with 3 machine-verifiable assertions + 2 delegated claims | Schema validation PASS; both delegated claims logged to playtest protocol | happy-path |
| `design-intent-contract` with no `playtest_delegation` section | Schema validation FAIL; "design-intent-contract missing playtest_delegation section" | error |
| `design-intent-contract` with `playtest_delegation: []` | Schema validation FAIL; "playtest_delegation requires at least one entry" | error |
| Delegated claim with `reason_not_machine_verifiable: "subjective feel"` | Schema PASS; claim accepted | edge-case (minimal valid) |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-017 | Schema validation rejects `design-intent-contract` with missing or empty `playtest_delegation` | kani (schema validation pure function; input = contract struct; output = pass/fail) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 |
| Capability Anchor Justification | CAP-006 ("Contract-Driven Simulation Quality Verification") per capabilities.md §CAP-006 — this BC enforces the explicit playtest delegation requirement named in CAP-006 as "explicit playtest delegation for non-verifiable claims" within design-intent contracts |
| L2 Domain Invariants | DI-007 (playtest satisfaction is always a human gate), DI-012 (every contract has a declared validation method) |
| Architecture Module | design-intent-verifier / schema-validator (SS-05) |
| Stories | S-TBD (assigned by story-writer) |

## Related BCs

- BC-6.02.001 — composes with (reachability is machine-verifiable; its complement is delegated here)
- BC-6.02.002 — composes with (solvability is machine-verifiable; feel of the solution journey is delegated here)
- BC-6.02.003 — composes with (balance bands are machine-verifiable; balance QUALITY is delegated here)
- BC-6.02.004 — composes with (no-softlock is machine-verifiable; pacing and frustration are delegated here)
- BC-7.05.001 — depended on by (playtest-satisfaction dim requires delegated claims to be tested; this BC ensures delegation is formal)
- BC-7.09.001 — depended on by (docs dim validates this section exists)

## Architecture Anchors

- `architecture/SS-05-design-intent-verifier.md` — design intent verification and schema validation module

## Story Anchor

S-TBD — Playtest Delegation Declaration

## VP Anchors

- VP-TBD-017 — schema validation rejects missing/empty playtest_delegation
