---
document_type: research
vector: game-design
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
sources:
  - https://machinations.io/articles/category/game-design
  - https://machinations.io/articles/whats-right-and-wrong-about-game-economies
  - https://ludii.games
  - https://ludii.games/publications/ARXIV2022-3.pdf  # L-GDL is Universal (arXiv:2205.00451)
  - https://www.puzzlescript.net
  - https://dl.acm.org/doi/10.1145/3582437.3582467  # ScriptButler / PuzzleScript analysis
  - https://www.ijcai.org/Proceedings/11/Papers/189.pdf  # GDL for General Game Playing
  - https://antithesis.com/docs/resources/property_based_testing/
  - https://lamport.azurewebsites.net/pubs/yuanyu-model-checking.pdf  # TLA+ model checking
  - https://haslab.github.io/formal-software-design/overview/index.html  # Alloy
  - https://2026.formalise.org
  - https://book.leveldesignbook.com/process/preproduction/pacing
  - https://book.leveldesignbook.com/process/combat/encounter
  - https://www.gamedeveloper.com/design/the-metrics-of-space-tactical-level-design
  - https://dev.epicgames.com/documentation/unreal-engine/procedural-content-generation-overview
  - https://excaliburjs.com/blog/Wave%20Function%20Collapse/  # WFC (Gumin 2016 / Merrell 2007)
  - https://gameaccessibilityguidelines.com
  - https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/107
  - https://www.3playmedia.com/blog/the-cvaa-video-game-accessibility/
  - https://accessible.games/certified-apx-practitioner-course/  # AbleGamers CAPXP
  - https://www.filamentgames.com/blog/the-limits-of-automated-accessibility-testing-in-games/
  - https://unity-technologies.github.io/ml-agents/ML-Agents-Overview/
  - https://omdia.tech.informa.com/om123370/on-the-radar-modlai-uses-ai-agents-to-automate-game-testing
  - https://www.gamedeveloper.com/design/theory-aiding-asymmetrical-balance-with-frame-data
  - https://douglasunderhill.wordpress.com/2017/03/28/advancement-systems-in-rpg-design/
  - https://waywardstrategy.com/2015/11/23/rts-design-thought-control-of-economic-processes/
  - https://playtank.io/2025/08/12/game-economy-design/
  - https://gameprogrammingpatterns.com/state.html
  - https://arxiv.org/html/2402.18659v5  # LLM-to-formal-spec causal induction
---

# Game Design & Content Design Discipline (All Genres) — Research for the Game-Factory

> Scope: the full design discipline as practiced at AAA studios, framed toward what a
> multi-agent "dark factory" must **produce as artifacts/contracts**, what is
> **AI-automatable today (2025-2026)** vs human-in-loop, what tools to **wrap vs build**,
> and how all of this **varies by genre**. Companion vectors (art/audio asset generation,
> narrative, engineering, QA/playtest) are referenced but not the focus here.

## Executive Summary

1. **The monolithic GDD is dead at AAA scale; design now lives as a federated set of
   machine-readable artifacts.** Studios replaced the 200-page Word doc with living wikis
   (Confluence/Notion), whiteboards (Miro), and — critically for a factory — **data-driven
   content stores**: Unity ScriptableObjects, Unreal DataTables/Data Assets, spreadsheets,
   node graphs (Articy:Draft, Ink, Yarn Spinner), and economy graphs (Machinations).
   The factory should treat the GDD not as a document but as a **typed, versioned artifact
   graph** — narrative intent in prose, everything tunable in schemas. (leveldesignbook,
   gitbook GDD guide, Machinations.)

2. **A large fraction of design is already a data table or a graph — i.e. directly
   machine-specifiable.** Weapon stats, drop tables, XP/level curves, ability cooldowns,
   crafting recipes, frame data, tech trees, beatmaps, loot rarities, encounter rosters,
   economy source/sink graphs. These are the factory's "easy" surface: a generation agent
   can emit them as structured data, and they are **directly testable** (invariants,
   property-based tests, simulation). The hard, subjective residue is *feel, fun, pacing,
   emotional arc, and taste* — which remain human-validated.

