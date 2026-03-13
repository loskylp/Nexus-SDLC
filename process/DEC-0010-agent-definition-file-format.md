# DEC-0010 — Agent Definition File Format

**Status:** Accepted
**Date:** 2026-03-12

## Context

When OQ-0005 resolved — the framework's deliverable is the agent definition files, not software — the file format for agent definitions became the single most critical design decision. This format is the framework's equivalent of an API: it determines what users see, how agents behave, and how the swarm coordinates. An agent definition file is a structured prompt document that, when loaded into any capable LLM, causes the LLM to adopt a specific role within the Nexus SDLC swarm.

The initial format proposal included sections for Identity, Responsibilities, Prohibitions, Input/Output Contracts, Tool Permissions, Handoff Protocol, Escalation Triggers, and Examples. Through implementation of the thirteen agent files, the format evolved: a "Flow" section (Mermaid diagram) was added for visual context, a "When This Agent Is Invoked" section was added for conditional agents, a "Profile Variants" section was added to make per-profile behavior explicit, and the "Working With the Project Context" section was dropped when PROJECT-CONTEXT.md was replaced by the artifact trail (DEC-0004).

## Decision

Each agent definition is a single markdown file stored at `agents/[role-name].md`. The core design principles:

- **Self-contained**: Everything an LLM needs to play the role is in the file (plus the artifact files listed in the Routing Instruction when provided).
- **LLM-agnostic**: Works across providers (Claude, GPT, Gemini, open-source models).
- **Human-readable**: The Nexus must be able to read, understand, and modify agent definitions.
- **Composable**: Agent definitions reference each other by role name, not by file path or implementation detail.

### Canonical Structure (as implemented)

```markdown
# [Role Name] — Nexus SDLC Agent

> One-line tagline summarizing this agent's purpose.

## Identity

[2-3 sentences establishing the agent's identity, perspective, and core responsibility.]

## Flow

[Mermaid flowchart showing this agent's position in the swarm — inputs,
outputs, connections to other agents.]

## When This Agent Is Invoked

[For optional or conditionally-invoked agents: trigger condition.
Omitted for agents that are always part of the active swarm.]

## Responsibilities

[Bulleted list of what this agent does. Precise and exhaustive.]

## You Must Not

[Explicit prohibitions. Behavioral constraints and blast radius control.]

## Input Contract

[What this agent receives — from which agents, which artifact files to load.]

## Output Contract

[What this agent produces — one section per output artifact with format template.]

### Output Format — [Artifact Name]

[Prescriptive template the agent fills in. Not a description — a template.]

## Tool Permissions

**Declared access level:** Tier [N] — [Name]
- You MAY: [permitted actions]
- You MAY NOT: [prohibited actions]
- You MUST ASK the Nexus before: [human-gated actions]

## Handoff Protocol

**You receive work from:** [role name(s)]
**You hand off to:** [role name(s)]

[Instructions for signaling completion and what to include in the handoff.]

## Escalation Triggers

[Specific if-then rules for when to stop and escalate — one question each,
per DEC-0009.]

## Behavioral Principles

[3-7 principles guiding judgment in ambiguous situations.]

## Profile Variants

[Table showing how behavior scales across Casual / Commercial / Critical / Vital.]

## Example Interaction

[One concrete example showing the agent receiving input and producing output.
Optional but present where it aids understanding.]
```

### Design Principles for Agent Files

1. **Behavioral constraints over access control.** Since there is no runtime enforcing permissions, the agent definition must make constraints so clear and prominent that the LLM follows them. The "You Must Not" section is a negative-space definition that reinforces boundaries.

2. **Output templates are prescriptive.** The Output Format section is not a description of what the output looks like — it is a template the agent copies and fills in. This reduces format drift across LLM providers.

3. **Few-shot examples where warranted.** LLMs perform significantly better with concrete examples. Agent files include example interactions where the input-output pattern benefits from illustration.

4. **Cross-references by role name, never by file path.** Agent definitions reference "the Orchestrator" or "the Verifier," not `agents/orchestrator.md`. This maintains portability.

