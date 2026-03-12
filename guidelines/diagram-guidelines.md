# Diagram Guidelines

Mermaid diagram standards for all agents that produce visual output embedded in Markdown documents.

---

## Visual Communication Principles

These principles govern every diagram produced by any agent in the pipeline. They address *why* a diagram succeeds or fails as a communication tool, independently of the technology used to render it.

### 1. Match abstraction level to audience

Every diagram has an intended reader. A diagram pitched at the wrong zoom level communicates nothing regardless of how accurate it is. Four levels exist; each serves a different reader and answers a different question:

| Level | Reader | Question answered |
|---|---|---|
| **Context** | Business stakeholders, product owners | Who uses the system and what external systems does it connect to? |
| **Container / Topology** | Engineering team, architects | What services, databases, and deployment tiers exist and how do they communicate? |
| **Component** | Developers working on a specific service | What are the internal parts of this container and how do they collaborate? |
| **Sequence / Detail** | Developers debugging or implementing a specific scenario | How do things interact step by step for this exact flow? |

Produce one diagram per level that the audience requires. Do not combine levels in one diagram.

### 2. Color encodes information, not decoration

Color is a data channel. Every color choice must carry a meaning that is consistent across all diagrams in the same output document:

- Use color to encode tier (cloud / edge / machine), role (operator / supervisor / system), or status (active / warning / complete).
- Do not use color for visual appeal. Decorative color trains readers to ignore it and wastes the channel.
- Assign colors before drawing. Establish the encoding in a `classDef` block and apply it uniformly.

### 3. What you leave out is as important as what you include

An overloaded diagram communicates less than a sparse one. Every element added to a diagram is a claim on the reader's attention. If an element does not help the reader answer the diagram's stated question, remove it.

- If a label requires a full sentence to be understood, the diagram structure is carrying responsibilities that belong in prose.
- If a diagram needs a legend longer than three items, it has too many distinct element types.
- Absence is visible: a system context diagram that omits the ERP integration tells the reader the ERP does not exist. Only omit what is truly irrelevant.

### 4. Diagrams go stale — minimize to maintain

The more detail a diagram holds, the sooner it becomes inaccurate. Favour structural diagrams (context, topology) over detail diagrams (component, sequence) for long-lived documentation. When detail diagrams are required:

- Scope them to a single scenario or decision.
- Label them with the version or date they reflect if the system is evolving rapidly.
- Prefer diagrams that survive refactoring (context, topology) over diagrams that require updates on every code change (component internals, sequence steps).

### 5. One diagram, one decision

A diagram that exists to justify or communicate an architectural or design decision should contain exactly the information that makes that decision visible — nothing more. If the reader needs surrounding context to understand why certain elements appear, that context belongs in the decision record prose, not in the diagram itself.

---

## Core Rule: One Concern Per Diagram

Every diagram answers exactly one question. A reader should understand the diagram's subject from its title alone without needing to study the image.

**Prefer multiple focused diagrams over one complex image.** A system with a context view, a container view, and a data flow view should produce three separate diagrams — not one combined image. Each diagram answers a single question:

| Question | Diagram |
|---|---|
| Who are the actors and external systems? | System context |
| What services and databases exist, and how are they deployed? | Container / topology |
| How does data move through the system end-to-end? | Data flow |
| What screens does a user navigate through? | Navigation flow (per role) |
| What are the valid states of an entity and how does it transition? | State lifecycle |
| How do services interact over time for a specific scenario? | Sequence |

If a single diagram covers more than one of these questions, split it.

---

## When to Split

Split one diagram into two or more when any of these conditions are met:

- **Node count exceeds 8** — diagrams become unreadable; split by concern or by tier
- **Two distinct subject matters appear** — actors and services belong in separate diagrams
- **A tier boundary is crossed more than twice** — draw one diagram per tier plus one cross-tier flow diagram
- **Happy path and exception paths compete for space** — draw the happy path first, then a separate diagram for exceptions and error flows
- **A reader needs to study the diagram** rather than read it — the diagram has failed; simplify or split

