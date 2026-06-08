---
document_type: research
vector: esports-competitive-integrity
version: "1.0"
status: draft
timestamp: 2026-06-07T00:00:00Z
producer: research-agent
project_context: "game-factory = engine-agnostic (Bevy/Unity/Godot primary; Unreal deferred) lights-out Dark Factory for AAA game development, with a strong DETERMINISTIC REPLAY-REGRESSION spine and BC/VP machine-verification rigor. THIS vector covers esports / competitive integrity / tournament features — relevant ONLY to competitive-multiplayer genres (genre-gated). It maps each esports feature onto the factory's machine-verifiable spine vs operational/human shell."
inputs:
  - docs/research/aaa/engineering-disciplines.md          # netcode tiers, deterministic lockstep/rollback, determinism spine
  - docs/research/aaa/security-anticheat-trust-safety.md  # competitive integrity, anti-cheat wrap-not-build, server-authority invariants
  - docs/research/aaa/qa-testing-liveops.md               # deterministic replay-regression (PRIMARY synergy), telemetry, machine-vs-human boundary
  - docs/research/aaa/online-services-platform-distribution.md  # matchmaking/leaderboards backend (Nakama/EOS/PlayFab/GameLift FlexMatch)
  - docs/research/aaa/game-design-discipline.md           # competitive balance, frame data, design-intent-as-contract
  - docs/research/aaa/AAA-RECONCILIATION.md               # BC/VP mapping, 9-dim convergence, scope, genre strategy, risk register, R-009 confabulation lesson
  - docs/decisions/0003-determinism-tier-capability.md    # (referenced via prior docs)
sources:
  # Rating-system math (PRIMARY — papers / official public-domain docs / reference implementations)
  - "Elo, A. — The Rating of Chessplayers, Past and Present (1978); modern logistic/Bradley-Terry exposition: https://en.wikipedia.org/wiki/Elo_rating_system"
  - "Glickman, M. — The Glicko system (public domain, rev. 2016): http://www.glicko.net/glicko/glicko.pdf"
  - "Glickman, M. — Example of the Glicko-2 system (public domain; Step 5 iterative procedure corrected 2012-02-22, item 4(b) revised 2022-03-22): http://www.glicko.net/glicko/glicko2.pdf"
  - "Glicko landing (public-domain statement + reference implementations pyglicko2/Glicko2js): http://www.glicko.net/glicko.html"
  - "Herbrich, Minka, Graepel — TrueSkill: A Bayesian Skill Rating System, NIPS 2006: https://www.microsoft.com/en-us/research/publication/trueskill-a-bayesian-skill-rating-system/"
  - "Minka, Cleven, Zaykov — TrueSkill 2: An Improved Bayesian Skill Rating System, Microsoft Research tech report, 2018-03-22 (Gears of War / Halo data): https://www.microsoft.com/en-us/research/uploads/prod/2018/03/trueskill2.pdf"
  - "trueskill (Python) reference implementation + docs (mu/sigma, beta, draw margin, mu-3sigma conservative rating, match quality): https://trueskill.org"
  - "Weng, Lin — A Bayesian Approximation Method for Online Ranking, JMLR 12 (2011): https://jmlr.org/papers/v12/weng11a.html"
  - "OpenSkill (openskill.py) — Weng-Lin models BradleyTerryFull/BradleyTerryPart/ThurstoneMostellerFull/PlackettLuce: https://openskill.me"
  # Matchmaking research (PRIMARY)
  - "Chen, Xue, Kolen, Aghdaie, Zaman, Sun, Seif El-Nasr — EOMM: An Engagement Optimized Matchmaking Framework, WWW 2017 (arXiv:1702.06820): https://arxiv.org/abs/1702.06820"
  - "EOMM paper PDF (UCLA mirror): http://web.cs.ucla.edu/~yzsun/papers/WWW17Chen_EOMM.pdf"
  # Netcode / lag-comp / lockstep / rollback (PRIMARY where possible)
  - "Valve Developer Wiki — Source Multiplayer Networking (prediction, interpolation, lag compensation): https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking"
  - "Valve Developer Wiki — Lag Compensation (server rewind; LAG_COMPENSATE_BOUNDS/HITBOXES/HITBOXES_ALONG_RAY; ~1s history): https://developer.valvesoftware.com/wiki/Lag_Compensation"
  - "Bettner, Terrano — 1500 Archers on a 28.8: Network Programming in Age of Empires (GDC 2001) — deterministic lockstep canon: https://zoo.cs.yale.edu/classes/cs538/readings/papers/terrano_1500arch.pdf"
  - "GGPO (Tony Cannon, 2010) — rollback netcode; determinism + fixed timestep requirement: https://en.wikipedia.org/wiki/GGPO  and  https://www.ggpo.net"
  - "Riot Games — Peeking Valorant's Netcode / 128-tick servers (official): https://www.riotgames.com/en/news/valorants-128-tick-servers"
  - "Overwatch netcode architecture deep-dive (ECS, 16ms command frame, deterministic client replay, time dilation) — secondary analysis of Blizzard GDC material: https://edgegap.com/blog/game-backend-deep-dive-overwatch-2016-netcode-architecture-rollback"
  # Demo / spectator / observer (PRIMARY where possible)
  - "Valve Developer Wiki — Demo Recording Tools (Source .dem command/state recording): https://developer.valvesoftware.com/wiki/Demo_Recording_Tools"
  - "Valve Developer Wiki — CS:GO Spectator Tools / GOTV: https://developer.valvesoftware.com/wiki/CS:GO_Spectator_Tools"
  - "advancedfx / HLAE (Half-Life Advanced Effects) — caster/cinematic tooling: https://github.com/advancedfx/advancedfx"
  - "Broadcast delay (anti stream-sniping) general reference: https://en.wikipedia.org/wiki/Broadcast_delay"
  # Tournament / matchmaking backend (PRIMARY)
  - "Amazon GameLift FlexMatch (rule-based matchmaking) developer reference: https://docs.aws.amazon.com/gameliftservers/latest/flexmatchguide/reference-awssdk-flex.html"
  - "Nakama (Heroic Labs) matchmaking + leaderboards (engine-agnostic, self-hostable, CI-testable): https://heroiclabs.com/docs/nakama/concepts/matches/"
  - "Toornament API (bracket/tournament data): https://developer.toornament.com"
  - "Challonge API (bracket generation/progression): https://api.challonge.com/v1"
confidence: >
  HIGH on the rating-system MATHEMATICS (Elo/Glicko/Glicko-2/TrueSkill/Weng-Lin are public, fully specified, pure deterministic
  functions with provable invariants — these are the strongest BC/VP targets in the whole report); HIGH on the replay-determinism
  synergy with the existing spine (it is the SAME fixed-tick + seeded-RNG + input-injection discipline) and on the netcode-tier /
  anti-cheat ties to prior vectors; HIGH on EOMM being a real WWW-2017 paper (arXiv:1702.06820) and its actual mechanism
  (churn-minimization via minimum-weight perfect matching, 1v1); HIGH on canonical netcode primary sources (Valve lag-comp wiki,
  Age-of-Empires lockstep paper, GGPO, Riot 128-tick). MEDIUM and FLAGGED on per-title deployment specifics (CS2 "sub-tick" internals,
  Overwatch 60Hz, exact MMR-to-visible-rank formulas, smurf-detection thresholds) — these are proprietary/secondary and marked
  [UNVERIFIED]. LOW / explicitly DISCARDED: a deep-research pass confabulated specific EOMM "win-bias delta_w = +0.5..2.5%",
  a "disappointment curve" closed form, and assorted MQI/quality-decay formulas with invented constants — these are NOT in the EOMM
  paper (which minimizes churn via MWPM and fixes draw prob at 20%) and are flagged, not asserted.
