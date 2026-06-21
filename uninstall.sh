#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SKILL_NAME="rtk-token-saver"
MARKER_START="<!-- rtk-token-saver:start -->"
MARKER_END="<!-- rtk-token-saver:end -->"

usage() {
  cat <<'USAGE'
Usage:
  ./uninstall.sh --agent <agent> --scope <scope> [--project <path>] [--dry-run]

Agents:
  opencode | claude | codex | antigravity | generic | all

Scopes:
  project | global

Examples:
  ./uninstall.sh --agent all --scope project --project ~/repo
  ./uninstall.sh --agent claude --scope global
USAGE
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

abs_path() {
  local input="$1"
  case "$input" in
    /*) printf '%s
' "$input" ;;
    *) printf '%s/%s
' "$PWD" "$input" ;;
  esac
}

strip_block() {
  local src="$1"
  awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { skipping=1; removed=1; next }
    $0 == end { skipping=0; next }
    skipping != 1 { print }
    END { if (removed != 1) exit 7 }
  ' "$src"
}

remove_managed_block() {
  local file="$1"
  local dry="$2"
  file="$(abs_path "$file")"

  if [[ ! -f "$file" ]]; then info "No bootstrap file: $file"; return 0; fi
  if [[ -L "$file" ]]; then die "refusing symlink file: $file"; fi
  if ! grep -Fqx "$MARKER_START" "$file"; then info "No managed block in: $file"; return 0; fi

  info "Removing managed block: $file"
  if [[ "$dry" == "1" ]]; then info "Dry run: no changes."; return 0; fi

  local backup _ts
  _ts="$(date +%Y%m%d-%H%M%S)"
  backup="${file}.backup-${_ts}"
  local tmp
  tmp="$(mktemp "$(dirname -- "$file")/.rtk-uninstall.XXXXXX")"

  cp -p -- "$file" "$backup"
  strip_block "$file" > "$tmp" || die "failed removing block from $file"
  chmod 0644 "$tmp"
  mv -- "$tmp" "$file"
  info "Backup created: $backup"
}

remove_skill_path() {
  local path="$1"
  local dry="$2"
  path="$(abs_path "$path")"

  if [[ ! -e "$path" ]]; then info "No skill path: $path"; return 0; fi
  if [[ -L "$path" ]]; then die "refusing symlink path: $path"; fi

  info "Removing installed skill path: $path"
  if [[ "$dry" == "1" ]]; then info "Dry run: no changes."; return 0; fi

  local backup _ts
  _ts="$(date +%Y%m%d-%H%M%S)"
  backup="${path}.removed-${_ts}"
  mv -- "$path" "$backup"
  info "Moved to backup: $backup"
}

project_path() {
  [[ -n "${PROJECT:-}" ]] || die "--project is required for project scope"
  abs_path "$PROJECT"
}

uninstall_agent() {
  local agent="$1"
  local scope="$2"
  local dry="$3"
  local project=""
  if [[ "$scope" == "project" ]]; then project="$(project_path)"; fi

  case "$agent:$scope" in
    opencode:project)
      remove_skill_path "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${project}/AGENTS.md" "$dry" ;;
    opencode:global)
      remove_skill_path "${HOME}/.config/opencode/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${HOME}/.config/opencode/AGENTS.md" "$dry" ;;
    claude:project)
      remove_skill_path "${project}/.claude/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${project}/CLAUDE.md" "$dry" ;;
    claude:global)
      remove_skill_path "${HOME}/.claude/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${HOME}/.claude/CLAUDE.md" "$dry" ;;
    codex:project)
      remove_skill_path "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${project}/AGENTS.md" "$dry" ;;
    codex:global)
      remove_skill_path "${HOME}/.agents/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${HOME}/.codex/AGENTS.md" "$dry" ;;
    antigravity:project)
      remove_skill_path "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${project}/.agents/agents.md" "$dry" ;;
    antigravity:global)
      remove_skill_path "${HOME}/.gemini/antigravity/skills/${SKILL_NAME}" "$dry" ;;
    generic:project)
      remove_skill_path "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      remove_managed_block "${project}/AGENTS.md" "$dry" ;;
    generic:global)
      remove_skill_path "${HOME}/.agents/skills/${SKILL_NAME}" "$dry" ;;
    *) die "unsupported combination: agent=$agent scope=$scope" ;;
  esac
}

AGENT=""; SCOPE=""; PROJECT=""; DRY="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="${2:-}"; [[ -n "$AGENT" ]] || die "--agent requires value"; shift 2 ;;
    --scope) SCOPE="${2:-}"; [[ -n "$SCOPE" ]] || die "--scope requires value"; shift 2 ;;
    --project) PROJECT="${2:-}"; [[ -n "$PROJECT" ]] || die "--project requires path"; shift 2 ;;
    --dry-run) DRY="1"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$AGENT" ]] || { usage; exit 1; }
[[ -n "$SCOPE" ]] || { usage; exit 1; }

if [[ "$AGENT" == "all" ]]; then
  [[ "$SCOPE" == "project" ]] || die "--agent all supports project scope only"
  for a in opencode claude codex antigravity; do
    info ""
    info "== Uninstalling adapter: $a =="
    uninstall_agent "$a" "$SCOPE" "$DRY"
  done
else
  uninstall_agent "$AGENT" "$SCOPE" "$DRY"
fi

info "Done."
