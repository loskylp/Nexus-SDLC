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

# DEC-0001 — Agent Role Taxonomy

**Status:** Accepted
**Date:** 2026-03-12

## Context

A multi-agent SDLC framework needs a role taxonomy that determines how work is divided, what each agent is authorized to do, and how agents relate to each other. The central design question is the organizing principle: should agents be separated by seniority (junior/senior), by lifecycle phase (design-time/build-time), or by concern?

The initial proposal sketched seven roles (Orchestrator, Planner, Coder, Reviewer, QA, Security, Integrator) organized in four tiers. Through collaborative design with the Nexus, the taxonomy was reshaped substantially: roles were renamed to reflect their actual function (Builder, Verifier, Sentinel, Auditor), the Integrator was removed as redundant, and six new agents were added to cover concerns the original seven did not address (Analyst, Architect, Designer, Scaffolder, Methodologist, DevOps, Scribe). The final taxonomy reflects thirteen agents across seven planes.

## Decision

Agents are organized by **concern**, grouped into planes that reflect what kind of work they do. Each plane operates at a different level of abstraction in the lifecycle.

### Configuration Plane

- **Methodologist** — Assesses the project and produces the Methodology Manifest. Acts as the process conscience of the swarm throughout the lifecycle: re-activates at project start, at every Demo Sign-off (retrospective), and on trigger events (team change, scope shift, escalation pattern). Does not participate in execution.

### Control Plane

- **Orchestrator** — The communication hub. Owns global state, task routing, escalation logic, and all inter-agent communication routing. All handoffs pass through the Orchestrator. Does not produce implementation artifacts or make strategic decisions.

### Analysis and Planning Plane

- **Analyst** — Business and requirements analysis. Two sub-modes: Business Analysis (domain model, vocabulary, delivery channel) and Requirements Analysis (functional requirements, acceptance criteria). Produces the Brief and Requirements List.
- **Auditor** — Validates work for correctness. Two modes: requirements audit (flags CONTRADICTION, GAP, AMBIGUOUS, UNTRACED, REGRESSION, DEFERRED) and architectural audit (flags UNCOVERED, INCONSISTENCY, UNGROUNDED, INADEQUATE). Produces audit reports only; does not modify artifacts.
- **Architect** — Technology selection, component boundaries, ADRs, fitness functions (dev + production sides), schema and migration strategy, spike identification and execution. The only agent that makes structural decisions. Has a direct communication path from the Builder during execution.

### Design and Structure Plane (optional)

- **Designer** — UX/IxD for projects with a delivery channel requiring interface design (Web, Mobile, Desktop, TUI). Activated by the Methodologist when the channel warrants it.
- **Scaffolder** — Translates the Architect's component decisions into code structure before Builder work begins. Performs API operation-level design that the Architect deliberately defers. Invoked when the profile is not Casual and the iteration plan contains three or more Builder tasks.

### Execution Plane

- **Builder** — Implements code, configuration, and migrations against a single atomic task. Strict TDD (red/green/refactor). Has a direct communication path to the Architect for architectural questions during implementation — the only agent-to-agent communication that does not route through the Orchestrator.

### Verification and Security Plane

- **Verifier** — Test-first verification across four layers: integration, system, acceptance, and performance. Produces Verification Reports and Demo Scripts. Runs concurrently with Sentinel during the verification phase.
- **Sentinel** — Security audit at verification time, every cycle (Commercial and above). Two tasks: dependency review (APPROVE / CONDITIONAL / REJECT per new dependency) and live OWASP testing against staging. Produces Security Report. Critical or High findings block Demo Sign-off.

### Delivery Plane

- **DevOps** — CI/CD pipeline, environment provisioning, deployment. Implements the CD philosophy declared in the Methodology Manifest.
- **Scribe** — Documentation transformation at release time. Channel-aware output (library -> reference docs, API -> Swagger/OpenAPI, app -> user manual). Always produces release notes and changelog.

### Composition Rules

