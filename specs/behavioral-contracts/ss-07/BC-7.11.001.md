---
document_type: behavioral-contract
level: L3
version: "1.2"
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
priority: P0
lifecycle_status: active
introduced: v0.1.0
modified:
  - version: "1.2"
    date: 2026-06-10
    author: product-owner
    change: "F53-01 (Pass-53): Add D-SEC sub-predicate 4 (never-emit-secrets / BC-1.15.003 / DI-013). PC1 narrowed — offline games are inapplicable ONLY for sub-predicates 1-3; secrets lint (SP4) applies unconditionally. PC2 GREEN extended with SP4 condition. Invariant 5 added: secrets-gate failure is fail-closed regardless of online/offline. BC-1.15.003 added to Related BCs. DI-013 added to L2 Domain Invariants traceability. Fixes fail-open security defect where offline single-player games bypassed secrets gate."
  - version: "1.1"
    date: 2026-06-09
    author: product-owner
    change: "O45-01 (Pass-45): Reconcile D-SEC trigger vocabulary with methodology-layer.md v1.15 and BC-13.02.006/BC-13.03.005. Precondition 3 updated from 'competitive-multiplayer' to genre-profile.esports_enabled: true. Precondition 4 updated from 'UGC/chat present' to genre-profile.modding_enabled: true OR game-metadata-spec.user_to_user_communication: true. EC-002 and EC-007 updated to match reconciled signals."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-7.11.001: Security-Invariants Convergence Dimension Evaluation

## Description

Defines the evaluation criteria for convergence dimension #11:
security-invariants. This dimension evaluates FOUR sub-predicates: (1) the
`server-authority-invariant-suite` (CWE-602 spine) for online games; (2)
anti-cheat-integration-adapter conformance for esports/competitive-MP; (3)
moderation-pipeline-contract with CSAM→NCMEC wiring for UGC/chat; and (4)
the never-emit-secrets output-bundle lint gate (BC-1.15.003 / DI-013) which
applies UNCONDITIONALLY to ALL games including fully offline ones. Sub-predicates
1-3 are conditional on online/multiplayer features; sub-predicate 4 is not
degradable and applies regardless of deployment target. Kernel anti-cheat is
never autonomously authored (DI-010).

## Preconditions

1. The game's online feature profile is declared: single-player (dimension
   inapplicable), online-leaderboard, cooperative-online, or competitive-multiplayer.
2. If online features are present: `server-authority-invariant-suite` exists
   declaring all CWE-602 invariants.
3. If `genre-profile.esports_enabled: true` (the schema-valid esports/competitive-multiplayer
   lane signal per BC-13.01.001; the online-feature-profile value `competitive-multiplayer`
   is the same lane described in enum terms):
   `anti-cheat-integration-adapter` exists declaring the provider (EAC/EOS default;
   BattlEye commercial; Riot Vanguard NOT allowed).
4. If `genre-profile.modding_enabled: true` (UGC lane active, schema-valid per
   BC-13.01.001) OR `game-metadata-spec.user_to_user_communication: true` (chat
   signal, canonical IARC/PEGI field): `moderation-pipeline-contract` exists.
5. Security assertion tests for the server-authority invariants are runnable
   headless (server-side logic only; no engine required).

## Postconditions

1. **PARTIALLY-INAPPLICABLE (offline):** Game is fully offline. Sub-predicates
   (1) server-authority-invariant-suite, (2) anti-cheat-integration-adapter, and
   (3) moderation-pipeline-contract are inapplicable (no online features; no
   `esports_enabled`; no UGC/chat). Sub-predicate (4) never-emit-secrets lint
   (BC-1.15.003 / DI-013) is NOT inapplicable — it STILL applies and STILL gates.
   An offline game is D-SEC GREEN only when the secrets scan passes (exit 0).
   If the secrets scan fails, the dimension is BLOCKED even for fully offline games.
   There is NO blanket GREEN-by-inapplicability for this dimension.
2. **GREEN:** All applicable sub-predicates pass:
   (SP1) All `server-authority-invariant-suite` assertions pass in CI (for online games).
   (SP2) `anti-cheat-integration-adapter` is wired (for games with `genre-profile.esports_enabled: true`).
   (SP3) `moderation-pipeline-contract` is wired and CSAM→NCMEC path verified (for UGC/chat games).
   (SP4) Output bundle passes the never-emit-secrets lint gate (BC-1.15.003 / DI-013) — ALL games.
   No kernel anti-cheat driver authored by the factory (DI-010).
