# DEC-0008: Nexus SDLC Swarm Pattern — Hybrid Swarm

**Status:** Accepted (revised — C0-C3 taxonomy superseded by DEC-0013 profile names)
**Date:** 2026-03-12 (revised)
**Deciders:** Nexus Method Architect

## Context

The initial assessment used Crystal's C0-C3 scale for criticality and a Simple/Complex/Highly-Complex scale for architectural complexity. DEC-0013 introduced plain-language profile names (Casual/Commercial/Critical/Vital) that supersede the C0-C3 notation throughout the framework. This document retains the hybrid swarm pattern decision, which remains accurate, and updates the taxonomy references.

## Decision

### Framework-Level Assessment

**Criticality: Commercial to Critical (project-dependent)**

The framework is used across projects ranging from solo proof-of-concept (Casual) to regulated systems (Vital). The framework itself is designed to handle the full range. Per-project assessment is done by the Methodologist at project start.

**Complexity: Complex**

Multi-agent coordination, persistent artifact trails, human-in-the-loop gates, tool access control, profile-calibrated behavior — this is a distributed system with stateful orchestration. Not Highly Complex (no real-time constraints, no safety-critical hardware integration in the framework itself).

### Prescribed Swarm Pattern: Hybrid

- **Agile core:** The execution/verification cycle operates with fast feedback, minimal ceremony, and event-driven routing (XP influence).
- **Formal gates:** Phase transitions use architecture-gated milestones with explicit quality criteria and Nexus approval (RUP influence).
- **Empirical adaptation:** The Methodologist monitors swarm health and re-configures when trigger events occur (Scrum's empirical process control applied to an agent swarm).
- **Human-centric communication:** All Nexus-facing outputs use the Nexus Briefing format, optimized for cognitive efficiency (Crystal influence).

### Dominant Methodology by Phase

| Phase | Dominant Methodology | Rationale |
|---|---|---|
| Ingestion | Crystal | Intent elicitation, cognitive load management |
| Decomposition | RUP | Architecture-centric, risk-first prioritization |
| Requirements Gate | Scrum | Transparent inspection of requirements |
| Architecture Gate | RUP | Architecture integrity verification |
| Plan Gate | Scrum | Empirical review of proposed plan |
| Execution Cycle | XP | Engineering discipline, TDD, tight feedback |
| Verification Cycle | XP | Continuous verification, automated checks |
| Demo Sign-off | Crystal | Human-centric summary, trust calibration |
| Go-Live | RUP | Milestone quality gate for production |

### Per-Project Adaptation (via Methodologist)

| Profile | Adaptation |
|---|---|
| **Casual** | Minimal agents (Planner, Builder, Verifier), lighter artifacts, Plan Gate may be informal |
| **Commercial** | Full agent set minus Designer if no UI, Draft-weight artifacts, all gates active |
| **Critical** | Full agent set, Blueprint-weight artifacts, strict TDD, fitness functions required |
| **Vital** | Full agent set, Spec-weight artifacts, formal architecture baseline, signed-off fitness functions |

## Rationale

**Why hybrid over pure Agile:** The human gates (Requirements Gate, Architecture Gate, Plan Gate, Demo Sign-off, Go-Live) are inherently formal — they require structured artifacts and explicit approval. Pure Agile would underserve these moments.

**Why hybrid over pure Formal:** The execution/verification cycle benefits from speed and minimal ceremony. Formal gates within this loop would add overhead without value.

**Why per-project adaptation via the Methodologist:** The Methodologist is the agent responsible for right-sizing the swarm. The Manifest it produces configures the Orchestrator for the specific project profile. This is not a one-time decision — the Methodologist re-activates when the profile should change.

## Consequences

**Easier:**
- The framework serves projects from Casual to Vital without redesign
- Each phase uses the methodology best suited to its nature

**Harder:**
- The Methodologist must encode enough methodology knowledge to make good profile assessments
- The hybrid model is more complex to understand than a pure-style approach

**Newly constrained:**
- C0-C3 and Simple/Complex/Highly-Complex terminology is superseded by DEC-0013 profile names throughout the framework

## Alternatives Considered

**Pure Agile Swarm:** Insufficient rigor for the gates. Rejected.

**Pure Formal Swarm:** Crushing overhead for Casual and Commercial projects. Rejected.

**Fixed single pattern:** Does not accommodate the range from Casual to Vital. Rejected.
