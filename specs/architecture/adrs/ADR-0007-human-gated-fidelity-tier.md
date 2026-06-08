---
document_type: adr
level: L4
adr_id: "ADR-0007"
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
traces_to: ARCH-INDEX.md
supersedes: []
inputs:
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md (§5A, §2 v2.0 change summary)
  - .factory/specs/domain-spec/invariants.md (DI-006)
  - .factory/specs/product-brief.md (§HUMAN-GATED external steps, §Constraints)
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# ADR-0007 — human-gated as a First-Class Fidelity Tier

**Status:** Draft
**Date:** 2026-06-08
**Driver:** AAA-RECONCILIATION §5A; product-brief §HUMAN-GATED external steps; DI-006

## Context

The engine adapter protocol defines fidelity grades: `full` / `partial` / `none`.
When the factory reaches a capability boundary where the *automatable prefix* is
complete but the *terminal step* is a legally or operationally required human act
(console cert sign-off, store publish/pricing, SAG-AFTRA/likeness consent signatures,
XR comfort-certification, paid-UGC vetting, live esports ops, ratings submission,
attorney legal opinion), the three existing grades do not model this accurately.
`none` implies the factory cannot help at all; `partial` implies automated partial
progress without a human handoff signal. Neither is correct.

The v2.0 AAA-RECONCILIATION introduced `human-gated` as a new fidelity value for this
case. This ADR records that decision as a formal architecture constraint.

## Decision

`human-gated` is a **first-class fidelity value** in the adapter protocol alongside
`full`, `partial`, and `none`. Its semantics are:

> The factory has completed all work it is capable of automating (packaging, validation,
> upload, pre-flight checking). A single checklisted human task is now required and has
> been surfaced. The factory does NOT attempt to complete this task autonomously.
> Suppressing or silently skipping this task is a hook-detectable defect (DI-006).

`human-gated` applies to these terminal steps:

| Seam | human-gated terminal step |
|------|--------------------------|
| engine-adapter | N/A (no human-gated engine capabilities) |
| distribution-adapter | Console cert sign-off; store publish / pricing; PSN/Nintendo NDA platform setup |
| asset-adapter | SAG-AFTRA / likeness consent signatures (when `likeness_consent_ref != null`) |
| xr-adapter | XR comfort-certification (requires physical headset + human vestibular system) |
| compliance pipeline | Ratings submission terminal sign-off; attorney legal-opinion sign-off |
| UGC distribution | Paid-UGC vetting (DMCA safe-harbor erosion risk) |
| playtest protocol | Playtest satisfaction human sign-off (DI-007 — never a fidelity grade, but structurally identical) |

## Rationale

1. **Honesty principle.** The factory explicitly does not pretend to automate what
   it cannot. `human-gated` is the honest signal, analogous to `replay: none →
   human playtest evidence` in the replay dimension. Pretending these steps are
   `partial` (implying they could become `full`) misrepresents the architecture.
2. **Hook-enforceability.** A `human-gated` task that has been completed
   autonomously (or suppressed without acknowledgment) is a defect the hook chain
   can detect. A `partial` boundary cannot be hooked for this signal.
3. **Convergence integration.** `human-gated` tasks surface as pending items in
   the convergence tracking engine (SS-06). A dimension with an outstanding
   `human-gated` task is blocked until the task is checked off by a human principal.
   This is structurally parallel to how `D-PLAY` (playtest satisfaction) is always
   a human gate.
4. **Legal/regulatory alignment.** Console cert sign-off, SAG-AFTRA consent,
   and XR comfort-cert are not automatable by external constraint — they require
   a human signature or physical human presence. Encoding this as an architecture
   fidelity value makes the constraint explicit and machine-enforceable.

## Fidelity Grade Full Table (post ADR-0007)

| Grade | Meaning | Hook behavior |
|-------|---------|---------------|
| `full` | Capability fully automated, verified by conformance | Proceeds without human intervention |
| `partial` | Capability automated with declared limitations | Proceeds with degraded convergence signal |
| `none` | Capability not implemented by this adapter | Returns `CapabilityUnsupported`; pipeline degrades gracefully |
| `human-gated` | Automatable prefix complete; checklisted human task surfaced | Blocks progression until human acknowledgment recorded |

## Consequences

- The conformance suite (CAP-002) must validate `human-gated` capabilities: the
  adapter must surface the correct checklist item and must NOT complete the terminal
  step autonomously. DTU-07 (human-gated task surfacing validator) tests this path.
- The distribution adapter manifest declares distribution targets with `human-gated`
  where appropriate; the core reads this and routes accordingly.
- `human-gated` is NOT a creative quality gate. Pure-maximal asset generation (CAP-004)
  is lights-out; creative finishing is never `human-gated`. Only external, third-party-
  required human acts receive this grade.
- The playtest protocol (SS-07) uses the same semantics structurally (automatable
  prefix complete; human sign-off required) but is governed by DI-007 and CAP-008
  rather than the adapter fidelity model.

## Alternatives Rejected

- **Model human acts as `partial`** — Inaccurate. `partial` implies automation
  could in principle be improved to `full`. Human acts like console cert sign-off
  cannot ever become `full` — they are structurally human by regulatory design.
- **Out-of-band tracking (not a fidelity grade)** — Loses hook-enforceability and
  convergence integration. Human tasks tracked outside the fidelity model are easy
  to suppress accidentally.
