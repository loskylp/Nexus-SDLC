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

# DEC-0018: Spike Task Ownership and Lifecycle

**Status:** Accepted (revised — spike execution moved from Builder to Architect)
**Date:** 2026-03-12 (revised)
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

The initial version stated "BUILDER → runs the investigation." Through conversation, the user corrected this: the Architect is the appropriate agent to run spikes. Spike output is architectural — a FINDING.md that routes to either a new ADR (structural decision) or a Planner sizing update. The investigation requires architectural judgment about what counts as evidence, what the finding means, and what architectural decision follows. A Builder sent into architectural territory would produce findings it is not positioned to evaluate.

Two additional design details were added: spikes live in their own isolated `spikes/SPIKE-NNN/` directories to keep throwaway investigation code away from source code, and the FINDING.md format was formalized to make routing explicit.

## Decision

Spike ownership is held by the Architect throughout:

```
ARCHITECT  →  identifies the unknown; writes the acceptance criterion;
              specifies where the finding routes (Architect or Planner)
PLANNER    →  schedules the spike as SPIKE-NNN before the tasks that depend on it
ARCHITECT  →  runs the investigation in spikes/SPIKE-NNN/
ARCHITECT  →  produces spikes/SPIKE-NNN/finding.md
ARCHITECT  →  routes the finding:
                - to self → produces ADR if a structural decision is needed
                - to Planner → if only task sizing or approach is affected
PLANNER    →  re-estimates affected tasks if scope or approach changed
```

### Spike Directory Structure

Each spike lives in its own isolated directory: `spikes/SPIKE-NNN/`

Contents:
- Any throwaway code, scripts, benchmarks, or references used in the investigation
- `spikes/SPIKE-NNN/finding.md` — the Architect's finding document

Spike code never enters `src/`. It is investigative and disposable. The Verifier does not run tests against spike code.

### Finding Format

```markdown
# Spike Finding — SPIKE-NNN: [Short title]
**Date:** [date] | **Routes to:** [Architect (ADR) | Planner (sizing)]

## Answer
[Direct answer to the acceptance criterion's question]

## Evidence
[What was done, what was measured or found — enough to audit the conclusion]

## Implications
[What this means for the architecture or task sizing]

## Routes to
[Architect → [ADR-NNNN title] to be produced | Planner → re-estimate [TASK-NNN, TASK-NNN]]
```

### Architect's Responsibilities for a Spike

The Architect identifies a spike when analysis surfaces a high-risk unknown that blocks safe planning. For each spike the Architect produces:
1. The unknown — what question must be answered
2. The blocked tasks — which tasks cannot proceed until the spike resolves
3. The acceptance criterion — the specific, answerable question that defines done
4. The finding destination — Architect (if the finding will produce an ADR) or Planner (if it only affects sizing)

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

### Planner's Responsibilities for a Spike

Schedules the spike as a first-class task (SPIKE-NNN) with standard fields plus:

```
SPIKE-NNN: [Short title of unknown]
Requirement(s): [NFR or architectural concern that drives this]
Resolves:       [The unknown, as stated by the Architect]
Needed before:  [TASK-NNN, TASK-NNN]
Acceptance criterion: [Copied from Architect's spike spec]
Finding goes to: [Architect | Planner]
Risk:   High (by definition)
Value:  [Derived from the value of the blocked tasks]
```

Spikes are scheduled before the first task that depends on them.

### After the Spike

- **If routed to Architect:** Architect interprets the finding and produces an ADR if a structural decision is needed. The ADR may trigger task re-ordering. Architect hands the finding (with any new ADR) to the Planner for re-estimation and notifies the Orchestrator.
- **If routed to Planner:** The finding resolves a sizing question. Planner re-estimates affected tasks and notes the revision.

If the finding reveals the unknown is larger than anticipated, the Architect may identify further spikes.

## Rationale

**Why the Architect runs the spike, not the Builder:** Spike output is architectural. The investigation requires judgment about what evidence is sufficient, what architectural decision the finding informs, and what follow-on work is needed. The Builder is an execution agent — it implements against contracts; it does not evaluate architectural options. Sending a Builder into architectural territory produces findings the Builder cannot evaluate.

**Why spikes/ is isolated from src/:** Spike code is throwaway investigation, not production code. Keeping it out of `src/` prevents it from being mistaken for implementation, prevents Verifier tests from running against it, and makes the architectural trail clean.

**Why FINDING.md, not a free-form note:** The finding routes to a specific destination (Architect or Planner). A structured format makes the routing explicit and the evidence auditable. The "Routes to" field eliminates ambiguity about what happens next.

**Why the Architect sets the routing destination at spike creation:** The Architect knows at creation time what kind of decision the finding will inform — structural (routes to Architect for ADR) or sizing (routes to Planner). The Builder cannot make this judgment; the Planner cannot make it. The routing must be set by the agent with the architectural context.

## Consequences

- The Architect agent definition includes spike execution as an explicit responsibility and Tier 2 tool permission
- The `spikes/` directory is a conventional project location alongside `src/`, `tests/`, `docs/`
- Spikes always carry High risk — they exist because of uncertainty
- The value of a spike derives from the value of its blocked tasks

## Alternatives Considered

**Builder runs the spike (initial version):** Replaced because spike investigation requires architectural judgment the Builder does not have.

**Architect identifies but Planner schedules and Builder runs:** Creates a split that breaks the clean ownership. The Architect needs to control the investigation because the Architect evaluates the findings. Rejected for unclear accountability.
