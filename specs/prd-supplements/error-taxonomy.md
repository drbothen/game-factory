---
document_type: prd-supplement
level: L3
section: error-taxonomy
version: "1.2"
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
| E-CONF | CAP-002 | Engine adapter conformance suite errors | error-taxonomy.md §E-CONF (added PRD rev 1.1) |
| E-REPLAY | CAP-003 | Deterministic replay harness errors | error-taxonomy.md §E-REPLAY (added PRD rev 1.1) |
| E-GEN | CAP-004 | Asset generation pipeline errors | error-taxonomy.md §E-GEN (added PRD rev 1.1) |
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
| E-COMP | CAP-010 | Compliance pipeline errors | prd-cap-009-010.md §4 |
| E-ETH | CAP-011 | Monetization ethics contract errors | error-taxonomy.md §E-ETH (added PRD rev 1.1) |
| E-KB | CAP-012 | Canon Knowledge-Base structural errors | error-taxonomy.md §E-KB (added PRD rev 1.1) |
| E-GENRE | CAP-013 | Genre-gated lane activation errors | error-taxonomy.md §E-GENRE (added PRD rev 1.1) |
| E-XR | CAP-014 | XR platform seam errors | error-taxonomy.md §E-XR (added PRD rev 1.1) |
| E-PRV | CAP-004 | Provenance sidecar `disclosure_class` field validation errors | error-taxonomy.md §E-PRV (added PRD rev 1.2) |

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
| E-CIN-003 | Directed flag missing creative gate | broken | 1 | `sequence-graph '<seq_id>' has directed=true but no cinematic-director creative sign-off record found (creative gate, not human-gated fidelity tier — see D-013 distinction in methodology-layer.md §2.8)` |
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

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-REPLAY-001 | Input stream | broken | 1 | `replay: input-stream file '<path>' missing or corrupt for session '<session_id>'` |
| E-REPLAY-002 | Tier mismatch | broken | 1 | `replay: requested comparison method '<method>' not available for declared tier '<tier>'` |
| E-REPLAY-003 | Golden state missing | broken | 1 | `replay: golden-state snapshot not found for '<session_id>' v<version> — bootstrap required` |
| E-REPLAY-004 | Golden state invalid | broken | 1 | `replay: golden-state snapshot '<snapshot_id>' failed integrity check; re-bootstrap required` |
| E-REPLAY-005 | Regression detected | broken | 1 | `replay: T1 regression at frame <frame_id>: snapshot hash mismatch — injected change or non-determinism detected` |
| E-REPLAY-006 | Replay diverged (T2) | degraded | 1 | `replay: T2 pinned-runner divergence at frame <frame_id>: <diff_summary>` |
| E-REPLAY-007 | Tolerance exceeded (T3) | degraded | 1 | `replay: T3 metric '<metric>' at frame <frame_id> = <value>, tolerance = ±<tol>` |

---

## E-GEN — Asset Generation Pipeline (CAP-004)

Quality gate failures are returned in `GenerationResult`. The error codes below cover
routing, backend policy, and sidecar failures that constitute hard stops.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-GEN-001 | Backend blocked | broken | 1 | `asset-gen: backend '<backend_id>' is ToS-excluded or litigation-exposed — generation refused` |
| E-GEN-002 | Schema invalid | broken | 1 | `asset-gen: GenerationRequest validation failed: <field> at <path>` |
| E-GEN-003 | Sidecar incomplete | broken | 1 | `asset-gen: provenance sidecar for asset '<asset_id>' missing required field '<field>' — ingest blocked (DI-003)` |
| E-GEN-004 | Disclosure class invalid | broken | 1 | `asset-gen: asset '<asset_id>' has invalid disclosure_class '<value>'; expected one of [pre-generated, live-generated, procedural-exempt]` |
| E-GEN-005 | Consent gate | broken | 1 | `asset-gen: asset '<asset_id>' has likeness_consent_ref but no human-gated SAG-AFTRA task has been created` |
| E-GEN-006 | Quality gate fail | broken | 1 | `asset-gen: asset '<asset_id>' failed quality gate check '<check>': <value> vs threshold <threshold>` |
| E-GEN-007 | License gate fail | broken | 1 | `asset-gen: ship gate blocked — asset '<asset_id>' has commercial_use: false or unresolved free-tier restriction` |
| E-GEN-008 | Backend routing fail | broken | 1 | `asset-gen: no eligible backend for asset class '<class>' after applying preference ordering and blocklist` |
| E-GEN-009 | Risk tier absent | broken | 1 | `asset-gen: GenerationRequest '<req_id>' has no risk_tier assigned — required before dispatch` |

