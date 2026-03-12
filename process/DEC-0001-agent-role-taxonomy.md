# DEC-0001: Agent Role Taxonomy

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

The RATIONALE.md defines seven agent roles (Orchestrator, Planner, Coder, Reviewer, QA, Security, Integrator) organized by concern rather than seniority. Before implementation, we need to formalize this taxonomy with precise boundaries, determine whether roles map 1:1 to agent instances or can be composed, and decide how role definitions evolve as the project matures.

Multi-agent SDLC systems (MetaGPT, ChatDev) have demonstrated that role clarity is the single strongest predictor of swarm coherence. Ambiguous role boundaries lead to duplicated work, contradictory outputs, and agents that silently expand scope.

## Decision

Adopt the seven-role taxonomy from RATIONALE.md as the **canonical agent role set** with the following formalization:

### Tier 1 — Control Plane (never produces artifacts)
- **Orchestrator**: Owns global state, task routing, escalation logic, and loop termination. It is the only agent that communicates directly with the Nexus (human). All other agents interact with the human indirectly through the Orchestrator's escalation protocol.

### Tier 2 — Planning Plane (produces specifications, not code)
- **Planner**: Decomposes goals into atomic tasks with dependency graphs, risk annotations, and acceptance criteria. Produces the plan artifact that goes through Nexus Check.

### Tier 3 — Execution Plane (produces artifacts)
- **Coder**: Implements code, configuration, and migrations against a single atomic task. Has read/write access to the working branch only.
- **Integrator**: Assembles outputs from multiple Coder runs into a coherent branch. Resolves merge conflicts. Produces the PR summary artifact.

### Tier 4 — Verification Plane (read-only, produces reports)
- **Reviewer**: Architectural consistency, code style, design pattern adherence. Read-only access.
- **QA**: Test generation, test execution, coverage analysis, structured failure reports. Read-only except for test files.
- **Security**: SAST, dependency audit, secret detection, vulnerability scanning. Read-only access.

### Composition Rules
1. A single LLM invocation may fulfill exactly one role at a time. Role-switching within a single invocation is prohibited to maintain audit trail clarity.
2. Multiple instances of Tier 3 and Tier 4 agents may run concurrently on independent tasks.
3. There is exactly one Orchestrator instance per project lifecycle.
4. The Planner role may be re-invoked during the Iterate phase when task re-decomposition is needed, but this must be logged as a plan amendment.

## Rationale

**Why concern-based, not seniority-based:** Seniority hierarchies (junior/senior coder) introduce subjective quality gradients that are difficult to operationalize in agent prompts. Concern separation (planning vs. coding vs. verification) creates hard boundaries that can be enforced through tool access profiles and input/output contracts.

**Why the Orchestrator never writes code:** This is the separation-of-concerns equivalent of not letting the project manager commit to main. The Orchestrator's job is routing and state management. If it also produces artifacts, its objectivity in evaluating whether work is complete is compromised.

**Why QA gets write access to test files:** QA must be able to generate test files. Restricting QA to pure read-only would require the Coder to write all tests, collapsing the TDD verification loop (XP principle) into a single agent — which defeats the purpose of the pair-programming-style verification pattern.

**Why one role per invocation:** Audit trail integrity. If a single invocation acts as both Coder and Reviewer, the reasoning trace conflates generation and evaluation, making post-hoc analysis unreliable.

## Consequences

**Easier:**
- Tool access profiles become simple per-tier ACLs
- Audit trails are unambiguous — every artifact is attributable to exactly one role
- Concurrent execution of Tier 3/4 agents is straightforward since roles have clear boundaries
- Agent prompt engineering is simplified — each prompt targets a single concern

**Harder:**
- Cross-cutting concerns (e.g., a security issue that requires a code change) require multi-step handoffs: Security flags it, Orchestrator routes it, Coder fixes it, Security re-verifies
- The taxonomy may need extension for project types not yet considered (e.g., infrastructure-as-code, data pipeline, ML model training)
- Strict one-role-per-invocation increases the total number of LLM calls

**Newly constrained:**
- Adding a new agent role requires updating the tier model, tool access profiles, and the Orchestrator's routing logic simultaneously

## Alternatives Considered

**Flat role list (no tiers):** Simpler to define but provides no structural guidance on which agents can interact, what tool access each gets, or how to reason about concurrent execution. Rejected for lack of architectural guidance.

**Seniority-based roles (Junior Coder, Senior Coder, Lead):** Mirrors human team structure but introduces subjective quality gradients. How does a "Senior Coder" agent differ from a "Junior" one in practice? Through prompt engineering differences that are fragile and hard to validate. Rejected for operational ambiguity.

**Merged Reviewer + QA role:** Reduces agent count but conflates static analysis (pattern adherence) with dynamic analysis (test execution). These require different tool access, different evaluation criteria, and different failure modes. Rejected for concern conflation.

**Dynamic role creation (agents spawn new roles as needed):** Maximally flexible but makes the system's behavior unpredictable and the audit trail uninterpretable. Rejected for violating the traceability design goal.
