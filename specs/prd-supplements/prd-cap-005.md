---
document_type: prd-supplement
level: L3
section: cap-005
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
modified:
  - pass: "Pass-28"
    reason: "O28-01 fix: enriched E-CIN-003 row to match error-taxonomy.md I5 wording — changed category name from 'Directed flag missing gate' to 'Directed flag missing creative gate' and expanded message format to include '(creative gate, not human-gated fidelity tier — see D-013 distinction in methodology-layer.md §2.8)' so the canonical source and rollup agree."
  - pass: "Pass-39"
    reason: "F39-02 fix: registered E-ENG-003 (UnclassifiedModule) and E-ENG-004 (TestScopedToWrongModule) — closes 'E-ENG-001/002 variant' language in BC-5.05.001 EC-001 and BC-5.05.002 EC-005. Registered E-CIN-005 (TimestampOutOfRange) and E-CIN-006 (BlendshapeTrackSetIncomplete) — closes 'E-CIN-001/004 variant' language in BC-5.06.001 PC1/EC-003 and BC-5.06.002 PC1/EC-001. All four codes added to this supplement table."
phase: 1a
traces_to: CAP-005
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/processes.md
  - .factory/specs/domain-spec/entities.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/research/aaa/game-design-discipline.md
  - .factory/planning/research/aaa/art-pipeline.md
  - .factory/planning/research/aaa/audio-discipline.md
  - .factory/planning/research/aaa/narrative-worldbuilding-lore.md
  - .factory/planning/research/aaa/engineering-disciplines.md
  - .factory/planning/research/aaa/cinematics-virtual-production.md
  - .factory/planning/research/aaa/production-pipeline.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
supplements:
  - .factory/specs/behavioral-contracts/ss-05/BC-5.01.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.01.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.01.003.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.02.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.02.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.03.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.03.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.04.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.04.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.05.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.05.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.06.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.06.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.07.001.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.07.002.md
  - .factory/specs/behavioral-contracts/ss-05/BC-5.07.003.md
---

# PRD Supplement: CAP-005 — Multi-Discipline Game Artifact Production

> **Scope.** This document elaborates requirements for CAP-005 only. It does not cover
> monetization ethics (CAP-011), compliance/AI-disclosure (CAP-010), cert pre-flight
> (CAP-009), or security invariants. Those are separate capability contracts referenced
> here as downstream dependencies.
>
> **Lane constraint.** BCs in this supplement carry subsystem S=5 only (BC-5.SS.NNN).
> Subsystem IDs (SS) are assigned by discipline section, not implementation module.
> Architecture subsystem assignment (SS-NN) is deferred to Phase 1b; all BCs carry
> `subsystem: SS-TBD` until the architect produces ARCH-INDEX.

---

## 1. Product Overview (CAP-005 Scope)

### 1.1 Problem Statement

Building a complete game requires coordinated artifact production across at least seven
disciplines (design, art, audio, narrative/lore, engineering, cinematics, production).
In a traditional studio, each discipline owns its own toolchain and hand-off conventions;
cross-discipline dependencies are managed informally, producing integration failures
discovered late. A dark factory must replace informal hand-offs with typed, machine-
validated contracts so that discipline agents can work in parallel with high confidence
their outputs will compose.

### 1.2 Vision

The Studio-of-Agents (66 roles per AAA-RECONCILIATION §5.X) produces every artifact a
game needs. Every artifact is expressed in an engine-neutral schema, machine-validated
against its discipline contract, and connected to downstream consumers via a typed
cross-discipline dependency contract. No artifact leaves its discipline without passing
structural validation; no cross-discipline dependency is fulfilled without the receiving
discipline's acceptance criteria being checked.

### 1.3 Competitive Differentiators (CAP-005 scope)

