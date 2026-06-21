#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SKILL_NAME="rtk-token-saver"
MARKER_START="<!-- rtk-token-saver:start -->"
MARKER_END="<!-- rtk-token-saver:end -->"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/verify.sh --agent <agent> --scope <scope> [--project <path>]

Agents:
  opencode | claude | codex | antigravity | generic | all

Scopes:
  project | global
USAGE
}

die() { printf '[fail] %s\n' "$*" >&2; exit 1; }
ok() { printf '[ok] %s\n' "$*"; }
warn() { printf '[warn] %s\n' "$*" >&2; }

abs_path() {
  local input="$1"
  case "$input" in
    /*) printf '%s
' "$input" ;;
    *) printf '%s/%s
' "$PWD" "$input" ;;
  esac
}

check_skill_dir() {
  local dir="$1"
  dir="$(abs_path "$dir")"
  [[ -f "$dir/SKILL.md" ]] || die "missing skill file: $dir/SKILL.md"
  grep -Fq "name: rtk-token-saver" "$dir/SKILL.md" || die "invalid skill name in: $dir/SKILL.md"
  grep -Fq "description:" "$dir/SKILL.md" || die "missing description in: $dir/SKILL.md"
  ok "skill verified: $dir/SKILL.md"
}

check_block() {
  local file="$1"
  file="$(abs_path "$file")"
  [[ -f "$file" ]] || die "missing bootstrap file: $file"
  grep -Fqx "$MARKER_START" "$file" || die "missing start marker: $file"
  grep -Fqx "$MARKER_END" "$file" || die "missing end marker: $file"
  grep -Fq "rtk git status" "$file" || die "missing RTK command guidance: $file"
  ok "bootstrap verified: $file"
}

check_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    ok "rtk found: $(command -v rtk)"
  else
    warn "rtk not found in PATH"
  fi
}

project_path() {
  [[ -n "${PROJECT:-}" ]] || die "--project is required for project scope"
  abs_path "$PROJECT"
}

verify_agent() {
  local agent="$1"
  local scope="$2"
  local project=""
  if [[ "$scope" == "project" ]]; then project="$(project_path)"; fi

  case "$agent:$scope" in
    opencode:project)
      check_skill_dir "${project}/.agents/skills/${SKILL_NAME}"
      check_block "${project}/AGENTS.md" ;;
    opencode:global)
      check_skill_dir "${HOME}/.config/opencode/skills/${SKILL_NAME}"
      check_block "${HOME}/.config/opencode/AGENTS.md" ;;
    claude:project)
      check_skill_dir "${project}/.claude/skills/${SKILL_NAME}"
      check_block "${project}/CLAUDE.md" ;;
    claude:global)
      check_skill_dir "${HOME}/.claude/skills/${SKILL_NAME}"
      check_block "${HOME}/.claude/CLAUDE.md" ;;
    codex:project)
      check_skill_dir "${project}/.agents/skills/${SKILL_NAME}"
      check_block "${project}/AGENTS.md" ;;
    codex:global)
      check_skill_dir "${HOME}/.agents/skills/${SKILL_NAME}"
      check_block "${HOME}/.codex/AGENTS.md" ;;
    antigravity:project)
      check_skill_dir "${project}/.agents/skills/${SKILL_NAME}"
      check_block "${project}/.agents/agents.md" ;;
    antigravity:global)
      check_skill_dir "${HOME}/.gemini/antigravity/skills/${SKILL_NAME}" ;;
    generic:project)
      check_skill_dir "${project}/.agents/skills/${SKILL_NAME}"
      check_block "${project}/AGENTS.md" ;;
    generic:global)
      check_skill_dir "${HOME}/.agents/skills/${SKILL_NAME}" ;;
    *) die "unsupported combination: agent=$agent scope=$scope" ;;
  esac
}

AGENT=""; SCOPE=""; PROJECT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="${2:-}"; [[ -n "$AGENT" ]] || die "--agent requires value"; shift 2 ;;
    --scope) SCOPE="${2:-}"; [[ -n "$SCOPE" ]] || die "--scope requires value"; shift 2 ;;
    --project) PROJECT="${2:-}"; [[ -n "$PROJECT" ]] || die "--project requires path"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$AGENT" ]] || { usage; exit 1; }
[[ -n "$SCOPE" ]] || { usage; exit 1; }

check_rtk

if [[ "$AGENT" == "all" ]]; then
  [[ "$SCOPE" == "project" ]] || die "--agent all supports project scope only"
  for a in opencode claude codex antigravity; do verify_agent "$a" "$SCOPE"; done
else
  verify_agent "$AGENT" "$SCOPE"
fi

ok "verification complete"
