---
document_type: phase-0-extraction-boundary-validated
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
source_repo: vsdd-factory@82163b7
producer: codebase-analyzer
validates: planning/design/extraction-boundary.md
---

# Extraction Boundary — Validated

> Confirms / refines `planning/design/extraction-boundary.md` against the actual
> `.reference/vsdd-factory@82163b7` source. Verdict: the draft 3-bucket model is
> **correct**. The ~70% spine / ~30% quality-model split is **validated** with two
> material refinements (see §3). Disposition codes:
> **REUSE** (extract verbatim/lightly) · **REPLACE** (swap VSDD-software model for
> game model) · **ADAPT** (neutral mechanism, game-aware extension needed).

## 1. Component disposition table

| Component | Reference path(s) | Disposition | Rationale | game-factory disposition |
|---|---|---|---|---|
| **Dispatcher binary** | `crates/factory-dispatcher/` | REUSE | Pure WASM host + event router; zero VSDD knowledge. Reads stdin envelope, loads registry, runs wasmtime tiers, emits telemetry. | Extract verbatim. Layer-1 core. |
| **Hook SDK + macros** | `crates/hook-sdk/`, `crates/hook-sdk-macros/` | REUSE | Generic plugin ABI (read/write/exec/emit/env/log/memory capabilities). | Extract verbatim. Layer-1 core; game guards compile against it. |
| **Telemetry sinks** | `crates/sink-core`, `crates/sink-{file,otel-grpc,http,datadog,honeycomb}` | REUSE | Standard observability fan-out. | Extract verbatim. |
| **Context resolvers** | `crates/vsdd-context-resolvers/` | REUSE | Mechanism-generic resolver registry (despite "vsdd" name). | Extract; rename to drop "vsdd". |
| **Hook registry config model** | `plugins/vsdd-factory/hooks-registry.toml` | REUSE (schema) / REPLACE (row set) | The TOML schema (schema_version 2; name/event/tier/timeout/capabilities/on-error) is neutral; the *registered guard set* is mixed. | Keep schema; ship a game guard set. |
| **Neutral hook plugins** | `crates/hook-plugins/{worktree-hooks, update-wave-state-on-merge, track-agent-start, track-agent-stop, capture-commit-activity, capture-pr-activity, session-{start,end}-telemetry, session-learning, tool-failure-hooks, validate-state-structure, validate-artifact-path, validate-dispatch-advance, validate-index-cite-refresh, validate-stable-anchors, pr-manager-completion-guard, handoff-validator, block-ai-attribution, lint-registry-async-invariant, legacy-bash-adapter, warn-pending-wave-gate, validate-policies-schema, validate-trajectory-tail-cell-completeness, validate-state-pin... }` | REUSE | Govern git/worktree/wave/state/PR/telemetry — all domain-neutral. | Extract verbatim. |
| **VSDD-quality hook plugins** | `crates/hook-plugins/{regression-gate, validate-per-story-adversary-convergence, validate-burst-log, validate-closes-completeness}` | ADAPT/REPLACE | Tied to BC/VP convergence + burst-log discipline. Mechanism (regression gate, convergence guard) is portable; *what* it gates is VSDD. | Reshape for sim-contract/replay regression + game convergence dims. |
| **Lobster workflow DSL + parser** | `bin/lobster-parse`, `workflows/*.lobster` (engine) | REUSE | Step types (skill/agent/gate/loop/human-approval/sub-workflow), DAG `depends_on`, conditions, cost-monitoring — fully neutral pipeline DSL. | Extract DSL + parser verbatim. |
| **Greenfield/feature/etc. workflow *content*** | `workflows/greenfield.lobster`, `feature.lobster`, `workflows/phases/phase-{4,6}-*.lobster` | ADAPT / REPLACE | Scaffolding (repo-init, worktree-health, state-init, planning, consistency gates, adversarial loops) is neutral and REUSED; phase-4 (holdout), phase-6 (formal-hardening), DTU + gene-transfusion steps, and convergence *criteria lists* are VSDD steps. | Keep scaffold; swap phase-4→playtest, phase-6→sim-hardening-scope, replace convergence criteria. |
| **Orchestrator + sequences** | `agents/orchestrator/` (orchestrator.md + {greenfield,brownfield,feature,maintenance,discovery,multi-repo,steady-state,per-story-delivery}-sequence.md, HEARTBEAT.md) | REUSE | Coordination + dispatch + "never writes files" discipline — domain-neutral. | Extract; sequences re-pointed at game phases. |
| **Agent routing table** | `CLAUDE.md` §Agent Routing Table | REUSE (mechanism) / ADAPT (rows) | The routing mechanism is neutral; ~6 rows are VSDD-quality roles. | Keep table; swap quality-role rows for game roles. |
| **Neutral specialist agents** | `agents/{orchestrator, architect, business-analyst, product-owner, story-writer, consistency-validator, adversary, spec-reviewer, code-reviewer, pr-manager, pr-reviewer, devops-engineer, dx-engineer, github-ops, state-manager, spec-steward, technical-writer, research-agent, session-reviewer, codebase-analyzer, validate-extraction, data-engineer, performance-engineer}.md` | REUSE | Building-software-with-agents roles, domain-neutral. | Extract verbatim/lightly. |
| **VSDD-quality agents** | `agents/{formal-verifier, dtu-validator, holdout-evaluator}.md` | REPLACE | Software-verification-specific roles. | Replace: holdout-evaluator→playtest-evaluator; dtu-validator→replay-regression; formal-verifier→sim-formal-hardening (scoped to pure-sim slice). |
| **UI/UX quality agents** | `agents/{ux-designer, visual-reviewer, accessibility-auditor, e2e-tester, demo-recorder, security-reviewer, implementer, test-writer, stub-architect}.md` | ADAPT | Neutral software-build roles; game variants need engine-adapter awareness (capture backend, sim test runner). | Extract + extend (game agents added in Layer 2). |
| **Neutral skills** | `skills/{create-brief, create-prd, create-domain-spec, create-architecture, create-adr, create-story, decompose-stories, wave-scheduling, wave-status, wave-gate, planning-research, research*, brownfield-ingest, disposition-pass, semport-analyze, phase-0-codebase-ingestion, repo-initialization, worktree-manage, factory-worktree-health, pr-create, pr-review-triage, fix-pr-delivery, release, model-routing, compact-state, state-update, state-burst, recover-state, check-state-health, consistency-validation, adversarial-review, next-step, run-phase, register-artifact, relocate-artifact, ...}` | REUSE | Orchestration / planning / state / PR / research / extraction tooling — domain-neutral. ~85 of 121 skills. | Extract. |
| **Convergence skills** | `skills/{convergence-check, convergence-tracking, phase-7-convergence}` | ADAPT | Convergence-loop engine + novelty-decay + 3-CLEAN streak are neutral; the **7-dim definition** (spec/tests/impl/verification/visual/perf/docs) is hardcoded software-quality. | Keep loop engine; redefine dimensions: spec · sim-tests · impl · playtest/feel · frame-budget · asset-completeness · visual · docs; wire each to declare-and-degrade vs adapter fidelity. |
| **VSDD-quality skills** | `skills/{holdout-eval, dtu-create, dtu-validate, formal-verify, phase-4-holdout-evaluation, phase-6-formal-hardening, perf-check, purity-check-related, toolchain-provisioning}` | REPLACE | Software-verification quality model. | holdout-eval→playtest-protocol; dtu→replay-regression harness; formal-verify→pure-sim-only hardening; perf-check→frame-budget; toolchain→engine-adapter toolchain. |
| **TDD red-gate** | `hooks/red-gate.sh`, `hooks/validate-red-ratio.sh`, `skills/phase-3-tdd-implementation` | ADAPT (refined — see §3.1) | red-gate.sh is **TDD-generic and opt-in** (`strict` mode via `.factory/red-gate-state.json`, defaults off), NOT BC-coupled. Ports dark-factory's tdd-enforcement. | REUSE the red-gate as-is for the deterministic-sim slice (degrades off for engine-bound code). |
| **BC/VP protection hooks** | `hooks/{protect-bc.sh, protect-vp.sh, validate-bc-title.sh, validate-vp-consistency.sh, validate-story-bc-sync.sh}` | REPLACE | Enforce VSDD BC/VP schema integrity. | Replace with sim-BC + design-intent-contract + replay-regression-contract integrity guards. |
| **Spec templates (quality)** | `templates/{behavioral-contract, L4-verification-property, holdout-*, dtu-*, formal-verification, fuzz-report, verification-*}` | REPLACE | VSDD spec data-model. | Replace with game contract templates (sim-BC, design-intent, replay-regression, playtest-protocol, asset-provenance). |
| **Spec templates (structural)** | `templates/{state, story, wave-schedule, adr, pr-description, architecture*, prd*, brief*, consistency-report, convergence-report, ...}` | REUSE/ADAPT | Structural artifacts, neutral. | Extract; convergence-report adapts to game dims. |
| **Purity hook** | `hooks/purity-check.sh` | ADAPT | Warn-only pure-core/effectful-IO boundary; relevant to the deterministic-sim slice. | Keep for sim slice; not enforced on engine/render code. |
| **Demo recorder** | `agents/demo-recorder.md`, `skills/{demo-recording, record-demo}`, demo templates | ADAPT | Mechanism (VHS/Playwright capture as evidence) is neutral; games need gameplay capture. | Re-back onto adapter `capture` command + ffmpeg fallback. |
| **Operational CLIs** | `bin/{factory-dashboard, factory-obs, factory-replay, factory-query, factory-report, factory-sla, compute-input-hash, wave-state, multi-repo-scan, emit-event, research-cache}` | REUSE | Observability/state tooling, neutral. | Extract; `factory-replay` notably aligns with the game replay-regression need. |
| **Governance rules** | `rules/{factory-protocol, git-commits, worktree-protocol, step-decomposition, story-completeness, bash}.md` | REUSE | Neutral protocol. | Extract. `rules/rust.md`, `rules/spec-format.md` ADAPT (Rust-specific / VSDD-spec-shaped). |
| **Policies registry** | `.factory/policies.yaml` + `hooks/validate-policies-schema` | REUSE (mechanism) | Declarative governance policy registry auto-loaded by adversary + lint hooks. Some policies (POL-7/8/9 BC/VP) are VSDD. | Keep registry mechanism; swap BC/VP policies for game-contract policies. |

