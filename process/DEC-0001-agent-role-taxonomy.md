# DEC-0001: Agent Role Taxonomy

**Status:** Accepted (revised)
**Date:** 2026-03-12 (revised through subsequent sessions)
**Deciders:** Nexus Method Architect (initial proposal); Nexus (Human) shaped final form through conversation

## Context

The initial proposal described a 7-role taxonomy: Orchestrator, Planner, Coder, Reviewer, QA, Security, Integrator. This was written unilaterally in the first session before collaborative design began. Through conversation the user reshaped the roster substantially: "Coder" became Builder, "QA" became Verifier, "Security" became Sentinel with a different scope (live adversarial testing, not static scanning), "Reviewer" became Auditor with expanded scope (requirements validation + architectural audit), the Integrator was removed as redundant, and six new agents were added — Analyst, Architect, Designer, Scaffolder, Methodologist, DevOps, and Scribe. The final taxonomy reflects what was actually designed, not the initial proposal.

## Decision

### Tier 0 — Configuration Plane

- **Methodologist**: Assesses the project and produces the Methodology Manifest. Acts as the process conscience of the swarm throughout the lifecycle — re-activates at project start, at every Demo Sign-off (retrospective), and when trigger events occur (team change, scope shift, escalation pattern). Does not participate in execution.

### Tier 1 — Control Plane

- **Orchestrator**: The communication hub. Owns global state, task routing, escalation logic, and all inter-agent communication routing. All handoffs pass through the Orchestrator — it is not an observer of the inner loop; it is the router. Does not produce implementation artifacts, does not make strategic decisions.

### Tier 2 — Analysis and Planning Plane

- **Analyst**: Business and requirements analysis. Two sub-modes: Business Analysis (domain model, vocabulary, delivery channel) and Requirements Analysis (functional requirements, acceptance criteria). Produces the Brief and Requirements List. Uses domain language the entire swarm adopts.
- **Auditor**: Validates work for correctness. Two modes: (1) requirements audit — flags CONTRADICTION, GAP, AMBIGUOUS, UNTRACED, REGRESSION, DEFERRED; (2) architectural audit — flags UNCOVERED, INCONSISTENCY, UNGROUNDED, INADEQUATE. Produces audit reports only; does not modify artifacts.
- **Architect**: Technology selection, component boundaries, ADRs, fitness functions (dev + production sides), schema and migration strategy, resource topology for API/Service channels, spike identification and execution. The only agent that makes structural decisions. Has a direct communication path from the Builder during execution (see Composition Rules).

### Tier 2 Optional — Design and Structure Plane

- **Designer**: UX/IxD for projects with a delivery channel requiring interface design (Web, Mobile, Desktop, TUI). Optional — activated by the Methodologist when the channel warrants it.
- **Scaffolder**: Translates the Architect's component decisions into code structure — signatures, documentation contracts, TODO bodies. Performs API operation-level design (which HTTP methods, CRUD exclusions per resource) that the Architect deliberately defers. Optional — invoked when the profile is not Casual and the iteration plan contains three or more Builder tasks.

### Tier 3 — Execution Plane

- **Builder**: Implements code, configuration, and migrations against a single atomic task. Strict TDD (red/green/refactor). Has a direct communication path to the Architect for architectural questions that surface during implementation — the only agent-to-agent path that does not route through the Orchestrator.

### Tier 4 — Verification and Security Plane

- **Verifier**: Test-first verification across four layers: unit tests (Builder's responsibility, Verifier validates), integration, system, and acceptance. Performance testing where applicable. Produces Verification Report and Demo Script per verified task. Runs concurrently with Sentinel during the verification phase.
- **Sentinel**: Security audit at verification time, every cycle. Two tasks: (1) dependency review — APPROVE / CONDITIONAL / REJECT per new dependency introduced this cycle; (2) live OWASP testing against staging — black-box, adversarial. Produces Security Report. Critical or High findings block Demo Sign-off.

### Tier 4 — Delivery Plane

- **DevOps**: CI/CD pipeline, environment provisioning, deployment. Implements the CD philosophy declared in the Methodology Manifest (Continuous Deployment / Continuous Delivery / Cycle-based). Issues production readiness signal required before the Orchestrator issues a Go-Live Briefing.
- **Scribe**: Documentation transformation at release time. CD-philosophy-aware trigger. Channel-aware output: library → reference docs, API → Swagger/OpenAPI, app → user manual. Always produces release notes and changelog.

### Composition Rules

1. One role per agent invocation — no role-switching within a single session.
2. There is exactly one Orchestrator and one Methodologist active at a time.
3. Multiple Builder instances may run concurrently on independent tasks in the same iteration.
4. Verifier and Sentinel run concurrently during the verification phase.
5. The Scaffolder is invoked once per iteration, before any Builder task begins, when the trigger condition is met (not Casual + 3 or more Builder tasks).
6. The Builder→Architect direct path is the only agent-to-agent communication that does not route through the Orchestrator. The Architect notifies the Orchestrator of any ADR produced. If the Architect cannot resolve the question without a Nexus decision, it escalates via the Orchestrator.

## Rationale

**Why concern-based, not seniority-based:** Seniority hierarchies introduce subjective gradients that are difficult to operationalize in agent instructions. Concern separation creates hard boundaries enforceable through tool access profiles and input/output contracts.

**Why the Orchestrator is a hub, not a monitor:** The Orchestrator needs a complete picture of project state to route correctly, detect patterns, and prepare Nexus briefings. An inner loop it only observes creates state it cannot see — breaking its ability to enforce iteration bounds, detect thrashing, and assemble accurate Demo Sign-off briefings.

**Why the Integrator was removed:** The Integrator's functions (branch integration, release assembly) were absorbed by the Orchestrator's coordination role. A separate Integrator added a handoff step without adding value.

**Why Sentinel is separate from DevOps CI scanning:** DevOps runs automated SAST and dependency scanning in the CI pipeline — catching known CVEs and static patterns. Sentinel does what automated scanning cannot: evaluate whether a dependency is a good choice given its maintenance status and license, and probe the running system's behaviour for logic-level vulnerabilities.

**Why the Builder→Architect exception exists:** Implementation-time architectural questions require the Architect's judgment and cannot always wait for an Orchestrator routing cycle. The exception is narrow, explicit, and the Orchestrator is always notified of outcomes — so it retains complete state.

**Why Builder runs spikes was rejected (initial proposal):** Spike output is architectural — a finding that routes to either an ADR or a Planner sizing update. The investigation requires the Architect's judgment about what evidence is sufficient and what decision follows. The Builder does not have the architectural context to evaluate what it finds.

## Consequences

**Easier:**
- The Orchestrator's hub role makes its state management complete and reliable
- Concern separation makes each agent's prompt focused and testable
- The direct Builder→Architect path handles time-sensitive architectural questions without adding unnecessary process

**Harder:**
- Adding a new agent role requires updating the tier model, Orchestrator routing logic, install script, and Methodology Manifest template
- The hub model adds one routing step to every handoff compared to direct communication

**Newly constrained:**
- The Orchestrator routes all communication except the Builder→Architect path
- No swarm execution begins without a Methodology Manifest

## Alternatives Considered

**Original 7-role taxonomy:** Coder/QA/Reviewer/Security were too coarse; missed the Analyst/Architect distinction; Integrator created unnecessary overhead. Replaced through conversation.

**Merged Verifier + Sentinel:** Conflates dynamic test verification with adversarial security probing. Different tool access, different failure modes, different timing. Rejected.

**Builder runs spikes:** Initial proposal. Rejected by the user — the Architect investigates because the investigation produces an architectural finding requiring architectural judgment.