---

## Diagram Type Selection

| Need | Correct type | Do NOT use |
|---|---|---|
| System context (actors + external systems) | `flowchart` with `subgraph` boundaries | `C4Context` — no size control in Mermaid |
| Deployment topology (services + databases + tiers) | `flowchart` with `subgraph` boundaries | `C4Container` — same problem |
| State lifecycle ≤ 5 states, no self-loops, no annotations | `stateDiagram-v2` | — |
| State lifecycle with annotations, self-transitions, or > 5 states | `flowchart` with terminal circle nodes | `stateDiagram-v2` — elements miniaturise; self-loops corrupt layout |
| User navigation flow | `flowchart TD` | — |
| Data flow across tiers | `flowchart TD` | — |
| Service interactions over time | `sequenceDiagram` | — |

---

## Direction

- **`flowchart LR`** — linear lifecycles with ≤ 6 nodes where left-to-right maps to time or progression. Breaks in narrow render panes.
- **`flowchart TD` (default)** — use for everything else: navigation flows, branching paths, data flows, anything with more than 6 nodes. Safe at any render width.

When in doubt, use `TD`.

---

## Label Syntax Rules

| Rule | Correct | Wrong |
|---|---|---|
| Line breaks in node labels | `["Line one<br/>Line two"]` | `["Line one\nLine two"]` — renders as literal `\n` |
| Line breaks in edge labels | `\|"Line one<br/>Line two"\|` | `\|"Line one\nLine two"\|` |
| Times and ratios in `stateDiagram-v2` transition text | `13h00`, `3-to-1` | `13:00`, `3:1` — colon breaks the parser |
| Self-transitions | Describe looping behaviour in the node label text | `A --> A : label` — renders as two-headed connector artefact |
| Visual separators inside labels | `─` single character | `─────────────────` long unicode runs — render as literal characters |

---

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `C4Context` / `C4Container` diagram types | Elements shrink to unreadable size with more than ~5 nodes | Replace with `flowchart` + `subgraph` |
| Nested states in `stateDiagram-v2` | Forces miniaturisation of the entire diagram | Flatten — describe nested behaviour in node annotations or a separate diagram |
| Self-loop arrow `A --> A` in state diagrams | Renders as two connectors pointing in opposite directions | Move the description into the node label |
| `\n` in any node or edge label | Renders as the literal two-character string `\n` | Use `<br/>` |
| Unicode separator runs (`─────`) inside labels | Render as raw character sequences | Use a single `─` or a `<br/>` |
| One diagram covering multiple abstraction levels | Confuses readers — each level has a different audience | Split by the abstraction level table above |
| Decorative color with no encoding meaning | Trains readers to ignore color entirely | Assign color per tier, role, or status — never per aesthetics |
| Labels that need a sentence to be understood | The diagram structure is carrying prose responsibilities | Move the explanation to the surrounding Markdown text |

---

## Flowchart State Lifecycle Template

Use this pattern when `stateDiagram-v2` is insufficient (annotations needed, self-transitions present, more than 5 states):

```
flowchart LR (or TD)

    classDef state    fill:...,stroke:...,color:...,font-weight:bold
    classDef terminal fill:...,stroke:...,color:...

    S((" ")):::terminal          ← solid start circle

    STATE_A["🔤 Status Label<br/>─<br/>Key invariant or description<br/>What is true in this state"]:::state

    E((" ")):::terminal          ← solid end circle

    S          -->|"Actor / trigger"| STATE_A
    STATE_A    -->|"Condition met"| STATE_B
    STATE_B    -->|"Rejection"| STATE_A   ← reverse transition drawn explicitly, not as self-loop
    STATE_LAST --> E
```

The `─` single character after the status label acts as a lightweight separator between the label and the description lines inside the node.
