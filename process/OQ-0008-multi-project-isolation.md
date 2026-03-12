# OQ-0008: Multi-Project Coordination and Context Isolation

**Status:** Open
**Date:** 2026-03-12
**Priority:** Low

## Question

Can the Nexus SDLC framework manage multiple concurrent projects? If so, how is context isolation maintained to prevent cross-contamination between projects?

## Why It Matters

The RATIONALE.md lists this as an open problem. If the framework is successful, a single Nexus (human) will want to run it across multiple repositories or projects simultaneously. Without context isolation, agent decisions in Project A could be influenced by context from Project B, leading to incorrect plans, irrelevant code, or security violations (code from a private project leaking into a public one).

## Options Being Considered

**Option A — Separate framework instances per project:**
Each project gets its own Orchestrator, its own Project Context, and its own agent invocations. No shared state between instances.

*Trade-offs:* Simplest and most secure. But the human must manage multiple instances manually, and cross-project learning (e.g., "this pattern worked well in Project A, apply it to Project B") is impossible.

**Option B — Shared Orchestrator with isolated Project Contexts:**
A single Orchestrator manages multiple projects, maintaining separate Project Context objects for each. Agents are invoked with project-scoped context slices.

*Trade-offs:* Single point of management. But the Orchestrator becomes more complex and is a cross-contamination risk if context slicing has bugs.

**Option C — Defer to v2:**
Build v1 for single-project use. Address multi-project only after the single-project experience is validated.

*Trade-offs:* Fastest path to v1. Multi-project is a real need but not a v1 blocker.

## Information Needed

1. **Usage pattern:** Does the Nexus (Pablo) intend to run this across multiple projects immediately, or is single-project sufficient for the initial use case?

2. **Security requirements:** Are any target projects confidentiality-sensitive in ways that make cross-contamination a security issue rather than just a correctness issue?

## Blocking

- No blockers. This is a v2 concern unless the Nexus indicates otherwise.
