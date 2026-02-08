# Plan: Skeleton Project with Stow-Managed Prompt Deployment

@architect: Create skeleton project with utils dir and stow feature for deploying CLAUDE.md / AGENTS.md from a single MISSION.md source.

@claude-opus-4.6: Plan follows.

---

## Problem

Two AI tools need the same system prompt deployed to different paths:

| Tool      | Config file   | Target path                        |
|-----------|---------------|------------------------------------|
| Claude Code | `CLAUDE.md`  | `~/.claude/CLAUDE.md`             |
| OpenCode    | `AGENTS.md`  | `~/.config/opencode/AGENTS.md`   |

Today these are manually maintained copies. They drift. We need:
1. A **single source of truth** (`MISSION.md`)
2. A **build step** that produces tool-specific files from it
3. **GNU Stow** to symlink the built files into place

---

## Architecture

```
prompts/
├── plans/
│   └── skeleton-and-stow.md      # this plan
├── MISSION.md                     # single source of truth prompt
├── partials/                      # tool-specific wrappers (optional)
│   ├── claude-header.md           # claude-only preamble (if needed)
│   └── agents-header.md          # opencode-only preamble (if needed)
├── stow/
│   ├── claude/                    # stow package: "claude"
│   │   └── .claude/
│   │       └── CLAUDE.md          # GENERATED — do not hand-edit
│   └── opencode/                  # stow package: "opencode"
│       └── .config/
│           └── opencode/
│               └── AGENTS.md      # GENERATED — do not hand-edit
├── utils/
│   ├── compose.sh                 # builds CLAUDE.md & AGENTS.md from MISSION.md
│   └── stow.sh                    # wraps stow deploy/undeploy
├── Makefile                       # orchestration: make build, make deploy, make clean
└── README.md
```

### Key directories

- **`plans/`** — planning documents
- **`utils/`** — standalone helper scripts organized by purpose. Only utility functions live here — things that serve a general purpose and aren't the main feature themselves.
- **`stow/`** — GNU Stow packages. Each subdirectory is a package whose internal structure mirrors `$HOME`.
- **`partials/`** — optional per-tool header/footer fragments that wrap `MISSION.md` content.

---

## How the pieces connect

```
MISSION.md  ─┐
              ├──[ utils/compose.sh ]──> stow/claude/.claude/CLAUDE.md
              ├──[ utils/compose.sh ]──> stow/opencode/.config/opencode/AGENTS.md
              │
partials/     ┘
claude-header.md ──────────────────────> prepended to CLAUDE.md (optional)
agents-header.md ──────────────────────> prepended to AGENTS.md (optional)
```

Then:

```
stow/claude/    ──[ GNU Stow ]──>  ~/.claude/CLAUDE.md        (symlink)
stow/opencode/  ──[ GNU Stow ]──>  ~/.config/opencode/AGENTS.md (symlink)
```

---

## Implementation Steps

### Step 1: Create `MISSION.md`

Move the current shared prompt content into `MISSION.md` at project root. This becomes the canonical source. Both CLAUDE.md and AGENTS.md are generated from it.

### Step 2: Create `partials/` (optional headers)

If the tools need different preambles (e.g., `# Global Instructions` vs a different title), put those in `partials/claude-header.md` and `partials/agents-header.md`. If both tools use identical content, these can be empty or omitted — `compose.sh` handles both cases.

### Step 3: Create `utils/compose.sh`

Responsibilities:
- Read `MISSION.md`
- Optionally prepend tool-specific header from `partials/`
- Write output to `stow/claude/.claude/CLAUDE.md` and `stow/opencode/.config/opencode/AGENTS.md`
- Idempotent — safe to run repeatedly

```bash
#!/usr/bin/env bash
# utils/compose.sh — Build tool-specific prompt files from MISSION.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MISSION="$ROOT/MISSION.md"

build_target() {
    local header="$1" output="$2"
    mkdir -p "$(dirname "$output")"
    if [[ -f "$header" ]]; then
        cat "$header" "$MISSION" > "$output"
    else
        cp "$MISSION" "$output"
    fi
    echo "  built: $output"
}

echo "Composing from: $MISSION"
build_target "$ROOT/partials/claude-header.md"  "$ROOT/stow/claude/.claude/CLAUDE.md"
build_target "$ROOT/partials/agents-header.md"  "$ROOT/stow/opencode/.config/opencode/AGENTS.md"
echo "Done."
```

### Step 4: Create `utils/stow.sh`

Wraps GNU Stow with sane defaults:

