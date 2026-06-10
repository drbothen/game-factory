---
document_type: prd-supplement
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
traces_to: CAP-001
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/entities.md
  - .factory/specs/domain-spec/processes.md
  - .factory/specs/domain-spec/failure-modes.md
  - .factory/planning/design/engine-adapter-protocol.md
  - .factory/planning/design/protocol-schema.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/research/aaa/engineering-disciplines.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
parallel-batch: cap-001
supplements:
  - behavioral-contracts/ss-01/
---

# PRD Supplement — CAP-001: Engine-Agnostic Game Build and Test

> **Parallel-batch artifact.** This file covers CAP-001 only. The master PRD
> index (`prd.md`) and BC-INDEX are produced in the integrate pass.
> All BC IDs in this section use S=1 (BC-1.SS.NNN).

---

## 1. Capability Overview

**CAP-001 — Engine-Agnostic Game Build and Test (P0)**

The factory builds, tests, runs, introspects, and captures gameplay from any
supported engine via the Engine Adapter Protocol (EAP), without naming or
coupling to any specific engine in the factory core (Layers 1-2).

This capability is the architectural keystone. Every other game-production
capability (replay regression, cert pre-flight, asset validation, convergence
tracking) presupposes a working adapter layer. The "implement adapter + pass
conformance; ZERO core changes" success criterion from the product brief is
operationalized entirely through CAP-001.

**Grounding:** Brief §What Is This, §Success Criteria; DI-001; ADR-0002;
`engine-adapter-protocol.md`; `protocol-schema.md`.

---

## 2. Scope of This Supplement

This supplement specifies the full Engine Adapter Protocol (EAP) surface:

| Domain Area | BCs |
|---|---|
| 1.01 — JSON-RPC 2.0 Transport and Framing | BC-1.01.001 |
| 1.02 — Adapter Lifecycle (initialize / shutdown / exit) | BC-1.02.001 – BC-1.02.004 |
| 1.03 — Dynamic Capability Negotiation | BC-1.03.001 – BC-1.03.003 |
| 1.04 — Execution Profile Declaration | BC-1.04.001 – BC-1.04.002 |
| 1.05 — Build Capability | BC-1.05.001 – BC-1.05.002 |
| 1.06 — Test Capability (Normalized Result) | BC-1.06.001 – BC-1.06.003 |
| 1.07 — Run-Headless Capability | BC-1.07.001 – BC-1.07.002 |
| 1.08 — Capture Capability (Render Profile) | BC-1.08.001 – BC-1.08.003 |
| 1.09 — Lint Capability | BC-1.09.001 |
| 1.10 — Assets-Validate Capability | BC-1.10.001 – BC-1.10.002 |
| 1.11 — Introspect Capability | BC-1.11.001 – BC-1.11.002 |
| 1.12 — Determinism-Tier Declaration and Enforcement | BC-1.12.001 – BC-1.12.003 |
| 1.13 — Graceful Degradation (Declare-and-Degrade) | BC-1.13.001 – BC-1.13.003 |
| 1.14 — Protocol Versioning and Compatibility | BC-1.14.001 – BC-1.14.002 |
| 1.15 — DI-001 Enforcement (Core Never Names Engine) | BC-1.15.001 – BC-1.15.003 |

**Total CAP-001 BCs: 36** (34 original + BC-1.15.002 added v1.1 + BC-1.15.003 never-emit-secrets added v2.3/Pass-42)

---

## 3. Design Context and Decisions

### 3.1 Protocol Architecture

