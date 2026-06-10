---
document_type: behavioral-contract
level: L3
version: "1.3"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/qa-testing-liveops.md
  - .factory/planning/research/aaa/online-services-platform-distribution.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-08
capability: CAP-009
priority: P1
lifecycle_status: active
introduced: v0.1.0
modified:
  - version: "1.1"
    date: 2026-06-08
    by: product-owner
    reason: "Pass-10 I-3: replace non-canonical AMBER with DEGRADED-PENDING for cert_preflight dimension status per methodology-layer.md §3.1 canonical enum {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}."
  - version: "1.2"
    date: 2026-06-08
    by: product-owner
    reason: "Pass-15 F15-01: fix Related-BCs cross-reference mis-anchor — changed BC-7.05.001 (Playtest-Satisfaction) to BC-7.06.001 (Cert-Preflight and Distribution-Readiness Convergence Dimension Evaluation). The description 'Cert Pre-Flight Convergence Dimension Evaluation' correctly identifies the cert dimension owner; the cited ID was wrong. ID-citation fix only; no content change."
  - version: "1.3"
    date: 2026-06-10
    by: product-owner
    reason: "F51-02: static-slot reconciliation — add nft_blockchain_policy as a statically config-declared check in console (xbox/psn/switch) cert-preflight-config. The slot is always present in the console cert-preflight-report (satisfying INV-1's config-declared invariant and the postcondition that every config check appears in every report). Result is SKIP when NFT/web3 inactive; REQUIRES_HUMAN_REVIEW when NFT/web3 active (per-report evaluation of genre-profile state, not runtime check-set mutation). Resolves producer/consumer gap identified in Pass-51 F51-02 with BC-13.01.004."
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-9.01.001: Cert Pre-Flight Checklist — Platform-Scoped Machine-Checkable Run

## Description

The factory's cert pre-flight harness runs a platform-scoped checklist of machine-checkable
certification requirements against a game build and emits a structured `cert-preflight-report`.
The checklist covers the automatable 55–80% of cert requirements per platform (verified
directional estimate: Sony ~60–65%, Xbox ~75–80% via GDK Submission Validator, Nintendo
~55–60%). The harness never asserts pass/fail on requirements it cannot evaluate; those slots
are explicitly flagged `requires-human-review` in the report.

## Preconditions

1. A game build artifact exists at a declared path with a known `build_version`, `target_platform`
   (`{steam|itchio|ios|android|xbox|psn|switch}`), and `build_profile` (`{release|debug}`).
2. A `cert-preflight-config` for the `target_platform` exists in the factory config store,
   declaring the checklist version and the set of automatable checks for that platform.
3. The factory has access to the build artifact file system (can read binary metadata, package
   manifests, crash-recovery markers, file-name length, icon assets, memory-snapshot outputs).
4. For Xbox targets: the GDK Submission Validator binary is present on the CI worker and
   executable (path declared in `cert-preflight-config`).
5. The `convergence-report` artifact for the game exists with a writable
   `dimensions.cert_preflight` field.

## Behavior

1. The harness loads the `cert-preflight-config` for `target_platform`.
2. For each automatable check in the checklist:
   - Evaluate the check against the build artifact.
   - Record result as `PASS | FAIL | SKIP` with evidence (file path, extracted value, expected value).
3. For each non-automatable check:
   - Record result as `REQUIRES_HUMAN_REVIEW` with a textual description of what the human
     reviewer must verify and a link to the relevant platform documentation section.
3a. **Console-only static policy slot (`nft_blockchain_policy`):** For `target_platform` in
   `{xbox, psn, switch}`, the `cert-preflight-config` MUST statically declare an
   `nft_blockchain_policy` check (non-automatable). The harness evaluates it as follows:
   - When the project's genre profile has `nft_mechanics: false` AND `web3_enabled: false`:
     record result as `SKIP` with reason "NFT/web3 mechanics inactive — not applicable".
   - When the project's genre profile has `nft_mechanics: true` OR `web3_enabled: true`:
     record result as `REQUIRES_HUMAN_REVIEW` with message: "NFT/web3 mechanics declared —
     verify platform holder NFT/blockchain policy compliance before cert submission (Sony,
     Microsoft, and Nintendo each maintain independent policies that may block certification
     independent of age rating)."
   This is a per-report result evaluation (based on current genre-profile state), NOT a
   runtime mutation of the check set. The slot is always present in the console
   cert-preflight-report; only its result value varies.
