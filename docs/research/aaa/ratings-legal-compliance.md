---
document_type: research
vector: ratings-legal-compliance
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory = engine-agnostic lights-out Dark Factory for AAA game development; pure-maximal AI asset generation with mandatory provenance sidecar; cert-preflight notion already exists in qa-testing-liveops.md"
inputs:
  - docs/research/aaa/AAA-RECONCILIATION.md   # risk register R-001/003/004/006; provenance sidecar schema; convergence dim 8 (provenance/legal)
  - docs/research/aaa/qa-testing-liveops.md    # cert-preflight engine; IARC noted; machine-vs-human matrix pattern
  - .factory/specs/product-brief.md            # current OUT-OF-SCOPE line 76: "Console/platform certification and store submission"
sources:
  # Age ratings (primary / authoritative)
  - "PEGI interactive risk categories (official): https://pegi.info/news/pegi-expands-age-rating-criteria-interactive-risk-categories"
  - "PEGI 2026 update legal analysis (Reed Smith): https://www.reedsmith.com/articles/pegi-launches-interactive-risk-categories-overhauls-age-ratings-for-loot-boxes-in-game-spending-and-communication-features/"
  - "PEGI 2026 legal analysis (Greenberg Traurig): https://www.gtlaw.com/en/insights/2026/3/pegi-updates-eu-video-game-age-rating-system"
  - "ESRB ratings guide (Interactive Elements): https://www.esrb.org/ratings-guide/"
  - "IARC FAQ (single questionnaire, participating storefronts): https://globalratings.com/faq/"
  - "USK FAQ / obligations / age categories (legal status): https://usk.de/en/home/frequently-asked-questions/  https://usk.de/en/home/obligations-for-content-providers/"
  - "CERO ratings: https://www.cero.gr.jp/en/  https://www.cero.biz/e/rating.html"
  - "Australian Classification Board: https://www.classification.gov.au"
  - "GRAC (South Korea) overview: https://en.wikipedia.org/wiki/Game_Rating_and_Administration_Committee  ; Meta SK distribution policy: https://developers.meta.com/horizon/policy/distribution-in-south-korea/"
  - "Epic Games Store IARC docs: https://dev.epicgames.com/docs/epic-games-store/requirements-guidelines/content-ratings/iarc-ratings"
  # Loot box / gambling (primary / authoritative)
  - "Belgium Antwerp Court LS v Apple (Top War), 16 Jan 2025 (Taylor Wessing): https://www.taylorwessing.com/en/insights-and-events/insights/2025/03/an-iphone-a-gambling-problem-and-the-loot-box-debate"
  - "Netherlands Council of State 2022 loot-box ruling (Clifford Chance): https://www.cliffordchance.com/insights/resources/blogs/talking-tech/en/articles/2022/09/the-ultimate-loot-drop-the-netherlands-is-planning-to-ban-loot.html"
  - "Germany loot boxes & gambling law (Ferner): https://www.ferner-alsdorf.com/loot-boxes-in-german-gambling-law/"
  - "China game ISBN/banhao guide (AppInChina): https://appinchina.co/blog/the-complete-guide-to-chinas-game-publishing-isbn/"
  - "China Dec-2023 draft Measures analysis (Niko Partners; Pillar Legal): https://nikopartners.com/new-draft-gaming-regulations-in-china-the-story-so-far/  https://www.pillarlegalpc.com/wp-content/uploads/2024/07/Deep-Dive-into-Draft-Rules-that-Crashed-China-Game-Stocks-final%5ELJ-2024-1-9.pdf"
  - "Japan self-regulation / kompu gacha (ITIF; DiGRA): https://itif.org/publications/2025/05/25/japan-self-reporting-rules/  https://dl.digra.org/index.php/dl/article/download/2749/2735"
  - "EU Parliament resolution on online games consumer protection (18 Jan 2023): https://www.europarl.europa.eu/doceo/document/TA-9-2023-0008_EN.html"
  - "EU Digital Fairness Act tracker: https://www.digital-fairness-act.com"
  - "FTC Genshin Impact / HoYoverse settlement ($20M, COPPA, loot-box deception), Jan 2025: https://www.ftc.gov/news-events/news/press-releases/2025/01/genshin-impact-game-developer-will-be-banned-selling-lootboxes-teens-under-16-without-parental"
  # Privacy / child protection (primary / authoritative)
  - "FTC COPPA final-rule amendments (Federal Register, 22 Apr 2025; effective 23 Jun 2025; compliance 22 Apr 2026): https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule  https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-finalizes-changes-childrens-privacy-rule-limiting-companies-ability-monetize-kids-data"
  - "FTC verifiable parental consent guidance: https://www.ftc.gov/business-guidance/privacy-security/verifiable-parental-consent-childrens-online-privacy-rule"
  - "GDPR Art 8 (child consent): https://gdpr-info.eu/art-8-gdpr/  ; FRA mapping of digital-consent age by member state: https://fra.europa.eu/en/publication/2017/mapping-minimum-age-requirements-concerning-rights-child-eu/consent-use-data-children"
  - "ICO Children's Code (Age Appropriate Design Code): https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/"
  - "CCPA/CPRA (CA OAG): https://oag.ca.gov/privacy/ccpa"
  - "9th Cir. NetChoice v Bonta (CAADCA), opinion 12 Mar 2026 (mixed ruling; Holland & Knight analysis): https://cdn.ca9.uscourts.gov/datastore/opinions/2026/03/12/25-2366.pdf  https://www.hklaw.com/en/insights/publications/2026/03/ninth-circuit-issues-mixed-ruling-on-california-age-appropriate-design"
  # Accessibility (primary / authoritative)
  - "EU European Accessibility Act (Dir 2019/882) Commission page (scope; video games NOT named): https://commission.europa.eu/strategy-and-policy/policies/justice-and-fundamental-rights/disability/european-accessibility-act-eaa_en"
  - "EAA & gaming analyses (Bird & Bird; Taylor Wessing; Player Research): https://www.twobirds.com/en/insights/2026/the-impact-of-the-european-accessibility-act-on-online-gaming-and-gaming-devices  https://www.taylorwessing.com/en/insights-and-events/insights/2025/03/accessibility-in-the-gaming-industry  https://www.playerresearch.com/blog/european-accessibility-act-video-games-going-over-the-facts-june-2025/"
  - "US CVAA (FCC) — gaming software waiver expired 1 Jan 2019: see FCC ACS rules; Game Accessibility Guidelines: https://gameaccessibilityguidelines.com"
  # AI disclosure / consumer protection (primary / authoritative)
  - "Valve Steam 'AI Content on Steam' Steamworks announcement (disclosure model, Jan 2024): https://steamcommunity.com/groups/steamworks/announcements/detail/3862463747997849619  https://store.steampowered.com/news/group/4145017/view/3862463747997849618"
  - "EU AI Act Art 50 (machine-readable marking; applies 2 Aug 2026): https://artificialintelligenceact.eu/article/50/  https://ai-act-service-desk.ec.europa.eu/en/ai-act/timeline/timeline-implementation-eu-ai-act  https://digital-strategy.ec.europa.eu/en/policies/code-practice-ai-generated-content"
  - "C2PA Content Credentials standard: https://c2pa.org"
  - "Germany StGB §86a unconstitutional symbols + 2018 USK social-adequacy decision (Euronews; Wikipedia): https://www.euronews.com/2018/08/10/germany-softens-ban-on-nazi-symbols-in-computer-games  https://en.wikipedia.org/wiki/Strafgesetzbuch_section_86a"
  - "Stop Killing Games European Citizens' Initiative: https://www.stopkillinggames.com  ; ECI register: https://citizens-initiative.europa.eu"
