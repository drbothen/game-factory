---
document_type: product-brief
level: L1
version: "2.2"
status: draft
producer: "human+planning-research"
timestamp: 2026-06-07T00:00:00
phase: 1a
inputs:
  - planning/research/aaa/AAA-RECONCILIATION.md
  - planning/design/architecture.md
  - planning/design/engine-adapter-protocol.md
  - planning/design/protocol-schema.md
  - planning/design/extraction-boundary.md
  - planning/decisions/0001-founding-engine-pair.md
  - planning/decisions/0002-protocol-and-conformance-stance.md
  - planning/decisions/0003-determinism-tier-capability.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: ""
---

# Product Brief: game-factory

## What Is This?

game-factory is a **Dark Factory for AAA game development**: a lights-out, multi-agent system
that applies vsdd-factory's governance rigor to game production and generates EVERYTHING a game
needs — design, art, audio, narrative, code, QA artifacts — for any genre, at AAA quality. It
is engine-, tool-, and platform-agnostic via five adapter seams (engine / asset / distribution /
XR / online-services) plus a canon knowledge-base (sixth load-bearing seam). Authoritative charter: `planning/research/aaa/AAA-RECONCILIATION.md` (v2.0).

## Who Is It For?

| Persona | Pain Point |
|---------|-----------|
| Multi-studio platform teams | Siloed per-engine CI; no shared semantic test/replay layer |
| Indie / small-studio tech leads | Want spec-driven, adversarially reviewed pipelines; lack team to build them |
| Solo / AI-assisted developers | Want multi-agent automation across all disciplines; current tools are black-box pixel/OCR only |

## Scope

### In Scope

- **Orchestration spine** — extracted vsdd-factory core: dispatcher, hook chain, adversarial review, wave scheduling, worktree lifecycle.
- **Game methodology layer** — simulation BCs, design-intent contracts, replay-regression, playtest protocol, 11-dimension convergence model.
- **Engine-adapter protocol + conformance suite** — JSON-RPC 2.0; Bevy + Unity founding pair; Godot third; conformance is load-bearing.
- **Asset generation (pure-maximal)** — all assets (hero art, music, voice) with NO mandatory human creative finishing; auto-provenance sidecar per asset (`disclosure_class` incl.).
- **Five adapter seams** — engine / asset / distribution (`human-gated` for cert/publish) / XR (seam reserved; impl. deferred) / online-services (BaaS — identity/saves/leaderboards/matchmaking/entitlements; Nakama self-hostable reference; Tier-1 v1).
- **Canon knowledge-base** — entity-registry + relationship-graph + timeline; RAG anchor for all generative agents.
- **All-genre core contract set + det-sim pilot** — genre-universal contracts (design, systems, economy, narrative, audio, cert, compliance, security-authority-invariants); one Bevy+Rapier (T1) game proves end-to-end.

### Out of Scope / Deferred

**DEFERRED — Tier 3 (seam reserved; not built):** Unreal Engine adapter; VR/AR/XR implementation.

**OUT (never):** Building a game engine; auto-scoring "fun"; kernel anti-cheat authoring;
virtual-production hardware; running live esports/events; unconstrained LTV optimization.

**HUMAN-GATED external steps** (automatable work done; single checklisted task surfaced —
NOT creative finishing, NOT dropped): console cert sign-off; store publish/pricing;
SAG-AFTRA/likeness consent signatures; legal-opinion sign-off; XR comfort-cert; paid-UGC
vetting; live esports/anti-cheat ops.

## Success Criteria

| Outcome | Metric | Target |
|---------|--------|--------|
| Engine-agnostic by construction | Engine adapters passing conformance suite | ≥ 3 (Bevy, Unity, Godot) |
| One spec → many engines | Reference game from a single engine-neutral spec | Runs on ≥ 2 engines |
| Replay-regression works | Injected sim regression detected at T1 (bitwise) | 100% on reference game |
| No lock-in (all five seams) | New engine/tool/platform onboarding cost | Implement adapter + pass conformance; ZERO core changes |
| Full asset provenance | Generated assets with complete provenance sidecar | 100%; 0 missing `disclosure_class` |
| All-genre + pilot proven | Core contract set defined; det-sim pilot ships end-to-end | Contract set complete; pilot on Bevy |

## Constraints & Integration Points

