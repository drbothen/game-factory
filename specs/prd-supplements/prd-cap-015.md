---
document_type: prd-supplement
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-09T00:00:00Z
phase: 1a
traces_to: "CAP-015"
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adapter-protocols.md
  - .factory/specs/architecture/adrs/ADR-0004-adapter-family-anti-lock-in.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
  - .factory/specs/architecture/adrs/ADR-0007-human-gated-fidelity-tier.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
modified:
  - v1.1: F39-01 fix — E-OSVC-016 (SaveSizeLimitExceeded) added to §5 E-OSVC table; closes BC-15.03.001 EC-006 semantic mismatch (was incorrectly using E-OSVC-005 SaveConflictUnresolvable for a size-limit rejection).
supplements:
  - behavioral-contracts/ss-15/
---

# PRD Supplement — CAP-015: Online-Services Adapter (BaaS)

> **Tier-1 supplement.** This file covers CAP-015 only. The master PRD index (`prd.md`)
> and BC-INDEX are updated in the integrate pass. CAP-015 BCs use S=15 (BC-15.SS.NNN).
> Subsystem: SS-13. Reference implementation: Nakama (DTU-08, Docker-in-CI).

---

## 1. Capability Overview

### CAP-015 — Online-Services Adapter (P1, Tier 1)

The factory integrates with Backend-as-a-Service (BaaS) platforms via the fifth adapter
seam, providing a capability surface for seven independently fidelity-graded online
services. Lock-in is prevented by the same manifest-plus-conformance pattern used by
all five adapter seams (ADR-0004).

**Tier:** 1 (v1 ship prerequisite, always-on when `online_features: true`).
**Default state:** ON when `online_features: true` in project genre-profile (default).
Disabled via `online_features: false` (project-level toggle, not genre-gated).

**Reference backend:** Nakama (open-source, self-hostable, Docker-in-CI testable).
DTU-08 provides the Nakama BaaS double for integration testing.

**Planned alternative adapters:** EOS (Epic Online Services), PlayFab.

**Capability surface (seven independently fidelity-graded capabilities):**

| Capability | What it does | Server-Authoritative |
|------------|-------------|----------------------|
| `identity` | Account create, authenticate, session token + expiry | — |
| `cloud_save` | Per-player write/read with conflict resolution | — |
| `leaderboards` | Server-validated score submit, ranked query with variants + pagination | REQUIRED |
| `matchmaking` | Lobby create/join, capacity enforcement, progress notifications | — |
| `entitlements` | Purchase verification, DLC/premium-tier access gate | REQUIRED |
| `remote_config` | Feature-flag fetch with contract binding, stale-cache detection | — |
| `conformance_suite` | Self-reports whether adapter ships its conformance suite | — |

---

## 2. Behavioral Contracts Index

### Section 01 — Manifest Conformance and Activation

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.01.001 | Online-services manifest schema validation and serverAuthoritative enforcement — all required fields present; serverAuthoritative: true mandatory for non-none leaderboards/entitlements | P0 | `ss-15/BC-15.01.001.md` |
| BC-15.01.002 | Off-by-default posture — offline/single-player zero-artifact guarantee when online_features: false or offlineProject: true | P0 | `ss-15/BC-15.01.002.md` |

### Section 02 — Identity

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.02.001 | Identity — player account create and authenticate with session token and expiry; SessionExpired on expired token | P0 | `ss-15/BC-15.02.001.md` |

### Section 03 — Cloud Save

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.03.001 | Cloud save — write/read round-trip and conflict resolution per declared strategy | P1 | `ss-15/BC-15.03.001.md` |

### Section 04 — Leaderboards

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.04.001 | Leaderboards — server-authoritative submit, tampered score rejection, board variants, cursor pagination | P0 | `ss-15/BC-15.04.001.md` |

### Section 05 — Matchmaking

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.05.001 | Matchmaking — lobby lifecycle (create and join), capacity enforcement, progress notifications | P1 | `ss-15/BC-15.05.001.md` |

### Section 06 — Entitlements

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.06.001 | Entitlements — server-authoritative verify, granted:false for unowned, human-gated platform-store-review path | P0 | `ss-15/BC-15.06.001.md` |

### Section 07 — Remote Config

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.07.001 | Remote config — fetch, remote-config-contract binding, stale-data handling | P1 | `ss-15/BC-15.07.001.md` |

