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

# Nexus SDLC — Process Architecture Index

Last updated: 2026-03-13

---

## Decisions

| ID | Title | Status | Summary |
|---|---|---|---|
| [DEC-0001](DEC-0001-agent-role-taxonomy.md) | Agent Role Taxonomy | **Accepted** | Thirteen agents across seven planes (Configuration, Control, Analysis/Planning, Design/Structure, Execution, Verification/Security, Delivery). Concern-based separation. Orchestrator as communication hub. Builder-to-Architect direct path as sole exception. |
| [DEC-0002](DEC-0002-lifecycle-phases-and-gates.md) | Lifecycle Phases and Human Gates | **Accepted** | Five phases (Ingestion, Decomposition, Execution, Verification, Go-Live) with five human gates (Requirements, Architecture, Plan, Demo Sign-off, Go-Live). Three CD philosophy models. Retrospective embedded at Demo Sign-off. |
| [DEC-0003](DEC-0003-agent-communication-protocol.md) | Agent Communication and Routing Protocol | **Accepted** | Hub model — all communication routes through the Orchestrator. Structured markdown artifacts at conventional file locations. Ubiquitous language. Builder-to-Architect direct path. Merges former DEC-0003 (Handoff Protocol) and DEC-0007 (Communication Standards). |
| [DEC-0004](DEC-0004-artifact-trail-as-project-state.md) | Artifact Trail as Project State | **Accepted** | Project state is a collection of markdown files at conventional locations, versioned by git. Methodology Manifest as swarm configuration. No single monolithic document. No software runtime. |
| [DEC-0005](DEC-0005-tool-access-tiering.md) | Tool Access Tiering and Blast Radius Control | **Accepted** | Five-tier model (Read and Reason, Scoped Write, Command Execution, Restricted, Human-Gated). Declared, not enforced — behavioral constraints in agent prompts plus human capability gating. |
| [DEC-0006](DEC-0006-escalation-protocol.md) | Escalation Protocol and Failure Mode Taxonomy | **Accepted** | Ten failure modes with defined detection and response. Nexus Briefing format for all escalations. One question per escalation (DEC-0009). Escalation log as audit trail. Two production incident tracks (next-cycle, hotfix). |
| [DEC-0008](DEC-0008-swarm-pattern-assessment.md) | Hybrid Swarm Pattern | **Accepted** | Hybrid pattern: Agile core (XP execution), Formal gates (RUP milestones), Empirical adaptation (Scrum process control), Human-centric communication (Crystal). Dominant methodology varies by phase. Per-project adaptation via Methodologist. |
| [DEC-0009](DEC-0009-iterative-approximation-principle.md) | Iterative Approximation Principle | **Accepted** | The system makes forward progress on partial, approximate input. Never block on perfect information. Prefer proposals over interrogations. One question at a time. |
| [DEC-0010](DEC-0010-agent-definition-file-format.md) | Agent Definition File Format | **Accepted** | Single markdown file per agent. Self-contained, LLM-agnostic, human-readable. Canonical structure: Identity, Flow, Responsibilities, You Must Not, Input/Output Contracts, Tool Permissions, Handoff Protocol, Escalation Triggers, Behavioral Principles, Profile Variants. |
| [DEC-0013](DEC-0013-project-profile-naming.md) | Project Profile Naming | **Accepted** | Four profiles by stakes (Casual/Commercial/Critical/Vital) with four artifact weights (Sketch/Draft/Blueprint/Spec). Self-describing in plain language. |
| [DEC-0014](DEC-0014-methodologist-role.md) | The Methodologist Role | **Accepted** | Standing role active throughout project life — not a one-shot bootstrap. Configures the swarm initially, then re-activates on triggers (phase end, team change, scope shift) to run retrospectives and update the versioned Methodology Manifest. |
| [DEC-0015](DEC-0015-ingestion-loop.md) | Ingestion Loop Design | **Accepted** | Ingestion is a multi-pass cycle: Analyst -> Auditor -> Nexus clarification -> Analyst revision -> repeat until clean. Demo feedback re-opens ingestion with regression check. |
| [DEC-0016](DEC-0016-decomposition-phase-and-gates.md) | Decomposition Phase and Gates | **Accepted** | Two gates (Requirements + Plan) with Architecture Gate between them. Approval criteria: risk-driven + value-driven. [DEFERRED] flag for conscious deferrals. Architect artifacts by profile: metaphor/sketch -> Overview -> ADRs -> ADRs + Baseline. |
| [DEC-0017](DEC-0017-fitness-functions-and-observability.md) | Fitness Functions as Dual-Purpose Specifications | **Accepted** | Every architectural characteristic has a dual-use fitness function: dev-side check (Verifier) + production monitoring threshold + alarm meaning. Architect defines both. Scales to profile. |
| [DEC-0018](DEC-0018-spike-task-ownership.md) | Spike Task Ownership and Lifecycle | **Accepted** | Architect identifies the unknown, writes the acceptance criterion, runs the investigation, produces the finding. Planner schedules before dependent tasks. Planner re-estimates affected tasks. |

