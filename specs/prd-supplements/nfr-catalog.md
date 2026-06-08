---
document_type: prd-supplement
level: L3
section: nfr-catalog
version: "1.2"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
traces_to: prd.md
inputs:
  - .factory/specs/prd-supplements/prd-cap-004.md
  - .factory/specs/prd-supplements/prd-cap-005.md
  - .factory/specs/prd-supplements/prd-cap-008-012.md
  - .factory/specs/domain-spec/risks.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# NFR Catalog — game-factory

> **Consolidated from per-supplement NFR sections per DF-021 integrate pass.**
> Per-supplement NFR tables remain canonical in their source files; this catalog
> is the cross-cutting view for architect and performance-engineer consumption.
> NFR-IDs are reassigned here to a sequential `NFR-NNN` scheme for cross-reference
> stability. The source supplement NFR ID is preserved in the Source column.

---

## NFR Table

| NFR-ID | Category | Capability | Requirement | Numerical Target | Validation Method | Source |
|--------|----------|-----------|-------------|-----------------|-------------------|--------|
| NFR-001 | Provenance completeness | CAP-004 | 100% of generated assets have a complete sidecar at ingestion time | 0 missing `disclosure_class` | Quality-gate hook on every ingest; CI blocks on any sidecar schema error | NFR-4-01 |
| NFR-002 | Generation latency | CAP-004 | Asset generation request dispatch to raw-asset available | p50 < 120 s per asset; p99 < 600 s (cloud-api class) | Measured in CI asset-lane smoke test with representative 3D and audio requests | NFR-4-02 |
| NFR-003 | Quality gate pass rate | CAP-004 | Tier-1 prop/texture assets pass quality gate without re-generation on first attempt | ≥ 80% first-attempt pass rate | Measured over 100-asset smoke corpus; logged in quality-gate-report | NFR-4-03 |
| NFR-004 | Blocked-backend enforcement | CAP-004 | 0 generation requests routed to ToS-excluded or litigation-exposed backends in any CI run | 0 exceptions permitted | Integration test: attempt to dispatch to Suno, Udio, OpenArt, Rosebud; assert all four refused | NFR-4-04 |
| NFR-005 | License-gate latency | CAP-004 | Ship-gate license check completes for a 1,000-asset build | < 30 s wall-clock | Benchmarked in ship-gate integration test | NFR-4-05 |
| NFR-006 | Design artifact generation time | CAP-005 | Full design-spec bundle (all sub-artifacts) generation time | < 30 s on reference hardware | Timed CI step | NFR-5.01 |
| NFR-007 | Schema validation reliability | CAP-005 | Valid artifact rejection (false-negative) rate | < 0.1% over 1,000 consecutive runs | Property-based test corpus | NFR-5.02 |
| NFR-008 | Audio bank build throughput | CAP-005 | Audio bank build time for reference game (< 200 events) | < 120 s on CI runner | Timed bank build step | NFR-5.03 |
| NFR-009 | Narrative graph coverage | CAP-005 | Reachability check: every terminal node classified as intended-end or dead-end | 100% classification coverage; 0 unclassified nodes | Graph-traversal CI gate | NFR-5.04 |
| NFR-010 | Cross-discipline dependency validation latency | CAP-005 | Dependency contract validation on merge | < 5 s per contract (< 50 acceptance criteria) | Timed validation step | NFR-5.05 |
| NFR-011 | Engine-neutrality (spec layer) | CAP-005 | Design artifact stack must contain zero engine-specific identifiers | 0 occurrences of engine-specific terms | Lint rule on all spec artifacts | NFR-5.06 |
| NFR-012 | Audio loudness conformance | CAP-005 | Audio build loudness within target band | LUFS within ±2 dB of target for all banks | loudnorm / libebur128 CI check | NFR-5.07 |
| NFR-013 | Playtest protocol completeness | CAP-008 | Protocol scaffold must populate ALL mandatory fields without requiring human completion | 100% mandatory fields populated in generated protocol | Schema validation on every generated protocol | NFR-008-001 |
| NFR-014 | Fun-score hook latency | CAP-008 | Fun-score detection hook must not add > 50 ms to artifact write path on average | p99 ≤ 100 ms added latency | CI performance gate on hook execution | NFR-008-002 |
| NFR-015 | Playtest sign-off auditability | CAP-008 | Every sign-off record must be traceable to a named human reviewer in the project's human-reviewer allowlist | 100% of sign-off records have a valid `reviewer_id` | Schema + registry validation | NFR-008-003 |
| NFR-016 | Canon-KB query performance | CAP-012 | Entity lookup by `entity_id` must complete | p99 ≤ 20 ms for KB with ≤ 10,000 entities | CI performance gate | NFR-012-001 |
| NFR-017 | Continuity check throughput | CAP-012 | 7-check continuity battery for an artifact up to 10,000 words | p95 ≤ 30 s | CI performance gate | NFR-012-002 |
| NFR-018 | Retrieval determinism | CAP-012 | Same `{entity_context_ids, kb_version}` query returns the same subgraph | 100% deterministic | Property-based test | NFR-012-003 |
| NFR-019 | Grounding coverage | CAP-012 | Every generative agent in the required-grounding list must produce artifacts with `grounded_against` tags | 100% of narrative artifacts from required-grounding agents | Schema validation at artifact acceptance | NFR-012-004 |

