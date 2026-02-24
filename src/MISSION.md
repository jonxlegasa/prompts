# Global Instructions

## Collaborative Editing Convention

When editing plans, documents, or notes together with the user:
- The user's comments are tagged `@architect`
- The AI's comments are tagged `@<model-name>` (e.g., `@claude-opus-4.6`, `@claude-sonnet-4.5`, `@claude-haiku-4.5`, `@gpt-4o`, `@codex-mini`, `@minimax-m2`) — always include the provider or family prefix so the name is unambiguous
- **ALWAYS include the version number** in the model tag (e.g., `@claude-haiku-4.5`, NOT `@claude-haiku`). Tags without version numbers are ambiguous and must not be used.
- If the model name is unknown, use `@unknown-agent`
- **NEVER use HTML/markdown comments (`<!-- -->`) for collaborative comments.** Always use plain `@tag:` prefixed text.
- **Write Permission:** Agents MUST NOT write to or append collaborative documents (plans, notes, shared files) unless the `@architect` explicitly instructs them to. The architect controls when agents contribute to the document. Being @-mentioned in the file does not grant write permission — only a direct instruction from the architect in the session does.

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
- **CITATION REQUIREMENT (ALWAYS ACTIVE):** Every Edit, Write, code block, or suggestion MUST be preceded by a **What** (one-line summary), **Why** (reasoning), and **Source** (file path with line numbers, URL, plan reference, or `model knowledge — not verified`). This applies even when skills are active. No exceptions. No change is ever obvious enough to skip.

## Why Citations Matter (Non-Negotiable)

Citations are **traceability infrastructure**, not formatting overhead.

- As projects scale (more subagents, larger codebases, intricate prompts), citations are the only way to debug where information came from and whether to trust it.
- Uncited subagent results are especially dangerous: the main agent didn't verify the data itself, so without `[source: ... — found via exploration]` there is zero traceability.
- "It's just informational" is **NEVER** a reason to skip citations. Informational claims are exactly where hallucinations hide.
- NEVER pass through subagent findings as bare tables or lists. Always attribute with `[source: <url or path> — found via <agent-type> agent]` or similar.
- When something breaks, citations are the breadcrumb trail. Without them, neither the user nor the AI can trace a decision back to its origin.
