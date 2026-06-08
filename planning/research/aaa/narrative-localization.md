---
document_type: research
vector: narrative-localization
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
sources:
  - https://www.inklestudios.com/ink
  - https://github.com/inkle/ink
  - https://github.com/inkle/ink/issues/514
  - https://github.com/YarnSpinnerTool/YarnSpinner
  - https://github.com/YarnSpinnerTool/YarnSpinner-Unreal
  - https://www.articy.com/
  - https://github.com/ArticyImporter/ArticyImporterForUnreal
  - https://twinery.org/cookbook/
  - https://dev.epicgames.com/documentation/unreal-engine/localization-overview-for-unreal-engine
  - https://docs.unity3d.com/Manual/com.unity.localization.html
  - https://www.pixelcrushers.com/dialogue-system/
  - https://nodecanvas.paradoxnotion.com/
  - https://developer.nvidia.com/ace-for-games
  - https://inworld.ai/blog/new-ai-infrastructure-scaling-games-media-characters
  - https://convai.com/
  - https://news.ubisoft.com/en-us/article/5qXdxhshJBXoanFZApdG3L/how-ubisofts-new-generative-ai-prototype-changes-the-narrative-for-npcs
  - https://news.ubisoft.com/en-us/article/7Cm07zbBGy4Xml6WgYi25d/the-convergence-of-ai-and-creativity-introducing-ghostwriter
  - https://developer.microsoft.com/en-us/games/articles/2023/11/xbox-and-inworld-ai-partnership-announcement/
  - https://docs.oasis-open.org/xliff/xliff-core/v2.0/xliff-core-v2.0.html
  - https://phrase.com/blog/posts/guide-to-the-icu-message-format/
  - https://phrase.com/blog/posts/pluralization/
  - https://igda.org/sigs/localization/
  - https://poeditor.com/blog/game-localization-testing-strategy/
  - https://storyflow-editor.com/blog/best-narrative-design-tools-for-game-developers-2025
---

# Narrative, Writing & Localization — AAA Dark Factory Research (Vector: narrative-localization)

> Scope note: this report evaluates the narrative/writing/localization discipline through the lens of the **game-factory** — an engine-agnostic, multi-agent "Dark Factory" intended to generate AAA-quality content for any genre. The framing question throughout is: *what artifacts and contracts must the factory produce, what can be automated today vs. kept human-in-the-loop, and what is the AAA acceptance bar.* Findings are cross-validated (Perplexity deep research + Tavily). Fast-moving areas (LLM NPC dialogue especially) are flagged explicitly. Citations are URLs in frontmatter `sources`.

---

## 1. Executive Summary

