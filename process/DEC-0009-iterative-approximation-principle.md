# DEC-0009: Iterative Approximation Principle

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect, Nexus (Human)

## Context

During the initial process architecture design, the Method Architect presented the Nexus with six critical open questions simultaneously, each requesting precise answers. The Nexus responded with a foundational insight:

> "I thought we could go through the problems with a series of approximations. You should set yourself up with something — the human usually does not have all the answers and not with all the precision and unambiguity necessary."

This revealed a structural mismatch between the process architecture's implicit expectations and the reality of how human knowledge works. The framework's documentation (RATIONALE.md) already identifies human cognitive bandwidth as the primary constraint. But the open questions treated the human as a specification machine capable of delivering precise, complete answers on demand. That assumption is wrong.

This insight applies at two levels:
1. **The Nexus SDLC framework itself** — how agents interact with the human
2. **The meta-process of designing the framework** — how the Method Architect collaborates with the Nexus

## Decision

**Iterative Approximation is a first-class architectural principle of Nexus SDLC**, with the same standing as Managed Autonomy, Bounded Blast Radius, and Auditable Reasoning.

### The Principle

The system must be designed to make forward progress on partial, approximate, ambiguous input and refine iteratively. Specifically:

1. **Never block on perfect information.** When input is incomplete, make a reasonable working assumption, flag it explicitly, and proceed. The assumption becomes a testable hypothesis that the next iteration can confirm or revise.

2. **Prefer proposals over interrogations.** When the system needs human input, present a concrete proposal with flagged assumptions rather than a list of abstract questions. Humans reason better about concrete artifacts than about hypotheticals.

3. **Treat first answers as approximations.** The first version of any plan, specification, or architectural decision is understood to be provisional. The system is designed for revision, not for getting it right the first time.

4. **One question at a time when human input is needed.** When escalation is required, ask the single most important question. Accept an approximate answer. Make working assumptions for everything downstream. Revisit as understanding sharpens.

5. **Flag, do not hide, uncertainty.** Every working assumption must be visible. The Nexus must be able to see what the system assumed and override it. Hidden assumptions are the primary source of intent divergence.

### Application Across the Framework

| Component | How This Principle Applies |
|---|---|
| **Analyst** | Assumes-and-flags when requirements context is incomplete rather than blocking for clarification |
| **Requirements Gate** | Nexus reviews a concrete requirements list with flagged assumptions, not a questionnaire |
| **Escalation Protocol (DEC-0006)** | Escalations present one question, not a decision matrix |
| **Orchestrator** | When facing ambiguity in routing or prioritization, makes a provisional choice and logs it |
| **Methodologist** | Elicits project context one question at a time, accepting approximate answers |
| **Method Architect (meta-level)** | Works in iterations with the Nexus, one question at a time, provisional answers welcome |

### Relationship to Existing Principles

This principle does not replace Managed Autonomy or Bounded Blast Radius — it operates alongside them:
- **Managed Autonomy** defines *where* the human intervenes (gates)
- **Bounded Blast Radius** defines *what* agents are allowed to do (tool access)
- **Iterative Approximation** defines *how* the system handles the inherent uncertainty of human input and early-stage design

### Embedded in Agent Design

This principle is not advisory — it is implemented in every agent's behavioral instructions. Concrete implementations:
- The Analyst assumes-and-flags when requirements context is incomplete rather than blocking on questions
- The Auditor asks one specific, actionable clarification question per issue — never a decision matrix
- The Planner uses [ASSUMPTION] markers in the task plan for working assumptions not yet confirmed
- The Orchestrator escalates with one question per escalation (DEC-0006)
- The Methodologist elicits project context one question at a time, accepting approximate answers
- Every agent's Escalation Triggers section specifies what specific question to surface — not "escalate on ambiguity" but "ask: [specific question]"

## Rationale

**Theoretical grounding:**
- Cockburn's *cooperative game*: software development proceeds under imperfect information by definition. Waiting for perfect information is a losing strategy.
- Lean's *eliminate waste*: waiting is the most common form of waste. Blocking on human input when a reasonable assumption can be made is waiting.
- Shape Up's *appetite over estimate*: the human provides direction and boundaries, not specifications. The system fills in the details.
- Cynefin *probe-sense-respond*: in complex domains, you act first with a safe-to-fail probe, observe the result, and adapt. The Planner's flagged-assumption plan is exactly this.

**Practical grounding:**
- The Nexus (human) explicitly stated that they do not have all answers with the necessary precision. Designing a system that demands precise answers is designing a system that will be blocked frequently and frustrate its user.
- The first round of process architecture design demonstrated this failure mode: six simultaneous questions, each demanding a precise answer, is an interrogation that produces decision fatigue rather than decisions.

## Consequences

**Easier:**
- The system makes forward progress even when human input is sparse or approximate
- The Nexus experiences the framework as a collaborator proposing ideas, not an interrogator demanding answers
- Early-stage design can proceed without analysis paralysis — decisions are provisional and revisable
- Escalation messages are simpler (one question, not six)

**Harder:**
- The system must track which assumptions are provisional and ensure they are revisited
- Flagged assumptions add visual noise to plans — the flagging system must be designed to be informative without being overwhelming
- "Provisional" decisions can calcify if they are never revisited — the system needs a mechanism to surface aging assumptions

**Newly constrained:**
- No agent, including the Method Architect, may present more than one question to the human at a time during escalation
- Every working assumption must be flagged with a visible marker in whatever artifact it appears in

## Alternatives Considered

**Precision-first (require complete specs before proceeding):** This is the waterfall assumption. It maximizes alignment on paper but blocks progress and assumes humans can provide precise specifications upfront. Decades of SDLC experience demonstrate that they cannot. Rejected as empirically falsified.

**Pure autonomy (agents decide everything, human reviews only at the end):** Eliminates the blocking problem but at the cost of intent alignment. The Analyst making assumptions is acceptable because the Requirements Gate catches bad assumptions before decomposition. Removing that gate would make unchecked assumptions dangerous. Rejected for safety.

**Ask-first for high-risk only (tiered elicitation):** A reasonable middle ground but requires the system to reliably classify ambiguities by risk level before asking — which is itself an uncertain judgment. The assume-and-flag approach sidesteps this by flagging everything and letting the human judge risk. Rejected as unnecessarily complex for v1.
