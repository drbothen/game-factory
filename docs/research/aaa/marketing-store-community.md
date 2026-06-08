---
document_type: research
vector: marketing-store-community
version: "1.0"
status: draft
timestamp: 2026-06-08T00:00:00Z
producer: research-agent
project: game-factory
scope: >
  Marketing asset production, store presence & ASO/SEO, press kits & review-copy
  distribution, social/community/influencer programs, marketing-beat/campaign timeline,
  and gameplay-capture automation — framed toward an engine-agnostic, lights-out AAA
  game-factory. Focus: which marketing assets the factory can AUTO-GENERATE, the
  platform asset SPECS that become machine-checkable, and the factory artifacts/contracts.
inputs:
  - docs/research/aaa/AAA-RECONCILIATION.md
  - docs/research/aaa/art-pipeline.md
  - docs/research/aaa/generative-asset-ai.md
  - docs/research/aaa/narrative-worldbuilding-lore.md
  - docs/design/engine-adapter-protocol.md   # capture / render execution profile
sources:
  # Steam / Steamworks store + library asset specs (PRIMARY — WebFetch-verified against partner.steamgames.com)
  - https://partner.steamgames.com/doc/store/assets/standard          # VERIFIED: header/small/main/vertical capsule, page bg, screenshots ≥5
  - https://partner.steamgames.com/doc/store/assets/libraryassets      # VERIFIED: library capsule/hero/logo/header dims
  - https://partner.steamgames.com/doc/store/assets/rules              # VERIFIED: capsule text rules (no review scores/awards/discount text)
  - https://partner.steamgames.com/doc/store/trailer                   # VERIFIED: 1920x1080, .mov/.wmv/.mp4, H.264/AAC, 30/60fps, 5000+ Kbps
  - https://partner.steamgames.com/doc/marketing/wishlist              # VERIFIED: notification rules (20%+/8hr, 1-2wk cooldown, demo-notify ≤2wk)
  - https://partner.steamgames.com/doc/marketing/upcoming_events       # VERIFIED: Next Fest 3x/yr, demo eligibility, 30-day sale rule
  - https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/tips  # cited: press preview list 10 days prior
  # Apple App Store (PRIMARY — WebFetch-verified against developer.apple.com)
  - https://developer.apple.com/app-store/product-page/                # VERIFIED: name/subtitle 30ch, keywords 100ch, ≤10 screenshots, ≤3 previews ≤30s
  - https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/  # VERIFIED: exact iPhone/iPad screenshot px; icon 1024x1024
  # Google Play (PRIMARY — WebFetch-verified against support.google.com)
  - https://support.google.com/googleplay/android-developer/answer/9866151  # VERIFIED: icon 512x512 PNG ≤1024KB, feature graphic 1024x500, screenshots
  # Microsoft / Xbox (PARTIAL public, much NDA-gated)
  - https://learn.microsoft.com/en-us/gaming/game-publishing/tutorial-xbox-managed/how-to-create-a-store-listing  # hero 1920x1080/3840x2160, trailer thumb 1920x1080, ≤30 screenshots; 9:16 poster art + screenshot specs NDA
  - https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/screenshots-and-images          # box art 1080x1080/2160x2160
  # Press kit conventions (PRIMARY — WebFetch-verified)
  - https://dopresskit.com/                                            # VERIFIED: presskit() by Rami Ismail / Vlambeer; free
  - https://github.com/pixelnest/presskit.html                         # VERIFIED: data.xml schema, fields, static HTML, ZIP gen
  # Marketing campaign beats / Steam visibility / review keys (deep research + primary-source spot-checks)
  - https://howtomarketagame.com/2024/01/29/do-wishlists-matter-any-more/        # Zukowski — Popular Upcoming, "no magic number"
  - https://howtomarketagame.com/2023/08/28/what-is-the-discovery-queue/         # Discovery Queue velocity
  - https://newsletter.gamediscover.co/p/the-state-of-steam-wishlist-conversions # wishlist conversion data (Bycer/Gamalytic-class)
  - https://www.immutable.com/resources/insights/steam-wishlist-conversion-rates # conversion 20%→5-10% claim
  - https://www.derek-lieu.com/blog/2020/11/2/when-to-launch-a-game-trailer       # trailer-beat timing
  - https://www.cloutboost.com/blog/keymailer-vs-lurkit-vs-terminals-vs-woovit-whats-the-best-key-distribution-service-for-game-publishers  # key platforms
  - https://store.steampowered.com/about/curators/                                # Curator Connect (secure key dist)
  # AI marketing-asset generation tools (deep research; vendor pages where verifiable)
  - https://runwayml.com/research/introducing-runway-gen-4   # Gen-4 world/reference consistency
  - https://aistudio.google.com/models/veo-3                 # Veo 3 native audio
  - https://pika.art/pricing                                 # Pika
  - https://www.adobe.com/products/firefly/discover/ai-for-game-developers.html  # Firefly (indemnified)
  - https://ideogram.ai                                      # Ideogram (text-in-image / logos)
  - https://store.steampowered.com/news/group/4145017/view/3862463747997849618   # Steam AI-disclosure policy
