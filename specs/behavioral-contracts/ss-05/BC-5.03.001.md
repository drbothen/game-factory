---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/audio-discipline.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-005
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

# BC-5.03.001: Audio Build Manifest Produces Conformant Bank Build

## Description

The audio-implementer agent produces an `audio-build-manifest` that fully declares all
audio assets, bank definitions, middleware configuration, platform targets, and loudness
targets. The factory invokes the middleware CLI (Wwise `WwiseConsole generate-soundbank`
or FMOD Bank Builder) headlessly to produce a bank build. The build must succeed (exit 0)
and all output banks must pass loudness conformance checks using ITU-R BS.1770 / libebur128:
LUFS within ±2 dB of target per platform, true-peak ≤ -1 dBTP. Both the bank build and
loudness check are CI gates; failure is a broken severity defect.

## Preconditions

1. An `audio-build-manifest` artifact exists with `middleware`, `project_path`, `platforms`,
   `bank_definitions`, and `loudness_targets` fields populated.
2. `middleware` is one of `"wwise"` or `"fmod"`. Other values are schema-rejected.
3. The middleware CLI for the declared `middleware` is installed and accessible in the
   CI runner PATH.
4. All audio source assets referenced in `bank_definitions` exist at their declared paths.
5. `loudness_targets.console_lufs` is a negative number (typically -23 to -18).
6. `loudness_targets.true_peak_dBTP` is a negative number ≤ -1 (typically -1 to -3).

## Postconditions

1. The factory invokes the middleware CLI with the `project_path` and the list of
   `bank_definitions` as parameters. CLI exits 0 (success). If CLI exits non-zero:
   E-AUD-001 raised with platform and bank_id detail; build fails.
2. For each output bank file on each declared platform:
   a. `ffmpeg loudnorm` or `libebur128` measures integrated LUFS and true-peak.
   b. Measured LUFS is within [target - 2.0, target + 2.0] dB. If outside band: E-AUD-002.
   c. Measured true-peak ≤ declared `true_peak_dBTP`. If above: E-AUD-003.
3. If ALL bank builds succeed and ALL banks pass loudness conformance:
   - `audio-build-report` with status `"pass"`, measured LUFS per bank, measured true-peak
     per bank, and middleware CLI exit code is emitted.
   - Output banks are staged for engine adapter import.
4. If any bank fails loudness check: E-AUD-002 or E-AUD-003 raised. Bank is not staged.
   The specific bank and measurement are included in the error.
5. Blocked or unavailable audio assets: CLI returns non-zero; E-AUD-001 raised with
   missing asset detail.

## Invariants

1. (DI-009) The factory never routes audio generation to Suno, Udio, or other
   ToS-excluded AI audio generators. This is enforced at the `asset-generation-request`
   level (CAP-004), but the audio-build-manifest must not reference any asset whose
   provenance sidecar names a blocked tool. If such a reference is detected, E-AUD-004
   is raised before the bank build.
2. The loudness target is per-platform. Console and portable targets are different;
   the bank build report must measure and report each platform separately.
3. The bank build is reproducible: same manifest + same source assets → same output
   banks. The CI runner must produce the same banks on consecutive runs.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Middleware is "wwise" but `WwiseConsole` binary not found in PATH | E-AUD-001: middleware CLI not available; pipeline blocked; error surfaced to producer |
| EC-002 | Bank build succeeds but one platform bank is empty (0 bytes) | Loudness check: libebur128 returns error on empty file; treated as E-AUD-001 (bank build failure for that bank) |
| EC-003 | Loudness target declares console_lufs=-18 (portable, not console standard) | Valid: manifest declares its own target; loudness check uses declared target, not a hardcoded value |
| EC-004 | Audio asset has SAG-AFTRA consent required (likeness_consent_ref != null in provenance) | Bank build proceeds (consent is a separate gate); a `human-gated` SAG-AFTRA signature task is surfaced as an open milestone item; asset usable in dev builds, not in ship build until consent |
| EC-005 | FMOD bank build succeeds but integrated LUFS measures -15 vs target -23 (+8 dB difference) | E-AUD-002: bank 'music_main', platform 'pc', measured=-15 LUFS, target=-23 ±2 LUFS |
| EC-006 | All banks pass; however one bank's true_peak measures -0.5 dBTP (above -1 dBTP ceiling) | E-AUD-003 raised for that bank |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Valid audio-build-manifest, wwise, all source assets present, 2 banks, loudness at -23 LUFS, true-peak -2 dBTP | audio-build-report: pass, all banks staged | happy-path |
| Manifest references missing source asset file | CLI exits non-zero; E-AUD-001 with missing asset path | error |
| Bank build succeeds, one bank measures -15 LUFS (target -23 ±2) | E-AUD-002: bank 'sfx_bank', measured=-15, target=-23±2 | error |
| Manifest declares middleware="protools" (unsupported) | Schema validation rejects; E-AUD-001 at schema validation time | error |
| All banks pass; one bank measures true-peak -0.5 dBTP | E-AUD-003: bank 'dialog', true-peak=-0.5, ceiling=-1 | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.03.001 | Bank build with valid manifest and available CLI always produces non-empty bank files | integration test against reference audio assets |
| VP-5.03.002 | Loudness measurement is within ±0.1 LUFS of reference measurement (libebur128 vs ffmpeg) | calibration test with known reference audio |
| VP-5.03.003 | Manifest with Suno/Udio-provenance asset reference always raises E-AUD-004 before build | proptest: inject blocked tool in provenance sidecar |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the audio-build-manifest is the primary audio production artifact listed in RECONCILIATION §5.5 and §6.1 as owned by the audio-implementer agent; this BC defines its machine-checkable production contract. |
| L2 Domain Invariants | DI-009 (Suno/Udio blocked), DI-003 (provenance sidecar completeness) |
| Architecture Module | SS-TBD — audio build pipeline; middleware CLI wrapper; loudness checker |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.03.002 — composes with (AI audio provenance ledger covers all assets in this manifest)
- BC-5.07.002 — depends on (cross-discipline dependency contract checks audio build status)

## Architecture Anchors

- `architecture/SS-TBD-audio-pipeline.md` — middleware CLI integration, bank build, loudness check

## Story Anchor

S-TBD — Audio Bank Build and Loudness Conformance

## VP Anchors

- VP-5.03.001 — bank build integration test
- VP-5.03.002 — loudness measurement calibration
- VP-5.03.003 — blocked-tool provenance rejection
