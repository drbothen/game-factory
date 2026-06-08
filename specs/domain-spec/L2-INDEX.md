---
document_type: domain-spec-index
level: L2
version: "1.0"
status: draft
producer: business-analyst
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/product-brief.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/phase-0-ingestion/extraction-boundary-validated.md
  - .factory/planning/design/architecture.md
  - .factory/planning/design/engine-adapter-protocol.md
  - .factory/planning/decisions/0001-founding-engine-pair.md
  - .factory/planning/decisions/0002-protocol-and-conformance-stance.md
  - .factory/planning/decisions/0003-determinism-tier-capability.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: .factory/specs/product-brief.md
sections:
  - ubiquitous-language.md
  - entities.md
  - capabilities.md
  - processes.md
  - invariants.md
  - assumptions.md
  - risks.md
  - failure-modes.md
  - differentiators.md
---

# L2 Domain Specification: game-factory

> **Sharded artifact (DF-021).** This index provides navigation and summary.
> Detail lives in per-section files listed below. Each section targets
> 800-1,200 tokens for optimal LLM consumption.

## Domain Summary

game-factory is a Dark Factory for AAA game development: a lights-out, multi-agent
production system that applies vsdd-factory governance rigor to games and generates
every artifact a game requires — design, art, audio, narrative, code, QA artifacts —
at AAA quality, for any genre, against any engine via four adapter seams (engine /
asset / distribution / XR) plus a canon knowledge-base.

## Document Map

| Section | File | Tokens | Primary Consumer | Purpose |
|---------|------|--------|-----------------|---------|
| Ubiquitous Language | ubiquitous-language.md | ~1,100 | All agents | Glossary of load-bearing domain terms |
| Domain Entities | entities.md | ~1,100 | architect, product-owner | Entity model with relationships and attributes |
| Domain Capabilities | capabilities.md | ~1,100 | product-owner, story-writer | CAP-NNN catalog |
| Domain Processes | processes.md | ~1,100 | architect, story-writer | Core workflows and state machines |
| Domain Invariants | invariants.md | ~1,000 | product-owner, architect | DI-NNN business rules |
| Assumptions | assumptions.md | ~900 | product-owner, test-writer | ASM-NNN with validation methods |
| Risks | risks.md | ~1,100 | product-owner, architect | R-NNN risk register |
| Failure Modes | failure-modes.md | ~900 | architect, test-writer | FM-NNN runtime failure catalog |
| Differentiators | differentiators.md | ~700 | product-owner | Competitive advantage → CAP traceability |

## Cross-References

| If you need... | Read these together |
|----------------|-------------------|
| PRD / BC creation input | capabilities.md + invariants.md + assumptions.md + risks.md |
| Architecture design input | entities.md + capabilities.md + invariants.md + failure-modes.md |
| Story decomposition input | capabilities.md + processes.md |
| Holdout / playtest scenario generation | assumptions.md + risks.md + failure-modes.md |
| NFR derivation | risks.md + failure-modes.md + invariants.md |
| Full domain review (adversary / spec-reviewer) | ALL sections |
| Adapter onboarding spec input | entities.md + capabilities.md + processes.md + invariants.md |

## ID Registry Summary

| ID Format | Count | Section |
|-----------|-------|---------|
| CAP-NNN | 14 | capabilities.md |
| DI-NNN | 12 | invariants.md |
| ASM-NNN | 8 | assumptions.md |
| R-NNN | 17 | risks.md |
| FM-NNN | 10 | failure-modes.md |
| Glossary terms | 42 | ubiquitous-language.md |
| Entities | 18 | entities.md |
| Processes | 6 | processes.md |

## Priority Distribution

| Priority | Count | Items |
|----------|-------|-------|
| P0 (must-have) | 7 | CAP-001, CAP-002, CAP-003, CAP-004, CAP-005, CAP-006, CAP-007 |
| P1 (should-have) | 5 | CAP-008, CAP-009, CAP-010, CAP-011, CAP-012 |
| P2 (nice-to-have) | 2 | CAP-013, CAP-014 |
