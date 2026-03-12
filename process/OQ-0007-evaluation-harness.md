# OQ-0007: Evaluation Harness Design — How to Measure Framework Effectiveness

**Status:** Open
**Date:** 2026-03-12
**Priority:** Medium

## Question

How should the Nexus SDLC framework be evaluated? What metrics, benchmarks, and test scenarios should be used to determine whether the framework is working correctly and delivering value?

## Why It Matters

The RATIONALE.md identifies four evaluation dimensions: SWE-bench performance, internal regression suites, DORA metrics, and human satisfaction scores. But these are outcome measures — they tell you whether the framework worked, not why it did or did not. We need an evaluation strategy that supports iterative improvement.

Without an evaluation harness, development will be driven by intuition rather than evidence, and there will be no way to detect regressions when changes are made to agent prompts, orchestration logic, or handoff protocols.

## Options Being Considered

**Option A — SWE-bench as primary benchmark:**
Run the framework against SWE-bench issues and measure resolution rate, comparing to published baselines (SWE-agent, etc.).

*Trade-offs:* Well-established benchmark with published baselines. But SWE-bench measures single-issue resolution, not full lifecycle quality. It does not test plan quality, human interaction design, or multi-task coordination.

**Option B — Custom scenario suite:**
Design a suite of 20-50 scenarios that exercise the full lifecycle: goal specification, decomposition, execution, verification, iteration, and integration. Scenarios range from simple (add a feature to a todo app) to complex (refactor a multi-service API).

*Trade-offs:* Tests what we actually care about. But expensive to create and maintain, and results are not comparable to published benchmarks.

**Option C — Dogfooding (self-application):**
Use the Nexus SDLC framework to build the Nexus SDLC framework. This tests the full lifecycle in the most realistic way.

*Trade-offs:* Maximally realistic. But creates a bootstrap problem (the framework must exist before it can build itself) and feedback loops where bugs in the framework affect the framework's own development.

**Option D — Layered evaluation:**
Layer 1: Unit tests for deterministic components (state machine, schema validation). Layer 2: Integration tests for agent handoffs using fixed inputs. Layer 3: End-to-end tests on a small set of curated scenarios. Layer 4: SWE-bench for comparison to published baselines.

*Trade-offs:* Most comprehensive but highest implementation effort. Requires maintaining four layers of tests.

## Information Needed

1. **Evaluation priority:** Is it more important to have benchmarks for external credibility (publish SWE-bench numbers) or internal confidence (know the system works)?

2. **Scenario availability:** Are there existing real-world tasks/issues in Pablo's projects that could serve as evaluation scenarios?

3. **Budget for evaluation compute:** Running SWE-bench or custom scenarios against LLM APIs has significant cost implications.

## Blocking

- No direct blockers, but the evaluation harness should be designed before or alongside v1 implementation to avoid building something that cannot be measured
