---
document_type: prd-supplement
level: L3
section: nfr-catalog
version: "1.0"
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

---

## Notes

- **CAP-001, CAP-002, CAP-003** supplements did not define explicit NFR tables. Latency and determinism requirements for those capabilities are embedded in BC postconditions and should be extracted by the architect during Phase 1b.
- **CAP-006, CAP-007, CAP-009, CAP-010, CAP-011, CAP-013, CAP-014** supplements also did not define explicit NFR tables. Known cross-cutting performance constraints for these (e.g., convergence loop evaluation time, conformance suite run time) are flagged as NFR gaps for the architect to quantify in Phase 1b.
- **NFR-011** (engine-neutrality) is a correctness NFR, not a performance NFR. It is listed here because it has a numerical target (0 occurrences) and a machine-checkable validation method.

**Total NFRs in this catalog: 19**
