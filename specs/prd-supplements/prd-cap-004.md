---
document_type: prd-supplement
level: L3
traces_to: CAP-004
capability: CAP-004
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
supplements:
  - behavioral-contracts/BC-4.01.001.md
  - behavioral-contracts/BC-4.01.002.md
  - behavioral-contracts/BC-4.01.003.md
  - behavioral-contracts/BC-4.01.004.md
  - behavioral-contracts/BC-4.02.001.md
  - behavioral-contracts/BC-4.02.002.md
  - behavioral-contracts/BC-4.03.001.md
  - behavioral-contracts/BC-4.03.002.md
  - behavioral-contracts/BC-4.03.003.md
  - behavioral-contracts/BC-4.03.004.md
  - behavioral-contracts/BC-4.04.001.md
  - behavioral-contracts/BC-4.04.002.md
  - behavioral-contracts/BC-4.04.003.md
  - behavioral-contracts/BC-4.05.001.md
  - behavioral-contracts/BC-4.06.001.md
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/entities.md
  - .factory/specs/domain-spec/processes.md
  - .factory/specs/domain-spec/risks.md
  - .factory/specs/domain-spec/failure-modes.md
  - .factory/specs/domain-spec/differentiators.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/research/aaa/generative-asset-ai.md
  - .factory/planning/research/aaa/audio-discipline.md
  - .factory/planning/research/aaa/art-pipeline.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# PRD Section: CAP-004 — Pure-Maximal Asset Generation with Auto-Provenance

> **Parallel-safe batch.** This document covers CAP-004 only (BC-4.*.* namespace).
> Do NOT edit prd.md, BC-INDEX, error-taxonomy, NFRs, or other capability batches from
> this file.

---

## 1. Problem Statement

Game studios generating assets at AAA scale face two orthogonal failure modes: (a) per-asset
provenance is captured informally or not at all, leaving EU AI Act Art. 50 compliance and
Steam AI disclosure untracked; and (b) asset generation toolchains are wired ad-hoc, with
no principled routing policy that blocks litigation-exposed generators, enforces license
compatibility with the ship target, or requires consent gating for performer likenesses.

game-factory solves both by making the asset adapter layer declarative (backend_class
taxonomy, preference ordering, explicit ToS exclusions), generating every asset with a
machine-readable provenance sidecar at generation time, and running a deterministic
license-gate hook before any asset is admitted to the ship build.

---

## 2. Ratified Decisions

| Decision | Description | Source |
|----------|-------------|--------|
| **D-006** | Pure-maximal generation: no mandatory human creative finishing. Provenance records copyrightability honestly. Per-project humanization is optional. | Brief §Constraints; RECONCILIATION §9 |
| **D-007** | Default to ship-safe generators: licensed-output music (AIVA, Stable Audio); non-performer synthetic voice. Real-performer likeness routes to human-gated consent. | Brief §Constraints; DI-009; R-003; R-004 |

---

## 3. Behavioral Contracts Index (CAP-004)

All BCs in this section have ID `BC-4.SS.NNN` with S=4.

### Section 4.01 — Backend Adapter Taxonomy and Routing

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.01.001 | Every AssetAdapter declares a `backend_class` from the canonical taxonomy and the factory accepts only valid class values | P0 | BC-4.01.001.md |
| BC-4.01.002 | The orchestrator routes generation requests to adapters following the declared preference ordering (cloud-api before headless-cli before saas-ui, blocked backends never selected) | P0 | BC-4.01.002.md |
| BC-4.01.003 | OpenArt, Rosebud, and any ToS-excluded backend are never selected regardless of availability or preference score | P0 | BC-4.01.003.md |
| BC-4.01.004 | Suno, Udio, and any litigation-exposed music generator are blocked from the music asset-class route; only DI-009-compliant licensed providers are eligible | P0 | BC-4.01.004.md |

### Section 4.02 — Generation Request Schema

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.02.001 | Every GenerationRequest is validated against the canonical schema before dispatch; schema-invalid requests are rejected with a structured error | P0 | BC-4.02.001.md |
| BC-4.02.002 | Risk tier is assigned from asset class and use-case at request creation time, before backend selection, and recorded on the request | P0 | BC-4.02.002.md |

### Section 4.03 — Provenance Sidecar (Mandatory)

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.03.001 | Every generated asset has a complete provenance sidecar populated at generation time with all required fields; an asset without a complete sidecar cannot be ingested (DI-003) | P0 | BC-4.03.001.md |
| BC-4.03.002 | Every provenance sidecar carries a `disclosure_class` of exactly `pre-generated`, `live-generated`, or `procedural-exempt`; no other value is valid and a missing or null value is a schema error | P0 | BC-4.03.002.md |
| BC-4.03.003 | Every provenance sidecar carries a `copyrightability_assessment` of `likely`, `partial`, or `unlikely`; an asset with an empty `human_modifications_log` at generation time receives `unlikely` automatically | P1 | BC-4.03.003.md |
| BC-4.03.004 | Any asset with `likeness_consent_ref != null` triggers a human-gated SAG-AFTRA signature task and is blocked from the ship build until the task is completed (DI-006) | P0 | BC-4.03.004.md |

