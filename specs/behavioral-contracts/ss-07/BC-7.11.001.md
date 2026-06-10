---
document_type: behavioral-contract
level: L3
version: "1.1"
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
security-invariants. This dimension is conditional — required for any game with
online/multiplayer features. When required, it is NOT degradable. The
`server-authority-invariant-suite` (CWE-602 spine) must pass: no-trust-client,
input range/rate/sequence validation, replay-attack prevention, authoritative
reconciliation, interest-management (anti-wallhack), economy conservation/
atomicity, and secure entitlement. Kernel anti-cheat is never autonomously
authored (DI-010). Anti-cheat integration for competitive-MP targets must be
verified.

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

1. **INAPPLICABLE (offline):** Game is fully offline. Dimension is GREEN by inapplicability.
2. **GREEN:** All `server-authority-invariant-suite` assertions pass in CI.
   `anti-cheat-integration-adapter` is wired (for competitive-MP).
   `moderation-pipeline-contract` is wired and CSAM→NCMEC path verified (if UGC/chat).
   No kernel anti-cheat driver authored by the factory (DI-010).
3. **BLOCKED:** Any server-authority invariant fails. Unchecked client input
   reaches game-authoritative state. Kernel AC driver detected in codebase.
   Riot Vanguard referenced as AC provider (DI-010: not licensable).
4. **NO DEGRADATION PATH (if online):** Online games must pass all security
   invariants. No tolerance for CWE-602 violations — they are not debatable
   quality choices, they are security defects.

## Invariants

1. Server-authority invariants are always CI-gated for online games. No exceptions.
2. Riot Vanguard is not licensable and must never appear as an AC provider
   declaration (DI-010). Its presence in any `anti-cheat-integration-adapter`
   config is a BLOCKED state.
3. Kernel anti-cheat code autonomously authored by any factory agent is a DI-010
   violation and triggers immediate BLOCKED state.
4. CSAM→NCMEC path wiring is required for any game with user-generated content or
   unmoderated chat (18 U.S.C. §2258A actual-knowledge trigger).

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
| Offline single-player game | security-invariants = GREEN (inapplicable) | happy-path |
| Online game; all CWE-602 invariants PASS; EAC/EOS wired | security-invariants = GREEN | happy-path |
| Online game; client input bypasses server validation | security-invariants = BLOCKED; "CWE-602: client input not validated server-side" | error |
| Competitive-MP; Riot Vanguard declared as AC provider | security-invariants = BLOCKED; DI-010 violation | error |

## Verification Properties

| VP | Property | Proof Method |
|----|----------|-------------|
| VP-TBD-030 | Client input that bypasses server validation always results in BLOCKED dimension | kani (server-authority invariant assertion: any server state change from unvalidated client input → BLOCKED) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 |
| Capability Anchor Justification | CAP-007 ("11-Dimension Convergence Tracking") per capabilities.md §CAP-007 — this BC defines the evaluation rule for convergence dimension #11 (security-invariants) |
| L2 Domain Invariants | DI-010 (kernel anti-cheat never autonomously authored), DI-012 |
| Architecture Module | convergence-tracker / security-gate (SS-06) |
| Stories | S-TBD |

## Related BCs

- BC-7.12.001 — depended on by (convergence loop reads this dimension)

## Architecture Anchors

- `architecture/SS-06-convergence-tracker.md`

## Story Anchor

S-TBD — Security-Invariants Convergence Dimension
