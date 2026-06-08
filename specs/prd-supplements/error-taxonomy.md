---
document_type: prd-supplement
level: L3
section: error-taxonomy
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
traces_to: prd.md
inputs:
  - .factory/specs/prd-supplements/prd-cap-001.md
  - .factory/specs/prd-supplements/prd-cap-005.md
  - .factory/specs/prd-supplements/prd-cap-009-010.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Consolidated Error Taxonomy — game-factory

> **Rolled up from per-supplement error sections per DF-021 integrate pass.**
> Per-supplement error tables in source files remain canonical. This document
> provides the single-registry view for implementers and test-writers.
>
> Convention: `E-{FAMILY}-{NNN}` where FAMILY = subsystem abbreviation (3-5 chars).
> Severity levels: `broken` = pipeline halt; `degraded` = partial functionality, no halt; `cosmetic` = warning only.

---

## Family Registry

| Family | Owning Capability | Description | Supplement Source |
|--------|------------------|-------------|-------------------|
| E-EAP | CAP-001 | Engine Adapter Protocol errors | prd-cap-001.md §5 |
| E-DES | CAP-005 | Design artifact schema and invariant errors | prd-cap-005.md §5 |
| E-ART | CAP-005 | Art asset quality gate errors | prd-cap-005.md §5 |
| E-AUD | CAP-005 | Audio build and loudness errors | prd-cap-005.md §5 |
| E-NAR | CAP-005 | Narrative graph structural errors | prd-cap-005.md §5 |
| E-ENG | CAP-005 | Code module separation and TDD gate errors | prd-cap-005.md §5 |
| E-CIN | CAP-005 | Cinematic / sequence graph errors | prd-cap-005.md §5 |
| E-PROD | CAP-005 | Cross-discipline production / wave ordering errors | prd-cap-005.md §5 |
| E-CERT | CAP-009 | Cert pre-flight errors | prd-cap-009-010.md §4 |
| E-DIST | CAP-009 | Distribution adapter and upload tool errors | prd-cap-009-010.md §4 |
| E-COMP | CAP-010 | Compliance pipeline errors | prd-cap-009-010.md §4 |

---

## E-EAP — Engine Adapter Protocol (CAP-001)

| Error Code | JSON-RPC Code | Name | Trigger Condition | Severity |
|-----------|--------------|------|-------------------|----------|
| E-EAP-001 | -32000 | ProtocolVersionMismatch | `initialize` when adapter's supported range excludes core's `protocolVersion` | broken |
| E-EAP-002 | -32001 | CapabilityUnsupported | Calling a capability with `fidelity: none` | degraded |
| E-EAP-003 | -32002 | ProfileUnavailable | Requested execution profile not available (no lavapipe/xvfb) | degraded |
| E-EAP-004 | -32003 | EngineToolMissing | Engine binary/tool/license not present (Unity .ulf, Godot export templates) | broken |
| E-EAP-005 | -32004 | DeterminismTierViolation | Snapshot-hash-diff requested from tolerance-only adapter | broken |
| E-EAP-006 | -32005 | OperationFailed | Engine operation ran but failed (build error, test runner crash) | broken |
| E-EAP-007 | -32006 | Cancelled | Request cancelled via `$/cancelRequest` | cosmetic |
| E-EAP-008 | -32600 | InvalidRequest | Malformed JSON-RPC envelope | broken |
| E-EAP-009 | -32601 | MethodNotFound | Method name unknown to adapter | broken |
| E-EAP-010 | -32700 | ParseError | Message is not valid JSON | broken |

---

## E-DES — Design Artifact Schema (CAP-005)

