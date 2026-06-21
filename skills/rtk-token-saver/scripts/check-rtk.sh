#!/usr/bin/env bash
set -Eeuo pipefail

if command -v rtk >/dev/null 2>&1; then
  echo "rtk found: $(command -v rtk)"
  rtk --version || true
  exit 0
fi

echo "rtk not found in PATH" >&2
echo "Install RTK:" >&2
echo "  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh" >&2
exit 1
