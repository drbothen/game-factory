---
document_type: behavioral-contract
level: L3
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/research/aaa/online-services-platform-distribution.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/capabilities.md
origin: greenfield
subsystem: SS-TBD
capability: CAP-009
priority: P1
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

# BC-9.03.001: steamcmd Depot Upload Executes Non-Interactively and Emits Verifiable Build Record

## Description

The factory's Steam distribution adapter invokes `steamcmd` with the `+run_app_build`
command in non-interactive mode (`+quit` flag) to upload a game build to a Steam depot.
The invocation is fully scriptable and CI-safe. On completion, the factory records a
`build-upload-record` with the AppID, depot IDs, build version, and steamcmd exit code.
Store page publishing remains a human-gated terminal step (BC-9.06.002). The steamcmd
automation is verified against Valve's SteamPipe documentation (partner.steamgames.com).

## Preconditions

1. `target == "steam"` and Steam distribution adapter is accepted in the registry.
2. A `steam-build-config` exists containing:
   - `app_id` (numeric Steam AppID)
   - `depot_configs[]`: array of `{depot_id, content_root, exclusions[]}`
   - `steamcmd_path`: path to `steamcmd.exe` / `steamcmd` / `builder_osx`
   - `steam_account`: Steam build account name
   - `steam_password_env`: name of the environment variable holding the account password
3. The game build artifact is present at the declared `content_root` path.
4. The Steam account has upload permissions for the AppID.
5. The CI environment has the `steam_password_env` variable set.

## Behavior

1. The factory generates `app_build_<AppID>.vdf` and `depot_build_<DepotID>.vdf` scripts
   from `steam-build-config`, using the declared content roots and exclusion rules.
2. Factory invokes steamcmd in non-interactive mode:
   ```
   steamcmd +login <account> <password> +run_app_build <path_to_app_build.vdf> +quit
   ```
3. Factory captures stdout/stderr and exit code.
4. **Success path (exit code 0):** Factory emits a `build-upload-record`:
   ```json
   {
     "adapter": "steam",
     "app_id": "<AppID>",
     "depot_ids": ["<DepotID>..."],
     "build_version": "<version>",
     "branch": "<branch>",
     "steamcmd_exit_code": 0,
     "upload_timestamp": "<ISO-8601>",
     "raw_log_path": "<path>"
   }
   ```
5. **Failure path (exit code non-zero):** Factory emits error `E-DIST-010`:
   "steamcmd exited with code <N>; upload failed. See raw log at <path>."
   The `build-upload-record` is written with `status: failed` and `steamcmd_exit_code: N`.
6. The factory does NOT attempt to publish the store page. Store page updates trigger
   BC-9.06.002 (human-gated store publish task).

## Postconditions

- **Success:** `build-upload-record` exists with `status: success` and `steamcmd_exit_code: 0`.
  The build is present on the Steam depot (verifiable via Steam Partner backend).
- **Failure:** `build-upload-record` exists with `status: failed`. The previous depot state
  is unchanged (steamcmd is atomic per SteamPipe design).
- In all cases: the raw steamcmd log is preserved at the declared `raw_log_path`.
- In all cases: the VDF scripts used are preserved alongside the build-upload-record.

## Invariants

- INV-1: The factory NEVER stores `steam_password` in any artifact. It reads the password
  exclusively from the declared environment variable at invocation time.
- INV-2: The `+quit` flag is always present; steamcmd is never invoked interactively.
- INV-3: The store page publish step is NEVER performed as part of this BC; it is always
  a separate human-gated task.
- INV-4: VDF scripts are generated from `steam-build-config`, not authored manually.
  Manual authorship bypasses the factory's config-as-truth discipline.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `steamcmd_path` does not exist | Error `E-DIST-011`: "steamcmd binary not found at declared path"; upload not attempted |
| EC-002 | Steam account lacks upload permission for AppID | steamcmd exits non-zero; error `E-DIST-010` emitted; `build-upload-record` has `status: failed` |
| EC-003 | `steam_password_env` variable is not set in CI environment | Error `E-DIST-012`: "Required environment variable '<var>' is not set"; upload not attempted |
| EC-004 | Network failure mid-upload | steamcmd exits non-zero (SteamPipe handles retry internally up to its limit); error `E-DIST-010` with steamcmd exit code emitted |
| EC-005 | Content root path is empty (no build files) | VDF generation succeeds; steamcmd may succeed with empty depot upload — emit `build-upload-record` with `warning: empty_content_root` |
| EC-006 | Upload succeeds but factory writes build-upload-record to a read-only path | Error `E-DIST-013`: "Failed to write build-upload-record to <path>"; build-upload-record must still exist (write to fallback temp path) |

## Canonical Test Vectors

| Scenario | Exit code | Expected `build-upload-record.status` |
|----------|-----------|--------------------------------------|
| Valid config, valid credentials, valid build | 0 | `success` |
| Valid config, wrong password | Non-zero | `failed` |
| steamcmd binary missing | N/A | Error E-DIST-011; no upload attempted |
| `steam_password_env` not set | N/A | Error E-DIST-012; no upload attempted |

## Verification Properties

- VP-DIST-006: No `build-upload-record` with `status: success` exists unless steamcmd exit code was 0.
- VP-DIST-007: Steam passwords never appear in any factory artifact or log file.
- VP-DIST-008: Every steamcmd invocation includes `+quit` flag (verified via process args record).

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — steamcmd depot upload is the verified automatable CLI for the Steam distribution target, specified as part of the distribution CLI execution capability |
| L2 Invariants | DI-006 (human-gated store publish not automated) |
| Research Grounding | online-services-platform-distribution.md §4.1 (SteamPipe / steamcmd; `+login <acct> <pass> +run_app_build ... +quit` verified against partner.steamgames.com; binary delta patching, branch support); AAA-RECONCILIATION §5A |

## Related BCs

- BC-9.02.001 — Distribution-Adapter Manifest (declares Steam `upload: {fidelity: full}`)
- BC-9.03.002 — butler Push Execution (itch.io equivalent)
- BC-9.03.003 — fastlane Upload Execution (mobile equivalent)
- BC-9.06.002 — Human-Gated Store Publish Task (the terminal step this BC explicitly excludes)
