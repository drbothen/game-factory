---
document_type: research
vector: modding-ugc-tools
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory = engine-agnostic (Bevy/Unity/Godot primary; Unreal deferred) lights-out Dark Factory for AAA game development. No lock-in via adapter protocols; heavy reliance on DATA-DRIVEN content and the canon-KB. THIS vector: modding / UGC creation tools / workshop — framed as an ARCHITECTURAL property the factory can deliberately design IN (stable data schemas + mod API + content pipeline), with a wrap-first engine-agnostic UGC backend."
inputs:
  - docs/research/aaa/engineering-disciplines.md        # data-oriented/ECS, architecture-separation rule, headless-contract tiers, BC/VP
  - docs/research/aaa/game-design-discipline.md          # data-driven content, Tier-A/B/C artifact taxonomy, schema-validated content
  - docs/research/aaa/security-anticheat-trust-safety.md # UGC moderation/T&S, CSAM/OSA/DSA/COPPA legal duties, moderation-pipeline-contract, server-authority
  - docs/research/aaa/online-services-platform-distribution.md # distribution-adapter, human-gated tier, wrap-first BaaS, mod.io adjacency
  - docs/research/aaa/production-pipeline.md             # DAM, large-binary VCS, derived-data cache
  - docs/research/aaa/AAA-RECONCILIATION.md              # BC/VP mapping, convergence model, scope, risk register, R-009 confabulation meta-lesson
sources:
  # mod.io — engine-agnostic UGC backend (PRIMARY, verified this pass)
  - "mod.io documentation root (live, verified): https://docs.mod.io/"
  - "mod.io REST API v1 introduction (HTTPS/JSON, API-key + OAuth2, offset/limit pagination, or_fields filtering): https://docs.mod.io/restapi/"
  - "mod.io rate-limiting doc (per-key/token/IP limits, HTTP 429 + retry-after): https://docs.mod.io/restapi/ (Rate Limiting)"
  - "mod.io C++ SDK (MIT/BSL, CMake, async, GitHub — releases through May 2026, verified): https://github.com/modio/modio-sdk"
  - "mod.io Unity plugin (Unity 2021.3+, cross-platform, GitHub): https://github.com/modio/modio-unity"
  - "mod.io Unreal Engine plugin (3 most-recent UE versions; Win/Linux/Mac/iOS/Android public, console under NDA): https://github.com/modio/modio-ue"
  - "mod.io Add Mod KVP Metadata (REST): https://docs.mod.io/restapi/docs/add-mod-kvp-metadata"
  - "mod.io Add Mod Dependencies (REST: POST /games/:id/mods/:id/dependencies): https://docs.mod.io/restapi/"
  - "mod.io console cross-platform support (Xbox/PS/Switch authorized middleware) + Platform SSO: https://docs.mod.io/ (Console Cross-Platform Support / Platform SSO)"
  - "mod.io moderation (4-layer; Content Approval queue; Moderation Dashboard): https://docs.mod.io/ (Moderation)"
  - "mod.io monetization (virtual-currency Marketplace; Partner Program; Thunes processor): https://docs.mod.io/ (Monetization / How it Works)"
  - "mod.io Godot (community, GDExtension): https://godotengine.org/asset-library/ (Mod.io For Godot) + https://github.com/aNaOH/modio-godot"
  - "AWS case study (mod.io scale: 14M+ users, 130+ games across PC/console/mobile/VR): aws.amazon.com case study (mod.io)"
  # Steam Workshop / SteamUGC (PRIMARY, verified this pass)
  - "Steam Workshop Implementation Guide — ISteamUGC API, SteamUGC()->CreateItem, k_EWorkshopFileTypeMicrotransaction, Steam Cloud for preview images (VERIFIED): https://partner.steamgames.com/doc/features/workshop/implementation"
  # UEFN / Verse / Fortnite Creator economy (PRIMARY, verified this pass)
  - "Fortnite Platform & Economy (developer): https://www.fortnite.com/developer/platform-and-economy"
  - "Engagement Payout in Fortnite Creative (Epic dev docs): https://dev.epicgames.com/documentation/fortnite/engagement-payout-in-fortnite-creative"
  - "Verse language reference (Epic dev docs): https://dev.epicgames.com/documentation/en-us/uefn/verse-language-reference"
  - "Fortnite: developers to sell in-game items via UEFN from Dec 2025; 100% V-Bucks rev-share through 2026 (primary): https://www.fortnite.com/news/fortnite-developers-will-soon-be-able-to-sell-in-game-items"
  # Embedded scripting / sandboxing (PRIMARY, verified this pass)
  - "Luau sandboxing model (protected globals, __gc removed, tag-based destructors): https://luau.org/sandbox"
  - "Luau language site: https://luau.org"
  - "WebAssembly security model (fault isolation, linear memory bounds, CFI): https://webassembly.org/docs/security/"
  - "Wasm component model + WIT interface types: https://component-model.bytecodealliance.org/design/components.html"
  - "Extism (Wasm plugin framework, host-function capabilities, xtp test runner): https://extism.org/ , https://extism.org/docs/concepts/testing/"
  - "Wasmer (Wasm runtime, resource limits): https://wasmer.io"
  - "BepInEx plugin framework (Unity/.NET loader; plugin tutorial): https://github.com/BepInEx/bepinex-docs"
  - "Harmony CIL patching (prefix/postfix/transpiler): https://bsmg.wiki/modding/pc/harmony-patching.html"
  - "MonoMod (assembly-level IL patching): https://github.com/monomod/monomod"
  # Mod loaders / schema / load-order (PRIMARY, verified this pass)
  - "Thunderstore package spec (manifest.json, SemVer, dependencies field, topo load-order): https://wiki.thunderstore.io/mods/creating-a-package"
  - "Godot ModLoader config-JSON schema (extra.godot.config_schema, JSON Schema validation): https://wiki.godotmodding.com/guides/modding/config_json/"
  - "Topological sorting (dependency resolution): https://en.wikipedia.org/wiki/Topological_sorting"
  # Legal / IP / DMCA (PRIMARY, verified this pass)
  - "17 U.S.C. §101 (derivative work definition): https://www.law.cornell.edu/uscode/text/17/101"
  - "17 U.S.C. §512 (DMCA safe harbor; §512(c) hosting, notice-and-takedown, repeat-infringer policy, designated agent): https://www.law.cornell.edu/uscode/text/17/512"
  - "Micro Star v. FormGen Inc., 154 F.3d 1107 (9th Cir. 1998) — user map files are derivative works"
  - "Lewis Galoob Toys v. Nintendo, 964 F.2d 965 (9th Cir. 1992) — transient on-the-fly modification not a fixed derivative work"
  - "Steam 2015 Skyrim paid-mods: 25% modder / ~40% Bethesda / ~30-35% Valve split; live ~Apr 23 2015, reverted ~Apr 27-28 2015 (~4 days), full refunds: https://www.gamedeveloper.com/business/where-is-your-mod-now-how-valve-s-paid-mod-program-imploded-in-four-days"
  - "GWU IP&EL — advent and repeal of paid Skyrim mods: https://studentbriefs.law.gwu.edu/gwipel/2015/05/27/the-advent-and-repeal-of-paid-skyrim-mods-on-steam-workshop/"