```bash
#!/usr/bin/env bash
# utils/stow.sh — Deploy or remove stow packages
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STOW_DIR="$ROOT/stow"
TARGET="$HOME"

ACTION="${1:-deploy}"

case "$ACTION" in
    deploy)
        stow -v -d "$STOW_DIR" -t "$TARGET" claude opencode
        echo "Deployed."
        ;;
    remove)
        stow -v -D -d "$STOW_DIR" -t "$TARGET" claude opencode
        echo "Removed."
        ;;
    restow)
        stow -v -R -d "$STOW_DIR" -t "$TARGET" claude opencode
        echo "Restowed."
        ;;
    *)
        echo "Usage: $0 {deploy|remove|restow}"
        exit 1
        ;;
esac
```

### Step 5: Create `Makefile`

```makefile
.PHONY: build deploy remove restow clean

build:
	bash utils/compose.sh

deploy: build
	bash utils/stow.sh deploy

remove:
	bash utils/stow.sh remove

restow: build
	bash utils/stow.sh restow

clean:
	rm -f stow/claude/.claude/CLAUDE.md
	rm -f stow/opencode/.config/opencode/AGENTS.md
```

### Step 6: `.gitignore` the generated files

Add to `.gitignore`:
```
stow/claude/.claude/CLAUDE.md
stow/opencode/.config/opencode/AGENTS.md
```

These are build artifacts. Only `MISSION.md` and `partials/` are source-controlled.

---

@architect should this not be as easy as just stow .?

@claude-opus-4.6: You're right — I was overengineering it. Looking at your dotfiles pattern:

```
.stowrc          → --target=~/.config
stow --adopt .   → done
```

No wrapper scripts, no Makefile indirection. The repo root IS the stow directory.

The wrinkle here is **two different targets**:
- `AGENTS.md` → `~/.config/opencode/AGENTS.md` (fits `.stowrc --target=~/.config`)
- `CLAUDE.md` → `~/.claude/CLAUDE.md` (target is `~/`, not `~/.config`)

Options:

**A) Target `~` instead of `~/.config`** — then package dirs mirror from home:
```
.stowrc              → --target=~
opencode/             # package
  .config/opencode/AGENTS.md
claude/               # package
  .claude/CLAUDE.md
```
`stow --adopt .` works. But packages need deeper nesting.

**B) Target `~/.config` and handle claude separately** — keep your dotfiles convention:
```
.stowrc              → --target=~/.config
opencode/AGENTS.md   # stow --adopt opencode → ~/.config/opencode/AGENTS.md ✓
```
Then for claude: `stow -t ~ claude` (one-off override since `.claude/` lives at `~` not `~/.config`).
Setup script becomes:
```bash
stow --adopt .
stow --adopt -t ~ claude
```

**C) Merge into your existing dotfiles repo** — add an `opencode/` package there (it already exists!) and a `claude/` package. This repo just holds `MISSION.md` + `compose.sh` and builds into the dotfiles repo.

@claude-opus-4.6: Which do you prefer? B keeps closest to your existing `stow .` pattern with one small exception for claude. A is cleaner but changes the target convention. C separates concerns but adds a cross-repo dependency.

@architect: I much prefer implementation A. It is much simpler. I also want you to consider that we also want to make a one to one stow with the current way we handle opencode and claude in our own setup.

@claude-opus-4.6: Agreed, A it is. And I see what you mean by one-to-one — your dotfiles repo already maps packages directly to their target structure. `opencode/` in dotfiles mirrors `~/.config/opencode/` exactly. Same principle here.

So the prompts repo should work identically: target `~`, each package mirrors the exact filesystem path from home. The revised structure:

```
prompts/
├── .stowrc                        # --target=~
├── setup.sh                       # stow --adopt .
├── MISSION.md                     # single source of truth
├── partials/                      # optional tool-specific fragments
├── utils/
│   └── compose.sh                 # builds package files from MISSION.md
├── claude/                        # stow package → ~/.claude/
│   └── .claude/
│       └── CLAUDE.md              # GENERATED from MISSION.md
├── opencode/                      # stow package → ~/.config/opencode/
│   └── .config/
│       └── opencode/
│           └── AGENTS.md          # GENERATED from MISSION.md
└── plans/
```

Workflow:
```bash
vim MISSION.md           # edit the source
bash utils/compose.sh    # build CLAUDE.md + AGENTS.md from MISSION.md
stow --adopt .           # deploy (or restow if already linked)
```

This matches your dotfiles convention exactly — same `.stowrc` pattern, same `stow --adopt .`, same one-to-one package-to-target mapping. The only addition is the compose step since the files are generated rather than hand-edited.

One thing to note: `stow .` will try to stow `plans/`, `utils/`, `partials/` etc. as packages too. We need to tell stow to ignore those. In `.stowrc`:

```
--target=~
--ignore=plans
--ignore=utils
--ignore=partials
--ignore=README.md
--ignore=MISSION.md
--ignore=Makefile
```

Or alternatively, we can use `stow claude opencode` explicitly instead of `stow .` to only deploy the actual packages. Cleaner — no ignore list to maintain.

