# DEC-0016: Decomposition Phase and Gates

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

Between Ingestion and Execution there are two distinct human approval points and a phase involving both architectural judgment and task decomposition. These needed to be separated and defined clearly, including what the Nexus is actually approving at each gate and what criteria drive those decisions.

## Decision

### Two Separate Gates

The Nexus Check is not a single gate — it is two distinct gates with different purposes and different approval criteria.

**Gate 1 — Requirements Gate**
The Nexus approves the requirements as understood at this point in time. This is not approval of a complete specification. It is approval of enough to proceed to architecture and decomposition. The approval implicitly acknowledges:
- Big, high-risk, high-value requirements: understood and stable
- Medium requirements: known, details to emerge during decomposition
- Small/edge requirements: expected to surface during execution and demo cycles

**Gate 2 — Plan Gate**
The Nexus approves the architectural approach and task plan before execution begins. This gate may be lightweight (two Architect questions + a short task list) or formal (a full -ilities document + dependency graph), depending on the project profile.

### Gate Approval Criteria: Risk + Value

The Nexus cannot make a meaningful approval without understanding two things:

**Risk-driven:** What are the hardest, most uncertain parts of the system? These must be understood and either resolved or consciously deferred before approval. An unknown risk approved without acknowledgement becomes a hidden assumption that surfaces as a crisis.

**Value-driven:** What delivers the highest business value? Requirements and architectural decisions should be prioritized by value contribution. The system being built must deliver on what matters most.

The interaction of these two dimensions drives gate decisions:

| Risk | Value | Decision |
|---|---|---|
| High risk | High value | Must be resolved before Gate 1 or Gate 2 |
| High risk | Low value | Candidate for deferral or extraction as a separate effort |
| Low risk | High value | Proceed — straightforward high-value work |
| Low risk | Low value | Defer to later cycles or cut from scope |

An architectural decision that is technically hard but serves only a low-value part of the system is a candidate for deferral or separation — not a blocker. This keeps the critical path clean and prevents low-value complexity from blocking high-value delivery.

### The [DEFERRED] Auditor Flag

The Auditor's `[GAP]` flag has been insufficient — it conflates two different situations:

- A **problematic gap**: something missing that must be resolved before proceeding
- An **intentional deferral**: a known unknown consciously left for later, with a rationale

A new flag type is added to the Auditor's vocabulary:

**`[DEFERRED]`** — A known unknown that has been consciously left for a later cycle. Must include:
- What is being deferred
- Why it is acceptable to defer now (low risk, low value, or dependency not yet available)
- When it must be resolved (before Gate 2, before execution of a specific task, before demo, etc.)

`[DEFERRED]` items do not block gate approval. They are logged in the requirements trail and reviewed at each subsequent gate to confirm the deferral is still appropriate.

### The Decomposition Phase Structure

```
⬡ REQUIREMENTS GATE
        │
        ▼
   [ Architect ]
   Profile-calibrated depth:
   - Casual: 1-2 questions ("web, CLI, or mobile?")
   - Commercial: key architectural choices documented
   - Critical: full -ilities analysis
   - Vital: formal architecture review with risk register
        │
        ▼
   [ Planner ]
   Atomic tasks with back-references to requirements.
   Ordered by risk and value, not just dependency.
   Spike tasks for unresolved unknowns.
        │
        ▼
⬡ PLAN GATE
```

### The Architect in Casual Mode

In Casual profile, the Architect role collapses to its simplest form: a few orienting questions. This is consistent with XP's "simple design" principle — the simplest architecture that could possibly work, chosen just-in-time. The Architect in Casual mode is not writing a document; it is asking the Nexus one or two questions that prevent the Builder from making an irreconcilable choice later.

Example Casual Architect questions:
- "Is this a web app, a CLI tool, or something else?"
- "Does it need to persist data between sessions?"
- "Will anyone other than you use it?"

The answers shape the task plan without requiring explicit documentation. This is the architectural metaphor from XP: the structure emerges from constraints, not from specification.

### Architect Artifact Types by Profile

The Architect produces different artifacts at different profile weights:

| Profile | Artifact | Form | Location |
|---|---|---|---|
| **Casual** | Architecture Sketch / Metaphor | A brief analogy or one-paragraph description of the system's shape. "This is a local CLI tool — think of it as a notebook with a search index." Lives in the Task Plan header. | Embedded in Task Plan |
| **Commercial** | Architecture Overview | A short document covering key decisions: deployment model, data persistence, auth approach, main components and their relationships. One page. | `architect/architecture-overview.md` |
| **Critical** | Architecture Decision Records (ADRs) | One ADR per significant decision, each with context, decision, rationale, consequences, and -ility implications. Individually auditable. | `architect/ADR-NNNN-*.md` |
| **Vital** | ADRs + Architecture Baseline | Full ADR set plus a formal Architecture Baseline document that is signed off by the Nexus before the Plan Gate proceeds. Each -ility has explicit acceptance criteria. | `architect/ADR-NNNN-*.md` + `architect/baseline.md` |

The XP metaphor in Casual mode is intentional: Kent Beck's "system metaphor" practice — give the architecture a name or analogy that every team member (or agent) can reason from without reading a document. "It's a pipeline." "It's a ledger." "It's a chatbot backed by a file system." This shared metaphor guides implementation decisions implicitly.

## Rationale

**Why two gates instead of one:** The requirements and the plan answer different questions. Gate 1 asks "do we understand the problem?" Gate 2 asks "do we understand the approach?" These are distinct decisions with distinct approval criteria. Collapsing them forces the Nexus to either approve requirements without knowing the approach, or delay requirements approval until decomposition is complete — both of which create poor incentives.

**Why risk + value as gate criteria:** These are the two dimensions that determine whether a decision is load-bearing. A requirement or architectural choice that is neither risky nor valuable should not be blocking a gate. A requirement that is both high-risk and high-value must be resolved before proceeding. Framing gates this way gives the Nexus a principled basis for approval rather than a checklist.

**Why [DEFERRED] instead of treating all unknowns as blockers:** Not all unknowns are equal. Treating every unknown as a blocker creates analysis paralysis. The [DEFERRED] flag makes the deferral conscious and traceable — the unknown is acknowledged, its deferral is justified, and it is tracked for resolution. This is the assume-and-flag principle (DEC-0009) applied at the requirements level.

## Consequences

- The Auditor must be updated to support the `[DEFERRED]` flag type
- The Planner must order tasks by risk and value, not just dependency
- Gate 2 (Plan Gate) is profile-calibrated: Casual may be a 2-minute exchange; Vital is a formal review
- The Methodologist Manifest must specify which gates are active and what depth is expected at each
- The Architect is added to the agent taxonomy — profile-collapsed into the Planner for Casual, separate for Commercial and above

## Alternatives Considered

**Single gate covering both requirements and plan:** Simpler but creates a false choice — either rush the plan to get to the gate, or delay the gate waiting for a complete plan. Rejected for poor incentive structure.

**Value-only prioritization (no risk dimension):** XP uses value-driven ordering. But ignoring risk allows high-risk unknowns to hide behind high-value justifications until they surface as crises late in execution. Risk and value together produce a more honest prioritization. Rejected for incompleteness.

**No [DEFERRED] flag — all unknowns must be resolved:** Creates analysis paralysis on large systems where some details are genuinely not knowable upfront. The Lean principle of last responsible moment applies here — decide when you must, not before. Rejected for premature closure.