4. Emit a structured `cert-preflight-report` (JSON schema: `cert-preflight-report-v1.schema.json`)
   containing:
   - `build_version`, `target_platform`, `checklist_version`, `run_timestamp`
   - `checks[]`: array of `{check_id, category, result, evidence, documentation_ref}`
   - `summary`: `{automatable_total, pass, fail, skip, requires_human_review}`
   - `overall_status`: `PASS | FAIL | PARTIAL` (PARTIAL = any REQUIRES_HUMAN_REVIEW;
     FAIL = any automatable check FAIL)
5. If any automatable check FAILs:
   - `overall_status` is set to `FAIL`.
   - The `convergence-report.dimensions.cert_preflight` field is set to `BLOCKED` with
     reference to the failing check IDs.
6. If all automatable checks PASS but REQUIRES_HUMAN_REVIEW items exist:
   - `overall_status` is `PARTIAL`.
   - The `convergence-report.dimensions.cert_preflight` field is set to `DEGRADED-PENDING`
     (awaiting human review completion).
7. If all automatable checks PASS and no REQUIRES_HUMAN_REVIEW items exist for this
   platform scope:
   - `overall_status` is `PASS`.
   - The `convergence-report.dimensions.cert_preflight` field is set to `GREEN`.

## Postconditions

- A `cert-preflight-report` artifact exists in `.factory/artifacts/cert/<build_version>/
  cert-preflight-<target_platform>.json`.
- The report schema validates against `cert-preflight-report-v1.schema.json`.
- Every check in the platform's `cert-preflight-config` appears in the report with a result
  of `PASS | FAIL | SKIP | REQUIRES_HUMAN_REVIEW` — no check is silently omitted. For the
  console-only `nft_blockchain_policy` slot, the result is `SKIP` (NFT inactive) or
  `REQUIRES_HUMAN_REVIEW` (NFT active) — both are valid result values; the slot is always
  present in the report.
- The `convergence-report.dimensions.cert_preflight` field reflects the run outcome.
- No check with `result: REQUIRES_HUMAN_REVIEW` is emitted as `PASS` or `FAIL`.

## Invariants

- INV-1: The set of checks for a platform is declared in `cert-preflight-config`, not
  inferred or injected at runtime. Adding a new check requires a config version bump. Note:
  a check whose result value depends on project state (e.g., `nft_blockchain_policy` emitting
  `SKIP` vs `REQUIRES_HUMAN_REVIEW` based on genre-profile NFT state) does NOT violate this
  invariant — the check SLOT is statically declared; only its per-run result value varies.
- INV-2: A check that the harness cannot evaluate (missing tooling, missing artifact) is
  emitted as `SKIP` (with reason), not silently omitted and not auto-PASS.
- INV-3: The harness never emits a result that contradicts observable build state. It reads
  build metadata directly; it does not accept developer assertions as evidence.
- INV-4: The checklist version is immutable once published; bug-fixes require a version bump
  so report results are reproducible by checklist version.
- INV-5 (DI-006): The harness never suppresses a `REQUIRES_HUMAN_REVIEW` slot by treating
  it as PASS. Doing so is a hook-detectable defect.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Build artifact path does not exist | Harness emits error `E-CERT-001`, no report written, `cert_preflight` = `BLOCKED` |
