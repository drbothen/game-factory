---
document_type: behavioral-contract
level: L3
id: BC-4.03.004
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/specs/prd-supplements/prd-cap-004.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-03
capability: CAP-004
priority: P0
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-4.03.004: Any Asset with `likeness_consent_ref != null` Triggers Human-Gated SAG-AFTRA Signature Task and Is Blocked from Ship Build Until Task Is Complete

## Description

Domain invariant DI-006 requires that human-gated tasks be surfaced, not silently dropped.
SAG-AFTRA's 2025 Interactive Media Agreement (ratified July 2025) requires written,
separately-signed, specific consent and compensation for any AI voice or likeness of a
covered performer (Independently Created Digital Replica). This BC specifies the enforcement
mechanism: when a provenance sidecar has `likeness_consent_ref != null`, the factory
immediately creates a human-gated task of type `sag_aftra_consent_signature` and blocks
the asset from any ship build until the task is marked complete by an authorized human.

## Preconditions

1. A provenance sidecar has been constructed (BC-4.03.001) and is being evaluated.
2. The `likeness_consent_ref` field is not null (it references a performer consent document ID).
3. The human-gated task management system is operational.
4. The convergence report for the game is accessible to record the outstanding task.

## Behavior

1. During sidecar construction or ingest evaluation, the orchestrator checks
   `likeness_consent_ref` on each sidecar.
2. **Null path (no performer likeness):** `likeness_consent_ref = null`.
   - No human-gated task is created.
   - Asset proceeds normally.