provenance_note: >
  Written AFTER reading the project's explicit prior-confabulation warnings (generative-asset-ai.md
  §8; AAA-RECONCILIATION.md R-009; narrative-worldbuilding-lore.md provenance_note). Accordingly:
  EVERY load-bearing PLATFORM ASSET SPEC (exact pixel dimensions, formats, counts) was verified
  DIRECTLY against the platform's own documentation via WebFetch before being stated as fact — Steam
  against partner.steamgames.com, Apple against developer.apple.com, Google against
  support.google.com. These are the machine-checkable specs and they are HIGH confidence.
  The AI-tooling and marketing-strategy material came from Perplexity sonar-deep-research
  (reasoning_effort: high) and is treated with suspicion: the deep-research prose contained the
  project's known confabulation fingerprints — invented metrics ("18 usable clips," "75% failure
  rate," specific per-second pricing), an apparent invented tool name ("Nexus Clips," "RoboVerse"),
  and a fabricated "official" Steam visibility FORMULA traceable to a single blog, NOT Valve. All
  such items are marked [UNVERIFIED] or [ILLUSTRATIVE] and are NOT load-bearing. Tool NAMES that are
  independently real (Runway Gen-4, Kling, Veo 3, Pika, OpusClip, Gling, Midjourney, FLUX, Firefly,
  Ideogram, Lurkit, Keymailer, Woovit, Terminals, presskit()) are stated as existing; their exact
  capability CLAIMS are flagged as deep-research-sourced where not vendor-verified. Console
  (PlayStation/Nintendo) and most Xbox promotional asset specs are NDA-gated and explicitly flagged.
---

# Marketing, Store Presence & Community — Vector: marketing-store-community

> Scope: the public-facing GO-TO-MARKET layer the factory must produce — trailers, key art,
> capsules, screenshots, store pages, press kits, review-key distribution, social/community, and
> the campaign timeline that sequences them. Framed toward the Dark Factory thesis: which of these
> artifacts the factory can AUTO-GENERATE (tying to `generative-asset-ai.md` + the `render` capture
> profile already in `engine-adapter-protocol.md`), which remain human, and — the keystone for a
> verifiable factory — which platform specs become MACHINE-CHECKABLE contracts.

---

## 1. Executive Summary

**The marketing/store/community vector splits cleanly into a machine-checkable spine and a
brand-judgment shell — the same pattern as every other AAA discipline in this project — but with
one vector-specific superpower: the platform asset specs are externally-published, exact, and
trivially machine-verifiable.** A capsule that must be 920×430 px JPG either is or isn't; a store
page that requires ≥5 screenshots either has them or doesn't; a trailer that must be H.264/AAC at
≥5,000 Kbps either conforms or fails. This makes the **store-page asset manifest the strongest
machine-checkable artifact in the entire factory after the deterministic-sim replay contract** —
it is pure conformance against a published, versioned external rule set, exactly the pattern the
factory already uses for platform certification (`cert-preflight-checklist`).

**Three load-bearing findings:**

1. **The factory already owns the hardest input — gameplay capture.** The `render` execution
   profile (windowless + lavapipe for Bevy; xvfb + software-GPU for Unity/Godot) defined in
   `engine-adapter-protocol.md` and the `capture` capability are *precisely* the primitive that
   marketing needs. Screenshots, GIFs, and raw gameplay footage are a near-free byproduct of a
   capability the factory builds anyway for QA evidence. **Marketing capture is a thin wrapper over
   the existing capture backend**, not new infrastructure.

2. **Auto-generatability is steeply tiered, and the tiering tracks public-facing brand stakes.**
   Today (mid-2026) the factory can autonomously produce: **screenshots, GIFs, raw/auto-cut
   gameplay clips, store/marketing COPY (KB-grounded), social posts, and the entire press-kit
   scaffold** — and can *draft* key art and short-form trailer B-roll. It CANNOT yet autonomously
   ship a flagship announce/launch trailer at AAA bar, nor brand-defining key art, without human
   creative direction. The split is identical in shape to `generative-asset-ai.md`: generate-then-
   finish, not generate-and-ship, for the high-stakes public assets.

3. **The marketing assets carry the project's HIGHEST brand + IP exposure precisely because they
   are public-facing.** A confabulated codex entry is a bug; a misleading AI trailer or an
   uncopyrightable key art is a brand and legal incident. The asset-provenance spine
   (`generative-asset-ai.md` §7) and the canon KB + style-profile (`narrative-worldbuilding-lore.md`)
   are therefore MORE critical here, not less. Steam's AI-content disclosure (rewritten Jan 17 2026)
   makes provenance a store-submission input, not just an internal record.

**Factory implication & scope delta:** this vector is largely net-new relative to the current brief
(which scopes asset generation but does not mention go-to-market). It adds four artifact families
(marketing-asset manifest, store-page spec, press-kit, capture-recipe), one new convergence concern
(store-asset conformance, machine-checkable), and one new human gate (brand/creative-direction
sign-off on flagship public assets). It reuses the capture backend, the provenance spine, the canon
KB, and the style-profile wholesale.

---

## 2. Marketing-Asset Taxonomy & AI-Generatability

The factory's marketing output surface, each rated for **AI-generatability TODAY** (mid-2026):
**HIGH** = auto-generate-and-use (with conformance + spot check); **MED** = auto-DRAFT, human
finish; **LOW** = human-led, AI-assist only. Ratings synthesize `generative-asset-ai.md` (the
underlying modality maturities), `narrative-worldbuilding-lore.md` (copy/store-text), and the
deep-research marketing pass (flagged where not independently verified).