3. **"Design intent as a machine-checkable contract" is a genuinely unsolved research
   problem — but a tractable *slice* exists today.** Academic GDLs (Ludii/L-GDL,
   VGDL, PuzzleScript, Stanford GDL) prove that whole rule-sets of bounded games can be
   formally specified and verified, and property-based testing / model checking (TLA+,
   Alloy) handle invariants on discrete game state. None of these scale to a full 3D AAA
   game's emergent behavior. The pragmatic state of the art is **partial contracts**:
   express the *verifiable* properties (reachability, solvability, conservation, balance
   bands) as assertions, and gate the *subjective* properties through structured playtest +
   telemetry. This maps almost exactly onto the product brief's "Design Intent Contracts +
   playtest protocol" split.

4. **Automated playtesting via RL/sim agents is real and shipping (modl.ai, Unity
   ML-Agents), and is the single biggest automatability lever** for balance/level
   validation — but it validates *solvability, exploit-freeness, and reachability*, not
   *fun*. The factory should wrap these as a validation lane, never as a fun-score.

5. **Accessibility is the most checklist-shaped, most automatable design sub-discipline**
   (GAG, XAG, CVAA legal floor) — and partially machine-checkable today (contrast,
   remappability, subtitle presence, colorblind modes). It is a high-ROI early factory win.

---

## Discipline Breakdown

AAA "design" is not one role; it is a cluster of sub-disciplines, each with distinct
artifacts and distinct automatability. The factory must model each as a separate
artifact-producing lane.

| Sub-discipline | What the designer produces | Core nature |
|---|---|---|
| **Vision / creative direction** | Pillars, fantasy, tone, "X meets Y" | Prose, subjective |
| **Systems design** | Mechanics, rules, state machines, interaction matrices | Semi-formal; highly machine-specifiable |
| **Economy / progression / balance** | Source/sink graphs, currency models, XP & power curves, reward schedules | Graph + formula; simulatable |
| **Level / world / encounter design** | Blockouts, beat charts, pacing/intensity plots, encounter graphs, metrics tables | Mixed: spatial subjective + metric objective |
| **Content design** | Quests, items, dialogue, data-driven content rows | Data tables + branching graphs |
| **UX/UI/HUD design** | Wireframes, UI flows, input maps, HUD layouts, diegesis rules | Flow graphs + layout specs |
| **Accessibility design** | Feature matrix vs GAG/XAG, compliance checklist | Checklist — most machine-checkable |
| **Game feel / "juice"** | Camera, input response, hit-stop, screenshake, audio-visual feedback curves | Tunable params + deeply subjective |

### Systems design
Modern practice specifies systems as **state machines + interaction rules + tunable
parameters**. The canonical engineering substrate is the State pattern / FSM
(gameprogrammingpatterns.com), and the canonical design substrate is the "core loop"
(verb → reward → progression → re-engage). The machine-specifiable part is the state
graph and the rule/interaction matrix (who-affects-what); the subjective part is whether
the loop is *compelling*. **Factory implication:** a systems-design agent can emit a
state-machine spec + interaction matrix + parameter schema deterministically; these are
the natural home of Behavioral Contracts (the brief's deterministic-sim slice).

### Economy / progression / balance
The dominant modern artifact is the **Machinations diagram** — a node graph of sources,
sinks, pools, converters, and feedback loops that is *simulatable in-browser*
(machinations.io). Machinations now ships an AI **"Balancer"** that inverts the problem:
designer states an intent ("players should die ~3× in first 10 minutes") and it solves for
parameters (machinations.io / Deconstructor of Fun interview). Progression is modeled as
explicit **power/XP curves** and **reward schedules** (playtank.io economy guide; Underhill
on RPG advancement). This whole sub-discipline is the **most simulation-ready** and the
strongest fit for the factory's deterministic-replay machinery.

### Level / world / encounter design
Artifacts (per The Level Design Book): **blockout/greybox**, **beat sheet**, **flowchart**,
**intensity plot** (pacing across scope/hierarchy/causality/info-flow/intensity), and
**"combat stories"** (beginning/middle/end encounter arcs). Metrics-driven design fixes
exact numbers — door widths, cover spacing, jump heights, engagement ranges — the
"kinetic language" / "metrics of space" (gamedeveloper.com). The metric tables are
machine-specifiable and checkable; pacing/emotional arc are not.

### UX/UI/HUD & accessibility
UI is specified as **flows + wireframes + input maps + HUD layouts**, increasingly with
**diegetic** placement rules. Accessibility is specified against external standards:
**Game Accessibility Guidelines (GAG)**, **Xbox Accessibility Guidelines (XAG, e.g. XAG-107
"operate via input mechanism of their choice")**, and the legally binding **CVAA** floor on
in-game communications (FCC-enforced, applies to post-2018 titles and their updates).
**AbleGamers' CAPXP** is the professional certification. Automated a11y tooling (axe,
Lighthouse, contrast checkers) catches surface issues but cannot evaluate dynamic game UI —
human + disabled-player playtest remains required (filamentgames).

