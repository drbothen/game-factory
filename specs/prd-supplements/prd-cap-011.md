---
document_type: prd-supplement
level: L3
version: "1.3"
status: draft
producer: product-owner
timestamp: 2026-06-08T00:00:00Z
phase: 1a
traces_to:
  - CAP-011
inputs:
  - .factory/specs/product-brief.md
  - .factory/specs/domain-spec/capabilities.md
  - .factory/specs/domain-spec/invariants.md
  - .factory/specs/domain-spec/processes.md
  - .factory/specs/domain-spec/entities.md
  - .factory/planning/research/aaa/AAA-RECONCILIATION.md
  - .factory/planning/research/aaa/monetization-business-model.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
parallel_batch: CAP-011
---

# PRD Section — CAP-011: Monetization Ethics Enforcement (P1)

> **Parallel-build constraint.** This file covers ONLY CAP-011.
> Do NOT edit prd.md, BC-INDEX, error-taxonomy, NFRs, STATE.md, or other
> batches' files. BC files live in
> `.factory/specs/behavioral-contracts/ss-11/`.

---

## Section 11: CAP-011 — Monetization Ethics Enforcement (P1)

### 11.1 Overview

CAP-011 is the ethics and safety gate for every monetization decision the
factory makes or validates. Its core mandate is identical in form to the
"never auto-score fun" principle (CAP-008 / DI-007), applied to the revenue
domain: the factory may never autonomously optimize for unconstrained LTV
maximization, because unconstrained revenue optimization provably converges on
dark patterns (FTC v. Epic, $245M settlement Mar 2023; Deceptive Design /
Brignull taxonomy; ACM CHI Mathur et al. 2019).