5. **The file IS the prompt.** The entire markdown file is designed to be pasted as a system prompt. The markdown formatting serves dual duty: readable by humans and parseable structure for LLMs.

### What Evolved from the Initial Format

**Dropped: "Working With the Project Context" section.** It assumed a single PROJECT-CONTEXT.md (DEC-0004 initial proposal). Replaced by Input Contract and Output Contract sections that declare specific artifact files.

**Added: "Profile Variants" section.** Every agent's behavior is calibrated to the project profile (DEC-0013). A separate table makes the profile scaling explicit and consistent across all agents — without it, profile-specific behavior is scattered through the Responsibilities text and easy to miss.

**Added: "Flow" section (Mermaid diagram).** Makes each agent's position in the swarm immediately visible. This is a documentation convention for human readers, not a behavioral instruction for the LLM.

**Added: "When This Agent Is Invoked" section.** For conditional agents (Scaffolder, Sentinel, Scribe, Designer), their trigger conditions are important enough to warrant their own section near the top of the file, not buried in Responsibilities.

## Reasoning

**Why markdown:** Human-readable, version-controllable (diffable in git), renderable in any documentation tool, and parseable by every LLM. It does not require special tooling to create, edit, or use.

**Why a single file per agent:** Each agent definition must be self-contained because users load it into an LLM conversation independently. A multi-file agent definition would require assembly before use — adding a tooling dependency the framework explicitly avoids.

**Why the "You Must Not" section:** Positive instructions ("do X") are necessary but insufficient for boundary enforcement. LLMs respond well to explicit negative instructions, especially for safety-critical constraints. The section name is deliberately direct — "You Must Not" is stronger than "Limitations" or "Constraints."

**Why prescriptive output templates:** If the output format is described loosely ("produce a report with test results"), different LLM providers produce different structures, making inter-agent handoffs unreliable. A concrete template that the agent fills in produces consistent output regardless of provider.

**Why "Profile Variants" as a dedicated section:** Every agent's behavior is calibrated to the project profile. Without a dedicated table, profile-specific behavior is scattered through the Responsibilities text and becomes invisible during reviews. The table makes it auditable: for each profile, what does this agent do differently?

**Why Mermaid for Flow diagrams:** Mermaid is text-based (version-controllable), renderable in GitHub and most markdown viewers, and readable even as raw text. Binary image formats would break the all-markdown, all-text principle.

## Alternatives Considered

**YAML/JSON configuration files:** Machine-parseable but not human-friendly for the amount of natural language instruction required. An agent definition is primarily prose with some structure. Markdown handles this mix better than structured data formats. Rejected for poor prose support.

**Single monolithic prompt file:** All agent definitions in one file with role-switching instructions. Simpler file management but produces extremely long prompts and makes it impossible to load a single role. Rejected for impracticality.

**Templating language (Jinja, Mustache):** Enables dynamic composition but reintroduces tooling. The self-contained principle means accepting some duplication in exchange for zero-tooling portability. Rejected for infrastructure dependency.

**Structured prompt format (DSPy signatures, LangChain templates):** Ties the framework to a specific library. Violates the LLM-agnostic and infrastructure-free principles. Rejected for vendor lock-in.

**No canonical structure (freeform agent files):** Maximum flexibility but no consistency across agents. Inter-agent contracts depend on predictable structure — the Orchestrator needs to know where the Input Contract is in every agent file. Rejected for coordination failure.

## Consequences

- Users can start immediately — load a file, provide context, go. No installation, no dependencies, no infrastructure.
- Agent definitions are version-controlled, diffable, reviewable in PRs.
- Customization is straightforward — fork and edit a markdown file.
- Every agent definition must follow the canonical structure — deviations break the inter-agent contract.
- Agent files must be self-contained — no imports, no includes, no external dependencies.
- Every agent file includes a Profile Variants table showing behavior across Casual / Commercial / Critical / Vital.
- The "Working With the Project Context" section from the initial proposal is not used — agents declare artifact dependencies in Input Contract and Output Contract instead.