Message format uses `<placeholder>` syntax for dynamic values.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-DES-001 | Schema validation | broken | 1 | `design-spec validation failed: <field> missing or invalid at <path>` |
| E-DES-002 | Engine-neutrality | broken | 1 | `engine-specific construct '<term>' found in <artifact>:<field> — violates DI-008` |
| E-DES-003 | Balance band | broken | 1 | `economy-graph balance check failed: <metric> = <value>, expected [<min>, <max>]` |
| E-DES-004 | Conservation invariant | broken | 1 | `economy-graph conservation violated: <invariant> net flow = <value> (expected 0 ± <tol>)` |
| E-DES-005 | Accessibility contract | broken | 1 | `accessibility-contract: required feature '<feature>' absent; GAG/XAG ID <id> not satisfied` |

---

## E-ART — Art Asset Quality Gate (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ART-001 | GLB quality gate | broken | 1 | `asset '<id>' failed quality gate: <check> = <value>, threshold = <threshold>` |
| E-ART-002 | Provenance sidecar | broken | 1 | `asset '<id>' missing provenance sidecar field '<field>' — violates DI-003` |
| E-ART-003 | Art bible schema | broken | 1 | `art-bible.spec validation failed: <field> at <path>` |

---

## E-AUD — Audio Build (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-AUD-001 | Bank build | broken | 1 | `audio bank build failed: <platform>/<bank_id>: <error>` |
| E-AUD-002 | Loudness conformance | broken | 1 | `audio bank '<bank_id>' loudness = <lufs> LUFS, target = <target> ±2 LUFS` |
| E-AUD-003 | True-peak | broken | 1 | `audio bank '<bank_id>' true-peak = <dBTP> dBTP, ceiling = -1 dBTP` |
| E-AUD-004 | AI audio provenance | broken | 1 | `audio asset '<id>' not covered by ai-audio-provenance-ledger — violates DI-003` |

---

## E-NAR — Narrative Graph (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-NAR-001 | Dead-end node | broken | 1 | `narrative-graph '<graph_id>' dead-end detected at node '<node_id>': no outgoing edges and not declared end` |
| E-NAR-002 | Unreachable node | broken | 1 | `narrative-graph '<graph_id>' unreachable node '<node_id>': no path from start` |
| E-NAR-003 | Dangling entity ref | broken | 1 | `narrative node '<node_id>' references canon entity '<entity_id>' not in Canon-KB` |
| E-NAR-004 | Timeline inconsistency | broken | 1 | `Canon-KB timeline event '<event_id>' at t=<t1> conflicts with event '<event_id2>' at t=<t2>: <conflict>` |

---

## E-ENG — Code Module Separation (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ENG-001 | Logic-presentation coupling | broken | 1 | `code module '<module>' imports presentation-layer symbol '<sym>' — violates pure-sim separation` |
| E-ENG-002 | Red Gate violation | broken | 1 | `production code commit exists without a prior failing test for story '<story_id>'` |

---

## E-CIN — Cinematic / Sequence Graph (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-CIN-001 | Sequence asset ref | broken | 1 | `sequence-graph '<seq_id>' asset ref '<ref>' does not resolve` |
| E-CIN-002 | Subtitle coverage | broken | 1 | `sequence-graph '<seq_id>' audio event '<event_id>' has no subtitle track` |
| E-CIN-003 | Directed flag missing gate | broken | 1 | `sequence-graph '<seq_id>' has directed=true but no cinematic-director sign-off record found` |
| E-CIN-004 | Blendshape range | broken | 1 | `lip-sync '<clip_id>' blendshape '<shape>' value <v> outside [0, 1]` |

---

## E-PROD — Cross-Discipline Production (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-PROD-001 | Missing dependency contract | broken | 1 | `wave '<wave_id>' starts discipline '<consumer>' but cross-discipline-dependency-contract from '<producer>' not found` |
| E-PROD-002 | Dependency acceptance fail | broken | 1 | `cross-discipline-dependency-contract '<contract_id>' acceptance criterion '<crit_id>' failed: <assertion>` |
| E-PROD-003 | Wave ordering violation | broken | 1 | `wave '<wave_id>' started but dependency '<dep_wave_id>' not yet green in discipline DAG` |

---

## E-CERT — Cert Pre-Flight (CAP-009)

