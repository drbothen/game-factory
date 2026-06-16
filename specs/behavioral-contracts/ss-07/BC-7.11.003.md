---
document_type: behavioral-contract
level: L3
id: BC-7.11.003
version: "1.1"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1d
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-06
capability: CAP-007
priority: P0
lifecycle_status: active
introduced: v0.1.0-prd-rev-1d
modified:
  - date: 2026-06-16
    version: "1.1"
    author: product-owner
    finding: F56-01-propagation
    rid: R-07
    summary: "R-07 propagation residual (F56-01): SP4 caveat expressed as test-vector row (mirrors BC-7.11.002 v1.2 pattern) rather than inline postcondition text — D-SEC GREEN still requires secrets scan (SP4 / BC-1.15.003 / DI-013) to pass; dimension is NOT GREEN-by-inapplicability. Operative OFFLINE EXEMPTION postcondition kept minimal to avoid check (n) false positive."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.11.003: Server-Authority Invariant — Input Range, Rate, and Sequence Validation

## Description

The server must validate every incoming client input against three constraints:
(1) **range** — the input value is within the game-physically-possible range;
(2) **rate** — the client is not sending inputs at a rate impossible for a human
player (bot/speed-hack detection gate); (3) **sequence** — the input is valid in
the current game state (e.g., you cannot reload a weapon that is already full).
These three validation gates collectively close CWE-602 bypass paths that the
no-trust-client invariant (BC-7.11.002) alone does not address — they are the
gate BEFORE server re-evaluation, not a replacement for it.

## Preconditions

1. Online features declared in game profile.
2. `server-authority-spec.input_validation_rules[]` is populated with range, rate,
   and sequence constraints for every declared client input type.

## Postconditions

1. **PASS:** Server applies all three validation gates before any state mutation.
   Out-of-range, over-rate, and invalid-sequence inputs are rejected silently
   (no informational response to the client that reveals valid ranges).
2. **FAIL — range:** Client sends input with value outside declared range
   (e.g., movement speed > declared `max_movement_speed_units_per_tick`).
   Input is rejected; server state unchanged; incident logged.
   Error: `E-CONV-006` `CWE-602: input range violation, input type '<type>', value '<val>'`.
3. **FAIL — rate:** Client input rate exceeds `max_inputs_per_second` for this input
   type. Excess inputs are dropped; rate-violation event logged for anti-cheat review.
   Error: `E-CONV-006` `CWE-602: input rate exceeded, input type '<type>', rate '<rate>'`.
4. **FAIL — sequence:** Input is not valid in current state (state machine does not
   permit this input from current state). Input rejected; error logged.
   Error: `E-CONV-006` `CWE-602: invalid input sequence, input '<type>' from state '<state>'`.
5. **OFFLINE EXEMPTION:** No online features declared. The input range/rate/sequence sub-invariant is INAPPLICABLE.

## Invariants

1. Range limits are declared in `server-authority-spec`, not hard-coded in server logic.
   Adding or modifying a range constraint requires a spec update, not a hot-patch.
2. Rate limits are per-input-type, not global. A per-tick movement rate and a per-second
   fire-weapon rate are separate constraints.
3. Sequence validation uses the authoritative server-side FSM state, not client-reported
   state.
4. Validation rejection must be silent (no informative error response to the client).
   Revealing valid ranges enables attackers to craft inputs that just barely pass.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Player moves at 1.2× declared max speed (lag-spike-induced client prediction overshoot) | Server clamps movement to max speed before applying; no input rejection (graceful) |
| EC-002 | Bot sends 1,000 fire-weapon inputs/second when max is 10/second | 990 inputs dropped; rate-violation event logged; `E-CONV-006` rate |
| EC-003 | Client sends `reload` while weapon is full | Input rejected silently; `E-CONV-006` sequence |
| EC-004 | New game mechanic added; range constraint not declared in spec | Validation gate for that input type has no constraint = BLOCKED; spec must be updated before the mechanic ships |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Valid movement within range at normal rate | PASS: state mutation applied | happy-path |
| Movement `speed = max_speed * 5` (range violation) | Rejected or clamped; E-CONV-006 range | error |
| Fire-weapon at 500/sec (rate violation) | 490 inputs dropped; E-CONV-006 rate | error |
| Reload while weapon full (sequence violation) | Rejected silently; E-CONV-006 sequence | error |
| Offline single-player game | input range/rate/sequence sub-invariant INAPPLICABLE (no online features); D-SEC GREEN still requires secrets scan (SP4 / BC-1.15.003 / DI-013) to pass — dimension is NOT GREEN-by-inapplicability | inapplicable |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-201 | Every declared input type has a range, rate, and sequence constraint in server-authority-spec | Schema validation: assert no input type in `client_inputs[]` lacks all three constraint fields |
| VP-TBD-202 | Out-of-range input is rejected without state mutation | Property-based test: inject 10,000 out-of-range inputs; assert server state unchanged for each |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC specifies the input range/rate/sequence invariant of the `server-authority-invariant-suite` (CWE-602 spine) evaluated by D-SEC (BC-7.11.001). |
| L2 Domain Invariants | DI-012 |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — evaluated by D-SEC dimension
- BC-7.11.002 — precedes (no-trust-client is the fundamental invariant; range/rate/sequence extend it)
- BC-7.11.004 — composes with (replay-attack prevention is a temporal constraint on sequence validation)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-201, VP-TBD-202
