# DEC-0003: Agent Communication and Handoff Protocol

**Status:** Accepted (revised — initial CI hybrid proposal replaced)
**Date:** 2026-03-12 (revised through conversation)
**Deciders:** Nexus Method Architect (initial proposal); Nexus (Human) corrected to hub model

## Context

The initial proposal described a "hybrid protocol": gated milestones between lifecycle phases, plus a Continuous Integration-style inner loop where verification agents would feed failure reports directly back to the Builder without Orchestrator mediation. The HandoffEnvelope was a programmatic schema designed for a software runtime. Both assumptions were wrong.

Through conversation, the user established the correct model: all inter-agent communication routes through the Orchestrator — it is the hub, not an observer of an inner loop. One exception was added later: the Builder may raise architectural questions directly to the Architect during implementation. The HandoffEnvelope schema was eliminated when OQ-0005 resolved to no software runtime.

## Decision

### Hub Model

The Orchestrator is the communication hub. All agent handoffs, routing instructions, and escalations pass through it. Agents do not communicate directly with each other, with one declared exception.

**Routing Instruction format (Orchestrator → Agent):**

```markdown
# Routing Instruction
**To:** [Agent name]
**Phase:** [Current lifecycle phase]
**Task:** [What the agent should do]
**Load these artifacts:** [List of artifact files to include as context]
**Produce:** [Expected output artifact]
**Iteration:** [N of max N if in iterate loop]
**Return to:** Orchestrator when complete
```

### The Builder → Architect Direct Path

During implementation, the Builder may raise architectural questions directly to the Architect without routing through the Orchestrator. This is the only direct agent-to-agent path in the swarm.

Protocol:
1. Builder raises the architectural question to the Architect with enough context to decide
2. Architect resolves the question and notifies the Orchestrator of any new ADR produced
3. If the Architect cannot resolve without a Nexus decision, the Architect escalates via the Orchestrator to the Nexus — not directly

**Scope of this exception:** Implementation-time architectural questions only — decisions that the Architect is the authoritative resolver for and that the Builder cannot proceed without. Not a general bypass for any inter-agent communication.

### Artifact Format

All artifacts are markdown files stored in the project repository. There is no programmatic schema, no serialization layer, and no runtime. Routing instructions are structured markdown documents. Agent outputs are markdown files written to declared conventional locations.

### Parallelism

Within an execution cycle, independent tasks (no dependency edges in the task DAG) may be routed to concurrent Builder sessions. The Planner's dependency graph determines what is independent. The Orchestrator manages concurrent routing and collects completions.

During the verification cycle, the Verifier and Sentinel run concurrently. The Orchestrator collects both reports before preparing the Demo Sign-off Briefing.

## Rationale

**Why hub model over CI inner loop:** The Orchestrator's state management function depends on seeing all handoffs. An inner loop it only observes creates state it cannot see — breaking its ability to enforce iteration bounds, detect thrashing, and assemble accurate Demo Sign-off briefings. The Orchestrator is not overhead; it is the agent that maintains coherence across the swarm.

**Why markdown over programmatic schemas:** No software runtime exists (OQ-0005). Programmatic schemas require parsers, validators, and serialization infrastructure. Markdown is human-readable, version-controllable, and directly loadable into LLM prompts. Structure comes from section headers and declared output formats, not from typed schemas.

**Why the Builder→Architect exception:** Implementation-time architectural questions require the Architect's judgment and cannot always wait for a routing cycle. The exception is narrow — only for architectural questions the Architect is authoritative to resolve — and the Orchestrator is always notified of outcomes. State remains complete.

**Why the CI inner loop proposal was wrong:** It was designed to mirror XP's fast-feedback model. But the feedback path (verification failures → Builder fix) is already fast within a single cycle — the Orchestrator routing adds minimal overhead compared to the value of maintaining complete state. The principle was sound (fast feedback) but the implementation was wrong (bypassing the hub breaks state).

## Consequences

**Easier:**
- The Orchestrator has a complete picture of all agent activity at all times
- Hub routing makes the interaction log complete and auditable
- Concurrent execution is well-defined — the Orchestrator batches completions

**Harder:**
- Every handoff goes through one more routing step than direct communication would require
- The Orchestrator becomes a potential bottleneck (mitigated by the fact that routing is a lightweight operation)

**Newly constrained:**
- Agents do not communicate directly with each other except the Builder→Architect path
- The Builder→Architect exception requires the Architect to always notify the Orchestrator of outcomes

## Alternatives Considered

**CI inner loop (initial proposal):** Verification agents feed back directly to the Builder. Replaced because it broke the Orchestrator's ability to maintain complete state.

**All communication through Orchestrator with no exceptions:** Fully consistent but creates unnecessary overhead for the specific case of implementation-time architectural questions. The Builder→Architect path is time-sensitive and the Architect is the authoritative resolver. Rejected for that specific case.

**HandoffEnvelope schema (initial proposal):** A programmatic typed structure for all inter-agent messages. Replaced when OQ-0005 resolved to no software runtime.
