---
document_type: research
vector: online-services-platform-distribution
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory — engine-agnostic lights-out Dark Factory for AAA game development that must SHIP games"
inputs:
  - docs/research/aaa/engineering-disciplines.md
  - docs/research/aaa/production-pipeline.md
  - docs/research/aaa/qa-testing-liveops.md
  - docs/research/aaa/AAA-RECONCILIATION.md
  - docs/design/engine-adapter-protocol.md
  - .factory/specs/product-brief.md
sources:
  # Backend game services / BaaS (primary docs, citation-grounded)
  - "Microsoft PlayFab overview: https://developer.microsoft.com/en-us/games/products/playfab/"
  - "PlayFab pricing (tiered; $0 < 100K players): https://developer.microsoft.com/en-us/games/products/playfab/pricing/"
  - "PlayFab Economy V2: https://learn.microsoft.com/en-us/gaming/playfab/economy-monetization/economy-v2/faq"
  - "PlayFab Title Data (remote config): https://learn.microsoft.com/en-us/gaming/playfab/live-service-management/game-configuration/titledata/quickstart"
  - "PlayFab Experiments (A/B): https://learn.microsoft.com/en-us/gaming/playfab/live-service-management/game-configuration/experiments/"
  - "AccelByte AGS Identity/Access: https://docs.accelbyte.io/gaming-services/modules/foundations/identity-access/"
  - "AccelByte Store/Catalog: https://docs.accelbyte.io/gaming-services/modules/online/store-catalog/"
  - "AccelByte Multiplayer Servers (AMS): https://accelbyte.io/multiplayer-servers"
  - "Nakama (Heroic Labs) docs root: https://heroiclabs.com/docs/"
  - "Nakama authentication: https://heroiclabs.com/docs/nakama/concepts/authentication/"
  - "Nakama matchmaking: https://heroiclabs.com/docs/nakama/tutorials/unity/pirate-panic/matchmaking/"
  - "Nakama parties: https://heroiclabs.com/docs/nakama/concepts/parties/"
  - "Hiro inventory (Heroic Labs): https://heroiclabs.com/docs/hiro/concepts/inventory/"
  - "Satori remote-config / feature flags: https://heroiclabs.com/docs/satori/concepts/remote-configuration/"
  - "Epic Online Services (free, cross-platform): https://dev.epicgames.com/docs/epic-online-services"
  - "EOS Player Data Storage: https://dev.epicgames.com/docs/epic-online-services/player-and-game-data/player-data-storage-interface/player-data-storage-overview"
  - "EOS Friends interface: https://dev.epicgames.com/docs/epic-account-services/eos-friends-interface"
  - "Amazon GameLift Servers dev guide: https://docs.aws.amazon.com/gameliftservers/latest/developerguide/"
  - "GameLift FlexMatch reference: https://docs.aws.amazon.com/gameliftservers/latest/flexmatchguide/reference-awssdk-flex.html"
  - "Firebase for games setup: https://firebase.google.com/docs/games/setup"
  - "Firebase Remote Config: https://firebase.google.com/products/remote-config"
  - "Firebase A/B Testing: https://firebase.google.com/docs/ab-testing/abtest-config"
  - "Firebase Crashlytics NDK: https://firebase.google.com/docs/crashlytics/android/get-started-ndk"
  - "Supabase realtime multiplayer GA: https://supabase.com/blog/supabase-realtime-multiplayer-general-availability"
  - "Unity Gaming Services getting started: https://docs.unity.com/en-us/services/getting-started"
  - "Unity Remote Config: https://docs.unity.com/en-us/remote-config"
  - "Unity Cloud Diagnostics: https://docs.unity.com/en-us/cloud/developer-data/diagnostics"
  # Distribution / store-submission CLIs (primary docs, WebFetch-verified)
  - "Steamworks SteamPipe / steamcmd uploading (CLI verified): https://partner.steamgames.com/doc/sdk/uploading"
  - "itch.io butler CLI (automatable, MIT, github.com/itchio/butler): https://itch.io/docs/butler/"
  - "fastlane iOS App Store deployment (build_app/upload_to_app_store/sync_code_signing/capture_screenshots verified): https://docs.fastlane.tools/getting-started/ios/appstore-deployment/"
  - "Xbox GDK Submission Validator (automates pre-cert checks; cert still human): https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/packaging/subval/submissionvalidator"
  # LiveOps backend / observability (primary docs, citation-grounded)
  - "LaunchDarkly feature flags + REST API + ldcli dev-server: https://launchdarkly.com/docs/guides/api/rest-api , https://launchdarkly.com/docs/guides/flags/ldcli-dev-server"
  - "Sentry native crash reporting (minidumps, PDB, sentry-cli symbol upload): https://docs.sentry.io/platforms/native/guides/minidumps/ , https://docs.sentry.io/platforms/unreal/configuration/debug-symbols/"
  - "Backtrace (Sauce Labs) game crash/error reporting: https://backtrace.io , https://docs.saucelabs.com/error-reporting/platform-integrations/minidump/"
confidence: "HIGH on the existence/role/hosting-model of named BaaS platforms and the three core distribution CLIs (steamcmd, butler, fastlane), all primary-source verified; HIGH on EOS-is-free and GDK Submission Validator; MEDIUM on exact pricing tiers and per-feature parity (move fast / partly secondary); console-submission internals are NDA-gated and flagged [UNVERIFIED]."
research_quality_warning: >
  One deep-research pass on distribution/console tooling was HEAVILY CONFABULATED and is
  explicitly DISCARDED here. It invented non-existent tool names and false specifics —
  e.g. "Steamworks Automation Framework (2025)", "machine-learning-driven SteamPipe
  optimization", "fastlane acquired by Google 2024", a "fastlane gms command", a
  "supply datasafety command", "Sony GN Tool (Generate)", a "Nintendo NSC Java GUI /
  .nsx format / SikuliX click-scripting", "Epic BuildPatchTool -buildsubmit store mode",
  and a "Coalition for Game Data Portability". NONE of these were confirmable against
  primary docs; several are demonstrably wrong (fastlane is Fastlane/owned within the
  fastlane open-source project; real fastlane actions are build_app / upload_to_app_store
  / sync_code_signing / capture_screenshots / upload_to_testflight, NOT gms/datasafety).
  Every load-bearing distribution claim below was RE-ANCHORED to a WebFetch/Tavily-extract
  of the actual vendor doc. Console-internal tool names are marked [UNVERIFIED] rather than
  guessed. This mirrors the confabulation warnings already logged in engineering-disciplines.md
  and AAA-RECONCILIATION.md R-009.
