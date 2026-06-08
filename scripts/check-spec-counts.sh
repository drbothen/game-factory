#!/usr/bin/env bash
# check-spec-counts.sh — Spec count consistency checker (S2-02) v1.1
#
# PURPOSE
# -------
# Prevent recurring count-drift across the spec layer. Three classes of drift
# have been observed in Phase-1d adversarial passes:
#   (a) BC file count diverging from stated totals in BC-INDEX / subsystem-decomposition / ARCH-INDEX / PRD
#   (b) Error code count diverging from stated total in error-taxonomy.md
#   (c) BC files without a `priority:` frontmatter field (coverage gap)
#
# This script computes runtime values for all three, compares them to their
# authoritative stated values, and exits non-zero if any mismatch is detected.
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
# SUMMARY
# ============================================================================
echo "=== SUMMARY ==="
if [[ $fail -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
  echo ""
  echo "  BC files (computed):     $computed_bc"
  echo "  Error codes (computed):  $computed_ecodes"
  echo "  Priority coverage:       $computed_with_priority / $computed_bc (100%)"
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
