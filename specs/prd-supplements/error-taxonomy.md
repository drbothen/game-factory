---
document_type: prd-supplement
level: L3
section: error-taxonomy
version: "2.4"
status: draft
producer: product-owner
timestamp: 2026-06-09T00:00:00Z
phase: 1d
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
| E-CONF | CAP-002 | Engine adapter conformance suite errors | error-taxonomy.md §E-CONF (added PRD rev 1.1) |
| E-REPLAY | CAP-003 | Deterministic replay harness errors | error-taxonomy.md §E-REPLAY (added PRD rev 1.1) |
| ~~E-GEN~~ | ~~CAP-004~~ | ~~Asset generation pipeline placeholder errors~~ | ~~error-taxonomy.md §E-GEN (added PRD rev 1.1)~~ **REMOVED PRD rev 1.6 — orphaned placeholder; no BC ever referenced these codes; superseded by E-AAG/E-SVC/E-QG/E-SHIP/E-ING/E-PRV** |
| E-AAG | CAP-004 | Asset-adapter routing and generation orchestrator errors (BC-4.01.*) | error-taxonomy.md §E-AAG (added PRD rev 1.6) |
| E-SVC | CAP-004 | GenerationRequest service validation errors (BC-4.02.*) | error-taxonomy.md §E-SVC (added PRD rev 1.6) |
| E-QG | CAP-004 | Quality gate per-modality check failures (BC-4.04.*) | error-taxonomy.md §E-QG (added PRD rev 1.6) |
| E-SHIP | CAP-004 | Ship gate license-check failures (BC-4.05.001) | error-taxonomy.md §E-SHIP (added PRD rev 1.6) |
| E-ING | CAP-004 | Asset store ingest pre-flight errors (BC-4.06.001) | error-taxonomy.md §E-ING (added PRD rev 1.6) |
| E-DES | CAP-005 | Design artifact schema and invariant errors | prd-cap-005.md §5 |
| E-ART | CAP-005 | Art asset quality gate errors | prd-cap-005.md §5 |
| E-AUD | CAP-005 | Audio build and loudness errors | prd-cap-005.md §5 |
| E-NAR | CAP-005 | Narrative graph structural errors | prd-cap-005.md §5 |
| E-ENG | CAP-005 | Code module separation and TDD gate errors | prd-cap-005.md §5 |
| E-CIN | CAP-005 | Cinematic / sequence graph errors | prd-cap-005.md §5 |
| E-PROD | CAP-005 | Cross-discipline production / wave ordering errors | prd-cap-005.md §5 |
| E-SIM | CAP-006 | Simulation quality verification contract errors | error-taxonomy.md §E-SIM (added PRD rev 1.1) |
| E-CONV | CAP-007 | 11-dimension convergence evaluation errors | error-taxonomy.md §E-CONV (added PRD rev 1.1) |
| E-PLAY | CAP-008 | Structured playtest protocol errors | error-taxonomy.md §E-PLAY (added PRD rev 1.1) |
| E-CERT | CAP-009 | Cert pre-flight errors | prd-cap-009-010.md §4 |
| E-DIST | CAP-009 | Distribution adapter and upload tool errors | prd-cap-009-010.md §4 |
| E-COMP | CAP-010 | Compliance pipeline errors (E-COMP-010: missing sidecar field; E-COMP-011: out-of-vocab disclosure_class at manifest aggregation; E-COMP-012: 3-signal NFT inconsistency seam guard — nft_blockchain / nft_mechanics / NFT_MECHANIC content-descriptor tag; F37-01 extended scope) | prd-cap-009-010.md §4 |
| E-ETH | CAP-011 | Monetization ethics contract errors | error-taxonomy.md §E-ETH (added PRD rev 1.1) |
| E-KB | CAP-012 | Canon Knowledge-Base structural errors | error-taxonomy.md §E-KB (added PRD rev 1.1) |
| E-GENRE | CAP-013 | Genre-gated lane activation errors (E-GENRE covers core lane-activation BCs; E-GLG, E-MOD, E-MKT cover sub-lane BCs) | error-taxonomy.md §E-GENRE (added PRD rev 1.1) |
| E-GLG | CAP-013 | Genre-lane gate schema/config errors for sub-lane BCs (BC-13.01.*/13.02.*/13.03.*/13.04.*) | error-taxonomy.md §E-GLG (added PRD rev 1.6) |
| E-MOD | CAP-013 | Modding/UGC lane errors (BC-13.03.*) | error-taxonomy.md §E-MOD (added PRD rev 1.6) |
| E-MKT | CAP-013 | Marketing lane asset conformance errors (BC-13.04.*) | error-taxonomy.md §E-MKT (added PRD rev 1.6) |
| E-TMOD | CAP-013 | Moderation pipeline contract errors — UGC/chat CSAM reporting + fail-closed enforcement (BC-13.03.005); scope: modding_enabled=true OR user_to_user_communication=true | error-taxonomy.md §E-TMOD (added PRD rev 2.3 Pass-42; scope corrected rev 2.4 F44-01) |
| E-ANTICH | CAP-013 | Anti-cheat integration adapter errors — provider allowlist + kernel-anomaly rejection (BC-13.02.006); scope: esports_enabled=true | error-taxonomy.md §E-ANTICH (added PRD rev 2.3 Pass-42; scope corrected rev 2.4 F44-01) |
| E-SEC | CAP-001 | Output-bundle secrets gate errors — secret-pattern scan + entropy scan (BC-1.15.003) | error-taxonomy.md §E-SEC (added PRD rev 2.3 Pass-42) |
| E-XR | CAP-014 | XR platform seam errors | error-taxonomy.md §E-XR (added PRD rev 1.1) |
| E-PRV | CAP-004 | Provenance sidecar field validation errors (`disclosure_class` + sidecar completeness) | error-taxonomy.md §E-PRV (added PRD rev 1.2; extended rev 1.6) |
| E-OSVC | CAP-015 | Online-Services Adapter errors (identity, cloud-save, leaderboards, matchmaking, entitlements, remote-config, seam integrity) | prd-supplements/prd-cap-015.md §5 (populated PRD rev 1.9) |

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
| E-EAP-011 | -32009 | KernelAntiCheatAttempted | Factory output artifact contains kernel-mode anti-cheat code pattern (DI-010 violation; BC-1.15.002) | broken |
| E-EAP-012 | -32007 | MalformedManifest | Manifest returned from `initialize` is missing required fields (adapter-protocols.md §1.3) | broken |
| E-EAP-013 | -32008 | HumanGatedTaskPending | Attempted to proceed past a `human-gated` boundary without acknowledgment (DI-006; load-bearing signal: ADR-0007) | broken |

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

The symbolic error names emitted by individual BCs are carried as the `error.data.reason`
sub-code of the registered parent E-NAR-NNN code where the condition does not warrant its
own registered code. E-NAR-003 covers the broad class of dangling references; E-NAR-005
and E-NAR-006 are dedicated codes for conditions that were previously incorrectly described
as "E-NAR-003 variants" (F-20-02 fix: no "variant" language is permitted — every condition
resolves to a registered code).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-NAR-001 | Dead-end node | broken | 1 | `narrative-graph '<graph_id>' dead-end detected at node '<node_id>': no outgoing edges and not declared end` |
| E-NAR-002 | Unreachable node | broken | 1 | `narrative-graph '<graph_id>' unreachable node '<node_id>': no path from start` |
| E-NAR-003 | Dangling entity ref | broken | 1 | `narrative node '<node_id>' references canon entity '<entity_id>' not in Canon-KB` |
| E-NAR-004 | Timeline inconsistency | broken | 1 | `Canon-KB timeline event '<event_id>' at t=<t1> conflicts with event '<event_id2>' at t=<t2>: <conflict>` |
| E-NAR-005 | Undeclared variable reference | broken | 1 | `narrative-graph '<graph_id>' node '<node_id>' references variable '<var_name>' not declared in variables array (BC-5.04.001 postcondition 3)` |
| E-NAR-006 | Invalid naming-registry pattern | broken | 1 | `canon-kb naming_registry entry '<registry_id>' pattern is not valid regex or string template syntax: <parse_error> (BC-5.04.002 EC-004 schema check)` |

---

## E-ENG — Code Module Separation (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ENG-001 | Logic-presentation coupling | broken | 1 | `code module '<module>' imports presentation-layer symbol '<sym>' — violates pure-sim separation` |
| E-ENG-002 | Red Gate violation | broken | 1 | `production code commit exists without a prior failing test for story '<story_id>'` |
| E-ENG-003 | Module unclassified | broken | 1 | `code module '<module>' has no declared module_type in factory manifest — classification required before lint` |
| E-ENG-004 | Test scoped to wrong module | broken | 1 | `test file '<file>' does not reference the story's assigned module '<module>' — test-writer must correct scope` |

---

## E-CIN — Cinematic / Sequence Graph (CAP-005)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-CIN-001 | Sequence asset ref | broken | 1 | `sequence-graph '<seq_id>' asset ref '<ref>' does not resolve` |
| E-CIN-002 | Subtitle coverage | broken | 1 | `sequence-graph '<seq_id>' audio event '<event_id>' has no subtitle track` |
| E-CIN-003 | Directed flag missing creative gate | broken | 1 | `sequence-graph '<seq_id>' has directed=true but no cinematic-director creative sign-off record found (creative gate, not human-gated fidelity tier — see D-013 distinction in methodology-layer.md §2.8)` |
| E-CIN-004 | Blendshape range | broken | 1 | `lip-sync '<clip_id>' blendshape '<shape>' value <v> outside [0, 1]` |
| E-CIN-005 | Sequence timestamp out of range | broken | 1 | `sequence-graph '<seq_id>' track event at timestamp <t>s is outside valid range [0, <duration>s]` |
| E-CIN-006 | Blendshape track set incomplete | broken | 1 | `lip-sync '<clip_id>' blendshape track set does not match ARKit-52; missing or extra tracks: <track_list>` |

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
| E-COMP-010 | AI-disclosure | Shipped asset MISSING required provenance sidecar field (DI-003 violation) — field absent or null | 1 |
| E-COMP-011 | AI-disclosure | Inbound sidecar `disclosure_class` value is out-of-vocabulary at manifest aggregation — field is present but its value is not in `{pre-generated, live-generated, procedural-exempt}` (parallel to E-PRV-011 at generation time; added PRD rev 1.7) | 1 |
| E-COMP-012 | IARC-compliance | Any divergence among the three NFT activation signals — `game-metadata-spec.nft_blockchain`, `genre-profile.nft_mechanics`, and/or `NFT_MECHANIC` in `game-metadata-spec.content_descriptors[]` — where signals disagree about NFT-active status; conservative PEGI-18 applied and manifest flagged for human review (DI-011 3-signal seam guard; scope extended F37-01 from 2-signal to 3-signal) | 1 |

---

---

## E-CONF — Engine Adapter Conformance Suite (CAP-002)

Conformance failures use structured return values for pass/fail verdicts on individual
test cases. The error codes below cover infrastructure and metadata failures that prevent
a conformance run from completing or reporting correctly.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-CONF-001 | Suite config | broken | 1 | `conformance: no capability-filter config for adapter '<adapter_id>'` |
| E-CONF-002 | Version mismatch | broken | 1 | `conformance: suite version '<suite_ver>' incompatible with adapter protocol '<proto_ver>'` |
| E-CONF-003 | Reference game missing | broken | 1 | `conformance: reference mini-game artifact not found at '<path>'` |
| E-CONF-004 | Acceptance gate | broken | 1 | `conformance: adapter '<adapter_id>' failed acceptance gate — writes blocked until conformance passes` |
| E-CONF-005 | Scheduled re-run failure | degraded | 0 | `conformance: scheduled anti-drift re-run for '<adapter_id>' v<engine_ver> failed; drift alert raised` |

---

## E-REPLAY — Deterministic Replay Harness (CAP-003)

Replay regression failures are reported in the `TestResult` schema. The error codes below
cover harness infrastructure failures distinct from regression detection results.

The symbolic error names emitted by individual BCs are carried as the `error.data.reason`
sub-code of the registered parent E-REPLAY-NNN code (same pattern as E-ETH).

**E-REPLAY Symbolic→Registered Code Crosswalk:**

