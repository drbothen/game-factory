---
cycle: v0.1.0-greenfield
document: adversarial-review
pass: 13
phase: 1d
date: 2026-06-08
verdict: FINDINGS
novelty: HIGH
converged: false
clean_pass_counter: 0/3
findings_summary: "1 critical, 1 important, 0 observations"
---

# Phase-1d Adversarial Review — Pass 13 (candidate clean #1)

**Verdict:** FINDINGS (1 critical, 1 important, 0 observations)
**Novelty:** HIGH — C13-01 is the first critical finding since Pass 5 AND the first finding
located entirely OUTSIDE the status-vocabulary subsystem. It exposes a structural gap: a
Tier-1 v1 ship-prerequisite capability (online-services/BaaS) mandated in the product brief
with a designated DTU clone (DTU-08 Nakama) had zero spec coverage — no capability entry in
CAP-001..014, no BCs, no adapter seam (ADR-0004 titled "four-seam" but body described a
fifth seam that was never formalized), no error family, and an orphaned DTU clone. The
resolution required human-approved scope completion: authoring CAP-015 Online-Services
Adapter as a full new subsystem SS-13 with 12 BCs, a fifth adapter seam, the E-OSVC error
family (15 codes), and DTU-08 wiring. This is a major spec expansion, not a terminology
correction. I13-01 is a direct consequence: one studio role's artifacts had been assigned
to SS-11 whose scope never owned them; reassignment to SS-13 closes the orphan anchor.
**Convergence status:** CONSECUTIVE-CLEAN COUNTER STAYS 0/3. Both findings fully resolved
by scope completion. Counter does not advance. Next = Pass 14 (must audit new CAP-015
surface as a fresh candidate clean #1).
**Severity trajectory:** 5C → 3C → 1C → 2C → 3C → 0C → CLEAN → FINDINGS (reset) →
FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3) → FINDINGS (0/3)

---

## Findings

### C13-01 (CRITICAL) — Online-services/BaaS capability entirely absent from spec despite being a Tier-1 v1 ship-prerequisite

**Class:** capability gap; orphan DTU clone; ADR self-contradiction; missing adapter seam
**Locus:** capabilities.md (CAP-001..014); adapter-protocols.md §6; ADR-0004; dtu-assessment.md DTU-08; error-taxonomy.md; studio-of-agents.md role 58; subsystem-decomposition.md; BC-INDEX.md; prd.md
**Finding:** The product brief §4.2 ("Capability Matrix") and §10 ("External Service Dependencies") both
list online-services/BaaS (Nakama) as a Tier-1 v1 ship-prerequisite — the same tier as the engine
adapters. The DTU assessment produced at architecture time correctly registered DTU-08 as a required
Nakama clone. Yet the spec layer contained zero coverage:

1. **No capability entry.** CAP-001..014 enumerated 14 capabilities; online-services was not among them.
2. **No behavioral contracts.** The BC-INDEX listed 178 BCs across SS-01..SS-12; no SS covered
   online-services adapter behavior (session/cloud-save/leaderboards/matchmaking/entitlements/remote-config).
3. **No adapter seam.** ADR-0004 was titled "Four-Seam Adapter Model" (engine, asset, compliance,
   analytics) but its own body §3 listed five seams including "Online-Services Adapter Seam" as
   the fifth entry — a self-contradiction that survived 12 passes.
4. **No error family.** error-taxonomy.md had no E-OSVC family; online-service fault codes were absent.
5. **Orphan DTU clone.** DTU-08 (Nakama) appeared in dtu-assessment.md with no governing spec,
   capability, or BC anchor. Nothing validated what DTU-08 was cloning FOR.
6. **Studio role 58 (backend-services-engineer) artifact orphan.** The role listed two
   artifacts — `online-services-spec` and `remote-config-contract` — assigned to SS-11
   (distribution) whose scope never owned them. See I13-01.

The gap was not a deferred feature: the brief explicitly classes online-services as a
non-negotiable v1 deliverable with a mandatory conformance check before ship.

**Human decision:** Build it now, faithful to the product brief. No deferral.

**Resolution:** Authored CAP-015 Online-Services Adapter as a complete new subsystem SS-13:

- **capabilities.md** — CAP-015 added (online-services adapter; Tier-1 v1; BaaS-agnostic;
  conformance-testable surface: identity/cloud_save/leaderboards/matchmaking/entitlements/
  remote_config; `serverAuthoritative` required for leaderboards and entitlements; `offlineProject`
  off-by-default and produces zero artifacts in offline mode).