CAP-011 operationalizes DI-005 ("Monetization Optimization Is Always
Constrained") through four machine-checkable mechanisms:

1. **The `monetization-ethics-contract` artifact** — a human-authored,
   machine-validated policy envelope that every monetization config must pass
   before being considered for a game build. Its structural presence is
   mandatory for any game whose `business-model-spec` is non-premium-only.

2. **The CONSTRAINED-OPTIMIZATION rule** — machine-checkable: the factory
   validates that no generated monetization config has an unconstrained LTV/
   ARPU/engagement maximization objective declared as its optimization target.
   All optimization objectives must declare their constraint envelope.

3. **The forbidden-dark-pattern set** — a declared allow-list of mechanics
   the factory will generate and a deny-list of prohibited patterns that the
   factory must refuse to produce or must flag as ethics violations.

4. **Mandatory adversarial review** — no `monetization-ethics-contract` is
   valid until it has completed at least one clean adversarial review pass.
   Convergence dimension #10 (monetization-ethics) is BLOCKED until this
   evidence is present.

### 11.2 The Ethics Contract Artifact

The `monetization-ethics-contract` is a `ContractArtifact` of type
`MonetizationEthicsContract`. It is the load-bearing artifact of CAP-011.

#### 11.2.1 Mandatory Fields

| Field | Type | Constraint |
|-------|------|-----------|
| `contract_id` | string | Unique; stable; never renumbered |
| `game_id` | string | Links to GameSpec |
| `declared_mechanics_allow_list` | string[] | Non-empty list of permitted mechanics |
| `forbidden_patterns` | ForbiddenPattern[] | See §11.3 for canonical set |
| `optimization_objective` | OptimizationObjective | Must have `constraints` non-empty |
| `disclosure_requirements` | DisclosureRequirement[] | At minimum: real_money_equivalent, odds_disclosure_if_gacha |
| `pressure_bounds` | PressureBounds | max_prompts_per_session, max_daily_spend_friction, max_expected_cost_to_target |
| `minor_protection` | MinorProtection | spend_cap_minor, no_loot_box_for_minors, no_p2w_in_ranked |
| `regional_restrictions` | RegionalRestriction[] | Per jurisdiction; loot_box_off_where_banned |
| `adversarial_review_evidence_ref` | string | Must not be null before convergence-dim-10 can be GREEN |
| `validation_method` | string | Per DI-012; must be declared at contract creation time |
| `authored_by_human` | bool | Must be `true` — policy envelope is never auto-generated |

#### 11.2.2 Optimization Objective Schema

```json
{
  "primary_objective": "revenue_per_session",
  "constraints": [
    { "type": "max_spend_concentration_gini", "threshold": 0.70 },
    { "type": "no_dark_pattern", "pattern_set_ref": "forbidden-patterns-v1" },
    { "type": "max_prompts_per_session", "n": 3 },
    { "type": "minor_spend_cap_usd", "amount": 5.00 }
  ],
  "unconstrained_ltv_maximize": false
}
```

The field `unconstrained_ltv_maximize: false` must always be explicitly set.
Any config where this field is `true` or absent is a factory defect.

#### 11.2.3 Default Ethics Envelope

When no custom contract is provided, the factory's default envelope applies.
The default is designed to be the strictest safe starting point:

| Policy | Default Value |
|--------|--------------|
| `declared_mechanics_allow_list` | `["premium_purchase", "cosmetic_dlc"]` |
| `gacha_permitted` | `false` |
| `loot_box_permitted` | `false` |
| `energy_timer_permitted` | `false` |
| `loss_triggered_offers` | `false` |
| `minor_spend_cap_usd` | `0.00` (effectively off) |
| `no_p2w_in_ranked` | `true` |
| `max_prompts_per_session` | `1` |
| `disclosure_real_money_equivalent` | `true` |

The default envelope MUST be applied automatically when `monetization_model != "none"` and no custom `monetization-ethics-contract` exists. This is not optional — absence of a contract with the default applied is still better than absence of any contract. However, shipping without a reviewed custom contract is a convergence amber state for monetization-ethics dimension #10.

### 11.3 Forbidden Dark Patterns

The factory maintains a canonical deny-list of 12 dark patterns (DP-001 through DP-012).
Any monetization config that generates or implies a forbidden pattern is flagged as an
ethics violation.

**Enforcement tiers (as of PRD v1.2):**

- **Enforced (machine-checkable BC exists):** DP-003, DP-004, DP-005, DP-006, DP-007, DP-008
  — six patterns have dedicated behavioral contracts with testable postconditions.
- **Catalog-only (deny-list entry; no dedicated BC):** DP-001, DP-002, DP-009, DP-010,
  DP-011, DP-012 — these patterns are on the deny-list but enforcement is currently via
  adversarial review (§11.6 check A-03) rather than a machine-checkable BC. Rationale for
  deferral: DP-001/002 require UI-spec schema fields that are not yet standardized in the
  engine-neutral spec layer; DP-009 requires UI-frame-level analysis not currently
  available at the factory's abstract spec layer (would require per-engine UI inspection);
  DP-010/011/012 require store-facing UI schema fields that are part of store-asset-spec
  (CAP-009 domain, not ethics enforcement domain). These patterns are detectable by the
  adversarial reviewer from the `monetization-ethics-contract`'s declared mechanics.
  A future iteration of the ethics enforcement layer may add machine-checkable BCs.

This classification is intentional. The next adversarial pass should verify this
rationale remains sound — if any "catalog-only" DP is machine-checkable at the current
spec layer, it should be escalated to the enforced tier.

| ID | Pattern | Why Forbidden | Machine-Checkable Signal | Registered Error Code | Enforcement Status |
|----|---------|--------------|--------------------------|----------------------|-------------------|
| DP-001 | Premium-currency obfuscation without real-money-equivalent disclosure | FTC scrutiny; EU consumer protection; deceptive by design | No real-money-equivalent field in purchase UI spec | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — UI spec field not standardized) |
| DP-002 | FOMO / false scarcity timer on unlimited-supply items | Deceptive scarcity; EU Unfair Commercial Practices Directive | Countdown timer on item with `supply: unlimited` | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — UI spec field not standardized) |
| DP-003 | Time-pressure purchase prompt during loss event | Exploits emotional distress (Brignull; DiGRA games literature) | Purchase prompt event fired within N frames of loss event | **E-ETH-012** | **Enforced** — BC-11.03.003 |
| DP-004 | Pay-to-win in ranked/competitive mode | Fairness violation; FTC/ESRB scrutiny | `economy-graph` shows combat-power gap between spend tiers in ranked mode | **E-ETH-011** | **Enforced** — BC-11.03.002 |
| DP-005 | Loot boxes without odds disclosure | Mandatory: Apple (Dec 2017), Google Play (May 2019), ESRB (Apr 2020), PEGI 16 (Jun 2026) | `gacha-spec` present without `published_odds` field | **E-ETH-010** | **Enforced** — BC-11.03.001 |
| DP-006 | Miscategorized "best value" bundle (dominated SKU labeled best value) | Deceptive pricing; FTC Section 5 risk | `iap-catalog` contains SKU where `best_value_tag = true` but per-unit EV is not maximum | **E-ETH-014** | **Enforced** — BC-11.03.005 |
| DP-007 | Escalating offers on inferred high-vulnerability player (whale hunting) | Predatory targeting; EU DSA dark patterns | `segmentation-ltv-spec` contains offer-escalation rule conditioned on vulnerability proxy | **E-ETH-009** | **Enforced** — BC-11.03.006 |
| DP-008 | Loot box or gacha access for minors without spending control | COPPA (FTC 2025 amendment); PEGI 16 (Jun 2026); Belgium gambling law | `minor_protection.no_loot_box_for_minors = false` in ethics contract | **E-ETH-013** | **Enforced** — BC-11.03.004 |
| DP-009 | Mis-tap / disguised purchase button | FTC v. Epic finding ($245M); Cognosphere/Genshin Jan 2025 proposed order | Purchase confirmation action within 1 UI frame of non-purchase action in UI spec | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — requires per-engine UI frame analysis) |
| DP-010 | Confirm-shaming opt-out | Dark pattern (Brignull); EU consumer law | Opt-out button text is pejorative toward the player | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — store-facing UI schema outside ethics domain) |
| DP-011 | Drip pricing (price revealed in stages) | EU Omnibus Directive; FTC guidance | Total price not shown before final purchase confirmation | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — store-facing UI schema outside ethics domain) |
| DP-012 | Auto-enrollment subscription without explicit consent | Apple/Google billing rules; EU consumer law | Subscription `auto_enroll: true` without `explicit_consent_required: true` | E-ETH-004 (generic) | Catalog-only (no dedicated BC; deferred — store-facing subscription schema outside ethics domain) |

