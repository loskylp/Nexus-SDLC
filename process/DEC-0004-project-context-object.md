# DEC-0004: Artifact Trail as Project State

**Status:** Accepted (revised — PROJECT-CONTEXT.md replaced by artifact trail)
**Date:** 2026-03-12 (revised)
**Deciders:** Nexus Method Architect

## Context

The initial proposal described a single PROJECT-CONTEXT.md document maintained by the human — with the human copying agent outputs into it and slicing it for each agent invocation. This was a reasonable first design but was replaced as the actual agent definitions took shape. Real agents write to specific output files; real agents load specific input files. A single human-maintained document became unnecessary overhead, and the Methodology Manifest emerged as the appropriate configuration document for swarm state.

## Decision

Project state is maintained as an **artifact trail** — a collection of markdown files written by agents to conventional locations in the project repository.

### Artifact Trail Structure

Each agent writes to a conventional location:

| Agent | Output Location |
|---|---|
| Methodologist | `manifest/manifest-vN.md` |
| Analyst | `analyst/brief.md`, `analyst/requirements.md` |
| Auditor | `auditor/audit-report-[phase]-[N].md` |
| Architect | `architect/architecture-overview.md` or `architect/ADR-NNNN-*.md`, `architect/baseline.md` |
| Planner | `planner/task-plan.md`, `planner/release-map.md` |
| Scaffolder | `scaffolder/scaffold-manifest.md` + scaffold files in source tree |
| Builder | `src/` (implementation), `tests/unit/` (unit tests) |
| Verifier | `verifier/verification-report-[task].md`, `verifier/demo-script-[task].md` |
| Sentinel | `sentinel/security-report-[cycle].md` |
| Architect (spikes) | `spikes/SPIKE-NNN/finding.md` |
| Scribe | `docs/vN.N.N/` (versioned snapshots), `CHANGELOG.md`, `RELEASE-NOTES-vN.N.N.md` |

### Methodology Manifest

The Methodology Manifest (produced by the Methodologist) is the swarm's configuration document. It declares: selected profile and artifact weight, active agents, documentation requirements per agent, human gate configuration, and any project-specific process rules. The Orchestrator reads it at the start of each invocation. Manifests are versioned (`manifest-v1.md`, `manifest-v2.md`). The full version history is preserved as part of the project traceability trail.

### Context Loading

Agents load only the artifacts relevant to their work, as declared in their Input Contract. The Orchestrator's Routing Instruction specifies which artifact files to load. The human provides these files when invoking the agent. This replaces the single-document copy-paste model with a targeted, file-based approach.

### Orchestrator Escalation Log

The Orchestrator maintains an escalation log as part of the artifact trail: `orchestrator/escalation-log.md`. Every escalation received and every Nexus decision is recorded as ESC-NNN entries. This is the audit trail of all significant project decisions.

## Rationale

**Why one file per agent output:** More maintainable than a single document that grows without bound. Each file is independently readable, version-diffable, and loadable into an LLM without loading everything.

**Why conventional locations:** Discoverability. Any agent (or human) can navigate the artifact trail without being told where to look. Convention over configuration.

**Why the Methodology Manifest as separate configuration:** The Manifest separates "how to run this project" from "what we built." The Orchestrator needs the Manifest to configure itself; it doesn't need the full artifact trail for that. Separation makes each document's purpose clear.

**Why git as audit trail:** Git history provides the complete audit trail of state evolution — who wrote what, when, and what changed. No custom audit system is needed.

## Consequences

**Easier:**
- Each artifact is independently readable and version-controlled
- Agents load exactly what they need, not a full project document
- Adding a new agent means defining its conventional output location — no schema changes

**Harder:**
- The human must know which artifact files to provide when invoking each agent (mitigated by the Routing Instruction, which lists exactly what to load)
- For large projects, the artifact trail grows — humans must exercise judgment about what to archive

**Newly constrained:**
- Every agent definition file declares its input artifacts (what it reads) and output artifacts (where it writes) in its Input Contract and Output Contract sections
- The Orchestrator's Routing Instruction always specifies "Load these artifacts" — no agent invocation without a context list

## Alternatives Considered

**Single PROJECT-CONTEXT.md (initial proposal):** One human-maintained document. Simpler conceptually but creates a growing, monolithic document and requires human copy-paste between agent outputs and the document. Replaced by the artifact trail.

**In-memory object managed by software Orchestrator:** Required a runtime, a programming language, and a persistence layer. Rejected because OQ-0005 resolved to no software runtime.
