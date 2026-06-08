---
document_type: phase-0-component-inventory
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
source_repo: vsdd-factory@82163b7
producer: codebase-analyzer
---

# Component Inventory — vsdd-factory

> One-line purpose + extraction disposition for every agent, workflow, hook, and
> the notable skill groups. Disposition: **REUSE** · **REPLACE** · **ADAPT**.
> Counts as of `develop@82163b7`: 35 agents, 121 skills, 8 top-level workflows
> (+8 phase sub-workflows), 47 bash hooks (35 top-level + 11 in `dim2-gates/` + 1 `lib/block.sh`),
> 28 hook-plugin crates, 136 templates.

## Agents (35)

| Agent | One-line purpose | Disposition |
|---|---|---|
| orchestrator (+ sequences) | Coordinates phases; dispatches specialists; never writes files. | REUSE |
| architect | Designs architecture/ADRs from domain specs + PRDs. | REUSE |
| business-analyst | Synthesizes L2 domain spec + ubiquitous language from brief. | REUSE |
| product-owner | L2→L3 PRD + behavioral contracts + holdout scenarios. | ADAPT (BC/holdout duties → game contracts) |
| story-writer | Decomposes specs into per-story files + dependency graph. | REUSE |
| architect (DTU/gene-transfusion duties) | DTU assessment, gene-transfusion assessment. | ADAPT (DTU→replay; gene-transfusion→conformance) |
| consistency-validator | Cross-document ID/anchor/count/naming validation. | REUSE |
| adversary | Fresh-context adversarial review; novelty-decay; 3-CLEAN. | REUSE |
| spec-reviewer | Constructive different-model spec second-opinion. | REUSE |
| code-reviewer | Constructive different-model PR diff review. | REUSE |
| codebase-analyzer | Deep semantic codebase scan / brownfield ingest. | REUSE |
| validate-extraction | Validates ingest output; catches hallucinated deps. | REUSE |
| pr-manager | Full PR lifecycle (9-step create→review→merge). | REUSE |
| pr-reviewer | Final fresh-eyes PR diff review before merge. | REUSE |
| devops-engineer | CI/CD, containers, worktrees, Cargo workspace, release. | REUSE (CI templates ADAPT to engine builds) |
| dx-engineer | Toolchain preflight, env setup, dependency install. | ADAPT (engine SDK provisioning) |
| github-ops | gh CLI ops for agents lacking shell. | REUSE |
| state-manager | Owns STATE.md; cycle/decision/lessons/burst bookkeeping. | REUSE |
| spec-steward | Spec versioning, traceability, governance. | REUSE (traceability over game contracts) |
| technical-writer | Descriptive docs from code/specs. | REUSE |
| research-agent | External research (Perplexity/Context7/Tavily). | REUSE |
| session-reviewer | Post-session lessons/decisions/follow-ups capture. | REUSE |
| data-engineer | Schemas, migrations, pure-core/effectful-IO boundary. | ADAPT (sim-state boundary) |
| performance-engineer | Benchmarks, regression detection, perf budgets. | ADAPT (perf→frame-budget) |
| implementer | Strict-TDD implementation (failing test→min code→commit). | ADAPT (sim-slice TDD; engine-bound via adapter) |
| test-writer | TDD test suites from behavioral contracts. | ADAPT (sim-BC + replay-regression tests) |
| stub-architect | Compilable stubs for a story's file list. | ADAPT (engine-aware stubs via adapter) |
| e2e-tester | E2E user-journey + browser tests (Playwright/Cypress). | ADAPT (gameplay E2E via adapter capture/replay) |
| demo-recorder | Visual evidence via VHS terminal / Playwright browser. | ADAPT (adapter `capture` + ffmpeg backend) |
| visual-reviewer | Visual regression / mockup fidelity. | ADAPT (game visual targets) |
| ux-designer | UX specs, wireframes, interaction design. | ADAPT (game UI/UX) |
| accessibility-auditor | WCAG AA/AAA audit. | ADAPT (game accessibility contract) |
| security-reviewer | App security review / CWE-CVE triage. | ADAPT (+ server-authority / anti-cheat invariants) |
| **formal-verifier** | Kani proofs, fuzzing, mutation testing, security scan. | **REPLACE** (→ pure-sim hardening scope) |
| **dtu-validator** | Validates DTU behavioral clones vs real services. | **REPLACE** (→ replay-regression validator) |
| **holdout-evaluator** | Evaluates impl vs hidden scenarios (strict asymmetry). | **REPLACE** (→ playtest-evaluator) |

## Top-level workflows (8) + phase sub-workflows (8)

