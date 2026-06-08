---
document_type: research
vector: security-anticheat-trust-safety
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory = lights-out Dark Factory for AAA game development. THIS vector is security as a FEATURE of the GAMES the factory builds (anti-cheat, DRM, trust & safety) — distinct from the factory's OWN software-security rigor (security-reviewer / formal-verifier), which is inherited from vsdd-factory and out of scope here."
inputs:
  - docs/research/aaa/engineering-disciplines.md   # server-authoritative tier, networking testability, determinism tiers
  - docs/research/aaa/qa-testing-liveops.md         # replay-regression, telemetry, cert, machine-vs-human boundary
  - docs/research/aaa/AAA-RECONCILIATION.md         # BC/VP mapping, convergence model, scope, risk register
  - docs/decisions/0003-determinism-tier-capability.md  # (referenced via prior docs)
sources:
  # Server-authoritative / netcode trust boundary (primary)
  - "CWE-602 Client-Side Enforcement of Server-Side Security: https://cwe.mitre.org/data/definitions/602.html"
  - "Gabriel Gambetta — Client-Server Game Architecture: https://www.gabrielgambetta.com/client-server-game-architecture.html"
  - "Gabriel Gambetta — Client-Side Prediction & Server Reconciliation: https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html"
  - "Unity Netcode for GameObjects — dealing with latency: https://docs.unity3d.com/Packages/com.unity.netcode.gameobjects@2.12/manual/learn/dealing-with-latency.html"
  - "Unity Netcode for Entities — server rewind: https://docs.unity3d.com/Packages/com.unity.netcode@1.11/manual/server-rewind.html"
  - "Unreal Engine networking overview: https://dev.epicgames.com/documentation/unreal-engine/networking-overview-for-unreal-engine"
  - "OWASP Top 10 (the Game) — web/app security ref: https://owasp.org/www-project-top-10-the-game/"
  - "Replay-attack defense (nonces/sequence): https://www.packetlabs.net/posts/a-guide-to-replay-attacks-and-how-to-defend-against-them/"
  # Anti-cheat vendors (primary)
  - "BattlEye official: https://www.battleye.com"
  - "BattlEye (Wikipedia overview / title list): https://en.wikipedia.org/wiki/BattlEye"
  - "Easy Anti-Cheat official: https://www.easy.ac"
  - "EAC licensing (free, part of EOS): https://www.easy.ac/en-US/licensing"
  - "Epic Online Services: https://onlineservices.epicgames.com"
  - "EOS Anti-Cheat interfaces (developer docs): https://dev.epicgames.com/docs/epic-online-services/trust-and-safety/anti-cheat-interfaces/anti-cheat-interfaces"
  - "EAC EOS integration guide (Client/Server interfaces, platform components, modes): https://www.getgud.io/blog/comprehensive-guide-to-implementing-easy-anti-cheat-eac-with-epic-online-services/"
  - "EOS plugin for Unity — EAC configuration (PlayEveryWare): https://github.com/EOS-Contrib/eos_plugin_for_unity/blob/stable/com.playeveryware.eos/Documentation~/easy_anticheat_configuration.md"
  - "Riot Vanguard FAQ: https://www.riotgames.com/en/DevRel/vanguard-faq"
  - "Riot Vanguard (ring-0, boot-time, Secure Boot/TPM, Linux/macOS) — community wiki: https://leagueoflegends.fandom.com/wiki/Riot_Vanguard"
  - "GamingOnLinux — Riot on Vanguard & Linux (Apr 2024): https://www.gamingonlinux.com/2024/04/riot-games-talk-vanguard-anti-cheat-for-league-of-legends-and-why-its-a-no-for-linux/"
  - "Valve VAC integration (Steamworks): https://partner.steamgames.com/doc/features/anticheat/vac_integration"
  - "Kernel anti-cheat technical critique (secret.club): https://secret.club/2020/04/17/kernel-anticheats.html"
  - "Academic: rootkit-like behaviour in anti-cheat (ACM): https://dl.acm.org/doi/10.1145/3664476.3670433"
  - "Microsoft post-CrowdStrike kernel restrictions (CyberScoop): https://cyberscoop.com/microsoft-security-updates-kernel-restrictions-downtime/"
  - "GamingOnLinux anti-cheat compatibility tracker: https://www.gamingonlinux.com/anticheat/"
  # Account/online security & anti-fraud (primary)
  - "OWASP (game security project): https://owasp.org/www-project-top-10-the-game/"
  - "Apple StoreKit — App Store Server API (server-side receipt validation): https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transactionId}"
  - "Adapty — validating IAP with App Store Server API: https://adapty.io/blog/validating-iap-with-app-store-server-api/"
  - "Nakama (Heroic Labs) — IAP validation (Google): https://heroiclabs.com/docs/nakama/concepts/iap-validation/google/"
  - "Epic EOS — identity provider management: https://dev.epicgames.com/docs/epic-online-services/eos-fundamentals/identity-provider-management"
  - "Akamai — credential stuffing: https://www.akamai.com/glossary/what-is-credential-stuffing"
  - "Barracuda — account takeover: https://www.barracuda.com/support/glossary/account-takeover"
  - "Steam account security FAQ: https://help.steampowered.com/en/faqs/view/6639-EB3C-EC79-FF60"
  - "PlayStation account security settings: https://www.playstation.com/en-us/support/account/security-settings/"
  - "HTTP 429 / rate limiting: https://blog.postman.com/http-error-429/"
  - "Microsoft PlayFab (managed game backend / anti-fraud services): https://developer.microsoft.com/en-us/games/products/playfab/"
  # UGC trust & safety + legal duties (primary)
  - "18 U.S.C. § 2258A (CyberTipline reporting, no-monitor clause): https://www.law.cornell.edu/uscode/text/18/2258A"
  - "18 U.S.C. § 2258A (House code): https://uscode.house.gov/view.xhtml?req=granuleid%3AUSC-prelim-title18-section2258A"
  - "Microsoft PhotoDNA: https://www.microsoft.com/en-us/photodna"
  - "UK Online Safety Act 2023 (legislation): https://www.legislation.gov.uk/ukpga/2023/50"
  - "UK Online Safety Act explainer (gov.uk): https://www.gov.uk/government/publications/online-safety-act-explainer/online-safety-act-explainer"
  - "EU Digital Services Act (European Commission): https://digital-strategy.ec.europa.eu/en/policies/digital-services-act"
  - "FTC COPPA FAQ: https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions"
  - "FTC age-verification workshop (Dec 2025): https://www.ftc.gov/news-events/news/press-releases/2025/12/ftc-announces-workshop-age-verification-technologies"
  - "47 U.S.C. § 230 (intermediary liability context): https://www.law.cornell.edu/uscode/text/47/230"
  - "Modulate ToxMod (gaming): https://www.modulate.ai/solutions/gaming"
  - "Modulate ToxMod product page: https://www.modulate.ai/products/toxmod"
  - "Modulate/AWS — ToxMod scale & CoD MWIII / RecRoom: https://aws.amazon.com/blogs/gametech/modulate-scales-toxmod-ai-voice-chat-moderation-tool-with-aws/"
  - "Riot — VALORANT voice & chat toxicity dev blog (Feb 2022): https://playvalorant.com/en-us/news/dev/valorant-systems-health-series-voice-and-chat-toxicity/"
  - "Fair Play Alliance × ADL framework: https://thrivingingames.org/fair-play-alliance-and-adl-rally-industry-to-combat-hate-and-harassment-in-video-games/"
  - "Roblox content/account moderation appeals: https://en.help.roblox.com/hc/en-us/articles/360000245263-Appeal-Your-Content-or-Account-Moderation"
  - "Ban evasion (Incognia): https://www.incognia.com/blog/ban-evasion"
