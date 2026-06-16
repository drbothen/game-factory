---
document_type: domain-spec-section
level: L2
section: entities
version: "1.1"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/engine-adapter-protocol.md
  - .factory/planning/design/architecture.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
modified:
  - version: "1.1"
    date: 2026-06-16
    author: product-owner
    reason: "R-22+R-23: AssetAdapter identity field renamed backend_id → adapter_id to match all three ss-04 BCs (BC-4.01.001/002/003). backend_class description corrected from '(Tier-1/2/3)' (which describes indemnification_tier) to the authoritative six-value taxonomy '(cloud-api | headless-cli | mcp-headless | mcp-gui | saas-ui | desktop-gui)' per BC-4.01.001."
---

# Domain Entities and Relationships

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> This section models domain entities (nouns). Implementation architecture is not modeled here.

## Core Entities

### GameSpec
The authoritative input to the factory. Contains game seed (genre, setting, mechanics
declaration), genre profile parameters, target engine list, and monetization model.
- Key properties: `genre_profile`, `target_engines[]`, `monetization_model`, `modding_enabled`,
  `esports_enabled`, `xr_target`
- Immutable once production begins except by explicit revision

### Engine
A game runtime whose capabilities the factory can use. Not a specific product — an Engine
is known to the factory only via its Adapter.
- Key properties: `engine_id`, `version_pinned`
- The factory core NEVER references an Engine directly; all Engine knowledge lives in
  its EngineAdapter

### EngineAdapter
The Layer-4 plugin that implements the Engine Adapter Protocol for one Engine at one
pinned version. Declares capability fidelity per capability, determinism tier, and
execution profiles.
- Key properties: `engine_id`, `protocol_version`, `determinism_tier` (T1/T2/T3),
  `execution_profiles[]` (headless-compute, render), `capabilities{}` (each with fidelity value)
- Relationship: one EngineAdapter per Engine version; many Adapters per Engine over time
- Conforms to: ConformanceSuite

### AssetAdapter
Adapter for one asset-generation backend (3D mesh, texture, audio, voice).
- Key properties: `adapter_id`, `asset_classes[]`, `backend_class` (cloud-api | headless-cli | mcp-headless | mcp-gui | saas-ui | desktop-gui),
  `indemnification_tier`, `fidelity{}` per asset class
- Conforms to: ConformanceSuite

### DistributionAdapter
Adapter for one distribution target (store + platform). Declares automatable CLI
operations and surfaces `human-gated` tasks.
- Key properties: `target_id`, `platform`, `automatable_ops[]`, `human_gated_tasks[]`
- Examples: Steam (steamcmd/butler), mobile (fastlane), console (`human-gated` cert)

### XRAdapter (seam reserved, Tier 3 deferred)
Adapter for one XR runtime (OpenXR 1.1, visionOS). Fidelity graded by extension
namespace (KHR > EXT > vendor).
- Key properties: `runtime_id`, `extension_namespace_fidelity`, `comfort_certify: human-gated`

### ConformanceSuite
The capability-gated test battery every Adapter must pass for its declared capabilities.
- Key properties: `adapter_type`, `capability_tests{}`, `reference_game_ref`
- Each Adapter must pass ConformanceSuite before being accepted into the factory

### GenerationRequest
A per-artifact request to an agent or adapter, including all parameters needed for
generation and provenance capture.
- Key properties: `request_id`, `artifact_type`, `asset_class`, `risk_tier`, `prompt_inputs`,
  `art_direction_refs[]`

### Asset
A generated game artifact (3D mesh, texture, audio clip, music, voice, concept art,
code module, narrative text). Inseparable from its ProvenanceSidecar.
- Key properties: `asset_id`, `asset_class`, `format` (GLB for 3D, canonical interchange)
- Relationship: every Asset has exactly one ProvenanceSidecar (1:1, mandatory)

### ProvenanceSidecar
Mandatory metadata record attached to every generated Asset at generation time.
- Key properties: `generated_by_tool`, `generation_date`, `prompt_and_inputs_log`,
  `human_modifications_log`, `license_terms_snapshot`, `training_data_provenance`,
  `likeness_consent_ref`, `risk_tier`, `copyrightability_assessment`, `disclosure_class`
- `disclosure_class`: `pre-generated` / `live-generated` / `procedural-exempt`
- Relationship: 1:1 with Asset; feeds AIDisclosureManifest

### CanonKBEntry
An entry in the Canon Knowledge-Base. Types: entity (character/faction/location/object),
relationship, timeline-event, naming-registry-entry, canon-fact.
- Key properties: `entry_id`, `entry_type`, `content`, `source_artifact_refs[]`
- Invariant: no dangling entity refs; timeline consistency
- All generative agents RAG over CanonKBEntries for grounding

### ContractArtifact
A machine-checkable artifact encoding domain rules for a specific game subsystem.
Types include: SimulationBC, DesignIntentContract, ReplayRegressionContract,
MonetizationEthicsContract, ServerAuthorityInvariantSuite, RankingSystemContract.
- Key properties: `contract_id`, `contract_type`, `subsystem`, `assertions[]`,
  `validation_method`
- Every ContractArtifact has a declared validation method

### FidelityTier
The declared quality of an adapter capability or human-gated production step.
Values: `full` / `partial` / `none` / `human-gated`.
- Domain enum; used on EngineAdapter, AssetAdapter, DistributionAdapter capabilities

### DeterminismTier
The declared strength of sim replay reproducibility for an EngineAdapter.
Values: `bitwise-cross-platform` (T1) / `same-machine` (T2) / `tolerance-only` (T3).
- Governs comparison method in ReplayRegressionContract

### AgentRole
A named production role in the Studio-of-Agents (66 total). Types: Catalyst (C) or
Specialist (S).
- Key properties: `role_id`, `role_type` (C/S), `discipline`, `owned_artifacts[]`
- Catalysts coordinate across disciplines; Specialists produce within one discipline

### Wave
A dependency-DAG-ordered batch of production stories.
- Key properties: `wave_id`, `story_ids[]`, `dependency_dag`, `gate_predicates[]`
- Relationship: Wave contains Stories; Wave is gated by post-wave MilestoneGate

### MilestoneGate
A hook-enforced predicate set that a build must satisfy before production advances.
- Key properties: `gate_id`, `predicates[]`, `convergence_dims_required[]`
- Blocks next Wave until all predicates pass

### AIDisclosureManifest
A pure projection of ProvenanceSidecar data for regulatory compliance output.
- Key properties: `manifest_id`, `game_id`, `asset_count_by_disclosure_class`,
  `c2pa_marks_generated`, `eu_ai_act_compliant`
- Generated from ProvenanceSidecars; no new data; required pipeline output

## Entity Relationship Summary

```
GameSpec ──────────────────── governs ──────── Wave[]
                               │                 │
                               │           MilestoneGate
                               │
                         EngineAdapter ──── ConformanceSuite
                         AssetAdapter ────── ConformanceSuite
                         DistributionAdapter
                         XRAdapter (deferred)
                               │
                        GenerationRequest ──── Asset ──── ProvenanceSidecar
                                                │               │
                                         ContractArtifact  AIDisclosureManifest
                                                │
                                        CanonKBEntry (RAG source)
                                                │
                                         AgentRole (owner)
```

## Notable Cardinality Constraints
- One GameSpec → zero or many target Engines (via EngineAdapters)
- One Asset → exactly one ProvenanceSidecar (mandatory, no exceptions)
- One EngineAdapter → exactly one ConformanceSuite result (must pass to be accepted)
- One DeterminismTier per EngineAdapter (declared, conformance-verified)
