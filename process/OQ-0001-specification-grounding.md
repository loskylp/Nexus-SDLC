# OQ-0001: Specification Grounding — How Much Ambiguity Can the Planner Resolve Autonomously?

**Status:** Resolved
**Date:** 2026-03-12
**Resolved:** 2026-03-12
**Priority:** Critical

## Question

When the Planner agent receives a human goal specification, how much ambiguity should it resolve on its own (by making reasonable assumptions) versus how much should it escalate back to the Nexus for clarification before producing a plan?

## Resolution

**Assume-and-flag mode (Option B).** The Planner makes reasonable working assumptions for all ambiguities, produces a complete plan, and surfaces every assumption as an explicitly flagged item for human review at NEXUS CHECK. The Planner never blocks waiting for complete specification.

This resolution is grounded in a broader architectural principle: the Nexus is not a specification machine. Human input is always approximate, contextual, and subject to revision. The system must make progress on partial information and refine iteratively. See DEC-0009 (Iterative Approximation Principle) for the full formalization.

### Implications

- **GoalSpec schema:** The GoalSpec can accept informal, incomplete input. Constraints and acceptance criteria are optional, not required. The Planner fills gaps with flagged assumptions.
- **Planner prompt design:** The Planner's prompt instructs it to (a) make a reasonable assumption for any ambiguity, (b) mark each assumption with a visible flag in the plan artifact, and (c) produce a complete, actionable plan regardless of input quality.
- **NEXUS CHECK content:** The human reviews a concrete plan with flagged assumptions, rather than answering abstract questions. The review is reactive (approve/amend) rather than generative (provide missing information).
- **Iteration expectation:** The first plan is understood to be a working approximation. Plan amendments at NEXUS CHECK are normal, not failures.

## Why It Matters

This was the foundational tension of the framework. The resolution establishes that the framework's default posture is forward progress under uncertainty, not precision-seeking delay. This aligns with the Lean principle of eliminating waste (waiting is waste) and with Cockburn's observation that software development is a cooperative game played under imperfect information.

## Options That Were Considered

**Option A — Conservative Planner (ask-first):** Rejected. Blocks on human input, transfers cognitive burden to the human, and some clarification questions are premature before a plan exists. Violates the cognitive load reduction goal.

**Option B — Aggressive Planner (assume-and-flag):** Selected. The human sees a concrete proposal and reacts to specific assumptions. The risk of poor assumptions is mitigated by explicit flagging and the NEXUS CHECK gate.

**Option C — Tiered Elicitation:** Rejected as a primary mode. The Planner's ability to reliably classify ambiguities by risk is unproven. However, the assume-and-flag approach naturally accommodates this — the Planner can flag high-risk assumptions more prominently without changing the fundamental protocol.

## Previously Blocking

- DEC-0007 (Communication Standards) — GoalSpec schema can now be finalized with optional fields
- Planner agent prompt design — can now proceed with assume-and-flag instructions
