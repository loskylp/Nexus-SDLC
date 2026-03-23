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

# DEC-0030: Skills Framework

**Status:** Accepted
**Date:** 2026-03-23
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

Some agent capabilities are procedural, reusable, and not specific to a single agent. The graphic design workflow (Stitch MCP integration), bash execution discipline, traceability link maintenance, and demo script execution follow defined protocols that multiple agents might apply, and that evolve independently of any single agent's core responsibilities.

Without a formal mechanism, these capabilities were either:
1. Duplicated across agent definitions — the same procedural instructions appearing verbatim in multiple files, creating drift risk when the procedure changes
2. Embedded in agent definitions at length — inflating agent files with procedural detail that obscures the agent's core flow
3. Undocumented — assumed known, making the framework incomplete for anyone loading a single agent in isolation

The framework needed a way to express reusable procedures as first-class artifacts that agents can reference and the Nexus can load selectively.

## Decision

**A skill is a reusable procedural document in `skills/` that an agent references to execute a specific capability.**

### Skill Definition

A skill file (`skills/<name>.md`) is a standalone procedural guide for a specific capability. It:
- Describes a complete procedure that an agent can follow
- Is LLM-agnostic markdown (no platform-specific frontmatter in the source file)
- Is self-contained — readable and actionable without access to any other document
- Declares its own tool requirements if any (e.g., MCP tools, Playwright)

### Loading Protocol

Skills are loaded into agent context by the Nexus at invocation time. The Orchestrator's Routing Instruction for an invocation that requires a skill includes the skill file in its "Load these artifacts" list.

An agent definition that relies on a skill names the skill in its Responsibilities or Profile Variants section: "See skill: `graphic-design`." The Nexus loads the referenced skill file alongside the agent definition.

Skills are not automatically loaded — they are opt-in per invocation. This keeps individual agent context windows lean for invocations that do not require the skill.

### Profile Neutrality

Skills are profile-neutral by default. A skill applies at any profile unless the skill file itself declares a profile restriction in its opening section. Profile-specific variations within a skill are noted inside the skill file, not in the agent definition.

### Installation

The `install-nexus.sh` installer copies `skills/` to the target `.claude/skills/` directory alongside agents and resources. Skills are available as loadable documents in any session where Nexus is installed.

### Versioning and Evolution

Skills evolve independently of agent definitions. When a procedure changes (e.g., the Stitch MCP API changes), only the skill file needs updating — agent definitions that reference the skill by name remain unchanged.

## Rationale

**Why a dedicated `skills/` directory rather than embedding in agent files:** Embedding procedural detail in agent definitions inflates files and creates duplication when multiple agents share a procedure. A dedicated directory makes skills discoverable, maintainable, and independently updatable.

**Why opt-in loading rather than always-included:** Context windows are a finite resource. An agent invoked for a task that does not require graphic design should not carry the graphic-design skill's procedural detail. Opt-in loading keeps context lean.

**Why skills are profile-neutral by default:** Skills represent capabilities, not risk levels. A bash execution discipline procedure applies equally at Casual and Critical — the procedure itself does not change with profile. If profile-specific behavior is needed, it belongs inside the skill file where the full procedural context is available.

**Why the Orchestrator references skills in Routing Instructions:** The Orchestrator has visibility into the current task and the project profile. It is the correct agent to decide which skills are relevant for a given invocation and include them in the routing instruction.

## Consequences

- Agent definitions that rely on a skill name it explicitly: "See skill: `<name>`" — this creates a traceable dependency
- The Orchestrator Routing Instruction format includes skills in the "Load these artifacts" list when relevant
- Skills are installed alongside agents and resources by `install-nexus.sh`
- Adding a new capability to the swarm may require creating a new skill file, updating one or more agent definitions to reference it, and updating the Orchestrator's routing logic — three coordinated changes

## Current Skills

| Skill file | Capability |
|---|---|
| `skills/graphic-design.md` | UI/screen design using Stitch MCP — Designer lifecycle from generation to handoff |
| `skills/bash-execution.md` | Bash execution discipline — safe shell usage patterns for agents with command access |
| `skills/commit-discipline.md` | Git commit protocol — message format, staging rules, no-skip-hooks policy |
| `skills/traceability-links.md` | Requirement traceability — how to embed and maintain REQ-NNN links in code and tests |
| `skills/demo-script-execution.md` | Demo script execution — Nexus-facing instructions for following a Verifier-produced Demo Script |

## Alternatives Considered

**Embed skills in agent definitions:** Simpler for single-agent capabilities. Does not scale when multiple agents share a procedure — creates duplication and drift. Rejected for shared capabilities; retained as acceptable for agent-specific procedures that are unlikely to be shared.

**Single skills registry document:** A single document listing all skill procedures inline. Simpler to load one file. But a single file grows unbounded as capabilities are added, and loading it for a targeted invocation brings in all skill procedures. Rejected in favor of one file per skill.