| Workflow | One-line purpose | Disposition |
|---|---|---|
| greenfield.lobster | Full brief→verified-code pipeline (reference path). | ADAPT (swap phase-4/6 + convergence criteria) |
| feature.lobster | Incremental feature delta pipeline (phase-f1..f7). | ADAPT (same seam as greenfield) |
| brownfield.lobster | Ingest existing codebase → recovered spec → onboarding. | REUSE (our current mode) |
| maintenance.lobster | Maintenance-sweep pipeline. | REUSE |
| discovery.lobster | Discovery/market-intel pipeline. | REUSE |
| multi-repo.lobster | Multi-repo health + phase-0 synthesis. | REUSE |
| planning.lobster | Env setup + artifact detection + brief creation/validation. | REUSE |
| code-delivery.lobster | Per-story delivery (stubs→tests→TDD→adversary→PR→merge). | ADAPT (sim-slice TDD; adapter test/replay) |
| phases/phase-0-codebase-ingestion | Codebase ingest sub-workflow. | REUSE |
| phases/phase-1-spec-crystallization | Spec crystallization sub-workflow. | ADAPT (game contract schemas) |
| phases/phase-2-story-decomposition | Story decomposition + waves. | REUSE |
| phases/phase-3-tdd-implementation | TDD implementation sub-workflow. | ADAPT (sim-slice) |
| **phases/phase-4-holdout-evaluation** | Holdout-scenario evaluation. | **REPLACE** (→ playtest-protocol) |
| phases/phase-5-adversarial-refinement | Adversarial refinement loop. | REUSE |
| **phases/phase-6-formal-hardening** | Kani/fuzz/mutants hardening. | **REPLACE** (→ pure-sim hardening only) |
| phases/phase-7-convergence | Convergence gate. | ADAPT (game dimension set) |

## Hook plugins — Rust crates (28)

| Plugin | Purpose | Disposition |
|---|---|---|
| legacy-bash-adapter | Execs underlying `.sh` for non-native hooks. | REUSE |
| worktree-hooks | Worktree create/remove lifecycle. | REUSE |
| update-wave-state-on-merge | Advances wave state on PR merge. | REUSE |
| warn-pending-wave-gate | Warns when wave gate pending. | REUSE |
| track-agent-start / track-agent-stop | Agent dispatch telemetry. | REUSE |
| capture-commit-activity / capture-pr-activity | Git/PR activity telemetry. | REUSE |
| session-start-telemetry / session-end-telemetry / session-learning | Session telemetry + lessons. | REUSE |
| tool-failure-hooks | PostToolUseFailure handling. | REUSE |
| validate-state-structure / validate-dispatch-advance / validate-stable-anchors / validate-index-cite-refresh | STATE.md + index integrity. | REUSE |
| validate-artifact-path | Artifact path-registry enforcement. | REUSE |
| validate-policies-schema | policies.yaml schema validation. | REUSE (game policies) |
| validate-trajectory-tail-cell-completeness | Convergence trajectory tail format. | ADAPT (game dims) |
| pr-manager-completion-guard | Guards PR completion sequence. | REUSE |
| handoff-validator | Agent handoff validation. | REUSE |
| block-ai-attribution | Blocks AI attribution in commits. | REUSE |
| lint-registry-async-invariant | Lints registry async-tier invariants. | REUSE |
| **regression-gate** | Regression gate (test/convergence-coupled). | ADAPT (→ replay-regression + game dims) |
| **validate-per-story-adversary-convergence** | Per-story 3-CLEAN convergence guard. | REUSE (mechanism) / ADAPT (criteria) |
| **validate-burst-log / validate-closes-completeness** | Burst-log + closes-block discipline. | REUSE (neutral discipline) |
| **validate-pr-review-posted** | Guards that a PR review has been posted before merge. | REUSE |

## Bash hooks (47 total) — quality-model-relevant subset

> Validated count: 35 top-level `.sh` in `hooks/`, 11 in `hooks/dim2-gates/`, 1 in `hooks/lib/` = 47.
> The `dim2-gates/` scripts (active-branches-sha-currency, banner-wc-l, block-label-canonical-form,
> decision-log-monotonic-rows, dim1-file-count-arithmetic, dim7-dispatched-count-sweep, freshness-literal-stdout,
> layer-ordinal-dual-direction, meta-level-ack-grep, propagation-completeness, trajectory-tail-cell-grep)
> are convergence-dimension 2 gate validators — **ADAPT** (game dimension set).
> Also untracked above: `validate-index-self-reference.sh` and `validate-changelog-monotonicity.sh` (both REUSE).