research_quality_warning: >
  Consistent with R-009 (AAA-RECONCILIATION risk register), the matchmaking deep-research pass produced rich but partly
  CONFABULATED output: invented closed-form "engagement"/"disappointment" formulas, specific win-bias percentages, a "Match Quality
  Index" with made-up weights, and quality-decay constants (k≈0.025/min) attributed to platforms. The EOMM paper was checked against
  its primary source (arXiv:1702.06820 + UCLA PDF): the REAL contribution is (1) measure disengagement as churn risk, (2) model the
  waiting pool as a complete graph, (3) solve minimum-weight perfect matching — and it explicitly fixes draw probability at ~20%
  regardless of skill gap. The confabulated formulas are flagged [UNVERIFIED] throughout and NOT carried as fact. Rating-system math,
  by contrast, was cross-checked against Glickman's public-domain docs, the TrueSkill NIPS paper + TrueSkill2 MSR report (verified:
  Minka/Cleven/Zaykov, 2018-03-22), and the Weng-Lin JMLR paper / OpenSkill — these are solid.
---

# Esports, Competitive Integrity & Tournament Features — Factory Vector Research

> **Vector.** This report covers the esports / competitive-integrity / tournament surface of AAA games:
> ranking & matchmaking systems, competitive netcode quality, replay/demo systems, spectator/observer &
> director tooling, tournament infrastructure & integrity, and broadcast/streaming integration. Its central
> deliverable for the factory is the **machine-verifiable vs operational/human split**, with a specific
> emphasis on two factory-native strengths: **rating-system correctness as pure-function BCs/VPs** and
> **replay-determinism, which the factory ALREADY has** (the replay-regression spine). It is **genre-gated**:
> almost nothing here applies outside competitive-multiplayer genres.
>
> **Builds on (does not re-derive):** `engineering-disciplines.md` (netcode tiers §2.6, the
> deterministic-lockstep/rollback = "replay-regression with peers" finding); `security-anticheat-trust-safety.md`
> (server-authority invariants, anti-cheat = wrap-not-build, lockstep determinism *is* the strongest anti-cheat);
> `qa-testing-liveops.md` (§4 deterministic replay-regression — the **primary synergy**, determinism tiers T1/T2/T3,
> desync checksums, the machine-vs-human boundary); `online-services-platform-distribution.md` (matchmaking/leaderboard
> backends — Nakama/EOS/PlayFab/GameLift FlexMatch, the online-services adapter); `AAA-RECONCILIATION.md` (BC/VP
> mapping, 9-dim convergence, genre strategy, R-009 confabulation lesson).
>
> **Research-quality warning (READ FIRST).** Per R-009, a matchmaking deep-research pass confabulated closed-form
> "engagement/disappointment" formulas, win-bias percentages, and quality-decay constants. Those are flagged
> **[UNVERIFIED]** and discarded. The **rating-system mathematics** (the report's highest-value finding) were
> re-anchored to primary sources and are solid; the **EOMM** mechanism was corrected against the actual WWW-2017
> paper (churn-minimizing minimum-weight perfect matching, not a win-bias curve).

---

## 1. Executive Summary

The esports vector splits — like every AAA discipline the factory has analyzed — into a **machine-verifiable
spine** and an **operational/human shell**. What makes this vector special for *this* factory is that **two of
its highest-value features land squarely on the factory's existing strengths**:

1. **Ranking/rating systems are PURE MATHEMATICS — the single cleanest BC/VP target in the entire AAA research
   corpus.** Elo, Glicko, Glicko-2, TrueSkill/TrueSkill2, and the Weng-Lin/OpenSkill family are **fully specified,
   public, side-effect-free deterministic functions**: given current ratings + observed results + fixed parameters,
   they produce exact new ratings. They carry **provable invariants** — Elo's two-player zero-sum (rating
   conservation under symmetric K), monotonicity (beating a higher-rated opponent gains more), Glicko's RD bound
   (≤350) and "RD shrinks with play, grows with inactivity", TrueSkill's σ-contraction with information, and the
   `μ − 3σ` conservative-rating ordering. These are **exactly** the property-based-testing + (where wanted)
   formal-hardening machinery vsdd-factory already runs. A `ranking-system-contract` is the factory's bread-and-butter.

2. **Deterministic replays are a FIRST-CLASS factory artifact the factory ALREADY produces.** A competitive
   deterministic replay = bit-identical re-simulation from a recorded input stream against a fixed tick + seeded
   RNG — which is **precisely** the replay-regression spine (`qa-testing-liveops.md §4`, Decision 0003). The
   esports "deterministic demo" and the factory's "replay-regression golden master" are the **same mechanism with
   the same prerequisites**. For the T1 (Bevy+Rapier, bitwise-cross-platform) pilot, esports-grade deterministic
   replay is essentially *free*, and its correctness is machine-verifiable as **checksum/snapshot-hash equality**.

3. **Matchmaking FAIRNESS reduces to declarable invariants** (team-MMR-balance within tolerance, predicted win
   probability near 0.5, no player matched outside a skill band, visible-rank monotonic in MMR, queue-time bound),
   even though the *engagement-vs-fairness policy* (EOMM) and the *deployment parameters* are proprietary/tunable
   and partly human-decided. The factory owns the **invariant suite**; it does not own the policy choice.

4. **Competitive netcode quality ties directly into the determinism spine and the netcode tiers.** Tick-rate is a
   trivially-checkable mathematical invariant (interval = 1/tick); rollback (GGPO) and deterministic lockstep
   (Age of Empires) **require** determinism and therefore *are* the factory's strongest multiplayer fit; lag-comp
   server-rewind geometric correctness is contractable (rewind to recorded history, raycast, assert hit
   determination) but its *feel/fairness asymmetry* is a playtest concern.

5. **The operational shell stays human/wrapped, honestly flagged.** Running real esports events, casting,
   observing/directing a live booth, prize disbursement, live anti-cheat ops, and league administration are
   irreducibly operational — the same `human-gated` posture the distribution-adapter and playtest gate already use.

6. **GENRE GATE (load-bearing).** This entire vector is **OFF by default** and applies **only to
   competitive-multiplayer genres** (FPS/MOBA/fighting/RTS/BR/competitive-racing/auto-battler-ladder). The det-sim
   pilot (single-player roguelike/automation/management) touches **none** of it. The det-sim pilot's *one* natural
   intersection is **leaderboards over seed-deterministic runs** (a daily-seed roguelike ladder is pure-verifiable).

**Scope implication (one line):** make the **`ranking-system-contract` + `matchmaking-fairness-invariants` + the
deterministic-replay synergy** first-class **OPTIONAL** (competitive-genre-gated) machine-verifiable artifacts that
extend BC/VP and reuse the replay spine; keep **spectator/director, tournament-bracket math** as optional artifacts;
and keep **running events / casting / live anti-cheat ops / prize ops** explicitly **human-gated, out of v1
autonomous scope**.

