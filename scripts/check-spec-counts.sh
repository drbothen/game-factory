#!/usr/bin/env bash
# check-spec-counts.sh — Spec count consistency checker (S2-02) v1.30
#
# PURPOSE
# -------
# Prevent recurring count-drift across the spec layer. Twelve classes of drift
# are checked (extended in v1.2 to cover Pass-3 adversarial defect classes;
# extended in v1.3 to cover Pass-4 VP catalog consistency;
# extended in v1.4 to cover Pass-5 studio §3 appearance counts, subsystem
# priority subtotals, and formal VP ↔ BC bidirectional anchor):
# extended in v1.5 to fix false-green in check (i) (I6-01) and add check (k);
# extended in v1.14 to extend check (k) with label-match sub-check (k.ii) —
# for E-EAP and E-OSVC families: asserts BC parenthetical label is non-
# contradictory with registered taxonomy category/name (C14-02 recurrence
# prevention). Also adds check (o) — seam-count consistency: FAIL if any
# scoped spec file contains stale "four adapter seam" / "four-seam adapter"
# in operative content (O14-01 recurrence prevention). POSIX/BSD compatible.
# extended in v1.15 to add check (p) — cross-reference ID/description
# consistency: for each Related-BCs citation of a SS-06 dimension-owner BC
# (BC-7.01.001..BC-7.11.001), assert the inline description does NOT contain a
# distinctive compound dimension keyword that maps to a DIFFERENT dimension owner
# than the one cited. Catches the CI false-green class exposed in Pass-15 (e.g.,
# BC-7.05.001 cited with "Cert Pre-Flight" description; BC-7.07.001 cited with
# "playtest-satisfaction" description). Scope limited to SS-06 dimension-owner
# citations to avoid false positives on legitimate paraphrases. (P15-01
# recurrence prevention). POSIX/BSD compatible.
# extended in v1.16 to add check (a.ii) — BC-INDEX per-capability section-header
# count consistency: for each H2 capability header of the form
# "## CAP-0NN — <name> — N BCs", parse the stated N, then count the actual
# "| BC-NN.NN.NNN |" rows in that capability's section table (up to the next
# "## " header). FAIL if stated header N != counted rows. Optionally also
# cross-checks the Summary table BC-Count cell (first integer in field 4 of the
# matching "| CAP-NNN" row) for triple consistency. Catches the P16-01 process-
# gap class: stale per-capability header counts that survive grand-total checks
# unchanged (e.g., CAP-007 "12 BCs" above 19 rows; CAP-015 "11 BCs" above 12
# rows). Positive-coverage log: "Check (a.ii): N capability section headers
# validated." POSIX/BSD-awk/grep compatible (no grep -P). (P16-01 recurrence
# prevention).
# extended in v1.17 to add check (a.iii) — alternate-phrasing BC grand-count
# consistency: scans prd.md, subsystem-decomposition.md, and ARCH-INDEX.md for
# operative statements of the BC grand total using alternate prose phrasings:
# "all N behavioral contracts", "N behavioral contracts have been assigned",
# "all N BCs" (non-historical context), "N behavioral contracts assigned". For
# each match, asserts the stated N equals the computed BC file count. Seven
# false-positive exclusion rules skip changelog table rows (lines starting |),
# blockquote lines (starting >), YAML reason: lines, lines containing
# "pre-v[0-9]", transition delta lines ("[0-9]+→" or "→[0-9]"), and historical
# backfill notes containing "backfilled". Positive-coverage log: "Check (a.iii):
# N alternate-phrasing BC-count statements validated." (P17-01 recurrence
# prevention). POSIX/BSD compatible.
# extended in v1.18 to add check (a.iv) — per-capability PRD BC totals + NFR
# total consistency: closes the recurring class of stale count-summary lines in
# prd-supplements that check (a) / (a.ii) / (a.iii) do not cover.
# extended in v1.19 to add check (q) — per-dimension allowed-value prose
# restatement guard (P19-01 recurrence prevention): scans methodology-layer.md
# for inline prose restatements of a dimension's allowed-value set — patterns
# like "D-<DIM> allows <TOKEN>/<TOKEN>/..." or "(D-<DIM> allows ...)". Any such
# line OUTSIDE the §3.1 canonical table is flagged as a restatement that must
# not diverge from §3.1. The check compares the token set on the flagged line
# against the canonical allowed set for that dimension (parsed from §3.1), and
# FAILs if any token is missing or extra. Convention: do not restate per-dimension
# allowed-value subsets in prose outside §3.1; reference §3.1 by name instead.
# POSIX/BSD-grep/awk compatible (no grep -P). Positive-coverage log always
# printed. Calibrated to be green after the F1 fix in methodology-layer.md v1.7.
# extended in v1.20 to add check (r) — error-family reverse coverage (Pass-20
# adversarial / orchestrator-sweep recurrence prevention): for every non-retired
# error family registered in error-taxonomy.md, asserts that at least one
# behavioral-contract file cites at least one code from that family.  Retired
# families (currently only E-GEN, detected via strikethrough markup) are
# explicitly excluded so they never trigger a false failure.  Any non-retired
# family with ZERO BC citations is an orphan and causes a FAIL.  POSIX/BSD-grep
# compatible. Positive-coverage log always printed. WILL FAIL until the PO
# reconciles E-KB / E-PLAY / E-REPLAY (families registered but not yet cited by
# any BC); becomes green automatically after PO work.
# extended in v1.21 to add check (s) — §3.1 cross-table consistency (Pass-23
# I23-01 recurrence prevention): parses BOTH §3.1 tables in methodology-layer.md
# and asserts, for each of the 4 canonical status values (GREEN, DEGRADED,
# DEGRADED-PENDING, BLOCKED), that the set of dimensions listed in the
# "Applicable Dimensions" cell of the Canonical Status-Value Enum table (A)
# exactly equals the set of dimensions that include that value in the
# Per-Dimension Allowed Value Subsets table (B). FAIL lists any mismatch as:
# "status value V: dimension D in table (B) but not table (A)" or vice versa.
# Closes the intra-§3.1 contradiction class which check (q) (prose restatement)
# and check (n.ii) (BC usage enforcement) do not cover — they both consume
# table (B) but neither compares table (A) against table (B). POSIX/BSD-awk
# compatible. Positive-coverage log always printed. Green after the I23-01 fix
# in methodology-layer.md v1.8.
# extended in v1.22 to add check (t) — BC-7.* owner-attribution guard (Pass-24
# I24-01 recurrence prevention): initial version matched two narrow compound
# patterns: "dimension-owner (SS-0" and "owner BCs (SS-0".
# extended in v1.23 (Pass-27 I27-01 recurrence prevention): BROADENED to cover
# the full mislabel class. Trigger: any operative line containing "dimension owner"
# or "dimension-owner" (space OR hyphen, case-insensitive). On triggered lines:
#   (t.i)  Any BC ID must be a valid dimension-owner BC (BC-7.0[1-9].001,
#          BC-7.10.001, BC-7.11.001). Non-owner BC (BC-8.*, etc.) named as
#          dimension owner FAILS.
#   (t.ii) If any SS-NN appears but SS-06 is absent, FAILS (non-SS-06 in
#          owner-attribution context without the correct SS-06 also named).
#   (t.iii) Retained: "owner BCs (SS-0X" where X != 6 compound pattern.
# Blockquote lines (">") excluded throughout. Calibrated: line 657 correct
# (SS-06 + BC-7.* — passes); producer table (no "dimension owner" — not triggered);
# per-dimension "Subsystem:" headers (no "dimension owner" — not triggered).
# Would have caught pre-fix line 714 (BC-8.08.004 named as dimension owner with
# SS-07 and no SS-06 on the line). POSIX/BSD-grep compatible.
# Positive-coverage log always printed. Green after I24-01 + I27-01 fixes.
# extended in v1.24 to add check (u) — human-gated / creative-gate term-misuse
# guard (Pass-28 I28-01 recurrence prevention):
# CANONICAL RULE (methodology §2.8 / ADR-0007): the `directed:true`
# cinematic-director creative sign-off is an INTERNAL creative gate (E-CIN-003,
# D-013). It MUST NOT use `human-gated` fidelity-tier vocabulary, which is
# reserved for EXTERNAL third-party acts (SAG-AFTRA consent, console cert sign-off,
# store publish, legal review). DI-007 is the PLAYTEST gate (BC-8.08.*/7.05.001),
# not the cinematic creative gate. The check scans all BC files.
#
# TRIGGER: an operative line that contains a human-gated vocabulary term AND a
# creative-gate context keyword in proximity (same line).
#
#   Human-gated vocabulary (any of):
#     "human-gated", "human-gate task", "HumanGatedTaskPending", "-32008", "DI-006"
#
#   Creative-gate context keywords (any of):
#     "cinematic-director" (bare agent name next to a gating verb)
#     "cinematic" + "sign-off" on the same line
#     "creative sign-off" / "creative-gate" / "creative gate"
#     "directed: true" / "directed:true"
#
# EXEMPTION: if the same line also contains an external-act keyword, it is a
# LEGITIMATE human-gated line and PASSES even if creative-gate keywords also appear.
#   External-act exemption keywords:
#     "SAG-AFTRA", "consent", "likeness", "console cert", "store publish",
#     "legal review", "legal-review"
#
# EXCLUSIONS (suppress the line from triggering):
#   - Lines starting with ">" (blockquote / changelog annotation lines)
#   - Lines containing "reason:" (YAML frontmatter lifecycle prose)
#
# FALSE-POSITIVE AVOIDANCE:
#   The external-act exemption is intentionally broad: any line naming
#   "SAG-AFTRA", "consent", "likeness", "console cert", "store publish",
#   or "legal review" is a legitimate external-act human-gated line and is
#   skipped — even if it also mentions "cinematic-director" as context.
#   Per-dimension "Subsystem:" headers and prose that mentions cinematic-director
#   in a non-gating role (e.g., "produced by cinematic-director") do NOT contain
#   human-gated vocabulary and therefore do NOT trigger this check.
#   DI-006 citations in the Traceability table's "L2 Domain Invariants" row
#   are excluded if the row also names an external act; if the row cites DI-006
#   without any creative-gate keyword on that line it does not trigger either.
#
# POSITIVE-COVERAGE LOG:
#   "Check (u): N BC lines scanned for human-gated/creative-gate term misuse,
#    K creative-gate-context lines validated."
#
# KNOWN MISLABELS CAUGHT (before PO fix):
#   BC-5.06.001 line 71:  "A `human-gated` sign-off task is surfaced"
#     (cinematic-director + human-gated, no external-act exemption) → FAIL
#   BC-7.04.001 line 64:  "sign-off is a `human-gated` task (DI-006)"
#     (directed:true + cinematic-director + human-gated, no external-act) → FAIL
#   BC-7.04.001 line 94:  "DEGRADED; human-gated task emitted for cinematic-director"
#     (cinematic-director + human-gated, no external-act) → FAIL
#   BC-7.05.001 line 92:  "Cinematic sign-off is a separate human-gated task (DI-006)"
#     (directed:true + cinematic sign-off + human-gated, no external-act) → FAIL
#   BC-12.12.008 line 90: "`human-gated` production artifact (e.g. cinematic script
#     signed off by `cinematic-director`)" (cinematic-director + human-gated,
#     no external-act) → FAIL
#
# WILL FAIL until PO completes fixes in BC-5.06.001, BC-12.12.008, BC-7.04.001,
# BC-7.05.001. Becomes green automatically after PO work.
# POSIX/BSD-grep/awk compatible (no grep -P).
# extended in v1.25 to extend check (o) with sub-check (o.ii) — Canon-KB
# load-bearing-seam ordinal guard (Pass-31 I31-01 recurrence prevention):
# CANONICAL RULE (ADR-0004 / product-brief §Overflow Context): the Canon
# Knowledge-Base is the SIXTH load-bearing seam. There are five adapter seams
# (engine/asset/distribution/XR/online-services); Canon-KB follows as the sixth.
# The check scans all architecture/*.md, domain-spec/*.md, prd.md,
# prd-supplements/prd-cap-*.md, and product-brief.md for operative lines (excl ">"
# blockquote / "reason:") that apply any ordinal OTHER than "sixth" to the phrase
# "load-bearing seam". FAIL on "fifth load-bearing seam" or any other wrong ordinal.
# "sixth load-bearing seam" passes silently. Sub-assertion (o.ii.b): lines that
# attribute a non-sixth ordinal to the product-brief are flagged as false citations
# (the brief at line 111 says "sixth"). Positive-coverage log always printed.
# WILL FAIL until PO fixes capabilities.md and prd-cap-008-012.md; architect files
# must be clean after this pass. POSIX/BSD compatible.
# extended in v1.26 to:
#   (1) Fix O-PASS32-02: correct v1.24 check (u) comment text — the cinematic
#       creative gate's invariant is "E-CIN-003, D-013" (NOT "DI-007"). DI-007 is
#       the PLAYTEST human gate (enforcer set: BC-8.08.004, BC-7.05.001, BC-8.08.005).
#       All occurrences of "E-CIN-003, DI-007" / "E-CIN-003; invariant: DI-007" in
#       check (u) comments and fix messages have been corrected to reference D-013.
#   (2) Add check (w) — DI-007-on-creative-gate mis-anchor guard (I-PASS32-01
#       recurrence prevention): scans BC bodies for OPERATIVE lines that cite DI-007
#       IN PROXIMITY to a CINEMATIC-CREATIVE-GATE context keyword (cinematic-director,
#       D-013, E-CIN-003, directed:true/directed: true, "creative gate", "creative
#       sign-off", "creative-gate"). DI-007 (the playtest invariant) MUST NOT be
#       cited for the cinematic creative gate. Legitimate DI-007 usages (playtest
#       contexts: "playtest", "fun-score", "playtest-satisfaction", BC-8.08.*, BC-14.*)
#       do NOT contain these cinematic-creative-gate keywords and do not trigger.
#       Blockquote (">") and "reason:" lines excluded. Positive-coverage log always
#       printed. WILL FAIL until PO removes 4 DI-007 cinematic grafts; becomes green
#       automatically after PO work. POSIX/BSD compatible. (I-PASS32-01 recurrence
#       prevention).
# extended in v1.27 to add check (x) — prd.md §4 NFR-table ID-set parity
#   (F33-01 recurrence prevention): parses the set of NFR IDs that appear as rows in
#   the prd.md §4 NFR summary table ("| NFR-NNN …" lines) and the set of NFR IDs
#   registered in nfr-catalog.md (the authoritative catalog; "| NFR-NNN …" rows).
#   ASSERTS the two ID sets are EQUAL (same membership). Reports IDs present in the
#   catalog but missing from the prd.md §4 table (dropped NFRs), and IDs present in
#   the prd.md table but not in the catalog (phantom NFRs). This is stronger than
#   check (a.iv) SUB-CHECK 2 which only checks the *count* (41); check (x) asserts
#   *set membership parity* so a future CAP's NFRs cannot be silently dropped from
#   the prd.md summary view even if the count prose is separately (in)correct.
#   Currently both sets are {NFR-001 .. NFR-041} (41 members) — PASSES after F33-01
#   fix (prd.md v2.4). POSIX/BSD-grep/awk compatible (no grep -P).
# extended in v1.28 to:
#   (1) Broaden check (u) — human-gated/creative-gate term-misuse guard (F34-01
#       recurrence prevention): BROADENED scan corpus from BC-files-only to
#       BC files + ALL architecture/*.md files (flat + adrs/ subdir, incl.
#       studio-of-agents.md). The F34-01 process-gap showed the prior BC-only scan
#       missed studio-of-agents.md:157's "`directed:true` = human-gated" roster
#       table-cell because that file is an architecture doc, not a BC file.
#       After the F34-01 content fix, this must report 0 violations.
#       Updated check (h) expected values: SS-03 16→15, SS-04 23→24 (F34-02).
#   (2) Add check (y) — seam-ordinal collision guard (F34-03 recurrence
#       prevention): asserts NO operative line labels the distribution adapter
#       as the "fifth" seam (it is the third), and asserts "fifth seam" co-occurs
#       ONLY with online-services context. Canonical ordering (ADR-0004/D-017):
#       engine=1, asset=2, distribution=3, XR=4, online-services=5. Green after
#       PO's prd-cap-009-010.md v1.1 fix ("third of the five adapter seams").
#       POSIX/BSD compatible. (F34-03 recurrence prevention).
# extended in v1.29 to add check (z) — §1.3 base manifest seam-enum completeness
#   (F35-01 recurrence prevention): parses the `seam` field enum literal in the §1.3
#   base Capability Manifest fenced schema block of adapter-protocols.md, then parses
#   the seam-key set from the §8 Compatibility Matrix fenced schema block (the
#   authoritative per-seam "seams": { … } keys). ASSERTS the two token sets are EQUAL
#   (both must be exactly: engine-adapter, asset-adapter, distribution-adapter,
#   xr-adapter, online-services-adapter — 5 tokens). Reports tokens present in the
#   compatibility matrix seams but missing from the §1.3 base enum, and vice versa.
#   Anchoring: §1.3 enum is parsed from the first fenced block that contains a
#   `"seam":` line with `<…>` angle-bracket syntax; seam keys are parsed from the
#   "seams": { … } object in the last fenced block of the file (which is §8).
#   Positive-coverage log always printed. Green after F35-01 fix.
#   POSIX/BSD-grep/awk compatible (no grep -P). (F35-01 recurrence prevention).
# extended in v1.30 to add check (aa) — frontmatter traceability path existence
#   guard (O36-01 recurrence prevention): scans ALL .factory/specs files that carry
#   frontmatter `inputs:` and/or `traces_to:` YAML list keys (VP files, BC files,
#   ADRs, and any other spec file using these keys). For each path value listed
#   under these keys that starts with ".factory/" (workspace-relative), strips any
#   "#fragment" suffix and parenthetical annotations, then asserts the path resolves
#   to an existing filesystem entry (file OR directory; directory paths with trailing
#   "/" are valid inputs: entries). Reports each unresolved (path, source-file) pair.
#   Generalizes F36-01: catches ANY frontmatter traceability path pointing at a
#   non-existent artifact — the subsystem dir-vs-alias hazard and typos. Positive-
#   coverage log always printed. Paths NOT starting with ".factory/" (bare filenames,
#   external URLs, symbolic references) are silently skipped (not workspace-relative).
#   POSIX/BSD-awk compatible (no grep -P). (O36-01 recurrence prevention).
# Inventory: checks a, a.ii, a.iii, a.iv, b, c, d, e, f, g, h, i, j, k, k.ii,
#   l, m, m.ii, n, n.ii, n.iii, o, o.ii, p, q, r, s, t, u, w, x, y, z, aa + o.ii.
#   Positive-coverage log always printed. (O36-01 recurrence prevention).
#
# SUB-CHECK 1 — PER-CAP PRD BC TOTALS:
#   Scans all .factory/specs/prd-supplements/prd-cap-*.md for lines matching:
#     "Total CAP-NNN BCs: N"   (primary form)
#     "Total CAP-NNN BCs ...: N"  (with annotation suffix)
#   Extracts the CAP-NNN identifier and the stated count N. Sources the
#   authoritative per-cap count by parsing BC-INDEX.md "## CAP-NNN — <name> — N BCs"
#   headers (which check (a.ii) already validates against actual row counts, so
#   they are trustworthy). FAIL lists any supplement line whose stated per-cap
#   total ≠ the BC-INDEX authoritative count.
#   NOTE: "Total BCs in this batch: N" is treated as an obsolete phrasing; any
#   such line is flagged as unresolvable (ambiguous capability mapping) and
#   reported as an advisory, not a hard failure — PO should migrate to the
#   canonical "Total CAP-NNN BCs: N" form.
#   False-positive exclusion: skip lines starting with "|" (changelog version
#   table rows), ">" (blockquote), or containing "reason:"; require literal
#   words "BCs" so error-code / NFR counts do not match.
#
# SUB-CHECK 2 — NFR TRIPLE CONSISTENCY:
#   (i)  Parse nfr-catalog.md "Total NFRs in this catalog: N" summary line.
#   (ii) Count actual "^| NFR-NNN" rows in nfr-catalog.md (the table rows).
#   (iii) Parse prd.md's inline NFR count statement of the form
#         "(N NFRs, NFR-001 through NFR-NNN)" (the parenthetical in §4 prose).
#   Asserts all three agree: rows == catalog summary == prd.md statement.
#   False-positive exclusion: prd.md parse anchors to "NFRs, NFR-001 through"
#   so changelog rows ("19 NFRs" in version table, "+16 NFRs" delta notes)
#   do not match.
#
# POSITIVE-COVERAGE LOG: "Check (a.iv): N per-cap PRD BC totals + NFR total
# validated." always printed.
# POSIX/BSD-grep/awk compatible (no grep -P). (P18-01 recurrence prevention).
# extended in v1.6 to add check (l) — disclosure_class closed-enum consistency
# (F8-01 recurrence prevention);
# extended in v1.7 to add check (m) — convergence-report dimension field name
# uniqueness (O-2 recurrence prevention);
# extended in v1.8 to extend check (m) with a second assertion: scan all BC
# bodies for convergence-report dimension field references and reject any
# field name not in the canonical 11-name set from methodology-layer §3.0
# (O-2 usage-site recurrence prevention);
# extended in v1.9 to add check (n) — convergence-dimension status-value enum
# (I-3 recurrence prevention): parses the canonical status-value enum from
# methodology-layer.md §3.1, extracts all values a convergence-report dimension
# field may hold, then scans all BC files for convergence-report dimension value
# assignments and asserts each assigned value is a member of the canonical enum.
# FAIL lists each BC + non-canonical value. WILL FAIL until PO propagates the
# AMBER → DEGRADED-PENDING / BLOCKED changes listed in methodology-layer §3.1.
# Implemented now so it becomes green automatically after PO work:
# extended in v1.10 to fix check (n) false positive: frontmatter changelog
# `reason:` lines (YAML lifecycle prose inside `modified:` blocks) are now
# excluded from check (n)'s dim_context_lines before status-value extraction.
# This prevents historical changelog prose such as "D-ETHICS is BINARY {GREEN,
# BLOCKED} per methodology-layer.md §3.1 (architect adjudication)" from being
# flagged as a non-canonical operative status value. Only operative BC body
# content (behavior steps, postconditions, invariants, test vectors) is scanned.
# The check still catches a genuine non-canonical value (e.g. `AMBER`) written
# in operative spec content. (I-3 false-positive fix)
# extended in v1.11 to add two sub-checks to check (n) (Pass-11 F-11-01/F-11-02
# recurrence prevention):
#   (n.ii) PER-DIMENSION SUBSET ENFORCEMENT: parses the §3.1 "Per-Dimension Allowed
#       Value Subsets" table from methodology-layer.md, builds a map of dimension →
#       allowed value set. For each line in any BC that assigns a status value to a
#       specific named dimension field (e.g. "perf_budget = DEGRADED" or lines that
#       reference "D-SIM" near a status token), asserts the value is in that dimension's
#       allowed subset (not just the flat enum). Catches F-11-01-class regressions: a
#       value that is enum-valid but illegal for the specific dimension (e.g.
#       DEGRADED-PENDING written for D-IMPL, which only allows GREEN/BLOCKED).
#       False-positive avoidance: dimension identity must be explicit on the same line
#       (field name match OR dimension ID); generic lines without a dimension anchor
#       are checked against the flat enum only (existing check (n)).
#   (n.iii) BARE TABLE-CELL TOKEN SCAN: widens the BC scan to catch hyphenated
#       non-canonical status tokens that appear as bare text in markdown table cells
#       (without backtick quoting or verb-phrase anchors) in convergence-dimension
#       context. Specifically targets the class of tokens seen in F-11-02:
#       BLOCKED-PENDING, DEGRADED-ACCEPTED, DEGRADED-advisory (and similar
#       UPPER-mixed or ALL-CAPS-hyphenated tokens in the pattern [A-Z]+-[A-Za-z]+).
#       Extraction: in dim_context_lines, grep for tokens matching
#       [A-Z][A-Z]+-[A-Z][A-Za-z]+ (hyphenated, starts uppercase, at least 2
#       uppercase letters before the hyphen) that are NOT in the canonical enum.
#       Changelog reason: lines remain excluded (same as v1.10 fix).
#       False-positive avoidance: the pattern requires at least 2 uppercase letters
#       before the hyphen, so prose hyphenations like "non-canonical" or
#       "machine-checkable" do NOT match (they start with lowercase). Spec identifier
#       prefixes (VP-*, BC-*, ADR-*, DI-*, CAP-*, EC-*, SS-*, DP-*) are excluded by
#       case-statement allowlist. Known legitimate compounds (SAG-AFTRA, AI-generated,
#       CPU-bound, NDA-gated, etc.) are similarly excluded. Only UPPER-CASE-initiated
#       hyphenated tokens in dimension context that are NOT spec identifiers or known
#       compounds are flagged. POSIX/BSD-grep compatible; no grep -P.
#   (n) [NEW v1.9, EXTENDED v1.11, EXTENDED v1.12] Convergence-dimension status-value
#       enum consistency:
#       (n.i)  [v1.9, case-insensitive in v1.12] Parses the canonical status-value enum
#              from §3.1 table. Scans all BC files for convergence-report dimension value
#              assignments and asserts each value is in the canonical 4-value enum
#              {GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED}. Changelog reason: lines
#              excluded. [v1.12] ALSO catches lowercase/mixed-case tokens (green/red/
#              amber/pending etc.) in backtick form on dimension-context lines. Extraction
#              is case-insensitive: backtick-quoted lowercase tokens are extracted from
#              dim_context_lines, folded to uppercase, then tested — tokens folding to
#              a canonical value are flagged as "wrong-case form"; tokens folding to a
#              known non-canonical status word (AMBER/RED/PENDING/YELLOW) are flagged as
#              "non-canonical + wrong case". False-positive avoidance: only tokens whose
#              uppercased form is a known status-vocabulary word (canonical enum OR the
#              known non-canonical set) are flagged; object/field names like
#              `playtest-satisfaction` or `convergence-report` fold to
#              PLAYTEST-SATISFACTION / CONVERGENCE-REPORT — not in either set — and are
#              silently dropped. Anchoring to dim_context_lines (same dimension-context
#              filter as v1.9) prevents false positives on the ~41 BCs that use lowercase
#              green/red/amber for non-dimension things (severity colors, lint status,
#              asset status, traffic-light UI) — those files have no matching
#              dim_context_lines. Catches F-12-02-class: BC-8.08.004's D-PLAY values
#              `green`/`red`/`amber`/`pending` which survived Passes 1-11. [v1.12] Also
#              adds a POSITIVE-COVERAGE log line: "Check (n) passed: N dimension-status
#              assignments validated across M BCs" to make a zero-scan run visible.
#       (n.ii) [NEW v1.11] Per-dimension subset enforcement: parses §3.1
#              "Per-Dimension Allowed Value Subsets" table; for each BC line that
#              both names a specific dimension (by field name or D-XX ID) AND assigns
#              a status value, asserts the value is in THAT dimension's allowed subset.
#              Catches F-11-01-class: enum-valid but dimension-illegal values.
#       (n.iii)[NEW v1.11] Bare table-cell token scan: widens extraction to catch
#              hyphenated non-canonical tokens (BLOCKED-PENDING, DEGRADED-ACCEPTED,
#              DEGRADED-advisory) in dimension context that appear as bare table cell
#              text without backtick/verb anchors. Pattern: [A-Z][A-Z]+-[A-Z][A-Za-z]+
#              in dimension-context lines, excluding canonical values and the known
#              allowlist. Catches F-11-02-class tokens. Changelog reason: excluded.
#       False-positive avoidance: patterns are anchored to convergence-report dimension
#       context (lines that contain `convergence[-_]report` or `dimensions.` near a
#       status keyword); standalone AMBER in non-dimension prose does NOT trigger.
#   (q) [NEW v1.19] Per-dimension allowed-value prose restatement guard: scans
#       methodology-layer.md for lines matching "D-<DIM> allows <TOKEN>/<TOKEN>/..."
#       or "(D-<DIM> allows ...)" OUTSIDE the §3.1 canonical table. For each match,
#       parses the token set and asserts it equals the §3.1 canonical allowed set for
#       that dimension. FAIL if any token is missing or extra (vs §3.1 authoritative
#       subset). Advisory if the pattern matches but §3.1 does not list the dimension.
#       Convention: avoid inline restatements; reference §3.1 instead.
#       Positive-coverage log: "Check (q): N prose restatements validated." POSIX/BSD.
#       (P19-01 recurrence prevention).
#   (r) [NEW v1.20] Error-family reverse coverage: for every non-retired error
#       family registered in error-taxonomy.md, assert >=1 BC file cites >=1
#       code of that family. Retired families (E-GEN, detected via ~~strikethrough~~
#       markup) are excluded. Orphan families (non-retired, zero BC citations)
#       cause a FAIL. Positive-coverage log always printed.
#       WILL FAIL until PO reconciles E-KB / E-PLAY / E-REPLAY.
#   (u) [NEW v1.24, I28-01] human-gated / creative-gate term-misuse guard: scans
#       all BC files for OPERATIVE lines that contain a human-gated vocabulary term
#       (human-gated / human-gate task / HumanGatedTaskPending / -32008 / DI-006) IN
#       PROXIMITY to a creative-gate context keyword (cinematic-director; cinematic +
#       sign-off; creative sign-off; creative-gate / creative gate; directed:true /
#       directed: true). Two-tier exemption: (E1) PASSES if line also contains an
#       external-act keyword (SAG-AFTRA / consent / likeness / console cert / store
#       publish / legal review / legal-review); (E2) PASSES if "not" appears within
#       60 chars before "human-gated" on the line (negation / contrast clause,
#       e.g. "NOT the `human-gated` fidelity tier"). Blockquote lines (">") and
#       "reason:" changelog lines excluded. Catches the I28-01 class: BC bodies
#       applying `human-gated` fidelity-tier vocabulary to the cinematic-director
#       internal creative gate (correct term: E-CIN-003, D-013; DI-007 is the
#       PLAYTEST gate, not the cinematic creative gate). Positive-coverage
#       log always printed. WILL FAIL until PO fixes BC-5.06.001, BC-12.12.008,
#       BC-7.04.001, BC-7.05.001. (I28-01 recurrence prevention). POSIX/BSD.
#   (w) [NEW v1.26, I-PASS32-01] DI-007-on-creative-gate mis-anchor guard: scans
#       all BC files for OPERATIVE lines that cite DI-007 IN PROXIMITY to a
#       CINEMATIC-CREATIVE-GATE context keyword (cinematic-director; D-013;
#       E-CIN-003; directed:true / directed: true; creative gate / creative-gate /
#       creative sign-off; cinematic + creative on same line). DI-007 is the PLAYTEST
#       invariant — it MUST NOT be cited in a cinematic-director creative gate context.
#       Playtest exemption: lines containing "playtest", "fun-score", "playtest-
#       satisfaction", or "BC-8.08" are treated as playtest-domain and pass (belt-and-
#       suspenders; in practice playtest lines never contain cinematic-creative-gate
#       keywords). Blockquote (">") and "reason:" changelog lines excluded.
#       Positive-coverage log always printed.
#       WILL FAIL until PO removes 4 DI-007 cinematic grafts; green after PO fix.
#       (I-PASS32-01 recurrence prevention). POSIX/BSD compatible.
#   (x) [NEW v1.27, F33-01] prd.md §4 NFR-table ID-set parity: parses the set of
#       NFR IDs that appear as rows in the prd.md §4 NFR summary table and the set
#       registered in nfr-catalog.md (authoritative catalog). ASSERTS both sets are
#       EQUAL (same membership). Reports IDs in catalog but missing from prd.md §4
#       (dropped NFRs) and IDs in prd.md §4 but not in catalog (phantom NFRs).
#       Stronger than check (a.iv) SUB-CHECK 2 (count-only): catches silent membership
#       drift even when the row count stays correct. Green after F33-01 fix.
#       Positive-coverage log always printed. POSIX/BSD compatible. (F33-01
#       recurrence prevention).
#   (t) [NEW v1.22, BROADENED v1.23, I24-01/I27-01] BC-7.* owner-attribution guard:
#       scans methodology-layer.md and architecture/*.md for operative lines that
#       mis-attribute OWNERSHIP of the BC-7.* dimension-evaluator family to any
#       subsystem other than SS-06, or name a non-owner BC as a dimension owner.
#       TRIGGER: any operative line containing "dimension owner" or "dimension-owner"
#       (space OR hyphen, case-insensitive). On triggered lines:
#         (t.i)  Any BC-N.NN.NNN ID must be BC-7.0[1-9].001 / BC-7.10.001 /
#                BC-7.11.001 (the 11 valid dimension owners). BC-8.*, etc. FAILS.
#         (t.ii) Any SS-NN must include SS-06; SS-NN without SS-06 also present FAILS.
#         (t.iii) Also catches: "owner BCs (SS-0X" where X != 6 (I24-01 class).
#       Blockquote lines (">") excluded. Calibrated: line 657 (correct SS-06 +
#       BC-7.*) passes; producer table (no "dimension owner") not triggered;
#       per-dimension "Subsystem:" headers (no "dimension owner") not triggered.
#       Catches both I24-01-style and I27-01-style (space variant) phrasing.
#       Positive-coverage log always printed. POSIX/BSD compatible.
#   (a) BC file count diverging from stated totals in BC-INDEX / subsystem-decomposition / ARCH-INDEX / PRD
#   (a.ii) [NEW v1.16] BC-INDEX per-capability section-header count: for each H2
#       "## CAP-NNN — <name> — N BCs" header, assert N equals the number of actual
#       "| BC-NN.NN.NNN |" rows in that capability's section. Optionally also
#       cross-checks the Summary table BC-Count cell for triple consistency.
#       FAIL lists any capability whose header count ≠ section row count (or ≠
#       summary cell). Catches P16-01 process-gap: stale per-capability header
#       counts that survive grand-total checks (e.g., CAP-007 "12 BCs" above 19
#       rows; CAP-015 "11 BCs" above 12 rows). Positive-coverage log always
#       printed. POSIX/BSD-awk/grep compatible (no grep -P).
#   (a.iii) [NEW v1.17] Alternate-phrasing BC grand-count consistency: scans
#       prd.md, subsystem-decomposition.md, and ARCH-INDEX.md for operative
#       BC-count statements using phrasings not caught by check (a):
#         - "all N behavioral contracts" (case-insensitive)
#         - "N behavioral contracts have been assigned"
#         - "all N BCs" (case-insensitive; with historical-context exclusions)
#         - "N behavioral contracts assigned"
#       For each match, asserts N == computed BC file count. FAIL lists each
#       stale phrasing with file, line number, stated count, and expected count.
#       Catches P17-01 defect class: "All 189 behavioral contracts" surviving
#       the "Grand total:" check because it uses different wording.
#       False-positive exclusions (7 rules):
#         (1) Lines starting with "|" (changelog version table rows).
#         (2) Lines starting with ">" (blockquote changelog lines).
#         (3) Lines containing "reason:" (YAML lifecycle prose).
#         (4) Lines containing "pre-v[0-9]" (explicit historical version refs).
#         (5) Lines containing "[0-9]→" or "→[0-9]" (transition delta notation).
#         (6) Lines containing "backfilled" (historical priority backfill notes).
#         (7) Patterns require words "behavioral contracts" or "BCs", NOT bare
#             numbers or "error codes" — so "189 active error codes" never matches.
#       Positive-coverage log: "Check (a.iii): N alternate-phrasing BC-count
#       statements validated." POSIX/BSD-awk/grep compatible (no grep -P).
#       WILL FAIL until PO fixes prd.md line with "All 189 behavioral contracts";
#       becomes green automatically after PO work. (P17-01 recurrence prevention).
#   (a.iv) [NEW v1.18] Per-capability PRD BC totals + NFR total consistency:
#       SUB-CHECK 1 (per-cap): scans all prd-cap-*.md for "Total CAP-NNN BCs: N"
#       lines; sources authoritative count from BC-INDEX.md CAP-NNN header N
#       (already validated by check a.ii); FAIL if stated N ≠ authoritative N.
#       Also detects obsolete "Total BCs in this batch: N" phrasing and reports
#       it as an advisory (ambiguous cap mapping — migrate to canonical form).
#       SUB-CHECK 2 (NFR triple): (i) counts actual "| NFR-NNN" rows in
#       nfr-catalog.md; (ii) parses "Total NFRs in this catalog: N" summary
#       line; (iii) parses "(N NFRs, NFR-001 through NFR-NNN)" in prd.md §4.
#       Asserts all three agree. Catches "35 vs 41" class: summary line not
#       updated when NFR-036..041 rows were added.
#       False-positive exclusions: skip "|" / ">" / "reason:" lines; pattern
#       anchors to "NFRs, NFR-001 through" so changelog delta notes
#       ("+16 NFRs", "19 NFRs") do not match.
#       Positive-coverage log: "Check (a.iv): N per-cap PRD BC totals + NFR
#       total validated." POSIX/BSD compatible. (P18-01 recurrence prevention).
#   (b) Error code count diverging from stated total in error-taxonomy.md
#   (c) BC files without a `priority:` frontmatter field (coverage gap)
#   (d) [NEW v1.2] VP P0/P1 counts: parse VP-INDEX table, assert P0+P1 match
#       VP-INDEX summary line AND ARCH-INDEX vp_p0/vp_p1 frontmatter values.
#   (e) [NEW v1.2] BC H1 ↔ BC-INDEX title sync: for each BC file, compare its
#       H1 heading title to its BC-INDEX title-column entry; fail on mismatch.
#   (f) [NEW v1.2] BC frontmatter-schema uniformity: assert every BC carries the
#       required fields: status:, version:, lifecycle_status:, subsystem:,
#       capability:, priority:.
#   (g) [NEW v1.3] VP catalog consistency across all VP-bearing docs: assert that
#       (i) total VP count = 10 and P0/P1 = 6/4 everywhere they are stated
#       (VP-INDEX, verification-architecture.md, ARCH-INDEX frontmatter); and
#       (ii) per-tool VP counts (Kani, proptest) agree between
#       verification-architecture.md and verification-coverage-matrix.md.
#       Directly prevents the C2 class of per-tool arithmetic drift.
#   (h) [NEW v1.4] studio-of-agents §3 per-SS appearance counts recomputed from
#       §2 roster using the canonical counting rule (each role counted under every
#       SS-NN listed in its row). Expected values: SS-03=16 SS-04=23 SS-05=6
#       SS-06=3 SS-07=3 SS-08=12 SS-09=2 SS-10=5 SS-11=10 SS-12=1 SS-13=1.
#       (v1.13/Pass-13: SS-11 corrected 11→10; SS-13 added=1)
#       §6 tier subtotals: Tier 1=53, Tier 2=13, sum=66.
#   (i) [REWRITTEN v1.5] subsystem-decomposition §Subsystem Priority Summary:
#       P0, P1, P2 subtotals stated in the doc are asserted to equal the counts
#       COMPUTED at runtime by counting `priority: P0/P1/P2` across BC frontmatter
#       files. No hardcoded priority constants — the BC frontmatter is authoritative.
#       Previously (v1.4) hardcoded P0=111/P1=45 which caused false-green when
#       frontmatter and table diverged (I6-01 process-gap).
#   (j) [NEW v1.4] VP ↔ BC bidirectional anchor: every formal VP (VP-001..010)
#       guarded BC must cite its VP-00x back. Currently EXPECTED TO FAIL until
#       PO completes back-reference additions (I2 fix). Implemented so the check
#       becomes green after PO work without script changes.
#   (k) [NEW v1.5, EXTENDED v1.14] Error-identifier resolution + label-match:
#       (k.i)  Every E-[A-Z]+-[0-9]+ token referenced in any BC file must
#              resolve to a registered code in error-taxonomy.md. Reports
#              unregistered codes. Will FAIL until PO registers all pending
#              codes. Becomes green after PO work.
#       (k.ii) [NEW v1.14] For E-EAP and E-OSVC families: asserts the
#              parenthetical BC label (e.g. "(UnsupportedAuthProvider)") is
#              non-contradictory with the registered taxonomy category/name.
#              E-EAP: exact CamelCase match (normalized). E-OSVC: significant
#              words from BC label must appear in the registered short
#              description. Scoped to E-EAP/E-OSVC only to avoid false positives
#              on families with looser label conventions. Will FAIL until PO
#              completes C14-01 re-citation fix. Positive-coverage log line
#              always printed.
#   (o) [NEW v1.14, O14-01] Seam-count consistency: FAIL if any scoped spec
#       file (ARCH-INDEX, ADR-0004, capabilities.md, invariants.md, prd.md,
#       product-brief.md) contains "four adapter seam" / "four-seam adapter"
#       (case-insensitive) in operative content (changelog/reason lines
#       excluded). Prevents I14-01 recurrence. Will go green after PO updates
#       domain-spec/prd/product-brief prose; architect files are clean now.
#   (p) [NEW v1.15, P15-01] Cross-reference ID/description consistency:
#       For each Related-BCs citation line of the form "- BC-X.Y.Z — <desc>"
#       (or "- BC-X.Y.Z — <desc>") in any BC body, scoped to citations of the
#       11 SS-06 dimension-owner BCs (BC-7.01.001..BC-7.11.001): extract the
#       inline description text and check for DISTINCTIVE compound dimension
#       keywords (e.g., "playtest-satisfaction", "cert-preflight",
#       "cert pre-flight", "perf-budget", "monetization-ethics",
#       "security-invariants", "asset-completeness", "tests/replay",
#       "sim/spec", "provenance/legal") that map to a specific dimension-owner
#       BC. If the keyword maps to a DIFFERENT dimension-owner BC than the one
#       cited, FAIL with the citing BC + cited ID + inline description vs actual
#       title. Changelog "reason:" lines excluded. Scope is intentionally
#       limited to SS-06 dimension-owner cross-references (BC-7.01.001..
#       BC-7.11.001) to avoid false positives on legitimate paraphrases.
#       Positive-coverage log: "Check (p): N cross-references validated."
#       WILL FAIL until PO fixes the 2 known mis-anchors (BC-9.01.001 citing
#       BC-7.05.001 for Cert Pre-Flight; BC-8.08.004 citing BC-7.07.001 for
#       playtest-satisfaction). Becomes green after PO work.
#   (l) [NEW v1.6] disclosure_class closed-enum consistency (F8-01 recurrence
#       prevention): derives the canonical allowed-value set programmatically from
#       the producer BC ss-04/BC-4.03.002.md (source of truth; authoritative closed
#       enum: pre-generated, live-generated, procedural-exempt). Scans ALL BC files
#       for disclosure_class value enumerations expressed as {set} notation or
#       backtick-quoted pipe-separated value lists. For every value token found in
#       any such enumeration, asserts it is a member of the canonical set. FAIL
#       reports the offending BC filename and the non-canonical value token.
#       Prevents the F8-01 defect class: consumer BCs adopting non-canonical
#       disclosure_class vocabulary that producer-side CI could not detect.
#   (m) [NEW v1.7, EXTENDED v1.8] Convergence-report dimension field name consistency
#       (O-2 recurrence prevention):
#       (m.i)  Parses the canonical dimension field name registry table from
#              methodology-layer.md (§3.0), extracts all `dimensions.<field>` canonical
#              names, and asserts (i) the count equals 11 (one per dimension, none missing
#              or added) and (ii) all 11 field names are unique (no two dimensions share a
#              name). Prevents: a new dimension added without a canonical field name, or
#              two dimensions assigned the same field name. (present since v1.7)
#       (m.ii) [NEW v1.8] Scans all BC body text for tokens of the form
#              `convergence-report.dimensions.<field>`, `convergence_report.dimensions.<field>`,
#              `` `dimensions.<field>` `` (backtick-quoted), and whitespace-prefixed
#              `.dimensions.<field>` (line-wrap continuations). For every <field> token
#              found, asserts it is a member of the canonical 11-name set parsed from
#              §3.0. FAIL reports the offending BC filename and the non-canonical field
#              name (e.g., "ss-09/BC-9.04.001.md: non-canonical convergence dimension
#              field 'distribution_readiness'"). Prevents: BCs adopting field names
#              outside the canonical registry (the O-2 usage-site class).
#              False-positive avoidance: patterns are anchored to the convergence-report
#              namespace or backtick-quoted, so `a.dimensions.width` (texture-asset
#              geometry) does NOT trigger this check.
#
# USAGE
#   ./scripts/check-spec-counts.sh [--verbose]
#
# OPTIONS
#   --verbose   Print all checked values even when counts match.
#
# EXIT CODES
#   0   All counts match stated values.
#   1   One or more count mismatches detected. See output for details.
#
# CI WIRING (see docs/cicd-setup.md §Spec Counts Lint)
# -------------------------------------------------------
# Add to the lint job in .github/workflows/ci.yml:
#
#   - name: Check spec counts
#     run: bash scripts/check-spec-counts.sh
#
# No external dependencies beyond bash + standard POSIX tools (find, grep, awk, sed).
# Compatible with both GNU grep and BSD grep (macOS). Does NOT use grep -P.

