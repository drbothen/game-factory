---
document_type: dtu-assessment
level: L4
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
DTU_REQUIRED: true
traces_to: ARCH-INDEX.md
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/architecture/layered-architecture.md
  - .factory/specs/architecture/subsystem-decomposition.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# DTU Assessment — game-factory

## DTU_REQUIRED: true

**Rationale.** game-factory does not clone third-party service APIs in the
vsdd-factory DTU sense (the product does not shadow external SaaS boundaries as its
primary testing strategy). Instead, game-factory's testing fidelity depends on
**two analogous isolation mechanisms** that serve the same purpose — preventing
external runtime dependencies from corrupting regression signals:

1. **Deterministic Replay Harness** (SS-02) — the game-factory's direct DTU analog.
   Records real engine execution, then replays it without the live engine, diffing
   sim state. This is the regression backbone.
2. **Engine Conformance Test Doubles** — in-process stubs and protocol-level doubles
   that allow the factory core (Layers 1-2) to be tested without a live engine
   process attached.

Both mechanisms must be built and validated before the pipeline is reliable.
`DTU_REQUIRED: true` governs both.

---

## Integration Surface Assessment

### 1. Engine Adapters (INBOUND — engine runtime → factory)

**Category:** Inbound data sources (engine process → adapter → factory core via JSON-RPC)

**Services assessed:**

| Engine | Fidelity | DTU Strategy | Rationale |
|--------|----------|--------------|-----------|
| Bevy adapter (T1) | L4 Adversarial | **Golden-State Harness Clone** | bitwise-cross-platform determinism makes a golden-state double feasible and load-bearing; regression at this tier is bitwise; any desync = defect |
| Unity adapter (T2) | L3 Behavioral | **Pinned-Runner Double** | same-machine only; double must pin CI image + engine version; floating runner invalidates the double |
| Godot adapter (T3) | L2 Stateful | **Tolerance-Window Double** | no physics determinism guarantee; double emits metric snapshots within tolerance band; not bitwise |
| Future adapters | L1 API Shape | **Protocol Stub** | unverified tier; protocol-level stub validates message framing before full adapter exists |

**Decision:** Produce one `engine-adapter-conformance-double` per tier, not per engine.
The conformance suite tests real adapters; the doubles enable Layer 1-2 CI without
live engine processes.

---

### 2. Asset Generation Backends (OUTBOUND — factory → generative AI APIs)

**Category:** Outbound operations (factory dispatches generation requests to external APIs)

**Services assessed:**

| Backend | Asset Class | Risk Tier | DTU Strategy |
|---------|-------------|-----------|--------------|
| Tripo / Rodin / Meshy | 3D mesh | Tier-1 (indemnified) | **L2 Stateful Clone** — record request/response pairs per asset class; stub returns recorded sidecar + mesh path |
| Stable Audio / AIVA / Soundraw | Music/audio | Tier-1 (licensed) | **L2 Stateful Clone** — audio backend stub returns recorded provenance sidecar; loudness/true-peak values stable |
| ElevenLabs / Replica | Voice | Tier-2 (consent required) | **L3 Behavioral Clone** — includes consent-ref trigger path; SAG-AFTRA human-gated flow must fire when `likeness_consent_ref != null` |
| Adobe Firefly | Image (IP-sensitive) | Tier-1 (indemnified) | **L2 Stateful Clone** — image hash + sidecar |
| Suno / Udio | Music | BLOCKED (DI-009) | **No DTU clone needed** — routing to these backends is a factory defect; test is a negative-path assertion |

**Decision:** Asset backend stubs must preserve provenance sidecar structure faithfully;
the compliance pipeline reads sidecar fields — a stub that omits `disclosure_class` will
mask R-014 (EU AI Act) defects.

---

### 3. Distribution CLIs (OUTBOUND — factory → store/platform CLIs)

**Category:** Outbound operations (CLI execution into external stores)

| Tool | Platform | DTU Strategy | Key concern |
|------|----------|--------------|-------------|
| `steamcmd` (depot upload) | Steam (PC) | **L3 Behavioral Clone** | VERIFIED CLI; clone must validate non-interactive execution path and emit verifiable build record |
| `butler` (itch.io) | itch.io | **L2 Stateful Clone** | VERIFIED CLI; delta-patching path must be exercised |
| `fastlane` | Mobile (iOS/Android) | **L3 Behavioral Clone** | VERIFIED; AppStore/Play API auth + upload flow; COPPA flags must flow through |
| GDK Submission Validator | Xbox | **L2 Stateful Clone** | cert pre-flight validator; clone validates that failure responses are correctly surfaced |
| Console cert sign-off | PSN / Nintendo / Xbox | **Human-gated** (no clone) | NDA-gated; factory surfaces checklist task only; no automation beyond preflight |
| Store publish / pricing | All stores | **Human-gated** (no clone) | Final publish is `human-gated` by DI-006; the clone covers upload, not publish |

**Decision:** Distribution adapter doubles must exercise the human-gated task surfacing
path — i.e., confirm that the factory surfaces the correct checklist and does NOT attempt
to complete the human task autonomously.

