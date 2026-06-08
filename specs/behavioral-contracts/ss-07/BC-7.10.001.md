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
subsystem: SS-TBD
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

# BC-7.10.001: Monetization-Ethics Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #10:
monetization-ethics. This dimension is conditional — it is only required when the
game has monetization features. When required, it is NOT degradable: the
`monetization-ethics-contract` must be present, schema-valid, and adversarially
reviewed. Unconstrained LTV optimization without a declared ethics contract, and
autonomous engagement optimization as a default, are both factory defects (DI-005).
PEGI/ESRB rating descriptors must be consistent with declared mechanics.

## Preconditions

1. The game's `business-model-spec` declares whether monetization is active.
   If `monetization_model = none` or `monetization_model = premium_no_iap`, this
   dimension is inapplicable and vacuously GREEN.
2. If monetization is active: `monetization-ethics-contract` exists with:
   - declared allowed mechanics
   - declared forbidden patterns (with explicit enumeration)
   - LTV optimization bounds (what is the declared optimization objective and
     its constraints)
   - gacha pity counter and odds disclosure if gacha mechanics are present
3. The adversarial review pipeline is operational for contract review.

## Postconditions

1. **INAPPLICABLE (non-monetized):** `business-model-spec` declares no
   monetization. Dimension is GREEN by inapplicability.
2. **GREEN:** `monetization-ethics-contract` is present, schema-valid, and has
   an adversarial review evidence record in the current cycle. PEGI/ESRB
   content descriptors are consistent with declared mechanics. No declared
   forbidden patterns are implemented in the game code.
3. **BLOCKED:** Any of the following:
   - Monetization is active but `monetization-ethics-contract` is absent.
   - `monetization-ethics-contract` is present but adversarial review not yet
     completed in the current cycle.
   - An implemented mechanic is a declared forbidden pattern (adversary finding).
   - Unconstrained LTV optimization detected in the game's implemented behavior.
   - PEGI/ESRB descriptors inconsistent with declared mechanics.
4. **NO DEGRADATION PATH:** If monetization is present, this dimension must be
   GREEN. There is no fallback. (DI-005: unconstrained LTV maximize = factory defect.)

## Invariants

1. The adversarial review of `monetization-ethics-contract` must use
   information-asymmetric fresh context — the reviewer must not have authored
   the contract.
2. EOMM-style engagement-as-autonomous-objective is always a declared forbidden
   pattern (encoded in DI-005). Any `monetization-ethics-contract` that declares
   engagement optimization without explicit ethical constraints is rejected.
3. The `gacha-spec` (if present) must declare pity counter and odds; ESRB Apr 2020
   and Apple/Google odds disclosure requirements are machine-checkable.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game transitions from premium to F2P mid-production | `monetization-ethics-contract` must be created immediately; dimension transitions from GREEN (inapplicable) to BLOCKED until contract is present and reviewed |
| EC-002 | Gacha mechanic implemented but `gacha-spec` missing | BLOCKED; gacha implementation without declared spec = forbidden pattern |
| EC-003 | Adversarial review found one finding in `monetization-ethics-contract` | BLOCKED until finding is resolved and re-review is clean; 3-clean-streak policy applies |
| EC-004 | PEGI descriptor says "no paid random items" but implemented mechanic is a loot box | BLOCKED; descriptor inconsistency; PEGI 16 minimum triggered (Jun 2026 rules) |
| EC-005 | `monetization-ethics-contract` contains constrained LTV optimization with declared bounds | GREEN for this check; constrained optimization is allowed |
| EC-006 | Ad monetization with no COPPA consent per ad SDK | BLOCKED for provenance/legal dimension (BC-7.08.001); this dimension also flags it as a forbidden-adjacent pattern |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Premium game, no monetization | monetization-ethics = GREEN (inapplicable) | happy-path |
| F2P game with ethics-contract, clean adversarial review | monetization-ethics = GREEN | happy-path |
| F2P game, no ethics-contract | monetization-ethics = BLOCKED; "monetization-ethics-contract required" | error |
| Ethics-contract present; adversarial review found dark-pattern finding | monetization-ethics = BLOCKED until finding resolved | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-029 | Dimension is BLOCKED if monetization active and ethics-contract absent | kani (state: monetized=true, contract=null → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #10 (monetization-ethics) |
| L2 Domain Invariants | DI-005 (monetization optimization is always constrained), DI-012 |
| Architecture Module | convergence-tracker / monetization-ethics-gate (SS-TBD) |
| Stories | S-TBD |

## Related BCs

- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-TBD-convergence-tracker.md`

## Story Anchor

S-TBD — Monetization-Ethics Convergence Dimension