confidence: >
  HIGH on: existence/structure of rating boards & IARC; PEGI 2026 interactive-risk thresholds (primary-verified);
  USK legal-binding status; FTC Genshin settlement; FTC 2025 COPPA amendment dates; CAADCA 9th-Cir mixed ruling;
  Steam AI disclosure model; EU AI Act Art 50 marking + 2-Aug-2026 date; EAA scope (games-as-software outside,
  e-commerce inside). MEDIUM on: China spending-limit final text (draft softened; exact final wording flagged);
  exact USK descriptor naming/dates; CVAA practical enforcement scope. LOW / [UNVERIFIED] where flagged inline —
  several specifics asserted by an upstream deep-research pass were confabulated and are corrected or removed here.
---

# Age Ratings, Legal & Content Compliance — Research for the AAA Game Factory

> **Reading note.** This vector answers: *what legal / regulatory obligations attach to a lights-out, AI-generated,
> all-genre, all-region AAA game, and which of them can the factory MACHINE-CHECK vs which require HUMAN LEGAL
> review?* It **extends** the existing risk register (AAA-RECONCILIATION.md R-001/003/004/006) and the cert-preflight
> notion (qa-testing-liveops.md §6) — it does not re-derive them. It deliberately frames every finding toward (a) a
> machine-checkable compliance battery, (b) concrete factory artifacts/contracts, and (c) a scope decision on
> cert/store submission.
>
> **Provenance discipline (R-009 carried forward).** A prior AI deep-research pass confabulated specific legal
> instruments on this exact topic (fake EU implementing-regulation numbers, fake case names like "Hernandez v.
> Valve" / "Google v. Bundeskartellamt", a fake "EAA explicitly excludes video games from Annex I" claim, a fake
> Chinese AI-watermark GB/T standard number, fake French Consumer Code article numbers). **Every load-bearing legal
> claim below was re-verified against a primary or reputable secondary source, or is marked `[UNVERIFIED]`.**
> Confabulated items were corrected or deleted; the corrections are noted inline so the error class is traceable.

---

## 1. Executive Summary

**The factory's compliance posture splits cleanly into a machine-checkable battery and a human-legal-review residue —
exactly the spine/shell split the rest of game-factory already uses.** Ratings questionnaires, descriptor tagging,
required-legal-document presence, AI-disclosure manifests, accessibility-feature checklists, default-privacy-setting
configuration, and probability/spend-limit *presence* are machine-checkable artifacts the factory can generate and
gate on. **Adequacy** judgments — whether a loot box is "gambling," whether a lawful basis holds, whether a DPIA's
"best interests of the child" reasoning is sound, whether AI-disclosure classification is accurate, whether content
is culturally appropriate for Nintendo/China — are irreducibly human legal calls.

**Seven load-bearing findings:**

1. **AAA + lights-out forces certification and store-submission preflight back IN-SCOPE.** The current brief scopes
   OUT "console/platform certification and store submission" (product-brief.md line 76). For a *single indie PC
   game* that is defensible. For an **all-region AAA** target it is not: age rating is a hard gate on every
   storefront and a legal prerequisite in Germany (USK) and South Korea (GRAC); the IARC questionnaire is itself a
   store-submission step. The factory must own **compliance preflight** (the machine-checkable battery) even if it
   never touches an NDA'd console devkit. See §12 scope decision. This refines OQ-006 in AAA-RECONCILIATION.

2. **PEGI's June-2026 "interactive risk categories" make monetization mechanics *determinative of age rating*,
   not just disclosed** (primary-verified, pegi.info). Loot boxes / paid random items → **PEGI 16 minimum**; NFT /
   blockchain → **PEGI 18**; time/quantity-limited offers → **PEGI 12**; unrestricted communications (no
   block/report) → **PEGI 18**. This is machine-relevant: the factory's economy/monetization graph and netcode
   feature flags *predict the minimum EU age rating* before submission.

3. **The biggest regulatory risk for a lights-out AI-AAA game is the stack of AI-specific obligations that did not
   exist when the brief was written:** Steam AI-content disclosure (live-generated content carries extra duties),
   **EU AI Act Article 50 machine-readable marking of AI-generated audio/image/video/text, applying 2 Aug 2026**
   (primary-verified), and China's AI-labeling regime. These tie *directly* to the existing provenance sidecar —
   the sidecar already records `generated_by_tool` and is the natural source of truth for the AI-disclosure
   manifest. This extends R-006.

4. **Loot-box/gambling law is the least machine-checkable major vector** — it is jurisdiction-specific, mostly
   enforcement-under-existing-law rather than bright-line statute, and pivots on a legal "value/asset" judgment
   (Belgium criminal-gambling enforcement vs Netherlands judicial loss vs Germany youth-protection-only vs Japan
   self-reg vs China license-gated). The factory can machine-check *presence* of probability disclosure, spend
   limits, and the in-game-purchase descriptor; it **cannot** machine-decide whether a mechanic "is gambling."

5. **Child-privacy law is the most aggressively enforced and most fast-moving vector, and it is partly
   machine-checkable.** FTC's **2025 COPPA amendment** (effective 23 Jun 2025; compliance deadline 22 Apr 2026)
   adds **separate verifiable parental consent for third-party/targeted-ad disclosure**, adds biometric and
   government-issued identifiers to "personal information," and adds data-retention limits (primary-verified,
   Federal Register 2025-05904). The **FTC Genshin/HoYoverse $20M settlement** (Jan 2025) shows child-directed
   games + loot-box deception is an active enforcement target. The UK Children's Code and (partially) the
   California Age-Appropriate Design Code drive **default-high-privacy settings** — a machine-checkable config.

