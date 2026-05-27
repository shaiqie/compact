#!/usr/bin/env bash
# install.sh — installs compact skill into OpenCode (+ Claude Code / Codex) skill paths

set -euo pipefail

# ── config ────────────────────────────────────────────────────────────────────
SOURCE_DIR="compact"
SKILL_NAME="compact"
REQUIRED_FILES=("SKILL.md" "references")

# install targets — all paths OpenCode natively scans
PROJECT_TARGETS=(
  ".opencode/skills"
  ".claude/skills"
  ".agents/skills"
)
GLOBAL_TARGETS=(
  "$HOME/.config/opencode/skills"
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
)

# ── colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[2m'
RESET='\033[0m'

pass()  { echo -e "${GREEN}  ok${RESET}  $1"; }
fail()  { echo -e "${RED}  !!${RESET}  $1"; exit 1; }
info()  { echo -e "${DIM}      $1${RESET}"; }
warn()  { echo -e "${YELLOW}  --${RESET}  $1"; }
skip()  { echo -e "${DIM}  --  skipped: $1${RESET}"; }

# ── args ──────────────────────────────────────────────────────────────────────
MODE="${1:-project}"   # "project" | "global" | "all"

usage() {
  echo ""
  echo "  usage: ./install.sh [project|global|all]"
  echo ""
  echo "    project  — installs to .opencode/skills/, .claude/skills/, .agents/skills/  (default)"
  echo "    global   — installs to ~/.config/opencode/skills/, ~/.claude/skills/, ~/.agents/skills/"
  echo "    all      — installs to both project and global paths"
  echo ""
  exit 0
}

[[ "$MODE" == "--help" || "$MODE" == "-h" ]] && usage
[[ "$MODE" =~ ^(project|global|all)$ ]] || fail "unknown mode '$MODE' — run ./install.sh --help"

# ── header ────────────────────────────────────────────────────────────────────
echo ""
echo "  compact — OpenCode skill installer"
echo "  ─────────────────────────────────────────"
echo "  mode: ${MODE}"

# ── validate source ───────────────────────────────────────────────────────────
echo ""
echo "  validating source..."

[[ -d "$SOURCE_DIR" ]] \
  || fail "source dir '${SOURCE_DIR}/' not found — run from repo root"

for item in "${REQUIRED_FILES[@]}"; do
  [[ -e "${SOURCE_DIR}/${item}" ]] \
    && pass "${SOURCE_DIR}/${item}" \
    || fail "missing required file: ${SOURCE_DIR}/${item}"
done

# ── install fn ────────────────────────────────────────────────────────────────
install_to() {
  local base="$1"
  local dest="${base}/${SKILL_NAME}"

  mkdir -p "$dest"

  # copy SKILL.md
  cp "${SOURCE_DIR}/SKILL.md" "${dest}/SKILL.md"

  # copy references/ if present
  if [[ -d "${SOURCE_DIR}/references" ]]; then
    cp -r "${SOURCE_DIR}/references" "${dest}/references"
  fi

  pass "${dest}/"
  info "SKILL.md + references/ → ${dest}"
}

# ── project install ───────────────────────────────────────────────────────────
if [[ "$MODE" == "project" || "$MODE" == "all" ]]; then
  echo ""
  echo "  installing (project-local)..."
  for target in "${PROJECT_TARGETS[@]}"; do
    install_to "$target"
  done
fi

# ── global install ────────────────────────────────────────────────────────────
if [[ "$MODE" == "global" || "$MODE" == "all" ]]; then
  echo ""
  echo "  installing (global)..."
  for target in "${GLOBAL_TARGETS[@]}"; do
    install_to "$target"
  done
fi

# ── verify ────────────────────────────────────────────────────────────────────
echo ""
echo "  verifying..."

verify_path() {
  local dest="${1}/${SKILL_NAME}/SKILL.md"
  [[ -f "$dest" ]] && pass "$dest" || warn "not found: $dest"
}

if [[ "$MODE" == "project" || "$MODE" == "all" ]]; then
  for target in "${PROJECT_TARGETS[@]}"; do verify_path "$target"; done
fi
if [[ "$MODE" == "global" || "$MODE" == "all" ]]; then
  for target in "${GLOBAL_TARGETS[@]}"; do verify_path "$target"; done
fi

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────"
echo -e "  ${GREEN}done.${RESET} restart OpenCode to load the skill."
echo ""
echo "  verify inside OpenCode:"
echo '    > list installed skills'
echo ""