---

### 4. Online Services / BaaS (BIDIRECTIONAL — factory wires BaaS; game runtime uses it)

**Category:** Persistence and state (identity, saves, leaderboards, matchmaking, entitlements)

| Service | Role | DTU Strategy |
|---------|------|--------------|
| Nakama (reference, self-hostable) | Identity/saves/leaderboards/matchmaking | **L3 Behavioral Clone** — self-hostable means Docker-in-CI is feasible; Nakama is the preferred testable reference |
| EOS (Epic Online Services) | Cross-platform (free, VERIFIED) | **L2 Stateful Clone** — EOS SDK has test mode; entitlement + leaderboard paths cloned |
| PlayFab | Managed BaaS ($0 < 100K) | **L2 Stateful Clone** — API key + sandbox environment |
| mod.io | UGC distribution (VERIFIED) | **L3 Behavioral Clone** — REST API; round-trip conformance (BC-13.03.004); genre-gated (SS-11) |

---

### 5. Observability Exports (OUTBOUND — factory → monitoring)

**Category:** Observability and export

| Service | DTU Strategy | Rationale |
|---------|--------------|-----------|
| OpenTelemetry OTLP sinks (inherited from vsdd spine) | REUSE (sinks are already tested in vsdd-factory) | Telemetry sinks are REUSE components; no new clone needed |
| Crash reporting (sentry-cli / Crashlytics) | **L1 API Shape** (low frequency, read/write) | Symbol upload CLI; shallow stub sufficient |
| C2PA mark embedding | **L2 Stateful Clone** | EU AI Act Art. 50 requires C2PA marks on generated content; clone must validate mark presence and format |

---

### 6. Enrichment and Lookup (EXTERNAL → factory decisions)

**Category:** Enrichment and lookup

| Service | Use | DTU Strategy |
|---------|-----|--------------|
| IARC ratings API | Objective questionnaire auto-fill (CAP-010) | **L2 Stateful Clone** — auto-fill answers; human-gated terminal step preserved |
| Platform policy docs (Steam, Apple, Google) | Compliance-checklist generation | **L1 API Shape** — machine-readable rules feeds; content cached per release cycle; R-009/R-016 require re-verification each cycle |
| PEGI / ESRB / USK rating rules | Content-descriptor min-rating rules | **L1 API Shape** — static rules DB; snapshot at build time; not a live API |

---

## Clone / Twin List (DTU_REQUIRED: true)

The following are the required doubles to build, in priority order:

| Clone ID | Name | Type | Subsystem | Priority | Complexity |
|----------|------|------|-----------|----------|------------|
| DTU-01 | T1 Golden-State Engine Double (Bevy) | Replay harness golden-state | SS-02 | P0 | L4 Adversarial |
| DTU-02 | T2 Pinned-Runner Engine Double (Unity) | Replay harness pinned-runner | SS-02 | P0 | L3 Behavioral |
| DTU-03 | Engine Adapter Conformance Double (protocol-level) | JSON-RPC stub | SS-01 | P0 | L2 Stateful |
| DTU-04 | Asset Backend Stub Set (3D/audio/image) | Provenance-preserving generation stubs | SS-03 | P0 | L2 Stateful |
| DTU-05 | Voice Backend Double with SAG-AFTRA path | Consent-trigger behavioral clone | SS-03 | P0 | L3 Behavioral |
| DTU-06 | steamcmd / butler Distribution Clone | Non-interactive upload + build-record | SS-08 | P1 | L3 Behavioral |
| DTU-07 | Human-Gated Task Surfacing Validator | Confirms task surface, never auto-completes | SS-08 | P1 | L2 Stateful |
| DTU-08 | Nakama BaaS Double (Docker-in-CI) | Online services behavioral clone | SS-11 | P2 | L3 Behavioral |
| DTU-09 | C2PA Mark Embedding Validator | Confirms mark presence + format | SS-08 | P1 | L2 Stateful |
| DTU-10 | T3 Tolerance-Window Engine Double (Godot) | Metric-snapshot comparison stub | SS-02 | P1 | L2 Stateful |

---

## Relationship to ADR-0003 (Determinism Tiers)

DTU-01, DTU-02, and DTU-10 directly implement the three determinism tiers declared in
ADR-0003. The clone set is the conformance verification mechanism for the tier declarations:
a T1 adapter that cannot produce an identical golden-state hash across two CI runners
fails its tier claim. DTU-01 is the most load-bearing double in the system — it is the
mechanism by which "100% regression detection on injected sim changes" (product brief
§Success Criteria) is verifiable.

---

## Out of Scope for DTU

The following external dependencies require no clone:
- **REUSE vsdd-factory telemetry sinks** — already tested upstream; game-factory inherits.
- **Blocked backends (Suno/Udio)** — routing to these is a defect; the test is a
  negative-path assertion in the routing hook, not a clone.
- **NDA-gated console cert / PSN / Nintendo** — `human-gated` by DI-006; no automation
  to clone; human task surfacing is tested via DTU-07.
