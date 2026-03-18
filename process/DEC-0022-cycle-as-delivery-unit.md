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

# DEC-0022: Cycle as Unit of Delivery

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

The framework described an outer loop (Execution → Verification → Demo Sign-off → next cycle) but never defined what a "cycle" was as a bounded unit of work. Without this definition:

- The Orchestrator had no rule for when to stop executing tasks and move to Demo Sign-off
- The Planner had no guidance on whether to plan one cycle's worth of work or the entire project
- The Nexus had no way to know in advance how much work would be presented at Demo Sign-off
- Scope creep within a cycle had no natural containment mechanism

Traditional methodologies handle this with a timebox (Scrum Sprint) or a milestone (RUP Iteration). A timebox is artificial for a solo-Nexus workflow with variable task complexity. A scope-based boundary is more natural.

## Decision

**A cycle is a Planner-defined subset of the backlog that forms a coherent, demonstrable increment.**

The Planner declares which tasks belong to the current cycle when producing or updating the Task Plan. This declaration is made explicit — the Task Plan groups tasks into cycles, each of which ends with a Demo Sign-off.

The Orchestrator executes only the tasks in the current cycle before preparing the Demo Sign-off Briefing. Tasks planned for future cycles are not touched until the current cycle closes.

The cycle boundary is reviewed and approved by the Nexus at the Plan Gate. The Nexus may adjust the boundary — moving tasks in or out — before approving.

The Methodology Manifest declares the cycle scope model in its Iteration Model section.

## Rationale

**Why scope-based rather than timebox-based:** The Nexus SDLC operates with LLM agents that complete tasks at variable speed. A timebox imposes artificial urgency on a process where the bottleneck is not time but quality — the Verifier's acceptance criteria are the natural completion signal, not a calendar. A scope-based cycle ends when the declared work is verified, not when a clock expires.

**Why the Planner declares the boundary:** The Planner is the agent with the complete view of the task graph, dependency constraints, risk/value scores, and the cut line. It is the correct agent to group tasks into coherent increments. The Orchestrator's role is to execute within the declared boundary, not to define it.

**Why the Nexus approves the boundary at Plan Gate:** The cycle boundary is a scope decision. Scope decisions require human approval under the Human-in-the-Middle principle. The Plan Gate is the natural moment for this — after the Planner has produced the full task plan, the Nexus sees the proposed grouping and can adjust it.

## Consequences

- The Task Plan format explicitly declares which tasks belong to which cycle
- The Methodology Manifest Iteration Model section includes a `Cycle scope` field
- The Orchestrator stops routing Builder tasks when the current cycle's tasks are all verified PASS, then prepares the Demo Sign-off Briefing
- Future-cycle tasks remain in the plan but are not routed until the current cycle closes and a new cycle is declared
- The Planner may plan multiple cycles at once (the Release Map) while executing one cycle at a time

## Alternatives Considered

**Timebox-based cycle (Scrum Sprint):** Artificial for LLM-agent workflows where task duration is variable. A fixed timebox would require the Planner to estimate time, which is not how the framework operates (tasks are scored on risk and value, not time). Rejected.

**No defined cycle — execute all tasks then Demo Sign-off:** Makes planning incremental delivery impossible. The Nexus would see everything at once with no intermediate feedback point. Inconsistent with Agile's preference for early and frequent delivery of value. Rejected.
