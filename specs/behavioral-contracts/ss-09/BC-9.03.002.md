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

# BC-9.03.002: butler Push Executes CI-Automatable itch.io Upload with Delta Patching

## Description

The factory's itch.io distribution adapter invokes butler `push` to upload a build to an
itch.io game page channel. butler is MIT open-source, "easily integrated into an automated
build/deploy pipeline" (verified: itch.io/docs/butler/). It uses rsync-style differential
upload for patching. The factory emits a `build-upload-record` on completion. Pricing,
page visibility, and access control remain human-configured via the itch.io web dashboard.
This contract is based on verified butler documentation; the confabulated upstream claims
(`butler deploy`, `--price`, `--pay-what-you-want`, "Butlerfile manifests") are explicitly
excluded — they do not exist in the real tool.

## Preconditions

1. `target == "itchio"` and itch.io distribution adapter is accepted in the registry.
2. `butler` binary is present at the declared path.
3. An `itchio-build-config` exists containing:
   - `game_slug`: e.g., `username/game-name`
   - `channel`: e.g., `stable`, `beta`, `windows-x64`
   - `build_path`: directory or file to upload
   - `butler_api_key_env`: name of the environment variable holding the scoped API key
   - `version`: (optional) human-readable version string
4. The `butler_api_key_env` environment variable is set and holds a valid scoped API key.
5. The build artifact exists at `build_path`.

## Behavior

1. Factory invokes butler push:
   ```
   butler push <build_path> <game_slug>:<channel> --userversion <version>
   ```
   (If `version` is absent in config, `--userversion` flag is omitted.)
2. Factory captures stdout/stderr and exit code.
3. **Success path (exit code 0):**
   ```json
   {
     "adapter": "itchio",
     "game_slug": "<slug>",
     "channel": "<channel>",
     "build_version": "<version>",
     "butler_exit_code": 0,
     "upload_timestamp": "<ISO-8601>",
     "raw_log_path": "<path>"
   }
   ```
4. **Failure path (exit code non-zero):** Error `E-DIST-020`: "butler push exited with code
   <N>". `build-upload-record` written with `status: failed`.
5. Pricing/access-control/page-publish steps are NOT automated; they trigger BC-9.06.002.

## Postconditions

- **Success:** `build-upload-record` with `status: success`, exit code 0, and channel reference.
- **Failure:** `build-upload-record` with `status: failed`; channel state unchanged.
- Raw butler log preserved.

## Invariants

- INV-1: Factory never stores the butler API key in any artifact; reads from environment variable only.
- INV-2: butler is always invoked in CI (non-interactive) mode via the declared binary; no
  interactive prompts are used.
- INV-3: The factory does NOT invoke any butler flags or subcommands not verified in the
  official itch.io/docs/butler/ documentation. Unknown commands are blocked.
- INV-4: Pricing and visibility changes are never automated; always human-gated.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | `butler` binary not found | Error `E-DIST-021`; no upload attempted |
| EC-002 | `butler_api_key_env` not set | Error `E-DIST-022`; no upload attempted |
| EC-003 | `build_path` does not exist | Error `E-DIST-023`; no upload attempted |
| EC-004 | itch.io API rate limit exceeded | butler exits non-zero; error `E-DIST-020`; `status: failed` |
| EC-005 | Channel does not exist on itch.io | butler creates the channel (butler behavior); success if channel creation succeeds |

## Canonical Test Vectors

| Scenario | Exit code | `build-upload-record.status` |
|----------|-----------|------------------------------|
| Valid config + valid API key + build exists | 0 | `success` |
| Invalid API key | Non-zero | `failed` |
| butler binary missing | N/A | Error E-DIST-021 |

## Verification Properties

- VP-DIST-009: No butler API key appears in any factory artifact or log.
- VP-DIST-010: Only verified butler subcommands are invoked; no confabulated flags used.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — butler push is the verified automatable distribution CLI for the itch.io target |
| L2 Invariants | DI-006 (human-gated tasks surfaced) |
| Research Grounding | online-services-platform-distribution.md §4.2 (butler; `butler push`; MIT; rsync-style differential; verified against itch.io/docs/butler/; confabulated flags explicitly excluded) |

## Related BCs

- BC-9.03.001 — steamcmd Depot Upload (sibling; Steam equivalent)
- BC-9.03.003 — fastlane Upload Execution (sibling; mobile equivalent)
- BC-9.06.002 — Human-Gated Store Publish Task
