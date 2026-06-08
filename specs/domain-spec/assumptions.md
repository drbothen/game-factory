---
document_type: domain-spec-section
level: L2
section: assumptions
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: L2-INDEX.md
---

# Assumptions

> **Sharded L2 section (DF-021).** Navigate via `L2-INDEX.md`.
> Every ASM has a validation method. Holdout candidates flagged.

| ID | Assumption | Confidence | Impact if Wrong | Validation Method | Status | Traced To |
|----|-----------|-----------|----------------|-------------------|--------|-----------|
| ASM-001 | Bevy + Rapier reliably provides T1 bitwise-cross-platform determinism when combined with system ordering + seeded RNG + fixed timestep. This is the foundation of the det-sim pilot. | High | CRITICAL — T1 replay regression fails; pilot cannot prove end-to-end. Must downgrade to T2. | Build reference game on Bevy+Rapier; reproduce identical snapshot hash on two different CI runners (Linux + macOS). | unvalidated | ADR-0003, RECONCILIATION §C.1 |
| ASM-002 | GLB (glTF 2.0) is a practically viable engine-neutral asset interchange format for all three founding adapters (Bevy, Unity, Godot) without lossy round-trip. | High | HIGH — asset lane breaks; per-engine import becomes bespoke. | Import a representative GLB (PBR material, skeleton, animations) into each engine adapter and verify quality-gate pass. | unvalidated | RECONCILIATION §9, architecture.md |
| ASM-003 | The JSON-RPC 2.0 transport is sufficient for all adapter protocol operations (build, test, replay, capture) without introducing unacceptable latency or payload size limits. | Medium | MEDIUM — transport must be swapped to gRPC; adapter implementations must be updated. | Load test: drive a full build+test+capture cycle through JSON-RPC adapter; measure round-trip latency under realistic payload sizes. | unvalidated | ADR-0002, engine-adapter-protocol.md |
| ASM-004 | The ~70% vsdd-factory reusable spine can be extracted without breaking changes to the dispatcher, hook SDK, or workflow runner. The extraction boundary is config/content, not code. | High | HIGH — extraction risk is much higher; Layer 1 may need significant rework. | Phase-0 brownfield extraction: run dispatcher + neutral hooks + lobster workflow in game-factory context; confirm no VSDD-specific assumptions surface. Validated conceptually in extraction-boundary-validated.md; confirmed only at runtime. | unvalidated; conceptually validated | extraction-boundary-validated.md §3.5; Holdout candidate: yes |
| ASM-005 | The Steam AI disclosure policy (Jan 2026) and EU AI Act Art. 50 compliance can be fully satisfied by the `disclosure_class` field in the provenance sidecar + `ai-disclosure-manifest` generation without additional regulatory steps. | Medium | HIGH — additional compliance steps required; disclosure pipeline incomplete. | Review primary sources (Steam Steamworks policy; EU AI Act Art. 50 text) at implementation time. Validate manifest format against C2PA Content Credentials spec. | unvalidated; Holdout candidate: yes |
| ASM-006 | Audio middleware licensing (Wwise/FMOD) for individual factory-produced games is solvable either via per-game licenses or via Godot native audio fallback for the det-sim pilot. (OQ-003 in RECONCILIATION is open.) | Low | MEDIUM — audio build automation blocked for Wwise/FMOD; must use Godot native or a different middleware. | Resolve OQ-003 before v1 audio build automation. Evaluate Wwise/FMOD per-game license cost vs Godot native audio feature parity for det-sim pilot genre. | unvalidated; Holdout candidate: yes |
| ASM-007 | mod.io is viable as the reference UGC distribution adapter without incurring unexpected pricing or feature restrictions for console targets. (OQ-008 in RECONCILIATION is open.) | Low | LOW (for v1 — modding is Tier 2 / optional) | Verify mod.io console/Embed Hub pricing tiers before committing to modding pipeline budget. | unvalidated |
| ASM-008 | The Bevy ECS BRP (Bevy Remote Protocol, JSON-RPC) is sufficiently stable in the Bevy version targeted for the pilot to be a reliable `introspect` backend for scenario driving. | Medium | MEDIUM — must build a DIY introspection driver for Bevy; introspect capability degrades to `partial`. | Pin Bevy version + BRP version at pilot start. Run BRP-driven scenario against reference game; verify stability across 10 consecutive scenario executions. | unvalidated |