| Symbolic Token | Registered E-REPLAY Code | Context / Enforcing BC |
|---|---|---|
| REPLAY_CAPABILITY_NONE | E-REPLAY-008 | BC-3.03.001 EC-007: recording attempted on adapter with replay: none |
| RECORDING_FRAME_GAP | E-REPLAY-009 | BC-3.03.002 EC-001: gap in frame numbers in recording |
| INCOMPATIBLE_REPLAY_ENGINE_VERSION | E-REPLAY-010 | BC-3.03.002 Invariant 4: replay engine version outside valid range for recording |
| GOLDEN_STATE_INVALIDATED | E-REPLAY-011 | BC-3.03.008 Postconditions for Invalidation: golden state explicitly invalidated |
| GOLDEN_STATE_ABSENT | E-REPLAY-012 | BC-3.03.008 EC-001/003: no golden state ever captured or replaced after invalidation |
| UNAUTHORIZED_GOLDEN_STATE_CAPTURE | E-REPLAY-013 | BC-3.03.008 EC-004: capture attempted without producer-role authorization |
| INSUFFICIENT_DETERMINISM_TIER_FOR_EXPORT | E-REPLAY-014 | BC-3.03.009 EC-001: demo/anti-cheat export rejected for T3 adapter |
| LANE_NOT_ACTIVE | E-REPLAY-015 | BC-3.03.009 EC-002: esports/demo export when competitive lane not active |
| SERVER_STATE_MISSING | E-REPLAY-016 | BC-3.03.009 EC-005: anti-cheat evidence package blocked; server snapshots absent |
| BROADCAST_DELAY_ZERO_STREAM_SNIPE_RISK | E-REPLAY-017 | BC-3.03.009 EC-004: broadcast delay 0 for demo export (cosmetic warning) |
| CHECKPOINT_MISMATCH | E-REPLAY-018 | BC-3.03.003 EC-002: checkpoint frames in golden and replay do not align |

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-REPLAY-001 | Input stream | broken | 1 | `replay: input-stream file '<path>' missing or corrupt for session '<session_id>'` |
| E-REPLAY-002 | Tier mismatch | broken | 1 | `replay: requested comparison method '<method>' not available for declared tier '<tier>'` |
| E-REPLAY-003 | Golden state missing | broken | 1 | `replay: golden-state snapshot not found for '<session_id>' v<version> — bootstrap required` |
| E-REPLAY-004 | Golden state invalid | broken | 1 | `replay: golden-state snapshot '<snapshot_id>' failed integrity check; re-bootstrap required` |
| E-REPLAY-005 | Regression detected | broken | 1 | `replay: T1 regression at frame <frame_id>: snapshot hash mismatch — injected change or non-determinism detected` |
| E-REPLAY-006 | Replay diverged (T2) | degraded | 1 | `replay: T2 pinned-runner divergence at frame <frame_id>: <diff_summary>` |
| E-REPLAY-007 | Tolerance exceeded (T3) | degraded | 1 | `replay: T3 metric '<metric>' at frame <frame_id> = <value>, tolerance = ±<tol>` |
| E-REPLAY-008 | Replay capability none | broken | 1 | `replay: recording rejected — adapter '<adapter_id>' declares replay: none; no input-stream recording possible; error.data.reason = REPLAY_CAPABILITY_NONE` |
| E-REPLAY-009 | Recording frame gap | broken | 1 | `replay: recording '<recording_id>' has gap in frame sequence — frame <frame_id> absent; recording invalid for regression use; error.data.reason = RECORDING_FRAME_GAP` |
| E-REPLAY-010 | Incompatible engine version | broken | 1 | `replay: engine version '<engine_ver>' for replay is outside the valid range for recording from '<recorded_ver>'; error.data.reason = INCOMPATIBLE_REPLAY_ENGINE_VERSION` |
| E-REPLAY-011 | Golden state invalidated | broken | 1 | `replay: golden state '<golden_state_id>' for game '<game_id>' + adapter '<adapter_id>' is invalidated — reason: <reason>; re-bootstrap required before regression can run; error.data.reason = GOLDEN_STATE_INVALIDATED` |
| E-REPLAY-012 | Golden state absent | broken | 1 | `replay: no active golden state found for game '<game_id>' + adapter '<adapter_id>'; tests/replay dimension blocked: golden_state_required; bootstrap task generated; error.data.reason = GOLDEN_STATE_ABSENT` |
| E-REPLAY-013 | Unauthorized golden state capture | broken | 1 | `replay: golden state capture for '<game_id>' rejected — producer-role authorization required; error.data.reason = UNAUTHORIZED_GOLDEN_STATE_CAPTURE` |
| E-REPLAY-014 | Insufficient determinism tier for export | broken | 1 | `replay: demo/anti-cheat export rejected — adapter '<adapter_id>' has determinism_tier: tolerance-only; T1 or T2 required for export integrity; error.data.reason = INSUFFICIENT_DETERMINISM_TIER_FOR_EXPORT` |
| E-REPLAY-015 | Lane not active for export | broken | 1 | `replay: esports/anti-cheat export rejected — competitive-multiplayer lane is not active for game '<game_id>'; error.data.reason = LANE_NOT_ACTIVE` |
| E-REPLAY-016 | Server state missing | broken | 1 | `replay: anti-cheat evidence package cannot be produced — server-authoritative state snapshots absent for recording '<recording_id>'; error.data.reason = SERVER_STATE_MISSING` |
| E-REPLAY-017 | Broadcast delay zero | cosmetic | 0 | `replay: demo export for '<recording_id>' has broadcast_delay = 0s — stream-snipe risk in live tournaments; error.data.reason = BROADCAST_DELAY_ZERO_STREAM_SNIPE_RISK` |
| E-REPLAY-018 | Checkpoint mismatch | degraded | 0 | `replay: golden and replay checkpoint frames do not fully align for recording '<recording_id>'; comparison performed on intersection only — non-intersecting golden frames flagged; error.data.reason = CHECKPOINT_MISMATCH` |

---

## ~~E-GEN — Asset Generation Pipeline (CAP-004)~~ [RETIRED PRD rev 1.6]

> **Status: RETIRED.** E-GEN was a placeholder family added in PRD rev 1.1. No BC in ss-04
> (or any other subsystem) ever referenced any E-GEN-NNN code. The ss-04 BCs use the granular
> families E-AAG, E-SVC, E-PRV, E-QG, E-SHIP, and E-ING, which were introduced in PRD rev 1.6.
> E-GEN codes are preserved here for historical traceability but are not emitted by any
> implementation path. The 9 E-GEN codes are **removed from the active count** (139 → 130
> pre-addition, then 130 + 57 new codes = 187 final total).
>
> Retained for reference:

| ~~Error Code~~ | ~~Category~~ | ~~Severity~~ | ~~Exit Code~~ | ~~Message Format~~ |
|---|---|---|---|---|
| ~~E-GEN-001~~ | Backend blocked | broken | 1 | `asset-gen: backend '<backend_id>' is ToS-excluded or litigation-exposed — generation refused` |
| ~~E-GEN-002~~ | Schema invalid | broken | 1 | `asset-gen: GenerationRequest validation failed: <field> at <path>` |
| ~~E-GEN-003~~ | Sidecar incomplete | broken | 1 | `asset-gen: provenance sidecar for asset '<asset_id>' missing required field '<field>' — ingest blocked (DI-003)` |
| ~~E-GEN-004~~ | Disclosure class invalid | broken | 1 | `asset-gen: asset '<asset_id>' has invalid disclosure_class '<value>'; expected one of [pre-generated, live-generated, procedural-exempt]` |
| ~~E-GEN-005~~ | Consent gate | broken | 1 | `asset-gen: asset '<asset_id>' has likeness_consent_ref but no human-gated SAG-AFTRA task has been created` |
| ~~E-GEN-006~~ | Quality gate fail | broken | 1 | `asset-gen: asset '<asset_id>' failed quality gate check '<check>': <value> vs threshold <threshold>` |
| ~~E-GEN-007~~ | License gate fail | broken | 1 | `asset-gen: ship gate blocked — asset '<asset_id>' has commercial_use: false or unresolved free-tier restriction` |
| ~~E-GEN-008~~ | Backend routing fail | broken | 1 | `asset-gen: no eligible backend for asset class '<class>' after applying preference ordering and blocklist` |
| ~~E-GEN-009~~ | Risk tier absent | broken | 1 | `asset-gen: GenerationRequest '<req_id>' has no risk_tier assigned — required before dispatch` |

---

## E-AAG — Asset-Adapter Routing and Generation Orchestrator (CAP-004, BC-4.01.*)

Errors emitted during adapter registry validation (BC-4.01.001) and orchestrator backend
selection (BC-4.01.002, BC-4.01.003, BC-4.01.004).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-AAG-001 | Backend class missing | broken | 1 | `asset-gen: adapter manifest rejected — backend_class is required; field absent or null` |
| E-AAG-002 | Backend class invalid value | broken | 1 | `asset-gen: adapter manifest rejected — backend_class '<value>' is not a recognized taxonomy value; allowed: {cloud-api, headless-cli, mcp-headless, mcp-gui, saas-ui, desktop-gui}` |
| E-AAG-010 | No eligible adapter after exclusions | broken | 1 | `asset-gen: no eligible adapter for asset_class '<class>' after exclusions (ToS-blocklist, desktop-gui filter, music-litigation-blocklist)` |
| E-AAG-011 | No adapter registered for asset class | broken | 1 | `asset-gen: no adapter registered for asset_class '<class>'` |
| E-AAG-020 | Blocklisted music adapter reached selection | broken | 1 | `asset-gen: music adapter '<id>' is on litigation-blocklist; music route requires licensed provider (DI-009)` |
| E-AAG-021 | No licensed music adapter available | broken | 1 | `asset-gen: no licensed music adapter available; music generation requires a DI-009-compliant provider (stable-audio, aiva, soundraw, or configured allowlist entry)` |
| E-AAG-022 | tool_preference override to blocked music provider | broken | 1 | `asset-gen: tool_preference overrides to blocked music provider '<id>' are not permitted; DI-009 policy` |

---

## E-SVC — GenerationRequest Service Validation (CAP-004, BC-4.02.*)

Errors emitted during GenerationRequest schema validation (BC-4.02.001) and risk-tier
assignment (BC-4.02.002). All E-SVC errors cause the request to be rejected before any
backend contact.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-SVC-001 | Required field missing | broken | 1 | `asset-gen: generation request schema invalid: missing required field(s): <list>` |
| E-SVC-002 | Field value invalid | broken | 1 | `asset-gen: generation request schema invalid: field '<name>' value '<value>' is not in allowed set / wrong type` |
| E-SVC-003 | Art direction ref unresolved | broken | 1 | `asset-gen: generation request art_direction_refs contain unresolved Canon-KB IDs: <list>` |
| E-SVC-004 | Modality/asset_class incompatible | broken | 1 | `asset-gen: generation request modality '<m>' is not valid for asset_class '<c>'` |
| E-SVC-005 | Duplicate request_id | broken | 1 | `asset-gen: generation request '<req_id>' duplicates an in-flight request_id; deduplicate before re-submitting` |
| E-SVC-010 | Risk tier mismatch | broken | 1 | `asset-gen: risk_tier mismatch: computed '<n>' but request specifies '<m>' with no justification; provide risk_tier_override_justification or correct the declared tier` |

---

## E-PRV — Provenance Sidecar Field Validation (CAP-004)

E-PRV codes cover two sub-groups:
- **E-PRV-001..003** (added PRD rev 1.6): sidecar completeness errors from BC-4.03.001
  (missing/truncated fields caught at generation time).
- **E-PRV-010..012** (added PRD rev 1.2): disclosure_class decision-tree failures from
  BC-4.03.002.
- **E-PRV-020** (added PRD rev 1.6): copyrightability_assessment absent from sidecar
  (BC-4.03.003 failure path).
- **E-PRV-030** (added PRD rev 1.6): ship gate blocked by outstanding SAG-AFTRA consent
  task (BC-4.03.004 failure path + BC-4.05.001 enforcement).

E-PRV-010/011/012 are emitted during the BC-4.03.002 decision-tree evaluation step
specifically (disclosure_class field); E-PRV-001/002/003 are emitted during BC-4.03.001
sidecar construction. Implementers should raise E-PRV-010/011/012 when the validation
failure is specifically the `disclosure_class` field value.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-PRV-001 | Sidecar required field missing | broken | 1 | `asset-gen: provenance sidecar incomplete: missing required fields <list> — ingest blocked (BC-4.03.001 failure path A)` |
| E-PRV-002 | Prompt log truncated | broken | 1 | `asset-gen: provenance prompt log appears truncated; re-generation required — log length below 80% of input (BC-4.03.001 failure path B)` |
| E-PRV-003 | model_version invalid value 'unknown' | broken | 1 | `asset-gen: model_version 'unknown' is not a valid provenance value; use 'backend-opaque' if the adapter does not expose version (BC-4.03.001 failure path C)` |
| E-PRV-010 | Disclosure class null/absent | broken | 1 | `asset-gen: asset '<asset_id>' sidecar missing disclosure_class — field is required and may not be null (BC-4.03.002 failure path A)` |
| E-PRV-011 | Disclosure class out-of-vocabulary | broken | 1 | `asset-gen: asset '<asset_id>' disclosure_class '<value>' not in allowed set {pre-generated, live-generated, procedural-exempt} (BC-4.03.002 failure path B)` |
| E-PRV-012 | Procedural-exempt misuse on neural model | broken | 1 | `asset-gen: asset '<asset_id>' disclosure_class 'procedural-exempt' invalid for neural-model adapter '<adapter_id>'; only classical procedural generation qualifies (BC-4.03.002 failure path C)` |
| E-PRV-020 | copyrightability_assessment absent | broken | 1 | `asset-gen: copyrightability_assessment is required but was not computed; sidecar construction error (BC-4.03.003 failure path)` |
| E-PRV-030 | SAG-AFTRA consent outstanding at ship gate | broken | 1 | `asset-gen: ship build contains asset '<id>' with outstanding SAG-AFTRA likeness consent task '<task_id>'; consent must be signed before shipping (BC-4.03.004 / BC-4.05.001)` |

---

## E-QG — Quality Gate Per-Modality Checks (CAP-004, BC-4.04.*)

