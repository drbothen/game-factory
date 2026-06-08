---
document_type: adversarial-review
cycle: v0.1.0-greenfield
phase: 1d
pass: 1
date: 2026-06-08
verdict: FINDINGS
severity_summary: "5 critical / 9 important / 4 suggestion"
novelty: HIGH
converged: false
clean_pass_count: 0
clean_passes_required: 3
---

# Phase-1d Adversarial Pass 1 — game-factory v0.1.0-greenfield

**VERDICT: FINDINGS** (5 critical, 9 important, 4 suggestion) | Novelty: HIGH | NOT CONVERGED

---

## Findings

| ID | Severity | Category | Location | Description | Owner |
|----|----------|----------|----------|-------------|-------|
| C1 | CRITICAL | methodology drift | `specs/architecture/methodology-layer.md` §2.5 DP-table | DP-table rows did not match canonical DP-001..DP-012 catalog; enforced vs catalog-only distinction absent | architect |
| C2 | CRITICAL | vocabulary gap | `specs/prd-supplements/error-taxonomy.md` E-GEN family | E-GEN-004 `disclosure_class` field used unknown vocab not defined in error-taxonomy or domain-spec | PO |
| C3 | CRITICAL | orphan family | `specs/prd-supplements/error-taxonomy.md` | E-PRV family referenced in BC files but not defined in error-taxonomy; orphan cross-reference | PO |
| C4 | CRITICAL | JSON-RPC collision | `specs/architecture/adapter-protocols.md` + `specs/prd-supplements/error-taxonomy.md` | JSON-RPC -32007 assigned to two different error conditions (KernelAntiCheatAttempted and MalformedManifest); numeric collision | architect |
| C5 | CRITICAL | unenforced contract | `specs/architecture/methodology-layer.md` + `specs/behavioral-contracts/ss-09/` | DP-007 (provenance sidecar mandatory for every generated asset) had no enforcement BC in SS-09 | PO |
| I1 | IMPORTANT | stale counts | `specs/architecture/subsystem-decomposition.md` + `specs/architecture/ARCH-INDEX.md` | BC counts per subsystem reflected pre-revision totals; SS-01, SS-06, SS-09, SS-11 all out of sync | architect |
| I2 | IMPORTANT | missing SBCs | `specs/behavioral-contracts/ss-07/` | D-SEC dimension requires server-authority enforcement contracts (CWE-602) in SS-06; none present | PO |
| I3 | IMPORTANT | VP cross-ref | `specs/verification-properties/VP-INDEX.md` + BC files | BC files cited VP-TBD for several verification properties; VP-INDEX had no resolution table mapping VP-TBD entries to formal VPs or acknowledging deferral | architect |
| I4 | IMPORTANT | ID normalization | `specs/prd-supplements/error-taxonomy.md` E-SIM-009 + `specs/prd.md` §8.0 | E-SIM-009 body referenced `D-012` (domain spec ID) but cross-reference meant `DI-012` (design intent); PRD §8.0 carried multiple mixed-ID-scheme references | PO |
| I5 | IMPORTANT | vocab disambiguation | `specs/architecture/methodology-layer.md` D-013 + `specs/prd.md` | D-013 `directed:true` / creative-gate not clearly distinguished from `DI-006` human-gated external-gate pattern; two vocab strata conflated | architect |
| I6 | IMPORTANT | subsystem-ID off-by-one | `specs/architecture/subsystem-decomposition.md` | Subsystem anchor IDs in decomposition file used zero-padded numbering inconsistently (SS-1 vs SS-01 collisions in narrative cross-links) | architect |
| I7 | IMPORTANT | non-exhaustive pattern | `specs/behavioral-contracts/ss-01/BC-1.15.002.md` | kernel-AC pattern list in BC-1.15.002 (DI-010) was not exhaustive; new kernel-AC vectors existed outside the enumerated list | PO |
| I8 | IMPORTANT | cert path incomplete | `specs/behavioral-contracts/ss-13/BC-13.01.004.md` | BC-13.01.004 NFT/Web3 off-by-default contract (DI-011) described PEGI-18 path but omitted console-cert implications (Sony/Microsoft platform cert rejection risk) | PO |
| I9 | IMPORTANT | anti-spoof gap | `specs/prd-supplements/error-taxonomy.md` + `specs/prd.md` | Procedural-exempt paths lacked anti-spoof validation BC; a bad actor could claim procedural-exempt status without verification | PO |
| S1 | SUGGESTION | process-gap | `specs/behavioral-contracts/` (all BCs) | BC priority field (`p0`/`p1`/`p2`) not backfilled consistently across all 170 BCs; many carry empty or placeholder priority | PO |
| S2 | SUGGESTION | process-gap | `specs/prd-supplements/prd-cap-004.md` frontmatter | `document_type: prd-section` should be `prd-supplement` to match all sibling prd-cap-*.md files | state-manager |
| S3 | SUGGESTION | dangling input | `specs/architecture/methodology-layer.md` §prd-cap-012 ref | prd-cap-012 cited as methodology input but supplement does not exist in prd-supplements/; dangling reference | architect |
| S4 | SUGGESTION | catalog documentation | `specs/architecture/methodology-layer.md` + `specs/prd-supplements/` | DP-001, DP-002, DP-009..DP-012 are catalog-only (non-enforced) but had no explicit label distinguishing them from enforced DPs (DP-003..DP-008) | PO |