## 2. The precise reuse/replace seam

The neutral spine and VSDD-specific code do **not** interleave at the function level
inside the dispatcher (that runtime is 100% neutral). The seam is entirely at the
**configuration / content boundary**, which is why Option-C extraction is tractable.
The seam is **four declarative interfaces**:

1. **`hooks-registry.toml` row set.** The dispatcher loads whatever guards the
   registry lists. Swap the VSDD-quality rows (BC/VP/red-ratio/burst-log/per-story-
   adversary-convergence) for game-quality rows (sim-contract integrity, replay-
   regression, playtest-evidence, asset-completeness). **No engine change.**

2. **Lobster phase sub-workflows.** `workflows/phases/phase-4-holdout-evaluation.lobster`
   and `phase-6-formal-hardening.lobster` are self-contained named steps in the
   greenfield/feature pipelines. Replace those two files (+ the DTU/gene-transfusion
   assessment steps in phase-1, + the convergence *criteria list* in phase-7).
   The pipeline scaffold (repo-init → worktree-health → state-init → planning →
   spec → consistency gate → adversarial loop → wave delivery → convergence → release)
   is untouched.

3. **Agent routing table rows.** Swap ~6 routing-table rows (formal-verifier,
   dtu-validator, holdout-evaluator + product-owner BC/VP duties) for game roles.
   Mechanism untouched.