Errors emitted by the per-modality quality gate for 3D mesh (BC-4.04.001), audio
(BC-4.04.002), and 2D image (BC-4.04.003) assets. E-QG-005 is shared across all three
quality gate BCs (provenance completeness failure — always a hard gate for all tiers).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-QG-001 | Non-manifold geometry | broken | 1 | `quality-gate: 3D mesh '<asset_id>' failed manifold check — non-manifold edges: <n>, non-manifold vertices: <m>` |
| E-QG-002 | Polycount over budget | broken | 1 | `quality-gate: 3D mesh '<asset_id>' face count <actual> exceeds budget <max>` |
| E-QG-003 | UV distortion / coverage | broken | 1 | `quality-gate: 3D mesh '<asset_id>' UV check failed — distortion score: <score> (threshold 0.3), UV coverage: <coverage> (threshold 0.7)` |
| E-QG-004 | PBR channels missing | broken | 1 | `quality-gate: 3D mesh '<asset_id>' PBR channels missing: <list>; required: albedo, metalness, roughness, normal` |
| E-QG-005 | Provenance completeness (all modalities) | broken | 1 | `quality-gate: asset '<asset_id>' failed provenance completeness check — sidecar schema invalid or disclosure_class / copyrightability_assessment absent; hard gate for all tiers` |
| E-QG-010 | Integrated loudness out of target | broken | 1 | `quality-gate: audio asset '<asset_id>' integrated loudness <measured> LUFS outside target <target> ±<tolerance> LU` |
| E-QG-011 | True-peak ceiling exceeded | broken | 1 | `quality-gate: audio asset '<asset_id>' true-peak <measured> dBTP exceeds -1.0 dBTP ceiling` |
| E-QG-012 | Boundary clip / DC offset | broken | 1 | `quality-gate: audio asset '<asset_id>' boundary check failed — hard clip at boundary or DC offset > 0.005 detected` |
| E-QG-020 | Resolution below target | broken | 1 | `quality-gate: 2D asset '<asset_id>' resolution check failed — actual dimensions <w>x<h>, minimum required: <min>` |
| E-QG-021 | Format mismatch | broken | 1 | `quality-gate: 2D asset '<asset_id>' format check failed — actual format '<actual>' not in declared output_formats <list>` |
| E-QG-022 | Tileability check failed (texture_material) | broken | 1 | `quality-gate: texture asset '<asset_id>' tileability check failed — wrap-distance metric <score> exceeds 5% threshold` |

---

## E-SHIP — Ship Gate License Check (CAP-004, BC-4.05.001)

Errors emitted at ship gate license evaluation. E-SHIP errors are hard stops: no
override path exists for E-SHIP-001 or E-SHIP-002.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-SHIP-001 | Commercial use explicitly false | broken | 1 | `ship-gate: asset '<id>' has commercial_use: false; not eligible for shipped product` |
| E-SHIP-002 | Free-tier restriction incompatible | broken | 1 | `ship-gate: asset '<id>' has free_tier_restriction: '<value>'; not eligible for shipped product under commercial license` |
| E-SHIP-003 | Build-level aggregated license violations | broken | 1 | `ship-gate: ship build contains <n> asset(s) with license violations; ship blocked until resolved (see license-violation-report for details)` |

---

## E-ING — Asset Store Ingest Pre-Flight (CAP-004, BC-4.06.001)

Errors emitted by the three-check ingest pre-flight. Any single failure causes the asset
to be rejected from the canonical asset store.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ING-001 | Quality gate status ineligible | broken | 1 | `ingest: asset '<id>' quality_gate_status '<status>' not eligible for ingest; allowed: pass, flagged (Tier-2/3)` |
| E-ING-002 | Sidecar schema validation failure | broken | 1 | `ingest: asset '<id>' sidecar fails schema validation; missing or invalid fields: <list>` |
| E-ING-003 | Outstanding SAG-AFTRA consent task | broken | 1 | `ingest: asset '<id>' has outstanding SAG-AFTRA consent task '<task_id>'; cannot be ingested into asset store until consent is cleared` |
| E-ING-004 | Duplicate asset_id | broken | 1 | `ingest: asset '<id>' already exists in store; use versioned re-submission to update` |

---

## E-SIM — Simulation Quality Verification (CAP-006)

Simulation contract violations are returned in verification result payloads. The error
codes below cover structural failures and gate-enforcement errors.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-SIM-001 | Conservation invariant | broken | 1 | `sim-qa: economy conservation invariant violated: net flow = <value>, tolerance = ±<tol> for sim '<sim_id>'` |
| E-SIM-002 | Damage matrix | broken | 1 | `sim-qa: damage I/O matrix '<matrix_id>' fails correctness check: <assertion>` |
| E-SIM-003 | FSM illegal state | broken | 1 | `sim-qa: FSM '<fsm_id>' reached illegal state '<state>' from '<prev_state>' via '<event>'` |
| E-SIM-004 | Balance band | broken | 1 | `sim-qa: balance band '<metric>' = <value>, expected [<min>, <max>] for economy '<econ_id>'` |
| E-SIM-005 | Softlock | broken | 1 | `sim-qa: softlock detected at node '<node_id>' — player has no path to progress without spend` |
| E-SIM-006 | Reachability | broken | 1 | `sim-qa: design-intent node '<intent_id>' unreachable from initial state in sim '<sim_id>'` |
| E-SIM-007 | Red Gate | broken | 1 | `sim-qa: TDD red-gate failed — production code present in '<module>' without prior failing test for story '<story_id>'` |
| E-SIM-008 | Validation method absent | broken | 1 | `sim-qa: contract '<contract_id>' has no declared validation_method — violates DI-012` |
| E-SIM-009 | Playtest delegation missing | broken | 1 | `sim-qa: design-intent contract '<contract_id>' requires playtest_delegation_note but field is absent (DI-012)` |

---

## E-CONV — 11-Dimension Convergence Tracking (CAP-007)

Convergence dimension failures are expressed as dimension status in the convergence state
document. The error codes below cover evaluation infrastructure failures and release-gating
violations.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-CONV-001 | Dimension config | broken | 1 | `convergence: dimension '<dim_id>' has no declared evaluation method` |
| E-CONV-002 | Release blocked | broken | 1 | `convergence: release blocked — dimensions not green: <dim_list>; required: all P0 dimensions green or explicitly degraded` |
| E-CONV-003 | Degradation undeclared | broken | 1 | `convergence: dimension '<dim_id>' is non-green but has no declared degradation rationale` |
| E-CONV-004 | Human gate absent | broken | 1 | `convergence: dimension '<dim_id>' requires human gate (D-PLAY or D-CERT terminal step) but no sign-off record exists` |
| E-CONV-005 | Ethics dimension fail | broken | 1 | `convergence: D-ETHICS dimension non-green — monetization-ethics-contract absent or adversarial review not passed` |
| E-CONV-006 | Security dimension fail | broken | 1 | `convergence: D-SEC dimension non-green — security invariant check failed (see D-SEC signal detail)` |

---

## E-PLAY — Structured Playtest Protocol (CAP-008)

Playtest protocol errors cover infrastructure and gate enforcement failures. Sign-off
blocking is a task state managed by the convergence engine (D-PLAY dimension).

The symbolic error names emitted by individual BCs are carried as the `error.data.reason`
sub-code of the registered parent E-PLAY-NNN code (same pattern as E-ETH).

**E-PLAY Symbolic→Registered Code Crosswalk:**

| Symbolic Token | Registered E-PLAY Code | Context / Enforcing BC |
|---|---|---|
| PLAYTEST_PROTOCOL_ALREADY_APPROVED | E-PLAY-006 | BC-8.08.001 EC-003: approved protocol already exists; overwrite blocked |
| PLAYTEST_PROTOCOL_IN_PROGRESS | E-PLAY-007 | BC-8.08.001 EC-006: concurrent generation attempt rejected |
| BUILD_NOT_ARCHIVED | E-PLAY-008 | BC-8.08.001 EC-002: no stable build_id to reference |
| BUILD_NOT_RUNNING | E-PLAY-009 | BC-8.08.002 EC-004: build not confirmed active before session starts |
| DUPLICATE_PARTICIPANT_SUBMISSION | E-PLAY-010 | BC-8.08.002 EC-005: second instrument submission for same participant |
| SESSION_NOT_COMPLETE | E-PLAY-011 | BC-8.08.003 EC-004: convergence report requested before session closed |
| AGENT_SIGN_OFF_FORBIDDEN | E-PLAY-012 | BC-8.08.004 EC-001: automated process attempted sign-off creation |
| CONDITIONS_REQUIRED_FOR_CONDITIONAL_VERDICT | E-PLAY-013 | BC-8.08.004 EC-004: CONDITIONAL verdict missing conditions_for_satisfaction text |
| FUN_SCORE_EMISSION_FORBIDDEN | E-PLAY-014 | BC-8.08.005 Postcondition 1: factory artifact contains fun-score field |
| DEFAULT_INSTRUMENTS_APPLIED | E-PLAY-015 | BC-8.08.001 EC-001: no instruments in GameSpec; defaulted to [GEQ, PENS, SUS] (cosmetic advisory) |

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-PLAY-001 | Protocol schema | broken | 1 | `playtest: protocol document '<doc_id>' failed schema validation: <field> missing` |
| E-PLAY-002 | Reviewer invalid | broken | 1 | `playtest: sign-off record '<record_id>' has reviewer_id '<id>' not in human-reviewer allowlist` |
| E-PLAY-003 | Fun score emitted | broken | 1 | `playtest: agent '<agent_id>' emitted automated fun-score '<score>' — violates DI-007; artifact rejected` |
| E-PLAY-004 | Evidence incomplete | broken | 1 | `playtest: convergence report '<report_id>' missing lens evidence for '<lens>'; 3-lens (say/do/behave) required` |
| E-PLAY-005 | Sign-off suppressed | broken | 1 | `playtest: human sign-off gate for session '<session_id>' was suppressed or bypassed — violates DI-006` |
| E-PLAY-006 | Protocol already approved | broken | 1 | `playtest: protocol for milestone '<milestone_id>' already has status: approved — overwrite is forbidden; error.data.reason = PLAYTEST_PROTOCOL_ALREADY_APPROVED` |
| E-PLAY-007 | Protocol generation in progress | broken | 1 | `playtest: protocol generation for milestone '<milestone_id>' is already in progress — concurrent generation rejected; error.data.reason = PLAYTEST_PROTOCOL_IN_PROGRESS` |
| E-PLAY-008 | Build not archived | broken | 1 | `playtest: playtest protocol generation blocked — no archived build with stable build_id for milestone '<milestone_id>'; archive build first; error.data.reason = BUILD_NOT_ARCHIVED` |
| E-PLAY-009 | Build not running | broken | 1 | `playtest: session '<session_id>' start blocked — build '<build_id>' is not confirmed running; verify build is active; error.data.reason = BUILD_NOT_RUNNING` |
| E-PLAY-010 | Duplicate participant submission | broken | 1 | `playtest: participant '<participant_id>' has already submitted instrument responses for session '<session_id>' — duplicate submission rejected; error.data.reason = DUPLICATE_PARTICIPANT_SUBMISSION` |
| E-PLAY-011 | Session not complete | broken | 1 | `playtest: convergence report generation requires session '<session_id>' to be closed first — session is still active; error.data.reason = SESSION_NOT_COMPLETE` |
| E-PLAY-012 | Agent sign-off forbidden | broken | 1 | `playtest: automated process '<agent_id>' attempted to create playtest-signoff-record — only human reviewers may sign off; gate remains open; error.data.reason = AGENT_SIGN_OFF_FORBIDDEN` |
| E-PLAY-013 | Conditions required for conditional verdict | broken | 1 | `playtest: sign-off verdict CONDITIONAL requires non-empty conditions_for_satisfaction text — sign-off rejected until conditions are authored; error.data.reason = CONDITIONS_REQUIRED_FOR_CONDITIONAL_VERDICT` |
| E-PLAY-014 | Fun score emission forbidden | broken | 1 | `playtest: artifact '<artifact_path>' written by agent '<agent_id>' contains fun-score field '<field_name>' — write blocked; DI-007 violation; error.data.reason = FUN_SCORE_EMISSION_FORBIDDEN` |
| E-PLAY-015 | Default instruments applied | cosmetic | 0 | `playtest: no playtest_instruments declared in GameSpec for genre '<genre>'; defaulted to [GEQ, PENS, SUS]; review protocol before approval; error.data.reason = DEFAULT_INSTRUMENTS_APPLIED` |

---

## E-ETH — Monetization Ethics Enforcement (CAP-011)

The symbolic error names emitted by individual BCs (e.g., `GACHA_ODDS_DISCLOSURE_MISSING`)
are carried as the `error.data.reason` sub-code of the registered parent E-ETH-NNN code.
The registered code is the machine-checkable, CI-resolvable identifier; the symbolic name
provides human-readable context in the error payload.

**DP→E-ETH crosswalk:**

