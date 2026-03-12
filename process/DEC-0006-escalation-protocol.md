# DEC-0006: Escalation Protocol and Failure Mode Taxonomy

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

The RATIONALE.md identifies "Graceful Degradation" as a core design goal: when agents fail to converge, the system must fail safely and informatively, surfacing a clear escalation with failure context, attempted approaches, and a specific question. Escalation paths must be first-class citizens, not afterthoughts.

We need to define: what failure modes exist, how they are classified, what the escalation path is for each, and how the human receives escalation information.

## Decision

### Failure Mode Taxonomy

| Failure Mode | Description | Detection | Response |
|---|---|---|---|
| **Verification Failure** | Tests fail, lint errors, type errors | QA/Reviewer/Security reports | Autonomous retry within iterate bounds (DEC-0002) |
| **Convergence Failure** | Iterate loop exhausted without passing verification | Orchestrator detects max_iterations or non-decreasing failures | NEXUS ESCALATION |
| **Plan Infeasibility** | Agent determines a task cannot be completed as specified | Coder or QA raises infeasibility signal | Orchestrator validates, then NEXUS ESCALATION |
| **Ambiguity Detection** | Agent encounters ambiguous requirement that has multiple valid interpretations | Any agent flags ambiguity | Orchestrator collects interpretations, then NEXUS ESCALATION |
| **Tool Failure** | External tool (compiler, test runner, linter) fails unexpectedly | Agent detects non-zero exit code with unexpected error | Orchestrator retries once; if persistent, NEXUS ESCALATION |
| **Scope Creep Detection** | Agent determines the task requires changes outside its authorized scope | Coder detects need to modify files outside task scope | NEXUS ESCALATION with scope expansion request |
| **Security Alert** | Security agent detects a vulnerability in generated code or dependencies | Security report with severity rating | Critical/High severity: immediate NEXUS ESCALATION. Medium/Low: included in verification report. |

### Escalation Message Format

Every escalation to the Nexus must use this structure:

```
NexusEscalation {
  escalation_id: string
  timestamp: ISO8601
  failure_mode: FailureModeType
  severity: Critical | High | Medium | Low

  // What happened
  summary: string (1-3 sentences, human-readable)
  task_context: {task_id, task_description, phase}

  // What was tried
  attempts: [{iteration, approach, result}]

  // What the swarm needs
  question: string (specific, actionable question for the human)
  options: [{option, trade_offs}]  // if applicable

  // What happens if the human does nothing
  default_action: string (e.g., "task will be skipped", "execution will pause")
}
```

### Escalation Principles

1. **Every escalation must contain a specific question.** "Something went wrong" is not an escalation. "The authentication module requires either JWT or session-based auth — which approach aligns with your infrastructure?" is an escalation.

2. **Every escalation must include what was already tried.** The human should never have to ask "did you try X?" because X should be listed in the attempts.

3. **Escalations are batched when possible.** If multiple tasks hit escalation simultaneously, the Orchestrator consolidates them into a single briefing rather than interrupting the human multiple times.

4. **The human can respond with: resolve (answer the question), amend (change the plan), skip (deprioritize the task), or abort (stop the lifecycle).** These are the only valid escalation responses.

5. **No silent failures.** If an agent encounters any condition it cannot handle, it must signal the Orchestrator. An agent that silently swallows an error is a design defect.

## Rationale

**Why a taxonomy rather than a generic "error" category:** Different failure modes require different responses. A verification failure should be retried autonomously; a scope creep detection should not. The taxonomy encodes this knowledge into the system design, preventing the Orchestrator from treating all failures uniformly.

**Why batched escalations:** The Crystal methodology principle — reduce human cognitive load. Five sequential interruptions asking unrelated questions is far more costly to the human than one consolidated briefing with five items.

**Why four response types (resolve, amend, skip, abort):** These cover the complete decision space. The human can answer the question (resolve), change the upstream plan (amend), defer the work (skip), or halt everything (abort). Any other response can be decomposed into one of these four.

**Why a default action for no-response:** The system must be able to make progress or halt cleanly if the human is unavailable. A default action (usually "pause and wait") ensures the system does not take unintended action in the absence of human input.

## Consequences

**Easier:**
- Humans receive structured, actionable escalation messages rather than raw error dumps
- The Orchestrator has a complete decision tree for every failure mode
- Batched escalations reduce interrupt frequency

**Harder:**
- Every agent must implement the failure detection and signaling protocol
- The Orchestrator must implement escalation batching logic
- The escalation message format requires discipline — it is easier to dump a stack trace than to formulate a specific question

**Newly constrained:**
- Agents cannot silently retry indefinitely — all failures must be surfaced through the taxonomy
- The human must respond using one of four structured response types

## Alternatives Considered

**Unstructured escalation (free-text messages to human):** Lower implementation cost but transfers the interpretation burden to the human. The human would need to parse agent output, determine the failure mode, and figure out what question is being asked. Rejected for violating the Crystal principle of cognitive load reduction.

**No escalation (agents retry indefinitely or abort):** Simpler but violates the "human in the middle" principle. An agent that retries indefinitely wastes compute. An agent that aborts without informing the human wastes the work already completed. Rejected for both waste and safety reasons.

**Per-agent escalation directly to human:** Each agent contacts the human independently. Creates interrupt storms and loses the Orchestrator's ability to batch and prioritize. Rejected for cognitive overload risk.