| EC-002 | `cert-preflight-config` for `target_platform` does not exist | Error `E-CERT-002`: "No cert-preflight-config for platform `<target>`" |
| EC-003 | GDK Submission Validator binary not found (Xbox target) | Xbox-specific checks that require it are emitted as `SKIP` with reason "GDK Submission Validator not found at declared path" |
| EC-004 | Game binary has `build_profile: debug` | Harness runs with a `debug-build` warning in the report header; release-only checks (e.g., strip-debug-symbols) emit `REQUIRES_HUMAN_REVIEW` with note |
| EC-005 | `cert-preflight-config` lists 0 automatable checks (all REQUIRES_HUMAN_REVIEW) | Report is valid; `overall_status = PARTIAL`; `convergence-report.cert_preflight = DEGRADED-PENDING` |
| EC-006 | Same build run against multiple platforms in parallel | Each platform gets its own scoped report; no cross-platform state sharing |
| EC-007 | Check execution throws a runtime exception | Check is emitted as `SKIP` with `reason: "evaluation_error"` and error detail; harness continues remaining checks |
| EC-008 | Checklist version in config does not match any known version | Error `E-CERT-003`: checklist version unknown; harness aborts |

## Canonical Test Vectors

| Target Platform | Build State | Expected `overall_status` | Expected `cert_preflight` dim |
|----------------|-------------|--------------------------|-------------------------------|
| `steam` | All automatable checks pass; no REQUIRES_HUMAN_REVIEW | `PASS` | `GREEN` |
| `steam` | 1 automatable check FAIL (e.g., missing crash handler) | `FAIL` | `BLOCKED` |
| `steam` | All automatable checks pass; 3 REQUIRES_HUMAN_REVIEW | `PARTIAL` | `DEGRADED-PENDING` |
| `xbox` | GDK Submission Validator: 0 failures; 2 REQUIRES_HUMAN_REVIEW | `PARTIAL` | `DEGRADED-PENDING` |
| `psn` | Config has 0 automatable checks (all NDA-gated) | `PARTIAL` | `DEGRADED-PENDING` |
| `steam` | Build artifact missing | Error `E-CERT-001` | `BLOCKED` |

## Verification Properties

- VP-CERT-001: Every platform config check appears exactly once in the output report.
- VP-CERT-002: No check with `automatable: false` in config is emitted as `PASS` or `FAIL`.
- VP-CERT-003: `summary.pass + summary.fail + summary.skip + summary.requires_human_review
  == summary.automatable_total + requires_human_review_count` (totals add up).
- VP-CERT-004: `overall_status == FAIL` iff `summary.fail > 0`.
- VP-CERT-005: `overall_status == PASS` iff `summary.fail == 0 && summary.requires_human_review == 0`.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — this BC defines the primary cert pre-flight harness contract that is the automated prefix of the distribution-readiness convergence dimension |
| L2 Invariants | DI-006 (human-gated tasks surfaced, not dropped), DI-012 (every contract has a declared validation method) |
| Source Processes | PROC-001 §Stage 6 (Cert Pre-Flight + Distribution Readiness), PROC-006 (Human-Gated Task Surfacing) |
| Research Grounding | qa-testing-liveops.md §1 (cert pre-flight ~55–80% machine-checkable; GDK Submission Validator verified), §6; online-services-platform-distribution.md §4.5 (GDK Submission Validator: "automates basic quality checks") |

## Related BCs

- BC-9.01.002 — Xbox GDK Submission Validator Integration (specializes this BC for Xbox)
- BC-9.02.001 — Distribution-Adapter Capability Negotiation (declares `human-gated` fidelity)
- BC-9.06.001 — Human-Gated Console Cert Sign-Off Task Surfacing (depends on: this BC's DEGRADED-PENDING state triggers it)
- BC-7.06.001 — Cert Pre-Flight Convergence Dimension Evaluation (consumes this BC's output)
- BC-13.01.004 — Genre Profile Default Enforces NFT/Web3 Off-By-Default (upstream producer: provides genre-profile NFT state that determines the `nft_blockchain_policy` slot result in console cert-preflight-reports)

## Architecture Anchors

- `.factory/specs/architecture/` (subsystem assignment TBD by architect)
- `cert-preflight-report-v1.schema.json` (schema artifact, to be defined)
- `cert-preflight-config` per platform (YAML config, to be defined)

## Story Anchor

TBD (filled after story decomposition)

## VP Anchors

VP-CERT-001 through VP-CERT-005 (above)