| Dark Pattern | DP ID | Registered E-ETH Code | Symbolic Sub-Codes (error.data.reason) | Enforcing BC |
|---|---|---|---|---|
| Loot box without odds disclosure | DP-005 | E-ETH-010 | GACHA_ODDS_DISCLOSURE_MISSING, GACHA_ODDS_DISCLOSURE_INCOMPLETE, GACHA_ODDS_PROBABILITY_INCONSISTENT | BC-11.03.001 |
| Pay-to-win in ranked mode | DP-004 | E-ETH-011 | PAY_TO_WIN_IN_RANKED_DETECTED | BC-11.03.002 |
| Loss-triggered purchase prompt | DP-003 | E-ETH-012 | LOSS_TRIGGERED_PURCHASE_PROMPT_DETECTED | BC-11.03.003 |
| Minor loot box / gacha access | DP-008 | E-ETH-013 | MINOR_LOOT_BOX_ACCESS_VIOLATION, MINOR_PROTECTION_UNIMPLEMENTED | BC-11.03.004 |
| Miscategorized best-value bundle | DP-006 | E-ETH-014 | BEST_VALUE_LABEL_DECEPTIVE | BC-11.03.005 |
| Predatory vulnerability targeting | DP-007 | E-ETH-009 | PREDATORY_TARGETING_VULNERABILITY_PROXY | BC-11.03.006 |

**SS-09 symbolic name crosswalk (non-dark-pattern BCs):**

| Symbolic Name | Registered Parent Code | Context |
|---|---|---|
| ETHICS_CONTRACT_ABSENT | E-ETH-001 | BC-11.01.001 postcondition 2; error.data.reason distinguishes absent vs. invalid |
| ETHICS_CONTRACT_INVALID | E-ETH-002 | BC-11.01.001 postcondition 3 |
| UNCONSTRAINED_LTV_OBJECTIVE_DETECTED | E-ETH-003 | BC-11.01.001 postcondition 4 (field absent = fail-closed) |
| UNCONSTRAINED_OPTIMIZATION_DETECTED | E-ETH-003 | BC-11.02.001 postcondition 2 (cross-agent config scan) |
| OPTIMIZATION_OBJECTIVE_WITHOUT_CONSTRAINTS | E-ETH-003 | BC-11.02.001 postcondition 3 (sub-code for empty-constraints variant) |
| CONSTRAINT_SOURCE_REF_STALE | E-ETH-003 | BC-11.02.001 postcondition 4 (agent config references expired ethics contract — stale ref is treated as no valid constraint; fail-closed; F37-04) |
| SPEND_CONCENTRATION_EXCEEDS_ETHICS_BOUND | E-ETH-008 | BC-11.04.002 postcondition 2 |
| MONETIZATION_ETHICS_ADVERSARIAL_REVIEW_REQUIRED | E-ETH-006 | BC-11.01.003 postcondition 1 (no evidence) |
| MONETIZATION_ETHICS_CONTRACT_MODIFIED_SINCE_REVIEW | E-ETH-006 | BC-11.01.003 postcondition 4 (stale evidence) |
| PROGRESSION_DEADLOCK_DETECTED | E-ETH-005 | BC-11.02.003 postcondition 2 |

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ETH-001 | Contract missing | broken | 1 | `ethics: monetization present but no monetization-ethics-contract found for project '<project_id>'` |
| E-ETH-002 | Contract schema | broken | 1 | `ethics: ethics-contract '<contract_id>' failed schema validation: <field>` |
| E-ETH-003 | Unconstrained LTV | broken | 1 | `ethics: agent '<agent_id>' produced unconstrained LTV optimization objective without declared ethics-contract — violates DI-005` |
| E-ETH-004 | Dark pattern (generic) | broken | 1 | `ethics: forbidden dark pattern '<dp_id>' detected in artifact '<artifact_id>': <description>` |
| E-ETH-005 | Progression deadlock | broken | 1 | `ethics: progression deadlock detected — player has no path to '<goal>' without spend (see BC-11.02.003)` |
| E-ETH-006 | Adversarial review absent | broken | 1 | `ethics: convergence gate blocked — D-ETHICS dimension requires adversarial review but no review record found for contract '<contract_id>'` |
| E-ETH-007 | Gacha EV invalid | broken | 1 | `ethics: gacha pool '<pool_id>' expected value <ev> outside permitted range [<min>, <max>]` |
| E-ETH-008 | Gini coefficient exceeded | broken | 1 | `ethics: spend-concentration Gini coefficient = <gini> for cohort '<cohort_id>', exceeds bound <max>` |
| E-ETH-009 | Predatory targeting detected (DP-007) | broken | 1 | `ethics: segmentation-ltv-spec '<spec_id>' contains offer-escalation rule conditioned on vulnerability proxy '<proxy_field>' — predatory targeting pattern DP-007 detected; error.data.reason = PREDATORY_TARGETING_VULNERABILITY_PROXY` |
| E-ETH-010 | Gacha odds disclosure violation (DP-005) | broken | 1 | `ethics: gacha-spec '<spec_id>' paid-pull mechanic has odds disclosure violation — error.data.reason = <GACHA_ODDS_DISCLOSURE_MISSING \| GACHA_ODDS_DISCLOSURE_INCOMPLETE \| GACHA_ODDS_PROBABILITY_INCONSISTENT>` |
| E-ETH-011 | Pay-to-win in ranked mode (DP-004) | broken | 1 | `ethics: economy-graph shows mechanical advantage for spend tier '<tier>' in ranked mode '<mode>': gap=<gap>, epsilon=<epsilon> — DP-004 violation; error.data.reason = PAY_TO_WIN_IN_RANKED_DETECTED` |
| E-ETH-012 | Loss-triggered purchase prompt (DP-003) | broken | 1 | `ethics: purchase prompt event '<prompt_event>' scheduled <gap_ms>ms after loss event '<loss_event>' — below required proximity window <window_ms>ms; DP-003 violation; error.data.reason = LOSS_TRIGGERED_PURCHASE_PROMPT_DETECTED` |
| E-ETH-013 | Minor loot box / gacha access violation (DP-008) | broken | 1 | `ethics: gacha-spec '<spec_id>' minor-protection check failed — error.data.reason = <MINOR_LOOT_BOX_ACCESS_VIOLATION \| MINOR_PROTECTION_UNIMPLEMENTED>` |
| E-ETH-014 | Best-value label deceptive (DP-006) | broken | 1 | `ethics: iap-catalog SKU '<sku_id>' labeled best_value_tag=true but per-unit EV <ev_labeled> is dominated by SKU '<dominant_sku_id>' (EV <ev_dominant>) — DP-006 violation; error.data.reason = BEST_VALUE_LABEL_DECEPTIVE` |

---

## E-KB — Canon Knowledge-Base (CAP-012)

Canon-KB structural errors are returned in query results. The error codes below cover
ingest-time structural violations that are hard stops.

The symbolic error names emitted by individual BCs (e.g., `CANONICAL_NAME_COLLISION`,
`DANGLING_ENTITY_REFERENCE`) are carried as the `error.data.reason` sub-code of the
registered parent E-KB-NNN code. The registered code is the machine-checkable,
CI-resolvable identifier; the symbolic name provides human-readable context in the error
payload (same pattern as E-ETH).

**E-KB Symbolic→Registered Code Crosswalk:**

| Symbolic Token | Registered E-KB Code | Context / Enforcing BC |
|---|---|---|
| CANON_KB_ALREADY_EXISTS | E-KB-024 | BC-12.12.001 EC-001: initialization attempted when KB exists |
| GAME_ID_REQUIRED | E-KB-025 | BC-12.12.001 EC-002: GameSpec missing game_id |
| CANON_KB_INIT_PARTIAL_FAILURE | E-KB-026 | BC-12.12.001 EC-003: partial init rolled back |
| CANONICAL_NAME_COLLISION | E-KB-005 | BC-12.12.002 EC-001/EC-005: name collision (case-insensitive); error.data.reason distinguishes exact vs. case-insensitive |
| RETIRED_NAME_REUSE | E-KB-008 | BC-12.12.002 EC-002: name of a retired entity being reused |
| FORBIDDEN_NAME | E-KB-010 | BC-12.12.002 EC-003: name in forbidden_names list |
| ENTITY_ID_IMMUTABLE | E-KB-009 | BC-12.12.002 EC-004: attempt to change entity_id after assignment |
| DANGLING_ENTITY_REFERENCE | E-KB-003 | BC-12.12.003 EC-001, BC-12.12.007 check 1/5: edge or artifact references entity not in registry; error.data.reason DANGLING_ENTITY_REFERENCE |
| DUPLICATE_RELATIONSHIP | E-KB-011 | BC-12.12.003 Invariant 4: duplicate edge (same subject, predicate, object) |
| INVALID_TEMPORAL_WINDOW | E-KB-012 | BC-12.12.003 EC-002: valid_to precedes valid_from on edge |
| UNKNOWN_PREDICATE | E-KB-013 | BC-12.12.003 EC-003: predicate not in declared vocabulary |
| TIMELINE_EVENT_NOT_FOUND | E-KB-014 | BC-12.12.003 EC-005: valid_from_event_id references absent event |
| ENTITY_NOT_FOUND | E-KB-003 | BC-12.12.004 EC-001: entity not found in participating_entity_ids; error.data.reason = ENTITY_NOT_FOUND |
| ORDINAL_INSERTION_PERFORMED | E-KB-016 | BC-12.12.004 EC-002: ordinal conflict → insertion performed (informational) |
| CHRONOLOGICAL_REFERENCE_VIOLATION | E-KB-015 | BC-12.12.004 Invariant 1, EC-003, BC-12.12.007 check 4: entity referenced outside its validity window |
| INVALID_ENTITY_VALIDITY_WINDOW | E-KB-017 | BC-12.12.004 EC-004: departed_event precedes introduced_event |
| HARD_CANON_CONTRADICTION | E-KB-018 | BC-12.12.006 EC-001: two hard-canon facts conflict on same subject/predicate/window |
| MISSING_PROVENANCE | E-KB-019 | BC-12.12.006 EC-004: source_artifact_ref empty or null |
| NAMING_REGISTRY_BYPASSED | E-KB-020 | BC-12.12.005 Invariant 4, BC-12.12.007 check 2: naming check was skipped |
| PHONOTACTIC_VIOLATION | E-KB-021 | BC-12.12.005 Postcondition 4, BC-12.12.007 check 3: name violates culture phonotactic rules |
| TERMINOLOGY_DRIFT | E-KB-022 | BC-12.12.007 check 7: canonical spelling mismatch in artifact |
| GROUNDING_BYPASSED | E-KB-007 | BC-12.12.009 Invariant 1: generation without grounded_against tag; error.data.reason = GROUNDING_BYPASSED |
| GROUNDING_TIMEOUT | E-KB-023 | BC-12.12.009 EC-005: KB query timed out blocking generation (distinct from absent: KB exists but retrieval failed) |
| UNREGISTERED_NAME_IN_CONTENT | E-KB-003 | BC-12.12.005 EC-002: name in artifact not in entity-registry; routes to E-KB-003 dangling-ref with error.data.reason = UNREGISTERED_NAME_IN_CONTENT |

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-KB-001 | Schema init | broken | 1 | `canon-kb: KB '<kb_id>' failed schema initialization: <field> missing` |
| E-KB-002 | Entity ID collision | broken | 1 | `canon-kb: entity_id '<id>' already registered; duplicate entity registration rejected` |
| E-KB-003 | Dangling ref | broken | 1 | `canon-kb: entity '<entity_id>' not found in registry; error.data.reason = <DANGLING_ENTITY_REFERENCE \| ENTITY_NOT_FOUND \| UNREGISTERED_NAME_IN_CONTENT>` |
| E-KB-004 | Timeline conflict | broken | 1 | `canon-kb: event '<event_id>' at t=<t1> conflicts with event '<event_id2>' at t=<t2> for entity '<entity_id>'` |
| E-KB-005 | Naming collision | broken | 1 | `canon-kb: name '<name>' conflicts with existing registry entry '<existing_id>'; error.data.reason = CANONICAL_NAME_COLLISION` |
| E-KB-006 | Retcon unresolved | degraded | 0 | `canon-kb: retcon '<retcon_id>' affects <n> downstream entities; impact analysis incomplete — grounding agents paused` |
| E-KB-007 | Grounding absent / bypassed | broken | 1 | `canon-kb: artifact '<artifact_id>' from required-grounding agent '<agent_id>' missing grounded_against tag; error.data.reason = GROUNDING_BYPASSED` |
| E-KB-008 | Retired name reuse | degraded | 0 | `canon-kb: name '<name>' was used by retired entity '<retired_id>'; reuse permitted with warning; new entity_id assigned; error.data.reason = RETIRED_NAME_REUSE` |
| E-KB-009 | Entity ID immutable | broken | 1 | `canon-kb: entity_id '<id>' may not be changed after assignment — rename updates canonical_name and aliases only; error.data.reason = ENTITY_ID_IMMUTABLE` |
| E-KB-010 | Forbidden name | broken | 1 | `canon-kb: name '<name>' is in the forbidden_names list and may not be registered as a canonical entity name` |
| E-KB-011 | Duplicate relationship | broken | 1 | `canon-kb: relationship edge (subject='<s>', predicate='<p>', object='<o>') already exists with no validity window distinction — duplicate rejected` |
| E-KB-012 | Invalid temporal window on edge | broken | 1 | `canon-kb: edge '<edge_id>' valid_to '<to_event>' precedes valid_from '<from_event>' — temporal window is inverted; error.data.reason = INVALID_TEMPORAL_WINDOW` |
| E-KB-013 | Unknown predicate | broken | 1 | `canon-kb: predicate '<predicate>' is not in the declared relationship vocabulary for game '<game_id>'; nearest valid predicate: '<suggestion>'` |
| E-KB-014 | Timeline event not found | broken | 1 | `canon-kb: event_id '<event_id>' referenced in edge validity window does not exist in timeline; error.data.reason = TIMELINE_EVENT_NOT_FOUND` |
| E-KB-015 | Chronological reference violation | broken | 1 | `canon-kb: entity '<entity_id>' referenced at era-ordinal <ref_ordinal> but introduced at ordinal <intro_ordinal> (or departed at ordinal <depart_ordinal>); error.data.reason = CHRONOLOGICAL_REFERENCE_VIOLATION` |
| E-KB-016 | Ordinal insertion performed | cosmetic | 0 | `canon-kb: event ordinal <ordinal> already occupied in era '<era>'; insertion performed — subsequent events shifted up; error.data.reason = ORDINAL_INSERTION_PERFORMED` |
| E-KB-017 | Invalid entity validity window | broken | 1 | `canon-kb: entity '<entity_id>' departed_event_id ordinal <depart> precedes introduced_event_id ordinal <intro> — validity window is inverted; error.data.reason = INVALID_ENTITY_VALIDITY_WINDOW` |
| E-KB-018 | Hard-canon contradiction | broken | 1 | `canon-kb: hard-canon fact '<new_fact_id>' (subject='<s>', predicate='<p>') conflicts with existing fact '<conflict_fact_id>' in overlapping temporal window — retcon required; error.data.reason = HARD_CANON_CONTRADICTION` |
| E-KB-019 | Missing provenance | broken | 1 | `canon-kb: fact registration requires non-empty source_artifact_ref — provenance is mandatory; error.data.reason = MISSING_PROVENANCE` |
| E-KB-020 | Naming registry bypassed | broken | 1 | `canon-kb: name '<name>' was accepted into canon without passing naming-registry check — bypassed invariant violated; error.data.reason = NAMING_REGISTRY_BYPASSED` |
| E-KB-021 | Phonotactic violation | degraded | 0 | `canon-kb: name '<name>' violates phonotactic rule '<rule>' for culture '<culture>'; suggestion: '<suggestion>'; error.data.reason = PHONOTACTIC_VIOLATION` |
| E-KB-022 | Terminology drift | degraded | 0 | `canon-kb: artifact '<artifact_id>' uses '<found_spelling>' but canonical spelling is '<canonical>'; error.data.reason = TERMINOLOGY_DRIFT` |
| E-KB-023 | Grounding timeout | broken | 1 | `canon-kb: grounding retrieval for entity_context_ids '<ids>' timed out after <ms>ms — generation blocked; error.data.reason = GROUNDING_TIMEOUT` |
| E-KB-024 | KB already exists | broken | 1 | `canon-kb: initialization rejected — KB for game_id '<game_id>' already exists; use versioned update path; error.data.reason = CANON_KB_ALREADY_EXISTS` |
| E-KB-025 | Game ID required | broken | 1 | `canon-kb: initialization rejected — GameSpec is missing game_id field; error.data.reason = GAME_ID_REQUIRED` |
| E-KB-026 | Partial initialization failure | broken | 1 | `canon-kb: initialization failed at subsystem '<subsystem>'; all created KB files rolled back; retry is safe; error.data.reason = CANON_KB_INIT_PARTIAL_FAILURE` |

