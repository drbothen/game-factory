---
document_type: cicd-setup
version: "1.2"
status: active
producer: devops-engineer
timestamp: 2026-06-09T00:00:00Z
phase: 1
decision: D-009
traces_to: ARCH-INDEX.md
files:
  - .github/workflows/ci.yml
  - .github/workflows/release.yml
  - .github/workflows/security.yml
---

# CI/CD Setup — game-factory

Decision D-009 (STATE.md): "Extracted core needs its own release/cross-compile
pipeline — owner: devops-engineer, target Phase 1+".

This document records every workflow file, every job, its trigger, the
toolchain assumptions, the branch-protection / required-status-check
configuration that MUST be applied before Phase-3 begins, and the stub/scaffold
jobs that will be fleshed out during implementation phases.

---

## Toolchain Assumptions

| Assumption | Source | Evidence |
|------------|--------|----------|
| Primary language: Rust / Cargo workspace | layered-architecture.md Layer 1 (dispatcher binary, hook-sdk, lobster DSL — all Rust crates) | Phase-0 extraction plan: "Rust runtime ~80k LOC crosses boundary untouched" |
| Test runner: cargo-nextest | adapter-protocols.md §2.5 — engine-adapter `test.resultFormat: libtest-json`; nextest native libtest-json | Aligns with normalized TestResult schema |
| Pure-sim formal hardening: Kani + proptest | methodology-layer.md §4.2; VP-INDEX.md — Kani (VP-001/002/004/008), proptest (VP-003/005/006/007/009/010) | D-003 / ADR-0006 |
| Cross-compile targets: Linux musl / macOS arm64 / macOS x86_64 / Windows MSVC | D-009; Unity adapter requires Windows; Bevy T1 bitwise-cross-platform requires matching runner | HANDOFF.md / adapter-protocols.md §2.4 |
| License policy: MIT / Apache-2.0 permissive | game-factory must be distributable; cargo-deny enforces | cargo-deny deny.toml (to be created in Phase-3) |
| Security scanning: cargo-audit + cargo-deny + Semgrep | VSDD devops standard; D-SEC (methodology-layer.md) | ADR-0006 D-SEC dimension |
| No Unity / Bevy / Godot SDK in core crates | DI-001 + DI-008 engine-neutrality invariants | layered-architecture.md Layer 1 invariants |
| Suno / Udio crates explicitly banned | DI-009 (asset-adapter blocklist) | adapter-protocols.md §3.5 |

---

## Workflow Files

### 1. `.github/workflows/ci.yml`

**Purpose:** Primary CI gate. Runs lint, test, build, and the pure-sim
verification job on every push to `main`, `feature/**`, `fix/**` branches, and
on every PR targeting `main`.

**Trigger:**
```yaml
on:
  push:
    branches: [main, "feature/**", "fix/**"]
  pull_request:
    branches: [main]
```

No `paths-ignore` or `paths` filters are used. This ensures all four required
status check jobs always report to branch protection, preventing deadlock where
a check would be skipped and GitHub marks the PR as "pending" indefinitely.

**Jobs:**

| Job name (stable) | Runner | Timeout | Description |
|-------------------|--------|---------|-------------|
| `CI / lint` | ubuntu-22.04 | 20 min | `cargo fmt --check` + `cargo clippy -D warnings` + engine-neutrality lint stub |
| `CI / test` | ubuntu-22.04 | 30 min | `cargo nextest run --workspace` + adapter conformance suite stub |
| `CI / build` | ubuntu-22.04 | 30 min | `cargo build --workspace --release` |
| `CI / pure-sim-verify` | ubuntu-22.04 | 45 min | proptest (VP-001/003/005/006/007/009/010) + Kani (VP-001/002/004/008) stubs |

**Permissions:** `contents: read` (workspace-level and per-job).

**Concurrency:** Cancel-in-progress runs on the same ref to avoid resource waste.

