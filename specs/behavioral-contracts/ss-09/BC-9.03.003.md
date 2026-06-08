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

# BC-9.03.003: fastlane Upload Executes CI-Automatable Mobile Build Distribution

## Description

The factory's iOS/Android distribution adapter invokes fastlane with verified actions
(`build_app` / `upload_to_app_store` / `upload_to_play_store` / `sync_code_signing` /
`upload_to_testflight`) to build and upload mobile game binaries. Only actions verified
against the official fastlane documentation (docs.fastlane.tools) are used. Final App Review
(iOS) and Play Store review (Android) remain human-gated terminal steps. The confabulated
upstream claims (`fastlane gms`, `supply datasafety`, "fastlane acquired by Google 2024")
are explicitly excluded and must not appear in any invocation.

## Preconditions

1. `target == "ios"` or `target == "android"`.
2. `fastlane` binary is present at the declared path.
3. A `fastlane-config` exists containing:
   - `platform`: `ios` or `android`
   - `actions[]`: ordered list of fastlane actions to invoke (only verified actions allowed)
   - `env_vars`: map of `{env_var_name: description}` for secrets (Apple ID, API keys, etc.)
   - `fastfile_path`: path to the Fastfile
4. All `env_vars` are set in the CI environment.
5. For iOS: Apple Developer account credentials and code signing certificates are configured
   via `sync_code_signing` or pre-loaded in the CI keychain.
6. The game binary/ipa/apk/aab to upload exists at the declared path.

## Behavior

1. Factory validates that all actions in `fastlane-config.actions[]` are in the verified
   allow-list: `{build_app, upload_to_app_store, upload_to_play_store, sync_code_signing,
   capture_screenshots, upload_to_testflight, get_push_certificate, increment_build_number}`.
   Any action outside this list is rejected with error `E-DIST-031`: "fastlane action
   '<action>' is not in the verified allow-list".
2. Factory invokes fastlane with the declared lane in non-interactive mode.
3. Factory captures stdout/stderr and exit code.
4. **Success path (exit code 0):**
   ```json
   {
     "adapter": "ios|android",
     "platform": "ios|android",
     "actions_invoked": ["..."],
     "upload_destination": "app_store_connect|testflight|google_play:<track>",
     "build_version": "<version>",
     "fastlane_exit_code": 0,
     "upload_timestamp": "<ISO-8601>",
     "raw_log_path": "<path>"
   }
   ```
5. **Failure path (exit code non-zero):** Error `E-DIST-030`. `build-upload-record`
   written with `status: failed`.
6. Final "Submit for Review" (iOS App Review, Google Play Review) is NOT automated;
   it triggers BC-9.06.002.

## Postconditions

- **Success:** Binary is present in App Store Connect / TestFlight / Google Play Console
  at the declared track. `build-upload-record` with `status: success`.
- **Failure:** Previous store state unchanged. `build-upload-record` with `status: failed`.
- Raw fastlane log preserved.

## Invariants

- INV-1: Only verified fastlane actions are invoked. The allow-list is closed; additions require
  a config version bump and documentation-source verification before use.
- INV-2: Credentials (Apple ID, API keys, Google service account keys) are never stored in
  factory artifacts; read from declared environment variables only.
- INV-3: App Review (iOS) and Play Review (Android) submission steps are never automated.
- INV-4: The confabulated actions (`gms`, `datasafety`, `deploy`) are never invoked. Any
  reference to them in a config triggers reject error `E-DIST-031`.

## Edge Cases

| EC-ID | Scenario | Expected Result |
|-------|----------|----------------|
| EC-001 | Config references action `gms` | Reject at validation: error `E-DIST-031`; no upload attempted |
| EC-002 | iOS code signing certificate expired | `sync_code_signing` fails; fastlane exits non-zero; error `E-DIST-030` |
| EC-003 | `fastlane` binary not found | Error `E-DIST-032`; no upload attempted |
| EC-004 | Required env var not set | Error `E-DIST-033`; no upload attempted |
| EC-005 | `upload_to_testflight` success, then `upload_to_app_store` requested for same build | These are separate actions; both allowed; factory records them as separate upload steps |
| EC-006 | Android `upload_to_play_store` targeting `production` track directly (bypassing internal/alpha/beta) | Allowed; the track is a config choice; factory does NOT gate this — it is a human release decision reflected in the Fastfile |

## Canonical Test Vectors

| Platform | Actions | Expected outcome |
|---------|---------|-----------------|
| iOS | `[sync_code_signing, build_app, upload_to_testflight]` | `status: success`; binary in TestFlight |
| iOS | `[sync_code_signing, build_app, upload_to_app_store]` | `status: success`; binary in App Store Connect awaiting human review |
| Android | `[build_app, upload_to_play_store]` | `status: success`; binary in Play Console |
| iOS | Actions include `gms` | `E-DIST-031`; no fastlane invoked |

## Verification Properties

- VP-DIST-011: No fastlane invocation uses actions outside the verified allow-list.
- VP-DIST-012: No mobile credentials appear in any factory artifact or log.
- VP-DIST-013: App Review / Play Review submission is never automated.

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 |
| Capability Anchor Justification | CAP-009 ("Cert Pre-Flight and Distribution-Readiness") per capabilities.md §CAP-009 — fastlane is the verified automatable mobile distribution CLI; this BC specifies its safe invocation contract |
| L2 Invariants | DI-006 (App Review not automated) |
| Research Grounding | online-services-platform-distribution.md §4.3 (fastlane actions verified against docs.fastlane.tools; confabulated actions explicitly excluded and named) |

## Related BCs

- BC-9.03.001 — steamcmd (PC equivalent)
- BC-9.03.002 — butler (itch.io equivalent)
- BC-9.06.002 — Human-Gated Store Publish Task