---

## E-GENRE — Genre-Gated Lane Activation (CAP-013)

> Note: E-GENRE covers the core lane-activation gate BCs (BC-13.01.*). Sub-lane
> behavioral contract BCs (BC-13.02.*, BC-13.03.*, BC-13.04.*) use E-GLG, E-MOD,
> and E-MKT respectively — see sections below.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-GENRE-001 | Profile schema | broken | 1 | `genre: profile document failed schema validation: <field> at <path>` |
| E-GENRE-002 | Inactive lane artifact | broken | 1 | `genre: artifact '<artifact_id>' produced by inactive lane '<lane_id>' — inactive-lane zero-artifact invariant violated` |
| E-GENRE-003 | Lane activation conflict | broken | 1 | `genre: lane '<lane_id>' activation request conflicts with existing lane state — idempotency violation` |
| E-GENRE-004 | NFT/web3 opt-in missing | broken | 1 | `genre: nft_mechanics or web3_enabled set to true but no business-model-spec document found — explicit opt-in required (DI-011)` |
| E-GENRE-005 | PEGI-18 not acknowledged | broken | 1 | `genre: business-model-spec declares nft_mechanics: true but pegi_18_acknowledged: false — PEGI 18 consequence must be acknowledged` |
| E-GENRE-006 | Mod-API version conflict | broken | 1 | `genre: mod-api '<api_id>' version '<ver>' violates semver stability contract for existing mods` |

---

## E-GLG — Genre-Lane Gate Sub-Lane Config/Schema Errors (CAP-013, BC-13.01.*/13.02.*/13.03.*/13.04.*)

E-GLG errors are emitted by genre profile schema validation (BC-13.01.001) and by
sub-lane BCs when config objects fail structural constraints. These are distinct from
E-GENRE (which covers lane-activation-gate-level BCs) and address config-level gate
failures within an already-validated genre profile.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-GLG-001 | Genre profile / sub-lane config schema invalid | broken | 1 | `genre-lane: schema validation failed — <field> at <path>: <violation>; no lanes activated` |
| E-GLG-002 | Schema version not supported | broken | 1 | `genre-lane: genre profile schema version '<version>' not supported by factory schema registry; upgrade required` |
| E-GLG-003 | Custom rating model missing invariant declaration | broken | 1 | `genre-lane: esports_config.rating_model 'custom' requires declared invariants but none are provided` |
| E-GLG-004 | Engagement objective without ethics review | degraded | 0 | `genre-lane: esports_config.matchmaking.objective 'engagement' declared without a monetization-ethics-contract review flag; artifact generated with warning annotation` |
| E-GLG-005 | match_result_audit unavailable (non-deterministic replay) | degraded | 0 | `genre-lane: match_result_audit overridden to 'unavailable' — replay_mode '<mode>' is not deterministic_input; match_result_audit requires T1 determinism (BC-13.02.003)` |

---

## E-MOD — Modding/UGC Lane Errors (CAP-013, BC-13.03.*)

Errors emitted by the modding lane BCs: mod-API contract (BC-13.03.001), UGC content
schema validation (BC-13.03.002), mod load determinism (BC-13.03.003), and UGC
distribution adapter (BC-13.03.004).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-MOD-001 | Breaking change without major version bump | broken | 1 | `modding: mod-API breaking change detected in '<api_id>' but api_version major component not incremented since prior version '<prior_ver>'; bump to major version required` |
| E-MOD-002 | UGC content schema — unknown field | broken | 1 | `modding: UGC content file '<file>' contains unknown field '<field>' not in published schema for type '<type>'; strict-mode rejection` |
| E-MOD-003 | UGC content schema — dangling entity reference | broken | 1 | `modding: UGC content file '<file>' references entity_id '<entity_id>' not found in base game or mod's declared additions; referential completeness failure` |
| E-MOD-004 | UGC content schema — band/range invariant violation | broken | 1 | `modding: UGC content file '<file>' field '<field>' value <value> violates declared band invariant [<min>, <max>]` |
| E-MOD-005 | UGC content schema — duplicate entity id | broken | 1 | `modding: UGC content file '<file>' declares duplicate id '<id>'; uniqueness constraint violated` |
| E-MOD-006 | Mod circular dependency | broken | 1 | `modding: circular dependency detected in mod set — cycle: <mod_ids>; no mods loaded` |
| E-MOD-007 | Mod file conflict | degraded | 0 | `modding: file conflict between mods '<mod_a>' and '<mod_b>' — both override '<path>'; higher-priority mod wins; conflict reported` |
| E-MOD-008 | Unsatisfied mod dependency | broken | 1 | `modding: mod '<mod_id>' requires '<dep_id> >= <required_version>' but only '<dep_id> <available_version>' is present; loading rejected` |
| E-MOD-009 | UGC file size exceeds platform limit | broken | 1 | `modding: UGC distribution upload rejected — file size <size> exceeds platform limit <limit> for backend '<backend>'` |
| E-MOD-010 | Marketplace capability without human vetting | broken | 1 | `modding: monetization_marketplace declared without human copyright-vetting flag; marketplace capability set to human-gated (DI-006)` |
| E-MOD-011 | Steam Workshop cross-platform requested | broken | 1 | `modding: Steam Workshop adapter cannot serve cross-platform mod content; use mod.io for cross-platform distribution` |

---

## E-MKT — Marketing Lane Asset Conformance Errors (CAP-013, BC-13.04.*)

Errors emitted by the marketing lane BCs: store page asset conformance (BC-13.04.001)
and marketing asset manifest completeness (BC-13.04.002).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-MKT-001 | Store asset spec violation | broken | 1 | `marketing: store asset '<asset_id>' for platform '<platform>' failed conformance — <violation_description>; expected: <expected>, actual: <actual>` |
| E-MKT-002 | Insufficient screenshots | broken | 1 | `marketing: platform '<platform>' requires ≥<required> screenshots but only <actual> are present; supply additional screenshots` |
| E-MKT-003 | Missing required marketing asset type | broken | 1 | `marketing: manifest incomplete — required asset type '<type>' for platform '<platform>' is absent; manifest_complete set to false` |
| E-MKT-004 | Incomplete provenance sidecar on marketing asset | broken | 1 | `marketing: asset '<asset_id>' has provenance sidecar but disclosure_class field is empty or null — DI-003 violation; asset listed as non-conformant` |

---

## E-TMOD — Moderation Pipeline Contract (CAP-013, BC-13.03.005)

Errors emitted by the moderation pipeline contract BC (BC-13.03.005) when a UGC/chat
game's `moderation-pipeline-manifest` is absent, incomplete, or declares a fail-open
configuration. Scope: games where `genre-profile.modding_enabled: true` (UGC lane) OR
`game-metadata-spec.user_to_user_communication: true` (chat). All E-TMOD errors cause
D-SEC BLOCKED.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-TMOD-001 | Moderation pipeline absent or provider invalid | broken | 1 | `moderation: moderation-pipeline-manifest absent or invalid for game '<game_id>' with modding_enabled=true or user_to_user_communication=true — provider must be non-empty and csam_detection_method must be one of {PhotoDNA, C2PA scan, hash-match}; D-SEC BLOCKED (BC-13.03.005)` |
| E-TMOD-002 | NCMEC report path missing | broken | 1 | `moderation: moderation-pipeline-manifest.ncmec_report_path is null or absent for game '<game_id>' — NCMEC CyberTipline must be configured (18 U.S.C. §2258A); D-SEC BLOCKED (BC-13.03.005)` |
| E-TMOD-003 | Moderation fail-open declared | broken | 1 | `moderation: moderation-pipeline-manifest declares degraded_behavior: 'pass_through' (fail-open) for game '<game_id>' — fail-open moderation is not a valid configuration; must be 'block_ugc' or equivalent fail-closed behavior; D-SEC BLOCKED (BC-13.03.005)` |

---

## E-ANTICH — Anti-Cheat Integration Adapter (CAP-013, BC-13.02.006)

Errors emitted by the anti-cheat integration adapter BC (BC-13.02.006) when an
esports-lane game's `anti_cheat_config` is absent, declares a provider not in the
allowed set, or attempts to use a kernel-anomaly provider. Scope: games where
`genre-profile.esports_enabled: true` (the sole schema-valid competitive-lane signal
per BC-13.01.001).

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ANTICH-001 | Provider not in allowed set | broken | 1 | `anti-cheat: provider '<provider>' declared in anti_cheat_config for game '<game_id>' is not in the factory-allowed set {eac, eos, battleye} (case-insensitive); D-SEC BLOCKED (BC-13.02.006, ADR-0008)` |
| E-ANTICH-002 | Kernel-anomaly provider attempted | broken | 1 | `anti-cheat: provider '<provider>' is a kernel-anomaly provider (Riot Vanguard / vgk.sys variant) — unconditionally rejected; not licensable, DI-010 violation; scaffolding generation BLOCKED; not overridable (BC-13.02.006, ADR-0008)` |
| E-ANTICH-003 | Provider absent for esports lane | broken | 1 | `anti-cheat: anti_cheat_config absent or provider field missing for game '<game_id>' with esports_enabled=true; anti-cheat provider declaration is required; D-SEC BLOCKED (BC-13.02.006)` |

---

## E-SEC — Output-Bundle Secrets Gate (CAP-001, BC-1.15.003)

Errors emitted by the output-bundle secrets gate (BC-1.15.003) when a factory-generated
artifact bundle contains a detected secret pattern or high-entropy string outside declared
baseline exclusions. E-SEC-001 is a hard stop: no override path exists.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-SEC-001 | Secret in output bundle | broken | 1 | `secrets-gate: factory output bundle for game '<game_id>' contains secret material at '<file_path>' — pattern: '<pattern_description>' / entropy: <entropy> bits/char; bundle rejected; CI exit 1; DI-013 violation (BC-1.15.003)` |

---