Which do you prefer: `stow .` with ignores, or `stow claude opencode` explicitly?

@architect: BUT also consider that opencode and claude ALSO have commands and agents.. We would also like to stow those markdown files as they are prompts as well.

@claude-opus-4.6: Right — it's not just CLAUDE.md and AGENTS.md. The full inventory:

| Source prompt | Claude Code target | OpenCode target |
|---|---|---|
| `MISSION.md` | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` |
| `doc-sync.md` | `~/.claude/commands/doc-sync.md` | `~/.config/opencode/agents/doc-sync.md` |
| `generate-beads.md` | `~/.claude/commands/generate-beads.md` | `~/.config/opencode/agents/generate-beads.md` |
| `implement-beads.md` | `~/.claude/commands/implement-beads.md` | `~/.config/opencode/agents/implement-beads.md` |

Currently these are copies that drift (implement-beads.md already has a one-line divergence). All content is identical — only the **path** and **filename** differ between tools.

This changes `compose.sh` — it's no longer just MISSION.md, it needs to build the commands/agents too. Each source prompt gets copied into both stow packages under the tool's naming convention.

Revised structure:

```
prompts/
├── .stowrc                              # --target=~
├── setup.sh                             # compose + stow
├── src/                                 # ALL source-of-truth prompts live here
│   ├── MISSION.md                       # main system prompt
│   └── skills/                          # command/agent prompts
│       ├── doc-sync.md
│       ├── generate-beads.md
│       └── implement-beads.md
├── partials/                            # optional per-tool wrappers
├── utils/
│   └── compose.sh                       # builds both packages from src/
├── claude/                              # stow package → ~/
│   └── .claude/
│       ├── CLAUDE.md                    # GENERATED from src/MISSION.md
│       └── commands/
│           ├── doc-sync.md              # GENERATED from src/skills/
│           ├── generate-beads.md
│           └── implement-beads.md
├── opencode/                            # stow package → ~/
│   └── .config/
│       └── opencode/
│           ├── AGENTS.md                # GENERATED from src/MISSION.md
│           └── agents/
│               ├── doc-sync.md          # GENERATED from src/skills/
│               ├── generate-beads.md
│               └── implement-beads.md
└── plans/
```

`compose.sh` does:
1. `src/MISSION.md` → `claude/.claude/CLAUDE.md` + `opencode/.config/opencode/AGENTS.md`
2. `src/skills/*.md` → `claude/.claude/commands/*.md` + `opencode/.config/opencode/agents/*.md`

Then `stow claude opencode` symlinks everything into place. One source, two targets, zero drift.

The `src/skills/` name is intentional — "skills" is a neutral term since Claude calls them "commands" and OpenCode calls them "agents". The compose step handles the rename. If a new tool shows up with yet another convention, we add one more stow package and a mapping in compose.sh.

@architect: Do we have a simple end bash script that then just does this similar to dotfiles?

@claude-opus-4.6: Yes — same pattern as your dotfiles `setup.sh`. Two lines of real work:

```bash
#!/usr/bin/env bash
echo "Building prompts from source..."
bash utils/compose.sh

echo "Stowing prompts..."
stow --adopt claude opencode

echo "Done."
```

That's it. `compose.sh` builds the files, `stow --adopt claude opencode` links them. Mirrors your dotfiles exactly — no Makefile needed, just `bash setup.sh`.

We name the packages explicitly (`claude opencode`) instead of `stow .` to avoid stowing `src/`, `utils/`, `plans/`, etc. Keeps the `.stowrc` clean — just `--target=~`, no ignore list.

## Workflow

```bash
# Edit the prompt
vim MISSION.md

# Build + deploy in one command
make deploy

# Verify symlinks
ls -la ~/.claude/CLAUDE.md
ls -la ~/.config/opencode/AGENTS.md

# Undo deployment
make remove
```

---

## Stow conflict handling

If `~/.claude/CLAUDE.md` or `~/.config/opencode/AGENTS.md` already exist as regular files (not symlinks), stow will refuse to overwrite them. The deploy script should:
1. Detect existing non-symlink files
2. Back them up (e.g., `CLAUDE.md.bak.20260208`)
3. Remove them so stow can create its symlinks

This logic belongs in `utils/stow.sh` as a pre-deploy check.

---

## Open questions for @architect

1. **Partials needed?** Currently CLAUDE.md and AGENTS.md are byte-identical. Do you want tool-specific headers, or is a straight copy from MISSION.md sufficient for now? We can always add partials later.
2. **Additional stow packages?** Any other dotfiles or configs to manage from this repo (e.g., project-level `.claude/CLAUDE.md` in specific repos)?
3. **Extra utils?** Any other utility scripts you already have in mind for `utils/`?