### Section 08 — Conformance Suite

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.08.001 | Conformance suite self-report (full vs. none fidelity); server-authority test required for full | P0 | `ss-15/BC-15.08.001.md` |

### Section 09 — Seam Isolation and Integrity

| BC ID | Summary | Priority | File |
|-------|---------|----------|------|
| BC-15.09.001 | Online-services seam isolation — zero core changes on adapter add/remove (ADR-0004 applied to BaaS) | P0 | `ss-15/BC-15.09.001.md` |
| BC-15.10.001 | Online-services graceful degradation — CapabilityUnsupported for none-fidelity capabilities; core degrades without pipeline halt | P0 | `ss-15/BC-15.10.001.md` |
| BC-15.11.001 | Entitlement and leaderboard integrity — D-SEC reference contract (100-Token Active Cap); violations surface through D-SEC dimension, not silently | P0 | `ss-15/BC-15.11.001.md` |

---

## 3. Functional Requirements

### FR-015-01: Online-Services Adapter Seam

The factory MUST provide a fifth adapter seam (`online-services-adapter`) following the
five-part base protocol pattern (initialize, capability manifest, fidelity grading,
conformance suite, graceful degradation). Lock-in is prevented: adding a new BaaS backend
requires implement-adapter + pass-conformance; ZERO core changes.

### FR-015-02: Manifest Schema Enforcement

Every online-services adapter manifest must satisfy the schema defined in
adapter-protocols.md §6.2. The core refuses any adapter with a malformed manifest.
`serverAuthoritative: true` is mandatory for non-`none` leaderboard and entitlement
fidelity.

### FR-015-03: Offline/Single-Player Zero-Artifact Guarantee

When `online_features: false` (project genre-profile) or `offlineProject: true`
(adapter manifest), the factory produces zero BaaS configuration artifacts and does not
halt the pipeline. This is a project-level toggle, not a genre-gated lane.

### FR-015-04: Identity Round-Trip

Player account creation and authentication must return session tokens with declared
expiry. Expired token use must return `E-OSVC-002`.

### FR-015-05: Cloud Save Round-Trip

Write followed by read for the same `(playerId, saveKey)` must return identical data.
Conflict resolution follows the declared strategy.

### FR-015-06: Server-Authoritative Leaderboards

Score submission is always server-validated. Tampered or implausible scores MUST be
rejected. Query supports declared variants and cursor pagination.

### FR-015-07: Matchmaking Lobby Lifecycle

Lobby creation returns a `joinCode`; join consumes the code. Capacity limits are
enforced server-side. Long-running waits emit `$/progress` notifications.

### FR-015-08: Server-Authoritative Entitlement Verification

Entitlement verification queries the authoritative backend store. `granted: false` is
the correct non-error result for unowned entitlements. Fail-closed on backend
unreachability. Human-gated path for platforms requiring store review (DI-006).

### FR-015-09: Remote Config with Contract Binding

`remote_config.fetch` returns key-value pairs. When `contract_ref` is declared,
values are validated against the contract schema before use. Stale cache detection
prevents use of expired cached values.

### FR-015-10: Seam Isolation

Adding or removing an online-services adapter produces zero changes to core layers 1-2.
No BaaS SDK is imported by the core.

### FR-015-11: Conformance Suite Acceptance Gate

Adapters declaring `conformance_suite: full` must pass all five parts (manifest
validation, per-capability functional, graceful degradation, server-authority, offline
path) before production acceptance.

### FR-015-12: D-SEC Integration

Leaderboard and entitlement integrity violations surface through the D-SEC convergence
dimension (E-CONV-006), not as silent online-services errors.

---

## 4. Non-Functional Requirements

| NFR ID | Category | Requirement | Numerical Target | Validation Method |
|--------|----------|-------------|-----------------|-------------------|
| NFR-036 | Performance | Identity authentication p95 latency (Nakama, Docker-in-CI) | ≤ 500 ms p95 | DTU-08 integration test: 100 sequential `online.identity.authenticate` calls; measure p95 |
| NFR-037 | Performance | Leaderboard score submit p95 latency (Nakama, Docker-in-CI) | ≤ 300 ms p95 | DTU-08 integration test: 100 sequential `online.leaderboard.submit` calls; measure p95 |
| NFR-038 | Performance | Entitlement verify p95 latency (Nakama, Docker-in-CI) | ≤ 200 ms p95 | DTU-08 integration test: 100 sequential `online.entitlement.verify` calls; measure p95 |
| NFR-039 | Performance | Cloud save write p95 latency (Nakama, Docker-in-CI) | ≤ 400 ms p95 | DTU-08 integration test: 100 sequential `online.save.write` calls; measure p95 |
| NFR-040 | Reliability | Graceful degradation — no pipeline halts from CapabilityUnsupported | 0 pipeline halts from any E-EAP-002 in online-services path | Conformance suite part 3: call all none-fidelity methods; assert zero pipeline halts |
| NFR-041 | Security | Tampered score rejection rate | 100% rejection of scores exceeding server-computed maximum | DTU-08 server-authority test: 1000 tampered submissions; assert 1000/1000 rejected |

