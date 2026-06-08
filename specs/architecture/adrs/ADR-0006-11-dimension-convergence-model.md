---
document_type: adr
level: L4
adr_id: "ADR-0006"
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md (§7, §12)
  - .factory/planning/design/architecture.md (§Convergence dimensions)
  - .factory/specs/domain-spec/capabilities.md (CAP-007)
  - .factory/phase-0-ingestion/extraction-boundary-validated.md (§3.2)
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0006 — 11-Dimension Convergence Model

**Status:** Draft
**Date:** 2026-06-08
**Driver:** AAA-RECONCILIATION §7; architecture.md §Convergence dimensions; CAP-007

## Context

vsdd-factory uses a 7-dimension convergence model (spec / tests / implementation /
verification / visual / perf / docs). This model covers software quality but is
insufficient for game production, which has orthogonal quality axes (playtest
satisfaction, asset completeness, cert/distribution readiness, monetization ethics,
compliance, security invariants). The convergence loop engine itself (novelty-decay,
3-CLEAN streak, dimension declarations) is sound and extracted; only the dimension
definitions change.

## Decision

game-factory uses an **11-dimension convergence model** replacing the vsdd 7-dim:

| Dim | ID | Name | Automated? | Fallback on degradation |
|-----|----|------|------------|------------------------|
| 1 | D-SIM | Sim / Spec | Yes (TDD Red Gate + sim-BC) | Degraded: partial-pass semantics |
| 2 | D-REPLAY | Tests / Replay | Yes (replay harness, tier-dependent) | Degraded: playtest evidence if `replay: none` |
| 3 | D-IMPL | Implementation | Yes (CI, wave integration gate) | — |
| 4 | D-ASSET | Asset Completeness | Yes (quality gate + provenance check) | Degraded: placeholder assets with documented gaps |
| 5 | D-PLAY | Playtest / Feel | **Human gate** (never automated) | N/A — non-substitutable |
| 6 | D-CERT | Cert-Preflight + Distribution-Readiness | Yes (machine-checkable subset) + Human gate (cert sign-off) | Degraded: human-gated task surfaced |
| 7 | D-PERF | Perf Budget (frame-time, not throughput) | Yes (CI profiler gate) | Degraded: manual profiler evidence |
| 8 | D-PROV | Provenance / Legal + Compliance | Yes (sidecar completeness + IARC auto-fill) + Human gate (ratings sign-off) | Degraded: human legal review flag |
| 9 | D-DOCS | Docs | Yes (structural completeness) | — |
| 10 | D-ETHICS | Monetization Ethics | Yes (ethics contract schema) + Adversarial review | Non-substitutable adversarial review gate |
| 11 | D-SEC | Security Invariants | Yes (server-authority-invariant suite + CWE-602 checks) | Degraded: manual security review |

**Convergence loop mechanics (ADAPTED from vsdd, extracted verbatim):**
- Novelty decay assessment per dimension
- 3-CLEAN streak required for convergence
- Any dimension declaring `degraded` must document the explicit fallback and human acknowledgment
- Release is blocked until all required dimensions are green or explicitly degraded-and-acknowledged

**Dimension declare-and-degrade rule.** Each dimension is wired to engine/adapter fidelity
declarations. If `replay: none` is declared by the adapter, D-REPLAY degrades automatically
to playtest evidence (no pipeline failure — honest degradation, same model as
`capture: ProfileUnavailable`). The core never *assumes* a capability.

## Rationale

- vsdd's 7 dims omit game-specific axes that are load-bearing for AAA ship decisions:
  **D-PLAY** (fun/feel cannot be automated — DI-007), **D-ASSET** (art/audio are
  first-class production outputs, not code), **D-CERT** (55-80% of cert is machine-
  checkable; the remainder is a declared human gate), **D-ETHICS** (monetization
  ethics is an adversarial-review gate — DI-005), **D-SEC** (CWE-602 server-authority
  invariant suite applies to online games).
- Adding these as separate convergence dimensions (rather than sub-criteria within
  existing dims) ensures each has its own blocking gate and degradation protocol.
- **D-PERF replaces vsdd throughput perf.** Games care about frame-time (CPU/GPU ms,
  1%/0.1%-low, thermal limits), not request throughput.
- The 11-dim model generalizes to every genre. Inactive genre lanes (esports, modding)
  do not add new dimensions; their quality signals flow through existing dimensions.

## Consequences

- SS-06 (Convergence Tracking Engine, CAP-007) owns the 11 BC evaluations (one per
  dimension) plus the release-gating rule.
- The extraction-boundary seam (ADR-0005) replaces the 7-dim definition in the
  convergence skill while retaining the loop engine.
- Any future convergence dimension addition is a BC change in SS-06 and a registry-row
  addition — no core architecture change.

## Alternatives Rejected

- **Extend vsdd 7-dim with game sub-criteria.** Loses independent blocking granularity
  per game axis; ethics and playtest satisfaction would be sub-criteria of existing dims
  rather than first-class gates.
- **Per-genre convergence model.** Unnecessary complexity; the 11 dims are genre-universal.
  Genre-specific quality signals (ranking-system math, mod determinism) flow through
  existing dims (D-SIM, D-REPLAY) rather than requiring new dims.
