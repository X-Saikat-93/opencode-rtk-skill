#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PROJECT="$TMP/project"
mkdir -p "$PROJECT"

printf '# Existing AGENTS\n\nKeep AGENTS.\n' > "$PROJECT/AGENTS.md"
printf '# Existing CLAUDE\n\nKeep CLAUDE.\n' > "$PROJECT/CLAUDE.md"

bash -n "$ROOT/install.sh"
bash -n "$ROOT/uninstall.sh"
bash -n "$ROOT/scripts/verify.sh"
bash -n "$ROOT/scripts/print-targets.sh"

"$ROOT/install.sh" --agent all --scope project --project "$PROJECT" --dry-run
"$ROOT/install.sh" --agent all --scope project --project "$PROJECT" --force
"$ROOT/scripts/verify.sh" --agent all --scope project --project "$PROJECT"

grep -q "Keep AGENTS" "$PROJECT/AGENTS.md"
grep -q "Keep CLAUDE" "$PROJECT/CLAUDE.md"
test -f "$PROJECT/.agents/skills/rtk-token-saver/SKILL.md"
test -f "$PROJECT/.claude/skills/rtk-token-saver/SKILL.md"
test -f "$PROJECT/.agents/agents.md"

"$ROOT/install.sh" --agent all --scope project --project "$PROJECT" --force

agents_count="$(grep -c '<!-- rtk-token-saver:start -->' "$PROJECT/AGENTS.md")"
claude_count="$(grep -c '<!-- rtk-token-saver:start -->' "$PROJECT/CLAUDE.md")"
ag_count="$(grep -c '<!-- rtk-token-saver:start -->' "$PROJECT/.agents/agents.md")"

[[ "$agents_count" == "1" ]]
[[ "$claude_count" == "1" ]]
[[ "$ag_count" == "1" ]]

SYMPROJ="$TMP/symlink-project"
mkdir -p "$SYMPROJ"
touch "$TMP/real-agents"
ln -s "$TMP/real-agents" "$SYMPROJ/AGENTS.md"

if "$ROOT/install.sh" --agent opencode --scope project --project "$SYMPROJ" --force >/dev/null 2>&1; then
  echo "installer accepted symlink destination unexpectedly" >&2
  exit 1
fi

"$ROOT/uninstall.sh" --agent all --scope project --project "$PROJECT"

grep -q "Keep AGENTS" "$PROJECT/AGENTS.md"
grep -q "Keep CLAUDE" "$PROJECT/CLAUDE.md"

if grep -q "rtk-token-saver:start" "$PROJECT/AGENTS.md"; then
  echo "managed block remains in AGENTS.md" >&2
  exit 1
fi

if grep -q "rtk-token-saver:start" "$PROJECT/CLAUDE.md"; then
  echo "managed block remains in CLAUDE.md" >&2
  exit 1
fi

echo "tests passed"