---

# Online Services, Platform Integration, Distribution & LiveOps Backend — Factory Vector Research

> **Vector.** This report covers everything *between a built game binary and live players*:
> backend game services (accounts, matchmaking, leaderboards, cloud saves, entitlements,
> inventory, player data) and the BaaS market; platform SDK integration (Steam, consoles,
> mobile) for achievements/saves/presence/IAP/DLC; build distribution & store-submission
> pipelines and their CLI-automatability; patching/CDN; and the liveops backend (remote
> config, feature flags, A/B, crash/observability). Its central deliverable is a proposed
> **platform/distribution-adapter protocol** that mirrors the existing engine-adapter
> protocol (`docs/design/engine-adapter-protocol.md`) so the factory stays platform-agnostic
> the same way it is engine-agnostic.
>
> **Builds on:** `engineering-disciplines.md` (networking tiers, Nakama, cert checklist),
> `production-pipeline.md` (build/release, P4 large-binary model), `qa-testing-liveops.md`
> (cert pre-flight 55–80% machine-checkable, telemetry, crash reporting), and
> `AAA-RECONCILIATION.md` (the vsdd→game-factory mechanism mapping and the existing
> Out-of-Scope decision that excludes console cert + store submission).

---

## 1. Executive Summary

Shipping a game is not one act; it is **three separable concerns**, and the factory can own
very different fractions of each:

1. **Backend game services** (accounts, saves, matchmaking, leaderboards, entitlements,
   inventory, player data). This is a **wrap-don't-build** layer: a mature, competitive BaaS
   market already solves it. The factory's job is a **normalized integration surface + a
   wired-up SDK**, not a backend.

2. **Platform SDK integration + store distribution** (Steam, consoles, mobile storefronts).
   This **splits cleanly** along a CLI-automatability line that maps almost exactly onto the
   factory's automatable-vs-human boundary: **PC and mobile build→upload is fully scriptable**
   (`steamcmd`, `butler`, `fastlane` — all primary-source verified below); **console
   certification and platform legal/account setup are irreducibly human** and NDA-gated.

3. **LiveOps backend** (remote config, feature flags, A/B, crash/observability, CDN/patching).
   This is **wireable plumbing** the factory generates as artifacts (the same posture
   `qa-testing-liveops.md` already took for telemetry).

**Five load-bearing findings:**

- **Wrap-first BaaS recommendation: a TWO-LANE default.** For the det-sim pilot and the
  engine-agnostic spine, default to **Nakama (Heroic Labs)** — it is open-source, self-hostable,
  genuinely **engine-agnostic** (official Unity, Unreal, **Godot**, and other client SDKs), and
  gives the factory a *backend it can run headless in CI under Docker* (matching the
  determinism/replay discipline). For studios already targeting consoles/storefronts and wanting
  zero-ops, **PlayFab** (most comprehensive managed enterprise backend; $0 tier under 100K
  players) and **Epic Online Services / EOS** (verified **free, cross-platform, engine-agnostic**)
  are the wrap targets. The factory should **not pick one** — it should define a
  **online-services capability surface** and ship **adapters** for at least Nakama (reference)
  + EOS (free cross-platform) + PlayFab (managed AAA), exactly as it ships engine adapters.

- **The distribution layer is a near-perfect mirror of the engine-adapter split.** A
  **platform/distribution-adapter** with capability negotiation (achievements / cloud-saves /
  entitlements / IAP / presence / leaderboards / **store-submission**) and fidelity grading
  (`full`/`partial`/`none` + a new **`human-gated`** fidelity for console cert) is the right
  abstraction. **YES, recommend it** (§7).

- **CLI-automatable distribution is real and verified** (steamcmd `+run_app_build`, butler
  `push`, fastlane `upload_to_app_store`/`upload_to_testflight`) — but **store *page publish*,
  pricing/regional config, and ALL console certification stay human.** (§4)

- **Shipping FORCES store submission partly IN-SCOPE** — but only its *automatable half*. The
  brief currently scopes console cert + store submission entirely OUT. A factory that must
  *ship* cannot leave the automatable depot-upload/store-build half on the floor; it CAN keep
  the human cert-relationship half out. The resolution is the `human-gated` fidelity tier on
  the distribution-adapter (§4, §12).

- **LiveOps backend is all real, all wrappable, none invented.** LaunchDarkly / Firebase
  Remote Config / Unity Remote Config / PlayFab Title Data + Experiments / Satori (feature
  flags) for config+A/B; Sentry / Backtrace(Sauce Labs) / Crashlytics / Unity Cloud
  Diagnostics for crash+observability — each has REST API/CLI/SDK automation and is a wrap
  target, not a build target (§6).

---

## 2. Backend Game Services & BaaS (Wrap-vs-Build)

### 2.1 The capability surface every game backend exposes

Across all platforms researched, backend game services decompose into a stable capability set
— this set IS the normalized surface the online-services adapter must define:

| Capability | What it does |
|---|---|
| **Identity / accounts / auth** | device/email/social/platform login; cross-platform account linking; session tokens |
| **Cloud saves / player data** | persistent, synced, often encrypted per-user game state across devices |
| **Leaderboards** | ranked score collections; client- or server-authoritative |
| **Matchmaking** | ticket/criteria-based grouping (skill/latency/region) |
| **Lobbies / parties / presence** | real-time groups, friend status, rich presence |
| **Entitlements / DLC / commerce** | ownership checks, store catalog, purchases |
| **Inventory / virtual economy** | items, currencies (wallet), bundles, ledger |
| **Friends / social** | relationship graph (one-way or mutual), blocking |
| **Dedicated server hosting/orchestration** | provision/scale/allocate game servers |
| **Analytics / telemetry** | event ingestion, KPIs (ties to qa-testing-liveops.md §7) |

