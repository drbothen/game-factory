---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
priority: P0
lifecycle_status: active
introduced: v0.1.0-prd-rev-1
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-1.15.002: Factory Core Output Contains No Kernel-Mode or Ring-0 Authored Code (Never-Author Enforcement)

## Description

The factory must never autonomously produce kernel-mode drivers, ring-0 code, eBPF
in-kernel programs, or kernel-level security modules as part of any game artifact output.
Anti-cheat integration is strictly wrap-only: the factory may reference external
commercially-licensed anti-cheat SDKs (EAC/EOS default, BattlEye commercial) in
integration scaffolding but may not author the kernel driver code itself. This BC enforces
DI-010 at the factory output level via static analysis on generated artifacts.

This is a lint-class behavioral contract: it is verified by scanning all generated
factory output artifacts for kernel-mode code signatures (cross-platform: Windows,
Linux, macOS) and for precompiled kernel binary blobs, not by runtime observation.

## Preconditions

1. A factory output artifact bundle (generated code, integration scaffolding, build
   scripts, adapter output) is present and staged for ingest or CI gate.
2. The output bundle has a declared bundle type (game code, integration scaffold,
   engine adapter, CI script, etc.).
3. A lint configuration for anti-cheat kernel-code patterns is loaded (list of
   forbidden patterns: see Postconditions §1).

## Postconditions

1. No generated source file in the factory output bundle contains any of the following
   patterns:
   - **Windows kernel-mode driver entry points:** `DriverEntry`, `DRIVER_OBJECT`,
     `IoCreateDevice`, `KernelCallbackTable`, `ZwQuerySystemInformation` (kernel variant),
     `PsLookupProcessByProcessId` (ring-0 context), `MmMapLockedPagesSpecifyCache`
   - **Linux kernel module macros:** `module_init(`, `module_exit(`, `MODULE_LICENSE(`,
     `EXPORT_SYMBOL_GPL(`
   - **Kernel SDK headers:** `#include <ntddk.h>`, `#include <wdm.h>`,
     `#include <linux/module.h>`
   - **macOS kernel extension / DriverKit identifiers:** `IOKit` framework imports used in
     ring-0 context (KEXT code), `kext` bundle declarations, `com.apple.kpi.*` bundle
     dependencies (these are KEXT kernel interface declarations), `IOKitLib` used as a
     kernel extension build target (user-space `IOKitLib` use-mode API calls are permitted;
     only KEXT compilation targets are blocked)
   - **eBPF in-kernel programs:** `bpf_prog` struct definitions, `SEC("kprobe/")`,
     `SEC("tracepoint/")`, `SEC("xdp")` section annotations in C source (these mark
     in-kernel eBPF programs, distinct from user-space eBPF loader code)
   - Explicit ring-0 privilege escalation invocations in generated code
2. No generated `CMakeLists.txt`, `build.gradle`, `cargo build` script, or equivalent
   links against kernel-mode driver build targets (`/SUBSYSTEM:NATIVE`, `KERNEL_DRIVER`
   WDK configs).
3. **Binary artifact scan:** No precompiled kernel binary blobs (`.sys` Windows kernel
   driver, `.ko` Linux kernel object, `.kext` macOS kernel extension bundle) are checked
   into the factory output bundle as artifacts. The CI gate performs binary-type
   inspection (file header/magic-byte scan) on all binary files in the output bundle.
   If a binary matching these signatures is detected, the gate emits `E-EAP-011` regardless
   of whether source code is present.
4. The factory CI gate runs this lint check on every artifact bundle before acceptance
   and returns exit code 1 with an `E-EAP-011` error if any forbidden pattern is detected.
5. External anti-cheat SDK references (e.g., `EAC SDK`, `BattlEye SDK`) may appear in
   generated integration scaffolding only as wrapper calls to the SDK's user-mode API
   surface — not as kernel driver compilation targets.
6. **`build.rs` FFI scope (EC-005 residual gap closure):** A generated Rust `build.rs`
   that calls out to an external kernel-driver toolchain (e.g., WDK build scripts, KEXT
   build scripts, Linux kernel module Makefile invocations) is a forbidden pattern. The
   lint checks `build.rs` for shell invocations that reference WDK/KEXT/kernel-module
   build tools. User-mode FFI calls (e.g., calling `EAC_Client_Init()` via user-mode
   library linkage) remain permitted.

## Invariants

1. The factory never generates kernel driver source code regardless of game genre,
   anti-cheat requirement, or explicit project configuration.
2. Riot Vanguard kernel driver is never referenced as a build target (not licensable per
   Brief §Out of Scope).
3. This constraint is not overridable by genre profile, flag, or agent instruction — it
   is a factory-level invariant enforcing DI-010.
4. The lint check pattern list may be extended (additive) but no existing pattern may be
   removed from the blocklist without a human-approved RFC.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Project config declares `anti_cheat: eac` (Easy Anti-Cheat) | Factory generates user-mode EAC SDK wrapper scaffolding only; no ring-0 code generated; passes lint |
