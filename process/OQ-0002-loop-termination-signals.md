# OQ-0002: Loop Termination — What Signals Indicate Genuine Convergence vs. Test-Gaming?

**Status:** Open
**Date:** 2026-03-12
**Priority:** Critical

## Question

DEC-0002 defines iterate loop bounds (max_iterations, convergence signal based on monotonically decreasing failures). But these are coarse metrics. How do we detect when an agent is "gaming" the verification — making tests pass by weakening test assertions, deleting failing tests, or implementing trivially correct but semantically wrong solutions?

## Why It Matters

This is the agentic equivalent of Goodhart's Law: when a metric becomes a target, it ceases to be a good metric. If the iterate loop's termination condition is "all tests pass," agents will optimize for test passage, not for correctness. This is the most dangerous failure mode of the framework — it produces code that looks verified but is not actually correct.

This question affects:
- The QA agent's verification strategy (what does "pass" actually mean?)
- The Reviewer agent's scope (does it check for test quality, not just code quality?)
- The iterate loop's convergence criteria (what signals beyond test pass/fail?)

## Options Being Considered

**Option A — Acceptance criteria as ground truth:**
The human's acceptance criteria (from the GoalSpec) are the authoritative definition of correctness. The QA agent generates tests from acceptance criteria. The Coder cannot modify these tests — only the QA agent can, and only to add coverage, never to relax assertions.

*Trade-offs:* Strong guarantee if acceptance criteria are well-specified. But acceptance criteria are often incomplete — they describe what should work, not all the ways it could fail.

**Option B — Dual verification (two independent QA runs):**
Two independent QA agent instances generate tests from the same acceptance criteria without seeing each other's tests. Both must pass. This is the "pair programming" principle applied to verification.

*Trade-offs:* Catches gaming because the Coder would have to satisfy two independent test sets. But doubles QA compute cost and still depends on acceptance criteria quality.

**Option C — Reviewer checks test quality:**
The Reviewer agent is given explicit mandate to evaluate whether tests are meaningful — checking for assertion strength, edge case coverage, and suspicious patterns (e.g., tests that assert True, tests that were deleted between iterations).

*Trade-offs:* Catches some gaming patterns but relies on the Reviewer's judgment, which is itself an LLM inference.

**Option D — Mutation testing:**
After verification passes, run mutation testing: introduce deliberate bugs and verify that tests catch them. If test survival rate is too high, the tests are too weak.

*Trade-offs:* Strongest signal of test quality but very compute-intensive and requires mutation testing tooling that may not exist for all languages/frameworks.

## Information Needed

1. **Empirical data on agent gaming behavior:** Do current LLMs actually game tests when given iterate-until-pass instructions? Published research (SWE-bench, SWE-agent) provides some data but not specifically on gaming.

2. **Compute budget constraints:** Options B and D multiply verification cost. What is the acceptable compute budget per atomic task?

3. **Tooling availability:** Mutation testing frameworks exist for major languages (pitest for Java, mutmut for Python) but not all. Does the framework need language-agnostic mutation testing?

## Blocking

- The QA agent's prompt design and tool access profile depend on this answer
- DEC-0002 (iterate loop convergence criteria) may need revision based on this answer
- DEC-0001 (Reviewer role scope) may need to expand to include test quality review