### 11.4 CONSTRAINED-OPTIMIZATION Rule

**Machine-checkable assertion:** for every game config where monetization is
active, the following must hold simultaneously:

```
assert(monetization_ethics_contract.unconstrained_ltv_maximize == false)
assert(monetization_ethics_contract.constraints.length >= 1)
assert(
  for all agent_config in pipeline_agents:
    agent_config.optimization_objective != "maximize_ltv_unconstrained" AND
    agent_config.optimization_objective != "maximize_arpu_unconstrained" AND
    agent_config.optimization_objective != "maximize_engagement_unconstrained"
)
```

The third assertion is the strongest: no pipeline agent — not just the
`monetization-designer`, but any agent — may declare an unconstrained
revenue/engagement maximization objective. This is a cross-cutting invariant
that is validated by the hook chain.

### 11.5 The Constrained-Optimization Substrate (CAP-005 / CAP-006 Tie-in)

CAP-011's ethics contract does not float free — it constrains the live-economy
spine produced by CAP-005 (economy-graph, balance-data, sink-faucet-model) and
verified by CAP-006 (simulation BCs). The relationship is:

```
monetization-ethics-contract
  ├── constrains → live-economy-balance-contract (CAP-005 output)
  ├── constrains → gacha-spec pull-rate configuration (CAP-013 output)
  ├── verifies-via → economy sim assertions in BC-6.02.xxx (CAP-006)
  └── verified-by → adversarial review (CAP-011 gate)
```

Specifically:
- **Gacha EV and pity correctness** (CAP-006 BC-6.02.xxx): the ethics contract
  declares `max_expected_cost_to_target` bounds; the sim-BC verifies pity fires
  within those bounds.
- **Sink-faucet conservation** (CAP-005): the ethics contract declares
  `no_progression_deadlock_without_spend = true`; the economy sim verifies it.
- **Pay-to-win power gap** (CAP-006): the ethics contract declares
  `max_p2w_power_gap_percent`; the sim-BC verifies the combat-power distribution
  across spend tiers does not exceed it.

### 11.6 Mandatory Adversarial Review Gate