### 2.2 Platform-by-platform (primary-source grounded; hosting model is the key axis)

| Platform | Hosting model | Engine reach | Strongest capabilities | Notable for factory |
|---|---|---|---|---|
| **Nakama (Heroic Labs)** | **Open-source, self-hostable** (Go server; Heroic Cloud managed option) | **Engine-agnostic** — Unity, Unreal, **Godot**, JS/others | auth (device/email/social/custom), matchmaking (server-side tickets: `max_tickets`/`interval_sec`/`max_intervals`), leaderboards (client- or server-auth), storage, **parties** (≤256), friends (directed-graph model), Hiro inventory/wallet, Satori liveops | **The reference adapter.** Self-host = factory runs it **headless in CI under Docker**; engine-agnostic = it doesn't break the no-lock-in spine. Already endorsed in engineering-disciplines.md as the dedicated-server tier. |
| **Epic Online Services (EOS)** | **Managed, FREE** (verified dev.epicgames.com) | **Engine-agnostic, cross-platform** (PC/console/mobile; any engine) | Accounts & Social (friends, presence, crossplay), Multiplayer (Lobbies = P2P w/ voice+host-migration; Sessions = dedicated-server), Player & Game Data (encrypted cloud saves), ecom/entitlements (ownership + entitlement queries), Trust & Safety | **Free + cross-platform** makes it the natural *default managed* adapter. Sessions vs Lobbies distinction matters for the netcode tier. |
| **Microsoft PlayFab** | Managed SaaS (Azure) | All major engines (Unity/Unreal/custom SDKs) | Most **comprehensive**: unified identity/cross-progression, Economy V2 (cross-platform bundle mapping), Multiplayer Servers (scale 100→10M), matchmaking, PlayFab Party (voice/text), **Title Data (remote config) + Experiments (A/B)**, analytics | **$0 tier < 100K players**; Standard/Premium meters above. The "AAA managed" adapter; also doubles as a liveops backend (§6). |
| **AccelByte (AGS)** | Managed + **hybrid/self-host/bare-metal** (AMS) | Cross-platform (Steam/Xbox/PSN linking) | Modular 3-layer (identity+analytics / monetization+progression / multiplayer); Store/Catalog + inventory; matchmaking+lobby; AMS server orchestration; **Extend** custom code | AAA-oriented, modular; closest commercial analog to "pick the modules you need." |
| **Amazon GameLift (Servers / FlexMatch)** | Managed AWS infra | Engine-agnostic server hosting | **Dedicated server hosting/orchestration + FlexMatch matchmaking** ONLY — not a full social/economy backend | Narrow: it is *server infra*, not BaaS. Pair with another backend for social/economy. |
| **Firebase (for games)** | Managed (Google) | Mobile-first; Unity/C++ SDKs | Auth (incl. Play Games), Firestore (leaderboards/data), **Remote Config + A/B Testing**, **Crashlytics** (incl. Android NDK), Analytics | Mobile-leaning; strong *liveops/observability* primitives more than full multiplayer backend. |
| **Supabase (for games)** | Managed/self-hostable (Postgres) | Engine-agnostic via REST/realtime | Auth, Postgres data, **Realtime multiplayer (GA)**, storage | General BaaS adapted to games; viable for data/auth/leaderboards + light realtime; not a turnkey game-economy stack. |
| **Unity Gaming Services (UGS)** | Managed (Unity) | **Unity-centric** | Auth, Cloud Save, Economy, Matchmaker, Lobby, Relay, **Remote Config**, Cloud Diagnostics, Analytics | Strong but **Unity-coupled** → violates the engine-agnostic spine if made the default; acceptable as a Unity-adapter-only option. **Flag:** UGS Multiplay hosting EOL was reported in the deep-research pass — [UNVERIFIED], confirm before relying on Multiplay. |

### 2.3 Wrap-vs-build verdict (backend)

| Layer | Decision | Rationale |
|---|---|---|
| Backend game services (all of §2.1) | **WRAP** | Mature competitive market; building a backend is out of scope and off-thesis |
| The **normalized online-services surface** + capability negotiation | **BUILD** | This is the platform-agnostic seam — the factory's differentiator (§7) |
| Reference self-hostable backend for CI/det-sim pilot | **WRAP Nakama** | Open-source + engine-agnostic + Docker-headless-testable |
| Default managed backend | **WRAP EOS** (free, cross-platform) and/or **PlayFab** (AAA managed) | Free + comprehensive; both engine-agnostic |

---

## 3. Platform SDK Integration Surface

The platform SDKs expose a **smaller, storefront-flavored** capability set that overlaps the
BaaS set but is owned by the *platform holder*, not a BaaS vendor. This is the surface the
**distribution-adapter** must normalize.

