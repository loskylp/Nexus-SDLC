---
name: bash-execution
description: Use BEFORE every Bash tool invocation in this project, especially when a command targets a subdirectory or another repository path. TRIGGER when about to call Bash with: any `cd <dir> && <cmd>` pattern; `git` commands against a path that is not the working directory; `npm`/`pnpm`/`bun`/`yarn`/`npx` against a sub-package; `eslint`/`tsc`/`vitest`/`jest`/`pytest`/`go test` against a sub-tree; running a test or build in a monorepo workspace. Forbids `cd <dir> && <cmd>` compounds (they force an approval prompt on every invocation even under wildcard permissions). Prescribes `git -C <path>`, `npm --prefix <path>`, absolute paths, or tool-native path flags instead. Applies to every Nexus SDLC agent that uses Bash (Builder, Verifier, Orchestrator, DevOps, Sentinel, Scribe).
---

# Bash Execution

## Rule

Never use `cd <directory> && <command>` compound forms. Always run commands directly from the working directory.

Claude Code treats `cd <dir> && <command>` as a compound requiring explicit approval on every invocation, even when a wildcard permission covers the command. Running from the working directory avoids this and is always safe.

## Wrong

```bash
cd /Users/pablo/projects/MyApp && npm test
cd /Users/pablo/projects/MyApp && git diff --staged
cd backend && npx eslint src/
```

## Right

```bash
npm test
git diff --staged
git -C /Users/pablo/projects/MyApp log --oneline
npx eslint backend/src/
```

## How to apply

- The working directory is always the project root unless the Orchestrator's routing instruction specifies otherwise.
- For commands that target a subdirectory, pass the path as an argument or flag — do not `cd` into it.
- For git commands targeting a different directory, use `git -C <path>` — never `cd <path> && git ...`.
- If a tool requires being inside a specific directory, use the tool's built-in path option (e.g., `npm --prefix backend test`) rather than `cd`.
- Apply this rule to every Bash tool call, without exception.