1. One role per agent invocation — no role-switching within a single session.
2. There is exactly one Orchestrator and one Methodologist active at a time.
3. Multiple Builder instances may run concurrently on independent tasks in the same iteration.
4. Verifier and Sentinel run concurrently during the verification phase.
5. The Scaffolder is invoked once per iteration, before any Builder task begins, when the trigger condition is met (not Casual + three or more Builder tasks).
6. The Builder-to-Architect direct path is the only agent-to-agent communication that does not route through the Orchestrator. The Architect notifies the Orchestrator of any ADR produced. If the Architect cannot resolve the question without a Nexus decision, it escalates via the Orchestrator.

## Reasoning

**Concern-based separation over seniority-based:** Seniority hierarchies (junior agent, senior agent, lead agent) introduce subjective gradients that are difficult to operationalize in agent instructions. An LLM playing "senior developer" has no stable behavioral meaning. Concern separation creates hard boundaries enforceable through tool access profiles and input/output contracts. The Builder writes code; the Verifier writes tests; the Auditor writes reports. These are crisp, non-overlapping scopes.

**Why the Orchestrator is a hub, not a monitor:** Early designs considered an inner loop where the Verifier would feed failure reports directly back to the Builder without Orchestrator mediation. This was rejected because the Orchestrator's state management function depends on seeing all handoffs. An inner loop it only observes creates state it cannot see — breaking its ability to enforce iteration bounds, detect thrashing, and assemble accurate Demo Sign-off briefings.

**Why the Integrator was removed:** The Integrator's original responsibilities (branch integration, release assembly, merge summary) were examined and found to overlap entirely with the Orchestrator's coordination role and DevOps's deployment role. A separate Integrator added a handoff step without adding value. It was folded into the Orchestrator.

**Why Sentinel is separate from DevOps CI scanning:** DevOps runs automated SAST and dependency scanning in the CI pipeline — catching known CVEs and static patterns. Sentinel does what automated scanning cannot: evaluate whether a dependency is a good choice given its maintenance status and license, and probe the running system's behavior for logic-level vulnerabilities. These are different threat surfaces requiring different tool access and different expertise.

**Why the Builder-to-Architect exception exists:** Implementation-time architectural questions require the Architect's judgment and cannot always wait for an Orchestrator routing cycle. The exception is narrow (architectural questions only), explicit (documented in both agent files), and the Orchestrator is always notified of outcomes — so it retains complete state.

**Why thirteen agents and not fewer:** Each agent was added when collaborative design revealed a concern that no existing agent covered. The Analyst emerged because requirements elicitation is distinct from requirements validation (Auditor). The Architect emerged because structural decisions are distinct from task planning (Planner). The Methodologist emerged because swarm configuration is distinct from swarm execution (Orchestrator). No agent exists without a demonstrated gap that justified its creation.

## Alternatives Considered

**Original 7-role taxonomy (Orchestrator, Planner, Coder, Reviewer, QA, Security, Integrator):** Too coarse — missed the Analyst/Architect distinction, used generic names (Coder, QA) that provided no behavioral guidance, and included an Integrator with no distinct value. Replaced through iterative collaboration.

**Merged Verifier + Sentinel:** Would conflate dynamic test verification with adversarial security probing. Different tool access (Verifier runs test suites; Sentinel probes a running system), different failure modes (test failures vs. security findings), different timing (Verifier runs per-task; Sentinel runs per-cycle). Rejected for concern conflation.

**Builder runs spikes:** Initially proposed because the Builder already has command execution permissions. Rejected because spike output is architectural — the investigation produces a finding that requires architectural judgment to evaluate and route. The Architect was the correct owner.

**Flat roster (no planes):** All agents listed without grouping. Rejected because the planes communicate the lifecycle flow: Configuration produces the Manifest, Control routes work, Analysis and Planning produce the plan, Execution implements, Verification validates, Delivery ships. The grouping is informative, not bureaucratic.

## Consequences

- The Orchestrator's hub role makes its state management complete and reliable — it sees every handoff.
- Concern separation makes each agent's prompt focused and independently testable against its contract.
- The direct Builder-to-Architect path handles time-sensitive architectural questions without adding unnecessary process.
- Adding a new agent role requires updating the plane model, Orchestrator routing logic, and Methodology Manifest template.
- The hub model adds one routing step to every handoff compared to direct communication — accepted as the cost of state completeness.
- No swarm execution begins without a Methodology Manifest (produced by the Methodologist).
