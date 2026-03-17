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

# DEC-0003 — Agent Communication and Routing Protocol

**Status:** Accepted
**Date:** 2026-03-12

## Context

A multi-agent system needs explicit rules for how agents communicate: who talks to whom, in what format, and through what mechanism. Two related questions were initially tracked as separate decisions (handoff protocol and communication standards) but answer one underlying question: how does information flow through the swarm?

The initial proposal described a "hybrid protocol" with gated milestones between phases and a Continuous Integration-style inner loop where the Verifier would feed failure reports directly back to the Builder without Orchestrator mediation. The inter-agent messages were typed schemas (HandoffEnvelope, GoalSpec, TaskPlan) designed for a software runtime.

Both assumptions were wrong. Through conversation, the Nexus established that all communication routes through the Orchestrator as a hub — it is not an observer of an inner loop. When OQ-0005 resolved (no software runtime), the typed schemas were replaced by structured markdown artifacts stored in the project repository. One direct communication exception was added later: the Builder may raise architectural questions directly to the Architect during implementation.

## Decision

### Hub Model

The Orchestrator is the communication hub. All agent handoffs, routing instructions, and escalations pass through it. Agents do not communicate directly with each other, with one declared exception.

**Routing Instruction format (Orchestrator to Agent):**

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

### The Builder-to-Architect Direct Path

During implementation, the Builder may raise architectural questions directly to the Architect without routing through the Orchestrator. This is the only direct agent-to-agent path in the swarm.

Protocol:
1. Builder raises the architectural question to the Architect with enough context to decide
2. Architect resolves the question and notifies the Orchestrator of any new ADR produced
3. If the Architect cannot resolve without a Nexus decision, the Architect escalates via the Orchestrator — not directly to the Nexus

Scope: Implementation-time architectural questions only — decisions the Architect is the authoritative resolver for and that the Builder cannot proceed without. Not a general bypass for any inter-agent communication.

### Structured Markdown Artifacts

All agent communication uses structured markdown files stored in the project repository. Structure comes from section headers, tables, and declared output formats defined in each agent's Output Contract. There is no programmatic schema, no serialization layer, and no runtime.

### Artifact Types

The swarm communicates through named artifact types, each with a conventional file location:

| Artifact | Producer | Location |
|---|---|---|
| Methodology Manifest | Methodologist | `manifest/manifest-vN.md` |
| Brief | Analyst | `analyst/brief.md` |
| Requirements List | Analyst | `analyst/requirements.md` |
| Audit Report | Auditor | `auditor/audit-report-[phase]-[N].md` |
| Architecture Artifacts | Architect | `architect/architecture-overview.md` or `architect/ADR-NNNN-*.md`, `architect/baseline.md` |
| Task Plan | Planner | `planner/task-plan.md` |
| Release Map | Planner | `planner/release-map.md` |
| Scaffold Manifest | Scaffolder | `scaffolder/scaffold-manifest.md` |
| Handoff Note | Builder | Per-task inline output |
| Verification Report | Verifier | `verifier/verification-report-[task].md` |
| Demo Script | Verifier | `verifier/demo-script-[task].md` |
| Security Report | Sentinel | `sentinel/security-report-[cycle].md` |
| Spike Finding | Architect | `spikes/SPIKE-NNN/finding.md` |
| Nexus Briefings | Orchestrator | Per-gate structured output |
| Escalation Log | Orchestrator | `orchestrator/escalation-log.md` |
| Release Documentation | Scribe | `docs/vN.N.N/`, `CHANGELOG.md`, `RELEASE-NOTES-vN.N.N.md` |

### Parallelism

Within an execution cycle, independent tasks (no dependency edges in the task DAG) may be routed to concurrent Builder sessions. The Planner's dependency graph determines what is independent. The Orchestrator manages concurrent routing and collects completions.

During the verification cycle, the Verifier and Sentinel run concurrently. The Orchestrator collects both reports before preparing the Demo Sign-off Briefing.

### Ubiquitous Language

The swarm uses a shared vocabulary throughout all artifacts and communication:

