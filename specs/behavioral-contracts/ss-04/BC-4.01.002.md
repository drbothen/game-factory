---
document_type: behavioral-contract
level: L3
id: BC-4.01.002
origin: greenfield
subsystem: SS-TBD
capability: CAP-004
priority: P0
lifecycle_status: active
traces_to: CAP-004
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# BC-4.01.002: Orchestrator Routes Generation Requests Following Declared Preference Ordering

## Description

When the asset-generation orchestrator selects a backend adapter for a GenerationRequest,
it must follow the canonical preference ordering: `cloud-api` > `headless-cli` >
`mcp-headless` > `mcp-gui` > `saas-ui`. Adapters with `backend_class: desktop-gui` are
never selected by the automated orchestrator. The selection algorithm must use the
highest-preference available adapter that (a) supports the required asset class,
(b) is not in the blocked-list, and (c) meets the risk-tier requirement.

## Preconditions

1. A GenerationRequest has been validated against the schema (BC-4.02.001 passed).
2. At least one active adapter in the registry declares the required `asset_class`.
3. The orchestrator has access to the adapter registry and the blocked-backends list.
4. No adapter with `backend_class: desktop-gui` is present in the candidate set (they are
   pre-filtered before preference scoring).

## Behavior

1. The orchestrator filters the registry to all adapters supporting the request's
   `asset_class` AND not on the blocked-backends list (see BC-4.01.003, BC-4.01.004).
2. The orchestrator removes any adapter with `backend_class: desktop-gui` from the
   candidate set.
3. The orchestrator assigns a preference score to each remaining candidate:
   - `cloud-api` → score 5 (highest)
   - `headless-cli` → score 4
   - `mcp-headless` → score 3
   - `mcp-gui` → score 2
   - `saas-ui` → score 1
4. **Happy path:** At least one valid candidate remains.
   - The orchestrator selects the candidate with the highest preference score.
   - On tie (same `backend_class`, multiple adapters): secondary sort by
     `indemnification_tier` (enterprise > adobe_firefly > other > none); then by
     `adapter_id` alphabetically for determinism.
   - The selected adapter's `adapter_id` is recorded in the GenerationRequest's
     `selected_backend` field before dispatch.
5. **Failure path A:** All candidates are blocked or `desktop-gui`.
   - Dispatch fails with error `E-AAG-010` ("no eligible adapter for asset_class
     '<class>' after exclusions").
   - The GenerationRequest is moved to `status: blocked` with the error recorded.
6. **Failure path B:** The candidate set is empty (no adapter supports the asset_class).
   - Dispatch fails with error `E-AAG-011` ("no adapter registered for asset_class
     '<class>'").
   - The GenerationRequest is moved to `status: blocked`.

## Postconditions

- **Happy path:** The GenerationRequest has `selected_backend` set to the highest-preference
  eligible adapter's `adapter_id` before any network/process call is made. The selection
  decision is logged with the full candidate list and scores.
- **Failure path:** The GenerationRequest has `status: blocked` and an error record. No
  network/process call was made. The error is surfaced to the producer role.

## Invariants

- `desktop-gui` adapters are never selected by the automated orchestrator under any
  circumstances, even if they are the only registered adapter for an asset class.
- The preference ordering is a constant of the factory; it does not vary per-project or
  per-request.
- The selection decision (adapter_id chosen, score, full candidate list) is always logged
  for audit traceability.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Only a `desktop-gui` adapter is registered for the asset class | Fail with E-AAG-010; never dispatch to desktop-gui |
| EC-002 | Two `cloud-api` adapters are eligible; one has `indemnification_tier: adobe_firefly`, one `none` | Select adobe_firefly tier as tiebreaker |
| EC-003 | Three adapters eligible: one `headless-cli` and two `cloud-api` | Select one of the `cloud-api` adapters (tiebreaker: indemnification_tier) |
| EC-004 | Adapter preference score computed but adapter is on blocked-backends list | Adapter excluded from candidates before scoring; not selected |
| EC-005 | GenerationRequest has `tool_preference` override from art-direction spec | Override is applied as an additional filter; if overridden adapter is blocked, override is ignored and default preference applies; logged as "override_ignored: blocked" |
| EC-006 | All `cloud-api` adapters are rate-limited (transient error) | Retry with same adapter first; on max retries fall back to next-highest-preference adapter; log fallback event |

## Canonical Test Vectors

| Candidate adapters | Expected selection |
|-------------------|--------------------|
| `[{class: cloud-api, indemnification: none}]` | That adapter |
| `[{class: cloud-api, indemnification: adobe_firefly}, {class: headless-cli, indemnification: none}]` | `cloud-api` adapter |
| `[{class: desktop-gui}]` | E-AAG-010 (none eligible) |
| `[{class: mcp-headless}, {class: cloud-api, blocked: true}]` | `mcp-headless` adapter (cloud-api blocked) |
| `[{class: cloud-api, indemnification: enterprise}, {class: cloud-api, indemnification: adobe_firefly}]` | enterprise tiebreaker wins |
| `[]` | E-AAG-011 (no adapter for class) |

## Verification Properties

- **VP-4.01.002-a:** `∀ dispatch: dispatch.selected_backend.backend_class ≠ "desktop-gui"`
- **VP-4.01.002-b:** `∀ dispatch d1, d2 with same candidate set: d1.selected_backend = d2.selected_backend` (determinism)
- **VP-4.01.002-c:** `∀ dispatch: dispatch.candidate_list ∩ blocked_backends = ∅`

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 |
| Capability Anchor Justification | CAP-004 ("Pure-Maximal Asset Generation with Auto-Provenance") per capabilities.md §CAP-004 — this BC governs the selection policy that determines which backend executes asset generation, the core operation of CAP-004. Without a correct preference ordering, the pipeline can silently route to hostile (GUI-only) or legally-exposed backends. |
| L2 Invariants | DI-009 (partial — Suno/Udio blocking is enforced via BC-4.01.004; this BC enforces the routing algorithm itself) |
| L2 Processes | PROC-003 §Stage 2 (Backend Selection) |
| L2 Risks | R-002 (indemnification gap — tiebreaker favors indemnified providers), R-005 (quality gap — preference ordering channels Tier-1 tools to highest preference) |
| L2 Failure Modes | FM-004 (upstream — if wrong backend is selected provenance may be incomplete) |

## Related BCs

- **BC-4.01.001** (depends on): backend_class taxonomy is validated before routing
- **BC-4.01.003** (composes with): blocked-backends filter applied before preference scoring
- **BC-4.01.004** (composes with): music-route block applied before preference scoring
- **BC-4.02.001** (depends on): GenerationRequest schema valid before dispatch

## Architecture Anchors

- Asset-adapter preference ordering: prd-supplements/prd-cap-004.md §8.1
- RECONCILIATION §5A (asset-adapter backend_class taxonomy)
- RECONCILIATION §9 (autonomous generation pipeline routing logic)

## Story Anchor

(Filled after story decomposition)

## VP Anchors

(Filled after VP creation)