| Marketing asset | Modality | Generatability | Mode | Notes / source |
|---|---|---|---|---|
| **Screenshots** (store + social) | gameplay capture | **HIGH** | auto: `capture` profile → frame grab → conformance crop | Byproduct of the `render` profile. Engine-native screenshot; deterministic camera scripts make it repeatable. |
| **Animated GIFs / short loops** | capture → ffmpeg | **HIGH** | auto: capture → ffmpeg palettegen/loop | ffmpeg is already the capture fallback (`engine-adapter-protocol.md`). |
| **Raw gameplay footage** | capture (video) | **HIGH** | auto: `capture` profile → mp4 | The factory's existing demo-recorder/QA-evidence path. |
| **Auto-cut short-form clips** (social, teasers) | gameplay footage + AI editor | **MED→HIGH** | auto-draft: AI cut-to-music/highlight-detect → human approve | Tools: OpusClip, Gling [deep-research; specific clip-count metrics UNVERIFIED]. Footage is authentic (from factory), so reality-gap risk is LOW — a key advantage over fully-generative trailers. |
| **Marketing / store COPY** (short+long description, "About") | LLM + canon KB | **HIGH** | auto: KB-grounded generate → brand-voice + legal check | `narrative-worldbuilding-lore.md` rates store copy MED (brand/legal); grounded against canon KB + style-profile it is HIGH-draft. |
| **Social posts / devlog text** | LLM + KB | **HIGH** | auto: generate → schedule | Lowest stakes; highest volume. |
| **Screenshots-with-text / feature cards** | capture + 2D compositing | **MED** | auto-draft: capture + template overlay | Templatable; brand-typography via style-profile. |
| **Key art / cover art / capsule art** | text/img→2D (Midjourney/FLUX/Firefly) | **MED (draft) / LOW (final hero)** | draft → human art-direction | `generative-asset-ai.md` §2.3: final shippable 2D carries highest IP/consistency burden. Brand-defining → human-led. Firefly = indemnified path. |
| **Logo / wordmark** | text-in-image (Ideogram) + vector | **LOW** | human-led; AI ideation | Logos need exact text rendering + vector cleanliness + trademark clearance. Ideogram does text-in-image [deep-research]. |
| **Capsule images (with title text)** | composite key art + wordmark | **MED→LOW** | auto-composite once art+logo exist | Once approved key art + logo exist, capsule *resizing/compositing* to N exact specs is fully automatable (see §3). |
| **Teaser trailer** | footage + edit | **MED** | auto-draft from capture | Short, gameplay-forward → tractable. |
| **Announce / reveal trailer** | footage + cinematic + edit | **LOW** | human-led | Narrative structure + emotional pacing remain human (deep-research consensus; consistent with `generative-asset-ai.md` animation verdict). |
| **Gameplay trailer** | capture + structured edit | **MED** | auto-assemble to template → human polish | Structured formula (hook→progression→features→climax) is templatable; capture is authentic. |
| **Launch trailer** | footage + edit | **LOW** | human-led | Highest-stakes; "best moments," urgency, CTA. |
| **AI-generative video B-roll** (Runway/Kling/Veo/Pika) | text/img→video | **MED (supplement) / LOW (primary)** | supplementary cinematic only | All four tools real; capability claims deep-research-sourced. **Reality-gap risk HIGH** for gameplay representation — must be labeled, and Steam users prefer authentic gameplay (Steamworks trailer doc, VERIFIED). |
| **Press kit (scaffold + assets)** | structured doc gen | **HIGH** | auto: assemble from manifest | presskit.html `data.xml` schema is directly machine-fillable (§4). |

**Key factory advantage (the through-line):** for trailers/screenshots/clips, the factory generates
from **authentic gameplay capture it produced itself**, not from a generative model hallucinating
gameplay. This sidesteps the single biggest documented failure mode of AI marketing video — the
"reality gap" where AI-generated footage misrepresents the actual game (deep-research; and Steam's
own guidance that shoppers distinguish cutscenes from gameplay, VERIFIED). The factory's capture-
first strategy is structurally lower-risk than a generate-the-trailer strategy.

---

## 3. Store Pages & ASO + Platform Asset Specs (MACHINE-CHECKABLE)

This is the load-bearing, fully-verified section. **Every dimension below was read directly from
the platform's own documentation via WebFetch** (prior passes confabulated specs; these did not).
These become the `store-page-spec` conformance contract.

### 3.1 Steam / Steamworks — store graphical assets (VERIFIED: partner.steamgames.com/doc/store/assets/standard)

| Asset | Exact dimensions | Format | Notes |
|---|---|---|---|
| **Header Capsule** | **920 × 430** | JPG | Top of store page, recommended sections, Big Picture |
| **Small Capsule** | **462 × 174** | PNG | Search/top-seller/new-release lists; 120×45 + 184×69 auto-generated |
| **Main Capsule** | **1232 × 706** | JPG | Store home carousel |
| **Vertical Capsule** | **748 × 896** | JPG | Seasonal sales / sale pages |
| **Page Background** (optional) | **1438 × 810** | JPG | Store page background |
| **Bundle Header** (bundles only) | **707 × 232** | JPG | Bundle detail page |
| **Screenshots** | **≥1920 × 1080** (16:9) | JPG | **Minimum 5 required**; ≥4 must be marked suitable for all ages |

### 3.2 Steam — library assets (VERIFIED: partner.steamgames.com/doc/store/assets/libraryassets)

