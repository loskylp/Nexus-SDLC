# DEC-0010: Agent Definition File Format

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

With OQ-0005 resolved — the framework's deliverable is the agent definition files, not software — the file format for agent definitions becomes the single most critical design decision. This format is the framework's equivalent of an API: it determines what users see, how agents behave, and how the swarm coordinates.

An agent definition file is a structured prompt document that, when loaded into any capable LLM, causes the LLM to adopt a specific role within the Nexus SDLC swarm. The file must be:
- **Self-contained**: Everything an LLM needs to play the role is in the file (plus the Project Context when provided)
- **LLM-agnostic**: Works across providers (Claude, GPT, Gemini, open-source models)
- **Human-readable**: The Nexus must be able to read, understand, and modify agent definitions
- **Composable**: Agent definitions reference each other by role name, not by file path or implementation detail

## Decision

Each agent definition is a single markdown file with the following canonical structure:

### File Naming Convention

`agents/[role-name].md` — e.g., `agents/orchestrator.md`, `agents/coder.md`, `agents/qa.md`

### Canonical Structure

```markdown
# [Role Name] — Nexus SDLC Agent

> One-line summary of this agent's purpose.

## Identity

You are the [Role Name] in the Nexus SDLC framework. [2-3 sentences establishing
the agent's identity, perspective, and core responsibility.]

## Responsibilities

[Bulleted list of what this agent does. Precise and exhaustive. If it is not
listed here, the agent should not do it.]

## You Must Not

[Explicit prohibitions. Things this agent must never do, even if asked.
This is the behavioral constraint section — the blast radius control.]

## Input Contract

What this agent receives at the start of an invocation:

- **From the Nexus (human):** [what the human provides directly]
- **From the Project Context:** [what sections of the Project Context this agent reads]
- **From other agents:** [what artifacts from other agent roles this agent consumes]

## Output Contract

What this agent must produce at the end of an invocation:

[Structured description of every artifact this agent produces, including format.
Each output must be concrete — "a list of tasks" not "a plan."]

### Output Format

[Exact template or schema the agent's output must follow. This section is
prescriptive, not descriptive. The agent copies this structure.]

## Tool Permissions

**Declared access level:** [Tier 0-4 per DEC-0005]

[List of tools/capabilities this agent may use, written as behavioral
instructions:]
- You MAY: [list of permitted actions]
- You MAY NOT: [list of prohibited actions]
- You MUST ASK the Nexus before: [list of human-gated actions]

## Working With the Project Context

[Instructions for how this agent reads and updates the Project Context document.
Which sections to read, which sections to update, what format to use when
appending entries.]

## Handoff Protocol

**You receive work from:** [role name(s)]
**You hand off work to:** [role name(s)]

[Instructions for how to signal completion and what to include in the handoff.
References the HandoffEnvelope format from DEC-0003, adapted for markdown.]

## Escalation Triggers

[Specific conditions under which this agent must stop working and escalate to
the Orchestrator or directly to the Nexus. Written as concrete if-then rules.]

- If [condition], then [escalation action with specific output format]

## Behavioral Principles

[3-7 principles that guide this agent's judgment in ambiguous situations.
These are the "spirit of the law" behind the specific rules above.]

## Example Interaction

[One or two concrete examples showing this agent receiving input and producing
output in the correct format. These serve as few-shot examples for the LLM
and as documentation for the human.]
```

### Design Principles for Agent Files

1. **Behavioral constraints over access control.** Since there is no runtime enforcing permissions, the agent definition must make constraints so clear and prominent that the LLM follows them. The "You Must Not" section exists for this reason — it is a negative-space definition that reinforces boundaries.

2. **Output templates are prescriptive.** The Output Format section is not a description of what the output looks like — it is a template the agent copies and fills in. This reduces format drift across LLM providers.

3. **Few-shot examples are mandatory.** LLMs perform significantly better with concrete examples. Every agent file includes at least one example interaction showing the input-output pattern.

4. **Cross-references by role name, never by file path.** Agent definitions reference "the Orchestrator" or "the QA agent," not `agents/orchestrator.md`. This maintains portability.

5. **The file IS the prompt.** The entire markdown file is designed to be pasted as a system prompt. The markdown formatting serves dual duty: readable by humans and parseable structure for LLMs.

## Rationale

**Why markdown:** Markdown is human-readable, version-controllable (diffable in git), renderable in any documentation tool, and parseable by every LLM. It does not require special tooling to create, edit, or use. It is the natural format for a text-first, infrastructure-free framework.

**Why a single file per agent:** Each agent definition must be self-contained because users load it into an LLM conversation independently. A multi-file agent definition would require assembly before use — which re-introduces tooling and infrastructure.

**Why the "You Must Not" section:** Positive instructions ("do X") are necessary but insufficient for boundary enforcement. LLMs respond well to explicit negative instructions, especially for safety-critical constraints. The section acts as a prompt-level ACL.

**Why prescriptive output templates:** If the output format is described loosely ("produce a task plan"), different LLM providers will produce different structures, making inter-agent handoffs unreliable. A concrete template that the agent fills in produces consistent output regardless of provider.

**Why few-shot examples:** The empirical evidence on few-shot prompting is clear — concrete examples improve output quality and format adherence more reliably than instructions alone. For a framework that depends on agents producing precisely formatted outputs, examples are non-optional.

## Consequences

**Easier:**
- Users can start immediately — load a file, provide context, go
- Agent definitions are version-controlled, diffable, reviewable in PRs
- Customization is straightforward — fork and edit a markdown file
- No installation, no dependencies, no infrastructure

**Harder:**
- Behavioral constraints are enforced by prompt adherence, not by code — sufficiently creative (or poorly aligned) LLMs may violate them
- Testing agent definitions requires running them against LLMs and evaluating outputs, which is inherently non-deterministic
- Keeping agent files in sync when the framework evolves requires discipline (no automated schema migration)

**Newly constrained:**
- Every agent definition must follow this canonical structure — deviations break the inter-agent contract
- Agent files must be self-contained — no imports, no includes, no external dependencies
- The Project Context document format must be stable because every agent file references it

## Alternatives Considered

**YAML/JSON configuration files:** Machine-parseable but not human-friendly for the amount of natural language instruction required. An agent definition is primarily prose (behavioral instructions, reasoning guidance) with some structure (input/output contracts). Markdown handles this mix better than structured data formats. Rejected for poor prose support.

**Single monolithic prompt file:** All agent definitions in one file with role-switching instructions. Simpler file management but produces extremely long prompts that exceed context windows and make it impossible to load a single role. Rejected for impracticality.

**Templating language (Jinja, Mustache):** Enables dynamic composition (e.g., include common sections across agents). But re-introduces tooling — users need a template renderer. The self-contained principle means accepting some duplication across agent files in exchange for zero-tooling portability. Rejected for infrastructure dependency.

**Structured prompt format (DSPy signatures, LangChain templates):** Ties the framework to a specific library. Violates the LLM-agnostic and infrastructure-free principles. Rejected for vendor lock-in.