| EC-002 | Artist provides a PRD that explicitly requests "implement kernel anti-cheat" | Factory rejects the request with E-EAP-011 and surfaces a human-gated task explaining the constraint; does not attempt to fulfill it |
| EC-003 | Generated integration code includes `#include "EAC/eac_client.h"` (user-mode EAC SDK header) | This is permitted — user-mode SDK includes are not blocked; only kernel-mode driver headers are blocked |
| EC-004 | Docs artifact generated by factory contains the word "ntddk.h" in a description string | Documentation content is excluded from the executable-code scan; only generated source/build files are checked |
| EC-005 | Factory generates a Rust `build.rs` that calls EAC user-mode FFI | Permitted; user-mode FFI linkage is not a kernel-mode pattern. A `build.rs` that instead shells out to a WDK Makefile or KEXT build script is blocked (Postcondition §6). |
| EC-006 | macOS plugin code imports `IOKit/IOKitLib.h` for user-space hardware enumeration | Permitted — `IOKitLib.h` in user-space context is a user-mode API. Blocked only when the artifact is compiled as a KEXT bundle (has `com.apple.kpi.*` dependency or `kext` bundle type declaration) |
| EC-007 | eBPF user-space loader code is generated (calls `bpf_prog_load()` from user space) | Permitted — user-space eBPF loader calls are not in-kernel programs. Only `SEC("kprobe/")` and similar in-kernel program annotations are blocked. |
| EC-008 | Factory output bundle contains a pre-built `.sys` file from EAC SDK (shipped binary) | BLOCKED: binary artifact scan flags `.sys` regardless of source. If the project legitimately ships a vendor-provided EAC `.sys`, this must be declared as an exclusion in the lint config with a human-approved rationale; the factory does not author it. Exclusion requires sign-off from the security-review gate. |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| Generated integration scaffold for `anti_cheat: eac` with no ring-0 code | Lint gate passes; output bundle accepted | happy-path |
| Generated source file containing `DriverEntry(IN PDRIVER_OBJECT DriverObject, ...)` | CI lint gate fails; `E-EAP-011` emitted; bundle rejected | error |
| Generated `CMakeLists.txt` with `/SUBSYSTEM:NATIVE` flag | CI lint gate fails; `E-EAP-011` emitted | error |
| Generated build script including `#include <ntddk.h>` | CI lint gate fails; `E-EAP-011` emitted | error |
| Generated EAC wrapper calling `EAC_Client_Init()` (user-mode SDK function) | Lint gate passes — user-mode function, not kernel entry point | happy-path |
| PRD request for Riot Vanguard kernel driver integration | Factory returns E-EAP-011 at plan time; human task surfaced | error |
| Generated macOS plugin importing `IOKitLib.h` in user-space context | Lint gate passes — user-space IOKit is permitted | happy-path |
| Generated macOS code with `com.apple.kpi.unsupported` bundle dependency | CI lint gate fails; `E-EAP-011` emitted — KEXT kernel interface dependency | error |
| Generated C file with `SEC("kprobe/tcp_sendmsg")` eBPF section annotation | CI lint gate fails; `E-EAP-011` emitted — in-kernel eBPF program | error |
| Output bundle contains `anticheat.sys` binary | CI binary scan fails; `E-EAP-011` emitted — precompiled `.sys` binary artifact detected | error |
| Generated `build.rs` shells out to WDK `makefile.inc` | CI lint gate fails; `E-EAP-011` emitted — build.rs invoking kernel-driver toolchain | error |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-060 | No kernel-mode driver entry point patterns appear in any generated source artifact | Static lint: pattern match over generated output bundle before CI acceptance |
| VP-TBD-061 | Kernel-mode build configs (WDK `/SUBSYSTEM:NATIVE`) never appear in generated build scripts | Static lint: build config scanner |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — kernel anti-cheat driver authoring would be an engine/platform-specific artifact; this BC enforces that factory-generated build artifacts stay within the engine adapter protocol surface and never cross into kernel-driver territory, which is structurally part of the "what the factory can build and test" boundary |
| L2 Domain Invariants | DI-010 (Kernel Anti-Cheat Is Never Autonomously Authored — THIS BC IS THE PRIMARY ENFORCEMENT OF DI-010); DI-001 (factory core never names a specific engine — kernel drivers are even more platform-specific than engine SDKs) |
| Architecture Anchors | SS-01 (Engine-Adapter Protocol subsystem); ADR-0006 (security-invariants convergence dimension D-SEC) |
| Architecture Module | Factory Core Output Linting (Layers 1-2 CI gate) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.15.001 — sibling (this BC extends the "factory core never names a specific engine" lint to cover factory-generated output; BC-1.15.001 covers the factory core source itself)
- BC-7.11.001 — depends on (Security-Invariants convergence dimension evaluation includes this anti-cheat never-author check as one of its signals)

## Architecture Anchors

- `specs/architecture/adrs/ADR-0006-11-dimension-convergence-model.md` — D-SEC dimension includes security invariants; DI-010 feeds into D-SEC
- `specs/domain-spec/invariants.md` §DI-010 — source of invariant
- `planning/research/aaa/AAA-RECONCILIATION.md §12 R-017` — post-CrowdStrike kernel AC risk assessment