| NFR-020 | Adapter protocol round-trip latency | CAP-001 | JSON-RPC request dispatch to response received (local stdio transport) | p50 < 5 ms; p99 < 50 ms per call (exclusive of engine operation time) | CI micro-benchmark: 1,000 no-op `ping` calls over stdio; measure round-trip at transport layer | prd-cap-001.md §FU-002 |
| NFR-021 | Engine-neutrality lint gate execution time | CAP-001 | CI lint check scanning factory core source for engine-name references | < 10 s for a ≤ 100,000-line codebase | Timed CI lint step on reference core source tree | prd-cap-001.md §FU-002 |
| NFR-022 | Conformance suite execution time | CAP-002 | Full conformance suite run for one engine adapter against all declared capabilities | p95 < 10 min per adapter on a standard CI runner (4 vCPU / 8 GB) | Timed CI conformance run for Bevy adapter; gate at 10 min | prd-cap-002-003.md §FU-002 (CAP-002) |
| NFR-023 | Conformance drift detection latency | CAP-002 | Scheduled anti-drift re-run on engine minor release | < 15 min end-to-end (trigger → pass/fail verdict) | Timed CI scheduled run | prd-cap-002-003.md §FU-002 (CAP-002) |
| NFR-024 | Replay recording overhead | CAP-003 | Input-stream recording overhead vs. unrecorded run at T1 determinism | < 5% wall-clock overhead | CI benchmark: 10,000-frame deterministic sim; compare recorded vs. unrecorded run | prd-cap-002-003.md §FU-002 (CAP-003) |
| NFR-025 | Replay execution wall-clock time | CAP-003 | Replay of a 10,000-frame session at T1 (exact snapshot-hash mode) | p95 < 2× original recorded wall-clock time | CI replay benchmark; regression flag if ratio exceeds 2× | prd-cap-002-003.md §FU-002 (CAP-003) |
| NFR-026 | Simulation-BC verification throughput | CAP-006 | Machine-verifiable simulation contract battery (economy, damage, FSM, AI — all 11 checks) | p95 < 60 s for a reference game's full sim-BC suite | Timed CI sim-BC gate | prd-cap-006-007.md §FU-002 (CAP-006) |
| NFR-027 | Convergence dimension evaluation latency | CAP-007 | Full 11-dimension convergence evaluation pass (one loop tick) | p95 < 30 s for a fully-populated project state | Timed CI convergence-tick benchmark | prd-cap-006-007.md §FU-002 (CAP-007) |
| NFR-028 | Cert pre-flight checklist generation time | CAP-009 | Machine-checkable cert pre-flight run for one target platform (Steam, PlayStation, Xbox, iOS, Android) | p95 < 5 min per platform on CI | Timed CI cert-preflight step per platform | prd-cap-009-010.md §FU-002 (CAP-009) |
| NFR-029 | Compliance manifest generation time | CAP-010 | AI disclosure manifest + IARC questionnaire auto-fill from provenance sidecar data | p95 < 60 s for a 1,000-asset project | Timed CI compliance-pipeline step | prd-cap-009-010.md §FU-002 (CAP-010) |
| NFR-030 | Ethics contract validation latency | CAP-011 | Monetization-ethics-contract structural validation + dark-pattern scan | p95 < 10 s per contract | Timed CI ethics-gate step | prd-cap-011.md §FU-002 |
| NFR-031 | Ethics adversarial review surface time | CAP-011 | Time from ethics-gate trigger to adversarial review task being surfaced to operator | < 30 s (task creation + notification) | CI integration test: trigger ethics gate; measure time to task visibility | prd-cap-011.md §FU-002 |
| NFR-032 | Genre profile schema validation time | CAP-013 | Genre profile validation including NFT/web3 default enforcement (BC-13.01.004) | p99 < 1 s per profile document | Property-based test: 10,000 random valid/invalid genre profiles; measure validation time | prd-cap-013-014.md §FU-002 (CAP-013) |
| NFR-033 | Inactive lane zero-artifact guarantee verification | CAP-013 | CI check that no artifacts from inactive lanes appear in build output | p99 < 30 s for full artifact manifest scan | Timed CI artifact-scan step | prd-cap-013-014.md §FU-002 (CAP-013) |
| NFR-034 | XR adapter manifest schema validation time | CAP-014 | XR adapter manifest schema validation at adapter registration | p99 < 500 ms per manifest | CI integration test: validate 100 XR manifests; measure median + p99 | prd-cap-013-014.md §FU-002 (CAP-014) |
| NFR-035 | XR seam isolation check | CAP-014 | Verify zero core changes required when XR adapter is added or removed (BC-14.01.004) | 0 core files modified in git diff between XR-adapter-present and XR-adapter-absent builds | Static analysis: git diff check; CI gate | prd-cap-013-014.md §FU-002 (CAP-014) |