set -euo pipefail

VERBOSE=false
if [[ "${1:-}" == "--verbose" ]]; then
  VERBOSE=true
fi

# ---- Paths ------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BC_DIR="$REPO_ROOT/.factory/specs/behavioral-contracts"
BC_INDEX="$BC_DIR/BC-INDEX.md"
SUBDECOMP="$REPO_ROOT/.factory/specs/architecture/subsystem-decomposition.md"
ARCH_INDEX="$REPO_ROOT/.factory/specs/architecture/ARCH-INDEX.md"
PRD="$REPO_ROOT/.factory/specs/prd.md"
ERROR_TAX="$REPO_ROOT/.factory/specs/prd-supplements/error-taxonomy.md"
VP_INDEX="$REPO_ROOT/.factory/specs/verification-properties/VP-INDEX.md"
VERIF_ARCH="$REPO_ROOT/.factory/specs/architecture/verification-architecture.md"
VERIF_MATRIX="$REPO_ROOT/.factory/specs/architecture/verification-coverage-matrix.md"
STUDIO_AGENTS="$REPO_ROOT/.factory/specs/architecture/studio-of-agents.md"
METHODOLOGY_LAYER="$REPO_ROOT/.factory/specs/architecture/methodology-layer.md"
NFR_CATALOG="$REPO_ROOT/.factory/specs/prd-supplements/nfr-catalog.md"
PRD_SUPPLEMENTS_DIR="$REPO_ROOT/.factory/specs/prd-supplements"

# ---- Helpers ----------------------------------------------------------------
fail=0
errors=()
# Initialize check-local counters that are referenced in the SUMMARY block;
# ensures the summary is valid even if a check is skipped (e.g. METHODOLOGY_LAYER not found).
q_validated=0
q_violations=0
# (r) reverse-coverage counters: initialized here so SUMMARY is safe if check is skipped
active_family_count=0
r_orphans=()
# (s) cross-table consistency counters: initialized here so SUMMARY is safe if check is skipped
s_dims_in_map=0
s_comparisons=0
s_violations=0
# (u) human-gated/creative-gate term-misuse counters: initialized here so SUMMARY is safe if skipped
u_lines_scanned=0
u_creative_gate_lines=0
u_violations=0
# (w) DI-007-on-creative-gate mis-anchor counters: initialized here so SUMMARY is safe if skipped
w_lines_scanned=0
w_creative_gate_lines=0
w_violations=0
# (o.ii) Canon-KB ordinal counters: initialized here so SUMMARY is safe if check is skipped
ordinal_files_scanned=0
ordinal_violations=0
# (x) NFR-table ID-set parity counters: initialized here so SUMMARY is safe if check is skipped
x_violations=0
x_catalog_count=0
x_prd_count=0
# (y) seam-ordinal collision counters: initialized here so SUMMARY is safe if check is skipped
y_violations=0
y_files_scanned=0
# (z) base-manifest seam-enum completeness counters: initialized here so SUMMARY is safe if skipped
z_violations=0
z_enum_count=0
z_matrix_count=0

check() {
  local label="$1" computed="$2" stated="$3" source_doc="$4"
  if [[ "$computed" != "$stated" ]]; then
    errors+=("MISMATCH [$label]: computed=$computed  stated=$stated  (in: $source_doc)")
    fail=1
  elif [[ "$VERBOSE" == true ]]; then
    echo "  OK [$label]: $computed == $stated  ($source_doc)"
  fi
}

# Extract first match of a pattern from a file using grep -E + awk.
# Usage: extract_first FILE PATTERN FIELD_INDEX
# FIELD_INDEX: awk field index of the number in the match line.
# Returns empty string if not found.
extract_grep_awk() {
  local file="$1" pattern="$2" awk_prog="$3"
  grep -E "$pattern" "$file" 2>/dev/null | awk "$awk_prog" | head -1 || true
}

echo "=== check-spec-counts.sh — game-factory spec consistency (v1.30) ==="
echo ""

# ============================================================================
# (a) BC FILE COUNT
# ============================================================================
# Computed: all BC-*.md files under the ss-NN/ subdirectories (depth 2).
# BC-INDEX.md is at depth 1 and is excluded by -mindepth 2.
computed_bc=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" | wc -l | tr -d '[:space:]')

echo "--- (a) Behavioral Contract file count ---"
echo "    Computed BC file count: $computed_bc"

# BC-INDEX: "Grand total: NNN behavioral contracts"
stated_bc_index=$(extract_grep_awk "$BC_INDEX" \
  'Grand total: [0-9]+ behavioral' \
  '{for(i=1;i<=NF;i++) if($i~/^[0-9]+$/ && $(i+1)~/behavioral/) {print $i; exit}}')

# subsystem-decomposition.md: "Grand total: **NNN**"
stated_bc_subdecomp=$(extract_grep_awk "$SUBDECOMP" \
  'Grand total:.*\*\*[0-9]+\*\*' \
  '{match($0,/\*\*[0-9]+\*\*/); s=substr($0,RSTART+2,RLENGTH-4); print s; exit}')

# ARCH-INDEX.md: "| **TOTAL** | **NNN** |"  (the BC count table row)
stated_bc_arch=$(grep -E '^\| \*\*TOTAL\*\* \| \*\*[0-9]+\*\*' "$ARCH_INDEX" 2>/dev/null \
  | awk '{match($0,/\*\*[0-9]+\*\*/); print substr($0,RSTART+2,RLENGTH-4)}' \
  | head -1 || true)

# PRD: "Grand total: NNN BCs" (first occurrence)
stated_bc_prd=$(extract_grep_awk "$PRD" \
  'Grand total: [0-9]+ BCs' \
  '{for(i=1;i<=NF;i++) if($i~/^[0-9]+$/ && $(i+1)~/BCs/) {print $i; exit}}')

echo "    Stated in BC-INDEX.md:               ${stated_bc_index:-NOT_FOUND}"
echo "    Stated in subsystem-decomposition.md: ${stated_bc_subdecomp:-NOT_FOUND}"
echo "    Stated in ARCH-INDEX.md:              ${stated_bc_arch:-NOT_FOUND}"
echo "    Stated in prd.md:                     ${stated_bc_prd:-NOT_FOUND}"
echo ""

[[ -n "$stated_bc_index" ]]    && check "BC total / BC-INDEX"                "$computed_bc" "$stated_bc_index"    "BC-INDEX.md"
[[ -n "$stated_bc_subdecomp" ]] && check "BC total / subsystem-decomp"        "$computed_bc" "$stated_bc_subdecomp" "subsystem-decomposition.md"
[[ -n "$stated_bc_arch" ]]      && check "BC total / ARCH-INDEX"               "$computed_bc" "$stated_bc_arch"     "ARCH-INDEX.md"
[[ -n "$stated_bc_prd" ]]       && check "BC total / prd.md"                   "$computed_bc" "$stated_bc_prd"      "prd.md"

# ============================================================================
# (a.ii) BC-INDEX PER-CAPABILITY SECTION-HEADER COUNT CONSISTENCY  [NEW v1.16]
# ============================================================================
# For each H2 capability section header of the form:
#   ## CAP-0NN — <name> — N BCs
# parse the stated N, then count the actual "| BC-NN.NN.NNN |" rows in that
# capability's section table (rows up to the next "## " header). FAIL if the
# stated header N does not equal the counted rows.
#
# Optionally also cross-checks the BC-INDEX Summary table's BC-Count cell for
# each capability (first integer in the 4th pipe-delimited field of the matching
# "| CAP-NNN" row in the Summary table). A mismatch in the summary cell is
# reported as an additional failure for triple consistency.
#
# False-positive avoidance:
#   - Headers without a "— N BCs" suffix are silently skipped (intro / summary
#     sections, headers that use a different format).
#   - Only rows of the exact form "| BC-[digit]" (BC file table rows) are counted;
#     header rows, separator rows, and prose lines are excluded.
#   - The Summary table is identified by the "## Summary" heading; capability rows
#     in it are matched by "| CAP-" prefix (case-sensitive) in field 2.
#
# POSIX/BSD-grep/awk compatible (no grep -P).
#
# POSITIVE-COVERAGE: "Check (a.ii): N capability section headers validated."
# EXPECTED: GREEN now that PO has landed the v1.7 header fixes. Any future
# header drift will cause a FAIL.
echo "--- (a.ii) BC-INDEX per-capability section-header count vs section row count ---"

if [[ ! -f "$BC_INDEX" ]]; then
  echo "    SKIP: BC-INDEX.md not found at $BC_INDEX"
else
  # Use awk to:
  #   1. Track the current capability header (H2 lines starting with "## CAP-").
  #   2. Count "| BC-" rows in the current capability's section.
  #   3. On encountering the next "## " header (any H2), record the (header, stated, rows)
  #      triple for the just-completed section.
  #   4. At END, flush the last capability.
  #   5. The Summary table section ("## Summary") is excluded from BC-row counting
  #      because its "| CAP-" rows do not start with "| BC-" — the BC-row filter
  #      naturally ignores them.
  #
  # Output format per capability: "CAP-NNN|stated_n|actual_rows"
  # Lines where the header had no "— N BCs" suffix are emitted as "CAP-NNN||actual_rows"
  # and are silently skipped in the check loop below.

  cap_check_results=$(awk '
    /^## CAP-[0-9]/ {
      # Flush previous capability if any
      if (cap_id != "") {
        print cap_id "|" stated "|" rows
      }
      cap_id = ""
      stated = ""
      rows = 0
      # Extract CAP-NNN id (first token like CAP-NNN after "## ")
      for (i=2; i<=NF; i++) {
        if ($i ~ /^CAP-[0-9]/) { cap_id=$i; break }
      }
      # Extract stated N from "— N BCs" suffix at end of line.
      # Match the last integer followed by " BCs" (case sensitive).
      # Use match() + substr() — POSIX awk compatible.
      line = $0
      if (match(line, /[0-9]+ BCs$/)) {
        tok = substr(line, RSTART, RLENGTH)
        # tok is "N BCs" — extract N
        n = tok + 0   # awk arithmetic strips " BCs"
        # Re-extract cleanly: split on space
        split(tok, a, " ")
        stated = a[1]
      }
      next
    }
    # Any other H2 header closes the current capability block
    /^## / {
      if (cap_id != "") {
        print cap_id "|" stated "|" rows
      }
      cap_id = ""
      stated = ""
      rows = 0
      next
    }
    # Count BC table rows: lines starting with "| BC-" followed by a digit
    cap_id != "" && /^\| BC-[0-9]/ { rows++ }
    END {
      if (cap_id != "") print cap_id "|" stated "|" rows
    }
  ' "$BC_INDEX" 2>/dev/null || true)

  # Build a Summary-table BC-Count map: CAP-NNN → first_integer_in_BC_Count_cell
  # Summary table rows look like:
  #   | CAP-007 — Convergence Tracking | P0 | SS-06 | 19 (+7 v1.2: ...) |
  # Field 2 (after leading |) starts with "CAP-NNN"; field 5 is the BC-Count cell.
  # We extract the first integer from field 5.
  declare -A SUMMARY_BC_COUNT
  while IFS= read -r row; do
    # Extract CAP-NNN from field 2
    cap_key=$(printf '%s' "$row" \
      | awk -F'|' '{gsub(/^[[:space:]]+/,"",$2); match($2,/CAP-[0-9]+/); print substr($2,RSTART,RLENGTH)}')
    # Extract first integer from field 5 (BC-Count cell)
    bc_count_cell=$(printf '%s' "$row" \
      | awk -F'|' '{print $5}')
    first_int=$(printf '%s' "$bc_count_cell" \
      | grep -oE '[0-9]+' | head -1 || true)
    if [[ -n "$cap_key" ]] && [[ -n "$first_int" ]]; then
      SUMMARY_BC_COUNT["$cap_key"]="$first_int"
    fi
  done < <(grep -E '^\| CAP-[0-9]' "$BC_INDEX" 2>/dev/null || true)

  # Process results
  cap_header_check_count=0
  cap_header_violations=0
  cap_header_violation_msgs=()

  while IFS='|' read -r cap_id stated_n actual_rows; do
    [[ -z "$cap_id" ]] && continue
    # Skip if no stated count in header (header without "— N BCs" suffix)
    [[ -z "$stated_n" ]] && continue
    cap_header_check_count=$(( cap_header_check_count + 1 ))

    # Check: header stated count == section row count
    if [[ "$stated_n" != "$actual_rows" ]]; then
      cap_header_violations=$(( cap_header_violations + 1 ))
      cap_header_violation_msgs+=("${cap_id}: header says '${stated_n} BCs' but section contains ${actual_rows} BC rows — header must be corrected")
    else
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [${cap_id} header]: stated=${stated_n} rows=${actual_rows}"
      fi
    fi

    # Optional triple-consistency: cross-check against Summary table cell
    summary_count="${SUMMARY_BC_COUNT[$cap_id]:-}"
    if [[ -n "$summary_count" ]] && [[ "$summary_count" != "$actual_rows" ]]; then
      cap_header_violations=$(( cap_header_violations + 1 ))
      cap_header_violation_msgs+=("${cap_id}: Summary table BC-Count='${summary_count}' but section contains ${actual_rows} BC rows — Summary table must be corrected")
    elif [[ "$VERBOSE" == true ]] && [[ -n "$summary_count" ]]; then
      echo "    OK [${cap_id} summary]: summary_count=${summary_count} rows=${actual_rows}"
    fi

  done <<< "$cap_check_results"

  # Positive-coverage log (always printed — detects zero-scan / inert run)
  echo "    Check (a.ii): $cap_header_check_count capability section headers validated against section row counts."
  echo "    Per-capability header/summary mismatches: $cap_header_violations"

  if [[ $cap_header_violations -gt 0 ]]; then
    echo ""
    echo "    CAPABILITY SECTION-HEADER COUNT MISMATCHES (BC-INDEX.md header or Summary table must be corrected):"
    for msg in "${cap_header_violation_msgs[@]}"; do
      echo "      $msg"
    done
    errors+=("MISMATCH [per-capability section-header count (a.ii)]: $cap_header_violations count mismatch(es) between BC-INDEX.md capability headers/Summary table and actual section row counts (see list above)")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (a.iii) ALTERNATE-PHRASING BC GRAND-COUNT CONSISTENCY  [NEW v1.17]
# ============================================================================
# Scans prd.md, subsystem-decomposition.md, and ARCH-INDEX.md for operative
# BC-count statements using phrasings NOT caught by check (a)'s "Grand total:"
# pattern. For each match, asserts the stated count equals $computed_bc.
#
# Target phrasings (case-insensitive):
#   1. "all [0-9]+ behavioral contracts"
#   2. "[0-9]+ behavioral contracts have been assigned"
#   3. "all [0-9]+ BCs"
#   4. "[0-9]+ behavioral contracts assigned"
#
# False-positive exclusions (applied per line before extracting a count):
#   (1) Line starts with "|" — changelog version table rows.
#   (2) Line starts with ">" — blockquote changelog/annotation lines.
#   (3) Line contains "reason:" — YAML frontmatter lifecycle prose.
#   (4) Line contains "pre-v" followed by a digit — explicit historical version
#       refs ("All 178 pre-v1.9 BCs").
#   (5) Line contains a digit followed by the arrow char OR arrow followed by a
#       digit — transition delta notation ("178->190 BCs", em-dash arrow form).
#   (6) Line contains "backfilled" — historical priority/field backfill notes
#       ("Priority fields have been backfilled on all 178 BCs").
#
# NOTE: "189 active error codes" does NOT match because the patterns require
# the words "behavioral contracts" or "BCs", not "error codes".
#
# POSIX/BSD-grep/awk compatible (no grep -P). awk used for number extraction.
# EXPECTED: FAIL until PO fixes "All 189 behavioral contracts" in prd.md sect 8.1;
# becomes green automatically after PO work.
#
# POSITIVE-COVERAGE: "Check (a.iii): N alternate-phrasing BC-count statements
# validated." always printed — detects zero-scan / inert run.
echo "--- (a.iii) Alternate-phrasing BC grand-count consistency ---"

aiii_violations=0
aiii_checked=0
aiii_violation_msgs=()

# Files to scan (same scope as check (a) minus BC-INDEX which uses a different
# phrasing and is already covered by check (a)'s "Grand total:" pattern).
AIII_FILES=("$PRD" "$SUBDECOMP" "$ARCH_INDEX")
AIII_FILE_LABELS=("prd.md" "subsystem-decomposition.md" "ARCH-INDEX.md")

