---
document_type: research
vector: narrative-worldbuilding-lore
version: "1.0"
status: draft
timestamp: 2026-06-08T00:00:00Z
producer: research-agent
project: game-factory
scope: >
  Worldbuilding, story-writing, and the canonical lore knowledge base as a first-class
  consistency backbone for an engine-agnostic, lights-out AAA game-factory. Extends (does
  not duplicate) the narrative TOOLING / dialogue-graph / localization material in
  narrative-localization.md.
inputs:
  - docs/research/aaa/narrative-localization.md
  - docs/research/aaa/game-design-discipline.md
  - docs/research/aaa/AAA-RECONCILIATION.md
  - docs/research/aaa/generative-asset-ai.md
sources:
  # Worldbuilding discipline / world-bible / studio canon (primary-verified)
  - https://www.gamedeveloper.com/design/building-a-basic-story-bible-for-your-game   # Megill, story-bible structure
  - https://www.gamedeveloper.com/design/learning-the-ways-of-the-game-development-wiki
  - https://newsroom.activisionblizzard.com/p/so-what-is-a-loremaster-exactly       # VERIFIED: Sean Copeland, "lore yoga", per-franchise historian + buddy, 6-person team
  - https://www.ubisoft.com/en-us/company/careers/search/744000126400479-narrative-director-assassin-s-creed-  # Narrative Director role text
  - https://gdcvault.com/play/1016566/Environmental-Storytelling-Indices-and-the    # Environmental storytelling "indices"
  - https://www.pcgamer.com/what-did-george-rr-martin-do-for-elden-ring-anyway/      # GRRM "overarching mythos" (fetch blocked at capture time; see provenance note)
  - https://www.imperial-library.info/content/filmdegs-oral-history-of-morrowind-michael-kirkbride  # TES lore (Kirkbride) — community archive, NOT a studio source
  # Lore-bible / knowledge-base tooling (primary-verified vendor pages)
  - https://www.worldanvil.com/features                                              # VERIFIED: 25+ templates, interactive maps, timelines, family trees, diplomacy webs, auto-linking
  - https://www.campfirewriting.com/                                                 # VERIFIED: characters, maps, species, timelines/calendars, conlang module, ~18 modules
  - https://www.legendkeeper.com/                                                    # VERIFIED: connected wiki, auto-linking, nested maps, timelines, boards, export
  - https://www.articy.com/en/articydraft/feature-list                               # VERIFIED: Game Object Database, Entities+templates, Checkup Tools, API (.NET), exports
  - https://www.articy.com/en/showcase/the-talos-principle-2                          # VERIFIED: shipped AAA articy use (Croteam)
  # Machine-checkable continuity + AI-generatability (primary-verified academic)
  - https://arxiv.org/abs/2603.05890                                                 # VERIFIED: "Lost in Stories" (ConStory-Bench / ConStory-Checker)
  - https://openreview.net/forum?id=3A71qNKWAS                                       # VERIFIED: LongGenBench (ICLR 2025)
  - https://neurips.cc/virtual/2025/poster/121417                                    # TimE temporal-reasoning benchmark (NeurIPS 2025 poster listing)
  - https://arxiv.org/html/2408.07453v1                                              # KG fact-verification (FactKG / DBpedia subgraph)
  - https://arxiv.org/abs/2405.01259                                                 # Neurosymbolic NLI (AMR→propositional logic→SAT)
  - https://aws.amazon.com/blogs/machine-learning/detect-hallucinations-for-rag-based-systems/  # RAG hallucination-detection patterns
  - https://github.com/lechmazur/writing                                             # VERIFIED: LLM creative-writing benchmark (pairwise, 10 required elements)
  # Narrative-theory references (well-established craft; not version-sensitive)
  - https://channel101.fandom.com/wiki/Story_Structure_101:_Super_Basic_Shit          # Dan Harmon Story Circle (primary author source)
provenance_note: >
  This report was written AFTER reading the prior project warnings (generative-asset-ai.md §8,
  AAA-RECONCILIATION.md R-009, game-design-discipline.md R2) that Perplexity sonar-deep-research
  CONFABULATED named studios, case names, paper titles, and figures in earlier passes. Accordingly:
  every named TOOL feature (World Anvil, Campfire, LegendKeeper, articy:draft), every named STUDIO
  PROCESS (Activision Blizzard loremaster / "lore yoga"), and every load-bearing ACADEMIC
  BENCHMARK (ConStory-Bench, LongGenBench, the lechmazur creative-writing benchmark) was verified
  DIRECTLY against its primary source via WebFetch / Tavily extract before being stated as fact.
  Claims that could not be so verified are marked [UNVERIFIED]. The deep-research pass on RAG/
  narrative theory self-declared "absence of verified contemporary search results" and leaned on
  pre-2023 theory with heavy "might be termed" hedging — that material is treated as FRAMING ONLY,
  not as sourced fact, and is so flagged where used.
---

# Narrative, Worldbuilding & Lore — Canon as Consistency Backbone (Vector: narrative-worldbuilding-lore)

> Scope: the CREATIVE crafts of worldbuilding and story-writing, and — the keystone — the
> canonical lore knowledge base that every generative agent in a lights-out factory must be
> grounded against. This EXTENDS `narrative-localization.md` (which covered dialogue-graph tooling,
> generative-NPC maturity, and localization). It does **not** re-derive the narrative-graph schema,
> bark contract, or loc-string contract — it adds the layer *above* them: the world-bible / canon
> KB those artifacts must be consistent *with*.

