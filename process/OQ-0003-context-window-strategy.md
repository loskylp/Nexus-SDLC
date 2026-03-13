# OQ-0003: Context Loading — What Artifacts Should the Human Load for Each Agent Invocation?

**Status:** Open (Reframed)
**Date:** 2026-03-12 (reframed 2026-03-13)
**Priority:** High

## Question

The framework's runtime is the human loading agent definition files into LLM sessions. Each agent's Input Contract declares what artifacts it needs — but the human must decide what to actually include in the context window for each invocation. How does the Nexus know what to load, and how much is enough?

## Why It Matters

Context loading is the practical bottleneck of a human-runtime framework. A project with 50 tasks across multiple cycles produces dozens of artifacts — briefs, requirements, ADRs, task plans, handoff notes, verification reports, escalation logs. No single LLM session can hold all of them, and the human should not have to guess which ones matter for a given agent invocation.

Poor context loading leads to:
- Agents repeating work because they lack context about prior decisions
- Inconsistent outputs because agents miss architectural constraints or domain vocabulary
- Wasted Nexus time re-providing information that should have been loaded upfront

## Options Being Considered

**Option A — Input Contracts are sufficient:**
Each agent's Input Contract already declares exactly what it needs. The Orchestrator's Routing Instruction includes a "Load these artifacts" field listing the specific files. The human follows this list. No additional guidance needed.

*Partial address:* The orchestrator.md Routing Instruction format already includes this field. If the human is acting as the Orchestrator (loading the Orchestrator prompt and following its instructions), the Routing Instruction tells them what to load for the next agent.

*Trade-offs:* Works well when the Orchestrator is invoked faithfully and the artifact trail is well-organized. Breaks down if the human skips the Orchestrator step and invokes agents directly, or if the artifact trail has grown large enough that the "Load these artifacts" list exceeds the context window.

**Option B — Agent definition files include a "Context Loading Guide":**
Add a new section to each agent definition file that provides a prioritized list: "Always load," "Load if relevant," "Load if the project has N+ cycles." This gives the human a quick reference even when not using the full Orchestrator routing.

*Trade-offs:* More self-contained per agent. But adds maintenance burden to agent files and may become stale as the artifact trail model evolves.

**Option C — A standalone context loading reference document:**
A single reference document that maps each agent invocation to its required and optional context, organized by lifecycle phase. The Nexus consults this when setting up an LLM session.

*Trade-offs:* Single source of truth, easy to update. But one more document to maintain and consult — adds a step to every invocation.

**Option D — Defer to empirical use:**
The Input Contracts and Routing Instructions provide the baseline. Let the Nexus discover through practice which invocations need more context and which need less. Document patterns as they emerge.

*Trade-offs:* Lowest upfront effort. Matches the iterative approximation principle. But the Nexus may waste early sessions on under-loaded or over-loaded invocations before calibrating.

## Information Needed

1. **Practical context window sizes:** How large do real agent invocations get when all declared Input Contract artifacts are loaded? If they consistently fit, Option A may be sufficient.

2. **Usage patterns:** Does the Nexus typically invoke the full Orchestrator flow (which includes routing instructions), or does the Nexus sometimes invoke agents directly?

3. **Artifact trail growth rate:** How many artifacts does a typical cycle produce, and how quickly does the trail exceed a single context window?

## Blocking

- Informs the Orchestrator agent file (whether the Routing Instruction's "Load these artifacts" field needs more structure)
- May inform whether agent definition files need a Context Loading Guide section (DEC-0010)