---

### 2. `.github/workflows/release.yml`

**Purpose:** Cross-compile release pipeline triggered by semver tag push
(`v*.*.*`). Implements D-009: "extracted core needs its own release/cross-compile
pipeline".

**Trigger:**
```yaml
on:
  push:
    tags: ["v[0-9]+.[0-9]+.[0-9]+", "v[0-9]+.[0-9]+.[0-9]+-*"]
```

**Jobs:**

| Job name | Runner | Timeout | Description |
|----------|--------|---------|-------------|
| `release / build (x86_64-unknown-linux-musl)` | ubuntu-22.04 | 60 min | Linux musl static binary via cross-rs |
| `release / build (aarch64-apple-darwin)` | macos-14 | 60 min | macOS M-series native build |
| `release / build (x86_64-apple-darwin)` | macos-13 | 60 min | macOS Intel native build |
| `release / build (x86_64-pc-windows-msvc)` | windows-2022 | 60 min | Windows MSVC binary (Unity adapter target) |
| `release / test (final)` | ubuntu-22.04 | 30 min | Final nextest pass before publish |
| `release / publish` | ubuntu-22.04 | 20 min | GitHub Release + binary upload (needs: build-matrix + run-tests) |

**Permissions:** `contents: read` on build/test jobs; `contents: write` on
publish job only (required to create GitHub Release and upload assets).

**Binaries collected:** `factory-dispatcher` + `factory-replay` per target triple.
These are the two primary binaries in the extracted core (layered-architecture.md
Layer 1: "dispatcher binary" + "factory-replay CLI").

**Prerelease detection:** Tags containing `-` (e.g., `v0.1.0-rc.1`) are marked
as GitHub prerelease automatically.

---

### 3. `.github/workflows/security.yml`

**Purpose:** Dependency audit, static analysis, and license compliance checks.
Runs weekly on schedule and on PRs to `main`.

**Trigger:**
```yaml
on:
  schedule:
    - cron: "0 8 * * 1"   # Every Monday 08:00 UTC
  pull_request:
    branches: [main]
```

**Jobs:**

| Job name | Runner | Timeout | Description |
|----------|--------|---------|-------------|
| `security / audit` | ubuntu-22.04 | 15 min | `cargo audit` (RustSec); posts PR comment or creates issue on failure |
| `security / deny` | ubuntu-22.04 | 15 min | `cargo deny check all` (license policy + banned crate list incl. Suno/Udio DI-009) |
| `security / semgrep` | ubuntu-22.04 | 20 min | Semgrep `p/rust` + `p/security-audit` + `p/secrets` rulesets |

**Permissions:**
- `security / audit`: `contents: read`, `issues: write`, `pull-requests: write`
- `security / deny`: `contents: read`
- `security / semgrep`: `contents: read`, `security-events: write` (SARIF upload)

**Non-blocking status:** `security / semgrep` is `continue-on-error: true` until
game-factory-specific Semgrep rules are tuned in Phase-5 (formal-verifier scope).

**Secret required:** `SEMGREP_APP_TOKEN` (optional; Semgrep runs without token
using auto-config; token unlocks Semgrep App dashboard and PR annotation).

---

## Action Pin Table

All third-party actions are pinned to full commit SHAs, never floating tags.

