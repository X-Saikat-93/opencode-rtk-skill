#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SKILL_NAME="rtk-token-saver"
MARKER_START="<!-- rtk-token-saver:start -->"
MARKER_END="<!-- rtk-token-saver:end -->"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILL_SRC="${SCRIPT_DIR}/skills/${SKILL_NAME}"
BOOTSTRAP_SRC="${SCRIPT_DIR}/templates/bootstrap-block.md"

# Read version from VERSION file, fallback to hardcoded default
VERSION="0.0.0"
if [[ -f "${SCRIPT_DIR}/VERSION" ]]; then
  read -r VERSION < "${SCRIPT_DIR}/VERSION"
fi

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --agent <agent> --scope <scope> [--project <path>] [--force] [--dry-run]

Agents:
  opencode      Install skill for OpenCode + AGENTS.md bootstrap.
  claude        Install skill for Claude Code + CLAUDE.md bootstrap.
  codex         Install skill for Codex + AGENTS.md bootstrap.
  antigravity   Install skill for Antigravity + .agents/agents.md bootstrap.
  generic       Install skill in .agents/skills + AGENTS.md bootstrap.
  all           Install all project-supported adapters.

Scopes:
  project       Install into a project/workspace. Requires --project.
  global        Install into user-level agent paths where supported.

Examples:
  ./install.sh --agent opencode --scope project --project ~/repo --force
  ./install.sh --agent claude --scope global --force
  ./install.sh --agent codex --scope project --project ~/repo --force
  ./install.sh --agent antigravity --scope project --project ~/repo --force
  ./install.sh --agent all --scope project --project ~/repo --force

Preferred skills.sh install:
  npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver

Security:
  - No sudo.
  - No network calls.
  - No npm installs.
  - No shell rc modification.
  - Refuses dangerous paths.
  - Refuses symlink destinations.
  - Creates backups before edits.
USAGE
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