for file_idx in "${!AIII_FILES[@]}"; do
  scan_file="${AIII_FILES[$file_idx]}"
  scan_label="${AIII_FILE_LABELS[$file_idx]}"

  if [[ ! -f "$scan_file" ]]; then
    echo "    SKIP [$scan_label]: file not found"
    continue
  fi

  # Use awk to scan every line in the file.
  # For each line:
  #   1. Apply exclusion rules — if any fires, skip the line.
  #   2. Test case-insensitive match for each of the 4 target phrasings.
  #   3. If matched, extract the integer N from the match.
  #   4. Output: "LINENO|N|matched_phrasing|line_snippet"
  #
  # The UTF-8 right-arrow (U+2192) used in transition notes like "178->190"
  # is represented in the source as the raw bytes e2 86 92. BSD awk processes
  # the file as bytes, so we match its raw occurrence with a literal character
  # in the pattern.  We also match the ASCII approximation "->" for robustness.
  match_records=$(awk '
    {
      line = $0
      lc   = tolower(line)

      # --- Exclusion rules ---
      # (1) starts with "|"
      if (substr(lc,1,1) == "|") next
      # (2) starts with ">"
      if (substr(lc,1,1) == ">") next
      # (3) contains "reason:"
      if (index(lc,"reason:") > 0) next
      # (4) contains "pre-v" followed by a digit
      if (match(lc,/pre-v[0-9]/)) next
      # (5) contains transition delta arrow patterns
      #     Match ASCII "->" approximation (common in changelog entries)
      if (index(lc,"->") > 0) next
      #     Match UTF-8 right-arrow as raw bytes (e2 86 92) via literal char
      if (index(line,"\342\206\222") > 0) next
      # (6) contains "backfilled"
      if (index(lc,"backfilled") > 0) next

      # --- Pattern matching ---
      matched = 0
      n = 0
      phrasing = ""

      # Phrasing 1: "all N behavioral contracts"
      if (!matched && match(lc, /all [0-9]+ behavioral contracts/)) {
        tok = substr(lc, RSTART, RLENGTH)
        split(tok, a, " ")
        n = a[2] + 0
        if (n > 0) { matched = 1; phrasing = "all N behavioral contracts" }
      }

      # Phrasing 2: "N behavioral contracts have been assigned"
      if (!matched && match(lc, /[0-9]+ behavioral contracts have been assigned/)) {
        tok = substr(lc, RSTART, RLENGTH)
        split(tok, a, " ")
        n = a[1] + 0
        if (n > 0) { matched = 1; phrasing = "N behavioral contracts have been assigned" }
      }

      # Phrasing 3: "all N BCs"  (tolower converts BCs -> bcs)
      if (!matched && match(lc, /all [0-9]+ bcs/)) {
        tok = substr(lc, RSTART, RLENGTH)
        split(tok, a, " ")
        n = a[2] + 0
        if (n > 0) { matched = 1; phrasing = "all N BCs" }
      }

      # Phrasing 4: "N behavioral contracts assigned"
      if (!matched && match(lc, /[0-9]+ behavioral contracts assigned/)) {
        tok = substr(lc, RSTART, RLENGTH)
        split(tok, a, " ")
        n = a[1] + 0
        if (n > 0) { matched = 1; phrasing = "N behavioral contracts assigned" }
      }

      if (matched) {
        disp = substr(line, 1, 80)
        print NR "|" n "|" phrasing "|" disp
      }
    }
  ' "$scan_file" 2>/dev/null || true)

  # Process each match record from this file
  while IFS='|' read -r lineno stated_n phrasing line_disp; do
    [[ -z "$lineno" ]] && continue
    aiii_checked=$(( aiii_checked + 1 ))

    if [[ "$stated_n" != "$computed_bc" ]]; then
      aiii_violations=$(( aiii_violations + 1 ))
      aiii_violation_msgs+=("${scan_label}:${lineno}: phrasing '${phrasing}' states ${stated_n} BCs but computed count is ${computed_bc} — text: ${line_disp}")
    else
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [a.iii ${scan_label}:${lineno}]: phrasing='${phrasing}' stated=${stated_n} matches computed=${computed_bc}"
      fi
    fi
  done <<< "$match_records"

done

# Positive-coverage log (always printed — detects zero-scan / inert run)
echo "    Check (a.iii): $aiii_checked alternate-phrasing BC-count statements validated."
echo "    Alternate-phrasing BC-count violations: $aiii_violations"

if [[ $aiii_violations -gt 0 ]]; then
  echo ""
  echo "    ALTERNATE-PHRASING BC-COUNT MISMATCHES (operative prose states wrong BC grand total):"
  for msg in "${aiii_violation_msgs[@]}"; do
    echo "      $msg"
  done
  errors+=("MISMATCH [alternate-phrasing BC count (a.iii)]: $aiii_violations operative prose statement(s) assert a stale BC grand total (see list above) — PO must update the stated count to ${computed_bc}")
  fail=1
fi
echo ""

# ============================================================================
# (b) ERROR CODE COUNT
# ============================================================================
# Computed: distinct E-<FAMILY>-<NNN> identifiers (numeric suffix required).
# grep -oE extracts every match; sort -u deduplicates; wc -l counts them.
# This excludes family-summary rows like "| E-EAP | 13 |" (no numeric suffix)
# and change-note rows that incidentally start with "| E-EAP-011 reassigned".
computed_ecodes=$(grep -oE 'E-[A-Z]+-[0-9]+' "$ERROR_TAX" 2>/dev/null | sort -u | wc -l | tr -d ' ')

echo "--- (b) Error code count ---"
echo "    Computed error code count: $computed_ecodes"

# Stated: "Total defined error codes (vN.N): NNN"
stated_ecodes=$(extract_grep_awk "$ERROR_TAX" \
  'Total defined error codes.*: [0-9]+' \
  '{match($0,/: [0-9]+/); print substr($0,RSTART+2,RLENGTH-2); exit}')

echo "    Stated in error-taxonomy.md: ${stated_ecodes:-NOT_FOUND}"
echo ""

if [[ -n "$stated_ecodes" ]]; then
  check "Error code total / error-taxonomy" "$computed_ecodes" "$stated_ecodes" "error-taxonomy.md"
else
  # No stated total to check against — advisory only (not a hard failure).
  echo "  ADVISORY: error-taxonomy.md has no 'Total defined error codes (vN.N): NNN' line."
  echo "            Computed count: $computed_ecodes"
  echo "            Add a line matching that pattern to enable the check."
  echo ""
fi

# ============================================================================
# (c) BC PRIORITY FIELD COVERAGE
# ============================================================================
# Computed: BC files with vs without `priority: P0|P1|P2` frontmatter field.
echo "--- (c) BC priority field coverage ---"

computed_with_priority=0
computed_without_priority=0
missing_list=()

while IFS= read -r -d $'\0' bc_file; do
  if grep -qE '^priority:[[:space:]]*(P0|P1|P2)' "$bc_file" 2>/dev/null; then
    computed_with_priority=$(( computed_with_priority + 1 ))
  else
    computed_without_priority=$(( computed_without_priority + 1 ))
    missing_list+=("$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")")
  fi
done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

echo "    BC files with priority: field:    $computed_with_priority / $computed_bc"
echo "    BC files missing priority: field: $computed_without_priority"

if [[ $computed_without_priority -gt 0 ]]; then
  echo ""
  echo "    FILES MISSING priority: field:"
  for f in "${missing_list[@]}"; do
    echo "      $f"
  done
  errors+=("MISMATCH [BC priority coverage]: $computed_without_priority files missing priority: field (expected 0)")
  fail=1
fi
echo ""

# ============================================================================
# (d) VP P0 / P1 COUNT CONSISTENCY  [NEW v1.2]
# ============================================================================
# Source of truth hierarchy:
#   1. VP-INDEX.md summary table (computed by counting P0/P1 rows)
#   2. VP-INDEX.md summary line  ("Total: N VPs — X P0, Y P1")
#   3. ARCH-INDEX.md frontmatter (vp_p0: X  and  vp_p1: Y)
# All three must agree. Any discrepancy is a count-drift defect.
echo "--- (d) VP P0/P1 count consistency ---"

if [[ ! -f "$VP_INDEX" ]]; then
  echo "    SKIP: VP-INDEX.md not found at $VP_INDEX"
else
  # Count P0 rows in the summary table (lines starting with "| VP-" that contain "| P0 |")
  # The table uses "|" delimiters; Phase column is field 5 (0-indexed from leading |).
  # Column order: | VP ID | Short Description | Formal Method | Phase | Owning SS | Traced BCs |
  computed_vp_p0=$(grep -E '^\| VP-[0-9]+' "$VP_INDEX" 2>/dev/null \
    | awk -F'|' '{gsub(/ /,"",$5); if($5=="P0") count++} END{print count+0}')
  computed_vp_p1=$(grep -E '^\| VP-[0-9]+' "$VP_INDEX" 2>/dev/null \
    | awk -F'|' '{gsub(/ /,"",$5); if($5=="P1") count++} END{print count+0}')

  # Parse stated P0/P1 from VP-INDEX summary line: "Total: N VPs — X P0, Y P1"
  # Extract the number immediately before "P0" and "P1"
  vp_summary_line=$(grep -E 'Total: [0-9]+ VPs' "$VP_INDEX" 2>/dev/null | head -1 || true)
  stated_vp_p0_summary=$(printf '%s' "$vp_summary_line" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P0," || $i=="P0.") {print $(i-1); exit}}')
  stated_vp_p1_summary=$(printf '%s' "$vp_summary_line" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P1." || $i=="P1,") {print $(i-1); exit}}')

  # Parse ARCH-INDEX frontmatter: "vp_p0: N" and "vp_p1: N"
  stated_vp_p0_arch=$(grep -E '^vp_p0:' "$ARCH_INDEX" 2>/dev/null \
    | awk '{gsub(/[^0-9]/,"",$2); print $2}' | head -1 || true)
  stated_vp_p1_arch=$(grep -E '^vp_p1:' "$ARCH_INDEX" 2>/dev/null \
    | awk '{gsub(/[^0-9]/,"",$2); print $2}' | head -1 || true)

  echo "    Computed P0 (VP-INDEX table rows): $computed_vp_p0"
  echo "    Computed P1 (VP-INDEX table rows): $computed_vp_p1"
  echo "    Stated P0 (VP-INDEX summary line): ${stated_vp_p0_summary:-NOT_FOUND}"
  echo "    Stated P1 (VP-INDEX summary line): ${stated_vp_p1_summary:-NOT_FOUND}"
  echo "    Stated P0 (ARCH-INDEX vp_p0):      ${stated_vp_p0_arch:-NOT_FOUND}"
  echo "    Stated P1 (ARCH-INDEX vp_p1):      ${stated_vp_p1_arch:-NOT_FOUND}"
  echo ""

  [[ -n "$stated_vp_p0_summary" ]] && check "VP P0 / VP-INDEX summary line" \
    "$computed_vp_p0" "$stated_vp_p0_summary" "VP-INDEX.md"
  [[ -n "$stated_vp_p1_summary" ]] && check "VP P1 / VP-INDEX summary line" \
    "$computed_vp_p1" "$stated_vp_p1_summary" "VP-INDEX.md"
  [[ -n "$stated_vp_p0_arch" ]] && check "VP P0 / ARCH-INDEX frontmatter" \
    "$computed_vp_p0" "$stated_vp_p0_arch" "ARCH-INDEX.md"
  [[ -n "$stated_vp_p1_arch" ]] && check "VP P1 / ARCH-INDEX frontmatter" \
    "$computed_vp_p1" "$stated_vp_p1_arch" "ARCH-INDEX.md"
fi

# ============================================================================
# (e) BC H1 ↔ BC-INDEX TITLE SYNC  [NEW v1.2]
# ============================================================================
# For each BC file, extract the H1 title (after "# BC-NNN: ") and compare to
# the BC-INDEX title column (the 3rd |-separated field in the BC-INDEX table row
# for that BC ID).
echo "--- (e) BC H1 <-> BC-INDEX title sync ---"

bc_title_mismatches=()
bc_title_checked=0

while IFS= read -r -d $'\0' bc_file; do
  bc_basename=$(basename "$bc_file")
  # Extract BC ID from filename (BC-X.YY.ZZZ)
  bc_id="${bc_basename%.md}"

  # Extract H1 title: line starting with "# BC-ID: " or "# BC-ID — "
  # Strip the leading "# BC-ID: " or "# BC-ID — " prefix; also handle missing prefix.
  h1_raw=$(grep -m1 "^# " "$bc_file" 2>/dev/null || true)
  if [[ -z "$h1_raw" ]]; then
    bc_title_mismatches+=("$bc_id: no H1 heading found in file")
    continue
  fi
  # Remove "# BC-X.Y.Z: " or "# BC-X.Y.Z — " prefix if present
  h1_title=$(printf '%s' "$h1_raw" \
    | sed 's/^# BC-[0-9][0-9.]*[^:]*:[[:space:]]*//' \
    | sed 's/^# BC-[0-9][0-9.]*[^—]*—[[:space:]]*//' \
    | sed 's/^# //')

  # Find BC-INDEX row for this BC ID. Match table row: "| BC-X.Y.Z |"
  # The title is the second pipe-delimited field (field 3 in awk because leading |).
  index_row=$(grep -E "^\| ${bc_id} \|" "$BC_INDEX" 2>/dev/null | head -1 || true)
  if [[ -z "$index_row" ]]; then
    # BC not found in BC-INDEX — skip (may be legitimately absent for new BCs)
    continue
  fi
  index_title=$(printf '%s' "$index_row" \
    | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}')

  bc_title_checked=$(( bc_title_checked + 1 ))

  # Comparison: check if the index title is a substring of the H1 title or vice versa.
  # Case-insensitive containment: catches truncation, minor punctuation differences.
  # A mismatch is flagged when neither is a substring of the other (after lowercasing
  # and stripping leading/trailing whitespace). This is intentionally lenient to avoid
  # false positives on punctuation, but will catch materially different titles.
  h1_lower=$(printf '%s' "$h1_title" | tr '[:upper:]' '[:lower:]' | tr -s ' ')
  idx_lower=$(printf '%s' "$index_title" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

  if [[ "$h1_lower" != *"$idx_lower"* ]] && [[ "$idx_lower" != *"$h1_lower"* ]]; then
    bc_title_mismatches+=("$bc_id: H1='$h1_title' | INDEX='$index_title'")
  fi
done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

echo "    BC files checked against BC-INDEX: $bc_title_checked"
echo "    Title mismatches found: ${#bc_title_mismatches[@]}"

if [[ ${#bc_title_mismatches[@]} -gt 0 ]]; then
  echo ""
  echo "    TITLE MISMATCHES:"
  for m in "${bc_title_mismatches[@]}"; do
    echo "      $m"
  done
  errors+=("MISMATCH [BC H1/BC-INDEX title sync]: ${#bc_title_mismatches[@]} BC(s) have divergent titles (see above)")
  fail=1
fi
echo ""

# ============================================================================
# (f) BC FRONTMATTER-SCHEMA UNIFORMITY  [NEW v1.2]
# ============================================================================
# Assert every BC file carries the required frontmatter fields:
#   status:, version:, lifecycle_status:, subsystem:, capability:, priority:
echo "--- (f) BC frontmatter-schema uniformity ---"

REQUIRED_FIELDS=("status:" "version:" "lifecycle_status:" "subsystem:" "capability:" "priority:")

bc_schema_failures=0
bc_schema_issues=()

while IFS= read -r -d $'\0' bc_file; do
  bc_basename=$(basename "$bc_file")
  bc_id="${bc_basename%.md}"
  missing_fields=()

  for field in "${REQUIRED_FIELDS[@]}"; do
    # Check field exists within the YAML frontmatter block (between --- delimiters).
    # We look within the first 60 lines (all BC frontmatter is well under 60 lines).
    if ! head -60 "$bc_file" 2>/dev/null | grep -qE "^${field}"; then
      missing_fields+=("$field")
    fi
  done

  if [[ ${#missing_fields[@]} -gt 0 ]]; then
    bc_schema_failures=$(( bc_schema_failures + 1 ))
    bc_schema_issues+=("$bc_id: missing fields: ${missing_fields[*]}")
  fi
done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

echo "    BC files checked for schema fields: $computed_bc"
echo "    BC files with schema violations: $bc_schema_failures"

if [[ $bc_schema_failures -gt 0 ]]; then
  echo ""
  echo "    SCHEMA VIOLATIONS:"
  for issue in "${bc_schema_issues[@]}"; do
    echo "      $issue"
  done
  errors+=("MISMATCH [BC frontmatter schema]: $bc_schema_failures BC file(s) missing required frontmatter fields (see above)")
  fail=1
fi
echo ""

# ============================================================================
# (g) VP CATALOG CONSISTENCY  [NEW v1.3]
# ============================================================================
# Assert VP count coherence across all four VP-bearing docs:
#   VP-INDEX.md, verification-architecture.md, verification-coverage-matrix.md,
#   ARCH-INDEX.md frontmatter.
#
# Checks:
#   (g.i)  Total VP count = 10 and P0/P1 = 6/4 in every doc that states them.
#   (g.ii) Per-tool VP counts (Kani, proptest) agree between
#          verification-architecture.md and verification-coverage-matrix.md.
#
# Pattern strategy: POSIX/BSD-grep compatible (no -P; uses -E only).
echo "--- (g) VP catalog consistency ---"

VP_TOTAL_EXPECTED=10
VP_P0_EXPECTED=6
VP_P1_EXPECTED=4

if [[ ! -f "$VERIF_ARCH" ]]; then
  echo "    SKIP: verification-architecture.md not found at $VERIF_ARCH"
elif [[ ! -f "$VERIF_MATRIX" ]]; then
  echo "    SKIP: verification-coverage-matrix.md not found at $VERIF_MATRIX"
elif [[ ! -f "$VP_INDEX" ]]; then
  echo "    SKIP: VP-INDEX.md not found at $VP_INDEX"
else
  # ---- (g.i) Total/P0/P1 checks ----

  # VP-INDEX summary line: "Total: 10 VPs — 6 P0, 4 P1"
  vp_idx_summary=$(grep -E 'Total: [0-9]+ VPs' "$VP_INDEX" 2>/dev/null | head -1 || true)
  vp_idx_total=$(printf '%s' "$vp_idx_summary" \
    | awk '{for(i=1;i<=NF;i++) if($i~/^[0-9]+$/ && $(i+1)~/VPs/) {print $i; exit}}')
  vp_idx_p0=$(printf '%s' "$vp_idx_summary" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P0," || $i=="P0.") {print $(i-1); exit}}')
  vp_idx_p1=$(printf '%s' "$vp_idx_summary" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P1." || $i=="P1,") {print $(i-1); exit}}')

  # verification-architecture.md VP counts line:
  # "**VP counts: 10 total — 6 P0 (VP-001...), 4 P1 (...)**"
  va_counts_line=$(grep -E 'VP counts:.*total' "$VERIF_ARCH" 2>/dev/null | head -1 || true)
  va_total=$(printf '%s' "$va_counts_line" \
    | awk '{for(i=1;i<=NF;i++) if($i~/^[0-9]+$/ && $(i+1)~/total/) {print $i; exit}}')
  va_p0=$(printf '%s' "$va_counts_line" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P0" && $(i+1)~/^\(VP/) {print $(i-1); exit}}')
  va_p1=$(printf '%s' "$va_counts_line" \
    | awk '{for(i=1;i<=NF;i++) if($i=="P1" && $(i+1)~/^\(VP/) {print $(i-1); exit}}')

  # verification-coverage-matrix.md grand total row:
  # "| Grand total VP rows | 10 |"
  vm_total=$(grep -E '^\| Grand total VP rows' "$VERIF_MATRIX" 2>/dev/null \
    | awk -F'|' '{gsub(/ /,"",$3); print $3}' | head -1 || true)

  # ARCH-INDEX frontmatter (already parsed in check d, re-read for clarity):
  arch_vp_total_line=$(grep -E '^vp_total:' "$ARCH_INDEX" 2>/dev/null \
    | awk '{gsub(/[^0-9]/,"",$2); print $2}' | head -1 || true)

  echo "    VP-INDEX total stated:          ${vp_idx_total:-NOT_FOUND}"
  echo "    VP-INDEX P0 stated:             ${vp_idx_p0:-NOT_FOUND}"
  echo "    VP-INDEX P1 stated:             ${vp_idx_p1:-NOT_FOUND}"
  echo "    verif-arch total stated:        ${va_total:-NOT_FOUND}"
  echo "    verif-arch P0 stated:           ${va_p0:-NOT_FOUND}"
  echo "    verif-arch P1 stated:           ${va_p1:-NOT_FOUND}"
  echo "    verif-matrix grand total:       ${vm_total:-NOT_FOUND}"
  echo "    ARCH-INDEX vp_total:            ${arch_vp_total_line:-NOT_FOUND}"
  echo "    Expected: total=$VP_TOTAL_EXPECTED  P0=$VP_P0_EXPECTED  P1=$VP_P1_EXPECTED"
  echo ""

  # Assert all stated totals equal expected
  [[ -n "$vp_idx_total" ]] && check "VP total / VP-INDEX summary" \
    "$vp_idx_total" "$VP_TOTAL_EXPECTED" "VP-INDEX.md"
  [[ -n "$vp_idx_p0" ]] && check "VP P0 / VP-INDEX summary (g)" \
    "$vp_idx_p0" "$VP_P0_EXPECTED" "VP-INDEX.md"
  [[ -n "$vp_idx_p1" ]] && check "VP P1 / VP-INDEX summary (g)" \
    "$vp_idx_p1" "$VP_P1_EXPECTED" "VP-INDEX.md"
  [[ -n "$va_total" ]] && check "VP total / verification-architecture" \
    "$va_total" "$VP_TOTAL_EXPECTED" "verification-architecture.md"
  [[ -n "$va_p0" ]] && check "VP P0 / verification-architecture" \
    "$va_p0" "$VP_P0_EXPECTED" "verification-architecture.md"
  [[ -n "$va_p1" ]] && check "VP P1 / verification-architecture" \
    "$va_p1" "$VP_P1_EXPECTED" "verification-architecture.md"
  [[ -n "$vm_total" ]] && check "VP grand total / verification-coverage-matrix" \
    "$vm_total" "$VP_TOTAL_EXPECTED" "verification-coverage-matrix.md"
  [[ -n "$arch_vp_total_line" ]] && check "VP total / ARCH-INDEX vp_total" \
    "$arch_vp_total_line" "$VP_TOTAL_EXPECTED" "ARCH-INDEX.md"

  # ---- (g.ii) Per-tool count agreement ----
  # Both the verification-architecture.md VP Targets column AND the
  # verification-coverage-matrix.md tool summary table must state the same
  # per-tool counts. VP-001 uses Kani+proptest and is counted under BOTH tools
  # in the matrix. The architecture tooling table lists it under Kani only
  # (proptest row lists 6 VPs, matrix Kani column enumerates 4, matrix proptest
  # enumerates 7 including VP-001 dual-counted). We assert both docs match
  # canonical expected values: Kani=4, proptest=7.
  VM_KANI_EXPECTED=4
  VM_PROPTEST_EXPECTED=7

  # Parse VP Targets column from verification-architecture.md tooling table.
  # The Kani row lists VP-001, VP-002, VP-004, VP-008 (4 targets).
  va_kani_vps=$(grep -E '^\| \*\*Kani\*\*' "$VERIF_ARCH" 2>/dev/null \
    | grep -oE 'VP-[0-9]+' | sort -u | wc -l | tr -d '[:space:]' || true)

  # Parse Kani/proptest counts from verification-coverage-matrix.md tool summary table:
  # "| Kani | 4 (VP-001, VP-002, VP-004, VP-008) |"
  # Extract the first integer in the second data column ($3 when split by |).
  vm_kani_count=$(grep -E '^\| Kani ' "$VERIF_MATRIX" 2>/dev/null \
    | awk -F'|' '{match($3,/[0-9]+/); print substr($3,RSTART,RLENGTH)}' | head -1 || true)
  vm_proptest_count=$(grep -E '^\| proptest ' "$VERIF_MATRIX" 2>/dev/null \
    | awk -F'|' '{match($3,/[0-9]+/); print substr($3,RSTART,RLENGTH)}' | head -1 || true)

  echo "    Kani VP count (verif-arch VP Targets): ${va_kani_vps:-NOT_FOUND}  (expected: $VM_KANI_EXPECTED)"
  echo "    Kani VP count (verif-matrix table):    ${vm_kani_count:-NOT_FOUND}  (expected: $VM_KANI_EXPECTED)"
  echo "    proptest VP count (verif-matrix):      ${vm_proptest_count:-NOT_FOUND}  (expected: $VM_PROPTEST_EXPECTED)"
  echo "    Note: proptest=7 because VP-001 is dual-counted (Kani+proptest)."
  echo ""

  [[ -n "$va_kani_vps" ]] && check "Kani VP count / verif-arch VP Targets column" \
    "$va_kani_vps" "$VM_KANI_EXPECTED" "verification-architecture.md"
  [[ -n "$vm_kani_count" ]] && check "Kani VP count / verif-matrix tool table" \
    "$vm_kani_count" "$VM_KANI_EXPECTED" "verification-coverage-matrix.md"
  [[ -n "$vm_proptest_count" ]] && check "proptest VP count / verif-matrix tool table" \
    "$vm_proptest_count" "$VM_PROPTEST_EXPECTED" "verification-coverage-matrix.md"
fi

# ============================================================================
# (h) STUDIO-OF-AGENTS §3 PER-SS APPEARANCE COUNTS  [NEW v1.4]
# ============================================================================
# Assert the §3 table totals in studio-of-agents.md match the canonical values
# derived from the §2 roster (counting rule: each role counted under every SS-NN
# listed in its row). Expected totals (ADAPT+NEW):
#   SS-03=15  SS-04=24  SS-05=6  SS-06=3  SS-07=3  SS-08=12
#   SS-09=2   SS-10=5   SS-11=10 SS-12=1  SS-13=1
# v1.28 (F34-02): lipsync-animator role 54 moved SS-03→SS-04;
#   SS-03 corrected 16→15; SS-04 corrected 23→24.
# v1.13 (Pass-13 C13-01): SS-11 corrected 11→10 (role 58 moved SS-11→SS-13);
#   SS-13 added (online-services-adapter; backend-services-engineer role 58).
# §6 tier subtotals: Tier 1=53, Tier 2=13, sum line "53 + 13 = 66".
#
# Strategy: parse the §3 table rows by looking for "| SS-NN |" lines and
# extracting the "Total appearances" column (field 5). Parse §6 tier rows for
# the parenthesized count. POSIX/BSD grep compatible.
echo "--- (h) studio-of-agents §3 per-SS appearance counts and §6 tier subtotals ---"

if [[ ! -f "$STUDIO_AGENTS" ]]; then
  echo "    SKIP: studio-of-agents.md not found at $STUDIO_AGENTS"
else
  # Expected per-SS total appearances (ADAPT + NEW combined)
  # Format: "SS-NN:expected"
  # v1.28 (F34-02): lipsync-animator moved SS-03→SS-04; SS-03 16→15, SS-04 23→24.
  declare -a SS_EXPECTED=(
    "SS-03:15"
    "SS-04:24"
    "SS-05:6"
    "SS-06:3"
    "SS-07:3"
    "SS-08:12"
    "SS-09:2"
    "SS-10:5"
    "SS-11:10"
    "SS-12:1"
    "SS-13:1"
  )

  for entry in "${SS_EXPECTED[@]}"; do
    ss_id="${entry%%:*}"
    expected="${entry##*:}"
    # Parse total from §3 table row: "| SS-NN | Name | ADAPT | NEW | TOTAL ... |"
    # Field 5 after splitting by | (leading | makes field 1 empty, then: 2=SS, 3=Name,
    # 4=ADAPT, 5=NEW, 6=Total). Extract the first integer in field 6.
    stated_total=$(grep -E "^\| ${ss_id} \|" "$STUDIO_AGENTS" 2>/dev/null \
      | awk -F'|' '{match($6,/[0-9]+/); if(RLENGTH>0) print substr($6,RSTART,RLENGTH)}' \
      | head -1 || true)

    if [[ -n "$stated_total" ]]; then
      check "studio §3 ${ss_id} total appearances" "$stated_total" "$expected" "studio-of-agents.md"
      if [[ "$VERBOSE" == true ]] && [[ "$stated_total" == "$expected" ]]; then
        echo "    OK [studio §3 ${ss_id}]: stated=$stated_total expected=$expected"
      fi
    else
      if [[ "$VERBOSE" == true ]]; then
        echo "    SKIP [studio §3 ${ss_id}]: row not found in §3 table"
      fi
    fi
  done

  # §6 Tier subtotals: parse "| Tier 1 — v1 Core | ... (53 roles) |" and
  # "| Tier 2 — Genre-Gated | ... (13 roles) |" rows.
  # Extract the parenthesized number from field 3 (the agent list column).
  tier1_stated=$(grep -E "Tier 1" "$STUDIO_AGENTS" 2>/dev/null \
    | grep -v '^>' | grep -E '\([0-9]+ roles\)' \
    | awk '{match($0,/\([0-9]+/); print substr($0,RSTART+1,RLENGTH-1)}' \
    | head -1 || true)
  tier2_stated=$(grep -E "Tier 2" "$STUDIO_AGENTS" 2>/dev/null \
    | grep -v '^>' | grep -E '\([0-9]+ roles\)' \
    | awk '{match($0,/\([0-9]+/); print substr($0,RSTART+1,RLENGTH-1)}' \
    | head -1 || true)

  # §6 summary line: "Tier 1 + Tier 2 = 53 + 13 = 66"
  tier_sum_line=$(grep -E 'Tier 1 \+ Tier 2' "$STUDIO_AGENTS" 2>/dev/null | head -1 || true)
  tier_sum_total=$(printf '%s' "$tier_sum_line" \
    | awk '{n=split($0,a,"="); gsub(/ /,"",a[n]); gsub(/\./,"",a[n]); print a[n]+0}' || true)

  echo "    §6 Tier 1 stated: ${tier1_stated:-NOT_FOUND}  (expected: 53)"
  echo "    §6 Tier 2 stated: ${tier2_stated:-NOT_FOUND}  (expected: 13)"
  echo "    §6 sum line total: ${tier_sum_total:-NOT_FOUND}  (expected: 66)"
  echo ""

  [[ -n "$tier1_stated" ]] && check "studio §6 Tier 1 count" "$tier1_stated" "53" "studio-of-agents.md"
  [[ -n "$tier2_stated" ]] && check "studio §6 Tier 2 count" "$tier2_stated" "13" "studio-of-agents.md"
  [[ -n "$tier_sum_total" ]] && [[ "$tier_sum_total" != "0" ]] && \
    check "studio §6 Tier 1+2 sum" "$tier_sum_total" "66" "studio-of-agents.md"
fi
echo ""

# ============================================================================
# (i) SUBSYSTEM-DECOMPOSITION PRIORITY SUBTOTALS  [REWRITTEN v1.5]
# ============================================================================
# Assert P0, P1, P2 subtotals STATED in §Subsystem Priority Summary equal the
# counts COMPUTED by scanning BC frontmatter files at runtime.
#
# The BC frontmatter is authoritative (source of truth). No hardcoded expected
# values — this guards against false-greens that occur when frontmatter is
# updated but the stated table is not (I6-01 process-gap).
#
# Computed counts: count lines matching `^priority: P0|P1|P2` across all BC
# files under BC_DIR. This reuses the same find+grep pattern as check (c).
# POSIX/BSD grep compatible (no -P; uses -E only).
#
# Stated counts: parsed from the Priority Summary table in subsystem-decomposition.md
# rows: "| P0 ... | ... | NNN (...) |" — first integer in the BC Count column.
echo "--- (i) subsystem-decomposition priority subtotals (computed vs stated) ---"

if [[ ! -f "$SUBDECOMP" ]]; then
  echo "    SKIP: subsystem-decomposition.md not found at $SUBDECOMP"
else
  # --- Step 1: Compute P0/P1/P2 counts from BC frontmatter files ---
  # Count lines matching `^priority: P0` etc. across all BC files.
  # Using find+xargs+grep to stay POSIX/BSD compatible.
  computed_frontmatter_p0=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" \
    -exec grep -lE '^priority:[[:space:]]*P0' {} \; 2>/dev/null | wc -l | tr -d '[:space:]')
  computed_frontmatter_p1=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" \
    -exec grep -lE '^priority:[[:space:]]*P1' {} \; 2>/dev/null | wc -l | tr -d '[:space:]')
  computed_frontmatter_p2=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" \
    -exec grep -lE '^priority:[[:space:]]*P2' {} \; 2>/dev/null | wc -l | tr -d '[:space:]')
  computed_frontmatter_grand=$(( computed_frontmatter_p0 + computed_frontmatter_p1 + computed_frontmatter_p2 ))

  # --- Step 2: Parse stated P0/P1/P2 counts from subsystem-decomposition.md ---
  # The Priority Summary table has rows like:
  # "| P0 (must ship v1) | SS-01, ... | 117 (SS-01=41, ...) |"
  # Extract the first integer in field 4 (the BC Count column).
  subdecomp_p0=$(grep -E '^\| P0 ' "$SUBDECOMP" 2>/dev/null \
    | awk -F'|' '{match($4,/[0-9]+/); print substr($4,RSTART,RLENGTH)+0}' \
    | head -1 || true)
  subdecomp_p1=$(grep -E '^\| P1 ' "$SUBDECOMP" 2>/dev/null \
    | awk -F'|' '{match($4,/[0-9]+/); print substr($4,RSTART,RLENGTH)+0}' \
    | head -1 || true)
  subdecomp_p2=$(grep -E '^\| P2 ' "$SUBDECOMP" 2>/dev/null \
    | awk -F'|' '{match($4,/[0-9]+/); print substr($4,RSTART,RLENGTH)+0}' \
    | head -1 || true)
  # Grand total row: "| **Total** | | **178** |"
  subdecomp_grand=$(grep -E '^\| \*\*Total\*\*' "$SUBDECOMP" 2>/dev/null \
    | awk -F'|' '{match($4,/[0-9]+/); print substr($4,RSTART,RLENGTH)+0}' \
    | head -1 || true)

  echo "    Computed P0 (BC frontmatter): $computed_frontmatter_p0"
  echo "    Computed P1 (BC frontmatter): $computed_frontmatter_p1"
  echo "    Computed P2 (BC frontmatter): $computed_frontmatter_p2"
  echo "    Computed P0+P1+P2 sum:        $computed_frontmatter_grand"
  echo "    Stated P0 (subdecomp table):  ${subdecomp_p0:-NOT_FOUND}"
  echo "    Stated P1 (subdecomp table):  ${subdecomp_p1:-NOT_FOUND}"
  echo "    Stated P2 (subdecomp table):  ${subdecomp_p2:-NOT_FOUND}"
  echo "    Stated grand total:           ${subdecomp_grand:-NOT_FOUND}"

  # --- Step 3: Assert stated subtotals equal computed frontmatter counts ---
  # The stated table must reflect the frontmatter. Any divergence is a drift defect.
  if [[ -n "$subdecomp_p0" ]] && [[ -n "$subdecomp_p1" ]] && [[ -n "$subdecomp_p2" ]]; then
    stated_priority_sum=$(( subdecomp_p0 + subdecomp_p1 + subdecomp_p2 ))
    echo "    Stated P0+P1+P2 sum:          $stated_priority_sum"
    # The stated sum must equal the computed grand total
    check "subdecomp stated P0+P1+P2 sum vs computed grand total" \
      "$stated_priority_sum" "$computed_frontmatter_grand" "subsystem-decomposition.md"
  fi
  echo ""

  # Assert each stated subtotal matches its computed counterpart
  [[ -n "$subdecomp_p0" ]] && check "subdecomp P0 stated vs computed frontmatter" \
    "$subdecomp_p0" "$computed_frontmatter_p0" "subsystem-decomposition.md"
  [[ -n "$subdecomp_p1" ]] && check "subdecomp P1 stated vs computed frontmatter" \
    "$subdecomp_p1" "$computed_frontmatter_p1" "subsystem-decomposition.md"
  [[ -n "$subdecomp_p2" ]] && check "subdecomp P2 stated vs computed frontmatter" \
    "$subdecomp_p2" "$computed_frontmatter_p2" "subsystem-decomposition.md"
  # Also assert stated grand total equals BC file count (cross-check with check a)
  [[ -n "$subdecomp_grand" ]] && check "subdecomp grand total vs computed BC count" \
    "$subdecomp_grand" "$computed_bc" "subsystem-decomposition.md"
fi
echo ""

# ============================================================================
# (j) FORMAL VP ↔ BC BIDIRECTIONAL ANCHOR  [NEW v1.4]
# ============================================================================
# Assert that every formal VP's guarded BC cites the VP back.
# This check WILL FAIL until PO adds back-references (I2 fix in VP-INDEX.md).
# Implemented now so it becomes green automatically after PO work.
#
# Pairs to check (VP-ID → BC file path relative to BC_DIR):
#   VP-001 → ss-06/BC-6.01.001.md
#   VP-002 → ss-06/BC-6.01.003.md
#   VP-003 → ss-06/BC-6.02.003.md
#   VP-004 → ss-06/BC-6.02.004.md
#   VP-005 → ss-13/BC-13.02.001.md  (checks for VP-005 OR VP-006 OR VP-007)
#   VP-006 → ss-13/BC-13.02.001.md  (same file, three VPs)
#   VP-007 → ss-13/BC-13.02.001.md  (same file)
#   VP-008 → ss-03/BC-3.03.001.md AND ss-03/BC-3.03.002.md
#   VP-009 → ss-06/BC-6.01.002.md
#   VP-010 → ss-13/BC-13.02.005.md
#
# A BC "cites" a VP when the string "VP-00N" (or "VP-01N") appears in the file.
# We do NOT require a specific field name — any occurrence in the file counts.
echo "--- (j) formal VP ↔ BC bidirectional anchor ---"

if [[ ! -f "$VP_INDEX" ]]; then
  echo "    SKIP: VP-INDEX.md not found"
else
  # Array of "VP-ID:relative/path/to/bc.md" pairs
  declare -a VP_BC_PAIRS=(
    "VP-001:ss-06/BC-6.01.001.md"
    "VP-002:ss-06/BC-6.01.003.md"
    "VP-003:ss-06/BC-6.02.003.md"
    "VP-004:ss-06/BC-6.02.004.md"
    "VP-005:ss-13/BC-13.02.001.md"
    "VP-006:ss-13/BC-13.02.001.md"
    "VP-007:ss-13/BC-13.02.001.md"
    "VP-008-a:ss-03/BC-3.03.001.md:VP-008"
    "VP-008-b:ss-03/BC-3.03.002.md:VP-008"
    "VP-009:ss-06/BC-6.01.002.md"
    "VP-010:ss-13/BC-13.02.005.md"
  )

  vp_bc_failures=0
  vp_bc_issues=()

  for entry in "${VP_BC_PAIRS[@]}"; do
    # Entry format: "VP-NNN:relative/path" or "VP-NNN-suffix:relative/path:actual-vp-id"
    label="${entry%%:*}"
    rest="${entry#*:}"
    bc_rel="${rest%%:*}"
    # If there's a third colon-segment, it's the actual VP id to search for
    actual_vp="${rest##*:}"
    if [[ "$actual_vp" == "$bc_rel" ]]; then
      # No third segment: actual_vp = label itself (strip any -a/-b suffix)
      actual_vp=$(printf '%s' "$label" | sed 's/-[ab]$//')
    fi

    bc_full="$BC_DIR/$bc_rel"

    if [[ ! -f "$bc_full" ]]; then
      # BC file not present — skip (may be future BC)
      if [[ "$VERBOSE" == true ]]; then
        echo "    SKIP [$label]: BC file not found: $bc_rel"
      fi
      continue
    fi

    # Check if the BC file contains a back-reference to the VP id
    if grep -qE "${actual_vp}[^0-9]|${actual_vp}$" "$bc_full" 2>/dev/null; then
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [$label]: $bc_rel cites $actual_vp"
      fi
    else
      vp_bc_failures=$(( vp_bc_failures + 1 ))
      vp_bc_issues+=("$actual_vp → $bc_rel: BC does not cite $actual_vp (PO back-reference pending)")
    fi
  done

  echo "    VP↔BC back-reference checks: ${#VP_BC_PAIRS[@]} pairs"
  echo "    Missing back-references: $vp_bc_failures"

  if [[ $vp_bc_failures -gt 0 ]]; then
    echo ""
    echo "    MISSING VP BACK-REFERENCES (PO action required per VP-INDEX.md §I2):"
    for issue in "${vp_bc_issues[@]}"; do
      echo "      $issue"
    done
    errors+=("MISMATCH [VP↔BC bidirectional anchor (j)]: $vp_bc_failures BC file(s) missing VP back-reference — PO must add per VP-INDEX.md §I2 table")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (k) ERROR-IDENTIFIER RESOLUTION + LABEL MATCH  [NEW v1.5; EXTENDED v1.14]
# ============================================================================
# (k.i)  [v1.5] Assert every E-[A-Z]+-[0-9]+ token in any BC resolves to a
#        registered code in error-taxonomy.md. Unregistered codes are reported.
#        WILL FAIL until PO registers all pending codes. Becomes green after PO
#        work without script changes.
#
# (k.ii) [NEW v1.14, C14-02] Label-match sub-check: for each occurrence of the
#        form "E-<FAMILY>-<NNN> (<Label>)" in any BC, look up the registered
#        Category/name for that code in error-taxonomy.md and assert the BC's
#        <Label> is non-contradictory with the registered category.
#
#        SCOPE: The check targets the two families where BCs consistently attach
#        CamelCase labels:
#          E-EAP  — column layout: | Code | JSONCode | CamelCaseName | ... |
#                   The 3rd column is the authoritative CamelCase name. The BC
#                   label is expected to match it exactly (after normalization).
#          E-OSVC — column layout: | Code | ShortDescription | Severity | ... |
#                   The 2nd column is the short description (prose). BCs derive
#                   a CamelCase label from it. Contradiction is detected by
#                   normalized word-overlap check (no significant words from the
#                   BC label must be absent from the registered description).
#
#        Other families are not scoped because their taxonomy Category columns
#        are prose sentences or symbolic SCREAMING_SNAKE_CASE sub-codes (E-ETH)
#        whose label conventions differ from the CamelCase form used in E-EAP/
#        E-OSVC. Scoping prevents false positives on 30+ other families.
#
#        NORMALIZATION strategy (POSIX/BSD-grep compatible; no -P):
#        1. Strip leading/trailing whitespace, backticks, underscores.
#        2. Lowercase both the BC label and the taxonomy category string.
#        3. For E-EAP: require the lowercased BC label to match the lowercased
#           CamelCase name from column 3 exactly (case-fold only; no word split).
#           E.g., BC "CapabilityUnsupported" folds to "capabilityunsupported";
#           taxonomy col3 "CapabilityUnsupported" folds to "capabilityunsupported"
#           — match. If the folded strings differ, it is a mismatch.
#        4. For E-OSVC: split the BC label's significant words by CamelCase
#           boundary (insert spaces before uppercase letters, then lowercase).
#           Check that every significant word from the BC label appears as a
#           substring in the lowercased taxonomy description. A word is
#           "significant" if it has 4+ characters (excludes "by", "in", "or").
#           E.g., BC label "UnsupportedAuthProvider" → words ["unsupported",
#           "auth", "provider"]; taxonomy "Score rejected by server" does NOT
#           contain "unsupported" → FAIL.
#           E.g., BC label "ScoreRejectedByServer" → words ["score", "rejected",
#           "server"]; taxonomy "Score rejected by server" contains all three →
#           PASS.
#
#        WILL FAIL until PO completes C14-01 re-citation fix (E-OSVC-003
#        UnsupportedAuthProvider → E-OSVC-013 in BC-15.02.001 and related BCs).
#        Implemented now so it becomes green automatically after PO work.
#
#        POSITIVE COVERAGE LOG: always prints the count of validated citations
#        ("Check (k) label-match: N E-code label citations validated against
#        taxonomy categories.") to detect a zero-scan (inert) run.
#
# POSIX/BSD grep compatible (no -P; uses -E and -o only).
echo "--- (k) error-identifier resolution (BC refs vs error-taxonomy.md) ---"

if [[ ! -f "$ERROR_TAX" ]]; then
  echo "    SKIP: error-taxonomy.md not found at $ERROR_TAX"
else
  # Build sorted unique list of registered error codes from taxonomy
  registered_codes=$(grep -oE 'E-[A-Z]+-[0-9]+' "$ERROR_TAX" 2>/dev/null | sort -u || true)

  # Collect all E-[A-Z]+-[0-9]+ tokens referenced across all BC files
  bc_referenced_codes=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" \
    -exec grep -ohE 'E-[A-Z]+-[0-9]+' {} \; 2>/dev/null | sort -u || true)

  echo "    Registered codes in error-taxonomy.md: $(printf '%s\n' "$registered_codes" | grep -c . 2>/dev/null || echo 0)"
  echo "    Distinct E-codes referenced across BC files: $(printf '%s\n' "$bc_referenced_codes" | grep -c . 2>/dev/null || echo 0)"

  # --- (k.i) Unregistered-code check ---
  unregistered_codes=()
  if [[ -n "$bc_referenced_codes" ]]; then
    while IFS= read -r code; do
      [[ -z "$code" ]] && continue
      if ! printf '%s\n' "$registered_codes" | grep -qF "$code" 2>/dev/null; then
        unregistered_codes+=("$code")
      fi
    done <<< "$bc_referenced_codes"
  fi

  echo "    Unregistered codes found: ${#unregistered_codes[@]}"

  if [[ ${#unregistered_codes[@]} -gt 0 ]]; then
    echo ""
    echo "    UNREGISTERED ERROR CODES (must be added to error-taxonomy.md):"
    for code in "${unregistered_codes[@]}"; do
      # Find which BC files reference this code
      bc_files_with_code=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" \
        -exec grep -lE "${code}([^0-9]|$)" {} \; 2>/dev/null \
        | awk -F'/' '{print $(NF-1)"/"$NF}' | tr '\n' ' ')
      echo "      $code  (referenced in: $bc_files_with_code)"
    done
    errors+=("MISMATCH [error-identifier resolution (k)]: ${#unregistered_codes[@]} E-code(s) referenced in BCs are not registered in error-taxonomy.md — PO must register (see list above)")
    fail=1
  fi

  # --- (k.ii) Label-match sub-check [NEW v1.14] ---
  # Scoped to E-EAP and E-OSVC families only (see design rationale in header above).
  echo ""
  echo "--- (k.ii) label-match: BC parenthetical labels vs registered taxonomy categories ---"
  echo "    Scope: E-EAP (exact CamelCase name match) + E-OSVC (word-overlap match)"

  # Build E-EAP code → CamelCase name map.
  # Taxonomy row format: | E-EAP-NNN | JSONCode | CamelCaseName | Description | Severity |
  # awk field $4 (1-indexed, leading | makes $1 empty): CamelCaseName column.
  declare -A EAP_NAMES
  while IFS= read -r row; do
    code=$(printf '%s' "$row" | awk -F'|' '{gsub(/[[:space:]]/,"",$2); print $2}')
    name=$(printf '%s' "$row" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$4); print $4}')
    if printf '%s' "$code" | grep -qE '^E-EAP-[0-9]+$' 2>/dev/null && [[ -n "$name" ]]; then
      EAP_NAMES["$code"]="$name"
    fi
  done < <(grep -E '^\| E-EAP-[0-9]+' "$ERROR_TAX" 2>/dev/null || true)

  # Build E-OSVC code → short description map.
  # Taxonomy row format: | E-OSVC-NNN | Short description | Severity | ExitCode | ... |
  # awk field $3 (1-indexed): short description column.
  declare -A OSVC_DESC
  while IFS= read -r row; do
    code=$(printf '%s' "$row" | awk -F'|' '{gsub(/[[:space:]]/,"",$2); print $2}')
    desc=$(printf '%s' "$row" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}')
    if printf '%s' "$code" | grep -qE '^E-OSVC-[0-9]+$' 2>/dev/null && [[ -n "$desc" ]]; then
      OSVC_DESC["$code"]="$desc"
    fi
  done < <(grep -E '^\| E-OSVC-[0-9]+' "$ERROR_TAX" 2>/dev/null || true)

  klabel_violations=0
  klabel_violation_msgs=()
  klabel_validated=0

  while IFS= read -r -d $'\0' bc_file; do
    bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

    # Extract all "E-FAMILY-NNN (Label)" patterns from this BC file.
    # Use grep -oE to extract each full match, then parse code and label.
    # Pattern: E-EAP-NNN or E-OSVC-NNN followed by optional whitespace, open-paren,
    # a label string of word chars/backticks/slashes/hyphens, close-paren.
    # POSIX/BSD-grep: use -E -o only; no -P. Match up to 60 chars inside parens.
    # We use two passes: one for E-EAP, one for E-OSVC.

    # Pass 1: E-EAP labels
    # Exclude lines containing "mis-citation" (YAML frontmatter changelog entries
    # that document a historical error-code fix — not operative BC body content).
    eap_cited=$(grep -E 'E-EAP-[0-9]+[[:space:]]*\(' "$bc_file" 2>/dev/null \
      | grep -v 'mis-citation' \
      | grep -oE 'E-EAP-[0-9]+[[:space:]]*\([^)]{1,80}\)' \
      || true)
    while IFS= read -r citation; do
      [[ -z "$citation" ]] && continue
      cited_code=$(printf '%s' "$citation" | grep -oE 'E-EAP-[0-9]+')
      # Extract the first CamelCase token only (content inside parens, up to the
      # first space character). This avoids absorbing extra prose like
      # "(HumanGatedTaskPending for human-gated path)" → "HumanGatedTaskPending".
      paren_content=$(printf '%s' "$citation" \
        | sed 's/E-EAP-[0-9]*[[:space:]]*//' \
        | sed 's/^(//' | sed 's/)$//' \
        | sed 's/`//g')
      # Take only the first whitespace-delimited token (the CamelCase name)
      cited_label=$(printf '%s' "$paren_content" | awk '{print $1}' | tr -d '[:space:]')
      [[ -z "$cited_code" || -z "$cited_label" ]] && continue
      registered_name="${EAP_NAMES[$cited_code]:-}"
      [[ -z "$registered_name" ]] && continue  # code not found — already caught by k.i
      klabel_validated=$(( klabel_validated + 1 ))
      # Normalize: lowercase, strip non-alphanumeric
      label_norm=$(printf '%s' "$cited_label" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
      reg_norm=$(printf '%s' "$registered_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
      if [[ "$label_norm" != "$reg_norm" ]]; then
        klabel_violations=$(( klabel_violations + 1 ))
        klabel_violation_msgs+=("${bc_rel}: ${cited_code} BC-label='${cited_label}' vs registered CamelCase='${registered_name}' (normalized: '${label_norm}' != '${reg_norm}')")
      fi
    done <<< "$eap_cited"

    # Pass 2: E-OSVC labels
    # Exclude lines containing "mis-citation" (same YAML frontmatter exclusion as pass 1).
    osvc_cited=$(grep -E 'E-OSVC-[0-9]+[[:space:]]*\(' "$bc_file" 2>/dev/null \
      | grep -v 'mis-citation' \
      | grep -oE 'E-OSVC-[0-9]+[[:space:]]*\([^)]{1,60}\)' \
      || true)
    while IFS= read -r citation; do
      [[ -z "$citation" ]] && continue
      cited_code=$(printf '%s' "$citation" | grep -oE 'E-OSVC-[0-9]+')
      cited_label=$(printf '%s' "$citation" \
        | sed 's/E-OSVC-[0-9]*[[:space:]]*//' \
        | sed 's/^(//' | sed 's/)$//' \
        | sed 's/`//g' | tr -d '[:space:]')
      [[ -z "$cited_code" || -z "$cited_label" ]] && continue
      registered_desc="${OSVC_DESC[$cited_code]:-}"
      [[ -z "$registered_desc" ]] && continue  # code not found — already caught by k.i
      klabel_validated=$(( klabel_validated + 1 ))
      # Word-overlap normalization for E-OSVC:
      # 1. Split BC label by CamelCase boundary: insert space before each uppercase
      #    letter that follows a lowercase letter, then lowercase the whole string.
      #    awk does not support lookahead; use a character-level approach:
      #    for each character, if it is uppercase and the previous was lowercase,
      #    prepend a space. POSIX/BSD awk compatible.
      label_words=$(printf '%s' "$cited_label" \
        | awk '{
            out=""
            for(i=1;i<=length($0);i++){
              c=substr($0,i,1)
              if(c~/[A-Z]/ && i>1 && substr($0,i-1,1)~/[a-z]/){out=out" "}
              out=out c
            }
            print tolower(out)
          }' \
        | grep -oE '[a-z]{4,}' \
        | sort -u || true)
      reg_lower=$(printf '%s' "$registered_desc" | tr '[:upper:]' '[:lower:]')
      # Check each significant word from the label appears in the registered description
      mismatch_words=()
      while IFS= read -r word; do
        [[ -z "$word" ]] && continue
        if ! printf '%s' "$reg_lower" | grep -qF "$word" 2>/dev/null; then
          mismatch_words+=("$word")
        fi
      done <<< "$label_words"
      if [[ ${#mismatch_words[@]} -gt 0 ]]; then
        klabel_violations=$(( klabel_violations + 1 ))
        klabel_violation_msgs+=("${bc_rel}: ${cited_code} BC-label='${cited_label}' — significant word(s) [${mismatch_words[*]}] not found in registered description '${registered_desc}'")
      fi
    done <<< "$osvc_cited"

  done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

  # Positive-coverage log line (always printed)
  echo "    Check (k) label-match: $klabel_validated E-code label citations validated against taxonomy categories."
  echo "    Label-match violations found: $klabel_violations"

  if [[ $klabel_violations -gt 0 ]]; then
    echo ""
    echo "    LABEL MISMATCHES (BC parenthetical label contradicts registered taxonomy category):"
    for msg in "${klabel_violation_msgs[@]}"; do
      echo "      $msg"
    done
    errors+=("MISMATCH [error-label contradiction (k.ii)]: $klabel_violations BC(s) cite an E-code with a label that contradicts the registered category in error-taxonomy.md — EXPECTED: await PO C14-01 re-citation fix (see list above)")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (o) SEAM-COUNT CONSISTENCY  [NEW v1.14, O14-01; EXTENDED v1.25, I31-01]
# ============================================================================
# Prevent recurrence of the I14-01 class: spec files retaining "four adapter
# seam" or "four-seam adapter" phrasing after the online-services seam (SS-13)
# was added in Pass-13, making the correct count "five adapter seams".
#
# Strategy: FAIL if any spec file in the scoped set contains the pattern
# "four adapter seam" or "four-seam adapter" (case-insensitive) outside a
# changelog/reason line.
#
# Scoped spec files (those that describe the adapter seam count):
#   - ARCH-INDEX.md (ADR registry + Document Map)
#   - ADR-0004-adapter-family-anti-lock-in.md (primary adapter-seam ADR)
#   - capabilities.md (domain-spec)
#   - invariants.md (domain-spec)
#   - prd.md
#   - product-brief.md
#
# Changelog exclusion: lines starting with ">" (blockquote / changelog prose)
# or containing "reason:" (YAML lifecycle) are excluded — historical references
# like "> reconciled from four-seam" are acceptable in changelog lines.
#
# This check WILL FAIL if any of the scoped files still contains stale "four"
# phrasing in operative content. It becomes green once the PO completes prose
# updates in prd.md/product-brief.md/capabilities.md/invariants.md (those files
# are not touched here per constraint; their green status awaits PO work).
#
# [v1.25 EXTENSION — (o.ii) Canon-KB load-bearing-seam ordinal guard (I31-01)]
# Assert that any operative line (excl ">" blockquote / "reason:" lines) in the
# spec tree that references a "load-bearing seam" with an explicit ordinal uses
# "sixth" — never "fifth" or any other ordinal. This closes the I31-01 class:
# Pass-14 O14-02 set Canon-KB to "sixth" in authoritative docs but left "fifth"
# in several architecture section files.
#
# Pattern: any word from the set (first|second|third|fourth|fifth|seventh|
# eighth|ninth|tenth) immediately preceding "load-bearing seam" — case-insensitive.
# "sixth load-bearing seam" does NOT match (correct — passes silently).
#
# Sub-assertion (o.ii.b): any line that both references the product-brief AND
# contains an ordinal-applied "load-bearing seam" attribution must use "sixth"
# (the brief line 111 reads "sixth load-bearing seam"). A line attributing a
# non-sixth ordinal to the brief is a false citation.
#
# Scoped files: all architecture/*.md + ADR files, domain-spec/*.md, prd.md,
# prd-supplements/prd-cap-*.md, product-brief.md.
# Exclusions: lines starting with ">" and lines containing "reason:".
# WILL FAIL until PO fixes capabilities.md and prd-cap-008-012.md; expected.
#
# Positive-coverage log: "Check (o.ii): N files scanned for Canon-KB ordinal;
# K wrong-ordinal violations found." always printed.
#
# POSIX/BSD grep compatible; no grep -P.
echo "--- (o) seam-count consistency: no stale 'four adapter seam' / 'four-seam adapter' in operative content ---"

DOMAIN_SPEC_DIR="$REPO_ROOT/.factory/specs/domain-spec"
ADR_0004="$REPO_ROOT/.factory/specs/architecture/adrs/ADR-0004-adapter-family-anti-lock-in.md"

# Files to check — only those that describe the adapter seam count
seam_check_files=(
  "$ARCH_INDEX"
  "$ADR_0004"
)
# Add domain-spec and prd files if they exist
[[ -f "$DOMAIN_SPEC_DIR/capabilities.md" ]] && seam_check_files+=("$DOMAIN_SPEC_DIR/capabilities.md")
[[ -f "$DOMAIN_SPEC_DIR/invariants.md" ]] && seam_check_files+=("$DOMAIN_SPEC_DIR/invariants.md")
[[ -f "$PRD" ]] && seam_check_files+=("$PRD")
[[ -f "$REPO_ROOT/.factory/specs/product-brief.md" ]] && seam_check_files+=("$REPO_ROOT/.factory/specs/product-brief.md")

seam_violations=0
seam_violation_msgs=()

for seam_file in "${seam_check_files[@]}"; do
  [[ ! -f "$seam_file" ]] && continue
  file_label=$(printf '%s' "$seam_file" | awk -F'/' '{print $(NF-1)"/"$NF}')

  # Grep for the stale patterns, case-insensitive.
  # Exclude changelog/reason lines:
  #   (a) Lines starting with ">" (blockquote / changelog prose).
  #   (b) Lines containing "reason:" (YAML lifecycle prose).
  #   (c) Lines that contain the pattern in a change-description context:
  #       the phrase appears alongside "to" + "five" (e.g., 'updated from
  #       "four adapter seams" to "five adapter seams"' in version tables).
  #       This excludes changelog table rows that describe the seam-count fix
  #       without flagging false positives on genuine stale content.
  # BSD grep -i: case-insensitive. -E: extended regex. POSIX compatible.
  stale_lines=$(grep -inE 'four[[:space:]]+adapter[[:space:]]+seam|four-seam[[:space:]]+adapter' \
    "$seam_file" 2>/dev/null \
    | grep -v '^[0-9]*:>[[:space:]]' \
    | grep -v 'reason:' \
    | grep -viE '"four[[:space:]]+adapter[[:space:]]+seam"[[:space:]]to[[:space:]]"five|four[[:space:]]+adapter[[:space:]]+seam.*to[[:space:]].*five[[:space:]]+adapter' \
    || true)

  if [[ -n "$stale_lines" ]]; then
    seam_violations=$(( seam_violations + 1 ))
    # Collect the offending line numbers for the report
    stale_summary=$(printf '%s' "$stale_lines" | head -3 | tr '\n' ';')
    seam_violation_msgs+=("${file_label}: stale 'four adapter seam' / 'four-seam adapter' in operative content: ${stale_summary}")
  fi
done

echo "    Files scanned for stale four-seam phrasing: ${#seam_check_files[@]}"
echo "    Files with stale phrasing in operative content: $seam_violations"

if [[ $seam_violations -gt 0 ]]; then
  echo ""
  echo "    STALE SEAM-COUNT PHRASING (must be updated to 'five adapter seams' per ADR-0004 v1.2):"
  for msg in "${seam_violation_msgs[@]}"; do
    echo "      $msg"
  done
  errors+=("MISMATCH [seam-count consistency (o)]: $seam_violations file(s) contain stale 'four adapter seam' / 'four-seam adapter' in operative content — EXPECTED: await PO updates in domain-spec/prd/product-brief prose; architect files (ARCH-INDEX, ADR-0004) must be clean immediately")
  fail=1
fi
echo ""

# ----------------------------------------------------------------------------
# (o.ii) Canon-KB load-bearing-seam ordinal guard  [NEW v1.25, I31-01]
# ----------------------------------------------------------------------------
# Assert any operative line containing "<ordinal> load-bearing seam" (where
# ordinal is NOT "sixth") is a violation.  "sixth load-bearing seam" passes.
# Exclusions: lines starting with ">" and lines containing "reason:".
# Scope: architecture/*.md (including ADR subdir), domain-spec/*.md, prd.md,
# prd-supplements/prd-cap-*.md, product-brief.md.
#
# WILL FAIL until PO fixes domain-spec/capabilities.md and
# prd-supplements/prd-cap-008-012.md (those files are PO-owned; expected).
# Architect files (layered-architecture, methodology-layer, subsystem-decomposition)
# must already be clean after this pass.
echo "--- (o.ii) Canon-KB load-bearing-seam ordinal guard: only 'sixth' allowed ---"

# Build the set of files to scan for (o.ii)
ordinal_check_files=()

# All architecture/*.md files (flat and one level deep for ADRs)
while IFS= read -r f; do
  ordinal_check_files+=("$f")
done < <(find "$REPO_ROOT/.factory/specs/architecture" -name "*.md" 2>/dev/null | sort || true)

# domain-spec files
[[ -f "$DOMAIN_SPEC_DIR/capabilities.md" ]] && ordinal_check_files+=("$DOMAIN_SPEC_DIR/capabilities.md")
[[ -f "$DOMAIN_SPEC_DIR/invariants.md" ]] && ordinal_check_files+=("$DOMAIN_SPEC_DIR/invariants.md")

# prd.md and product-brief.md
[[ -f "$PRD" ]] && ordinal_check_files+=("$PRD")
[[ -f "$REPO_ROOT/.factory/specs/product-brief.md" ]] && ordinal_check_files+=("$REPO_ROOT/.factory/specs/product-brief.md")

# prd-supplements/prd-cap-*.md
while IFS= read -r f; do
  ordinal_check_files+=("$f")
done < <(find "$PRD_SUPPLEMENTS_DIR" -name "prd-cap-*.md" 2>/dev/null | sort || true)

ordinal_violations=0
ordinal_violation_msgs=()
ordinal_files_scanned=0

# Wrong-ordinal pattern: any ordinal word EXCEPT "sixth" immediately before
# "load-bearing seam" (case-insensitive).
# Ordinals covered: first, second, third, fourth, fifth, seventh, eighth, ninth, tenth.
# "sixth" is intentionally absent — those lines are correct and must pass silently.
WRONG_ORDINAL_PAT='(first|second|third|fourth|fifth|seventh|eighth|ninth|tenth)[[:space:]]+load-bearing[[:space:]]+seam'

for ord_file in "${ordinal_check_files[@]}"; do
  [[ ! -f "$ord_file" ]] && continue
  ordinal_files_scanned=$(( ordinal_files_scanned + 1 ))
  file_label=$(printf '%s' "$ord_file" | sed "s|$REPO_ROOT/||")

  # Grep for wrong-ordinal pattern, case-insensitive.
  # Exclude: lines starting with ">" (blockquote/changelog) and "reason:" lines.
  wrong_ord_lines=$(grep -inE "$WRONG_ORDINAL_PAT" "$ord_file" 2>/dev/null \
    | grep -v '^[0-9]*:>[[:space:]]' \
    | grep -v 'reason:' \
    || true)

  if [[ -n "$wrong_ord_lines" ]]; then
    ordinal_violations=$(( ordinal_violations + 1 ))
    ord_summary=$(printf '%s' "$wrong_ord_lines" | head -3 | tr '\n' ';')
    ordinal_violation_msgs+=("${file_label}: wrong ordinal applied to 'load-bearing seam' (must be 'sixth'): ${ord_summary}")
  fi

  # Sub-assertion (o.ii.b): lines that both reference product-brief AND assign
  # a non-sixth ordinal to "load-bearing seam" in an attribution context.
  # Pattern: line contains "product-brief" AND wrong-ordinal "load-bearing seam".
  # (Already caught by the main wrong-ordinal scan above — this is an additional
  # targeted message for false-brief-citation context, not a separate violation counter.)
  brief_false_cite=$(grep -inE "$WRONG_ORDINAL_PAT" "$ord_file" 2>/dev/null \
    | grep -v '^[0-9]*:>[[:space:]]' \
    | grep -v 'reason:' \
    | grep -iE 'product.?brief' \
    || true)

  if [[ -n "$brief_false_cite" ]]; then
    brief_cite_summary=$(printf '%s' "$brief_false_cite" | head -2 | tr '\n' ';')
    ordinal_violation_msgs+=("  NOTE — false brief-citation (product-brief says 'sixth'): ${brief_cite_summary}")
  fi
done

# Positive-coverage log (always printed — detects zero-scan / inert run).
echo "    Check (o.ii): $ordinal_files_scanned files scanned for Canon-KB load-bearing-seam ordinal; $ordinal_violations file(s) with wrong-ordinal violations found."

if [[ $ordinal_violations -gt 0 ]]; then
  echo ""
  echo "    WRONG CANON-KB ORDINAL (must be 'sixth load-bearing seam' per ADR-0004 / product-brief §Overflow Context):"
  for msg in "${ordinal_violation_msgs[@]}"; do
    echo "      $msg"
  done
  errors+=("MISMATCH [Canon-KB seam ordinal (o.ii)]: $ordinal_violations file(s) contain wrong ordinal on 'load-bearing seam' (must be sixth) — architect files must be clean; PO-owned files (capabilities.md, prd-cap-008-012.md) await PO fix")
  fail=1
fi
echo ""

# ============================================================================
# (l) DISCLOSURE_CLASS CLOSED-ENUM CONSISTENCY  [NEW v1.6]
# ============================================================================
# Assert every disclosure_class value token found in any BC file's enum
# enumeration is a member of the canonical closed set defined in BC-4.03.002.
#
# Source of canonical set: BC-4.03.002 §Behavior step 2 (schema validator line)
# and Postconditions, which contain the only authoritative statement of the
# three-value closed enum. The canonical values are extracted programmatically
# from BC-4.03.002 — not hardcoded — so a future ADR-authorized enum extension
# only requires updating BC-4.03.002 (this script auto-adapts). Comment below
# names BC-4.03.002 as source of truth per the instruction.
#
# Scanning strategy (POSIX/BSD-grep compatible, no grep -P):
#   Class A: Lines matching "disclosure_class.*{[a-z][a-z-]+"
#            Extract content inside {...} braces; tokenize on [a-z][a-z-]+.
#            Catches: "values are strictly {pre-generated, live-generated, ...}"
#            and VP formal property lines like "disclosure_class ∈ {set}".
#   Class B: Lines matching "disclosure_class.*`[a-z][a-z-]+ |"
#            Extract backtick-quoted spans containing "|" pipe separators;
#            tokenize on [a-z][a-z-]+.
#            Catches: "`disclosure_class` (exactly `pre-generated | live-generated | ...`)"
#
# Any extracted token that is not in {canonical_val1, canonical_val2, canonical_val3}
# is a vocabulary violation. The failure message names the offending BC + value.
#
# This check PASSES after PO completes F8-01 fix (replacing dev-tool-only in
# BC-10.05.001); FAILS if that value is re-introduced or if any new BC adopts
# a non-canonical disclosure_class value in an enumeration.
echo "--- (l) disclosure_class closed-enum consistency (source of truth: BC-4.03.002) ---"

BC_4_03_002="$BC_DIR/ss-04/BC-4.03.002.md"

if [[ ! -f "$BC_4_03_002" ]]; then
  echo "    SKIP: canonical source BC-4.03.002 not found at $BC_4_03_002"
else
  # Step 1: Extract canonical set from BC-4.03.002.
  # Use the first line in BC-4.03.002 that contains a {set} with "pre-generated".
  # This matches both the Behavior §2 line and the Postconditions line.
  dc_canonical_line=$(grep -E '\{pre-generated' "$BC_4_03_002" 2>/dev/null | head -1 || true)

  if [[ -z "$dc_canonical_line" ]]; then
    echo "    SKIP: cannot parse canonical enum from BC-4.03.002 (no '{pre-generated' line found)"
  else
    # Extract the three canonical tokens by prefix-anchored grep on the token list
    dc_canon1=$(printf '%s' "$dc_canonical_line" \
      | grep -oE '[a-z][a-z-]+' | grep '^pre-' | head -1 || true)
    dc_canon2=$(printf '%s' "$dc_canonical_line" \
      | grep -oE '[a-z][a-z-]+' | grep '^live-' | head -1 || true)
    dc_canon3=$(printf '%s' "$dc_canonical_line" \
      | grep -oE '[a-z][a-z-]+' | grep '^procedural-' | head -1 || true)

    echo "    Canonical set (from BC-4.03.002): {$dc_canon1, $dc_canon2, $dc_canon3}"

    if [[ -z "$dc_canon1" || -z "$dc_canon2" || -z "$dc_canon3" ]]; then
      echo "    SKIP: failed to parse all three canonical values from BC-4.03.002"
    else
      # Step 2: Scan all BC files for disclosure_class value enumerations.
      dc_violations=0
      dc_violation_msgs=()

      while IFS= read -r -d $'\0' bc_file; do
        bc_id=$(basename "$(dirname "$bc_file")")/$(basename "$bc_file" .md)

        # Class A: {set} notation — lines with "disclosure_class.*{[a-z][a-z-]+"
        # Extract tokens from inside the {...} brace span only (avoids prose tokens).
        classA_toks=$(grep -hE 'disclosure_class.*\{[a-z][a-z-]+' "$bc_file" 2>/dev/null \
          | grep -oE '\{[^}]+\}' \
          | grep -oE '[a-z][a-z-]+' \
          | sort -u || true)

        # Class B: backtick-quoted pipe-separated value list
        # Lines matching "disclosure_class.*`[a-z][a-z-]+ |"
        # Extract the backtick-quoted spans that contain " | " (value-list spans).
        classB_toks=$(grep -hE 'disclosure_class.*`[a-z][a-z-]+ \|' "$bc_file" 2>/dev/null \
          | grep -oE '`[^`]+`' \
          | grep ' | ' \
          | sed 's/`//g' \
          | grep -oE '[a-z][a-z-]+' \
          | grep -E '^[a-z]+-[a-z]' \
          | sort -u || true)

        all_dc_toks=$(printf '%s\n%s\n' "$classA_toks" "$classB_toks" \
          | sort -u | grep -v '^$' || true)

        while IFS= read -r tok; do
          [[ -z "$tok" ]] && continue
          # Skip if this is one of the three canonical values
          if [[ "$tok" == "$dc_canon1" || "$tok" == "$dc_canon2" || "$tok" == "$dc_canon3" ]]; then
            continue
          fi
          # Non-canonical token found
          dc_violations=$(( dc_violations + 1 ))
          dc_violation_msgs+=("${bc_id}.md: non-canonical disclosure_class value '$tok' (allowed: {$dc_canon1, $dc_canon2, $dc_canon3}; source: BC-4.03.002)")
        done <<< "$all_dc_toks"

      done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

      echo "    BC files scanned: $computed_bc"
      echo "    Non-canonical disclosure_class values found: $dc_violations"

      if [[ $dc_violations -gt 0 ]]; then
        echo ""
        echo "    NON-CANONICAL DISCLOSURE_CLASS VALUES (must use {$dc_canon1, $dc_canon2, $dc_canon3}):"
        for msg in "${dc_violation_msgs[@]}"; do
          echo "      $msg"
        done
        errors+=("MISMATCH [disclosure_class closed-enum (l)]: $dc_violations non-canonical value(s) found in BC enum declarations — PO must replace with canonical values per BC-4.03.002 (see list above)")
        fail=1
      fi
    fi
  fi
fi
echo ""

# ============================================================================
# (m) CONVERGENCE-REPORT DIMENSION FIELD NAME UNIQUENESS  [NEW v1.7]
# ============================================================================
# Source of truth: methodology-layer.md §3.0 canonical dimension field name
# registry table (introduced in methodology-layer.md v1.3).
#
# The §3.0 table has rows of the form:
#   | D-SIM | ... | `sim_spec` | ... | ... |
# Column 3 (0-based) is the canonical field name enclosed in backticks.
# We extract all backtick-enclosed tokens from column 3 of §3.0 table rows.
#
# Strategy (POSIX/BSD grep compatible, no -P):
#   1. Find the §3.0 table block between the "§3.0 Canonical" heading and the
#      "Count invariant:" line. Extract pipe-delimited data rows starting with
#      "| D-" (dimension rows, excluding the header row).
#   2. From each such row, extract column 3 (awk field $4 because leading |
#      makes field 1 empty: | D-ID | Title | `field` | Derivation | Owner BC |).
#   3. Strip backticks; collect field names.
#   4. Assert count = 11 and all names are unique.
#
# This check does NOT assert specific field name values — methodology-layer.md
# is the authority. It asserts structural invariants: 11 entries, all distinct.
# If a future spec change adds/removes a dimension, the count check will alert.
echo "--- (m) convergence-report dimension field names — registry uniqueness + BC usage-site check (source: methodology-layer.md §3.0) ---"

DIM_FIELD_COUNT_EXPECTED=11

if [[ ! -f "$METHODOLOGY_LAYER" ]]; then
  echo "    SKIP: methodology-layer.md not found at $METHODOLOGY_LAYER"
else
  # Extract backtick-wrapped field names from §3.0 table rows starting with "| D-"
  # Column layout: | D-ID | Dimension Title | `field_name` | Derivation | Owner BC |
  # awk field $4 is the third pipe-delimited column (leading | gives empty $1).
  # Extract the content inside backticks from that field.
  # Filter: keep only values that are pure snake_case (lowercase letters + underscores
  # only, no spaces, no uppercase, no hyphens) — this excludes §3.1 per-dimension rows
  # whose column 4 contains prose descriptions or status-value lists.
  dim_fields=$(grep -E '^\| D-[A-Z]+ ' "$METHODOLOGY_LAYER" 2>/dev/null \
    | awk -F'|' '{gsub(/[[:space:]]/,"",$4); gsub(/`/,"",$4); print $4}' \
    | grep -E '^[a-z][a-z_]+$' \
    | grep -v '^$' \
    | sort || true)

  dim_field_count=$(printf '%s\n' "$dim_fields" | grep -c . 2>/dev/null || echo 0)
  dim_field_unique_count=$(printf '%s\n' "$dim_fields" | sort -u | grep -c . 2>/dev/null || echo 0)

  echo "    Canonical dimension field names parsed from §3.0 table: $dim_field_count"
  echo "    Unique field names: $dim_field_unique_count"
  echo "    Expected: count=$DIM_FIELD_COUNT_EXPECTED, all unique"

  if [[ "$VERBOSE" == true ]] && [[ -n "$dim_fields" ]]; then
    echo ""
    echo "    Field names found:"
    printf '%s\n' "$dim_fields" | while IFS= read -r fn; do
      echo "      $fn"
    done
  fi
  echo ""

  # Assert count = 11
  check "dimension field name count (§3.0 table)" \
    "$dim_field_count" "$DIM_FIELD_COUNT_EXPECTED" "methodology-layer.md §3.0"

  # Assert all unique (duplicate detection: if unique count != total count, there's a dup)
  if [[ "$dim_field_count" -gt 0 ]] && [[ "$dim_field_unique_count" != "$dim_field_count" ]]; then
    dup_count=$(( dim_field_count - dim_field_unique_count ))
    errors+=("MISMATCH [dimension field uniqueness (m)]: $dup_count duplicate dimension field name(s) found in methodology-layer.md §3.0 — each dimension must have a unique convergence-report field name")
    fail=1
    if [[ "$VERBOSE" == true ]]; then
      echo "    DUPLICATES detected:"
      printf '%s\n' "$dim_fields" | sort | uniq -d | while IFS= read -r dup; do
        echo "      duplicate field name: $dup"
      done
    fi
  fi

  # ---- (m.ii) [NEW v1.8] BC usage-site scan — assert all field references are canonical ---
  # Scan every BC body for tokens of the form:
  #   Pattern A: convergence[-_]report.dimensions.<field>  (primary namespace form,
  #              both hyphen and underscore variants of convergence-report/convergence_report)
  #   Pattern B: `dimensions.<field>`  (backtick-quoted bare form used in precondition
  #              lines like "writable `dimensions.sim_spec` field")
  #   Pattern C: [[:space:]].dimensions.<field>  (line-wrap continuation of a
  #              convergence-report.dimensions reference split across two lines;
  #              anchored on leading whitespace to exclude `a.dimensions.width` etc.)
  #
  # False-positive avoidance:
  #   - `a.dimensions.width` (texture-asset geometry in BC-4.04.003): NOT matched because
  #     (A) requires "convergence" prefix, (B) requires opening backtick immediately before
  #     "dimensions", and (C) requires whitespace before the dot — `a.dimensions` has a
  #     letter before the dot, not whitespace.
  #   - Other unrelated `.dimensions` uses (e.g. image width/height math) are similarly
  #     excluded by the same anchors.
  #
  # Only runs if the canonical field set is non-empty (i.e. §3.0 table was parsed OK).
  echo "--- (m.ii) BC usage-site: convergence-report dimension field references ---"

  if [[ "$dim_field_count" -eq 0 ]]; then
    echo "    SKIP: canonical field set is empty (§3.0 table parse failed above)"
  else
    dim_usage_violations=0
    dim_usage_violation_msgs=()

    while IFS= read -r -d $'\0' bc_file; do
      bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

      # Extract field-name tokens from Pattern A: convergence[-_]report.dimensions.<field>
      # grep -oE extracts each full match; sed strips everything up to and including the
      # last dot to leave just the field name. BSD/POSIX compatible (-E -o only).
      patA=$(grep -ohE 'convergence[-_]report\.dimensions\.[a-z][a-z_]*' "$bc_file" 2>/dev/null \
        | sed 's/.*\.//' \
        | sort -u || true)

      # Extract field-name tokens from Pattern B: `dimensions.<field>` (backtick-quoted)
      # Opening and closing backtick anchor prevents matching `a.dimensions.width`.
      patB=$(grep -ohE '`dimensions\.[a-z][a-z_]*`' "$bc_file" 2>/dev/null \
        | sed 's/`dimensions\.//' \
        | sed 's/`//' \
        | sort -u || true)

      # Extract field-name tokens from Pattern C: whitespace + .dimensions.<field>
      # Matches line-wrap continuations like "     .dimensions.cert_preflight`".
      # The leading [[:space:]] means `a.dimensions.cert_preflight` (no space before dot)
      # does NOT match — only genuine line-wrap fragments match.
      patC=$(grep -ohE '[[:space:]]\.dimensions\.[a-z][a-z_]*' "$bc_file" 2>/dev/null \
        | sed 's/.*\.//' \
        | sort -u || true)

      # Union all extracted field names for this BC file (deduplicate)
      all_fields=$(printf '%s\n%s\n%s\n' "$patA" "$patB" "$patC" \
        | sort -u | grep -v '^$' || true)

      # Check each field name against the canonical set
      while IFS= read -r field; do
        [[ -z "$field" ]] && continue
        if ! printf '%s\n' "$dim_fields" | grep -qF "$field" 2>/dev/null; then
          dim_usage_violations=$(( dim_usage_violations + 1 ))
          dim_usage_violation_msgs+=("${bc_rel}: non-canonical convergence dimension field '$field' (allowed: $(printf '%s\n' "$dim_fields" | sort -u | tr '\n' ',' | sed 's/,$//'))")
        fi
      done <<< "$all_fields"

    done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

    echo "    BC files scanned for dimension field references: $computed_bc"
    echo "    Non-canonical dimension field references found: $dim_usage_violations"

    if [[ $dim_usage_violations -gt 0 ]]; then
      echo ""
      echo "    NON-CANONICAL CONVERGENCE DIMENSION FIELDS (PO must rename to canonical field from methodology-layer §3.0):"
      for msg in "${dim_usage_violation_msgs[@]}"; do
        echo "      $msg"
      done
      errors+=("MISMATCH [convergence dimension field usage-site (m.ii)]: $dim_usage_violations BC file(s) reference non-canonical convergence-report dimension field names — PO must rename to canonical fields per methodology-layer.md §3.0 (see list above)")
      fail=1
    fi
  fi
fi
echo ""

# ============================================================================
# (n) CONVERGENCE-DIMENSION STATUS-VALUE ENUM CONSISTENCY  [NEW v1.9]
# ============================================================================
# Source of truth: methodology-layer.md §3.1 "Canonical Convergence-Dimension
# Status-Value Enum" table.
#
# The §3.1 table has rows of the form:
#   | `GREEN` | ... | All 11 dimensions ... |
#   | `DEGRADED` | ... | ... |
#   | `DEGRADED-PENDING` | ... | ... |
#   | `BLOCKED` | ... | ... |
# Column 1 (awk field $2 because leading |) contains the backtick-wrapped value.
#
# Step 1: Parse canonical status values from §3.1 table (rows starting with "| `").
# Step 2: Scan every BC file for lines that contain BOTH a convergence-report
#         dimension reference AND a status keyword token. Extraction patterns:
#   Pattern A: lines containing "convergence[-_]report" or ".dimensions." followed
#              by a `VALUE` token (backtick-quoted) on the same line.
#   Pattern B: lines where `cert_preflight`, `provenance_legal_compliance`,
#              `monetization_ethics`, or other canonical dim fields appear alongside
#              a capitalized all-caps word that is not part of a field name.
# Step 3: For each extracted value token, assert it is in the canonical enum.
#         Report failures as: "BC-file: non-canonical status value 'AMBER' in
#         convergence-dimension context."
#
# False-positive avoidance:
#   - Frontmatter changelog `reason:` lines (YAML prose inside `modified:` blocks)
#     are EXCLUDED before status-value extraction. These lines carry historical
#     adjudication prose (e.g. "D-ETHICS is BINARY {GREEN, BLOCKED} per §3.1")
#     that is NOT an operative dimension-status assignment. Exclusion is done by
#     stripping lines matching `reason:` from dim_context_lines after the initial
#     grep. Only operative BC body content is scanned.
#   - Only tokens on lines containing a dimension-field reference are scanned.
#   - All-caps tokens that match canonical enum values are skipped.
#   - Single-word all-caps tokens not preceded by a dimension-field reference
#     on the same line are excluded (avoids flagging "BLOCKED" in a prose heading).
#   - Patterns are anchored to the convergence-report namespace.
#   POSIX/BSD-grep compatible; no grep -P.
#
# EXPECTED STATUS: FAIL (await PO propagation of AMBER → DEGRADED-PENDING/BLOCKED
# in SS-09/10/11/13 BCs and prd-cap-009-010.md). Will become green automatically
# after PO completes changes listed in methodology-layer.md §3.1 PO change list.
echo "--- (n) convergence-dimension status-value enum (source: methodology-layer.md §3.1) ---"

if [[ ! -f "$METHODOLOGY_LAYER" ]]; then
  echo "    SKIP: methodology-layer.md not found at $METHODOLOGY_LAYER"
else
  # Step 1: Parse canonical status-value enum from §3.1 table.
  # The §3.1 table rows start with "| `" and the value is in backticks in column 1.
  # We extract rows between the "§3.1" heading and the next "---" or "###" delimiter.
  # Strategy: grep for rows starting "| `" that contain all-caps value tokens
  # (GREEN, DEGRADED, BLOCKED, and hyphenated variants like DEGRADED-PENDING).
  # This is the §3.1 table's Value column (field $2 after splitting by |).
  dim_status_enum=$(grep -E '^\| `[A-Z][A-Z-]+` \|' "$METHODOLOGY_LAYER" 2>/dev/null \
    | awk -F'|' '{gsub(/[[:space:]`]/,"",$2); print $2}' \
    | grep -E '^[A-Z][A-Z-]+$' \
    | sort -u || true)

  dim_status_count=$(printf '%s\n' "$dim_status_enum" | grep -c . 2>/dev/null || echo 0)

  echo "    Canonical status values parsed from §3.1 table: $dim_status_count"
  if [[ "$VERBOSE" == true ]] && [[ -n "$dim_status_enum" ]]; then
    printf '%s\n' "$dim_status_enum" | while IFS= read -r sv; do
      echo "      $sv"
    done
  fi

  if [[ "$dim_status_count" -eq 0 ]]; then
    echo "    SKIP: §3.1 canonical status-value enum could not be parsed from methodology-layer.md"
    echo "          (expected rows matching '| \`ALL-CAPS[-VALUE]\` |' in §3.1 table)"
  else
    # Step 2: Scan all BC files for convergence-dimension value assignments.
    # We look for lines that:
    #   (a) contain a convergence-report/convergence_report dimension reference OR
    #       a backtick-quoted canonical dimension field name (e.g. `cert_preflight`)
    #   AND
    #   (b) contain a backtick-quoted all-caps token that looks like a status value.
    #
    # Extraction:
    #   - Match lines containing "convergence[-_]report" or "`dimensions." or
    #     field-name tokens like cert_preflight, provenance_legal_compliance,
    #     monetization_ethics, tests_replay, sim_spec, asset_completeness,
    #     playtest_satisfaction, perf_budget, implementation, docs, security_invariants.
    #   - From those lines, extract all backtick-quoted tokens consisting of [A-Z-]+.
    #   - Also extract unquoted uppercase tokens preceded by "= " or "to " or
    #     "remains " or "is set to " or "is " (verb phrases used in BC prose).
    #
    # POSIX/BSD grep: use -E -o only; no -P.

    # Build the list of DISTINCTIVE canonical dimension field name tokens for line-anchor.
    # We exclude generic English words that are also dim field names ("implementation",
    # "docs") to avoid false positives on lines that use those words as prose. Those two
    # dims are captured via the "convergence[-_]report" / "`dimensions." anchors only.
    # The distinctive_dim_fields set covers all multi-word snake_case fields that cannot
    # appear as prose: cert_preflight, provenance_legal_compliance, monetization_ethics,
    # tests_replay, sim_spec, asset_completeness, playtest_satisfaction, perf_budget,
    # security_invariants.
    # POSIX/BSD grep: use -E -o only; no -P.
    if [[ -n "${dim_fields:-}" ]]; then
      dim_field_pattern=$(printf '%s\n' "$dim_fields" \
        | grep -vE '^(implementation|docs)$' \
        | tr '\n' '|' | sed 's/|$//')
    else
      dim_field_pattern="cert_preflight|provenance_legal_compliance|monetization_ethics|tests_replay|sim_spec|asset_completeness|playtest_satisfaction|perf_budget|security_invariants"
    fi

    dim_status_violations=0
    dim_status_violation_msgs=()
    # Coverage counters for the positive-coverage log line (F-12-02 fix):
    # dim_status_assignments_checked: total status-value assignments examined
    # dim_status_bcs_with_context: number of BC files that had dimension context
    dim_status_assignments_checked=0
    dim_status_bcs_with_context=0

    while IFS= read -r -d $'\0' bc_file; do
      bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

      # Grep for lines that contain a convergence-report dimension context.
      # Anchor: lines with "convergence[-_]report" OR "`dimensions." OR one of the
      # distinctive dim field names (distinctive = multi-word snake_case that can't
      # appear as prose). Also match "dim-[0-9]+" (shorthand dimension references
      # like "dim-10") and "D-ETHICS|D-CERT|D-PROV" (dimension ID references).
      # Generic dim field names ("implementation", "docs") are excluded from this
      # trigger to prevent false positives; they are covered by the stronger
      # "convergence[-_]report" and "`dimensions." anchors.
      # CHANGELOG EXCLUSION: strip frontmatter `reason:` lines (YAML lifecycle
      # prose inside `modified:` blocks) before extracting status values. These
      # lines carry historical adjudication prose that is NOT an operative
      # dimension-status assignment (e.g. "D-ETHICS is BINARY {GREEN, BLOCKED}").
      dim_context_lines=$(grep -hE \
        'convergence[-_]report|`dimensions\.|dim-[0-9]+|D-ETHICS|D-CERT|D-PROV|D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-PERF|D-DOCS|D-SEC|'"${dim_field_pattern}" \
        "$bc_file" 2>/dev/null \
        | grep -v 'reason:' \
        || true)

      [[ -z "$dim_context_lines" ]] && continue
      dim_status_bcs_with_context=$(( dim_status_bcs_with_context + 1 ))

      # From those lines, extract backtick-quoted all-caps tokens: `VALUE`
      # These represent explicitly quoted status values in BC prose.
      backtick_vals=$(printf '%s\n' "$dim_context_lines" \
        | grep -oE '`[A-Z][A-Z-]+-?[A-Z]*`' \
        | sed 's/`//g' \
        | grep -E '^[A-Z][A-Z-]+$' \
        | sort -u || true)

      # Whole-file scan for backtick-quoted `AMBER` — this catches cases where the
      # non-canonical value appears on a different line than the convergence field
      # reference (e.g. "Update `dimensions.field`:" followed by "`AMBER` iff ...").
      # Only runs when the file has dimension references (already checked above).
      # This avoids false positives in files with no convergence context at all.
      whole_file_amber=$(grep -ohE '`AMBER`' "$bc_file" 2>/dev/null \
        | sed 's/`//g' \
        | sort -u || true)

      backtick_vals=$(printf '%s\n%s\n' "$backtick_vals" "$whole_file_amber" \
        | sort -u | grep -v '^$' || true)

      # Also extract unquoted all-caps tokens that follow status-assignment verbs:
      # "= VALUE", "to VALUE", "remains VALUE", "is VALUE", "stays VALUE"
      # anchored by a word boundary pattern. Use word-context grep.
      # Only capture the all-caps token itself (2-10 chars, may contain hyphen).
      # Also capture ": VALUE" (YAML-style colon assignment: `field: AMBER`) and
      # "= VALUE" and common verb phrases used in BC prose.
      verb_vals=$(printf '%s\n' "$dim_context_lines" \
        | grep -oE '(= |: |to |remains |is set to |is |stays |transitions to |set to )[A-Z][A-Z-]+-?[A-Z]*[^a-z]' \
        | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
        | grep -E '^[A-Z][A-Z-]+$' \
        | sort -u || true)

      all_status_vals=$(printf '%s\n%s\n' "$backtick_vals" "$verb_vals" \
        | sort -u | grep -v '^$' || true)

      while IFS= read -r sv; do
        [[ -z "$sv" ]] && continue
        # Skip tokens that are clearly not status values:
        # - Dimension IDs like D-SIM, D-CERT (contain a single letter after D-)
        # - Field names that happen to be uppercase (none in canonical set, but safety)
        # - Short tokens that are common words: AND, OR, NOT, ANY, ALL, YES, NO
        case "$sv" in
          # Common acronyms, IDs, and non-status tokens that appear in BC prose
          AND|OR|NOT|ANY|ALL|YES|NO|NA|API|CLI|CI|ID|BC|SS|VP|PRD|PO|TBD|DI|ADR|EC|EP)
            continue ;;
          CWE|PASS|FAIL|PARTIAL|PENDING|NONE|NDA|EU|JP|CN|US|IAP|LTV|AI|F2P|EOMM)
            continue ;;
          IARC|PEGI|ESRB|SAG|AFTRA|NFT|XR|VR|AR|OK|URL|JSON|SDK|UI|UX|ML|TLS|TDD)
            continue ;;
          P0|P1|P2|L1|L2|L3|L4|T1|T2|T3|CAP|WIP|TBD|NULL|TRUE|FALSE|VALID|INVALID)
            continue ;;
          COMPLETE|ACTIVE|DRAFT|REQUIRED|OPTIONAL|DEPRECATED)
            continue ;;
          # YELLOW and RED are used in compliance / prd-cap tables for non-dimension contexts
          YELLOW|RED)
            continue ;;
          # Dimension IDs are line triggers, not status values — skip them
          D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-CERT|D-PERF|D-PROV|D-DOCS|D-ETHICS|D-SEC)
            continue ;;
        esac
        # Skip tokens starting with "E-" (error code prefixes like E-ETH-)
        [[ "$sv" == E-* ]] && continue
        # Skip if length < 3 (too short to be a meaningful status token)
        [[ "${#sv}" -lt 3 ]] && continue
        # Count this assignment (coverage counter)
        dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
        # Check against canonical enum
        if ! printf '%s\n' "$dim_status_enum" | grep -qF "$sv" 2>/dev/null; then
          dim_status_violations=$(( dim_status_violations + 1 ))
          dim_status_violation_msgs+=("${bc_rel}: non-canonical convergence-dimension status value '$sv' (canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
        fi
      done <<< "$all_status_vals"

      # [NEW v1.12] CASE-INSENSITIVE EXTRACTION (F-12-02 fix): also catch
      # lowercase/mixed-case status tokens in backtick form on dim_context_lines.
      # Anchoring is the same dim_context_lines filter used above — this preserves
      # the false-positive guarantee: BCs that use `green`/`red`/`amber`/`pending`
      # for non-dimension things (severity colors, lint, asset status, traffic-light
      # UI) have no matching dim_context_lines and are never reached here.
      # Extraction: backtick-quoted lowercase tokens from dim_context_lines.
      # Classification: fold to uppercase; test against canonical enum (wrong-case
      # form of canonical value) OR known non-canonical status words (AMBER, RED,
      # PENDING, YELLOW — non-canonical + wrong case). Object/field names like
      # `playtest-satisfaction`, `convergence-report`, `session-evidence-record`
      # fold to PLAYTEST-SATISFACTION etc. — not in either set — and are silently
      # dropped. POSIX/BSD-grep compatible; no grep -P.
      lc_btick_toks=$(printf '%s\n' "$dim_context_lines" \
        | grep -oE '`[a-z][a-z-]+`' \
        | sed 's/`//g' \
        | grep -v '^$' \
        | sort -u || true)

      while IFS= read -r lctok; do
        [[ -z "$lctok" ]] && continue
        # Fold to uppercase for classification (tr is POSIX/BSD compatible)
        uctok=$(printf '%s' "$lctok" | tr '[:lower:]' '[:upper:]')
        # Test if folded form is in the canonical enum — use -x for exact-line match
        # so that e.g. PENDING does not accidentally match DEGRADED-PENDING via substring.
        if printf '%s\n' "$dim_status_enum" | grep -qxF "$uctok" 2>/dev/null; then
          # Wrong-case form of a canonical value — always a violation
          dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
          dim_status_violations=$(( dim_status_violations + 1 ))
          dim_status_violation_msgs+=("${bc_rel}: lowercase form of canonical status value '\`${lctok}\`' in dimension-context — must be uppercase '\`${uctok}\`' (F-12-02; canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
        else
          # Not in canonical enum — check against known non-canonical status words
          case "$uctok" in
            AMBER|RED|PENDING|YELLOW)
              # Non-canonical value + wrong case — double violation
              dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
              dim_status_violations=$(( dim_status_violations + 1 ))
              dim_status_violation_msgs+=("${bc_rel}: lowercase non-canonical status value '\`${lctok}\`' in dimension-context (folds to ${uctok}; F-12-02; canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
              ;;
            *)
              # Not a status-vocabulary word — silently drop (object/field name)
              ;;
          esac
        fi
      done <<< "$lc_btick_toks"

    done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

    # Also scan prd-supplements for dimension status references
    PRD_SUPP_DIR="$REPO_ROOT/.factory/specs/prd-supplements"
    if [[ -d "$PRD_SUPP_DIR" ]]; then
      while IFS= read -r -d $'\0' supp_file; do
        supp_rel="prd-supplements/$(basename "$supp_file")"

        # CHANGELOG EXCLUSION: same as BC loop — strip `reason:` lines.
        dim_context_lines=$(grep -hE \
          'convergence[-_]report|`dimensions\.|dim-[0-9]+|D-ETHICS|D-CERT|D-PROV|D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-PERF|D-DOCS|D-SEC|'"${dim_field_pattern}" \
          "$supp_file" 2>/dev/null \
          | grep -v 'reason:' \
          || true)

        [[ -z "$dim_context_lines" ]] && continue

        backtick_vals=$(printf '%s\n' "$dim_context_lines" \
          | grep -oE '`[A-Z][A-Z-]+-?[A-Z]*`' \
          | sed 's/`//g' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)

        whole_file_amber=$(grep -ohE '`AMBER`' "$supp_file" 2>/dev/null \
          | sed 's/`//g' \
          | sort -u || true)

        backtick_vals=$(printf '%s\n%s\n' "$backtick_vals" "$whole_file_amber" \
          | sort -u | grep -v '^$' || true)

        verb_vals=$(printf '%s\n' "$dim_context_lines" \
          | grep -oE '(= |: |to |remains |is set to |is |stays |transitions to |set to )[A-Z][A-Z-]+-?[A-Z]*[^a-z]' \
          | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)

        all_status_vals=$(printf '%s\n%s\n' "$backtick_vals" "$verb_vals" \
          | sort -u | grep -v '^$' || true)

        while IFS= read -r sv; do
          [[ -z "$sv" ]] && continue
          case "$sv" in
            AND|OR|NOT|ANY|ALL|YES|NO|NA|API|CLI|CI|ID|BC|SS|VP|PRD|PO|TBD|DI|ADR|EC|EP)
              continue ;;
            CWE|PASS|FAIL|PARTIAL|PENDING|NONE|NDA|EU|JP|CN|US|IAP|LTV|AI|F2P|EOMM)
              continue ;;
            IARC|PEGI|ESRB|SAG|AFTRA|NFT|XR|VR|AR|OK|URL|JSON|SDK|UI|UX|ML|TLS|TDD)
              continue ;;
            P0|P1|P2|L1|L2|L3|L4|T1|T2|T3|CAP|WIP|TBD|NULL|TRUE|FALSE|VALID|INVALID)
              continue ;;
            COMPLETE|ACTIVE|DRAFT|REQUIRED|OPTIONAL|DEPRECATED|YELLOW|RED)
              continue ;;
            D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-CERT|D-PERF|D-PROV|D-DOCS|D-ETHICS|D-SEC)
              continue ;;
          esac
          [[ "$sv" == E-* ]] && continue
          [[ "${#sv}" -lt 3 ]] && continue
          dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
          if ! printf '%s\n' "$dim_status_enum" | grep -qF "$sv" 2>/dev/null; then
            dim_status_violations=$(( dim_status_violations + 1 ))
            dim_status_violation_msgs+=("${supp_rel}: non-canonical convergence-dimension status value '$sv' (canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
          fi
        done <<< "$all_status_vals"

        # [NEW v1.12] Case-insensitive extraction for prd-supplements (same as BC loop)
        lc_btick_toks=$(printf '%s\n' "$dim_context_lines" \
          | grep -oE '`[a-z][a-z-]+`' \
          | sed 's/`//g' \
          | grep -v '^$' \
          | sort -u || true)

        while IFS= read -r lctok; do
          [[ -z "$lctok" ]] && continue
          uctok=$(printf '%s' "$lctok" | tr '[:lower:]' '[:upper:]')
          # Use -x for exact-line match (prevents PENDING matching DEGRADED-PENDING)
          if printf '%s\n' "$dim_status_enum" | grep -qxF "$uctok" 2>/dev/null; then
            dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
            dim_status_violations=$(( dim_status_violations + 1 ))
            dim_status_violation_msgs+=("${supp_rel}: lowercase form of canonical status value '\`${lctok}\`' in dimension-context — must be uppercase '\`${uctok}\`' (F-12-02; canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
          else
            case "$uctok" in
              AMBER|RED|PENDING|YELLOW)
                dim_status_assignments_checked=$(( dim_status_assignments_checked + 1 ))
                dim_status_violations=$(( dim_status_violations + 1 ))
                dim_status_violation_msgs+=("${supp_rel}: lowercase non-canonical status value '\`${lctok}\`' in dimension-context (folds to ${uctok}; F-12-02; canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'; echo))")
                ;;
            esac
          fi
        done <<< "$lc_btick_toks"

      done < <(find "$PRD_SUPP_DIR" -maxdepth 1 -name "*.md" -print0)
    fi

    echo "    BC + prd-supplement files scanned: $computed_bc (BCs) + prd-supplements"
    echo "    Non-canonical dimension status values found: $dim_status_violations"
    # [NEW v1.12] Positive-coverage log line: makes a zero-scan (inert) run visible.
    # A silent zero means either there is genuinely nothing to check (no dimension
    # context found anywhere) or the anchoring pattern has been broken. Either case
    # is worth surfacing. This line is always printed regardless of pass/fail.
    echo "    Check (n) coverage: $dim_status_assignments_checked dimension-status assignment(s) validated across $dim_status_bcs_with_context BC(s) with dimension context"
    if [[ "$dim_status_violations" -gt 0 ]]; then
      echo ""
      echo "    NON-CANONICAL CONVERGENCE-DIMENSION STATUS VALUES (PO must update per methodology-layer §3.1):"
      for msg in "${dim_status_violation_msgs[@]}"; do
        echo "      $msg"
      done
      errors+=("MISMATCH [convergence-dimension status-value enum (n)]: $dim_status_violations non-canonical status value(s) found in dimension-context lines — PO must update to canonical enum per methodology-layer.md §3.1 (EXPECTED: await PO propagation of AMBER changes)")
      fail=1
    fi

    # ---- (n.ii) [NEW v1.11] Per-dimension subset enforcement -------------------
    # Parse the §3.1 "Per-Dimension Allowed Value Subsets" table from
    # methodology-layer.md. The table has rows starting with "| D-" under the
    # "Per-Dimension Allowed Value Subsets" heading. Column layout:
    #   | Dim | Allowed Values | Rationale |
    # We map each dimension ID (D-SIM etc.) AND its canonical field name
    # (sim_spec etc.) to the set of allowed status values.
    #
    # Then scan every BC file for lines that BOTH reference a specific dimension
    # (by field name or D-XX ID on the same line) AND contain a status value.
    # Assert the value is in that dimension's allowed subset.
    #
    # False-positive avoidance:
    #   - Only lines where a specific dimension can be identified on the SAME line
    #     are checked for subset compliance. Lines with only a generic convergence
    #     reference (no specific dimension) are covered by (n.i) only.
    #   - Changelog reason: lines remain excluded.
    #   - Known allowlist exclusions same as (n.i).
    echo ""
    echo "--- (n.ii) per-dimension allowed-value subset enforcement ---"

    # Build dimension→allowed-values map from §3.1 per-dimension table.
    # Row format in §3.1: | D-DIM | GREEN, DEGRADED, ... | Rationale |
    # awk: field $2 is D-XX id (strip spaces), field $3 is allowed values list.
    # Extract only rows starting with "| D-" from methodology-layer.md.
    # Map each extracted pair to "DIM_ID:VALUE1 VALUE2 VALUE3"
    declare -A DIM_ALLOWED_MAP
    declare -A FIELD_TO_DIM_MAP

    # Build field→dimension mapping from §3.0 table for subset lookup
    # Row format: | D-ID | Dimension Title | `field_name` | Derivation | Owner BC |
    while IFS= read -r row; do
      dim_id=$(printf '%s' "$row" | awk -F'|' '{gsub(/[[:space:]]/,"",$2); print $2}')
      field_name=$(printf '%s' "$row" | awk -F'|' '{gsub(/[[:space:]`]/,"",$4); print $4}')
      # Only store if field_name looks like a snake_case identifier
      if printf '%s' "$field_name" | grep -qE '^[a-z][a-z_]+$' 2>/dev/null; then
        FIELD_TO_DIM_MAP["$field_name"]="$dim_id"
      fi
    done < <(grep -E '^\| D-[A-Z]+ ' "$METHODOLOGY_LAYER" 2>/dev/null \
      | grep -v 'Allowed Values' || true)

    # Build dimension→allowed-values mapping from §3.1 per-dimension table rows.
    # The §3.1 per-dimension table rows look like:
    #   | D-SIM | GREEN, DEGRADED, BLOCKED | ... |
    # field $3 (awk, 1-based with leading |) is the allowed values column.
    # We extract only dimension rows from the §3.1 table section.
    # Strategy: extract lines matching "^\| D-" that contain "GREEN" (dimension rows)
    # from the §3.1 section (after the "Per-Dimension Allowed Value Subsets" heading).
    while IFS= read -r row; do
      dim_id=$(printf '%s' "$row" | awk -F'|' '{gsub(/[[:space:]]/,"",$2); print $2}')
      allowed_raw=$(printf '%s' "$row" | awk -F'|' '{print $3}')
      # Extract canonical status value tokens from the allowed column
      # (all-uppercase tokens possibly with hyphens: GREEN, DEGRADED, DEGRADED-PENDING, BLOCKED)
      allowed_vals=$(printf '%s' "$allowed_raw" \
        | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
        | grep -E '^[A-Z][A-Z-]+$' \
        | tr '\n' ' ')
      if [[ -n "$dim_id" ]] && printf '%s' "$dim_id" | grep -qE '^D-[A-Z]+$'; then
        DIM_ALLOWED_MAP["$dim_id"]="$allowed_vals"
      fi
    done < <(grep -E '^\| D-[A-Z]+ ' "$METHODOLOGY_LAYER" 2>/dev/null \
      | grep 'GREEN' || true)

    ndii_violations=0
    ndii_violation_msgs=()

    # For each BC file, find lines that both name a specific dimension AND contain
    # a canonical status value. Check subset compliance.
    while IFS= read -r -d $'\0' bc_file; do
      bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

      # Get dimension-context lines (same filter as (n.i)), excluding reason: lines
      dim_ctx=$(grep -hE \
        'convergence[-_]report|`dimensions\.|dim-[0-9]+|D-ETHICS|D-CERT|D-PROV|D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-PERF|D-DOCS|D-SEC|'"${dim_field_pattern}" \
        "$bc_file" 2>/dev/null \
        | grep -v 'reason:' \
        || true)
      [[ -z "$dim_ctx" ]] && continue

      # For each canonical field name, check lines that reference that field
      for field in "${!FIELD_TO_DIM_MAP[@]}"; do
        dim_id="${FIELD_TO_DIM_MAP[$field]}"
        [[ -z "$dim_id" ]] && continue
        allowed="${DIM_ALLOWED_MAP[$dim_id]:-}"
        [[ -z "$allowed" ]] && continue

        # Find lines that reference this specific field name
        field_lines=$(printf '%s\n' "$dim_ctx" \
          | grep -F "$field" \
          | grep -v 'reason:' \
          || true)
        [[ -z "$field_lines" ]] && continue

        # Extract status value tokens from these field-specific lines
        # (backtick-quoted and verb-phrase patterns, same as (n.i))
        btick=$(printf '%s\n' "$field_lines" \
          | grep -oE '`[A-Z][A-Z-]+-?[A-Z]*`' \
          | sed 's/`//g' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)
        verb=$(printf '%s\n' "$field_lines" \
          | grep -oE '(= |: |to |remains |is set to |is |stays |transitions to |set to )[A-Z][A-Z-]+-?[A-Z]*[^a-z]' \
          | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)
        cand_vals=$(printf '%s\n%s\n' "$btick" "$verb" \
          | sort -u | grep -v '^$' || true)

        while IFS= read -r sv; do
          [[ -z "$sv" ]] && continue
          # Apply same exclusion list as (n.i)
          case "$sv" in
            AND|OR|NOT|ANY|ALL|YES|NO|NA|API|CLI|CI|ID|BC|SS|VP|PRD|PO|TBD|DI|ADR|EC|EP) continue ;;
            CWE|PASS|FAIL|PARTIAL|PENDING|NONE|NDA|EU|JP|CN|US|IAP|LTV|AI|F2P|EOMM) continue ;;
            IARC|PEGI|ESRB|SAG|AFTRA|NFT|XR|VR|AR|OK|URL|JSON|SDK|UI|UX|ML|TLS|TDD) continue ;;
            P0|P1|P2|L1|L2|L3|L4|T1|T2|T3|CAP|WIP|TBD|NULL|TRUE|FALSE|VALID|INVALID) continue ;;
            COMPLETE|ACTIVE|DRAFT|REQUIRED|OPTIONAL|DEPRECATED|YELLOW|RED) continue ;;
            D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-CERT|D-PERF|D-PROV|D-DOCS|D-ETHICS|D-SEC) continue ;;
          esac
          [[ "$sv" == E-* ]] && continue
          [[ "${#sv}" -lt 3 ]] && continue
          # Skip if not in the flat canonical enum (already caught by n.i)
          if ! printf '%s\n' "$dim_status_enum" | grep -qF "$sv" 2>/dev/null; then
            continue
          fi
          # Now check subset: is sv allowed for this specific dimension?
          if ! printf '%s\n' "$allowed" | tr ' ' '\n' | grep -qF "$sv" 2>/dev/null; then
            ndii_violations=$(( ndii_violations + 1 ))
            ndii_violation_msgs+=("${bc_rel}: value '$sv' is enum-valid but NOT in allowed subset for dimension ${dim_id} (${field}); allowed: {$(printf '%s' "$allowed" | tr ' ' ',')}")
          fi
        done <<< "$cand_vals"
      done

      # Also check by D-XX dimension ID references on lines
      for dim_id in "${!DIM_ALLOWED_MAP[@]}"; do
        allowed="${DIM_ALLOWED_MAP[$dim_id]}"
        [[ -z "$allowed" ]] && continue
        # Find lines that explicitly name this dimension ID
        id_lines=$(printf '%s\n' "$dim_ctx" \
          | grep -F "$dim_id" \
          | grep -v 'reason:' \
          || true)
        [[ -z "$id_lines" ]] && continue

        btick=$(printf '%s\n' "$id_lines" \
          | grep -oE '`[A-Z][A-Z-]+-?[A-Z]*`' \
          | sed 's/`//g' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)
        verb=$(printf '%s\n' "$id_lines" \
          | grep -oE '(= |: |to |remains |is set to |is |stays |transitions to |set to )[A-Z][A-Z-]+-?[A-Z]*[^a-z]' \
          | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
          | grep -E '^[A-Z][A-Z-]+$' \
          | sort -u || true)
        cand_vals=$(printf '%s\n%s\n' "$btick" "$verb" \
          | sort -u | grep -v '^$' || true)

        while IFS= read -r sv; do
          [[ -z "$sv" ]] && continue
          case "$sv" in
            AND|OR|NOT|ANY|ALL|YES|NO|NA|API|CLI|CI|ID|BC|SS|VP|PRD|PO|TBD|DI|ADR|EC|EP) continue ;;
            CWE|PASS|FAIL|PARTIAL|PENDING|NONE|NDA|EU|JP|CN|US|IAP|LTV|AI|F2P|EOMM) continue ;;
            IARC|PEGI|ESRB|SAG|AFTRA|NFT|XR|VR|AR|OK|URL|JSON|SDK|UI|UX|ML|TLS|TDD) continue ;;
            P0|P1|P2|L1|L2|L3|L4|T1|T2|T3|CAP|WIP|TBD|NULL|TRUE|FALSE|VALID|INVALID) continue ;;
            COMPLETE|ACTIVE|DRAFT|REQUIRED|OPTIONAL|DEPRECATED|YELLOW|RED) continue ;;
            D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-CERT|D-PERF|D-PROV|D-DOCS|D-ETHICS|D-SEC) continue ;;
          esac
          [[ "$sv" == E-* ]] && continue
          [[ "${#sv}" -lt 3 ]] && continue
          if ! printf '%s\n' "$dim_status_enum" | grep -qF "$sv" 2>/dev/null; then
            continue
          fi
          if ! printf '%s\n' "$allowed" | tr ' ' '\n' | grep -qF "$sv" 2>/dev/null; then
            # Deduplicate: skip if same violation already recorded for this bc_rel/dim_id/sv
            already=0
            for existing in "${ndii_violation_msgs[@]}"; do
              if printf '%s' "$existing" | grep -qF "${bc_rel}" && \
                 printf '%s' "$existing" | grep -qF "$sv" && \
                 printf '%s' "$existing" | grep -qF "$dim_id"; then
                already=1; break
              fi
            done
            if [[ $already -eq 0 ]]; then
              ndii_violations=$(( ndii_violations + 1 ))
              ndii_violation_msgs+=("${bc_rel}: value '$sv' is enum-valid but NOT in allowed subset for dimension ${dim_id}; allowed: {$(printf '%s' "$allowed" | tr ' ' ',')}")
            fi
          fi
        done <<< "$cand_vals"
      done

    done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

    echo "    Per-dimension subset violations found: $ndii_violations"
    if [[ $ndii_violations -gt 0 ]]; then
      echo ""
      echo "    PER-DIMENSION SUBSET VIOLATIONS (value is enum-valid but illegal for that dimension):"
      for msg in "${ndii_violation_msgs[@]}"; do
        echo "      $msg"
      done
      errors+=("MISMATCH [per-dimension status-value subset (n.ii)]: $ndii_violations violation(s) — enum-valid values used outside their allowed dimension subset per methodology-layer.md §3.1")
      fail=1
    fi

    # ---- (n.iii) [NEW v1.11] Bare table-cell token scan -----------------------
    # Catches hyphenated non-canonical tokens (BLOCKED-PENDING, DEGRADED-ACCEPTED,
    # DEGRADED-advisory, etc.) that appear as bare text in markdown table cells
    # in convergence-dimension context. These tokens evade (n.i)'s backtick and
    # verb-phrase anchors because they are written without backticks in table cells.
    #
    # Pattern: [A-Z][A-Z]+-[A-Z][A-Za-z]+ — requires at least 2 uppercase letters
    # before the hyphen, then an uppercase-initial word after. This matches
    # BLOCKED-PENDING, DEGRADED-ACCEPTED but NOT "non-canonical", "machine-checkable",
    # "pre-generated", "on-device" (all start with lowercase before/after hyphen).
    # Also matches DEGRADED-advisory (mixed case after hyphen — intentional: we want
    # to catch these).
    #
    # Exclusions: canonical 4-value enum tokens (they may appear hyphenated in prose),
    # known all-caps acronyms that happen to be hyphenated.
    echo ""
    echo "--- (n.iii) bare table-cell hyphenated non-canonical status token scan ---"

    ndiii_violations=0
    ndiii_violation_msgs=()

    while IFS= read -r -d $'\0' bc_file; do
      bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

      # Get dimension-context lines (same filter), excluding reason: lines
      dim_ctx_bare=$(grep -hE \
        'convergence[-_]report|`dimensions\.|dim-[0-9]+|D-ETHICS|D-CERT|D-PROV|D-SIM|D-REPLAY|D-IMPL|D-ASSET|D-PLAY|D-PERF|D-DOCS|D-SEC|'"${dim_field_pattern}" \
        "$bc_file" 2>/dev/null \
        | grep -v 'reason:' \
        || true)
      [[ -z "$dim_ctx_bare" ]] && continue

      # Extract hyphenated tokens matching [A-Z][A-Z]+-[A-Z][A-Za-z]+
      # (2+ uppercase before hyphen, uppercase-or-mixed after hyphen)
      hyph_toks=$(printf '%s\n' "$dim_ctx_bare" \
        | grep -oE '[A-Z][A-Z]+-[A-Z][A-Za-z]+' \
        | sort -u || true)

      while IFS= read -r tok; do
        [[ -z "$tok" ]] && continue
        # Skip canonical enum members (DEGRADED-PENDING is canonical)
        if printf '%s\n' "$dim_status_enum" | grep -qF "$tok" 2>/dev/null; then
          continue
        fi
        # Skip known hyphenated non-status tokens that appear in BC prose.
        # These are identifier prefixes (VP-COMP, BC-7, ADR-0006 etc.) or known
        # acronym compounds (SAG-AFTRA, AI-generated, CPU-bound etc.) that are
        # never status values.
        case "$tok" in
          # Spec identifier prefixes (VP-COMP-NNN, BC-NNN, ADR-NNN, etc.)
          # Note: most of these patterns have digits after hyphen and won't match
          # [a-zA-Z][a-zA-Z]+ — but VP-COMP would match as VP- + COMP.
          # Exclude by prefix:
          VP-*|BC-*|ADR-*|CAP-*|DI-*|EC-*|SS-*|DP-*|SBC-*|RRC-*|DIC-*|MEC-*|CDC-*) continue ;;
          # Known legitimate hyphenated tokens in BC prose that are not status values
          SAG-AFTRA|AI-generated|CPU-bound|GPU-bound|NDA-gated|EOMM-style|CI-gated|NON-COMPETITIVE|GAME-DESIGN|AOI-filtered|AAA-RECONCILIATION|BC-linked|BC-INDEX) continue ;;
        esac
        [[ "$tok" == E-* ]] && continue
        # This is a hyphenated token in dimension-context that is NOT in the canonical enum
        ndiii_violations=$(( ndiii_violations + 1 ))
        ndiii_violation_msgs+=("${bc_rel}: bare non-canonical status token '$tok' in dimension-context (canonical enum: $(printf '%s\n' "$dim_status_enum" | sort -u | tr '\n' '/' | sed 's/\/$//'); add to enum in §3.1 or map to canonical value)")
      done <<< "$hyph_toks"

    done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

    echo "    Bare non-canonical hyphenated tokens in dimension-context: $ndiii_violations"
    if [[ $ndiii_violations -gt 0 ]]; then
      echo ""
      echo "    NON-CANONICAL BARE HYPHENATED STATUS TOKENS (must map to canonical enum or be registered in §3.1):"
      for msg in "${ndiii_violation_msgs[@]}"; do
        echo "      $msg"
      done
      errors+=("MISMATCH [bare non-canonical status token (n.iii)]: $ndiii_violations non-canonical hyphenated status token(s) found in dimension-context — map to canonical enum per methodology-layer.md §3.1")
      fail=1
    fi

  fi