| Action | SHA pinned | Floating tag | Purpose |
|--------|-----------|--------------|---------|
| `actions/checkout` | `11bd71901bbe5b1630ceea73d27597364c9af683` | v4.2.2 | Checkout |
| `dtolnay/rust-toolchain` | `fcf085536bf67f4944bd6c4a87e63cb4c08eb5de` | stable | Rust toolchain install |
| `Swatinem/rust-cache` | `9d47c6ad4b02e050fd481d890b2ea34778fd0d05` | v2.7.8 | Cargo registry + build cache |
| `taiki-e/install-action` | `7c0a0060d577e9d44cbddf0b5c2d4e16f80dc2e4` | v2.49.51 | Install cargo-nextest, cargo-audit, cargo-deny, cross |
| `actions/upload-artifact` | `6f51ac03b9356f520e9adb1b1b7802705f340c2b` | v4.5.0 | Upload build artefacts |
| `actions/download-artifact` | `fa0a91b85d4f404e444306234f91f42f8c70082e` | v4.1.8 | Download release artefacts |
| `softprops/action-gh-release` | `c95fe1489396fe8a9eb87c0abf8aa5b2ef267fda` | v2.2.1 | Create GitHub Release |
| `actions/github-script` | `60a0d83039c74a4aee543508d2ffcb1c3799cdea` | v7.0.1 | Post PR comments / create issues |
| `semgrep/semgrep-action` | `7174f8f4f07f0e1b87ef34be3a76be5b97c7faa5` | v1.1.0 | Semgrep static analysis |
| `github/codeql-action/upload-sarif` | `b56ba49b26e50535fa1e7f7db0f4f7b4bf65d80a` | v3.28.10 | Upload SARIF to GitHub Security tab |

**SHA verification procedure:** All SHAs above were resolved from the action
repositories' commit history at time of authoring (2026-06-08).  When any action
is updated, resolve the new SHA from the action repo's release tag and update all
three workflow files in the same commit.

---

## Required Status Checks (Branch Protection)

These are the exact check names to register as required status checks on the
`main` branch.  Apply these settings before Phase-3 implementation begins.

### Exact required check names

```
CI / lint
CI / test
CI / build
CI / pure-sim-verify
```

### Branch protection configuration

Apply via GitHub UI (Settings → Branches → Add rule for `main`) or via the
`gh` CLI command below:

```bash
gh api repos/drbothen/game-factory/branches/main/protection \
  --method PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      { "context": "CI / lint",            "app_id": null },
      { "context": "CI / test",            "app_id": null },
      { "context": "CI / build",           "app_id": null },
      { "context": "CI / pure-sim-verify", "app_id": null }
    ]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": true
  },
  "enforce_admins": false,
  "restrictions": null
}
EOF
```

**`strict: true`** means branches must be up-to-date with `main` before merging.
This is intentional: it prevents merge-order races on the pure-sim verification
gate (replay determinism is order-sensitive).

**`required_approving_review_count: 0`** is appropriate for the current Phase-1
spec cycle where CI gates are the sole quality bar.  Raise to 1 in Phase-3 as
implementation begins.

**Security workflow jobs** (`security / audit`, `security / deny`,
`security / semgrep`) are NOT in the required check set initially.  They can be
promoted to required checks after the first clean scheduled pass (i.e., once
`deny.toml` exists and Semgrep rules are tuned).

---

## Stub / Scaffold Jobs — Phase Gate Reference

These jobs exist in `ci.yml` now as scaffolding.  They exit 0 so CI passes,
but they must be fleshed out in the phases listed below.

| Job | Step stub | Flesh-out phase | What replaces the stub |
|-----|-----------|-----------------|------------------------|
| `CI / lint` | Engine-neutrality lint (DI-001 / DI-008) | Phase-3, SS-01 | `scripts/lint/engine-neutrality-check.sh` — grep for engine identifiers in Layer-1/2 crates |
| `CI / test` | Adapter conformance suite (CAP-002) | Phase-3, SS-01 | `cargo run -p adapter-conformance-runner -- --suite engine-adapter` |
| `CI / pure-sim-verify` | proptest VP-001/003/005/006/007/009/010 | Phase-3/6, SS-05 | `cargo test -p pure-sim --features proptest` |
| `CI / pure-sim-verify` | Kani VP-001/002/004/008 | Phase-6, SS-05 | `cargo kani --workspace --harness <proof_fn>` |

