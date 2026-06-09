---
document_type: behavioral-contract-index
level: L3
version: "1.8"
status: draft
producer: product-owner
timestamp: 2026-06-09T00:00:00Z
phase: 1a
traces_to: prd.md
inputs:
  - .factory/specs/behavioral-contracts/ss-01/
  - .factory/specs/behavioral-contracts/ss-02/
  - .factory/specs/behavioral-contracts/ss-03/
  - .factory/specs/behavioral-contracts/ss-04/
  - .factory/specs/behavioral-contracts/ss-05/
  - .factory/specs/behavioral-contracts/ss-06/
  - .factory/specs/behavioral-contracts/ss-07/
  - .factory/specs/behavioral-contracts/ss-08/
  - .factory/specs/behavioral-contracts/ss-09/
  - .factory/specs/behavioral-contracts/ss-10/
  - .factory/specs/behavioral-contracts/ss-11/
  - .factory/specs/behavioral-contracts/ss-12/
  - .factory/specs/behavioral-contracts/ss-13/
  - .factory/specs/behavioral-contracts/ss-14/
  - .factory/specs/behavioral-contracts/ss-15/
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# Behavioral Contracts Index

> **Subsystem IDs are now assigned.** All BC frontmatter `subsystem:` fields have been
> populated from the architect's ARCH-INDEX Subsystem Registry (see
> `.factory/specs/architecture/subsystem-decomposition.md`). The directory names `ss-NN`
> mirror capability numbers (CAP-001 = ss-01, etc.) for navigability only and are NOT
> architecture subsystem IDs. The subsystem mapping is documented in the Summary table below.

**Grand total: 190 behavioral contracts** across 15 capabilities. (178 from CAP-001..014 + 12 added in v1.5 for CAP-015 online-services adapter: BC-15.01.001, BC-15.01.002, BC-15.02.001, BC-15.03.001, BC-15.04.001, BC-15.05.001, BC-15.06.001, BC-15.07.001, BC-15.08.001, BC-15.09.001, BC-15.10.001, BC-15.11.001. v1.5: CAP-015/SS-13 online-services seam BCs (12 BCs); new E-OSVC error family (15 codes) registered. v1.8: Pass-39 F39-01/F39-02 error-code semantic-fit fixes — E-OSVC-016, E-ENG-003/004, E-CIN-005/006 registered; total error codes 255→260. BC count unchanged: 190.)

---

