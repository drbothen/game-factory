---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/differentiators.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
  - .factory/planning/research/aaa/esports-competitive-integrity.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-02
capability: CAP-003
priority: P0
lifecycle_status: active
introduced: v0.1.0
modified:
  - version: "1.1"
    date: 2026-06-09
    author: product-owner
    reason: "F46-01: remove non-schema `competitive_multiplayer_enabled: true` OR-branch from Precondition 2. The genre-profile schema defines no separate `competitive_multiplayer_enabled` field; `genre-profile.esports_enabled: true` is the sole schema-valid competitive/esports lane signal (per BC-13.01.001 and BC-13.02.006 F44-01 resolution). The OR-branch was redundant and referenced a non-existent schema field. Gate now reads solely on `genre-profile.esports_enabled: true`."
  - version: "1.2"
    date: 2026-06-16
    author: product-owner
    reason: "R-32: Remove CAP-013 from the Processes traceability row. CAP-013 is a Capability, not a Process; it was already correctly cited in the Capability Anchor Justification row. The Processes row now retains only PROC-NNN entries."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-3.03.009: Esports/Anti-Cheat Dual-Use Replay Export

## Description

The same input-stream recording produced for regression purposes (BC-3.03.001) is
re-exported in a format suitable for esports demo playback and anti-cheat evidence when
the competitive-multiplayer genre lane is active (CAP-013). The replay export does not
re-record; it re-packages the existing sealed recording into a demo format with an
optional observation layer (playback speed control, spectator viewpoints). For anti-cheat
evidence, the recording + per-checkpoint server-authoritative state provides the
machine-verifiable record required for dispute resolution. This synergy is possible only
because the factory's replay spine uses the same fixed-tick + seeded-RNG + input-injection
discipline as competitive-grade deterministic lockstep netcode.

## Preconditions

1. The adapter is T1 or T2 (`determinism_tier` is not `tolerance-only`) — T3 cannot
   provide the authoritative state integrity required for esports/anti-cheat use.
2. The competitive-multiplayer/esports lane is active: `genre-profile.esports_enabled: true`
   (schema-valid per BC-13.01.001; the sole genre-profile activation signal for the
   competitive/esports lane per CAP-013; no separate `competitive_multiplayer_enabled`
   field exists in the schema).
3. A sealed input recording (BC-3.03.001) and optionally a golden-state record
   (BC-3.03.008) exist for the session to be exported.
4. The export is requested for one of: `demo_playback`, `anti_cheat_evidence`.

## Postconditions for demo_playback export

1. A demo file is produced containing: the sealed input recording, a playback header
   (adapter_id, engine_version, determinism_tier, tick_rate_hz, start_frame, end_frame),
   and an optional observation layer (per-frame camera hints, broadcast delay value).
2. The demo file is signed with the game server's key (HMAC-SHA256 over the sealed
   recording checksum + demo header) to prevent replay tampering.
3. A demo playback engine can consume this file to produce a frame-accurate re-simulation
   of the match for spectating.
4. The broadcast delay value (default 60 seconds, configurable) is included to prevent
   stream-sniping during live tournament playback.

## Postconditions for anti_cheat_evidence export

1. An evidence package is produced containing:
   - The sealed input recording (BC-3.03.001)
   - Per-checkpoint server-authoritative state snapshots (from the original server run,
     not a client replay)
   - The player ID(s) under review
   - A chain-of-custody hash: SHA-256 over the evidence package contents + capture timestamp
2. The evidence package can be used as input to a deterministic replay to reproduce the
   exact server state at any checkpoint frame, providing the machine-verifiable basis for
   dispute resolution.
3. The evidence package is stored with tamper-evidence and access controls: only authorized
   anti-cheat administrators may retrieve it.

## Invariants

1. **No re-recording:** The export functions re-package the existing recording; they do
   not re-run the simulation or produce a new input stream. The same `recording_id` is used.
2. **Dual-use requires T1 or T2:** The esports/anti-cheat export is only available for
   T1 and T2 adapters. T3 tolerance-window comparison cannot provide the authoritative
   state integrity required for these use cases.