**Adapter conformance suite note.** The conformance suite hook (CAP-002) covers
the 5-part structure defined in adapter-protocols.md §1.7:
1. Manifest validation
2. Per-capability functional tests (happy + error path)
3. Graceful degradation tests (CapabilityUnsupported)
4. `human-gated` surfacing tests (DTU-07 pattern)
5. Version and compatibility checks

**Engine-neutrality lint note.** When the workspace is populated, this lint
must scan:
- `crates/factory-core/` — no `bevy`, `unity`, `godot` identifiers
- `crates/methodology-layer/` — no engine SDK imports
- `crates/hook-sdk/` — no engine names or SDK types
This enforces DI-001 (core never names an engine) and DI-008 (specs
engine-portable by construction) at the CI level.

---

## Asset-Lane Smoke-Test Gate

> **Phase-3-instantiated.** The gate specification is defined here and wired into CI
> when SS-03 (asset generation subsystem) lands. Until SS-03 is merged, the gate
> step exits 0 as a stub (same pattern as other Phase-3 stubs in §Stub / Scaffold Jobs).
> NFR-002 and NFR-003 in nfr-catalog.md trace to this section.

### Purpose

Enforce NFR-002 (generation latency) and NFR-003 (quality-gate first-attempt pass-rate)
at the CI level for the asset-generation lane (SS-03: `crates/asset-lane/`).

### Corpus Composition — 100-Asset Smoke Corpus

The corpus consists of 100 representative asset requests drawn from the three
primary cloud-api generation classes:

| Asset class | Count | Discipline |
|-------------|-------|-----------|
| 3D props (GLB — PBR material, no skeleton) | 30 | Art |
| 3D props (GLB — skinned / animated) | 20 | Art |
| Textures (2K diffuse + normal + roughness, PNG) | 20 | Art |
| Audio SFX (mono WAV < 5 s) | 20 | Audio |
| Audio ambience (stereo WAV 15–60 s) | 10 | Audio |

The corpus fixture file is checked in at `test-fixtures/asset-smoke-corpus.json`.
Each entry specifies: `asset_class`, `target_backend`, `reference_quality_tier`
(Tier-1 or Tier-2), and `expected_disclosure_class`. The corpus MUST include at
least one asset of each Tier-1 class (prop/texture) for NFR-003 pass-rate to be
meaningful.

### Measurement Protocol

**Latency (NFR-002):**

- Each asset request is dispatched sequentially (not batched) to avoid
  saturating the cloud-api backend rate limiter.
- Wall-clock time is measured from request-dispatch timestamp to
  raw-asset-file-available timestamp (sidecar written, quality gate not yet run).
- p50 and p99 are computed over all 100 measurements.
- Units: seconds.

**First-attempt pass-rate (NFR-003):**

- After raw-asset availability, the quality gate (`factory-quality-gate`) runs
  on each asset exactly once.
- An asset "passes on first attempt" if the quality gate returns `PASS` without
  re-triggering generation.
- Pass-rate = (count of Tier-1 assets passing quality gate on first attempt) /
  (total Tier-1 assets in corpus).
- Result is logged to `quality-gate-report.json` alongside the run timestamp,
  corpus version, and per-asset verdict.

### Pass Thresholds

| Metric | Pass condition | Fail condition | Source NFR |
|--------|---------------|----------------|-----------|
| Latency p50 | < 120 s | ≥ 120 s | NFR-002 |
| Latency p99 | < 600 s | ≥ 600 s | NFR-002 |
| First-attempt pass-rate (Tier-1) | ≥ 80% | < 80% | NFR-003 |

All three must pass for the gate to exit 0. Any single failure fails the gate.

### CI Job

Added to `ci.yml` as a stub job in Phase-1; fleshed out in Phase-3 (SS-03):

