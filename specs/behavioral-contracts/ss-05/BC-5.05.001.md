---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/engineering-disciplines.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-04
capability: CAP-005
priority: P0
lifecycle_status: active
introduced: v1.0.0
modified:
  - v1.2: F39-02 fix — EC-001 and test vector re-pointed from "E-ENG-001 variant" (logic-presentation coupling — inapplicable when no imports present) to E-ENG-003 (UnclassifiedModule, dedicated registered code).
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-5.05.001: Code Module Satisfies Gameplay-Logic / Pure-Sim Separation Contract

## Description

Every code module produced by engineering agents must satisfy the gameplay-logic / pure-sim
separation contract: gameplay simulation logic (economy, damage, inventory, AI behavior,
state machines) must not import or depend on presentation-layer symbols (rendering, audio
playback, UI framework, windowing). This separation is the precondition for headless unit
testing of the simulation slice, the TDD Red Gate (BC-5.05.002), and deterministic replay
regression (CAP-003). The separation is checked by import lint on every CI run.

## Preconditions

1. A code module file exists at a declared path in the factory source tree.
2. The module has been assigned a `module_type` in the factory manifest:
   one of `"pure-sim"`, `"engine-bound"`, `"infrastructure"`, `"test"`.
3. A `presentation_symbols_blocklist` registry exists, listing all presentation-layer
   symbol namespaces by engine (e.g., for Bevy: `bevy_render::`, `bevy_audio::`,
   `bevy_winit::`, `bevy_ui::` as presentation; `bevy_ecs::` is allowed in pure-sim).
4. Import lint tooling (language-appropriate static analysis: `cargo deny` + custom lint
   rule for Rust; ASM-equivalent for other languages) is available in CI.

## Postconditions

1. Import lint runs on all `module_type: "pure-sim"` modules.
2. For each pure-sim module, the lint checks all import statements (Rust: `use` statements;
   other languages: equivalent import mechanism). Any import that matches a symbol in
   `presentation_symbols_blocklist` for the active engine adapter raises E-ENG-001.
3. If any E-ENG-001 is raised: the module fails the separation check; the engineering
   agent is notified; the build does NOT proceed until the violation is resolved.
4. If lint passes (zero violations): a `module-separation-report` with status `"pass"` is
   emitted for the module.
5. `module_type: "engine-bound"` modules are NOT subject to separation lint (they are
   expected to import engine symbols). They are however excluded from TDD Red Gate pure-sim
   test requirements (BC-5.05.002).
6. Cross-module dependency: a `pure-sim` module that depends on an `engine-bound` module
   is flagged as a violation (indirect coupling). Dependency tree lint depth: 2 levels.

## Invariants

1. (DI-008 analog for code) The pure-sim slice is the factory's verifiable spine. Its
   correctness depends on isolation from presentation. Any coupling destroys the ability
   to run headless unit tests.
2. The `presentation_symbols_blocklist` is maintained per engine adapter. When a new
   engine adapter is onboarded, its presentation symbol namespaces are added to the
   registry before any code modules are linted for that engine.
3. The lint result for a module is deterministic: same module + same blocklist → same
   result on any runner.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | A module type is not declared in the factory manifest | Module type defaults to "unclassified"; E-ENG-003 raised: module requires classification before lint |
| EC-002 | Pure-sim module conditionally imports a presentation symbol under a feature flag | Lint detects the import even if feature flag is off; the import is present in the AST; E-ENG-001 raised |
| EC-003 | New engine adapter onboarded; presentation_symbols_blocklist not updated yet | Lint cannot run for that engine's modules; modules flagged as "lint-blocked pending blocklist update"; build blocked for pure-sim modules of that engine |
| EC-004 | Pure-sim module imports another pure-sim module that happens to re-export a presentation symbol | Indirect coupling; lint at depth-2 detects the re-export; E-ENG-001 raised on the re-exporting module |
| EC-005 | Module has zero imports (standalone pure functions) | Lint passes trivially; module-separation-report: pass |
| EC-006 | `engine-bound` module incorrectly classified as `pure-sim` in manifest | Lint runs and likely raises E-ENG-001 for legitimate engine imports; engineering agent must reclassify the module |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Pure-sim Rust module with only `use std::collections::HashMap` and game-internal pure-sim crates | module-separation-report: pass; build proceeds | happy-path |
| Pure-sim module with `use bevy_render::prelude::*` (Bevy engine) | E-ENG-001: presentation symbol bevy_render found in pure-sim module | error |
| Engine-bound module with `use bevy_render::prelude::*` | No lint run; engine-bound excluded; module accepted | edge-case |
| Module with no type declared in manifest | E-ENG-003: module unclassified; classification required | error |
| Pure-sim module importing another pure-sim module that re-exports bevy_audio | E-ENG-001: indirect coupling detected at depth-2 | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-5.05.001 | For all pure-sim modules, any import matching the blocklist always raises E-ENG-001 | proptest: inject blocklisted imports; assert error rate = 100% |
| VP-5.05.002 | Engine-bound modules are never subject to separation lint | test: engine-bound module with known presentation imports; assert lint not run |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 |
| Capability Anchor Justification | CAP-005 ("Multi-Discipline Game Artifact Production") per capabilities.md §CAP-005 — code modules are a primary artifact class of CAP-005 ("generates EVERYTHING a game needs — code... artifacts"); this BC defines the machine-checkable architectural separation contract for code artifacts. |
| L2 Domain Invariants | DI-008 (engine-neutral spec layer; analog: pure-sim code isolation) |
| Architecture Module | SS-04 — import lint gate; module type registry; presentation symbol blocklist |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-5.05.002 — composes with (TDD Red Gate applies to pure-sim modules passing this BC)

## Architecture Anchors

- `architecture/SS-04-engineering-pipeline.md` — import lint, module classification

## Story Anchor

S-TBD — Pure-Sim Separation Lint Gate

## VP Anchors

- VP-5.05.001 — blocklisted import detection
- VP-5.05.002 — engine-bound exclusion