---

## 5. E-OSVC Error Family

All E-OSVC error codes are `severity: broken` (pipeline-halting) unless noted.
Message format uses `<placeholder>` syntax.

| Error Code | Category | Severity | Exit Code | Message Format | Enforcing BC |
|-----------|----------|----------|-----------|----------------|-------------|
| E-OSVC-001 | Backend unreachable | broken | 1 | `online-services: backend '<targetId>' unreachable — connection failed or timed out` | BC-15.02.001, BC-15.03.001, BC-15.04.001, BC-15.05.001, BC-15.06.001, BC-15.07.001 |
| E-OSVC-002 | Session expired or invalid credentials | broken | 1 | `online-services: session token expired or credentials rejected for playerId '<id>' via provider '<provider>'` | BC-15.02.001 |
| E-OSVC-003 | Score rejected by server | broken | 1 | `online-services: leaderboard.submit: score <score> for board '<boardId>' rejected by server — exceeds server-computed maximum for playerId '<playerId>'` | BC-15.04.001 |
| E-OSVC-004 | Entitlement not found in store registry | broken | 1 | `online-services: entitlement.verify: entitlementId '<id>' not registered in backend store '<targetId>'` | BC-15.06.001 |
| E-OSVC-005 | Save conflict unresolvable | broken | 1 | `online-services: save.write: conflict for playerId '<id>' key '<key>' — strategy '<strategy>' could not resolve; winner_version: '<v>', payload in error.data` | BC-15.03.001 |
| E-OSVC-006 | Remote config stale | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' cache expired at '<expiry>'; backend unreachable; returning stale error` | BC-15.07.001 |
| E-OSVC-007 | Remote config contract violation | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' key '<key>' value '<v>' fails contract '<contract_ref>' schema at '<path>'` | BC-15.07.001 |
| E-OSVC-008 | Remote config namespace not found | broken | 1 | `online-services: remote_config.fetch: namespace '<ns>' not configured in backend '<targetId>'` | BC-15.07.001 |
| E-OSVC-009 | Online artifact leak in offline project | broken | 1 | `online-services: BaaS artifact '<path>' found in output tree but project declares online_features: false or offlineProject: true — zero-artifact invariant violated` | BC-15.01.002 |
| E-OSVC-010 | No conformance suite | degraded | 0 | `online-services: adapter '<targetId>' declares conformance_suite: none — accepted for dev/sandbox only; not eligible for production pipeline gate` | BC-15.08.001 |
| E-OSVC-011 | Online-services core coupling detected | broken | 1 | `online-services: adapter add/remove caused core file '<file>' to change — violates seam isolation (BC-15.09.001, ADR-0004)` | BC-15.09.001 |
| E-OSVC-012 | CapabilityUnsupported suppressed | broken | 1 | `online-services: adapter '<targetId>' returned nominal success for none-fidelity capability '<cap>' — E-EAP-002 required; conformance failure` | BC-15.10.001 |
| E-OSVC-013 | Unsupported auth provider | broken | 1 | `online-services: identity.create/authenticate: authProvider '<provider>' not in adapter's declared authProviders list` | BC-15.02.001 |
| E-OSVC-014 | Lobby capacity exceeded | broken | 1 | `online-services: matchmaking.joinLobby: lobby '<lobbyId>' is at max capacity (<maxPlayers>) — join rejected` | BC-15.05.001 |
| E-OSVC-015 | Lobby not found | broken | 1 | `online-services: matchmaking.joinLobby: joinCode '<code>' does not resolve to an active lobby — code may be expired or invalid` | BC-15.05.001 |
| E-OSVC-016 | Save size limit exceeded | broken | 1 | `online-services: save.write: payload for playerId '<id>' key '<key>' exceeds backend size limit '<limit>'` | BC-15.03.001 |

