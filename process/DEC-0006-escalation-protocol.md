# DEC-0006: Escalation Protocol and Failure Mode Taxonomy

**Status:** Accepted (revised — programmatic schema replaced by markdown format)
**Date:** 2026-03-12 (revised)
**Deciders:** Nexus Method Architect

## Context

The initial proposal described a NexusEscalation structured schema with typed fields (escalation_id, severity, attempts array, options array, default_action). This was a programmatic concept designed for a software runtime. With no software runtime (OQ-0005), all escalations are markdown Nexus Briefings prepared by the Orchestrator and delivered to the Nexus.

## Decision

### Failure Mode Taxonomy

| Failure Mode | Description | Detection | Response |
|---|---|---|---|
| Verification Failure | Tests fail, lint errors, type errors | Verifier reports | Autonomous retry within iterate bounds |
| Convergence Failure | Iterate loop exhausted without passing | Orchestrator detects max_iterations or non-decreasing failures | NEXUS ESCALATION |
| Plan Infeasibility | Agent determines a task cannot be completed as specified | Builder raises infeasibility signal | Orchestrator validates, then NEXUS ESCALATION |
| Ambiguity Detection | Agent encounters ambiguity requiring domain knowledge | Any agent flags | Orchestrator surfaces to Nexus with one specific question (DEC-0009) |
| Scope Creep Detection | Task requires changes outside authorized scope | Builder detects | NEXUS ESCALATION with scope expansion request |
| Security Alert | Sentinel finds Critical or High severity findings | Sentinel Security Report | Demo Sign-off is blocked; findings listed in Demo Sign-off Briefing |
| Dependency Rejection | Sentinel REJECTs a new dependency | Sentinel Dependency Review | Escalate to Nexus — Builder does not adopt without Nexus decision |
| Architectural Conflict | Two agents produce conflicting artifacts | Orchestrator detects | Hold conflicting artifact; NEXUS ESCALATION before proceeding |
| Incident (Production) | Bug reported against production | Nexus reports | Orchestrator asks Nexus to choose track (next-cycle or hotfix) if not stated; route to Planner |
| Escalation Pattern | Same failure mode appears 3+ times | Orchestrator detects | Flag to Methodologist as potential process issue |

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

Every escalation received and every Nexus decision is recorded as an ESC-NNN entry in the Orchestrator's escalation log:

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

## Rationale

**Why markdown over programmatic schema:** Consistent with OQ-0005 (no runtime). The Nexus reads escalations directly — human-readable markdown is more useful than a JSON object.

**Why security findings are not standalone escalations:** Sentinel findings that block Demo Sign-off are included in the Demo Sign-off Briefing, keeping gate decisions consolidated. The Nexus sees the full cycle picture at one gate rather than receiving separate escalation interrupts.

**Why escalation patterns flag to the Methodologist:** Three occurrences of the same failure mode signals a process issue, not just a task issue. The Methodologist is the appropriate agent to diagnose and reconfigure the process — the Orchestrator should not make process changes unilaterally.

## Consequences

**Easier:**
- Nexus receives structured, actionable escalation messages
- The Orchestrator has a complete taxonomy for every failure mode
- The escalation log provides an audit trail of all significant decisions

**Harder:**
- The Orchestrator must implement the escalation log diligently — every escalation received and decision made
- Escalation quality depends on the Orchestrator formulating a specific question, which requires judgment

**Newly constrained:**
- Agents cannot silently retry indefinitely — all failures must be surfaced through the taxonomy
- The Orchestrator routes production incidents by asking the Nexus to choose the track before creating tasks

## Alternatives Considered

**NexusEscalation structured schema (initial proposal):** Typed object with attempt arrays and option lists. Replaced with markdown Nexus Briefing format — same information, human-readable, no runtime required.

**Per-agent escalation directly to the Nexus:** Each agent contacts the Nexus independently. Creates interrupt storms and loses the Orchestrator's ability to batch, contextualize, and prioritize. Rejected.
