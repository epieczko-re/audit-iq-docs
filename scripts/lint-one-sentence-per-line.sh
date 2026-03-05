#!/usr/bin/env bash
# lint-one-sentence-per-line.sh
#
# Checks that AsciiDoc prose lines contain at most one sentence.
# A violation is a line where a sentence-ending period (". ") is followed
# by an uppercase letter mid-line, indicating two sentences on one line.
#
# Exceptions (skipped lines):
#   - AsciiDoc directives (lines starting with : or include::)
#   - Table rows (lines starting with |)
#   - Source/listing block delimiters (----, ....)
#   - Lines inside source blocks
#   - Attribute definitions
#   - Comments (//)
#   - URLs (https://, http://)
#   - Abbreviations: common patterns like "e.g. ", "i.e. ", "vs. ", "etc. "

set -euo pipefail

EXIT_CODE=0
VIOLATIONS=0

find_adoc_files() {
  find "${1:-.}" -name '*.adoc' -not -path '*/.git/*' | sort
}

check_file() {
  local file="$1"
  local in_block=false
  local line_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    # Toggle source/listing block tracking
    if [[ "$line" =~ ^(\-\-\-\-|\.\.\.\.|\+\+\+\+|====)$ ]]; then
      if $in_block; then
        in_block=false
      else
        in_block=true
      fi
      continue
    fi

    # Skip lines inside blocks
    $in_block && continue

    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Skip AsciiDoc directives, attributes, includes, comments
    [[ "$line" =~ ^[:/] ]] && continue
    [[ "$line" =~ ^include:: ]] && continue
    [[ "$line" =~ ^ifdef:: ]] && continue
    [[ "$line" =~ ^endif:: ]] && continue
    [[ "$line" =~ ^ifndef:: ]] && continue

    # Skip table rows
    [[ "$line" =~ ^\| ]] && continue
    [[ "$line" =~ ^a\| ]] && continue

    # Skip block titles and anchors
    [[ "$line" =~ ^\. ]] && continue
    [[ "$line" =~ ^\[\[ ]] && continue
    [[ "$line" =~ ^\[ ]] && continue

    # Skip section headers
    [[ "$line" =~ ^= ]] && continue

    # Skip lines that are just admonitions (NOTE:, TIP:, WARNING:, etc.)
    [[ "$line" =~ ^(NOTE|TIP|WARNING|IMPORTANT|CAUTION): ]] && continue

    # Normalize known abbreviations to avoid false positives
    local normalized="$line"
    normalized="${normalized//e.g. /eg }"
    normalized="${normalized//i.e. /ie }"
    normalized="${normalized//vs. /vs }"
    normalized="${normalized//etc. /etc }"
    normalized="${normalized//Dr. /Dr }"
    normalized="${normalized//Mr. /Mr }"
    normalized="${normalized//Mrs. /Mrs }"
    normalized="${normalized//Ms. /Ms }"
    normalized="${normalized//Jr. /Jr }"
    normalized="${normalized//Sr. /Sr }"
    normalized="${normalized//Inc. /Inc }"
    normalized="${normalized//Ltd. /Ltd }"
    normalized="${normalized//Corp. /Corp }"
    normalized="${normalized//No. /No }"
    normalized="${normalized//Vol. /Vol }"
    normalized="${normalized//Rev. /Rev }"
    normalized="${normalized//v0./v0_}"
    normalized="${normalized//v1./v1_}"
    normalized="${normalized//v2./v2_}"

    # Check for multiple sentences: period + space + uppercase letter
    if echo "$normalized" | grep -qP '\.\s+[A-Z]'; then
      echo "  ${file}:${line_num}: ${line:0:120}"
      VIOLATIONS=$((VIOLATIONS + 1))
      EXIT_CODE=1
    fi

  done < "$file"
}

echo "Linting AsciiDoc files for one-sentence-per-line..."
echo ""

for f in $(find_adoc_files "${1:-.}"); do
  check_file "$f"
done

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "All AsciiDoc files pass one-sentence-per-line check."
else
  echo ""
  echo "Found ${VIOLATIONS} violation(s)."
  echo "Each line should contain at most one sentence."
  echo "See .editorconfig for the one-sentence-per-line rule."
fi

exit $EXIT_CODE