## CAP-001 — Engine-Agnostic Game Build and Test (P0) — 35 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-001.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-1.01.001 | JSON-RPC 2.0 stdio Transport with LSP-Style Content-Length Framing | P0 | ss-01/BC-1.01.001.md | active |
| BC-1.02.001 | initialize Handshake Returns Capability Manifest | P0 | ss-01/BC-1.02.001.md | active |
| BC-1.02.002 | Protocol Version Incompatibility Returns ProtocolVersionMismatch Error | P0 | ss-01/BC-1.02.002.md | active |
| BC-1.02.003 | shutdown Request Flushes In-Flight Work and Stops Accepting New Requests | P0 | ss-01/BC-1.02.003.md | active |
| BC-1.02.004 | exit Notification Terminates the Adapter Process | P0 | ss-01/BC-1.02.004.md | active |
| BC-1.03.001 | Adapter Upgrades a Capability via capability/register After Project Inspection | P0 | ss-01/BC-1.03.001.md | active |
| BC-1.03.002 | Adapter Downgrades a Capability via capability/unregister | P0 | ss-01/BC-1.03.002.md | active |
| BC-1.03.003 | Core Re-Plans Gates After Capability Registration Change | P0 | ss-01/BC-1.03.003.md | active |
| BC-1.04.001 | Every Adapter Declares headless-compute and render Execution Profiles | P0 | ss-01/BC-1.04.001.md | active |
| BC-1.04.002 | render Profile Declares GPU Backend Requirements | P0 | ss-01/BC-1.04.002.md | active |
| BC-1.05.001 | build Capability Returns Normalized BuildResult | P0 | ss-01/BC-1.05.001.md | active |
| BC-1.05.002 | build Failure Returns OperationFailed with Diagnostics | P0 | ss-01/BC-1.05.002.md | active |
| BC-1.06.001 | test Capability Normalizes Engine-Native Format to TestResult | P0 | ss-01/BC-1.06.001.md | active |
| BC-1.06.002 | Test Failure Cases Reported Per-Test with status fail and message | P0 | ss-01/BC-1.06.002.md | active |
| BC-1.06.003 | test Capability Reports capabilityFidelity in TestResult | P0 | ss-01/BC-1.06.003.md | active |
| BC-1.07.001 | runHeadless Runs Game Process Without Display and Returns RunResult | P0 | ss-01/BC-1.07.001.md | active |
| BC-1.07.002 | runHeadless Timeout and Crash Are Distinguished Exit Statuses | P0 | ss-01/BC-1.07.002.md | active |
| BC-1.08.001 | capture/screenshot on render Profile Returns CaptureResult with media Path | P0 | ss-01/BC-1.08.001.md | active |
| BC-1.08.002 | capture Returns ProfileUnavailable When render Profile Is Absent | P0 | ss-01/BC-1.08.002.md | active |
| BC-1.08.003 | capture/frames Returns Ordered Frame Sequence Paths | P0 | ss-01/BC-1.08.003.md | active |
| BC-1.09.001 | lint Capability Returns Normalized LintResult with Per-Finding Severity | P0 | ss-01/BC-1.09.001.md | active |
| BC-1.10.001 | assetsValidate Returns AssetValidateResult with Per-Asset Status | P0 | ss-01/BC-1.10.001.md | active |
| BC-1.10.002 | partial Fidelity assetsValidate Declares Method and Coverage Limitation | P0 | ss-01/BC-1.10.002.md | active |
| BC-1.11.001 | introspect Returns Normalized IntrospectResult with Root Entity Tree | P0 | ss-01/BC-1.11.001.md | active |
| BC-1.11.002 | introspect Normalizes ECS World-Dump and Scene-Tree Formats to Common root | P0 | ss-01/BC-1.11.002.md | active |
| BC-1.12.001 | Adapter Declares determinismTier in Capability Manifest | P0 | ss-01/BC-1.12.001.md | active |
| BC-1.12.002 | Core Selects Replay Comparison Method from Declared determinismTier | P0 | ss-01/BC-1.12.002.md | active |
| BC-1.12.003 | DeterminismTierViolation Returned When Core Requests Stricter Comparison Than Tier Allows | P0 | ss-01/BC-1.12.003.md | active |
| BC-1.13.001 | Calling a none-Fidelity Capability Returns CapabilityUnsupported | P0 | ss-01/BC-1.13.001.md | active |
| BC-1.13.002 | Core Degrades Convergence Dimension on CapabilityUnsupported Without Pipeline Failure | P0 | ss-01/BC-1.13.002.md | active |
| BC-1.13.003 | ProfileUnavailable Is Caught and headless-compute Capabilities Continue | P0 | ss-01/BC-1.13.003.md | active |
| BC-1.14.001 | Adapter Pins Exactly One engineVersion in the Capability Manifest | P0 | ss-01/BC-1.14.001.md | active |
| BC-1.14.002 | Core Compatibility Matrix Maps Core Version to Supported Protocol Major Versions | P0 | ss-01/BC-1.14.002.md | active |
| BC-1.15.001 | Factory Core Source Artifacts Contain No Engine SDK Imports or Engine Name References | P0 | ss-01/BC-1.15.001.md | active |
| BC-1.15.002 | Factory Core Output Contains No Kernel-Mode or Ring-0 Authored Code (Never-Author Enforcement) | P0 | ss-01/BC-1.15.002.md | active |

---

## CAP-002 — Engine Adapter Conformance Gating (P0) — 6 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-002-003.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-2.02.001 | Capability-Gated Conformance Test Selection | P0 | ss-02/BC-2.02.001.md | active |
| BC-2.02.002 | Conformance Acceptance Gate (Fail-Closed for Writes) | P0 | ss-02/BC-2.02.002.md | active |
| BC-2.02.003 | Fidelity-Declared Conformance (Partial-Pass Semantics) | P0 | ss-02/BC-2.02.003.md | active |
| BC-2.02.004 | Conformance Suite Versioning and Core-Adapter Compatibility Matrix | P0 | ss-02/BC-2.02.004.md | active |
| BC-2.02.005 | Conformance Re-Run on Engine Minor Release (Anti-Drift Scheduled Check) | P0 | ss-02/BC-2.02.005.md | active |
| BC-2.02.006 | Reference Mini-Game Acceptance Validation | P0 | ss-02/BC-2.02.006.md | active |

---