The EAP is a JSON-RPC 2.0 protocol transported over stdio with LSP-style
`Content-Length` framing. The factory core is the client; the adapter is the
server. This allows adapters to be written in any language (Rust for Bevy,
C# for Unity, Python/GDScript for Godot) without an FFI boundary.

Key protocol precedents (Decision 0002):
- **LSP-style**: dynamic capability negotiation + `initialize`/`shutdown` lifecycle
- **Terraform-style**: versioned protocol with compatibility matrix
- **CRI/CSI-style**: capability-gated conformance suite as the anti-drift mechanism

### 3.2 Capability Independence Constraint

Capabilities are NEVER bundled. Research confirmed that "headless ⇒ capture" is
false on every engine (Unity `-nographics` → blank frame; Godot `--headless`
disables all rendering). Each capability is independently fidelity-graded.

### 3.3 Two Execution Profiles

Every adapter declares exactly two execution profiles:
- `headless-compute`: build/test/run/lint/assets-validate/introspect — true headless, no GPU
- `render`: capture — always requires a GPU backend (lavapipe for Bevy, xvfb+Mesa for Unity/Godot)

The `render` profile requirement is research-confirmed and non-negotiable.

### 3.4 The Eight Capabilities

The fixed surface every adapter implements (fidelity may be `none`):
`build`, `test`, `runHeadless`, `replay`, `capture`, `lint`, `assetsValidate`, `introspect`

Note: `replay` is intentionally excluded from this CAP-001 batch because
replay-regression is covered by CAP-003. The BC for `replay/record` and
`replay/play` protocol methods appear in the CAP-003 supplement.

### 3.5 Founding Engine Pair

Adapters are designed against Bevy AND Unity simultaneously (Decision 0001)
to prevent single-backend assumptions. Godot serves as the interpolating
third adapter. Every BC is validated against the known behaviors of all three.

---

## 4. Behavioral Contracts Index

All BCs are in `.factory/specs/behavioral-contracts/ss-01/`.

### 1.01 — Transport and Framing

| BC ID | Title | Priority |
|---|---|---|
| BC-1.01.001 | JSON-RPC 2.0 stdio transport with LSP-style Content-Length framing | P0 |

### 1.02 — Adapter Lifecycle

| BC ID | Title | Priority |
|---|---|---|
| BC-1.02.001 | initialize handshake returns Capability Manifest | P0 |
| BC-1.02.002 | Protocol version incompatibility returns ProtocolVersionMismatch error | P0 |
| BC-1.02.003 | shutdown request flushes in-flight work and stops accepting new requests | P0 |
| BC-1.02.004 | exit notification terminates the adapter process | P0 |

### 1.03 — Dynamic Capability Negotiation

| BC ID | Title | Priority |
|---|---|---|
| BC-1.03.001 | Adapter upgrades a capability via capability/register after project inspection | P0 |
| BC-1.03.002 | Adapter downgrades a capability via capability/unregister | P0 |
| BC-1.03.003 | Core re-plans gates after capability registration change | P0 |

### 1.04 — Execution Profile Declaration

| BC ID | Title | Priority |
|---|---|---|
| BC-1.04.001 | Every adapter declares headless-compute and render execution profiles | P0 |
| BC-1.04.002 | render profile declares GPU backend requirements | P0 |

### 1.05 — Build Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.05.001 | build capability returns normalized BuildResult | P0 |
| BC-1.05.002 | build failure returns OperationFailed with diagnostics | P0 |

### 1.06 — Test Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.06.001 | test capability normalizes engine-native format to TestResult | P0 |
| BC-1.06.002 | test failure cases reported per-test with status fail and message | P0 |
| BC-1.06.003 | test capability reports capabilityFidelity in TestResult | P0 |

### 1.07 — Run-Headless Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.07.001 | runHeadless runs game process without display and returns RunResult | P0 |
| BC-1.07.002 | runHeadless timeout and crash are distinguished exit statuses | P0 |

### 1.08 — Capture Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.08.001 | capture/screenshot on render profile returns CaptureResult with media path | P0 |
| BC-1.08.002 | capture returns ProfileUnavailable when render profile is absent | P0 |
| BC-1.08.003 | capture/frames returns ordered frame sequence paths | P0 |

### 1.09 — Lint Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.09.001 | lint capability returns normalized LintResult with per-finding severity | P1 |

### 1.10 — Assets-Validate Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.10.001 | assetsValidate returns AssetValidateResult with per-asset status | P0 |
| BC-1.10.002 | partial fidelity assetsValidate declares method and coverage limitation | P0 |

### 1.11 — Introspect Capability

| BC ID | Title | Priority |
|---|---|---|
| BC-1.11.001 | introspect returns normalized IntrospectResult with root entity tree | P0 |
| BC-1.11.002 | introspect normalizes ECS world-dump and scene-tree formats to common root | P0 |

### 1.12 — Determinism-Tier Declaration

| BC ID | Title | Priority |
|---|---|---|
| BC-1.12.001 | Adapter declares determinismTier in Capability Manifest | P0 |
| BC-1.12.002 | Core selects replay comparison method from declared determinismTier | P0 |
| BC-1.12.003 | DeterminismTierViolation returned when core requests stricter comparison than tier allows | P0 |

### 1.13 — Graceful Degradation

| BC ID | Title | Priority |
|---|---|---|
| BC-1.13.001 | Calling a none-fidelity capability returns CapabilityUnsupported error | P0 |
| BC-1.13.002 | Core degrades convergence dimension on CapabilityUnsupported without pipeline failure | P0 |
| BC-1.13.003 | ProfileUnavailable is caught and the headless-compute capabilities continue | P0 |

### 1.14 — Protocol Versioning

| BC ID | Title | Priority |
|---|---|---|
| BC-1.14.001 | Adapter pins exactly one engineVersion in the Capability Manifest | P0 |
| BC-1.14.002 | Core compatibility matrix maps core version to supported protocol major versions | P0 |

### 1.15 — DI-001 Enforcement

| BC ID | Title | Priority |
|---|---|---|
| BC-1.15.001 | Factory core source artifacts contain no engine SDK imports or engine name references | P0 |

---

## 5. Protocol Error Taxonomy (CAP-001 Scope)

| Error Code | JSON-RPC Code | Name | Trigger | Severity |
|---|---|---|---|---|
| E-EAP-001 | -32000 | ProtocolVersionMismatch | initialize when adapter's supported range excludes core's protocolVersion | broken |
| E-EAP-002 | -32001 | CapabilityUnsupported | calling a capability with fidelity: none | degraded |
| E-EAP-003 | -32002 | ProfileUnavailable | requested execution profile not available (no lavapipe/xvfb) | degraded |
| E-EAP-004 | -32003 | EngineToolMissing | engine binary/tool/license not present (Unity .ulf, Godot export templates) | broken |
| E-EAP-005 | -32004 | DeterminismTierViolation | snapshot-hash-diff requested from tolerance-only adapter | broken |
| E-EAP-006 | -32005 | OperationFailed | engine operation ran but failed (build error, test runner crash) | broken |
| E-EAP-007 | -32006 | Cancelled | request cancelled via $/cancelRequest | cosmetic |
| E-EAP-008 | -32600 | InvalidRequest | malformed JSON-RPC envelope | broken |
| E-EAP-009 | -32601 | MethodNotFound | method name unknown to adapter | broken |
| E-EAP-010 | -32700 | ParseError | message is not valid JSON | broken |

---

## 6. Invariants Enforced by CAP-001 BCs

| Invariant | Enforcing BCs |
|---|---|
| DI-001 (core never names engine) | BC-1.15.001 |
| DI-002 (adapter must pass conformance) | BC-1.02.001, BC-1.02.002, BC-1.03.001 |
| DI-004 (determinism tier declared, never assumed) | BC-1.12.001, BC-1.12.002, BC-1.12.003 |
| DI-006 (human-gated tasks surfaced, not dropped) | BC-1.13.002 (degraded convergence surfaced) |

---

## 7. Cross-Capability Dependencies

This batch makes the following assumptions about other CAP batches:

| Assumed Capability | What CAP-001 Assumes | Dependency On |
|---|---|---|
| CAP-002 (Conformance Gating) | Conformance suite exists and is the acceptance gate; CAP-001 BCs define what the adapter must implement but not how conformance tests are structured | CAP-002 supplement |
| CAP-003 (Replay Regression) | `replay/record` and `replay/play` protocol methods exist at the adapter layer; the determinismTier declared in BC-1.12.001 is consumed by CAP-003's regression comparison logic | CAP-003 supplement |
| Protocol Schema | `protocol-schema.md` v1.0 is stable for all result schemas (BuildResult, TestResult, etc.) used in postconditions | `planning/design/protocol-schema.md` |

---

## 8. Success Metrics (CAP-001)

| Metric | Target | Validation Method |
|---|---|---|
| New engine onboarding cost | Implement adapter + pass conformance; ZERO core changes | Conformance suite run on new adapter; grep core for engine names |
| Adapters passing conformance | ≥ 3 (Bevy, Unity, Godot) by v1 | BC-1.02.001 + CAP-002 conformance suite |
| Capability negotiation accuracy | 100% of capability calls respect declared fidelity | BC-1.03.001, BC-1.13.001 |
| Transport framing correctness | 100% of JSON-RPC messages parseable by both sides | BC-1.01.001 |
| Determinism tier compliance | 0 DeterminismTierViolation errors on correct usage | BC-1.12.003 |

---

## Changelog

### v1.1 (2026-06-08)

| Change | Detail |
|--------|--------|
| BC total corrected (Pass-18 sweep) | Line 76 "Total BCs in this batch: 34" → "Total CAP-001 BCs: 35 (34 original + BC-1.15.002 added v1.1)". BC-1.15.002 was added in an earlier v1.1 authoring burst but the count line was not updated. |
