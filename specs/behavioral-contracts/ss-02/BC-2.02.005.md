---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/failure-modes.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-002
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-2.02.005: Conformance Re-Run on Engine Minor Release (Anti-Drift Scheduled Check)

## Description

When an engine releases a new minor or patch version, the factory must schedule and
complete a conformance re-run for all accepted adapters that target that engine version,
before those adapters are used in production against the new engine version. This
is the Semport-analog anti-drift mechanism that addresses FM-001: adapter capability drift
after an engine update. The re-run produces a new acceptance record (or rejection) for the
new engine version; the old acceptance record remains valid for the old engine version.

## Preconditions

1. An adapter has a current `accepted` record for engine version `E.M` (major M, some
   minor/patch N).
2. A new engine version `E.M'` (where M' > M in semver minor or patch) is detected by
   the factory's adapter-version monitor.
3. The conformance suite version is compatible with the new engine version per the
   compatibility matrix (BC-2.02.004).

## Postconditions

1. A conformance re-run is scheduled against the new engine version `E.M'` using the
   adapter's existing manifest (or an updated manifest if the adapter author provides one).

2. The re-run uses the same test selection logic (BC-2.02.001) and acceptance gate
   (BC-2.02.002) as the initial acceptance.

3. If the re-run passes:
   - A new accepted record for engine version `E.M'` is created.
   - The old `E.M` record is retained (backward compat for builds still using `E.M`).
   - The adapter is cleared for use with `E.M'`.

4. If the re-run fails (FM-001: capability drift detected):
   - The adapter's status for `E.M'` is set to `rejected`.
   - Production jobs targeting `E.M'` are blocked from using this adapter.
   - The failure is reported to the adapter author with diff of failing tests vs prior run.
   - The factory continues to use the adapter with the last-accepted engine version
     until the drift is fixed.

5. The factory never uses an adapter with engine version `E.M'` without a valid accepted
   record for `E.M'`, even if a valid record exists for `E.M`.

## Invariants

1. **Per-version acceptance:** Acceptance is per `(adapter_id, engine_version)` pair.
   Accepting an adapter for version X does not implicitly accept it for version X+1.
2. **Drift surfaces as rejection:** A capability that was `full` in version X but breaks
   in version Y is detected as a failure in the re-run for version Y and surfaced
   immediately, not silently tolerated.
3. **No version skip in production:** The factory version monitor must detect new engine
   versions before they are used in production. A job targeting a newer engine version
   than the adapter's last-accepted version is blocked.
4. **Backward compat preserved:** Old accepted records are never deleted. A build pipeline
   pinned to `E.M` continues to use the `E.M` accepted record even after `E.M'` is released.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Engine patches a security fix (micro version bump); no API changes | Re-run scheduled; if all tests pass (expected), new record created with minimal overhead. |
| EC-002 | Engine major version bump (breaking API changes) | Major version change requires the adapter author to update the adapter and manifest; the factory blocks use until a new acceptance run completes for the major version. |
| EC-003 | Re-run detects that a capability previously `full` now only meets `partial` criteria | Adapter is rejected for `full` fidelity on `E.M'`; author must choose to re-declare as `partial` and re-run, or fix the regression. |
| EC-004 | Version monitor is unavailable; factory cannot detect new engine version | Production jobs continue using the last-known-valid engine version; alert emitted that version monitor is offline. |
| EC-005 | Adapter author proactively re-runs conformance before engine version is detected | Factory accepts the proactive re-run; new accepted record stored. |
| EC-006 | Two adapters for same engine; one drifts on new version, one does not | Drifted adapter rejected for new version; healthy adapter accepted for new version; factory routes tasks to the accepted adapter. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Adapter accepted for Bevy 0.15; Bevy 0.16 released; re-run passes | New accepted record for Bevy 0.16; Bevy 0.15 record retained. | happy-path |
| Adapter accepted for Unity 2025.1; Unity 2025.2 released; `replay` test now fails | Adapter rejected for Unity 2025.2 for `replay` capability. Production jobs targeting Unity 2025.2 blocked. | error-path (drift) |
| Engine minor update; adapter's conformance suite version no longer in matrix range | Re-run aborted with `SUITE_TOO_OLD` per BC-2.02.004; suite must be updated too. | edge-case |
| Engine micro-patch; all tests pass in re-run | Quick re-acceptance with no capability changes. | happy-path |

## Verification Properties

| VP-ID | Property | Proof Method |
|-------|----------|-------------|
| VP-TBD-014 | No production dispatch to adapter with engine version V when accepted record for V does not exist. | kani / static analysis of dispatch path |
| VP-TBD-015 | Re-run failure for version V does not invalidate accepted record for version V-1. | integration test |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 |
| Capability Anchor Justification | CAP-002 ("Engine Adapter Conformance Gating") per capabilities.md §CAP-002 — this BC specifies the scheduled conformance re-run on engine releases, which is the ongoing anti-drift mechanism that makes the conformance gate durable over the adapter lifecycle (not just at initial acceptance). |
| L2 Domain Invariants | DI-002 (Every Engine Adapter Must Pass Conformance Before Acceptance) |
| L2 Failure Modes | FM-001 (Adapter Capability Drift) |
| Architecture Module | SS-01 (Adapter Registry, Version Monitor — filled by architect) |
| Stories | (filled by story-writer) |
| ADRs | ADR-0002 §Decision point 2 (Terraform-style acceptance testing; Semport analog) |

## Related BCs

- BC-2.02.001 — composes with (same test selection logic used in re-run)
- BC-2.02.002 — composes with (same acceptance gate used in re-run)
- BC-2.02.004 — depends on (version compatibility check applies to re-run too)

## Architecture Anchors

- `architecture/SS-01-conformance-suite.md` — Scheduled re-run, version monitor, backward-compat record model

## Story Anchor

(filled by story-writer)

## VP Anchors

- VP-TBD-014 — no-dispatch-without-version-accepted-record
- VP-TBD-015 — re-run failure does not invalidate prior version record
