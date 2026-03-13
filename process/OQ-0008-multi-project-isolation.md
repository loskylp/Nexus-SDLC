# OQ-0008: Multi-Project Coordination and Context Isolation

**Status:** Open
**Date:** 2026-03-12
**Priority:** Low

## Question

Can the Nexus SDLC framework manage multiple concurrent projects? If so, how is context isolation maintained to prevent cross-contamination between projects?

## Why It Matters

If the framework is successful, a single Nexus (human) will want to run it across multiple repositories or projects simultaneously. Without context isolation, artifacts from Project A could bleed into an LLM session for Project B — leading to incorrect plans, irrelevant code, or security violations (code from a private project leaking into a public one).

## Options Being Considered

**Option A — Separate artifact trails per project:**
Each project gets its own artifact trail in its own repository, its own Methodology Manifest, and its own agent invocation history. The human loads only the artifacts from the active project into each LLM session. No shared state between projects.

*Trade-offs:* Simplest and most secure. But the human must manage multiple projects manually, and cross-project learning (e.g., "this pattern worked well in Project A, apply it to Project B") is impossible without the human explicitly transferring knowledge.

**Option B — Shared Orchestrator session with isolated artifact trails:**
The human maintains one running Orchestrator session that tracks multiple projects. The Orchestrator's routing instructions specify which project's artifacts to load for each agent invocation. Each project has its own artifact trail, but the Orchestrator holds awareness of all active projects.

*Trade-offs:* Single point of management. But the Orchestrator session becomes very large and is a cross-contamination risk if the human loads the wrong project's artifacts into an agent session.

**Option C — Defer to v2:**
Build v1 for single-project use. Address multi-project only after the single-project experience is validated.

*Trade-offs:* Fastest path to v1. Multi-project is a real need but not a v1 blocker.

## Information Needed

1. **Usage pattern:** Does the Nexus (Pablo) intend to run this across multiple projects immediately, or is single-project sufficient for the initial use case?

2. **Security requirements:** Are any target projects confidentiality-sensitive in ways that make cross-contamination a security issue rather than just a correctness issue?

## Blocking

- No blockers. This is a v2 concern unless the Nexus indicates otherwise.
