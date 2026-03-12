# DEC-0007: Agent Communication Standards and Artifact Formats

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

Agents communicate through structured artifacts, not natural language conversation. The RATIONALE.md draws from MetaGPT's SOP-driven approach and DDD's ubiquitous language concept. We need to define the standard formats for inter-agent communication, human-facing outputs, and internal reasoning traces.

## Decision

### Core Principle: Structured Over Conversational

All agent-to-agent communication uses typed, schema-validated messages. Natural language is reserved for:
- Reasoning traces (internal to an agent's output)
- Human-facing summaries (Nexus Briefings)
- Escalation question text

### Standard Artifact Types

**1. Goal Specification (Human -> Orchestrator)**
```
GoalSpec {
  title: string
  description: string (natural language, may be informal)
  constraints: string[] (optional — explicit limitations)
  acceptance_criteria: string[] (optional — how to know it's done)
  priority: Critical | High | Medium | Low
}
```

**2. Task Plan (Planner -> Orchestrator -> Human)**
```
TaskPlan {
  tasks: Task[]
  dependency_graph: DAG<TaskID>
  risk_flags: RiskFlag[]
  estimated_total_effort: EffortEstimate
}

Task {
  task_id: string
  title: string
  description: string
  acceptance_criteria: string[]
  risk_level: Low | Medium | High
  estimated_effort: EffortEstimate
  required_tools: ToolAccess[]
}
```

**3. Implementation Artifact (Coder -> Orchestrator)**
```
ImplementationArtifact {
  task_id: string
  files_created: FilePath[]
  files_modified: FilePath[]
  reasoning_trace: string
  self_assessment: string (agent's confidence and known limitations)
}
```

**4. Verification Report (QA/Reviewer/Security -> Orchestrator)**
```
VerificationReport {
  task_id: string
  agent_role: RoleType
  status: Pass | Fail | Warn
  findings: Finding[]
  summary: string
}

Finding {
  severity: Critical | High | Medium | Low | Info
  category: string (e.g., "test_failure", "lint_error", "vulnerability")
  location: FilePath + line range (if applicable)
  description: string
  suggested_fix: string (optional)
}
```

**5. Nexus Strategic Briefing (Orchestrator -> Human)**

Used at NEXUS CHECK, NEXUS MERGE, and NEXUS ESCALATION. Format defined in the Nexus Method Architect system prompt — includes status, completed work, in-progress items, blockers, and human decisions required.

**6. Reasoning Trace (all agents, appended to every output)**
```
ReasoningTrace {
  agent_id: string
  role: RoleType
  timestamp: ISO8601
  task_id: string
  decision: string (what was decided)
  reasoning: string (why — the considerations, trade-offs, alternatives rejected)
  confidence: float (0.0 - 1.0, self-assessed)
}
```

### Ubiquitous Language

The following terms have precise definitions across all agent communications:

| Term | Definition |
|---|---|
| **Nexus** | The human-in-the-middle; the strategic decision-maker |
| **Swarm** | The collective of all active agents in a lifecycle |
| **Orchestrator** | The control-plane agent that routes, manages state, and escalates |
| **Atomic Task** | The smallest unit of work that produces a verifiable artifact |
| **Nexus Check** | Human approval gate before execution begins |
| **Nexus Merge** | Human approval gate before code enters the main branch |
| **Nexus Escalation** | Conditional human gate triggered by convergence failure or ambiguity |
| **Iterate** | An autonomous code-verify cycle within the execution phase |
| **Convergence** | Verification passing after one or more iterate cycles |
| **Thrashing** | Non-decreasing failure count across consecutive iterations |
| **Blast Radius** | The scope of potential damage from an agent action |
| **Context Slice** | The subset of Project Context provided to an agent for a specific task |

## Rationale

**Why structured messages over natural language:** Natural language between agents introduces ambiguity, requires parsing, and makes validation impossible. Structured messages can be schema-validated before delivery, ensuring that receiving agents get well-formed inputs. This is the MetaGPT insight applied rigorously.

**Why reasoning traces are mandatory:** The RATIONALE.md identifies "Auditable Reasoning" as a core design goal. If an agent makes a decision, the reasoning must be inspectable post-hoc. This also enables future learning — if a reasoning pattern consistently leads to failures, it can be identified and corrected.

**Why self-assessed confidence:** Confidence signals help the Orchestrator make routing decisions. A Coder with low confidence on a security-sensitive task might trigger additional Security review. This is an imperfect signal (LLMs are not well-calibrated), but it provides useful information for escalation thresholds.

**Why a ubiquitous language:** DDD's insight is that shared terminology prevents entire categories of misunderstanding. When the Orchestrator says "thrashing," every agent and the human know exactly what it means. This reduces the noise in escalation messages and makes logs interpretable.

## Consequences

**Easier:**
- Agent inputs/outputs are validated against schemas, catching malformed messages before they cause downstream failures
- Logs are structured and machine-parseable, enabling automated analysis
- The ubiquitous language reduces ambiguity in all communications

**Harder:**
- Schema design must happen before agent implementation — this is upfront investment
- Schema evolution (adding fields, deprecating fields) must be managed carefully
- Natural language in reasoning traces is still unstructured — automated analysis of reasoning quality requires additional tooling

**Newly constrained:**
- Every agent must produce output conforming to the relevant artifact schema
- Every agent must include a ReasoningTrace with every output
- The ubiquitous language terms must be used consistently — agents should not use synonyms

## Alternatives Considered

**Natural language conversation between agents (ChatDev style):** Simpler to implement but produces ambiguous, unparseable inter-agent communication. Validation is impossible. Post-hoc analysis requires human reading. Rejected for lack of rigor.

**Binary protocol (protobuf, etc.):** Maximally efficient but premature optimization. The system is not I/O-bound on inter-agent messages. Human readability of the communication log matters more than serialization efficiency at this stage. Rejected for premature optimization.

**No ubiquitous language (let terms emerge naturally):** Risks semantic drift where different agents or documentation use different terms for the same concept. This is the exact problem DDD's ubiquitous language solves. Rejected for ambiguity risk.
