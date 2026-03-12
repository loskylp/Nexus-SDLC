# OQ-0006: Orchestrator Implementation — LLM-Based or Deterministic State Machine?

**Status:** Resolved
**Date:** 2026-03-12
**Resolved:** 2026-03-12
**Priority:** High

## Question

Should the Orchestrator agent be implemented as an LLM-based agent (with a prompt, reasoning, and tool use) or as a deterministic state machine with coded logic? Or a hybrid?

## Resolution

**The question is dissolved.** With OQ-0005 resolved (no software runtime), there is no state machine to implement. The Orchestrator is an agent definition file — a structured prompt document (`agents/orchestrator.md`) that, when loaded into an LLM, causes it to play the Orchestrator role.

The Orchestrator is therefore fully LLM-based by definition. But it is a specific kind of LLM agent: one whose prompt encodes deterministic-style rules (phase transition criteria, escalation triggers, context slicing guidance) as behavioral instructions rather than code. The prompt contains the state machine logic as prose — "If the current phase is DECOMPOSE and the Planner has produced a Task Plan, transition to NEXUS CHECK" — and relies on the LLM to follow these rules.

### What This Means in Practice

1. **The human loads the Orchestrator agent file** at the start of a lifecycle and whenever they need guidance on what to do next.

2. **The Orchestrator agent reads the Project Context document** (provided by the human) and advises: what phase the project is in, what agent to invoke next, what context to provide that agent, and what to do with the agent's output.

3. **The Orchestrator does not directly invoke other agents.** The human does. The Orchestrator is an advisor that tells the human the next step. The human is the runtime.

4. **Phase transition logic, escalation rules, and context slicing guidance** are encoded in the Orchestrator's agent definition file as conditional instructions. The LLM interprets the current Project Context against these rules and produces guidance.

### Trade-offs Acknowledged

- **Non-deterministic:** The same Project Context might produce slightly different orchestration advice on different runs. This is acceptable because the human validates every step.
- **Rule completeness:** The Orchestrator's prompt cannot anticipate every edge case. But per DEC-0009 (Iterative Approximation), the Orchestrator should make a reasonable provisional recommendation and flag uncertainty, rather than refusing to advise.
- **No automation:** The human must manually follow the Orchestrator's instructions — loading agents, passing context, applying updates. This is deliberate: the human IS the orchestration runtime.

## Previously Blocking

- DEC-0006 (Escalation Protocol) — escalation logic is now encoded in the Orchestrator agent definition file
- DEC-0004 (Project Context) — context slicing is now guidance in the Orchestrator's instructions, not programmatic logic
- First agent implementation — **unblocked**: we can now write the Orchestrator agent definition file
