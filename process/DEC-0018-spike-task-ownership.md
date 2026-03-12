# DEC-0018: Spike Task Ownership and Lifecycle

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

Spike tasks exist to resolve architectural or technical unknowns that block safe planning or implementation. Two agents have natural claims on spikes: the Architect (who identifies the unknown) and the Planner (who manages the task sequence). Without clear ownership, spikes risk being open-ended, poorly scoped, or placed at the wrong point in the plan.

## Decision

Spike ownership is split across the lifecycle with clean handoffs:

```
ARCHITECT  →  identifies the unknown and writes the acceptance criterion
PLANNER    →  schedules the spike before the tasks that depend on its finding
BUILDER    →  runs the investigation
ARCHITECT  →  interprets the finding; produces ADR if a decision is needed
PLANNER    →  re-estimates affected tasks if scope or approach changed
```

### Architect's Responsibilities for a Spike

The Architect identifies a spike when analysis surfaces a high-risk unknown that blocks one or more tasks from being safely planned or built. For each spike, the Architect produces:

1. **The unknown** — what question must be answered
2. **The blocked tasks** — which tasks cannot proceed until the spike resolves
3. **The acceptance criterion** — the specific, answerable question that defines when the spike is done
4. **The finding format** — what the Builder should produce (benchmark result, reference citation, minimal prototype, comparison table)

### Acceptance Criterion Standard

```
Bad:  "Research database options"
      → No exit condition, no definition of done

Good: "Document which of the three candidate approaches
       satisfies NFR-003 (response time < 200ms at 10k
       concurrent users), with evidence from a minimal
       benchmark or authoritative reference."
      → Clear question · clear answer format · clear done condition
```

A spike criterion must answer: what question is being asked, and what evidence counts as an answer?

### Planner's Responsibilities for a Spike

The Planner schedules the spike as a first-class task using the standard TASK format with one addition — a `Resolves` field:

```
SPIKE-NNN: [Short title of unknown]
Requirement(s): [NFR or architectural concern that drives this]
Resolves:       [The unknown, as stated by the Architect]
Needed before:  [TASK-NNN, TASK-NNN — tasks blocked on this finding]
Acceptance criterion: [Copied from Architect's spike spec]
Finding goes to:  Architect (if architectural decision needed)
                  Planner only (if sizing or approach clarification)
Risk:   High (by definition — if risk were low, no spike would be needed)
Value:  [Derived from the value of the blocked tasks]
```

Spikes are scheduled as early as possible — ideally before the first task that depends on them, and early enough that the finding can be incorporated into the plan without disrupting committed work.

### After the Spike

The Builder produces the finding document. It goes to:

- **Architect** — if the finding requires an architectural decision. The Architect produces an ADR. The new ADR may trigger re-ordering of the affected tasks.
- **Planner only** — if the finding resolves a sizing or approach question without a structural decision. The Planner re-estimates the affected tasks and notes the revision.

If the spike finding reveals the unknown is larger than anticipated, the Architect may identify further spikes. These are treated as new spike tasks and scheduled before their dependent tasks.

## Rationale

**Why Architect writes the criterion, not the Planner:** The Architect knows what question needs answering and what evidence is sufficient. A criterion written without architectural knowledge risks being too vague ("research options") or measuring the wrong thing.

**Why the Planner schedules, not the Architect:** The Architect knows what needs to be known. The Planner knows when it needs to be known relative to everything else. Scheduling requires understanding the full task dependency graph — that is the Planner's domain.

**Why the Builder runs the spike, not the Architect:** The Architect's role is decision-making, not investigation. The Builder is the execution agent. Keeping the Architect as interpreter (not runner) preserves the separation between doing and deciding.

## Consequences

- The Architect agent definition must include spike identification and criterion writing as explicit responsibilities
- The Planner's task format must include the `Resolves` and `Needed before` fields for spike tasks
- Spikes always carry High risk in the priority matrix — they exist because of uncertainty
- The value of a spike is derived from the value of its blocked tasks — a spike blocking only low-value tasks is itself low value, and its necessity should be questioned