4. **Spec template + INDEX data-model.** BC-INDEX/VP-INDEX/holdout/DTU/formal
   templates ARE the quality regime's data model. Replace the template set + index
   schemas; keep the index *mechanism* (catalog + cross-doc consistency hooks).

**Seam summary:** the extraction boundary is a **content/config boundary, not a code
boundary**. The Rust runtime + lobster DSL + orchestrator + state/worktree/PR/wave/
adversarial machinery cross the boundary into Layer 1 untouched; the BC/VP/holdout/
DTU/formal *content* (templates, registry rows, phase steps, routing rows, indexes)
stays behind / is replaced by the Layer-2 game quality model.

## 3. Corrections / refinements to the draft extraction-boundary.md

The draft is substantially correct. Refinements:

### 3.1 (MATERIAL) red-gate / TDD is REUSE, not REPLACE.
The draft implicitly bundles "TDD red gate" with the VSDD-quality bucket
("STAYS in vsdd-factory"). **Source check: `hooks/red-gate.sh` is TDD-generic,
opt-in (`mode: strict` via `.factory/red-gate-state.json`, defaults off), engine-
agnostic, and explicitly ports dark-factory's generic tdd-enforcement.** It is NOT
coupled to BC schemas. game-factory should REUSE red-gate verbatim for the
deterministic-sim slice (where TDD applies) and simply leave it off (its default) for
engine-bound/render code. This *enlarges* the reusable spine slightly. The
AAA-RECONCILIATION already says "Red Gate retained for pure-sim code" — this confirms
it at the hook level.