**Note on E-EAP-012 (MalformedManifest):** When `serverAuthoritative: false` is declared
on leaderboards or entitlements with non-none fidelity, the error is `E-EAP-012`
(MalformedManifest) — not a new E-OSVC code. This routes through the existing
MalformedManifest protocol error (adapter-protocols.md §1.5, §6.2). The E-OSVC family
covers online-services-specific runtime errors; manifest-level violations are always
E-EAP-012.

---

## 6. Domain Invariants Enforced

| Invariant | Enforcing BCs |
|-----------|---------------|
| DI-001 — Factory core never names a specific engine (applied to BaaS) | BC-15.09.001 |
| DI-002 — Every adapter must pass conformance before acceptance | BC-15.08.001 |
| DI-006 — Human-gated tasks surfaced, not silently dropped | BC-15.06.001 (entitlement human-gated path) |
| DI-008 — Factory core spec layer engine-portable (applied to BaaS portability) | BC-15.09.001 |
| DI-012 — Every ContractArtifact has a declared validation method | BC-15.01.001, BC-15.02.001, BC-15.03.001, BC-15.04.001, BC-15.05.001, BC-15.06.001, BC-15.07.001, BC-15.08.001, BC-15.09.001, BC-15.10.001, BC-15.11.001 |

---

## 7. Cross-Capability Dependencies

| Dependency | Relationship |
|-----------|--------------|
| CAP-001 (Engine-Agnostic Build/Test) | Online-services seam follows same adapter-protocol pattern |
| CAP-002 (Engine Adapter Conformance Gating) | Online-services conformance suite follows same five-part structure |
| CAP-007 (11-Dimension Convergence Tracking) | Leaderboard and entitlement integrity violations surface via D-SEC dimension (BC-7.11.001, BC-7.11.002, BC-7.11.008) |
| CAP-009 (Cert Pre-Flight) | Online-services entitlement human-gated path uses same DI-006 surfacing contract as distribution human-gated steps |
| CAP-013 (Genre-Gated Lanes) | `online_features: false` toggle is independent of genre lanes — it is a project-level switch that overrides all lanes |

---

## 8. Competitive Differentiator Traceability

| Differentiator | BC(s) |
|---------------|-------|
| BaaS backend lock-in eliminated via fifth adapter seam | BC-15.09.001, BC-15.01.001 |
| Server-authority enforcement is a factory-level contract, not BaaS-dependent | BC-15.04.001, BC-15.06.001, BC-15.11.001 |
| Offline/single-player projects get zero-artifact guarantee without pipeline degradation | BC-15.01.002 |
| Human-gated entitlement store review is honestly surfaced, never suppressed | BC-15.06.001 |
| Docker-in-CI testability via Nakama (no cloud spend for integration tests) | BC-15.08.001 (DTU-08 conformance suite) |

---

## 9. Out of Scope (explicitly excluded from these BCs)

- Running live backend infrastructure in production (the factory configures and tests; ops is out of scope)
- Custom BaaS backend implementations (the factory provides the seam; backend code is user-provided)
- Real-time network gameplay protocol (WebSocket relay, QUIC transport) — online-services adapter handles BaaS control plane, not real-time game data plane
- Platform SDK receipt validation implementation (platform-specific; hosted on platform side)
- Anti-cheat integration in the online-services path (DI-010; kernel AC never authored)

---

## 10. Accepted Ambiguities and Resolutions

| Ambiguity | Resolution |
|-----------|-----------|
| Should `online_features: false` be genre-gated? | No. It is a project-level toggle. Any project type may disable online services. Genre lanes (esports, matchmaking) that depend on online services degrade gracefully per BC-15.10.001. |
| Which conflict resolution strategy is the default for cloud save? | Adapter declares its default in the manifest (`last-write-wins` is the Nakama default). The factory does not impose a default; it enforces that the strategy is declared. |
| How is "server-computed maximum" for leaderboard score determined? | The BaaS backend is responsible for this computation (it may be configured as a hard cap per board, or derived from player game-state). The factory's contract is: the adapter MUST reject implausible scores, not that the factory specifies the cap value. |
| Does `E-OSVC-002` cover both session expiry AND invalid credentials? | Yes — both are authentication failures. The `error.data.reason` sub-code distinguishes `SESSION_EXPIRED` from `INVALID_CREDENTIALS`. |
