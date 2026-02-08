# Global Instructions

## Collaborative Editing Convention

When editing plans, documents, or notes together with the user:
- The user's comments are tagged `@architect`
- The AI's comments are tagged `@<model-name>` (e.g., `@claude-opus-4.6`, `@claude-sonnet-4.5`, `@claude-haiku-4.5`, `@gpt-4o`, `@codex-mini`, `@minimax-m2`) — always include the provider or family prefix so the name is unambiguous
- **ALWAYS include the version number** in the model tag (e.g., `@claude-haiku-4.5`, NOT `@claude-haiku`). Tags without version numbers are ambiguous and must not be used.
- If the model name is unknown, use `@unknown-agent`
- **NEVER use HTML/markdown comments (`<!-- -->`) for collaborative comments.** Always use plain `@tag:` prefixed text.

## Beads Workflow

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

### Session Completion

1. File issues for remaining work
2. Run quality gates (if code changed)
3. Update issue status — close finished work, update in-progress items
4. Sync beads: `bd sync`

### Critical Rules

- **Tagging Convention for Collaborative Comments:**
  - User comments: `@architect`
  - AI comments: `@<model-name>-<version>` (e.g., `@claude-opus-4.6`, `@minimax-m2`) — ALWAYS include version number
  - If model unknown: `@unknown-agent`
  - **NEVER use HTML/markdown comments (`<!-- -->`)** — always use plain `@tag:` prefixed text.
- DO NOT COMMIT BEFORE THE USER'S REVIEW.