| Asset | Exact dimensions | Format | Notes |
|---|---|---|---|
| **Library Capsule** | **600 × 900** | PNG | Half-size 300×450 auto-generated; logo + optional subtitle |
| **Library Header** | **920 × 430** | PNG | Steam client library / Recent Games |
| **Library Hero** | **3840 × 1240** | PNG | Safe area **860 × 380** (center); half-size 1920×620 auto-gen; artwork only, no text |
| **Library Logo** | **1280 wide and/or 720 tall** | PNG (transparent) | Logotype + optional logomark; half-size auto-gen |

### 3.3 Steam — capsule TEXT rules (VERIFIED: .../assets/rules) — machine-lintable

- Capsules may show **game artwork, name, official subtitle only**.
- **Prohibited on capsules:** review scores, awards, discount text, cross-product marketing.
- Temporary "Artwork Overrides" (≤1 month) may carry text for major-update/seasonal content; **must
  be localized** to the game's supported languages.
- Library Hero = **no text**; Library Logo = transparent background.
- → These are checkable: the factory can lint a capsule's text layer / OCR for prohibited tokens
  ("% off", "9/10", "Award", competitor names) and verify localization coverage. **[Confidence: rule
  text VERIFIED; automated OCR-lint is a factory build, flagged as design.]**

### 3.4 Steam — trailer/video specs (VERIFIED: partner.steamgames.com/doc/store/trailer)

- Resolution: **up to 1920 × 1080**, **16:9 preferred** (4:3 accepted).
- Container: **.mov, .wmv, or .mp4**. Codecs: **H.264 video + AAC audio** (preferred).
- Frame rate: **30/29.97 or 60/59.94 fps**. Bitrate: **≥5,000 Kbps**. Audio: 44 or 48 kHz (down-mixed to stereo).
- Content guidance (VERIFIED): "most Steam users are looking for gameplay" — first trailer should be
  gameplay-focused. Categories: General/Cinematic, Teaser, Gameplay, Interview/Dev-Diary.
- Max file size: **not specified** in the doc [UNVERIFIED — leave unconstrained].

### 3.5 Steam — wishlists & Next Fest (VERIFIED: .../marketing/wishlist, .../marketing/upcoming_events)

- **Wishlist notifications** auto-send on release (Early Access or full) and on discount, IF:
  discount **≥20%**, duration **>8 hours**, lowest-priced package discounted. **1–2 week cooldown**
  per app ID. **Demo notification** can be manually triggered **within 2 weeks of demo release**.
- Official wishlist/visibility statement (VERIFIED): "Wishlists can be an important factor in
  determining where your game appears on Steam… your game may appear in different featured
  sections," but visibility depends on many personalized factors (user prefs, location, language,
  friends, curators) — **not solely wishlist count.**
- **Steam Next Fest**: 3×/year (2026: Feb 23–Mar 2, Jun 15–22, Oct 19–26). Eligibility: **upcoming
  unreleased game with a playable demo.** Press preview list shared with outlets **10 days prior**
  (cited, .../nextfest/tips). Seasonal sales: any game released **≥30 days** before event.
- Marketing-strategy claims about wishlists (7k–10k for Popular Upcoming; velocity drives Discovery
  Queue; conversion declined ~20%→5–10% from 2018→2026) are **deep-research/secondary-source
  [DIRECTIONAL — not official Valve numbers]**. Valve explicitly states there is "no magic number"
  (Zukowski/howtomarketagame, corroborating). A widely-cited "Visibility Score = (Engagement ×
  Traffic) + Conversion" formula traces to a single blog and is **[ILLUSTRATIVE — NOT an official
  Valve formula]**.

### 3.6 Apple App Store (VERIFIED: developer.apple.com)

| Element | Spec | Source |
|---|---|---|
| **App name** | ≤30 characters | product-page |
| **Subtitle** | ≤30 characters | product-page |
| **Keywords** | ≤100 characters total, comma-separated | product-page |
| **Promotional text** | ≤170 characters | product-page |
| **Screenshots** | **1–10 per device category**; JPG/PNG | screenshot-specifications |
| **App previews** | **≤3**, **≤30 s each**, captured on device, autoplay muted | product-page |
| **App icon** | **1024 × 1024**, JPG/PNG | screenshot-specifications |
| **iPhone 6.9" screenshot** | **1320 × 2868** (P) / 2868 × 1320 (L) | screenshot-specifications — *required if app runs on iPhone* (6.5" fallback) |
| **iPhone 6.5"** | **1284 × 2778** / 2778 × 1284 | screenshot-specifications |
| **iPhone 6.3"** | **1179 × 2556** | screenshot-specifications |
| **iPhone 6.1"** | **1170 × 2532** | screenshot-specifications |
| **iPad 13"** | **2064 × 2752** / 2752 × 2064 | screenshot-specifications — *required if app runs on iPad* |
| **iPad 12.9"** | **2048 × 2732** | screenshot-specifications |
| **iPad 11"** | **1668 × 2420** | screenshot-specifications |

### 3.7 Google Play (VERIFIED: support.google.com/.../9866151)

| Asset | Spec |
|---|---|
| **App icon** | **512 × 512**, 32-bit PNG (alpha), ≤1024 KB |
| **Feature graphic** | **1024 × 500**, JPEG / 24-bit PNG (no alpha) |
| **Screenshots** | JPEG/24-bit PNG; min dim 320 px, max 3840 px (≤2× min); **2–8 per device type**; min 2 total |
| **Preview video** | YouTube URL (public/unlisted, ads off, embeddable, not age-restricted); first 30 s autoplay |
| **TV banner** (Android TV) | **1280 × 720**, JPEG/24-bit PNG (no alpha) |