---

## 2. Ranking & Matchmaking Systems (machine-specifiable math)

This is the vector's strongest fit. Every system below is a **pure deterministic function** (NIST sense: output
fully predictable from inputs; no I/O, no hidden state) — the stochasticity lives only in the *generative model*
used to *justify* the update, never in the update itself. That makes them ideal BC/VP + formal-hardening targets.

### 2.1 Elo (primary: Elo 1978; logistic/Bradley-Terry exposition)

**Spec (verified):**
- Expected score: `E_A = 1 / (1 + 10^((R_B − R_A)/400))`, with `E_A + E_B = 1`. Equivalent to a rescaled
  Bradley-Terry-Luce logistic: `Pr(i ≻ j) = σ(κ(R_i − R_j))`, `κ = ln10/400`.
- Update: `R_A' = R_A + K(S_A − E_A)`, `S ∈ {1, 0.5, 0}`.
- Elo update = a stochastic-gradient step on the BTL log-loss with step-size K. (HIGH confidence; multi-source.)

**Machine-verifiable invariants (BC/VP):**
- **Rating conservation (zero-sum):** for a 2-player game with shared K, `R_A' + R_B' = R_A + R_B` (algebraic proof;
  excellent VP / property test). 
- **Expected-score monotonicity:** `E_A` strictly increasing in `R_A − R_B` (logistic monotone).
- **Surprise monotonicity:** for fixed K and a win, gain `K(1 − E_A)` is larger when defeating a higher-rated
  opponent; loss to a weaker opponent costs more. (Derivable; testable over sampled triples.)
- **Bounds/sign:** `0 < E_A < 1`; gain sign matches `S_A − E_A`.

### 2.2 Glicko & Glicko-2 (primary: Glickman, public-domain glicko.net)

**Spec (verified against glicko.net; public domain).** Glicko adds a **rating deviation RD** (uncertainty). Per
rating period: pre-period inflation `RD ← min(√(RD_old² + c²), 350)`; with `q = ln10/400`, attenuation
`g(RD_j) = 1/√(1 + 3q²RD_j²/π²)`, expected score `E_j` logistic in `g(RD_j)(r − r_j)`; variance `d²`; update
`r' = r + (q / (1/RD² + 1/d²)) Σ g(RD_j)(s_j − E_j)`, `RD' = √(1/(1/RD² + 1/d²))`.

**Glicko-2** adds a **volatility σ** governed by **system constant τ**, on a transformed scale (`μ = (r−1500)/173.7178`,
`φ = RD/173.7178`): computes `v`, `Δ`, then solves `f(x)=0` (defined in the doc) by the **Illinois algorithm**
(regula-falsi variant, tolerance ~1e-6) to get `σ' = exp(x/2)`, then `φ* = √(φ²+σ'²)`, `φ' = 1/√(1/φ*² + 1/v)`,
`μ' = μ + φ'² Σ g(φ_j)(s_j − E_j)`. Defaults: rating 1500, RD 350, σ=0.06; τ typically 0.3–1.2.

> **NOTE (verified at glicko.net):** the Glicko-2 "Step 5" iterative procedure was **corrected 2012-02-22** (now
> stable) and item 4(b) revised 2022-03-22 (`<` → `<=`). A factory implementation MUST target the corrected version
> — this is a concrete trap a conformance test should pin.

**Machine-verifiable invariants (BC/VP):**
- **RD bound:** Glicko `RD' ≤ 350`; Glicko-2 `RD', σ' > 0` (since `σ' = exp(x/2)`). 
- **Activity monotonicity:** RD **strictly decreases** when ≥1 game is played in a period (`1/d²` adds positive
  information); RD **strictly increases** under inactivity (`√(RD²+c²)`). (Glickman states this explicitly — strong VP.)