| # | Differentiator | BC Backing |
|---|---|---|
| D-1 | Every discipline artifact is schema-valid and machine-checkable at the point of production — not at integration | BC-5.01.001, BC-5.02.001, BC-5.03.001, BC-5.04.001, BC-5.05.001, BC-5.06.001 |
| D-2 | Cross-discipline dependencies are typed contracts with machine-checked acceptance criteria, never implicit conventions | BC-5.07.001, BC-5.07.002 |
| D-3 | The design-spec artifact stack is engine-neutral by construction — no engine implementation construct may appear | BC-5.01.001 (Invariants), BC-5.01.002 |
| D-4 | Every generated asset is inseparable from its provenance sidecar; the sidecar is validated at ingest, not at ship | BC-5.02.001, BC-5.02.002 |
| D-5 | Narrative graph and canon-KB are first-class machine-checkable artifacts — reachability, dead-ends, and entity continuity are CI gates | BC-5.04.001, BC-5.04.002 |
| D-6 | Audio build manifest produces a loudness/true-peak-conformant bank build on every CI run | BC-5.03.001, BC-5.03.002 |
| D-7 | The sequence-graph (cinematics) is engine-agnostic; Bevy sequencer gap is explicitly handled by BUILD-new runtime | BC-5.06.001, BC-5.06.002 |
| D-8 | The producer-orchestrator uses a dependency-DAG-ordered wave schedule; no discipline wave begins before its declared inputs are green | BC-5.07.003 |

### 1.4 Target Consumers (within the factory)

- Implementer agents (consume: design-spec, systems-spec, balance-data, level-spec, narrative-graph, audio-build-manifest, sequence-graph)
- Asset-generation-orchestrator (consumes: art-bible.spec, asset-generation-request)
- Test-writer agents (consume: BCs for contract validation)
- Wave-gate and CI pipeline (consume: all discipline validation outputs)
- CAP-006 (simulation BC contracts depend on systems-spec from CAP-005)
- CAP-007 (convergence dimension 4 "asset-completeness" gates on BC-5.02.002)
- CAP-009 / CAP-010 (downstream consumers of compliance-checklist and ai-disclosure-manifest artifacts)

### 1.5 Out of Scope for CAP-005

- Monetization-ethics-contract (CAP-011)
- IARC / compliance-checklist generation (CAP-010)
- Cert pre-flight harness (CAP-009)
- Replay-regression harness (CAP-003)
- Asset generation backends and provenance sidecar capture (CAP-004)
- Security invariant suite (separate CAP)

---

## 2. Behavioral Contracts Index

BCs are grouped by discipline subsection (SS). Each row is a one-line summary linking
to the full contract file. Full preconditions, postconditions, edge cases, and test
vectors are in the individual BC files.

### SS-01: Game Design Artifacts

> Agents: systems-designer, economy-designer, combat-designer, level-designer,
> encounter-designer, ux-accessibility-designer. Catalyst: creative-director, art-director.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.01.001 | Design Artifact Stack Produces Valid, Engine-Neutral Spec Bundle | P0 | ss-05/BC-5.01.001.md |
| BC-5.01.002 | Economy Graph Passes Balance-Band Invariants | P0 | ss-05/BC-5.01.002.md |
| BC-5.01.003 | Accessibility Contract Satisfies CVAA / GAG / XAG Checklist | P0 | ss-05/BC-5.01.003.md |

### SS-02: Art Pipeline Artifacts

> Agents: concept-artist, env-modeler, prop-artist, char-modeler, char-texture, vfx-artist,
> char-rigger, animator. Catalysts: pipeline-ta, char-ta, art-director.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.02.001 | Art Package (GLB) Passes Quality Gate and Carries Complete Provenance | P0 | ss-05/BC-5.02.001.md |
| BC-5.02.002 | Art Bible Spec Provides Deterministic Generation Parameters | P0 | ss-05/BC-5.02.002.md |

### SS-03: Audio Build Artifacts

> Agents: audio-designer, composer, audio-implementer. Catalyst: voice-director.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.03.001 | Audio Build Manifest Produces Conformant Bank Build | P0 | ss-05/BC-5.03.001.md |
| BC-5.03.002 | AI Audio Provenance Ledger Covers All Generated Audio Assets | P0 | ss-05/BC-5.03.002.md |

### SS-04: Narrative, Worldbuilding, and Lore Artifacts

> Agents: narrative-designer, writer, localization-engineer, worldbuilder, quest-designer,
> systemic-writer, cinematic-writer, copywriter. Catalysts: narrative-director, loremaster.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.04.001 | Narrative Graph Is Reachable, Dead-End-Free, and Canon-Grounded | P0 | ss-05/BC-5.04.001.md |
| BC-5.04.002 | Canon-KB Maintains Structural Integrity (Entity Ref + Timeline Consistency) | P0 | ss-05/BC-5.04.002.md |

### SS-05: Engineering / Code Artifacts