| Job name (stable) | Runner | Timeout | Description |
|-------------------|--------|---------|-------------|
| `CI / asset-lane-smoke` | ubuntu-22.04 | 20 min (stub: immediate exit 0) | Run 100-asset smoke corpus; assert latency p50 < 120 s, p99 < 600 s, and first-attempt pass-rate ≥ 80%; upload quality-gate-report.json as artifact |

**Trigger:** Same as `ci.yml` — every push to `main`, `feature/**`, `fix/**`, and
every PR targeting `main`.

**Note on cloud-api credentials in CI:** The smoke corpus uses a sandboxed
generation-api key (asset-adapter mock mode) in PR CI so it does not incur live
cloud-api costs. The real cloud-api key is used in the scheduled weekly smoke run
and on merge to `main` (controlled via `ASSET_LANE_SMOKE_MODE` environment variable:
`mock` for PR CI, `live` for merge/scheduled runs).

### Stub / Scaffold Entry

| Job | Step stub | Flesh-out phase | What replaces the stub |
|-----|-----------|-----------------|------------------------|
| `CI / asset-lane-smoke` | `echo "asset-lane smoke: stub (Phase-3-instantiated)" && exit 0` | Phase-3, SS-03 | `cargo run -p asset-lane-smoke-runner -- --corpus test-fixtures/asset-smoke-corpus.json --mode $ASSET_LANE_SMOKE_MODE` |

---

## Output-Bundle Secrets Gate

> **Pass-42 F42-03 addition.** This gate is DISTINCT from the existing
> `security / semgrep` job (which scans the factory source tree with
> `continue-on-error: true`). This gate scans the GENERATED OUTPUT BUNDLE
> (game artifacts emitted by the factory pipeline) and is fail-closed
> (no `continue-on-error`). The distinction is critical: factory source
> having a false-positive in a non-blocking Semgrep scan is acceptable;
> the generated output bundle containing secrets is a production security failure.

### Purpose

Enforce DI-013 (never-emit-secrets into the generated output bundle) by running
a secret-pattern and entropy scan over every generated artifact bundle before
acceptance. This gate wires to the never-emit-secrets behavioral contract
(reserved as a sibling to BC-1.15.002 in ss-01/, subsystem SS-01;
product-owner to author as BC-1.15.003 per Pass-42 F42-03 reserved-ID table)
and to the D-SEC convergence dimension pass predicate (methodology-layer.md §D-SEC,
sub-predicate 4).

### What Is Scanned

The output bundle scan covers all files written to the factory's designated output
directory (configurable via `FACTORY_OUTPUT_BUNDLE_PATH` environment variable):

- Generated source code files (`.rs`, `.ts`, `.go`, `.py`, `.cs`, `.cpp`, `.h`, etc.)
- Generated configuration files (`.yaml`, `.json`, `.toml`, `.env.*`, `.ini`)
- Generated scripts (`.sh`, `.bat`, `.ps1`)
- Generated documentation (`.md`, `.txt`)
- Manifest and sidecar files (`*.manifest.json`, `*.sidecar.json`)

The scan does NOT cover engine binary assets (`.fbx`, `.png`, `.wav`, etc.) —
secret-pattern scanning of binary assets is not meaningful and would produce noise.
Binary asset scanning is limited to MIME-type check (ensure they are actual binary
assets, not text files with binary extensions).

### Scan Method: Pattern + Entropy

Two-pass scan:

**Pass 1 — Pattern Match** (fast; covers known secret formats):
- High-entropy strings matching patterns: `sk_live_`, `ghp_`, `AIza`, `xoxb-`,
  AWS access key patterns (`AKIA[0-9A-Z]{16}`), private key PEM headers
  (`-----BEGIN RSA PRIVATE KEY-----`, `-----BEGIN EC PRIVATE KEY-----`,
  `-----BEGIN OPENSSH PRIVATE KEY-----`), base64-encoded blobs that decode to
  known key material.
- Tool: `trufflehog filesystem` or `gitleaks detect --no-git` over the output
  bundle path.

