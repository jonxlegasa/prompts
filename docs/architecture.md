# Architecture

## Problem

AI tools each want their system prompts and skills in different locations with different naming conventions. Maintaining separate copies leads to drift.

For example:
- Claude Code: `~/.claude/CLAUDE.md`, `~/.claude/commands/*.md`
- OpenCode: `~/.config/opencode/AGENTS.md`, `~/.config/opencode/agents/*.md`

## Solution

A three-stage pipeline: **source** → **compose** → **stow**.

### 1. Source (`src/`)

All prompts live once in `src/`:

```
src/
├── MISSION.md        # the main system prompt
└── skills/           # shared command/agent prompts
    ├── doc-sync.md
    ├── generate-beads.md
    ├── implement-beads.md
    └── sync-edits.md
```

"Skills" is the neutral term — Claude Code calls them "commands", OpenCode calls them "agents".

### 2. Compose (`utils/compose.sh`)

The build script copies source files into two stow packages, mapping to each tool's naming convention:

```
src/MISSION.md     → claude/.claude/CLAUDE.md
                   → opencode/.config/opencode/AGENTS.md

src/skills/*.md    → claude/.claude/commands/*.md
                   → opencode/.config/opencode/agents/*.md
```

If a tool-specific header exists in `partials/` (e.g., `partials/claude-header.md`), it gets prepended to that tool's copy of MISSION.md.

### 3. Stow

GNU Stow creates symlinks from `~` into the stow packages. The `.stowrc` sets `--target=~`.

Each stow package mirrors the filesystem path from home:

```
claude/.claude/CLAUDE.md         → ~/.claude/CLAUDE.md           (symlink)
opencode/.config/opencode/AGENTS.md → ~/.config/opencode/AGENTS.md  (symlink)
```

Stow may tree-fold — creating a single directory-level symlink instead of individual file symlinks. Both are equivalent.

## Data flow

```
src/MISSION.md ──[ compose.sh ]──→ claude/.claude/CLAUDE.md ──[ stow ]──→ ~/.claude/CLAUDE.md
                                 → opencode/.config/opencode/AGENTS.md ──→ ~/.config/opencode/AGENTS.md

src/skills/*.md ──[ compose.sh ]──→ claude/.claude/commands/*.md ──[ stow ]──→ ~/.claude/commands/*.md
                                  → opencode/.config/opencode/agents/*.md ──→ ~/.config/opencode/agents/*.md
```

## Adding a new tool

To support a third AI tool:

1. Create a new stow package directory (e.g., `newtool/`)
2. Mirror the target path structure inside it
3. Add a compose step in `utils/compose.sh` to copy source files with the tool's naming convention
4. Add the package name to `stow --adopt` in `setup.sh`