fi
echo ""

# ============================================================================
# (p) CROSS-REFERENCE ID/DESCRIPTION CONSISTENCY  [NEW v1.15, P15-01]
# ============================================================================
# For each Related-BCs citation line in any BC body that cites one of the 11
# SS-06 dimension-owner BCs (BC-7.01.001..BC-7.11.001), assert that the inline
# description does NOT contain a DISTINCTIVE compound dimension keyword that
# unambiguously identifies a DIFFERENT dimension owner than the one cited.
#
# SCOPE: citations of BC-7.01.001..BC-7.11.001 only (dimension-owner BCs).
# This scope is intentionally narrow to avoid false positives on legitimate
# paraphrases in citations to other BCs. Cross-references that cite non-SS-06
# BCs, or SS-06 BCs with generic relationship prose ("composes with",
# "depended on by", "convergence loop reads this dimension") that carry no
# distinctive dimension keyword, are silently skipped.
#
# KEYWORD→OWNER MAP (compound/distinctive forms only — simple words excluded):
#   playtest-satisfaction  → BC-7.05.001  (Playtest-Satisfaction)
#   cert-preflight         → BC-7.06.001  (Cert-Preflight and Distribution-Readiness)
#   cert pre-flight        → BC-7.06.001  (same; space form used in prose)
#   cert preflight         → BC-7.06.001  (no-hyphen normalisation)
#   perf-budget            → BC-7.07.001  (Perf-Budget)
#   monetization-ethics    → BC-7.10.001  (Monetization-Ethics)
#   security-invariants    → BC-7.11.001  (Security-Invariants)
#   asset-completeness     → BC-7.04.001  (Asset-Completeness)
#   tests/replay           → BC-7.02.001  (Tests/Replay)
#   tests-replay           → BC-7.02.001  (hyphen normalisation)
#   sim/spec               → BC-7.01.001  (Sim/Spec)
#   sim-spec               → BC-7.01.001  (hyphen normalisation)
#   provenance/legal       → BC-7.08.001  (Provenance/Legal)
#   provenance-legal       → BC-7.08.001  (hyphen normalisation)
#   docs convergence       → BC-7.09.001  (Docs; scoped to "docs convergence" compound
#                                          to avoid flagging "docs dim" / generic "docs")
#
# Simple single-word forms ("playtest", "cert", "perf", "provenance") are NOT
# used as triggers because they appear legitimately in descriptions for many
# non-dimension-owner BCs (e.g., "Cert Pre-Flight Checklist" = BC-9.01.001).
# Compound forms are required for the trigger to fire.
#
# CITATION LINE EXTRACTION:
#   Pattern: "^- BC-7\.[0-9]+\.001" (bullet list items in Related-BCs sections).
#   Separator: Unicode em-dash (—, U+2014) or ASCII hyphen-minus; both handled
#   by extracting everything after the first whitespace following the BC-ID.
#   The grep -E pattern "^- BC-7\.[0-9]+\.001" is POSIX/BSD compatible.
#
# EXCLUSIONS:
#   - Lines containing "reason:" (YAML frontmatter changelog prose).
#   - Lines containing "through BC-" (range references like "BC-7.01.001 through
#     BC-7.11.001") — these are not specific single citations.
#
# POSITIVE-COVERAGE LOG: always printed.
# WILL FAIL until PO fixes the 2 known mis-anchors:
#   (1) BC-9.01.001 citing BC-7.05.001 for "Cert Pre-Flight" description
#       (BC-7.05.001 = Playtest-Satisfaction; cert-preflight → BC-7.06.001)
#   (2) BC-8.08.004 citing BC-7.07.001 for "playtest-satisfaction" description
#       (BC-7.07.001 = Perf-Budget; playtest-satisfaction → BC-7.05.001)
# Becomes green automatically after PO work.
#
# POSIX/BSD grep compatible (no -P; uses -E and -i only).
echo ""
echo "--- (p) cross-reference ID/description consistency (SS-06 dimension-owner citations) ---"
echo "    Scope: citations of BC-7.01.001..BC-7.11.001 with distinctive dimension keywords"

