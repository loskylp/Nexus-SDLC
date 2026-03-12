# DEC-0004: Project Context as Living Document

**Status:** Proposed (Revised 2026-03-12)
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

**Revision note:** This decision was originally framed as an in-memory object managed by a software Orchestrator. Following the resolution of OQ-0005 (no software runtime — the framework is agent definition files), it has been revised. The Project Context is now a structured markdown document that the human maintains and passes between agent invocations.

## Context

Agents in the Nexus SDLC swarm operate in separate LLM conversations. They have no shared memory, no shared filesystem, and no runtime state bus. The only way to maintain coherence across agent invocations is a document that travels with the work — provided by the human as part of each agent's input.

This document is the Project Context. It is the swarm's institutional memory.

## Decision

The Project Context is a **structured markdown document** maintained in the project repository (e.g., `PROJECT-CONTEXT.md`). It is the single source of truth for all agent operations. The human is responsible for including the relevant sections when invoking each agent.

### Structure

```markdown
# Project Context — [Project Name]

**Last Updated:** [ISO date]
**Current Phase:** [DEFINE | DECOMPOSE | NEXUS CHECK | EXECUTE | VERIFY | ITERATE | INTEGRATE | NEXUS MERGE]
**Lifecycle Version:** [incremented on every phase transition or significant update]

## Goal Specification

[The human's original goal, constraints, and acceptance criteria.
May be informal. Updated with Nexus amendments after NEXUS CHECK.]

## Approved Plan

[The task plan produced by the Planner and approved at NEXUS CHECK.
Includes atomic tasks, dependency order, risk flags, and flagged assumptions.]

### Task Status Tracker

| Task ID | Title | Status | Assigned To | Iteration | Notes |
|---|---|---|---|---|---|
| T-001 | ... | Not Started / In Progress / Verify / Pass / Fail / Blocked | [Agent role] | 0 | ... |

## Decision Log

[Append-only. Every agent appends its significant decisions here with reasoning.]

| Date | Agent Role | Decision | Reasoning |
|---|---|---|---|
| ... | ... | ... | ... |

## Active Artifacts

[List of files created or modified, organized by task.]

### T-001: [Task Title]
- `path/to/file.py` — [description of what was created/changed]
- `tests/test_file.py` — [test file for this task]

## Verification Results

[Most recent verification results per task.]

### T-001: [Task Title]
- **Reviewer:** [Pass/Fail] — [summary]
- **QA:** [Pass/Fail] — [summary, failure details if applicable]
- **Security:** [Pass/Fail] — [summary]

## Escalation History

[Record of escalations to the Nexus and their resolutions.]

| Date | Failure Mode | Summary | Nexus Response |
|---|---|---|---|
| ... | ... | ... | resolve / amend / skip / abort — [details] |

## Flagged Assumptions

[Working assumptions made by agents that have not yet been confirmed by the Nexus.
Agents add here. The Nexus reviews and either confirms or overrides.]

| Source | Assumption | Status | Nexus Response |
|---|---|---|---|
| Planner | ... | Flagged / Confirmed / Overridden | ... |
```

### Ownership and Update Protocol

1. **The human (Nexus) owns the document.** The human creates it, stores it in the repository, and is responsible for passing relevant sections to agents.

2. **Agents propose updates, the human applies them.** When an agent produces output that should update the Project Context (e.g., the Planner produces a task plan, the QA agent produces verification results), the agent's output includes a clearly marked section: "Update to Project Context — [section name]." The human copies this into the document.

3. **The Orchestrator agent's instructions include guidance** for the human on which sections to include when invoking each agent role. This replaces the programmatic "context slicing" from the original decision — the human performs the slicing guided by the Orchestrator's instructions.

4. **Append-only sections** (Decision Log, Escalation History) are never edited, only extended. The human should not delete entries from these sections.

### Context Slicing Guide (for the human)

| Agent Role | Include These Sections |
|---|---|
| **Orchestrator** | Full document |
| **Planner** | Goal Specification, Flagged Assumptions |
| **Coder** | Goal Spec summary, the specific task from Approved Plan, prior Verification Results for this task, relevant Active Artifacts |
| **Reviewer** | The specific task, relevant Active Artifacts, architectural constraints from Approved Plan |
| **QA** | The specific task, acceptance criteria, relevant Active Artifacts, prior Verification Results |
| **Security** | Relevant Active Artifacts, dependency-related sections of Approved Plan |
| **Integrator** | Full Approved Plan, all Active Artifacts, all Verification Results |

## Rationale

**Why a markdown document:** The framework has no runtime (OQ-0005). State must be human-readable, human-editable, version-controllable (git), and includable in LLM prompts as text. Markdown satisfies all of these. It is the only format that is simultaneously a document, a prompt input, and a version-controlled artifact.

**Why human-managed rather than agent-managed:** Without a runtime, there is no automated process to serialize and persist state. The human is the integrating layer between agent invocations. This is consistent with the Managed Autonomy principle — the human controls what each agent sees and what state is preserved.

**Why agents propose updates rather than directly editing:** Direct editing would require agents to have file write access and would risk conflicting edits. The propose-and-apply model keeps the human in control of the document's integrity. It adds friction, but that friction is a feature — it forces the human to see every state change.

**Why a context slicing guide:** Without programmatic slicing, the human needs guidance on what to include. Including the full document for every agent is wasteful (consumes context window) and potentially harmful (agents see information outside their scope). The guide provides role-specific recommendations.

## Consequences

**Easier:**
- No infrastructure needed — it is a file in the repo
- Fully transparent — the human can read every piece of swarm state
- Version-controlled — git history provides the audit trail of state evolution
- Portable — works with any LLM, any interface

**Harder:**
- The human bears the operational burden of maintaining the document and slicing context
- Manual copy-paste between agent outputs and the document is error-prone
- For large projects, the document will become long and unwieldy — the human will need to exercise judgment about what to include
- No automated validation that the document structure is correct

**Newly constrained:**
- Every agent definition file (DEC-0010) must include instructions for what Project Context sections it reads and what updates it proposes
- The Project Context structure must be stable — changing it requires updating all agent definition files
- The human must be disciplined about maintaining the document, or swarm coherence degrades

## Alternatives Considered

**In-memory object managed by software Orchestrator:** The original DEC-0004 design. Required a runtime, a programming language, and a persistence layer. Rejected because OQ-0005 resolved to no-software.

**No explicit state document (agents carry context in conversation history):** Each agent invocation builds on prior conversation turns. Simple but fragile — conversation history is ephemeral, not version-controlled, and tied to a specific LLM session. Rejected for lack of persistence and portability.

**Structured data file (JSON/YAML) maintained by the human:** Machine-parseable but harder for the human to read and edit directly. The Project Context is primarily prose (goals, decisions, reasoning) with some tabular data (task status). Markdown handles this mix better. Rejected for poor ergonomics.

**Wiki or Notion-style document:** Richer editing experience but introduces a tool dependency and is not directly includable in an LLM prompt without copy-paste. Rejected for portability.