| Platform SDK | Achievements | Cloud saves | Presence | IAP / commerce | DLC entitlements | Leaderboards | Automatability of *integration* |
|---|---|---|---|---|---|---|---|
| **Steamworks** | ✅ (ISteamUserStats) | ✅ Steam Cloud (ISteamRemoteStorage) | ✅ Rich Presence (ISteamFriends) | ✅ microtxns / ISteamInventory | ✅ ISteamApps `BIsDlcInstalled` | ✅ ISteamUserStats | SDK calls in-engine; config in Partner portal (web) |
| **PlayStation / PSN** | ✅ Trophies | ✅ Save Data | ✅ | ✅ | ✅ | ✅ | NDA-gated SDK; details [UNVERIFIED] |
| **Xbox / GDK** | ✅ Achievements | ✅ (Connected Storage / Smart Delivery) | ✅ | ✅ | ✅ | ✅ | GDK partly public; Xbox Live service config in Partner Center (web + NDA parts) |
| **Nintendo (NSA/NSDK)** | ✅ | ✅ | partial | ✅ eShop | ✅ | ✅ | NDA-gated; details [UNVERIFIED] |
| **Epic Games Store / EOS** | ✅ (EOS Achievements/Stats) | ✅ Player Data Storage | ✅ | ✅ ecom | ✅ entitlements | ✅ | Free SDK, engine-agnostic, well-documented |
| **Google Play Games Services** | ✅ | ✅ Saved Games | — | (Play Billing) | (Play Billing) | ✅ | SDK + Play Console; partial API automation |
| **Apple Game Center** | ✅ | ✅ (iCloud/GKSavedGame) | partial | (StoreKit) | (StoreKit) | ✅ | SDK + App Store Connect; leaderboards pre-defined, limited runtime creation |

**Key cross-platform reality for the adapter design:** the *same logical achievement* maps to
different APIs (Steam ISteamUserStats vs EOS Achievements vs GKAchievement vs Xbox), and the
*same logical save* maps to Steam Cloud / EOS Player Data / iCloud / Connected Storage. This
**N-API-for-one-concept** problem is exactly the problem the engine-adapter already solves for
test/replay/capture — strong evidence the same pattern applies (§7).

---

## 4. Build Distribution & Store-Submission Pipelines (CLI Automatability)

This is the section where the confabulated deep-research pass was discarded and every claim
re-anchored to the **actual vendor doc** via WebFetch.

### 4.1 PC — Steam (SteamPipe / steamcmd) — VERIFIED automatable

From `partner.steamgames.com/doc/sdk/uploading` (WebFetch-verified):

- **SteamPipe** = Valve's content delivery system; features **binary delta patching**,
  public/private **beta branches**, web-based build management.
- CLI tool = **`steamcmd`** (Windows `steamcmd.exe`, `builder_osx`, `builder_linux`).
- **ContentBuilder** directory holds builder tools + scripts.
- VDF scripts: **`app_build_[AppID].vdf`** (content root, output, depot refs) and
  **`depot_build_[DepotID].vdf`** (file mappings/exclusions).
- **Verified non-interactive command:**
  `steamcmd.exe +login <acct> <pass> +run_app_build ..\scripts\app_build.vdf +quit`
  (the `+quit` flag = non-interactive; CI-scriptable).
- **Human boundary:** the doc does **not** cover automated *store-page publishing*; store page
  updates go through the Steamworks **web** interface. So: **build→depot upload is fully
  CLI-automatable; store-page publish/visibility is human/web.**

### 4.2 PC/indie — itch.io (butler) — VERIFIED automatable

From `itch.io/docs/butler/` (WebFetch-verified): butler is "a small command-line tool" that
uploads builds and manages patches, is **"easily integrated into an automated build/deploy
pipeline,"** is **MIT / open-source** (github.com/itchio/butler), supports **channels**
(e.g. `stable`/`beta`), version numbering, and **delta patching** (rsync-style differential
upload via `butler push`). Auth via scoped API keys. **Fully CI-automatable.**

> NOTE: the confabulated pass invented `--price`/`--pay-what-you-want` butler flags,
> `butler deploy` HTML5 publication, "Butlerfile manifests", and SmartScreen submission —
> [UNVERIFIED], treat as false until confirmed against the per-command butler docs.

### 4.3 Mobile — fastlane — VERIFIED automatable (with corrected action names)

From `docs.fastlane.tools/getting-started/ios/appstore-deployment/` (WebFetch-verified) the
**actual** modern fastlane actions are:

- **`build_app`** (compile; legacy alias `gym`)
- **`upload_to_app_store`** (binary + metadata → App Store Connect; legacy alias `deliver`)
- **`sync_code_signing`** (certs/profiles; legacy alias `match`)
- **`capture_screenshots`** (legacy alias `snapshot`)
- **`upload_to_testflight`** (beta; legacy alias `pilot`)
- `get_push_certificate`, `increment_build_number`

For Google Play the analogous action is **`upload_to_play_store`** (legacy alias `supply`),
which supports staged/track rollouts. **Human boundary:** fastlane *prepares and uploads*;
final **"Submit for Review" / App Review** is the human/web gate (the iOS doc covers upload
workflows, not the review-approval step).

> The confabulated pass's `fastlane gms`, `supply datasafety`, `supply promote` closed-loop
> auto-pause, "fastlane acquired by Google 2024" are all [UNVERIFIED]/false. Real fastlane is
> the community open-source project; verify any Play-specific subcommand against
> docs.fastlane.tools.

### 4.4 Epic Games Store — partially verified

EOS SDK + Epic publishing tools exist; **BuildPatchTool** is a real Epic build/patch utility.
The confabulated "store integration mode / `-buildsubmit` / `-stagesubmission`" specifics are
**[UNVERIFIED]** and should be confirmed against Epic dev docs before any automation is built.
Store-page/pricing changes go through **Partner Center (web)** = human.

### 4.5 Consoles — Xbox / PlayStation / Nintendo — submission is HUMAN + NDA-gated