## E-XR — XR Platform Seam (CAP-014)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-XR-001 | Manifest schema | broken | 1 | `xr: adapter manifest '<manifest_id>' failed schema validation: <field>` |
| E-XR-002 | Fidelity invalid | broken | 1 | `xr: capability '<cap>' has invalid fidelity value '<value>' in XR manifest` |
| E-XR-003 | Core change detected | broken | 1 | `xr: XR adapter add/remove caused core file '<file>' to change — violates XR seam isolation (BC-14.01.004)` |
| E-XR-004 | Comfort cert missing | broken | 1 | `xr: comfort_certify capability declared but no human-gated comfort-cert task created — violates DI-006` |
| E-XR-005 | Performance budget schema | broken | 1 | `xr: XR performance budget document failed schema validation: <field>` |
| E-XR-006 | OpenXR extension invalid | broken | 1 | `xr: extension '<ext>' does not match KHR > EXT > vendor namespace hierarchy` |
| E-XR-007 | OpenXR field used in visionOS manifest | broken | 1 | `xr: visionOS manifest '<manifest_id>' contains OpenXR-specific field '<field>' — visionOS does not implement OpenXR; remove openxr_version, khronos-cts conformance suite, and XR_* namespace capability IDs (BC-14.02.003)` |

---

## E-OSVC — Online-Services Adapter (CAP-015)

> **Populated in PRD rev 1.9 (CAP-015 delivery).** 15 codes covering all seven
> capability areas plus seam integrity.
>
> **Naming rationale.** `E-SVC` is taken by CAP-004 (GenerationRequest service
> validation). `E-OSVC` = Online Services Capability.
>
> **Note on E-EAP-012 (MalformedManifest):** When `serverAuthoritative: false` is
> declared on leaderboards or entitlements with non-none fidelity, the error is
> `E-EAP-012` (MalformedManifest) — not an E-OSVC code. Manifest-level violations
> always route to E-EAP-012 per adapter-protocols.md §1.5.

All E-OSVC errors have `exit_code: 1` unless marked `degraded` (exit code 0).
Message format uses `<placeholder>` syntax.

| Error Code | Category | Severity | Exit Code | Message Format | Enforcing BC |
|-----------|----------|----------|-----------|----------------|-------------|
| E-OSVC-001 | Backend unreachable | broken | 1 | `online-services: backend '<targetId>' unreachable — connection failed or timed out` | BC-15.02.001, BC-15.03.001, BC-15.04.001, BC-15.05.001, BC-15.06.001, BC-15.07.001 |
| E-OSVC-002 | Session expired or invalid credentials | broken | 1 | `online-services: session token expired or credentials rejected for playerId '<id>' via provider '<provider>'; error.data.reason = SESSION_EXPIRED \| INVALID_CREDENTIALS` | BC-15.02.001 |
| E-OSVC-003 | Score rejected by server | broken | 1 | `online-services: leaderboard.submit: score <score> for board '<boardId>' rejected by server — exceeds server-computed maximum for playerId '<playerId>'` | BC-15.04.001 |
| E-OSVC-004 | Entitlement not found in store registry | broken | 1 | `online-services: entitlement.verify: entitlementId '<id>' not registered in backend store '<targetId>'` | BC-15.06.001 |
| E-OSVC-005 | Save conflict unresolvable | broken | 1 | `online-services: save.write: conflict for playerId '<id>' key '<key>' — strategy '<strategy>' could not resolve; winner_version in error.data` | BC-15.03.001 |
| E-OSVC-006 | Remote config stale | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' cache expired at '<expiry>'; backend unreachable; cache cannot be used` | BC-15.07.001 |
| E-OSVC-007 | Remote config contract violation | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' key '<key>' value '<v>' fails contract '<contract_ref>' schema at '<path>'` | BC-15.07.001 |
| E-OSVC-008 | Remote config namespace not found | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' not configured in backend '<targetId>'` | BC-15.07.001 |
| E-OSVC-009 | Online artifact leak in offline project | broken | 1 | `online-services: BaaS artifact '<path>' found in output tree but project declares online_features: false or offlineProject: true — zero-artifact invariant violated (BC-15.01.002)` | BC-15.01.002 |
| E-OSVC-010 | No conformance suite | degraded | 0 | `online-services: adapter '<targetId>' declares conformance_suite: none — accepted for dev/sandbox only; not eligible for production pipeline gate` | BC-15.08.001 |
| E-OSVC-011 | Online-services core coupling detected | broken | 1 | `online-services: adapter add/remove caused core file '<file>' to change — violates seam isolation (BC-15.09.001, ADR-0004)` | BC-15.09.001 |
| E-OSVC-012 | CapabilityUnsupported suppressed | broken | 1 | `online-services: adapter '<targetId>' returned nominal success for none-fidelity capability '<cap>' — E-EAP-002 required; conformance failure (BC-15.10.001)` | BC-15.10.001 |
| E-OSVC-013 | Unsupported auth provider | broken | 1 | `online-services: identity: authProvider '<provider>' not in adapter's declared authProviders list` | BC-15.02.001 |
| E-OSVC-014 | Lobby capacity exceeded | broken | 1 | `online-services: matchmaking.joinLobby: lobby '<lobbyId>' is at max capacity (<maxPlayers>) — join rejected` | BC-15.05.001 |
| E-OSVC-015 | Lobby not found | broken | 1 | `online-services: matchmaking.joinLobby: joinCode '<code>' does not resolve to an active lobby — code may be expired or invalid` | BC-15.05.001 |
| E-OSVC-016 | Save size limit exceeded | broken | 1 | `online-services: save.write: payload for playerId '<id>' key '<key>' exceeds backend size limit '<limit>'` | BC-15.03.001 |

---

## Coverage Notes

### PRD Revision 2.4 Changes (Pass-44 F44-01 — trigger vocabulary reconciliation: E-TMOD, E-ANTICH scope fix)

| Change | Detail |
|--------|--------|
| E-TMOD-001 message format fixed (F44-01) | **CORRECTION:** E-TMOD-001 message format replaced non-schema tokens `ugc_enabled/chat_enabled` with schema-valid signals `modding_enabled` (genre-profile UGC lane) and `user_to_user_communication` (game-metadata-spec chat signal). BC-13.03.005 precondition 1, invariant 1, edge cases, and test vectors updated accordingly. CSAM gate is now reachable via any valid genre profile with `modding_enabled: true` or any game-metadata-spec with `user_to_user_communication: true`. No code count change. |
| E-ANTICH-003 message format fixed (F44-01) | **CORRECTION:** E-ANTICH-003 message format removed non-schema token `competitive_multiplayer=true`; now references only `esports_enabled=true` (the sole schema-valid competitive-lane signal per BC-13.01.001). Category renamed ProviderAbsentForCompetitiveLane → ProviderAbsentForEsportsLane. BC-13.02.006 precondition 1, invariant 1, edge cases, and test vectors updated accordingly. No code count change. |
| E-ANTICH section scope note updated (F44-01) | Section intro now states scope as `esports_enabled: true` only; previous "competitive-multiplayer or esports-enabled" language removed. E-TMOD section intro now explicitly states scope as `modding_enabled: true` OR `user_to_user_communication: true`. |
| Total codes unchanged | No new codes added. E-TMOD: 3 (unchanged). E-ANTICH: 3 (unchanged). Total: **267** (unchanged). |

---

### PRD Revision 2.3 Changes (Pass-42 D-019 security burst — 3 new families, 7 new codes, DI-013)

| Change | Detail |
|--------|--------|
| E-TMOD family registered (Pass-42) | **NEW FAMILY:** `E-TMOD` (Moderation Pipeline Contract, CAP-013, BC-13.03.005) registered with 3 codes: E-TMOD-001 (ModerationPipelineAbsent — absent manifest or invalid provider/csam_detection_method), E-TMOD-002 (NCMECReportPathMissing — ncmec_report_path null or absent), E-TMOD-003 (ModerationFailOpen — degraded_behavior: pass_through declared). All 3 codes are severity: broken, exit code: 1. E-TMOD: 0 → **3 codes**. |
| E-ANTICH family registered (Pass-42) | **NEW FAMILY:** `E-ANTICH` (Anti-Cheat Integration Adapter, CAP-013, BC-13.02.006) registered with 3 codes: E-ANTICH-001 (ProviderNotInAllowedSet), E-ANTICH-002 (KernelAnomalyProviderAttempted — unconditional Vanguard/vgk rejection), E-ANTICH-003 (ProviderAbsentForCompetitiveLane). All 3 codes are severity: broken, exit code: 1. E-ANTICH: 0 → **3 codes**. |
| E-SEC family registered (Pass-42) | **NEW FAMILY:** `E-SEC` (Output-Bundle Secrets Gate, CAP-001, BC-1.15.003) registered with 1 code: E-SEC-001 (SecretInOutputBundle — secret-pattern scan or entropy scan failure on CI). Severity: broken, exit code: 1. E-SEC: 0 → **1 code**. |
| DI-013 added to invariants.md | **NEW INVARIANT:** DI-013 (Factory Output Bundle Never Contains Secret Material) added to domain-spec/invariants.md v1.2. Enforced by BC-1.15.003. Grounded in ARCH-INDEX.md §F42-03 (D-SEC sub-predicate 4) and cicd-setup.md §Output-Bundle Secrets Gate. |
| BC-1.15.003 authored (Pass-42) | New BC `BC-1.15.003` (Never-Emit-Secrets Output-Bundle Lint, SS-01, CAP-001, P0) authored. Primary enforcer of DI-013. VP-TBD-327 reserved. |
| BC-13.02.006 authored (Pass-42) | New BC `BC-13.02.006` (Anti-Cheat Integration Adapter, SS-11, CAP-013, P2) authored. VP-TBD-326 reserved. |
| BC-13.03.005 authored (Pass-42) | New BC `BC-13.03.005` (Moderation Pipeline Contract, SS-11, CAP-013, P2) authored. VP-TBD-324/325 reserved. |
| Total codes 260 → 267 | E-TMOD: 0→3 (+3), E-ANTICH: 0→3 (+3), E-SEC: 0→1 (+1). Net: **+7 new codes**. Active codes: 251 → **258**. Total registered (incl. retired E-GEN): 260 → **267**. Active families: 30 → **33** (+3 new). Total families: 31 → **34** (+3 new). BC count: 190 → **193** (+3). |

---

### PRD Revision 2.0 Changes (Pass-20 — symbolic token reconciliation: E-KB, E-PLAY, E-REPLAY, E-NAR)