abs_path() {
  local input="$1"
  case "$input" in
    /*) printf '%s
' "$input" ;;
    *) printf '%s/%s
' "$PWD" "$input" ;;
  esac
}

is_dangerous_path() {
  local p="$1"
  case "$p" in
    /|/bin|/boot|/dev|/etc|/lib|/lib64|/proc|/root|/run|/sbin|/sys|/usr|/var|/opt|/snap|/tmp)
      return 0 ;;
  esac
  return 1
}

require_sources() {
  [[ -d "$SKILL_SRC" ]] || die "missing skill source: $SKILL_SRC"
  [[ -f "$SKILL_SRC/SKILL.md" ]] || die "missing SKILL.md: $SKILL_SRC/SKILL.md"
  [[ -f "$BOOTSTRAP_SRC" ]] || die "missing bootstrap template: $BOOTSTRAP_SRC"
}

validate_file_target() {
  local dest="$1"
  local dir
  dir="$(dirname -- "$dest")"
  if is_dangerous_path "$dir"; then die "refusing dangerous directory: $dir"; fi
  if [[ -L "$dest" ]]; then die "refusing symlink destination: $dest"; fi
  if [[ -e "$dest" && ! -f "$dest" ]]; then die "destination exists but is not a regular file: $dest"; fi
}

validate_dir_target() {
  local dest="$1"
  local parent
  parent="$(dirname -- "$dest")"
  if is_dangerous_path "$dest" || is_dangerous_path "$parent"; then die "refusing dangerous directory target: $dest"; fi
  if [[ -L "$dest" ]]; then die "refusing symlink directory destination: $dest"; fi
}

rotate_backups() {
  local pattern="$1"
  local keep="${2:-5}"
  local dir; dir="$(dirname "$pattern")"
  local name; name="$(basename "$pattern")"
  # shellcheck disable=SC2012
  ls -dt "$dir"/"$name" 2>/dev/null | tail -n +$((keep + 1)) | while IFS= read -r old; do
    rm -rf -- "$old"
  done || true
}

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S-%N)"
    local backup="${file}.backup-${ts}"
    cp -p -- "$file" "$backup"
    info "Backup created: $backup"
    rotate_backups "${file}.backup-*" 5
  fi
}

managed_block() {
  printf '%s\n' "$MARKER_START"
  printf '<!-- Managed by OpenCode RTK Skill v%s. Do not edit inside this block. -->\n\n' "$VERSION"
  cat -- "$BOOTSTRAP_SRC"
  printf '\n%s\n' "$MARKER_END"
}

strip_block() {
  local src="$1"
  awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { skipping=1; next }
    $0 == end { skipping=0; next }
    skipping != 1 { print }
  ' "$src"
}

install_managed_block() {
  local dest="$1"
  local force="$2"
  local dry="$3"
  dest="$(abs_path "$dest")"
  validate_file_target "$dest"
  info "Bootstrap target: $dest"

  if [[ "$dry" == "1" ]]; then
    info "Dry run: would install/update managed bootstrap block."
    return 0
  fi

  mkdir -p -- "$(dirname -- "$dest")"
  local tmp cleaned
  tmp="$(mktemp "$(dirname -- "$dest")/.rtk-skill.tmp.XXXXXX")"
  cleaned="$(mktemp "$(dirname -- "$dest")/.rtk-skill.clean.XXXXXX")"
  trap 'rm -f -- "$tmp" "$cleaned"' RETURN

  if [[ -f "$dest" ]]; then
    if ! grep -Fqx "$MARKER_START" "$dest" && [[ "$force" != "1" ]]; then
      info "Existing unmanaged file found: $dest"
      info "No changes made. Re-run with --force to append managed block while preserving existing content."
      return 0
    fi
    backup_file "$dest"
    strip_block "$dest" > "$cleaned"
    if [[ -s "$cleaned" ]]; then
      cat -- "$cleaned" > "$tmp"
      printf '\n\n' >> "$tmp"
    fi
    managed_block >> "$tmp"
  else
    managed_block > "$tmp"
  fi

  chmod 0644 "$tmp"
  mv -- "$tmp" "$dest"
  trap - RETURN
  rm -f -- "$cleaned"
  info "Installed/updated bootstrap block."
}

copy_skill_dir() {
  local dest="$1"
  local dry="$2"
  dest="$(abs_path "$dest")"
  validate_dir_target "$dest"
  info "Skill target: $dest"

  if [[ "$dry" == "1" ]]; then
    info "Dry run: would copy skill directory."
    return 0
  fi

  mkdir -p -- "$(dirname -- "$dest")"
  if [[ -e "$dest" ]]; then
    if [[ -L "$dest" ]]; then die "refusing symlink skill destination: $dest"; fi
    local ts
    ts="$(date +%Y%m%d-%H%M%S-%N)"
    local backup="${dest}.backup-${ts}"
    mv -- "$dest" "$backup"
    info "Existing skill backed up: $backup"
    rotate_backups "${dest}.backup-*" 5
  fi

  cp -R -- "$SKILL_SRC" "$dest"
  find "$dest" -type f -name "*.sh" -exec chmod 0755 {} \;
  info "Installed skill directory."
}

check_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    info "RTK found: $(command -v rtk)"
  else
    warn "rtk not found in PATH. Install RTK first:"
    warn "  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
  fi
}

project_path() {
  [[ -n "${PROJECT:-}" ]] || die "--project is required for project scope"
  abs_path "$PROJECT"
}

install_agent() {
  local agent="$1"
  local scope="$2"
  local force="$3"
  local dry="$4"
  local project=""
  if [[ "$scope" == "project" ]]; then project="$(project_path)"; fi

  case "$agent:$scope" in
    opencode:project)
      copy_skill_dir "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${project}/AGENTS.md" "$force" "$dry" ;;
    opencode:global)
      copy_skill_dir "${HOME}/.config/opencode/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${HOME}/.config/opencode/AGENTS.md" "$force" "$dry" ;;
    claude:project)
      copy_skill_dir "${project}/.claude/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${project}/CLAUDE.md" "$force" "$dry" ;;
    claude:global)
      copy_skill_dir "${HOME}/.claude/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${HOME}/.claude/CLAUDE.md" "$force" "$dry" ;;
    codex:project)
      copy_skill_dir "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${project}/AGENTS.md" "$force" "$dry" ;;
    codex:global)
      copy_skill_dir "${HOME}/.agents/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${HOME}/.codex/AGENTS.md" "$force" "$dry" ;;
    antigravity:project)
      copy_skill_dir "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${project}/.agents/agents.md" "$force" "$dry" ;;
    antigravity:global)
      copy_skill_dir "${HOME}/.gemini/antigravity/skills/${SKILL_NAME}" "$dry" ;;
    generic:project)
      copy_skill_dir "${project}/.agents/skills/${SKILL_NAME}" "$dry"
      install_managed_block "${project}/AGENTS.md" "$force" "$dry" ;;
    generic:global)
      copy_skill_dir "${HOME}/.agents/skills/${SKILL_NAME}" "$dry" ;;
    *) die "unsupported combination: agent=$agent scope=$scope" ;;
  esac
}

AGENT=""; SCOPE=""; PROJECT=""; FORCE="0"; DRY="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="${2:-}"; [[ -n "$AGENT" ]] || die "--agent requires value"; shift 2 ;;
    --scope) SCOPE="${2:-}"; [[ -n "$SCOPE" ]] || die "--scope requires value"; shift 2 ;;
    --project) PROJECT="${2:-}"; [[ -n "$PROJECT" ]] || die "--project requires path"; shift 2 ;;
    --force) FORCE="1"; shift ;;
    --dry-run) DRY="1"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$AGENT" ]] || { usage; exit 1; }
[[ -n "$SCOPE" ]] || { usage; exit 1; }
require_sources

if [[ "$AGENT" == "all" ]]; then
  [[ "$SCOPE" == "project" ]] || die "--agent all supports project scope only"
  for a in opencode claude codex antigravity; do
    info ""
    info "== Installing adapter: $a =="
    install_agent "$a" "$SCOPE" "$FORCE" "$DRY"
  done
else
  install_agent "$AGENT" "$SCOPE" "$FORCE" "$DRY"
fi

check_rtk
info ""
info "Done. Restart your agent app/CLI if needed, then test with: rtk git status"
