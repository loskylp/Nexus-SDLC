<!--
Copyright 2026 Pablo Ochendrowitsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# DEC-0006 — Escalation Protocol and Failure Mode Taxonomy

**Status:** Accepted
**Date:** 2026-03-12

## Context

Agents fail. Tests do not pass. Requirements are ambiguous. Plans turn out to be infeasible. Dependencies get rejected by Sentinel. Production incidents arrive. A multi-agent system without a defined escalation protocol will either silently swallow failures or interrupt the human with unstructured noise.

The initial proposal described a NexusEscalation structured schema with typed fields (escalation_id, severity, attempts array, options array, default_action). This was designed for a software runtime. When OQ-0005 resolved (no runtime), all escalations became markdown Nexus Briefings prepared by the Orchestrator. The failure mode taxonomy was developed through collaborative design as each failure scenario was identified and its appropriate response defined.

## Decision

### Failure Mode Taxonomy

| Failure Mode | Detection | Response |
|---|---|---|
| **Verification Failure** — tests fail, lint errors, type errors | Verifier reports | Autonomous retry within iterate bounds |
| **Convergence Failure** — iterate loop exhausted without passing | Orchestrator detects max_iterations or non-decreasing failures | Nexus escalation |
| **Plan Infeasibility** — agent determines a task cannot be completed as specified | Builder raises infeasibility signal | Orchestrator validates, then Nexus escalation |
| **Ambiguity Detection** — agent encounters ambiguity requiring domain knowledge | Any agent flags | Orchestrator surfaces to Nexus with one specific question (DEC-0009) |
| **Scope Creep Detection** — task requires changes outside authorized scope | Builder detects | Nexus escalation with scope expansion request |
| **Security Alert** — Sentinel finds Critical or High severity findings | Sentinel Security Report | Demo Sign-off is blocked; findings listed in Demo Sign-off Briefing |
| **Dependency Rejection** — Sentinel REJECTs a new dependency | Sentinel Dependency Review | Escalate to Nexus — Builder does not adopt without Nexus decision |
| **Architectural Conflict** — two agents produce conflicting artifacts | Orchestrator detects | Hold conflicting artifact; Nexus escalation before proceeding |
| **Incident (Production)** — bug reported against production | Nexus reports | Orchestrator asks Nexus to choose track (next-cycle or hotfix) if not stated; route to Planner |
| **Escalation Pattern** — same failure mode appears 3+ times | Orchestrator detects | Flag to Methodologist as potential process issue |

### Escalation Format

The Orchestrator uses the Nexus Briefing format for all escalations:

```markdown
# Nexus Briefing — [Escalation description]
**Project:** [Name] | **Date:** [date] | **Phase:** [phase]

## Status
[One sentence: where we are and what is blocked]

## What Happened
[Compact summary of what led to this escalation — including what was already tried]

## What Needs Your Decision
[The specific approval, amendment, or answer required — one question, per DEC-0009]

## Risks or Concerns
[Anything the Nexus should be aware of even if no action is needed now]

## To Proceed
[Exact instruction: "Approve to continue", "Choose track: next-cycle or hotfix", etc.]
```

### Escalation Log

Every escalation received and every Nexus decision is recorded as an ESC-NNN entry in `orchestrator/escalation-log.md`:

```markdown
## ESC-NNN — [date]
**From:** [Agent] | **Type:** [failure mode]
**Description:** [What happened]
**Decision:** [How it was resolved: routed / amended / escalated to Nexus / aborted]
**Outcome:** [What happened as a result]
```

### Escalation Principles

1. **Every escalation must contain a specific question.** Per DEC-0009: one question, not a decision matrix.
2. **Every escalation must include what was already tried.** The Nexus should not need to ask "did you try X?"
3. **No silent failures.** An agent that cannot complete its task must signal the Orchestrator.
4. **Production incidents require identification.** If an incident description is too vague to identify the violated requirement, the Orchestrator surfaces one specific question before creating any BUG task.
5. **Escalation log is part of the traceability trail.** It is preserved for the lifetime of the project.

### Production Incident Routing

Two tracks, declared by the Nexus:

**Next-cycle track:** The bug is recorded as BUG-NNN and enters the next Planner cycle. Standard verification applies.

**Hotfix track:** BUG-NNN routes directly through Verifier (reproduce) -> Builder (fix) -> Verifier (verify) -> DevOps (deploy) -> Nexus sign-off. No Plan Gate. The Planner is notified to record the closure.

The Orchestrator does not choose the track — the Nexus does. If the Nexus does not state a track, the Orchestrator asks.

## Reasoning

**Why markdown over programmatic schema:** Consistent with OQ-0005 (no runtime). The Nexus reads escalations directly — human-readable markdown is more useful than a JSON object that requires a renderer.

**Why security findings are not standalone escalations:** Sentinel findings that block Demo Sign-off are included in the Demo Sign-off Briefing, keeping gate decisions consolidated. The Nexus sees the full cycle picture at one gate rather than receiving separate escalation interrupts during the cycle.

**Why escalation patterns flag to the Methodologist:** Three occurrences of the same failure mode signals a process issue, not just a task issue. The Methodologist is the appropriate agent to diagnose and reconfigure the process. The Orchestrator should not make process changes unilaterally — it routes, it does not redesign.

**Why one question per escalation (DEC-0009):** The Iterative Approximation principle applies to escalations as strongly as anywhere else. A decision matrix with five options and three tradeoffs creates decision fatigue. One specific question with enough context to answer it respects the Nexus's cognitive bandwidth.

**Why the Orchestrator decides "route for resolution" vs. "escalate to Nexus":** Not every failure needs human attention. A verification failure within iterate bounds is autonomous. A convergence failure after exhausting iterations needs the human. The taxonomy makes this boundary explicit for every failure mode so the Orchestrator's judgment is guided, not ad hoc.

## Alternatives Considered

**NexusEscalation structured schema (initial proposal):** Typed object with attempt arrays and option lists. Replaced with markdown Nexus Briefing format — same information, human-readable, no runtime required.

**Per-agent escalation directly to the Nexus:** Each agent contacts the Nexus independently. Creates interrupt storms and loses the Orchestrator's ability to batch, contextualize, and prioritize. The Nexus would receive raw, unfiltered noise from multiple agents. Rejected for cognitive load.

**No taxonomy — handle failures ad hoc:** Leaves the Orchestrator without guidance on which failures are autonomous and which require human attention. Every failure becomes a judgment call. Rejected for inconsistency and unpredictability.

**Severity-based escalation (Critical/High/Medium/Low):** Generic severity levels that do not encode what the appropriate response is. Knowing a failure is "High severity" does not tell the Orchestrator whether to retry, escalate, or block the gate. The failure mode taxonomy is more useful because it maps each mode to a specific response. Rejected for insufficient actionability.

## Consequences

- The Nexus receives structured, actionable escalation messages with one question each.
- The Orchestrator has a complete taxonomy covering every identified failure mode.
- The escalation log provides an audit trail of all significant decisions.
- The Orchestrator must implement the escalation log diligently — every escalation received and decision made must be recorded.
- Agents cannot silently retry indefinitely — all failures must be surfaced through the taxonomy.
- The Orchestrator routes production incidents by asking the Nexus to choose the track before creating tasks — it does not assume.
