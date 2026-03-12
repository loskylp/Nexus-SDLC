# DEC-0008: Nexus SDLC Swarm Pattern — Hybrid Swarm

**Status:** Proposed
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

Before designing any swarm, two dimensions must be assessed:
- **Criticality (Crystal scale):** What is the cost of failure?
- **Complexity (RUP scale):** What is the architectural complexity?

Nexus SDLC is not a single project — it is a framework that will be used across projects of varying criticality and complexity. However, the framework itself must be designed to a standard that accounts for its most demanding use cases while remaining right-sized for simpler ones.

## Decision

### Framework-Level Assessment

**Criticality: C1 (loss of money) — trending toward C2 for some use cases**

Rationale: Nexus SDLC agents will write, modify, and deploy code in production software projects. Faulty agent behavior can introduce bugs, security vulnerabilities, or architectural degradation that costs money to fix. For projects where the framework manages infrastructure or security-sensitive code, criticality approaches C2 (loss of essential money). The framework does not directly control life-safety systems (C3), though it could theoretically be used in that context — which would require additional safeguards beyond what we design here.

**Complexity: Complex (not Highly Complex)**

Rationale: The framework involves multi-agent coordination, persistent state management, human-in-the-loop gates, and tool access control. This is a distributed system with stateful orchestration — clearly beyond "Moderate." However, it does not involve real-time constraints, regulatory compliance requirements, or safety-critical hardware integration that would push it to "Highly Complex."

### Prescribed Swarm Pattern: Hybrid

- **Agile core:** The inner EXECUTE-VERIFY-ITERATE loop operates with fast feedback, no documentation overhead beyond reasoning traces, and event-driven handoffs (XP/CI influence).
- **Formal gates:** Phase transitions (DECOMPOSE->NEXUS CHECK, INTEGRATE->NEXUS MERGE) are architecture-gated milestones with explicit quality criteria (RUP influence).
- **Empirical adaptation:** The Orchestrator monitors swarm health metrics and can trigger methodology adjustments (instantiate new agent roles, adjust iterate bounds, consolidate outputs). This is Scrum's empirical process control applied to an agent swarm.
- **Human-centric communication:** All human-facing outputs use the Strategic Briefing format, optimized for cognitive efficiency (Crystal influence).

### Dominant Methodology by Phase

| Phase | Dominant Methodology | Rationale |
|---|---|---|
| DEFINE | Crystal | Human communication, intent elicitation, cognitive load management |
| DECOMPOSE | RUP | Architecture-centric decomposition, risk-first prioritization |
| NEXUS CHECK | Scrum | Empirical review, transparent inspection of proposed plan |
| EXECUTE | XP | Engineering discipline, tight feedback loops, TDD |
| VERIFY | XP | Continuous integration, automated verification |
| ITERATE | XP + Scrum | Fast iteration with empirical bounds checking |
| INTEGRATE | RUP | Architecture integrity verification, milestone quality gate |
| NEXUS MERGE | Crystal | Human-centric summary, trust calibration |

### Per-Project Adaptation

When Nexus SDLC is deployed on a specific project, the Orchestrator should assess that project's criticality and complexity and adjust:

- **C0/Simple:** Reduce Tier 4 restrictions, skip Security agent, use shorter Strategic Briefings
- **C2/Complex:** Add mandatory architecture review at INTEGRATE, increase max_iterations, require dual verification (two independent QA runs)
- **C3/Highly Complex (if ever):** Add formal verification agent, require human review at EXECUTE (per-task), full audit trail with tamper-evident logging

## Rationale

**Why Hybrid over pure Agile:** The human gates at NEXUS CHECK and NEXUS MERGE are inherently formal — they require structured artifacts and explicit approval. Pure Agile would underserve these moments. The formality at gates ensures the human gets high-quality information to make decisions.

**Why Hybrid over pure Formal:** The EXECUTE-VERIFY-ITERATE loop benefits from speed and minimal ceremony. Formal gates within this loop would add overhead without value — the agents are already producing structured verification reports. The value of formality is at phase boundaries, not within the execution engine.

**Why per-project adaptation:** A framework that demands the same rigor for a personal script as for a financial system is over-engineered for the former and appropriately-engineered for the latter. The adaptation rules make the framework viable across the criticality spectrum.

## Consequences

**Easier:**
- The framework can serve projects from C0 to C2 without redesign
- Each phase uses the methodology best suited to its nature
- The Orchestrator has clear guidelines for when to add or reduce rigor

**Harder:**
- Per-project adaptation requires the Orchestrator to make judgment calls about criticality and complexity
- The hybrid model is more complex to implement than a pure-style approach
- Documentation must describe both the default behavior and the adaptation rules

**Newly constrained:**
- The framework's default configuration must target C1/Complex as baseline
- Any C3 deployment would require explicit extensions beyond the current design

## Alternatives Considered

**Pure Agile Swarm:** Lightweight, fast, minimal documentation. Works for C0-C1/Simple but provides insufficient rigor for the framework's intended use cases (production software development with autonomous agents). Rejected for insufficient safety.

**Pure Formal Swarm:** Maximum rigor, mandatory reviews at every stage, full documentation. Appropriate for C3 but adds crushing overhead for typical use cases. The framework would be slower than manual development for small projects. Rejected for excessive overhead.

**Fixed pattern (no per-project adaptation):** Simpler to implement but forces every project into the same mold. A personal utility script does not need Security agent review. A financial application does. Rejected for one-size-fits-all inflexibility.