confidence: "HIGH on the machine-verifiable / operational boundary, server-authoritative principle, anti-cheat vendor integration models, and the CSAM/UK-OSA/DSA/COPPA legal-duty existence; MEDIUM on fast-moving specifics (Microsoft kernel-access changes, exact cert/regulator thresholds); LOW and explicitly FLAGGED on confabulation-prone specifics (Denuvo perf %, cheat-market dollar figures, Steam CEG internals, blockchain-cheat-market claims)."
---

# Game Security, Anti-Cheat, DRM & Trust/Safety — Factory Vector Research

> **Scope-of-vector note (READ FIRST).** This document is about **security as a FEATURE
> of the games the factory builds** — protecting *those games'* players, economies, and
> communities. It is **distinct from** the factory's own *software* security rigor
> (`security-reviewer`, `formal-verifier`, the 7→9-dimension convergence "security"
> dimension), which is inherited wholesale from vsdd-factory and governs the factory's
> code, not the game's. The two share machinery (BC/VP, property-based testing, fuzzing)
> but answer different questions: *"is the factory secure?"* vs *"is the game the factory
> shipped cheat-resistant and trust-and-safety-compliant?"* This vector answers the second.
>
> **Research-quality warning (READ FIRST).** The deep-research passes that fed this report
> produced rich but **partly confabulation-prone** output — consistent with the
> meta-lesson logged repeatedly in `AAA-RECONCILIATION.md` (R-009). Every load-bearing
> vendor/legal claim below was **re-verified against a primary source** (vendor docs,
> Cornell Law, regulator pages, GitHub) and is cited inline. Where a deep-research pass
> asserted a specific number, internal name, or mechanism that the primary-source check
> **could not confirm**, it is marked **[UNVERIFIED]** and the discrepancy is stated.
> Two concrete catches: (1) a pass claimed VALORANT issued "over 400,000 restrictions /
> 40,000 bans in **January 2026**" — primary source confirms those figures but they are
> from **January 2022** (Riot dev blog dated Feb 2022); the date was confabulated.
> (2) Denuvo performance percentages, cheat-market dollar totals, "Steam CEG = AES-256",
> "gameoverlayui.exe", and "blockchain cheat marketplaces" are **vendor-opaque or
> uncorroborated** and are flagged, not asserted.

---

## 1. Executive Summary

Game security splits — like every other AAA discipline the factory has analyzed — into a
**machine-verifiable spine** and an **operational / human shell**, and the split here is
unusually clean because it is anchored to a single, well-established architectural
principle: **never trust the client** (CWE-602). The factory's leverage is concentrated on
the spine; the shell is wrap-or-defer.

**Six load-bearing findings:**

1. **Server-authoritative validation is THE machine-verifiable security property — and it
   is already in the factory's wheelhouse.** "The client sends *inputs*, the server owns
   *state* and validates every action" (Gambetta; CWE-602) reduces directly to
   testable invariants: range checks, rate limits, sequence/nonce replay-prevention,
   line-of-sight/possible-movement validation, and "no client-reported authoritative
   value is ever trusted." These are exactly **Behavioral Contracts + Verification
   Properties** (property-based testing, fuzzing) on the *netcode trust boundary* — the
   same BC/VP rigor vsdd-factory already applies. This is the vector's primary deliverable:
   a **server-authority invariant suite** that the factory can generate and check headless,
   tied to the server-authoritative tier of `engineering-disciplines.md §2.6`.

2. **Client-side anti-cheat (kernel or user-mode) is fundamentally OPERATIONAL and
   mostly OUT OF AUTONOMOUS REACH — wrap, never build.** BattlEye, Easy Anti-Cheat/EOS,
   Riot Vanguard, and VAC are live-ops services with their own back-ends, kernel drivers,
   signing chains, and 24/7 detection teams. The factory can **integrate** one (an
   *anti-cheat adapter*), but cannot autonomously *operate* the cat-and-mouse loop, and
   **cannot generate a kernel driver** at AAA standard. **EAC/EOS is the clear default
   wrap target** (free, self-service, engine-agnostic, Client+Server SDK interfaces).

3. **Kernel anti-cheat is honestly beyond the factory's autonomous reach AND a moving
   regulatory target.** Ring-0 drivers carry CrowdStrike-class systemic risk, are
   Windows-only by nature, break Linux/Steam Deck/Proton, and are the subject of
   Microsoft's post-CrowdStrike push to move security software *out* of the kernel
   (CyberScoop). The factory should **never auto-author a kernel driver**; it integrates a
   vendor's, and the genre default (the det-sim pilot) doesn't need one at all.

