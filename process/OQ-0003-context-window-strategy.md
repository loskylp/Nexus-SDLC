# OQ-0003: Context Window Management — Summarization and Retrieval Strategy

**Status:** Open
**Date:** 2026-03-12
**Priority:** High

## Question

DEC-0004 defines context slicing as the approach for managing context window limits. But the slicing strategy itself is under-specified: how does the Orchestrator decide what goes into a slice? What summarization strategy preserves critical information while fitting within token limits? How is retrieval handled when an agent needs historical context not in its current slice?

## Why It Matters

Context management is the technical bottleneck that will determine whether the framework works for non-trivial projects. A project with 50 atomic tasks, 3 iterations each, produces hundreds of reasoning traces, verification reports, and artifact records. No current LLM context window can hold all of this simultaneously.

Poor context slicing leads to:
- Agents repeating work because they lack context about prior attempts
- Inconsistent decisions because agents lack access to architectural decisions made in earlier tasks
- Escalations that could have been avoided with better context

## Options Being Considered

**Option A — Template-based slicing:**
Each agent role has a fixed template that defines what context sections are included. The Orchestrator populates the template from the Project Context. Templates are hand-designed per role.

*Trade-offs:* Predictable and debuggable. But rigid — does not adapt to task-specific needs. A Coder working on a task that depends heavily on a prior task's output needs different context than one working on an independent task.

**Option B — Relevance-scored retrieval (RAG):**
The Project Context is indexed. When an agent is invoked, the Orchestrator retrieves the most relevant context entries based on the current task description. This uses embedding-based similarity search.

*Trade-offs:* Adaptive to task specifics. But introduces a retrieval system as a dependency, adds latency, and retrieval quality depends on embedding model quality. May retrieve irrelevant context or miss critical context.

**Option C — Hierarchical summarization:**
The Orchestrator maintains summaries at multiple granularity levels: full detail (recent tasks), summarized (older tasks), and high-level (project-level architectural decisions). The context slice includes full detail for the current task and its dependencies, summaries for related tasks, and high-level context for everything else.

*Trade-offs:* Good balance of detail and breadth. But summarization itself is an LLM operation that may lose critical details. Requires a summarization protocol that preserves the right information.

**Option D — Hybrid (template + summarization):**
Use templates as the base structure, populate them with full detail for current/dependent tasks, and fill remaining context budget with hierarchical summaries of broader project context.

*Trade-offs:* Most flexible but most complex to implement. Requires both template design and summarization logic.

## Information Needed

1. **Typical project context size:** How large does the Project Context object get for projects of 10, 50, 100 tasks? This determines how aggressive context management needs to be.

2. **Context window trends:** Current frontier models offer 128K-200K token windows. Is this sufficient for most single-task slices without summarization? If so, summarization can be deferred to a later version.

3. **Summarization quality:** How much critical information is lost when a reasoning trace or verification report is summarized? Empirical testing is needed.

4. **Technology stack decision (OQ-0005):** RAG-based retrieval requires embedding infrastructure. The technology stack choice affects which options are viable in v1.

## Blocking

- DEC-0004 (Project Context) — the context slicing implementation details
- The Orchestrator agent's implementation — context slice generation is a core responsibility