| Hook | Purpose | Disposition |
|---|---|---|
| **red-gate.sh** | TDD red-before-green gate (opt-in strict; engine-agnostic). | REUSE (sim slice; defaults off) |
| **validate-red-ratio.sh** | Red/green test-ratio enforcement. | ADAPT (sim slice) |
| **protect-bc.sh / protect-vp.sh** | Protect BC/VP files from unauthorized edits. | REPLACE (→ sim-BC + design-intent guards) |
| **validate-bc-title.sh / validate-vp-consistency.sh / validate-story-bc-sync.sh** | BC/VP schema + sync integrity. | REPLACE (→ game contract integrity) |
| **purity-check.sh** | Warn-only pure-core/effectful-IO boundary. | ADAPT (sim slice only) |
| convergence-tracker.sh | Convergence tracking (bash). | ADAPT (game dims) |
| validate-novelty-assessment.sh | Adversarial novelty-decay format. | REUSE |
| validate-wave-gate-completeness.sh / validate-wave-gate-prerequisite.sh | Wave gate integrity. | REUSE |
| validate-template-compliance.sh / validate-table-cell-count.sh / validate-count-propagation.sh / validate-subsystem-names.sh / validate-anchor-capabilities-union.sh | Template + cross-doc structural integrity. | REUSE (game templates) |
| validate-demo-evidence-story-scoped.sh | Demo-evidence scoping. | ADAPT (gameplay capture) |
| check-factory-commit.sh / factory-branch-guard.sh / factory-path-root / state-{size,pin-freshness,index-status-coherence} | Factory git + STATE governance. | REUSE |
| destructive-command-guard.sh / protect-secrets.sh / verify-git-push.sh / changelog-monotonicity / input-hash / finding-format / pr-description / pr-merge-prerequisites | Safety + PR + governance guards. | REUSE |
| brownfield-discipline.sh | Brownfield ingest discipline. | REUSE |
| update-cargo-audit-cache.sh | Rust cargo-audit cache. | ADAPT (per-engine toolchain) |

## Skill groups (121 total) — disposition by cluster

| Cluster | Example skills | Disposition |
|---|---|---|
| Planning / specs | create-brief, create-prd, create-domain-spec, create-architecture, create-adr, guided-brief-creation, validate-brief | REUSE (schemas ADAPT) |
| Story / wave | decompose-stories, create-story, wave-scheduling, wave-status, wave-gate, implementation-readiness | REUSE |
| Orchestration / state | run-phase, next-step, mode-decision-guide, state-update, state-burst, compact-state, recover-state, check-state-health, register-artifact, relocate-artifact | REUSE |
| PR / delivery / release | code-delivery, deliver-story, pr-create, pr-review-triage, fix-pr-delivery, release, worktree-manage, factory-worktree-health | REUSE |
| Adversarial / consistency / convergence | adversarial-review, consistency-validation, convergence-check, convergence-tracking | REUSE (convergence ADAPT dims) |
| Research / ingest / extraction | research, planning-research, brownfield-ingest, phase-0-codebase-ingestion, disposition-pass, semport-analyze, multi-repo-phase-0-synthesis | REUSE |
| Model / obs / health | model-routing, factory-obs, factory-dashboard, factory-health, onboard-observability, claude-telemetry | REUSE |
| **VSDD quality model** | holdout-eval, dtu-creation, dtu-validate, formal-verify, perf-check, phase-4-holdout-evaluation, phase-6-formal-hardening, toolchain-provisioning, purity-related | **REPLACE** (→ playtest, replay-regression, pure-sim hardening, frame-budget, engine toolchain) |
| TDD | phase-3-tdd-implementation, post-feature-validation | ADAPT (sim slice) |
| UI/UX/visual | design-system-bootstrap, multi-variant-design, ux-heuristic-evaluation, ui-quality-gate, ui-completeness-check, responsive-validation, visual-companion, storybook-mcp-integration, demo-recording, record-demo | ADAPT (game visual/UX + adapter capture) |
| Spec governance | spec-drift, spec-versioning, traceability-extension, validate-consistency, validate-template-compliance, conform-to-template, design-drift-detection | REUSE |
| SDK / repo | sdk-generation, repo-initialization, scaffold-claude-md, setup-env, factory-cycles-bootstrap, policy-add, policy-registry, track-debt | REUSE |

## State Checkpoint
```yaml
pass: component-inventory
status: complete
agents: 35
skills: 121
workflows: 8 + 8 phases
hook_plugins: 28
bash_hooks: 47  # 35 top-level + 11 dim2-gates/ + 1 lib/block.sh
hooks_registry_entries: 63  # 35 legacy-bash-adapter + 28 native-WASM
templates: 136
timestamp: 2026-06-07T00:00:00Z
source_repo: vsdd-factory@82163b7
validated_by: extraction-validator 2026-06-07
```
