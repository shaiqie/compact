#!/usr/bin/env bash
# install.sh — packages compact/ into skills/compact.skill

set -euo pipefail

# ── config ────────────────────────────────────────────────────────────────────
SOURCE_DIR="compact"
OUTPUT_DIR="skills"
SKILL_NAME="compact"
SKILL_FILE="${OUTPUT_DIR}/${SKILL_NAME}.skill"
REQUIRED_FILES=("SKILLS.md" "references")

# ── colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
DIM='\033[2m'
RESET='\033[0m'

pass() { echo -e "${GREEN}  ok${RESET}  $1"; }
fail() { echo -e "${RED}  !!${RESET}  $1"; exit 1; }
info() { echo -e "${DIM}      $1${RESET}"; }

# ── header ────────────────────────────────────────────────────────────────────
echo ""
echo "  compact — skill installer"
echo "  ─────────────────────────────────────────"

# ── validate source ───────────────────────────────────────────────────────────
echo ""
echo "  validating source..."

[[ -d "$SOURCE_DIR" ]] \
  || fail "source dir '${SOURCE_DIR}/' not found — run from repo root"

for item in "${REQUIRED_FILES[@]}"; do
  [[ -e "${SOURCE_DIR}/${item}" ]] \
    && pass "${SOURCE_DIR}/${item}" \
    || fail "missing: ${SOURCE_DIR}/${item}"
done

# ── prepare output dir ────────────────────────────────────────────────────────
echo ""
echo "  preparing output..."

mkdir -p "$OUTPUT_DIR"
pass "skills/ ready"

# ── package ───────────────────────────────────────────────────────────────────
echo ""
echo "  packaging..."

# remove stale build
[[ -f "$SKILL_FILE" ]] && rm "$SKILL_FILE" && info "removed old ${SKILL_FILE}"

# zip: contents of compact/ stored as compact/<file> inside the archive
(cd "$(dirname "$SOURCE_DIR")" && zip -rq "$OLDPWD/${SKILL_FILE}" "$SKILL_NAME/")

SIZE=$(du -sh "$SKILL_FILE" | cut -f1)
FILE_COUNT=$(unzip -l "$SKILL_FILE" | tail -1 | awk '{print $2}')
pass "built ${SKILL_FILE} (${SIZE}, ${FILE_COUNT} files)"

# ── verify ────────────────────────────────────────────────────────────────────
echo ""
echo "  verifying archive..."

while IFS= read -r entry; do
  info "$entry"
done < <(unzip -l "$SKILL_FILE" | awk 'NR>3 && /[^-]/{print $NF}' | head -20)

pass "archive intact"

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────"
echo -e "  ${GREEN}installed → ${SKILL_FILE}${RESET}"
echo ""