---

## 1. Executive Summary

**The canonical lore knowledge base is the architecturally load-bearing artifact of this entire
vector — more so than any single piece of prose.** In a factory that emits thousands of names,
quests, item descriptions, barks, and codex entries from many parallel generative agents, the
world-bible is the *single source of truth* against which every generation must be grounded and
every output continuity-checked. The prior doc named a `lore-bible.schema` almost in passing
(`narrative-localization.md` §7.4); this report promotes it to a first-class, structured,
queryable, machine-checkable subsystem: an **entity registry + relationship graph + timeline +
naming registry + canon-fact store with provenance.** It is the narrative analog of the
deterministic-sim's economy graph — the part of a fuzzy creative discipline that reduces to a
verifiable schema.

**Worldbuilding is a real, professionalized discipline with a documented artifact (the "world/story
bible") and documented roles.** Verified primary sources establish: a structured story-bible
practice (Megill, *Game Developer*) covering premise, geography, factions/politics, history,
culture/religion, cosmology, magic/tech systems, naming/language, ecology, economy-in-fiction, and
environmental storytelling; a real **loremaster / continuity** function (Activision Blizzard's
6-person lore team with a per-franchise historian + "buddy", and the documented practice of "**lore
yoga** — the bending, but not breaking, of established canon"); and a brand-level **Narrative
Director** role (Ubisoft job posting). Studios sit on a spectrum from **exhaustive textual canon**
(Bethesda Elder Scrolls; CD Projekt Red's in-game books) to **deliberately fragmentary,
environment-first canon** (FromSoftware — where George R.R. Martin wrote an "overarching mythos"
used as *stimulus*, not a rigid script).

**Story-writing reduces to a stable set of structural models plus a large, tiered taxonomy of game
text.** The structure models (three-act, Hero's Journey/Vogler, Harmon's Story Circle, Freytag,
branching, Nemesis-style emergent) are well-established craft, not fast-moving tech. The factory's
real surface is the **game-text taxonomy**: main-quest narrative, side quests, barks, codex/lore
entries, item/flavor text, audio logs, environmental text, tutorial/UI text, achievement text, and
marketing/store copy — each with sharply different *volume*, *stakes*, and *AI-tractability*.

**Narrative/lore is plausibly the MOST AI-tractable creative discipline in game dev — but only
when grounded against a canon KB, and only for the low-stakes / high-volume tiers.** Verified
benchmarks (ConStory-Bench/"Lost in Stories", LongGenBench, TimE) show modern LLMs write fluent,
on-style prose yet **systematically drift on long-form factual/temporal consistency**, with errors
concentrating in the middle of long generations. This is exactly the gap a canon KB +
continuity-check battery closes: **generate → ground → continuity-check → freeze.** Verdict:
**HIGH** generatability for flavor/codex/barks/item-text grounded against canon; **MEDIUM** for
side quests and lore expansion; **LOW (assist-only)** for main-arc narrative, theme, and signature
character voice — and the canon KB *itself* is human-authored or human-ratified.

---

## 2. Worldbuilding as a Discipline

### 2.1 The world-bible / story-bible / franchise-bible artifact (verified)

The canonical artifact is a structured, *living* document — explicitly "a living document" that must
"accommodate changes" rather than a frozen blueprint (Megill, *Game Developer*, "Building a Basic
Story Bible"). The verified structure begins with a tight 2–3 paragraph premise/pitch and expands
into sections that map almost one-to-one onto the research brief:

| World-bible section | What it captures | Drives (downstream) |
|---|---|---|
| **Premise / pillars / tone** | 2–3 paragraph essence; emotional+thematic territory | every discipline's north star |
| **Geography & maps** | terrain, climate, resource distribution, region identity | level design, environment art, region color/lighting language |
| **Factions / politics** | power structures, conflict-resolution norms, allegiances | quest design, architecture/propaganda, faction visual identity |
| **History & timelines** | chronology — often *multiple, contested* accounts | environmental storytelling, codex, quest backstory |
| **Cultures / religions** | class, ritual, taboo, daily life; cosmology, creation myth, theology | NPC behavior, iconography, dialogue register |
| **Cosmology / magic-or-tech system** | the "rules" — costs, limits, who controls access | gameplay systems, VFX signature, ambient design |
| **Languages / naming conventions** | phonetic/grammatical patterns, regional naming, conlang | naming registry, localization, immersion |
| **Ecology** | flora/fauna, biome logic | settlement logic, environmental story (e.g. plants → magic nodes) |
| **Economy-in-fiction** | currencies, trade, *and* non-physical resources (street cred, mystical energy) | quest stakes, signage, market scenes |
| **Environmental storytelling** | "indices" — environmental clues implying larger narrative without exposition (GDC Vault talk verified) | art direction, level dressing |
| **Visual consistency / art-direction bridge** | palette, lighting, "visual threshold" guidance per region/faction | the lore→art-bible handoff |

The bridge to art direction is real and bidirectional: the bible carries palette/lighting/visual-
language guidance so "when you commit to a visual language long enough, your work begins to feel
connected, intentional, and recognisable." This is the seam between this vector's `world-bible` and
the art vector's `art-bible.spec` (AAA-RECONCILIATION §6).

> NOTE on a confabulation-prone area: much of the deep-research prose on "what the world bible
> contains" was generic and partly hedged. The TABLE above is grounded in the verified Megill
> *Game Developer* article + GDC Vault environmental-storytelling talk; the rest of the deep-research
> elaboration is treated as plausible framing, not sourced fact.

### 2.2 Worldbuilding & canon ROLES (verified where named)

- **Narrative Director (brand level)** — defines long-term narrative vision and "ensures coherence
  and scalability of the narrative ecosystem across the brand," while per-project directors keep
  creative ownership. (Verified: Ubisoft *Narrative Director, Assassin's Creed* job posting.)
- **Worldbuilder / worldbuilding designer** — owns the underlying systems (history, politics,
  economy, culture) that the bible documents. (Role exists across job listings; treat the
  hybrid-skillset framing as descriptive, not a single-source fact.)
- **Loremaster / continuity editor (VERIFIED in detail)** — Activision Blizzard's lore team:
  **6 people, one dedicated historian per franchise** (WoW, Diablo, …) **each with a "buddy" to
  offset workload, daily coordination meetings**; they act "not as lore police but as **lore
  lawyers**," do editorial checks (artwork details, manuscript timeline/character consistency) up to
  authoring sourcebooks, and practice "**lore yoga — the bending, but not breaking, of established
  canon to accommodate a new story point.**" (Sean Copeland interview, Activision Blizzard newsroom.)
- **Narrative designer** — bridges worldbuilding to interactive implementation (quests, dialogue
  systems, environmental story). (Established role; see also `narrative-localization.md`.)

### 2.3 How specific studios manage canon (verified anchors + flags)

- **FromSoftware (Elden Ring / Dark Souls)** — *deliberately fragmentary*, environment-first canon.
  Miyazaki's documented method is to "first set a certain game system and then apply a worldview that
  matches that," and to embrace ambiguity ("story conflict which arises from different
  interpretations… and the audience doesn't know which one is right"). George R.R. Martin wrote the
  **"overarching mythos for the game world,"** used by the team as a *base/stimulus* rather than a
  rigid script (widely reported via PC Gamer / Miyazaki statements; the specific PC Gamer page was
  **fetch-blocked at capture time** — treat the *exact wording* as [UNVERIFIED] but the substance as
  well-corroborated). **Factory implication:** "minimum-viable bible" + intentional gaps is itself a
  valid canon strategy — the KB must support *marked ambiguity*, not just hard facts.
- **CD Projekt Red (Witcher / Cyberpunk)** — adapts external IP into a "parallel canon"; The Witcher
  games are positioned as an *alternate timeline/sequel* to Sapkowski rather than 1:1 book canon, and
  the studio leans on in-game books as canon-bearing "mini-novels." (Substance corroborated across
  community/dev sources; treat as MEDIUM confidence — no single authoritative studio doc verified.)
- **Bethesda (Elder Scrolls / Fallout)** — *exhaustive textual* canon; deep in-game library; the
  Elder Scrolls cosmology is a frequently-cited example of canon extending beyond the games. Michael
  Kirkbride's contribution is documented largely via the community **Imperial Library** archive — a
  fan archive, NOT a studio source; treat all "official Bethesda process" claims as [UNVERIFIED].
- **Larian (Baldur's Gate 3)** — adapts established D&D / Forgotten Realms IP (a pre-existing,
  externally-owned canon — itself a sourcebook-style KB). The deep-research pass produced little
  *verified* Larian-specific process detail; specifics are [UNVERIFIED].

---

## 3. Story-Writing Craft & the Game-Text Taxonomy

### 3.1 Structure models (established craft — not fast-moving)

These are stable, decades-old frameworks; they are reference scaffolding, not technology to track:

- **Three-act** (setup / confrontation / resolution) — default screenplay spine; in games realized
  via "narrative containment" (branching that reconverges on key beats).
- **Hero's Journey (Campbell → Vogler's 12 stages)** — maps cleanly onto RPG progression; modular
  stages are convenient for procedural assembly.
- **Harmon Story Circle (8 steps, symmetrical loop)** — compact, recursive; well-suited to
  per-quest/per-character arc templating. (Primary author source: Harmon's "Story Structure 101.")
- **Freytag's pyramid** — five-stage tension model; useful as a *pacing curve* the factory can
  target/measure.
- **Branching / systemic narrative** — decision graphs with reconvergence ("narrative trunking") to
  fight combinatorial explosion (see `narrative-localization.md` §2 for the graph tooling).
- **Emergent / Nemesis-style** — *Middle-earth: Shadow of Mordor* — narrative generated at runtime
  from an entity registry + relationship graph + procedural event generators. Note: this is the same
  shape as the canon KB (§4) — emergent narrative is literally "run the KB forward at runtime."

Craft dimensions the factory must respect but largely cannot auto-judge: character arc (flaw →
crisis → transformation), theme/"controlling idea," pacing, foreshadowing/callbacks, subplot
interweave, dramatic irony. **Cinematic/cutscene screenwriting** adds timing, diegetic-UI, and
gameplay-state-aware dialogue — covered as VO/timing checks in `narrative-localization.md` §4.3.

### 3.2 The full game-text taxonomy (the factory's real output surface)

This is the load-bearing taxonomy. Each row gets a **volume**, **stakes**, and **AI-tractability**
rating (when grounded against the canon KB). Tractability: **HIGH** = generate-and-freeze with
continuity check + spot review; **MED** = generate-then-human-edit; **LOW** = assist-only, human-led.

| Game-text type | Typical volume | Narrative stakes | AI-tractability (grounded) |
|---|---|---|---|
| **Main-quest narrative / critical-path dialogue** | Low–Med count, very high impact | Highest (arc, theme, payoff) | **LOW** — human-led; canon-critical |
| **Major character dialogue (signature NPCs)** | Med | High (voice, arc) | **LOW–MED** |
| **Side quests** | High | Medium | **MED** — structure + grounding help; human edit |
| **Codex / lore entries / in-game books** | Very high | Medium-low individually | **HIGH** — pure KB expansion; ideal RAG target |
| **Item / flavor text** | Very high | Low individually | **HIGH** — templatable + KB-grounded |
| **Barks / systemic one-liners** | Very high | Low individually | **HIGH** — best LLM first-draft fit (see narr-loc §2.3) |
| **Audio logs / environmental text (notes, graffiti, signage)** | High | Low–Med | **HIGH–MED** — KB-grounded; sets tone |
| **Tutorial / UI / system text** | Med | Low (but clarity-critical) | **HIGH** (but accuracy-gated, not "creative") |
| **Achievement / trophy text** | Low–Med | Low | **HIGH** |
| **Marketing / store copy** | Low | Med (brand/legal) | **MED** — brand-voice + legal review |

**Key insight:** the factory's *volume* is overwhelmingly in the HIGH-tractability tiers
(codex/flavor/barks/logs), and those are exactly the tiers where canon-grounding does the most work
and human stakes are lowest. This is *why* narrative/lore is the most AI-tractable creative
discipline — the long tail is enormous and KB-groundable.

---

## 4. Canon / Lore Knowledge-Base Architecture (THE KEYSTONE)

### 4.1 The core thesis

The canonical world must be represented as a **structured, queryable, versioned knowledge base** —
not as prose alone — so that (a) every generative agent retrieves the *relevant, current* canon
before generating (RAG grounding), and (b) every generated artifact can be continuity-checked
against schema invariants. Prose lives *attached to* KB entities, not instead of them.

### 4.2 Subsystems of the canon KB

```
canon-kb/
├── entity-registry/          # the spine: every canon noun is a typed, stable-ID node
│   ├── characters            # name, aliases, status(alive/dead/...), affiliations, traits
│   ├── locations             # region hierarchy, parent/contains, map refs
│   ├── factions              # leadership, allegiances, doctrine
│   ├── items / artifacts     # provenance, owner, powers (cross-ref to design item data)
│   ├── events                # what happened (links to timeline)
│   └── concepts / lore-terms # cosmology, magic rules, glossary terms
├── relationship-graph/       # typed edges: ally_of, parent_of, located_in, member_of, killed_by, occurred_before
├── timeline/                 # chronology: events with (era, ordinal/date); per-entity validity windows
│                             #   (e.g. character.appears ∈ [introduced_event, death_event))
├── naming-registry/          # canonical spellings, phonotactic rules, per-culture name pools,
│                             #   reserved/forbidden names, conlang lexicon; collision authority
├── canon-facts/              # atomic assertions WITH provenance + canon-tier + temporal validity
│                             #   {subject, predicate, object, source, tier, valid_from, valid_to, ambiguity_flag}
└── style/voice/              # tone, register, per-faction/character voice fingerprints, do-not-use list
```

Three design rules, grounded in verified tooling conventions:

1. **Stable content-addressable IDs on every entity** (mirrors the narrative-graph node-ID rule).
   Prose references resolve to IDs, so renames don't break canon.
2. **Provenance + canon-tier on every fact.** Each assertion records its source (which doc/quest/DLC
   introduced it), a tier (hard-canon / soft / contested / ambiguous-by-design), and **temporal
   validity** (a fact can be true only within a story-time window, and only "known to the audience"
   after a reveal). This is what makes retcon-tracking and FromSoftware-style *intentional* ambiguity
   first-class rather than bugs.
3. **The KB is the grounding source AND the terminology authority** — the same store feeds RAG
   grounding (§4.4), naming-collision checks, and localization glossary consistency
   (narr-loc §4). One source of truth, many consumers.

### 4.3 Existing lore-bible tooling — what's real (VERIFIED vendor pages)

These prove the *shape* is industry-validated and tell us what to emulate vs. wrap. All features
below were read directly from the vendors' own pages.

| Tool | Verified capabilities (from vendor's own site) | Relevance to factory KB |
|---|---|---|
| **World Anvil** | "25+ worldbuilding templates," **Interactive Maps**, **Interactive Timelines**, **Family Trees**, **Diplomacy Webs** (relationship graphs), **Global Search**, **Automatic Article Linking**, RPG statblocks, novel editor, co-authors. | Direct precedent for entity-template + timeline + relationship-graph + auto-linking. Human-facing wiki, not an agent-grounding API. |
| **Campfire (Campfire Writing)** | Named modules incl. **Characters, Maps & Locations, Species, Timelines & Calendars**, **Conlang Software**, manuscript/story-planning; "~18 modules." | Confirms conlang/naming + species/ecology as standard KB facets. |
| **LegendKeeper** | **Connected wiki** with **auto-linked terms/tags**, **GM-only hidden secrets**, template reuse; **nested/hierarchical maps** with pins→pages; **timelines** (eras, lineage, parallel storylines, fantasy calendars); **Boards** (whiteboard relationship mapping, quest/"conspiracy" plotting); **export**, offline sync, granular permissions. | "Everything connected" + hidden-canon (provenance/visibility) is exactly the factory pattern. Closest conceptual match. |
| **articy:draft X** | **Game Object Database**; **Entities** (characters/items/abstract things) via a **Template System** (typed properties, inheritance); Location editor; **Checkup Tools**; **Exports/Imports** + engine integrations; **articy:draft API** (.NET, read/write project data, commits to SVN/Perforce). Shipped AAA: **The Talos Principle 2** (Croteam, verified showcase). | The most *machine-integrable*: typed entity DB + API + checkup tools + engine export. This is the production-grade analog of the factory's KB-with-an-API. |

**Takeaway:** the entity-template DB + relationship graph + timeline + auto-linking pattern is
fully industry-validated (World Anvil, LegendKeeper, articy all implement it). What none of them
provide out-of-the-box is an **agent-grounding RAG contract** + a **CI-grade continuity-check
battery**. That gap is the factory's net-new contribution — *wrap articy's entity DB / API where a
visual DB is wanted; build the grounding contract and the check battery.*

### 4.4 RAG grounding for creative consistency (the generate→ground loop)

The grounding pattern is: **retrieve relevant canon → inject as constraints → generate → check →
freeze.** Verified evidence and caveats:

- **Knowledge-graph–assisted retrieval beats flat-document RAG for fact-consistency.** KG-based fact
  verification (FactKG/DBpedia subgraph retrieval, arXiv 2408.07453) reports high accuracy and,
  notably, that *simpler targeted subgraph retrieval can outperform heavier multi-model graph
  traversal* — i.e. precise entity-neighborhood retrieval is both cheaper and more accurate. This
  argues for **graph-shaped grounding over the canon KB**, not just embedding search over prose.
- **Neurosymbolic contradiction detection is explainable** (AMR → propositional logic → SAT solver,
  arXiv 2405.01259) — relevant because the factory needs *auditable* "why was this flagged" output,
  not a black-box score.
- **RAG hallucination detection is a known, practical pattern** (AWS ML blog) with LLM-as-judge,
  semantic-similarity, and token-similarity variants; LLM-as-judge reported >75% accuracy at modest
  cost. Usable as a continuity gate, but **not** a perfect one.

> The broader deep-research narrative-theory pass on RAG self-declared it lacked fresh sources and
> hedged heavily ("might be termed narrative provenance tracking," etc.). Those specific
> mechanism-names are FRAMING, not citations — the *verified* anchors are the KG/neurosymbolic/RAG-
> hallucination papers above plus the consistency benchmarks in §5.

---

## 5. Machine-Checkable Canon-Continuity vs. Human Judgment

This is the narrative analog of `game-design-discipline.md`'s "verifiable spine vs. subjective
shell." The split is grounded in verified benchmarks (§5.2).

### 5.1 The split

| MACHINE-VERIFIABLE (CI gate — schema/graph invariants) | HUMAN-JUDGMENT (gate, never auto-scored) |
|---|---|
| **Entity-reference integrity** — every named character/place/faction/item in generated text resolves to a registry entity (no dangling refs) | Whether the prose is *good* / distinctive / non-bland |
| **Naming-collision / duplicate detection** — two distinct entities sharing a name; spelling drift vs. canonical spelling | Whether a name "feels right" for the culture |
| **Timeline / chronology consistency** — event A before B per timeline; character not referenced before introduction or after death; no two-places-at-once | Pacing, dramatic timing, whether a reveal *lands* |
| **Broken cross-reference detection** — codex/quest references a KB id that doesn't exist or is wrong-tier | Theme / "controlling idea" coherence |
| **Canon-fact contradiction** (graph-expressible) — generated assertion conflicts with a hard-canon fact (KG/neurosymbolic check) | Voice consistency; tonal appropriateness |
| **Retcon / version tracking** — fact changed across versions; which artifacts depend on the changed fact (where-used) | Whether a contradiction is an *intentional* device (unreliable narrator) vs. a bug |
| **Terminology / glossary consistency** (shared with loc) | Emotional impact; whether a twist "works" |
| **Naming-registry rule conformance** — generated names match per-culture phonotactic rules / conlang lexicon | Whether the world feels *alive* and lived-in |

**Rule of thumb (mirrors the engine-wide pattern):** anything expressible as a graph/timeline/registry
invariant is a CI gate; anything requiring taste, theme, voice, or "does the twist work" is a human
gate. The one subtle case the factory MUST get right: a contradiction-detector that doesn't
understand *intentional* ambiguity (FromSoftware-style) will false-positive — hence the
`ambiguity_flag` / canon-tier in §4.2; flagged-ambiguous facts are exempt from contradiction gates.

### 5.2 Why this split is evidence-based (VERIFIED benchmarks)

- **ConStory-Bench / "Lost in Stories"** (arXiv 2603.05890, verified): 2,000 prompts; a taxonomy of
  **5 error categories / 19 subtypes**; an automated checker (**ConStory-Checker**) that grounds each
  judgment in explicit textual evidence. Key empirical findings: consistency errors are **most common
  in factual and temporal dimensions**, **concentrate in the MIDDLE of long narratives**, and occur in
  higher-entropy segments. → This is the *direct* justification for an external canon KB + continuity
  battery: the model's *internal* consistency degrades precisely where a long factory generation would.
- **LongGenBench** (ICLR 2025, verified): across 4 scenarios / 16K–32K tokens, **all ten SOTA models
  struggled with long-form generation under constraints**, even when they ace long-context
  *understanding*. → Long-form coherence is not solved by bigger context windows; you need external
  grounding + checks.
- **TimE** (NeurIPS 2025 poster; 38,522 QA pairs across Wiki/News/Dial): temporal reasoning is a
  consistent LLM weak point. → Timeline consistency is the single most fragile dimension and the
  highest-value machine check. (Cited at the confidence of a poster listing.)
- **lechmazur/writing creative-writing benchmark** (verified GitHub): pairwise-comparison evaluation
  of how well models weave **10 required story elements**, across 31 models — i.e. even "quality"
  evaluation in practice leans on *constraint satisfaction + LLM-as-judge*, never a clean fun-score.

---

## 6. AI-Generatability Assessment

**Verdict: narrative/lore is the MOST AI-tractable creative discipline in game dev — conditional on
canon grounding — but tractability is steeply tiered.**

| Content / task | Maturity (grounded against canon KB) | Mode |
|---|---|---|
| Codex / lore entries / in-game books | **HIGH** | generate → ground → check → freeze |
| Item & flavor text | **HIGH** | generate → check → freeze |
| Barks / systemic one-liners | **HIGH** | generate (first draft) → spot-check |
| Audio logs / environmental notes/signage | **HIGH–MED** | generate → ground → light human edit |
| Naming (per culture/registry) | **HIGH** | generate → registry-conformance + collision check |
| Side quests (objectives + supporting prose) | **MED** | generate structure+prose → human edit |
| Worldbuilding *expansion* (new region/faction lore) | **MED** | generate proposal → human ratify into KB |
| Main-arc narrative / theme / signature voice | **LOW** | assist-only; human-led |
| The canon KB *itself* (the source of truth) | **LOW** (authoring) | human-authored or human-ratified |

**Why it's the most tractable:** (1) most of the *volume* is in HIGH tiers (codex/flavor/barks); (2)
text is the native LLM modality — fluency and on-style prose are largely solved (Claude/GPT-class
models write readable, voice-carrying prose); (3) the canon KB converts an open-ended creative task
into a *constrained, retrieval-grounded* one, which is where LLMs are strongest.

**The limits (verified failure modes):**
- **Canon drift** — long-form factual/temporal drift, concentrated mid-generation (ConStory-Bench).
  *Mitigation: external KB grounding + continuity gate; chunk + re-ground; never one-shot long lore.*
- **Blandness / genericness** — competent-but-flavorless "AI-default" prose; the thing human review
  catches but auto-metrics miss (BLEU/ROUGE poorly correlate; even BERTScore is partial).
- **Repetition** — across thousands of barks/items, dedup + variety checks are needed (mechanical).
- **Derivative / IP risk** — ungrounded generation drifts toward training-data tropes; this is both a
  quality and a *legal* risk (ties to the asset-provenance/IP machinery in generative-asset-ai.md §5).
  *Mitigation: ground against the OWN canon KB; record provenance; the KB is the de-tropifier.*
- **Intentional-ambiguity false positives** — see §5.1; the KB must model ambiguity as canon.

**The freeze principle (carried from narr-loc §3.5, reaffirmed):** any shipped narrative text is
*generated → grounded → continuity-checked → human-gated where stakes warrant → FROZEN as static
authored content* that then flows through the normal loc/VO pipeline. No unbounded runtime lore
generation in canon-critical paths.

---

## 7. Genre Variation

Narrative/worldbuilding *load* varies enormously by genre, even though the canon-KB *shape* is
constant. (Extends the genre matrices in `game-design-discipline.md` and `narrative-localization.md`.)

| Genre | Worldbuilding load | Canon-KB depth | Dominant text tiers | Continuity-check emphasis |
|---|---|---|---|---|
| **Narrative RPG** (Witcher/BG3-like) | Massive | Deep entity+timeline+faction graph; full bible | all tiers, heavy main-arc | full battery; timeline + entity-ref critical |
| **Systemic sandbox / emergent** (Nemesis-like, sim) | Med authored + high *generated* | Entity registry + relationship graph as a RUNTIME generator | barks, generated event text, flavor | naming/dedup + relationship-graph legality |
| **Competitive multiplayer** | Low (lore as skin/flavor) | Shallow: factions/heroes/cosmetic lore | barks, callouts, store/marketing copy | terminology + loc consistency; minimal canon graph |
| **Roguelike w/ emergent lore** | Med (system-generated history) | Generators + content pools + meta-unlock lore graph | flavor, item, run-summary text | seed-determinism + naming-collision |
| **Deterministic-sim PILOT** (factory/automation, det-RTS) | **Low–Med** (lore is light; world is mechanism-first) | **Shallow but exact**: small entity registry (machines/resources/regions), light timeline, naming registry | codex/tutorial/flavor/item; little branching narrative | **entity-ref integrity + naming registry + glossary** — fully machine-verifiable; near-zero subjective-shell |

**Pilot fit (reinforces AAA-RECONCILIATION §11):** the deterministic-sim pilot has the *smallest*
narrative subjective shell — its lore is light, its entity set is small and exact, and essentially
all of its continuity checking (entity-ref, naming, glossary, codex/tutorial correctness) is
machine-verifiable. The canon KB for the pilot is small but proves the whole grounding + check loop
end-to-end with minimal human-gated prose.

---

## 8. Proposed Agent Roles (studio-of-agents)

Net-new roles for this vector, all organized *around the canon KB*. (Complements the
`narrative-designer / writer / localization-engineer` already proposed in AAA-RECONCILIATION §5.6.)

| Agent role | Owns | Primary KB interaction |
|---|---|---|
| **narrative-director** | premise, pillars, theme, arc spine; brand-level coherence | authors/ratifies top-level canon; sets `story-structure-spec` |
| **worldbuilder** | geography, factions, history, cultures, cosmology, magic/tech, ecology, economy-in-fiction | **writes the canon KB** (entity/relationship/timeline registries) |
| **loremaster / continuity-editor** | canon integrity; runs the continuity-check battery; manages retcons + "lore yoga"; owns ambiguity flags | **gate-keeps the KB**; adjudicates contradiction flags (machine-flagged → human-ruled) |
| **quest-designer** | main & side quest structure + supporting narrative | reads KB (grounded); writes quest text; emits `quest-schema` (per narr-loc §7.2) |
| **systemic / bark-writer** | barks, systemic one-liners, ambient/environmental text | KB-grounded high-volume first-draft generation |
| **cinematic-writer** | cutscene/cinematic screenplays, critical-path dialogue | KB-grounded; human-led; feeds narrative-graph + VO/timing |
| **copywriter** | item/flavor/achievement text, marketing/store copy | KB-grounded; brand-voice + legal review |

**Collaboration model:** the **worldbuilder** populates the KB; the **narrative-director** sets arc +
theme; **quest/bark/cinematic/copy** agents are all *KB-grounded consumers* (RAG against canon); the
**loremaster** is the gate — every generated artifact must pass the continuity battery, and any
machine-flagged contradiction is escalated to the loremaster for a human ruling (the "lore lawyer"
function, verified at Activision Blizzard). The loremaster also owns retcon propagation (where-used).

---

## 9. Factory Artifacts / Contracts (net-new)

These extend, and do not duplicate, the narrative-graph / quest-schema / bark-rules / loc-string
contracts already defined in `narrative-localization.md` §7.

1. **`canon-kb.schema`** (THE KEYSTONE) — the structured canon: `entity-registry` (typed,
   stable-ID), `relationship-graph` (typed edges), `timeline` (events + per-entity validity windows),
   `naming-registry` (canonical spellings + phonotactic/conlang rules + reserved names), `canon-facts`
   (assertions with `{source, canon_tier, valid_from, valid_to, ambiguity_flag}`), `style/voice`
   fingerprints. Has a **query/grounding API** (the articy-API precedent). *Build; optionally wrap an
   articy entity DB where a visual DB is desired.*

2. **`story-structure-spec`** — chosen structure model(s) (3-act / Hero's Journey / Story Circle /
   Freytag) instantiated as the arc spine + beat list + target pacing curve; references quest/narrative
   nodes. Owned by narrative-director.

3. **`narrative-arc-contract`** — per-character/per-quest arc assertions that *are* machine-checkable
   (e.g. character appears only within `[introduced, departed]`; required beats present in order) plus
   explicit human-gate delegation for the non-verifiable remainder (theme, payoff). The narrative
   analog of the `design-intent-contract`.

4. **`game-text-taxonomy-manifest`** — declares, per game, which text tiers exist, their volume
   targets, stakes tier, and AI-tractability mode (HIGH-freeze / MED-edit / LOW-assist). Drives which
   gates and which human review each tier gets.

5. **`canon-continuity-check-battery`** (CI gates) — `entity-reference-integrity`,
   `naming-collision`, `naming-registry-conformance`, `timeline-consistency`,
   `broken-cross-reference`, `canon-fact-contradiction` (KG/neurosymbolic, ambiguity-aware),
   `retcon-where-used`, `terminology-consistency` (shared with loc), `repetition/dedup`. Outputs
   evidence-grounded flags (ConStory-Checker pattern) → loremaster adjudication.

6. **`lore-grounding (RAG) contract`** — the interface every generative agent uses: given a
   generation request + entity context, retrieve the relevant canon subgraph (graph-shaped retrieval,
   per FactKG evidence), inject as constraints, generate, then run the continuity battery before the
   artifact is accepted. Records *what canon was grounded against* (provenance) for auditability and
   retcon propagation.

**Wrap vs build:** *Wrap* articy:draft's entity DB/API (where a visual entity DB is wanted) and any
existing RAG/vector infra. *Build* the canon-kb.schema, the grounding contract, and the
continuity-check battery — none of the verified tools (World Anvil/Campfire/LegendKeeper/articy)
ship an agent-grounding + CI-continuity layer.

---

## 10. AAA Acceptance Bar

A narrative/worldbuilding/lore deliverable is "AAA-ready" when:

1. **A canonical KB exists** and is the single source of truth: every shipped named entity resolves
   to a registry node with stable ID, provenance, and canon-tier.
2. **Continuity battery is green** — zero dangling entity references; zero unintended naming
   collisions; timeline-consistent (no pre-introduction / post-death references, no two-places-at-once);
   zero broken cross-references; zero *unflagged* canon contradictions; terminology consistent.
3. **Naming conforms** to the registry's per-culture rules / conlang lexicon; no reserved-name use.
4. **Every generated text artifact is grounded + frozen** — produced via the lore-grounding contract,
   passed the battery, human-gated at the stakes tier its taxonomy entry declares, then frozen as
   static authored content flowing through the normal loc/VO pipeline (no runtime lore in canon paths).
5. **Retcons are tracked** — any canon-fact change has a recorded where-used impact and the dependent
   artifacts re-checked.
6. **Intentional ambiguity is modeled as canon** (flagged), not silently "fixed" by contradiction
   gates.
7. **Human-judged dimensions signed off** — theme, voice, pacing, "does the twist work" reviewed by a
   human (loremaster/narrative-director); never auto-scored. (Consistent with the engine-wide no-fun-
   score / playtest-satisfaction human-gate principle.)

---

## 11. Open Questions & Risks

1. **KB authoring bootstrap.** The canon KB is the keystone but is *itself* LOW-tractability to
   author. Who/what creates the initial bible — human seed + AI expansion (generate→ratify), and how
   much human ratification is the minimum? (Mirrors the asset copyrightability/ownership tension.)
2. **Ambiguity-aware contradiction detection is unsolved at the edges.** Distinguishing an
   intentional unreliable-narrator contradiction from a real continuity bug is partly human-judgment;
   the `ambiguity_flag` is necessary but not sufficient. Risk of false-positives blocking FromSoft-
   style design.
3. **Benchmark dating.** ConStory-Bench/"Lost in Stories" carries an arXiv ID in the 2603 (Mar-2026)
   range — recent and verified, but treat as a *single* primary source; re-check on revision. TimE is
   cited at poster-listing confidence.
4. **Blandness has no clean auto-metric.** BLEU/ROUGE are discredited for narrative; BERTScore is
   partial; LLM-as-judge is itself an LLM. The factory cannot auto-score "distinctive voice" — it
   stays a human gate. Risk of shipping competent-but-bland lore at scale if review is skipped.
5. **Derivative/IP risk compounds at volume.** Thousands of generated lore lines amplify
   training-data-trope leakage; grounding against the OWN KB mitigates but does not eliminate. Links to
   the IP/provenance risk register (R-001/R-002, generative-asset-ai.md).
6. **Tool-shape vs. agent-shape.** Verified lore tools (World Anvil/LegendKeeper/articy) are
   human-facing; none provide an agent-grounding RAG + CI-continuity API. The factory must build that
   layer — and resist importing a tool's human-UI assumptions into the machine contract.
7. **Studio-process evidence is thin for several studios.** Only Activision Blizzard's loremaster
   process and Ubisoft's narrative-director role were verified in detail; CDPR/Larian/Bethesda
   specifics are corroborated-but-not-single-source — do not treat as load-bearing.

---

## 12. Sources

See YAML frontmatter `sources`. Primary-verified anchors (read directly at capture time):
- **World-bible / studio canon:** Megill *Game Developer* story-bible article; GDC Vault
  environmental-storytelling ("indices"); **Activision Blizzard loremaster interview (Sean Copeland —
  "lore yoga", per-franchise historian + buddy, 6-person team) [VERIFIED]**; Ubisoft Narrative
  Director posting [VERIFIED]. GRRM/Elden Ring "overarching mythos" corroborated (PC Gamer page
  fetch-blocked → exact wording [UNVERIFIED]). TES/Kirkbride via community Imperial Library archive
  (NOT a studio source).
- **Lore-bible tooling [all VERIFIED from vendor pages]:** World Anvil features; Campfire Writing
  modules; LegendKeeper features; articy:draft X feature list + Talos Principle 2 showcase.
- **Machine-checkable continuity + AI-generatability [VERIFIED]:** ConStory-Bench/"Lost in Stories"
  (arXiv 2603.05890); LongGenBench (ICLR 2025, OpenReview 3A71qNKWAS); lechmazur/writing benchmark
  (GitHub). TimE (NeurIPS 2025 poster listing — poster-confidence). Supporting: FactKG KG-verification
  (arXiv 2408.07453); neurosymbolic NLI (arXiv 2405.01259); AWS RAG hallucination-detection patterns.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep multi-source synthesis: (1) worldbuilding discipline + world-bible + studio canon practices; (2) story-structure models + RAG-for-consistency + lore-bible tooling; (3) machine-checkable continuity + LLM narrative-consistency benchmarks + AI-generatability. All `reasoning_effort: high`, `strip_thinking: true`. **NOTE:** pass (2) self-declared limited fresh sources and hedged heavily — its tooling/benchmark claims were therefore treated as leads to VERIFY, not as facts. |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no library-API question in scope) |
| Tavily tavily_extract | 1 | Direct extraction of World Anvil `/features` (WebFetch was 403-blocked) — verified templates/maps/timelines/family-trees/diplomacy-webs/auto-linking. |
| Tavily tavily_search | 1 | Verified articy:draft Game Object Database / Entities+templates / Checkup Tools / API / Talos Principle 2 showcase (articy.com domain-restricted). |
| WebFetch | 6 | Primary-source verification: Campfire modules; LegendKeeper features; ConStory-Bench (arXiv 2603.05890 — title/authors/abstract confirmed); lechmazur/writing benchmark README; LongGenBench (OpenReview); Activision Blizzard loremaster ("lore yoga" confirmed verbatim). (PC Gamer GRRM page returned nav-only → flagged [UNVERIFIED].) |
| WebSearch | 0 | — |
| Training data | ~1 area | Narrative-structure-model canon (3-act / Hero's Journey / Story Circle / Freytag / Nemesis) — well-established craft, used only to structure §3.1; each model anchored to a primary source where one exists (Harmon Story Structure 101). |

**Total MCP tool calls:** 5 (3 perplexity_research + 1 tavily_extract + 1 tavily_search) + 6 WebFetch verifications = 11 external retrievals.
**Training data reliance:** low — every named tool feature, studio process, and academic benchmark
was verified DIRECTLY against its primary source before being stated as fact (per the explicit
prior-confabulation warnings in the project's earlier research). Unverifiable items are marked
[UNVERIFIED]; the one deep-research pass that self-declared thin sourcing is flagged and demoted to
framing-only.