> Agents: gameplay-engineer, tools-engineer, build-engineer (implementation-layer roles;
> mapping to factory agents defined by architect). Systems from RECONCILIATION §5.10 QA.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.05.001 | Code Module Satisfies Gameplay-Logic / Pure-Sim Separation Contract | P0 | ss-05/BC-5.05.001.md |
| BC-5.05.002 | Simulation Module Passes TDD Red Gate Before Production Code Exists | P0 | ss-05/BC-5.05.002.md |

### SS-06: Cinematics and Virtual Production Artifacts

> Agents: cinematic-director, camera-cinematography, lipsync-animator, cinematic-writer.

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.06.001 | Sequence Graph Is Well-Formed, Engine-Agnostic, and Passes Structural Validation | P0 | ss-05/BC-5.06.001.md |
| BC-5.06.002 | Lip-Sync Pipeline Contract Produces ARKit-52 Aligned Blendshape Output | P1 | ss-05/BC-5.06.002.md |

### SS-07: Production, Cross-Discipline Dependency, and Wave Scheduling

> Agents: producer, cert-owner. Asset-generation-orchestrator (catalyst).

| BC ID | Title | Priority | File |
|-------|-------|----------|------|
| BC-5.07.001 | Cross-Discipline Dependency Contract Is Declared Before Dependent Wave Begins | P0 | ss-05/BC-5.07.001.md |
| BC-5.07.002 | Cross-Discipline Dependency Acceptance Criteria Are Machine-Checked on Handoff | P0 | ss-05/BC-5.07.002.md |
| BC-5.07.003 | Wave Schedule Respects Discipline-DAG Ordering and Emits Blocked-Wave Signals | P0 | ss-05/BC-5.07.003.md |

---

## 3. Interface Definitions (CAP-005 Artifact Schemas)

See also: `.factory/specs/prd-supplements/interface-definitions.md` for the cross-CAP
interface catalog. The below is CAP-005-scoped.

### 3.1 design-spec (federated GDD graph)

Top-level engine-neutral document; typed references into all sub-artifacts below.

```json
{
  "schema_version": "1.0",
  "game_id": "string",
  "genre_profile": "string",
  "intent_prose": "string",           // vision/tone — prose, not checkable
  "systems_spec_ref": "path",
  "economy_graph_ref": "path",
  "progression_spec_ref": "path",
  "level_specs": ["path"],
  "content_data_ref": "path",
  "ui_spec_ref": "path",
  "accessibility_contract_ref": "path",
  "design_intent_contracts": ["path"],
  "engine_neutral": true              // invariant: must always be true
}
```

### 3.2 systems-spec

State machines + interaction matrices + parameter schemas. Carries simulation BCs.

```json
{
  "schema_version": "1.0",
  "state_machines": [
    {
      "id": "string",
      "states": ["string"],
      "transitions": [{"from": "string", "to": "string", "condition": "string"}],
      "initial_state": "string"
    }
  ],
  "interaction_matrix": {
    "actors": ["string"],
    "rules": [{"subject": "string", "verb": "string", "object": "string", "effect": "string"}]
  },
  "parameter_schemas": {"name": "json-schema"},
  "simulation_bc_refs": ["BC-NNN"]
}
```

### 3.3 economy-graph

Machinations-importable source/sink graph with balance-band declarations.

```json
{
  "schema_version": "1.0",
  "nodes": [
    {"id": "string", "type": "source|sink|pool|converter|gate|drain", "label": "string"}
  ],
  "edges": [
    {"from": "string", "to": "string", "rate": "number|formula", "label": "string"}
  ],
  "balance_bands": [
    {"metric": "string", "min": "number", "max": "number", "check_method": "sim|formula"}
  ],
  "conservation_invariants": ["string"]
}
```

### 3.4 level-spec

```json
{
  "schema_version": "1.0",
  "level_id": "string",
  "beat_sheet": [
    {"beat_id": "string", "type": "intro|combat|puzzle|rest|climax", "pacing_target": "number"}
  ],
  "encounter_graph": {
    "encounters": [{"id": "string", "roster": ["string"], "spawn_table": {"enemy_id": "weight"}}],
    "edges": [{"from": "string", "to": "string", "condition": "string"}]
  },
  "metrics_table": {
    "door_width_m": "number",
    "cover_spacing_m": "number",
    "jump_height_m": "number",
    "engagement_range_m": "number"
  },
  "critical_path_refs": ["node_id"],
  "pcg_ruleset_ref": "path|null"
}
```

