---
document_type: domain-spec-section
level: L2
section: processes
version: "1.1"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/design/architecture.md
  - .factory/planning/design/engine-adapter-protocol.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
modified:
  - version: "1.1"
    date: 2026-06-16
    by: product-owner
    reason: "F64-01 AMBER→canonical residual sweep: replaced non-canonical 'amber/blocked' token in PROC-006 Stage 4 with canonical 'DEGRADED-PENDING or BLOCKED' per methodology-layer.md §3.1 enum."
---

# Domain Processes

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> Processes model domain workflows — triggers, state transitions, happy and failure paths.

---

## PROC-001 — Game Production Pipeline (Seed → Converge)

The primary production workflow from game spec to shippable build.

**Trigger:** GameSpec created and validated.

**Stages:**
1. **Spec Crystallization** — Business analyst + product owner produce L2 domain spec,
   PRD, and all-genre core contract set. Consistency validator cross-checks IDs and anchors.
2. **Story Decomposition + Wave Scheduling** — Story writer decomposes PRD into stories;
   producer builds dependency DAG and wave schedule. Cross-discipline dependency contracts
   established.
3. **Wave-Gated Production** — For each wave: discipline agents generate artifacts (design
   specs, assets, code, narrative, audio); contracts validated; replay-regression run; wave
   gate checked before advancing.
4. **Asset Lane** — Concurrent with waves: asset-generation-orchestrator runs GenerationRequests
   → Quality Gate → ProvenanceSidecar → asset store. Pure-maximal; no creative finishing gate.
5. **Playtest Gate** — Structured playtest protocol runs against a playable build; 3-lens
   convergence report produced; human sign-off required before cert stage.
6. **Cert Pre-Flight + Distribution Readiness** — cert-owner runs pre-flight harness;
   distribution CLIs executed; `human-gated` task list emitted for store publish / console cert.
7. **Convergence Check** — All 11 dimensions evaluated. Adversarial review runs. Dimensions
   that are not green trigger declare-and-degrade or block release.

**Failure paths:**
- Wave gate fails → stories re-queued in next wave; dependency contracts re-evaluated.
- Replay regression fails → re-simulate; if T1 tier, determinism root-cause required.
- Playtest satisfaction not met → design intent contracts revised; new playtest scheduled.
- Compliance checklist gaps → compliance-officer generates human-gated resolution tasks.

---

## PROC-002 — Engine Adapter Onboarding

The workflow for adding a new engine to the factory.

**Trigger:** Decision to support a new engine (e.g., Godot third adapter).

**Stages:**
1. **Capability Declaration** — Adapter author writes `engineCapabilities` manifest:
   per-capability fidelity, determinism tier, execution profiles.
2. **Driver Implementation** — Code drivers written for capabilities requiring logic
   (replay, capture, introspect). YAML manifest covers ~80% of commands.
3. **Conformance Suite Run** — Suite executes tests only for declared capabilities.
   Results: pass/fail per capability.
4. **Determinism Tier Verification** — T1 adapters: reproduce identical snapshot hash
   across two different CI runners. T2/T3: appropriate tolerance-window tests.
5. **Reference Mini-Game Validation** — Adapter builds, runs, and tests the reference
   mini-game successfully.
6. **Acceptance** — All declared capabilities pass conformance → adapter accepted.
   "Implement adapter + pass conformance; ZERO core changes."

**Failure paths:**
- Capability declared at `full` but test fails → downgrade to `partial` or fix driver.
- Reference mini-game build fails → build capability blocked; other capabilities unaffected.
- T1 tier claimed but hash differs across runners → tier must be downgraded to T2.

---

## PROC-003 — Asset Generation and Provenance Capture

The per-asset workflow for generating game content lights-out.

**Trigger:** GenerationRequest issued (per game-production-plan + design-spec).

**Stages:**
1. **Risk Tier Assignment** — Asset class and use-case determine risk tier (Tier-1/2/3).
   Tier-1 = licensed/indemnified tools. Tier-2 = some indemnification. Tier-3 = unindemnified.
2. **Backend Selection** — asset-generation-orchestrator routes to appropriate backend
   per risk-tier policy (Tripo/Rodin for 3D; ElevenLabs for SFX; Stable Audio for music; etc.).
3. **Generation** — Backend generates raw asset + provenance sidecar fields populated
   automatically at generation time (tool, model, prompt log, license, disclosure_class).