xref_violations=0
xref_violation_msgs=()
xref_validated=0

# Keyword→owner-BC mapping.
# Each entry is "KEYWORD_PATTERN:OWNER_BC_ID" where KEYWORD_PATTERN is a
# lowercase string to match (case-insensitively) against the inline description.
# We use a bash array and loop, checking each keyword against each citation line.
# POSIX/BSD: we use grep -i -F (fixed-string, case-insensitive) for each keyword.
declare -a KW_OWNER_MAP=(
  "playtest-satisfaction:BC-7.05.001"
  "cert-preflight:BC-7.06.001"
  "cert pre-flight:BC-7.06.001"
  "cert preflight:BC-7.06.001"
  "perf-budget:BC-7.07.001"
  "monetization-ethics:BC-7.10.001"
  "security-invariants:BC-7.11.001"
  "asset-completeness:BC-7.04.001"
  "tests/replay:BC-7.02.001"
  "tests-replay:BC-7.02.001"
  "sim/spec:BC-7.01.001"
  "sim-spec:BC-7.01.001"
  "provenance/legal:BC-7.08.001"
  "provenance-legal:BC-7.08.001"
  "docs convergence:BC-7.09.001"
)

while IFS= read -r -d $'\0' bc_file; do
  bc_rel="$(basename "$(dirname "$bc_file")")/$(basename "$bc_file")"

  # Extract lines that cite a SS-06 dimension-owner BC (BC-7.NN.001), excluding
  # changelog reason: lines and range-reference "through BC-" lines.
  # The em-dash separator (—, U+2014) is a multi-byte UTF-8 sequence; grep -E
  # with a literal UTF-8 string works on both BSD and GNU grep in a UTF-8 locale.
  # We match on the simpler "^- BC-7\.[0-9]+\.001" prefix and exclude exclusions.
  xref_lines=$(grep -E "^- BC-7\.[0-9]+\.001" "$bc_file" 2>/dev/null \
    | grep -v "reason:" \
    | grep -v "through BC-" \
    || true)

  [[ -z "$xref_lines" ]] && continue

  while IFS= read -r xref_line; do
    [[ -z "$xref_line" ]] && continue

    # Extract the cited BC-ID: the second whitespace-delimited token on the line
    # (the first is "-", the second is "BC-X.Y.Z").
    cited_id=$(printf '%s' "$xref_line" | awk '{print $2}')
    [[ -z "$cited_id" ]] && continue

    # Validate it is a BC-7.NN.001 form (not BC-7.01.001 from a range-ref; already
    # excluded by "through BC-" filter above, but double-check the ID format).
    if ! printf '%s' "$cited_id" | grep -qE '^BC-7\.[0-9]+\.001$' 2>/dev/null; then
      continue
    fi

    # Extract inline description: everything after the BC-ID on the line.
    # This includes the em-dash (or hyphen) separator and any text after it,
    # including parenthetical relationship clauses. We drop the leading "- BC-ID"
    # prefix and work with the rest.
    inline_desc=$(printf '%s' "$xref_line" \
      | sed "s/^- ${cited_id}//" \
      | sed 's/^[[:space:]]*//')

    xref_validated=$(( xref_validated + 1 ))

    # For each keyword in the map, check if the inline description (case-insensitively)
    # contains that keyword. If yes, and the expected owner differs from the cited BC,
    # record a violation.
    # POSIX/BSD: use printf + grep -i -F for case-insensitive fixed-string search.
    for kw_entry in "${KW_OWNER_MAP[@]}"; do
      kw_keyword="${kw_entry%%:*}"
      kw_owner="${kw_entry##*:}"

      # Check if the inline description contains this keyword (case-insensitive)
      if printf '%s' "$inline_desc" | grep -qiF "$kw_keyword" 2>/dev/null; then
        # Keyword found — check if cited BC == expected owner
        if [[ "$cited_id" != "$kw_owner" ]]; then
          # Look up the cited BC's actual title from BC-INDEX (for the error message)
          actual_title=$(grep -E "^\| ${cited_id} \|" "$BC_INDEX" 2>/dev/null \
            | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}' \
            | head -1 || true)
          xref_violations=$(( xref_violations + 1 ))
          xref_violation_msgs+=("${bc_rel}: cites ${cited_id} (actual title: '${actual_title:-NOT_FOUND}') but inline description contains '${kw_keyword}' which maps to ${kw_owner}")
          break  # One violation per citation line is enough
        fi
      fi
    done

  done <<< "$xref_lines"

