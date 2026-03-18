<!--
Copyright 2026 Pablo Ochendrowitsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Author: Pablo Ochendrowitsch
Session recorded: 2026-03-17
-->

# NexusScan — Process Retrospective

Combined critique from two perspectives: the **Nexus Methodologist** (swarm-side analysis) and the **Nexus** (human-side observations). Both sets were produced independently after the full session completed.

Points marked **[M]** originate from the Methodologist. Points marked **[N]** originate from the Nexus. Points marked **[M+N]** were raised by both independently.

---

## 1. Profile & Intake

**[M]** The Methodologist's job ends at "what kind of project is this." In practice the first user message often contains both the risk calibration answer and the substantive brief. The framework has no instruction for handling that collision. The Methodologist should either absorb the brief and pass it forward as a structured hand-off note, or explicitly tell the Nexus to hold the brief until the Analyst is invoked. Neither is specified.

---

## 2. Requirements Gate & Analyst Behaviour

**[M]** The Requirements Gate ran three times — two of those iterations were compensating for a hand-off failure upstream, not performing genuine requirements elaboration. The Analyst's first output missed the expanded brief entirely because it arrived in a different turn. That is a two-iteration tax on noise, not on ambiguity.

**[N]** The Analyst was avoidant of requirements discovery. It took the first brief description from the kick-off and assumed it was complete. It only asked for clarification of its own assumptions — it did not probe for hidden requirements, edge cases, or unstated constraints. The Nexus had to push it to extract more detailed requirements. The Analyst's job is active elicitation, not passive clarification.

**[M+N]** Acceptance scripts should be specified with Given / When / Then behaviour *first* — before any code is written. The format must be consistent:

```
Given:    <precondition>
When:     <trigger or action>
Then:     <observable result>
```

No mixing of one-line and multi-line formats. No visible table borders — tabulated alignment only. These specifications are the authoritative source from which runnable scripts are derived, and from which demo documentation is generated in a descriptive, auditable format. They are Analyst and Auditor output, not Builder output.

---

## 3. Gate Design

**[M]** The Architecture Gate asked two questions simultaneously, violating the one-question principle. The one-question discipline is currently Methodologist-only at intake. It should apply swarm-wide at all gate boundaries. Multiple simultaneous questions at a gate invite non-answers that leave ambiguity unresolved — which is exactly what happened when the Nexus replied with a performance requirement instead of answering either question.

**[M]** Mid-cycle REQ-010 and REQ-011 skip REQ-009. The gap in the ID sequence will silently mislead anyone using the requirements log as an audit trail. The framework specifies ID assignment for the Analyst but gives no rule for mid-cycle additions. Required rule: mid-cycle additions get the next available sequential ID; the gap is documented in the requirements log with a note.

---

## 4. Cycles, Demos, and the Task Plan

**[N]** A demo opportunity occurred after TASK-001 — the Nexus could have given feedback at that point. Then nothing until the full cycle was complete. The release plan and task plan had no information about: which tasks belong to which cycle, when demos are scheduled within a cycle, or what constitutes a cycle boundary. Demos should be planned events, not spontaneous checkpoints. The task plan must declare cycles explicitly, assign tasks to cycles, and schedule a demo at each cycle boundary.

**[N]** The task plan contained acceptance checklist items that were never marked as done at any moment in the session. Either do not create checklists in the task plan, or explicitly assign the responsibility to mark them as done to whichever agent is executing that task (Builder, Verifier, DevOps). Unchecked checklists are noise and create false ambiguity about what was actually completed.

---

## 5. Agent Roles & Responsibilities

**[M+N]** The Builder wrote the acceptance tests. The Builder is responsible for source code and unit tests only. Acceptance tests — the scripts that verify requirements are met — must be produced by the Verifier (or co-produced by Analyst and Verifier) from the Given / When / Then specifications. A Verifier running tests authored by the Builder is not independent verification; it is the Builder checking its own work.

**[M]** The Orchestrator absorbed the Analyst, Auditor, Architect, Planner, Builder, and Verifier all as internal steps rather than visible turn boundaries. For Casual this is pragmatic, but it means per-agent artifact attribution is reconstructed from memory, not derived from actual hand-off events. The framework specifies hand-offs but does not specify whether they must be visible turn boundaries or can be internal Orchestrator steps. This must be clarified — it determines traceability at Commercial and above.

---

## 6. Demo Artefacts

**[M]** Verifier demo scripts were inconsistent in format — some scenarios were presented one-line, others multi-line, with no uniform structure. The format should be tabulated Given / When / Then with no visible border lines, as specified in section 2 above.

**[N]** Demo documents should be stored in `tests/demo/` to make explicit that they are Nexus-facing artefacts, separate from executable test scripts.

**[N]** All demo documents contained full local filesystem paths (e.g. `/Users/pablo/projects/Nexus-SDLC/tests/NexusScan/`). These must never appear in exported artefacts. All path references must be relative to the project base directory.

---

## 7. Version Control

**[N]** There was no version control policy during execution. No commits were made while the swarm was running. The process documents and `nexusscan.py` were the only history available after the session — it is impossible to reconstruct how the source code evolved across tasks, what changed between TASK-001 and TASK-006, or what the intermediate state of the implementation looked like after each task. The framework must define a commit policy: at minimum, a commit after each task passes verification. The Builder or Verifier must be responsible for executing it.

---

## 8. Resource File Location

**[N]** The resource templates (agent output templates) were installed inside the NexusScan project directory under `resources/`. They belong in `.claude/resources/`, at the same level as `.claude/agents/`, as part of the Nexus SDLC installation — not as part of any project being built. Projects should contain only their own artefacts.

---

## 9. Context Window Exhaustion

**[M]** The framework assumes continuous agent context. It has no checkpoint format, no resume protocol, and no instruction for the Orchestrator to serialize state before hitting a context limit. A context limit was hit between TASK-005 and the verification pass; the Nexus typed "continue" and the Orchestrator recovered by re-reading project state. That recovery worked this time. The framework should define: what the Orchestrator must write before context is exhausted, what the Nexus should say to resume, and what the Orchestrator must verify on resume to confirm no state was lost.

---

## Summary of Required Framework Changes

| # | Area | Change required | Owner |
|---|------|-----------------|-------|
| 1 | Intake | Define handling when brief arrives with calibration answer | Methodologist |
| 2 | Analyst | Require active elicitation, not passive clarification | Analyst |
| 3 | Acceptance specs | Mandate Given/When/Then format swarm-wide before any code | Analyst + Auditor |
| 4 | Gates | Apply one-question rule to all agents at gate boundaries | All |
| 5 | Requirements IDs | Define mid-cycle ID numbering rule | Orchestrator |
| 6 | Task plan | Declare cycles, assign tasks to cycles, schedule demos | Planner |
| 7 | Task plan | Remove checklists or assign done-marking responsibility | Planner |
| 8 | Test authorship | Acceptance tests authored by Verifier/Analyst, not Builder | Verifier |
| 9 | Builder scope | Builder owns source code and unit tests only | Builder |
| 10 | Demo artefacts | Store in `tests/demo/`; tabulated GWT format; relative paths only | Verifier |
| 11 | Version control | Commit after each task passes; Builder or Verifier responsible | Builder / Verifier |
| 12 | Resources | Install templates in `.claude/resources/`, not in project dirs | Install script |
| 13 | Context exhaustion | Define checkpoint, resume, and state-verification protocol | Orchestrator |