### 3.5 audio-build-manifest

```json
{
  "schema_version": "1.0",
  "middleware": "wwise|fmod",
  "project_path": "path",
  "engine_targets": ["string"],
  "platforms": ["string"],
  "languages": ["string"],
  "bank_definitions": [
    {
      "bank_id": "string",
      "events": ["string"],
      "platform_overrides": {}
    }
  ],
  "loudness_targets": {
    "console_lufs": -23,
    "portable_lufs": -18,
    "true_peak_dBTP": -1
  },
  "validation_required": ["loudness", "true_peak", "bank_build_success", "event_coverage"]
}
```

### 3.6 narrative-graph

```json
{
  "schema_version": "1.0",
  "nodes": [
    {
      "id": "string",
      "type": "start|dialogue|choice|event|end",
      "content_ref": "string",
      "canon_entity_refs": ["CanonKBEntry.id"]
    }
  ],
  "edges": [
    {"from": "string", "to": "string", "condition": "string|null", "label": "string"}
  ],
  "variables": [{"id": "string", "type": "string", "initial": "any"}],
  "export_targets": ["ink|yarn|articy"],
  "reachability_check_required": true,
  "dead_end_check_required": true
}
```

### 3.7 sequence-graph (cinematic)

```json
{
  "schema_version": "1.0",
  "sequence_id": "string",
  "directed": false,
  "duration_seconds": "number",
  "tracks": {
    "camera_cuts": [{"time_s": "number", "shot_type": "string", "target_ref": "string"}],
    "animation": [{"time_s": "number", "actor_ref": "string", "clip_ref": "string"}],
    "facial_lipsync": [{"time_s": "number", "actor_ref": "string", "blendshapes_ref": "path"}],
    "audio": [{"time_s": "number", "event_ref": "string"}],
    "subtitles": [{"time_s": "number", "end_s": "number", "text": "string", "loc_key": "string"}],
    "activation": [{"time_s": "number", "entity_ref": "string", "action": "string"}]
  },
  "asset_refs": ["string"],
  "validation_required": ["asset_refs_resolve", "subtitle_coverage", "audio_sync_tolerance_ms", "directed_flag_check"]
}
```

### 3.8 cross-discipline-dependency-contract

The central new artifact. Typed hand-off specification between two disciplines.

```json
{
  "schema_version": "1.0",
  "contract_id": "string",
  "producer_discipline": "design|art|audio|narrative|engineering|cinematics",
  "consumer_discipline": "design|art|audio|narrative|engineering|cinematics|qa",
  "artifact_types": ["string"],
  "format_requirements": {
    "schema_ref": "path",
    "encoding": "string",
    "version": "string"
  },
  "budget_constraints": {
    "poly_budget": "number|null",
    "texel_density_px_per_m": "number|null",
    "audio_bank_size_mb": "number|null"
  },
  "naming_conventions": {"pattern": "string", "examples": ["string"]},
  "acceptance_criteria": [
    {
      "criterion_id": "string",
      "check_type": "schema_valid|bc_pass|format_check|budget_check|naming_check",
      "assertion": "string"
    }
  ],
  "change_propagation_policy": "blocking|advisory|deferred",
  "validated_at": "merge|wave_gate|milestone"
}
```

---

## 4. Non-Functional Requirements (CAP-005 Scope)

NFRs are cross-cutting for this capability. Full NFR catalog at `prd-supplements/nfr-catalog.md`.

| NFR-NNN | Category | Requirement | Target | Validation Method |
|---------|----------|-------------|--------|------------------|
| NFR-5.01 | Performance | Design artifact stack generation time | < 30 s for a full design-spec bundle (all sub-artifacts) on reference hardware | Timed CI step |
| NFR-5.02 | Reliability | Schema validation false-negative rate (valid artifact rejected) | < 0.1% over 1000 consecutive runs | Property-based test corpus |
| NFR-5.03 | Throughput | Audio bank build time for reference game (< 200 events) | < 120 s on CI runner | Timed bank build step |
| NFR-5.04 | Correctness | Narrative graph reachability check: every terminal node classified as intended-end or dead-end | 100% classification coverage; 0 unclassified nodes | Graph-traversal CI gate |
| NFR-5.05 | Scalability | Cross-discipline dependency contract validation on merge | < 5 s per contract (< 50 acceptance criteria) | Timed validation step |
| NFR-5.06 | Engine-neutrality | Design artifact stack: zero engine-specific identifiers | 0 occurrences of engine-specific terms (MonoBehaviour, ECS Component by name, etc.) | Lint rule on all spec artifacts |
| NFR-5.07 | Loudness conformance | Audio build loudness within target band | LUFS within ±2 dB of target for all banks | loudnorm / libebur128 CI check |