3. **Export does not modify the original recording:** The sealed recording remains sealed
   and unmodified after export. Export is a read operation.
4. **Genre gate enforced:** This BC's behavior is only exercised when the competitive-
   multiplayer lane is active. For non-competitive games, the export functions are
   not available, and any attempt returns `LANE_NOT_ACTIVE`.
5. **Factory does not author kernel anti-cheat:** The evidence package is produced for
   use by third-party anti-cheat systems (EAC/EOS default, BattlEye commercial). The
   factory never authors kernel-mode anti-cheat drivers (DI-010).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Demo export requested for T3 adapter | Rejected: `INSUFFICIENT_DETERMINISM_TIER_FOR_EXPORT`. T3 variance invalidates demo integrity. |
| EC-002 | Esports export requested for non-competitive-multiplayer game | Rejected: `LANE_NOT_ACTIVE`. |
| EC-003 | Anti-cheat evidence requested for a recording that was re-captured (original tampered) | Rejected: original recording is tampered; chain-of-custody broken; evidence invalid. |
| EC-004 | Broadcast delay configured to 0 seconds | Warning emitted: `BROADCAST_DELAY_ZERO_STREAM_SNIPE_RISK`. Export proceeds but risk is noted in demo header. |
| EC-005 | Server-authoritative state snapshots are missing (game ran client-only) | Anti-cheat evidence package cannot be produced: `SERVER_STATE_MISSING`. Demo export still possible (no server-auth requirement for demo). |
| EC-006 | Multiple recordings for the same match (reconnection scenario) | Export bundles all recordings for the match in sequence; playback engine stitches them. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| T1 Bevy adapter; esports_enabled; demo export requested | Demo file produced; signed; broadcast delay 60s in header. | happy-path (demo) |
| T1 adapter; anti_cheat_evidence export; server snapshots present | Evidence package produced with chain-of-custody hash; tamper-evident. | happy-path (anti-cheat) |
| T3 Godot adapter; demo export requested | Rejected: `INSUFFICIENT_DETERMINISM_TIER_FOR_EXPORT`. | error |
| Non-competitive game; demo export requested | Rejected: `LANE_NOT_ACTIVE`. | error |
| Anti-cheat export; original recording tampered | Rejected: chain-of-custody broken. | error (tamper) |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-043 | Demo export is never produced for T3 adapters. | integration test |
| VP-TBD-044 | Anti-cheat evidence package hash covers the complete evidence package; any modification is detectable. | unit test (tamper detection) |
| VP-TBD-045 | Export never modifies the original sealed recording. | unit test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 |
| Capability Anchor Justification | CAP-003 ("Determinism-Tier-Governed Replay Regression") per capabilities.md §CAP-003 — this BC specifies the esports demo/anti-cheat dual-use of the replay recording, which is the "synergy that this same machinery serves esports replay + anti-cheat" cited in the product brief §In Scope and the Differentiators §D-002 ("replay primitive serves esports demo, anti-cheat spine"). |
| L2 Domain Invariants | DI-004 (Determinism Tier Is Declared, Never Assumed), DI-010 (Kernel Anti-Cheat Is Never Autonomously Authored) |
| Architecture Module | SS-02 (Replay Exporter, Genre-Lane Activator — filled by architect) |
| Stories | (filled by story-writer) |
| Processes | PROC-004 (Replay Regression Workflow as foundation) |
| ADRs | ADR-0003 |
| Differentiators | D-002 (Deterministic Replay as First-Class Quality Gate — "single replay primitive" claim) |

## Related BCs

- BC-3.03.001 — depends on (recording produced here is the input for export)
- BC-3.03.008 — depends on (golden state provides server-authoritative snapshots for anti-cheat)
- BC-3.03.003 — related to (same T1 guarantee enables esports integrity)

## Architecture Anchors

- `architecture/SS-02-replay-exporter.md` — Demo format, anti-cheat evidence package, signing
- `architecture/SS-02-genre-lane-activator.md` — Competitive-multiplayer lane gate

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-043 — T3 rejection for demo export
- VP-TBD-044 — anti-cheat evidence tamper detection