The adversarial review of the `monetization-ethics-contract` is not optional.
It follows the same 3-clean-passes-to-convergence rule inherited from
vsdd-factory. Specific adversarial checks:

| Check | Adversary question |
|-------|--------------------|
| A-01 | Does every declared permitted mechanic have a machine-checkable validation path? |
| A-02 | Is the declared optimization objective genuinely constrained, or does it optimize toward a proxy that collapses back to unconstrained LTV? |
| A-03 | Are all forbidden patterns in the deny-list absent from the generated config? |
| A-04 | Are pressure bounds actually enforced by a hook, or just declared? |
| A-05 | Does the minor protection section comply with FTC COPPA 2025 (effective 22 Apr 2026) and PEGI 16 (Jun 2026)? |
| A-06 | Are all regional restriction entries consistent with the `content-descriptor-contract`? |
| A-07 | If gacha is permitted, is `published_odds` present and accurate against `gacha-spec`? |

### 11.7 Autonomous LTV Maximization as Factory Defect

Per DI-005 and Brief §Constraints:

> "Autonomous LTV maximization without a declared ethics contract is a factory
> defect."

This is not a warning. It is not a convergence DEGRADED state. It is BLOCKED
and treated as a hook-detectable defect equivalent to DI-006 (suppressing a
human-gated task). The enforcement point:

1. **Hook**: `monetization-ethics-present` hook fires whenever `business-model-spec`
   is non-premium-only. If `monetization-ethics-contract` is absent, the hook
   fails the pipeline build.
2. **Pipeline check**: if any agent config declares an unconstrained optimization
   objective and no ethics contract overrides it, the build fails.
3. **Convergence dimension #10**: GREEN only when (a) contract present, (b)
   adversarially reviewed, (c) all generated config passes all invariants.

### 11.8 Behavioral Contracts Index (CAP-011)

All BCs are in `.factory/specs/behavioral-contracts/ss-11/`.

> **Priority policy (v1.2, per D-008):** CAP-011 has a mixed P0/P1 profile. BCs that gate
> regulatory-mandatory consumer protection obligations (FTC, COPPA 2025, PEGI-16, EU consumer
> law) or enforce DI-005 (unconstrained LTV as factory defect) are **P0** and must ship in
> wave 1. BCs that enforce economy-quality properties (pity correctness, spend-concentration)
> are **P1**. This split is authoritative across all three locations: this table, BC-INDEX.md,
> and BC frontmatter `priority:` fields.

| BC ID | Title | Priority | Summary |
|-------|-------|----------|---------|
| BC-11.01.001 | Ethics Contract Structural Validity | P0 | Contract exists, all required fields populated, validation method declared |
| BC-11.01.002 | Default Ethics Envelope Application | P0 | Default envelope applied when monetization present and no custom contract authored |
| BC-11.01.003 | Adversarial Review Evidence Gate | P0 | Convergence dim-10 blocked until adversarial review evidence present |
| BC-11.02.001 | No Unconstrained LTV Optimization Objective | P0 | No agent config or generated config declares unconstrained LTV/ARPU/engagement objective |
| BC-11.02.002 | Constrained-Optimization Invariant — Economy Spine | P1 | Ethics contract constraints propagate into live-economy-balance-contract assertions |
| BC-11.02.003 | No-Progression-Deadlock-Without-Spend Invariant | P1 | Economy sim verifies all player archetypes can progress without purchase, or contract explicitly declares deadlock-by-design with human sign-off |
| BC-11.03.001 | Forbidden Dark Pattern — Loot Box Without Odds Disclosure (DP-005) | P0 | gacha-spec presence requires published_odds field (Apple Dec 2017, Google Play May 2019, ESRB Apr 2020, PEGI-16 Jun 2026) |
| BC-11.03.002 | Forbidden Dark Pattern — Pay-to-Win in Ranked (DP-004) | P0 | Economy graph shows zero mechanical advantage in ranked mode for any spend level |
| BC-11.03.003 | Forbidden Dark Pattern — Loss-Triggered Purchase Prompt (DP-003) | P1 | No purchase prompt event within declared loss-event proximity window |
| BC-11.03.004 | Forbidden Dark Pattern — Minor Loot Box Access (DP-008) | P0 | minor_protection.no_loot_box_for_minors = true whenever gacha/loot-box mechanic is declared (COPPA 2025, PEGI-16 Jun 2026) |
| BC-11.03.005 | Forbidden Dark Pattern — Miscategorized Best-Value Bundle (DP-006) | P1 | Every SKU labeled best_value_tag=true has the highest per-unit EV in its category |
| BC-11.03.006 | Forbidden Dark Pattern — Predatory Vulnerability Targeting / Whale Hunting (DP-007) | P0 | segmentation-ltv-spec must not contain offer-escalation rules conditioned on vulnerability proxies (EU DSA dark patterns) |
| BC-11.04.001 | Gacha EV and Pity Correctness (Ethics-Bounded) | P1 | Gacha pull EV and worst-case cost-to-target remain within ethics-contract declared bounds |
| BC-11.04.002 | Spend-Concentration Guardrail | P1 | Gini coefficient of spend distribution measured in sim does not exceed ethics-contract declared threshold |