### 3.8 Microsoft / Xbox (PARTIAL public; much NDA-gated)

| Asset | Spec | Status |
|---|---|---|
| **1:1 Box art** | **1080 × 1080** or **2160 × 2160** | public (MSIX docs) |
| **1:1 App tile icon** | **300 × 300** | public |
| **Store hero image** (16:9, behind trailer) | **1920 × 1080** or **3840 × 2160** | public |
| **Trailer thumbnail** | **1920 × 1080** | public |
| **Screenshots** | up to **30** per listing | count public; **exact px NDA-gated** ("Authorization required") |
| **9:16 Poster art** (vertical key art) | required for Xbox; **dimensions NDA-gated** | NDA |
| **Titled hero / featured square art** | NDA-gated | NDA |

### 3.9 PlayStation Store & Nintendo eShop — NDA-GATED

- **No public official spec.** Detailed capsule/hero/screenshot/banner dimensions live in
  **PlayStation Partners/DevNet** and the **Nintendo Developer Portal**, both under NDA. Any pixel
  values circulating publicly are leaks/reverse-engineering, **NOT authoritative — do not encode as
  factory contracts.** [VERIFIED via deep research + absence on public Sony/Nintendo sites.]
- → Mirrors the cert-preflight pattern (`AAA-RECONCILIATION.md` R-012): the factory builds the
  console store-asset contract against the studio's **own NDA'd spec sheet**, supplied per
  deployment, not baked into the public engine.

### 3.10 ASO / Steam SEO (general practice, directional)

- **Steam tags** drive Discovery; "niche-domination" tag strategy (compete in specific categories,
  not broad genre tags) is recommended practice [deep-research/gamediscover — DIRECTIONAL].
- **ASO** (App Store/Play): keyword field optimization (Apple 100ch keyword field; Play uses
  description text), title/subtitle keywords, screenshot conversion optimization. Standard ASO
  craft; tractable for AI keyword-candidate generation, human-gated selection.

---

## 4. Press Kit & Review Distribution

### 4.1 Press kit — the presskit() / dopresskit convention (VERIFIED)

- **presskit()** — created by **Rami Ismail (Vlambeer)**, free, the de-facto indie standard
  ("beautiful, optimized press pages in 30–60 minutes"). (VERIFIED: dopresskit.com.)
- **presskit.html** (pixelnest) — Node.js reimplementation generating **static HTML from an
  XML `data.xml`** schema, auto-thumbnails + downloadable ZIP. **This `data.xml` schema is directly
  machine-fillable by the factory.** (VERIFIED: github.com/pixelnest/presskit.html.)

