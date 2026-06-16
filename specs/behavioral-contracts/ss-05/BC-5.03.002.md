---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-06-16T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/audio-discipline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
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

# BC-5.03.002: AI Audio Provenance Ledger Covers All Generated Audio Assets

## Description

Every AI-generated audio asset (music, SFX, voice) produced for the game must have an
entry in the `ai-audio-provenance-ledger` artifact — a manifest that aggregates all audio
asset provenance sidecars and adds audio-specific fields (voice-consent reference, music
license tier). The ledger is a required input to the `ai-disclosure-manifest` (CAP-010).
Coverage is 100%: any audio asset referenced in `audio-build-manifest` that was AI-generated
must appear in the ledger. Human-performed audio (non-AI foley, live orchestra) is
separately tracked with `generated_by_tool: "human-recording"`.

## Preconditions

1. An `audio-build-manifest` exists and has been schema-validated (BC-5.03.001 preconditions
   are met).
2. All audio source assets referenced in `audio-build-manifest` have `asset-provenance-sidecar`
   files at `<asset_path>.provenance.json`.
3. The `ai-audio-provenance-ledger` schema is registered in the schema registry.
4. A `voice-consent-registry` artifact exists (may be empty if no voice assets).

## Postconditions

1. The factory constructs the `ai-audio-provenance-ledger` by scanning all source assets
   referenced in `audio-build-manifest` and collecting their provenance sidecars.
2. For each audio asset where `generated_by_tool` in the sidecar is NOT `"human-recording"`:
   a. A ledger entry is created with: `asset_id`, `asset_class` (music/sfx/voice),
      `generated_by_tool`, `license_tier` (Tier-1/2/3 from sidecar `risk_tier`),
      `disclosure_class`, and `voice_consent_ref` (null for non-voice).
   b. If the asset is a voice asset (`asset_class: "voice"`) and `likeness_consent_ref`
      is non-null in the sidecar: the ledger entry includes a reference to the consent
      record in `voice-consent-registry`. A `human-gated` SAG-AFTRA task is surfaced
      if the consent record status is not `"signed"`.
3. Coverage check: for every AI-generated audio asset in `audio-build-manifest`, exactly
   one ledger entry exists. Missing entry → E-AUD-005 (coverage gap: AI-generated audio
   asset missing from provenance ledger).
4. The completed `ai-audio-provenance-ledger` is emitted with:
   - `total_assets_covered`: integer count
   - `voice_consent_pending`: list of asset_ids awaiting SAG-AFTRA signature
   - `blocked_tool_detected`: true if any asset uses a blocked tool (DI-009); if true,
     the relevant asset_ids are listed and E-AUD-004 is raised
5. If any AI-generated audio asset is missing from the ledger: E-AUD-005 raised for
   each missing asset (coverage gap — distinct from blocked-tool detection in postcondition 4).

## Invariants

1. (DI-003) Every AI-generated audio asset must have a ledger entry. Coverage is 100%; no
   exceptions for "placeholder" or "test" audio.
2. (DI-009) Blocked-tool detection: any audio asset with `generated_by_tool` in the
   factory's blocked-tools list (Suno, Udio, or any tool added to the block list by
   policy update) raises E-AUD-004 and is flagged as a compliance defect. Missing-ledger-entry
   coverage gaps raise E-AUD-005 (distinct from blocked-tool: E-AUD-004 is for known-bad tool;
   E-AUD-005 is for absent ledger entry regardless of tool).
3. (DI-006) Voice consent pending items are surfaced as human-gated tasks. They are never
   silently dropped from the ledger.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Audio build has no AI-generated assets (all human-recording) | Ledger emitted with `total_assets_covered: 0`; coverage check trivially passes |
| EC-002 | Voice asset with `likeness_consent_ref` pointing to a consent record marked "pending" | Ledger entry created; `voice_consent_pending` list includes asset_id; human-gated SAG-AFTRA task surfaced |
| EC-003 | Sidecar `generated_by_tool` is "Udio" (blocked tool) | E-AUD-004: blocked tool detected; asset flagged; ledger `blocked_tool_detected: true`; `ai-disclosure-manifest` generation blocked until resolved (E-AUD-004 = blocked tool; E-AUD-005 = missing ledger entry — distinct conditions) |
| EC-004 | Same audio asset referenced in two different banks | Single ledger entry created (deduplicated by asset_id); coverage check counts unique assets |
| EC-005 | New blocked tool added to policy after ledger was generated | Ledger becomes stale; manifest re-generation required on policy update; state-manager drift detection catches stale ledger |
| EC-006 | Music asset declared as Tier-1 (Stable Audio) but sidecar says Tier-3 | Ledger records sidecar values as authoritative; discrepancy between request tier and sidecar tier is flagged as warning in ledger |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| 3 AI SFX (Tier-1 ElevenLabs), 2 AI music (Stable Audio), 0 voice | Ledger: 5 entries, all covered, no blocked tools, no consent pending | happy-path |
| 1 AI music asset with no provenance sidecar | E-AUD-005: asset '<id>' missing from ai-audio-provenance-ledger — coverage gap | error |
| 1 voice asset with likeness_consent_ref, consent status "pending" | Ledger: entry created; voice_consent_pending: ['voice_id']; human-gated SAG-AFTRA task emitted | edge-case |
| 1 AI SFX generated by "Udio" | E-AUD-004: blocked tool Udio detected; ledger blocked_tool_detected=true | error |
| All assets are human-recording | Ledger: total_assets_covered=0; coverage pass; no errors | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.03.004 | For all AI-generated audio assets in manifest, exactly one ledger entry exists; missing entry raises E-AUD-005 | proptest: manifest with N AI assets → assert ledger.total_assets_covered = N; remove sidecar → assert E-AUD-005 raised |
| VP-5.03.005 | Blocked tool in any sidecar always triggers E-AUD-004 (not E-AUD-005 — distinct condition) | proptest: inject Suno/Udio in tool field; assert E-AUD-004 raised, not E-AUD-005 |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the `ai-audio-provenance-ledger` is listed in RECONCILIATION §5.5 as a primary audio discipline artifact; this BC defines its machine-checkable coverage contract. |
| L2 Domain Invariants | DI-003 (provenance sidecar completeness), DI-009 (Suno/Udio blocked), DI-006 (human-gated tasks surfaced) |
| Architecture Module | SS-04 — audio provenance ledger builder; voice-consent-registry |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.03.001 — depends on (audio-build-manifest is the asset source for ledger)

## Architecture Anchors

- `architecture/SS-04-audio-provenance.md`

## Story Anchor

S-TBD — AI Audio Provenance Ledger Generation

## VP Anchors

- VP-5.03.004 — ledger coverage completeness (E-AUD-005)
- VP-5.03.005 — blocked-tool detection (E-AUD-004)

## Changelog

### v1.2 (2026-06-16)

| Change | Detail |
|--------|--------|
| R-16: E-AUD-004 overload split | Postconditions 3 and 5 (coverage-gap case) updated from E-AUD-004 to E-AUD-005. Invariant 2 updated to distinguish E-AUD-004 (blocked tool) from E-AUD-005 (missing ledger entry). Test vector for no-provenance-sidecar case updated to E-AUD-005. EC-003 clarification note added. VP-5.03.004/005 updated to specify which error code each verifies. |