4. **The cheat taxonomy maps cleanly onto "server-validatable vs client-only," which tells
   the factory exactly where its contracts bite.** Speed hacks, teleport/no-clip, memory
   edits of authoritative state, duplication/economy exploits, and RMT-feeding bots are
   **server-validatable → contractable**. Aimbots, triggerbots, and wallhacks/ESP are
   **client-side perceptual exploits → NOT server-detectable by validation alone** (they
   need client anti-cheat or statistical/ML detection). The factory owns the first column;
   the second is wrap-or-defer.

5. **DRM / anti-tamper (Denuvo, platform DRM) is wrap-or-config, with low autonomous
   value for the pilot.** Anti-tamper protects the *binary* against piracy; it is
   conceptually distinct from anti-cheat (live integrity) and licensing-DRM (ownership).
   It is a publisher/business decision with a real performance/perception cost, normally
   integrated by a vendor and often *removed* post-launch. The factory treats DRM as an
   **opt-in build-config / wrapped integration**, not a generated artifact.

6. **UGC trust & safety carries HARD LEGAL DUTIES with citations — but they are reporting/
   process duties, mostly operational, with a thin machine-verifiable edge.** CSAM
   reporting to NCMEC (18 U.S.C. § 2258A), UK Online Safety Act duties, EU DSA
   obligations, and COPPA (under-13) are real, must-do, and citable. Crucially, §2258A
   imposes **no affirmative duty to monitor/search** — the duty triggers on *actual
   knowledge*. The factory can generate the **wiring** (report pipeline, PhotoDNA-hash
   integration point, sanction/appeal flow, age-gate) as artifacts and verify their
   *presence/shape*; the *moderation judgment and policy* stay human/operational.

**Scope implication (one line):** include a **security-requirements contract +
server-authority invariant suite** as a first-class, machine-verifiable artifact (it
extends BC/VP and the existing networking-convergence contract); treat client anti-cheat,
DRM, and live moderation as **wrapped integrations / human-operated** with explicit
adapter seams; and keep kernel anti-cheat and live trust-and-safety operations **out of
v1 autonomous scope**, flagged honestly.

---

## 2. Anti-Cheat Approaches & the Client-Trust Problem

### 2.1 The foundational principle: never trust the client (server-authoritative)