3. **BLOCKED:** Any of the following: Any server-authority invariant fails (online games).
   Unchecked client input reaches game-authoritative state. Kernel AC driver detected
   in codebase. Riot Vanguard referenced as AC provider (DI-010: not licensable).
   Output bundle fails the never-emit-secrets lint gate (DI-013 violation) — for any
   game regardless of online/offline status. Fail-closed: secrets-scan failure ⇒
   D-SEC BLOCKED with no exception.
4. **NO DEGRADATION PATH (if online):** Online games must pass all security
   invariants. No tolerance for CWE-602 violations — they are not debatable
   quality choices, they are security defects.
5. **NO DEGRADATION PATH (secrets, all games):** Sub-predicate (4) is not
   degradable for any game. Factory output bundles must never contain secrets
   in any deployment target (methodology-layer.md §D-SEC lines 1063-1065).

## Invariants

1. Server-authority invariants are always CI-gated for online games. No exceptions.
2. Riot Vanguard is not licensable and must never appear as an AC provider
   declaration (DI-010). Its presence in any `anti-cheat-integration-adapter`
   config is a BLOCKED state.
3. Kernel anti-cheat code autonomously authored by any factory agent is a DI-010
   violation and triggers immediate BLOCKED state.
4. CSAM→NCMEC path wiring is required for any game with user-generated content or
   unmoderated chat (18 U.S.C. §2258A actual-knowledge trigger).
5. The never-emit-secrets output-bundle lint gate (BC-1.15.003 / DI-013) is
   fail-closed and unconditional. A secrets-scan failure causes D-SEC BLOCKED
   regardless of whether the game is online or fully offline. No deployment target,
   game genre, or online-feature-profile value exempts a game from sub-predicate (4).
   This invariant cannot be waived by any agent, flag, or config (DI-013).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Game has online leaderboard only (no real-time multiplayer) | Security invariants scoped to leaderboard: no-trust-client for score submission; replay-attack prevention for score entries; no full multiplayer suite required |
| EC-002 | Game with `genre-profile.esports_enabled: true` (competitive-multiplayer/esports lane) with EAC/EOS declared | AC integration verified; EAC/EOS = allowed; PASS for this check |
| EC-003 | Client sends out-of-range input to the server | Server-authority invariant: input rejected without state mutation; assertion test verifies server rejects |
| EC-004 | Economy atomicity violated — partial transaction committed during server crash | BLOCKED; economy conservation/atomicity invariant requires atomic transactions; partial commits are a security defect |
| EC-005 | Moderation pipeline present but CSAM→NCMEC wiring not implemented | BLOCKED; CSAM reporting path is a legal requirement (18 U.S.C. §2258A) |
| EC-006 | Factory agent authors a kernel-mode driver claiming it is "anti-tamper not anti-cheat" | BLOCKED; kernel-mode code is kernel-mode code regardless of framing; DI-010 violation |
| EC-007 | Interest-management (anti-wallhack) not implemented for a game with `genre-profile.esports_enabled: true` (competitive-multiplayer/esports lane) | BLOCKED; interest-management is a declared CWE-602-spine invariant for the esports/competitive-multiplayer lane |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Offline single-player game; secrets scan exits 0 | security-invariants = GREEN (SP1-3 inapplicable; SP4 passed) | happy-path |
| Offline single-player game; secrets scan exits 1 (API key found in output bundle) | security-invariants = BLOCKED; DI-013 violation; secrets gate fail-closed | error |
| Online game; all CWE-602 invariants PASS; EAC/EOS wired; secrets scan exits 0 | security-invariants = GREEN | happy-path |
| Online game; client input bypasses server validation | security-invariants = BLOCKED; "CWE-602: client input not validated server-side" | error |
| Competitive-MP; Riot Vanguard declared as AC provider | security-invariants = BLOCKED; DI-010 violation | error |
| Any game (online or offline); output bundle contains high-entropy credential | security-invariants = BLOCKED; DI-013 violation regardless of online/offline status | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-030 | Client input that bypasses server validation always results in BLOCKED dimension | kani (server-authority invariant assertion: any server state change from unvalidated client input → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #11 (security-invariants) |
| L2 Domain Invariants | DI-010 (kernel anti-cheat never autonomously authored), DI-012, DI-013 (factory output bundle never contains secret material — enforced via BC-1.15.003 as D-SEC sub-predicate 4; unconditional across all games) |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.12.001 — depended on by (convergence loop reads this dimension)
- BC-1.15.003 — composes with (D-SEC sub-predicate 4: never-emit-secrets output-bundle lint gate; BC-1.15.003 is the producer; this BC is the evaluator that consumes its pass/fail signal unconditionally for all games)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Security-Invariants Convergence Dimension
