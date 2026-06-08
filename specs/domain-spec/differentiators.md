---
document_type: domain-spec-section
level: L2
section: differentiators
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/architecture.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
---

# Competitive Differentiators

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> Maps each competitive advantage to the supporting capabilities and the brief evidence.

---

## D-001 — First Engine-Agnostic Multi-Engine Semantic Test Layer

**Claim:** No existing system builds an engine-agnostic build-and-test factory across
Unity/Godot/Unreal/Bevy. Build CI is mature but single-engine; the deepest cross-engine
test SDKs reach only two engines (Unity+Unreal) and operate black-box (pixels/OCR only).

**Evidence:** architecture.md §Why a sibling ("No one builds an engine-agnostic build-AND-
test factory across Unity/Godot/Unreal/Bevy...The market quadrant we target is empty").
Grounded in prior-art-and-precedents.md research.

**Supporting capabilities:** CAP-001 (engine-agnostic build/test), CAP-002 (conformance
gating), CAP-003 (replay regression)

---

## D-002 — Deterministic Replay Regression as First-Class Quality Gate

**Claim:** game-factory provides the first multi-engine, tier-graded deterministic replay
regression harness that also serves as QA regression, esports demo, anti-cheat spine, and
mod-determinism verification — all from a single replay primitive.

**Evidence:** RECONCILIATION §2 ("Deterministic replay spine is cross-cutting and load-
bearing"). Brief §In Scope ("replay-regression works: 100% on reference game").

**Supporting capabilities:** CAP-003 (replay regression), CAP-006 (contract verification),
CAP-001 (engine adapter)

---

## D-003 — Pure-Maximal Lights-Out Asset Generation at AAA Scale

**Claim:** The factory generates all game assets (3D, audio, voice, narrative, marketing)
lights-out with no mandatory human creative finishing, while automatically capturing
complete provenance metadata per EU AI Act and Steam disclosure requirements.

**Evidence:** Brief §In Scope ("pure-maximal + auto-provenance"), §Constraints ("pure-maximal
+ auto-provenance — IP/legal risks recorded in risk register; not used as human gates").
RECONCILIATION §9.

**Supporting capabilities:** CAP-004 (asset generation), CAP-010 (compliance/disclosure),
CAP-005 (full-discipline production)

---

## D-004 — Governed Monetization Ethics Envelope

**Claim:** The factory is the first production system that enforces a constrained-optimization
policy on monetization by construction — making unconstrained LTV maximization a factory
defect rather than a feature.

**Evidence:** Brief §Constraints ("unconstrained LTV maximize is a factory defect; adversarial
review of monetization-ethics-contract mandatory"). RECONCILIATION §8.

**Supporting capabilities:** CAP-011 (monetization ethics enforcement)

---

## D-005 — Engine-Portable Spec Layer

**Claim:** Game specs (design, systems, economy, narrative) produced by game-factory are
engine-neutral by construction, enabling re-targeting to a new engine without spec revision.

**Evidence:** architecture.md ("the spec layer is engine-portable by construction. A design
can be re-targeted to another engine even though its code/assets cannot port. That is the
deepest form of no-lock-in."). Brief §Success Criteria ("One spec → many engines").

**Supporting capabilities:** CAP-001 (engine adapter protocol), CAP-005 (spec production)

---

## D-006 — Compliance and Provenance Pipeline as First-Class Output

**Claim:** The factory treats EU AI Act Art. 50 compliance, PEGI/ESRB rating submissions,
FTC COPPA consent wiring, and Steam AI disclosure as first-class pipeline outputs generated
from the same provenance data that governs asset quality — not afterthought checklists.

**Evidence:** Brief §Constraints ("EU AI Act Art. 50 — applies 2026-08-02; C2PA marks
generated from provenance sidecar; ai-disclosure-manifest is a required pipeline output").
RECONCILIATION §10 Tier 1 (compliance pipeline as ship prerequisite).

**Supporting capabilities:** CAP-010 (compliance pipeline), CAP-004 (provenance sidecar)

---

## D-007 — Structured Playtest Protocol (Never Auto-Scored Fun)

**Claim:** game-factory is the only automated game production system that explicitly refuses
to auto-score fun or feel, instead providing a structured playtest protocol infrastructure
with 3-lens convergence instruments, while governing the subjective shell via a human gate
that cannot be bypassed.

**Evidence:** Brief §Out of Scope ("auto-scoring fun: OUT (never)"). RECONCILIATION §2
("Satisfaction over Boolean Pass/Fail"). DI-007 (invariant).

**Supporting capabilities:** CAP-008 (playtest protocol), CAP-007 (convergence tracking)
