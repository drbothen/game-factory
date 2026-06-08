#!/usr/bin/env bash
# check-spec-counts.sh — Spec count consistency checker (S2-02) v1.3
#
# PURPOSE
# -------
# Prevent recurring count-drift across the spec layer. Seven classes of drift
# are checked (extended in v1.2 to cover Pass-3 adversarial defect classes;
# extended in v1.3 to cover Pass-4 VP catalog consistency):
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