## CAP-003 — Determinism-Tier-Governed Replay Regression (P0) — 9 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-002-003.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-3.03.001 | Input Stream Recording Keyed by Sim Frame | P0 | ss-03/BC-3.03.001.md | active |
| BC-3.03.002 | Deterministic Replay Execution with Identical Tick Schedule | P0 | ss-03/BC-3.03.002.md | active |
| BC-3.03.003 | T1 Exact Snapshot-Hash Comparison (bitwise-cross-platform) | P0 | ss-03/BC-3.03.003.md | active |
| BC-3.03.004 | T2 Pinned-Runner Snapshot Diff (same-machine) | P0 | ss-03/BC-3.03.004.md | active |
| BC-3.03.005 | T3 Tolerance-Window Metric Comparison (tolerance-only) | P0 | ss-03/BC-3.03.005.md | active |
| BC-3.03.006 | Regression Detection at T1 (100-Percent Sensitivity for Injected Changes) | P0 | ss-03/BC-3.03.006.md | active |
| BC-3.03.007 | Replay-None Graceful Degradation to Playtest Evidence | P0 | ss-03/BC-3.03.007.md | active |
| BC-3.03.008 | Golden State Bootstrap and Invalidation Protocol | P0 | ss-03/BC-3.03.008.md | active |
| BC-3.03.009 | Esports/Anti-Cheat Dual-Use Replay Export | P0 | ss-03/BC-3.03.009.md | active |

---

## CAP-004 — Pure-Maximal Asset Generation with Auto-Provenance (P0) — 15 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-004.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-4.01.001 | AssetAdapter Declares a Valid `backend_class` from Canonical Taxonomy | P0 | ss-04/BC-4.01.001.md | active |
| BC-4.01.002 | Orchestrator Routes Generation Requests Following Declared Preference Ordering | P0 | ss-04/BC-4.01.002.md | active |
| BC-4.01.003 | ToS-Excluded Backends (OpenArt, Rosebud) Are Never Selected | P0 | ss-04/BC-4.01.003.md | active |
| BC-4.01.004 | Suno, Udio, and Litigation-Exposed Music Generators Are Blocked from Music Route | P0 | ss-04/BC-4.01.004.md | active |
| BC-4.02.001 | Every GenerationRequest Is Validated Against the Canonical Schema Before Dispatch | P0 | ss-04/BC-4.02.001.md | active |
| BC-4.02.002 | Risk Tier Is Assigned from Asset Class and Use-Case at Request Creation Time | P0 | ss-04/BC-4.02.002.md | active |
| BC-4.03.001 | Every Generated Asset Has a Complete Provenance Sidecar Populated at Generation Time (DI-003) | P0 | ss-04/BC-4.03.001.md | active |
| BC-4.03.002 | Every Provenance Sidecar Has a Valid `disclosure_class` (One of Three Exact Values) | P0 | ss-04/BC-4.03.002.md | active |
| BC-4.03.003 | Every Provenance Sidecar Carries a `copyrightability_assessment`; Assets with Empty `human_modifications_log` Receive `unlikely` | P1 | ss-04/BC-4.03.003.md | active |
| BC-4.03.004 | Any Asset with `likeness_consent_ref != null` Triggers Human-Gated SAG-AFTRA Signature Task and Is Blocked from Ship Build Until Task Is Complete | P0 | ss-04/BC-4.03.004.md | active |
| BC-4.04.001 | A Generated 3D Mesh Passes the Quality Gate Only When Manifold, Within Budget, UV-Valid, Full PBR, and Provenance Complete | P0 | ss-04/BC-4.04.001.md | active |
| BC-4.04.002 | A Generated Audio Asset Passes the Quality Gate When Loudness Is Within Target, True-Peak Does Not Exceed -1 dBTP, and Provenance Is Complete | P0 | ss-04/BC-4.04.002.md | active |
| BC-4.04.003 | A Generated 2D Image Passes the Quality Gate When Resolution Meets Target, Format Matches Declaration, and Provenance Is Complete | P1 | ss-04/BC-4.04.003.md | active |
| BC-4.05.001 | Ship Gate FAILS When Any Build Asset Has `commercial_use: false` or Unresolved Free-Tier Restriction | P0 | ss-04/BC-4.05.001.md | active |
| BC-4.06.001 | Asset Store Ingest Requires Quality Gate Pass, Complete Sidecar, and Consent-Cleared Status | P0 | ss-04/BC-4.06.001.md | active |

---

