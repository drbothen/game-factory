---
document_type: adr
level: L4
adr_id: "ADR-0005"
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
  - .factory/planning/design/extraction-boundary.md
  - .factory/planning/design/architecture.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0005 — Config/Content Extraction Seam (Spine vs Quality-Model)

**Status:** Draft
**Date:** 2026-06-08
**Driver:** `extraction-boundary-validated.md` §2; `architecture.md` §The split that makes Option C coherent

## Context

game-factory is built as a sibling of vsdd-factory (Option C), not a fork (Option B)
or a mode (Option A). This requires a precise, stable boundary between what is extracted
from vsdd-factory and what is replaced. Phase-0 codebase analysis (`extraction-boundary-
validated.md`) established that the boundary is at the **content/configuration level,
not the code level**, with four discrete seam interfaces. This decision records that
seam as an architectural constraint.

## Decision

The extraction seam is defined by **four declarative interfaces** at which vsdd-factory's
domain-neutral machinery ends and game-factory's quality model begins:

1. **`hooks-registry.toml` row set** — The dispatcher loads whatever guard plugins the
   registry lists. game-factory ships a game guard set (sim-BC integrity, replay-regression,
   asset-completeness, playtest-evidence, ethics-contract) in place of vsdd-factory's BC/VP
   guard set. The TOML schema (schema_version 2; name/event/tier/timeout/capabilities/
   on-error) is unchanged. **No dispatcher code change.**

2. **Lobster phase sub-workflow files** — The pipeline scaffold (repo-init → worktree-health
   → state-init → planning → spec → consistency gate → adversarial loop → wave delivery →
   convergence → release) is extracted verbatim. Two phase files are replaced: `phase-4-
   holdout-evaluation.lobster` → `phase-4-playtest-protocol.lobster`; `phase-6-formal-
   hardening.lobster` → `phase-6-sim-hardening.lobster`. The DTU/gene-transfusion
   assessment steps in phase-1 are replaced with replay-regression-harness assessment.

3. **Agent routing table rows** — The routing mechanism in CLAUDE.md is extracted intact.
   Approximately 6 rows (formal-verifier, dtu-validator, holdout-evaluator, product-owner
   BC/VP duties) are replaced with game roles. All neutral specialist agent rows are
   unchanged.

4. **Spec template + index data-model** — BC-INDEX/VP-INDEX/holdout/DTU/formal templates
   are the vsdd quality regime's data model. These are replaced with game contract templates
   (sim-BC, design-intent-contract, replay-regression-contract, asset-provenance-sidecar).
   The index *mechanism* (catalog + cross-doc consistency hooks) is extracted.

## Rationale

`extraction-boundary-validated.md` confirms (§3.5): ~70% reusable spine validated at
code level (~85% of files are REUSE or ADAPT-neutral). The Rust runtime (~80k LOC),
lobster DSL parser, orchestrator, and state/worktree/PR/wave/adversarial machinery cross
the boundary untouched. The "~30% replace" is the quality-model *content* concentrated
in discrete, named, declarative units — not interleaved with the runtime. This makes
the extraction a mechanical swap-out, not surgical code untangling.

**Key corrections from Phase-0 analysis:**
- TDD red-gate is **REUSE**, not REPLACE (red-gate.sh is TDD-generic, opt-in, not BC-coupled).
- Convergence is **ADAPT (split)**: the loop engine + 3-CLEAN streak is extracted;
  only the dimension list is replaced.

## Consequences

- The seam is stable: adding a new game contract type (e.g., new convergence dimension)
  does NOT require changes to the Rust runtime or lobster DSL.
- The seam is auditable: the four interface points are the complete list; any vsdd
  content that leaks through these four points and is not replaced constitutes a
  maintenance obligation rather than a defect.
- **DI-001 (factory core never names an engine) is enforced by the registry row swap**:
  game guard plugins may reference engine adapter BCs; the dispatcher never does.

## Alternatives Rejected

- **Hard fork (Option B).** The boundary would be invisible (no seam); the ~80k LOC
  Rust runtime would be duplicated, forked, and would diverge.
- **Game mode inside vsdd-factory (Option A).** The seam would be a runtime conditional,
  not a content boundary; the two quality models (formal verification vs sim-BC/playtest)
  would be interleaved in the same codebase.
