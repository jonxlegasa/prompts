import { readFileSync } from "fs"
import { join } from "path"

/**
 * Citation audit plugin for OpenCode.
 *
 * Mirrors the Claude Code hooks in src/hooks/hooks.json:
 * - Injects cited.md into context on session compaction
 * - Preserves citation rules across compaction boundaries
 */
export const CitationAudit = async ({ directory }: { directory: string }) => {
  const citedPath = join(
    process.env.HOME || "~",
    ".config/opencode/output-styles/cited.md",
  )

  let citedContent: string
  try {
    citedContent = readFileSync(citedPath, "utf-8")
  } catch {
    console.warn(`[citation-audit] Could not read ${citedPath}`)
    citedContent = ""
  }

  return {
    "experimental.session.compacting": async (
      input: unknown,
      output: { context: string[] },
    ) => {
      if (citedContent) {
        output.context.push(citedContent)
      }
    },
  }
}