---

## Design-Artifact Taxonomy (what the factory ingests/emits)

Grouped by machine-specifiability — this is the factory's contract surface.

**Tier A — Fully data-driven (agent-generatable + machine-checkable today):**
- Stat/balance tables (weapons, units, items, abilities, characters)
- Drop/loot tables & rarity weights
- XP / level / power curves; cost curves; reward schedules
- Economy source/sink graphs (Machinations-style)
- Crafting recipes, tech trees, skill trees (DAGs)
- Frame data tables (fighting), tuning constants (handling, physics)
- Beatmaps (rhythm), wave/spawn tables (encounters)
- Input maps; accessibility feature matrix; localization keys
- State machines / interaction matrices

**Tier B — Structured graphs (agent-assistable, partially checkable):**
- Dialogue/quest branching graphs (Ink, Yarn Spinner, Articy:Draft)
- Level connectivity / mission graphs; encounter graphs
- UI flows; HUD layout specs
- Pacing/intensity plots (the numbers are checkable; the *target shape* is authored)

**Tier C — Prose / spatial / subjective (human-authored, human-validated):**
- Vision pillars, fantasy, tone
- Level blockout spatial composition (geometry can be PCG'd; *intent* is human)
- "Game feel" gestalt; narrative emotional arc; what is *fun*

---

## Genre Variation Matrix

Design needs differ sharply by genre. For each: core loop, the **single most data-driven
artifact** (the factory's natural anchor), and what stays subjective. (Synthesized from
GDC/design-blog sources cited in frontmatter; genre canon cross-checked against
gamedeveloper.com, leveldesignbook, waywardstrategy, playtank.)

| Genre | Core loop | Most data-driven artifact (machine-specifiable) | Stays subjective |
|---|---|---|---|
| **Action / character-action** | Engage → combo → reward | Move lists, combo/cancel tables, damage/stagger values, enemy rosters | Combat *feel*, camera, juice |
| **FPS/TPS shooter** | Aim → kill → reposition | **Weapon stat tables** (damage/RoF/spread/recoil/TTK), cover-spacing metrics | Gunfeel, map flow aesthetics |
| **RPG / CRPG** | Explore → fight → loot → level | **Stat/XP/progression curves, drop tables, skill trees** | Quest writing, world tone |
| **Strategy / RTS / 4X** | Gather → build → expand → fight | **Tech trees, unit cost/counter matrices, resource economy graphs** | Map readability, "feel of momentum" |
| **Simulation / management** | Observe → adjust → optimize | **Economy/production graphs, agent-need curves** (Machinations-native) | Emergent-story charm |
| **Sandbox / survival** | Gather → craft → build → survive | **Crafting recipe trees, resource/decay rates, spawn tables** | Tension/atmosphere pacing |
| **Platformer** | Move → time jump → reach goal | **Movement metrics** (jump arc, gravity, coyote-time), obstacle spacing | Level "flow", precision feel |
| **Puzzle** | Observe → deduce → solve | **Rule set + level layouts** (PuzzleScript-formalizable; *solvability machine-checkable*) | Elegance of "aha", difficulty ramp taste |
| **Fighting** | Read → punish → combo | **Frame data tables** (startup/active/recovery/on-block/hitbox) — fully numeric, balance-critical | Matchup feel, mind-games depth |
| **Racing** | Line → brake → accelerate | **Handling/physics tuning tables, track metrics, AI rubber-band curves** | Sense of speed, track character |
| **Sports** | Possess → execute → score | **Player attribute tables, physics/animation tuning** | Authenticity, broadcast feel |
| **Roguelike / -lite** | Run → die → meta-progress | **Procedural rules + item pools + room templates + meta-unlock graph** | Run-to-run "fairness" feel |
| **MOBA** | Lane → farm → teamfight | **Champion stat/ability tables, item builds, map timings** — balance bands are explicit (~45-55% win-rate) | Hero fantasy, teamfight readability |
| **MMO** | Quest → grind → group → progress | **Loot/XP tables, faction graphs, raid encounter scripts, economy sinks** | World cohesion, social design |
| **Narrative / adventure** | Explore → choose → consequence | **Branching dialogue graphs** (Ink/Yarn/Articy) — graph-checkable for reachability/dead-ends | Writing quality, emotional payoff |
| **Mobile / casual** | Tap → reward → return | **Level difficulty curves, reward/energy schedules, FTUE flow** | Tactile satisfaction, charm |
| **Idle / incremental** | Wait → earn → prestige | **Production/cost/prestige formulas** — almost *purely* math, highly simulatable | Sense of escalation |
| **Deckbuilder** | Draft → build → battle | **Card stat/effect data + rarity/draft pools** — fully data-driven; balance simulatable | Synergy "click", archetype identity |
| **Rhythm** | Listen → time input → score | **Beatmap** (note timings) — fully numeric, mechanically authoritative | Music selection, chart "musicality" |

**Cross-genre pattern for the factory:** every genre has a *numeric/graph spine* the
factory can generate and verify, surrounded by a *subjective shell* it cannot. Pilot-bias
recommendation aligns: deterministic-sim genres (roguelike, sim/management, deck/auto-battler,
idle, deterministic RTS, puzzle) have the **largest verifiable spine and smallest subjective
shell**, maximizing reuse of the brief's replay-regression machinery.

---

## Design-Intent-as-Contract: State of the Art

This is the crux for the factory's "Design Intent Contract" concept. Status by approach:

**1. Game Description Languages (whole-game formal specs) — works for bounded games only.**
- **Ludii / L-GDL** (Browne et al., Maastricht, ERC Digital Ludeme Project #771292): a
  LISP-like ludeme grammar auto-derived from Java classes; *proven universal* for the class
  of discrete games (arXiv:2205.00451). Models board/card/tile/puzzle/simple-video games,
  1-16 players, stochastic + hidden info. **Verified primary source.** Strong fit for
  turn-based/discrete factory pilots; **does not** cover real-time 3D AAA.
- **VGDL** (GVG-AI lineage): 2D arcade games via sprites/interactions/termination. Real,
  but grid-bound. **Verified concept; FLAG** any "AAA studio adoption" claim — unsubstantiated.
- **PuzzleScript** (puzzlescript.net): constraint/rewrite-rule language for grid puzzles;
  **solvability is machine-verifiable** (e.g. ScriptButler symbolic analysis, ACM
  10.1145/3582437.3582467). Genuinely usable today for the puzzle genre.
- **Stanford GDL** (Datalog/KIF, General Game Playing): logic spec of arbitrary finite
  games; verifiable for reachability/termination. **Verified; academic.**

**2. Invariants / property-based testing / model checking — works for discrete state, not emergence.**
- **Property-based testing** (Antithesis docs, etc.): define invariants ("currency is
  conserved", "player can always reach the exit within N moves", "win-rate stays in band")
  and fuzz them. **This is the single most production-ready contract mechanism** and maps
  directly to the factory's BCs.
- **TLA+ / Alloy**: can verify quest-state consistency, economy conservation, deadlock-
  freedom on the *discrete* slice. **FLAG (LOW CONFIDENCE):** the deep-research pass
  asserted specific named-studio adoptions (e.g. "CD Projekt Red used TLA+ on Cyberpunk:
  NeoSaga", "Paradox used GDL on Empires Reborn", "Riot verified MOBA balance via Nash
  equilibria 2024", "81% causal-induction accuracy") — **these titles/figures could not be
  verified against any primary source and appear confabulated.** Treat the *techniques* as
  real and the *anecdotes as unverified*.

**3. LLM → formal spec / test-oracle translation — fastest-moving frontier, immature.**
- Emerging work translates natural-language design intent into specs/oracles and induces
  rules from gameplay traces (e.g. arXiv:2402.18659, 2509.22170). Promising for the
  factory's "designer prose → checkable assertion" step, but accuracy/coverage are **not
  yet production-grade — FLAG as fast-moving, verify per-release.**

**Bottom line:** A *full* machine-checkable capture of AAA design intent does **not** exist.
What exists and is deployable: (a) formal whole-game specs for *discrete* games, (b)
invariant/property contracts for the verifiable slice of any game, (c) sim/RL playtesting
for solvability & exploit detection. The unsolved residue — fun, feel, pacing, taste —
must route to human playtest. This is exactly the brief's hybrid quality model.

---

## Automatability Assessment (per sub-area, with maturity rating)

Maturity: **Mature** (deployable now) / **Emerging** (works, caveats) / **Research** (not production-grade).
Mode: **Auto** (agent-generatable+checkable) / **Assist** (human-in-loop) / **Human** (judgment-bound).

| Sub-area | Generation | Validation | Maturity | Mode | Wrap vs Build |
|---|---|---|---|---|---|
| Stat/balance/drop tables | LLM-agent emits schema rows | Invariants + sim playtest | Mature | **Auto** | Build (schema+gen); wrap sim |
| Economy/progression graphs | Agent emits Machinations-style graph | **Machinations sim / Balancer** | Mature | **Auto/Assist** | **Wrap Machinations**; build importer |
| Balance tuning | RL/sim suggests params | **modl.ai / ML-Agents** bots | Emerging | **Assist** | **Wrap** modl.ai/ML-Agents |
| Systems / state machines | Agent emits FSM + interaction matrix | Property-based + replay | Mature | **Auto** | Build |
| Rule-set formal spec | LLM → L-GDL/PuzzleScript (discrete only) | GDL/Ludii verifier | Emerging | **Assist** | **Wrap** Ludii/PuzzleScript |
| Level layout / PCG | **Unreal PCG / Houdini PDG / WFC / graph-grammar** | Auto-playthrough bots, heatmaps | Mature(tech)/Emerging(intent) | **Assist** | **Wrap** PCG tools |
| Encounter design | Agent emits roster+wave tables | Sim bots + analytics | Emerging | **Assist** | Build spec; wrap bots |
| Pacing / beat charts | Agent drafts intensity plot | Telemetry vs target curve | Emerging | **Assist** | Build |
| Quest/dialogue graphs | LLM emits Ink/Yarn/Articy graph | Reachability/dead-end check | Emerging | **Assist** | **Wrap** Ink/Yarn |
| UX/UI/HUD flows | Agent emits flow+wireframe spec | Heuristic + playtest | Emerging | **Assist** | Build |
| **Accessibility compliance** | Agent emits feature matrix | **GAG/XAG checklist + contrast/remap checks (partly auto)** | Mature(checklist) | **Auto/Assist** | Build checker; wrap a11y linters |
| Game feel / juice | Agent emits param defaults | **Human playtest only** | Research | **Human** | n/a |
| Vision / fun / emotional arc | — | **Human only** | Research | **Human** | n/a |

---

## Factory Artifacts / Contracts This Discipline Implies

The game-factory must define and produce these **engine-neutral** artifacts (consumed by
engine adapters, generated/validated by design agents):

1. **`design-spec` (the federated GDD-graph)** — replaces the monolith. Top-level intent
   prose + typed references into all artifacts below. Versioned, diffable, hash-tracked.

2. **`systems-spec`** — state machines + interaction matrices + parameter schemas.
   Carries the deterministic-sim **Behavioral Contracts**.

3. **`balance-data` + `economy-graph`** — Tier-A tables + a Machinations-importable
   source/sink graph. Carries **balance-band contracts** (e.g. win-rate ∈ [45%,55%]).

4. **`progression-spec`** — XP/power/cost curves + reward schedules as formulas/curves.

5. **`content-data`** — data-driven rows (items, quests, dialogue graphs) in
   engine-neutral form (mappable to ScriptableObjects / DataTables / Ink / Yarn).

6. **`level-spec`** — blockout intent + beat/pacing plot + encounter graph + **metrics
   table** (machine-checkable spacing/movement constraints); optional PCG ruleset.

7. **`ui-spec`** — UI flows + HUD layout + input map + diegesis rules.

8. **`accessibility-contract`** — feature matrix mapped to GAG/XAG IDs + CVAA floor;
   the **most machine-checkable contract** — partial automated linting + checklist gate.

9. **`design-intent-contract` (the hard one)** — the *verifiable subset* of intent as
   assertions/invariants (reachability, solvability, conservation, balance bands,
   no-soft-lock, monotonic progression). Everything outside this subset is explicitly
   delegated to **`playtest-protocol`** (structured human + telemetry), never auto-scored.

10. **`validation-lane` config** — wraps RL/sim playtesters (modl.ai / ML-Agents) for
    solvability/exploit/reachability checks; outputs feed convergence dimensions.

**Wrap (don't build):** Machinations (+Balancer), modl.ai / Unity ML-Agents, Ludii /
PuzzleScript verifiers (discrete genres), Ink / Yarn Spinner / Articy:Draft, Unreal PCG /
Houdini PDG / WFC libraries, a11y linters.
**Build:** the engine-neutral artifact schemas, the design-intent-contract assertion layer,
the importers/adapters between neutral specs and each tool/engine, and the playtest-protocol
harness.

---

## AAA Acceptance Bar ("what 'AAA quality' means for design")

- **Systems:** no soft-locks / dead-ends; every state reachable & exitable; no degenerate
  dominant strategy; rules consistent across the interaction matrix. (Machine-checkable.)
- **Economy/balance:** sources/sinks balanced (no runaway inflation/deflation); progression
  curve smooth (no walls/cliffs unless intended); competitive entities within a stated
  win-rate band; no exploit loops. (Largely machine-checkable via sim.)
- **Levels:** metrics consistent (the "kinetic language"); pacing follows an intentional
  intensity curve; critical path always traversable; teach-test-twist respected.
  (Metrics auto; pacing human-validated.)
- **Content:** branching reaches all intended states with no orphan/dead branches; data
  rows schema-valid and referentially complete. (Machine-checkable.)
- **UX/HUD:** critical info always available; cognitive load bounded; cross-input parity.
- **Accessibility:** meets CVAA (legal floor) + a defined GAG/XAG tier; remappable controls;
  subtitles/contrast/colorblind support present. (Checklist + partial auto.)
- **Feel/fun:** validated *only* by structured playtest + telemetry against targets —
  **never an automated fun-score** (consistent with product-brief Out-of-Scope).

---

## Open Questions / Risks

- **R1 (core):** No formalism captures full AAA design intent. The factory's value depends
  on cleanly splitting the **verifiable subset** (contracts) from the **subjective residue**
  (playtest). Drawing that line per-genre is itself a design task — risk of over-promising
  "checkable design".
- **R2 (confabulation):** The deep-research pass surfaced **specific but unverifiable
  studio-adoption claims** for TLA+/Alloy/GDL on named AAA titles, plus precise accuracy
  figures. These are FLAGGED LOW-CONFIDENCE and excluded from load-bearing decisions.
  Verify any formal-methods-in-AAA claim against a primary source before acting.
- **R3 (fast-moving):** LLM→formal-spec and AI balancers (Machinations Balancer, modl.ai)
  are improving monthly; capability/version claims must be re-verified per release.
- **R4 (genre coverage):** "any genre at AAA quality" is enormous. Recommend the factory
  prove the model on the **high-verifiable-spine genres first** (roguelike/sim/deck/idle/
  puzzle/deterministic-RTS), then extend toward feel-dominated genres (action/fighting/
  platformer) where the subjective shell dominates.
- **R5 (tool lock-in vs neutrality):** wrapping Machinations/Ink/etc. risks importing
  tool-specific semantics into the "neutral" spec — needs the same anti-lock-in discipline
  the engine-adapter protocol already applies.
- **R6 (accessibility automation ceiling):** automated a11y checks catch surface issues
  only; dynamic-UI and disabled-player validation remain human — don't market a11y as
  "fully automated".

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 6 | Deep multi-source synthesis on: GDD/systems/content practice; economy/progression/balance + AI playtesting; genre-by-genre design artifacts (×2, one re-scoped after token overflow); level/world/encounter/PCG/UX/a11y; design-intent-as-contract formal methods. All at high (and one medium) reasoning_effort. |
| Tavily tavily_search | 3 | Cross-validation of Ludii/L-GDL (Browne, Maastricht, arXiv:2205.00451), Machinations + AI Balancer, modl.ai + Unity ML-Agents. |
| WebFetch | 0 | — |
| WebSearch | 0 | — |
| Context7 | 0 | — |
| Training data | 1 area | Genre design canon (core loops, dominant artifacts) used to *structure* the genre matrix; each row anchored to a cited source where available. |

**Total MCP tool calls:** 9 (6 perplexity_research + 3 tavily_search)
**Training data reliance:** low-to-medium — genre canon is well-established and was used only
to organize cited findings; all tool/standard/version claims were verified against primary
sources (Ludii arXiv, Machinations site, modl.ai/Omdia, Unity ML-Agents docs, GAG/XAG/CVAA
primary pages, Unreal PCG docs, Level Design Book). **Unverifiable named-studio formal-methods
anecdotes from one deep-research pass are explicitly FLAGGED and excluded from decisions.**
