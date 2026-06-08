---
document_type: behavioral-contract
level: L3
id: BC-4.01.004
origin: greenfield
subsystem: SS-03
capability: CAP-004
priority: P0
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.01.004: Suno, Udio, and Litigation-Exposed Music Generators Are Blocked from Music Route

## Description

Domain invariant DI-009 prohibits routing any asset generation request with
`asset_class: audio_music` to Suno, Udio, or any other AI music generator identified
as litigation-exposed or ToS-excluded. This BC specifies the enforcement mechanism:
a static `music-litigation-blocklist` combined with a runtime asset-class check that
fires before backend selection for any music request. Only generators explicitly on the
DI-009-compliant allowlist (`stable-audio`, `aiva`, `soundraw`, and future verified-safe
additions) are eligible for the music route.

## Preconditions

1. The factory has a version-controlled `music-litigation-blocklist` (distinct from the
   general ToS-exclusion list) and a `music-licensed-allowlist`, both loaded at orchestrator
   startup.
2. A GenerationRequest with `asset_class: audio_music` has been dispatched.
3. The `music-litigation-blocklist` contains at minimum: `suno`, `udio`.
4. The `music-licensed-allowlist` contains at minimum: `stable-audio`, `aiva`, `soundraw`.

## Behavior

1. When the orchestrator identifies a request with `asset_class: audio_music`, it applies
   a specialized music-route policy BEFORE the general preference ordering.
2. The orchestrator restricts the candidate set to adapters whose `adapter_id` matches
   an entry in the `music-licensed-allowlist` AND whose `asset_classes[]` includes
   `audio_music`.
3. **Allowed path:** At least one allowlist adapter is registered, active, and not blocked.
   - Proceed with the filtered candidate set to preference ordering per BC-4.01.002.
4. **Blocklist check (defensive):** If any candidate somehow survived with an `adapter_id`
   matching the `music-litigation-blocklist`, it is rejected with error `E-AAG-020`
   ("music adapter '<id>' is on litigation-blocklist; music route requires licensed provider").
   - This should never trigger if the allowlist check works correctly; it is a defensive belt.
5. **Failure path A:** No allowlist adapter is registered or available.
   - Dispatch fails with error `E-AAG-021` ("no licensed music adapter available; music
     generation requires a DI-009-compliant provider").
   - The request is moved to `status: blocked`; the producer is notified.
6. **Failure path B:** A request attempts to specify `tool_preference` pointing to a
   blocklisted adapter for `audio_music`.
   - The override is rejected with error `E-AAG-022` ("tool_preference overrides to blocked
     music provider are not permitted; DI-009 policy").
   - The request proceeds with the allowlist-filtered candidate set.

## Postconditions

- No dispatched `audio_music` request has `selected_backend` matching any entry on the
  `music-litigation-blocklist`.
- No dispatched `audio_music` request has `selected_backend` that is absent from the
  `music-licensed-allowlist`.
- Every blocklist-match event is written to the audit log with `E-AAG-020` and the
  attempted `adapter_id`.

## Invariants

- The `music-litigation-blocklist` is a permanent factory constraint derived from DI-009;
  it cannot be bypassed at runtime or per-project.
- A music provider may be moved from the blocklist to the allowlist ONLY after the factory
  receives a verified update confirming litigation resolution AND explicit allowance, with
  a supporting ADR entry.
- `suno` and `udio` entries on the blocklist are permanent until litigation with Sony
  resolves and an explicit policy update ADR is filed.
- The allowlist is the positive control: only named-and-reviewed providers are eligible;
  unknown providers are implicitly blocked regardless of blocklist membership.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `asset_class: audio_sfx` (SFX, not music) — does this BC apply? | No; this BC applies only to `audio_music`. ElevenLabs and similar SFX providers are governed by BC-4.01.002 general routing only |
| EC-002 | `asset_class: audio_music` with `tool_preference: suno` | Override rejected with E-AAG-022; allowlist selection proceeds |
| EC-003 | Sony/Suno litigation resolves; developer wants to add Suno to allowlist | Requires: (a) verified legal opinion, (b) ADR filed, (c) config deploy that moves `suno` from blocklist to allowlist — NOT a runtime change |
| EC-004 | A new music generator "SoundForge AI" launches; not on either list | Implicitly blocked (not on allowlist); dispatch fails E-AAG-021 until explicitly added to allowlist via config deploy |
| EC-005 | Both `stable-audio` and `aiva` adapters are registered but `stable-audio` is rate-limited | Fallback to `aiva` per BC-4.01.002 retry/fallback logic; within same allowlist |
| EC-006 | `asset_class: audio_voice` with a voice that is NOT a performer likeness | Not governed by this BC (voice is separate modality); governed by BC-4.03.004 for consent |

## Canonical Test Vectors

| Request `asset_class` | `tool_preference` | Available adapters | Expected outcome |
|-----------------------|-------------------|-------------------|-----------------|
| `audio_music` | none | `[stable-audio, aiva]` | Routes to higher-preference of allowlist |
| `audio_music` | `suno` | `[stable-audio]` | Override rejected E-AAG-022; routes to `stable-audio` |
| `audio_music` | none | `[udio]` only | Blocklist match E-AAG-020; then E-AAG-021 (no licensed provider) |
| `audio_music` | none | `[]` | E-AAG-021 |
| `audio_sfx` | none | `[elevenlabs]` | General routing applies; this BC does not fire |
| `audio_music` | `stable-audio` | `[stable-audio]` | Proceeds; allowlist + preference match |

## Verification Properties

- **VP-4.01.004-a:** `∀ dispatch d where d.asset_class = "audio_music": d.selected_backend.adapter_id ∈ music_licensed_allowlist`
- **VP-4.01.004-b:** `∀ dispatch d where d.asset_class = "audio_music": d.selected_backend.adapter_id ∉ music_litigation_blocklist`
- **VP-4.01.004-c:** `"suno" ∈ music_litigation_blocklist ∧ "udio" ∈ music_litigation_blocklist` (invariant on list contents)

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — generating audio music is a core asset generation operation under CAP-004. The D-007 decision specifies "default to ship-safe generators — licensed-output music" as a ratified constraint on HOW music generation is executed within CAP-004. |
| L2 Invariants | **DI-009** ("Suno/Udio and Unlicensed AI Music Providers Are Blocked") — this BC is the direct enforcement mechanism for DI-009 |
| L2 Processes | PROC-003 §Stage 2 (Backend Selection) |
| L2 Risks | **R-003** ("AI music legal hazard: Suno/Udio litigation ongoing") — direct mitigation of R-003 |
| L2 Failure Modes | FM-004 (upstream; blocked music route prevents provenance from being written for an illegal backend) |

## Related BCs

- **BC-4.01.003** (sibling): general ToS exclusion list; music litigation blocklist is distinct and additional
- **BC-4.01.002** (depends on): after music-route filter, general preference ordering applies within the allowlist

## Architecture Anchors

- DI-009 ("Suno/Udio and Unlicensed AI Music Providers Are Blocked") — invariants.md
- RECONCILIATION §9 (Autonomous generation pipeline): "Tier-1: Stable Audio 2.5 / AIVA / Soundraw (music — licensed only)"
- RECONCILIATION §12 R-003: "Factory defaults to licensed models (Stable Audio 2.5, AIVA, Soundraw). Suno/Udio = non-ship until litigation resolves."
- Product brief §Constraints: "ToS-excluded tools — Suno/Udio (litigation)"

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