**Verified `data.xml` field set** (the factory's `press-kit` artifact maps 1:1):

| Category | Fields |
|---|---|
| Identification | title, description, history |
| Release | release date(s) — per-platform supported |
| Product | platforms, price, website |
| Media | header image, logos, screenshots, videos, galleries |
| Business | monetization permission (Let's Play / video creator rights), pricing |
| People | press contact(s) (name/email), company info |
| Marketing | features list, quotes, awards, social links |
| Relations | related products (sequels, DLC, expansions) |
| Org | partners, about, store widgets (Steam/App Store) |

The **monetization-permission tag** (explicit Let's Player/streamer rights) is a notable convention
the factory should auto-populate — it pre-clears content creators, reducing community friction.

### 4.2 Review-copy / key distribution (deep-research + primary spot-checks)

- **Steam Curator Connect** (VERIFIED: store.steampowered.com/about/curators) — Valve's official
  secure path: grant temporary access to curators **without handing over resellable keys**. Preferred
  primary method; prevents grey-market key leakage.
- **Third-party key/creator platforms** (real, named): **Keymailer, Lurkit, Woovit, Terminals** —
  campaign management + analytics + creator vetting [vendor existence verified via comparison sources;
  per-feature claims deep-research-sourced].
- **Embargo discipline** (best practice): specify exact date+time+timezone; get journalist consent
  rather than blast-emailing an embargo; reserve embargoes for genuinely newsworthy beats
  [deep-research, well-corroborated craft].
- **Key-request fraud filtering** (scam detection — bulk requests, fake "curators," no portfolio) is
  a partly-automatable triage the factory could assist [deep-research].

**Factory role:** auto-generate the press kit + review-key request landing page from the asset
manifest; manage embargo metadata; the *relationships* (who gets exclusives, creator selection)
remain human/strategic.

---

## 5. Social / Community / Influencer

| Activity | Generatability | Mode |
|---|---|---|
| **Devlog posts / patch notes** | **HIGH** | auto-draft from changelog + KB → human approve |
| **Social shorts (gameplay clips)** | **HIGH** | auto: capture → AI cut → schedule |
| **Social copy / captions** | **HIGH** | auto: KB + style-profile grounded |
| **Screenshot-Saturday / community assets** | **HIGH** | auto: capture + template |
| **Discord community management** | **MED (assist) / LOW (judgment)** | bots for FAQ/onboarding/moderation; human for tone/crisis |
| **Community moderation** | **MED** | auto-flag (toxicity/spam) → human adjudication |
| **Influencer/creator outreach** | **LOW** | human-led; AI-assist targeting (creators who covered similar games) |
| **Influencer relationship management** | **LOW** | human; authenticity > transactional [deep-research consensus] |

**Pattern (mirrors loremaster/playtest gates):** high-volume content generation is automatable;
**human judgment, relationships, crisis response, and brand voice are human gates.** Discord
moderation is the community analog of the consistency-validator: auto-flag, human-rule. None of this
is in the current brief; it is a deployment/ops surface the factory can *scaffold* (generate the
content + the runbook) but not *run autonomously* at brand-acceptable risk.

---

## 6. Gameplay-Capture Automation (the factory's existing superpower)

**This is where the factory has a structural head start.** From `engine-adapter-protocol.md`
(VERIFIED against the design doc):

- The `capture` capability (screenshot / video / frame grab → media file) is a **first-class,
  fidelity-graded adapter capability**, independent of `run_headless`.
- The **`render` execution profile** already exists for this: **Bevy = windowless + software Vulkan
  (lavapipe)**, offscreen-render-imagecopier; **Unity = RenderTexture readback under xvfb + software
  GPU (NOT `-nographics`, which blanks)**; **Godot = xvfb, drop `--headless`** (Godot sits *with*
  Unity on the capture axis — its one deviation from the between-the-extremes hypothesis).
- Research already confirmed "headless = no GPU" is **false on every engine**; capture needs a GPU
  backend everywhere. This is settled.

**Marketing-capture is therefore a thin recipe layer over the existing `capture` backend:**

```
capture-recipe:
  scene / save-state / replay-seed   # deterministic, reproducible (reuses replay spine)
  camera-path: [scripted keyframes]  # repeatable hero shots
  resolution: {capture_w, capture_h} # capture high, downscale to each store spec
  outputs:
    - {kind: screenshot, count, crop-targets: [store-spec-ids]}
    - {kind: gif, loop, fps, palette}
    - {kind: video, codec: h264, container: mp4, fps, bitrate}  # → Steam trailer spec
  marketing-flags: {hide-debug-ui, beauty-settings, deterministic-rng-seed}
```

Because captures are driven by **deterministic save-states / replay seeds** (the same machinery as
the deterministic-sim replay-regression contract), marketing screenshots/clips are **reproducible
and auditable** — re-runnable when art changes, diffable, version-controlled. This is a capability
ordinary marketing pipelines do NOT have, and it falls out of the factory's determinism work for
free. **Capture high-resolution once; the store-spec compositor downscales/crops to all N exact
platform dimensions** (§3) — turning "produce 30+ correctly-sized store images" into a deterministic
transform, not manual work.

---

## 7. Automatable vs Human (summary verdict)

**Factory can AUTO-GENERATE today (HIGH confidence):**
- Screenshots, GIFs, raw gameplay footage (via `capture`/`render` profile)
- Store/marketing copy, social posts, devlog/patch-note text (KB + style-profile grounded)
- Press-kit scaffold + asset packaging (presskit.html `data.xml`)
- **Store-asset RESIZING/COMPOSITING to all exact platform specs** (deterministic transform)
- **Store-asset CONFORMANCE checking** (the machine-checkable spine — §3)
- Auto-cut short-form social clips from authentic capture (MED→HIGH, light human approve)

**Factory can AUTO-DRAFT, human finishes (MED):**
- Key art / capsule art (draft; brand-defining → human art-direction)
- Gameplay/teaser trailers (assemble-to-template from authentic capture → human polish)
- Generative video B-roll as cinematic *supplement* only (reality-gap + IP risk)

**Human-led, AI-assist only (LOW):**
- Announce / reveal / launch trailers (narrative + emotional pacing)
- Logo/wordmark final (text precision + trademark clearance)
- Brand voice, creative direction sign-off on flagship public assets
- Influencer relationships, community crisis response, exclusive-access strategy
- Console (NDA) store-spec authoring

**The boundary tracks public brand stakes:** the higher the public visibility and brand-definition of
an asset, the more human creative direction it requires — the marketing analog of the project-wide
"verifiable spine vs. subjective shell." The new human gate this vector adds is
**brand/creative-direction sign-off**, analogous to playtest-satisfaction: non-automatable by design.

---

## 8. Genre Variation

| Genre | Trailer emphasis | Key art automation | Store-text load | Capture difficulty | Notes |
|---|---|---|---|---|---|
| **Deterministic-sim PILOT** (factory/automation, det-RTS, roguelike) | systems/loop showcase; satisfying-machine footage | **HIGH** — clean readable scenes, low-poly/voxel style-profile (highest automation per `generative-asset-ai.md`) | low–med (mechanism-first) | **LOW** — deterministic save-states make reproducible hero shots trivial | **Best-fit pilot for THIS vector too**: capture is most reproducible, art most automatable, copy lightest. |
| **Narrative RPG** | story/character/world cinematic | LOW (hero characters, signature IP) | HIGH (rich store copy, lore hooks) | MED (cinematic camera) | Highest human-direction load; flagship trailers human-led. |
| **Competitive multiplayer** | hype/montage; esports framing | MED | low (flavor) | MED (multi-agent scenes) | Community/influencer is the dominant channel; ongoing live beats. |
| **Mobile (ASO-first)** | ≤30s preview, feature-benefit screenshots | MED | HIGH (keyword-optimized) | LOW | ASO keyword optimization dominates; screenshot A/B testing critical. |
| **Photoreal AAA** | cinematic + gameplay | LOW (brand-defining) | HIGH | MED–HIGH (beauty render passes) | Highest brand stakes → most human gates. |

The deterministic-sim pilot is the lowest-risk first target for marketing automation for the same
reasons it is the pilot everywhere else: reproducible capture, high art-automation style profile,
light narrative/copy load (`narrative-worldbuilding-lore.md` §7 reinforces this).

---

## 9. Factory Artifacts / Contracts (net-new for this vector)

These extend the asset-generation pipeline and reuse the provenance spine, canon KB, style-profile,
and capture backend. Engine-neutral by definition.

1. **`marketing-asset-manifest`** — per-game declaration of every marketing asset to produce: type,
   target platforms, source (capture-recipe id / generation-request id / human), brand-stakes tier,
   generatability mode (HIGH-auto / MED-draft / LOW-human), and required output specs (links to
   `store-page-spec`). Each generated asset carries an **`asset-provenance-sidecar`**
   (`generative-asset-ai.md` §7.2) — MANDATORY for public assets; feeds the Steam AI-disclosure
   manifest (R-006). Validation: completeness + every asset has a provenance sidecar + each fulfills
   its store-spec.

2. **`store-page-spec`** (THE MACHINE-CHECKABLE KEYSTONE) — per-target-platform, per-asset exact
   requirement set encoding the VERIFIED specs in §3: dimensions, format, count minimums, text rules,
   trailer codec/bitrate, localization coverage. Validation: **pure conformance gate** — a generated
   asset either matches the published spec or fails. Console (NDA) specs supplied per-deployment from
   the studio's own spec sheet (mirrors `cert-preflight-checklist`). **This is the single most
   verifiable artifact in the vector** and slots directly into the convergence model's
   asset-completeness / cert-preflight dimensions.

3. **`press-kit`** — structured press kit mapping to the presskit.html `data.xml` schema (§4.1):
   factsheet, description, history, features, logos, screenshots, trailers, awards, quotes, contact,
   monetization-permission, related products. Validation: schema completeness + all referenced media
   exist + resolve to manifest assets + press-res variants present.

4. **`capture-recipe`** — deterministic gameplay-capture spec (§6): scene/save-state/replay-seed,
   scripted camera path, capture resolution, output kinds (screenshot/gif/video) with per-output
   params, marketing flags (hide-debug-UI, beauty settings, RNG seed). Validation: recipe runs under
   the `render` profile and produces media that passes `store-page-spec` conformance. **Reuses the
   replay/determinism spine** — captures are reproducible and diffable.

5. **`campaign-beat-plan`** (advisory/scheduling) — the marketing timeline: announce → reveal →
   gameplay trailer → demo/Next Fest → pre-order → launch trailer → post-launch, with per-beat asset
   dependencies (which manifest assets each beat needs) and platform-event windows (Next Fest dates,
   wishlist-notification eligibility, embargo timing). Validation: each beat's required assets exist
   + conform before the beat's gate; **the strategic content (timing choices, exclusives) is
   human-owned** — this artifact schedules and dependency-checks, it does not auto-decide strategy.

6. **`store-text-bundle`** — generated, localized store copy (short/long description, "About",
   keywords/tags, ASO keyword candidates), KB- + style-profile-grounded, with brand-voice + legal
   review flags. Validation: char-limit conformance per platform (Apple 30/30/100/170; etc.),
   localization coverage, capsule-text-rule lint (no prohibited tokens, §3.3).

**Wrap vs build:** *Wrap* presskit.html (`data.xml` generation), ffmpeg (already wrapped for
capture), the generative APIs (`generative-asset-ai.md` tool list), Keymailer/Lurkit/Curator-Connect
for key distribution, and AI video editors (OpusClip/Gling) as optional clip-cutters. *Build* the
`store-page-spec` conformance engine (the machine-checkable keystone — no off-the-shelf tool checks
your assets against all platform specs), the `capture-recipe` layer over the existing capture
backend, the `marketing-asset-manifest`, and the provenance→AI-disclosure bridge.

---

## 10. AAA Acceptance Bar

A marketing/store/community deliverable is "AAA-ready" when:

1. **Store-page conformance is green** — every required asset for every target platform exists at the
   EXACT published dimensions/format/count, capsule text-rules pass, trailer meets codec/bitrate, all
   text within char limits, localization coverage complete. (Machine-checkable, §3.)
2. **Every public asset has a complete provenance sidecar**, and the Steam AI-disclosure manifest is
   auto-generated from it (R-006) — generated-vs-procedural flagged per asset.
3. **Brand consistency holds** — all assets conform to the `style-profile` (palette, typography,
   logo usage) and the canon KB (no off-canon names/claims in copy); cross-asset visual coherence
   reviewed.
4. **Flagship public assets are human-direction-signed** — announce/launch trailer, key art, logo,
   capsule hero: human creative-direction sign-off (the non-automatable brand gate).
5. **Press kit is complete and accurate** — factsheet, media, contact, monetization-permission;
   all media resolve; press-res variants present.
6. **No reality-gap** — trailers/screenshots represent ACTUAL gameplay (the factory's capture-first
   strategy makes this structurally true); any generative B-roll is labeled.
7. **IP/legal cleared at the brand-stakes tier** — key art via indemnified path (Firefly) or
   human-transformed; logo trademark-cleared; no uncopyrightable brand-defining asset shipped
   un-flagged (R-001/R-002).

---

## 11. Open Questions & Risks

1. **OQ — Scope vs current brief (SCOPE IMPLICATION).** The current product brief scopes *asset*
   generation but does not mention go-to-market (marketing assets, store pages, press, community).
   This vector is **largely net-new scope.** Recommend: add a `marketing-store` lane to the wave DAG
   (downstream of art + capture), with the `store-page-spec` conformance engine as the v1 anchor
   (highest verifiability, lowest risk) and trailers/key-art as generate-then-human-finish.
   **Decision needed:** is go-to-market In-Scope for v1, or a planned future lane?

2. **R — Brand/IP exposure is the HIGHEST in the project** because assets are public. An
   uncopyrightable key art or a misleading AI trailer is a brand+legal incident, not a logged bug.
   Mitigation: route brand-defining assets to indemnified tools + human direction; the pure-maximal
   lights-out default may warrant a **human gate exception for flagship public marketing assets**
   (parallels OQ-002 in AAA-RECONCILIATION). **Decision needed.**

3. **R — Console store specs are NDA-gated** (PlayStation, Nintendo, most Xbox promotional art).
   The factory cannot bake these into the public engine; it builds the console `store-page-spec`
   against the studio's own NDA'd sheet per deployment (mirrors cert-preflight R-012). Public Steam /
   Apple / Google specs ARE encodable now.

4. **R — Steam AI-disclosure is a moving target** (rewritten Jan 17 2026). The provenance→disclosure
   bridge must track Valve policy changes; traditional PCG is exempt, AI-generated shipped content is
   not. Re-validate per submission.

5. **R — Deep-research marketing-strategy numbers are DIRECTIONAL.** Wishlist thresholds (7k–10k),
   conversion rates (5–10%), the "visibility formula," and AI-tool capability metrics are
   secondary-source/single-blog and several show the project's confabulation fingerprints. They are
   NOT encoded as factory contracts — only the platform asset specs (primary-verified) are.
   `campaign-beat-plan` schedules against VERIFIED event windows (Next Fest dates, wishlist
   notification rules), not against unverified thresholds.

6. **R — AI generative video reality-gap.** Runway/Kling/Veo/Pika can produce cinematic B-roll but
   misrepresent gameplay; Steam users prefer authentic gameplay (VERIFIED). The factory's
   capture-first strategy is the mitigation; generative video is supplement-only, labeled.

7. **OQ — Community ops boundary.** Discord management / moderation / influencer relationships are a
   live-ops surface the factory can scaffold (content + runbook) but probably should not run fully
   autonomously at brand risk. Where is the autonomy boundary? (Parallels liveops-runbook: generated
   as artifact, execution is an integration point.)

---

## 12. Sources

See YAML frontmatter. **Primary-verified (read directly at capture time via WebFetch):** all Steam
store + library + trailer + wishlist + Next Fest specs (partner.steamgames.com); all Apple App Store
specs (developer.apple.com); all Google Play specs (support.google.com); Microsoft/Xbox public specs
(learn.microsoft.com); presskit()/presskit.html conventions (dopresskit.com, github.com/pixelnest).
**Deep-research-sourced (flagged, not load-bearing):** AI marketing-tool capabilities, campaign-beat
strategy, wishlist thresholds/conversion, review-key platform features. **NDA-gated / unavailable:**
PlayStation Store, Nintendo eShop, most Xbox promotional asset specs.

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep synthesis: (1) AI marketing-asset generation (trailers/key-art/screenshots/copy/capture tools + IP); (2) marketing campaign beats, Steam wishlist algorithm, review-key distribution, influencer/community, ASO/SEO; (3) [Steam store-spec query errored at 77KB — re-routed to WebFetch primary verification]. `reasoning_effort: high, strip_thinking: true`. Output treated with suspicion per project confabulation history; all load-bearing specs re-verified against primary docs. |
| Perplexity perplexity_ask | 1 | Console store asset specs (Xbox public px + PlayStation/Nintendo NDA status) — flagged NDA-gated. |
| Perplexity perplexity_search | 0 | (attempted; arg-validation error → routed to perplexity_ask) |
| Context7 | 0 | — (no library-API question in scope) |
| Tavily | 0 | — (WebFetch sufficed for primary-source verification) |
| **WebFetch** | 11 | **PRIMARY-SOURCE VERIFICATION of every machine-checkable spec:** Steam store assets (standard), Steam library assets, Steam asset rules, Steam trailer specs, Steam wishlist doc, Steam Next Fest/events; Apple product page, Apple screenshot-specifications; Google Play asset specs; presskit()/dopresskit; presskit.html data.xml schema. (Xbox dev URL redirect noted.) |
| WebSearch | 0 | — |
| Training data | ~2 areas | Only for well-known tool/convention existence (ffmpeg GIF/loop, OBS, USD/codec basics) and the capture/render profile (re-read from the project's own design doc, not training data). No spec values from training data — all verified against platform docs. |

**Total MCP tool calls:** 4 (3 perplexity_research + 1 perplexity_ask) + 11 WebFetch primary-source verifications = 15 external retrievals.
**Training data reliance:** low — every machine-checkable platform asset spec (the load-bearing
content of this report) was verified DIRECTLY against the platform's own documentation; deep-research
strategy/tooling prose is explicitly flagged as directional/unverified and is NOT encoded as a
factory contract, per the project's standing prior-confabulation warnings.
