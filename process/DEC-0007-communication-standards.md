# DEC-0007: Agent Communication Standards and Artifact Formats

**Status:** Accepted (revised — programmatic schemas replaced by markdown artifacts)
**Date:** 2026-03-12 (revised)
**Deciders:** Nexus Method Architect

## Context

The initial proposal described typed, schema-validated messages — GoalSpec, TaskPlan, ImplementationArtifact, VerificationReport, ReasoningTrace — as structured objects with typed fields. These were designed for a software runtime and assumed automated schema validation between agents. When OQ-0005 resolved to no software runtime, all inter-agent communication became markdown files. The artifact types are still named and structured — but through markdown section conventions, not programmatic schemas.

## Decision

### Core Principle: Structured Markdown

All agent communication uses structured markdown artifacts stored in the repository. Structure comes from section headers, tables, and declared output formats defined in each agent's Output Contract. Natural language is used throughout.

### Actual Artifact Types

**1. Methodology Manifest (Methodologist → Orchestrator)**
Profile and artifact weight, active agents, documentation requirements, gate configuration, max iterations. File: `manifest/manifest-vN.md`. Versioned.

**2. Brief (Analyst → all agents)**
Domain model, delivery channel, vocabulary, stakeholder context. Free-form structured markdown. File: `analyst/brief.md`.

**3. Requirements List (Analyst → Auditor → all agents)**
Numbered requirements (REQ-NNN), each with description, origin, rationale, and acceptance criteria. File: `analyst/requirements.md`.

**4. Audit Report (Auditor → Orchestrator)**
Per-requirement or per-component flags using the Auditor's flag vocabulary. PASS overall if no blocking flags remain. File: `auditor/audit-report-[phase]-[N].md`.

**5. Architecture Artifacts (Architect → all agents)**
Profile-calibrated:
- Casual: Architecture Sketch embedded in Task Plan
- Commercial: Architecture Overview (`architect/architecture-overview.md`)
- Critical/Vital: ADRs (`architect/ADR-NNNN-*.md`), optionally Architecture Baseline (`architect/baseline.md`)

Each ADR includes dual-use fitness functions (dev check + production monitoring threshold).

**6. Task Plan (Planner → Orchestrator)**
Atomic tasks (TASK-NNN) with acceptance criteria, risk/value rating, dependency order. Spike tasks (SPIKE-NNN) with Resolves, Needed before, Finding goes to fields. File: `planner/task-plan.md`.

**7. Release Map (Planner → Orchestrator)**
CD philosophy, version targets, ships-when conditions per release. File: `planner/release-map.md`.

**8. Scaffold Manifest (Scaffolder → Builder)**
Directory structure, component responsibilities, exported interfaces table, dependency map, Builder task surface. File: `scaffolder/scaffold-manifest.md`.

**9. Routing Instruction (Orchestrator → Agent)**
Standard format: To, Phase, Task, Load these artifacts, Produce, Iteration, Return to.

**10. Handoff Note (Builder → Orchestrator)**
Per-task completion. Task completed, unit tests written/passing, deviations from scaffold if any, architectural questions raised with Architect, known limitations.

**11. Verification Report (Verifier → Orchestrator)**
Per-task, per-layer test results. Test counts (written/passing/failing) per layer. PASS or FAIL overall. File: `verifier/verification-report-[task].md`.

**12. Demo Script (Verifier → Orchestrator)**
Given/When/Then scenarios per verified task. The Nexus follows these to explore the running software at Demo Sign-off. File: `verifier/demo-script-[task].md`.

**13. Security Report (Sentinel → Orchestrator)**
Per-cycle. Dependency Review results (APPROVE/CONDITIONAL/REJECT per new dependency) + live security test findings (SEC-NNN entries with severity, evidence, remediation). PASS or FINDINGS overall. File: `sentinel/security-report-[cycle].md`.

**14. Spike Finding (Architect → Architect or Planner)**
Answer, Evidence, Implications, Routes to. File: `spikes/SPIKE-NNN/finding.md`.

**15. Nexus Briefings (Orchestrator → Nexus)**
Gate-specific summaries: Requirements Gate Briefing, Architecture Gate Briefing, Plan Gate Briefing, Demo Sign-off Briefing (includes What Was Built, Requirements Satisfied, Tasks Completed, Verification Summary, Security Summary, Demo), Go-Live Briefing.

### Ubiquitous Language

| Term | Definition |
|---|---|
| Nexus | The human-in-the-middle; strategic decision-maker |
| Swarm | The collective of all active agents in a lifecycle |
| Orchestrator | Hub agent: routes, manages state, prepares gate briefings |
| Builder | Implementation agent (replaces original "Coder") |
| Verifier | Test and verification agent (replaces original "QA") |
| Sentinel | Security audit agent (replaces original "Security") |
| Methodologist | Process configuration agent; produces Methodology Manifest |
| Requirements Gate | First human gate — approves requirements before decomposition |
| Architecture Gate | Second human gate — approves architectural approach after Auditor review |
| Plan Gate | Third human gate — approves task plan before execution |
| Demo Sign-off | Per-cycle gate — approves delivered features; authorizes next cycle |
| Go-Live | Release gate — decoupled from Demo Sign-off; three trigger modes |
| Spike | Architect-run investigation to resolve a high-risk unknown |
| Profile | Project stakes classification: Casual / Commercial / Critical / Vital |
| Artifact Weight | Documentation rigor: Sketch / Draft / Blueprint / Spec |
| Fitness Function | Dual-use architectural specification: dev check + production monitoring |
| Thrashing | Non-decreasing failure count across consecutive iteration cycles |
| Blast Radius | The scope of potential damage from an agent action |

## Rationale

**Why structured markdown over programmatic schemas:** Consistent with OQ-0005 (no runtime). Markdown is human-readable, version-controllable, and directly loadable into LLM prompts. Structured schemas require parsers, validators, and serialization infrastructure that does not exist in this framework.

**Why named artifact types without schemas:** Even without schemas, naming artifact types provides the inter-agent coordination structure. An agent that knows it receives a "Verification Report" knows what sections to look for, even without a schema validator.

**Why ubiquitous language:** DDD's insight applied — shared terminology prevents entire categories of misunderstanding. "Builder" not "Coder", "Verifier" not "QA", "Demo Sign-off" not "Nexus Merge." The ubiquitous language is the contract between all agents and the human.

## Consequences

**Easier:**
- Artifact types are discoverable without reading the code
- The ubiquitous language makes all agent communications interpretable without a glossary lookup
- New artifact types can be added by defining their format and conventional location

**Harder:**
- Without schema validation, malformed artifacts are discovered when the receiving agent reads them, not when they are written
- Schema evolution requires updating all agent definitions that reference the changed artifact

**Newly constrained:**
- Every agent definition file uses the ubiquitous language terms — agents do not use synonyms
- Artifact locations are conventional, not arbitrary — agents write to declared locations

## Alternatives Considered

**Typed schemas with a software runtime (initial proposal):** GoalSpec, TaskPlan, etc. as structured objects. Replaced when OQ-0005 resolved to no runtime.

**Natural language conversation between agents (ChatDev style):** Unstructured, unvalidatable, produces ambiguous handoffs. Rejected.
