# Mission

Sync implementation edits back into a plan file using the collaborative `@tag` comment format. When further changes are made after an initial plan — discovered during implementation, testing, or architect feedback — this command captures them as a conversation between `@architect` and the agent, appended to the original plan.

# Context

Plans evolve during implementation. The architect runs the code, discovers issues, requests changes, or refines the approach. These post-plan edits need to be recorded in the plan file so future sessions have full context. The format mirrors the existing collaborative comment convention: `@architect` describes what they wanted, `@<model-name>` summarizes what was done and why.

# Arguments
```
$ARGUMENTS
```

Parse as: `<plan_file>`
- `plan_file`: Path to the plan markdown file to sync edits into

# Rules

- Use the collaborative comment convention: `@architect` for user intent, `@<model-name>` (e.g. `@claude-opus-4.6`) for agent summary
- ALWAYS include the version number in the model tag (e.g., `@claude-opus-4.6`, NOT `@claude-opus`)
- NEVER use HTML/markdown comments (`<!-- -->`) — always use plain `@tag:` prefixed text
- Append edits to the plan — never rewrite or remove existing content
- The `@architect` comment should capture the user's intent/feedback concisely
- The agent comment should list concrete changes made, referencing files and functions
- Keep both comments concise — bullet points preferred for the agent summary
- If multiple rounds of edits happened, group them into one `@architect` + `@agent` pair per logical topic
- Read the plan file FIRST to understand its structure and existing comments
- Review session history (git diff, recent conversation) to identify what changed beyond the original plan
- Present the proposed comment block to the user for approval before writing

# Comment Format

```
@architect: <concise description of what the architect wanted or the feedback that triggered edits>

@<model-name>: <summary of what was implemented>
- Change 1: file/function affected and what changed
- Change 2: file/function affected and what changed
- ...
```

# Instructions

1. Parse arguments to extract `plan_file`
2. Read the plan file completely
3. Review the current session's changes:
   - Check git diff for modified files
   - Review conversation history for architect feedback and requests
   - Identify changes that go beyond what the original plan specified
4. Group the post-plan edits by logical topic (e.g., "progress bar rework", "config toggles", "bug fix")
5. For each topic, draft a comment pair:
   - `@architect:` — what the user wanted (use their words where possible)
   - `@<model-name>:` — concise summary of what was done
6. Present the proposed comment block(s) to the user for review
7. On approval, append to the plan file in the appropriate location:
   - If the edit relates to a specific section, append after that section
   - If it's a general post-implementation update, append before the closing sections (e.g., before "Thread Safety Analysis" or "Verification")
8. Confirm the sync is complete

# Example

Given a plan about parallelizing grid search, after the architect requests progress bar changes:

```
@architect: The progress bars were a mess with 20 threads fighting for the terminal. I wanted one shared bar per batch so you can see all PINNs training together. Also needed a startup banner showing threads/GPU info.

@claude-opus-4.6: Implemented shared batch progress bar and startup banner.
- `train_pinn()`: new `progress_callback` kwarg — grid search passes a shared `ProgressMeter.Progress` bar, single run creates its own as before.
- `evaluate_weight_configuration()`: threads the callback through to `train_pinn()`.
- `grid_search_2d()`: creates ONE shared progress bar per batch, all threads tick it via `ProgressMeter.next!()`.
- Startup banner prints threads, GPU name, VRAM free, grid dims, batch size.
- `ProgressBar.jl`: fixed thread-unsafe globals — converted to closured `Ref`s.
```

# Error Handling

- If the plan file doesn't exist, ask the user which file to sync into
- If no post-plan edits are detected, inform the user and exit
- If the model name is unknown, use `@unknown-agent`
