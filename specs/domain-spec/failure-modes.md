---
document_type: domain-spec-section
level: L2
section: failure-modes
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/engine-adapter-protocol.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
---

# Failure Modes

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> FM-NNN catalogs domain-level runtime failure modes grouped by subsystem.

---

## Adapter Subsystem

### FM-001 — Adapter Capability Drift
**What:** An adapter's declared capability (e.g., `replay: full`) passes conformance at
onboarding but silently fails in production after an engine minor release update.

**Detection:** Conformance suite scheduled re-run on each engine minor release (Semport
model). Adapter version mismatch in compatibility matrix alerts before use.

**Consequence:** Regression detection degrades silently; quality signal becomes unreliable.
Must re-run conformance; downgrade fidelity or fix driver.

---

### FM-002 — Determinism Regression (T1 Tier)
**What:** A T1 (bitwise) adapter produces a different snapshot hash on replay after a code
change, indicating a determinism violation has been introduced.

**Detection:** Replay regression contract fails (exact hash diff).

**Consequence:** Determinism root-cause analysis required. Cannot ship until T1 invariant
is restored or tier explicitly downgraded to T2 (loses cross-platform guarantee).

---

### FM-003 — Capture-Profile GPU Unavailable
**What:** The `render` execution profile on an adapter fails because no GPU backend
(lavapipe for Bevy, xvfb+Mesa for Unity/Godot) is available on the CI runner.

**Detection:** Adapter returns capability-fidelity: none for `capture`; CI step errors.

**Consequence:** Marketing asset capture and visual convergence dimension blocked.
Requires GPU-provisioned runner or fallback to software rendering configuration.

---

## Asset Lane Subsystem

### FM-004 — Provenance Sidecar Missing at Ingest
**What:** An asset arrives at the ingest step without a complete provenance sidecar
(missing fields, missing `disclosure_class`, or sidecar file absent).

**Detection:** Quality-gate report fails provenance-completeness check. Hook validates
sidecar schema before asset store ingest.

**Consequence:** Asset cannot be ingested (DI-003). Generation must be re-run with
provenance capture enabled. `ai-disclosure-manifest` is blocked until resolved.

---

### FM-005 — Likeness Consent Ref Present Without Human-Gated Completion
**What:** An asset has `likeness_consent_ref != null` (voice/face of a real person) but
the SAG-AFTRA/IMA consent signature task has not been completed.

**Detection:** Human-gated task tracker shows outstanding consent task; hook prevents
asset use in ship build.

**Consequence:** Asset remains a placeholder. Ship build cannot include the asset without
consent completion (DI-006). Producer must resolve human-gated task.

---

## Quality Model Subsystem

### FM-006 — Convergence Dimension Silently Suppressed
**What:** A convergence dimension (e.g., `monetization-ethics` or `security-invariants`)
is not included in the convergence report for a game that requires it, silently omitting
a mandatory check.

**Detection:** Hook validates convergence report completeness against game's genre profile
and active feature flags. Missing mandatory dimension = defect.

**Consequence:** Ship gate blocked until dimension is added to the report and evaluated.
This is a factory integrity failure, not a game quality issue.

---

### FM-007 — Playtest Satisfaction Dimension Bypassed
**What:** The playtest-satisfaction convergence dimension is marked green without a
structured playtest protocol human sign-off (e.g., an automated metric substituted for
the human gate).

**Detection:** Hook checks that the playtest-satisfaction dimension has a human sign-off
artifact reference; automated-only evidence is rejected.

**Consequence:** Convergence is invalid; ship gate blocked. This is the auto-scoring
defect identified in DI-007 and R-010.

---

## Compliance Subsystem

### FM-008 — AI Disclosure Manifest Not Generated Before Ship Gate
**What:** The factory reaches the cert/distribution phase without generating the
`ai-disclosure-manifest` for the game's generated assets.

**Detection:** Distribution pipeline hook checks for manifest presence before executing
upload CLIs. Missing manifest = blocked.

**Consequence:** EU AI Act Art. 50 (C2PA) compliance violated post-2026-08-02. Ship gate
blocked. Manifest generation is non-blocking to re-run from existing provenance sidecars.

---

## Spec Layer Subsystem

### FM-009 — Engine-Specific Reference in Spec Artifact
**What:** A spec-layer artifact (design spec, systems spec, economy graph) contains a
reference to an engine-specific concept (e.g., Unity component name, Bevy ECS type) that
violates the engine-portability invariant (DI-008).

**Detection:** Spec-layer linting hook scans for known engine namespace patterns.
Consistency validator cross-checks spec artifacts for engine-specific vocabulary.

**Consequence:** The spec cannot be used as input for a second engine adapter without
manual surgery. Portability thesis damaged; requires spec revision.

---

### FM-010 — Canon-KB Dangling Reference
**What:** A generative agent produces a narrative artifact referencing a canon entity
(character, faction, location) that does not exist in the Canon Knowledge-Base, or
references a timeline event that contradicts existing canon-facts.

**Detection:** `canon-continuity-check-battery` structural assertions fail
(entity ref integrity, timeline consistency check).

**Consequence:** Narrative artifact is flagged for revision. Loremaster (continuity-editor
role) must either add the entity to the Canon-KB or revise the artifact.
