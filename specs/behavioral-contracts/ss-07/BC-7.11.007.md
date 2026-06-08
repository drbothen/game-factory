---
document_type: behavioral-contract
level: L3
id: BC-7.11.007
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
  - version: "1.1"
    date: 2026-06-08
    reason: "O8-02: clarified DI-012 is the meta-invariant anchor for economy-atomicity/CWE-602; no dedicated DI-NNN exists"
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.11.007: Server-Authority Invariant — Economy Atomicity and Conservation

## Description

All game-economy transactions (currency transfers, item grants, purchases, crafting
operations, loot-drop credits) must be executed atomically on the server: either the
entire transaction commits or the entire transaction rolls back. Partial commits (e.g.,
currency deducted but items not granted, or items granted but currency not deducted)
are both a game-integrity defect and a security defect (exploitable for item duplication).
Additionally, the economy conservation invariant (BC-6.01.001) must hold for server-side
economy mutations: no value is created or destroyed outside declared faucet/sink mechanics.

This BC extends BC-6.01.001 (economy conservation) with a security frame: atomicity is
the SECURITY requirement; conservation is the GAME-DESIGN requirement. Both must hold.

## Preconditions

1. Game declares any form of in-game economy (currency, items, crafting, loot).
2. `server-authority-spec.economy_transactions[]` declares all transaction types and
   their commit/rollback semantics.
3. The server economy module runs headless and is testable with injected transaction events.

## Postconditions

1. **PASS (atomicity):** Every economy transaction either fully commits all mutations
   or rolls back all mutations on any failure. There is no observable intermediate state.
2. **PASS (conservation):** The sum of all currency and item quantities in the server's
   authoritative economy state satisfies the conservation invariant (sum of inputs from
   declared faucets = sum of outputs to declared sinks over any closed transaction set).
3. **FAIL (partial commit):** A transaction failure leaves economy state in a partially-
   mutated form (e.g., player's currency decremented but item not granted, or item granted
   without currency decrement — the "dupe exploit" case). Error: `E-CONV-006`
   `CWE-602: economy partial-commit — currency and item state inconsistent after transaction failure`.
4. **FAIL (conservation violated):** Economy conservation invariant violated by a
   server-side mutation outside declared faucets/sinks. This is the server-side
   equivalent of BC-6.01.001. Error: `E-SIM-001` (conservation invariant).
5. **OFFLINE EXEMPTION:** No online economy mutations. INAPPLICABLE for this BC
   (BC-6.01.001 covers offline economy conservation separately).

## Invariants

1. Economy transactions must use database-style atomic commit semantics (2-phase commit
   or equivalent rollback mechanism).
2. Economy state mutations are never committed partially — the transaction log must
   record the full mutation set before any mutation is applied.
3. The conservation check is evaluated per-transaction by the server, not only in
   periodic batch audits.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Server crashes mid-transaction (currency deducted, item grant not yet applied) | On server restart, transaction log used to roll back partial commit; player currency restored |
| EC-002 | Network timeout during purchase; client retries | Replay-prevention (BC-7.11.004) prevents double-processing; idempotency key or nonce ensures single credit |
| EC-003 | Crafting operation: 3 items → 1 item; item destruction + item creation in one transaction | PASS: atomic transaction; conservation satisfied (3-in, 1-out per declared recipe) |
| EC-004 | Loot box opened; server applies currency grant but loot-box item consumption not committed | FAIL: E-CONV-006 partial-commit; item should be consumed in same transaction as loot grant |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Purchase: currency -= 100, item += 1; both committed | PASS: economy state consistent | happy-path |
| Purchase: currency -= 100, item grant fails; transaction rolls back | PASS: currency restored; no item granted; E-CONV-006 logged for diagnostics | rollback-pass |
| Currency -= 100, item += 1 committed, but separately item += 1 committed again (dupe exploit) | FAIL: E-CONV-006 partial commit; conservation violated | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-206 | Economy state is consistent (no partial commits) after any server crash point during a transaction | Fault injection test: interrupt transaction at every commit phase; assert state is consistent on recovery |
| VP-TBD-207 | Economy conservation holds across any sequence of N transactions | Property-based test: run N random economy transactions; assert sum of currency + item quantities equals initial + declared faucet outputs - declared sink inputs |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — specifies the economy atomicity and conservation invariants of the `server-authority-invariant-suite` for D-SEC evaluation. |
| L2 Domain Invariants | DI-012 (Every ContractArtifact Has a Declared Validation Method). Note: the economy atomicity / CWE-602 server-authority rule has no dedicated DI-NNN; DI-012 is cited as the applicable meta-invariant. |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.11.001 — evaluated by D-SEC dimension
- BC-6.01.001 — composes with (economy conservation invariant for offline/sim; this BC is the online/security-frame version)
- BC-7.11.004 — composes with (replay-attack prevention ensures each transaction is processed once)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC

## Story Anchor

S-TBD — Server-Authority Invariant Suite (D-SEC)

## VP Anchors

- VP-TBD-206, VP-TBD-207