| Change | Detail |
|--------|--------|
| E-KB extended (+19 codes: E-KB-008..026) | **CRITICAL (Pass-20 orphan reconciliation):** E-KB was under-provisioned relative to the 20+ symbolic tokens emitted by BCs BC-12.12.001..009. The 7 original codes could not cover all conditions. Added: E-KB-008 (RETIRED_NAME_REUSE), E-KB-009 (ENTITY_ID_IMMUTABLE), E-KB-010 (FORBIDDEN_NAME), E-KB-011 (DUPLICATE_RELATIONSHIP), E-KB-012 (INVALID_TEMPORAL_WINDOW on edge), E-KB-013 (UNKNOWN_PREDICATE), E-KB-014 (TIMELINE_EVENT_NOT_FOUND), E-KB-015 (CHRONOLOGICAL_REFERENCE_VIOLATION), E-KB-016 (ORDINAL_INSERTION_PERFORMED — cosmetic), E-KB-017 (INVALID_ENTITY_VALIDITY_WINDOW), E-KB-018 (HARD_CANON_CONTRADICTION), E-KB-019 (MISSING_PROVENANCE), E-KB-020 (NAMING_REGISTRY_BYPASSED), E-KB-021 (PHONOTACTIC_VIOLATION), E-KB-022 (TERMINOLOGY_DRIFT), E-KB-023 (GROUNDING_TIMEOUT — distinct from E-KB-007 absent), E-KB-024 (CANON_KB_ALREADY_EXISTS), E-KB-025 (GAME_ID_REQUIRED), E-KB-026 (CANON_KB_INIT_PARTIAL_FAILURE). E-KB-003/005/007 extended with error.data.reason sub-codes for overlapping conditions. Symbolic→code crosswalk added to E-KB section. E-KB: 7 → **26 codes**. |
| E-PLAY extended (+10 codes: E-PLAY-006..015) | **CRITICAL (Pass-20 orphan reconciliation):** E-PLAY was under-provisioned relative to symbolic tokens emitted by BCs BC-8.08.001..005. Added: E-PLAY-006 (PLAYTEST_PROTOCOL_ALREADY_APPROVED), E-PLAY-007 (PLAYTEST_PROTOCOL_IN_PROGRESS), E-PLAY-008 (BUILD_NOT_ARCHIVED), E-PLAY-009 (BUILD_NOT_RUNNING), E-PLAY-010 (DUPLICATE_PARTICIPANT_SUBMISSION), E-PLAY-011 (SESSION_NOT_COMPLETE), E-PLAY-012 (AGENT_SIGN_OFF_FORBIDDEN), E-PLAY-013 (CONDITIONS_REQUIRED_FOR_CONDITIONAL_VERDICT), E-PLAY-014 (FUN_SCORE_EMISSION_FORBIDDEN), E-PLAY-015 (DEFAULT_INSTRUMENTS_APPLIED — cosmetic). Symbolic→code crosswalk added to E-PLAY section. E-PLAY: 5 → **15 codes**. |
| E-REPLAY extended (+11 codes: E-REPLAY-008..018) | **CRITICAL (Pass-20 orphan reconciliation):** E-REPLAY was under-provisioned relative to symbolic tokens emitted by BCs BC-3.03.001..009. Added: E-REPLAY-008 (REPLAY_CAPABILITY_NONE), E-REPLAY-009 (RECORDING_FRAME_GAP), E-REPLAY-010 (INCOMPATIBLE_REPLAY_ENGINE_VERSION), E-REPLAY-011 (GOLDEN_STATE_INVALIDATED), E-REPLAY-012 (GOLDEN_STATE_ABSENT), E-REPLAY-013 (UNAUTHORIZED_GOLDEN_STATE_CAPTURE), E-REPLAY-014 (INSUFFICIENT_DETERMINISM_TIER_FOR_EXPORT), E-REPLAY-015 (LANE_NOT_ACTIVE for export), E-REPLAY-016 (SERVER_STATE_MISSING), E-REPLAY-017 (BROADCAST_DELAY_ZERO_STREAM_SNIPE_RISK — cosmetic), E-REPLAY-018 (CHECKPOINT_MISMATCH — degraded). Symbolic→code crosswalk added to E-REPLAY section. E-REPLAY: 7 → **18 codes**. |
| E-NAR extended (+2 codes: E-NAR-005..006) | **CRITICAL (F-20-02 fix):** BC-5.04.001 Postcondition 3 and BC-5.04.002 EC-004 were using "E-NAR-003 variant" language for distinct conditions that lack registered backing. Added: E-NAR-005 (undeclared variable reference in narrative graph, BC-5.04.001 Post-3), E-NAR-006 (invalid naming-registry pattern regex, BC-5.04.002 EC-004). "E-NAR-003 variant" language removed from both BCs. E-NAR: 4 → **6 codes**. |
| OBS-20-A (BC-12.12.004 Invariant 2) | **FIXED:** Invariant 2 reworded from "Ordinals within an era are unique and form a contiguous sequence" to "Ordinals within an era are unique (unless both events are explicitly concurrent: true) and form a contiguous sequence starting from 1." Contradiction between Invariant 2 and EC-005 resolved. |
| OBS-20-B (CAP-012 / CAP-005 timeline authority) | **FIXED:** Cross-reference note added to BC-12.12.004 and BC-5.04.002 identifying CAP-012 Canon-KB as the authoritative timeline store; CAP-005 (BC-5.04.002) is the narrative-integrity consumer view. |
| Total codes 213 → 255 | E-KB: 7→26 (+19), E-PLAY: 5→15 (+10), E-REPLAY: 7→18 (+11), E-NAR: 4→6 (+2). Net: **+42 new codes**. Active codes: 204 → **246**. Total registered (incl. retired E-GEN): 213 → **255**. Active families unchanged: **30**. Total families: **31** (unchanged). |

---

### PRD Revision 2.2 Changes (F39-01, F39-02, F39-03, F39-04 — Pass-39 error-code semantic-fit fixes)

