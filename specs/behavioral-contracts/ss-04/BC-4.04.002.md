---
document_type: behavioral-contract
level: L3
id: BC-4.04.002
origin: greenfield
subsystem: SS-TBD
capability: CAP-004
priority: P0
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.04.002: A Generated Audio Asset Passes the Quality Gate When Loudness Is Within Target, True-Peak Does Not Exceed -1 dBTP, and Provenance Is Complete

## Description

Generated audio assets (music and SFX) are validated against loudness and true-peak
conformance targets before ingest. These targets are derived from the game's declared
`audio_profile` (loudness target from the GameSpec) and from console platform standards
(ASWG-R001). The quality gate applies the ITU-R BS.1770 / EBU R128 loudness measurement
standard. Provenance completeness is also checked (same rule as BC-4.04.001 check 5).
A passing audio asset is auto-ingested (Tier-1) or flagged-and-ingested (Tier-2/3).

## Preconditions

1. A generated audio asset (WAV/OGG/MP3/FLAC) is available for loudness analysis.
2. The GameSpec has declared an `audio_profile` with at minimum:
   - `loudness_target_lufs`: the integrated loudness target (LUFS, negative value)
   - `loudness_tolerance_lu`: acceptable deviation in LU (default: ±2 LU)
   - `platform_targets[]`: target platforms (e.g., `["ps5", "pc", "mobile"]`)
3. A provenance sidecar has been constructed and attached.
4. A loudness measurement tool implementing ITU-R BS.1770 is available (e.g., `ffmpeg loudnorm`,
   `libebur128`).

## Behavior

Quality gate check 1 — **Integrated Loudness Within Target:**
- Measure integrated loudness over the full asset duration using ITU-R BS.1770 (I-measure).
- Compare against `audio_profile.loudness_target_lufs ± audio_profile.loudness_tolerance_lu`.
- Default targets if not specified in audio_profile:
  - Console (PS5/Xbox): −23 LUFS ±2 LU (ASWG-R001)
  - PC/Steam: −18 LUFS ±3 LU (lenient default)
  - Mobile: −18 LUFS ±3 LU
- **Pass:** measured_lufs ∈ [target − tolerance, target + tolerance].
- **Fail:** E-QG-010 ("integrated loudness <measured> LUFS outside target <target> ±<tolerance> LU").

Quality gate check 2 — **True-Peak Does Not Exceed -1 dBTP:**
- Measure inter-sample true-peak level (TP) across all channels.
- Maximum true-peak level ≤ −1.0 dBTP (ASWG-R001 console standard; also Steam/PC safe default).
- **Pass:** max_true_peak ≤ −1.0 dBTP.
- **Fail:** E-QG-011 ("true-peak <measured> dBTP exceeds -1.0 dBTP limit").

Quality gate check 3 — **No Silence Clipping at Boundaries:**
- First 100ms and last 100ms must not be hard clips (peak > 0 dBFS).
- No DC offset > 0.005 normalized amplitude (DC offset indicates encoding problem).
- **Pass:** boundary_check = true.
- **Fail:** E-QG-012.

Quality gate check 4 — **Provenance Complete:**
- Same as BC-4.04.001 check 5: sidecar schema-valid, disclosure_class present, copyrightability_assessment present.
- **Pass:** provenance_check = true.
- **Fail:** E-QG-005.

**Aggregation:** Same Tier-1/2/3 policy as BC-4.04.001: Tier-1 fails trigger retry then block;
Tier-2/3 fails ingest with quality_flagged = true. Provenance failure is a hard gate for all tiers.

**Special rule for music (DI-009-compliant):** The loudness check specifically validates the
output of licensed music generators (Stable Audio 2.5, AIVA, Soundraw). These generators may
normalize output differently; the quality gate normalizes to target using the measurement tool
if the measured level is within a ±5 LU correction window. If the level deviation is > ±5 LU,
normalization is not applied; the asset fails the loudness check and is queued for re-generation.

## Postconditions

- A `quality-gate-report` artifact is produced with all four check results.
- Passing audio assets have `quality_gate_status: pass` in the asset store.
- The measured `loudness_lufs` and `true_peak_dbtp` values are stored in the quality-gate-report
  for reference.
- Auto-normalized assets have a normalization record in `human_modifications_log` (the
  normalization step is an automated modification; it is logged to preserve sidecar accuracy).