## CAP-005 — Multi-Discipline Game Artifact Production (P0) — 16 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-005.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-5.01.001 | Design Artifact Stack Produces Valid, Engine-Neutral Spec Bundle | P0 | ss-05/BC-5.01.001.md | active |
| BC-5.01.002 | Economy Graph Passes Balance-Band Invariants | P0 | ss-05/BC-5.01.002.md | active |
| BC-5.01.003 | Accessibility Contract Satisfies CVAA / GAG / XAG Checklist | P0 | ss-05/BC-5.01.003.md | active |
| BC-5.02.001 | Art Package (GLB) Passes Quality Gate and Carries Complete Provenance | P0 | ss-05/BC-5.02.001.md | active |
| BC-5.02.002 | Art Bible Spec Provides Deterministic Generation Parameters | P0 | ss-05/BC-5.02.002.md | active |
| BC-5.03.001 | Audio Build Manifest Produces Conformant Bank Build | P0 | ss-05/BC-5.03.001.md | active |
| BC-5.03.002 | AI Audio Provenance Ledger Covers All Generated Audio Assets | P0 | ss-05/BC-5.03.002.md | active |
| BC-5.04.001 | Narrative Graph Is Reachable, Dead-End-Free, and Canon-Grounded | P0 | ss-05/BC-5.04.001.md | active |
| BC-5.04.002 | Canon-KB Maintains Structural Integrity (Entity Ref + Timeline Consistency) | P0 | ss-05/BC-5.04.002.md | active |
| BC-5.05.001 | Code Module Satisfies Gameplay-Logic / Pure-Sim Separation Contract | P0 | ss-05/BC-5.05.001.md | active |
| BC-5.05.002 | Simulation Module Passes TDD Red Gate Before Production Code Exists | P0 | ss-05/BC-5.05.002.md | active |
| BC-5.06.001 | Sequence Graph Is Well-Formed, Engine-Agnostic, and Passes Structural Validation | P0 | ss-05/BC-5.06.001.md | active |
| BC-5.06.002 | Lip-Sync Pipeline Contract Produces ARKit-52 Aligned Blendshape Output | P0 | ss-05/BC-5.06.002.md | active |
| BC-5.07.001 | Cross-Discipline Dependency Contract Is Declared Before Dependent Wave Begins | P0 | ss-05/BC-5.07.001.md | active |
| BC-5.07.002 | Cross-Discipline Dependency Acceptance Criteria Are Machine-Checked on Handoff | P0 | ss-05/BC-5.07.002.md | active |
| BC-5.07.003 | Wave Schedule Respects Discipline-DAG Ordering and Emits Blocked-Wave Signals | P0 | ss-05/BC-5.07.003.md | active |

---

## CAP-006 — Contract-Driven Simulation Quality Verification (P0) — 11 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-006-007.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-6.01.001 | Economy Conservation Invariant | P0 | ss-06/BC-6.01.001.md | active |
| BC-6.01.002 | Damage I/O Matrix Correctness | P0 | ss-06/BC-6.01.002.md | active |
| BC-6.01.003 | FSM State Legality Assertion | P0 | ss-06/BC-6.01.003.md | active |
| BC-6.01.004 | AI Behavior-Tree Output Determinism | P0 | ss-06/BC-6.01.004.md | active |
| BC-6.02.001 | Design Intent Reachability Contract | P0 | ss-06/BC-6.02.001.md | active |
| BC-6.02.002 | Game Solvability Contract | P0 | ss-06/BC-6.02.002.md | active |
| BC-6.02.003 | Balance Band Invariant | P0 | ss-06/BC-6.02.003.md | active |
| BC-6.02.004 | No-Softlock Invariant | P0 | ss-06/BC-6.02.004.md | active |
| BC-6.02.005 | Playtest Delegation Declaration | P0 | ss-06/BC-6.02.005.md | active |
| BC-6.03.001 | Replay-Regression Contract Linkage | P0 | ss-06/BC-6.03.001.md | active |
| BC-6.04.001 | TDD Red Gate — Pure-Sim Slice Enforcement | P0 | ss-06/BC-6.04.001.md | active |

---