| Change | Detail |
|--------|--------|
| E-OSVC-016 registered (F39-01) | **CRITICAL:** New code `E-OSVC-016` (SaveSizeLimitExceeded) registered for save.write payload exceeding backend size limit. Fixes BC-15.03.001 EC-006 which incorrectly reused E-OSVC-005 (SaveConflictUnresolvable — conflict-specific, requires winner_version/winner_data payload) for a size-limit rejection. Size-limit is a genuinely distinct failure with no competing writer. E-OSVC-016 re-points BC-15.03.001 EC-006. E-OSVC: 15 → **16 codes**. |
| E-ENG-003 registered (F39-02) | **CRITICAL:** New code `E-ENG-003` (UnclassifiedModule) for BC-5.05.001 EC-001 (module has no declared module_type). E-ENG-001 (logic-presentation coupling) is semantically wrong for this condition — no import violation is present. E-ENG: 2 → **3 codes**. |
| E-ENG-004 registered (F39-02) | **CRITICAL:** New code `E-ENG-004` (TestScopedToWrongModule) for BC-5.05.002 EC-005 (test file does not reference story's assigned module). E-ENG-002 (RedGate violation — production code without prior failing test) is a different condition. E-ENG: 3 → **4 codes**. |
| E-CIN-005 registered (F39-02) | **CRITICAL:** New code `E-CIN-005` (TimestampOutOfRange) for BC-5.06.001 PC1 and EC-003 (timestamp outside [0, duration_seconds]). E-CIN-001 (unresolved asset ref) is semantically wrong for this condition — no ref resolution failure is present. E-CIN: 4 → **5 codes**. |
| E-CIN-006 registered (F39-02) | **CRITICAL:** New code `E-CIN-006` (BlendshapeTrackSetIncomplete) for BC-5.06.002 PC1 (missing or extra ARKit-52 blendshape track names). E-CIN-004 covers range violations (value outside [0,1]); track-set completeness is a distinct structural condition. E-CIN: 5 → **6 codes**. |
| E-MKT-002/003 screenshot-count alignment (F39-03) | **IMPORTANT:** BC-13.04.002 EC-001 and test vector re-pointed from E-MKT-003 (MissingRequiredAssetType) to E-MKT-002 (InsufficientScreenshots) for screenshot count shortfall. E-MKT-002 is the dedicated count code; E-MKT-003 remains correct for the general case of a wholly absent asset type. No new code. |
| E-OSVC-004 "variant" removed (F39-04) | **COSMETIC:** BC-15.06.001 PC4 removed the word "variant" from "E-OSVC-004 variant EntitlementNotFound". The code was already correct; only the non-standard word was removed. |
| Total codes 255 → 260 | E-ENG: 2→4 (+2), E-CIN: 4→6 (+2), E-OSVC: 15→16 (+1). Net: **+5 new codes**. Active codes: 246 → **251**. Total registered (incl. retired E-GEN): 255 → **260**. Active families unchanged: **30**. Total families: **31** (unchanged). |

---

### PRD Revision 2.1 Changes (F37-01, F37-04 — Pass-37 adversarial deep BC logic fixes)

| Change | Detail |
|--------|--------|
| E-COMP-012 scope extended (F37-01) | **IMPORTANT (regulatory):** E-COMP-012 trigger condition extended from a 2-signal check (`nft_blockchain` vs `nft_mechanics`) to a 3-signal check that also includes `NFT_MECHANIC` in `game-metadata-spec.content_descriptors[]`. The `NFT_MECHANIC` content-descriptor tag is an independently authoritative NFT signal (used by BC-7.08.001 EC-006 and BC-10.01.001 EC-001). BC-10.01.001 step-4 matrix, INV-2, VP-COMP-002, and EC-001 updated to reflect the 3-signal rule. No new registered code — E-COMP-012 scope broadened. Total error codes: **255** (unchanged). |
| CONSTRAINT_SOURCE_REF_STALE sub-code added (F37-04) | **IMPORTANT (DI-005):** New symbolic sub-code `CONSTRAINT_SOURCE_REF_STALE` registered as `error.data.reason` sub-code of E-ETH-003. Emitted by BC-11.02.001 postcondition 4 (new) when an agent config's `constraint_source_ref` points to an expired ethics contract. Fail-closed: stale reference is treated as no valid constraint — FAIL, never PASS. BC-11.02.001 test vectors updated with stale-ref FAIL vector. No new registered code — E-ETH-003 extended with new sub-code. Total error codes: **255** (unchanged). |

---

### PRD Revision 1.8 Changes (Pass-13 C13-01 — online-services seam)

| Change | Detail |
|--------|--------|
| E-OSVC family reserved | **ARCHITECT (C13-01):** Family `E-OSVC` (Online-Services Adapter, CAP-015, SS-13) reserved for future PO population. Zero active codes added. Family registry updated (30 → 31 families; 29 active + 1 retired E-GEN + **1 reserved E-OSVC**). Active code count unchanged: **189**. Total registered count unchanged: **198**. |
| Collision check | `E-SVC` (CAP-004 GenerationRequest) is DIFFERENT from `E-OSVC`. No collision. |

---

### PRD Revision 1.9 Changes (CAP-015 online-services adapter delivery)

| Change | Detail |
|--------|--------|
| E-OSVC populated (15 codes) | **PRODUCT-OWNER (CAP-015 delivery):** Family `E-OSVC` (Online-Services Adapter, CAP-015, SS-13) promoted from reserved to active. 15 codes added: E-OSVC-001..015 covering identity/session (001/002/013), cloud-save (005), leaderboards (003), matchmaking (014/015), entitlements (004), remote-config (006/007/008), offline-project seam (009), conformance (010/012), and seam isolation (011). Active code count: 189 → **204**. Total registered count: 198 → **213**. Active families: 29 (reserved E-OSVC) → **30**. Total families (incl. retired E-GEN): 31 (unchanged). |
| Headline updated | Authoritative total headline updated from 198 to **213** (30 active families + 1 retired E-GEN = 31 total). |

---

### PRD Revision 1.7 Changes (Pass-9 adversarial fixes: I-1, I-2, O-1)

| Change | Detail |
|--------|--------|
| E-COMP-011 added (I-1) | **IMPORTANT:** New code for out-of-vocabulary `disclosure_class` value arriving on an inbound sidecar at manifest aggregation time. Triggered when the `disclosure_class` field IS present but its value is not in `{pre-generated, live-generated, procedural-exempt}`. Distinct from E-COMP-010 (field absent/null). Matches the E-PRV-010/011 producer-side split pattern (E-PRV-010 = absent/null; E-PRV-011 = present but out-of-vocab) at the consumer/manifest layer. BC-10.05.001 INV-3 and VP-COMP-017 updated to reference E-COMP-011 for the out-of-vocab case; Behavior step 3 retains E-COMP-010 for the genuine missing-field case. |
| E-COMP-012 added (I-2) | **IMPORTANT (regulatory):** New code for NFT activation flag inconsistency seam: `game-metadata-spec.nft_blockchain` ≠ `genre-profile.nft_mechanics`. Emitted by BC-10.01.001 when these two fields diverge. Conservative fail-closed: PEGI-18 override and `NFT_PEGI18_OVERRIDE` flag applied to the `ratings-submission-manifest` whenever either source declares NFT active, preventing under-rated storefront submissions (DI-011 / R-013). |
| BC-10.05.001 O-1 fix | **LOW:** `eu_scope_category` inline JSON comment in the `eu_c2pa_marks.marked_assets` object now lists all four projection values `image\|audio\|text\|3d-mesh` (was `image\|audio\|text`), matching the authoritative projection defined in the Preconditions. |
| Total 196 → 198 | E-COMP family: 2 → 4. Total registered (incl. retired E-GEN): 198. Active codes only: 189. |

---

### PRD Revision 1.6 Changes (check-k completeness fix)

| Change | Detail |
|--------|--------|
| E-GEN retired | **CRITICAL:** E-GEN (9 codes) was an orphaned placeholder added in v1.1. No BC in ss-04 or any other subsystem referenced any E-GEN-NNN code — the ss-04 BCs use the granular families below. Removed from active count (139 → 130 pre-addition). Retained in retired table for historical traceability. |
| E-AAG added (7 codes) | **CRITICAL:** New family for asset-adapter routing and generation orchestrator errors. Covers BC-4.01.001 (E-AAG-001/002: backend_class validation), BC-4.01.002 (E-AAG-010/011: no eligible adapter), BC-4.01.004 (E-AAG-020/021/022: music litigation blocklist). |
| E-SVC added (6 codes) | **CRITICAL:** New family for GenerationRequest service validation. Covers BC-4.02.001 (E-SVC-001..005: schema validation failure paths), BC-4.02.002 (E-SVC-010: risk_tier mismatch). |
| E-PRV extended (+5 codes) | **CRITICAL:** Added E-PRV-001/002/003 (BC-4.03.001 sidecar completeness failure paths), E-PRV-020 (BC-4.03.003 copyrightability_assessment absent), E-PRV-030 (BC-4.03.004/BC-4.05.001 SAG-AFTRA consent ship-gate block). E-PRV-010/011/012 were already registered (v1.2). |
| E-QG added (11 codes) | **CRITICAL:** New family for quality gate per-modality check failures. Covers BC-4.04.001 (E-QG-001..005: 3D mesh checks), BC-4.04.002 (E-QG-005/010/011/012: audio checks), BC-4.04.003 (E-QG-005/020/021/022: 2D image checks). E-QG-005 is shared across all three QG BCs (provenance hard gate). |
| E-SHIP added (3 codes) | **CRITICAL:** New family for ship gate license checks (BC-4.05.001). |
| E-ING added (4 codes) | **CRITICAL:** New family for asset store ingest pre-flight (BC-4.06.001). |
| E-GLG added (5 codes) | **CRITICAL:** New family for genre-lane gate sub-lane config/schema errors. Covers BC-13.01.001 (E-GLG-001/002), BC-13.02.001 (E-GLG-003), BC-13.02.002 (E-GLG-004), BC-13.02.005 (E-GLG-005). |
| E-MOD added (11 codes) | **CRITICAL:** New family for modding/UGC lane errors. Covers BC-13.03.001 (E-MOD-001), BC-13.03.002 (E-MOD-002..005), BC-13.03.003 (E-MOD-006..008), BC-13.03.004 (E-MOD-009..011). |
| E-MKT added (4 codes) | **CRITICAL:** New family for marketing lane asset conformance. Covers BC-13.04.001 (E-MKT-001/002), BC-13.04.002 (E-MKT-003/004). |
| E-XR extended (+1 code) | **CRITICAL:** Added E-XR-007 (visionOS manifest with OpenXR fields, BC-14.02.003). |
| Total 139 → 196 (CI-computed) | **Net:** +57 new codes (E-AAG×7 + E-SVC×6 + E-PRV×5 + E-QG×11 + E-SHIP×3 + E-ING×4 + E-GLG×5 + E-MOD×11 + E-MKT×4 + E-XR×1) = 139 + 57 = **196 total registered codes** (CI computes all distinct E-xxx-NNN tokens including retired E-GEN). E-GEN (9 codes) retired but its codes remain in the taxonomy as a retired table, so CI still counts them. Active families: 22 − 1 (E-GEN retired) + 8 new = **29 active families**. Active codes only (excl. E-GEN): **187**. |
| Total 196 → 198 (PRD rev 1.7) | **+E-COMP-011** (out-of-vocabulary `disclosure_class` at manifest aggregation; I-1 fix) and **+E-COMP-012** (`nft_blockchain`/`nft_mechanics` inconsistency seam guard; I-2 fix). E-COMP family: 2 → 4. Total all registered (incl. retired E-GEN): **198**. Active codes only (excl. E-GEN): **189**. |

**Total defined error codes: 267** across 34 families (33 active + 1 retired E-GEN). Per-family breakdown (active codes: 258; retired codes: 9 E-GEN):

| Family | Code Count | Notes |
|--------|-----------|-------|
| E-EAP | 13 | v1.1: +E-EAP-011; v1.2: +E-EAP-012 (MalformedManifest), +E-EAP-013 (HumanGatedTaskPending) |
| E-CONF | 5 | v1.1 addition |
| E-REPLAY | 18 | v1.1: 7 codes; v2.0: +E-REPLAY-008..018 (11 new — symbolic token reconciliation Pass-20) |
| E-AAG | 7 | v1.6 addition: routing/backend-selection errors (BC-4.01.*) |
| E-SVC | 6 | v1.6 addition: GenerationRequest validation (BC-4.02.*) |
| E-PRV | 8 | v1.2: E-PRV-010/011/012 (disclosure_class); v1.6: +E-PRV-001/002/003/020/030 |
| E-QG | 11 | v1.6 addition: quality gate per-modality checks (BC-4.04.*) |
| E-SHIP | 3 | v1.6 addition: ship gate license check (BC-4.05.001) |
| E-ING | 4 | v1.6 addition: ingest pre-flight (BC-4.06.001) |
| E-DES | 5 | |
| E-ART | 3 | |
| E-AUD | 4 | |
| E-NAR | 6 | v2.0: +E-NAR-005 (undeclared variable, BC-5.04.001), +E-NAR-006 (invalid naming-registry regex, BC-5.04.002) — F-20-02 fix |
| E-ENG | 4 | v2.2: +E-ENG-003 (UnclassifiedModule), +E-ENG-004 (TestScopedToWrongModule) — F39-02 fix |
| E-CIN | 6 | v2.2: +E-CIN-005 (TimestampOutOfRange), +E-CIN-006 (BlendshapeTrackSetIncomplete) — F39-02 fix |
| E-PROD | 3 | |
| E-CERT | 3 | |
| E-DIST | 19 | |
| E-COMP | 4 | v1.7: +E-COMP-011 (out-of-vocab disclosure_class at manifest aggregation), +E-COMP-012 (nft_blockchain/nft_mechanics inconsistency seam guard); v2.1: E-COMP-012 scope extended to 3-signal (adds NFT_MECHANIC content-descriptor tag, F37-01) — count unchanged |
| E-SIM | 9 | v1.1 addition |
| E-CONV | 6 | v1.1 addition |
| E-PLAY | 15 | v1.1: 5 codes; v2.0: +E-PLAY-006..015 (10 new — symbolic token reconciliation Pass-20) |
| E-ETH | 14 | v1.1 addition; v1.2: +E-ETH-009; v1.5: +E-ETH-010..014 (DP-005/004/003/008/006 dedicated codes) |
| E-KB | 26 | v1.1: 7 codes; v2.0: +E-KB-008..026 (19 new — symbolic token reconciliation Pass-20) |
| E-GENRE | 6 | v1.1 addition |
| E-GLG | 5 | v1.6 addition: genre sub-lane gate config errors (BC-13.01.*/13.02.*/13.03.*/13.04.*) |
| E-MOD | 11 | v1.6 addition: modding/UGC lane (BC-13.03.*) |
| E-MKT | 4 | v1.6 addition: marketing lane (BC-13.04.*) |
| E-XR | 7 | v1.1: 6 codes; v1.6: +E-XR-007 (visionOS/OpenXR namespace error) |
| ~~E-GEN~~ | ~~9~~ | **RETIRED v1.6** — orphaned placeholder; no BC ever referenced these codes |
| E-OSVC | 16 | v1.9 addition: online-services adapter (CAP-015) — identity, cloud-save, leaderboards, matchmaking, entitlements, remote-config, seam integrity; v2.2: +E-OSVC-016 (SaveSizeLimitExceeded) — F39-01 fix |
| E-TMOD | 3 | v2.3 addition (Pass-42): moderation pipeline contract (CAP-013, BC-13.03.005) |
| E-ANTICH | 3 | v2.3 addition (Pass-42): anti-cheat provider policy (CAP-013, BC-13.02.006) |
| E-SEC | 1 | v2.3 addition (Pass-42): output-bundle secrets gate (CAP-001, BC-1.15.003) |
| **TOTAL (all registered incl. retired E-GEN)** | **267** | Sum of all rows including retired E-GEN; CI-computed unique E-XXX-NNN count = 267 |
| *(active only, excl. E-GEN retired)* | *258* | Active codes only (33 active families) |

---

### PRD Revision 1.5 Changes (I6-02 fix)

| Change | Detail |
|--------|--------|
| E-ETH-010 added | **CRITICAL (I6-02):** New code for DP-005 (gacha odds disclosure). Emitted by BC-11.03.001. Replaces unregistered symbolic names GACHA_ODDS_DISCLOSURE_MISSING / _INCOMPLETE / _PROBABILITY_INCONSISTENT, which are now `error.data.reason` sub-codes of this registered parent. |
| E-ETH-011 added | **CRITICAL (I6-02):** New code for DP-004 (pay-to-win in ranked). Emitted by BC-11.03.002. Replaces unregistered symbolic name PAY_TO_WIN_IN_RANKED_DETECTED. |
| E-ETH-012 added | **CRITICAL (I6-02):** New code for DP-003 (loss-triggered purchase prompt). Emitted by BC-11.03.003. Replaces unregistered symbolic name LOSS_TRIGGERED_PURCHASE_PROMPT_DETECTED. |
| E-ETH-013 added | **CRITICAL (I6-02):** New code for DP-008 (minor loot box / gacha access). Emitted by BC-11.03.004. Replaces unregistered symbolic names MINOR_LOOT_BOX_ACCESS_VIOLATION / MINOR_PROTECTION_UNIMPLEMENTED. |
| E-ETH-014 added | **CRITICAL (I6-02):** New code for DP-006 (best-value label deceptive). Emitted by BC-11.03.005. Replaces unregistered symbolic name BEST_VALUE_LABEL_DECEPTIVE. |
| SS-09 symbolic name crosswalk added | **IMPORTANT (I6-02):** ETHICS_CONTRACT_ABSENT / ETHICS_CONTRACT_INVALID → E-ETH-001/002; UNCONSTRAINED_LTV_OBJECTIVE_DETECTED / UNCONSTRAINED_OPTIMIZATION_DETECTED / OPTIMIZATION_OBJECTIVE_WITHOUT_CONSTRAINTS → E-ETH-003; SPEND_CONCENTRATION_EXCEEDS_ETHICS_BOUND → E-ETH-008. All symbolic names now resolve to a registered E-ETH-NNN parent via `error.data.reason` sub-code pattern. |
| DP→E-ETH crosswalk table added | **IMPORTANT (I6-02):** Added dedicated crosswalk tables (DP→registered code and symbolic→registered parent) to the E-ETH section header. Every BC that emits an E-ETH error now cites only registered E-ETH-NNN codes; symbolic names are sub-code payload fields only. |
| Total 134→139 | **IMPORTANT (I6-02):** E-ETH family 9→14 codes. Per-family table and authoritative total updated consistently. |

---

### PRD Revision 1.4 Changes

| Change | Detail |
|--------|--------|
| Stale v1.1 total removed (I3) | **IMPORTANT:** Removed contradictory `Total defined error codes (v1.1): 137 across 21 families` statement. The authoritative total is 134 across 22 families per the per-family table in § PRD Revision 1.2 Changes. The stale figure was a historical snapshot that was never updated after v1.2 additions; it could cause CI tools reading past the first total match to encounter conflicting data. |
| E-ETH v1.1 changelog clarified (I3) | **IMPORTANT:** Annotated E-ETH v1.1 resolution row to read "8 codes at v1.1 launch; 9 codes current — E-ETH-009 added in v1.2", preventing the historical figure from being misread as the current code count. |

---

### PRD Revision 1.2 Changes

| Change | Detail |
|--------|--------|
| E-GEN-004 vocabulary corrected | **CRITICAL (C2):** Changed `[ai_generated, human_modified, human_created]` → `[pre-generated, live-generated, procedural-exempt]`. The old values were incorrect; the canonical vocabulary is defined in BC-4.03.002 and methodology-layer.md. This field is EU AI Act Art. 50 compliance-load-bearing. |
| E-PRV family added | **CRITICAL (C3):** New family with 3 codes (E-PRV-010/011/012) maps the three distinct failure paths from BC-4.03.002 (null/absent, out-of-vocabulary, procedural-exempt on neural model). BC-4.03.002 already referenced these codes; they were missing from this registry. |
| E-ETH-009 added | **CRITICAL (C5):** New code for DP-007 (whale hunting / predatory targeting). Emitted by BC-11.03.006. |
| E-ETH-005 corrected | **IMPORTANT (I4):** Removed `(DP-007 equivalent)` mislabel — E-ETH-005 covers progression deadlock (BC-11.02.003 / no-spend-required invariant), which is a distinct pattern from DP-007 (vulnerability-targeted offer escalation). Now references BC-11.02.003 correctly. |
| E-SIM-009 corrected | **IMPORTANT (I4):** Changed `(D-012)` → `(DI-012)`. `D-012` is an orchestrator tracking ID; `DI-012` is the domain invariant. |
| E-EAP-011 reassigned; E-EAP-012/013 added | **CRITICAL (C4, arch cross-edit):** E-EAP-011 (KernelAntiCheatAttempted) was assigned JSON-RPC code -32007, which collided with -32007 (`MalformedManifest`) defined in adapter-protocols.md §1.5. Resolved by reassigning E-EAP-011 to **-32009** (next available in protocol-reserved range). Added E-EAP-012 (`MalformedManifest`, -32007) and E-EAP-013 (`HumanGatedTaskPending`, -32008) as registered E-EAP entries — these codes exist in adapter-protocols.md §1.5 but were absent from this registry. E-EAP-013 is load-bearing: it carries the DI-006 / ADR-0007 `human-gated` signal. |
| E-CIN-003 wording corrected | **IMPORTANT (I5, arch cross-edit):** Changed "human-gated checklist item" vocabulary to "cinematic-director creative sign-off" to unambiguously distinguish the D-013 creative gate from the ADR-0007 `human-gated` fidelity tier. |

---

### PRD Revision 1.1 Changes

All 14 capability families now have defined error families. The following previously-flagged
gaps are now resolved:

| Capability | Previous Status | Resolution |
|-----------|----------------|------------|
| CAP-002 (Conformance Gating) | No error table | **E-CONF added** (5 codes) |
| CAP-003 (Replay Regression) | No error table | **E-REPLAY added** (7 codes) |
| CAP-004 (Asset Generation) | No error table | **E-GEN added** (9 codes; retired in v1.6 as orphaned placeholder) |
| CAP-006 (Simulation QA) | No error table | **E-SIM added** (9 codes) |
| CAP-007 (Convergence) | No error table | **E-CONV added** (6 codes) |
| CAP-008 (Playtest) | No error table | **E-PLAY added** (5 codes) |
| CAP-011 (Monetization Ethics) | No error table | **E-ETH added** (8 codes at v1.1 launch; 9 codes current — E-ETH-009 added in v1.2) |
| CAP-012 (Canon KB) | No error table | **E-KB added** (7 codes) |
| CAP-013 (Genre Lanes) | No error table | **E-GENRE added** (6 codes) |
| CAP-014 (XR Seam) | No error table | **E-XR added** (6 codes) |

**E-EAP extended:** E-EAP-011 (KernelAntiCheatAttempted) added to enforce BC-1.15.002 / DI-010.

_Historical snapshot (v1.1 at launch): 126 codes across 21 families (was 59 / 11 families in PRD v1.0). Current total is 134 across 22 families — see the authoritative per-family table above._
