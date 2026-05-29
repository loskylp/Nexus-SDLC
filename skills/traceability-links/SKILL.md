---
name: traceability-links
description: Use BEFORE writing an Orchestrator routing instruction, a Builder task brief, or any inter-agent artifact that references requirements, ADRs, task plans, or scaffold manifests. TRIGGER when about to type a "Documents required", "References", or "See also" section; when a routing prompt mentions REQ-NNN, ADR-NNN, TASK-NNN, or "the requirements list"; when instructing an agent to "find" or "search for" a document; when about to type an absolute filesystem path like `/Users/pablo/projects/...` into an artifact. Mandates project-root-relative markdown links to specific anchors (e.g. `[REQ-005 — Note editor autosave](../../analyst/requirements-v2.md#req-005)`), the per-receiving-agent required-links table, and anchor conventions (`{#req-005}`, `{#task-014}`, ADR per-file). Forbids absolute filesystem paths, "find this document" instructions, and stale-version links.
---

# Traceability Links

## Rule

Routing slips and task briefs must contain markdown links to the specific documents and sections the receiving agent needs. Agents must not search for documents — the link is the contract.

## Why

Agents that search for documents load broad context before narrowing to what they need. Links eliminate that search step, reduce context use, and make the hand-off auditable: the routing slip records exactly what the agent was given.

## How to write links

### In routing slips and task briefs

Use project-root-relative paths (no absolute filesystem paths):

```markdown
## Documents required

- Requirement: [REQ-005 — Note editor autosave](../../analyst/requirements-v2.md#req-005)
- Architecture decision: [ADR-003 — PostgreSQL as primary store](../../architect/adr/ADR-003-postgresql.md)
- Acceptance criteria: [TASK-014 AC](../../planner/task-plan-v2.md#task-014)
- Scaffold manifest: [scaffold-manifest.md](../../scaffolder/scaffold-manifest.md#task-014-files)
```

### Requirement anchors

The Analyst must write requirement IDs as markdown anchors in every requirements document:

```markdown
## REQ-005 — Note editor autosave {#req-005}
```

### ADR anchors

The Architect must write ADR IDs as anchors in every ADR file. Each ADR is a separate file; the filename is the link target:

```markdown
[ADR-003](../../architect/adr/ADR-003-postgresql.md)
```

### Task plan anchors

The Planner must write task IDs as markdown anchors in every task plan:

```markdown
## TASK-014 — Search and filter {#task-014}
```

## What the Orchestrator must include in every routing slip

| Receiving agent | Required links |
|---|---|
| Builder | Relevant REQ IDs, relevant ADR IDs, task AC section in task plan, scaffold manifest section for this task |
| Verifier | Task AC section in task plan, relevant REQ IDs, Builder's implementation files (for context) |
| Auditor | Requirements document being audited (full file link) |
| Sentinel | Architecture overview, environment description |
| Planner | Approved requirements document, architecture overview |

## What is forbidden

- Absolute filesystem paths in any artefact (e.g., `/Users/pablo/projects/...`)
- Instructing an agent to "find" or "search for" a document that the routing slip should have linked
- Linking to the wrong version of a document (always link the current `vN` file, not `v1` if `v3` exists)