done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" -print0)

# Positive-coverage log line (always printed — detects zero-scan / inert run).
echo "    Check (p): $xref_validated cross-references to SS-06 dimension-owner BCs validated against cited BC titles."
echo "    Cross-reference ID/description violations found: $xref_violations"

if [[ $xref_violations -gt 0 ]]; then
  echo ""
  echo "    CROSS-REFERENCE ID/DESCRIPTION MISMATCHES (cited BC ID does not match dimension keyword in description):"
  for msg in "${xref_violation_msgs[@]}"; do
    echo "      $msg"
  done
  errors+=("MISMATCH [cross-reference ID/description (p)]: $xref_violations BC cross-reference(s) cite a dimension-owner BC ID whose title contradicts the dimension keyword in the inline description — PO must fix cited BC ID (see list above)")
  fail=1
fi
echo ""

# ============================================================================
# (a.iv) PER-CAPABILITY PRD BC TOTALS + NFR TOTAL CONSISTENCY  [NEW v1.18]
# ============================================================================
# SUB-CHECK 1: Scan every prd-cap-*.md supplement for lines of the form
#   "Total CAP-NNN BCs: N"   (primary canonical form)
#   "Total CAP-NNN BCs ...: N"  (with annotation, e.g., parenthetical suffix)
# For each matched line, extract the CAP-NNN identifier and the stated count N.
# Source the authoritative per-cap count from the BC-INDEX.md H2 capability
# header "## CAP-NNN — <name> — N BCs" (already validated by check a.ii, so
# this N is trustworthy). FAIL if stated supplement N ≠ BC-INDEX N.
#
# Also detect the obsolete phrasing "Total BCs in this batch: N" (previously
# used in prd-cap-001.md before it was migrated to the canonical form). Any
# such line is reported as an advisory note — PO should migrate to canonical
# "Total CAP-NNN BCs: N" form. Not a hard failure because the capability cannot
# be determined unambiguously from the line alone.
#
# SUB-CHECK 2: NFR triple-consistency check.
#   (i)  Count actual "| NFR-NNN" table rows in nfr-catalog.md.
#   (ii) Parse "Total NFRs in this catalog: N" summary line in nfr-catalog.md.
#   (iii) Parse prd.md's inline NFR count statement of the form
#         "(N NFRs, NFR-001 through NFR-NNN)" in the §4 catalog reference line.
#   Assert all three values agree. Catches the class where rows were added
#   (e.g., NFR-036..041 for CAP-015) but the summary line was not updated.
#
# FALSE-POSITIVE AVOIDANCE:
#   - Skip lines starting with "|" (changelog version table rows, table body rows).
#   - Skip lines starting with ">" (blockquote constraint/annotation blocks).
#   - Skip lines containing "reason:" (YAML lifecycle prose in frontmatter).
#   - Per-cap pattern requires literal "BCs" (not "NFRs" or bare numbers).
#   - NFR prd.md pattern anchors to "NFRs, NFR-001 through" so changelog delta
#     lines ("+16 NFRs", "19 NFRs" in version table) do not match.
#
# POSITIVE-COVERAGE LOG: "Check (a.iv): N per-cap PRD BC totals + NFR total
# validated." always printed — detects zero-scan / inert run.
# POSIX/BSD-grep/awk compatible (no grep -P). (P18-01 recurrence prevention).
echo "--- (a.iv) Per-capability PRD BC totals + NFR total consistency ---"

aiv_violations=0
aiv_checked=0
aiv_violation_msgs=()
aiv_advisory_msgs=()

# ---------------------------------------------------------------------------
# Step A: Build authoritative per-cap count map from BC-INDEX.md headers.
# Source: "## CAP-NNN — <name> — N BCs" headers (already validated by a.ii).
# Output: associative array BCIDX_CAP_COUNT[CAP-NNN] = N
# ---------------------------------------------------------------------------
declare -A BCIDX_CAP_COUNT

if [[ -f "$BC_INDEX" ]]; then
  while IFS= read -r idx_line; do
    # Match: "## CAP-NNN" line containing "N BCs" at end
    cap_id_raw=$(printf '%s' "$idx_line" \
      | awk '{for(i=1;i<=NF;i++) if($i~/^CAP-[0-9]+/) {print $i; exit}}')
    cap_n_raw=$(printf '%s' "$idx_line" \
      | awk '{if(match($0,/[0-9]+ BCs$/)) {tok=substr($0,RSTART,RLENGTH); split(tok,a," "); print a[1]}}')
    if [[ -n "$cap_id_raw" ]] && [[ -n "$cap_n_raw" ]]; then
      BCIDX_CAP_COUNT["$cap_id_raw"]="$cap_n_raw"
    fi
  done < <(grep -E '^## CAP-[0-9]' "$BC_INDEX" 2>/dev/null || true)
fi