| Term | Definition |
|---|---|
| Nexus | The human-in-the-middle; strategic decision-maker |
| Swarm | The collective of all active agents in a lifecycle |
| Orchestrator | Hub agent: routes work, manages state, prepares gate briefings |
| Builder | Implementation agent |
| Verifier | Test and verification agent |
| Sentinel | Security audit agent |
| Methodologist | Process configuration agent; produces the Methodology Manifest |
| Requirements Gate | Human gate — approves requirements before decomposition |
| Architecture Gate | Human gate — approves architectural approach after Auditor review |
| Plan Gate | Human gate — approves task plan before execution |
| Demo Sign-off | Per-cycle gate — approves delivered features; authorizes next cycle |
| Go-Live | Release gate — decoupled from Demo Sign-off; three trigger modes |
| Spike | Architect-run investigation to resolve a high-risk unknown |
| Profile | Project stakes classification: Casual / Commercial / Critical / Vital |
| Artifact Weight | Documentation rigor: Sketch / Draft / Blueprint / Spec |
| Fitness Function | Dual-use architectural specification: dev check + production monitoring |
| Thrashing | Non-decreasing failure count across consecutive iteration cycles |
| Blast Radius | The scope of potential damage from an agent action |

All agents use these terms exclusively. Synonyms (Coder for Builder, QA for Verifier, Sprint for Cycle) are not used within the framework.

## Reasoning

**Why hub model over CI inner loop:** The Orchestrator's state management function depends on seeing all handoffs. An inner loop it only observes creates state it cannot see — breaking its ability to enforce iteration bounds, detect thrashing, and assemble accurate Demo Sign-off briefings. The feedback path (verification failures to Builder fix) is already fast within a single cycle; Orchestrator routing adds minimal overhead compared to the value of maintaining complete state. The XP principle of fast feedback was sound, but the implementation (bypassing the hub) was wrong.

**Why markdown over programmatic schemas:** No software runtime exists (OQ-0005). Programmatic schemas require parsers, validators, and serialization infrastructure. Markdown is human-readable, version-controllable, and directly loadable into LLM prompts. Structure comes from section headers and declared output formats, not from typed schemas.

**Why the Builder-to-Architect exception:** Implementation-time architectural questions require the Architect's judgment and cannot always wait for a routing cycle. The exception is narrow — only for architectural questions the Architect is authoritative to resolve — and the Orchestrator is always notified of outcomes. State remains complete.

**Why named artifact types without schemas:** Even without programmatic validation, naming artifact types provides the inter-agent coordination structure. An agent that knows it receives a "Verification Report" knows what sections to look for. Named types also establish the ubiquitous language — shared terminology that prevents misunderstanding across agents and between agents and the Nexus.

**Why ubiquitous language:** DDD's insight applied to an agent swarm. Shared terminology prevents entire categories of misunderstanding. The renaming from the initial proposal (Coder to Builder, QA to Verifier, Security to Sentinel, Nexus Merge to Demo Sign-off + Go-Live) was itself an application of this principle — each name was chosen to describe what the agent actually does.

**Why conventional file locations:** Discoverability. Any agent (or human) can navigate the artifact trail without being told where to look. Convention over configuration eliminates a class of routing errors.

## Alternatives Considered

**CI inner loop (initial proposal):** Verification agents feed failure reports directly to the Builder. Replaced because it broke the Orchestrator's ability to maintain complete state.

**All communication through Orchestrator with no exceptions:** Fully consistent but creates unnecessary overhead for implementation-time architectural questions. The Builder-to-Architect path is time-sensitive and the Architect is the authoritative resolver. Rejected for one specific case.

**HandoffEnvelope schema (initial proposal):** A programmatic typed structure for all inter-agent messages. Replaced when OQ-0005 resolved to no software runtime.

**Typed schemas with runtime validation (GoalSpec, TaskPlan, etc.):** Designed for a software runtime that does not exist. Replaced with structured markdown — same information, human-readable, no infrastructure required.

**Natural language conversation between agents (ChatDev style):** Unstructured, unvalidatable, produces ambiguous handoffs. Rejected for reliability.

## Consequences

- The Orchestrator has a complete picture of all agent activity at all times.
- Hub routing makes the interaction log complete and auditable.
- Every handoff goes through one more routing step than direct communication would require — accepted as the cost of state completeness.
- Agents do not communicate directly with each other except the Builder-to-Architect path.
- Without schema validation, malformed artifacts are discovered when the receiving agent reads them, not when they are written — acceptable for v1; a future runtime could add validation.
- All agent definitions use the ubiquitous language terms — deviations break the inter-agent contract.
- Artifact locations are conventional, not arbitrary — agents write to declared locations.
