# Research Reconciliation — Pass 1

**Date:** 2026-06-07
**Inputs:** `bevy-capabilities.md`, `unity-capabilities.md`, `godot-capabilities.md`, `prior-art-and-precedents.md`
**Purpose:** reconcile the from-memory `[PROVISIONAL]` design claims against cited research — what was **confirmed**, **refuted/refined**, and **newly surfaced** — and record the resulting design changes.

---

## A. CONFIRMED (provisional claims now cited)

1. **The premise is sound and the gap is open.** No one builds an engine-agnostic build-AND-test factory across Unity/Godot/Unreal/Bevy. Deepest cross-engine test SDKs reach only **two** engines (Unity+Unreal); Godot and Bevy are unserved at the deep/semantic level; engine-agnostic tools are all black-box (pixels/OCR). **The whole Option-C premise is validated by an empty market quadrant.**

2. **The capture-vs-headless conflict is real — and it's the COMMON case, not a Unity quirk.**
   - Unity: `-nographics` → blank/black frames (confirmed, fresh June-2025 repro). Needs xvfb + software GPU, drop `-nographics`.
   - Godot: `--headless` disables *all* rendering. Same conflict, same xvfb+Mesa(lavapipe) workaround.
   - Bevy: offscreen render-to-texture works *windowless* — **but still needs a wgpu backend** (real GPU or lavapipe). "Headless = no GPU" is FALSE everywhere.
   - **→ Protocol design "capture fidelity is independent of run_headless" is confirmed by all three.**

3. **The protocol-precedent analogy (LSP / Terraform / CRI / Testcontainers) holds** — all four match the pattern, and they're complementary rather than redundant.

4. **The two-adapter rule paid off immediately.** Bevy+Unity exposed the capability-independence requirement (capture ⊥ headless) that a similar pair would have hidden.

---

## B. REFUTED / REFINED (design claims corrected)

1. **"Bevy is the determinism champion" → REFINED.** Bevy is non-deterministic *by default* (parallel ECS scheduling, hash iteration, FP). Determinism is **opt-in/DIY** for every engine. BUT: **Rapier physics gives Bevy cross-platform *bitwise* determinism** (snapshot-hash identical across OS/CPU) — a guarantee Unity PhysX (same-machine only) and Godot Physics/Jolt (no guarantee) cannot match. So Bevy's determinism *ceiling* is highest, but it's earned, not free.

2. **Unity replay = "DIY" → REFUTED.** Unity has a **native** input record/replay primitive (`InputEventTrace` / `InputRecorder`) — but only via the **new Input System** package; the legacy Input Manager has none. (Godot/Bevy replay remain DIY-on-a-primitive.)

3. **Bevy test output = "libtest JSON" → REFINED.** libtest JSON is nightly-unstable. The stable machine-readable path is **cargo-nextest → JUnit XML**. So all three engines normalize to **JUnit/NUnit-family XML** except Bevy-via-nextest (JUnit) — convenient: the normalized result schema's source formats are NUnit3 (Unity), JUnit (Godot GUT, Bevy nextest), with libtest-JSON as a Bevy fallback.

4. **"Godot is between Bevy and Unity on every axis" → REFINED (7/8).** Holds on 7 axes; **breaks on capture**, where Godot sits *with* Unity (headless disables rendering). On lint + introspect Godot is *better* than the between-prediction.

---

## C. NEWLY SURFACED (not in the original design)

1. **Determinism TIER is a required capability dimension.** Classify each adapter: `bitwise-cross-platform` (Bevy+Rapier) / `same-machine` (Unity PhysX, Godot) / `tolerance-only`. The replay-regression model's strictness must degrade by tier — exact snapshot-hash diff for tier 1, tolerance-window metric diff for tiers 2–3. None of the four protocol precedents had to model this; it's our game-specific addition to the capability schema. **→ Decision 0003.**

2. **Two execution profiles per adapter.** `headless-compute` (build/test/introspect/assets — true headless, cheap) vs `render` (capture/video — virtual display + software GPU). Bevy: render profile = windowless + lavapipe. Unity/Godot: render profile = xvfb + software GPU, no headless flag. **→ bake into protocol manifest.**

3. **Reuse the engine-native build runners.** Don't reinvent: wrap **GameCI** (Unity), **godot-ci** (Godot), **UAT/BuildGraph** (Unreal), **Cargo** (Bevy), and **Rapier** for determinism. Build only the protocol + conformance + the semantic/replay layer (esp. for Godot/Bevy where no deep SDK exists).

4. **Conformance approach is now decided by precedent (hybrid).** LSP-style dynamic capability negotiation + Terraform-style versioned protocol & acceptance tests through the real adapter + **CRI/CSI-style capability-gated conformance suite** (the load-bearing anti-drift mechanism). Explicitly avoid the Testcontainers "no conformance" trap. **→ Decision 0002.**

5. **Unity licensing is a per-CI-agent factory constraint.** Every runner needs an activated seat (`.ulf` / Build Server / floating); serial-CLI activation is legacy; headless activation itself needs xvfb. This is a real operational cost the Unity adapter must document.

6. **Bevy Remote Protocol (BRP) is a standout introspection asset.** Native JSON-RPC 2.0 over HTTP to the live ECS — almost purpose-built for an external automated harness. (Method names renamed in 0.17: `bevy/query`→`world.query`.) The Bevy adapter should use BRP as its `introspect` (and scenario-driving) backbone.

7. **Pre-1.0 API churn is the Bevy adapter's dominant maintenance risk.** ~quarterly breaking changes (verified BRP/ECS renames 0.15→0.18) + ecosystem-crate version lag (replay crate gates the effective Bevy version). The adapter must pin an exact version and treat each minor release as scheduled maintenance.

8. **Meta-lesson: AI research tools confabulate hard on fast-moving engine APIs.** The Bevy agent caught Perplexity inventing ~10 APIs and false case studies; it re-verified against primary sources. **Adapter implementation must verify every engine API against the exact version-tagged example/docs, never against a summarizer.**

---

## D. Net effect on the design

- Capability matrix: capture row confirmed (all need a GPU backend; Bevy windowless is the only meaningfully cleaner case).
- Capability schema gains: `determinism_tier`, `execution_profiles` (headless-compute | render).
- `replay`: Unity native (new Input System); Godot/Bevy DIY-on-primitive.
- `test` normalized source formats: NUnit3 (Unity) / JUnit (Godot GUT, Bevy nextest) / libtest-JSON fallback (Bevy).
- Protocol stance: hybrid (LSP negotiation + Terraform versioning/acceptance + CRI/CSI conformance), Testcontainers as anti-pattern. → Decision 0002.
- Determinism tier added to capability schema + conformance classification. → Decision 0003.
- Build layer: wrap engine-native runners + Rapier, don't reinvent.
- Operational: Unity per-agent licensing; Bevy version-pinning + churn budget.