3. **Non-null path (performer likeness present):**
   a. The orchestrator creates a `HumanGatedTask` record of type `sag_aftra_consent_signature`:
      ```
      task_type: sag_aftra_consent_signature
      asset_id: <the asset_id>
      consent_ref: <value of likeness_consent_ref>
      performer_identity: <from request's likeness_ref metadata>
      required_signatories: [producer, sag_aftra_icdr_rep]
      blocking: true
      convergence_dimension: provenance_legal
      description: "SAG-AFTRA IMA 2025 (ratified Jul 9 2025): separately-signed, specific
                    consent required for ICDR including AI voice/face of covered performer.
                    This asset may NOT be included in any ship build until consent is signed."
      ```
   b. The task is added to the active human-gated task list in the convergence report
      under dimension `provenance/legal` (convergence dimension #8 per RECONCILIATION §7).
   c. The asset's `ingest_status` is set to `pending_consent`.
   d. The asset is flagged as `ship_blocked: true`.
4. **Ship-gate enforcement:** At ship-gate evaluation, if any asset in the build has
   `ship_blocked: true` due to an outstanding `sag_aftra_consent_signature` task:
   - The ship gate FAILS with error `E-PRV-030` ("ship build contains asset '<id>' with
     outstanding SAG-AFTRA likeness consent task '<task_id>'; consent must be signed
     before shipping").
   - The error lists all blocked assets and their task IDs.
5. **Task completion path:** A human marks the `sag_aftra_consent_signature` task as
   `complete` with a consent document reference:
   - The asset's `ship_blocked` flag is cleared.
   - `ingest_status` is updated to `consent_cleared`.
   - The convergence report is updated to reflect task completion.

## Postconditions

- **Consent outstanding:** The asset is in `ship_blocked: true` state. A human-gated task
  record exists in the convergence report under `provenance/legal`. The ship gate refuses
  to include this asset.
- **Consent cleared:** The asset has `ship_blocked: false` and `ingest_status: consent_cleared`.
  A consent document reference is recorded on the task. The ship gate may include this asset.
- In both states, the task record persists in the audit log indefinitely.

## Invariants

- `ship_blocked: true` assets are NEVER included in a ship build, regardless of any other
  quality-gate status.
- The SAG-AFTRA consent task cannot be dismissed, overridden, or marked complete without
  a human action. The factory has no automation path to mark it complete.
- This gate applies to ALL voice and face/character assets with a non-null
  `likeness_consent_ref`, regardless of risk tier or asset class.
- The consent task persists even if the asset is later re-generated (the new generation
  still requires consent for the same performer).

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | AI-generated voice using ElevenLabs with a custom (non-performer) voice profile | `likeness_consent_ref = null`; no task created; proceeds normally |
| EC-002 | AI voice of a named SAG-AFTRA-covered performer's voice | `likeness_consent_ref != null`; task created; asset blocked |
| EC-003 | `likeness_consent_ref` is set to a placeholder value `"tbd"` | Treated as non-null; task created; blocked (placeholder is not consent) |
| EC-004 | Same performer referenced in 50 voice lines | 50 assets all get `ship_blocked: true`; a single task may cover all 50 if the consent document covers them — the task record must enumerate all asset_ids |
| EC-005 | Consent task is marked complete but the consent document ref is missing | Task completion rejected; factory requires a `consent_document_id` field in the task completion data |
| EC-006 | Build system attempts to include a blocked asset using a `--force-include` flag | Flag not supported for consent-blocked assets; E-PRV-030 is always a hard stop |
| EC-007 | Voice asset generated for a prototype build (not shipping) | Same rule applies; `ship_blocked: true`; the flag is per-asset, not per-build-type. Prototype builds must explicitly configure `build_type: prototype_non_ship` to bypass (factory must audit this bypass) |

## Canonical Test Vectors

| `likeness_consent_ref` | Human task status | Ship gate result |
|------------------------|------------------|-----------------|
| `null` | n/a | No block; proceeds |
| `"icdr-performer-001"` | outstanding | FAIL E-PRV-030 |
| `"icdr-performer-001"` | complete with doc ref | Pass |
| `"tbd"` | outstanding | FAIL E-PRV-030 (placeholder = outstanding) |
| `"icdr-performer-002"` | task marked complete without doc ref | Task completion rejected; still blocked |

## Verification Properties

- **VP-4.03.004-a:** `∀ asset a in ship build: a.sidecar.likeness_consent_ref ≠ null → a.consent_task.status = "complete" ∧ a.consent_task.consent_document_id ≠ null`
- **VP-4.03.004-b:** `∀ asset a: a.ship_blocked = true → a ∉ ship_build`
- **VP-4.03.004-c:** `∀ asset a: a.sidecar.likeness_consent_ref ≠ null → a.consent_task ∈ convergence_report.human_gated_tasks`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — this BC governs a critical provenance attribute (`likeness_consent_ref`) that determines whether an asset can be used in a shipped product. The D-007 decision ("real-performer likeness routes to human-gated consent") is directly encoded here. |
| L2 Invariants | **DI-006** ("Human-Gated Tasks Are Surfaced, Not Silently Dropped") — the consent task is a DI-006 human-gated act; this BC enforces that it cannot be silently skipped; DI-012 (Every ContractArtifact Has a Declared Validation Method) — validation method is declared via the Verification Properties section (VP-4.03.004-a/b/c: formal property assertions) |
| L2 Processes | PROC-003 §Stage 5 (Likeness Check), PROC-006 (Human-Gated Task Surfacing) |
| L2 Risks | **R-004** ("SAG-AFTRA 2025 IMA voice consent requirement") — direct mitigation |
| L2 Failure Modes | **FM-005** ("Likeness Consent Ref Present Without Human-Gated Completion") — this BC is the enforcement mechanism preventing FM-005 |
| L2 Entities | Asset, ProvenanceSidecar, HumanGatedTask (via MilestoneGate) |

## Related BCs

- **BC-4.03.001** (parent): `likeness_consent_ref` is a field in the sidecar constructed by BC-4.03.001
- **BC-4.06.001** (downstream): ingest gate checks `ship_blocked` flag; this BC is the setter
- **BC-4.05.001** (sibling at ship gate): license check runs in parallel with consent check at ship gate

## Architecture Anchors

- DI-006: invariants.md §DI-006
- FM-005: failure-modes.md §FM-005
- R-004: risks.md §R-004
- RECONCILIATION §12 R-004: "SAG-AFTRA ICDR rules; `likeness-consent-ref` for any voice; `human-gated` signature flow when `likeness_consent_ref != null`"
- SAG-AFTRA 2025 Interactive Media Agreement (ratified Jul 9, 2025): consent + compensation for ICDR
- PROC-006: processes.md §PROC-006 (Human-Gated Task Surfacing)

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