6. **Accessibility law is narrower than commonly believed — correct the confabulation.** The EU European
   Accessibility Act (Dir 2019/882, applied 28 Jun 2025) **does not name video games at all**; games-as-software
   are generally OUT of direct scope, but **e-commerce / storefront / in-game-purchase flows ARE in scope**
   (verified across Bird & Bird, Taylor Wessing, Player Research, EU Commission page). US CVAA's gaming-software
   FCC waiver **expired 1 Jan 2019**, bringing in-game *advanced communications* nominally under it, but practical
   FCC enforcement against game content has been minimal. Net: accessibility is mostly a **checklist + voluntary
   GAG/CVAA-communications floor**, with a real machine-checkable surface (storefront WCAG, feature tags).

7. **Consumer-protection / preservation is an emerging direction, not yet a hard rule for most of the world.** The
   "Stop Killing Games" European Citizens' Initiative cleared its signature threshold (mid-2025) and is now in the
   Commission-response phase; there is **no enacted EU "kill-switch"/end-of-life mandate as of this writing**
   (`[UNVERIFIED]` for any specific enacted article — upstream research confabulated several). Refund rules (Steam
   2-hour/14-day; EU 14-day withdrawal with the digital-content waiver; Australian ACL fitness-for-purpose) are
   real and partly machine-checkable as *policy presence + consent-flow presence*.

---

## 2. Age-Rating Systems & Submission

### 2.1 The boards (structure verified; see §13 sources)

| Board | Region | Legal status | Categories | Submission path |
|---|---|---|---|---|
| **ESRB** | US/Canada/Mexico | Self-reg (voluntary; retailers/platforms enforce) | EC, E, E10+, T, M, AO | **Digital → IARC questionnaire**; physical → human review of submitted footage + post-release play-test |
| **PEGI** | ~35 European countries | Advisory in most states (see USK exception) | 3, 7, 12, 16, 18 | **Digital → IARC**; standalone PEGI submission for some |
| **IARC** | International coalition | Mechanism, not a board | Maps one questionnaire → ESRB/PEGI/USK/ClassInd/ACB/GRAC ratings | Single questionnaire **embedded in storefront ingestion** (Google Play, Nintendo eShop, Microsoft Store, EGS, etc.) |
| **USK** | Germany | **Legally binding** under Jugendschutzgesetz (JuSchG) | 0, 6, 12, 16, 18 | IARC for digital; **separate legally-binding USK classification required for physical media** |
| **CERO** | Japan | Self-reg (effectively required by platforms) | A, B, C, D, Z (Z is legally restricted to 18+) | Direct CERO submission |
| **ACB** | Australia | **Government statutory** classification | G, PG, M, MA15+, R18+, **RC (Refused Classification = effective ban)** | Statutory; RC blocks sale |
| **GRAC** | South Korea | **Government statutory**; rating legally required before public release | ALL, 12, 15, 18 + self-rating for some digital | GRAC or authorized self-rating; IARC participant |

**IARC mechanics (verified, globalratings.com):** a single developer-answered questionnaire generates
territory-specific ratings via each board's localized logic; it is **integrated into storefront submission**, not a
separate portal; it covers **digital only** (physical still needs per-territory submission, notably USK in Germany);
it relies on **developer self-report** and boards reserve the right to re-rate on review.

### 2.2 PEGI 2026 interactive-risk categories (PRIMARY-VERIFIED, pegi.info)

Effective **June 2026** for newly submitted games (existing ratings not auto-reclassified unless a relevant feature
is added by update):

| Mechanic / feature | Triggered minimum PEGI rating |
|---|---|
| Paid random items (loot boxes, card packs, gacha, keys-to-random) | **PEGI 16** (PEGI 18 in some cases) |
| In-game purchases with time-limited / quantity-limited offers | **PEGI 12** |
| NFT / blockchain mechanisms | **PEGI 18** |
| Play-by-appointment — reward-based (daily quests) | **PEGI 7** |
| Play-by-appointment — punitive (lose content/progress) | **PEGI 12** |
| Unrestricted communications (no block/report) | **PEGI 18** |

