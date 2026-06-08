# Decision 0002 — Protocol & conformance stance (hybrid of LSP + Terraform + CRI/CSI)

**Status:** Accepted
**Date:** 2026-06-07
**Driver:** `planning/research/prior-art-and-precedents.md` §3 + `RECONCILIATION.md` §C.4

## Context

The engine adapter protocol (Layer 3) needs a concrete stance on three things:
versioning, capability negotiation, and drift prevention. Research verified four
precedents (LSP, Terraform providers, Kubernetes CRI/CSI, Testcontainers) against
those criteria. They are complementary, and one is a cautionary anti-pattern.

## Decision

Adopt a **hybrid**:

1. **Capability negotiation — LSP-style.** Adapters declare an
   `engineCapabilities` manifest at handshake; the core requests only what an
   adapter supports; unsupported operations return an explicit "unsupported"
   error (graceful degradation, no lowest-common-denominator). Allow
   **dynamic registration** (capabilities may resolve after project inspection,
   e.g. "this Unity project uses the new Input System → replay: full").

2. **Versioning + acceptance testing — Terraform-style.** A versioned adapter
   protocol with an explicit **core ↔ adapter compatibility matrix**. Acceptance
   tests exercise **real engine build/test/replay through the real adapter**, not
   abstract protocol messages, CI-matrixed across engine versions.

3. **Drift prevention — CRI/CSI-style (LOAD-BEARING).** A
   **capability-gated conformance suite** (`critest`/`csi-sanity` pattern):
   adapters declare capability flags; the suite runs only the tests for declared
   capabilities. This is the mechanism that lets backends differ while preventing
   drift. To be an accepted adapter you pass conformance for what you claim.

4. **Anti-pattern to avoid — Testcontainers.** It works only because it
   standardizes on one de facto backend (Docker) and skips formal conformance.
   Our backends (four genuinely different engines + heterogeneous determinism)
   are not homogeneous, so "common API + env checks, no conformance suite" is
   explicitly **insufficient** and rejected.

## Rationale

Each precedent validates exactly one pillar and none covers all three well:
LSP has the best negotiation but **no conformance suite (a documented drift
risk)**; Terraform has rigorous acceptance testing but static capabilities;
CRI/CSI has the strongest conformance; Testcontainers shows what breaks when you
skip conformance with heterogeneous backends. Taking the best pillar from each is
strictly better than copying any single one.

## Consequences

- The conformance suite + reference mini-game (already planned) becomes the
  **central anti-drift artifact**, not an optional extra.
- Protocol transport: gRPC or JSON-RPC 2.0 (both precedented; choice deferred to
  protocol-schema design — JSON-RPC favored for parity with Bevy's BRP and LSP).
- "Implement adapter + pass conformance for declared capabilities" is the formal
  bar for adding any new engine.

## Alternatives rejected

- **LSP-only:** no conformance suite → drift (its own documented weakness).
- **Testcontainers-style:** insufficient for heterogeneous engine backends.
