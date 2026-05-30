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

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Nexus SDLC** is a Human-in-the-Middle (HITM) orchestration framework that coordinates a swarm of specialized autonomous agents to automate the end-to-end software development lifecycle.

The core principle is **Managed Autonomy**: a human ("The Nexus") provides high-level goals and approves critical checkpoints, while specialized agents handle decomposition, implementation, verification, and iteration autonomously.

## Architecture

Three-layer model:

- **The Nexus (Human)** — strategic control: sets goals, approves plans, validates before production
- **The Swarm (Agents)** — autonomous specialized units that decompose tasks, implement, and self-correct via feedback loops
- **Dynamic Orchestration Layer** — manages state, agent hand-offs, and unified context across the lifecycle

**Workflow:**
1. Human defines high-level goal
2. Orchestrator decomposes into atomic tasks → human approves plan
3. Swarm executes with continuous validation (tests, lint, security)
4. On failure, swarm iterates autonomously
5. Clean PR surfaced to Nexus for final merge

## Current State

This repository **is the product** — an installable framework that defines a methodology for software development using agent swarms. The agents, their roles, protocols, and workflows are the implementation. The repo contains the result of research into development methodologies and is ready to install and use for developing systems.

## Key Design Constraints

- **Safety by Design:** Agents must not execute high-risk operations without explicit Nexus approval
- **Traceable Reasoning:** All agent decisions must be logged for audit trails
- **Human checkpoints are non-negotiable** — the Nexus Check (step 3) and final PR merge (step 5) must remain human-gated

## Working Guidelines

These are universal disciplines that apply to any work in this project — exploring a problem, making a decision, producing an artifact, modifying an existing one. They apply equally to the dispatcher routing work, to a subagent executing work, and to a human reviewing the result. Adapted from [Andrej Karpathy's CLAUDE.md](https://github.com/multica-ai/andrej-karpathy-skills). They bias toward caution over speed; for trivial actions, use judgment.

### Think before acting

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations of a request exist, present them — don't pick silently.
- If a simpler path exists, name it. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### Solve the problem in front of you

**Minimum work that solves the problem. Nothing speculative.**

- No scope beyond what was asked.
- No abstractions, options, or flexibility for use cases that don't exist yet.
- No safeguards for scenarios that can't happen.
- If your output is twice as long as it needed to be, rewrite it shorter.

Test: "Would a senior practitioner say this is overdone?" If yes, cut.

### Surgical changes

**Touch only what you must. Clean up only your own mess.**

When modifying something that already exists — an artifact, a section of code, a routing instruction, a plan:

- Don't "improve" adjacent content that wasn't part of the request.
- Don't restructure what isn't broken.
- Match the existing style and tone, even if you'd write it differently.
- If you notice unrelated problems, surface them — don't fix them silently.

When your changes leave orphans (broken references, dangling pointers, unused content):

- Fix what YOUR changes broke.
- Don't remove pre-existing dead content unless explicitly asked.

Test: every changed line should trace directly to the request.

### Goal-driven execution

**Define success criteria. Loop until verified.**

Transform any task into a verifiable goal before acting:

- "Add X" → "Add X and verify it doesn't contradict existing constraints."
- "Fix Y" → "Reproduce the failure, fix it, confirm the fix from a clean starting state."
- "Reorganize Z" → "Verify all references still resolve and downstream consumers still work."

For multi-step work, state the plan with explicit verify steps:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you proceed independently. Weak criteria ("make it better") guarantee rework.

---

**These guidelines are working if:** fewer unnecessary changes in outputs, fewer rewrites due to overdoing it, and clarifying questions come before action rather than after the wrong action.
