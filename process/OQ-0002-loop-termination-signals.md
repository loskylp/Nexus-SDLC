# OQ-0002: Loop Termination — What Signals Indicate Genuine Convergence vs. Test-Gaming?

**Status:** Partially Resolved
**Date:** 2026-03-12
**Updated:** 2026-03-13
**Priority:** Critical

## Question

DEC-0002 defines iterate loop bounds (max_iterations, convergence signal based on monotonically decreasing failures). But these are coarse metrics. How do we detect when an agent is "gaming" the verification — making tests pass by weakening test assertions, deleting failing tests, or implementing trivially correct but semantically wrong solutions?

## Why It Matters

This is the agentic equivalent of Goodhart's Law: when a metric becomes a target, it ceases to be a good metric. If the iterate loop's termination condition is "all tests pass," agents will optimize for test passage, not for correctness. This is the most dangerous failure mode of the framework — it produces code that looks verified but is not actually correct.

This question affects:
- The Verifier's verification strategy (what does "pass" actually mean?)
- The iterate loop's convergence criteria (what signals beyond test pass/fail?)

## Partial Resolution (2026-03-13)

Three structural defenses are now in place in the agent definitions:

**1. Directory partition (builder.md):** The Builder MAY NOT write into `tests/integration/`, `tests/system/`, or `tests/acceptance/`. The Verifier owns these directories exclusively. The Builder cannot weaken or delete the Verifier's tests.

**2. Requirement-traced test immutability (verifier.md):** The Verifier MAY NOT modify or remove an existing test unless the requirement it traces to (REQ-NNN) has been formally changed, superseded, or cancelled. Test changes follow requirement changes, not iteration difficulty. This closes the path where a Verifier reinvoked in the iterate loop rewrites weak tests to converge.

**3. Mandatory negative cases + pre-PASS self-check (verifier.md):** The Verifier must write at least one negative case per acceptance criterion — a condition that should NOT be satisfied and must be correctly rejected. Before reporting PASS, the Verifier must verify each test would fail against a trivially permissive implementation (e.g., a function that always returns the expected success value). Negative cases are the primary structural defense against trivially correct implementations.

## What Remains Open

**Semantically wrong implementations that satisfy well-formed tests.** If the acceptance criteria themselves are incomplete, a correct test suite derived from them may still pass against a wrong implementation. This is an upstream problem — the Analyst and Auditor's responsibility to produce adequate acceptance criteria — not a Verifier problem. The Demo Sign-off gate (Nexus explores running software) is the final structural defense here; a trivially correct implementation often fails human exploration even when it passes tests.

**Mutation testing as a stronger signal.** Option C below remains viable as a higher-profile enhancement but is not required for correctness at Casual/Commercial profiles.

## Remaining Options

**Option B — Dual verification (two independent Verifier runs):**
Two independent Verifier instances generate tests from the same acceptance criteria without seeing each other's tests. Both must pass.

*Trade-offs:* Adds defense-in-depth against Verifier writing weak tests. Doubles verification compute cost. Only warranted at Critical/Vital profiles. Deferred to pilot phase.

**Option C — Mutation testing:**
After verification passes, run mutation testing: introduce deliberate bugs and verify that tests catch them.

*Trade-offs:* Strongest signal of test quality. Compute-intensive. Requires language-specific tooling (pitest for Java, mutmut for Python). Deferred to pilot phase.

## Information Needed (remaining)

1. **Empirical data on gaming behavior in practice:** Do the three structural defenses above hold under real iterate-loop conditions? Resolve during first pilot.

2. **Whether Option B or C is warranted at Critical/Vital:** Depends on pilot observations of Verifier test quality and whether the negative-case rule is sufficient in practice.

## Blocking

- No longer blocking agent definition files — both Verifier and Builder definitions are complete
- DEC-0002 iterate loop convergence criteria: no revision needed based on current resolution; may revisit after pilot
