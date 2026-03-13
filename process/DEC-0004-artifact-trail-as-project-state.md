# DEC-0004 — Artifact Trail as Project State

**Status:** Accepted
**Date:** 2026-03-12

## Context

A multi-agent system needs a state management strategy: how is project state created, stored, shared between agents, and preserved over time?

The initial proposal described a single PROJECT-CONTEXT.md document maintained by the human, who would copy agent outputs into it and slice it for each agent invocation. This was a reasonable first design but was replaced as the actual agent definitions took shape. Real agents write to specific output files. Real agents load specific input files. A single human-maintained document became unnecessary overhead — the human was being asked to do bookkeeping that the agent file conventions already handled. When OQ-0006 resolved (the Orchestrator is an agent definition file, not software), and OQ-0005 resolved (no software runtime), the state model settled: project state is the collection of markdown files agents write to conventional locations, versioned by git.

## Decision

Project state is maintained as an **artifact trail** — a collection of markdown files written by agents to conventional locations in the project repository.

### Artifact Trail Structure

Each agent writes to a declared location (see DEC-0003 for the full artifact type table). The key structural principles:

1. **One artifact per concern** — the Brief is one file, the Requirements List is one file, each ADR is one file. No single document grows without bound.
2. **Conventional locations** — agents write to declared directories (`analyst/`, `architect/`, `verifier/`, etc.). Any agent or human can navigate the trail without being told where to look.
3. **Git is the audit trail** — the complete history of state evolution is captured by version control. No custom audit system is needed. Who wrote what, when, and what changed is answered by `git log` and `git diff`.

### Methodology Manifest

The Methodology Manifest (produced by the Methodologist) is the swarm's configuration document. It declares: selected profile and artifact weight, active agents, documentation requirements per agent, human gate configuration, CD philosophy, and max_iterations. The Orchestrator reads the current Manifest at every invocation. Manifests are versioned (`manifest-v1.md`, `manifest-v2.md`). The full version history is the project's process audit trail.

### Context Loading

Agents load only the artifacts relevant to their work, as declared in their Input Contract. The Orchestrator's Routing Instruction specifies which artifact files to load. The human provides these files when invoking the agent. This replaces the single-document copy-paste model with a targeted, file-based approach.

### Orchestrator Escalation Log

The Orchestrator maintains `orchestrator/escalation-log.md` as part of the artifact trail. Every escalation received and every Nexus decision is recorded as ESC-NNN entries. This is the audit trail of all significant project decisions that do not live in other artifacts.

### No Software Runtime

All artifacts are human-readable markdown. The framework has no runtime, no serialization layer, and no infrastructure dependency. The project repository and git history are the only persistence required. This is a direct consequence of OQ-0005's resolution.

## Reasoning

**Why one file per agent output:** More maintainable than a single document that grows without bound. Each file is independently readable, version-diffable, and loadable into an LLM prompt without loading everything else. An Architect reviewing its prior ADRs does not need to load the Analyst's Brief.

**Why conventional locations over configurable paths:** Discoverability. Convention over configuration eliminates a class of "where did that file go?" errors and makes the artifact trail navigable by any agent or human without a lookup step.

**Why the Methodology Manifest as a separate configuration:** The Manifest separates "how to run this project" from "what we built." The Orchestrator needs the Manifest to configure itself; it does not need the full artifact trail for that purpose. Separation makes each document's purpose clear.

**Why git as audit trail:** Git history provides the complete audit trail of state evolution. It is already present in every software project. Adding a custom audit system would violate the no-runtime constraint and duplicate functionality that git provides natively.

**Why the single PROJECT-CONTEXT.md was abandoned:** As agent definitions were written, each agent declared its specific inputs and outputs. The single document became a human-maintained aggregation layer with no consumers — every agent already knew which specific files it needed. The maintenance cost (human copy-paste) had no corresponding benefit.

## Alternatives Considered

**Single PROJECT-CONTEXT.md (initial proposal):** One human-maintained document containing all project state. Simpler conceptually but creates a growing monolithic document and requires human copy-paste between agent outputs and the document. Abandoned when the artifact trail made it redundant.

**In-memory object managed by a software Orchestrator:** Would provide structured state management with validation. Rejected because OQ-0005 resolved to no software runtime — the framework is agent definition files, not software.

**Database-backed state store:** Maximum structure and query capability. Rejected for the same reason as the in-memory object — no runtime, no infrastructure dependencies.

## Consequences

- Each artifact is independently readable and version-controlled.
- Agents load exactly what they need, not a full project document.
- Adding a new agent means defining its conventional output location — no schema changes or infrastructure updates.
- The human must know which artifact files to provide when invoking each agent — mitigated by the Routing Instruction, which lists exactly what to load.
- For large projects, the artifact trail grows. The human must exercise judgment about what to archive or summarize. This is an open question (OQ-0003).
- Every agent definition file declares its input artifacts (what it reads) and output artifacts (where it writes) in its Input Contract and Output Contract sections.
