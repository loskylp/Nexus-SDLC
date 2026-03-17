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

# OQ-0005: Technology Stack Selection

**Status:** Resolved
**Date:** 2026-03-12
**Resolved:** 2026-03-12
**Priority:** Critical

## Question

What programming language, runtime, LLM provider(s), state management approach, and infrastructure should the Nexus SDLC framework be built on?

## Resolution

**There is no software to build.** The deliverable is the agent definition files themselves — structured prompt documents that define each agent's role, behavior, constraints, and handoff contracts. Users instantiate the swarm by loading the relevant agent definition files into whatever LLM interface they prefer (web-based AI chat, Claude Code, API calls, custom tooling).

This is not "no code for v1 and code later." This is a fundamental reframing: the framework IS the agent definitions. The system of agents is the files with the agent definitions.

### Resolution Details

| Dimension | Answer |
|---|---|
| **Programming language** | None. The deliverable is structured text (markdown/prompt files). |
| **Runtime** | The user's chosen LLM interface. The framework is LLM-agnostic. |
| **LLM provider** | Any. Agent definitions are written to be portable across providers. |
| **State management** | A structured markdown document (the Project Context) that is maintained as a living artifact and passed between agent invocations. See revised DEC-0004. |
| **Deployment model** | File distribution. Users download/clone the agent definition files and load them into their preferred LLM. |
| **Extensibility** | Users create new agent definition files following the canonical format (DEC-0010). |

### Implications

This resolution fundamentally changes several prior decisions:
- **DEC-0004** (Project Context): Revised from in-memory object to structured markdown document
- **DEC-0005** (Tool Access Tiering): Tiers become declared behavioral constraints in agent prompts, not enforced ACLs
- **OQ-0006** (Orchestrator Implementation): Resolved — the Orchestrator is an agent definition file, not a software component
- **OQ-0003** (Context Window Strategy): Reframed — context management is now a human responsibility (choosing what to include in the conversation) guided by the Orchestrator agent's instructions

## Why It Matters

This resolution eliminates the entire infrastructure question and reframes the project's output. Instead of building a software system that orchestrates agents, we are writing the playbook that tells agents how to orchestrate themselves. The human remains the integrating layer — loading the right agent at the right time, passing the Project Context between conversations, and acting on escalation instructions.

This is maximally aligned with the project's current state (design phase, no implementation) and with the Managed Autonomy principle (the human remains the strategic control center). It is also the most honest answer to "what is the minimum viable framework?" — the framework is the knowledge of how to coordinate agents, encoded in the agent definitions.

## Previously Blocking

- All implementation work — **reframed**: implementation is now writing agent definition files, not code
- OQ-0003 (Context Window) — **reframed**: context management is human-guided, not infrastructure
- DEC-0004 (Project Context) — **revised**: now a markdown document
- OQ-0006 (Orchestrator) — **resolved**: Orchestrator is an agent definition file