**Pass 2 — Entropy Analysis** (catches novel formats):
- Shannon entropy over sliding windows on text files; threshold: > 4.5 bits/char
  over 32+ character non-whitespace runs, filtered by a corpus of known
  high-entropy-but-benign patterns (base64-encoded game data, hash digests).
- Tool: `gitleaks detect` or equivalent entropy scanner; false-positive baseline
  established per corpus type.

### Fail-Closed Behavior

This gate has NO `continue-on-error`. Any detected secret causes:

1. CI job exits with code 1.
2. The factory pipeline halts; the output bundle is not accepted.
3. Error code E-SEC-001 (reserved; product-owner to register in error-taxonomy.md
   under the new E-SEC family when authoring BC-1.15.003) is emitted in the scan
   report.
4. D-SEC convergence dimension sub-predicate 4 is BLOCKED until the gate passes.

The output bundle is quarantined (not uploaded as a CI artifact) until the scan
passes. Developers must audit and remove the detected secret, then re-run the
pipeline.

### CI Job

Added to `ci.yml` as a stub job in Phase-1 (Pass-42); fleshed out in Phase-3:

| Job name (stable) | Runner | Timeout | Description |
|-------------------|--------|---------|-------------|
| `CI / output-bundle-secrets-scan` | ubuntu-22.04 | 10 min (stub: immediate exit 0) | Run gitleaks/trufflehog pattern + entropy scan over `$FACTORY_OUTPUT_BUNDLE_PATH`; fail-closed (no continue-on-error); emits E-SEC-001 on detection; gates D-SEC sub-predicate 4 |

**Trigger:** Same as `ci.yml` — every push to `main`, `feature/**`, `fix/**`, and
every PR targeting `main`. Also triggered by `release.yml` before the publish step.

**Required status check:** `CI / output-bundle-secrets-scan` MUST be added to the
required status checks on `main` (alongside `CI / lint`, `CI / test`, `CI / build`,
`CI / pure-sim-verify`) in Phase-3 when SS-01 output-bundle linting lands.

### Stub / Scaffold Entry

| Job | Step stub | Flesh-out phase | What replaces the stub |
|-----|-----------|-----------------|------------------------|
| `CI / output-bundle-secrets-scan` | `echo "output-bundle-secrets-scan: stub (Phase-3-instantiated)" && exit 0` | Phase-3, SS-01 | `gitleaks detect --no-git --source=$FACTORY_OUTPUT_BUNDLE_PATH --config=.gitleaks.toml` or `trufflehog filesystem $FACTORY_OUTPUT_BUNDLE_PATH --fail` |

### Distinction from `security / semgrep`

| Attribute | `security / semgrep` (existing) | `CI / output-bundle-secrets-scan` (new) |
|-----------|--------------------------------|-----------------------------------------|
| What is scanned | Factory source tree (`.factory/`, `crates/`, scripts) | Generated output bundle (`$FACTORY_OUTPUT_BUNDLE_PATH`) |
| Blocking | Non-blocking (`continue-on-error: true`) until Phase-5 rules tuned | Blocking (no `continue-on-error`) from Phase-3 |
| Trigger | Weekly schedule + PRs to main | Every push + every PR + release pipeline |
| Enforces | D-SEC (source-level) + advisory rule catalog | DI-013 (never-emit-secrets); D-SEC sub-predicate 4 |
| Error code | Semgrep SARIF findings | E-SEC-001 (reserved for product-owner to register) |

---

## Secrets Reference

| Secret name | Required by | When to provision |
|-------------|------------|-------------------|
| `GITHUB_TOKEN` | `release.yml` (publish job) | Automatic — provided by GitHub Actions |
| `SEMGREP_APP_TOKEN` | `security.yml` (semgrep job) | Optional; provision before Phase-5 if Semgrep App is used |

