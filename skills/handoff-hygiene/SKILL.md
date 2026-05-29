---
name: handoff-hygiene
description: Use BEFORE writing a Builder handoff note, a Verifier handoff to the Orchestrator, an Orchestrator routing instruction, or any inter-agent communication artifact in this project. TRIGGER when about to write to `process/builder/handoff-notes/TASK-NNN-handoff.md`, `process/orchestrator/routing-instructions/...`, or any agent-to-agent note; when an agent prompt mentions "handoff", "produce a handoff note", "summarise what you did"; when about to paste raw logs or terminal output into an artifact. Prescribes the three things a handoff must answer (what was done, what deviated, what the next agent needs to know) and the inclusion test ("would the receiving agent's behavior change if this line were removed?"). Forbids raw debug logs, rejected alternatives, resolved error messages, repetition of the task description, and hedging language. Size guideline: handoff > 40 lines = a signal to apply the inclusion test paragraph-by-paragraph.
---

# Handoff Note Hygiene

> Apply this skill when writing any handoff note, routing instruction, or inter-agent communication artifact.

## What Belongs in a Handoff Note

A handoff note answers three questions for the receiving agent:

1. **What was done** — the outcome, not the journey. State the result, not the process of arriving at it.
2. **What deviated from the plan** — anything that differs from what the task description or routing instruction expected. Deviations without explanation become surprises downstream.
3. **What the next agent needs to know** — blockers, assumptions made, known limitations, environment state changes. Information the receiving agent cannot discover from reading the code or artifacts alone.

## What Does Not Belong

- Raw debug logs or tool output — the receiving agent does not need your terminal history
- Exploratory reasoning or alternatives considered and rejected — the decision matters, not the deliberation
- Copy-pasted error messages that were already resolved — if you fixed it, it is not relevant to the next agent
- Repetition of information already in the task description or acceptance criteria — the receiving agent has access to those documents
- Self-congratulatory or hedging language ("I believe this should work", "hopefully this covers it") — state facts

## The Inclusion Test

For every line in a handoff note, ask: **"Would the receiving agent's behavior change if this line were removed?"**

If no — remove it. The handoff note is a signal, not a transcript.

## Size Guideline

A handoff note longer than 40 lines is a signal that the agent is dumping rather than communicating. If the note exceeds this guideline, re-read it and apply the inclusion test to every paragraph. The exception: a task with multiple deviations from plan, where each deviation requires its own explanation.
