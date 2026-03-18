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
-->

# DEC-0021: Context Exhaustion Checkpoint Protocol

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

LLM context windows are a hard physical constraint of the framework's runtime. Unlike traditional software where process state persists in a database or runtime between sessions, the Nexus SDLC's state exists only in the artifact trail and the current conversation context. When context is exhausted, the conversation is lost.

Without an explicit protocol, the Nexus must manually reconstruct the project state from the artifact trail on resume — a time-consuming and error-prone process that violates Crystal's principle of minimizing human cognitive load.

## Decision

When any agent session approaches context exhaustion, the Orchestrator writes a self-sufficient checkpoint to `process/orchestrator/project-state.md` before the session ends.

**The checkpoint records:**
- Current phase
- Active task ID (or gate being processed)
- Which agent holds control
- Decisions made since the last commit
- What happens next (the specific action and routing the Orchestrator would have taken)

**Self-sufficiency constraint:** The checkpoint must be readable cold — by someone who has never seen the prior conversation and has no access to it. It cannot reference "the decision we just made" or "the issue we were discussing" — it must name the decision and the issue explicitly. This is the difference between a bookmark and a checkpoint.

**On resume:** The Orchestrator reads the checkpoint, confirms it is intact, and explicitly states what was recovered before routing any agent.

### Continuation Prompt

When resuming after context exhaustion, the Nexus invokes the Orchestrator in continuation mode with:

```
@nexus-orchestrator Continuation mode. Context was exhausted in the previous session.
Load process/orchestrator/project-state.md. Confirm the checkpoint is intact and state
explicitly what was recovered — current phase, active task, controlling agent, and next
action — before routing anything.
```

This prompt signals to the Orchestrator that it must perform a checkpoint verification pass before taking any action, rather than simply summarizing state and waiting for a gate decision.

## Rationale

**Why self-sufficient:** A checkpoint that references prior context is useless when context is gone. The entire value of the protocol is that the Nexus can restart with an empty session, load only the Orchestrator prompt and `process/orchestrator/project-state.md`, and know exactly where to continue. Any dependency on the prior conversation defeats this.

**Why a dedicated continuation prompt:** The standard resume prompt (`@nexus-orchestrator Resuming. Load project-state.md and tell me where we are.`) is appropriate for planned session boundaries. Context exhaustion is different — the Orchestrator may have been mid-routing when it wrote the checkpoint, and the continuation mode prompt signals that the Orchestrator must verify and confirm the checkpoint state before acting, not just summarize it.

**Why the Orchestrator writes it:** The Orchestrator is the only agent with a complete picture of project state at any moment. Individual specialist agents (Builder, Verifier, etc.) do not have the full context needed to write a useful checkpoint.

**Why project-state.md, not a separate file:** The checkpoint is not a separate artifact — it is an update to the living project-state document. Git history preserves the prior state. The checkpoint is the current state.

**Relationship to OQ-0003:** OQ-0003 addresses the broader question of context loading strategy across agent invocations. DEC-0021 addresses the narrower, already-settled question of what to do when context runs out during a session. DEC-0021 does not close OQ-0003.

## Consequences

- The Orchestrator prompt includes the checkpoint protocol as Behavioral Principle 8 (already in place)
- The project-state.md template must support checkpoint fields: phase, active task, controlling agent, pending decisions, next action
- The Nexus can resume any interrupted session by loading the Orchestrator prompt and project-state.md — all other artifacts are loaded on demand based on what the checkpoint says to do next
- The protocol applies to planned session boundaries (end of day) as well as unexpected exhaustion
- See DEC-0020 (Commit Policy): uncommitted working tree state during the iterate loop must be described in the checkpoint, since it cannot be inferred from commit history

## Alternatives Considered

**Manual reconstruction from artifact trail:** Functional for short projects but requires the Nexus to scan all process artifacts to determine state. Does not scale as the artifact trail grows.

**Periodic auto-checkpoints on a timer:** Rejected. The framework has no runtime — the Orchestrator is an LLM agent, not a process. The checkpoint must be written by the Orchestrator when it determines context is approaching exhaustion, not on a schedule.