---

## 5. Error Taxonomy (CAP-005 Scope)

See also: `.factory/specs/prd-supplements/error-taxonomy.md` (cross-CAP catalog).

| Error Code | Category | Severity | Exit Code | Message Format |
|------------|----------|----------|-----------|---------------|
| E-DES-001 | Schema validation | broken | 1 | `design-spec validation failed: <field> missing or invalid at <path>` |
| E-DES-002 | Engine-neutrality | broken | 1 | `engine-specific construct '<term>' found in <artifact>:<field> — violates DI-008` |
| E-DES-003 | Balance band | broken | 1 | `economy-graph balance check failed: <metric> = <value>, expected [<min>, <max>]` |
| E-DES-004 | Conservation invariant | broken | 1 | `economy-graph conservation violated: <invariant> net flow = <value> (expected 0 ± <tol>)` |
| E-DES-005 | Accessibility contract | broken | 1 | `accessibility-contract: required feature '<feature>' absent; GAG/XAG ID <id> not satisfied` |
| E-ART-001 | GLB quality gate | broken | 1 | `asset '<id>' failed quality gate: <check> = <value>, threshold = <threshold>` |
| E-ART-002 | Provenance sidecar | broken | 1 | `asset '<id>' missing provenance sidecar field '<field>' — violates DI-003` |
| E-ART-003 | Art bible schema | broken | 1 | `art-bible.spec validation failed: <field> at <path>` |
| E-AUD-001 | Bank build | broken | 1 | `audio bank build failed: <platform>/<bank_id>: <error>` |
| E-AUD-002 | Loudness conformance | broken | 1 | `audio bank '<bank_id>' loudness = <lufs> LUFS, target = <target> ±2 LUFS` |
| E-AUD-003 | True-peak | broken | 1 | `audio bank '<bank_id>' true-peak = <dBTP> dBTP, ceiling = -1 dBTP` |
| E-AUD-004 | AI audio provenance | broken | 1 | `audio asset '<id>' not covered by ai-audio-provenance-ledger — violates DI-003` |
| E-NAR-001 | Dead-end node | broken | 1 | `narrative-graph '<graph_id>' dead-end detected at node '<node_id>': no outgoing edges and not declared end` |
| E-NAR-002 | Unreachable node | broken | 1 | `narrative-graph '<graph_id>' unreachable node '<node_id>': no path from start` |
| E-NAR-003 | Dangling entity ref | broken | 1 | `narrative node '<node_id>' references canon entity '<entity_id>' not in Canon-KB` |
| E-NAR-004 | Timeline inconsistency | broken | 1 | `Canon-KB timeline event '<event_id>' at t=<t1> conflicts with event '<event_id2>' at t=<t2>: <conflict>` |
| E-ENG-001 | Logic-presentation coupling | broken | 1 | `code module '<module>' imports presentation-layer symbol '<sym>' — violates pure-sim separation` |
| E-ENG-002 | Red Gate violation | broken | 1 | `production code commit exists without a prior failing test for story '<story_id>'` |
| E-ENG-003 | Module unclassified | broken | 1 | `code module '<module>' has no declared module_type in factory manifest — classification required before lint` |
| E-ENG-004 | Test scoped to wrong module | broken | 1 | `test file '<file>' does not reference the story's assigned module '<module>' — test-writer must correct scope` |
| E-CIN-001 | Sequence asset ref | broken | 1 | `sequence-graph '<seq_id>' asset ref '<ref>' does not resolve` |
| E-CIN-002 | Subtitle coverage | broken | 1 | `sequence-graph '<seq_id>' audio event '<event_id>' has no subtitle track` |
| E-CIN-003 | Directed flag missing creative gate | broken | 1 | `sequence-graph '<seq_id>' has directed=true but no cinematic-director creative sign-off record found (creative gate, not human-gated fidelity tier — see D-013 distinction in methodology-layer.md §2.8)` |
| E-CIN-004 | Blendshape range | broken | 1 | `lip-sync '<clip_id>' blendshape '<shape>' value <v> outside [0, 1]` |
| E-CIN-005 | Sequence timestamp out of range | broken | 1 | `sequence-graph '<seq_id>' track event at timestamp <t>s is outside valid range [0, <duration>s]` |
| E-CIN-006 | Blendshape track set incomplete | broken | 1 | `lip-sync '<clip_id>' blendshape track set does not match ARKit-52; missing or extra tracks: <track_list>` |
| E-PROD-001 | Missing dependency contract | broken | 1 | `wave '<wave_id>' starts discipline '<consumer>' but cross-discipline-dependency-contract from '<producer>' not found` |
| E-PROD-002 | Dependency acceptance fail | broken | 1 | `cross-discipline-dependency-contract '<contract_id>' acceptance criterion '<crit_id>' failed: <assertion>` |
| E-PROD-003 | Wave ordering violation | broken | 1 | `wave '<wave_id>' started but dependency '<dep_wave_id>' not yet green in discipline DAG` |