- **Xbox GDK Submission Validator** (VERIFIED, learn.microsoft.com): a real GDK component that
  **"runs a series of basic quality checks on a title or app package"** and **"automate[s]
  these checks and push[es] them as early into the process as possible"** so partners
  **self-diagnose before submitting for certification**. Packaging uses GDK tooling
  (`makepkg`-class — name [UNVERIFIED] beyond GDK's documented packaging flow). **Final
  certification is a human step** via Partner Center / Xbox cert. → This is precisely a
  **`human-gated`** distribution capability: pre-flight automatable, sign-off human.
- **PlayStation (PSN/Sony) and Nintendo (NSA/NSDK)**: submission toolchains, package formats,
  and cert processes are **NDA-gated**. The confabulated pass invented "Sony GN Tool" and
  "Nintendo NSC Java GUI / .nsx / SikuliX" — **[UNVERIFIED], discard.** What IS reliably known
  (from qa-testing-liveops.md cert research): TRC (Sony) / XR (Xbox) / Lotcheck (Nintendo) are
  all-pass human-reviewed cert gates, and ~30-day Nintendo submission windows / physical
  devkit requirements apply. **Console cert = human, by platform-holder design.**

### 4.6 Distribution automatability summary

| Step | Steam | itch.io | iOS | Android | Xbox | PS / Switch |
|---|---|---|---|---|---|---|
| Build → package | ✅ CLI | ✅ CLI | ✅ fastlane | ✅ fastlane | ◑ GDK pkg (NDA parts) | ◑ NDA |
| Upload artifact | ✅ steamcmd | ✅ butler push | ✅ upload_to_app_store | ✅ upload_to_play_store | ◑ Partner Center | ◑ NDA portal |
| Pre-cert validation | (Steam review) | (none) | (App Review) | (Play scans) | ✅ Submission Validator (CLI) | ◑ NDA |
| **Store publish / pricing** | ❌ human/web | ◑ web | ❌ human/web | ◑ web | ❌ human | ❌ human |
| **Certification sign-off** | (light review) | (none) | **human App Review** | **human review** | **human cert** | **human cert** |

---

## 5. Patching, CDN & Content Delivery

- **Delta/binary patching is the norm and is platform-owned**, not factory-built: SteamPipe
  does binary delta patching (verified); butler does rsync-style differential patches
  (verified); console/mobile storefronts handle their own CDN + patch delivery.
- **CDN distribution** for self-published / web / direct-download builds is a **wrap target**
  (any CDN: CloudFront, Cloudflare, Fastly, etc.) — the factory does not build a CDN.
- **Self-hosted backend content** (Nakama assets, remote config payloads) ride normal cloud
  CDN/object storage.
- **Factory posture:** patching/CDN is **delegated to the platform/CDN**; the factory's only
  artifact here is a **release manifest** declaring the build version, channel/branch, and the
  delta-patch baseline — consumed by the distribution-adapter. **Do not build a patcher.**

---

## 6. LiveOps Backend & Observability

All real, all wrappable, all primary-source grounded (no confabulation in this pass).

### 6.1 Remote config / feature flags / A-B

| Tool | Role | Automation | Hosting |
|---|---|---|---|
| **LaunchDarkly** | enterprise feature flags + experimentation | **REST API** (full flag/env CRUD) + **`ldcli` dev-server** CLI | managed |
| **Firebase Remote Config + A/B Testing** | config + experiments (Analytics-segmented) | REST API + SDK + CLI | managed (Google) |
| **Unity Remote Config** | game config + Game Overrides | **CLI** ("scalable and automatable") + REST | managed (UGS) — Unity-coupled |
| **PlayFab Title Data + Experiments** | KV config (≤1M chars/1000 keys) + A/B (MS internal platform) | REST/Experimentation APIs | managed (Azure) |
| **Satori (Heroic Labs)** | feature flags + experiments + liveops, **pairs with Nakama** | server-read flags + SDK | self-host/managed (matches Nakama choice) |

**Factory posture:** generate a **remote-config contract** (default values bundled in-build +
override schema) and **wire** one provider via adapter. **Satori is the natural default**
because it pairs with the recommended Nakama backend and keeps the self-hostable/CI-testable
property. A/B *execution* stays human-decided (consistent with qa-testing-liveops.md §7.2 —
the factory generates the runbook, humans decide cadence).

### 6.2 Crash / error reporting / observability

| Tool | Strength | Automation |
|---|---|---|
| **Sentry** | broad: native C/C++ crashes (minidumps, PDB/dSYM), Unity/Unreal SDKs, breadcrumbs | **`sentry-cli`** symbol upload; auto-upload env var; CI-wireable |
| **Backtrace (Sauce Labs)** | game-specialized crash analysis; NDK; minidumps | symbolication pipeline; SDK setup |
| **Firebase Crashlytics** | mobile + **Android NDK** native crashes; auto dSYM/symbol processing | Firebase CLI symbol upload |
| **Unity Cloud Diagnostics** | Unity-native crash/exception/ANR + telemetry | UGS-integrated |

**Factory posture:** crash reporting is a **wired artifact** (`crash-reporting-wiring` already
exists in qa-testing-liveops.md §10). Mandatory deliverable = **per-build symbol upload**
(sentry-cli / Crashlytics) so live crashes symbolicate. Crash-free-session rate is a hard
liveops SLO (already established).

---

## 7. Proposed Platform/Distribution-Adapter Protocol

**Recommendation: YES — build a platform/distribution-adapter that mirrors the engine-adapter
protocol.** The N-API-for-one-concept problem (Steam Cloud vs EOS Player Data vs iCloud; Steam
achievements vs EOS vs Game Center; steamcmd vs butler vs fastlane vs GDK) is *structurally
identical* to the engine-adapter's N-engines-for-one-capability problem the factory already
solves. Reusing the exact pattern (capability negotiation + fidelity grading + manifest+driver
+ conformance suite) keeps the factory **platform-agnostic the same way it is engine-agnostic**,
at near-zero conceptual cost.

### 7.1 Two adapters, mirrored design

The vector actually contains **two** seams (intentionally split, like build⊥capture):

**A. Online-Services Adapter** — runtime backend integration (the BaaS surface §2.1):

```yaml
# online-services adapter manifest (sketch)
provider: nakama            # | eos | playfab | accelbyte | firebase | supabase | ugs
hosting: self-hosted        # | managed   (drives CI-testability)
engine_agnostic: true
capabilities:
  identity:      { fidelity: full,    methods: [device, email, social, custom] }
  cloud_save:    { fidelity: full,    encryption: true }
  leaderboards:  { fidelity: full,    authority: server }   # client|server
  matchmaking:   { fidelity: full,    driver: "drivers/matchmaking" }
  lobby_party:   { fidelity: full,    max_party: 256 }
  entitlements:  { fidelity: partial }                       # DLC/ownership
  inventory:     { fidelity: full }                          # Hiro/wallet+ledger
  friends:       { fidelity: full,    model: directed-graph }
  presence:      { fidelity: partial }
  server_hosting:{ fidelity: full,    backend: nakama|gamelift|ams }
  analytics:     { fidelity: full }
ci_testable: true           # self-host ⇒ run backend in Docker in CI (Nakama)
```

**B. Distribution Adapter** — store/platform packaging & submission (§3, §4):

```yaml
# distribution adapter manifest (sketch)
target: steam               # | itchio | ios | android | egs | xbox | psn | switch
capabilities:
  achievements:    { fidelity: full,    api: ISteamUserStats }
  cloud_save:      { fidelity: full,    api: ISteamRemoteStorage }
  presence:        { fidelity: full,    api: ISteamFriends }
  iap:             { fidelity: full,    api: ISteamInventory }
  dlc_entitlement: { fidelity: full,    api: "ISteamApps.BIsDlcInstalled" }
  leaderboards:    { fidelity: full,    api: ISteamUserStats }
  build_upload:    { fidelity: full,    cli: "steamcmd +run_app_build {vdf} +quit" }  # VERIFIED
  store_submit:    { fidelity: human-gated, note: "store-page publish via web" }      # NEW TIER
# itch.io: build_upload {cli: "butler push {dir} user/game:channel"}  store_submit: none
# ios:     build_upload {cli: "fastlane upload_to_app_store"}  store_submit: human-gated (App Review)
# xbox:    build_upload {tool: GDK-pkg}  preflight: {cli: SubmissionValidator}  store_submit: human-gated (cert)
# psn/switch: build_upload {fidelity: partial, NDA}  store_submit: human-gated (TRC/Lotcheck)
```

### 7.2 The key protocol innovation: a `human-gated` fidelity tier

The engine-adapter uses `full`/`partial`/`none`. The distribution-adapter needs a **fourth
value: `human-gated`** — a capability whose *automatable prefix* (package, validate, upload)
the factory performs, and whose *terminal step* (console cert sign-off, store-page publish,
App Review submit) is a **declared human gate** the orchestrator surfaces as a manual task
with a checklist. This is the precise mechanism that lets a *lights-out* factory honestly
represent the irreducibly-human console-cert relationship **without pretending to automate it
and without dropping it on the floor.** It is the distribution analog of the existing
`replay: none` → human-playtest degradation.

### 7.3 Conformance suite (mirrored)

Just as engine adapters pass a reference-mini-game conformance suite, distribution adapters
pass a **reference-release conformance suite**: given a built artifact + a release manifest,
the adapter must (for its declared-`full` capabilities) round-trip an achievement unlock, a
cloud-save write/read, an entitlement check, and a build upload to a sandbox/test branch. For
`human-gated` capabilities, conformance verifies the **pre-flight** (e.g. Submission Validator
passes) and that the human-task artifact is emitted — not that submission completed.

---

## 8. Automatable vs Human

| Concern | Automatable (factory owns) | Human (factory surfaces as gated task) |
|---|---|---|
| Backend services integration | SDK wiring, auth flows, save/leaderboard/inventory calls, matchmaking config, server orchestration via API | choosing the provider's commercial tier; signing the BaaS contract |
| Platform SDK features | achievements/saves/presence/IAP/DLC *code integration* | platform account creation, app-ID registration, store metadata |
| Build → upload | **steamcmd / butler / fastlane / GDK package + Submission Validator** (all verified CLI) | — |
| Store presence | release manifest generation, build to test branch | **store-page publish, pricing, regional availability** (web) |
| Certification | **cert pre-flight** (GDK Submission Validator; qa-testing-liveops cert checklist 55–80%) | **console cert sign-off (TRC/XR/Lotcheck), App Review** — NDA + devkit + human lab |
| Platform legal/account | — | **platform partner agreements, NDAs, age-rating questionnaire submission, banking/tax setup** |
| LiveOps config | remote-config contract gen, flag wiring, crash-reporting + symbol-upload wiring, telemetry taxonomy | A/B cadence decisions, live-event tuning, on-call/SRE response |
| Patching/CDN | release manifest + delta baseline; delegate to platform CDN | CDN vendor account/billing |

**The clean line:** *technical integration and build→upload are automatable; commercial
relationships, legal/account setup, and certification sign-off are human.* This line is
**stable across every platform researched** and is the natural place to draw the `human-gated`
boundary.

---

## 9. Genre Variation

| Genre | Online-services need | Distribution complexity | Notes |
|---|---|---|---|
| **Det-sim pilot (roguelike/factory/RTS)** | LOW — leaderboards + cloud save + optional accounts | **LOW — PC-first (Steam/itch.io), fully CLI-automatable** | Ideal first target; Nakama (or even none) suffices; no console cert needed for v1 |
| **Live-service / F2P** | **HIGH — full BaaS: accounts, economy, inventory, matchmaking, liveops** | HIGH — multi-store + console + continuous patch | Backend + liveops adapter dominant; PlayFab/AccelByte-class |
| **Competitive multiplayer / fighting** | HIGH — matchmaking, leaderboards, dedicated servers, anti-cheat | HIGH — console parity expected | GameLift/AMS server hosting; rollback netcode (engineering-disciplines §5) |
| **Single-player narrative / premium** | LOW–MED — saves, achievements, maybe cloud save | MED — console cert if shipping console | Distribution-adapter `human-gated` cert is the main online surface |
| **Mobile casual** | MED — auth, leaderboards, IAP, remote config, A/B | MED — fastlane-automatable + store review | Firebase/UGS-class; liveops/experimentation heavy |
| **Open-world / RPG** | MED — saves (large), DLC entitlements, telemetry | HIGH — multi-platform, big patches/CDN | Entitlement/DLC + delta-patch manifest matter most |

**Implication:** the online-services + distribution adapters must be **genre-parameterized**
(which capabilities are required vs absent). The det-sim pilot deliberately minimizes both —
PC-only, optional backend — so it can ship **without** touching the human-gated console lane,
proving the automatable spine first.

---

## 10. Factory Artifacts / Contracts This Vector Implies

Additive to the artifact taxonomy in AAA-RECONCILIATION.md §6:

1. **`online-services-spec`** — engine/provider-neutral declaration of required backend
   capabilities (§2.1 surface) per game: which of identity/saves/leaderboards/matchmaking/
   entitlements/inventory/social/server-hosting are needed, at what authority (client vs
   server), with what data schema. Compiled by an **online-services adapter** into a concrete
   provider (Nakama/EOS/PlayFab/...).
2. **`platform-integration-manifest`** — per-target-platform declaration of which platform SDK
   features (achievements/saves/presence/IAP/DLC/leaderboards) the game wires, mapped to the
   normalized capability surface; the distribution-adapter compiles it to ISteam*/EOS/GameKit/
   Xbox calls.
3. **`distribution-release-pipeline`** (a.k.a. release manifest) — build version, channel/branch,
   delta-patch baseline, per-target upload command (steamcmd/butler/fastlane/GDK), and the
   **`human-gated` task list** (store publish, cert submit) emitted for human action.
4. **`remote-config-contract`** — bundled default values + override schema + which provider
   (Satori/Firebase/Unity/PlayFab/LaunchDarkly); flag-state logged to telemetry (ties to
   qa-testing-liveops §7.2).
5. **`crash-reporting-wiring`** *(exists, qa-testing-liveops §10.10)* — extended here to make
   **per-build symbol upload** (sentry-cli/Crashlytics) a hard deliverable.
6. **`cert-preflight-checklist`** *(exists, qa-testing-liveops §10.4)* — the distribution-adapter
   consumes it; GDK Submission Validator is the canonical wrapped pre-flight.

All ride the existing **declare-and-degrade** machinery: a distribution capability degrades
`full → human-gated → none`, and the orchestrator surfaces human-gated steps as checklisted
manual tasks rather than silently failing.

---

## 11. AAA Acceptance Bar

To claim "AAA-ready ship" for this vector:

- **Backend:** required online-services capabilities (per genre) wired and integration-tested
  against the real backend (Nakama in CI under Docker for the self-host path; sandbox tenant
  for managed) — round-trip auth, save, leaderboard, entitlement.
- **Platform features:** every declared platform SDK feature (achievements/saves/presence/
  IAP/DLC) passes distribution-adapter conformance on its target.
- **Distribution:** build→upload runs green via CLI to a test branch/track on every automatable
  target; the **human-gated** cert/publish tasks are emitted with their checklists.
- **Cert pre-flight:** GDK Submission Validator (and per-platform pre-flight) pass for console
  targets; the remaining human cert items are surfaced, not skipped.
- **LiveOps:** remote-config contract present with bundled defaults; crash reporting wired with
  per-build symbol upload; crash-free-session SLO defined.
- **Human gates honored:** console cert sign-off, store-page publish, platform legal/account
  setup, and A/B cadence are explicitly represented as human tasks — the factory is honest that
  it does not automate these, by design.

---

## 12. Scope Implications for the Brief (the load-bearing recommendation)

The current brief (§Scope, Out of Scope) excludes **"Console/platform certification and store
submission"** entirely and **"Real-time multiplayer netcode as a product feature."** This
vector forces a **partial revision**, resolved cleanly by the `human-gated` fidelity tier:

- **MOVE PARTIALLY IN-SCOPE: build distribution & store submission's automatable half.** A
  factory that must *ship* cannot leave verified, CLI-automatable depot-upload/store-build
  (steamcmd/butler/fastlane/GDK Submission Validator) out of scope — that *is* shipping. Bring
  **the automatable prefix** IN (build→package→upload→pre-flight via the distribution-adapter).
- **KEEP OUT-OF-SCOPE (but represented): console certification sign-off + platform legal.** The
  irreducibly-human, NDA-gated, devkit-requiring cert *terminal step* and partner/account/legal
  setup stay out — but are now **first-class `human-gated` tasks** the factory emits, not
  silent gaps. This is strictly more honest than the current "entirely out" framing.
- **ADD IN-SCOPE: online-services adapter + a reference backend.** Backend game services are
  unavoidable for any shippable multiplayer/live game and many single-player games (cloud
  saves, achievements). Recommend **Nakama as the reference adapter** (engine-agnostic,
  self-hostable, CI-testable) + the **distribution-adapter** + at least one managed adapter
  (EOS, free). This is a *wrap* layer, consistent with the brief's "wrap, don't reinvent" rule.
- **ADD IN-SCOPE: liveops-backend wiring** (remote-config contract + crash-reporting+symbols),
  extending the telemetry/liveops posture qa-testing-liveops.md already established.
- **NETCODE unchanged:** consistent with engineering-disciplines.md and the brief, real-time
  server-authoritative netcode stays a later tier; the online-services adapter *can wrap*
  Nakama/GameLift server hosting when a game opts in, but it is not a default v1 product feature.

**Net:** the brief's binary "store submission: OUT" should become **"store submission:
automatable prefix IN via distribution-adapter; cert sign-off + platform legal = `human-gated`,
surfaced not automated."** This preserves the lights-out thesis (the factory automates
everything automatable) while being truthful about the human cert relationship — the same
truthfulness the playtest-gate and `replay: none` degradations already model.