The bedrock of game security is **CWE-602: Client-Side Enforcement of Server-Side
Security** — when a game relies on the client to protect the server, attackers modify the
client to bypass it (https://cwe.mitre.org/data/definitions/602.html). The cure is
**server-authoritative architecture**: the client sends *input requests* ("I pressed
fire"), the server owns authoritative state, validates each action against game rules, and
broadcasts results; the client is a renderer (Gambetta, client-server architecture). This
is the *same* principle the engineering vector already adopted as the
**server-authoritative networking tier** (`engineering-disciplines.md §2.6`).

Responsiveness is preserved via **client-side prediction + server reconciliation + server
rewind / lag compensation** (Gambetta; Unity Netcode docs; Unreal networking docs) — these
keep the security benefit while hiding latency. The security-relevant point for the factory:
**prediction is cosmetic; the server's validation is authoritative.** Every predicted
client outcome must be reconcilable to a server-validated truth, and that reconciliation is
*testable*.

What server-authority can and cannot stop:
- **Stops (validatable):** impossible movement/speed, teleport/no-clip, fire-rate /
  cooldown violations, ammo/resource fabrication, inventory/currency tampering of
  *authoritative* values, out-of-sequence or replayed packets. These are the validatable
  cheats.
- **Cannot stop by validation alone:** **information leakage** to the client (wallhack/ESP
  exploit the fact that the client legitimately *receives* world data) and **input-quality**
  cheats (aimbot/triggerbot send *legal* inputs, just superhumanly aimed). Mitigations are
  **relevancy/interest-management culling** (don't send a client what it can't perceive)
  and **client anti-cheat + statistical detection** — partial, not absolute.

### 2.2 Client anti-cheat: kernel-mode vs user-mode (vendor-verified)

Kernel-mode (Ring 0) anti-cheat sees the whole system (user + kernel memory, drivers,
syscalls) and can catch cheats that hide from user-mode; the cost is system-stability risk,
privacy exposure, OS-compatibility breakage, and a rootkit-like footprint
(secret.club kernel-anticheat analysis; ACM study finding "two of four anti-cheat solutions
exhibiting rootkit-like behaviour"). User-mode (Ring 3) is safer and more portable but
"cannot guarantee the integrity of the kernel" (secret.club).

| Vendor | Mode | Platforms | Developer integration | Licensing / availability | Verified source |
|---|---|---|---|---|---|
| **Easy Anti-Cheat (EAC) / EOS Anti-Cheat** | Kernel on Windows; **user-mode bootstrapper on macOS/Linux/Steam Deck** | Windows, macOS, Linux, **Steam Deck**; *not* mobile/console (but protected PC clients can match cross-platform) | **Client Interface + Server Interface** SDK; `EOS_AntiCheatClient_*` / `EOS_AntiCheatServer_*`; **cheat prevention + detection**; supports **dedicated-server, P2P-mesh, listen-server** modes; engine-agnostic with Unreal/Unity plugins; Windows ships a service installer + `start_protected_game` bootstrapper | **Free, self-service** as part of EOS | easy.ac/licensing; EOS anti-cheat-interfaces docs; getgud integration guide; PlayEveryWare Unity plugin; EOS/AWS talk |
| **BattlEye** | Kernel (Windows); user-mode on Linux/Proton (reduced) | Windows primary; partial Linux via Proton (many titles "Broken" on Linux per GamingOnLinux) | Proprietary SDK, client+server components; "fully proactive kernel-based protection," dynamic backend-controlled routines, global SteamID banning | **Subscription** (commercial; "100% independent") | battleye.com; Wikipedia; GamingOnLinux tracker |
| **Riot Vanguard** | **Kernel (Ring 0), boot-time, always-on**; requires **Secure Boot + TPM 2.0** (TPM 2.0 enforced on Vanguard devices) | **Windows only**; **no Linux, no macOS** (Linux "can't attest boot state"; macOS uses a different method) | **Not available to third parties** — Riot-internal only (Valorant, LoL, TFT, 2XKO) | Proprietary, not licensed out | Vanguard FAQ; LoL wiki; GamingOnLinux (Apr 2024) |
| **Valve Anti-Cheat (VAC) / VACnet / "VAC Live"** | **User-mode** (Valve deliberately avoids kernel AC) | Steam | Enable via **Steamworks** (flag servers VAC-secured); minimal SDK work; little customization | **Free with Steam** distribution; Steam-only | Steamworks VAC docs |

**VACnet / statistical-ML detection.** Valve's approach shifts from signature scanning to
**behavioral / ML detection**: "Trust Scores" and a model trained on Overwatch
human-reviewed labels to predict ban-worthiness, watching for super-human aim/reaction
patterns (Valve GDC 2018 talk, referenced). The **2026-state "VAC Live" real-time variant
is [UNVERIFIED]** against a Valve primary source in this pass — treat the *direction*
(ML behavioral detection) as solid, the specific product name/timeline as soft.

**What ML/statistical detection can and cannot do (for the factory):** it can flag
*behavioral consequences* of cheating (aim distributions, reaction-time floors, win-rate
anomalies) statistically and **server-side from telemetry** — which is contract-adjacent
(anomaly *thresholds* are declarable). It **cannot** give a hard yes/no on novel cheats and
carries false-positive risk, so enforcement stays human-reviewed. This is the *only* part
of client-cheat detection that touches the factory's verifiable spine, and only as
**telemetry-anomaly gates feeding human review**, never as autonomous bans.

### 2.3 Platform / OS controversies & limits (honest flags)

- **Linux / Steam Deck / Proton:** kernel AC is Windows-shaped; on Linux it degrades to
  user-mode (EAC/BattlEye) or is refused entirely (Vanguard). Competitive titles routinely
  exclude or break on Linux/Deck (GamingOnLinux tracker). **Implication:** a factory that
  ships cross-platform competitive MP inherits this dilemma; the det-sim pilot sidesteps it.
- **CrowdStrike-class systemic risk + Microsoft's response:** a faulty Ring-0 update can
  take down machines fleet-wide; post-CrowdStrike, **Microsoft is moving third-party
  security software out of the Windows kernel toward user-mode** (CyberScoop). This is a
  **fast-moving** structural shift that undercuts the long-term viability of kernel AC.
  **The factory must not bet autonomous capability on kernel drivers.** [Specifics of the
  Microsoft program timeline are MEDIUM-confidence / fast-moving — re-verify.]
- **macOS:** kext deprecation + SIP largely preclude traditional kernel AC; Riot uses a
  non-kernel method on macOS. Apple's posture reduces the *need* for, and *ability* to
  ship, kernel AC.
- **Privacy / rootkit criticism:** independent analysis documents rootkit-like behavior in
  some AC drivers (ACM 10.1145/3664476.3670433); this is a real reputational/ethical cost
  the factory should surface in a risk register, not paper over.

---

## 3. Cheat Taxonomy → Server-Validatable vs Client-Only (the factory's map)

The single most useful framing for the factory: **which column is a cheat in?** The left
column is contractable by server-authority; the right column is not, and needs wrapped
client-AC / ML detection / design mitigation.

| Cheat | How it works (verified at a conceptual level) | Server-validatable? | Factory posture |
|---|---|---|---|
| **Speed hack / movement exploit** | Manipulate time-delta or velocity to exceed movement caps | **YES** — server compares reported position vs max-possible movement from inputs | Server-authority invariant (max-speed/trajectory) |
| **Teleport / no-clip** | Overwrite position coords / disable collision | **YES** — trajectory + navmesh plausibility validation | Server-authority invariant |
| **Memory/value edit (Cheat Engine)** of *authoritative* state (health, currency, ammo) | `ReadProcessMemory`/`WriteProcessMemory` on client state | **YES** — server-owned state overwrites client claims | "No-trust-client" invariant; server reconciliation |
| **Duplication / economy exploit** | Race/atomicity bug in trades, dupes items/currency | **YES** — transactional invariants (conservation, atomicity) | **Economy-conservation BC** (ties to `economy-balance-contract`) |
| **Bots / automation / grind bots** | Scripted input or memory-driven action loops | **PARTIAL** — server can validate action plausibility / cooldowns / accrual rates; perfect humanization evades | Rate/accrual invariants + telemetry anomaly (human review) |
| **RMT (real-money trading)** | Off-platform sale of in-game assets; fed by bots/dupes | **PARTIAL** — server detects abnormal transfers/accrual; the *sale* is off-platform | Anti-fraud telemetry + economy invariants; mostly operational |
| **Account theft / ATO** | Credential stuffing, phishing, session hijack | **PARTIAL** — server-side ATO defenses (MFA, anomaly login, session mgmt) | Auth/anti-fraud (see §5) |
| **Aimbot / triggerbot** | Read enemy coords from memory; auto-aim/auto-fire — sends **legal** inputs | **NO** (by validation) — only **statistical/ML** + client AC | Wrap client-AC / ML detection; out of autonomous reach |
| **Wallhack / ESP** | Disable occlusion / read entity list / overlay — **client receives the data legitimately** | **NO** (by validation) — mitigate via **relevancy culling**; detect via client AC | **Interest-management invariant** ("don't replicate non-perceivable entities") is the one contractable lever; full defense is client-AC |

> **Confabulation flags in this section's source pass:** the deep pass asserted specific
> hooking APIs (`DrawIndexedPrimitive`, Direct3D device-table hooking) and "GPU-level"
> detection details. These are plausible and broadly consistent with public reversing
> writeups but were **not individually primary-verified**; treat mechanism detail as
> [UNVERIFIED] illustration. The **column placement** (validatable vs not) is the
> load-bearing, high-confidence claim.

---

## 4. DRM & Anti-Tamper (wrap-or-config; low autonomous value for pilot)

**Three distinct systems — keep them separate (high-confidence conceptual distinction):**
- **Licensing DRM** — proves *ownership/entitlement*, gates install/launch (Steam, Epic,
  console platform DRM). Minimal runtime cost.
- **Anti-tamper** — protects the *binary* from reverse-engineering/cracking (Denuvo). VM
  obfuscation, control-flow obfuscation, anti-debug, hardware-bound activation. Continuous
  runtime cost; primarily valuable in the early-sales piracy window.
- **Anti-cheat** — protects the *live game* from cheating players (§2). Behavioral/runtime.

**Denuvo Anti-Tamper:** conceptually, encrypts/obfuscates critical code into a custom VM
interpreted at runtime + hardware-bound activation, defeating static analysis. The
**performance controversy and player-perception backlash** are real and well-documented as
*sentiment*; the **specific "5–15% frame-rate" figures are [UNVERIFIED]** — Denuvo's impact
is vendor-opaque, confounded by simultaneous patches, and independent measurements vary
widely. The **post-launch removal trend** (publishers strip Denuvo months after release) is
a real, observable pattern, though exact timelines (the pass's "3–12 months") are
directional, not audited.

**Platform DRM:** Steam (Steamworks DRM wrapper / CEG), Epic (opt-out-able), and
hardware-rooted console DRM (PS5/Xbox/Switch signed-execution chains) exist and differ.
**[UNVERIFIED]**: the deep pass's internal specifics ("Steam CEG uses AES-256,"
"`gameoverlayui.exe` verifies license," PS5 key-burning details) are **not primary-source
confirmed here** and should not be relied on; the *existence and category* of each platform
DRM is solid, the *internals* are not.

**Exploit economy:** a real subscription-cheat market exists with weekly update cadence,
crypto payments, and resilient redistribution — the **arms-race dynamic is high-confidence**.
The deep pass's **specific dollar totals ("$500M–$2B annually"), "$20–$100/mo" pricing, and
"blockchain marketplaces" are [UNVERIFIED]** estimates — flag, do not cite as fact.

**Factory posture:** DRM/anti-tamper is a **business/publisher decision and a vendor
integration**, not a generated artifact. Model it as an **opt-in build-config flag +
wrapped-integration seam** in the build capability; the det-sim pilot (PC-first,
single-player or deterministic MP) gets little value from anti-tamper and should default
**off**. Record the perf/perception tradeoff in the risk register.

---

## 5. Account & Online Security & Anti-Fraud

This is mostly **operational security posture** with a **machine-verifiable edge** at the
server-validation boundary (which overlaps §6).

- **Authentication / identity:** wrap platform identity (Steam, PSN, Xbox Live, Epic
  accounts) via OAuth/OIDC providers; EOS supports multiple identity providers (EOS
  identity-provider docs). **MFA/2FA, passwordless, session management** are
  best-practice posture; **ATO defenses** (credential-stuffing mitigation, login-anomaly
  detection) are operational (Akamai; Barracuda; Steam/PSN security docs).
- **Anti-fraud / anti-bot:** payment-fraud/chargeback handling, fake-account/bot-signup
  prevention, CAPTCHA + behavioral bot detection, **API/matchmaking rate limiting** (HTTP
  429). Largely wrap (PlayFab-class backends, vendor fraud services) + operational.
- **Secure entitlements (machine-verifiable!):** ownership/DLC/IAP must be verified
  **server-side**, never trusting a client receipt. Primary patterns: **Apple App Store
  Server API** transaction/subscription verification; **Google Play** receipt validation
  (Nakama IAP docs); server-side entitlement checks. **This is contractable:** "no
  entitlement is granted on a client-asserted receipt; every grant traces to a
  server-validated transaction" is a testable invariant.

**Machine-verifiable vs operational here:** *secure-entitlement server-validation* and
*rate-limit enforcement* are **contractable invariants**; *auth provider choice, MFA
adoption, fraud-model tuning, ATO incident response* are **operational posture** the
factory wires/wraps but does not autonomously operate.

---

## 6. Secure Netcode Invariants — Machine-Verifiable, Tied to BC/VP

**This is the vector's strongest fit and primary deliverable.** Every server-authority
property reduces to a typed assertion checkable headless — exactly the **Behavioral
Contract + Verification Property** machinery vsdd-factory already runs (TDD Red Gate,
property-based testing, `cargo-fuzz`/Kani-class hardening), and it rides the existing
**networking-convergence contract** (`engineering-disciplines.md §8.3`) and the
server-authoritative tier.

**Machine-verifiable security invariants (contractable):**

| Invariant class | Assertion form | Verification technique |
|---|---|---|
| **No-trust-client** | "No authoritative value (health, position, currency, ammo, entitlement) is ever set from a client-asserted value without server re-derivation" | Structural/BC test over the netcode boundary; fuzz client messages and assert state unchanged |
| **Input range validation** | "Every client input field is within declared min/max before use" | Property-based testing over the input schema; fuzzing |
| **Action plausibility** | "Reported action is physically/temporally possible (max-speed, cooldown, line-of-sight, ammo)" | BC: input→state matrices; replay-regression with adversarial inputs |
| **Rate limiting** | "No client exceeds N actions/window; excess is rejected (429-equivalent)" | Property test: flood → bounded acceptance |
| **Replay-attack prevention** | "Each message processed at most once and within freshness window (sequence numbers / nonces / timestamps)" | Property test: replayed/duplicated/old packets are rejected |
| **Sequence/ordering** | "Out-of-order or forged-sequence packets do not corrupt state" | Fuzz reorder/drop/duplicate; assert convergence |
| **Authoritative reconciliation** | "Predicted client state always reconciles to a server-validated truth; no client prediction is durable" | Replay-regression: predict vs authoritative, assert bounded drift → reconvergence |
| **Interest-management (anti-wallhack lever)** | "No entity outside a client's relevancy set is replicated to that client" | Test: assert non-perceivable entities absent from outbound replication |
| **Economy conservation / atomicity (anti-dupe)** | "Trades are atomic; total currency/items conserved across any interleaving" | BC + property test over concurrent transactions (ties to `economy-balance-contract`) |
| **Secure-entitlement server-validation** | "Every entitlement grant traces to a server-validated transaction; client receipts never sufficient" | BC over the entitlement path; fuzz forged receipts |

These are **declare-and-degrade-friendly**: on a non-server-authoritative (P2P/lockstep)
topology, some invariants restate as *N-peer determinism + checksum equality* (reusing the
replay-regression spine almost verbatim — `qa-testing-liveops.md §4`). The factory should
treat this as a **security-requirements contract** that *extends* BC/VP, with adversarial
fuzzing of the trust boundary as a first-class generation+verification step.

---

## 7. UGC & Trust/Safety Moderation (+ Legal Duties)

**Mostly operational/human, with a thin machine-verifiable wiring edge and HARD,
CITABLE legal duties.**

### 7.1 The work
- **UGC moderation** (custom levels, mods, usernames, profiles, skins): automated
  classifiers (image/text/3D scanning, PhotoDNA hash-matching) for high-volume obvious
  violations + **human review** for nuance; the scale problem is real (millions of
  assets/day on large UGC platforms). Hybrid is the industry norm (Modulate; WebPurify;
  Roblox).
- **Text + voice moderation:** text filters + transformer toxicity models; **real-time
  voice moderation** via **Modulate ToxMod** (verified: triage→analyze→act,
  human-in-the-loop, used by **Call of Duty: Modern Warfare III** and **RecRoom**;
  Modulate/AWS). **Riot VALORANT** records/evaluates voice **only when a report is filed**,
  with mute/restriction/ban tiers (Riot dev blog — **note: the 400k-restriction / 40k-ban
  figures are from January 2022, not 2026** [date corrected from a confabulated pass]).
- **Industry collaboration:** **Fair Play Alliance** + ADL "Disruption and Harms in Online
  Gaming Framework" — voluntary best-practice, not a legal duty.
- **Reporting / sanctions / appeals / ban evasion:** report flows, escalating automated
  sanctions, appeals (Roblox appeals docs), and ban-evasion detection (Incognia) — largely
  operational.

### 7.2 Hard legal duties (must-do, cited)

| Duty | Who / where | What it actually requires | Citation |
|---|---|---|---|
| **CSAM reporting** | US "providers" (ECS/RCS) — includes online games with user comms | Report apparent CSAM to **NCMEC CyberTipline** "as soon as reasonably possible after obtaining **actual knowledge**." **No affirmative duty to monitor/search** — duty triggers on actual knowledge, not proactive scanning | 18 U.S.C. § 2258A (law.cornell.edu) |
| **CSAM detection tooling** | Voluntary but near-universal | **PhotoDNA** perceptual-hash matching against known-CSAM databases | microsoft.com/photodna |
| **UK Online Safety Act** | User-to-user & search services with UK users | Duties of care: risk assessments, systems to protect users (esp. children) from illegal/harmful content; Ofcom-enforced | UK OSA 2023 (legislation.gov.uk); gov.uk explainer |
| **EU Digital Services Act** | Online platforms serving EU users | Notice-and-action, transparency reporting, illegal-content removal systems; tiered by size (VLOPs strictest) | EC Digital Services Act |
| **COPPA (under-13)** | US services directed to / knowingly serving children | Parental consent, data-minimization for under-13 | FTC COPPA FAQ |
| **Age assurance (emerging)** | Fast-moving (US/UK/EU) | Age-verification/assurance trend; FTC held a Dec-2025 workshop — **direction is firming, exact mandates jurisdiction-specific** | FTC age-verification workshop |

> §230 (47 U.S.C.) provides US intermediary-liability context but is **not** a CSAM/child
> shield — §2258A duties stand independently.

### 7.3 What the factory can verify vs operate
- **Machine-verifiable (wiring presence/shape):** the **moderation pipeline exists and is
  correctly wired** — a CSAM-report path to NCMEC, a PhotoDNA-hash integration point, a
  reporting/sanction/appeal state machine, an age-gate, DSA transparency-logging hooks.
  The factory can generate these as artifacts and **assert their presence and structural
  correctness** (a `moderation-pipeline-contract`), the same way it verifies
  telemetry-taxonomy wiring.
- **Operational / human (NOT factory-autonomous):** the **moderation judgments**, policy
  authorship, classifier tuning, human-reviewer staffing, and the *legal sign-off* that the
  pipeline satisfies a given jurisdiction. These are explicitly **human gates**, consistent
  with the playtest-satisfaction precedent.

---

## 8. Machine-Verifiable vs Operational/Human (the core deliverable)

| Security property | Class | Factory mechanism | Gate |
|---|---|---|---|
| Server-authoritative validation / no-trust-client | **Machine** | Server-authority invariant suite (BC/VP + fuzz on trust boundary) | CI gate |
| Input range/rate/sequence validation | **Machine** | Property-based tests + fuzzing | CI gate |
| Replay-attack prevention (nonce/sequence/freshness) | **Machine** | Property tests over packet reorder/replay | CI gate |
| Authoritative reconciliation (prediction is cosmetic) | **Machine** | Replay-regression (predict vs authoritative) | CI gate |
| Interest-management culling (anti-wallhack lever) | **Machine** | Replication-relevancy assertion | CI gate |
| Economy conservation / dupe-atomicity | **Machine** | Economy-conservation BC + concurrency property tests | CI gate |
| Secure-entitlement server validation | **Machine** | Entitlement-path BC + forged-receipt fuzz | CI gate |
| Telemetry-anomaly cheat *signals* (statistical) | **Mixed** | Declarable anomaly thresholds → **human-reviewed** | Advisory + human |
| Client anti-cheat (kernel/user-mode) operation | **Operational** | **Wrap** EAC/EOS (default), BattlEye; never build kernel driver | Wrapped integration |
| Live anti-cheat ops (cat-and-mouse, ban waves) | **Operational** | Vendor + live team | Out of autonomous scope |
| DRM / anti-tamper | **Operational/config** | Opt-in build-config + vendor wrap | Publisher decision |
| Account auth / MFA / ATO response / anti-fraud tuning | **Operational** | Wrap (PlayFab-class) + posture | Out of autonomous scope |
| UGC/chat/voice **moderation pipeline wiring** | **Machine (shape)** | `moderation-pipeline-contract` (presence/structure) | CI gate |
| Moderation **judgments + policy + legal sign-off** | **Human** | Human gate (CSAM/OSA/DSA/COPPA) | Mandatory human/legal gate |
| Kernel anti-cheat authoring | **Out of reach** | — (honest flag) | Not in scope |

---

## 9. Genre Variation

| Genre lane | Security weight | What the factory owns | What it wraps/defers |
|---|---|---|---|
| **Competitive multiplayer (FPS/MOBA/BR/fighting)** | **Highest** | Full server-authority invariant suite; interest-management; anti-dupe; rate limits | **Client anti-cheat (wrap EAC/EOS)**; live AC ops; kernel AC (defer/exclude); statistical detection (wrap) — and inherits the **Linux/Deck exclusion dilemma** |
| **Single-player** | **Lowest** | Save-integrity, optional anti-tamper config | Anti-cheat largely N/A; DRM is publisher choice; no T&S duty absent user comms |
| **Det-sim pilot (roguelike / automation / det-RTS)** | **Low–moderate, ideal fit** | If MP: **lockstep determinism + N-peer checksum equality** *is* the anti-cheat (no client-authoritative state to forge); economy-conservation BC; server-authority invariants where applicable | No kernel AC needed; no/low T&S surface; PC-first DRM optional — **maximizes the verifiable spine, minimizes operational shell** |
| **UGC-heavy (sandbox/creative) or chat/voice-heavy** | **Trust-&-safety-dominant** | Moderation-pipeline *wiring* + legal-duty wiring (CSAM/OSA/DSA/COPPA) | **All moderation judgment + policy + legal sign-off = human**; voice mod = wrap ToxMod |

**Pilot implication:** the det-sim pilot is again the cleanest target — deterministic
lockstep makes the *strongest* anti-cheat guarantee (every peer re-simulates identically;
divergence = desync/cheat, caught by checksum) **for free from the determinism work
already specified**, with essentially no operational anti-cheat or T&S burden.

---

## 10. Factory Artifacts / Contracts This Vector Implies

Additive to the existing Layer-2 taxonomy (`AAA-RECONCILIATION.md §6`); all ride the
declare-and-degrade machinery.

1. **`security-requirements-contract`** *(new)* — the game's declared security posture:
   topology (server-auth / lockstep / P2P / single-player), threat model, which cheat
   classes are in-scope, which invariants apply, anti-cheat/DRM/T&S integration decisions,
   and the genre security profile. The seed for everything below. Verifiable for
   *completeness/consistency*; an **adversary checks the verifiable-vs-operational split**.
2. **`server-authority-invariant-suite`** *(new, the spine)* — the machine-checkable
   netcode security invariants of §6 (no-trust-client, range/rate/sequence, replay
   prevention, reconciliation, interest-management, economy conservation, secure
   entitlement). **Extends BC/VP**; generated *and* adversarially fuzzed at the trust
   boundary; integrates with the existing **networking-convergence contract**. The factory's
   bread-and-butter for this vector.
3. **`anti-cheat-integration-adapter`** *(new, wrap seam)* — an adapter contract for
   integrating a third-party client anti-cheat (**EAC/EOS default**; BattlEye optional),
   declaring Client/Server-interface wiring, build-step inclusion, platform components, and
   topology mode (dedicated/P2P/listen). The factory **wires and verifies presence/shape**;
   it does **not** operate the service or author a kernel driver. Explicitly flags
   Linux/Deck and kernel limits.
4. **`moderation-pipeline-contract`** *(new, wrap+legal seam)* — declares the UGC/chat/voice
   moderation wiring: classifier/PhotoDNA integration points, **CSAM→NCMEC report path**,
   report/sanction/appeal state machine, age-gate, DSA transparency hooks, **voice-mod wrap
   (ToxMod) seam**. Factory verifies the pipeline's **presence and structural correctness**;
   the **moderation judgments, policy, and legal sign-off are mandatory human/legal gates.**
5. **`drm-anti-tamper-config`** *(new, opt-in config)* — opt-in build-config + vendor-wrap
   seam for licensing-DRM / anti-tamper; **distinct** from anti-cheat and from entitlement
   validation; defaults off for the pilot; records perf/perception tradeoff in the risk
   register.
6. **`secure-entitlement-contract`** *(new, machine-verifiable)* — "no entitlement granted
   on a client-asserted receipt; every grant traces to a server-validated transaction"
   (Apple App Store Server API / Google Play / EOS patterns). A clean BC.

**Convergence-model tie-in:** these populate the existing **`security` convergence
dimension** *for the shipped game* (not just the factory's own code), and the
server-authority/entitlement invariants extend the **`sim/spec` (#1)** and **`tests/replay`
(#2)** dimensions of `AAA-RECONCILIATION.md §7`.

---

## 11. AAA Bar

- **Server-authoritative validation is table-stakes** for any monetized/competitive AAA MP
  title (CWE-602; universal practitioner consensus). The machine-verifiable invariant suite
  *is* the AAA-grade contribution here and is fully in the factory's reach.
- **Shipping a competitive AAA MP title implies a wrapped client anti-cheat** (EAC/EOS,
  BattlEye, or — if you're Riot — a bespoke kernel AC). The factory can clear this bar
  **only by integration**, and only to the limit of the vendor; the live cat-and-mouse,
  kernel-driver maintenance, and ban-wave operations are **beyond autonomous v1**.
- **UGC/chat/voice at AAA scale implies a legally-compliant T&S operation** (CSAM/OSA/DSA/
  COPPA). The factory can clear the *wiring/shape* bar; **legal compliance sign-off and
  moderation judgment are human gates** — non-negotiable.
- **DRM/anti-tamper is optional and publisher-driven**, not a quality bar; the modern AAA
  pattern even *removes* it post-launch.

---

## 12. Open Questions & Risks

1. **Client anti-cheat operation is genuinely out of autonomous reach (HIGH).** The factory
   can wrap EAC/EOS but cannot run the detection arms race or author a kernel driver. Hold
   the line: competitive-MP shipped by the factory carries an explicit "wrapped client-AC +
   human live-ops" dependency, not an autonomous claim.
2. **Kernel AC is a fast-moving, possibly-shrinking target (HIGH/fast-moving).** Microsoft's
   post-CrowdStrike kernel-access changes (MEDIUM-confidence specifics) may reshape the
   landscape; do not architect around kernel drivers. Re-verify Microsoft's program before
   any related decision.
3. **Confabulation in source passes (HIGH — meta-risk, per R-009).** This pass caught a
   **wrong date** (VALORANT figures: Jan **2022**, not 2026), **vendor-opaque perf numbers**
   (Denuvo %), **uncorroborated market totals** (cheat-economy $), and **unverified DRM
   internals** (Steam CEG / PS5 keys). All flagged [UNVERIFIED] above. Anything not
   primary-cited here is suspect.
4. **Statistical/ML cheat detection is advisory, not a contract (MEDIUM).** It feeds
   human-reviewed thresholds; never wire it to autonomous bans (false-positive + fairness
   risk). It is the *only* client-cheat signal that touches the verifiable spine, and only
   weakly.
5. **T&S legal duties are jurisdiction-specific and evolving (MEDIUM).** §2258A is firm
   (actual-knowledge trigger, no-monitor clause); UK OSA / EU DSA / age-assurance are
   evolving and Ofcom/EC-enforced. The factory verifies *wiring*; **a human/legal gate must
   own compliance** — the factory must not assert legal compliance autonomously.
6. **Interest-management is the only contractable anti-wallhack lever (MEDIUM).** It reduces
   but does not eliminate ESP; full defense needs wrapped client AC. Don't over-claim.
7. **Privacy/rootkit ethics of client AC (MEDIUM).** If the factory integrates kernel AC,
   it inherits the rootkit-criticism and CrowdStrike-class systemic-risk reputation. Record
   in the risk register; prefer user-mode/EAC defaults.

---

## 13. Sources

See YAML `sources` block for the full primary-source list. Primary/authoritative anchors by
claim class:

- **Server-authority / netcode:** CWE-602 (MITRE); Gabriel Gambetta (client-server,
  prediction/reconciliation); Unity Netcode (latency, server-rewind); Unreal networking
  docs; OWASP; packetlabs replay-attack guide.
- **Anti-cheat vendors (primary-verified):** easy.ac + easy.ac/licensing; EOS anti-cheat
  interface docs; getgud EAC/EOS integration guide; PlayEveryWare EOS-Unity EAC config;
  battleye.com + Wikipedia; Riot Vanguard FAQ + LoL wiki + GamingOnLinux (Apr 2024);
  Steamworks VAC docs; secret.club + ACM 3664476.3670433 (kernel/rootkit critique);
  CyberScoop (Microsoft kernel restrictions).
- **Account/anti-fraud/entitlements:** EOS identity-provider docs; Apple App Store Server
  API; Nakama IAP validation; Akamai/Barracuda (ATO/credential stuffing); Steam/PSN
  security docs; Postman HTTP-429; PlayFab.
- **Trust & safety + legal:** 18 U.S.C. § 2258A (Cornell + House); Microsoft PhotoDNA; UK
  OSA 2023 (legislation.gov.uk + gov.uk explainer); EU DSA (EC); FTC COPPA + age-verif
  workshop; 47 U.S.C. § 230; Modulate ToxMod (product + AWS); Riot VALORANT dev blog (2022);
  Fair Play Alliance × ADL; Roblox appeals; Incognia ban-evasion.

**Cross-references (in-repo, built upon, not contradicted):**
`docs/research/aaa/engineering-disciplines.md` (§2.6 server-authoritative tier, §8.3
networking-convergence contract), `docs/research/aaa/qa-testing-liveops.md` (§4
replay-regression, telemetry, machine-vs-human boundary),
`docs/research/aaa/AAA-RECONCILIATION.md` (BC/VP mapping §4, convergence model §7, scope §10,
risk register §12, R-009 confabulation meta-lesson).

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 4 | Deep multi-source synthesis (`reasoning_effort: high`, `strip_thinking: true`): (1) anti-cheat landscape + server-authoritative + kernel/user-mode vendors + ML detection + OS controversies; (2) DRM/anti-tamper + cheat taxonomy + exploit economy; (3) UGC trust&safety + voice mod + CSAM/OSA/DSA/COPPA legal duties; (4) account security + anti-fraud + secure entitlements + machine-verifiable netcode invariants |
| Perplexity perplexity_search | 3 | Primary-source cross-validation of fast-moving/confabulation-prone vendor claims: Riot Vanguard (kernel/Secure Boot/TPM/Linux/macOS — confirmed via Fandom wiki + Riot dev lineage); EAC/EOS (free/self-service/engine-agnostic/Client+Server interfaces/Win-kernel+Mac-Linux-Deck user-mode — confirmed via easy.ac + getgud + EOS/AWS talk + PlayEveryWare); Modulate ToxMod (CoD MWIII/RecRoom, triage/analyze/act, human-in-loop — confirmed via modulate.ai + AWS) |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (no library-API depth needed; netcode framework specifics already in engineering vector) |
| Tavily tavily_search | 0 | — |
| WebFetch | 3 | Primary-source verification: **18 U.S.C. § 2258A** (Cornell Law — confirmed actual-knowledge trigger + no-duty-to-monitor clause verbatim); Riot Vanguard FAQ (confirmed "no allow list," redirected detailed claims to wiki/dev-post); VALORANT voice-mod dev blog (**caught confabulated date** — figures are Jan 2022 not 2026; confirmed record-on-report + mute/restrict/ban tiers) |
| WebSearch | 0 | — |
| Training data | ~2 areas | Taxonomy structure + the machine-verifiable/operational framing (the report's spine); every load-bearing vendor/legal/mechanism claim re-anchored to a cited primary source or explicitly marked [UNVERIFIED] |

**Total MCP tool calls:** 7 (4 `perplexity_research` + 3 `perplexity_search`) + 3 WebFetch = 10 grounded calls
**Training data reliance:** low — the verifiable-vs-operational framing and taxonomy are
model-structured, but all load-bearing claims are primary-cited; confabulation-prone
specifics (Denuvo perf %, cheat-market $, Steam CEG/PS5 DRM internals, VALORANT date,
VAC-Live productization) are explicitly flagged [UNVERIFIED] rather than asserted. One
deep-research date error was caught and corrected against the primary source.