---

## 6. Competitive Differentiator Traceability

| Differentiator | BC(s) | Verification |
|---|---|---|
| D-1: Every discipline artifact schema-valid at production time | BC-5.01.001, BC-5.02.001, BC-5.03.001, BC-5.04.001, BC-5.05.001, BC-5.06.001 | Schema validation CI gate per discipline |
| D-2: Cross-discipline dependencies are typed contracts | BC-5.07.001, BC-5.07.002 | Contract presence + acceptance criteria CI gate |
| D-3: Design-spec stack is engine-neutral by construction | BC-5.01.001 (Invariant I-1), BC-5.01.002 | Lint rule: zero engine-specific terms in spec artifacts |
| D-4: Asset inseparable from provenance sidecar | BC-5.02.001 | Provenance completeness check at ingest (DI-003) |
| D-5: Narrative graph + Canon-KB machine-checkable | BC-5.04.001, BC-5.04.002 | Reachability + entity-integrity CI gate |
| D-6: Audio loudness-conformant on every CI run | BC-5.03.001 | loudnorm / libebur128 bank-build CI check |
| D-7: Sequence-graph engine-agnostic; Bevy gap handled | BC-5.06.001 | Structural validation + Bevy runtime BUILD-new marker |
| D-8: Wave schedule respects discipline-DAG ordering | BC-5.07.003 | Topological sort + blocked-wave signal CI gate |

---

## 7. Requirements Traceability Matrix

| BC ID | Source L2 CAP | L2 Invariants | Discipline Section | Priority | Test Type |
|-------|--------------|---------------|--------------------|----------|-----------|
| BC-5.01.001 | CAP-005 | DI-008 | SS-01 Design | P0 | Schema + lint |
| BC-5.01.002 | CAP-005 | DI-008 | SS-01 Design | P0 | Simulation + property-based |
| BC-5.01.003 | CAP-005 | DI-008 | SS-01 Design | P0 | Checklist + contract |
| BC-5.02.001 | CAP-005 | DI-003 | SS-02 Art | P0 | Quality gate + schema |
| BC-5.02.002 | CAP-005 | DI-008 | SS-02 Art | P0 | Schema + generation params |
| BC-5.03.001 | CAP-005 | DI-009 | SS-03 Audio | P0 | Bank build + loudness |
| BC-5.03.002 | CAP-005 | DI-003 | SS-03 Audio | P0 | Ledger completeness |
| BC-5.04.001 | CAP-005 | DI-008 | SS-04 Narrative | P0 | Graph traversal |
| BC-5.04.002 | CAP-005 | DI-008 | SS-04 Narrative | P0 | Entity integrity |
| BC-5.05.001 | CAP-005 | DI-008 | SS-05 Engineering | P0 | Import lint + architecture check |
| BC-5.05.002 | CAP-005 | DI-012 | SS-05 Engineering | P0 | TDD red-gate hook |
| BC-5.06.001 | CAP-005 | DI-008 | SS-06 Cinematics | P0 | Schema + structural lint |
| BC-5.06.002 | CAP-005 | DI-006 | SS-06 Cinematics | P1 | Blendshape range + consent check |
| BC-5.07.001 | CAP-005 | DI-006, DI-012 | SS-07 Production | P0 | Contract presence gate |
| BC-5.07.002 | CAP-005 | DI-012 | SS-07 Production | P0 | Acceptance criteria execution |
| BC-5.07.003 | CAP-005 | DI-006 | SS-07 Production | P0 | DAG topological sort |