---

## 13. Open Questions & Risks

1. **Console SDK/submission internals are NDA-gated (HIGH).** PSN and Nintendo toolchain names,
   package formats, and cert APIs cannot be verified from public sources; the deep-research
   pass confabulated them badly. The distribution-adapter for consoles must be built against
   each studio's **licensed/NDA'd** docs + devkit; public build = stubs + `human-gated`. **The
   automatable console fraction is unknowable without devkit access.**
2. **Confabulation risk on distribution tooling (HIGH, demonstrated).** This very vector's
   second deep-research pass invented ~10 fake tool names/specifics. Rule (reaffirming R-009):
   **every distribution CLI/flag verified against the vendor doc before any automation is
   built.** Only steamcmd `+run_app_build +quit`, butler `push`, fastlane `upload_to_app_store`/
   `upload_to_testflight`/`build_app`/`sync_code_signing`, and GDK Submission Validator are
   confirmed in this pass. EGS BuildPatchTool flags are [UNVERIFIED].
3. **Backend provider lock-in vs the engine-agnostic thesis (MEDIUM).** Picking UGS (Unity-only)
   or PlayFab (Azure) as a *default* would re-introduce lock-in the factory exists to avoid.
   Mitigation: the online-services *adapter* is the neutral seam; **Nakama (open, engine-agnostic)
   is the reference**; managed providers are optional adapters, never the spine.
