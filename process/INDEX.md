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

Last updated: 2026-03-18

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
| [DEC-0024](DEC-0024-devops-phased-invocation.md) | DevOps Phased Invocation | **Accepted** | DevOps invoked in three just-in-time phases at Commercial+: Phase 1 (CI pipeline, dev environment, Environment Contract) before first Builder task; Phase 2 (staging, CD pipeline) after first Verifier PASS; Phase 3 (production, monitoring, rollback verification) before Go-Live gate. Planner tags tasks by phase; Orchestrator enforces sequencing. |
| [DEC-0023](DEC-0023-backward-cascade-protocol.md) | Backward Cascade Protocol | **Accepted** | When an Architecture Gate rejection changes a foundational assumption (delivery channel, deployment model, auth model, data persistence, system boundary), the Orchestrator triggers a backward impact check: Auditor checks approved requirements for invalidated acceptance scenarios (`[INVALIDATED]` flag); if found, Analyst revises before gate is re-attempted. Scoped to foundational assumptions only — not all revisions. |
| [DEC-0022](DEC-0022-cycle-as-delivery-unit.md) | Cycle as Unit of Delivery | **Accepted** | A cycle is a Planner-defined subset of the backlog forming a coherent, demonstrable increment. The Planner declares cycle boundaries explicitly in the Task Plan. The Orchestrator executes only the current cycle's tasks before Demo Sign-off. Nexus approves the cycle boundary at the Plan Gate. No timebox — scope-based boundary. |
| [DEC-0021](DEC-0021-context-exhaustion-checkpoint.md) | Context Exhaustion Checkpoint Protocol | **Accepted** | When a session approaches context exhaustion, the Orchestrator writes a self-sufficient checkpoint to `process/orchestrator/project-state.md` before the session ends. On resume, the Nexus uses the continuation prompt to invoke the Orchestrator in verification mode. The checkpoint must be readable cold with no access to the prior conversation. |
| [DEC-0020](DEC-0020-commit-policy.md) | Commit Policy | **Accepted** | One commit per task. Verifier is sole committer, after full PASS + clean regression. Builder never commits. Commit pushed to remote; CI green required if pipeline configured. Commit message: `TASK-NNN: <description> — all tests pass`. Replaces the pilot approach of a single manual Nexus commit at Go-Live. |
| [DEC-0019](DEC-0019-acceptance-test-authorship-chain.md) | Acceptance Test Authorship Chain | **Accepted** | Analyst's GWT scenarios are the minimum required test coverage. Verifier MUST implement all Analyst-drafted scenarios as executable tests. Verifier MAY add additional negative, boundary, and edge-case tests beyond the Analyst's scenarios; any such test is tagged `[VERIFIER-ADDED]` in the test name or immediately above the test function. |
| DEC-0025 | Planner Multi-Pass Invocation | **Accepted** | Initial Planner invocation for a cycle is split into three focused Orchestrator-managed passes: Pass 1 — decomposition (atomic tasks, acceptance criteria); Pass 2 — scoring and ordering (risk/value rubrics, priority matrix, cut line); Pass 3 — release map (MVP boundary, rolling confidence). Revision invocations (spike, demo feedback, mid-cycle change) remain single-pass. Prevents LLM cognitive overload on a ~700-line agent definition. |
| DEC-0026 | Sentinel Sequential Timing | **Accepted** | Sentinel runs once per cycle, after all tasks in the cycle have passed Verifier — not alongside Verifier per task. Sentinel requires a stable, fully verified build and the Verifier's test results as input. Sequential ordering eliminates interference between security probing and functional test runs against the same staging environment. |
| DEC-0027 | Process Metrics Collection | **Accepted** | The Orchestrator maintains a Process Metrics section in `process/orchestrator/project-state.md` as a running tally (Commercial and above): auditor pass counts, gate rejection counts, average iterations to PASS, tasks hitting max iterations, escalation count, backward cascade events. The Methodologist reads this section as primary quantitative input to the retrospective. |
| DEC-0028 | Convergence Signal Evaluation | **Accepted** | The Orchestrator tracks failing acceptance criterion counts per Builder-Verifier iteration in the Iterate Loop State. If the count has not decreased for the number of consecutive iterations defined as the convergence signal in the Manifest, the Orchestrator escalates to the Nexus before the next Builder iteration — not after the hard limit. Escalation includes the failure count trend. |
| DEC-0029 | Technical Observations Routing | **Accepted** | Verifier non-blocking observations (architectural concerns, stale docs, fragile patterns) are collected by the Orchestrator at cycle completion and surfaced in the Demo Sign-off Briefing's Technical Observations section. They do not block sign-off. If the Nexus chooses to act on an observation, it enters the normal demo feedback channel through the Analyst. |

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
| OQ-0011 | Fitness Function Source of Truth | **Resolved** | ADR (or Architecture Overview) is authoritative for each fitness function's definition and rationale. `fitness-functions.md` is a generated index maintained by the Architect — not independently authored. Planner and Verifier enumerate from the index and follow pointers for context. See DEC-0017. |
| OQ-0012 | Scaffolder Handoff Routing | **Resolved** | Scaffold Manifest routes to the Builder, not back to the Planner. The Planner's task decomposition is complete before the Scaffolder is invoked. The Manifest is reference material for the Builder (what exists, interfaces, dependency order). Routing it back to the Planner would create a circular dependency. |

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
| OQ-0014 | RATIONALE.md Maintenance Policy | **Resolved** | RATIONALE.md is a design rationale document — explains why the framework exists and what principles drive it. It is not a living specification. Authoritative current-state sources are `agents/*.md`, the Methodology Manifest, and `process/INDEX.md`. Update RATIONALE.md at major milestones only (role changes, new design goals, principle changes) — not on individual agent refinements. A one-time correction pass to fix identified drift points is deferred to after the audit resolution session. |
| OQ-0013 | Configurable VCS Workflow | Open (Deferred) | Which version control workflow to use — trunk-based, Feature Branch Workflow, Git Flow, or other. Currently the framework assumes a single working branch. Feature branches per task would enable PR-based review for larger teams; Git Flow or similar would add release branches. Resolve before first multi-developer pilot. The Methodologist Manifest may be the right place to declare the chosen workflow, with downstream impact on Verifier commit/push instructions and DevOps pipeline configuration. |
| OQ-0015 | Production Feedback Loop | Open (By Design) | The production feedback loop is open by design. The framework's responsibility ends at Go-Live. The Architect's fitness functions and DevOps monitoring configuration are the handoff artifacts that enable human operators to detect issues in the live system. When issues surface post-deployment, a human operator raises them to the Nexus, who re-engages the swarm through the normal channel (production incident or new requirement). The swarm does not stay active between development cycles. This is not a gap — it is a deliberate design boundary consistent with the Human-in-the-Middle principle. |

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