### Section 4.04 — Per-Modality Quality Gates

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.04.001 | A generated 3D mesh passes the quality gate only when it satisfies: manifold geometry, polycount within budget, UV distortion within threshold, full PBR channel set present, and provenance complete | P0 | BC-4.04.001.md |
| BC-4.04.002 | A generated audio asset (music or SFX) passes the quality gate only when: integrated loudness is within the declared target range (±2 LU), true-peak does not exceed -1 dBTP, and provenance is complete | P0 | BC-4.04.002.md |
| BC-4.04.003 | A generated 2D image (concept art, texture, UI) passes the quality gate only when: resolution meets or exceeds the request target, file format matches the declared output format, and provenance is complete | P1 | BC-4.04.003.md |

### Section 4.05 — Ship-Bound License Enforcement

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.05.001 | At ship-gate evaluation, every asset in the build is checked for license compatibility; any asset with `license_terms_snapshot.commercial_use = false` or an unresolved free-tier restriction causes the ship gate to FAIL with a structured license-violation report | P0 | BC-4.05.001.md |

### Section 4.06 — Asset-Library Ingestion

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-4.06.001 | An asset is ingested into the asset store only when: quality gate passes for its modality, provenance sidecar is complete and schema-valid (including `disclosure_class`), and for likeness assets the consent ref is either null or the human-gated task is marked complete | P0 | BC-4.06.001.md |

---

## 4. Invariants Enforced by This Section

| Invariant | Enforcing BCs |
|-----------|--------------|
| DI-003 — Every generated asset has a complete provenance sidecar | BC-4.03.001, BC-4.03.002, BC-4.06.001 |
| DI-006 — Human-gated tasks are surfaced, not silently dropped | BC-4.03.004 |
| DI-009 — Suno/Udio and unlicensed AI music providers are blocked | BC-4.01.004 |

---

## 5. Failure Modes Covered

| FM | Description | Covering BCs |
|----|-------------|-------------|
| FM-004 — Provenance Sidecar Missing at Ingest | Asset arrives at ingest without a complete sidecar | BC-4.03.001, BC-4.06.001 |
| FM-005 — Likeness Consent Ref Present Without Human-Gated Completion | Asset with consent ref used in ship build without signature | BC-4.03.004 |
| FM-008 — AI Disclosure Manifest Not Generated Before Ship Gate | Distribution phase reached without ai-disclosure-manifest | BC-4.03.002 (disclosure_class feeds manifest) |

---

## 6. Risks Mitigated by This Section

| Risk | Mitigating BCs |
|------|---------------|
| R-001 — AI assets may be uncopyrightable | BC-4.03.003 (copyrightability_assessment), BC-4.03.001 (human_modifications_log) |
| R-002 — Training-data indemnification gap | BC-4.01.002 (preference ordering routes to indemnified providers), BC-4.03.001 (indemnification_tier recorded) |
| R-003 — AI music legal hazard (Suno/Udio) | BC-4.01.004 (blocked by policy) |
| R-004 — SAG-AFTRA voice consent | BC-4.03.004 (human-gated gate) |
| R-005 — Hero-character autonomous quality gap | BC-4.04.001 (quality gate flags failures for Tier-3), BC-4.02.002 (risk-tier assignment) |
| R-014 — EU AI Act Art. 50 C2PA marking | BC-4.03.002 (disclosure_class mandatory), BC-4.03.001 (full sidecar required) |

---

## 7. Non-Functional Requirements (CAP-004 Scope)

| NFR-ID | Category | Requirement | Target | Validation |
|--------|----------|-------------|--------|-----------|
| NFR-4-01 | Provenance completeness | 100% of generated assets have a complete sidecar at ingestion time | 0 missing `disclosure_class` (Brief §Success Criteria) | Quality-gate hook on every ingest; CI blocks on any sidecar schema error |
| NFR-4-02 | Generation latency | Asset generation request dispatch to raw-asset available | p50 < 120 s per asset; p99 < 600 s (cloud-api class) | Measured in CI asset-lane smoke test with representative 3D and audio requests |
| NFR-4-03 | Quality gate pass rate (Tier-1 assets) | Tier-1 prop/texture assets pass quality gate without re-generation on first attempt | ≥ 80% first-attempt pass rate | Measured over 100-asset smoke corpus; logged in quality-gate-report |
| NFR-4-04 | Blocked-backend enforcement | 0 generation requests routed to ToS-excluded or litigation-exposed backends in any CI run | 0 exceptions permitted | Integration test: attempt to dispatch to Suno, Udio, OpenArt, Rosebud backends; assert routing refuses all four |
| NFR-4-05 | License-gate latency | Ship-gate license check completes for a 1,000-asset build | < 30 s wall-clock | Benchmarked in ship-gate integration test |

