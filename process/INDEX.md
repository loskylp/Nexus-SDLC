# Nexus SDLC — Process Architecture Index

Last updated: 2026-03-12

---

## Decisions

| ID | Title | Status | Summary |
|---|---|---|---|
| [DEC-0001](DEC-0001-agent-role-taxonomy.md) | Agent Role Taxonomy | Proposed | Seven roles across four tiers (Control, Planning, Execution, Verification) with strict one-role-per-invocation and concern-based separation |
| [DEC-0002](DEC-0002-lifecycle-phases-and-gates.md) | Lifecycle Phases and Human Gates | Proposed | Seven-phase lifecycle (DEFINE through NEXUS MERGE) with two mandatory human gates, one conditional escalation gate, and bounded iterate loops |
| [DEC-0003](DEC-0003-handoff-protocol.md) | Agent Handoff Protocol | Proposed | Hybrid protocol — gated milestones between phases, continuous integration within the EXECUTE-VERIFY-ITERATE loop |
| [DEC-0004](DEC-0004-project-context-object.md) | Project Context as Living Document | Proposed (Revised) | Structured markdown document maintained by the human, passed between agent invocations. Pending supersession by DEC-0011. |
| [DEC-0005](DEC-0005-tool-access-tiering.md) | Tool Access Tiering | Proposed (Revised) | Five-tier model retained as declared behavioral constraints in agent prompts. Enforcement via LLM prompt adherence + human capability gating. |
| [DEC-0006](DEC-0006-escalation-protocol.md) | Escalation Protocol | Proposed | Seven failure modes with structured escalation messages, batched delivery, and four response types (resolve, amend, skip, abort) |
| [DEC-0007](DEC-0007-communication-standards.md) | Communication Standards | Proposed | Typed artifact schemas for all inter-agent communication, mandatory reasoning traces, and ubiquitous language glossary |
| [DEC-0008](DEC-0008-swarm-pattern-assessment.md) | Swarm Pattern Assessment | Proposed | Hybrid Swarm pattern at C1/Complex baseline — profile naming now superseded by DEC-0013 |
| [DEC-0009](DEC-0009-iterative-approximation-principle.md) | Iterative Approximation Principle | **Accepted** | The system makes forward progress on partial, approximate input. Never block on perfect information. Prefer proposals over interrogations. One question at a time. |
| [DEC-0010](DEC-0010-agent-definition-file-format.md) | Agent Definition File Format | Proposed | Canonical markdown structure for agent definition files: Identity, Responsibilities, Prohibitions, Input/Output Contracts, Tool Permissions, Handoff Protocol, Escalation Triggers, Examples. |
| [DEC-0013](DEC-0013-project-profile-naming.md) | Project Profile Naming | **Accepted** | Four profiles by stakes (Casual/Commercial/Critical/Vital) with four artifact weights (Sketch/Draft/Blueprint/Spec). Self-describing in plain language. |
| [DEC-0014](DEC-0014-methodologist-role.md) | The Methodologist Role | **Accepted** | Standing role active throughout project life — not a one-shot bootstrap. Configures the swarm initially, then re-activates on triggers (phase end, team change, scope shift) to run retrospectives and update the versioned Methodology Manifest. |
| [DEC-0015](DEC-0015-ingestion-loop.md) | Ingestion Loop Design | **Accepted** | Ingestion is a multi-pass cycle: Analyst → Auditor → Nexus clarification (one question at a time) → Analyst revision → repeat until clean. Demo feedback re-opens ingestion with a mandatory regression check on all previously approved requirements. |

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
| [OQ-0002](OQ-0002-loop-termination-signals.md) | Loop Termination Signals | Open | How to detect genuine convergence vs. test-gaming by agents in the iterate loop? |

### High Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0003](OQ-0003-context-window-strategy.md) | Context Window Strategy | Open (Reframed) | Now about guiding the human on what to include when invoking each agent, not about programmatic retrieval |
| [OQ-0004](OQ-0004-trust-calibration.md) | Trust Calibration | Open | How the Nexus develops calibrated trust in agent output over time |

### Medium Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0007](OQ-0007-evaluation-harness.md) | Evaluation Harness Design | Open | Metrics, benchmarks, and test scenarios for measuring framework effectiveness |

### Medium Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0007](OQ-0007-evaluation-harness.md) | Evaluation Harness Design | Open | Metrics, benchmarks, and test scenarios for measuring framework effectiveness |
| [OQ-0009](OQ-0009-retrospective-by-profile.md) | Retrospective by Profile | Open | What a Methodologist retrospective looks like in each profile — Casual through Vital. Deliberately deferred; will differ significantly per profile. |

### Low Priority

| ID | Title | Status | Summary |
|---|---|---|---|
| [OQ-0008](OQ-0008-multi-project-isolation.md) | Multi-Project Isolation | Open | Context isolation strategy for concurrent project management |

---

## Dependency Map

```
DEC-0014 (Methodologist) ──produces──> Methodology Manifest
                          ──configures──> Orchestrator agent

DEC-0013 (Profile Naming) ──used by──> DEC-0014 (Methodologist output)
                           ──used by──> All agent artifact production

DEC-0010 (Agent File Format) ──blocks──> Writing any agent definition file

OQ-0002 (Loop Termination) ──blocks──> QA agent definition design
                           ──may revise──> DEC-0002 (iterate convergence criteria)

OQ-0003 (Context Window)  ──informs──> Orchestrator agent file (context assembly guidance)
OQ-0004 (Trust Calibration)──informs──> Strategic Briefing format in Orchestrator agent file
```