## CAP-007 — 11-Dimension Convergence Tracking (P0) — 19 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-006-007.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-7.01.001 | Sim/Spec Convergence Dimension Evaluation | P0 | ss-07/BC-7.01.001.md | active |
| BC-7.02.001 | Tests/Replay Convergence Dimension Evaluation | P0 | ss-07/BC-7.02.001.md | active |
| BC-7.03.001 | Implementation Convergence Dimension Evaluation | P0 | ss-07/BC-7.03.001.md | active |
| BC-7.04.001 | Asset-Completeness Convergence Dimension Evaluation | P0 | ss-07/BC-7.04.001.md | active |
| BC-7.05.001 | Playtest-Satisfaction Convergence Dimension Evaluation | P0 | ss-07/BC-7.05.001.md | active |
| BC-7.06.001 | Cert-Preflight and Distribution-Readiness Convergence Dimension Evaluation | P0 | ss-07/BC-7.06.001.md | active |
| BC-7.07.001 | Perf-Budget Convergence Dimension Evaluation | P0 | ss-07/BC-7.07.001.md | active |
| BC-7.08.001 | Provenance/Legal and Compliance Convergence Dimension Evaluation | P0 | ss-07/BC-7.08.001.md | active |
| BC-7.09.001 | Docs Convergence Dimension Evaluation | P0 | ss-07/BC-7.09.001.md | active |
| BC-7.10.001 | Monetization-Ethics Convergence Dimension Evaluation | P0 | ss-07/BC-7.10.001.md | active |
| BC-7.11.001 | Security-Invariants Convergence Dimension Evaluation | P0 | ss-07/BC-7.11.001.md | active |
| BC-7.11.002 | Server-Authority Invariant — No-Trust-Client (CWE-602 Core) | P0 | ss-07/BC-7.11.002.md | active |
| BC-7.11.003 | Server-Authority Invariant — Input Range, Rate, and Sequence Validation | P0 | ss-07/BC-7.11.003.md | active |
| BC-7.11.004 | Server-Authority Invariant — Replay-Attack Prevention | P0 | ss-07/BC-7.11.004.md | active |
| BC-7.11.005 | Server-Authority Invariant — Authoritative Reconciliation | P0 | ss-07/BC-7.11.005.md | active |
| BC-7.11.006 | Server-Authority Invariant — Interest Management (Anti-Wallhack) | P0 | ss-07/BC-7.11.006.md | active |
| BC-7.11.007 | Server-Authority Invariant — Economy Atomicity and Conservation | P0 | ss-07/BC-7.11.007.md | active |
| BC-7.11.008 | Server-Authority Invariant — Secure Entitlement Verification | P0 | ss-07/BC-7.11.008.md | active |
| BC-7.12.001 | Convergence Loop Engine and Release-Gating Rule | P0 | ss-07/BC-7.12.001.md | active |

---

## CAP-008 — Structured Playtest Protocol (P1) — 5 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-008-012.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-8.08.001 | Playtest Protocol Document Scaffold Generation | P1 | ss-08/BC-8.08.001.md | active |
| BC-8.08.002 | 3-Lens Evidence Capture (Say/Do/Behave) During Playtest Session | P1 | ss-08/BC-8.08.002.md | active |
| BC-8.08.003 | Playtest Convergence Report Generation (3-Lens Synthesis) | P1 | ss-08/BC-8.08.003.md | active |
| BC-8.08.004 | Human Playtest Sign-Off Gate (Mandatory, Non-Substitutable) | P1 | ss-08/BC-8.08.004.md | active |
| BC-8.08.005 | Agent-Emitted Fun-Score Detection and Defect Surfacing | P1 | ss-08/BC-8.08.005.md | active |

---

## CAP-009 — Cert Pre-Flight and Distribution-Readiness (P1) — 11 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-009-010.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-9.01.001 | Cert Pre-Flight Checklist — Platform-Scoped Machine-Checkable Run | P1 | ss-09/BC-9.01.001.md | active |
| BC-9.01.002 | Xbox GDK Submission Validator Integration in Cert Pre-Flight | P1 | ss-09/BC-9.01.002.md | active |
| BC-9.02.001 | Distribution-Adapter Manifest Declares Valid Capabilities with Correct Fidelity Values | P1 | ss-09/BC-9.02.001.md | active |
| BC-9.02.002 | Distribution-Adapter Conformance Suite Validates Declared Fidelity at Runtime | P1 | ss-09/BC-9.02.002.md | active |
| BC-9.03.001 | steamcmd Depot Upload Executes Non-Interactively and Emits Verifiable Build Record | P1 | ss-09/BC-9.03.001.md | active |
| BC-9.03.002 | butler Push Executes CI-Automatable itch.io Upload with Delta Patching | P1 | ss-09/BC-9.03.002.md | active |
| BC-9.03.003 | fastlane Upload Executes CI-Automatable Mobile Build Distribution | P1 | ss-09/BC-9.03.003.md | active |
| BC-9.04.001 | Distribution-Release-Pipeline Artifact Is Structurally Complete and Version-Stamped | P1 | ss-09/BC-9.04.001.md | active |
| BC-9.05.001 | Store-Asset Spec Conformance Report Validates Required Storefronts Assets | P1 | ss-09/BC-9.05.001.md | active |
| BC-9.06.001 | Human-Gated Console Cert Sign-Off Task Is Surfaced with Checklist, Never Suppressed | P1 | ss-09/BC-9.06.001.md | active |
| BC-9.06.002 | Human-Gated Store Publish and Pricing Task Is Surfaced After Upload, Never Auto-Published | P1 | ss-09/BC-9.06.002.md | active |

