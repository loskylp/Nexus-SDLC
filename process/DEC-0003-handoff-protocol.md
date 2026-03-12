# DEC-0003: Agent Handoff Protocol — Gated Milestone with Continuous Integration Hybrid

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

Three handoff protocols are standard in SDLC methodology:
1. **Scrum-style Backlog Handoff** — agents pull from a prioritized queue, sprint-bounded
2. **XP-style Continuous Integration Handoff** — agents push outputs to a shared stream, no batching
3. **RUP-style Gated Milestone Handoff** — work advances only through quality gates

The Nexus SDLC lifecycle (DEC-0002) has clear phase boundaries with human gates, suggesting a gated approach. But within the EXECUTE-VERIFY-ITERATE loop, agents need tight, fast feedback — suggesting continuous integration. We need a protocol that serves both needs.

## Decision

Adopt a **hybrid protocol**: Gated Milestone between lifecycle phases, Continuous Integration within the execution loop.

### Between Phases: Gated Milestone

Phase transitions (DEFINE->DECOMPOSE, DECOMPOSE->NEXUS CHECK, NEXUS CHECK->EXECUTE, etc.) are gated. The Orchestrator enforces that exit criteria for phase N are met before phase N+1 begins. Artifacts are handed off as structured messages with the following envelope:

```
HandoffEnvelope {
  source_agent: AgentID
  source_role: RoleType
  target_phase: PhaseID
  artifact_type: ArtifactType
  artifact: <structured payload>
  reasoning_trace: string
  timestamp: ISO8601
  project_context_version: int
}
```

The Orchestrator validates the envelope before routing. Invalid envelopes are rejected with a structured error.

### Within EXECUTE-VERIFY-ITERATE: Continuous Integration

Once the plan is approved and execution begins, agents operate in a tight CI-style loop:
1. Coder produces an artifact and pushes it to the shared working state
2. Verification agents (Reviewer, QA, Security) are triggered immediately
3. Failure reports are fed directly back to the Coder without Orchestrator mediation for routing (though the Orchestrator observes and logs)
4. The loop continues until verification passes or bounds are hit (DEC-0002)

This inner loop is **event-driven**, not sprint-bounded. There is no batching of verification feedback.

### Task-Level Parallelism

Within the EXECUTE phase, independent tasks (no dependency edges in the task DAG) may execute concurrently. Each independent task runs its own EXECUTE-VERIFY-ITERATE loop. The Integrator assembles results only after all concurrent loops complete.

Dependent tasks execute sequentially according to the DAG topological order.

## Rationale

**Why hybrid instead of pure gated:** Pure gated handoffs between every agent interaction would introduce unnecessary latency in the inner loop. The Coder-QA feedback cycle needs to be as tight as possible — this is the XP "10-minute build" principle applied to agentic systems. Adding gate overhead to every test-fix cycle would multiply cycle time without adding value.

**Why hybrid instead of pure CI:** The lifecycle phases (DEFINE through NEXUS MERGE) have fundamentally different actors and quality criteria. A pure CI stream would blur the distinction between "plan is ready for human review" and "code fix is ready for re-test." Phase gates preserve semantic clarity about what kind of transition is happening.

**Why event-driven inner loop:** Sprint-bounded inner loops (e.g., "batch all verification results and deliver every N minutes") add artificial latency. When a test fails, the Coder should know immediately. Reinertsen's *Principles of Product Development Flow* demonstrates that batch size is the single largest source of delay in development processes.

**Why the Orchestrator observes but does not mediate the inner loop:** The Orchestrator needs visibility for logging and loop-bound enforcement, but inserting it as a mandatory router in every Coder->QA->Coder cycle would add latency and a single point of failure. The Orchestrator intervenes only when bounds are hit or escalation is needed.

## Consequences

**Easier:**
- Inner loop speed is maximized — verification feedback reaches the Coder in the fastest possible path
- Phase transitions are explicit and auditable
- Task-level parallelism is well-defined by the DAG structure

**Harder:**
- The Orchestrator must maintain two modes of operation: phase-gate enforcement and inner-loop observation
- The HandoffEnvelope schema must be defined and validated before implementation
- Event-driven inner loops require a messaging or event system (even if in-process)

**Newly constrained:**
- Every inter-phase handoff must use the envelope format — no informal message passing
- The Orchestrator must log all inner-loop events even though it does not mediate them

## Alternatives Considered

**Pure Scrum-style Backlog:** Tasks in a prioritized queue, agents pull from the top. Clean and simple, but sprint boundaries add artificial delays and do not map well to the DEFINE->MERGE lifecycle which has hard phase semantics. Rejected for poor lifecycle fit.

**Pure RUP-style Gated Milestone:** Every handoff goes through a quality gate. Maximally rigorous but adds gate overhead to the inner Coder-QA loop, turning a 3-iteration fix cycle into a 3x-gated process. Rejected for excessive overhead in the execution phase.

**Pure XP-style CI:** All work flows through a single integration stream. Elegant for homogeneous work but loses semantic clarity about which lifecycle phase is active. Makes it harder for the Orchestrator to enforce phase-specific quality criteria. Rejected for insufficient structure.
