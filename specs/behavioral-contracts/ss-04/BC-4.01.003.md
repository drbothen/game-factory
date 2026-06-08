---
document_type: behavioral-contract
level: L3
id: BC-4.01.003
origin: greenfield
subsystem: SS-TBD
capability: CAP-004
priority: P0
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.01.003: ToS-Excluded Backends (OpenArt, Rosebud) Are Never Selected

## Description

Certain asset generation backends are excluded from the factory by policy due to Terms of
Service violations, known licensing incompatibilities, or explicit scope exclusion. The
factory maintains a static, version-controlled `tos-exclusion-list` that names specific
`adapter_id` values. The routing policy must check every candidate adapter against this
list before scoring, and excluded adapters are silently removed from the candidate set
— they are never dispatched to, regardless of preference score or availability.

This BC covers the general ToS-exclusion mechanism. BC-4.01.004 covers the specialized
music-litigation exclusion. OpenArt and Rosebud are the currently ratified exclusions per
the product brief scope decisions.

## Preconditions

1. The factory has a version-controlled `tos-exclusion-list` that is loaded at orchestrator
   startup and cannot be overridden at runtime.
2. The orchestrator is executing backend selection for a GenerationRequest.
3. The `tos-exclusion-list` contains at least the entries: `openart`, `rosebud`.

## Behavior

1. During candidate filtering (before preference scoring per BC-4.01.002), the orchestrator
   reads the `tos-exclusion-list`.
2. For each adapter in the pre-candidate set, the orchestrator checks whether the adapter's
   `adapter_id` (case-insensitive prefix match on the canonical exclusion identifier) appears
   on the exclusion list.
3. **Happy path:** The candidate has no `adapter_id` prefix matching any exclusion entry.
   - Adapter remains in the candidate set; proceeds to preference scoring.
4. **Exclusion path:** The candidate's `adapter_id` matches an exclusion entry.
   - Adapter is silently removed from the candidate set.
   - A `WARN`-level audit log entry is written: "adapter '<id>' excluded from selection
     (tos-exclusion-list match: '<exclusion_entry>')".
   - No error is returned to the caller; the exclusion is transparent to the requester.
5. **If all candidates are excluded:** Proceeds to E-AAG-010 (no eligible adapter) per
   BC-4.01.002's failure path A.

## Postconditions

- No dispatched request has `selected_backend` matching any entry on the `tos-exclusion-list`.
- Every exclusion event is recorded in the audit log with timestamp, `adapter_id`,
  `exclusion_entry`, and `request_id`.
- The `tos-exclusion-list` itself is never mutated at runtime; changes require a factory
  configuration deploy.

## Invariants

- The `tos-exclusion-list` is an append-only registry; removing an entry requires an
  explicit configuration change with a documented justification, not a runtime override.
- `openart` and `rosebud` entries are permanent fixtures of the exclusion list and may not
  be removed without a human-authorized policy decision recorded in the ADR log.
- The exclusion check runs on every dispatch, even in test environments (no bypass mode).

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | An adapter registers with `adapter_id: "openart-v2"` (prefixed variant) | Excluded; prefix match `openart` catches it |
| EC-002 | `adapter_id: "ROSEBUD"` (uppercase) | Excluded; case-insensitive match |
| EC-003 | A tool named `"openartisan"` registers (false-positive concern) | NOT excluded; prefix match must be `openart` followed by non-alphanumeric separator or end-of-string (e.g. `openart`, `openart-*`, not `openartisan`) |
| EC-004 | Test run with `--integration-test` flag tries to dispatch to an excluded backend to verify blocking | Still excluded; no bypass mode; test must assert the E-AAG-010 error |
| EC-005 | New policy decision adds `"novaai"` to exclusion list; factory re-deployed | All subsequent requests automatically exclude `novaai`; no code change needed |
| EC-006 | `tos-exclusion-list` file is missing or unparseable at startup | Orchestrator startup FAILS with a fatal error; no generation dispatched until the list is restored |

## Canonical Test Vectors

| Candidate `adapter_id` | On exclusion list? | Expected result |
|------------------------|--------------------|----------------|
| `"openart"` | yes | Excluded; audit log written |
| `"openart-2026"` | prefix match | Excluded; audit log written |
| `"rosebud"` | yes | Excluded; audit log written |
| `"ROSEBUD"` | yes (case-insensitive) | Excluded; audit log written |
| `"openartisan"` | no (not a prefix match boundary) | Not excluded; proceeds to preference scoring |
| `"tripo3d"` | no | Not excluded |
| `"stable-audio"` | no | Not excluded |

## Verification Properties

- **VP-4.01.003-a:** `∀ dispatch d: d.selected_backend.adapter_id ∉ tos_exclusion_list`
- **VP-4.01.003-b:** `∀ exclusion_event e: e ∈ audit_log ∧ e.adapter_id ∈ tos_exclusion_list`
- **VP-4.01.003-c:** `tos_exclusion_list` is immutable at runtime; no runtime mutation is possible

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — this BC ensures that the "pure-maximal" generation policy cannot be used to route to legally or policy-excluded backends. Without this gate, the factory could inadvertently generate assets from tools that are out of scope by decision. |
| L2 Invariants | None directly (DI-009 covers music specifically; this BC covers the general ToS mechanism) |
| L2 Processes | PROC-003 §Stage 2 (Backend Selection) |
| L2 Risks | R-002 (indemnification gap), R-016 (confabulation meta-risk — static list prevents runtime policy drift) |
| L2 Failure Modes | FM-004 (upstream) |

## Related BCs

- **BC-4.01.002** (composes with): this exclusion is applied in step 1 of the routing algorithm
- **BC-4.01.004** (sibling): specialized exclusion for litigation-exposed music generators

## Architecture Anchors

- Product brief §Constraints: "ToS-excluded tools — Suno/Udio (litigation), Riot Vanguard (not
  licensable), kernel AC drivers blocked by policy"
- RECONCILIATION §10 "Explicitly out of scope (never)": AI music using uncleared generators

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
