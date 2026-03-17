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

# DEC-0014: The Methodologist Role

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect, Nexus (Human)

## Context

DEC-0001 defined the agent role taxonomy with the Orchestrator as the control-plane agent. But the Orchestrator's job is to run the swarm during execution — routing tasks, managing state, handling escalation. There is a prior question that must be answered before the Orchestrator can operate: what swarm configuration is appropriate for this project?

The swarm configuration is not one-size-fits-all (DEC-0008, DEC-0013). A Casual/Sketch project needs fewer agents and lighter artifacts than a Critical/Blueprint project. Someone must assess the project and decide. That someone is the Methodologist.

## Decision

The **Methodologist** is a distinct agent role that runs once, before the swarm is configured. It is not part of the swarm — it designs the swarm.

### Purpose

The Methodologist assesses the project across three dimensions and produces a Methodology Manifest that configures the swarm for that project.

### Intake Dimensions

1. **Team:** How many Nexus humans are involved? Working independently or coordinated? What is their domain expertise?

2. **Nature:** What kind of project is this? Proof of concept, internal tool, shipped product, regulated system? What happens if it fails? (Maps to Profile per DEC-0013.)

3. **Scale:** Rough user count, expected lifetime, anticipated size of the codebase or system.

### Output: The Methodology Manifest

The Methodologist produces a single document — the **Methodology Manifest** — whose own weight matches the selected profile:

- Casual project: the Manifest is a Sketch (a few paragraphs)
- Commercial project: the Manifest is a Draft (a structured short document)
- Critical project: the Manifest is a Blueprint (a comprehensive configuration document)
- Vital project: the Manifest is a Spec (a formal, auditable configuration)

The Manifest declares:

1. **Selected Profile and Artifact Weight** — "This is a [Profile] project. The swarm will operate in [ArtifactWeight] mode."

2. **Active Agents** — Which agents from the taxonomy are active for this project. A Casual project might activate only Planner, Builder, and Verifier. A Critical project activates the full roster including Analyst, Auditor, Sentinel, and Architect.

3. **Documentation Requirements Per Agent** — How much each active agent produces. In Sketch mode, the Planner produces a task list. In Blueprint mode, the Planner produces a formal task breakdown with requirement traceability, dependency graphs, and risk annotations.

4. **Agent Combination Rules** — Whether agents may be combined for this project. In a Casual project, the Verifier might perform a light security check rather than invoking Sentinel separately. In a Critical project, Verifier and Sentinel are always separate.

5. **Human Gate Configuration** — Which gates are active. Casual projects may use only Demo Sign-off (skip Requirements Gate and Plan Gate for speed). Critical and Vital projects use all gates.

6. **CD Philosophy** — Continuous Deployment, Continuous Delivery, or Cycle-based (determines Go-Live trigger).

7. **max_iterations** — Iterate loop bound for the execution/verification cycle.

### Continuous Lifecycle Role

The Methodologist is not a bootstrap agent that runs once and is retired. It is a standing role that re-activates throughout the project lifetime. It is the process conscience of the swarm.

**Invocation triggers:**

| Trigger | What it signals |
|---|---|
| Project start | Initial configuration — produces first Manifest |
| Demo Sign-off | Orchestrator hands control to Methodologist with one question: "Is there anything you want to change for the next iteration?" If yes, Methodologist reconfigures before next cycle. |
| End of each major phase | Process retrospective — is the current profile still appropriate? |
| Team composition change | More or fewer humans changes coordination needs |
| Scope or criticality shift | A PoC gaining users; a tool becoming customer-facing |
| Escalation pattern | Repeated swarm failures may indicate process misconfiguration |
| Human request | The Nexus senses something is off |

Each re-invocation may produce an updated Manifest. Manifests are versioned: `manifest-v1.md`, `manifest-v2.md`. The Orchestrator always operates from the latest Manifest. The full version history is preserved as part of the project traceability trail.

A project may graduate across profiles over its lifetime — starting as Casual/Sketch and evolving to Commercial/Draft or Critical/Blueprint as it gains team members, users, and stakes. The Methodologist detects and proposes these transitions; the Nexus approves them.