4. **Quality Gate** — topology/UV/PBR/loudness/provenance completeness checks run.
   Pass + Tier-1: auto-ingest. Pass + Tier-2/3: flag, ingest anyway (pure-maximal).
   Fail: flag defect, re-generate with adjusted parameters.
5. **Likeness Check** — If `likeness_consent_ref != null`, trigger `human-gated` SAG-AFTRA
   signature flow before asset can be used in final build.
6. **Ingest** — Asset stored in canonical format (GLB for 3D). Engine adapter imports via
   `assets_validate` capability.

**Failure paths:**
- Tool outage → fallback to secondary backend if available; else flag as blocked.
- Topology/UV failure on re-generate → escalate to quality-gate-report; studio elects action.
- Likeness consent not obtained → asset remains placeholder; not usable in ship build.

---

## PROC-004 — Replay Regression Workflow

The game-factory analog of VSDD's DTU: regression detection via deterministic replay.

**Trigger:** Simulation code changed (gameplay systems, economy, physics integration).

**Stages:**
1. **Input Recording** — During reference-game run: input stream recorded keyed by sim frame.
   Golden sim state captured at designated checkpoints.
2. **Tier-Appropriate Replay** — T1: re-run on any machine; compare snapshot hash.
   T2: re-run on pinned CI image; compare snapshot diff. T3: re-run; compare metrics within
   tolerance window.
3. **Diff Evaluation** — Pass: no unexpected divergence. Fail: regression detected;
   diff surfaced with frame-precise location.
4. **Degradation** — If adapter reports `replay: none` (no fixed-timestep or no RNG injection):
   dimension degrades to human playtest evidence requirement.

**Failure paths:**
- T1 hash mismatch → determinism root-cause analysis required; engine adapter re-checked.
- Golden state file missing → replay blocked; new golden state must be recorded.
- T2 pinned runner unavailable → degrade to T3 tolerance; note in convergence report.

---

## PROC-005 — Playtest Protocol Execution

The human-gate quality dimension for feel, fun, and polish.

**Trigger:** A playable build reaches playtest milestone; playtest-evaluator agent prepares
the playtest protocol document.

**Stages:**
1. **Protocol Preparation** — playtest-evaluator defines research question, recruitment
   criteria, tasks, instruments (GEQ/PENS/SUS), and success thresholds.
2. **Session Execution** — Human participants play; 3-lens data collected (say: verbal
   think-aloud; do: observable actions; behave: physiological/biometric signals if available).
3. **Convergence Report** — playtest-evaluator synthesizes 3-lens data into structured
   convergence report per GEQ/PENS/SUS dimensions.
4. **Human Sign-Off** — A human (producer or director) reviews convergence report and signs
   off on playtest-satisfaction dimension. This sign-off is mandatory; no automated substitute.
5. **Design Revision Loop** — If satisfaction thresholds not met: design intent contracts
   revised, implementation cycle runs, new playtest scheduled.

**Failure paths:**
- Recruitment fails → playtest blocked; milestone gate stalled.
- Instruments report satisfaction below threshold → design revision loop triggered.
- `directed: true` cinematic flagged → cinematic-director creative sign-off required separately.

---

## PROC-006 — Human-Gated Task Surfacing

The process by which external, third-party-required human acts are surfaced — not silently
dropped — when the factory completes its automatable prefix.

**Trigger:** Any production step reaches a `human-gated` fidelity boundary:
console cert sign-off, store publish/pricing, SAG-AFTRA consent, legal opinion,
XR comfort-cert, paid-UGC vetting.

**Stages:**
1. **Automatable Prefix Completion** — Factory completes all automatable work
   (cert pre-flight, build upload, document template generation, rights-clearance metadata).
2. **Checklist Generation** — A checklisted human task is generated with: what must be done,
   by whom, with what artifacts, and what the success criterion is.
3. **Surfacing** — Task is surfaced to the producer / cert-owner role via the milestone gate
   mechanism. Not silently skipped, not dropped from the convergence report.
4. **Completion Gating** — The `human-gated` convergence sub-dimension remains DEGRADED-PENDING or BLOCKED
   until the task is marked complete by the responsible human.

**Invariant:** Suppressing a `human-gated` task without completion is hook-detectable as a
defect. The convergence report must reflect outstanding `human-gated` items.
