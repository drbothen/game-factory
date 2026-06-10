---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-09T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/ARCH-INDEX.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
priority: P0
lifecycle_status: active
introduced: v0.1.0-prd-pass-42
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-1.15.003: Factory Output Bundle Never Contains Secret Material (Output-Bundle Secrets Gate)

## Description

Every factory-generated output artifact bundle must pass a secret-pattern scan and a
high-entropy string scan before CI acceptance. The gate enforces DI-013 (Factory Output
Bundle Never Contains Secret Material) at the CI layer using gitleaks/trufflehog for
pattern scanning and Shannon entropy analysis for high-entropy string detection. The
gate is unconditionally blocking: it has no `continue-on-error`, cannot be disabled
by flag or config, and runs after the full bundle is assembled. A detected secret or
high-entropy string (outside declared baseline exclusions) causes CI exit 1 plus
`E-SEC-001`.

## Preconditions

1. A factory output artifact bundle (generated code, integration scaffolding, build
   scripts, adapter output, config files) is staged for CI gate processing.
2. gitleaks and/or trufflehog are available in the CI environment per
   `cicd-setup.md §Output-Bundle Secrets Gate`.
3. A `secrets-scan-exclusions.toml` file is present (may be empty); any declared
   exclusions must carry a human-approved rationale comment.
4. The full output bundle has been assembled (this gate runs AFTER bundle assembly,
   not incrementally).

## Postconditions

1. **PC1 — Secret-pattern scan exits 0:** A gitleaks/trufflehog scan over all bundle
   text files exits 0 (no secret patterns detected). Any detected secret pattern
   causes CI exit 1 and `E-SEC-001`.
2. **PC2 — Entropy scan finds no high-entropy strings outside baseline exclusions:**
   A Shannon entropy scan (threshold: >4.5 bits/char over windows of 32+ consecutive
   characters) finds no high-entropy strings in bundle text files that are not covered
   by a declaration in `secrets-scan-exclusions.toml` with a human-approved rationale
   comment. Any uncovered high-entropy string causes CI exit 1 and `E-SEC-001`.
3. **PC3 — Either scan failure blocks the bundle:** If PC1 or PC2 fails, CI exits 1,
   `E-SEC-001` is emitted with the offending file path and pattern/entropy value, and
   the bundle is rejected.
4. **PC4 — Gate has no `continue-on-error`:** The secrets gate CI step is
   unconditionally blocking. There is no `continue-on-error: true` or equivalent
   bypass flag. The gate runs as a hard prerequisite for any downstream artifact
   acceptance step.

## Invariants

1. **INV-1:** Factory output bundles never contain secret material regardless of game
   genre, project configuration, or explicit project config overrides. This is
   unconditional and applies to all bundle types (game code, integration scaffold,
   build scripts, config artifacts).
2. **INV-2:** The secrets scan is not disableable by any flag, config value, CI
   environment variable, or agent instruction. A PR or config that disables the
   scan step is a defect.
3. **INV-3:** The scan runs AFTER the full output bundle is assembled. Partial-bundle
   or incremental scans do not satisfy this postcondition — only a full-bundle scan
   counts.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Bundle contains high-entropy base64 encoded save-data blob (game data, not a secret) | PASSES only if the specific file/pattern is declared in `secrets-scan-exclusions.toml` with a human-approved rationale comment; if absent from exclusions, `E-SEC-001` emitted |
| EC-002 | Bundle contains vendor `.pem` distribution certificate (code signing cert, not a private key) | PASSES only if declared in `secrets-scan-exclusions.toml` with sign-off; a plain-text private key in a `.pem` file is still blocked even with an exclusion for the cert |
| EC-003 | Bundle contains a config file with a placeholder `API_KEY=<your-key-here>` | PASSES — placeholder angle-bracket syntax does not match a real secret pattern; no `E-SEC-001` |
| EC-004 | Bundle contains a `README.md` with an example env var line `export STRIPE_SECRET=sk_test_abc...` (fake test key) | Depends on tool configuration; if gitleaks/trufflehog flags it, `E-SEC-001` is emitted; exclusion with rationale required to suppress |
| EC-005 | `secrets-scan-exclusions.toml` has an entry for a previously approved high-entropy binary asset; new version of that asset is added to bundle | PASSES for the declared path/pattern; human must re-approve if the file path changes |
| EC-006 | CI config has `continue-on-error: true` on the secrets gate step | BLOCKED: `continue-on-error: true` violates PC4; CI config is rejected by this BC's enforcement |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Output bundle with no secret patterns and no high-entropy strings | Secrets gate passes; CI exits 0; bundle accepted | happy-path |
| Bundle containing `AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE...` in a config file | `E-SEC-001` emitted; CI exits 1; bundle rejected | error |
| Bundle containing a high-entropy 64-char base64 string (entropy >4.5 bits/char) not in exclusions | `E-SEC-001` emitted; CI exits 1 | error |
| Bundle containing a high-entropy base64 asset declared in `secrets-scan-exclusions.toml` with rationale | Secrets gate passes; declared exclusion accepted | happy-path |
| Bundle containing `private_key.pem` with RSA private key material | `E-SEC-001` emitted; private key always blocked regardless of exclusions | error |
| CI step configured with `continue-on-error: true` | Gate rejects configuration; step must be unconditionally blocking per INV-2 | error |
| Full bundle assembled; gate runs after assembly (correct timing) | Gate passes if no secrets; gate runs on complete bundle per INV-3 | happy-path |
| Partial bundle scan (incremental build artifact, not full bundle) | Does NOT satisfy this BC; full-bundle scan required per INV-3 | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-327 | No high-entropy secret patterns appear in any factory output bundle text file outside declared baseline exclusions | Static lint: gitleaks/trufflehog scan + Shannon entropy scan over generated output bundle before CI acceptance |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — the output-bundle secrets gate is a CI-layer quality gate on the factory-generated artifact bundle; it enforces that factory build outputs are safe for distribution regardless of engine, which is structurally within the "what the factory can build and test" boundary that CAP-001 governs |
| L2 Domain Invariants | DI-013 (Factory Output Bundle Never Contains Secret Material — THIS BC IS THE PRIMARY ENFORCEMENT OF DI-013); DI-001 (factory core never names a specific engine — output bundles are engine-agnostic and must be secret-free across all engine targets) |
| Architecture Module | SS-01 (Engine-Adapter Protocol CI gate); D-SEC sub-predicate 4 (output-bundle secrets gate) |
| CI Reference | cicd-setup.md §Output-Bundle Secrets Gate — blocking gate specification |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.15.002 — sibling (BC-1.15.002 covers kernel-mode code never-authored; this BC covers secrets never-emitted into output bundle; both are SS-01 lint-class BCs enforcing factory output safety invariants)
- BC-1.15.001 — sibling (factory core source never names a specific engine; this BC covers factory output never contains secrets)
- BC-7.11.001 — evaluated by (D-SEC dimension evaluation includes this BC as required signal for D-SEC sub-predicate 4)

## Architecture Anchors

- `specs/architecture/ARCH-INDEX.md` §F42-03 — never-emit-secrets output-bundle lint gate (security sub-predicate 4)
- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` §D-SEC — D-SEC dimension fail-closed signal
- `specs/domain-spec/invariants.md` §DI-013 — source of invariant

## Story Anchor

S-TBD — Output-bundle secrets gate implementation (CI layer, D-SEC sub-predicate 4)

## VP Anchors

- VP-TBD-327 — No high-entropy secret patterns in output bundle (lint)