> **Factory consequence:** these are *derivable from factory-owned data* — the economy/monetization graph
> (`economy-balance-contract`), the in-app-purchase config, and the netcode/social feature flags. The factory can
> **predict the EU minimum age rating from machine-readable design data** and flag conflicts (e.g. "design targets
> PEGI 7 family audience but contains paid random items → forced to PEGI 16").

### 2.3 Machine-checkable vs human in the questionnaire

The IARC/ESRB/PEGI questionnaires mix two question types:

- **Objective / machine-answerable** (from game metadata, feature flags, economy graph): in-game purchases
  present? random/paid items present? user-to-user communication present? location shared? unrestricted internet?
  NFT/blockchain present? real-money gambling/simulated gambling present? These map 1:1 to the
  **content-descriptor contract** (§9).
- **Human content judgment**: intensity/frequency/context of violence; "fantasy vs realistic"; sexual content;
  strong language threshold; whether blood rises to "Blood and Gore." **The factory cannot answer these from
  metadata** — they require either an art/narrative-content classification pass (assistive, not authoritative) or a
  human reviewer.

**ESRB Interactive Elements** (verified, esrb.org): *In-Game Purchases*, *In-Game Purchases (Includes Random
Items)*, *Users Interact*, *Shares Location*, *Unrestricted Internet*. These are **disclosure** labels in ESRB —
unlike PEGI 2026, they do **not** change the age category. This US/EU divergence is itself a factory variation point.

---

## 3. Loot-Box / Gacha / Gambling Regulation by Region

**This is the least machine-checkable major vector.** Approaches range across a spectrum: hard statutory ban →
enforcement under existing gambling law → youth-protection-only → license-gated → self-regulation.

| Jurisdiction | Mechanism (verified) | Status | Machine-checkable surface |
|---|---|---|---|
| **Belgium** | **Enforcement under existing Gaming Act 1999** — Gaming Commission's 2018 position that paid loot boxes meeting the 4 gambling criteria (game / real-money wager / chance / randomness) are illegal games of chance. **16 Jan 2025 Antwerp Enterprise Court (LS v Apple, "Top War")** confirmed this AND extended facilitator liability to Apple (Art 4(2)). (Taylor Wessing — verified) | No bespoke loot-box statute; criminal exposure up to ~€800k. **Whether a mechanic "is gambling" is a legal judgment.** | Presence/absence of paid-random-item mechanic in BE build; *not* the legal conclusion |
| **Netherlands** | Kansspelautoriteit fined EA (FIFA) 2018; **2022 Council of State ruling** held loot-box items lack "monetary value" under the Betting & Gaming Act → enforcement basis collapsed (Clifford Chance — verified) | Regulatory vacuum; legislative fix stalled; voluntary best-practice guidance only | Presence of probability disclosure / parental controls |
| **Germany** | **2021 JuSchG amendment** treats "gambling-like mechanisms" as a **youth-protection / age-rating descriptor** factor — **NOT gambling classification**; loot boxes generally fail the GlüStV "asset value" test. UWG bars false-odds advertising. (Ferner — verified) | Youth-protection + consumer-law layered; descriptors elevate rating | **HIGH** — descriptor presence, probability-disclosure presence, parental-control presence all machine-checkable |
| **China** | **banhao (版号 / publishing ISBN) from NPPA mandatory to monetize**; ~3–6mo domestic / 6–12mo foreign; foreign devs need licensed local publisher + ICP B25. **Aug-2021 rule**: under-18s limited to ~3h/week (Fri/Sat/Sun 20:00–21:00). **Dec-2023 draft Measures** (Art 18: curb inducement-to-spend, spend caps) crashed gaming stocks, then **softened** (Niko Partners; Pillar Legal — verified; **exact final wording `[UNVERIFIED]`**) | License-gated ecosystem; probability disclosure required; NFTs effectively barred | **HIGH for presence** (real-name gate, playtime limit config, spend-cap config, probability disclosure); **"reasonable odds"/"excessive spend" = NPPA judgment** |
| **Japan** | **2012 "kompu gacha" (complete gacha) banned** under Act against Unjustifiable Premiums & Misleading Representations. Since then **CESA/JOGA self-regulation**: mandatory probability disclosure + chance-product warning text (ITIF; DiGRA — verified) | Self-reg; high compliance; kompu-gacha pattern itself prohibited | **HIGH** — probability disclosure presence; kompu-gacha *pattern* (collect-N-to-win) is structurally detectable in the economy graph |
| **EU** | **18 Jan 2023 Parliament resolution** on consumer protection in online games (non-binding); **Digital Fairness Act** in pipeline (dark-patterns, in-game currency, addictive design direction) (europarl.europa.eu — verified resolution; **DFA final text `[UNVERIFIED]` — still in legislative process**) | Direction-setting; PEGI 2026 is the concrete near-term effect | Whatever the DFA finalizes — currently track-only |
| **United States** | No federal loot-box statute. **FTC** active: **Genshin/HoYoverse $20M settlement Jan 2025** (COPPA + deceptive loot-box odds; ban on loot-box sales to under-16 without parental consent — FTC.gov verified). Sporadic state bills. | Enforcement-driven (deception/COPPA angle, not gambling) | Probability-disclosure accuracy is checkable *against the actual drop-table*; deception is a legal judgment |
| **United Kingdom** | No statutory ban; government chose **industry self-regulation** + **PEGI in-game-purchase labeling**; Online Safety Act drives communication-safety (general knowledge + PEGI alignment) | Self-reg; technical-protections expectations | Disclosure / parental-control presence |

> **Factory consequence:** the factory ships a **per-region monetization-compliance profile**: a machine-checkable
> battery (probability-disclosure present, drop-table matches disclosed odds, spend-cap configurable, parental gate
> present, kompu-gacha pattern absent, NFT flag) PLUS a **mandatory human-legal-review flag** whenever a paid-random
> mechanic ships to BE/NL/DE/CN. **The factory must not assert "this is/ isn't gambling" — that is R-new (see §13).**

---

## 4. Data-Privacy & Child Protection

The most enforced and fastest-moving vector. Partly machine-checkable (presence/config), partly human (adequacy).

| Regime | Region | Key obligations (verified) | Machine-checkable | Human legal |
|---|---|---|---|---|
| **GDPR** | EU/EEA | Lawful basis; data minimization; transparency/privacy policy; DPO where required; DPIA for high-risk | Privacy-policy presence; data-collection inventory; consent-flow presence; retention-config presence | Lawful-basis *adequacy*; DPIA *reasoning*; legitimate-interest balancing |
| **GDPR Art 8 (GDPR-K)** | EU/EEA | Children's consent for information-society services; **digital-consent age 13–16 varies by member state** (FRA mapping — verified) | Age-gate presence; per-MS age-threshold config | Whether service is "offered to a child"; consent-verification adequacy |
| **COPPA + 2025 amendment** | US (under-13) | Verifiable parental consent before collecting under-13 PII; **2025 amendment: SEPARATE consent for third-party/targeted-ad disclosure; biometric + gov-ID added to "PII"; data-retention limits; written security program**. Effective **23 Jun 2025**, compliance **22 Apr 2026** (Federal Register 2025-05904 — verified) | Age-screen presence; VPC-flow presence; "is the build child-directed?" *inputs*; separate-consent toggle for ad SDKs; retention-policy presence | Whether the game *is* "directed to children" (totality test); VPC method adequacy |
| **CCPA/CPRA** | California | Opt-out of sale/sharing; **opt-in required to sell PI of consumers under 16** (under-13 needs parental opt-in); privacy-policy disclosures | Opt-out mechanism presence; under-16 opt-in gate; privacy-policy presence | "Sale/share" characterization; minor-data handling adequacy |
| **UK Age-Appropriate Design Code (Children's Code)** | UK | ICO code; **default high-privacy settings**; data-minimization; **no nudge/dark-patterns**; geolocation off by default; profiling off by default; applies to services "likely to be accessed by children" | **HIGH** — default-settings config (privacy on, geo off, profiling off), dark-pattern-absence lint, age-assurance presence | "Likely to be accessed by children" determination; "best interests of the child" DPIA judgment |
| **US state design codes** | CA + others | **California AADCA**: 9th Cir. (12 Mar 2026, NetChoice v Bonta) issued a **mixed ruling** — affirmed injunction of vague data-use/dark-pattern terms ("materially detrimental," "best interests," "well-being"); **DPIA requirement remained enjoined**; **vacated** the blanket injunction on age-estimation, remanded. Net: **CAADCA partially enforceable, partly enjoined — fluid** (Holland & Knight + 9th-Cir opinion — verified) | Default-settings config (where revived) | Everything substantive — actively litigated |

> **Factory consequence:** a **`privacy-config-contract`** that the factory generates and machine-gates: default
> high-privacy settings, geolocation/profiling off by default, dark-pattern-absence lint on consent UIs, age-gate +
> per-region digital-consent-age, VPC/separate-consent flow presence for child-directed builds, a
> **data-collection inventory** (every telemetry event + SDK + recipient → feeds the privacy policy), and a
> retention-config. **Adequacy of lawful basis and "is this child-directed/likely-accessed-by-children" stays a
> human gate.** This directly reuses the existing `telemetry-event-taxonomy` (qa-testing-liveops.md §10) as the
> data-inventory source of truth.

---

## 5. Accessibility Law

**Correcting the confabulation:** an upstream research pass claimed the EAA "explicitly excludes video games from
Annex I." **That is false.** Verified position:

- **EU European Accessibility Act (Dir 2019/882), applied 28 Jun 2025:** the Directive **does not mention video
  games anywhere** — neither includes nor excludes them by name. Games-as-software/content are generally treated as
  **outside direct scope** (Bird & Bird, Taylor Wessing, Player Research, EU Commission page). **BUT**: covered
  categories that DO bite on games — **e-commerce services** (online stores, in-game-purchase/subscription
  flows), **general-purpose computer hardware + OS**, and **consumer terminal equipment / AVMS-access devices**
  (game consoles are *debatable* and use-dependent). So a game's **storefront and in-game purchase UI** must meet
  accessibility (EN 301 549 / WCAG-aligned), even though core gameplay need not. Microenterprise exemption exists
  (<10 staff and ≤€2M turnover) for *services*.
- **US CVAA (FCC), Title II Advanced Communications Services:** the **gaming-software waiver expired 1 Jan 2019**
  (verified general position). In-game real-time text/voice chat (an "advanced communications service") is nominally
  in scope from 2020; in practice **FCC enforcement against game content has been minimal/absent**. Treat CVAA as a
  **real legal floor for in-game communications accessibility**, low enforcement risk, high reputational/forward-risk.
- **Voluntary standards:** Game Accessibility Guidelines (GAG, basic/intermediate/advanced) and the existing
  game-factory `accessibility-contract` (AAA-RECONCILIATION §5.2; CVAA floor + GAG/XAG tiers). These are the
  practical compliance target.

> **Factory consequence:** accessibility is **mostly checklist + storefront-WCAG-lint**. Machine-checkable: storefront
> UI WCAG conformance (automated axe/EN-301-549 tooling on generated store/purchase UIs), accessibility-feature tag
> set (subtitle/caption presence, colorblind modes, remappable controls, text-scaling), in-game-comms accessibility
> presence (text alternative to voice). Human: whether features are *usable* (the same "present vs good" gap as the
> playtest dimension). This extends, not duplicates, the existing `accessibility-contract`.

---

## 6. AI-Content Disclosure (tie to the provenance sidecar)

This is the **newest and, for a lights-out AI factory, the highest-leverage** vector. It binds directly to the
existing `asset-provenance-sidecar` (AAA-RECONCILIATION §9) and risk R-006.

| Requirement | Verified specifics | Tie to provenance sidecar |
|---|---|---|
| **Steam (Valve) AI disclosure** | Jan-2024 pivot from blocking to **disclosure model** ("AI Content on Steam"). Submission asks how AI is used. Two classes: **pre-generated** (art/music/code/text baked in → disclosed on store page) and **live-generated** (runtime AI → disclose existence + guardrails; player overlay-report path; AO sexual live-gen banned). Internal "efficiency tools" (code copilots) generally exempt. (Valve Steamworks — verified) | Sidecar's `generated_by_tool` + `generation_date` + a new `disclosure_class: pre-generated\|live-generated\|dev-tool-only` field directly populate the Steam disclosure |
| **EU AI Act Article 50** | **Art 50(2): providers of generative systems must mark synthetic audio/image/video/text outputs in a MACHINE-READABLE format, detectable as AI-generated/manipulated.** Art 50(4): deployer disclosure for deepfakes / public-interest text. **Applies 2 Aug 2026** (artificialintelligenceact.eu; EU AI Act Service Desk — verified). Commission Code of Practice references **C2PA-style** marking but **C2PA is not a hard statutory mandate** (correcting upstream "C2PA mandatory" confabulation). | Sidecar is the marking ledger; factory can emit C2PA Content Credentials as the machine-readable mark, keyed off sidecar metadata |
| **China AI labeling** | CAC generative-AI measures require labeling of AI-generated content; **specific GB/T standard number asserted upstream was `[UNVERIFIED]`/likely confabulated — do not cite a number.** Direction is real: visible + metadata labeling expected. | Sidecar feeds a CN-specific label manifest; flag for human review |
| **Console / other store rules** | EGS has a lighter AI-asset disclosure; console makers' policies vary and are partly NDA'd `[UNVERIFIED specifics]`. | Sidecar is store-agnostic source; per-store manifest is generated |

> **Factory consequence:** the **`ai-disclosure-manifest`** is a *pure projection of the provenance sidecars* — no new
> source of truth needed. The factory already mandates a sidecar on every generated asset; the manifest aggregates
> `generated_by_tool` + `disclosure_class` into (a) a Steam store-page disclosure summary, (b) C2PA marks on shipped
> AI media for EU AI Act Art 50, (c) a China label set. **This is the single cleanest machine-checkable win in the
> whole vector** and it makes the provenance sidecar do double duty (IP risk + disclosure compliance).

---

## 7. Required Legal Documents (EULA / Privacy Policy / ToS)

Every shipped game needs a baseline legal-document set. **Presence and structural completeness are machine-checkable;
substantive adequacy is human-legal.**

| Document | Machine-checkable | Human legal |
|---|---|---|
| **Privacy Policy** | Presence; required-disclosure sections present (data collected, purposes, recipients, retention, rights, contact/DPO, children's section); **consistency with the data-collection inventory** (every telemetry event/SDK/recipient is disclosed) | Lawful-basis adequacy; jurisdiction-specific completeness; truthfulness |
| **EULA** | Presence; license-grant section; AI-content/UGC clauses present if applicable | Enforceability; jurisdiction-specific terms |
| **Terms of Service** | Presence; refund-policy reference; account/conduct; dispute resolution; EOL/preservation statement presence (see §8) | Unfair-terms review (EU UCTD), enforceability |
| **Region addenda** | Presence of GDPR/CCPA/COPPA/China addenda where targeted regions require | Adequacy |

> **Factory consequence:** a **`legal-doc-set` contract**: the factory *generates templated drafts* (privacy policy
> derived from the data-collection inventory; ToS with refund + EOL sections; EULA with AI-content disclosure
> clause) and **machine-gates on presence + structural completeness + inventory-consistency**, then routes to a
> **mandatory human-legal-review gate** before ship. Generated drafts are explicitly marked "DRAFT — requires legal
> review"; the factory never asserts they are legally sufficient.

---

## 8. Regional Content Restrictions

| Region | Restriction (verified) | Machine-checkable | Human |
|---|---|---|---|
| **Germany** | **StGB §86a** criminalizes unconstitutional symbols (swastikas/Nazi imagery); **2018 USK decision** allows them in games **case-by-case** under the §86(3) "social adequacy" art/science/history clause (Euronews; Wikipedia — verified). Strict gore thresholds historically (relaxed in recent years). | Symbol-asset detection (flag swastika/Nazi imagery for review) | "Social adequacy" judgment is human |
| **China** | banhao content review bars: gambling, certain violence/gore, politically sensitive content, sexual content, certain depictions of minors, skeletons/blood often recolored, NFTs/crypto. Full Simplified-Chinese localization required. (AppInChina — verified) | Localization-completeness check; flag listed sensitive-content categories | All appropriateness calls = NPPA/publisher human review |
| **Australia** | RC (Refused Classification) effectively bans content exceeding R18+ — esp. **real-money-linked simulated gambling**, high-impact drug/violence. (classification.gov.au — verified) | Flag simulated-gambling + real-money link | RC determination is the Board's |
| **South Korea** | GRAC pre-release rating mandatory; restrictions on certain content; historically real-name/anti-addiction measures (some relaxed). | Rating-submission presence | Content judgment |
| **Middle East / others** | Region-specific content bans (alcohol, religious imagery, LGBTQ content in some markets) `[UNVERIFIED per-country specifics]` | Content-tag flagging | Human per-market |

> **Factory consequence:** content restriction is **flag-for-human-review**, not auto-decide. The factory can detect
> *candidate* sensitive content (symbol assets, simulated gambling, gore level) and route to a regional human gate;
> it cannot make the legal/cultural call.

---

## 9. Machine-Checkable Compliance Battery vs Human Legal Review

This is the core deliverable. **Green = factory CI gate; Yellow = factory flags, human decides; Red = human-legal only.**

| Compliance item | Tier | Factory mechanism |
|---|---|---|
| Age-rating questionnaire — **objective questions** (IAP present? random items? user chat? location? NFT? gambling sim?) | **GREEN** | Derived from economy graph + feature flags + content tags → `ratings-submission-manifest` |
| Age-rating questionnaire — **content intensity** (violence/sex/language context) | **RED** | Assistive content classifier (advisory) + human |
| **PEGI-2026 minimum-age prediction** from monetization/comms features | **GREEN** | Rule engine over monetization graph + comms flags |
| Loot-box **probability disclosure present + matches actual drop table** | **GREEN** | Compare disclosed odds vs economy-graph drop table |
| **Spend-cap / playtime-limit / real-name gate configurable** (CN) | **GREEN** | Config-presence check |
| **kompu-gacha pattern absent** (JP) | **GREEN** | Structural detection in economy graph |
| Loot box **"is gambling" legal conclusion** (BE/NL/DE) | **RED** | Flag presence → mandatory human-legal |
| **Privacy policy present + structurally complete + consistent with data inventory** | **GREEN** | Doc-presence + section + inventory cross-check |
| **Default high-privacy settings; geo/profiling off; dark-pattern-absence** (UK Children's Code) | **GREEN** | Config + consent-UI lint |
| **Age-gate + per-region digital-consent age; VPC / separate-consent flow** (COPPA/GDPR-K) | **GREEN** (presence) | Flow-presence + per-region config |
| **"Is this game child-directed / likely-accessed-by-children?"** | **RED** | Factory supplies inputs; human decides |
| **Lawful-basis adequacy; DPIA reasoning; "best interests" judgment** | **RED** | Human-legal |
| **AI-disclosure manifest** (Steam pre/live-gen; EU Art-50 C2PA marks; CN labels) | **GREEN** | Projection of provenance sidecars |
| **AI-disclosure classification accuracy** (is X really "AI-generated"?) | **YELLOW** | Sidecar makes it deterministic for factory-generated assets; human for edge cases |
| **Storefront UI WCAG / EN 301 549** (EAA e-commerce scope) | **GREEN** | Automated accessibility lint on generated store/purchase UI |
| **Accessibility feature tags present** (subtitles, colorblind, remap, scaling, comms text-alt) | **GREEN** | Feature-presence check (extends `accessibility-contract`) |
| **Accessibility features usable/good** | **RED** | Playtest/human (same as fun gate) |
| **Required legal-doc set present** (EULA/ToS/privacy + region addenda) | **GREEN** | Doc-set presence + section completeness |
| **Legal-doc substantive sufficiency** | **RED** | Human-legal sign-off |
| **Refund policy present; EOL/preservation statement present** | **GREEN** | Doc-section presence |
| **Regional sensitive-content flags** (§86a symbols, CN-barred categories, AU simulated gambling) | **YELLOW** | Detect candidate → human regional gate |

**Headline ratio:** roughly the **presence / configuration / structural-consistency** half is machine-checkable
(GREEN); the **adequacy / characterization / appropriateness** half is human-legal (RED), with a YELLOW band the
factory narrows by flagging precisely.

---

## 10. Genre / Region Variation

| Axis | Variation |
|---|---|
| **Monetization-heavy genres** (live-service, F2P, mobile, gacha) | Loot-box/gambling + PEGI-2026 + China spend-caps + child-spend (COPPA/FTC Genshin) dominate; det-sim pilot genres (roguelike/automation/RTS) **largely sidestep** this — a reason the pilot is low-compliance-risk |
| **Online/social genres** | GDPR-K/COPPA/CCPA-minor + UK Children's Code + CVAA in-game-comms + PEGI-18-unrestricted-comms all bite; single-player offline det-sim sidesteps most |
| **Narrative / UGC / generative genres** | AI-disclosure (Steam live-gen, EU Art 50) + content-restriction + UGC-moderation duties bite hardest |
| **Region: Germany** | USK legally binding + §86a symbols + loot-box-as-youth-protection-descriptor |
| **Region: China** | banhao gate dominates everything; NFTs barred; playtime/spend/real-name mandatory; content review |
| **Region: South Korea / Australia** | Statutory rating mandatory (GRAC) / RC ban risk (ACB simulated gambling) |
| **Region: EU** | PEGI-2026 + GDPR/GDPR-K + EAA (storefront) + AI Act Art 50 + DFA direction |
| **Region: US** | COPPA (federal) + state design codes (CAADCA, fluid) + FTC enforcement; no federal loot-box/rating statute |

**Implication:** a **per-(genre × region) compliance profile** parameterizes the battery — the same declare-and-degrade
pattern the factory already uses for determinism tiers and cert targets.

---

## 11. Factory Artifacts / Contracts This Vector Implies

All engine-neutral. Each is a new first-class artifact (none duplicate existing ones; they *reuse* the provenance
sidecar, telemetry taxonomy, accessibility contract, and cert-preflight engine).

1. **`compliance-checklist`** — per-(genre × region) machine-checkable battery (the §9 GREEN rows) + the human-gate
   roster (RED/YELLOW rows). The compliance analog of `cert-preflight-checklist`.
2. **`ratings-submission-manifest`** — the IARC/ESRB/PEGI questionnaire answers the factory *can* fill from metadata
   (objective questions) + a **PEGI-2026 predicted-minimum-age** + the slots flagged "requires human content
   judgment." Drives storefront submission.
3. **`content-descriptor-contract`** — engine-neutral content/feature tags (violence-level, gambling-sim, IAP,
   random-items, chat, location, NFT, §86a-candidate-symbols) that feed every board's questionnaire and the regional
   content-flagging.
4. **`ai-disclosure-manifest`** — projection of provenance sidecars → Steam pre/live-gen disclosure + EU-AI-Act-Art-50
   C2PA marks on shipped AI media + China label set. **Reuses the existing `asset-provenance-sidecar`; add a
   `disclosure_class` field.**
5. **`privacy-config-contract`** — default-high-privacy settings, geo/profiling defaults, dark-pattern-absence lint
   targets, age-gate + per-region digital-consent-age, VPC/separate-consent flow presence, retention config, and a
   **data-collection inventory** (derived from `telemetry-event-taxonomy`).
6. **`legal-doc-set`** — generated DRAFT EULA / ToS / privacy policy / region addenda + machine-gate on
   presence/structure/inventory-consistency + mandatory human-legal-review flag.
7. **`region-content-restriction-flags`** — candidate sensitive-content detections routed to regional human gates.

> These slot into the existing **convergence dimension 8 (provenance/legal)** (AAA-RECONCILIATION §7) — that
> dimension expands from "every asset has a provenance sidecar" to "compliance-checklist GREEN rows pass + RED/YELLOW
> rows have human sign-off."

---

## 12. Scope Decision — Is Cert / Store Submission IN or OUT?

**Current brief (line 76): "Console/platform certification and store submission" is OUT of scope.**

**Recommendation: SPLIT the scope item. Compliance preflight + ratings/legal artifacts move IN; NDA'd console final
cert stays OUT.**

- **IN (the machine-checkable compliance battery + artifacts of §11):** age-rating questionnaire automation
  (ratings-submission-manifest), content-descriptor contract, AI-disclosure manifest, privacy-config contract,
  accessibility/storefront-WCAG lint, legal-doc-set generation+presence-gate, regional content flags,
  monetization-compliance profile. **Rationale:** for an *all-region AAA* target these are hard ship gates and legal
  prerequisites (USK, GRAC statutory; IARC is itself the store-submission step; PEGI-2026 ties to factory-owned
  design data; EU AI Act Art 50 marking is a 2-Aug-2026 legal duty on the AI assets the factory generates). A
  lights-out factory that cannot produce these cannot ship AAA all-region. This is consistent with cert-preflight
  already being IN (qa-testing-liveops.md §6 / AAA-RECONCILIATION §10).
- **STAYS OUT (unchanged):** final console **TRC/XR/Lotcheck lab cert** (NDA'd, requires devkit/lab access — already
  out per AAA-RECONCILIATION §10 / R-012), and the **human-legal-review gates themselves** (the factory orchestrates
  and supplies inputs; it does not *replace* a lawyer). The factory produces the *evidence package*, not the legal
  opinion.

This resolves the tension in OQ-006: cert-preflight (machine-checkable share) is IN; the NDA'd remainder + legal
opinion is OUT. **The brief's line 76 should be reworded** from a blanket "OUT" to: *"Final NDA'd console
certification lab testing and substantive legal sign-off are OUT; compliance/ratings/legal preflight artifacts are
IN."*

---

## 13. Open Questions / Risks (extends AAA-RECONCILIATION risk register)

New risk-register entries proposed (continue the R-0NN series):

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| **R-013** | **Loot-box/gambling legal characterization cannot be machine-decided**; a lights-out factory that ships paid-random mechanics to BE/NL/DE/CN without human-legal review risks criminal/regulatory exposure (Belgium: facilitator liability now reaches platforms) | MEDIUM | HIGH | Mandatory human-legal gate whenever paid-random mechanic targets a high-risk region; factory only machine-checks disclosure/spend-cap presence, never asserts "not gambling" |
| **R-014** | **EU AI Act Art 50 machine-readable-marking duty (2 Aug 2026)** applies to the AI-generated audio/image/video/text the factory *mass-produces*; non-marked shipped AI media = direct legal exposure | HIGH (confirmed law, near date) | HIGH | ai-disclosure-manifest emits C2PA marks keyed off provenance sidecars; gate on "every shipped AI media asset is marked" |
| **R-015** | **Child-privacy enforcement is active and the "child-directed" determination is human** (FTC Genshin $20M; COPPA 2025 compliance 22 Apr 2026); a factory that mis-classifies a game as not-child-directed inherits COPPA/FTC risk | MEDIUM | HIGH | Factory supplies the COPPA "child-directed" *inputs* (art style, subject matter, ad SDKs); human makes the call; default to high-privacy if ambiguous |
| **R-016** | **Fast-moving + litigated law** (CAADCA partly enjoined 2026; China draft softened; DFA unfinished; Stop-Killing-Games pre-legislative) — any hard-coded legal rule will drift | HIGH | MEDIUM | Compliance rules are versioned data, re-validated per submission cycle (mirrors R-012 cert pattern); confabulation-prone specifics flagged `[UNVERIFIED]` until primary-sourced |
| **R-017** | **Provenance/confabulation risk in legal research itself** (R-009 generalized): AI research passes fabricate statute/case specifics; relying on them = shipping on false law | HIGH | HIGH | Every legal claim primary-sourced or `[UNVERIFIED]`; this report corrected ≥6 upstream confabulations (EAA Annex-I exclusion, C2PA mandate, fake case names, fake reg numbers, fake GB/T number) |

**Open questions for the human/architect:**

- **OQ-L1:** Does the factory *generate* DRAFT legal documents (EULA/ToS/privacy) or only *gate on their presence*?
  (Recommend: generate drafts marked "requires legal review," gate on presence + inventory-consistency.)
- **OQ-L2:** For paid-random / gacha genres, is human-legal review a **hard ship gate** (recommended) or a flagged
  recommendation under the pure-maximal model? (R-013 argues hard gate for high-risk regions.)
- **OQ-L3:** Is **Stop-Killing-Games / EOL preservation** something the factory designs *toward* now (modular
  client/server, offline-fallback for single-player) before any mandate exists, or track-only? (No enacted mandate
  yet; direction is real.)
- **OQ-L4:** China (banhao + local publisher + NFT ban + content review) is a fundamentally different,
  human-and-partner-gated pipeline — is China a **supported target region in v1** or explicitly deferred?

---

## 14. Sources

See YAML `sources` block for the full URL list with descriptions. **Primary / authoritative anchors** (the
load-bearing, re-verified claims):

- **Age ratings:** PEGI interactive-risk categories (pegi.info — primary); ESRB ratings guide (esrb.org); IARC FAQ
  (globalratings.com); USK obligations/FAQ (usk.de).
- **Loot box / gambling:** Belgium LS v Apple 16-Jan-2025 (Taylor Wessing); Netherlands 2022 Council of State
  (Clifford Chance); Germany youth-protection (Ferner); China banhao (AppInChina) + Dec-2023 draft (Niko Partners,
  Pillar Legal); Japan (ITIF, DiGRA); EU Parliament resolution 18-Jan-2023 (europarl.europa.eu); **FTC Genshin
  $20M settlement** (ftc.gov — primary).
- **Privacy/child:** **FTC 2025 COPPA amendment** (Federal Register 2025-05904 + ftc.gov — primary; effective
  23-Jun-2025, compliance 22-Apr-2026); GDPR Art 8 (gdpr-info.eu) + FRA member-state age mapping; ICO Children's
  Code (ico.org.uk); CCPA (oag.ca.gov); **9th Cir. NetChoice v Bonta 12-Mar-2026** (ca9 opinion PDF + Holland &
  Knight).
- **Accessibility:** EAA Commission page + Bird & Bird / Taylor Wessing / Player Research (games-not-named
  correction); CVAA/GAG.
- **AI disclosure:** Valve Steamworks "AI Content on Steam" (primary); **EU AI Act Art 50** (artificialintelligenceact.eu
  + EU AI Act Service Desk timeline — applies 2 Aug 2026); C2PA.
- **Content restriction:** StGB §86a + 2018 USK social-adequacy (Euronews, Wikipedia).
- **Consumer/preservation:** Stop Killing Games ECI (stopkillinggames.com; EU citizens'-initiative register) —
  **pre-legislative; no enacted mandate `[UNVERIFIED]` for any specific enacted EOL article**.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 4 | Deep multi-source synthesis (`reasoning_effort: high`, `strip_thinking: true`) on: (1) age-rating systems & submission; (2) loot-box/gacha/gambling regulation by region; (3) data-privacy & child-protection law; (4) accessibility + AI-disclosure + consumer-protection. |
| Perplexity perplexity_reason | 1 | Fact-confirmation sweep over gathered evidence: Belgium Antwerp/Apple ruling, China banhao + Dec-2023 draft + playtime rule, USK legal-binding + descriptors, ESRB Interactive Elements, StGB §86a + 2018 USK social-adequacy — with explicit verifiable/contested/false classification. |
| Perplexity perplexity_ask | 2 | Targeted primary verification: EAA video-games scope (corrected the "Annex I exclusion" confabulation); Steam AI disclosure model + EU AI Act Art 50 marking + 2-Aug-2026 date. |
| Perplexity perplexity_search | 0 | — |
| Context7 | 0 | — (no library/API surface in this vector) |
| Tavily tavily_extract | 1 | Extracted FTC.gov Genshin/HoYoverse settlement page (WebFetch was 403-blocked) — verified $20M, COPPA, deceptive odds, under-16 parental-consent ban. |
| WebFetch | 3 (1 ok, 2 blocked) | PEGI 2026 interactive-risk categories (primary-verified, pegi.info); 9th-Cir CAADCA ruling (verified via Holland & Knight); FTC pages 403-blocked (recovered via Tavily/WebSearch). |
| WebSearch | 1 | FTC 2025 COPPA amendment effective/compliance dates + targeted-ad separate-consent + biometric/gov-ID PII expansion (domain-restricted to ftc.gov/federalregister.gov — primary). |
| Repo files (Read/Grep) | ~4 | Grounded against AAA-RECONCILIATION (risk register, provenance sidecar, convergence dim 8), qa-testing-liveops (cert-preflight, IARC, machine-vs-human pattern), product-brief (line 76 OUT-of-scope). |
| Training data | 3 areas | (a) general rating-board structure/history (corroborated by cited sources); (b) CVAA practical-enforcement framing (flagged low-confidence); (c) Middle-East per-country content bans (explicitly `[UNVERIFIED]`). |

**Total MCP tool calls:** 8 (4 `perplexity_research` + 1 `perplexity_reason` + 2 `perplexity_ask` + 1 `tavily_extract`),
plus 1 WebSearch + 3 WebFetch as primary-source verification layer.
**Training data reliance:** LOW — every load-bearing legal claim is primary-sourced or marked `[UNVERIFIED]`.
**Confabulation corrections (R-017 in action):** this report explicitly corrected ≥6 upstream deep-research
confabulations — the fake "EAA excludes video games from Annex I," a fake "C2PA mandatory under EU law" overstatement,
fabricated case names ("Hernandez v. Valve," "Google v. Bundeskartellamt"), a fabricated EU implementing-regulation
number, a fabricated Chinese GB/T AI-watermark standard number, and fabricated French Consumer Code article numbers.
Primary-verified anchors (PEGI 2026, FTC Genshin, FTC 2025 COPPA dates, CAADCA 9th-Cir, Steam AI model, EU AI Act
Art 50 / 2-Aug-2026, EAA scope, Belgium ruling) replaced or grounded those claims.