4. **Pricing/tier figures are MEDIUM-confidence.** PlayFab "$0 < 100K players", Nakama Heroic
   Cloud "from ~$600/mo", AccelByte AIS "$500/mo" come from vendor/secondary sources and move
   fast — re-verify at integration time; do not hard-code.
5. **UGS Multiplay EOL [UNVERIFIED].** The deep-research pass asserted Unity Multiplay hosting
   end-of-life; not confirmed against docs.unity.com. Verify before recommending UGS server
   hosting.
6. **`human-gated` throughput (MEDIUM).** Console cert + store publish are slow human loops
   (days–weeks). The factory must make them *cheap and checklisted* (pre-flight + emitted task
   templates) without pretending to remove them — the same bottleneck the playtest gate has.
7. **Entitlement/DLC fidelity varies (MEDIUM).** DLC/ownership semantics differ per platform
   (Steam BIsDlcInstalled vs EOS entitlements vs console); `entitlements` is marked `partial`
   on several adapters until per-platform round-trips are conformance-verified.

---

## 14. Sources

See YAML frontmatter for the full URL list. Verification highlights by claim class:

- **Distribution CLIs (WebFetch primary-source verified):** Steamworks SteamPipe/steamcmd
  uploading doc (exact `+run_app_build +quit` command, app_build/depot_build VDF, binary delta
  patching, store-page = web); itch.io butler doc (automatable pipeline, channels, delta
  patching, MIT); fastlane iOS App Store deployment (build_app/upload_to_app_store/
  sync_code_signing/capture_screenshots; App Review = human).