---

## 8. Interface Notes (for Implementer Consumption)

### 8.1 AssetAdapter `backend_class` Taxonomy

```
backend_class enum:
  cloud-api      # REST/gRPC API; outputs asset URL or binary response
  headless-cli   # Local process invocation, no GUI required, fully non-interactive
  mcp-headless   # MCP tool invocation, runs in factory agent context, no GUI
  mcp-gui        # MCP tool invocation that opens a GUI (automation-hostile; lowest preference)
  saas-ui        # Web UI only; automation via browser-control (hostile; lowest preference)
  desktop-gui    # Desktop application with GUI; no CLI/API (hostile; not usable in CI)
```

**Preference ordering for CI/dark-factory use:**
1. `cloud-api` (highest preference — fully async, no local dependency)
2. `headless-cli` (second — deterministic, reproducible)
3. `mcp-headless` (third — agent-driven, no GPU required)
4. `mcp-gui` (fourth — GUI opens but automation possible)
5. `saas-ui` (fifth — fragile, test-environment-only)
6. `desktop-gui` (lowest — cannot run in CI headlessly; BLOCKED for automated pipelines)

`desktop-gui` adapters MAY NOT be selected by the automated orchestrator. They are reserved
for human-assisted workflows only.

### 8.2 Canonical `disclosure_class` Values

Per Steam AI disclosure policy (Jan 17 2026 rewrite) and EU AI Act Art. 50:

| Value | Meaning |
|-------|---------|
| `pre-generated` | AI content generated before runtime and shipped with the product |
| `live-generated` | AI content generated at runtime during gameplay (requires dev attestation) |
| `procedural-exempt` | Traditional deterministic procedural generation; no AI model involved; Steam/EU exempt |

`procedural-exempt` MUST NOT be assigned to any asset generated by a neural/diffusion/LLM
model. It is reserved for WFC, BSP, Perlin-noise, SpeedTree, and other classical algorithmic
generation that does not use learned model weights.

### 8.3 Sidecar Required Fields

The following fields are ALL required (no nullable permitted on a valid sidecar):

```
generated_by_tool:
  name: string
  vendor: string
  model_version: string          # exact model/weights ID if available; "unknown" is INVALID
generation_date: ISO 8601
prompt_and_inputs_log: object    # full prompt and reference inputs; never truncated
human_modifications_log: list    # empty list at generation; populated if human transform applied
license_terms_snapshot:
  commercial_use: boolean
  resale_allowed: boolean
  attribution_required: boolean
  indemnification_tier: enum [none | adobe_firefly | enterprise | other]
training_data_provenance: enum [licensed | open | unknown]
likeness_consent_ref: string | null
risk_tier: integer [1 | 2 | 3]
copyrightability_assessment: enum [likely | partial | unlikely]
disclosure_class: enum [pre-generated | live-generated | procedural-exempt]
```

`model_version: "unknown"` is explicitly invalid. If the backend does not expose a model
version, the sidecar must record `model_version: "backend-opaque"` and flag
`copyrightability_assessment: unlikely`.

---

## 9. Competitive Differentiator Traceability

| Differentiator | Supporting BCs |
|----------------|---------------|
| D-003 — Pure-maximal lights-out asset generation with provenance | BC-4.03.001, BC-4.03.002, BC-4.06.001 |
| D-006 — Compliance and provenance pipeline as first-class output | BC-4.03.002, BC-4.05.001 |

---

## 10. Cross-Capability Dependencies

| Capability | Dependency Type | Notes |
|-----------|----------------|-------|
| CAP-005 — Multi-Discipline Artifact Production | Upstream: CAP-005 disciplines produce GenerationRequests that CAP-004 fulfills | Art, audio, narrative agents generate requests; CAP-004 executes them |
| CAP-010 — Compliance Pipeline and AI Disclosure | Downstream: CAP-004 provenance sidecars feed CAP-010 ai-disclosure-manifest | BC-4.03.002 disclosure_class is the primary input to the manifest projection |
| CAP-012 — Canon Knowledge-Base Grounding | Upstream: CAP-012 entity registry grounds art_direction_refs in GenerationRequests | BC-4.02.001 validates art_direction_refs resolve to Canon-KB entries |