## Open Questions

### Resolved

| ID | Title | Status | Resolution |
|---|---|---|---|
| [OQ-0001](OQ-0001-specification-grounding.md) | Specification Grounding | **Resolved** | Assume-and-flag mode. Planner makes working assumptions, flags them, proceeds, refines on feedback. See DEC-0009. |
| [OQ-0005](OQ-0005-technology-stack.md) | Technology Stack | **Resolved** | No software runtime. The deliverable IS the agent definition files — structured markdown prompts loaded into any LLM. See DEC-0010. |
| [OQ-0006](OQ-0006-orchestrator-implementation.md) | Orchestrator Implementation | **Resolved** | The Orchestrator is an agent definition file. The human is the runtime. Orchestration logic is encoded as behavioral instructions in the prompt. |

### Critical Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0002](OQ-0002-loop-termination-signals.md) | Loop Termination Signals | Open | How to detect genuine convergence vs. test-gaming in the iterate loop. Builder/Verifier directory separation partially addresses Option A. |

### High Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0003](OQ-0003-context-window-strategy.md) | Context Loading Strategy | Open (Reframed) | How the Nexus decides what artifacts to load into each agent's LLM session. Orchestrator Routing Instructions partially address this. |
| [OQ-0004](OQ-0004-trust-calibration.md) | Trust Calibration | Open | How the Nexus develops calibrated trust in agent output over time. Demo Sign-off gate (explore running software) partially addresses this. |

### Medium Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0007](OQ-0007-evaluation-harness.md) | Evaluation Harness Design | Open (Reframed) | How to measure quality of a prompt-based, human-runtime framework. Covers prompt review, dogfooding, scenario evaluation, and regression through diffing. |
| [OQ-0009](OQ-0009-retrospective-by-profile.md) | Retrospective by Profile | Open | What a Methodologist retrospective produces at each profile level. Methodologist triggers are defined; per-profile output format is not. |
| [OQ-0010](OQ-0010-builder-session-definition.md) | Builder Session Definition | Open (Deferred) | What constitutes a single "Builder session" for LLM-based agents? Deferred to implementation phase — resolve before first pilot. |

### Low Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0008](OQ-0008-multi-project-isolation.md) | Multi-Project Isolation | Open | Context isolation strategy when the Nexus runs the framework across multiple concurrent projects. |

---

## Dependency Map

```
DEC-0010 (Agent File Format) ──blocks──> Writing any agent definition file

DEC-0013 (Profile Naming) ──used by──> DEC-0008 (Hybrid Swarm per-project adaptation)
                           ──used by──> DEC-0014 (Methodologist Manifest output)
                           ──used by──> DEC-0010 (Profile Variants section in every agent file)
                           ──used by──> All agent artifact production

DEC-0014 (Methodologist)  ──produces──> Methodology Manifest
                           ──configures──> Orchestrator agent (DEC-0001 Control Plane)

DEC-0008 (Hybrid Swarm)   ──informs──> DEC-0002 (methodology per phase)
                           ──informs──> DEC-0014 (Methodologist adaptation logic)

DEC-0001 (Role Taxonomy)  ──defines──> DEC-0003 (who communicates with whom)
                           ──defines──> DEC-0005 (which tier per agent)
                           ──defines──> DEC-0006 (who detects and routes each failure mode)

DEC-0003 (Communication)  ──defines──> DEC-0004 (artifact locations and formats)
                           ──defines──> DEC-0006 (escalation format as Nexus Briefing)

DEC-0009 (Iterative Approx) ──constrains──> DEC-0006 (one question per escalation)
                              ──constrains──> DEC-0015 (Auditor asks one question at a time)
                              ──constrains──> All agent Escalation Triggers sections

DEC-0002 (Lifecycle)       ──structures──> DEC-0015 (Ingestion loop within lifecycle)
                           ──structures──> DEC-0016 (Decomposition within lifecycle)
                           ──structures──> DEC-0017 (Fitness functions within ADR cycle)
                           ──structures──> DEC-0018 (Spikes within decomposition)

OQ-0002 (Loop Termination) ──may revise──> DEC-0002 (iterate convergence criteria)
OQ-0003 (Context Loading)  ──informs──> Orchestrator Routing Instruction format
OQ-0004 (Trust Calibration) ──informs──> Demo Sign-off Briefing format in Orchestrator agent file
OQ-0009 (Retrospective)   ──informs──> Methodologist per-profile retrospective output
```

---

## Deleted Documents

| Former ID | Former Title | Disposition |
|---|---|---|
| DEC-0007 | Communication Standards | Merged into [DEC-0003](DEC-0003-agent-communication-protocol.md) — artifact types, ubiquitous language, and structured markdown formats are now part of the unified communication protocol decision. |
