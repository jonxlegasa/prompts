#!/usr/bin/env bash
# utils/compose.sh — Build tool-specific prompt files from src/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
PARTIALS="$ROOT/partials"

# Target stow package paths
CLAUDE_DIR="$ROOT/claude/.claude"
OPENCODE_DIR="$ROOT/opencode/.config/opencode"

build_file() {
  local header="$1" src="$2" dest="$3"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$header" ]]; then
    cat "$header" "$src" > "$dest"
  else
    cp "$src" "$dest"
  fi
  echo "  built: $dest"
}

echo "Composing prompts from: $SRC"

# 1. MISSION.md → CLAUDE.md + AGENTS.md
build_file "$PARTIALS/claude-header.md" "$SRC/MISSION.md" "$CLAUDE_DIR/CLAUDE.md"
build_file "$PARTIALS/agents-header.md" "$SRC/MISSION.md" "$OPENCODE_DIR/AGENTS.md"

# 2. skills/*.md → commands/*.md + agents/*.md
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$OPENCODE_DIR/agents"

for skill in "$SRC"/skills/*.md; do
  [[ -f "$skill" ]] || continue
  name="$(basename "$skill")"
  cp "$skill" "$CLAUDE_DIR/commands/$name"
  echo "  built: $CLAUDE_DIR/commands/$name"
  cp "$skill" "$OPENCODE_DIR/agents/$name"
  echo "  built: $OPENCODE_DIR/agents/$name"
done

echo "Done."