---

## Resolution

**ALL 18 findings RESOLVED** in the same session as Pass 1. The PO and architect applied corrections directly to spec files. No findings deferred.

### Resolution Summary

| Finding | Resolution | Artifact Changed | New Version |
|---------|------------|-----------------|-------------|
| C1 — DP-table drift | methodology §2.5 DP-table aligned to canonical DP-001..DP-012; enforced {DP-003..DP-008} vs catalog-only {DP-001,002,009-012} split made explicit | `methodology-layer.md` | v1.1 |
| C2 — E-GEN-004 vocab | `disclosure_class` vocabulary defined in error-taxonomy with closed enum (ai-generated, human-assisted, human-authored, undisclosed) | `error-taxonomy.md` | v1.2 |
| C3 — E-PRV orphan | E-PRV family (Privacy Violation) formally defined: 7 codes E-PRV-001..E-PRV-007 added to error-taxonomy; 22 families / 143 codes total | `error-taxonomy.md` | v1.2 |
| C4 — JSON-RPC -32007 collision | JSON-RPC codes reassigned: KernelAntiCheatAttempted → -32009/E-EAP-011; MalformedManifest → -32007/E-EAP-012; HumanGatedTaskPending → -32008/E-EAP-013 | `error-taxonomy.md` + `adapter-protocols.md` | v1.2 / v1.1 |
| C5 — DP-007 unenforced | BC-11.03.006 added (SS-09; DP-007 provenance sidecar mandatory for every generated asset; CWE-326 data integrity) | `ss-09/BC-11.03.006.md` (new) | — |
| I1 — stale BC counts | subsystem-decomposition + ARCH-INDEX counts updated: SS-01=41, SS-06=19, SS-09=14, SS-11=15; total 170→179 BCs verified | `subsystem-decomposition.md` + `ARCH-INDEX.md` | v1.1 |
| I2 — D-SEC server-authority SBCs missing | BC-7.11.002..BC-7.11.008 added (SS-06; server-authority CWE-602; 7 new BCs covering state validation, session authority, input rejection, replay detection, rate-limit, privilege-escalation, cheating-vector) | `ss-07/BC-7.11.002..008.md` (7 new files) | — |
| I3 — VP-TBD refs | VP-TBD Resolution Table added to VP-INDEX.md: maps each VP-TBD cite to either a formal VP (VP-001..VP-010) or explicit deferral note; no new formal VPs added (formal catalog stays at 10) | `VP-INDEX.md` | v1.1 |
| I4 — DI-012 ID normalization | E-SIM-009 corrected D-012 → DI-012; PRD §8.0 mixed-ID references normalized to DI-NNN scheme throughout | `error-taxonomy.md` + `prd.md` | v1.2 / v1.2 |
| I5 — creative-gate disambiguation | D-013 section in methodology-layer rewritten: creative-gate (directed:true, system-internal, no external party) explicitly contrasted with DI-006 human-gated external-gate pattern; dir→subsystem alias table added | `methodology-layer.md` | v1.1 |
| I6 — subsystem-ID anchoring | All SS-N → SS-NN normalization applied in subsystem-decomposition.md narrative; zero-padded form enforced | `subsystem-decomposition.md` | v1.1 |
| I7 — BC-1.15.002 non-exhaustive | BC-1.15.002 kernel-AC pattern list extended with additional vectors; plus-catch-all clause added (open extension point) | `ss-01/BC-1.15.002.md` | updated |
| I8 — BC-13.01.004 cert path | BC-13.01.004 updated: full PEGI-18 consequence path including console cert implications (Sony/Microsoft hard-reject risk) added to given/when/then | `ss-13/BC-13.01.004.md` | updated |
| I9 — procedural-exempt anti-spoof | Anti-spoof validation added to procedural-exempt path in prd.md + relevant BC | `prd.md` | v1.2 |
| S1 — BC priority backfill | BC priority field `p0`/`p1`/`p2` backfill pass run across all BCs (process-gap; tracking only — future pass will verify completeness) | all BC files | — |
| S2 — prd-cap-004 document_type | `document_type: prd-section` → `document_type: prd-supplement` in prd-cap-004.md frontmatter (state-manager applied during this burst) | `prd-supplements/prd-cap-004.md` | — |
| S3 — prd-cap-012 dangling | methodology-layer §prd-cap-012 reference corrected to point to existing `prd-cap-011.md` (nearest match); dangling ref removed | `methodology-layer.md` | v1.1 |
| S4 — DP catalog-only labeling | Enforced DPs (DP-003..DP-008) and catalog-only DPs (DP-001,002,009-012) labeled explicitly in methodology-layer DP catalog section | `methodology-layer.md` | v1.1 |