What a "retrospective" means in practice varies by profile and is intentionally left open — see OQ-0009.

### Separation from the Orchestrator

| Concern | Methodologist | Orchestrator |
|---|---|---|
| **When** | Project start + recurring triggers | Continuously during execution |
| **What it decides** | Which agents, how much documentation, which gates | Which task next, which agent to invoke, when to escalate |
| **Input** | Human intake answers + accumulated project history | Current Methodology Manifest + project artifacts |
| **Output** | Versioned Methodology Manifest | Lifecycle state, handoff instructions, escalation messages |
| **Invoked** | At start and on triggers throughout project life | Continuously throughout the lifecycle |

The Orchestrator receives the current Methodology Manifest as its configuration. It does not question the Manifest — it operates within it. When the Manifest changes, the Orchestrator adapts.

## Rationale

**Why a separate agent, not a section of the Orchestrator prompt:** Separation of concerns. The Orchestrator's prompt is already complex — it manages phase transitions, task routing, escalation, and context assembly. Adding project assessment and swarm configuration to the same prompt would overload it and blur the boundary between "what process to use" and "how to execute the process." The Methodologist has a different input (human intake answers), a different output (Manifest), and a different lifecycle (runs once per trigger, not continuously).

**Why the Manifest weight matches the profile:** Self-consistency. If you are assessing a Casual project, a 10-page methodology document is itself over-engineered. If you are assessing a Vital project, a one-paragraph configuration is recklessly light. The Methodologist practices what it preaches.

**Why intake questions, not automated assessment:** The three dimensions (team, nature, scale) require information the system cannot infer from a codebase. How many people are involved? What happens if it fails? These are human knowledge. The Methodologist elicits this per DEC-0009 — asking one question at a time, accepting approximate answers, making provisional assumptions for the rest.

**Why the Methodologist can combine agent roles:** Right-sizing. A solo developer running a PoC does not need seven separate agent invocations. Combining Verifier with light security checks, or having the Planner also perform light analysis, reduces operational friction without sacrificing the concern-separation principle for projects where the stakes do not justify the overhead.

**Why the Methodologist re-activates at Demo Sign-off:** The end of a working cycle is the best moment to reconsider the process. The Orchestrator hands off with one specific question — "is there anything you want to change?" — which keeps the retrospective lightweight. The Methodologist only produces an updated Manifest if the answer is yes.

## Consequences

**Easier:**
- The swarm is right-sized for every project from the start
- The Orchestrator has a clear configuration to operate from, not implicit assumptions
- The human gets explicit confirmation of what process will be used before any work begins
- Adding the Methodologist to DEC-0001's taxonomy is clean — it occupies Tier 0 (Configuration) that runs before the Control Plane

**Harder:**
- The Methodologist agent definition must encode enough methodology knowledge to make good profile assessments
- If the project's nature changes mid-lifecycle, the human must recognize this and re-invoke the Methodologist
- The Manifest format must be defined per artifact weight (four variants)

**Newly constrained:**
- No swarm execution begins without a Methodology Manifest
- The Orchestrator's agent definition must include instructions for reading and following the Manifest
- After every Demo Sign-off, the Orchestrator must hand control to the Methodologist before starting the next cycle

## Alternatives Considered

**Embed assessment in the Orchestrator:** Simpler (one less agent) but conflates two distinct concerns. The Orchestrator would need to both assess the project and execute the process, making its prompt unwieldy and its responsibilities ambiguous. Rejected for concern conflation.

**Let the human choose the profile directly:** Faster but assumes the human knows the framework's profile system. The Methodologist's value is translating natural project descriptions ("it's a small internal tool, just me") into framework configuration. Rejected for poor user experience.

**Static profiles with no Methodologist (pick a template):** The human selects from four pre-built swarm templates. Simple but rigid — real projects often need mixed configurations (e.g., Blueprint-weight security artifacts on an otherwise Draft-weight project). The Methodologist can handle these nuances. Rejected for inflexibility.
