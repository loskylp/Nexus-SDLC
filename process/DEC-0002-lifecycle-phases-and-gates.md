# DEC-0002: Lifecycle Phases and Human Gates

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

The RATIONALE.md defines a seven-phase lifecycle: DEFINE, DECOMPOSE, NEXUS CHECK, EXECUTE, VERIFY, INTEGRATE, NEXUS MERGE — with an ITERATE loop feeding back from VERIFY/EXECUTE to DECOMPOSE. The CLAUDE.md establishes that the Nexus Check (step 3) and final PR merge (step 5) are non-negotiable human gates.

We need to formalize: (a) the exact entry and exit criteria for each phase, (b) the handoff contracts between phases, (c) whether additional human gates are needed beyond the two mandated ones, and (d) how the iterate loop is bounded.

## Decision

Adopt the seven-phase lifecycle with the following formalization:

### Phase Definitions

| Phase | Entry Condition | Actor(s) | Exit Artifact | Exit Condition |
|---|---|---|---|---|
| **DEFINE** | Human initiates | Nexus (Human) | Goal Specification (goal, constraints, acceptance criteria) | Goal spec is non-empty and parseable by Planner |
| **DECOMPOSE** | Goal spec received | Orchestrator + Planner | Task Plan (atomic tasks, dependency DAG, risk flags, effort estimates) | Plan passes structural validation (no circular deps, all tasks have acceptance criteria) |
| **NEXUS CHECK** | Task Plan ready | Nexus (Human) | Approved Plan (with optional amendments) | Explicit human approval signal. No timeout-based auto-approval. |
| **EXECUTE** | Approved Plan | Coder(s) | Implementation artifacts per task | All atomic tasks have produced artifacts |
| **VERIFY** | Implementation artifacts exist | Reviewer + QA + Security | Verification Report (pass/fail per criterion, structured failure details) | All verification agents have reported |
| **ITERATE** | Verification failures exist AND iteration budget remaining | Coder + QA (autonomous) | Corrected artifacts | All verification criteria pass OR iteration budget exhausted |
| **INTEGRATE** | All verifications pass | Integrator | Clean branch + PR summary + diff summary | Branch builds, all tests pass, no merge conflicts |
| **NEXUS MERGE** | PR ready | Nexus (Human) | Merged PR | Explicit human merge action |

### Human Gates

Two mandatory, one conditional:

1. **NEXUS CHECK** (mandatory): Human reviews and approves the decomposed plan before any code execution begins. This is the intent-alignment gate.

2. **NEXUS MERGE** (mandatory): Human reviews the final PR, diff summary, and verification reports before merging. This is the quality-and-trust gate.

3. **NEXUS ESCALATION** (conditional): Triggered when the iterate loop exhausts its budget without converging. The Orchestrator surfaces: what was attempted, why it failed, and a specific question for the human. The human may amend the plan, relax constraints, or abort. This is the graceful-degradation gate.

### Iterate Loop Bounds

The iterate loop is bounded by two configurable parameters:
- **max_iterations**: Maximum number of code-verify cycles per atomic task (default: 3)
- **convergence_signal**: If the verification failure count is not monotonically decreasing over 2 consecutive iterations, escalate immediately (the swarm is thrashing, not converging)

When either bound is hit, the Orchestrator triggers NEXUS ESCALATION.

## Rationale

**Why only two mandatory gates:** The RATIONALE.md explicitly identifies human cognitive bandwidth as the primary constraint (Goldratt's Theory of Constraints). Every mandatory gate consumes human attention. The two chosen gates are the minimum set that preserves intent alignment (pre-execution) and output quality (pre-merge). Adding more gates (e.g., mid-execution progress reviews) would reduce the value proposition of the framework.

**Why the iterate loop needs bounds:** Unbounded retry loops are the most dangerous failure mode in agentic systems. An agent that fails and retries indefinitely can consume unlimited compute, drift from the original intent, and produce increasingly incoherent artifacts. The convergence signal (non-decreasing failure count) catches thrashing early.

**Why NEXUS ESCALATION is conditional, not mandatory:** Most iterate cycles should converge autonomously — that is the core value of the framework. Making escalation mandatory would turn every test failure into a human-gated event, defeating the purpose.

**Why no timeout-based auto-approval at NEXUS CHECK:** Auto-approval under time pressure is a safety anti-pattern. If the human is unavailable, the swarm waits. The cost of waiting is lower than the cost of executing a misaligned plan.

## Consequences

**Easier:**
- Human cognitive load is minimized — only two mandatory decision points per lifecycle
- Iterate loop has clear termination semantics, preventing runaway compute
- Each phase has explicit entry/exit criteria, making orchestrator logic deterministic

**Harder:**
- The human must provide high-quality goal specifications upfront, since the next human interaction is after decomposition
- If the plan is approved but turns out to be wrong mid-execution, there is no mandatory checkpoint to catch it — the system relies on verification failures and escalation
- Configuring max_iterations and convergence signals requires empirical tuning per project type

**Newly constrained:**
- The Orchestrator must implement a state machine that tracks phase transitions and enforces gate conditions
- Every phase transition must be logged for audit trail purposes

## Alternatives Considered

**More human gates (review after each task):** Provides tighter control but at extreme cognitive cost. A plan with 20 atomic tasks would require 20 human reviews. This collapses back to a code-review workflow with extra steps. Rejected for defeating the managed-autonomy principle.

**Fewer human gates (only NEXUS MERGE):** Removes the pre-execution alignment check. The swarm could spend significant compute implementing a misunderstood plan before the human sees any output. Rejected for violating the "verifiable intent" design goal.

**Time-bounded iterate loop (wall-clock timeout):** Simpler than iteration counting but doesn't account for task complexity. A complex refactoring might legitimately take longer. Rejected for being a poor proxy for convergence.

**No convergence signal (just max_iterations):** Simpler but allows the swarm to thrash for all N iterations before escalating. The convergence signal provides early termination when thrashing is detected. Rejected for waste tolerance.