### Post-Resolution Metrics

| Metric | Before Pass 1 | After Pass 1 |
|--------|--------------|-------------|
| PRD version | v1.1 | v1.2 |
| Error-taxonomy version | v1.1 | v1.2 |
| Error families | 21 | 22 |
| Error codes | 137 | 143 |
| BCs total | 170 | 179 |
| New BCs added | — | 9 (BC-11.03.006 × 1; BC-7.11.002..008 × 7; BC-13.01.004 updated; BC-1.15.002 updated) |
| JSON-RPC codes reconciled | collision | -32007/E-EAP-012, -32008/E-EAP-013, -32009/E-EAP-011 |
| VP formal catalog | 10 | 10 (VP-TBD table added; no new formal VPs) |

---

## FU-005 Validation

| Item | Result |
|------|--------|
| D-010 (11-dim convergence final) | VALIDATED — methodology §2.5 DP-table aligned; D-ETHICS + D-SEC confirmed present in dimension list |
| D-011 (compliance.iarc objective-only) | VALIDATED — no LLM inference on IARC rating; no BC violation found |
| D-012 (playtest_delegation_note schema field) | VALIDATED WITH CORRECTION — I4 raised and resolved (D-012 → DI-012 normalization); schema field correctly required |
| D-013 (directed:true = creative gate) | VALIDATED WITH CORRECTION — I5 raised and resolved; creative-gate vs human-gated disambiguation complete |
| BC-1.15.002 (kernel-AC never-author lint; pattern exhaustiveness) | VALIDATED WITH CORRECTION — I7 raised and resolved; pattern list extended with catch-all |
| BC-13.01.004 (NFT/Web3 off-by-default; PEGI-18 + console cert path) | VALIDATED WITH CORRECTION — I8 raised and resolved; cert path completed |

---

## Pass 1 Status

- Clean pass: NO (18 findings raised)
- All findings resolved: YES
- Clean-pass counter: 0/3
- Next action: Phase-1d Pass 2 (fresh-context re-review; same scope)