### 3.2 (MATERIAL) Convergence is ADAPT (split), not a clean STAY.
The draft lists "7-dimensional convergence definition" under STAYS. Refinement: the
**convergence-loop engine, novelty-decay assessment, and 3-CLEAN streak protocol are
neutral and REUSED**; only the *dimension set* is replaced. The draft's architecture.md
already names the new dims — this just records that the split runs *through* the
convergence skill, not around it. Practically: extract `convergence-check`/
`convergence-tracking`, edit the dimension list + criteria, keep the loop.

### 3.3 (MINOR) `vsdd-context-resolvers` crate is REUSE despite its name.
It is a generic resolver registry with a determinism proptest; carry it over and
rename to drop "vsdd".

### 3.4 (MINOR) The seam is config/content, not code — extraction is lower-risk than
"riskiest single step" implies for the *runtime*, but the draft's risk callout is
correct for the *content* layer (BC/VP/dims are baked into agents/skills/templates,
not behind an interface). The mitigation is that they are baked in as **discrete,
named, declarative units** (registry rows, phase files, routing rows, templates), so
excision is mechanical swap-out, not surgical untangling of interleaved logic.

### 3.5 (CONFIRM) Validated % spine.
~70% reusable spine **confirmed**. Quantified by component: of 35 agents, ~26 REUSE/
ADAPT-neutral, 3 REPLACE (~91% retained, slightly under on quality roles); of 121
skills, ~85 REUSE + ~24 ADAPT, ~12 REPLACE (~90% retained at skill granularity); of
the Rust workspace (~80k LOC) the dispatcher/SDK/sinks/resolvers (~100% neutral) plus
~24/28 hook plugins are REUSE. The "~30% replace" is concentrated in the
**quality-model content** (BC/VP/holdout/DTU/formal templates + 2 phase workflows +
a handful of guard plugins + ~6 agent/skill roles), which is a smaller *fraction of
files* than 30% but represents the *conceptual* 30% (the entire quality philosophy).
**Verdict: keep the ~70/30 framing as a conceptual split; at the file level the
reusable spine is closer to ~85% of artifacts.**

## State Checkpoint
```yaml
pass: extraction-boundary
status: complete
timestamp: 2026-06-07T00:00:00Z
source_repo: vsdd-factory@82163b7
draft_validated: true
material_corrections: 2  # red-gate=REUSE, convergence=ADAPT-split
```