- **prd-cap-015.md** — new PRD supplement, SS-13 scope; session/cloud-save/leaderboard/matchmaking/
  entitlement/remote-config contract surfaces; offline guard; conformance suite seam.
- **behavioral-contracts/ss-15/** — 12 new BCs (BC-15.01.001 through BC-15.11.001):
  - BC-15.01.001 — Online-services adapter init / session handshake (P0)
  - BC-15.02.001 — Cloud-save write contract (P0)
  - BC-15.02.002 — Cloud-save read / conflict resolution (P0)
  - BC-15.03.001 — Leaderboard submit with server-authority guard (P0)
  - BC-15.04.001 — Matchmaking session create contract (P0)
  - BC-15.04.002 — Matchmaking session join / leave contract (P1)
  - BC-15.05.001 — Entitlement check contract with server-authority guard (P0)
  - BC-15.06.001 — Remote-config fetch + stale-fallback contract (P0)
  - BC-15.07.001 — Offline-mode guard: adapter produces zero network artifacts (P0)
  - BC-15.08.001 — Conformance test suite seam: all methods testable against DTU-08 (P1)
  - BC-15.09.001 — Error propagation contract: all E-OSVC codes surfaced to caller (P1)
  - BC-15.11.001 — BaaS-swap guarantee: adapter implementation replaceable without caller changes (P0)
  Priority breakdown: 9 P0 / 3 P1.
- **adapter-protocols.md §6 (v1.2)** — Fifth seam formally defined:
  "Online-Services Adapter Seam" — capability surface: identity, cloud_save, leaderboards,
  matchmaking, entitlements, remote_config, conformance; `serverAuthoritative: bool` required
  for leaderboards and entitlements; `offlineProject: bool` off-by-default (zero-artifact mode);
  conformance suite validates all six surfaces against DTU-08 Nakama clone.
- **ADR-0004 (v1.1)** — Title changed from "Four-Seam Adapter Model" to "Five-Seam Adapter Model";
  §3 body was already correct (five seams listed); title reconciled to body. Self-contradiction closed.
- **error-taxonomy.md (v1.9)** — E-OSVC family registered (15 codes: E-OSVC-001..015 covering
  session-auth-failure, cloud-save-conflict, leaderboard-server-rejected, matchmaking-timeout,
  entitlement-server-rejected, remote-config-stale-fallback, offline-guard-blocked, conformance-
  suite-failure, adapter-not-initialized, invalid-session-token, cloud-save-quota-exceeded,
  matchmaking-no-peers, entitlement-cache-miss, remote-config-parse-error, baas-swap-contract-
  violation). Total error codes: 198 → 213 (204 active; 9 retired = E-GEN family).
- **subsystem-decomposition.md (v1.6)** — SS-13 Online-Services Adapter added; Priority Summary
  updated (P0: 117→126, P1: 39→42, P2: 22 unchanged; Grand total: 178→190).
- **ARCH-INDEX.md (v1.8)** — SS-13 row added; total_bcs: 178→190; subsystem count 12→13.
- **studio-of-agents.md (v1.3)** — SS-13 column added to §3 table; role 58
  (backend-services-engineer) reassigned from SS-11 to SS-13 (see I13-01 resolution).
  §3 SS-11 total corrected 11→10; SS-13 total = 1. §6 tier counts unchanged (Tier 1=53, Tier 2=13).
- **dtu-assessment.md (v1.1)** — DTU-08 Nakama wired to CAP-015 / SS-13; orphan status removed.
  DTU-08 now has governing spec, capability, and conformance seam anchor.
- **BC-INDEX.md (v1.5)** — 12 BC-15.* entries added; Grand total: 178→190.
- **nfr-catalog.md (v1.3)** — 6 new NFRs added (NFR-036..041):
  - NFR-036: Online-services round-trip p99 ≤ 500ms (cloud-save write, leaderboard submit)
  - NFR-037: Offline-mode activation ≤ 100ms from connectivity-loss detection
  - NFR-038: BaaS-swap migration ≤ 4h of adapter re-implementation effort (conformance suite guides)
  - NFR-039: Entitlement check p99 ≤ 200ms (server-authority path)
  - NFR-040: Remote-config stale-fallback RTO ≤ 50ms (local cache hit)
  - NFR-041: Conformance suite full run ≤ 60s against DTU-08 Nakama clone
  Total NFRs: 35→41.
- **D-SEC (BC-7.11.*)** — server-authority enforcement for leaderboards and entitlements reuses
  the existing D-SEC convergence dimension; no new convergence dimension required.
- **prd.md (v1.9)** — CAP-015 row added to capability table; Grand total 178→190 BCs.

**Count impact:**
- BC total: 178 → 190 (+12 new BC-15.* files)
- Capability count: 14 → 15
- Subsystem count: 12 → 13 (SS-13 added)
- Error codes: 198 → 213 (204 active; E-GEN 9 codes retired = 9 struck-through)
- Active error families: 30 active + 1 retired = 31 total
- Priority P0: 117 → 126; P1: 39 → 42; P2: 22 (unchanged) → sum = 190
- NFRs: 35 → 41 (+6 new NFR-036..041)

**Verification:** check-spec-counts.sh v1.13 run post-resolution — ALL CHECKS PASSED (a–n;
assertions: BC=190, error codes=213, priority P0=126/P1=42/P2=22, all 17 sub-assertions
including studio §3 SS-11=10 + SS-13=1, VP↔BC anchors, error-id resolution, convergence
dimension fields and subsets), exit 0.

---

### I13-01 (IMPORTANT) — studio role 58 artifacts assigned to SS-11 but SS-11 scope never owned them

**Class:** orphan role-artifact anchor; governing BC absent
**Locus:** studio-of-agents.md §2 roster role 58 (backend-services-engineer); subsystem-decomposition.md SS-11 scope
**Finding:** Role 58 (backend-services-engineer) in studio-of-agents.md §2 listed two artifacts:
`online-services-spec` and `remote-config-contract`, both assigned to SS-11 (distribution adapter).
SS-11's scope in subsystem-decomposition.md covered Steam/itch.io distribution, platform submission,
and release artifact packaging — it never owned online-services or remote-config contracts. No
governing BC in SS-11 covered either artifact. This is a direct consequence of C13-01: the
online-services subsystem did not exist, so its role had been assigned to the nearest plausible
subsystem as a placeholder.

**Impact:** studio-of-agents §3 SS-11 appearance count was inflated by 1 (role 58 counted under
SS-11); SS-11 total was 11 but should be 10. check-spec-counts.sh check (h) would have flagged
this as a mismatch had the CAP-015 work been done before this pass.

**Resolution:** Role 58 (backend-services-engineer) reassigned from SS-11 to SS-13 (Online-Services
Adapter, new subsystem from C13-01 resolution). SS-13 scope explicitly lists `online-services-spec`
and `remote-config-contract` as owned artifacts. SS-11 appearance count corrected 11→10; SS-13
appearance count = 1. studio-of-agents.md v1.3. check-spec-counts.sh v1.13 updated: expected
SS-11=10, SS-13=1 (replacing prior SS-11=11 expectation). CI check (h) passes with new values.

---

## Resolution Summary

| Finding | Severity | Root Cause | Resolution | Files Changed |
|---------|----------|------------|------------|---------------|
| C13-01 | CRITICAL | Online-services/BaaS (Tier-1 v1 brief req) entirely absent from spec; DTU-08 orphan; ADR-0004 self-contradiction | Built CAP-015 / SS-13 faithful to brief per human decision; 12 BCs, 5th seam, E-OSVC (15 codes), 6 NFRs, DTU-08 wired, ADR-0004 reconciled | capabilities.md, prd-cap-015.md, ss-15/BC-15.*.md (12 files), adapter-protocols.md, ADR-0004, error-taxonomy.md, subsystem-decomposition.md, ARCH-INDEX.md, studio-of-agents.md, dtu-assessment.md, BC-INDEX.md, nfr-catalog.md, prd.md |
| I13-01 | IMPORTANT | Role 58 artifacts anchored to wrong subsystem (SS-11 not SS-13) | Reassigned role 58 to SS-13; corrected §3 SS-11 count 11→10, SS-13=1 | studio-of-agents.md, check-spec-counts.sh (h) expected values |

**Counter:** 0/3 clean passes. Pass 13 found 1 critical (resolved via human-approved CAP-015 scope
completion) + 1 important (resolved as direct consequence). Counter does not advance.
**Next action:** Pass 14 — must audit the new CAP-015/SS-13 surface as the first candidate clean pass.
The entire new capability surface (12 BCs, E-OSVC family, 5th seam, DTU-08 wiring, 6 NFRs) is
unreviewed by an adversarial pass. Pass 14 will be the true candidate clean #1 for the expanded spec.