No other secrets are needed at this stage.  When the adapter conformance suite
is implemented (Phase-3), the following may be needed:

| Future secret | Purpose | Phase |
|--------------|---------|-------|
| `UNITY_LICENSE_FILE_B64` | Unity Build Server license (base64-encoded) for Unity adapter CI tests | Phase-3, SS-01 Unity adapter |
| `STEAM_BUILD_ACCOUNT_TOKEN` | steamcmd CI credentials for distribution adapter dry-run tests | Phase-3, SS-08 distribution adapter |

These are listed here so they are provisioned before the implementing stories
arrive, not discovered mid-sprint.

---

## Architecture Gate Mapping

This table maps CI jobs to the convergence dimensions they gate
(methodology-layer.md §3):

| CI job | Convergence dimension | Gate type |
|--------|-----------------------|-----------|
| `CI / lint` (engine-neutrality stub) | D-IMPL (DI-001/DI-008 enforcement) | Hard gate |
| `CI / test` (adapter conformance stub) | D-IMPL + SS-01 (adapter conformance) | Hard gate |
| `CI / build` | D-IMPL (build pass required) | Hard gate |
| `CI / pure-sim-verify` (proptest) | D-SIM (balance/conservation/damage-io) | Hard gate |
| `CI / pure-sim-verify` (Kani) | D-SIM (FSM legality, no-softlock) + D-REPLAY (VP-008 T1 harness) | Hard gate |
| `security / audit` | D-SEC (dependency vulnerabilities) | Advisory (promote to required in Phase-5) |
| `security / deny` | D-PROV (license compliance) + D-SEC (banned crates DI-009) | Advisory (promote in Phase-5) |
| `release / build (*)` | D-IMPL (cross-platform build pass) | Hard gate on release tag |
| `CI / asset-lane-smoke` | D-PROV (provenance sidecar completeness) + SS-03 (asset quality) | Hard gate (Phase-3-instantiated; stub exits 0 until SS-03 lands) |
| `CI / output-bundle-secrets-scan` | D-SEC sub-predicate 4 (DI-013 never-emit-secrets; BC-1.15.003 reserved) | Hard gate — fail-closed, no continue-on-error (Phase-3-instantiated; stub exits 0 until SS-01 output-bundle linting lands) |

---

## Changelog

### v1.2 (2026-06-09)

| Change | Detail |
|--------|--------|
| Pass-42 F42-03: Output-Bundle Secrets Gate section added | Added `§Output-Bundle Secrets Gate` specifying a BLOCKING (fail-closed, no continue-on-error) secret-pattern + entropy scan over the generated output bundle (distinct from the existing non-blocking `security / semgrep` factory-source scan). Scan covers generated source, config, scripts, manifests; uses trufflehog/gitleaks pattern + entropy passes. CI job `CI / output-bundle-secrets-scan` stub added. Architecture Gate Mapping table updated. Enforces DI-013 (never-emit-secrets invariant; product-owner to add to domain-spec/invariants.md) and D-SEC sub-predicate 4. Error code E-SEC-001 reserved (product-owner to register E-SEC family in error-taxonomy.md when authoring BC-1.15.003). |

### v1.1 (2026-06-09)

| Change | Detail |
|--------|--------|
| F41-04: Asset-Lane Smoke-Test Gate section added | Added `§Asset-Lane Smoke-Test Gate` specifying the 100-asset corpus composition (5 asset classes: 3D props, textures, audio SFX, audio ambience), latency measurement protocol (p50/p99 per-asset wall-clock), first-attempt pass-rate measurement, concrete pass thresholds (NFR-002: p50 < 120 s, p99 < 600 s; NFR-003: ≥ 80%), and the `CI / asset-lane-smoke` stub job. Gate is Phase-3-instantiated; stub exits 0 until SS-03 asset-generation subsystem lands. NFR-002 and NFR-003 in nfr-catalog.md now cite this section as a resolvable reference. |
