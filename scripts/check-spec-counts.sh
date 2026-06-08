#!/usr/bin/env bash
# check-spec-counts.sh — Spec count consistency checker (S2-02) v1.6
#
# PURPOSE
# -------
# Prevent recurring count-drift across the spec layer. Eleven classes of drift
# are checked (extended in v1.2 to cover Pass-3 adversarial defect classes;
# extended in v1.3 to cover Pass-4 VP catalog consistency;
# extended in v1.4 to cover Pass-5 studio §3 appearance counts, subsystem
# priority subtotals, and formal VP ↔ BC bidirectional anchor):
# extended in v1.5 to fix false-green in check (i) (I6-01) and add check (k);
# extended in v1.6 to add check (l) — disclosure_class closed-enum consistency
# (F8-01 recurrence prevention):
#   (a) BC file count diverging from stated totals in BC-INDEX / subsystem-decomposition / ARCH-INDEX / PRD
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
#       SS-06=3 SS-07=3 SS-08=12 SS-09=2 SS-10=5 SS-11=11 SS-12=1.
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
#   (k) [NEW v1.5] Error-identifier resolution: every E-[A-Z]+-[0-9]+ token
#       referenced in any BC file must resolve to a registered code in
#       error-taxonomy.md. Reports unregistered codes. Will FAIL until PO
#       registers E-ETH codes for dark-pattern BCs (I6-02 class). Implemented
#       now so it becomes green automatically after PO work.
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

# ---- Helpers ----------------------------------------------------------------
fail=0
errors=()

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

echo "=== check-spec-counts.sh — game-factory spec consistency ==="
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
#   SS-03=16  SS-04=23  SS-05=6  SS-06=3  SS-07=3  SS-08=12
#   SS-09=2   SS-10=5   SS-11=11 SS-12=1
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
  declare -a SS_EXPECTED=(
    "SS-03:16"
    "SS-04:23"
    "SS-05:6"
    "SS-06:3"
    "SS-07:3"
    "SS-08:12"
    "SS-09:2"
    "SS-10:5"
    "SS-11:11"
    "SS-12:1"
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
# (k) ERROR-IDENTIFIER RESOLUTION  [NEW v1.5]
# ============================================================================
# Assert every E-[A-Z]+-[0-9]+ token referenced in any BC file resolves to a
# registered code in error-taxonomy.md. Unregistered codes are reported.
#
# This guards the I6-02 class: BCs that reference error codes that have not yet
# been registered in the taxonomy. The check WILL FAIL until PO registers E-ETH
# codes for dark-pattern/ethics BCs in SS-09 (CAP-011). Implemented so it
# becomes green automatically after PO work without script changes.
#
# Strategy:
#   1. Build the set of registered codes from error-taxonomy.md (same grep used
#      in check b, but here we keep the full list rather than just counting).
#   2. Collect all E-[A-Z]+-[0-9]+ tokens across BC files.
#   3. Report any token that is not in the registered set.
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

  # Find BC-referenced codes that are NOT in the registered set
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
  echo "  Studio §3/§6 counts:               verified"
  echo "  Subdecomp priority subtotals:      P0=${computed_frontmatter_p0:-?} P1=${computed_frontmatter_p1:-?} P2=${computed_frontmatter_p2:-?} sum=${computed_frontmatter_grand:-?} (computed from frontmatter)"
  echo "  VP↔BC bidirectional anchor:        all formal VPs back-referenced"
  echo "  Error-identifier resolution:       all BC E-codes registered in taxonomy"
  echo "  disclosure_class closed-enum:      all BC enum declarations use canonical values"
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