| Error Code | Subsystem | Trigger Condition | Exit Code |
|-----------|-----------|-------------------|-----------|
| E-CERT-001 | cert-preflight | Build artifact path does not exist | 1 |
| E-CERT-002 | cert-preflight | No cert-preflight-config for target platform | 1 |
| E-CERT-003 | cert-preflight | Checklist version unknown | 1 |

---

## E-DIST — Distribution Adapter and Upload Tools (CAP-009)

| Error Code | Subsystem | Trigger Condition | Exit Code |
|-----------|-----------|-------------------|-----------|
| E-DIST-001 | distribution-adapter | Invalid fidelity value in manifest | 1 |
| E-DIST-002 | distribution-adapter | `human-gated` capability missing `human_task` descriptor | 1 |
| E-DIST-003 | distribution-adapter | Required capability not declared | 1 |
| E-DIST-004 | distribution-adapter | `console cert_sign_off` declared as `full` (forbidden) | 1 |
| E-DIST-005 | distribution-adapter | Duplicate `adapter_id` | 1 |
| E-DIST-010 | steamcmd | steamcmd exited with non-zero code | 1 |
| E-DIST-011 | steamcmd | steamcmd binary not found | 1 |
| E-DIST-012 | steamcmd | Required environment variable not set | 1 |
| E-DIST-013 | steamcmd | Failed to write build-upload-record | 1 |
| E-DIST-020 | butler | butler push exited with non-zero code | 1 |
| E-DIST-021 | butler | butler binary not found | 1 |
| E-DIST-022 | butler | butler API key env var not set | 1 |
| E-DIST-023 | butler | build_path does not exist | 1 |
| E-DIST-030 | fastlane | fastlane exited with non-zero code | 1 |
| E-DIST-031 | fastlane | fastlane action not in verified allow-list | 1 |
| E-DIST-032 | fastlane | fastlane binary not found | 1 |
| E-DIST-033 | fastlane | Required fastlane env var not set | 1 |
| E-DIST-040 | distribution-pipeline | cert-preflight-report missing for build version | 1 |
| E-DIST-050 | store-asset | No store-asset-spec for target platform | 1 |

---

## E-COMP — Compliance Pipeline (CAP-010)

| Error Code | Subsystem | Trigger Condition | Exit Code |
|-----------|-----------|-------------------|-----------|
| E-COMP-001 | IARC | Questionnaire version not recognized | 1 |
| E-COMP-010 | AI-disclosure | Shipped asset missing required provenance sidecar field (DI-003 violation) | 1 |

---

## Coverage Gaps (Flagged for Adversarial Pass)

The following capabilities have **no error taxonomy defined** in their supplements and were not extracted into a family above. The adversarial pass should verify whether these caps need error codes or if errors are entirely covered by EAP / embedded in BC postconditions.

| Capability | Status | Notes |
|-----------|--------|-------|
| CAP-002 (Conformance Gating) | No error table in supplement | Conformance failure modeled as return value, not error code |
| CAP-003 (Replay Regression) | No error table in supplement | Regression failure modeled as TestResult, not error code |
| CAP-004 (Asset Generation) | No error table in supplement | Quality gate failures returned in GenerationResult; may need E-GEN family |
| CAP-006 (Simulation QA) | No error table in supplement | Contract violations returned in verification result |
| CAP-007 (Convergence) | No error table in supplement | Dimension failures expressed as dimension status, not error codes |
| CAP-008 (Playtest) | No error table in supplement | Sign-off blocking is a task state, not error code |
| CAP-011 (Monetization Ethics) | No error table in supplement | Dark pattern violations may need E-ETH family |
| CAP-012 (Canon KB) | No error table in supplement | Entity conflicts returned in query results |
| CAP-013 (Genre Lanes) | No error table in supplement | Schema errors likely reuse E-DES |
| CAP-014 (XR Seam) | No error table in supplement | XR manifest errors may need E-XR family |

**Total defined error codes: 59** across 11 families.
**Families with gaps: 10** capabilities have no error families — flagged for resolution in adversarial pass.
