# DEC-0018: Spike Task Ownership and Lifecycle

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

Spike tasks exist to resolve architectural or technical unknowns that block safe planning or implementation. Two agents have natural claims on spikes: the Architect (who identifies the unknown) and the Planner (who manages the task sequence). Without clear ownership, spikes risk being open-ended, poorly scoped, or placed at the wrong point in the plan.

## Decision

Spike ownership is split across the lifecycle with clean handoffs:

```
ARCHITECT  →  identifies the unknown, writes the acceptance criterion,
              and specifies where the finding goes (Architect or Planner)
PLANNER    →  schedules the spike before the tasks that depend on its finding
BUILDER    →  runs the investigation, sends finding to the specified destination
ARCHITECT  →  interprets the finding; produces ADR if a decision is needed
              (only invoked if the Architect specified itself as the destination)
PLANNER    →  re-estimates affected tasks if scope or approach changed
```

### Architect's Responsibilities for a Spike

The Architect identifies a spike when analysis surfaces a high-risk unknown that blocks one or more tasks from being safely planned or built. For each spike, the Architect produces:

1. **The unknown** — what question must be answered
2. **The blocked tasks** — which tasks cannot proceed until the spike resolves
3. **The acceptance criterion** — the specific, answerable question that defines when the spike is done
4. **The finding format** — what the Builder should produce (benchmark result, reference citation, minimal prototype, comparison table)
5. **The finding destination** — where the Builder sends the completed finding: `Architect` if the finding will require an architectural decision (new or revised ADR), or `Planner` if the finding only affects task sizing or implementation approach. The Architect determines this at spike creation time because the Architect knows what kind of decision the finding will inform.

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
Finding goes to:  [Architect | Planner — resolved value, set by Architect at spike creation]
Risk:   High (by definition — if risk were low, no spike would be needed)
Value:  [Derived from the value of the blocked tasks]
```

Spikes are scheduled as early as possible — ideally before the first task that depends on them, and early enough that the finding can be incorporated into the plan without disrupting committed work.

### After the Spike

The Builder produces the finding document and sends it to the destination specified in the spike's `Finding goes to` field. This routing was determined by the Architect at spike creation time — the Builder follows the instruction, it does not make the routing judgment.

- **If routed to Architect:** The Architect interprets the finding and produces an ADR if a structural decision is needed. The new ADR may trigger re-ordering of affected tasks. The Architect then hands the finding (with any new ADR) to the Planner for re-estimation.
- **If routed to Planner:** The finding resolves a sizing or approach question without a structural decision. The Planner re-estimates the affected tasks and notes the revision.

If the spike finding reveals the unknown is larger than anticipated, the Architect may identify further spikes. These are treated as new spike tasks and scheduled before their dependent tasks.

## Rationale

**Why Architect writes the criterion, not the Planner:** The Architect knows what question needs answering and what evidence is sufficient. A criterion written without architectural knowledge risks being too vague ("research options") or measuring the wrong thing.

**Why the Planner schedules, not the Architect:** The Architect knows what needs to be known. The Planner knows when it needs to be known relative to everything else. Scheduling requires understanding the full task dependency graph — that is the Planner's domain.

**Why the Builder runs the spike, not the Architect:** The Architect's role is decision-making, not investigation. The Builder is the execution agent. Keeping the Architect as interpreter (not runner) preserves the separation between doing and deciding.

**Why the Architect sets the finding destination, not the Builder or Planner:** The Architect knows, at spike creation time, what kind of decision the finding will inform. A spike investigating whether a chosen technology meets a threshold will produce a sizing adjustment (route to Planner). A spike investigating which of several architectural options is viable will produce a structural decision (route to Architect). The Builder cannot make this judgment — it is an execution agent. The Planner cannot make it — it does not know the architectural implications. The routing must be set at creation time by the agent with the architectural context.

## Consequences

- The Architect agent definition must include spike identification and criterion writing as explicit responsibilities
- The Planner's task format must include the `Resolves` and `Needed before` fields for spike tasks
- Spikes always carry High risk in the priority matrix — they exist because of uncertainty
- The value of a spike is derived from the value of its blocked tasks — a spike blocking only low-value tasks is itself low value, and its necessity should be questioned
