---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/planning/design/protocol-schema.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
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

# BC-1.09.001: lint Capability Returns Normalized LintResult with Per-Finding Severity

## Description

When the `lint` capability is invoked, the adapter runs the engine-native static
analysis tool (e.g., `cargo clippy -- -D warnings` for Bevy, `dotnet format
--verify-no-changes` for Unity, `gdtoolkit` for Godot) and normalizes the findings
into a `LintResult` with per-finding severity, file, and location. The factory
core uses the normalized result for quality gating; it never parses the native
linter output format.

## Preconditions

1. The adapter's `lint` capability has `fidelity: "full"` or `"partial"`.
2. The linter tool is installed and accessible.
3. The `lint` request params may include `severityThreshold`
   (e.g., `"error"` = only report errors; default: all severities).

## Postconditions

1. The adapter returns a `LintResult` object with:
   - `findings`: array of finding objects, each with:
     - `severity`: `"error"`, `"warning"`, or `"info"`
     - `code`: string (native lint code, e.g., `"clippy::needless_clone"`)
     - `message`: string (description of the finding)
     - `file`: string (relative or absolute path to the source file)
     - `line`: positive integer (1-indexed line number)
     - `col`: positive integer or null (1-indexed column; null if not available)
   - `totals`: object with `{ error: N, warning: N, info: N }` where N is a
     non-negative integer matching the counts in `findings`
2. `totals.error + totals.warning + totals.info` equals `findings.length`.
3. If the linter exits with non-zero due to errors only (no output parsing failure),
   a `LintResult` is returned (not `OperationFailed`).

## Invariants

1. `totals` counts are always consistent with `findings` contents.
2. An empty `findings` array with all-zero `totals` means the project is clean.
3. The `code` field uses the native tool's identifier; it is not translated.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Linter not installed | `EngineToolMissing` error (`-32003`) |
| EC-002 | Linter produces no output (clean project) | `LintResult` with `findings: []` and all-zero totals |
| EC-003 | Linter reports errors only (no warnings) | `findings` contains only error-severity entries; `totals.warning: 0` |
| EC-004 | `severityThreshold: "error"` specified | Only error-severity findings are included in `findings`; lower-severity items are filtered |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Bevy project with one clippy warning | `{ findings: [{severity:"warning", code:"clippy::needless_clone", message:"...", file:"src/sim.rs", line:88, col:17}], totals:{error:0,warning:1,info:0} }` | happy-path |
| Clean Bevy project | `{ findings: [], totals: {error:0,warning:0,info:0} }` | happy-path |
| Missing gdtoolkit for Godot | `EngineToolMissing` error | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-036 | totals counts are consistent with findings array | invariant check |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — normalized lint results allow cross-engine static analysis gating without engine-specific parsing in the core |
| L2 Domain Invariants | DI-001 |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.04.001 — depends on (lint runs on headless-compute profile)

## Architecture Anchors

- `planning/design/protocol-schema.md#36-lintresult`