### 11.9 Relationship to Other Capabilities

| Capability | Relationship |
|-----------|-------------|
| CAP-005 (Multi-Discipline Production) | CAP-011 constrains the `live-economy-balance-contract` and `sink-faucet-model` produced by CAP-005's economy-designer. Ethics envelope is a filter on what economy configs are valid outputs. |
| CAP-006 (Simulation Quality Verification) | CAP-011 produces the ethics-bounded assertions that become sim-BCs (gacha EV, pity correctness, P2W gap). CAP-006's verification infrastructure is the substrate for proving those assertions. |
| CAP-007 (Convergence Tracking) | Convergence dimension #10 (monetization-ethics) is owned by CAP-011. It is BLOCKED unless: (a) ethics contract present, (b) adversarially reviewed, (c) all generated configs pass ethics assertions. No degradation path. |
| CAP-010 (Compliance Pipeline) | CAP-011 and CAP-010 intersect at PEGI 16 (paid random items, Jun 2026), FTC COPPA 2025 (ad SDK consent, 22 Apr 2026), and ESRB "Includes Random Items" label (Apr 2020). `content-descriptor-contract` triggers ethics obligations; ethics contract declares the mechanics that drive rating triggers. |
| CAP-013 (Genre-Gated Optional Lane) | The monetization mechanics lane (CAP-013, Tier 2) produces `gacha-spec`, `iap-catalog`, `battle-pass-spec`. Every artifact from this lane must pass the ethics contract before it is accepted into a game build. CAP-011 is the gate at the lane's exit. |

### 11.10 Acceptance Criteria

The monetization-ethics convergence dimension (#10) is GREEN when ALL of the
following hold:

1. If `business-model-spec.monetization_model != "none"`: a
   `monetization-ethics-contract` artifact is present with all required fields.
2. `contract.authored_by_human == true`.
3. `contract.unconstrained_ltv_maximize == false`.
4. `contract.adversarial_review_evidence_ref` is non-null and references a
   completed adversarial review artifact.
5. All generated monetization configs pass every assertion in §11.4.
6. No generated config contains a pattern from the deny-list (§11.3).
7. All gacha-spec / iap-catalog artifacts pass their ethics-bounded sim-BC
   assertions (BC-11.04.001, BC-11.04.002).
8. PEGI/ESRB content-descriptor implications are consistent with declared
   mechanics in the ethics contract.

**There is no degradation path for this dimension.** If monetization is
present, the ethics gate is mandatory. A waiver is not possible because
DI-005 is a domain invariant, not a policy choice.

---

## References

- `domain-spec/invariants.md` §DI-005 — Monetization Optimization Is Always Constrained
- `domain-spec/invariants.md` §DI-012 — Every ContractArtifact Has a Declared Validation Method
- `planning/research/aaa/AAA-RECONCILIATION.md` §7 dimension #10, §8, §10, §12 R-010, R-013, R-015
- `planning/research/aaa/monetization-business-model.md` §6, §7, §10, §11
- `product-brief.md` §Constraints ("constrained optimization only; unconstrained LTV maximize is a factory defect")
- BCs: `.factory/specs/behavioral-contracts/ss-11/BC-11.*.*.md`