confidence: >
  HIGH on: mod.io being a real, actively-maintained, engine-agnostic, console-authorized
  UGC backend with REST API + C++/Unity/Unreal SDKs (verified against docs.mod.io + GitHub,
  releases through May 2026); the embedded-scripting sandbox taxonomy (Lua/Luau/WASM/C#)
  and its security properties (verified against luau.org/sandbox, webassembly.org/docs/security,
  extism.org, BepInEx/Harmony/MonoMod repos); SteamUGC API existence/shape (verified against
  partner.steamgames.com); UEFN/Verse + Fortnite engagement-payout/Dec-2025 item-sales model
  (verified against fortnite.com + Epic dev docs); the core mod-IP/DMCA legal frame (17 U.S.C.
  §101/§512; Micro Star; Galoob; the 2015 Skyrim 25%/4-day facts).
  MEDIUM on: exact mod.io pricing tiers (vendor-gated), exact Bethesda Creation Club/Verified
  Creations contract terms (private), and fast-moving Fortnite economy specifics (re-verify).
  LOW / explicitly FLAGGED [UNVERIFIED]: one deep-research pass on UGC creation-tools/legal
  self-reported "absence of current search results" and produced heavily confabulated specifics
  (Verse "compiles to Blueprint"; a "100MB UEFN memory cap"; an "ISteamUGC AllowPayment flag";
  "ISteamUGC::QueryUserUGC"; "CS:GO 2017 Workshop cryptominer"; "Nexus Claim Shield";
  Nexus/CurseForge "Modrinth-index cross-platform support"; many revenue-split numbers). That
  entire pass is DISCARDED; its claims are marked [UNVERIFIED] or excluded, and the load-bearing
  facts were re-anchored to primary sources above (mirrors AAA-RECONCILIATION R-009).
research_quality_warning: >
  READ FIRST. Per the project's recurring confabulation meta-lesson (AAA-RECONCILIATION R-009),
  one of three deep-research passes feeding this report (UGC creation tools + distribution +
  legal) explicitly stated it lacked live search results and fell back to "pre-2023 foundational
  knowledge," then asserted detailed but UNCITED specifics. It is treated as NON-AUTHORITATIVE
  and discarded. Every load-bearing claim in this document is either (a) verified against a
  primary source cited inline, or (b) flagged [UNVERIFIED]. The two passes that WERE well-cited
  — mod.io (cited to docs.mod.io/GitHub) and moddability-architectures (cited to luau.org,
  webassembly.org, extism.org, BepInEx, Thunderstore, Godot modding wiki) — are used as primary.
---

# Modding / UGC Creation Tools / Workshop — Factory Vector Research

> **Vector.** Everything that lets *players extend the games the factory ships*: moddability
> architectures (data-driven config, embedded scripting VMs, asset override, total
> conversions, mod APIs), UGC creation tools (in-game editors, visual scripting,
> "the factory generates the mod SDK"), UGC distribution backends (Steam Workshop vs the
> engine-agnostic mod.io), and UGC moderation + legal duties. The central thesis: **moddability
> is an ARCHITECTURAL property the factory can deliberately design IN** — stable data schemas +
> a versioned mod API + a content pipeline — most of which is *machine-checkable*, sitting on
> top of the factory's existing data-driven-content spine.
>
> **Builds on (does not contradict):** the data-driven-content and Tier-A/B/C artifact taxonomy
> of `game-design-discipline.md`; the architecture-separation rule and headless-contract /
> BC/VP machinery of `engineering-disciplines.md`; the `moderation-pipeline-contract`,
> server-authority invariants, and CSAM/OSA/DSA/COPPA legal duties of
> `security-anticheat-trust-safety.md`; and the **distribution-adapter + `human-gated`
> fidelity tier** of `online-services-platform-distribution.md` (this vector adds a
> *UGC-distribution adapter* as a sibling seam, with **mod.io as the wrap-first reference**).

---

## 1. Executive Summary

Modding decomposes the same way every other AAA discipline the factory has analyzed does:
into a **machine-checkable architectural spine** and a **human/creative shell** — and the
split is unusually favorable here because the spine is *almost entirely the factory's existing
data-driven-content + schema + BC/VP machinery, re-pointed at an external audience*. Six
load-bearing findings:

1. **Moddability is a designed-in ARCHITECTURE, not a feature bolted on later — and the
   factory is unusually well-positioned to design it in.** The three pillars of a moddable
   game — (a) **stable, versioned data schemas** for content; (b) a **curated mod API** exposed
   through an embedded VM or a plugin surface; (c) an **asset override / virtual-filesystem +
   load-order** pipeline — are *the same artifacts the factory already produces internally*
   (`content-data`, `systems-spec`, the engine-neutral asset contract). The retrofit tax that
   makes modding expensive for traditional studios (exposing extension points after the fact —
   the BepInEx/Harmony reflection-hooking reality) is largely *avoided* when content is
   data-driven and schema-first from generation. (Verified: BepInEx/Harmony docs; Thunderstore
   package spec; Godot ModLoader config-schema.)

2. **The wrap-first, engine-agnostic UGC backend is mod.io — and it verifies strongly.**
   mod.io is a real, actively-maintained (C++ SDK releases through **May 2026**, verified on
   GitHub), API-driven UGC middleware that is **clientless, store-agnostic, and explicitly
   cross-engine** (REST API + official C++/Unity/Unreal SDKs; community Godot/GameMaker), with
   **console authorization on Xbox/PlayStation/Nintendo Switch**, platform SSO across Steam/
   Epic/GOG/PSN/Xbox/Switch/Meta/Apple/Google, mod hosting (8 GB/file), dependencies,
   collections, versioning, a **4-layer moderation system with a Content-Approval queue**, and
   a virtual-currency **Marketplace**. This is the **direct UGC analog of the `online-services`
   wrap recommendation** (Nakama/EOS): a neutral seam the factory wires, not a backend it
   builds. **Recommend mod.io as the reference UGC-distribution adapter; Steam Workshop
   (SteamUGC) as a Steam-only secondary adapter.** (Verified: docs.mod.io; github.com/modio;
   partner.steamgames.com.)

3. **The factory's machine-checkable territory in modding is large and clean.** Mod-API
   **semver stability**, **schema-validated UGC**, **mod-load determinism** (topologically-sorted
   dependency resolution + conflict detection), **sandbox capability conformance** (what host
   functions a mod VM may call), and **moderation-pipeline wiring presence** are all
   contract-shaped — they extend the existing BC/VP + `moderation-pipeline-contract` machinery.
   The **human/creative shell** — curation taste, creative-tool UX, what makes a mod *fun* — is
   exactly the playtest-gate boundary the factory already refuses to automate.

4. **Embedded scripting VM choice is a security architecture decision with a clean tier
   ladder.** **WASM (capability-based, fault-isolated linear memory, CFI; via Extism/Wasmtime/
   Wasmer) > Luau (Roblox-hardened sandbox: protected globals, `__gc` removed, host-controlled
   destructors) > plain Lua (sandbox is DIY and historically escapable) > C#/.NET runtime
   patching (BepInEx/Harmony/MonoMod — maximally powerful, NOT sandboxed; trusted-code model).**
   For a *lights-out factory* that wants **machine-verifiable mod isolation**, WASM's
   capability model is the strongest fit; Luau is the strongest *typed-scripting* option; C#
   patching is the *power-user, trust-the-modder* lane. (Verified: webassembly.org/docs/security;
   luau.org/sandbox; extism.org; BepInEx/Harmony/MonoMod.)

5. **"The factory generates the mod SDK" is a real, high-value angle — and UEFN/Roblox are the
   reference platforms.** Because the factory *already* owns the canonical data schemas and the
   engine adapters, it can **emit a game's mod-API contract, content schemas, sample mods, and
   docs as first-class artifacts** — the SDK is a *projection of internal artifacts*, not a
   separate build. UEFN (Verse + Fortnite's engagement-payout creator economy) and Roblox
   Studio are the AAA proofs that "the game ships its own creation tools" is a viable model;
   but a full **in-game level/visual-scripting editor is creative-tool-UX-heavy = mostly human
   shell**, so it is a *later/optional* depth, not v1. (Verified: fortnite.com developer docs;
   dev.epicgames.com Verse/engagement-payout.)

6. **UGC carries HARD legal duties that are mostly operational, with a thin machine-checkable
   edge — and they are already mapped.** Mods are typically **derivative works** of the base
   game (17 U.S.C. §101; *Micro Star v. FormGen*), EULAs typically have the publisher **retain
   game IP + take a broad license** to UGC while the modder may keep original-element copyright,
   the **uploader bears primary infringement liability**, and a UGC host can usually invoke
   **DMCA §512(c) safe harbor** (designated agent + notice-and-takedown + repeat-infringer
   policy) — *unless it curates/monetizes heavily* (the paid-mods trap). The factory **wires**
   the report/takedown/age-gate pipeline (machine-checkable presence/shape, reusing the existing
   `moderation-pipeline-contract`); **legal sign-off, curation, and IP judgment are human gates.**
   (Verified: 17 U.S.C. §101/§512; *Micro Star*; *Galoob*; 2015 Skyrim paid-mods history.)

**Scope verdict (one line):** Modding/UGC is an **OPTIONAL v1 CAPABILITY, not a default and
not deferred** — the factory should *design the moddability architecture in from day one* (it
is nearly free given data-driven content) and ship the **machine-checkable spine** (mod-API
contract, UGC content schema, mod.io-backed UGC-distribution adapter, moderation wiring) as a
declare-and-degrade capability a game opts into; **in-game creation editors and live curation
are human-shell extensions deferred past v1.**

---

## 2. Moddability Architectures (design it IN)

Three orthogonal, composable pillars. A game can adopt any subset; each is independently
machine-checkable to a meaningful degree.

### 2.1 Pillar A — Data-driven content & config moddability (the factory's home turf)

The cheapest, most robust, lowest-risk moddability: **expose game content as stable data, let
mods override/extend the data, no code execution required.** This is *already* the factory's
`content-data` / Tier-A artifact surface (`game-design-discipline.md`): stat tables, drop/loot
tables, curves, recipes, tech trees, frame data, level metrics, dialogue graphs — all
schema-typed and engine-neutral.

- **Mechanism:** JSON/config files validated against a **published JSON Schema**; the engine is
  a generic interpreter of the schema. Mods ship data that conforms. (Pattern verified: Godot
  ModLoader's `extra.godot.config_schema` key drives JSON-Schema validation of mod configs at
  load time; Thunderstore `manifest.json` carries SemVer + dependencies.)
- **Why the factory wins here:** the factory *generates the base content as schema-validated
  data already*. Publishing that schema as the modding contract is **near-zero marginal work**,
  and the **same validator the factory uses internally becomes the UGC ingest gate** — a mod is
  acceptable iff it passes the schema. This is the single highest-ROI moddability lever.
- **Machine-checkable:** schema validity, referential completeness (no dangling IDs), range/band
  invariants (the same `design-intent-contract` assertions), determinism of load (data-only mods
  are inherently deterministic). **Human:** whether the modded content is *good*.

### 2.2 Pillar B — Scripting / embedded VMs (curated mod API + sandbox)

When mods need *behavior*, not just data, the game embeds a scripting VM and exposes a **curated
API surface** (host functions). The security posture is the VM choice. (All rows verified
against primary docs.)

| Approach | Sandbox / isolation model | Security posture | Factory fit | Primary source |
|---|---|---|---|---|
| **WebAssembly (Wasmtime/Wasmer + Extism)** | **Capability-based**: fault-isolated linear memory with bounds-checked access, control-flow integrity, *no* ambient authority — a module can only call host functions explicitly granted; component-model + WIT give typed interface contracts | **Strongest, machine-enforced.** Resource limits (fuel/memory/timeout) configurable. Deterministic execution amenable to testing (Extism `xtp` test runner) | **Best fit for lights-out factory** wanting *verifiable* mod isolation + a typed, versionable mod-API surface (WIT ≈ semver-able interface) | webassembly.org/docs/security; component-model.bytecodealliance.org; extism.org |
| **Luau (Roblox's typed Lua)** | Hardened sandbox: **protected globals table** (scripts can't redefine `require`/`loadstring`), **`__gc` metamethod removed** and replaced with host-only tag-based destructors, restricted stdlib (no fs/net) | **Strong, language-level.** Designed for multi-tenant untrusted code at Roblox scale | Best **typed-scripting** option; gradual typing aids modder DX + load-time error detection; small runtime | luau.org/sandbox; luau.org |
| **Plain Lua (PUC-Lua / LuaJIT)** | Minimal core (<~200 KB), no fs/net in stdlib by default, but **sandbox is DIY**; metatable/global manipulation has historically been used to escape under-built sandboxes | **Moderate; integrator-dependent.** Ubiquitous (WoW, Factorio, etc.) but secure-sandbox work is on the game dev | Viable, but the factory would have to *generate the sandbox*, a verification burden | dev.to Lua-modding patterns; lua.org PiL |
| **C#/.NET runtime patching (BepInEx + Harmony + MonoMod)** | **None — not a sandbox.** Harmony rewrites CIL at runtime (prefix/postfix/transpiler); MonoMod patches assemblies; reflection reaches privates | **Trusted-code model.** Maximal power; arbitrary host access. De-facto standard for Unity titles *retrofitting* modding | Power-user lane for Unity adapter; **explicitly a trust-the-modder, not-isolated** posture — flag in risk register | BepInEx docs; bsmg.wiki Harmony; github.com/monomod |

**Factory framing.** The mod API is a **versioned interface contract** (`mod-api-contract`,
§9). WASM's WIT makes that contract *machine-typed and semver-able*; Luau makes it a typed-Lua
surface; C#-patching makes it *implicit and unstable* (it hooks internals → breaks every patch
— the maintenance reality the well-cited passes confirm). **The factory should prefer
interface-first VMs (WASM, then Luau) precisely because the mod API can then be a checkable,
versioned artifact** rather than an emergent property of which internals happen to be hookable.

### 2.3 Pillar C — Asset replacement / override + virtual filesystem + load order

For art/audio/level swaps and total conversions: the engine resolves resources through a
**priority-ordered search path / virtual filesystem (VFS)**; higher-priority mods override lower.
(Pattern verified: Thunderstore/BepInEx load-order practice; Godot ModLoader; general VFS
override pattern. NOTE: specific named anecdotes from the discarded pass — e.g. a particular
total-conversion's internals — are illustrative only.)

- **Load order & conflict resolution:** mods declare **dependencies**; the loader **topologically
  sorts** them (deps before dependents) and detects file/asset conflicts. (Topo-sort: verified.
  mod.io exposes a first-class **Add Mod Dependencies** REST endpoint.)
- **Total conversions** = the maximal case: replace ~all data + assets + (optionally) scripts
  while reusing the engine. Architecturally this is "Pillars A+B+C turned up to full," gated by
  how much of the game is data-driven vs hard-coded — *again favoring the factory's data-first
  output.*
- **Machine-checkable:** load-order **determinism** (same mod set → same resolved order/state),
  conflict **detection**, override **resolution correctness**, VFS path-precedence invariants.
  **Human:** whether a total conversion is *coherent/fun*.

---

## 3. UGC Creation Tools (incl. "the factory generates the SDK")

Two distinct things: **(a) the toolchain a modder uses to make a mod (an SDK)** and **(b) an
in-game editor that lets *players* create without leaving the game.** They sit at opposite ends
of the automatable↔human spectrum.

### 3.1 The factory generates the mod SDK (high-value, mostly machine-side)

This is the strongest factory-specific angle. Because the factory already owns **the canonical
data schemas, the mod-API interface, and the engine adapters**, "shipping a mod SDK" is largely
**a projection of internal artifacts into a public, versioned package**:

- the **published JSON Schemas** for `content-data` (Pillar A);
- the **mod-API interface contract** (WIT / typed-Lua / documented host functions, Pillar B);
- **sample mods** (the factory can *generate* canonical examples — it generates the base content
  with the same schemas);
- **schema-validators + a mod-load harness** (the same tools the factory uses for internal
  ingest become the modder's local validation);
- **docs** generated from the schemas + interface.

This is **machine-generatable and machine-checkable** (does the SDK round-trip a sample mod?
does the published schema match the shipped game's loader? is the mod-API surface semver-clean
vs the previous release?). It is a natural `mod-sdk` artifact (§9).

### 3.2 In-game level/map editors & visual scripting for players (mostly human shell)

Reference platforms (verified):

- **UEFN (Unreal Editor for Fortnite) + Verse.** A full UE5-based editor producing islands that
  run inside Fortnite. **Verse is a full textual scripting language** (Epic dev docs verified) —
  **NOT** a node/Blueprint-compiled DSL ([UNVERIFIED claim from the discarded pass that "Verse
  compiles to Blueprint" is FALSE]; Verse is its own language with its own reference). Assets are
  drawn from Epic's library (Epic retains asset IP); creators author logic + arrangement.
  **Creator economy is the headline:** Fortnite's **engagement-payout** model has paid third-party
  developers **$900M+** since UEFN launch, and from **December 2025** creators can sell durable/
  consumable items via UEFN/Verse APIs with a **100% V-Bucks-value revenue share through end of
  2026** (≈74% of retail spend), reverting to 50% (≈37%) afterward. (Verified: fortnite.com
  developer + news; dev.epicgames.com engagement-payout. The discarded pass's "100MB memory cap"
  and other UEFN internals are [UNVERIFIED] and excluded.)
- **Roblox Studio + Luau.** The canonical "game-as-platform": a full creation IDE, Luau
  scripting in a hardened sandbox (§2.2), creator monetization via DevEx. (Luau sandbox verified;
  detailed Roblox internals from the discarded pass — R15/poly caps/etc. — are [UNVERIFIED].)
- **Dreams (Media Molecule)** — in-game creation of original assets + logic; demonstrates the
  ceiling and the *console-hardware + no-monetization* limits of the model. (General; specifics
  [UNVERIFIED].)

**Factory posture:** an in-game editor is **creative-tool UX = dominantly human shell** (the
same class as the playtest gate). The factory can *emit an editor spec* (`in-game-editor-spec`,
§9) and wire the data/save/publish plumbing, but **building a polished player-facing editor is
deferred past v1** — it is the highest-effort, least-machine-checkable part of this vector.

### 3.3 Automatable vs human (creation tools)

| Concern | Machine (factory owns) | Human (shell) |
|---|---|---|
| Mod SDK (schemas, mod-API contract, validators, sample mods, docs) | **Generate + verify** (round-trip, semver check) | API ergonomics/taste |
| Content schema design | Emit + validate; band/invariant assertions | What content is fun |
| In-game editor plumbing (save/load, publish, asset import validation) | Wire + schema-validate | **Editor UX, creativity** |
| Visual scripting surface | Define node/host-function contract; check determinism | Whether it's *expressive/pleasant* |
| Curation / discovery | Schema-driven filtering/search; metadata KVP validation | **Editorial taste, featuring** |

---

## 4. UGC Distribution Backends (Steam Workshop vs mod.io — wrap-first)

This is the wrap-vs-build decision, and it is the **direct sibling of the BaaS wrap decision**
in `online-services-platform-distribution.md` (Nakama/EOS reference). **Wrap, don't build a UGC
backend.** The seam is a **UGC-distribution adapter** (§9), mirroring the distribution-adapter.

### 4.1 mod.io — the engine-agnostic wrap-first reference (VERIFIED)

mod.io is the **engine-agnostic** anchor — the same role Nakama plays for backend services.
Verified against `docs.mod.io` + `github.com/modio` (C++ SDK releases through **May 2026**):

| Property | What mod.io provides (verified) | Source |
|---|---|---|
| **API** | Versioned **REST API v1** over HTTPS/JSON; **API-key (read) + OAuth2 (write)** auth; offset/limit pagination; `or_fields` filtering; explicit **rate limits + 429/retry-after**; **test environment** + Live/hidden staging | docs.mod.io/restapi |
| **Engine reach** | Official **C++ SDK (MIT/BSL, CMake, async, custom engines)**, **Unity (2021.3+)**, **Unreal (3 latest UE)** plugins; **community Godot (GDExtension) + GameMaker** | github.com/modio/{modio-sdk,modio-unity,modio-ue}; godotengine asset-library |
| **Platform reach** | **Authorized middleware on Xbox One/Series, PS4/PS5, Switch/Switch 2** (cert support, native SDK, SSO; monetization on console except Switch); **SSO** across Steam/Epic/GOG/PSN/Xbox/Switch/Meta/Apple/Google; live across PC stores + console + VR + mobile | docs.mod.io (Console / Platform SSO) |
| **Features** | Mod hosting (**8 GB/file**), browse/search, **collections**, **dependencies** (first-class REST endpoint), versioning, **KVP metadata**, dedicated-server flows, cross-device subscription sync, in-game UI (Unreal UGC-browser framework; Unity one-click installs), embeddable **Embed Hub** (premium) | docs.mod.io |
| **Moderation** | **4-layer moderation**; **Content-Approval queue** (newly-uploaded mods hidden pending moderator approval — critical for console cert); Moderation Dashboard; in-game + web reporting; per-platform approval toggles | docs.mod.io (Moderation) |
| **Monetization** | End-to-end **virtual-currency Marketplace** (web/in-game/console); **Partner Program** creator vetting; Thunes processor; cross-platform payout | docs.mod.io (Monetization) |
| **Pricing** | **Free for indie hosting within limits**; transaction fees on Marketplace; **console + Embed Hub + white-label are premium tiers** (exact rate card vendor-gated, [UNVERIFIED beyond "free within limits"]) | docs.mod.io (FAQ) |
| **Scale / adoption** | AWS case study: **14M+ users, 130+ games** across PC/console/mobile/VR; "more than 1 game/week went live" (2025) | AWS case study; mod.io blog |

**Why it's the wrap-first pick:** it is **clientless, store-agnostic, engine-agnostic, and
console-authorized** — i.e. it *is* the no-lock-in UGC backend the factory's thesis demands. It
maps 1:1 onto the engine-adapter pattern (capability surface + driver) and lets the *same UGC
content* reach every store/console, which Steam Workshop structurally cannot.

### 4.2 Steam Workshop / SteamUGC — Steam-only secondary adapter (VERIFIED)

- **What it is (verified, partner.steamgames.com):** the **ISteamUGC API** in the Steamworks SDK.
  Accessed via the `SteamUGC()` pointer; e.g. `SteamUGC()->CreateItem(appID,
  k_EWorkshopFileTypeMicrotransaction)`. Steam client + CDN handle download/cache/update; **Steam
  Cloud stores preview images** (quota-configured). Enabled via App Admin "Enable ISteamUGC for
  file transfer."
- **The structural constraint:** **Steam-only.** ISteamUGC requires the Steamworks SDK + active
  Steam client/auth → Workshop content **cannot reach Epic/GOG/console/mobile copies of the same
  game** ("Steam silo"). Excellent *frictionless* one-click UX on Steam; zero portability off it.
- **Factory posture:** support as a **secondary, Steam-target adapter** behind the same
  UGC-distribution capability surface — the same way the distribution-adapter treats Steam as one
  target. Default the *reference* to mod.io for cross-platform reach.

> **[UNVERIFIED — discarded-pass claims about SteamUGC]** the second deep-research pass asserted
> an `ISteamUGC AllowPayment` flag, an `ISteamUGC::QueryUserUGC()` method, a 2017 CS:GO Workshop
> cryptominer, and specific 1 GB/2 GB file caps. **None were confirmed against
> partner.steamgames.com in this pass.** The primary doc confirms `CreateItem` +
> `k_EWorkshopFileTypeMicrotransaction` and Steam-Cloud-for-previews only. Treat the others as
> unverified.

### 4.3 Nexus Mods / CurseForge (third-party, manual-install heritage)

- **Nexus Mods** and **CurseForge** are large third-party mod hosts (Nexus for Bethesda/PC
  modding incl. Vortex manager; CurseForge for Minecraft/modpacks). Both expose APIs. **However,
  the discarded pass's detailed claims about their internals** (Nexus "Claim Shield," "Cloud"
  mirror percentages, "Modrinth-index cross-platform support," CurseForge daily-review counts,
  revenue-split numbers) **are [UNVERIFIED]** and were not primary-confirmed this pass. What is
  safe to assert: they are **established external mod hosts with APIs**, oriented toward
  PC/manual-install + community workflows rather than in-game console-grade UGC pipelines.
- **Factory posture:** **not primary integration targets for v1.** mod.io covers the
  engine-agnostic + console-grade case; Steam Workshop covers the Steam-native case. Nexus/
  CurseForge are *possible future adapters* but add little the mod.io+Workshop pair doesn't.

---

## 5. UGC Moderation & Legal (mostly operational; wire the pipeline, gate the judgment)

This section ties directly to `security-anticheat-trust-safety.md §7` — the
`moderation-pipeline-contract` and the hard legal duties already mapped there apply verbatim to
mods/UGC.

### 5.1 Moderation (reuse the existing pipeline)

- **The work** (verified pattern, mod.io Moderation + security vector): automated classifiers +
  hash-matching (PhotoDNA) for high-volume obvious violations; **human review** for nuance;
  **report → sanction → appeal** state machine; **Content-Approval queues** (mod.io's hidden-by-
  default-pending-approval, mandatory for console cert). Voice/text mod for any UGC chat wraps
  ToxMod (per security vector).
- **Machine-checkable (wiring presence/shape):** the moderation pipeline *exists and is wired* —
  classifier/PhotoDNA hooks, CSAM→NCMEC report path, report/sanction/appeal state machine,
  age-gate, DSA transparency logging. This is the existing `moderation-pipeline-contract`,
  re-pointed at UGC.
- **Human (NOT factory-autonomous):** the moderation *judgments*, policy authorship, classifier
  tuning, reviewer staffing, and **legal sign-off**. Human gates, by construction.

### 5.2 Hard legal duties (cited; mostly operational)

Same duties as the security vector — they attach to UGC the moment players can publish:

| Duty | Requirement | Citation |
|---|---|---|
| **CSAM reporting** | Report apparent CSAM to NCMEC CyberTipline on **actual knowledge**; **no duty to monitor/search** | 18 U.S.C. §2258A |
| **UK Online Safety Act** | Risk assessments + systems to protect users (esp. children); Ofcom-enforced | UK OSA 2023 |
| **EU DSA** | Notice-and-action, transparency, illegal-content removal | EU DSA |
| **COPPA** | Parental consent / data-minimization for under-13 | FTC COPPA |

### 5.3 IP / copyright / EULA / liability (verified legal frame)

- **Mods are typically derivative works.** A mod that copies/modifies the game's protected
  expression (assets, levels, scripts) is a **derivative work** (17 U.S.C. §101) and cannot
  lawfully be distributed without the copyright owner's authorization. *Micro Star v. FormGen*
  (9th Cir. 1998) held user-made map files were infringing derivative works; *Lewis Galoob v.
  Nintendo* (9th Cir. 1992) held *transient, unfixed* on-the-fly modification was **not** a
  derivative work (the cheat/mod-runtime distinction). **[Open/jurisdiction-dependent]:** a mod
  that ships **no game assets** and interacts only via API/scripts/config may *not* be derivative
  — not comprehensively litigated; EU and other regimes differ.
- **EULA ownership pattern (typical, varies by publisher):** publisher **retains the game IP**;
  the modder may **retain copyright in original elements** they author, but grants the publisher/
  platform a **broad, perpetual, royalty-free license** (sometimes assignment / work-for-hire in
  *curated* programs). Enforceability of broad assignment/waiver clauses varies by jurisdiction
  (consumer protection, moral rights).
- **Liability:** the **uploader/modder is the primary infringer.** The **hosting platform**
  (Steam Workshop, mod.io, Nexus, the studio's own host) can usually invoke **DMCA §512(c) safe
  harbor** — *if* it has a **designated agent**, a **repeat-infringer termination policy**, and
  does **expeditious notice-and-takedown**, and does **not** have red-flag knowledge or a direct
  financial benefit it has the right+ability to control. **Heavy curation/monetization erodes
  safe harbor** and pushes the host toward direct-publisher liability.
- **Paid-mods cautionary history (verified):** Valve enabled **paid Skyrim mods on ~Apr 23,
  2015** with a **25% modder / ~40% Bethesda / ~30-35% Valve** split; backlash over the low
  share, stolen assets, and no copyright verification forced a **full reversal in ~4 days
  (~Apr 27-28, 2015) with refunds.** Successor models (**Bethesda Creation Club / "Verified
  Creations"**) are **curated, contracted, copyright-vetted paid content** — closer to mini-DLC
  than open UGC; exact contract/rev-share terms are **private/[UNVERIFIED]**. **Lesson for the
  factory:** *paid UGC requires copyright verification + curation up front* — which (a) is human
  work and (b) **erodes safe harbor** — so paid-mods monetization is **explicitly a later/human-
  gated capability**, not a v1 lights-out feature.

### 5.4 Machine vs human (moderation & legal)

| Concern | Machine (factory) | Human/legal (gate) |
|---|---|---|
| Moderation pipeline wiring | `moderation-pipeline-contract` presence/shape | **Moderation judgments, policy** |
| Schema-validated UGC ingest (reject malformed/unsafe) | **Validator gate** | Edge-case adjudication |
| CSAM→NCMEC / report / appeal wiring | Presence + state-machine shape | Actual-knowledge handling |
| DMCA takedown plumbing | Designated-agent config + takedown workflow presence | **Infringement determinations** |
| IP/copyrightability of a given mod | (record provenance, flag) | **Legal sign-off** |
| Paid-UGC copyright verification | Provenance/record hooks | **Vetting decision (human)** |

---

## 6. Moddability-as-Architecture: Machine-Checkable vs Human (the core deliverable)

The crux. Moddability is something the factory **designs in and verifies**, with a clean split.

| Property | Class | Factory mechanism | Gate |
|---|---|---|---|
| **Mod-API stability (semver)** | **Machine** | Diff current vs prior mod-API surface (WIT/interface/host-functions); flag breaking changes; require major-version bump | CI gate |
| **Schema-validated UGC** | **Machine** | JSON-Schema validation of mod data at ingest (the same validator used for internal `content-data`); referential completeness | CI gate |
| **Mod-load determinism** | **Machine** | Same mod set → same topologically-sorted load order → same resolved state; conflict detection | CI gate (extends replay-regression) |
| **Sandbox capability conformance** | **Machine** | Assert a mod VM can only call granted host functions (WASM capability set / Luau protected globals); fuzz for escape | CI gate |
| **Asset-override resolution correctness** | **Machine** | VFS path-precedence invariants; deterministic override resolution | CI gate |
| **Mod SDK round-trip** | **Machine** | Published schemas/API match shipped loader; sample mod loads | CI gate |
| **Moderation-pipeline wiring** | **Machine (shape)** | `moderation-pipeline-contract` presence/structure | CI gate |
| **Dependency/conflict declaration** | **Machine** | Validate manifest deps resolvable; cycle detection | CI gate |
| **Creative-tool UX (in-game editor)** | **Human** | Editor spec emitted; UX is human-built/judged | Human gate |
| **Curation / discovery / featuring** | **Human** | Schema-driven filtering wired; taste is human | Human gate |
| **Is a mod / total conversion *good*** | **Human** | Playtest-class judgment | Human gate |
| **IP / legal sign-off; paid-UGC vetting** | **Human/legal** | Provenance recorded; decision human | Mandatory human/legal gate |

**This is the same verifiable-spine / subjective-shell split the whole factory is built on** —
modding just makes the *audience* external. The spine (API stability, schema validity, load
determinism, sandbox conformance, moderation wiring) is **directly an extension of BC/VP + the
data-driven-content schemas + the `moderation-pipeline-contract`** the factory already has.

---

## 7. Genre Variation

| Genre lane | Modding weight & natural form | What the factory owns | What it wraps/defers |
|---|---|---|---|
| **Det-sim pilot (roguelike / automation / det-RTS / sim)** | **High & ideal.** Content is *already* data (item pools, recipes, tech trees, room templates); data-mods are deterministic and schema-checkable; the strongest fit | Schema-validated data-mods; mod-load determinism; mod-API contract | mod.io distribution; curation |
| **Sandbox / survival / creative** | **Highest — modding/UGC is the genre.** Scripting + total conversions + in-game building | Mod-API + sandbox conformance; asset-override pipeline | **In-game editor UX (human); live moderation** |
| **FPS / action / competitive MP** | **Constrained.** Client mods collide with anti-cheat (security vector); server-authoritative validation must hold | Server-authority invariants vs modded clients; data-mod limits | Client-AC wrap; restrict executable mods |
| **RPG / open-world** | **High (Bethesda-class).** Big asset + data + script mods; Nexus heritage | Content schemas; asset-override + load-order | mod.io/Workshop; large-binary handling (DAM) |
| **Narrative / linear** | **Low.** Little surface; maybe cosmetic/data tweaks | Optional data-mod schema | Mostly N/A |
| **Platform/UGC-first (Roblox/UEFN-style)** | **Maximal.** The game *is* a creation platform | Mod-SDK projection; data/API contracts | **Full in-game editor + creator economy = deferred** |

**Pilot implication:** the det-sim pilot is (again) the cleanest modding target — its content is
*already* the factory's schema-validated data, so **data-driven moddability is nearly free and
fully machine-checkable**, with no in-game-editor or live-moderation burden in v1.

---

## 8. AAA Bar

- **Data-driven moddability** is table-stakes-cheap for the factory and a real lifespan/community
  multiplier (the verified mod.io adoption corpus); the AAA-grade contribution is **schema-first
  content + a versioned mod-API contract + a console-grade UGC backend (mod.io)**.
- **Console-grade UGC** implies a **moderation/Content-Approval pipeline** (mod.io provides the
  wiring; console cert *requires* curated/approved UGC) — the factory wires it; **judgment +
  legal sign-off are human.**
- **An in-game creation editor at UEFN/Roblox polish is a multi-year product in itself** — beyond
  v1 autonomous reach; the factory emits the *spec* and wires plumbing, not the polished tool.
- **Paid UGC** at AAA implies **copyright verification + curation** (the 2015 lesson) — human work
  that erodes DMCA safe harbor; **not a v1 lights-out feature.**

---

## 9. Factory Artifacts / Contracts This Vector Implies

Additive to the Layer-2 taxonomy (`AAA-RECONCILIATION §6`); all ride declare-and-degrade.

1. **`mod-api-contract`** *(new, the spine)* — the game's **versioned mod-API surface**: exposed
   host functions / WIT interface / typed-Lua API, with **semver discipline** (breaking change ⇒
   major bump). Machine-checkable: diff vs prior release; sandbox capability set; determinism of
   exposed calls. The interface-first VM choice (WASM/Luau) makes this a *typed, checkable*
   artifact.
2. **`ugc-content-schema`** *(new; extends `content-data`)* — the **published JSON Schemas** that
   define moddable data (the same schemas the factory uses to generate base content). The UGC
   ingest gate *is* this validator. Machine-checkable: schema validity, referential completeness,
   band/invariant assertions.
3. **`ugc-distribution-adapter`** *(new; sibling of the distribution-adapter)* — a capability-
   negotiated seam over UGC backends: **mod.io (reference, engine-agnostic, console-grade)**;
   **Steam Workshop / SteamUGC (Steam-only secondary)**; (Nexus/CurseForge future). Capabilities:
   host, browse/search, **dependencies**, versioning, subscription sync, **moderation/Content-
   Approval**, monetization (opt-in). Conformance: round-trip publish→browse→subscribe→install
   against a sandbox/test environment (mod.io provides one).
4. **`mod-load-spec`** *(new)* — load-order + dependency-resolution + conflict-detection + VFS
   override-precedence contract. Machine-checkable: deterministic topo-sorted load; cycle
   detection; conflict resolution correctness (extends replay-regression).
5. **`mod-sdk`** *(new; a projection)* — the generated modder SDK: published schemas + mod-API
   contract + sample mods + local validator + docs. Machine-checkable: SDK round-trips a sample
   mod; published artifacts match the shipped loader.
6. **`in-game-editor-spec`** *(new; mostly human shell)* — declarative spec for an in-game
   level/visual-scripting editor (save/load/publish plumbing, asset-import validation, node/host-
   function surface). Factory wires plumbing + emits spec; **editor UX is human-built, deferred
   past v1.**
7. **`moderation-pipeline-contract`** *(REUSED from security vector)* — UGC report/sanction/appeal
   + CSAM→NCMEC + PhotoDNA hooks + age-gate + DSA logging; presence/shape machine-checkable,
   judgment human.

**Convergence-model tie-in:** these populate **`asset-completeness` (#4)** (schema-valid UGC +
provenance), extend **`sim/spec` (#1)** and **`tests/replay` (#2)** (mod-load determinism, sandbox
conformance), and the moderation/legal items land on the **`provenance/legal` (#8)** human/legal
gate — exactly the existing 9-dimension model (`AAA-RECONCILIATION §7`).

---

## 10. Scope Recommendation

**Modding / UGC = OPTIONAL v1 CAPABILITY (design the architecture in from day one; ship the
machine-checkable spine as opt-in), with the human-shell parts DEFERRED.** Not default-on; not
fully deferred.

### In Scope (v1) — the machine-checkable spine, as an opt-in capability
- **Design moddability IN from day one** (near-free given data-driven content): the factory's
  generated content is schema-first, so **publishing `ugc-content-schema` is marginal work** and
  the internal validator becomes the UGC ingest gate.
- **`mod-api-contract`** with **semver discipline**, preferring **interface-first VMs (WASM via
  Extism/Wasmtime, then Luau)** so the mod API is a *typed, checkable, versioned* artifact;
  C#/BepInEx-patching supported only as an explicit *trusted-code, not-isolated* Unity lane.
- **`ugc-distribution-adapter`** with **mod.io as the engine-agnostic, console-grade reference**
  (wrap-first, mirrors the Nakama/EOS decision) + **SteamUGC as a Steam-only secondary**.
- **`mod-load-spec`** (deterministic topo-sorted load + conflict detection + VFS override) and
  **`mod-sdk`** (projection of internal schemas/API/samples/docs).
- **Reuse `moderation-pipeline-contract`** for UGC report/takedown/age-gate wiring (presence/shape
  checked; judgment human).
- **Det-sim pilot**: data-driven moddability only (no scripting/editor) — fully machine-checkable,
  near-zero added scope.

### Optional / opt-in (v1 capability gate, not default)
- Embedded scripting mods (WASM/Luau sandbox) for genres that want behavior mods.
- Asset-override / total-conversion pipeline for RPG/sandbox genres (ties to DAM large-binary
  handling, `production-pipeline.md`).

### Out of Scope / Deferred (v1) — the human shell
- **Polished in-game creation editor** (UEFN/Roblox-class): emit `in-game-editor-spec` + wire
  plumbing only; the tool itself is a multi-year human-shell product.
- **Live curation / discovery editorial** (taste = human).
- **Paid UGC / Marketplace monetization** (copyright verification + curation = human work that
  erodes DMCA safe harbor — the 2015 lesson). Wire mod.io Marketplace as an *opt-in human-gated
  capability*, not a lights-out feature.
- **Nexus/CurseForge adapters** (no v1 need beyond mod.io + Workshop).
- **C#/BepInEx-patching as the default mod model** (unsandboxed; unstable mod surface) — supported
  but flagged, never the recommended path for a verifiable mod API.

---

## 11. Open Questions & Risks

| ID | Risk / Question | Sev | Note |
|---|---|---|---|
| MOD-R1 | **Confabulation in the UGC-creation/legal pass (HIGH, demonstrated).** One deep-research pass self-reported no live search and invented specifics (Verse→Blueprint, UEFN 100MB cap, ISteamUGC AllowPayment/QueryUserUGC, CS:GO cryptominer, Nexus Claim Shield, Modrinth cross-platform). | HIGH | Pass DISCARDED; load-bearing facts re-anchored to primary sources (fortnite.com, dev.epicgames.com, partner.steamgames.com, 17 U.S.C., case law). Mirrors R-009. |
| MOD-R2 | **mod.io pricing/console tiers are vendor-gated.** Only "free within limits" + "console/Embed Hub/white-label = premium" verified; exact rate card not public. | MED | Re-verify at integration; do not hard-code. |
| MOD-R3 | **Client-side mods vs anti-cheat (HIGH for competitive MP).** Executable mods collide with the server-authority/anti-cheat posture (security vector). | HIGH | Restrict to server-validated data-mods for competitive MP; sandboxed (WASM) mods for trusted contexts; defer client-script mods on competitive lanes. |
| MOD-R4 | **Mod-API semver vs internal churn (MED).** A stable public mod API constrains internal refactors; interface-first VMs (WASM/WIT) mitigate; C#-patching makes it impossible (hooks internals). | MED | Prefer WASM/Luau; treat the mod-API surface as a frozen contract with scheduled major bumps. |
| MOD-R5 | **Paid-UGC erodes DMCA safe harbor (MED/legal).** Curation+monetization push the host toward direct-publisher liability + require copyright vetting (human). | MED | Keep paid UGC human-gated/opt-in; record provenance; legal sign-off mandatory. |
| MOD-R6 | **Mod-IP derivative-work line is jurisdiction-dependent (MED).** API/script/config-only mods may not be derivative; EU/moral-rights regimes differ; broad-license EULA enforceability varies. | MED | Legal sign-off owns this; factory records, does not adjudicate. |
| MOD-R7 | **In-game editor is a product, not a feature (MED).** UEFN/Roblox-class editors are multi-year. | MED | Emit spec + plumbing only; defer the tool. |
| MOD-R8 | **Fast-moving creator-economy specifics (LOW/fast).** Fortnite Dec-2025 item sales / 100%-rev-share-through-2026 are time-boxed and will change. | LOW | Re-verify per use; cited as of 2026-06. |
| MOD-R9 | **Nexus/CurseForge internals are [UNVERIFIED] (LOW).** Detailed claims from the discarded pass not primary-confirmed. | LOW | Treat only as "established external hosts with APIs"; verify before any adapter. |

---

## 12. Sources

See YAML `sources` for the full list. Primary anchors by claim class (all verified this pass):

- **mod.io (engine-agnostic UGC backend):** docs.mod.io (REST API, console/SSO, moderation,
  monetization); github.com/modio (C++/Unity/Unreal SDKs, **releases through May 2026**); AWS
  case study (scale).
- **Steam Workshop / SteamUGC:** partner.steamgames.com/doc/features/workshop/implementation
  (`SteamUGC()->CreateItem`, `k_EWorkshopFileTypeMicrotransaction`, Steam-Cloud previews).
- **UEFN / Verse / creator economy:** fortnite.com/developer + /news; dev.epicgames.com (Verse
  reference; engagement-payout).
- **Embedded scripting / sandboxing:** luau.org/sandbox; webassembly.org/docs/security;
  component-model.bytecodealliance.org; extism.org (+ /docs/concepts/testing); wasmer.io;
  BepInEx docs; bsmg.wiki Harmony; github.com/monomod.
- **Mod loaders / schema / load-order:** wiki.thunderstore.io (manifest/SemVer/deps);
  wiki.godotmodding.com (config_schema); en.wikipedia.org Topological_sorting.
- **Legal / IP / DMCA:** 17 U.S.C. §101 (derivative work) + §512 (safe harbor); *Micro Star v.
  FormGen* (9th Cir. 1998); *Lewis Galoob v. Nintendo* (9th Cir. 1992); gamedeveloper.com +
  GWU IP&EL (2015 Skyrim paid-mods 25%/4-day facts).

**Cross-references (in-repo, built upon, not contradicted):**
`docs/research/aaa/engineering-disciplines.md` (data-oriented/ECS, architecture-separation rule,
headless-contract tiers, BC/VP), `docs/research/aaa/game-design-discipline.md` (data-driven
content, Tier-A/B/C taxonomy, schema-validated content), `docs/research/aaa/security-anticheat-
trust-safety.md` (`moderation-pipeline-contract`, CSAM/OSA/DSA/COPPA, server-authority),
`docs/research/aaa/online-services-platform-distribution.md` (distribution-adapter, `human-gated`
tier, wrap-first BaaS), `docs/research/aaa/production-pipeline.md` (DAM/large-binary),
`docs/research/aaa/AAA-RECONCILIATION.md` (BC/VP mapping, convergence model, scope, R-009).

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep passes (`reasoning_effort: high`, `strip_thinking`): (1) **mod.io** as engine-agnostic UGC backend — API/SDKs/engines/console/features/pricing/comparison-to-Workshop [WELL-CITED to docs.mod.io + GitHub, USED]; (2) **moddability architectures** — Lua/Luau/WASM/C# scripting + sandboxing, data-driven schemas, asset override/VFS, mod-API semver, total conversions, load-order/topo-sort [WELL-CITED to luau.org/webassembly.org/extism/BepInEx/Thunderstore/Godot-modding, USED]; (3) **UGC creation tools + distribution + legal** [SELF-REPORTED no-live-search, HEAVILY CONFABULATED — DISCARDED, debunked via primary sources] |
| Perplexity perplexity_reason | 1 | Synthesis over established legal facts: 2015 Steam paid-mods, Creation Club/Verified Creations, mod-IP derivative-works (Micro Star/Galoob), DMCA §512 safe harbor — verifiable-vs-disputed framing |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (vendor/primary docs are the authority here) |
| Tavily tavily_extract | 2 | **Primary-source verification:** docs.mod.io (live) + github.com/modio/modio-sdk (releases through May 2026) → confirm mod.io real/maintained/engine-agnostic; partner.steamgames.com Workshop Implementation (ISteamUGC/CreateItem/Steam-Cloud — VERIFIED; debunked discarded-pass SteamUGC specifics); UEFN Verse ref + Nexus API (failed fetch — flagged) |
| WebSearch | 1 | UEFN/Verse + Fortnite creator economy → primary-confirmed engagement-payout ($900M+), Dec-2025 item sales, 100% rev-share-through-2026 (fortnite.com/news + dev.epicgames.com) |
| WebFetch | 0 | — |
| Repo files (Read) | 6 | Grounded against engineering-disciplines, game-design-discipline, security-anticheat-trust-safety, online-services-platform-distribution, AAA-RECONCILIATION (+ production-pipeline via reconciliation) — to reuse BC/VP, the moderation-pipeline-contract, the distribution-adapter `human-gated` tier, and the data-driven-content spine |
| Training data | ~2 areas | Moddability-pillar taxonomy + the machine-checkable/human split framing (the report's spine) — every load-bearing vendor/legal/mechanism claim re-anchored to a cited primary source or marked [UNVERIFIED] |

**Total MCP tool calls:** 6 (3 `perplexity_research` + 1 `perplexity_reason` + 2 `tavily_extract`) + 1 WebSearch = 7 grounded calls
**Training data reliance:** low — the pillar taxonomy and verifiable-spine/subjective-shell
framing are model-structured, but all load-bearing claims are primary-cited (docs.mod.io,
github.com/modio, partner.steamgames.com, fortnite.com, dev.epicgames.com, luau.org,
webassembly.org, extism.org, 17 U.S.C. §101/§512, Micro Star, Galoob). **One full deep-research
pass self-reported missing live search and was confabulated; it is explicitly DISCARDED and its
invented specifics (Verse→Blueprint, UEFN 100MB cap, ISteamUGC AllowPayment/QueryUserUGC, CS:GO
cryptominer, Nexus Claim Shield, Modrinth cross-platform) are flagged [UNVERIFIED]** rather than
carried as fact — mirroring AAA-RECONCILIATION R-009.
