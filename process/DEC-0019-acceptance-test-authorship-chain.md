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

# DEC-0019: Acceptance Test Authorship Chain

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

During NexusScan pilot testing, the boundary between the Analyst's specification work and the Verifier's test authorship was unclear. The Analyst wrote Given/When/Then scenarios as part of requirements. The Builder wrote unit tests. But neither the Analyst's nor the Verifier's agent files explicitly stated who authored the acceptance tests, or whether the Verifier could write test cases beyond what the Analyst had specified.

This created a gap: the Analyst's GWT scenarios were treated as notes, not as a test coverage floor. The Verifier had no explicit authority to add cases the Analyst hadn't thought of. The audit also found that neither agent file answered whether the Verifier could invent adversarial negative test cases beyond the Analyst's specification.

## Decision

**The Analyst's GWT scenarios define the minimum required test coverage. The Verifier is the sole author of executable acceptance tests. The Verifier may exceed the Analyst's floor.**

Specifically:

1. **The Analyst** drafts Given/When/Then acceptance scenarios as part of each requirement. These scenarios are part of the requirement — not supplementary notes. They define what must be proven true for the requirement to be satisfied.

2. **The Verifier** derives and writes all executable acceptance tests from the Analyst's GWT scenarios. The Builder does not write acceptance tests. The Verifier must implement every Analyst-drafted scenario as an executable test — the Analyst's scenarios are the minimum required coverage.

3. **The Verifier MAY add additional negative, boundary, and edge-case tests** beyond the Analyst's scenarios when professional judgment indicates they are needed. These cases are tagged `[VERIFIER-ADDED]` in the test name or immediately above the test function.

4. **The Auditor** flags any requirement without GWT scenarios with `[SCENARIOLESS]` — a blocking flag. The Verifier cannot derive independent tests from a requirement without scenarios, and a scenarioless requirement blocks the Verifier's work.

## Rationale

**Why Analyst writes spec-level GWT, not tests:** The Analyst operates at the requirements level. GWT scenarios are a specification bridge — they express what observable behavior satisfies the requirement in concrete terms. Writing executable tests requires knowing the interface, the technology stack, and the deployment environment. The Analyst does not know these at requirements time.

**Why Verifier writes executable tests, not Builder:** The Builder's test domain is unit tests — internal behavior at the function and class level, written before implementation (TDD). Acceptance tests validate the system through its public interface against the requirement's Definition of Done. This is a different layer of the V-Model. Mixing authorship would undermine independence — the same agent cannot implement code and write the tests that prove the code is correct without creating a conflict of interest.

**Why Verifier MAY exceed the Analyst's floor:** Test design is a professional skill. The Analyst writes scenarios from a requirements perspective. The Verifier brings testing expertise: equivalence partitioning, boundary value analysis, negative testing, adversarial scenarios. A test suite that only covers the Analyst's scenarios may miss important failure modes that a skilled tester would catch. The `[VERIFIER-ADDED]` tag preserves traceability — it distinguishes what the requirement explicitly demanded from what the Verifier added on professional judgment.

**Why `[SCENARIOLESS]` is blocking:** A Verifier that cannot trace tests to scenarios cannot produce requirement-traceable evidence. The Auditor catching this at the requirements phase prevents the Verifier from being blocked later when it cannot write traceable tests.

## Consequences

- The Analyst's GWT scenarios are mandatory for every requirement at Commercial and above; at Casual they are strongly recommended
- The Auditor's `[SCENARIOLESS]` flag blocks requirements gate passage until scenarios are provided
- Every Verifier test file traces to REQ-NNN in the test name or an immediately preceding comment
- Verifier-authored tests beyond the Analyst's spec are tagged `[VERIFIER-ADDED]` — they are still required to pass but are identified as beyond-spec coverage additions
- The Builder's "You Must Not" section explicitly prohibits writing acceptance tests

## Alternatives Considered

**Builder writes acceptance tests based on their understanding of the task:** Rejected. Creates a conflict of interest — the same agent writes the implementation and the tests that prove it correct. Undermines structural independence between implementation and verification.

**Verifier derives tests strictly from Analyst scenarios only (no additions):** Rejected. A test suite that only covers explicitly specified scenarios provides weaker assurance than one that also covers boundary and adversarial cases. Professional testing judgment must be applied at the test authorship layer, not just the specification layer.

**Analyst writes executable tests directly:** Rejected. The Analyst operates before the technology stack and interface design are finalized. Executable tests require concrete interface knowledge. A test written against a hypothetical interface must be rewritten when the interface is defined — creating duplicate maintenance work.