---

## CAP-010 — Compliance Pipeline and AI Disclosure (P1) — 6 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-009-010.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-10.01.001 | IARC Objective-Questionnaire Auto-Fill from Game Metadata | P1 | ss-10/BC-10.01.001.md | active |
| BC-10.02.001 | Compliance-Checklist Generated Per (Genre × Region) Profile | P1 | ss-10/BC-10.02.001.md | active |
| BC-10.03.001 | Privacy-Config-Contract Is Generated and Machine-Gated for Default-High-Privacy Settings | P1 | ss-10/BC-10.03.001.md | active |
| BC-10.04.001 | Legal-Doc-Set Is Generated as DRAFT with Structural Completeness Gate and Human-Legal-Review Flag | P1 | ss-10/BC-10.04.001.md | active |
| BC-10.05.001 | AI-Disclosure-Manifest Is a Complete Projection of Provenance Sidecars with C2PA Marks | P1 | ss-10/BC-10.05.001.md | active |
| BC-10.06.001 | Human-Gated Ratings Submission Terminal Step Is Surfaced with Complete Evidence Package | P1 | ss-10/BC-10.06.001.md | active |

---

## CAP-011 — Monetization Ethics Enforcement (P0/P1) — 14 BCs

> Priority split per D-008 (compliance/provenance = P0 wave-1): regulatory-enforcement
> BCs (ethics contract gate, forbidden patterns, COPPA/PEGI compliance) are P0;
> economy-quality BCs are P1. See prd-cap-011.md §11.8 for rationale.

