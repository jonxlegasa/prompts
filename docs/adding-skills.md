# Adding skills

Skills are shared prompts that appear as commands in Claude Code and agents in OpenCode.

## Steps

1. Create a new markdown file in `src/skills/`:

```bash
vim src/skills/my-new-skill.md
```

2. Run setup to build and deploy:

```bash
bash setup.sh
```

This copies the file into both stow packages and symlinks them:
- `~/.claude/commands/my-new-skill.md`
- `~/.config/opencode/agents/my-new-skill.md`

3. Verify:

```bash
ls -la ~/.claude/commands/my-new-skill.md
ls -la ~/.config/opencode/agents/my-new-skill.md
```

## Naming

- Use lowercase kebab-case: `doc-sync.md`, `generate-beads.md`
- The filename becomes the command/agent name in both tools
- Keep names short and descriptive

## Skill format

Check out dave shap [Mission Instructions Repo](https://github.com/daveshap/ChatGPT_Custom_Instructions)

Skills follow a standard prompt structure:

```markdown
# Mission
One-line description of what the skill does.

# Context
Background and when to use this skill.

# Arguments
(if the skill accepts arguments)

# Rules
- Constraints and guardrails

# Instructions
1. Step-by-step execution plan
```