- **EOS free + cross-platform (Tavily-extract verified):** dev.epicgames.com EOS landing
  ("free, cross-platform services"; Accounts & Social, Multiplayer, Player & Game Data, Trust
  & Safety; Platforms Supported).
- **Xbox GDK Submission Validator (Tavily-extract verified):** learn.microsoft.com — automates
  basic quality checks pre-certification so partners self-diagnose; cert = human downstream.
- **BaaS platforms (deep-research, citation-grounded to official docs):** PlayFab
  (developer.microsoft.com + learn.microsoft.com Economy V2 / Title Data / Experiments);
  Nakama (heroiclabs.com docs — auth, matchmaking, parties, friends, Hiro inventory, Satori);
  AccelByte (docs.accelbyte.io identity/store/AMS); GameLift (docs.aws.amazon.com); Firebase
  (firebase.google.com remote-config/ab-testing/crashlytics); Supabase (supabase.com realtime
  GA); UGS (docs.unity.com).
- **LiveOps/observability (deep-research, citation-grounded):** LaunchDarkly (REST API,
  ldcli dev-server); Sentry (minidumps, native crash, sentry-cli); Backtrace/Sauce Labs;
  Crashlytics NDK; Unity Cloud Diagnostics; PlayFab Experiments; Satori remote-config.

**Cross-references (in-repo, built upon, not contradicted):**
`docs/research/aaa/{engineering-disciplines,production-pipeline,qa-testing-liveops}.md`,
`docs/research/aaa/AAA-RECONCILIATION.md`, `docs/design/engine-adapter-protocol.md`,
`.factory/specs/product-brief.md`.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep passes (reasoning_effort: high, strip_thinking): (1) BaaS platform comparison — PlayFab/AccelByte/Nakama/EOS/GameLift/Firebase/Supabase/UGS capabilities + hosting models [citation-grounded, USED]; (2) platform SDK + distribution-CLI automation [HEAVILY CONFABULATED — DISCARDED, debunked via WebFetch]; (3) liveops backend — remote config/feature flags/A-B + crash/observability [citation-grounded, USED] |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (library API depth not needed; vendor docs are the authority here) |
| Tavily tavily_extract | 1 | Primary-source verification of EOS-is-free/cross-platform (dev.epicgames.com) + GDK Submission Validator (learn.microsoft.com), advanced depth |
| Tavily tavily_search | 0 | — |
| WebFetch | 4 | **Primary-source re-anchoring of the confabulated distribution pass:** Steamworks uploading doc, itch.io butler doc, fastlane iOS deployment doc (all verified); EOS services page (404) and GDK subval (403) → recovered via Tavily-extract |
| WebSearch | 0 | — |
| Repo files (Read) | 6 | Grounded against engineering-disciplines, production-pipeline, qa-testing-liveops, AAA-RECONCILIATION, engine-adapter-protocol, product-brief — to mirror the adapter pattern and assess brief scope deltas |
| Training data | ~2 areas | Adapter-pattern framing + the automatable/human taxonomy structure — corroborated by sourced material; all specific tool/command names verified against vendor docs |

**Total MCP tool calls:** 4 (3 perplexity_research + 1 tavily_extract); + 4 WebFetch (primary-source verification)
**Training data reliance:** low — every load-bearing distribution claim is WebFetch/Tavily-verified
against the vendor doc; BaaS and liveops claims are deep-research outputs citation-grounded to
official URLs. **One full deep-research pass was confabulated and is explicitly discarded and
debunked** (see `research_quality_warning` frontmatter); its invented tool names are flagged
[UNVERIFIED] throughout rather than carried as fact. Console-submission internals are NDA-gated
and marked [UNVERIFIED] rather than guessed.