- **Root-finding determinism:** Illinois converges deterministically given bracket + tolerance (testable: same
  inputs → same σ' to tolerance).
- **Surprise monotonicity:** intuitively holds (logistic core) but **Glickman does not state it as a theorem for
  Glicko-2** — treat as a property to *test*, not a proven invariant. [FLAG: derive-or-test, not cite.]

### 2.3 TrueSkill & TrueSkill2 (primary: Herbrich/Minka/Graepel NIPS 2006; Minka/Cleven/Zaykov MSR 2018)

**Spec (verified).** Skill `s_i ~ N(μ, σ²)` (defaults μ₀=25, σ₀=25/3); performance `p_i ~ N(s_i, β²)`; team performance
= sum of member performances; outcome = ordering of team performances with **draw margin ε**. Inference is
**Expectation Propagation on a factor graph** (Gaussian message passing + truncated-Gaussian moment matching) —
**deterministic** given a fixed message schedule. Two-player win probability (derived, not in the NIPS paper
verbatim — [FLAG derived]): `Φ((μ_i − μ_j)/√(2β² + σ_i² + σ_j²))`. **Conservative/leaderboard rating: `μ − 3σ`.**

**TrueSkill2 (verified: Minka, Cleven, Zaykov; Microsoft Research; 2018-03-22; Gears of War / Halo data, 343
Industries):** extends TrueSkill with individual stats (kills/deaths/score), **quit modeling**, **multiple game
modes** (skill correlation across modes), **squad performance boosts**, and an **experience-biased skill random
walk** (`skill_{t+L} ~ N(skill_t, γ²)`, with early-match upward bias). Adds **offline parameter learning**
(μ₀,σ₀,β,γ,τ,ε learned from history). **The online update given fixed parameters remains a pure deterministic
function.** [FLAG: TrueSkill2 closed-form win-probability expressions are NOT in the public report — keep qualitative.]

**Machine-verifiable invariants (BC/VP):**
- **σ-contraction:** σ_i strictly decreases with each conditioning game (EP intersects Gaussians). (Documented
  qualitatively; strong property test.)
- **Conservative-rating ordering:** `μ − 3σ` is non-decreasing in μ, non-increasing in σ (trivial pure-function VP).
- **Permutation equivariance:** identical players/opponents/outcomes → identical posteriors (symmetry property test).
- **Match quality = draw probability:** TrueSkill defines *match quality* as the probability of a draw (max when
  skills are balanced) — a pure function `quality(μ_i,σ_i,μ_j,σ_j,β)` and a **direct matchmaking-fairness target**.

### 2.4 Weng-Lin / OpenSkill (primary: Weng & Lin, JMLR 12, 2011; openskill.py)

**Spec (verified at structure level).** Weng-Lin derive **closed-form** Bayesian approximate updates for multi-team,
multi-player games (no numerical integration) using **Bradley-Terry** (logistic) or **Thurstone-Mosteller**
(Gaussian) likelihoods, extended to **Plackett-Luce** for full rankings. OpenSkill (`openskill.py`) ships these as
named models: `BradleyTerryFull`, `BradleyTerryPart`, `ThurstoneMostellerFull`, `ThurstoneMostellerPart`,
`PlackettLuce`. Each player is Gaussian (μ, σ); team skill = sum; updates are **pure deterministic** algebra.
OpenSkill is the **open-source, dependency-light** option — attractive as a *reference adapter* the factory can run
headless in CI and BC-test directly. [FLAG: exact per-model update equations should be pinned to openskill.py +
the JMLR paper at implementation time; library API/version churn applies — Semport-pin it.]

**Invariants:** inherits BTL/Plackett-Luce **monotonicity** (higher μ ⇒ higher predicted finish), σ-contraction
with information, and permutation equivariance — all property-testable.

### 2.5 SBMM, MMR vs visible rank, ladder/season design

- **SBMM** pools players by MMR into skill bands; **match quality** is a pure function of the rating model (e.g.
  TrueSkill draw probability, or `|PWP − 0.5|`). The **fairness math is verifiable**; the **queue-time-vs-quality
  tradeoff** and the band-widening policy are tunable/operational.
- **EOMM (verified: Chen et al., WWW 2017, arXiv:1702.06820).** The real framework: measure player **disengagement
  as churn risk** after a match; model the waiting pool as a **complete graph** (edge weight = summed churn risk if
  paired); solve **minimum-weight perfect matching (MWPM)** to pick pairings (1v1 only); it **fixes draw
  probability at ~20%** regardless of skill gap (empirical finding). It proves **equal-skill matchmaking is a
  special case** of EOMM. **[UNVERIFIED / DISCARDED]:** a deep-research pass attributed to EOMM a "win-bias
  δ_w = +0.5..2.5%", a closed-form "disappointment curve", and an "MQI" with invented weights — **none of these are
  in the paper** and are not asserted here. The factory-relevant point: even an *engagement-optimized* matchmaker
  is a **well-defined optimization** (MWPM over a churn-risk graph) whose **structural correctness** (valid perfect
  matching, no player double-booked, symmetric edge weights) is machine-verifiable; the **objective/policy**
  (fairness vs engagement) is a human/product decision.
- **MMR vs visible rank.** Hidden MMR is the continuous matchmaking value; **visible rank** (LoL LP/divisions, CS
  tiers, Valorant RR) is a **discretized, often non-linear, hysteresis-buffered function of MMR**. The
  factory-verifiable property is **monotonicity**: `dR_visible/dμ_MMR ≥ 0` under normal operation (piecewise-constant
  within divisions). The **exact mappings, promotion/demotion thresholds, LP-gain formulas, and decay rates are
  proprietary** per title — [UNVERIFIED] as specific numbers; verifiable only as *shape* invariants (monotone,
  bounded, hysteresis present).
- **Ladder/season design.** Placement matches (high-σ initial estimate, fast convergence `σ_n ≈ σ_0/√n` under
  stationarity), promotion/demotion hysteresis, **rank decay** under inactivity (RD/σ inflation — *this is literally
  the Glicko/TrueSkill uncertainty-growth invariant*), and **soft/hard seasonal resets** (σ re-inflation toward
  prior; an explicit, testable reset function). Reset *calibration* (how much to compress toward the mean) is a
  human-tuned policy; the reset *function's* properties (monotone in prior rank, bounded) are verifiable.
- **Smurf detection.** Detect high-skill players on new accounts via **performance z-score vs MMR-expected**
  (`z = (P_actual − P_expected)/σ_expected`, flag `|z| > k` over n games). The **statistical primitive is
  declarable** (anomaly threshold), but it feeds **human review**, never autonomous bans (false-positive/fairness
  risk) — exactly the posture `security-anticheat-trust-safety.md §2.2` took for telemetry-anomaly cheat signals.
  Production thresholds/features are **proprietary [UNVERIFIED]**.

---

## 3. Competitive Netcode & Fairness (tie to netcode tiers + determinism spine)

This section **defers to `engineering-disciplines.md §2.6`** (netcode tiers) and **§5** (deterministic-lockstep/
rollback = first-class multiplayer lane) and adds the *competitive-fairness* framing.

### 3.1 Tick rate — trivially machine-verifiable

Tick rate defines the simulation temporal grid: **interval = 1/tick** (e.g. 64 Hz → 15.625 ms; 128 Hz → 7.8125 ms).
This is an exact mathematical invariant — a `perf-budget`/`replay-regression` style gate can assert "fixed tick of
N Hz, no tick skips under load." **Per-title facts (primary vs flagged):**
- **Valorant 128-tick** — Riot official (riotgames.com 128-tick post; HIGH). Riot states 128-tick was chosen "to
  give defenders the time they need to react." 
- **CS2 "sub-tick"** — Valve markets sub-tick (input timestamped within a 64 Hz frame). **[UNVERIFIED internals]** —
  the "still 64 Hz infrastructure / 7.84 ms inter-packet" detail comes from community packet analysis, not a Valve
  spec. Treat *direction* (input timestamping within tick) as solid, internals as soft.
- **Overwatch ~16 ms command frame (≈60 Hz), tournament ~7 ms (≈128 Hz)** — from a secondary architecture
  deep-dive of Blizzard's GDC material (edgegap); **[FLAG secondary]**. The "20 Hz → 60 Hz upgrade" claim is
  community/secondary — flag.
- **Call of Duty/Warzone ~20 Hz** — community/secondary; **[UNVERIFIED]**.

### 3.2 Lag compensation / server rewind — geometric correctness is contractable

Valve's canonical model (Valve Developer Wiki, Lag Compensation; HIGH): the server **rewinds** to the time the
client issued the command (using its latency), retrieves historical positions (default ~**1 second** of history,
players only), and performs hit detection in that rewound frame. Modes:
`LAG_COMPENSATE_BOUNDS` / `LAG_COMPENSATE_HITBOXES` (standard) / `LAG_COMPENSATE_HITBOXES_ALONG_RAY`.
- **Machine-verifiable:** given a recorded position history + a fired ray + a latency, the rewind-and-raycast hit
  determination is a **deterministic geometric function** — a clean BC (inject history+shot, assert hit/no-hit).
  Buffer-size ⊥ max-compensatable-latency is a quantifiable property.
- **Operational/feel:** the **shooter-advantage vs peeker's-advantage asymmetry** is an inherent property of the
  model, not a bug — whether it *feels fair* is a **playtest** judgment, not a contract.

### 3.3 Rollback (GGPO) and deterministic lockstep — the factory's strongest competitive-netcode fit

- **Rollback (GGPO, Tony Cannon 2010; HIGH):** predict opponent inputs, simulate forward, and on misprediction
  **roll back to the last correct state and replay** corrected inputs. **Requires strict determinism + fixed
  timestep** — GGPO docs and every practitioner source are emphatic. This is **identical** to the factory's
  replay-regression prerequisites; rollback correctness is verifiable as **frame-checksum equality** (the same
  desync-diagnosis tooling `qa-testing-liveops.md §4.4` already specifies).
- **Deterministic lockstep (Age of Empires "1500 Archers", Bettner & Terrano GDC 2001; HIGH):** transmit **only
  inputs**, each peer re-simulates identically; commands scheduled ~2 turns ahead. **Requires perfect
  cross-machine determinism.** This is the RTS canon and maps to the **N-peer checksum-equality** contract
  (`security-anticheat-trust-safety.md §9`, `AAA-RECONCILIATION.md §8`): every peer re-simulates; divergence =
  desync **or cheat**, caught by checksum. **Lockstep determinism is simultaneously the netcode, the replay, and
  the anti-cheat** — a triple win the factory's T1 (Bevy+Rapier) tier gets essentially for free.

**Competitive-fairness invariants (machine-verifiable):** fixed-tick conformance; rollback/lockstep determinism =
N-peer bit-identical checksums; lag-comp rewind geometric determinism; regional-server assignment by lowest RTT
(a verifiable selection rule). **Operational:** actual regional server fleet provisioning, real-world latency/jitter
(wrap GameLift/AMS/Nakama), and "does the netcode feel fair" (playtest).

---

## 4. Replay / Demo Systems (PRIMARY synergy with the replay-regression spine)

**This is the headline synergy.** The factory **already has** a deterministic replay-regression harness
(`qa-testing-liveops.md §4`, Decision 0003): record inputs keyed by sim frame → replay → diff state, with
comparison tiered by `determinism_tier` (T1 exact hash / T2 pinned-runner snapshot / T3 tolerance window). An
**esports deterministic replay is the same artifact**.

### 4.1 Two replay architectures (primary: Valve Demo Recording Tools)

1. **Deterministic-input replay** (record only inputs/commands; re-simulate). Source `.dem` command recording,
   RTS/fighting replays. **Tiny files, requires determinism, supports free-camera + re-derivation.** This is
   **byte-for-byte the factory's replay-regression model.** ⇒ **STRONGEST SYNERGY.**
2. **State-snapshot/stream replay** (record periodic world-state snapshots / network stream). GOTV/`.dem`
   stream-style, Dota 2 replays. **Larger files, tolerant of non-determinism, no re-simulation needed.** This is the
   fallback for T2/T3 (non-deterministic) engines — matching the factory's `replay: none/tolerance` degradation.

**Factory mapping (declare-and-degrade):**
| Determinism tier | Esports replay form | Factory regression form (already exists) |
|---|---|---|
| T1 bitwise (Bevy+Rapier) | deterministic-input demo, free-cam, re-sim | exact snapshot-hash / golden-master |
| T2 same-machine (Unity PhysX) | input demo on pinned build, or snapshot stream | pinned-runner snapshot diff |
| T3 tolerance (Godot FP) | **must** use state-snapshot stream replay | tolerance-window metric diff |
| none | state-snapshot stream only | human-playtest evidence |

### 4.2 Machine-verifiable replay properties (BC/VP)

- **Replay determinism = re-simulation produces bit-identical state** (T1): `hash(replay(inputs)) == hash(live)`.
  *This is the existing `replay-regression-contract`, reused verbatim for the esports replay feature.*
- **Replay round-trip integrity:** record → serialize → deserialize → replay yields identical trajectory.
- **Killcam = bounded-window replay:** a killcam is a short replay seeked to a death event; correctness = "the
  killcam re-simulation matches the authoritative kill frame" (T1) — a deterministic BC.
- **Seek/scrub correctness:** for snapshot replays, seeking to time t restores the nearest-snapshot + replays
  forward deterministically.

**Operational/human:** replay *highlight selection*, *aesthetic camera work*, and "is this replay exciting" are
production judgments, not contracts.

> **Load-bearing factory implication:** the esports deterministic-replay feature is **not new work** for a T1 game —
> it is the **replay-regression spine exposed as a player/observer feature.** The factory gets competitive-grade
> demos, killcams, and "save & share replay" *for free* on the det-sim/T1 stack, with correctness already gated by
> the existing convergence dimension #2 (`tests/replay`).

---

## 5. Spectator / Observer & Director

### 5.1 The work (primary: Valve CS:GO Spectator Tools / GOTV; advancedfx/HLAE; Dota 2 spectating)

- **Observer client / GOTV:** a spectator consumes the match (relayed) with the ability to switch POVs, free-cam,
  and see information players cannot. **GOTV** (CS) and Dota 2 spectator are the canonical primary references.
- **Spectator/broadcast delay:** a deliberate time delay (commonly minutes for tournaments) between live play and
  the observed/broadcast feed to prevent **ghosting / stream-sniping**. **The delay value is a configurable,
  testable parameter** ("observed feed lags live by ≥ N seconds"); the *choice* of N is operational.
- **Fog-of-war for observers:** observers may see full or fogged state per ruleset — a **replication/visibility
  rule** identical in form to the **interest-management anti-wallhack invariant**
  (`security-anticheat-trust-safety.md §6`): "an observer at delay D sees exactly the authorized visibility set."
- **Directed / auto-director camera:** an algorithm that scores "interestingness" (proximity to objectives, fights,
  economy swings) and cuts the camera. The **camera-selection function** can be deterministic and unit-tested
  (given a world state, the director picks camera C); whether its cuts are *good TV* is operational.
- **Caster/observer HUD + cinematics:** observer HUD overlays, and cinematic tools like **HLAE** (advancedfx) for
  high-production-value captures. Mostly production tooling.

### 5.2 Machine-verifiable vs operational

| Spectator feature | Machine-verifiable property | Operational/human |
|---|---|---|
| Broadcast/observer delay | "observed feed is delayed ≥ N s vs authoritative" (testable) | choosing N; live booth ops |
| Observer fog-of-war | "observer visibility set = authorized set" (interest-mgmt BC) | ruleset policy |
| Auto-director camera | "director(state) is deterministic + returns a valid camera" | is the cut *good TV* (playtest) |
| Killcam (see §4) | bounded-window replay determinism (T1 BC) | highlight curation |
| Caster HUD / HLAE cinematics | overlay data-correctness (stats match sim) | production/casting craft |

**Verdict:** the **observer DATA layer** (delayed authoritative feed, fog rules, deterministic director selection,
HUD-stat correctness) is contractable as a **`spectator-spec`**; the **production layer** (casting, directing for
drama, cinematics) is operational/human.

---

## 6. Tournament Infrastructure & Integrity

### 6.1 Brackets = deterministic combinatorial structures (machine-verifiable)

Bracket formats are **pure combinatorics** — the factory's wheelhouse:
- **Single elimination, double elimination (winners/losers brackets), round-robin, Swiss, GSL groups** are
  deterministic structures with well-defined **progression rules** (who advances, who they meet next).
- **Seeding** (rank-based bracket placement, e.g. 1-vs-16) is a **deterministic function** of seed order; standard
  seeding avoids top-seed early collisions.
- **Verifiable properties (BC):** every participant placed exactly once; winners advance per format; losers' bracket
  fed correctly (double-elim); Swiss pairing avoids rematches and pairs equal records; round-robin schedules every
  pair once; **bracket progression is a deterministic function of match results** (replayable, auditable). Platforms
  expose this via APIs (**Challonge**, **Toornament**) — wrap targets, not build targets, but the **progression
  invariants are testable** against a reference.

### 6.2 Competitive integrity (ties to security doc)

- **Match servers / tournament & custom realms:** isolated, often anti-cheat-required match servers; **server
  authority + lockstep determinism** (§3) is the integrity backbone — and `security-anticheat-trust-safety.md` is
  emphatic that **deterministic lockstep IS the strongest anti-cheat** (every peer re-simulates; divergence =
  cheat, caught by checksum).
- **Anti-cheat for comp:** **wrap, never build** (EAC/EOS default; BattlEye; never auto-author a kernel driver) —
  defer wholesale to `security-anticheat-trust-safety.md §2`. Competitive MP shipped by the factory carries an
  explicit "wrapped client-AC + human live-ops" dependency.
- **Result integrity / audit:** because deterministic matches are **fully replayable**, the factory can offer
  **machine-auditable match results** (re-simulate the input log, assert the recorded outcome) — a genuinely strong
  competitive-integrity property that **falls straight out of the determinism spine**.

### 6.3 Machine-verifiable vs operational

| Tournament concern | Machine-verifiable | Operational/human |
|---|---|---|
| Bracket structure & progression | seeding determinism, progression correctness, Swiss/round-robin pairing invariants | bracket *format choice*, schedule logistics |
| Match-server integrity | server-authority invariants; lockstep N-peer checksum; replay-audit of results | provisioning real match-server fleets |
| Anti-cheat for comp | (none autonomous — wrap) | wrap EAC/EOS; live AC ops; ban waves |
| Prize / payouts / admin | (none) | prize disbursement, dispute resolution, league ops |
| Running the actual event | (none) | the entire live event |

---

## 7. Broadcast / Streaming Integration

- **In-game observer overlays + stats APIs:** games expose live match data (e.g. CS **Game State Integration**,
  Riot/Valve broadcast/data feeds) that drive overlays and third-party stats. **Verifiable:** "the exported stats
  feed matches authoritative sim state" (a data-correctness BC); "the GSI/stat schema is well-formed & versioned."
- **OBS / production integration:** the factory can **generate the wiring** (stats-export endpoint, overlay data
  contract, observer-feed config) as artifacts and verify their **shape/presence** — the same posture
  `qa-testing-liveops.md`/`online-services-platform-distribution.md` took for telemetry/crash wiring. The **OBS
  scene design, graphics, and live production are operational.**
- **Factory posture:** broadcast = a **`broadcast-stats-contract`** (export schema + correctness BC) that the
  factory generates and verifies; the **production/casting/graphics craft is human**.

---

## 8. Machine-Verifiable vs Operational/Human (the core deliverable)

| Esports concern | Class | Factory mechanism | Gate |
|---|---|---|---|
| Rating math (Elo/Glicko/Glicko-2/TrueSkill/Weng-Lin) | **Machine (strongest)** | `ranking-system-contract` = pure-fn BC/VP + property-based testing + formal hardening | CI gate |
| Rating invariants (conservation, monotonicity, RD/σ bounds & decay, μ−3σ ordering) | **Machine** | property tests / Kani-class proofs on pure-logic | CI gate |
| Matchmaking fairness (team-MMR balance, PWP≈0.5, skill-band, queue bound, MWPM validity) | **Machine** | `matchmaking-fairness-invariants` | CI gate |
| Visible-rank monotonic-in-MMR (shape) | **Machine (shape only)** | monotonicity property test | CI gate |
| Matchmaking *policy* (fairness vs EOMM engagement; band-widening; decay calibration) | **Human/product** | tunable policy declaration | Human decision |
| Smurf-detection statistic (z-score threshold) | **Mixed** | declarable anomaly threshold → human review | Advisory + human |
| Tick-rate conformance | **Machine** | fixed-tick invariant | CI gate |
| Rollback/lockstep determinism | **Machine** | N-peer checksum equality (reuses replay spine) | CI gate |
| Lag-comp rewind geometry | **Machine** | inject-history-raycast BC | CI gate |
| Netcode "feel fair" | **Human** | playtest | Human gate |
| Deterministic replay/demo/killcam (T1) | **Machine (already have)** | `replay-format` = replay-regression spine exposed as feature | CI gate |
| Replay highlight/camera craft | **Human** | production judgment | Human |
| Observer delay / fog / director selection (data) | **Machine** | `spectator-spec` (delay bound, fog=interest-mgmt BC, deterministic director) | CI gate |
| Casting / directing for drama / cinematics | **Human** | observer-booth ops | Human |
| Bracket seeding + progression correctness | **Machine** | `tournament-mode-spec` combinatorial BC | CI gate |
| Match-result audit (re-sim input log) | **Machine** | replay-audit (determinism spine) | CI gate |
| Broadcast stats-feed correctness | **Machine** | `broadcast-stats-contract` data BC | CI gate |
| Running events / prize ops / live AC ops / league admin | **Operational** | (wrap / human) | Out of autonomous scope |
| Client anti-cheat for comp | **Operational** | wrap EAC/EOS (per security doc) | Wrapped integration |

---

## 9. Genre Gating (load-bearing)

**This entire vector is OFF by default and applies ONLY to competitive-multiplayer genres.** It is a
genre-profile capability, not a universal one.

| Genre lane | Esports vector relevance | What the factory owns (if enabled) |
|---|---|---|
| **Fighting** | **HIGH** — rollback (GGPO), frame data, 1v1 ladder | rating BC + rollback-determinism (= replay spine) + frame-data contract + deterministic replay/killcam |
| **FPS / tactical shooter** | **HIGH** — tick-rate, lag-comp, MMR, demos, observer | fairness invariants + lag-comp geometry BC + demo (snapshot if T2/T3) + spectator-spec; **wrap client-AC** |
| **MOBA** | **HIGH** — MMR, ladder, spectator/fog, brackets | rating BC + matchmaking-fairness + spectator fog (interest-mgmt) + tournament-mode |
| **RTS** | **HIGH, IDEAL** — deterministic lockstep | lockstep = netcode + replay + anti-cheat triple (T1); rating BC; bracket math |
| **Battle royale / competitive racing / ladder auto-battler** | MED–HIGH | rating/leaderboard BC; replay; fairness invariants |
| **Det-sim PILOT (roguelike/automation/management, single-player)** | **NONE by default** | only intersection: **seed-deterministic leaderboard** (e.g. daily-seed roguelike ladder) — pure-verifiable, no MP, no AC, no observer |
| **Single-player narrative / open-world (non-competitive)** | **NONE** | — |

**Pilot implication:** the det-sim pilot deliberately **does not enter this vector**, except that a **daily-seed
deterministic leaderboard** is a *trivially pure-verifiable* optional add-on (re-simulate the seeded run, verify the
claimed score) — a cheap, on-thesis demonstration of the rating/leaderboard BC on the T1 stack **without** any
operational esports burden. The full competitive-MP esports lane is a **later, competitive-genre-gated tier**.

---

## 10. Factory Artifacts / Contracts This Vector Implies

Additive to `AAA-RECONCILIATION.md §6`; all **competitive-genre-gated** and riding declare-and-degrade.

1. **`ranking-system-contract`** *(new, the spine)* — declares the rating model (elo | glicko | glicko2 | trueskill |
   trueskill2 | weng_lin/openskill | custom) + parameters (K, c, τ, β, ε, σ₀, …) + the **machine-checkable
   invariant set** (conservation, monotonicity, RD/σ bounds, activity-decay direction, μ−3σ ordering,
   permutation-equivariance). Verified via **property-based testing + optional formal hardening** on the pure-logic
   update — the cleanest BC/VP target in the corpus. **Pins the corrected Glicko-2 Step-5** and the exact reference
   implementation (Semport-pinned: openskill.py / trueskill / glicko2 lib).
2. **`matchmaking-fairness-invariants`** *(new)* — declares & verifies: team-MMR balance within tolerance,
   predicted-win-probability band (e.g. |PWP−0.5| ≤ ε), no player matched outside skill band, queue-time upper
   bound, visible-rank monotonic-in-MMR (shape), and — if EOMM-style — **MWPM structural validity** (perfect
   matching, no double-booking, symmetric weights). The **objective/policy** (fairness vs engagement) is a declared
   *parameter*, not a verified value.
3. **`replay-format`** *(new, but REUSES the existing spine)* — the esports deterministic-replay/demo/killcam
   feature as a declared artifact: input-replay (T1) | snapshot-stream (T2/T3) | none, with **correctness =
   `replay-regression-contract`** (convergence dim #2). Adds round-trip integrity, seek/scrub determinism,
   killcam-window determinism. **This is the highest-leverage artifact: it is the replay spine exposed as a feature.**
4. **`spectator-spec`** *(new)* — observer data layer: broadcast/observer-delay bound, observer fog-of-war =
   interest-management visibility BC, deterministic auto-director camera-selection function, HUD/overlay
   stat-correctness. Verifies the **data/visibility layer**; casting/directing craft is explicitly human.
5. **`tournament-mode-spec`** *(new)* — bracket format (single/double-elim, Swiss, round-robin, GSL) + seeding
   function + **progression-correctness combinatorial BCs** (every participant placed once, advance-per-format,
   Swiss no-rematch/equal-record pairing, double-elim losers feed). Plus **match-result replay-audit** (re-simulate
   input log, assert outcome) — a determinism-spine integrity win. Wraps Challonge/Toornament for live ops.
6. **`broadcast-stats-contract`** *(new, light)* — stats-export schema (GSI-class) + "exported feed matches
   authoritative sim" data-correctness BC + overlay/OBS wiring presence. Production/casting human.
7. **`competitive-anti-cheat-integration`** *(REUSE)* — defers entirely to
   `security-anticheat-trust-safety.md §10.3 anti-cheat-integration-adapter` (wrap EAC/EOS; never build kernel AC).
   Listed here only to mark the competitive-MP dependency.

**Convergence-model tie-in:** `ranking-system-contract` + `matchmaking-fairness-invariants` +
`tournament-mode-spec` populate **sim/spec (#1)** and **security (#8-game)**; `replay-format` rides **tests/replay
(#2)** verbatim; `spectator-spec`/`broadcast-stats-contract` ride sim/spec + docs. The whole vector is an
**optional, competitive-genre-gated extension**, not a v1-universal requirement.

---

## 11. AAA Acceptance Bar

For a competitive-multiplayer AAA title in this vector:
- **Rating correctness is table-stakes and fully in factory reach:** the rating update passes its invariant suite
  (conservation/monotonicity/RD-σ bounds/decay/conservative-ordering) — property-tested, optionally formally hardened.
- **Matchmaking fairness invariants pass** for the declared model; the engagement-vs-fairness policy is a *declared,
  human-owned* parameter (the factory does not silently optimize engagement).
- **Deterministic replay/demo + match-result audit are green** on the T1 stack (= the existing replay-regression
  gate). For T2/T3, snapshot-stream replay with tier-appropriate strictness.
- **Netcode:** fixed-tick conformance; rollback/lockstep N-peer checksum equality; lag-comp rewind geometry BC.
  "Feels fair" is a **playtest** sign-off.
- **Spectator/tournament:** observer-delay/fog/director-selection BCs pass; bracket seeding+progression correct.
- **Human-gated, honestly flagged:** wrapped client anti-cheat + live AC ops; running events; casting/observing;
  prize/league ops — the factory **does not** claim to automate these.

---

## 12. Scope Recommendation

Framed as v1 / optional / deferred, consistent with the det-sim-pilot-first thesis and the existing
brief Out-of-Scope on "real-time multiplayer netcode as a shipped product feature."

### IN v1 (universal, on-thesis, near-free)
- **`ranking-system-contract` (rating math as BC/VP) — IN v1.** It is genre-universal *as a contract type*
  (any game with a leaderboard can use it), it is the **cleanest BC/VP target in the whole AAA corpus**, and a
  **seed-deterministic leaderboard for the det-sim pilot** demonstrates it end-to-end with zero MP/AC/operational
  burden. This is the single highest-ROI esports artifact for v1.
- **Deterministic replay/demo via `replay-format` — IN v1 (it already exists).** It is the replay-regression spine
  exposed as a feature; on T1 it is essentially free. **Match-result replay-audit** comes with it.

### OPTIONAL (competitive-genre-gated; enable per genre profile)
- **`matchmaking-fairness-invariants`** — optional; on when a game declares matchmaking. (Wrap the backend:
  Nakama/EOS/PlayFab/GameLift FlexMatch per `online-services-platform-distribution.md`; verify the *fairness math*.)
- **`spectator-spec`** (observer data layer) and **`tournament-mode-spec`** (bracket combinatorics + result audit) —
  optional; on for esports-targeting competitive genres.
- **`broadcast-stats-contract`** — optional; light wiring + data-correctness.
- **Competitive netcode (rollback/lockstep)** — optional, but note it is **already the first-class multiplayer lane**
  in `engineering-disciplines.md §5`; for fighting/RTS it is the natural fit and reuses the determinism spine.

### DEFERRED / OUT of v1 autonomous scope (human-gated, honestly flagged)
- **Running real esports events, casting, live observing/directing a booth, prize disbursement, league/league-ops
  administration** — irreducibly operational.
- **Live anti-cheat operations** (cat-and-mouse, ban waves) and **kernel anti-cheat authoring** — wrap-only / never
  build, per `security-anticheat-trust-safety.md`.
- **Large-scale competitive match-server fleet operation / regional provisioning** — wrap (GameLift/AMS), not build.
- **EOMM-style engagement *policy* as an autonomous objective** — the factory must NOT autonomously optimize for
  engagement over fairness; the objective is a **declared human/product decision** (ethics: R-010 dark-pattern risk).

**Net:** bring **rating-math BC/VP** and **deterministic replay** in as **v1, on-thesis, near-free** artifacts
(proved out by a det-sim seed-leaderboard); keep the rest of esports as **optional, competitive-genre-gated**
machine-verifiable artifacts that **reuse the determinism spine and the BC/VP machinery**; keep all **event/casting/
AC-ops/prize/league operations human-gated and out of v1 autonomous scope** — the same truthful posture the
playtest gate, `replay: none`, and the distribution-adapter `human-gated` tier already model.

---

## 13. Open Questions & Risks

1. **Matchmaking deep-research confabulation (HIGH — R-009 recurrence).** A pass invented EOMM win-bias percentages,
   a "disappointment curve", and an "MQI" with made-up constants. **Corrected against arXiv:1702.06820** (EOMM =
   churn-minimizing MWPM, 1v1, 20% fixed draw prob). **Anything not primary-cited here is suspect**; rating-system
   *math* is the trustworthy core, deployment *parameters* are proprietary/[UNVERIFIED].
2. **Per-title netcode/rank specifics are proprietary/secondary (MEDIUM).** CS2 sub-tick internals, OW2 60Hz, exact
   MMR→visible-rank formulas, LP-gain curves, decay rates, and smurf-detection thresholds are **vendor-opaque** —
   verifiable only as *shape* invariants (monotone, bounded, hysteresis present), not specific numbers.
3. **Glicko-2 corrected Step-5 trap (LOW but concrete).** Implement the **2012-02-22 corrected** iterative
   procedure (and 2022 item-4(b) revision); a conformance test must pin this or risk an unstable volatility update.
4. **Floating-point determinism is the gating risk for esports replay (MEDIUM, inherited).** Esports deterministic
   replay/rollback/lockstep inherit **exactly** the FP-determinism constraints of the replay spine (Decision 0003,
   `qa-testing-liveops.md §4.3`): fixed-point or pinned FP for sim-critical math, seeded RNG, hash-order control.
   T1 (Bevy+Rapier) gets bitwise replay; T2/T3 must fall back to snapshot-stream replay (no re-sim).
5. **Smurf detection / engagement optimization carry ethics + fairness risk (MEDIUM).** Anomaly thresholds feed
   **human review, never autonomous bans**; engagement-as-objective is a **dark-pattern hazard** (R-010) and must be
   a declared human decision, not a factory default.
6. **Competitive MP pulls in the whole operational shell (MEDIUM).** Even with the verifiable spine owned, shipping
   competitive esports drags in client-AC, live ops, event ops, and the Linux/Deck anti-cheat dilemma
   (`security-anticheat-trust-safety.md §2.3`). Hold the v1 line at **rating-math + deterministic-replay +
   seed-leaderboard**; gate the rest behind explicit competitive-genre opt-in.
7. **Library/version churn (LOW, Semport).** openskill.py / trueskill / glicko2 implementations and netcode crates
   move; pin versions and re-verify per release (each is scheduled adapter maintenance).

---

## 14. Sources

See YAML frontmatter for the full list. Primary/authoritative anchors by claim class:

- **Rating math (PRIMARY):** Glickman public-domain Glicko + Glicko-2 docs (glicko.net — verified public-domain
  statement + corrected Step-5 dates); TrueSkill NIPS 2006 (Herbrich/Minka/Graepel); **TrueSkill 2 MSR report
  (verified: Minka, Cleven, Zaykov, 2018-03-22, Gears/Halo data)**; Weng-Lin JMLR 2011 + OpenSkill; Elo
  (logistic/Bradley-Terry exposition).
- **Matchmaking (PRIMARY):** **EOMM verified — Chen, Xue, Kolen, Aghdaie, Zaman, Sun, Seif El-Nasr, WWW 2017,
  arXiv:1702.06820** (churn-minimizing minimum-weight perfect matching; 20% fixed draw prob; equal-skill is a
  special case). TrueSkill match-quality = draw probability (trueskill.org).
- **Netcode (PRIMARY where possible):** Valve Developer Wiki (Source Multiplayer Networking; Lag Compensation —
  server rewind, ~1s history, compensate modes); Age of Empires "1500 Archers" GDC 2001 (deterministic lockstep);
  GGPO (rollback; determinism + fixed-timestep requirement); Riot 128-tick (official). CS2 sub-tick internals /
  OW2 60 Hz / CoD 20 Hz — **secondary/community, flagged**.
- **Replay/spectator (PRIMARY where possible):** Valve Demo Recording Tools; CS:GO Spectator Tools / GOTV;
  advancedfx/HLAE; broadcast-delay reference.
- **Tournament/backend (PRIMARY):** GameLift FlexMatch; Nakama matchmaking/leaderboards; Challonge/Toornament APIs.

**Cross-references (in-repo, built upon, not contradicted):**
`docs/research/aaa/engineering-disciplines.md` (§2.6 netcode tiers, §5 lockstep/rollback = replay-with-peers),
`docs/research/aaa/security-anticheat-trust-safety.md` (§2 anti-cheat wrap-not-build, §6 server-authority +
interest-management invariants, §9 lockstep = strongest anti-cheat),
`docs/research/aaa/qa-testing-liveops.md` (§4 deterministic replay-regression — PRIMARY synergy, determinism tiers,
desync checksums), `docs/research/aaa/online-services-platform-distribution.md` (matchmaking/leaderboard backends),
`docs/research/aaa/game-design-discipline.md` (competitive balance / frame data),
`docs/research/aaa/AAA-RECONCILIATION.md` (BC/VP §4, convergence §7, genre strategy §11, R-009 / R-010 §12).

---

## Research Methods

| Tool | Queries | Purpose |
|------|---------|---------|
| **Perplexity perplexity_research (PRIMARY)** | 3 | Deep passes (reasoning_effort: high, strip_thinking): (1) rating-system MATHEMATICS — Elo/Glicko/Glicko-2/TrueSkill/TrueSkill2/Weng-Lin/OpenSkill formulas, primary sources, pure-function/invariant analysis [USED, solid]; (2) competitive NETCODE + REPLAY/DEMO + SPECTATOR — tick rate, lag-comp, rollback/lockstep, demo architectures, observer/director [USED, primary-anchored]; (3) MATCHMAKING + tournament/broadcast — SBMM/EOMM/MMR-vs-rank/smurf/ladder + brackets + broadcast [USED WITH CORRECTION — confabulated EOMM formulas flagged/discarded] |
| Perplexity perplexity_reason | 0 | — |
| Perplexity perplexity_search | 1 | Primary-source verification of EOMM (arXiv:1702.06820, WWW 2017, authors, MWPM mechanism, 20% draw prob) + TrueSkill match-quality=draw-probability |
| Perplexity perplexity_ask | 0 | — |
| Context7 | 0 | — (rating-system math is in papers/public-domain docs, not library-API depth; openskill.py/trueskill APIs to be Context7-pinned at implementation time) |
| Tavily tavily_extract | 1 | Primary-source verification: TrueSkill 2 MSR PDF (confirmed authors Minka/Cleven/Zaykov, 2018-03-22, Gears/Halo, skill random-walk eqns) + glicko.net (confirmed public-domain + corrected-Step-5 dates) |
| Tavily tavily_search | 0 | — |
| WebFetch | 2 | Attempted Glicko-2 PDF (compressed binary — fell back to prior verified math) + TrueSkill2 MSR page (404 — recovered via Tavily-extract of the PDF) |
| WebSearch | 0 | — |
| Repo files (Read) | 6 | Grounded against engineering-disciplines, security-anticheat, qa-testing-liveops, online-services, game-design, AAA-RECONCILIATION — to map every esports feature onto the existing BC/VP + replay-spine + netcode-tier + anti-cheat framing |
| Training data | ~2 areas | Rating-system + netcode taxonomy framing and the machine-vs-operational split structure — every load-bearing formula/claim re-anchored to a primary source or explicitly flagged [UNVERIFIED] |

**Total MCP tool calls:** 5 (3 perplexity_research + 1 perplexity_search + 1 tavily_extract) + 2 WebFetch (verification) = 7 grounded calls
**Training data reliance:** low — rating-system mathematics verified against Glickman public-domain docs / TrueSkill
NIPS + TrueSkill2 MSR (author-verified) / Weng-Lin JMLR / OpenSkill; EOMM corrected against arXiv:1702.06820; netcode
anchored to Valve wiki / Age-of-Empires paper / GGPO / Riot. **Confabulation caught and discarded:** a matchmaking
pass invented EOMM win-bias percentages, a "disappointment curve", and MQI/quality-decay constants — flagged
[UNVERIFIED] and replaced with the primary-verified MWPM/churn-minimization mechanism. Per-title deployment specifics
(CS2 sub-tick internals, OW2 60Hz, exact rank formulas, smurf thresholds) are flagged proprietary/secondary.