Supplement: `.factory/specs/prd-supplements/prd-cap-011.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-11.01.001 | Ethics Contract Structural Validity | P0 | ss-11/BC-11.01.001.md | active |
| BC-11.01.002 | Default Ethics Envelope Application | P0 | ss-11/BC-11.01.002.md | active |
| BC-11.01.003 | Adversarial Review Evidence Gate (Fail-Closed for Convergence) | P0 | ss-11/BC-11.01.003.md | active |
| BC-11.02.001 | No Unconstrained LTV Optimization Objective (Fail-Closed for All Agents) | P0 | ss-11/BC-11.02.001.md | active |
| BC-11.02.002 | Constrained-Optimization Invariant — Economy Spine Propagation | P1 | ss-11/BC-11.02.002.md | active |
| BC-11.02.003 | No-Progression-Deadlock-Without-Spend Invariant | P1 | ss-11/BC-11.02.003.md | active |
| BC-11.03.001 | Forbidden Dark Pattern — Loot Box Without Odds Disclosure (DP-005) | P0 | ss-11/BC-11.03.001.md | active |
| BC-11.03.002 | Forbidden Dark Pattern — Pay-to-Win in Ranked Mode (DP-004) | P0 | ss-11/BC-11.03.002.md | active |
| BC-11.03.003 | Forbidden Dark Pattern — Loss-Triggered Purchase Prompt (DP-003) | P1 | ss-11/BC-11.03.003.md | active |
| BC-11.03.004 | Forbidden Dark Pattern — Minor Loot Box / Gacha Access (DP-008) | P0 | ss-11/BC-11.03.004.md | active |
| BC-11.03.005 | Forbidden Dark Pattern — Miscategorized Best-Value Bundle (DP-006) | P1 | ss-11/BC-11.03.005.md | active |
| BC-11.03.006 | Forbidden Dark Pattern — Predatory Vulnerability Targeting / Whale Hunting (DP-007) | P0 | ss-11/BC-11.03.006.md | active |
| BC-11.04.001 | Gacha EV and Pity Correctness (Ethics-Bounded) | P1 | ss-11/BC-11.04.001.md | active |
| BC-11.04.002 | Spend-Concentration Guardrail (Gini Coefficient Bound) | P1 | ss-11/BC-11.04.002.md | active |

---

## CAP-012 — Canon Knowledge-Base Grounding (P1) — 9 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-008-012.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-12.12.001 | Canon-KB Structure Initialization and Schema Validation | P1 | ss-12/BC-12.12.001.md | active |
| BC-12.12.002 | Entity Registry — Registration, Lookup, and Stable-ID Guarantee | P1 | ss-12/BC-12.12.002.md | active |
| BC-12.12.003 | Relationship-Graph — Typed Edge Registration and Dangling-Reference Prevention | P1 | ss-12/BC-12.12.003.md | active |
| BC-12.12.004 | Timeline — Event Ordering and Per-Entity Validity Window Consistency | P1 | ss-12/BC-12.12.004.md | active |
| BC-12.12.005 | Naming-Registry — Collision Detection and Phonotactic Rule Enforcement | P1 | ss-12/BC-12.12.005.md | active |
| BC-12.12.006 | Canon-Facts — Assertion Registration with Tier and Provenance | P1 | ss-12/BC-12.12.006.md | active |
| BC-12.12.007 | Canon-Continuity-Check Battery (CI Gate) | P1 | ss-12/BC-12.12.007.md | active |
| BC-12.12.008 | Retcon Propagation — Where-Used Impact Analysis | P1 | ss-12/BC-12.12.008.md | active |
| BC-12.12.009 | RAG-Grounding Contract — All Generative Agents Ground Against Canon-KB | P1 | ss-12/BC-12.12.009.md | active |

---

## CAP-013 — Genre-Gated Optional Lane Activation (P2) — 15 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-013-014.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-13.01.001 | Genre Profile Schema Validation | P2 | ss-13/BC-13.01.001.md | active |
| BC-13.01.002 | Inactive Lane Zero-Artifact Guarantee | P2 | ss-13/BC-13.01.002.md | active |
| BC-13.01.003 | Lane Activation Idempotency | P2 | ss-13/BC-13.01.003.md | active |
| BC-13.02.001 | Ranking System Contract — Pure-Function Math Invariants | P2 | ss-13/BC-13.02.001.md | active |
| BC-13.02.002 | Matchmaking Fairness Invariants | P2 | ss-13/BC-13.02.002.md | active |
| BC-13.02.003 | Esports Replay Format — CAP-003 Spine Reuse | P2 | ss-13/BC-13.02.003.md | active |
| BC-13.02.004 | Spectator Spec — Observer Data Layer | P2 | ss-13/BC-13.02.004.md | active |
| BC-13.02.005 | Tournament Mode Spec — Bracket Combinatorics and Match-Result Audit | P2 | ss-13/BC-13.02.005.md | active |
| BC-13.03.001 | Mod-API Contract — Versioned Surface with Semver Stability Enforcement | P2 | ss-13/BC-13.03.001.md | active |
| BC-13.03.002 | UGC Content Schema Validation | P2 | ss-13/BC-13.03.002.md | active |
| BC-13.03.003 | Mod Load Determinism — Topological Ordering and Conflict Detection | P2 | ss-13/BC-13.03.003.md | active |
| BC-13.03.004 | UGC Distribution Adapter — mod.io Round-Trip Conformance | P2 | ss-13/BC-13.03.004.md | active |
| BC-13.01.004 | Genre Profile Default Enforces NFT/Web3 Off-By-Default (DI-011) | P2 | ss-13/BC-13.01.004.md | active |
| BC-13.04.001 | Store Page Asset Conformance | P2 | ss-13/BC-13.04.001.md | active |
| BC-13.04.002 | Marketing Asset Manifest Completeness | P2 | ss-13/BC-13.04.002.md | active |

---

## CAP-014 — XR Platform Seam (P2, Tier 3 Deferred) — 7 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-013-014.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-14.01.001 | XR Adapter Manifest Schema Validation | P2 | ss-14/BC-14.01.001.md | active |
| BC-14.01.002 | OpenXR Capability Fidelity Grading | P2 | ss-14/BC-14.01.002.md | active |
| BC-14.01.003 | Comfort Certify Is Always Human-Gated (Fail-Closed for XR Comfort) | P2 | ss-14/BC-14.01.003.md | active |
| BC-14.01.004 | XR Seam Isolation — Zero Core Changes on XR Adapter Add/Remove | P2 | ss-14/BC-14.01.004.md | active |
| BC-14.02.001 | XR Performance Budget Schema | P2 | ss-14/BC-14.02.001.md | active |
| BC-14.02.002 | XR Comfort Spec Schema — Locomotion, Vignette, Candidate Rating, Human-Gated Playtest Gate | P2 | ss-14/BC-14.02.002.md | active |
| BC-14.02.003 | Apple Vision Pro as Separate Non-OpenXR Adapter Target | P2 | ss-14/BC-14.02.003.md | active |

---

## CAP-015 — Online-Services Adapter (P1, Tier 1) — 12 BCs

Supplement: `.factory/specs/prd-supplements/prd-cap-015.md`

| BC ID | Title | Priority | File | Lifecycle |
|-------|-------|----------|------|-----------|
| BC-15.01.001 | Online-Services Manifest Schema Validation and serverAuthoritative Enforcement | P0 | ss-15/BC-15.01.001.md | active |
| BC-15.01.002 | Off-by-Default Posture — Offline/Single-Player Zero-Artifact Guarantee | P0 | ss-15/BC-15.01.002.md | active |
| BC-15.02.001 | Identity — Player Account Create and Authenticate with Session Token and Expiry | P0 | ss-15/BC-15.02.001.md | active |
| BC-15.03.001 | Cloud Save — Write/Read Round-Trip and Conflict Resolution | P1 | ss-15/BC-15.03.001.md | active |
| BC-15.04.001 | Leaderboards — Server-Authoritative Submit, Tampered Score Rejection, Variants, and Pagination | P0 | ss-15/BC-15.04.001.md | active |
| BC-15.05.001 | Matchmaking — Lobby Lifecycle (Create and Join) | P1 | ss-15/BC-15.05.001.md | active |
| BC-15.06.001 | Entitlements — Server-Authoritative Verify, Granted:False for Unowned, Human-Gated Platform-Store-Review Path | P0 | ss-15/BC-15.06.001.md | active |
| BC-15.07.001 | Remote Config — Fetch, Remote-Config-Contract Binding, and Stale-Data Handling | P1 | ss-15/BC-15.07.001.md | active |
| BC-15.08.001 | Conformance Suite Self-Report (Full vs. None Fidelity) | P0 | ss-15/BC-15.08.001.md | active |
| BC-15.09.001 | Online-Services Seam Isolation — Zero Core Changes on Adapter Add/Remove | P0 | ss-15/BC-15.09.001.md | active |
| BC-15.10.001 | Online-Services Graceful Degradation — CapabilityUnsupported for None-Fidelity Capabilities | P0 | ss-15/BC-15.10.001.md | active |
| BC-15.11.001 | Entitlement and Leaderboard Integrity — D-SEC Reference Contract | P0 | ss-15/BC-15.11.001.md | active |

---

## Summary Counts

| Capability | Priority | Subsystem | BC Count |
|-----------|----------|-----------|----------|
| CAP-001 — Engine-Agnostic Build and Test | P0 | SS-01 | 35 |
| CAP-002 — Conformance Gating | P0 | SS-01 (merged into Engine-Adapter Protocol) | 6 |
| CAP-003 — Replay Regression | P0 | SS-02 | 9 |
| CAP-004 — Asset Generation + Provenance | P0 | SS-03 | 15 |
| CAP-005 — Multi-Discipline Production | P0 | SS-04 | 16 |
| CAP-006 — Simulation Quality | P0 | SS-05 | 11 |
| CAP-007 — Convergence Tracking | P0 | SS-06 | 19 (+7 v1.2: BC-7.11.002..008 server-authority invariant suite) |
| CAP-008 — Playtest Protocol | P1 | SS-07 | 5 |
| CAP-009 — Cert + Distribution | P1 | SS-08 | 11 |
| CAP-010 — Compliance + AI Disclosure | P1 | SS-08 (merged into Cert+Distribution) | 6 |
| CAP-011 — Monetization Ethics | P0/P1 | SS-09 | 14 (+1 v1.2: BC-11.03.006 DP-007) |
| CAP-012 — Canon KB | P1 | SS-10 | 9 |
| CAP-013 — Genre-Gated Lanes | P2 | SS-11 | 15 |
| CAP-014 — XR Seam | P2 | SS-12 | 7 |
| CAP-015 — Online-Services Adapter | P0/P1 | SS-13 | 12 (v1.5: all new; P0×9: BC-15.01.001/002, 15.02.001, 15.04.001, 15.06.001, 15.08.001, 15.09.001, 15.10.001, 15.11.001; P1×3: BC-15.03.001, 15.05.001, 15.07.001) |
| **TOTAL** | | | **190** |

---

## Changelog

| Version | Date | Change |
|---------|------|--------|
| v1.7 | 2026-06-08 | Fix (I-16-01): Corrected 2 stale per-capability section-header BC counts. CAP-007 header: "12 BCs" → "19 BCs" (section has 19 rows: BC-7.01.001..BC-7.12.001 incl. BC-7.11.002..008 server-authority invariant suite). CAP-015 header: "11 BCs" → "12 BCs" (section has 12 rows: BC-15.01.001..BC-15.11.001 incl. BC-15.01.002). Grand total (190), Summary table, prd.md, and subsystem-decomposition were correct and unchanged. All 15 capability section headers verified against section row counts. |
| v1.6 | 2026-06-08 | (prior version — see git history) |