# ---------------------------------------------------------------------------
# Step B: Scan all prd-cap-*.md supplement files for per-cap total lines.
# ---------------------------------------------------------------------------
for supp_file in "$PRD_SUPPLEMENTS_DIR"/prd-cap-*.md; do
  [[ -f "$supp_file" ]] || continue
  supp_label=$(basename "$supp_file")

  # Use awk to scan each line in the supplement.
  # For each line, apply exclusion rules, then test per-cap patterns.
  # Output format: "TYPE|CAP_ID|STATED_N|line_snippet"
  #   TYPE = "CANONICAL"  for "Total CAP-NNN BCs: N" form
  #          "OBSOLETE"   for "Total BCs in this batch: N" form
  supp_matches=$(awk '
    {
      line = $0
      lc   = tolower(line)

      # --- Exclusion rules ---
      # (1) starts with "|"
      if (substr(line,1,1) == "|") next
      # (2) starts with ">"
      if (substr(line,1,1) == ">") next
      # (3) contains "reason:"
      if (index(lc,"reason:") > 0) next

      # --- Pattern 1: canonical "Total CAP-NNN BCs: N" or "Total CAP-NNN BCs ...: N"
      # Case-insensitive search; require "bcs" after "CAP-NNN"
      if (match(lc, /total cap-[0-9]+ bcs[^:]*: *[0-9]+/)) {
        tok = substr(line, RSTART, RLENGTH)
        # Extract CAP-NNN (case from original line, but match done on lc)
        # Re-do on original line for correct case
        orig_tok = substr(line, RSTART, RLENGTH)
        # Extract CAP-NNN from tok (find "CAP-" prefix, 3+ digits)
        cap_id = ""
        n_val  = ""
        split(tok, parts, " ")
        for (p in parts) {
          up = toupper(parts[p])
          if (up ~ /^CAP-[0-9]+/) { cap_id = up; break }
        }
        # Extract N: the integer after the final ":"
        if (match(tok, /:[[:space:]]*[0-9]+/)) {
          n_tok = substr(tok, RSTART+1, RLENGTH-1)
          gsub(/[^0-9]/, "", n_tok)
          n_val = n_tok + 0
        }
        if (cap_id != "" && n_val != "") {
          disp = substr(line, 1, 80)
          print "CANONICAL|" cap_id "|" n_val "|" disp
        }
        next
      }

      # --- Pattern 2: obsolete "Total BCs in this batch: N"
      if (match(lc, /total bcs in this batch:[[:space:]]*[0-9]+/)) {
        tok = substr(lc, RSTART, RLENGTH)
        n_val = ""
        if (match(tok, /:[[:space:]]*[0-9]+/)) {
          n_tok = substr(tok, RSTART+1, RLENGTH-1)
          gsub(/[^0-9]/, "", n_tok)
          n_val = n_tok + 0
        }
        disp = substr(line, 1, 80)
        print "OBSOLETE||" n_val "|" disp
        next
      }
    }
  ' "$supp_file" 2>/dev/null || true)

  # Process each match record
  while IFS='|' read -r match_type cap_id stated_n line_disp; do
    [[ -z "$match_type" ]] && continue

    if [[ "$match_type" == "OBSOLETE" ]]; then
      # Advisory: obsolete phrasing — capability cannot be determined unambiguously
      aiv_advisory_msgs+=("${supp_label}: obsolete phrasing 'Total BCs in this batch: ${stated_n}' — migrate to 'Total CAP-NNN BCs: N' form (cannot validate against BC-INDEX without explicit CAP-ID)")
      continue
    fi

    # CANONICAL form: validate against BC-INDEX authoritative count
    aiv_checked=$(( aiv_checked + 1 ))

    auth_count="${BCIDX_CAP_COUNT[$cap_id]:-}"

    if [[ -z "$auth_count" ]]; then
      # CAP-NNN not found in BC-INDEX — report as a violation
      aiv_violations=$(( aiv_violations + 1 ))
      aiv_violation_msgs+=("${supp_label}: 'Total ${cap_id} BCs: ${stated_n}' — ${cap_id} not found in BC-INDEX.md header map (cannot validate)")
    elif [[ "$stated_n" != "$auth_count" ]]; then
      aiv_violations=$(( aiv_violations + 1 ))
      aiv_violation_msgs+=("${supp_label}: 'Total ${cap_id} BCs: ${stated_n}' — BC-INDEX authoritative count for ${cap_id} is ${auth_count} (mismatch: supplement says ${stated_n}, BC-INDEX says ${auth_count})")
    else
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [a.iv per-cap ${cap_id}]: supplement=${stated_n} bcindex=${auth_count} in ${supp_label}"
      fi
    fi

  done <<< "$supp_matches"

done

# ---------------------------------------------------------------------------
# Step C: NFR triple-consistency check.
# ---------------------------------------------------------------------------
aiv_nfr_violations=0
aiv_nfr_violation_msgs=()
aiv_nfr_checked=0

if [[ ! -f "$NFR_CATALOG" ]]; then
  echo "    SKIP [NFR triple-check]: nfr-catalog.md not found at $NFR_CATALOG"
else
  # (i) Count actual "| NFR-NNN" table rows (lines starting "| NFR-" followed by digit)
  computed_nfr_rows=$(grep -cE '^\| NFR-[0-9]' "$NFR_CATALOG" 2>/dev/null || true)
  computed_nfr_rows="${computed_nfr_rows:-0}"

  # (ii) Parse "Total NFRs in this catalog: N" summary line.
  # Exclude lines starting with "|" or ">" or containing "reason:".
  catalog_nfr_stated=$(awk '
    {
      lc = tolower($0)
      if (substr($0,1,1) == "|") next
      if (substr($0,1,1) == ">") next
      if (index(lc,"reason:") > 0) next
      if (match(lc, /total nfrs in this catalog:[[:space:]]*[0-9]+/)) {
        tok = substr(lc, RSTART, RLENGTH)
        if (match(tok, /:[[:space:]]*[0-9]+/)) {
          n = substr(tok, RSTART+1, RLENGTH-1)
          gsub(/[^0-9]/, "", n)
          print n+0
          exit
        }
      }
    }
  ' "$NFR_CATALOG" 2>/dev/null || true)

  # (iii) Parse prd.md inline NFR count: "(N NFRs, NFR-001 through NFR-NNN)"
  # Anchor: "NFRs, NFR-001 through" to avoid changelog delta lines.
  # Exclude lines starting with "|" or ">" or containing "reason:".
  prd_nfr_stated=$(awk '
    {
      lc = tolower($0)
      if (substr($0,1,1) == "|") next
      if (substr($0,1,1) == ">") next
      if (index(lc,"reason:") > 0) next
      # Look for pattern: "(N NFRs, NFR-001 through" — case-insensitive
      if (match(lc, /\([0-9]+ nfrs, nfr-001 through/)) {
        tok = substr(lc, RSTART, RLENGTH)
        # Extract leading number: after "(" before " NFRs"
        gsub(/^\(/, "", tok)
        split(tok, a, " ")
        n = a[1] + 0
        if (n > 0) { print n; exit }
      }
    }
  ' "$PRD" 2>/dev/null || true)

  echo "    NFR rows computed (nfr-catalog.md):   ${computed_nfr_rows}"
  echo "    NFR total stated (catalog summary):   ${catalog_nfr_stated:-NOT_FOUND}"
  echo "    NFR count stated (prd.md §4 prose):   ${prd_nfr_stated:-NOT_FOUND}"

  # Assert: rows == catalog summary
  if [[ -n "$catalog_nfr_stated" ]]; then
    aiv_nfr_checked=$(( aiv_nfr_checked + 1 ))
    if [[ "$computed_nfr_rows" != "$catalog_nfr_stated" ]]; then
      aiv_nfr_violations=$(( aiv_nfr_violations + 1 ))
      aiv_nfr_violation_msgs+=("nfr-catalog.md: 'Total NFRs in this catalog: ${catalog_nfr_stated}' but ${computed_nfr_rows} actual '| NFR-NNN' rows counted — summary line must be corrected")
    else
      [[ "$VERBOSE" == true ]] && echo "    OK [a.iv NFR catalog]: stated=${catalog_nfr_stated} rows=${computed_nfr_rows}"
    fi
  fi

  # Assert: rows == prd.md stated
  if [[ -n "$prd_nfr_stated" ]]; then
    aiv_nfr_checked=$(( aiv_nfr_checked + 1 ))
    if [[ "$computed_nfr_rows" != "$prd_nfr_stated" ]]; then
      aiv_nfr_violations=$(( aiv_nfr_violations + 1 ))
      aiv_nfr_violation_msgs+=("prd.md: inline NFR count states ${prd_nfr_stated} but nfr-catalog.md has ${computed_nfr_rows} actual rows — prd.md §4 reference line must be corrected")
    else
      [[ "$VERBOSE" == true ]] && echo "    OK [a.iv NFR prd.md]: prd_stated=${prd_nfr_stated} rows=${computed_nfr_rows}"
    fi
  fi

  # Assert: catalog summary == prd.md stated (belt-and-suspenders cross-check)
  if [[ -n "$catalog_nfr_stated" ]] && [[ -n "$prd_nfr_stated" ]]; then
    if [[ "$catalog_nfr_stated" != "$prd_nfr_stated" ]]; then
      aiv_nfr_violations=$(( aiv_nfr_violations + 1 ))
      aiv_nfr_violation_msgs+=("NFR count divergence: nfr-catalog.md summary says ${catalog_nfr_stated} but prd.md §4 says ${prd_nfr_stated} — both must equal computed row count ${computed_nfr_rows}")
    fi
  fi

  if [[ $aiv_nfr_violations -gt 0 ]]; then
    echo ""
    echo "    NFR TRIPLE-CONSISTENCY VIOLATIONS:"
    for msg in "${aiv_nfr_violation_msgs[@]}"; do
      echo "      $msg"
    done
    errors+=("MISMATCH [NFR triple-consistency (a.iv)]: $aiv_nfr_violations NFR count mismatch(es) among nfr-catalog.md rows, catalog summary line, and prd.md §4 prose (see list above)")
    fail=1
  fi
fi

# Positive-coverage log (always printed — detects zero-scan / inert run)
aiv_total_checked=$(( aiv_checked + aiv_nfr_checked ))
echo "    Check (a.iv): ${aiv_checked} per-cap PRD BC totals + ${aiv_nfr_checked} NFR total check(s) validated (${aiv_total_checked} total)."
echo "    Per-cap BC total violations: ${aiv_violations}   NFR violations: ${aiv_nfr_violations}"

if [[ ${#aiv_advisory_msgs[@]} -gt 0 ]]; then
  echo ""
  echo "    ADVISORIES (obsolete per-cap total phrasing — PO should migrate to canonical form):"
  for msg in "${aiv_advisory_msgs[@]}"; do
    echo "      ADVISORY: $msg"
  done
fi

if [[ $aiv_violations -gt 0 ]]; then
  echo ""
  echo "    PER-CAP BC TOTAL MISMATCHES (supplement per-cap count ≠ BC-INDEX authoritative count):"
  for msg in "${aiv_violation_msgs[@]}"; do
    echo "      $msg"
  done
  errors+=("MISMATCH [per-cap PRD BC totals (a.iv)]: $aiv_violations supplement per-cap BC total line(s) do not match the BC-INDEX authoritative count (see list above) — PO must correct supplement total lines")
  fail=1
fi
echo ""

# ============================================================================
# (q) PER-DIMENSION ALLOWED-VALUE PROSE RESTATEMENT GUARD  [NEW v1.19, P19-01]
# ============================================================================
# Detects inline prose restatements of a dimension's allowed-value set that
# appear OUTSIDE the §3.1 canonical "Per-Dimension Allowed Value Subsets" table
# in methodology-layer.md.
#
# This is the 3rd recurrence of per-dimension subset drift between the §3.1
# table and a prose restatement of it (Pass-12 changelog note omitting DEGRADED
# from D-PLAY; earlier occurrences in Pass-11 BC body drift). The check flags
# restatements so they can be corrected before CI goes stale.
#
# DETECTION PATTERN (POSIX/BSD grep -E compatible):
#   Lines matching:
#     "D-[A-Z]+ allows [A-Z]"                (e.g. "D-PLAY allows GREEN/...")
#     "(D-[A-Z]+ allows"                      (parenthetical form)
#   Both forms capture the dimension ID (D-PLAY, D-PERF, etc.) and the token list
#   that follows "allows " up to the next whitespace-free boundary.
#
# §3.1 TABLE EXCLUSION:
#   The §3.1 canonical table itself contains "Allowed Values" in its header row
#   and rows of the form "| D-SIM | GREEN, DEGRADED, BLOCKED | ..." — these do
#   NOT match the detection pattern (no "allows" verb), so they are never flagged.
#
# VALIDATION:
#   For each flagged line, extract the claimed dimension ID (e.g. D-PLAY) and
#   the token list (slash- or comma-separated all-caps tokens). Parse the
#   §3.1 canonical allowed set for that dimension (from the DIM_ALLOWED_MAP
#   built by check (n.ii), reused here). Assert:
#     (i)  every token in the prose restatement is in the §3.1 canonical set
#     (ii) every token in the §3.1 canonical set appears in the prose restatement
#   FAIL if either assertion fails — the restatement is inconsistent with §3.1.
#   ADVISORY if the dimension is not found in §3.1 (cannot validate).
#
# EXCLUSIONS:
#   - Lines starting with ">" (blockquote / changelog entries) — historical
#     prose restatements in changelogs are tolerated; only operative content fails.
#   - Lines starting with "|" (table rows — part of §3.1 canonical table).
#   - Lines containing "reason:" (YAML lifecycle prose).
#
# POSITIVE-COVERAGE: "Check (q): N prose restatements validated." always printed.
# POSIX/BSD-grep/awk compatible (no grep -P). (P19-01 recurrence prevention).
echo ""
echo "--- (q) per-dimension allowed-value prose restatement guard ---"
echo "    Scope: methodology-layer.md operative lines matching 'D-<DIM> allows <TOKENS>'"
echo "    Convention: do not restate per-dimension subsets in prose; reference §3.1 instead."

if [[ ! -f "$METHODOLOGY_LAYER" ]]; then
  echo "    SKIP: methodology-layer.md not found at $METHODOLOGY_LAYER"
else
  q_violations=0
  q_validated=0
  q_violation_msgs=()

  # Extract restatement lines from methodology-layer.md.
  # We scan for lines containing the pattern "D-[A-Z]+ allows" (case-sensitive;
  # dimension IDs are always uppercase). Exclude changelog/reason lines:
  #   (a) Lines starting with ">" (blockquote — changelog entries).
  #   (b) Lines starting with "|" (table rows — §3.1 canonical table).
  #   (c) Lines containing "reason:" (YAML lifecycle prose).
  restatement_lines=$(grep -nE 'D-[A-Z]+ allows [A-Z]' "$METHODOLOGY_LAYER" 2>/dev/null \
    | grep -v '^[0-9]*:>' \
    | grep -v '^[0-9]*:|' \
    | grep -v 'reason:' \
    || true)

  if [[ -z "$restatement_lines" ]]; then
    echo "    No prose restatements found outside §3.1 table."
  else
    while IFS= read -r rline; do
      [[ -z "$rline" ]] && continue

      # Extract line number and content
      lineno=$(printf '%s' "$rline" | cut -d: -f1)
      content=$(printf '%s' "$rline" | cut -d: -f2-)

      # Extract dimension ID: first "D-[A-Z]+" token on the line
      dim_id=$(printf '%s' "$content" | grep -oE 'D-[A-Z]+' | head -1 || true)
      [[ -z "$dim_id" ]] && continue

      # Extract token list: everything after "allows " up to end-of-word boundary
      # The token list uses "/" or "," or "/" separators: "GREEN/DEGRADED/BLOCKED"
      # Extract the text after "allows " using awk (POSIX compatible)
      token_string=$(printf '%s' "$content" \
        | awk '{if(match($0,/allows [A-Z][A-Z\/-]+/)) print substr($0,RSTART+7,RLENGTH-7)}' \
        | head -1 || true)
      [[ -z "$token_string" ]] && continue

      # Tokenize: split on "/" and "," to get individual token names
      # Use tr + grep to normalize and extract [A-Z][A-Z-]+ tokens
      prose_tokens=$(printf '%s' "$token_string" \
        | tr '/,' '\n' \
        | grep -oE '[A-Z][A-Z-]+' \
        | grep -E '^[A-Z][A-Z-]+$' \
        | sort -u || true)
      [[ -z "$prose_tokens" ]] && continue

      # Look up §3.1 canonical allowed set for this dimension (from DIM_ALLOWED_MAP
      # built in check n.ii; may be empty if check (n) was skipped or §3.1 not parsed)
      canonical_allowed="${DIM_ALLOWED_MAP[$dim_id]:-}"

      if [[ -z "$canonical_allowed" ]]; then
        # Cannot validate — dimension not in §3.1 map (advisory, not hard fail)
        echo "    ADVISORY: line $lineno: '${dim_id} allows ...' — dimension not in §3.1 map; cannot validate token set"
        continue
      fi

      q_validated=$(( q_validated + 1 ))

      # canonical_allowed is space-separated; convert to newline-separated for comparison
      canonical_tokens=$(printf '%s\n' "$canonical_allowed" | tr ' ' '\n' \
        | grep -E '^[A-Z][A-Z-]+$' | sort -u || true)

      # Check (i): every prose token must be in the canonical set
      missing_from_canonical=()
      while IFS= read -r ptok; do
        [[ -z "$ptok" ]] && continue
        if ! printf '%s\n' "$canonical_tokens" | grep -qxF "$ptok" 2>/dev/null; then
          missing_from_canonical+=("$ptok")
        fi
      done <<< "$prose_tokens"

      # Check (ii): every canonical token must appear in the prose restatement
      missing_from_prose=()
      while IFS= read -r ctok; do
        [[ -z "$ctok" ]] && continue
        if ! printf '%s\n' "$prose_tokens" | grep -qxF "$ctok" 2>/dev/null; then
          missing_from_prose+=("$ctok")
        fi
      done <<< "$canonical_tokens"

      if [[ ${#missing_from_canonical[@]} -gt 0 || ${#missing_from_prose[@]} -gt 0 ]]; then
        q_violations=$(( q_violations + 1 ))
        prose_set=$(printf '%s\n' "$prose_tokens" | tr '\n' '/' | sed 's/\/$//')
        canon_set=$(printf '%s\n' "$canonical_tokens" | tr '\n' '/' | sed 's/\/$//')
        msg="line $lineno: ${dim_id} prose restatement {${prose_set}} != §3.1 canonical {${canon_set}}"
        [[ ${#missing_from_canonical[@]} -gt 0 ]] && \
          msg="${msg}; extra-in-prose: ${missing_from_canonical[*]}"
        [[ ${#missing_from_prose[@]} -gt 0 ]] && \
          msg="${msg}; missing-from-prose: ${missing_from_prose[*]}"
        q_violation_msgs+=("methodology-layer.md:${msg}")
      else
        if [[ "$VERBOSE" == true ]]; then
          echo "    OK [q line $lineno]: ${dim_id} prose restatement matches §3.1 canonical set"
        fi
      fi

    done <<< "$restatement_lines"
  fi

  # Positive-coverage log (always printed)
  echo "    Check (q): $q_validated prose restatements validated against §3.1 canonical subsets."
  echo "    Prose restatement mismatches: $q_violations"

  if [[ $q_violations -gt 0 ]]; then
    echo ""
    echo "    PROSE RESTATEMENT MISMATCHES (token set differs from §3.1 canonical table):"
    for msg in "${q_violation_msgs[@]}"; do
      echo "      $msg"
    done
    errors+=("MISMATCH [per-dim prose restatement (q)]: $q_violations prose restatement(s) of dimension allowed-value subsets differ from §3.1 canonical table in methodology-layer.md — correct the restatement or remove it and reference §3.1")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (r) ERROR-FAMILY REVERSE COVERAGE  [NEW v1.20, Pass-20 adversarial sweep]
# ============================================================================
# For every non-retired error family registered in error-taxonomy.md, assert
# that at least one BC file cites at least one code of that family.
#
# RETIRED-FAMILY EXCLUSION:
#   E-GEN is the only family currently marked retired. It is marked in two
#   complementary ways in error-taxonomy.md:
#     (1) Family Registry row (line ~36):
#           | ~~E-GEN~~ | ~~CAP-004~~ | ... |
#         The family token appears as "~~E-GEN~~" — strikethrough via double-tilde.
#     (2) Section heading (line ~245):
#           ## ~~E-GEN — Asset Generation Pipeline ...~~ [RETIRED PRD rev 1.6]
#         The H2 heading starts with "## ~~E-" (strikethrough section).
#     (3) Per-family breakdown table row (line ~704):
#           | ~~E-GEN~~ | ~~9~~ | **RETIRED v1.6** ... |
#         Same strikethrough pattern.
#   Strategy: scan error-taxonomy.md for ALL lines containing "~~E-<FAMILY>~~"
#   (two tildes before and after the family token). Extract the FAMILY name from
#   any such match. This builds the retired-family set.  E-GEN will be found in
#   all three locations (Family Registry, section heading prefix, breakdown table)
#   — any single detection is sufficient; duplicates are harmless.
#   Crucial: "~~" in the Family Registry row ONLY wraps the family token on
#   retired rows — active families like E-GENRE are NOT wrapped in tildes.
#
# ACTIVE-FAMILY EXTRACTION:
#   Parse the Family Registry table (lines starting with "| E-" that do NOT
#   contain "~~E-") to get the set of active (non-retired) registered families.
#   Match: lines of the form "| E-<FAMILY> |" in the Family Registry section.
#   We scan ALL "| E-" lines in the file, then subtract retired families — this
#   handles any family added to the registry in the future without script changes.
#
# BC-CITATION CHECK:
#   For each active family, run:
#     grep -rl 'E-<FAMILY>-[0-9]' behavioral-contracts/
#   and assert the result is non-empty (at least one BC cites that family).
#   POSIX/BSD-grep compatible (no -P; -E and -o only).
#
# POSITIVE-COVERAGE LOG:
#   "Check (r): N non-retired error families, all cited by >=1 BC"
#   OR list orphans on failure.
#
# EXPECTED: FAIL until PO reconciles E-KB / E-PLAY / E-REPLAY.
#   These families are registered in error-taxonomy.md but the BCs they own
#   currently emit unregistered symbolic tokens instead of citing E-KB/E-PLAY/
#   E-REPLAY codes. This check becomes green automatically after PO reconciliation.
#   E-GEN is NOT flagged because it is correctly excluded as retired.
#
# POSIX/BSD-grep compatible (no grep -P). (Pass-20 recurrence prevention).
echo ""
echo "--- (r) error-family reverse coverage: every non-retired family cited by >=1 BC ---"

if [[ ! -f "$ERROR_TAX" ]]; then
  echo "    SKIP: error-taxonomy.md not found at $ERROR_TAX"
else
  # ------------------------------------------------------------------
  # Step 1: Build retired-family set.
  # Detect any family token wrapped in ~~strikethrough~~ in the taxonomy.
  # Match: "~~E-<FAMILY>~~" where FAMILY = all-uppercase letters only (no digits).
  # This covers all three locations where E-GEN is retired:
  #   (1) Family Registry row:  | ~~E-GEN~~ | ~~CAP-004~~ | ...
  #   (2) Section heading:      ## ~~E-GEN — ...~~ [RETIRED PRD rev 1.6]
  #   (3) Breakdown table row:  | ~~E-GEN~~ | ~~9~~ | **RETIRED v1.6** ...
  # The pattern ~~E-[A-Z]+~~ (no digits, no hyphen inside the family name)
  # extracts "E-GEN" without matching "~~E-GEN-001~~" (individual codes that
  # are also struck through in the retired code table).
  # ------------------------------------------------------------------
  retired_families=$(grep -oE '~~E-[A-Z]+~~' "$ERROR_TAX" 2>/dev/null \
    | grep -oE 'E-[A-Z]+' \
    | sort -u || true)

  # ------------------------------------------------------------------
  # Step 2: Extract all registered family names from the Family Registry table.
  # The Family Registry table lives between "## Family Registry" and the next
  # "## " heading. Its rows have the form:
  #   "| E-FAMILY | ..."  (active)  or  "| ~~E-FAMILY~~ | ..."  (retired)
  # We extract field 2 (after stripping spaces and tildes), then filter to
  # tokens that match exactly ^E-[A-Z]+$ — all uppercase letters, no digits,
  # no trailing hyphen. This cleanly captures family names like E-EAP, E-REPLAY,
  # E-GENRE, etc., and excludes individual codes (E-EAP-001) and changelog rows.
  # ------------------------------------------------------------------
  all_families=$(awk '
    /^## Family Registry/ { in_section=1; next }
    /^## /                 { if (in_section) exit }
    in_section && /^\| / {
      # field 2: strip spaces and tildes, check it matches E-FAMILY exactly
      gsub(/[[:space:]~]/, "", $2)
      # $2 is the second space-delimited word; but we used FS=" " here.
      # Re-parse with FS="|" using split.
      n = split($0, f, "|")
      for (i=1; i<=n; i++) {
        gsub(/[[:space:]~]/, "", f[i])
        if (f[i] ~ /^E-[A-Z]+$/) { print f[i]; break }
      }
    }
  ' "$ERROR_TAX" 2>/dev/null | sort -u || true)

  # Subtract retired families: keep only families NOT in the retired set.
  # Build active_families as a newline-separated string.
  active_families=$(
    while IFS= read -r fam; do
      [[ -z "$fam" ]] && continue
      if ! printf '%s\n' "$retired_families" | grep -qxF "$fam" 2>/dev/null; then
        printf '%s\n' "$fam"
      fi
    done <<< "$all_families"
  )

  all_family_count=$(printf '%s\n' "$all_families" | grep -c . 2>/dev/null || echo 0)
  retired_family_count=$(printf '%s\n' "$retired_families" | grep -c . 2>/dev/null || echo 0)
  active_family_count=$(printf '%s\n' "$active_families" | grep -c . 2>/dev/null || echo 0)

  echo "    Registered families in taxonomy:   $all_family_count"
  echo "    Retired families (excluded):        $retired_family_count"
  echo "    Non-retired (active) families:      $active_family_count"

  if [[ "$VERBOSE" == true ]] && [[ -n "$retired_families" ]]; then
    echo "    Retired families detected (excluded from check):"
    printf '%s\n' "$retired_families" | while IFS= read -r rf; do
      echo "      $rf"
    done
  fi

  # ------------------------------------------------------------------
  # Step 3: For each active family, assert at least one BC file cites
  # at least one code from that family (E-FAMILY-<digit>).
  # Use grep -rl (recursive, list filenames only) for efficiency.
  # BSD/GNU grep both support -r and -l — POSIX/BSD compatible.
  # ------------------------------------------------------------------
  r_orphans=()
  r_cited=0

  while IFS= read -r fam; do
    [[ -z "$fam" ]] && continue
    # Search for any "E-FAMILY-<digit>" token under the BC directory tree.
    citing_bc=$(grep -rl "${fam}-[0-9]" "$BC_DIR" 2>/dev/null | head -1 || true)
    if [[ -n "$citing_bc" ]]; then
      r_cited=$(( r_cited + 1 ))
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [r ${fam}]: cited by >=1 BC"
      fi
    else
      r_orphans+=("$fam")
    fi
  done <<< "$active_families"

  r_orphan_count=${#r_orphans[@]}

  if [[ $r_orphan_count -eq 0 ]]; then
    echo "    Check (r): $active_family_count non-retired error families, all cited by >=1 BC."
  else
    echo "    Check (r): $active_family_count non-retired error families; $r_orphan_count orphan(s) found (0 BC citations)."
    echo ""
    echo "    ORPHANED ERROR FAMILIES (registered but not cited by any BC — PO reconciliation required):"
    for orf in "${r_orphans[@]}"; do
      echo "      $orf  (registered in error-taxonomy.md; no BC cites ${orf}-[0-9]* — PO must reconcile)"
    done
    errors+=("MISMATCH [error-family reverse coverage (r)]: $r_orphan_count non-retired error family/families registered in error-taxonomy.md but cited by ZERO behavioral contracts: ${r_orphans[*]} — EXPECTED: await PO reconciliation of E-KB/E-PLAY/E-REPLAY (becomes green after PO work)")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (s) §3.1 CROSS-TABLE CONSISTENCY  [NEW v1.21, Pass-23 I23-01]
# ============================================================================
# For each of the 4 canonical status values (GREEN, DEGRADED, DEGRADED-PENDING,
# BLOCKED), assert:
#   set_A(V) == set_B(V)
# where:
#   set_A(V) = dimensions listed in table (A) "Applicable Dimensions" cell for V
#   set_B(V) = dimensions that list V in their table (B) "Allowed Values" cell
#
# Table (A) layout: "| `VALUE` | Meaning | Applicable Dimensions |"
#   - GREEN and BLOCKED use sentinel text "All 11 dimensions"
#   - DEGRADED and DEGRADED-PENDING list explicit comma-separated D-XX codes
#
# Table (B) layout: "| D-DIM | GREEN, DEGRADED, ... | Rationale |"
#   - Each row is a dimension; field 3 (awk F=|) is the allowed-values column
#
# The 11 canonical dimension IDs (from §3.0):
#   D-SIM D-REPLAY D-IMPL D-ASSET D-PLAY D-CERT D-PERF D-PROV D-DOCS D-ETHICS D-SEC
#
# Algorithm:
#   Step 1: From table (B), build a map: dim -> set of status values it allows.
#           Already done in check (n.ii) as DIM_ALLOWED_MAP; re-use it here.
#           If DIM_ALLOWED_MAP is empty (check n skipped), parse table (B) fresh.
#   Step 2: Derive set_B(V) for each V by iterating DIM_ALLOWED_MAP.
#   Step 3: Parse table (A) for DEGRADED and DEGRADED-PENDING explicit dimension
#           lists; treat GREEN and BLOCKED as "all 11".
#   Step 4: Compare set_A(V) vs set_B(V) for each V; report any dim in one but
#           not the other.
#
# POSIX/BSD-awk compatible (no grep -P, no associative arrays in awk).
# Positive-coverage log always printed.
# ============================================================================
echo ""
echo "--- (s) §3.1 cross-table consistency (Canonical Status-Value Enum A vs Per-Dimension Subsets B) ---"

if [[ ! -f "$METHODOLOGY_LAYER" ]]; then
  echo "    SKIP: methodology-layer.md not found at $METHODOLOGY_LAYER"
else
  s_violations=0
  s_violation_msgs=()

  # Canonical dimension ID set (all 11, space-separated, ordered)
  ALL_DIMS="D-SIM D-REPLAY D-IMPL D-ASSET D-PLAY D-CERT D-PERF D-PROV D-DOCS D-ETHICS D-SEC"
  ALL_DIMS_COUNT=11

  # ----------------------------------------------------------------
  # Step 1: Build set_B(V) — for each status value V, the set of
  # dimensions whose table-(B) row includes V in their allowed list.
  # Always parse table (B) fresh to guarantee all 11 dimension rows
  # are captured, including rows that use bold markup (| **D-ETHICS** |).
  # DIM_ALLOWED_MAP (from check n.ii) uses a narrower grep pattern that
  # misses the **D-ETHICS** bold row, so we do not rely on it here.
  # ----------------------------------------------------------------
  declare -A S_DIM_ALLOWED_MAP

  # Parse table (B) fresh, stripping bold markers before field extraction.
  # Rows match either "^\| D-[A-Z]+" (plain) or "^\| **D-[A-Z]+" (bold).
  while IFS= read -r row; do
    # Strip bold markers so **D-ETHICS** → D-ETHICS in field 2
    clean_row=$(printf '%s' "$row" | sed 's/\*\*//g')
    dim_id=$(printf '%s' "$clean_row" | awk -F'|' '{gsub(/[[:space:]]/,"",$2); print $2}')
    allowed_raw=$(printf '%s' "$clean_row" | awk -F'|' '{print $3}')
    allowed_vals=$(printf '%s' "$allowed_raw" \
      | grep -oE '[A-Z][A-Z-]+-?[A-Z]*' \
      | grep -E '^[A-Z][A-Z-]+$' \
      | tr '\n' ' ')
    if [[ -n "$dim_id" ]] && printf '%s' "$dim_id" | grep -qE '^D-[A-Z]+$'; then
      S_DIM_ALLOWED_MAP["$dim_id"]="$allowed_vals"
    fi
  done < <(grep -E '^\| (\*\*)?D-[A-Z]+' "$METHODOLOGY_LAYER" 2>/dev/null \
    | grep 'GREEN' || true)

  s_dims_in_map=${#S_DIM_ALLOWED_MAP[@]}
  echo "    Table (B) dimensions parsed: $s_dims_in_map (expected: $ALL_DIMS_COUNT)"

  # Derive set_B(V) for each of the 4 canonical status values
  # set_B is a space-separated list of dimension IDs
  declare -A SET_B
  SET_B["GREEN"]=""
  SET_B["DEGRADED"]=""
  SET_B["DEGRADED-PENDING"]=""
  SET_B["BLOCKED"]=""

  for dim in $ALL_DIMS; do
    allowed="${S_DIM_ALLOWED_MAP[$dim]:-}"
    [[ -z "$allowed" ]] && continue
    for val in GREEN DEGRADED "DEGRADED-PENDING" BLOCKED; do
      if printf '%s' " $allowed " | grep -qF " $val "; then
        SET_B["$val"]="${SET_B[$val]} $dim"
      fi
    done
  done

  # Trim leading spaces
  for val in GREEN DEGRADED "DEGRADED-PENDING" BLOCKED; do
    SET_B["$val"]=$(printf '%s' "${SET_B[$val]}" | sed 's/^ *//')
  done

  # ----------------------------------------------------------------
  # Step 2: Parse table (A) to get set_A(V) for each status value.
  # Table (A) rows match: "^\| `VALUE`" in methodology-layer.md
  # GREEN and BLOCKED rows contain "All 11 dimensions" (sentinel).
  # DEGRADED and DEGRADED-PENDING rows list explicit D-XX IDs.
  # ----------------------------------------------------------------
  declare -A SET_A
  SET_A["GREEN"]=""
  SET_A["DEGRADED"]=""
  SET_A["DEGRADED-PENDING"]=""
  SET_A["BLOCKED"]=""

  # Extract table (A) rows — lines starting "| `" that contain a status value token
  # These are the 4 data rows of the Canonical Status-Value Enum table.
  while IFS= read -r trow; do
    # Determine which status value this row represents by checking backtick token
    row_val=""
    for v in GREEN DEGRADED "DEGRADED-PENDING" BLOCKED; do
      if printf '%s' "$trow" | grep -qF "\`${v}\`"; then
        row_val="$v"
        break
      fi
    done
    [[ -z "$row_val" ]] && continue

    # Extract the "Applicable Dimensions" cell — field 4 (awk F=|)
    appdim_cell=$(printf '%s' "$trow" | awk -F'|' '{print $4}')

    if printf '%s' "$appdim_cell" | grep -qiE 'All 11'; then
      # Sentinel: all 11 dimensions apply
      SET_A["$row_val"]="$ALL_DIMS"
    else
      # Extract explicit D-XX dimension IDs from the cell
      dims_in_cell=$(printf '%s' "$appdim_cell" \
        | grep -oE 'D-[A-Z]+' \
        | sort -u \
        | tr '\n' ' ' \
        | sed 's/ *$//')
      SET_A["$row_val"]="$dims_in_cell"
    fi
  done < <(grep -E "^\| \`(GREEN|DEGRADED|DEGRADED-PENDING|BLOCKED)\`" "$METHODOLOGY_LAYER" 2>/dev/null || true)

  # Diagnostic: log parsed sets
  if [[ "$VERBOSE" == true ]]; then
    for val in GREEN DEGRADED "DEGRADED-PENDING" BLOCKED; do
      echo "    set_A($val): ${SET_A[$val]:-<empty>}"
      echo "    set_B($val): ${SET_B[$val]:-<empty>}"
    done
  fi

  # ----------------------------------------------------------------
  # Step 3: Compare set_A(V) vs set_B(V) for all 4 values
  # For each value V, every dim in set_B(V) must be in set_A(V) and vice versa.
  # ----------------------------------------------------------------
  s_comparisons=0
  for val in GREEN DEGRADED "DEGRADED-PENDING" BLOCKED; do
    a_set="${SET_A[$val]:-}"
    b_set="${SET_B[$val]:-}"

    # Normalize to sorted newline-separated lists for comparison
    a_sorted=$(printf '%s\n' $a_set | sort -u | grep -E '^D-[A-Z]+$' || true)
    b_sorted=$(printf '%s\n' $b_set | sort -u | grep -E '^D-[A-Z]+$' || true)

    # dims in B but not A
    while IFS= read -r bdim; do
      [[ -z "$bdim" ]] && continue
      s_comparisons=$(( s_comparisons + 1 ))
      if ! printf '%s\n' "$a_sorted" | grep -qxF "$bdim" 2>/dev/null; then
        s_violations=$(( s_violations + 1 ))
        s_violation_msgs+=("status $val: $bdim is in Per-Dimension table (B) allowed set but MISSING from Canonical Enum table (A) 'Applicable Dimensions' cell")
      fi
    done <<< "$b_sorted"

    # dims in A but not B
    while IFS= read -r adim; do
      [[ -z "$adim" ]] && continue
      if ! printf '%s\n' "$b_sorted" | grep -qxF "$adim" 2>/dev/null; then
        s_violations=$(( s_violations + 1 ))
        s_violation_msgs+=("status $val: $adim is in Canonical Enum table (A) 'Applicable Dimensions' cell but NOT in Per-Dimension table (B) allowed set for $adim")
      fi
    done <<< "$a_sorted"
  done

  # Positive-coverage log (always printed)
  echo "    Check (s): $s_dims_in_map dimensions × 4 status values cross-checked ($s_comparisons dim-value pairs verified)."
  echo "    §3.1 cross-table mismatches: $s_violations"

  if [[ $s_violations -gt 0 ]]; then
    echo ""
    echo "    §3.1 CROSS-TABLE MISMATCHES (tables A and B disagree — reconcile to per-dimension prose/BC/ADR authority):"
    for smsg in "${s_violation_msgs[@]}"; do
      echo "      $smsg"
    done
    errors+=("MISMATCH [§3.1 cross-table consistency (s)]: $s_violations discrepancy/discrepancies between Canonical Status-Value Enum table (A) and Per-Dimension Allowed Value Subsets table (B) in methodology-layer.md §3.1 — reconcile both tables to match the authoritative per-dimension prose predicates, owner BCs, and ADR-0006")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (t) BC-7.* OWNER-ATTRIBUTION GUARD  [NEW v1.22, BROADENED v1.23, I24-01/I27-01]
# ============================================================================
# The BC-7.* dimension-evaluator family (BC-7.01.001..BC-7.11.001) is owned by
# SS-06 (Convergence Tracking Engine). Per-dimension "Subsystem:" headers in §3
# of methodology-layer.md denote the PRODUCING/EVALUATED subsystem (a legitimately
# different semantic); those headers must NOT be corrected by this check.
#
# v1.22 (I24-01): two narrow compound patterns caught "dimension-owner (SS-0X" and
# "owner BCs (SS-0X". Missed line-714-style phrasing where "dimension owner" (space,
# no parenthetical) was used instead — root cause of I27-01 surviving Pass-22..26.
#
# v1.23 (I27-01): BROADENED to cover the full mislabel class:
#
# TRIGGER: An operative line is a "dimension-owner attribution line" if it contains
# the phrase "dimension owner" or "dimension-owner" (space OR hyphen, case-insensitive).
#
# CHECKS ON TRIGGERED LINES:
#   (t.i)  If the line names ANY BC ID (BC-N.NN.NNN pattern), that ID must be one of
#          the 11 canonical dimension-owner BCs: BC-7.0[1-9].001 or BC-7.10.001 or
#          BC-7.11.001. A BC-8.*, BC-9.*, BC-1X.*, etc. named as a dimension owner FAILS.
#   (t.ii) If the line names ANY subsystem ID (SS-NN pattern) in an owner context, it
#          must be SS-06. An SS-0X (X != 6) in dimension-owner context FAILS.
#          Exception: "feeding the SS-06 dimension owner BC-7.05.001" correctly names
#          both a non-SS-06 producer and SS-06 owner — passes because SS-06 is present.
#          Sub-rule: FAIL only when NO SS-06 appears on the line AND some other SS-NN does.
#
# ALSO RETAINS (t.iii): the original v1.22 compound patterns as a belt-and-suspenders
# catch for "owner BCs (SS-0X" where X != 6 (I24-01 class), regardless of whether the
# line also contains "dimension owner".
#
# EXCLUSIONS:
#   - Lines starting with ">" (changelog/blockquote lines) — avoids false-positives
#     on historical notes documenting the I24-01/I27-01 fixes.
#
# CALIBRATION (verified against known-good corpus):
#   - Line 657: "SS-06 dimension-owner BCs (BC-7.01.001 through BC-7.11.001)"
#     → triggers (has "dimension-owner"); BC IDs are BC-7.0*.001 (valid); SS-06 present → PASS
#   - Line 735 (fixed): "SS-07 sign-off gate feeding the SS-06 dimension owner BC-7.05.001"
#     → triggers; BC-7.05.001 is valid; SS-06 IS present → PASS
#   - Lines 701-709 producer table: use "writes"/"maps", no "dimension owner" phrase → NOT triggered
#   - Per-dimension "Subsystem: SS-07" headers: no "dimension owner" phrase → NOT triggered
#   - PRE-FIX line 714 (I27-01): "BC-8.08.004 (... D-PLAY dimension owner, SS-07/SS-08 ...)"
#     → triggers (has "dimension owner"); BC-8.08.004 is NOT a valid dimension-owner BC → FAIL
#     Also: SS-06 absent, SS-07 present → (t.ii) FAIL → would have caught this before the fix
#
# FILES SCANNED: methodology-layer.md + all architecture/*.md files.
#
# POSIX/BSD grep/awk compatible (no -P; uses -E only).
# Positive-coverage log always printed.
echo ""
echo "--- (t) BC-7.* owner-attribution guard (SS-06 ownership, I24-01/I27-01 recurrence prevention) ---"
echo "    Convention: BC-7.* dimension-evaluator family is owned by SS-06; per-dimension"
echo "    'Subsystem:' headers in §3 denote the PRODUCING subsystem (a different semantic)."

t_violations=0
t_violation_msgs=()
t_scanned_lines=0
t_dim_owner_lines=0  # count of lines that triggered the "dimension owner" check

# Helper: returns true (0) if a BC id string is one of the 11 valid dimension-owner BCs.
# Valid pattern: BC-7.0[1-9].001  OR  BC-7.10.001  OR  BC-7.11.001
_t_is_valid_owner_bc() {
  local bcid="$1"
  # BC-7.01.001 through BC-7.09.001
  if printf '%s' "$bcid" | grep -qE '^BC-7\.0[1-9]\.001$'; then return 0; fi
  # BC-7.10.001 and BC-7.11.001
  if printf '%s' "$bcid" | grep -qE '^BC-7\.1[01]\.001$'; then return 0; fi
  return 1
}

_t_scan_file() {
  local fpath="$1"
  [[ ! -f "$fpath" ]] && return
  while IFS= read -r tline; do
    t_scanned_lines=$(( t_scanned_lines + 1 ))
    # Skip blockquote/changelog lines (start with ">")
    case "$tline" in
      ">"*) continue ;;
    esac

    # ----------------------------------------------------------------
    # (t.iii) RETAINED v1.22: compound patterns — belt-and-suspenders
    # "owner BCs (SS-0X" where X != 6
    # ----------------------------------------------------------------
    if printf '%s' "$tline" | grep -qE 'owner BCs \(SS-0[^6 ]'; then
      t_violations=$(( t_violations + 1 ))
      t_violation_msgs+=("$fpath [t.iii]: 'owner BCs' attributed to non-SS-06 subsystem — line: $tline")
    fi

    # ----------------------------------------------------------------
    # Check if this is a "dimension owner" attribution line
    # Matches: "dimension owner" (space) OR "dimension-owner" (hyphen), case-insensitive
    # ----------------------------------------------------------------
    tline_lc=$(printf '%s' "$tline" | tr '[:upper:]' '[:lower:]')
    case "$tline_lc" in
      *"dimension owner"* | *"dimension-owner"*)
        # This line is a dimension-owner attribution line
        t_dim_owner_lines=$(( t_dim_owner_lines + 1 ))

        # (t.i) Check any BC IDs named on this line
        # Extract all BC-N.NN.NNN tokens
        bc_ids_on_line=$(printf '%s' "$tline" | grep -oE 'BC-[0-9]+\.[0-9]+\.[0-9]+' || true)
        for bc_id in $bc_ids_on_line; do
          if ! _t_is_valid_owner_bc "$bc_id"; then
            t_violations=$(( t_violations + 1 ))
            t_violation_msgs+=("$fpath [t.i]: non-owner BC '$bc_id' attributed as dimension owner (valid owners: BC-7.0[1-9].001, BC-7.10.001, BC-7.11.001) — line: $tline")
          fi
        done

        # (t.ii) Check subsystem IDs: SS-06 must be present if any SS-NN appears
        # Extract all SS-NN tokens
        ss_ids_on_line=$(printf '%s' "$tline" | grep -oE 'SS-[0-9]+' || true)
        if [[ -n "$ss_ids_on_line" ]]; then
          has_ss06=0
          has_non_ss06=0
          for ss_id in $ss_ids_on_line; do
            case "$ss_id" in
              SS-06) has_ss06=1 ;;
              *)     has_non_ss06=1 ;;
            esac
          done
          # Fail only when no SS-06 is present AND some other SS-NN is (mis-attribution without correction)
          if [[ $has_ss06 -eq 0 ]] && [[ $has_non_ss06 -eq 1 ]]; then
            t_violations=$(( t_violations + 1 ))
            t_violation_msgs+=("$fpath [t.ii]: dimension-owner line names subsystem(s) but SS-06 absent — non-SS-06 subsystem in owner context — line: $tline")
          fi
        fi
        ;;
    esac
  done < "$fpath"
}

_t_scan_file "$METHODOLOGY_LAYER"
# Also scan other architecture docs that might carry an owner claim
_ARCH_DIR="$(dirname "$METHODOLOGY_LAYER")"
for _t_f in "$_ARCH_DIR"/*.md; do
  [[ "$_t_f" == "$METHODOLOGY_LAYER" ]] && continue
  [[ -f "$_t_f" ]] && _t_scan_file "$_t_f"
done

# Positive-coverage log (always printed)
echo "    Check (t): $t_scanned_lines lines scanned; $t_dim_owner_lines dimension-owner attribution lines examined."
echo "    Owner-attribution violations found: $t_violations"

if [[ $t_violations -gt 0 ]]; then
  echo ""
  echo "    BC-7.* OWNER-ATTRIBUTION VIOLATIONS (must say SS-06, not another subsystem):"
  for tmsg in "${t_violation_msgs[@]}"; do
    echo "      $tmsg"
  done
  errors+=("MISMATCH [BC-7.* owner-attribution guard (t)]: $t_violations operative line(s) attribute the BC-7.* dimension-evaluator family to a subsystem other than SS-06 — fix to 'SS-06' per ARCH-INDEX Subsystem Registry, subsystem-decomposition, and BC-7.* frontmatter")
  fail=1
fi
echo ""

# ============================================================================
# (u) HUMAN-GATED / CREATIVE-GATE TERM-MISUSE GUARD  [NEW v1.24, I28-01]
# ============================================================================
# CANONICAL RULE (methodology §2.8 / ADR-0007):
#   The `directed:true` cinematic-director creative sign-off is an INTERNAL creative
#   gate (error code: E-CIN-003; dimension: D-013). It MUST NOT use `human-gated`
#   fidelity-tier vocabulary, which is reserved for EXTERNAL third-party acts
#   (SAG-AFTRA consent, console cert sign-off, store publish, legal review).
#   NOTE: DI-007 is the PLAYTEST gate invariant (enforcer set: BC-8.08.004,
#   BC-7.05.001, BC-8.08.005) — it is NOT the cinematic creative gate's invariant.
#
# TRIGGER: any operative BC line containing both:
#   (1) a human-gated vocabulary term:
#         "human-gated", "human-gate task", "HumanGatedTaskPending", "-32008", "DI-006"
#   (2) a creative-gate context keyword:
#         "cinematic-director"
#         "cinematic" + "sign-off" (both present on same line)
#         "creative sign-off" / "creative-gate" / "creative gate"
#         "directed: true" / "directed:true"
#
# EXEMPTIONS: a triggering line PASSES if any of the following apply:
#   (E1) External-act exemption: line contains an external-act keyword —
#        "SAG-AFTRA", "consent", "likeness", "console cert", "store publish",
#        "legal review", "legal-review"
#        (these are legitimate third-party human-gated acts)
#   (E2) Negation exemption: "not" (case-insensitive) appears within the 60 chars
#        immediately preceding "human-gated" on the lowercased line.
#        Covers correctly-fixed contrast clauses:
#          "NOT the `human-gated` fidelity tier per ADR-0007"
#          "not a DI-006 human-gated task"
#          "not a `human-gated` fidelity tier task"
#        The 60-char window is narrow enough to avoid exempting bad lines where
#        "not" appears unrelated to "human-gated" earlier in the line.
#
# EXCLUSIONS (suppress trigger entirely):
#   Lines starting with ">" (blockquote / changelog annotation lines)
#   Lines containing "reason:" (YAML frontmatter lifecycle prose)
#
# SCANS: all BC-*.md files under BC_DIR ss-NN/ subdirectories AND all *.md files
#   under .factory/specs/architecture/ (flat + adrs/ subdir). The F34-01 process-gap
#   showed that studio-of-agents.md roster table cells (non-BC format) were not
#   caught by the BC-only scan. The broadened scope closes that class.
#   [BROADENED v1.28, F34-01]: architecture docs added to scan corpus.
#
# EXPECTED: FAIL until PO fixes BC-5.06.001, BC-12.12.008, BC-7.04.001, BC-7.05.001.
# Green automatically after PO work. Architecture files must be clean after F34-01 fix.
echo "--- (u) human-gated/creative-gate term-misuse guard (I28-01/F34-01 recurrence prevention) ---"
echo "    Convention: directed:true cinematic-director sign-off is an internal creative gate"
echo "    (E-CIN-003 / D-013). human-gated vocabulary is reserved for external acts"
echo "    (SAG-AFTRA consent, console cert, store publish, legal review)."
echo "    NOTE: DI-007 is the PLAYTEST gate, not the cinematic creative gate."
echo "    Scope (v1.28): BC files AND architecture/*.md files (incl. studio-of-agents.md)."

u_violations=0
u_lines_scanned=0
u_creative_gate_lines=0
u_violation_msgs=()

# Build the combined file list: BC files + architecture *.md files.
# BC files: depth-2 BC-*.md under BC_DIR (same as check (a)).
# Architecture files: all *.md under .factory/specs/architecture/ (flat + subdirs).
# We use a temporary file list to avoid nested process substitutions.
u_scan_bc_files=$(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" | sort 2>/dev/null || true)
u_scan_arch_files=$(find "$REPO_ROOT/.factory/specs/architecture" -name "*.md" | sort 2>/dev/null || true)
u_all_scan_files=$(printf '%s\n%s\n' "$u_scan_bc_files" "$u_scan_arch_files" | grep -v '^$' | sort -u || true)

while IFS= read -r ufile; do
  [[ ! -f "$ufile" ]] && continue
  # Compute a short relative label for the violation message
  u_rel_label="${ufile#$REPO_ROOT/.factory/specs/}"
  # Fall back: if prefix strip didn't work (e.g. BC_DIR path), strip BC_DIR prefix
  if [[ "$u_rel_label" == "$ufile" ]]; then
    u_rel_label="${ufile#$BC_DIR/}"
  fi

  while IFS= read -r uline; do
    u_lines_scanned=$(( u_lines_scanned + 1 ))

    # --- Exclusion rules ---
    # (1) blockquote lines: start with ">"
    case "$uline" in
      ">"*) continue ;;
    esac
    # (2) reason: lines (YAML frontmatter changelog prose)
    # Use case for POSIX compatibility
    case "$uline" in
      *"reason:"*) continue ;;
    esac

    # --- Test for human-gated vocabulary (condition 1) ---
    # Lower-case the line once for all case-insensitive tests
    uline_lc=$(printf '%s' "$uline" | tr '[:upper:]' '[:lower:]')

    has_hg_vocab=0
    case "$uline_lc" in
      *"human-gated"* | *"human-gate task"* | *"humangatedtaskpending"* | *"-32008"* | *"di-006"*)
        has_hg_vocab=1 ;;
    esac
    [[ $has_hg_vocab -eq 0 ]] && continue

    # --- Test for creative-gate context keyword (condition 2) ---
    # Keywords tested (case-insensitive via lowercased line):
    #   "cinematic-director"
    #   "cinematic" + "sign-off" (both must be present on same line)
    #   "creative sign-off" / "creative-gate" / "creative gate"
    #   "directed: true" / "directed:true"
    has_creative_gate=0
    case "$uline_lc" in
      *"cinematic-director"*)      has_creative_gate=1 ;;
      *"creative sign-off"*)       has_creative_gate=1 ;;
      *"creative-gate"*)           has_creative_gate=1 ;;
      *"creative gate"*)           has_creative_gate=1 ;;
      *"directed: true"*)          has_creative_gate=1 ;;
      *"directed:true"*)           has_creative_gate=1 ;;
    esac
    # "cinematic" + "sign-off" combination (both on same line)
    if [[ $has_creative_gate -eq 0 ]]; then
      case "$uline_lc" in
        *"cinematic"*)
          case "$uline_lc" in
            *"sign-off"*) has_creative_gate=1 ;;
          esac
          ;;
      esac
    fi
    [[ $has_creative_gate -eq 0 ]] && continue

    # This line has both human-gated vocab AND creative-gate context.
    u_creative_gate_lines=$(( u_creative_gate_lines + 1 ))

    # --- Apply external-act exemption ---
    # If the line contains an external-act keyword it is a legitimate
    # human-gated external act and PASSES even if creative-gate keywords appear.
    has_external_act=0
    case "$uline_lc" in
      *"sag-aftra"*)       has_external_act=1 ;;
      *"consent"*)         has_external_act=1 ;;
      *"likeness"*)        has_external_act=1 ;;
      *"console cert"*)    has_external_act=1 ;;
      *"store publish"*)   has_external_act=1 ;;
      *"legal review"*)    has_external_act=1 ;;
      *"legal-review"*)    has_external_act=1 ;;
    esac
    if [[ $has_external_act -eq 1 ]]; then
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [u exempt] $ufile: external-act exemption applies — line: $(printf '%s' "$uline" | cut -c1-100)"
      fi
      continue
    fi

    # --- Apply negation exemption ---
    # Lines that contain "human-gated" in a NEGATION / CONTRAST context
    # (e.g., "NOT the `human-gated` fidelity tier", "not a DI-006 human-gated task",
    # "not a `human-gated` fidelity tier task") are correctly-fixed lines that
    # EXPLAIN the distinction. They should NOT be flagged.
    # Detection: the word "not" (case-insensitive) appears BEFORE "human-gated"
    # on the same lowercased line (within 60 characters preceding the match).
    # This covers all five negation-clause forms seen in the corpus after the PO fix.
    # False-positive risk: a malformed line like "NOT a problem; human-gated cinematic"
    # would be wrongly exempted — but spec language is deliberate and this form does
    # not occur in the corpus. Belt-and-suspenders: require "not" within 60 chars of
    # "human-gated" in the lowercased line.
    has_negation=0
    # Use awk: find position of "human-gated"; check if "not" occurs within
    # the 60 chars immediately preceding it on the same line.
    has_negation=$(printf '%s' "$uline_lc" | awk '
      {
        hg_pos = index($0, "human-gated")
        if (hg_pos == 0) { print 0; exit }
        # Look in the 60-char window before human-gated
        start = hg_pos - 60
        if (start < 1) start = 1
        window = substr($0, start, hg_pos - start)
        # Does "not" appear in the window (as part of "not", "NOT", "not a", etc.)?
        if (index(window, "not") > 0) { print 1; exit }
        print 0
      }
    ' 2>/dev/null || printf '0')
    if [[ "$has_negation" == "1" ]]; then
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [u negation] $ufile: negation-clause exemption ('not...human-gated') — line: $(printf '%s' "$uline" | cut -c1-100)"
      fi
      continue
    fi

    # FAIL: human-gated vocabulary applied to cinematic-director creative gate
    # without any external-act exemption or negation exemption.
    u_violations=$(( u_violations + 1 ))
    u_violation_msgs+=("$u_rel_label: human-gated vocabulary applied to creative-gate context (must use E-CIN-003/D-013, not human-gated/DI-006; DI-007 is the playtest gate) — line: $(printf '%s' "$uline" | cut -c1-120)")

  done < "$ufile"
done <<< "$u_all_scan_files"

# Positive-coverage log (always printed — detects zero-scan / inert run)
echo "    Check (u): $u_lines_scanned lines scanned (BC + architecture docs) for human-gated/creative-gate term misuse, $u_creative_gate_lines creative-gate-context lines validated."
echo "    Human-gated/creative-gate term-misuse violations: $u_violations"

if [[ $u_violations -gt 0 ]]; then
  echo ""
  echo "    HUMAN-GATED/CREATIVE-GATE TERM MISUSE (BC body uses human-gated vocabulary for cinematic-director creative gate):"
  echo "    FIX: replace human-gated/DI-006 with E-CIN-003/D-013; use 'creative gate checklist item' not 'human-gated task'."
  echo "    NOTE: DI-007 is the PLAYTEST gate — do NOT graft DI-007 onto cinematic-director CREATIVE gate contexts."
  for umsg in "${u_violation_msgs[@]}"; do
    echo "      $umsg"
  done
  errors+=("MISMATCH [human-gated/creative-gate term misuse (u)]: $u_violations operative BC line(s) apply human-gated fidelity-tier vocabulary to the cinematic-director internal creative gate — fix per methodology §2.8 / ADR-0007: use E-CIN-003, D-013, 'creative gate checklist item' (not 'human-gated task'); DI-007 is the playtest gate, not the cinematic creative gate")
  fail=1
fi
echo ""

# ============================================================================
# (w) DI-007-ON-CREATIVE-GATE MIS-ANCHOR GUARD  [NEW v1.26, I-PASS32-01]
# ============================================================================
# CANONICAL RULE: DI-007 is the PLAYTEST human gate invariant (enforcer set:
#   BC-8.08.004, BC-7.05.001, BC-8.08.005). It MUST NOT be cited for the
#   cinematic-director CREATIVE gate. The creative gate is governed by D-013 +
#   E-CIN-003. Grafting DI-007 onto a cinematic-creative-gate context is a
#   mis-anchor of the I-PASS32-01 class — discovered when check (u)'s guard
#   validated removal of human-gated vocabulary but did NOT check that the
#   substituted invariant was correct, allowing DI-007 to be silently grafted
#   into 4 BCs' cinematic CREATIVE gate contexts.
#
# TRIGGER: an operative BC line contains BOTH:
#   (1) DI-007 citation (the token "DI-007" anywhere on the line)
#   (2) a CINEMATIC-CREATIVE-GATE context keyword — any of:
#         "cinematic-director"
#         "D-013"
#         "E-CIN-003"
#         "directed: true" / "directed:true"
#         "creative gate" / "creative-gate" / "creative sign-off"
#         "cinematic" + "creative"  (both on same line)
#
# FAIL: DI-007 (playtest invariant) cited in a cinematic-creative-gate context.
#
# FALSE-POSITIVE AVOIDANCE:
#   Legitimate DI-007 usages live in:
#     — Playtest contexts: lines containing "playtest", "fun-score", or
#       "playtest-satisfaction" — these do NOT contain the cinematic-creative-gate
#       keywords listed above, so they cannot trigger this check.
#     — XR-comfort analogical DI-007 (BC-14.*): these BCs contain neither
#       "cinematic-director", "D-013", "E-CIN-003", "directed:true", nor
#       "creative gate" — they will NOT trigger.
#   The check is therefore narrow: only lines that simultaneously cite DI-007 AND
#   contain a cinematic-creative-gate keyword are flagged. Pure playtest or XR
#   lines never contain those keywords.
#
#   Additional playtest-context exemption: if a triggering line also contains
#   any of "playtest", "fun-score", "playtest-satisfaction", "BC-8.08" it is
#   treated as a playtest-domain line and passes — belt-and-suspenders for any
#   edge-case proximity.
#
# EXCLUSIONS (suppress trigger entirely):
#   Lines starting with ">" (blockquote / changelog annotation lines)
#   Lines containing "reason:" (YAML frontmatter lifecycle prose)
#
# SCANS: all BC-*.md files under BC_DIR ss-NN/ subdirectories.
#
# EXPECTED: FAIL until PO removes 4 DI-007 cinematic grafts (the 4 BCs whose
# cinematic CREATIVE gate blocks were incorrectly annotated with DI-007 by the
# Pass-28 I28-01 fix). Green automatically after PO fix. (I-PASS32-01).
# POSIX/BSD compatible (no grep -P). Positive-coverage log always printed.
echo "--- (w) DI-007-on-creative-gate mis-anchor guard (I-PASS32-01 recurrence prevention) ---"
echo "    Convention: DI-007 is the PLAYTEST gate invariant. Cinematic creative gate uses D-013."
echo "    FAIL: any operative BC line cites DI-007 in a cinematic-creative-gate context."

w_violations=0
w_lines_scanned=0
w_creative_gate_lines=0
w_violation_msgs=()

while IFS= read -r bcfile; do
  [[ ! -f "$bcfile" ]] && continue
  while IFS= read -r wline; do
    w_lines_scanned=$(( w_lines_scanned + 1 ))

    # --- Exclusion rules ---
    # (1) blockquote lines: start with ">"
    case "$wline" in
      ">"*) continue ;;
    esac
    # (2) reason: lines (YAML frontmatter changelog prose)
    case "$wline" in
      *"reason:"*) continue ;;
    esac

    # --- Test for DI-007 citation (condition 1) ---
    # Case-insensitive via lowercased copy
    wline_lc=$(printf '%s' "$wline" | tr '[:upper:]' '[:lower:]')
    case "$wline_lc" in
      *"di-007"*) ;;
      *) continue ;;  # no DI-007 on this line — skip
    esac

    # --- Test for cinematic-creative-gate context keyword (condition 2) ---
    has_cin_creative=0
    case "$wline_lc" in
      *"cinematic-director"*)    has_cin_creative=1 ;;
      *"d-013"*)                 has_cin_creative=1 ;;
      *"e-cin-003"*)             has_cin_creative=1 ;;
      *"directed: true"*)        has_cin_creative=1 ;;
      *"directed:true"*)         has_cin_creative=1 ;;
      *"creative gate"*)         has_cin_creative=1 ;;
      *"creative-gate"*)         has_cin_creative=1 ;;
      *"creative sign-off"*)     has_cin_creative=1 ;;
    esac
    # "cinematic" + "creative" combination (both on same line)
    if [[ $has_cin_creative -eq 0 ]]; then
      case "$wline_lc" in
        *"cinematic"*)
          case "$wline_lc" in
            *"creative"*) has_cin_creative=1 ;;
          esac
          ;;
      esac
    fi
    [[ $has_cin_creative -eq 0 ]] && continue

    # This line has DI-007 AND a cinematic-creative-gate context keyword.
    w_creative_gate_lines=$(( w_creative_gate_lines + 1 ))

    # --- Belt-and-suspenders playtest exemption ---
    # If the line is anchored to a playtest or XR context, it is a legitimate
    # DI-007 usage that was incorrectly triggered. In practice this should not
    # fire (legitimate DI-007 lines do not contain cinematic-creative-gate
    # keywords), but guard it anyway.
    has_playtest_ctx=0
    case "$wline_lc" in
      *"playtest"*)                  has_playtest_ctx=1 ;;
      *"fun-score"*)                 has_playtest_ctx=1 ;;
      *"playtest-satisfaction"*)     has_playtest_ctx=1 ;;
      *"bc-8.08"*)                   has_playtest_ctx=1 ;;
    esac
    if [[ $has_playtest_ctx -eq 1 ]]; then
      if [[ "$VERBOSE" == true ]]; then
        echo "    OK [w playtest-exempt] $bcfile: playtest context — DI-007 is legitimate here — line: $(printf '%s' "$wline" | cut -c1-100)"
      fi
      continue
    fi

    # FAIL: DI-007 cited in a cinematic-creative-gate context with no playtest exemption.
    w_violations=$(( w_violations + 1 ))
    rel_bcfile="${bcfile#$BC_DIR/}"
    w_violation_msgs+=("$rel_bcfile: DI-007 (playtest gate) cited in cinematic-creative-gate context (D-013 is the correct creative gate dimension; DI-007 must not appear here) — line: $(printf '%s' "$wline" | cut -c1-120)")

  done < "$bcfile"
done < <(find "$BC_DIR" -mindepth 2 -maxdepth 2 -name "BC-*.md" | sort)

# Positive-coverage log (always printed — detects zero-scan / inert run)
echo "    Check (w): $w_lines_scanned BC lines scanned for DI-007-on-creative-gate mis-anchor, $w_creative_gate_lines DI-007+creative-gate co-occurrence lines evaluated."
echo "    DI-007-on-creative-gate mis-anchor violations: $w_violations"

if [[ $w_violations -gt 0 ]]; then
  echo ""
  echo "    DI-007-ON-CREATIVE-GATE MIS-ANCHOR VIOLATIONS (I-PASS32-01 class):"
  echo "    FIX: remove DI-007 from cinematic-director creative gate context."
  echo "    The correct creative gate invariant dimension is D-013 (not DI-007)."
  echo "    DI-007 belongs only in playtest contexts (BC-8.08.*, BC-7.05.001, fun-score)."
  for wmsg in "${w_violation_msgs[@]}"; do
    echo "      $wmsg"
  done
  errors+=("MISMATCH [DI-007-on-creative-gate mis-anchor (w)]: $w_violations operative BC line(s) cite DI-007 (the playtest gate invariant) in a cinematic-director creative gate context — DI-007 must NOT appear for cinematic creative gate; use D-013 instead (I-PASS32-01 recurrence prevention)")
  fail=1
fi
echo ""

# ============================================================================
# (x) PRD.MD §4 NFR-TABLE ID-SET PARITY  [NEW v1.27, F33-01]
# ============================================================================
# CANONICAL RULE: The prd.md §4 NFR summary table must contain exactly the same
# set of NFR IDs as the authoritative nfr-catalog.md.  A count match alone (check
# (a.iv) SUB-CHECK 2) does not detect membership drift: if NFR-036 is dropped and
# an NFR-042 is added the count remains 41 but the set is wrong. This check asserts
# set identity.
#
# METHOD:
#   (1) Parse the set of NFR IDs from nfr-catalog.md: every line matching
#       "^\| NFR-[0-9]" — extract the NFR-NNN token from field 2 (first pipe-delimited
#       field). These form the CATALOG set.
#   (2) Parse the set of NFR IDs from prd.md §4: every line matching
#       "^\| NFR-[0-9]" — extract the NFR-NNN token from field 2.
#       The prd.md §4 rows have the form "| NFR-NNN * |" or "| NFR-NNN **** |" etc.
#       Only the NFR-NNN prefix is extracted (strip trailing ` *` / ` ****`).
#       These form the PRD_TABLE set.
#   (3) ASSERT catalog set == prd table set (same members, order-independent).
#       Report: IDs in catalog but NOT in prd table (dropped NFRs — FAIL).
#               IDs in prd table but NOT in catalog (phantom NFRs — FAIL).
#
# FALSE-POSITIVE AVOIDANCE:
#   Only lines starting with "| NFR-" are parsed — changelog/reason lines,
#   header rows (NFR-ID), separator rows (|---|) do not match the pattern.
#   NFR IDs elsewhere in the file (prose, footnotes) are not in the §4 table
#   and are not extracted (those lines do not start with "| NFR-[0-9]").
#
# POSITIVE-COVERAGE: "Check (x): N catalog IDs × M prd.md §4 table IDs compared"
#   always printed. Should always read 41 × 41 after F33-01 fix.
#
# EXPECTED: GREEN now that F33-01 is fixed (prd.md v2.4). Any future CAP whose
# NFRs are added to the catalog but not to the prd.md §4 table will cause a FAIL.
# POSIX/BSD-grep/awk compatible (no grep -P). (F33-01 recurrence prevention).
echo "--- (x) prd.md §4 NFR-table ID-set parity (F33-01 recurrence prevention) ---"
echo "    Convention: prd.md §4 NFR summary table must enumerate exactly the same NFR IDs"
echo "    as nfr-catalog.md. A count match alone does not catch membership drift."

x_violations=0
x_violation_msgs=()

if [[ ! -f "$NFR_CATALOG" ]]; then
  echo "    SKIP: nfr-catalog.md not found at $NFR_CATALOG"
elif [[ ! -f "$PRD" ]]; then
  echo "    SKIP: prd.md not found at $PRD"
else
  # Step 1: collect catalog NFR ID set from nfr-catalog.md.
  # Lines matching "^| NFR-<digits>" — extract the NFR-NNN token (strip trailing text).
  # awk: field 2 after splitting on "|"; strip leading/trailing spaces; extract NFR-NNN prefix.
  catalog_nfr_ids=$(grep -E '^\| NFR-[0-9]' "$NFR_CATALOG" 2>/dev/null \
    | awk -F'|' '{
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        # Extract only the NFR-NNN part: match NFR- followed by digits at start of field
        if (match($2, /NFR-[0-9]+/)) {
          print substr($2, RSTART, RLENGTH)
        }
      }' \
    | sort -u || true)

  x_catalog_count=$(printf '%s\n' "$catalog_nfr_ids" | grep -c . 2>/dev/null || true)
  x_catalog_count="${x_catalog_count:-0}"

  # Step 2: collect prd.md §4 NFR ID set.
  # Lines matching "^| NFR-<digits>" in prd.md — same extraction logic.
  prd_nfr_ids=$(grep -E '^\| NFR-[0-9]' "$PRD" 2>/dev/null \
    | awk -F'|' '{
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        # Field 2 may be "NFR-001", "NFR-020 *", "NFR-036 ****" etc.
        # Extract only the NFR-NNN part.
        if (match($2, /NFR-[0-9]+/)) {
          print substr($2, RSTART, RLENGTH)
        }
      }' \
    | sort -u || true)

  x_prd_count=$(printf '%s\n' "$prd_nfr_ids" | grep -c . 2>/dev/null || true)
  x_prd_count="${x_prd_count:-0}"

  echo "    NFR IDs in catalog (nfr-catalog.md): $x_catalog_count"
  echo "    NFR IDs in prd.md §4 table:          $x_prd_count"

  # Step 3: set difference — IDs in catalog but NOT in prd table (dropped NFRs).
  if [[ -n "$catalog_nfr_ids" ]] && [[ -n "$prd_nfr_ids" ]]; then
    dropped_nfrs=$(comm -23 \
      <(printf '%s\n' "$catalog_nfr_ids") \
      <(printf '%s\n' "$prd_nfr_ids") \
      2>/dev/null || true)
    phantom_nfrs=$(comm -13 \
      <(printf '%s\n' "$catalog_nfr_ids") \
      <(printf '%s\n' "$prd_nfr_ids") \
      2>/dev/null || true)
  else
    dropped_nfrs=""
    phantom_nfrs=""
  fi

  # Report dropped NFRs (in catalog, absent from prd.md §4 table)
  if [[ -n "$dropped_nfrs" ]]; then
    while IFS= read -r nfr_id; do
      [[ -z "$nfr_id" ]] && continue
      x_violations=$(( x_violations + 1 ))
      x_violation_msgs+=("DROPPED: $nfr_id is registered in nfr-catalog.md but MISSING from prd.md §4 NFR summary table — add the row to §4")
    done <<< "$dropped_nfrs"
  fi

  # Report phantom NFRs (in prd.md §4 table, absent from catalog)
  if [[ -n "$phantom_nfrs" ]]; then
    while IFS= read -r nfr_id; do
      [[ -z "$nfr_id" ]] && continue
      x_violations=$(( x_violations + 1 ))
      x_violation_msgs+=("PHANTOM: $nfr_id appears in prd.md §4 table but is NOT registered in nfr-catalog.md — remove the row or register the NFR in the catalog")
    done <<< "$phantom_nfrs"
  fi

  # Positive-coverage log (always printed — detects zero-scan / inert run)
  echo "    Check (x): $x_catalog_count catalog IDs x $x_prd_count prd.md §4 table IDs compared; ID-set parity violations: $x_violations"

  if [[ $x_violations -gt 0 ]]; then
    echo ""
    echo "    PRD.MD §4 NFR TABLE ID-SET PARITY VIOLATIONS (F33-01 recurrence prevention):"
    echo "    DROPPED = in catalog but missing from §4 table; PHANTOM = in §4 table but not in catalog."
    for xmsg in "${x_violation_msgs[@]}"; do
      echo "      $xmsg"
    done
    errors+=("MISMATCH [prd.md §4 NFR-table ID-set parity (x)]: $x_violations NFR ID membership violation(s) between nfr-catalog.md and prd.md §4 summary table — prd.md §4 table must enumerate exactly the same NFR IDs as nfr-catalog.md (F33-01 recurrence prevention)")
    fail=1
  fi
fi
echo ""

# ============================================================================
# (y) SEAM-ORDINAL COLLISION GUARD  [NEW v1.28, F34-03]
# ============================================================================
# CANONICAL ORDERING (ADR-0004 / D-017 / subsystem-decomposition.md):
#   Seam 1 = engine-adapter (SS-01)
#   Seam 2 = asset-adapter (SS-03)
#   Seam 3 = distribution-adapter (SS-08)
#   Seam 4 = XR-adapter (SS-12)
#   Seam 5 = online-services-adapter (SS-13)
#
# F34-03 defect class: operative prose labeled the distribution adapter as "the
# fifth seam" when it is the THIRD. The product owner fixed prd-cap-009-010.md
# v1.1 to say "third of the five adapter seams." This guard prevents recurrence.
#
# ASSERTION 1: No operative line labels the distribution adapter as the "fifth"
#   seam. Pattern: any line containing BOTH a distribution-adapter context keyword
#   (distribution-adapter, distribution adapter, SS-08, "distribution seam",
#   "steamcmd", "butler", "fastlane", "store/distribution", "cert/dist") AND the
#   ordinal "fifth" (case-insensitive) is a FAIL (distribution = third, not fifth).
#
# ASSERTION 2: Any operative line that uses "fifth adapter seam" or "fifth seam"
#   (case-insensitive) in a seam-ordinal context MUST co-occur with an
#   online-services context keyword (online-services, online-services-adapter,
#   SS-13, "fifth seam" + "online", "BaaS", "nakama", "matchmaking",
#   "leaderboard", "identity/saves"). If "fifth seam" appears without an
#   online-services context keyword, it is a FAIL.
#
# EXCLUSIONS:
#   Lines starting with ">" (blockquote / changelog annotation lines)
#   Lines containing "reason:" (YAML frontmatter lifecycle prose)
#
# SCOPE: all .factory/specs/ *.md files (BC files + architecture docs +
#   domain-spec + prd.md + prd-supplements) — same broad scope as (o.ii).
#
# POSITIVE-COVERAGE LOG: "Check (y): N files scanned for seam-ordinal collision;
#   K violations found." always printed.
#
# EXPECTED: GREEN after PO's prd-cap-009-010.md v1.1 fix (distribution → "third").
# POSIX/BSD compatible (no grep -P). (F34-03 recurrence prevention).
echo "--- (y) seam-ordinal collision guard (F34-03 recurrence prevention) ---"
echo "    Canonical: engine=1, asset=2, distribution=3, XR=4, online-services=5."
echo "    Assert: distribution-adapter NOT labeled 'fifth'; 'fifth seam' ONLY with online-services context."

y_violations=0
y_violation_msgs=()
y_files_scanned=0

# Build file list: all *.md under .factory/specs/ (recursive).
y_scan_files=$(find "$REPO_ROOT/.factory/specs" -name "*.md" 2>/dev/null | sort || true)

while IFS= read -r yfile; do
  [[ ! -f "$yfile" ]] && continue
  y_files_scanned=$(( y_files_scanned + 1 ))
  y_rel="${yfile#$REPO_ROOT/}"

  # Read all non-excluded operative lines from this file once.
  # Exclusion: lines starting with ">" and lines containing "reason:".
  operative_lines=$(grep -v '^>' "$yfile" 2>/dev/null | grep -v 'reason:' || true)
  [[ -z "$operative_lines" ]] && continue

  # --- ASSERTION 1: distribution-adapter NOT labeled "fifth" ---
  # Trigger: line contains distribution-adapter context keyword AND the word "fifth".
  # Distribution-adapter context keywords (case-insensitive):
  #   distribution-adapter, distribution adapter, SS-08, distribution seam,
  #   steamcmd, butler, fastlane, store/distribution, cert/dist
  # We check case-insensitively by lowercasing the line.
  while IFS= read -r yline; do
    yline_lc=$(printf '%s' "$yline" | tr '[:upper:]' '[:lower:]')

    # Must contain "fifth"
    case "$yline_lc" in
      *"fifth"*) ;;
      *) continue ;;
    esac

    # Must contain a distribution-adapter context keyword
    has_dist_ctx=0
    case "$yline_lc" in
      *"distribution-adapter"*)  has_dist_ctx=1 ;;
      *"distribution adapter"*)  has_dist_ctx=1 ;;
      *"ss-08"*)                 has_dist_ctx=1 ;;
      *"distribution seam"*)     has_dist_ctx=1 ;;
      *"steamcmd"*)              has_dist_ctx=1 ;;
      *"fastlane"*)              has_dist_ctx=1 ;;
      *"store/distribution"*)    has_dist_ctx=1 ;;
      *"cert/dist"*)             has_dist_ctx=1 ;;
    esac
    # "butler" alone too common in prose; require "butler" + "distribution" or "butler" + "seam"
    if [[ $has_dist_ctx -eq 0 ]]; then
      case "$yline_lc" in
        *"butler"*)
          case "$yline_lc" in
            *"distribution"*|*"seam"*|*"release"*) has_dist_ctx=1 ;;
          esac
          ;;
      esac
    fi
    [[ $has_dist_ctx -eq 0 ]] && continue

    # Distribution-adapter context + "fifth" = violation
    y_violations=$(( y_violations + 1 ))
    y_violation_msgs+=("${y_rel}: distribution-adapter labeled 'fifth' (must be 'third'); canonical: engine=1 asset=2 distribution=3 XR=4 online-services=5 — line: $(printf '%s' "$yline" | cut -c1-120)")
  done <<< "$operative_lines"

  # --- ASSERTION 2: "fifth seam" / "fifth adapter seam" with a NON-online-services adapter context ---
  # Pattern: line contains "fifth" + "seam" AND a WRONG adapter context keyword (engine,
  # asset/generative, distribution, or XR — NOT online-services) → FAIL.
  # Rationale: lines that say "fifth seam" without any adapter context are ambiguous prose
  # (e.g., a line that says "This is the fifth adapter seam" in a paragraph that is clearly
  # about online-services but whose context keywords span multiple lines) and should PASS.
  # Only flag when "fifth seam" is ALSO anchored to a non-online-services adapter by a
  # context keyword ON THE SAME LINE.
  while IFS= read -r yline; do
    yline_lc=$(printf '%s' "$yline" | tr '[:upper:]' '[:lower:]')

    # Must contain "fifth" and "seam" on the same line
    case "$yline_lc" in
      *"fifth"*) ;;
      *) continue ;;
    esac
    case "$yline_lc" in
      *"seam"*) ;;
      *) continue ;;
    esac

    # Must NOT be a load-bearing-seam ordinal line (those are caught by o.ii, not here)
    # Exclude "fifth load-bearing seam" from this check to avoid double-counting with o.ii.
    case "$yline_lc" in
      *"load-bearing seam"*) continue ;;
    esac

    # Check for online-services context keyword (PASS if present — this seam IS the fifth)
    has_online_ctx=0
    case "$yline_lc" in
      *"online-services"*)   has_online_ctx=1 ;;
      *"online services"*)   has_online_ctx=1 ;;
      *"ss-13"*)             has_online_ctx=1 ;;
      *"baas"*)              has_online_ctx=1 ;;
      *"nakama"*)            has_online_ctx=1 ;;
      *"matchmaking"*)       has_online_ctx=1 ;;
      *"leaderboard"*)       has_online_ctx=1 ;;
      *"identity/saves"*)    has_online_ctx=1 ;;
    esac
    [[ $has_online_ctx -eq 1 ]] && continue

    # Check for a WRONG adapter context: engine, asset, distribution, or XR on the same line.
    # If none of these wrong-adapter context keywords are present, the line is ambiguous
    # (e.g., "This is the fifth adapter seam" in isolation) and passes.
    has_wrong_adapter_ctx=0
    case "$yline_lc" in
      *"engine-adapter"*)         has_wrong_adapter_ctx=1 ;;
      *"engine adapter"*)         has_wrong_adapter_ctx=1 ;;
      *"ss-01"*)                  has_wrong_adapter_ctx=1 ;;
      *"asset-adapter"*)          has_wrong_adapter_ctx=1 ;;
      *"asset adapter"*)          has_wrong_adapter_ctx=1 ;;
      *"generative asset"*)       has_wrong_adapter_ctx=1 ;;
      *"ss-03"*)                  has_wrong_adapter_ctx=1 ;;
      *"distribution-adapter"*)   has_wrong_adapter_ctx=1 ;;
      *"distribution adapter"*)   has_wrong_adapter_ctx=1 ;;
      *"distribution seam"*)      has_wrong_adapter_ctx=1 ;;
      *"ss-08"*)                  has_wrong_adapter_ctx=1 ;;
      *"steamcmd"*)               has_wrong_adapter_ctx=1 ;;
      *"fastlane"*)               has_wrong_adapter_ctx=1 ;;
      *"store/distribution"*)     has_wrong_adapter_ctx=1 ;;
      *"xr-adapter"*)             has_wrong_adapter_ctx=1 ;;
      *"xr adapter"*)             has_wrong_adapter_ctx=1 ;;
      *"xr seam"*)                has_wrong_adapter_ctx=1 ;;
      *"ss-12"*)                  has_wrong_adapter_ctx=1 ;;
      *"openxr"*)                 has_wrong_adapter_ctx=1 ;;
    esac
    [[ $has_wrong_adapter_ctx -eq 0 ]] && continue

    # "fifth seam" + non-online-services adapter context = wrong ordinal → FAIL
    y_violations=$(( y_violations + 1 ))
    y_violation_msgs+=("${y_rel}: 'fifth seam' co-occurs with non-online-services adapter context (canonical fifth seam = online-services-adapter/SS-13; engine=1, asset=2, distribution=3, XR=4) — line: $(printf '%s' "$yline" | cut -c1-120)")
  done <<< "$operative_lines"

done <<< "$y_scan_files"

# Positive-coverage log (always printed)
echo "    Check (y): $y_files_scanned files scanned for seam-ordinal collision; $y_violations violation(s) found."

if [[ $y_violations -gt 0 ]]; then
  echo ""
  echo "    SEAM-ORDINAL COLLISION VIOLATIONS (F34-03 recurrence prevention):"
  echo "    Canonical: engine=1, asset=2, distribution=3 (SS-08), XR=4 (SS-12), online-services=5 (SS-13)."
  for ymsg in "${y_violation_msgs[@]}"; do
    echo "      $ymsg"
  done
  errors+=("MISMATCH [seam-ordinal collision (y)]: $y_violations operative line(s) apply wrong ordinal to a seam — distribution-adapter must be 'third'; 'fifth seam' must co-occur with online-services context (F34-03 recurrence prevention)")
  fail=1
fi
echo ""

# ============================================================================
# (z) BASE MANIFEST SEAM-ENUM COMPLETENESS  [NEW v1.29, F35-01]
# ============================================================================
# Asserts that the `seam` field enum in the §1.3 base Capability Manifest
# fenced schema block (adapter-protocols.md) contains exactly the same set of
# seam tokens as the top-level seam keys in the §8 Compatibility Matrix fenced
# schema block.
#
# Anchoring strategy (POSIX/BSD-awk, no grep -P):
#   §1.3 base enum — locate the FIRST fenced block (``` ... ```) that contains
#     a line matching `"seam":` followed by `<...>` angle-bracket content.
#     Extract the tokens from the pipe-separated `<tok1|tok2|...>` value.
#   §8 matrix seam keys — locate the LAST fenced block and extract lines of the
#     form `"<seam-key>": {` — these are the top-level keys of the "seams": {...}
#     object. The canonical five keys are the five adapter seam identifiers.
#
# EXPECTED: 5 tokens in each set, set equality → 0 violations after F35-01 fix.
# POSIX/BSD-grep/awk compatible (no grep -P). (F35-01 recurrence prevention).
echo "--- (z) §1.3 base manifest seam-enum completeness (F35-01 recurrence prevention) ---"
echo "    Assert: 'seam' enum in §1.3 base schema == seam keys in §8 compatibility matrix."
echo "    Expected 5 tokens: engine-adapter asset-adapter distribution-adapter xr-adapter online-services-adapter"

z_violations=0
z_violation_msgs=()
z_enum_count=0
z_matrix_count=0

ADAPTER_PROTOCOLS="$REPO_ROOT/.factory/specs/architecture/adapter-protocols.md"

if [[ ! -f "$ADAPTER_PROTOCOLS" ]]; then
  echo "    SKIP: adapter-protocols.md not found at $ADAPTER_PROTOCOLS"
else
  # --- Extract §1.3 base enum tokens ---
  # Strategy: awk over the whole file; track fenced-block state (toggle on ```).
  # Inside the FIRST fenced block that contains a line matching `"seam":` with `<`,
  # extract the angle-bracket token list. Stop after the first matching block.
  #
  # Output: one token per line (e.g., engine-adapter, asset-adapter, …)
  z_enum_raw=$(awk '
    /^```/ {
      in_fence = !in_fence
      if (!in_fence && found_seam_in_block) {
        # Closing the block that had the seam line — we are done
        exit
      }
      if (!in_fence) {
        found_seam_in_block = 0
      }
      next
    }
    in_fence && /\"seam\"/ && /<[a-z]/ {
      found_seam_in_block = 1
      # Extract the angle-bracket content: everything between < and >
      match($0, /<[^>]+>/)
      if (RSTART > 0) {
        tokens = substr($0, RSTART+1, RLENGTH-2)
        n = split(tokens, arr, "|")
        for (i=1; i<=n; i++) {
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[i])
          if (arr[i] != "") print arr[i]
        }
      }
    }
  ' "$ADAPTER_PROTOCOLS" 2>/dev/null || true)

  # --- Extract §8 matrix seam keys ---
  # Strategy: awk over the whole file; track fenced-block state.
  # In ANY fenced block, collect lines matching `"<word>": {` or `"<word>": {`
  # where the word looks like a seam identifier (contains "-adapter").
  # We only want the top-level seam keys (not nested keys inside the seam objects).
  # Heuristic: lines that contain "-adapter": { (with adapter identifier pattern).
  z_matrix_raw=$(awk '
    /^```/ {
      in_fence = !in_fence
      next
    }
    in_fence && /"[a-z][a-z-]+-adapter"[[:space:]]*:/ {
      # Extract the quoted key: e.g. "engine-adapter", "online-services-adapter"
      match($0, /"[a-z][a-z-]+-adapter"/)
      if (RSTART > 0) {
        key = substr($0, RSTART+1, RLENGTH-2)
        print key
      }
    }
  ' "$ADAPTER_PROTOCOLS" 2>/dev/null | sort -u || true)

  # Count tokens
  if [[ -n "$z_enum_raw" ]]; then
    z_enum_count=$(printf '%s\n' "$z_enum_raw" | grep -c '[a-z]' || true)
  fi
  if [[ -n "$z_matrix_raw" ]]; then
    z_matrix_count=$(printf '%s\n' "$z_matrix_raw" | grep -c '[a-z]' || true)
  fi

  echo "    §1.3 base enum tokens ($z_enum_count): $(printf '%s\n' "$z_enum_raw" | tr '\n' ' ')"
  echo "    §8 matrix seam keys ($z_matrix_count):   $(printf '%s\n' "$z_matrix_raw" | tr '\n' ' ')"

  # --- Assert set equality ---
  # Tokens in matrix but missing from enum
  if [[ -n "$z_matrix_raw" ]]; then
    while IFS= read -r z_tok; do
      [[ -z "$z_tok" ]] && continue
      if ! printf '%s\n' "$z_enum_raw" | grep -qxF "$z_tok" 2>/dev/null; then
        z_violations=$(( z_violations + 1 ))
        z_violation_msgs+=("seam token '$z_tok' present in §8 matrix keys but MISSING from §1.3 base enum")
      fi
    done <<< "$z_matrix_raw"
  fi

  # Tokens in enum but missing from matrix
  if [[ -n "$z_enum_raw" ]]; then
    while IFS= read -r z_tok; do
      [[ -z "$z_tok" ]] && continue
      if ! printf '%s\n' "$z_matrix_raw" | grep -qxF "$z_tok" 2>/dev/null; then
        z_violations=$(( z_violations + 1 ))
        z_violation_msgs+=("seam token '$z_tok' present in §1.3 base enum but MISSING from §8 matrix keys")
      fi
    done <<< "$z_enum_raw"
  fi

  # Assert count == 5 for each set (belt-and-suspenders: catches truncated parse)
  if [[ "$z_enum_count" -ne 5 ]]; then
    z_violations=$(( z_violations + 1 ))
    z_violation_msgs+=("§1.3 base enum has $z_enum_count tokens (expected 5: engine-adapter asset-adapter distribution-adapter xr-adapter online-services-adapter)")
  fi
  if [[ "$z_matrix_count" -ne 5 ]]; then
    z_violations=$(( z_violations + 1 ))
    z_violation_msgs+=("§8 matrix seam keys has $z_matrix_count keys (expected 5)")
  fi
fi

# Positive-coverage log (always printed)
echo "    Check (z): §1.3 enum=$z_enum_count tokens, §8 matrix=$z_matrix_count seam keys; $z_violations violation(s) found."

if [[ $z_violations -gt 0 ]]; then
  echo ""
  echo "    BASE-MANIFEST SEAM-ENUM VIOLATIONS (F35-01 recurrence prevention):"
  echo "    §1.3 base enum must list all five canonical seams (engine-adapter, asset-adapter,"
  echo "    distribution-adapter, xr-adapter, online-services-adapter) and must equal the §8 matrix keys."
  for zmsg in "${z_violation_msgs[@]}"; do
    echo "      $zmsg"
  done
  errors+=("MISMATCH [base-manifest seam-enum (z)]: $z_violations violation(s) — §1.3 base enum and §8 matrix seam keys are not equal (F35-01 recurrence prevention)")
  fail=1
fi
echo ""

# ============================================================================
# (aa) FRONTMATTER TRACEABILITY PATH EXISTENCE  [NEW v1.30, O36-01]
# ============================================================================
# Scans ALL .factory/specs files that carry frontmatter `inputs:` and/or
# `traces_to:` YAML list keys. For each path value starting with ".factory/",
# strips any "#fragment" suffix and parenthetical annotations "(§…)" before
# resolving against the filesystem (REPO_ROOT-relative). Asserts every such
# path resolves to an existing filesystem entry (file OR directory — directory
# paths with trailing "/" are valid inputs: entries). Reports unresolved
# (path, source-file) pairs. Paths NOT starting with ".factory/" are skipped
# (not workspace-relative).
#
# SCOPE: all .md files under .factory/specs/ (recursive).
# POSITIVE-COVERAGE LOG: "Check (aa): N .factory/ paths verified across M
#   source files; K unresolved path(s) found."
# POSIX/BSD-awk compatible (no grep -P). (O36-01 recurrence prevention).
echo "--- (aa) frontmatter traceability path-existence guard (O36-01 recurrence prevention) ---"
echo "    Assert: every .factory/-prefixed path in traces_to:/inputs: frontmatter resolves to an existing file."

aa_violations=0
aa_violation_msgs=()
aa_total_paths=0
aa_source_files=0

# Use awk to extract all .factory/ paths from traces_to/inputs frontmatter,
# then check existence in bash. Output format: filepath|lineno|path_value
aa_extracted_paths=""
aa_extracted_paths=$(find "$REPO_ROOT/.factory/specs" -name "*.md" 2>/dev/null | sort | while IFS= read -r specfile; do
  awk -v fname="$specfile" '
    /^---/ {
      in_front = !in_front
      next
    }
    in_front && /^(traces_to|inputs)[[:space:]]*:/ {
      in_list = 1
      next
    }
    in_front && in_list && /^  - / {
      path_val = substr($0, 5)
      # Strip leading whitespace
      gsub(/^[[:space:]]+/, "", path_val)
      # Strip trailing whitespace
      gsub(/[[:space:]]+$/, "", path_val)
      # Strip #fragment suffix
      sub(/#[^[:space:]]*$/, "", path_val)
      # Strip trailing whitespace again after fragment strip
      gsub(/[[:space:]]+$/, "", path_val)
      # Strip parenthetical annotation at end: e.g. " (§5A)" or " (§3)"
      sub(/[[:space:]]+\([^)]*\)$/, "", path_val)
      # Strip trailing whitespace one more time
      gsub(/[[:space:]]+$/, "", path_val)
      if (path_val ~ /^\.factory\//) {
        print fname "|" NR "|" path_val
      }
      next
    }
    in_front && in_list && /^[^[:space:]]/ { in_list = 0 }
    !in_front { in_list = 0 }
  ' "$specfile" 2>/dev/null || true
done)

if [[ -n "$aa_extracted_paths" ]]; then
  # Count unique source files and total paths
  aa_total_paths=$(printf '%s\n' "$aa_extracted_paths" | grep -c '|' || true)
  aa_source_files=$(printf '%s\n' "$aa_extracted_paths" | cut -d'|' -f1 | sort -u | grep -c '.' || true)

  # Check each path for existence
  while IFS='|' read -r aa_src aa_line aa_path; do
    [[ -z "$aa_path" ]] && continue
    aa_full_path="$REPO_ROOT/$aa_path"
    if [[ ! -e "$aa_full_path" ]]; then
      aa_violations=$(( aa_violations + 1 ))
      aa_rel_src="${aa_src#$REPO_ROOT/}"
      aa_violation_msgs+=("${aa_rel_src}:${aa_line}: references non-existent path '$aa_path'")
    fi
  done <<< "$aa_extracted_paths"
fi

# Positive-coverage log (always printed)
echo "    Check (aa): $aa_total_paths .factory/ paths verified across $aa_source_files source files; $aa_violations unresolved path(s) found."

if [[ $aa_violations -gt 0 ]]; then
  echo ""
  echo "    FRONTMATTER PATH-EXISTENCE VIOLATIONS (O36-01 recurrence prevention):"
  echo "    Every .factory/-prefixed path in traces_to:/inputs: frontmatter must exist on disk (file or directory)."
  echo "    Tip: subsystem directory alias (e.g., ss-02 vs ss-03) and typos are common causes."
  for aamsg in "${aa_violation_msgs[@]}"; do
    echo "      $aamsg"
  done
  errors+=("MISMATCH [frontmatter path-existence (aa)]: $aa_violations unresolved .factory/ path(s) in traces_to:/inputs: frontmatter (O36-01 recurrence prevention)")
  fail=1
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "=== SUMMARY ==="
if [[ $fail -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
  echo ""
  echo "  BC files (computed):               $computed_bc"
  echo "  Error codes (computed):            $computed_ecodes"
  echo "  Priority coverage:                 $computed_with_priority / $computed_bc (100%)"
  echo "  VP P0 (computed from table):       ${computed_vp_p0:-N/A}"
  echo "  VP P1 (computed from table):       ${computed_vp_p1:-N/A}"
  echo "  BC H1/INDEX title sync:            ${bc_title_checked} checked, 0 mismatches"
  echo "  BC frontmatter schema:             $computed_bc checked, 0 violations"
  echo "  Cap section-header counts (a.ii):  ${cap_header_check_count:-0} headers validated, 0 mismatches"
  echo "  Alt-phrasing BC counts (a.iii):   ${aiii_checked:-0} statements validated, 0 violations"
  echo "  Per-cap PRD BC totals+NFR (a.iv): ${aiv_checked:-0} per-cap + ${aiv_nfr_checked:-0} NFR checks, 0 violations"
  echo "  Studio §3/§6 counts:               verified"
  echo "  Subdecomp priority subtotals:      P0=${computed_frontmatter_p0:-?} P1=${computed_frontmatter_p1:-?} P2=${computed_frontmatter_p2:-?} sum=${computed_frontmatter_grand:-?} (computed from frontmatter)"
  echo "  VP↔BC bidirectional anchor:        all formal VPs back-referenced"
  echo "  Error-identifier resolution (k.i): all BC E-codes registered in taxonomy"
  echo "  Error label-match (k.ii):          $klabel_validated E-code label citations validated, 0 contradictions"
  echo "  Seam-count consistency (o):        no stale 'four adapter seam' phrasing in operative content"
  echo "  Canon-KB ordinal guard (o.ii):    $ordinal_files_scanned files scanned, 0 wrong-ordinal violations (all say 'sixth')"
  echo "  disclosure_class closed-enum:      all BC enum declarations use canonical values"
  echo "  Dimension field uniqueness:        §3.0 table has $DIM_FIELD_COUNT_EXPECTED unique field names"
  echo "  Dimension field usage-site:        all BC convergence-report dimension references use canonical field names"
  echo "  Dimension status-value enum (n.i):  all BC convergence-dimension status values are canonical ($dim_status_assignments_checked assignments validated across $dim_status_bcs_with_context BCs)"
  echo "  Per-dim subset enforcement (n.ii): all dimension-value assignments within allowed subsets"
  echo "  Bare token scan (n.iii):           no bare non-canonical hyphenated tokens in dim-context"
  echo "  Cross-ref ID/desc consistency (p): $xref_validated SS-06 dim-owner citations validated, 0 ID/description mismatches"
  echo "  Prose restatement guard (q):       $q_validated prose restatements validated, 0 mismatches"
  echo "  Error-family reverse coverage (r): $active_family_count non-retired families, all cited by >=1 BC"
  echo "  §3.1 cross-table consistency (s):  $s_dims_in_map dims × 4 values, 0 mismatches ($s_comparisons pairs verified)"
  echo "  BC-7.* owner-attribution (t):      $t_scanned_lines lines scanned, 0 mis-attribution violations"
  echo "  human-gated/creative-gate (u):    $u_lines_scanned lines scanned, $u_creative_gate_lines creative-gate lines validated, 0 term-misuse violations"
  echo "  DI-007-on-creative-gate (w):      $w_lines_scanned lines scanned, $w_creative_gate_lines DI-007+creative-gate lines evaluated, 0 mis-anchor violations"
  echo "  NFR §4 ID-set parity (x):         $x_catalog_count catalog IDs == $x_prd_count prd.md §4 IDs, 0 membership violations"
  echo "  Seam-ordinal collision (y):        $y_files_scanned files scanned, 0 collision violations (distribution=3rd, online-services=5th)"
  echo "  Base-manifest seam-enum (z):      §1.3 enum=$z_enum_count tokens == §8 matrix=$z_matrix_count seam keys, 0 set-equality violations"
  echo "  Frontmatter path-existence (aa):  $aa_total_paths .factory/ paths verified across $aa_source_files source files, 0 unresolved paths"
else
  echo "FAILURES DETECTED:"
  for e in "${errors[@]}"; do
    echo "  $e"
  done
  echo ""
  echo "Fix the stated totals in the documents listed above to match the"
  echo "computed values, or fix the source BC/error files causing the discrepancy."
fi
echo ""

exit $fail
