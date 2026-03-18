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

# DEC-0020: Commit Policy

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

During NexusScan pilot testing, the framework had no explicit commit policy. Agents were not instructed to commit at any point, and the Nexus made a single manual commit after the Go-Live gate. This produced a working system but left the git history without per-task traceability — there was no way to identify which commit corresponded to which task's verified state.

The pilot exposed that the framework needed an explicit commit policy that assigns ownership, defines the commit point, and preserves per-task traceability in the audit trail.

## Decision

**One commit per task. The Verifier is the sole committer.**

The commit occurs only after:
1. All acceptance criteria pass (Verifier PASS)
2. The full regression suite is clean (all previously-passed task acceptance tests still pass)
3. The commit is pushed to the remote (if a remote exists)
4. If a CI pipeline is configured: the CI run triggered by the push completes green; a CI failure is treated as a regression failure and routes back to the Builder

The commit includes: the Builder's implementation, the Builder's unit tests, the Verifier's acceptance/integration/system tests, and the Demo Script.

Commit message format: `TASK-NNN: <description> — all tests pass`

**The Builder never commits.** The working tree remains uncommitted throughout the Builder session and throughout every iteration of the iterate loop. Only the final verified state is recorded in the commit history.

## Rationale

**Atomic traceability:** Every commit maps to exactly one task (TASK-NNN). The git history becomes a clean audit trail: what was built, when it was verified, and by which task specification.

**Verification-gated code:** No code enters the commit history that has not passed both task-specific acceptance tests and full regression. This is the XP principle "never break the build" applied at the task level.

**Clean iterate loop:** Uncommitted work during the Builder-Verifier iterate loop means failed iterations leave no trace in commit history. Only the final verified state is recorded.

**CI as final gate:** Pushing before monitoring CI ensures the remote pipeline is the last gate — not the Verifier's local test run. A CI failure after push is a regression failure because CI may run in a different environment or with different tooling than the Verifier's local execution.

## Consequences

- The working tree may contain uncommitted changes across multiple Builder-Verifier iterations
- If context is exhausted mid-iterate-loop, the Orchestrator's checkpoint (Behavioral Principle 8 in orchestrator.md) must capture enough state to resume without relying on commit history — the uncommitted work remains in the working tree
- The Verifier's commit includes artifacts from multiple agents (Builder code, Verifier tests, Demo Script) — all staged together
- At Casual profile, the Demo Script is optional; if not produced, the commit still includes implementation and any tests written

## Alternatives Considered

**Nexus commits manually at Go-Live:** The approach used in the NexusScan pilot. Functional but produces a single commit for the entire project — no per-task traceability, no ability to bisect regressions to a specific task.

**Builder commits after implementation, Verifier commits after verification (two commits per task):** Puts unverified Builder output into commit history. Creates ambiguity about which commit represents the verified "done" state.

**Squash at cycle end:** Loses per-task traceability — a single squash commit for a full development cycle makes it impossible to bisect which task introduced a regression.

**Builder commits to a feature branch, Verifier merges after verification:** Not rejected — a viable option for multi-developer projects requiring PR-based review. Deferred to OQ-0013 (Configurable VCS Workflow). The current policy assumes trunk-based development.
