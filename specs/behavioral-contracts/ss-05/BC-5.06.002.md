---
document_type: behavioral-contract
level: L3
version: "1.3"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/cinematics-virtual-production.md
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
modified:
  - v1.2: F38-01 fix — E-CIN-003 mis-citation corrected to E-PRV-030 at all sites for SAG-AFTRA likeness-consent ship-build gate (PC4c, test vector, Error Codes, Related-BC rows)
  - v1.3: F39-02 fix — PC1 re-pointed from "E-CIN-004 variant" (blendshape range — value outside [0,1]) to E-CIN-006 (BlendshapeTrackSetIncomplete, dedicated registered code for missing/extra track names); EC-001 and test vector updated accordingly.
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.06.002: Lip-Sync Pipeline Contract Produces ARKit-52 Aligned Blendshape Output

## Description

The lipsync-animator agent produces a `lip-sync-pipeline-contract` for each voiced
character in cinematic sequences. This contract declares the lip-sync method (Audio2Face-3D,
MetaHuman Animator, JALI, Speech Graphics, or custom) and produces output in the canonical
ARKit-52 blendshape format — the single portable representation used by all engine adapters.
The factory validates: all 52 ARKit blendshape values are within [0.0, 1.0]; the audio
alignment is within declared tolerance; and if the voice asset involves a real performer's
likeness (`likeness_consent_ref != null`), a SAG-AFTRA signature flow is triggered as a
`human-gated` task before the character can be used in a ship build.

## Preconditions

1. A `lip-sync-pipeline-contract` artifact exists with:
   - `character_id` referencing a valid entity in Canon-KB
   - `method`: one of `"audio2face-3d"` | `"metahuman-animator"` | `"jali"` |
     `"speech-graphics"` | `"custom"`
   - `output_format: "arkit-52-blendshapes"` (only accepted format)
   - `blendshapes_ref`: path to the output blendshape animation file
   - `source_audio_ref`: path to the voice audio file
   - `likeness_consent_ref`: null or reference to consent record
2. The blendshape animation file exists at `blendshapes_ref` with an array of 52 named
   blendshape tracks matching the ARKit face blendshape set.
3. The voice audio file exists at `source_audio_ref`.

## Postconditions

1. **ARKit-52 completeness check**: the blendshape animation file contains exactly 52
   named blendshape tracks corresponding to the ARKit face blendshape set (e.g.,
   `jawOpen`, `mouthClose`, `eyeBlinkLeft`, etc.). Missing or extra track names →
   E-CIN-006 (BlendshapeTrackSetIncomplete).
2. **Range check**: for every blendshape value at every keyframe, the value is within
   [0.0, 1.0] inclusive. Value outside range → E-CIN-004 per violation.
3. **Audio alignment tolerance**: the blendshape animation duration must match the source
   audio duration within the declared `audio_alignment_tolerance_ms` (default: 100 ms).
   Misalignment beyond tolerance → warning in report.
4. **Likeness consent check**: if `likeness_consent_ref != null`:
   a. The factory looks up the consent record in the `voice-consent-registry`.
   b. If status is `"signed"`: the lip-sync output is accepted for use in the ship build.
   c. If status is `"pending"` or `"unsigned"`: a `human-gated` SAG-AFTRA signature task
      is surfaced; the character's lip-sync output may be used in dev builds but is
      blocked from ship build until signed. E-PRV-030 is raised for the ship-build gate
      ("ship build contains asset with outstanding SAG-AFTRA likeness consent task").
5. A `lip-sync-validation-report` is emitted with: method used, blendshape range pass/fail,
   alignment tolerance pass/fail, consent status.

## Invariants

1. (DI-006) If `likeness_consent_ref != null`, the SAG-AFTRA signature task is ALWAYS
   surfaced. It is never silently dropped. This is a DI-006 enforcement point.
2. The canonical output format is always `arkit-52-blendshapes`. Custom lip-sync tools
   must produce ARKit-52 output via an adapter; the contract never accepts tool-specific
   blendshape formats as output.
