---
document_type: behavioral-contract
level: L3
id: BC-4.03.003
origin: greenfield
subsystem: SS-03
capability: CAP-004
priority: P1
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.03.003: Every Provenance Sidecar Carries a `copyrightability_assessment`; Assets with Empty `human_modifications_log` Receive `unlikely`

## Description

Every provenance sidecar must include a `copyrightability_assessment` field that reflects
the factory's best-available estimate of whether the asset can be registered for copyright
protection under current US law (USCO Jan 2025 guidance: human authorship required; mere
prompts do not yield copyright). The assessment follows a deterministic rule set applied
at sidecar construction time. This field does not create a legal opinion; it signals the
studio that they should engage counsel for Tier-2/3 assets where ownership matters.

## Preconditions

1. A provenance sidecar is being constructed (BC-4.03.001).
2. The `human_modifications_log` field has been initialized (empty list `[]` at generation).
3. The `risk_tier` has been assigned (BC-4.02.002).
4. The `generated_by_tool.model_version` is known (or `"backend-opaque"`).

## Behavior

1. During sidecar construction, the orchestrator applies the following rule set to compute
   `copyrightability_assessment`:

   | Condition | Assigned value |
   |-----------|---------------|
   | `human_modifications_log` is empty `[]` AND `disclosure_class = "pre-generated"` | `"unlikely"` |
   | `human_modifications_log` is empty `[]` AND `disclosure_class = "live-generated"` | `"unlikely"` |
   | `human_modifications_log` is empty `[]` AND `disclosure_class = "procedural-exempt"` | `"partial"` (traditional PCG may have human-authored algorithm, but output may not) |
   | `human_modifications_log` is non-empty (at least one human transformation logged) AND modifications are described as "minor cleanup" or "fix" | `"partial"` |
   | `human_modifications_log` is non-empty AND modifications are described as "substantial creative direction" or "significant sculpt/repaint" | `"likely"` |
   | `generated_by_tool.model_version = "backend-opaque"` (adapter does not expose version) | Downgrade by one level (e.g., `partial` → `unlikely`; `likely` → `partial`) |

2. The schema validator checks that `copyrightability_assessment` is one of
   `{likely, partial, unlikely}`.
3. **Happy path:** A valid value is assigned.
   - Field is written to the sidecar.
4. **Failure path:** Field is null or absent (should not occur if BC-4.03.001 construction
   ran correctly).
   - Error `E-PRV-020` ("copyrightability_assessment is required but was not computed;
     sidecar construction error").
5. **Advisory output:** For every `risk_tier: 3` asset with `copyrightability_assessment:
   unlikely`, the quality-gate report includes an advisory: "This Tier-3 asset has an
   empty human_modifications_log. Consider documenting human creative control if IP
   ownership matters."

## Postconditions

- The sidecar has `copyrightability_assessment` set to one of `{likely, partial, unlikely}`.
- The assessment is a static snapshot at generation time; it may be re-assessed if
  `human_modifications_log` is later updated.
- Assets with `copyrightability_assessment: unlikely` are NOT blocked from ingestion
  (pure-maximal policy, D-006); they are informational only. Studio may elect to humanize.

## Invariants

- `copyrightability_assessment: unlikely` does NOT block asset ingestion. It is a data
  field, not a gate. Gating on copyright ownership is a studio-legal decision, not a
  factory default.
- The assessment is NEVER upgraded without an explicit update to `human_modifications_log`;
  it cannot be set to `likely` on a fully-automated asset by manual override without
  documenting the modifications.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Fully automated prop (no human touch, model version known) | `unlikely` |
| EC-002 | Fully automated prop, adapter does not expose model version (`backend-opaque`) | `unlikely` (already at bottom; no further downgrade) |
| EC-003 | Human artist retopologizes an AI mesh and documents "significant retopo and silhouette sculpt" in modifications_log | `likely` |
| EC-004 | Human applies UV cleanup only ("minor UV fix") | `partial` |
| EC-005 | Procedural terrain (WFC), `disclosure_class: procedural-exempt` | `partial` (classical PCG has human-authored algorithm) |
| EC-006 | `model_version: "backend-opaque"` + `human_modifications_log: ["significant creative direction"]` | `partial` (downgraded from `likely` by opaque version) |
| EC-007 | Tier-3 hero character, no human modifications | `unlikely`; advisory inserted in quality-gate-report |

## Canonical Test Vectors

| `human_modifications_log` | `disclosure_class` | `model_version` | Expected `copyrightability_assessment` |
|--------------------------|--------------------|----------------|----------------------------------------|
| `[]` | `pre-generated` | `"stable-audio-2.5"` | `unlikely` |
| `["significant sculpt and repaint"]` | `pre-generated` | `"tripo-3.0"` | `likely` |
| `["minor UV cleanup"]` | `pre-generated` | `"meshy-5"` | `partial` |
| `[]` | `procedural-exempt` | `"n/a-procedural"` | `partial` |
| `["significant creative direction"]` | `pre-generated` | `"backend-opaque"` | `partial` (downgraded from `likely`) |
| `[]` | `live-generated` | `"inworld-v2"` | `unlikely` |

## Verification Properties

- **VP-4.03.003-a:** `∀ asset a ∈ asset_store: a.sidecar.copyrightability_assessment ∈ {"likely", "partial", "unlikely"}`
- **VP-4.03.003-b:** `∀ asset a: a.sidecar.human_modifications_log = [] ∧ a.sidecar.disclosure_class = "pre-generated" → a.sidecar.copyrightability_assessment = "unlikely"`
- **VP-4.03.003-c:** `∀ asset a: a.sidecar.copyrightability_assessment = "unlikely" → a ∈ asset_store` (unlikely does not block ingest)

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — this BC implements the "provenance records copyrightability honestly" part of ratified decision D-006. The copyrightability_assessment field makes the IP ownership risk legible without blocking pure-maximal generation. |
| L2 Invariants | DI-003 (provenance completeness — `copyrightability_assessment` is a required sidecar field per entities.md) |
| L2 Processes | PROC-003 §Stage 3 (Generation), §Stage 4 (Quality Gate — advisory insertion) |
| L2 Risks | **R-001** ("Fully autonomous AI assets may be uncopyrightable") — this BC is the direct data capture mitigating R-001 by recording `copyrightability_assessment` and `human_modifications_log` |
| L2 Entities | ProvenanceSidecar |

## Related BCs

- **BC-4.03.001** (parent): this BC specifies the copyrightability_assessment field within sidecar construction
- **BC-4.03.002** (sibling): disclosure_class field, computed in the same construction pass

## Architecture Anchors

- RECONCILIATION §12 R-001: "Record human-modifications-log on every asset; auto-populate copyrightability-assessment"
- generative-asset-ai.md §5.1: USCO 2025 guidance on human authorship and copyrightability
- entities.md §ProvenanceSidecar: `copyrightability_assessment` is listed as a required entity field

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