## Invariants

- The true-peak ceiling of −1 dBTP is non-negotiable and applies to all modalities; it is a
  platform safety standard.
- Auto-normalization applies only when deviation is ≤ ±5 LU; larger deviations require
  re-generation.
- Provenance completeness is a hard gate for ALL tiers.
- The loudness target is taken from `audio_profile` in the GameSpec; if no GameSpec is
  available, default console targets (−23 LUFS, −1 dBTP) apply.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Music asset at −22 LUFS against a −23 LUFS ±2 LU target | Pass (within ±2 LU window) |
| EC-002 | SFX at −10 LUFS (too loud) against −23 LUFS ±2 LU | Fail E-QG-010; deviation = +13 LU > ±5 LU; re-generation required |
| EC-003 | Music at −20 LUFS against −23 LUFS ±2 LU | Fail E-QG-010; deviation = 3 LU, within auto-normalize window; auto-normalized to −23 LUFS; normalization logged in modifications_log; re-check passes |
| EC-004 | Asset true-peak is −0.5 dBTP | Fail E-QG-011; must be ≤ −1.0 dBTP |
| EC-005 | Procedural music from a licensed music system with disclosure_class: procedural-exempt | Still runs loudness and true-peak checks; provenance check passes if disclosure_class is set |
| EC-006 | Voice asset (not music/SFX) — what loudness target applies? | Voice uses a dialogue target from audio_profile (if present; default: −23 LUFS ±3 LU); same true-peak ceiling applies |
| EC-007 | Suno/Udio asset arrives at quality gate (should never happen given BC-4.01.004) | If it somehow arrives: quality gate runs normally; blocked by BC-4.05.001 ship-gate check for non-commercial license |

## Canonical Test Vectors

| Measured loudness | Measured true-peak | Target | Expected status |
|------------------|-------------------|--------|----------------|
| −23 LUFS | −2 dBTP | −23 LUFS ±2 LU | pass |
| −22 LUFS | −1.5 dBTP | −23 LUFS ±2 LU | pass (within ±2) |
| −25 LUFS | −2 dBTP | −23 LUFS ±2 LU | pass (within ±2) |
| −28 LUFS | −2 dBTP | −23 LUFS ±2 LU | fail E-QG-010 (−5 LU outside ±2; auto-normalize then re-check) |
| −23 LUFS | −0.3 dBTP | −23 LUFS ±2 LU | fail E-QG-011 |
| −23 LUFS | −2 dBTP | any | fail E-QG-005 if disclosure_class null |

## Verification Properties

- **VP-4.04.002-a:** `∀ audio asset a ∈ asset_store: a.quality_gate_status = "pass" → a.measured_true_peak ≤ -1.0`
- **VP-4.04.002-b:** `∀ Tier-1 audio asset a ∈ asset_store: a.quality_gate_status = "pass"`
- **VP-4.04.002-c:** `∀ audio asset a with normalization: a.sidecar.human_modifications_log contains normalization entry`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — audio assets are a named modality in the CAP-004 definition ("audio, music, voice"). The quality gate for audio is the per-modality acceptance check mandated by PROC-003 §Stage 4. Loudness/true-peak conformance is the primary machine-checkable quality assertion for audio. |
| L2 Invariants | DI-003 (provenance check 4), DI-009 (music providers checked upstream; this gate is downstream verification) |
| L2 Processes | PROC-003 §Stage 4 (Quality Gate) |
| L2 Risks | R-003 (music legal hazard — quality gate runs but license check is BC-4.05.001) |
| L2 Failure Modes | FM-004 (provenance check within quality gate) |

## Related BCs

- **BC-4.01.004** (upstream): music routing only allows licensed providers before quality gate runs
- **BC-4.03.001** (dependency for check 4): sidecar required
- **BC-4.04.001** (sibling): 3D mesh quality gate; same Tier-1/2/3 ingest policy applies

## Architecture Anchors

- audio-discipline.md §1.4: "Loudness analysis and conformance are fully automatable with off-the-shelf tooling"
- audio-discipline.md §0: "Sony ASWG-R001 = -23 LUFS console (±2), -18 LUFS portable, -1 dBTP" [VERIFIED]
- RECONCILIATION §9: "Quality Gate: topology/UV/PBR/loudness/provenance completeness checks"

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