---

## E-PRV — Provenance Sidecar Disclosure Class Validation (CAP-004)

The three E-PRV codes map directly to the three failure paths defined in BC-4.03.002.
They are separate from E-GEN-004 (which covers any general schema invalidity); E-PRV
codes are emitted during the BC-4.03.002 decision-tree evaluation step specifically.
BC-4.03.002 originally referenced E-PRV-010/011/012; E-GEN-004 covers the same violation
class at the broader schema-validation layer but with a non-specific message. Implementers
should raise E-PRV-010/011/012 when the validation failure is specifically the
`disclosure_class` field value; E-GEN-004 covers any other sidecar schema field failure.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-PRV-010 | Disclosure class null/absent | broken | 1 | `asset-gen: asset '<asset_id>' sidecar missing disclosure_class — field is required and may not be null (BC-4.03.002 failure path A)` |
| E-PRV-011 | Disclosure class out-of-vocabulary | broken | 1 | `asset-gen: asset '<asset_id>' disclosure_class '<value>' not in allowed set {pre-generated, live-generated, procedural-exempt} (BC-4.03.002 failure path B)` |
| E-PRV-012 | Procedural-exempt misuse on neural model | broken | 1 | `asset-gen: asset '<asset_id>' disclosure_class 'procedural-exempt' invalid for neural-model adapter '<adapter_id>'; only classical procedural generation qualifies (BC-4.03.002 failure path C)` |

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

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-PLAY-001 | Protocol schema | broken | 1 | `playtest: protocol document '<doc_id>' failed schema validation: <field> missing` |
| E-PLAY-002 | Reviewer invalid | broken | 1 | `playtest: sign-off record '<record_id>' has reviewer_id '<id>' not in human-reviewer allowlist` |
| E-PLAY-003 | Fun score emitted | broken | 1 | `playtest: agent '<agent_id>' emitted automated fun-score '<score>' — violates DI-007; artifact rejected` |
| E-PLAY-004 | Evidence incomplete | broken | 1 | `playtest: convergence report '<report_id>' missing lens evidence for '<lens>'; 3-lens (say/do/behave) required` |
| E-PLAY-005 | Sign-off suppressed | broken | 1 | `playtest: human sign-off gate for session '<session_id>' was suppressed or bypassed — violates DI-006` |

---

## E-ETH — Monetization Ethics Enforcement (CAP-011)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-ETH-001 | Contract missing | broken | 1 | `ethics: monetization present but no monetization-ethics-contract found for project '<project_id>'` |
| E-ETH-002 | Contract schema | broken | 1 | `ethics: ethics-contract '<contract_id>' failed schema validation: <field>` |
| E-ETH-003 | Unconstrained LTV | broken | 1 | `ethics: agent '<agent_id>' produced unconstrained LTV optimization objective without declared ethics-contract — violates DI-005` |
| E-ETH-004 | Dark pattern | broken | 1 | `ethics: forbidden dark pattern '<dp_id>' detected in artifact '<artifact_id>': <description>` |
| E-ETH-005 | Progression deadlock | broken | 1 | `ethics: progression deadlock detected — player has no path to '<goal>' without spend (see BC-11.02.003)` |
| E-ETH-006 | Adversarial review absent | broken | 1 | `ethics: convergence gate blocked — D-ETHICS dimension requires adversarial review but no review record found for contract '<contract_id>'` |
| E-ETH-007 | Gacha EV invalid | broken | 1 | `ethics: gacha pool '<pool_id>' expected value <ev> outside permitted range [<min>, <max>]` |
| E-ETH-008 | Gini coefficient exceeded | broken | 1 | `ethics: spend-concentration Gini coefficient = <gini> for cohort '<cohort_id>', exceeds bound <max>` |
| E-ETH-009 | Predatory targeting detected (DP-007) | broken | 1 | `ethics: segmentation-ltv-spec '<spec_id>' contains offer-escalation rule conditioned on vulnerability proxy '<proxy_field>' — predatory targeting pattern DP-007 detected` |

