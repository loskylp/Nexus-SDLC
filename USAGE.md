# Nexus SDLC — Usage Guide

Prompts and guidance for working with the Nexus SDLC swarm.

For installation, see [INSTALL.md](INSTALL.md). For the framework design and rationale, see [README.md](README.md).

---

## How the swarm works

You start the process with one prompt. After that, you step back. The swarm coordinates internally — work moves between agents, loops resolve on their own, and you are brought in only at gate decisions and clarification questions. You are not driving the process — you are steering it.

Your active role is at two kinds of moments:

- **Clarification questions** — an agent needs domain knowledge only you have. Answer and it continues.
- **Gate decisions** — the Orchestrator presents a briefing and waits for your explicit approval before the next phase begins.

Everything between those moments runs autonomously.

---

## Starting a project

Invoke the Methodologist once with a description of what you want to build:

```
@nexus-methodologist I want to build [describe your project].

[Add any context that matters:]
- Who it's for
- Known constraints or non-negotiables
- Whether it's a personal tool, internal system, or product
- Any existing systems it needs to work with
```

The Methodologist will ask you one question at a time to assess the right profile for the project. Answer each question. When it has enough, it produces the Methodology Manifest and hands off to the Orchestrator — which begins the ingestion phase without you needing to do anything else.

---

## What to expect during ingestion

The Analyst will ask you clarifying questions about requirements — one at a time. Just answer them. When the Analyst is satisfied, it returns to the Orchestrator, which routes to the Auditor. If the Auditor finds issues that need your input, it will surface a single question. Answer it. The loop continues until the requirements pass clean.

When ingestion is complete, the Orchestrator presents the **Requirements Gate briefing**. This is the first moment you must make an explicit decision.

---

## Gate decisions

These are the moments the swarm stops and waits for you.

### Requirements Gate

The Orchestrator presents what the Analyst produced — the Brief and the Requirements List. Review them, then respond:

```
Approved. Proceed.
```

Or with changes:

```
Approved with changes:
- [requirement to add, remove, or modify]
- [anything that doesn't match your intent]
```

### Architecture Gate

The Architect may ask you to decide on contested trade-offs during its work — answer those as they come. When architecture is complete and audited, the Orchestrator presents the Architecture Gate briefing:

```
Approved. Proceed to planning.
```

### Plan Gate

The Planner presents the Task Plan with a cut line — tasks it recommends deferring. Review the priorities and the cut line, then respond:

```
Approved. The cut line is confirmed.
```

Or move things:

```
Approved with changes:
- Move [task] above the cut line — it's needed for this release
- Cut [task] entirely
```

### Demo Sign-off

At the end of each development cycle, the Orchestrator presents a Demo Sign-off briefing with everything that was built. Follow the Demo Scripts to explore the running software in staging, then respond:

```
Approved. [Any observations for the next cycle.]
```

Or return with issues:

```
Return. I found the following during the demo:
- [describe what didn't match expectations]
- [anything broken or missing]
```

### Go-Live

When a signed-off version is ready to release:

```
Go-Live approved. Deploy [vN.N.N].
```

---

## Special scenarios

These are situations you initiate — the swarm doesn't know about them until you say so.

### Bug in production

When a defect is found in production, tell the Orchestrator:

```
Production bug reported.

Observed: [what the system is doing — be specific]
Expected: [what it should do]
Environment: production

Is this a hotfix or does it go in the next cycle?
```

The Orchestrator will confirm the track with you if you haven't stated it. On hotfix, it routes Verifier → Builder → Verifier → DevOps without a plan gate. On next-cycle, it creates a P1 task and inserts it before all other pending work.

### New or changed requirements after a demo

If the demo triggered new ideas or you've changed your mind about something:

```
I have feedback from the demo.

New: [describe anything you want to add]
Changed: [describe anything you want to modify about existing requirements]
```

The Orchestrator routes this back through the Analyst and Auditor, then to the Planner to revise the task plan. Completed tasks that are now affected will get follow-up tasks rather than being reopened.

### Mid-cycle requirement change

If something changes while tasks are in progress:

```
I need to change [requirement]. [Describe what changed and why.]
```

The Orchestrator halts any in-progress work that traces to that requirement before routing the change through the Analyst.

### Evaluating a new dependency

If the Builder asks whether it can use a specific library:

```
Evaluate this dependency: [package-name@version]
Intended use: [what the Builder wants to use it for]
```

The Orchestrator routes to the Sentinel, which returns APPROVE, CONDITIONAL, or REJECT. A REJECT comes back to you before the Builder proceeds.

### Profile upgrade

If the project has grown beyond its current setup:

```
The project has changed. [Describe what changed — new compliance requirements, production users, team growth, etc.]
Should we revisit the profile?
```

The Orchestrator routes to the Methodologist, which reassesses and produces an updated Manifest if needed.

---

## Resuming a session

At the start of a new Claude Code session:

```
@nexus-orchestrator Resuming. Load process/orchestrator/project-state.md and tell me where we are.
```

The Orchestrator reads the project state and tells you what was in progress and what needs to happen next. If it needs a decision from you to continue, it will ask. Otherwise it picks up where it left off.

---

## Agent quick reference

You should rarely need to invoke agents directly — the Orchestrator handles routing. But if you need to jump to a specific agent:

| Agent | Invoke directly when |
|---|---|
| `@nexus-methodologist` | Starting a new project; process feels broken; major scope change |
| `@nexus-orchestrator` | Resuming a session; after any gate decision |
| `@nexus-architect` | Builder surfaced an architectural question and you want the Architect to answer it now |
| `@nexus-sentinel` | You want a dependency evaluated or a security review outside the normal cycle |