- **Built BY vsdd-factory** — greenfield new layers + Phase-0 brownfield extraction of vsdd-factory core (`planning/design/extraction-boundary.md`).
- **Pure-maximal + auto-provenance** — IP/legal risks recorded in risk register; not used as human gates. `human-gated` = external third-party acts ONLY (not creative quality).
- **Monetization-ethics envelope** — constrained optimization only; unconstrained LTV maximize is a factory defect; adversarial review of `monetization-ethics-contract` mandatory.
- **EU AI Act Art. 50** — applies 2026-08-02; C2PA marks generated from provenance sidecar; `ai-disclosure-manifest` is a required pipeline output.
- **ToS-excluded tools** — Suno/Udio (litigation), Riot Vanguard (not licensable), kernel AC drivers blocked by policy.
- **Determinism tiers** — T1 Bevy+Rapier (bitwise), T2 Unity PhysX (pinned-runner), T3 Godot (tolerance-window); det-sim pilot targets T1.
- **Capture requires GPU** — "headless = no GPU" is false; separate `render` profile per engine (confirmed by research).
- **SAG-AFTRA / likeness consent** — any voice/face with consent ref triggers `human-gated` signature flow; not automatable.

---

## Overflow Context (Reference Only — exempt from word limit)

**Authoritative charter.** `planning/research/aaa/AAA-RECONCILIATION.md` (v2.0) is the
single source of truth for the full methodology, agent roster (66 roles), artifact taxonomy,
convergence model (11 dimensions), and risk register (R-001 through R-017). Pipeline agents
should load the charter directly; do not treat this section as exhaustive.

**Dark Factory lights-out principles.** game-factory applies vsdd-factory's Dark Factory
paradigm (StrongDM lineage: Seed → Validation Harness → Feedback Loop) to games. No step
requires mandatory human authorship except declared `human-gated` external acts. Every
discipline decomposes into a machine-verifiable spine (the factory owns it) and a subjective
shell (governed by structured human gates — playtest, monetization-ethics review — never
collapsed to an automated scalar).

**vsdd rigor tailored to game dev.** 70% of vsdd-factory's machinery carries over unchanged
(orchestration, worktrees, adversarial review, wave scheduling, conformance gating, TDD Red Gate,
hook chain). The 30% replaced: simulation BCs for the verifiable spine; design-intent contracts
for the verifiable subset of feel; playtest protocol (never an auto-fun-score) for the subjective
remainder; deterministic replay harness instead of DTU; asset lane; reshaped 11-dimension
convergence model.

**Five-seam + canon-KB thesis.** The capability-negotiation + fidelity-grading + conformance-suite
pattern applies identically to engines, assets, distribution/stores, XR runtimes, and online-services
(BaaS). The canon-KB is the sixth load-bearing seam: the shared lore/entity/timeline RAG anchor. The
`human-gated` fidelity value means "automatable prefix complete; one checklisted human task
surfaced." Suppressing a `human-gated` task is hook-checkable as a defect.

**Three-tier scope model (from AAA-RECONCILIATION §10).**
- *Tier 1 — default-on, v1 ship prerequisite:* engine protocol + adapters (Bevy/Unity/Godot),
  conformance suite, orchestration spine, game methodology layer, all-genre core contract set,
  asset generation pipeline (pure-maximal), cert pre-flight + distribution-readiness, compliance
  pipeline, security invariant suite, online-services adapter, ranking-system-contract, det-sim pilot.
- *Tier 2 — v1-ready, genre-gated opt-in:* competitive-multiplayer/esports lane, modding/UGC,
  monetization mechanics, marketing/GTM lane, multiplayer tiers.
- *Tier 3 — seam reserved; implementation deferred:* Unreal Engine, VR/AR/XR, MMO-scale server
  orchestration, runtime generative NPC dialogue as a shipping feature.

**Pilot bias.** First reference game = Bevy + Rapier deterministic-simulation genre (factory/
automation, roguelike, det-RTS, management sim, card game). Maximizes verifiable spine, gives T1
bitwise replay-regression, minimizes subjective shell. Pilot parameters: `monetization_model =
premium`, `modding_enabled = false`, `esports_enabled = false`, `xr_target = none`.

**Founding-pair rationale.** Bevy + Unity are maximally dissimilar (compiled-code-first vs
editor/GUI-first; windowless-capture vs `-nographics`-conflict). Godot interpolates on 7/8
capability axes. Two-adapter rule prevents single-backend assumptions in the neutral protocol
(Decision 0001).

**Research evidence base.** Full 22-vector corpus: `planning/research/aaa/`. Per-engine reports:
`planning/research/{bevy,unity,godot}-capabilities.md`. Prior art:
`planning/research/prior-art-and-precedents.md`. Decisions: `planning/decisions/000{1,2,3}.md`.
Architecture: `planning/design/architecture.md`.