---

## Notes

- **NFR-020, NFR-021** cover CAP-001 (adapter protocol round-trip; engine-neutrality lint). These targets are conservative and should be tightened by the architect after the first Bevy adapter milestone.
- **NFR-022, NFR-023** cover CAP-002 (conformance suite). The 10-minute wall-clock target is intentionally generous for Phase 1; it should be profiled and tightened once the full conformance suite is built.
- **NFR-024, NFR-025** cover CAP-003 (replay recording overhead and execution time). The 2× replay-to-original ratio is an upper bound; T1 deterministic replay at exact snapshot-hash should approach 1× on a pinned runner.
- **NFR-026** covers CAP-006 (simulation-BC battery). The 60-second target is for the full suite on a reference game; individual checks (economy conservation, FSM legality) should be < 5 s each.
- **NFR-027** covers CAP-007 (convergence loop tick). The 30-second target enables real-time convergence tracking during CI without blocking the pipeline.
- **NFR-028** covers CAP-009 (cert pre-flight). Mobile platforms (iOS/Android) tend to be faster; console platforms (PS5/XB1) require more checklist items and drive the 5-minute ceiling.
- **NFR-029** covers CAP-010 (compliance pipeline). IARC auto-fill is the slow step; C2PA mark application is near-instantaneous.
- **NFR-030, NFR-031** cover CAP-011 (ethics gate). The 10-second validation target and 30-second surface time ensure the ethics gate does not become a pipeline bottleneck.
- **NFR-032, NFR-033** cover CAP-013 (genre lanes). The < 1 s genre profile validation and < 30 s inactive-lane scan are both CI-gate critical-path items.
- **NFR-034, NFR-035** cover CAP-014 (XR seam). These are seam-contract NFRs; implementation-layer XR performance targets (frame time, reprojection latency) are NOT captured here — those are covered by BC-14.02.001 XR Performance Budget Schema.
- **NFR-011** (engine-neutrality) is a correctness NFR, not a performance NFR. It is listed here because it has a numerical target (0 occurrences) and a machine-checkable validation method.

**Total NFRs in this catalog: 35** (NFR-001..NFR-019 from Phase 1a; NFR-020..NFR-035 added in PRD revision v1.1 to close FU-002)

---

## Changelog

### v1.2 (2026-06-08)

| Change | Detail |
|--------|--------|
| Source column backfilled for NFR-020..035 (I4) | **IMPORTANT:** NFR-020..NFR-035 rows were missing the `Source` column, making the reverse-traceability claim in § NFR Table (lines 24-25) false for 16 of 35 rows. Added `Source` values derived from the originating per-capability supplement file and FU-002 numeric-target pass: NFR-020/021 → `prd-cap-001.md §FU-002`; NFR-022/023 → `prd-cap-002-003.md §FU-002 (CAP-002)`; NFR-024/025 → `prd-cap-002-003.md §FU-002 (CAP-003)`; NFR-026 → `prd-cap-006-007.md §FU-002 (CAP-006)`; NFR-027 → `prd-cap-006-007.md §FU-002 (CAP-007)`; NFR-028 → `prd-cap-009-010.md §FU-002 (CAP-009)`; NFR-029 → `prd-cap-009-010.md §FU-002 (CAP-010)`; NFR-030/031 → `prd-cap-011.md §FU-002`; NFR-032/033 → `prd-cap-013-014.md §FU-002 (CAP-013)`; NFR-034/035 → `prd-cap-013-014.md §FU-002 (CAP-014)`. All 35 rows now have a complete 7-column structure. |