3. The blendshape animation file is inseparable from the `lip-sync-pipeline-contract`.
   Referencing a blendshapes_ref that no longer exists at the contract's path is an
   E-CIN-001 (broken ref).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Method is "custom" but output file only has 48 blendshapes (custom subset) | E-CIN-006: ARKit-52 requires exactly 52 tracks; custom method must produce all 52 or map missing shapes to 0.0 explicitly |
| EC-002 | Blendshape value of -0.001 (floating point rounding artifact) | E-CIN-004: value outside [0.0, 1.0]; clamp to 0.0 is permitted as an automatic correction with a warning |
| EC-003 | Character has no voice lines (instrumental/non-verbal) | No lip-sync contract required; sequence-graph has no `facial_lipsync` tracks for this character; this BC does not apply |
| EC-004 | `likeness_consent_ref` is null (synthetic voice, no real performer) | Consent check skipped; lip-sync output accepted (assuming all other checks pass) |
| EC-005 | Audio file is 3.2 s; blendshape animation is 3.5 s; tolerance is 100 ms | Difference is 300 ms > 100 ms; warning in report (not block); animator must re-sync |
| EC-006 | JALI tool produces output in its native curve format; adapter converts to ARKit-52 | Adapter output is validated; native JALI format is not the contract artifact; only the ARKit-52 output is validated |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Audio2Face-3D output, 52 ARKit blendshape tracks, all values [0.0, 1.0], audio-aligned within 50ms, likeness_consent_ref=null | lip-sync-validation-report: pass; accepted for ship build | happy-path |
| Blendshape track `jawOpen` has value 1.15 at keyframe 42 | E-CIN-004: blendshape 'jawOpen' value 1.15 at frame 42 outside [0.0, 1.0] | error |
| Only 48 blendshape tracks present (missing 4 ARKit shapes) | E-CIN-006: missing blendshape tracks [list of 4] | error |
| likeness_consent_ref points to unsigned consent record | lip-sync-validation report: other checks pass; SAG-AFTRA task surfaced; dev-build: accepted; ship-build: blocked (E-PRV-030 at ship-gate evaluation) | edge-case |
| Audio 3.2s, blendshapes 3.5s, tolerance=100ms | Warning: alignment diff=300ms > 100ms; accepted with warning | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.06.003 | For all blendshape files, any value outside [0.0, 1.0] always raises E-CIN-004 | proptest: inject out-of-range values at random keyframes; assert error rate = 100% |
| VP-5.06.004 | For all contracts with likeness_consent_ref != null, human-gated SAG-AFTRA task always surfaced | test: inject non-null consent ref; assert task in milestone gate |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — the `lip-sync-pipeline-contract` is listed in RECONCILIATION §6.3 (cinematics additions) as a primary cinematic artifact produced by the lipsync-animator agent within CAP-005. |
| L2 Domain Invariants | DI-006 (human-gated tasks surfaced — SAG-AFTRA consent) |
| Architecture Module | SS-04 — lip-sync pipeline; ARKit-52 blendshape validator; voice-consent-registry |
| Error Codes | E-CIN-001 (broken blendshapes_ref), E-CIN-004 (blendshape value outside [0,1]), E-CIN-006 (blendshape track set incomplete — missing/extra ARKit-52 track names), E-PRV-030 (SAG-AFTRA likeness consent outstanding at ship gate — PC4c) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.06.001 — composes with (blendshapes_ref is a track in the sequence-graph)
- BC-4.03.004 — depends on (authoritative SAG-AFTRA ship-block mechanism; E-PRV-030 is defined and enforced there; this BC surfaces the same gate for lip-sync assets with `likeness_consent_ref != null`)

## Architecture Anchors

- `architecture/SS-04-cinematics-pipeline.md` — lip-sync contract, consent gate

## Story Anchor

S-TBD — Lip-Sync Pipeline Contract Validation

## VP Anchors

- VP-5.06.003 — blendshape range validation
- VP-5.06.004 — SAG-AFTRA consent task surfacing