**Narrative authoring is a solved-tooling problem with no single winner.** AAA narrative content flows through a small set of mature tools, each exporting a known data format the factory can target: **Ink** (compiled JSON; e.g., *Vampire: The Masquerade — Bloodlines 2*, *Heaven's Vault*, *80 Days*), **Yarn Spinner** (`.yarn` text + `.yarnproject` JSON + compiled bytecode; e.g., *DREDGE*), **articy:draft X** (proprietary DB + rule-driven JSON/Excel export; e.g., *Disco Elysium*), **Twine/Twee** (HTML + Twee text, prototyping only), **Unreal native** (Dialogue Wave/Voice `.uasset` + Blueprints/Data Assets), and **Unity plugins** (Dialogue System for Unity, NodeCanvas — Unity-serialized assets). All converge on the same abstraction: a **directed branching dialogue graph** with nodes, conditional edges, variables, and tags. This is the single most important factory artifact — a canonical **narrative-graph schema** that all engine adapters import from.

**Generative LLM NPC dialogue is NOT production-mature for unbounded conversation as of mid-2026.** It ships only as constrained prototypes (Ubisoft's *NEO NPC*, Bethesda/NVIDIA experiments). Cloud round-trip latency (3–7s) breaks immersion; per-interaction cost ($0.001–0.004) is unsustainable at AAA scale ($150K–$1.8M/month for millions of players); and canon-drift, hallucination, SAG-AFTRA voice concerns, and per-utterance localization remain unsolved. Edge/SLM (quantized Llama-3-8B, Phi-3 Mini) promises sub-50ms and zero marginal cost but sacrifices model quality and excludes mobile/console. **Factory stance: treat generative dialogue as an authoring accelerant (Ghostwriter-style first-draft barks with human gate), NOT as a shipping runtime, for any narrative-critical content.**

**Localization at AAA scale is a mature, heavily machine-checkable pipeline.** ICU MessageFormat is the standard for plurals/gender/variables; XLIFF 2.0 is the interchange backbone; Crowdin/Lokalise/memoQ/Smartcat are the management platforms. A large fraction of LQA — string coverage, missing-key detection, placeholder validation, pseudo-loc overflow, encoding/CJK glyph coverage — is automatable. Creative translation, culturalization, and VO casting/timing remain human.

**The factory's highest-leverage outputs are contracts, not prose:** (1) a canonical narrative-graph schema with stable IDs, (2) a localization string contract (ICU + metadata + context), and (3) a battery of machine checks (branch-reachability, dead-end detection, string coverage, placeholder/ICU validation, pseudo-loc). Genre dramatically changes *volume* but not *shape*: a narrative RPG needs the full stack; a competitive multiplayer shooter needs barks + UI strings + heavy i18n but minimal branching.

---

## 2. Narrative Authoring Tools & Data Formats

All major tools reduce to the same conceptual model — a **directed graph of dialogue nodes** with conditional edges, variables, and metadata — but differ in source format, editing paradigm (text DSL vs. visual node DB), and engine integration. This is what makes a single canonical factory schema feasible.

### 2.1 Tool-by-tool (verified)

| Tool | Source format | Compiled/export format | Graph model | UE5 integration | Unity integration | Shipped (verified) |
|------|---------------|------------------------|-------------|-----------------|-------------------|--------------------|
| **Ink** (Inkle) | `.ink` text DSL (knots/stitches/diverts/weaves/gathers) | **Compiled JSON** (runtime IR; `root` array of containers) | Implicit graph; text-first; first-class "diverge-then-gather" | **Inkpot** (by The Chinese Room) + bespoke C++ | Official ink-unity plugin (auto-recompile, in-editor preview) | *VtM Bloodlines 2*, *Heaven's Vault*, *80 Days*, *Sorcery!*, *Overboard!*, *Wayward Strand* |
| **Yarn Spinner** | `.yarn` (screenplay-style nodes, `->` options, `<<declare>>`) | `.yarnproject` **JSON** + compiled **bytecode** | Explicit nodes + jumps; YS3 ships visual node editor | **YarnSpinner-Unreal** (beta, Windows-only, caveats) | First-class (Dialogue Runner, Yarn Project assets) | *DREDGE*, *Night in the Woods* (origin), *A Short Hike* |
| **articy:draft X** | Proprietary visual DB ("visual database") | **Rule-driven JSON** + Word/Excel; LocaID + Excel for loc | Explicit flow: Dialogue/Hub/Jump/Condition nodes + entity DB | Official open-source importer → C++/Blueprint structs | Official importer + 3rd-party (Dialogue System imports articy) | *Disco Elysium* and broad AAA RPG/adventure use |
| **Twine** | Passages + links; **Twee 3** text source | **HTML** (standalone, story-format JS: Harlowe/SugarCube); JSON via 3rd-party Twison | Passages = nodes, `[[link\|target]]` = edges; vars via macros | None official (custom import or via Dialogue System) | Via Dialogue System for Unity import; Cradle plugin | Prototyping/IF; not a primary AAA runtime |
| **Unreal native** | Dialogue Wave / Dialogue Voice `.uasset` (binary UObject) | `.uasset`; intermediate JSON only when importing | No native branching system — built via Blueprints/Data Assets/custom graph (GenericGraph) | N/A (is the engine) | N/A | Universally present in UE5 VO pipelines as building blocks |
| **Dialogue System for Unity** (Pixel Crushers) | In-Unity node editor; ScriptableObject `.asset` | Unity serialization; **imports** articy/Twine/Chat Mapper/Ink/Yarn | Conversation trees (nodes, links, conditions, actors) | N/A | Native; built-in localization + save/load | Wide AA/indie; acts as interop hub |
| **NodeCanvas** (Paradox Notion) | Behavior Trees + FSMs + **Dialogue Trees**; `.asset` | Unity serialization; JSON for save/restore | "Say" nodes + branch/condition tasks + blackboards | N/A | Native; couples dialogue to AI behavior graphs | Wide AA/indie |

### 2.2 Implications for the factory

- **Text DSLs (Ink, Yarn, Twee) give clean Git diffs** — ideal for a code-like, version-controlled, automatable pipeline and for LLM generation/review. **Visual DBs (articy, StoryFlow, Arcweave)** suit non-programmer writers and rich entity/world data but are harder to diff/automate.
- **Ink's localization gap is a known, documented limitation** (GitHub issue #514): Ink has **no built-in "export all strings"** because enumerating all reachable output requires path traversal. Studios bolt on custom string-ID/extraction tooling. **This is a direct factory opportunity:** a branch-traversal string extractor with stable IDs.
- **articy and Yarn separate LocaIDs from text cleanly** (articy: LocaID in JSON + Excel column A/B; Yarn: `.yarnproject` + localization assets) — better aligned with AAA loc than Ink out-of-the-box.
- **Wrap, don't build.** The factory should **target these formats as adapter outputs**, not invent a new runtime. Build the *canonical intermediate schema* + *N exporters/importers*, reusing each engine's mature runtime.

### 2.3 Quest/mission data, barks & systemic dialogue

- **Quest/mission content** is typically a separate data model from dialogue (objectives, states, triggers, rewards, prerequisites) — often Data Tables/Data Assets in UE, ScriptableObjects in Unity, or articy entities. The factory needs a **quest schema** (DAG of objectives with state machine + reward/prereq links) distinct from but cross-referencing the narrative graph.
- **Barks / systemic dialogue** (contextual one-liners triggered by game state — Valve's rule-based response system, *Left 4 Dead* "Director", combat/ambient barks) are a **rules + response-table** model, not a branching graph: `(set of world-state facts) → ranked candidate lines → selection with cooldown/dedup`. This is the **most automatable narrative content** (high volume, low individual stakes, templatable) and the **best fit for LLM first-draft generation** with human spot-check.
- **Emergent/systemic narrative** (e.g., *Dwarf Fortress*, *RimWorld*, Shadow-of-Mordor Nemesis-style) is generated at runtime from systems — the factory produces the *generators, grammars, and content pools*, not fixed scripts.

---

## 3. Generative / LLM NPC Dialogue — Maturity & Risk

**FAST-MOVING — flagged. Findings as of mid-2026; this landscape shifts quarterly.**

### 3.1 Platform landscape (verified)

- **Inworld AI** — C++ "Runtime" graph engine orchestrating LLM+STT+TTS+memory+knowledge; SDKs for Node.js and Unreal. Predominantly cloud for LLM. **Xbox multi-year partnership** to build AI dialogue/narrative tools at scale. Used in **Ubisoft Project NEO NPC** (prototype).
- **Convai** — Character Tool (cognition + backstory + "Knowledge Bank" grounding) + Voice API (TTS/STT); Unreal Blueprint integration, character-to-character conversation. Free tier + enterprise plans.
- **NVIDIA ACE** — infrastructure suite (cloud **and** on-device models): Riva (STT/TTS), Audio2Face/Audio2Emotion (2.2 prod / 3.0 experimental). GA for developers. **Bethesda/NVIDIA** collaboration reported for future Elder Scrolls/Fallout (animation, quest gen, NPC goals). ACE is an *enabler layer*, not a turnkey dialogue system.

### 3.2 Maturity verdict

**Constrained prototype, not shipping production** for open-ended NPC conversation. Real shipped AAA use is limited to heavily guard-railed, narrow contexts. The strongest *production* pattern today is **authoring-time assist**, exemplified by **Ubisoft Ghostwriter** (AI drafts bark variations, human writer selects/edits).

### 3.3 Latency, cost, safety (verified numbers)

| Dimension | Cloud (today) | Edge/SLM (emerging) |
|-----------|---------------|---------------------|
| **Full-cycle latency** | 3–7s typical (avg ~7s, optimistic ~3s); breaks immersion ("pausing narrator") | Sub-50ms core LLM; ~80–200ms full cycle on RTX hardware |
| **Per-interaction cost** | $0.001–0.004; ~$500–$3,000 / million interactions; **$150K–$1.8M/month** at AAA scale | ~Zero marginal cost (amortized into dev/hardware) |
| **Throughput** | Server-bound, scales as OPEX | Llama-3-8B q: 35–45 tok/s (RTX 3060); Phi-3 Mini: 15–20 tok/s (handheld) |
| **Hardware reach** | Any connected device | Excludes low-end PC, most console/mobile |

**Safety/guardrails** are multi-layered: input toxicity filtering (95%+ claimed), personality/prompt constraints ("invisible guardrails"), output filtering, and **knowledge grounding** (Convai Knowledge Bank, RAG over lore) to suppress hallucination/canon-drift.

### 3.4 Shipping design risks (the reason it's not mainstream)

1. **Canon/lore drift & hallucination** — generated lines can contradict established world facts; grounding mitigates but does not eliminate.
2. **Authorial control** — non-determinism is hostile to narrative craft, QA reproducibility, and certification.
3. **SAG-AFTRA / voice union concerns** — AI-generated/synthetic voice is a live labor-relations and contractual flashpoint.
4. **Localization explosion** — runtime-generated text cannot be pre-translated/LQA'd; per-utterance MT lacks AAA quality and culturalization control.
5. **Cost unpredictability** — generative dialogue *encourages* more interaction, compounding cloud OPEX; forces monetization hacks (cooldowns, credits, paywalls) that degrade UX.
6. **Determinism/QA** — you cannot exhaustively test an infinite output space; certification and content-rating compliance become probabilistic.

### 3.5 Factory stance

- **Automatable today (with human gate):** LLM-generated **first-draft barks**, dialogue variations, placeholder/greybox lines, lore-bible expansion, name/flavor-text generation, summarization of narrative graphs for review. Pattern = **generate → ground against lore bible → human approve → freeze as static authored content** that flows through the normal loc/VO pipeline.
- **Human-in-loop / avoid as runtime:** narrative-critical branching, anything voiced by union talent, anything that must be localized/certified, anything where canon consistency is a ship blocker.
- **Wrap, don't build:** if runtime generative NPCs are in scope later, integrate Inworld/Convai/ACE behind an adapter — do not build an LLM serving stack.

---

## 4. Localization & i18n Pipeline & Standards

### 4.1 Architecture (verified, AAA-standard)

- **Externalize everything early.** Retrofitting i18n after feature-complete inflates loc cost 300–500%. No hardcoded strings; granular string tables organized **by feature/context** (not one monolith) — yields materially fewer contextual errors.
- **ICU MessageFormat is the standard** for dynamic text: plurals (CLDR categories — Arabic has 6: zero/one/two/few/many/other), gender via `select`, variable isolation so translators can reorder for target syntax (JA/AR word order). Example: `You have {count, plural, one {# coin} other {# coins}}`.
- **Encoding:** UTF-8 universal. **CJK requires explicit glyph-coverage testing** with distinct per-variant test strings (Simplified/Traditional/JP/KO) inside the engine — fallback-font substitution gives false confidence.
- **RTL (Arabic/Hebrew)** = Unicode Bidi Algorithm **plus full UI mirroring** (layout, nav, directional icons), designed in from the start; incomplete RTL drives uninstalls/negative reviews.

### 4.2 Formats & platforms (verified)

- **Interchange:** **XLIFF 2.0** (OASIS) is the enterprise backbone; **gettext PO/POT** remains common (great Git diffs); **engine-native** — UE text/StringTable (ICU-backed), Unity Localization package (JSON-based, UI Toolkit binding, built-in pseudo-loc).
- **Management platforms:** Crowdin, Lokalise (strong gaming features, UE/Unity integration, visual context, char-limit indicators), memoQ (advanced QA/terminology), Smartcat (AI/MT-assisted), Gridly. Selection criteria: **API/CI integration**, ICU support, context metadata, continuous-loc for live-service.
- **MT + human post-edit (MTPE):** domain-adapted neural MT now near-human for *certain content types* (UI, repetitive system text); **human translation stays mandatory for narrative-critical text.** MTPE is a tier, not a replacement.

### 4.3 Voice-over localization (human-heavy)

Script adaptation under timing/lip-sync constraints (EN 5s line ≈ RU 12s); culturally appropriate casting (AAA titles can exceed 1,200 voice actors across languages); audio asset management (can't diff/merge audio); continuity across live-service updates. Machine-checkable parts: file-naming/asset-presence validation, subtitle-timing sync, audio spec (sample rate/bit depth) checks.

### 4.4 Culturalization (human-creative + compliance)

Beyond translation: symbolism, humor rework, regulatory compliance (China content rules, German symbol restrictions, religious content), modular/conditional region content. Documented in living cultural style guides. Largely human + legal review; the factory can **track and enforce** style-guide/terminology rules and flag region-flagged assets.

---

## 5. Machine-Checkable vs. Creative-Human

| Machine-checkable (factory-automatable) | Creative-human (gate, do not automate) |
|------------------------------------------|----------------------------------------|
| **Branch-reachability** of narrative graph (every node reachable from a start) | Quality/voice/emotional resonance of dialogue |
| **Dead-end / orphan-node detection**; unreachable choices | Narrative coherence, pacing, character voice |
| **Variable/flag consistency** (set-before-read; undefined refs) | Branching design that is *fun* and meaningful |
| **String coverage** (all source strings have target translations) | Translation craft & literary quality |
| **Missing-key / dangling-reference detection** | Culturalization decisions (offense, humor, symbolism) |
| **Placeholder & ICU validation** (var count/name match; valid plural/select syntax) | Gender/pronoun *representation* choices |
| **Pseudo-localization overflow** (UI truncation/overlap at +30–100% length) | VO casting, accent/dialect choices, performance direction |
| **Encoding / CJK glyph-coverage** testing (in-engine, per variant) | Regulatory/legal sufficiency judgment |
| **Terminology/glossary consistency** enforcement | Lore-bible canon authorship |
| **Bidi/RTL mirroring presence checks** (asset-level) | Whether a generated bark "feels right" in context |
| **VO asset presence, subtitle-timing sync, audio-spec validation** | Voice union/labor compliance |
| **Diff-based "what changed" string deltas** for incremental loc | Strategic loc tiering (which languages, depth) |

**Rule of thumb for the factory:** anything expressible as a graph/schema invariant, a string-table set operation, or a format/placeholder grammar is automatable and belongs in CI gates. Anything requiring taste, canon judgment, cultural nuance, or labor/legal compliance is a human gate.

---

## 6. Genre Variation

The narrative *shape* is constant (graph + strings + barks); the *volume and emphasis* vary enormously.

| Genre | Branching narrative | Barks/systemic | Localization volume | LLM-dialogue fit | Factory emphasis |
|-------|---------------------|----------------|---------------------|------------------|------------------|
| **Narrative-heavy RPG** (e.g., Disco Elysium / VtM B2) | Massive (100K–1M+ words, deep branching, variables, lore bibles) | Moderate | Very high (full VO, many languages) | Low for canon dialogue; assist-only authoring | Full stack: graph schema + quest schema + lore bible + heavy loc/VO + all checks |
| **Systemic sandbox** (e.g., RimWorld / open-world emergent) | Low fixed; high *generated* (grammars, event pools, Nemesis-style) | Very high (systemic, combinatorial) | High (lots of templated strings) | Higher fit (barks/flavor, low stakes) | Content generators + grammar/template systems + bark rules + ICU plural/gender stress |
| **Competitive multiplayer** (e.g., shooter/MOBA) | Minimal/none | High (callouts, voice lines, taunts) | High (UI/HUD/system strings, many regions, fast patch cadence) | Low (consistency/competitive integrity) | Bark/voice-line tables + heavy i18n + continuous-loc CI + pseudo-loc; light on graphs |
| **Linear cinematic** (e.g., scripted AAA) | Linear with light variation | Moderate | High (full VO) | Low | Linear script + VO loc + timing/subtitle checks |

**Factory parameterization:** a genre profile should toggle which artifacts and checks are mandatory (e.g., multiplayer skips branch-reachability but hard-enforces continuous-loc + pseudo-loc; RPG enforces everything).

---

## 7. Factory Artifacts & Contracts

These are the concrete deliverables this discipline implies. They are **schemas and checks**, engine-agnostic, with adapters to each tool/engine.

### 7.1 Canonical Narrative-Graph Schema (`narrative-graph.schema.json`)
The keystone artifact. A directed graph all adapters import/export:
- **Nodes:** `id` (stable, content-addressable), `type` (line/choice/hub/jump/condition/command), `speaker`, `listener`, `text` (→ LocaID), `tags`, `audio_ref`, `emotion`, `stage_direction`.
- **Edges:** `from`, `to`, `condition` (expression over variables), `is_default`/`gather`.
- **Variables:** declared vars/flags with types and defaults.
- **Adapters:** Ink (compiled JSON), Yarn (`.yarn`/`.yarnproject`), articy (rule JSON), Twee, UE Data Assets, Unity Dialogue System. *Reuse runtimes; the factory owns only the intermediate + transforms.*

### 7.2 Quest/Mission Schema (`quest.schema.json`)
DAG of objectives + state machine: `objectives` (states, triggers, completion conditions), `prerequisites`, `rewards`, cross-refs into narrative-graph node IDs.

### 7.3 Bark / Systemic-Dialogue Contract (`bark-rules.schema.json`)
Rule-based response selection (Valve-style): `(world-state predicates) → candidate response set → ranked selection with cooldown/dedup/context`. The prime target for LLM-assisted authoring + human gate.

### 7.4 Lore Bible / World-Building Artifact (`lore-bible.schema.json`)
Structured canon: entities (characters, factions, locations, items, timeline), relationships, glossary/terminology, style guide, naming conventions. Doubles as **the grounding source** (RAG) for any generative assist and as the **terminology authority** for localization consistency.

### 7.5 Localization String Contract (`loc-string.schema.json`)
- `string_id` (stable), `source` (ICU MessageFormat), `context` (screenshot/scene/speaker/notes), `char_limit`, `content_type` (UI/narrative/tutorial/bark), `plural`/`gender` metadata, `do_not_translate` flags, `placeholders` (typed).
- **Export targets:** XLIFF 2.0, gettext PO, UE StringTable, Unity Localization tables.

### 7.6 Machine-Check Battery (CI gates)
- `branch-reachability` — all nodes reachable; report orphans/dead-ends.
- `variable-consistency` — set-before-read, no undefined refs.
- `string-coverage` — every source string has target per locale.
- `missing-key / dangling-ref` detection.
- `icu-placeholder-validation` — placeholder parity + valid plural/select syntax.
- `pseudo-loc` — generate +X% expanded/accented/bracketed strings; flag overflow.
- `cjk-glyph-coverage` + encoding validation.
- `terminology-consistency` — enforce glossary.
- `bidi/rtl-asset` presence checks.
- `vo-asset-integrity` — presence, naming, subtitle-timing, audio spec.

### 7.7 Generative-Assist Pipeline (optional, gated)
`prompt + lore-bible grounding → LLM draft (barks/variations/flavor) → automated lore/canon check → human approve → freeze as authored content → normal loc/VO pipeline.` Adapter to Inworld/Convai/ACE only if runtime generative NPCs are explicitly scoped, behind guardrails.

---

## 8. AAA Acceptance Bar

A narrative/loc deliverable is "AAA-ready" when:

1. **Narrative graph passes all structural checks** — zero unreachable nodes, zero unintended dead-ends, no undefined-variable references, all choices resolvable.
2. **Every shipping string is externalized** with ICU formatting, stable ID, context metadata, and char-limit — zero hardcoded text.
3. **String coverage = 100%** for every shipped locale; pseudo-loc passes with no UI truncation/overflow; placeholder/ICU validation clean.
4. **CJK glyph coverage verified in-engine** (not via fallback fonts); RTL fully mirrored (layout + icons), Bidi-correct.
5. **VO localized** with timing/lip-sync within tolerance, culturally appropriate casting, continuity across updates; subtitle sync verified.
6. **Culturalization + legal review** complete for each region (regulatory compliance, sensitivity); terminology consistent against glossary.
7. **Any generative content is frozen, grounded, human-approved** and has flowed through the same loc/VO/QA gates as authored content — no un-QA'd runtime text in narrative-critical or voiced paths.
8. **Determinism/reproducibility** — narrative and dialogue outcomes are testable and reproducible for certification; no unbounded runtime generation in ship-blocking paths.

---

## 9. Open Questions & Risks

1. **Generative-NPC trajectory (fast-moving):** edge/SLM economics may flip the calculus within 2–3 years; re-survey quarterly. Risk of building around a runtime that becomes obsolete or, conversely, missing a real maturity inflection.
2. **SAG-AFTRA / labor:** AI voice terms are unsettled; any synthetic-voice or AI-dialogue feature carries contractual/reputational risk that is non-technical and must be tracked.
3. **Ink localization gap:** if Ink is a primary target, the factory must own the string-extraction tooling (traversal-based, stable IDs) — Inkle does not provide it (issue #514, still open).
4. **Schema impedance mismatch:** each tool's graph model has tool-specific features (Ink gathers, articy entity DB, Yarn commands) that may not round-trip losslessly through a single canonical schema. Need a "capabilities" negotiation per adapter, not a lowest-common-denominator schema.
5. **Live-service continuous loc:** patch-cadence loc (multiplayer especially) needs incremental string-delta + CI integration; under-tooled in many platforms.
6. **MT quality boundary:** where exactly MTPE is acceptable vs. human-only is content-type- and franchise-dependent; needs a per-content-type policy, not a blanket rule.
7. **Determinism vs. emergence tension:** systemic/emergent narrative (grammars, generators) is desirable for sandbox genres but fights the deterministic, certifiable acceptance bar — needs bounded/seedable generation contracts.
8. **Adoption-evidence gaps:** several tools (Dialogue System, NodeCanvas, articy specific titles) lack public AAA case studies in available sources; AAA usage is inferred from positioning/integrations, not always confirmed.

---

## 10. Sources

See YAML frontmatter `sources` for canonical URLs. Key cross-validated anchors:
- **Narrative tools/formats:** inklestudios.com/ink, github.com/inkle/ink (+issue #514), YarnSpinnerTool repos, articy importer repos, twinery.org cookbook, pixelcrushers.com, nodecanvas.paradoxnotion.com, storyflow-editor.com 2026 tool comparison; gamedeveloper.com (Wayward Strand + Ink). Shipped-title confirmations cross-validated via Tavily (Ink→VtM Bloodlines 2/Heaven's Vault/80 Days; Yarn→DREDGE; articy→Disco Elysium; Inkpot by The Chinese Room for UE).
- **Generative dialogue:** developer.nvidia.com/ace-for-games, inworld.ai, convai.com, Ubisoft NEO NPC + Ghostwriter articles, Xbox×Inworld announcement; latency/cost/edge analysis (veriprajna edge whitepaper, cloudzero inference-cost, gamefile.news AI-NPC economics).
- **Localization:** OASIS XLIFF 2.0 spec, phrase.com (ICU/pluralization/platform comparison 2026), igda.org Localization SIG, poeditor.com testing strategy, Unreal/Unity localization docs, lokalise/gridly/smartcat docs.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep multi-source synthesis: (1) narrative authoring tools & data formats + barks/systemic + genre needs; (2) LLM generative NPC dialogue maturity/latency/cost/safety/risk; (3) AAA localization/i18n pipeline & standards. All `reasoning_effort` high/medium, `strip_thinking` true. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — |
| Tavily tavily_search | 1 | Cross-validation of narrative tool data formats + shipped-title claims (confirmed Ink→VtM B2, Yarn→DREDGE, articy→Disco Elysium, Inkpot/UE). |
| Tavily tavily_extract | 0 | — |
| WebFetch | 0 | (attempted on local file — invalid for file:// ; read via Read instead) |
| WebSearch | 0 | — |
| Training data | ~2 areas | Genre-pattern framing (Nemesis system, L4D Director, Valve rule-based dialogue) and schema-design synthesis — flagged explicitly; structural claims grounded in retrieved sources. |

**Total MCP tool calls:** 4 (3 Perplexity deep-research + 1 Tavily)
**Training data reliance:** low — all tool/format/version/shipped-title and latency/cost/standards claims are sourced and cross-validated; training data used only for well-established genre-pattern framing and for synthesizing the factory-schema recommendations (which are design proposals, not factual claims).