---

## E-KB — Canon Knowledge-Base (CAP-012)

Canon-KB structural errors are returned in query results. The error codes below cover
ingest-time structural violations that are hard stops.

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-KB-001 | Schema init | broken | 1 | `canon-kb: KB '<kb_id>' failed schema initialization: <field> missing` |
| E-KB-002 | Entity ID collision | broken | 1 | `canon-kb: entity_id '<id>' already registered; duplicate entity registration rejected` |
| E-KB-003 | Dangling ref | broken | 1 | `canon-kb: relationship edge '<edge_id>' references entity '<entity_id>' not in registry` |
| E-KB-004 | Timeline conflict | broken | 1 | `canon-kb: event '<event_id>' at t=<t1> conflicts with event '<event_id2>' at t=<t2> for entity '<entity_id>'` |
| E-KB-005 | Naming collision | broken | 1 | `canon-kb: name '<name>' conflicts with existing registry entry '<existing_id>'` |
| E-KB-006 | Retcon unresolved | degraded | 0 | `canon-kb: retcon '<retcon_id>' affects <n> downstream entities; impact analysis incomplete — grounding agents paused` |
| E-KB-007 | Grounding absent | broken | 1 | `canon-kb: artifact '<artifact_id>' from required-grounding agent '<agent_id>' missing grounded_against tag` |

---

## E-GENRE — Genre-Gated Lane Activation (CAP-013)

| Error Code | Category | Severity | Exit Code | Message Format |
|-----------|----------|----------|-----------|----------------|
| E-GENRE-001 | Profile schema | broken | 1 | `genre: profile document failed schema validation: <field> at <path>` |
| E-GENRE-002 | Inactive lane artifact | broken | 1 | `genre: artifact '<artifact_id>' produced by inactive lane '<lane_id>' — inactive-lane zero-artifact invariant violated` |
| E-GENRE-003 | Lane activation conflict | broken | 1 | `genre: lane '<lane_id>' activation request conflicts with existing lane state — idempotency violation` |
| E-GENRE-004 | NFT/web3 opt-in missing | broken | 1 | `genre: nft_mechanics or web3_enabled set to true but no business-model-spec document found — explicit opt-in required (DI-011)` |
| E-GENRE-005 | PEGI-18 not acknowledged | broken | 1 | `genre: business-model-spec declares nft_mechanics: true but pegi_18_acknowledged: false — PEGI 18 consequence must be acknowledged` |
| E-GENRE-006 | Mod-API version conflict | broken | 1 | `genre: mod-api '<api_id>' version '<ver>' violates semver stability contract for existing mods` |

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

---

## Coverage Notes

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

**Total defined error codes: 143** across 22 families (was 141 / 22 families in PRD v1.2; +2 from C4 JSON-RPC reconciliation: E-EAP-012 MalformedManifest, E-EAP-013 HumanGatedTaskPending; E-EAP-011 reassigned from -32007 to -32009 to resolve collision).

---

### PRD Revision 1.1 Changes

All 14 capability families now have defined error families. The following previously-flagged
gaps are now resolved:

| Capability | Previous Status | Resolution |
|-----------|----------------|------------|
| CAP-002 (Conformance Gating) | No error table | **E-CONF added** (5 codes) |
| CAP-003 (Replay Regression) | No error table | **E-REPLAY added** (7 codes) |
| CAP-004 (Asset Generation) | No error table | **E-GEN added** (9 codes) |
| CAP-006 (Simulation QA) | No error table | **E-SIM added** (9 codes) |
| CAP-007 (Convergence) | No error table | **E-CONV added** (6 codes) |
| CAP-008 (Playtest) | No error table | **E-PLAY added** (5 codes) |
| CAP-011 (Monetization Ethics) | No error table | **E-ETH added** (8 codes) |
| CAP-012 (Canon KB) | No error table | **E-KB added** (7 codes) |
| CAP-013 (Genre Lanes) | No error table | **E-GENRE added** (6 codes) |
| CAP-014 (XR Seam) | No error table | **E-XR added** (6 codes) |

**E-EAP extended:** E-EAP-011 (KernelAntiCheatAttempted) added to enforce BC-1.15.002 / DI-010.

**Total defined error codes (v1.1): 137** across 21 families (was 59 / 11 families in PRD v1.0).
