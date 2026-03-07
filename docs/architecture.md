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
├── skills/           # shared command/agent prompts
│   ├── baseline-ui.md
│   ├── doc-sync.md
│   ├── fixing-accessibility.md
│   ├── fixing-metadata.md
│   ├── fixing-motion-performance.md
│   ├── generate-beads.md
│   ├── implement-beads.md
│   └── sync-edits.md
├── output-styles/    # shared output style definitions
│   └── cited.md
└── hooks/            # tool-specific hook configs
    ├── hooks.json          # Claude Code settings.json (hooks + outputStyle)
    └── citation-audit.ts   # OpenCode plugin for citation enforcement
```

"Skills" is the neutral term — Claude Code calls them "commands", OpenCode calls them "agents".

Output styles are **symlinked** (not composed) into both stow packages, so edits to `src/output-styles/` propagate immediately without rebuilding.

Hooks are **symlinked** into each tool's stow package. Each tool has a different hook format (Claude uses JSON settings, OpenCode uses TS plugins), so they are separate source files rather than a shared one.

### 2. Compose (`utils/compose.sh`)

The build script copies source files into two stow packages, mapping to each tool's naming convention:

```
src/MISSION.md              → claude/.claude/CLAUDE.md
                            → opencode/.config/opencode/AGENTS.md

src/skills/*.md             → claude/.claude/commands/*.md
                            → opencode/.config/opencode/agents/*.md
```

If a tool-specific header exists in `partials/` (e.g., `partials/claude-header.md`), it gets prepended to that tool's copy of MISSION.md.

Output styles and hooks are **not** composed — they are symlinked directly in the stow packages:

```
src/output-styles/cited.md  ←── claude/.claude/output-styles/cited.md      (symlink)
                            ←── opencode/.config/opencode/output-styles/cited.md (symlink)

src/hooks/hooks.json        ←── claude/.claude/settings.json               (symlink)
src/hooks/citation-audit.ts ←── opencode/.config/opencode/plugins/citation-audit.ts (symlink)
```

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
src/MISSION.md ──[ compose ]──→ claude/.claude/CLAUDE.md ──[ stow ]──→ ~/.claude/CLAUDE.md
                               → opencode/.config/opencode/AGENTS.md ──→ ~/.config/opencode/AGENTS.md

src/skills/*.md ──[ compose ]──→ claude/.claude/commands/*.md ──[ stow ]──→ ~/.claude/commands/*.md
                                → opencode/.config/opencode/agents/*.md ──→ ~/.config/opencode/agents/*.md

src/output-styles/cited.md ←──[ symlink ]── claude/.claude/output-styles/cited.md ──[ stow ]──→ ~/.claude/output-styles/cited.md
                           ←──[ symlink ]── opencode/.config/opencode/output-styles/cited.md ──→ ~/.config/opencode/output-styles/cited.md

src/hooks/hooks.json ←──[ symlink ]── claude/.claude/settings.json ──[ stow ]──→ ~/.claude/settings.json
src/hooks/citation-audit.ts ←──[ symlink ]── opencode/.config/opencode/plugins/citation-audit.ts ──[ stow ]──→ ~/.config/opencode/plugins/citation-audit.ts
```

## Adding a new tool

To support a third AI tool:

1. Create a new stow package directory (e.g., `newtool/`)
2. Mirror the target path structure inside it
3. Add a compose step in `utils/compose.sh` to copy source files with the tool's naming convention
4. Add the package name to `stow --adopt` in `setup.sh`
