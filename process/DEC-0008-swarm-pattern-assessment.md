# DEC-0008 — Hybrid Swarm Pattern

**Status:** Accepted
**Date:** 2026-03-12

## Context

The Nexus Method Architect tradition prescribes assessing every project on two dimensions — criticality and complexity — and then prescribing either an Agile Swarm, a Formal Swarm, or a Hybrid Swarm. This decision applies that assessment to the Nexus SDLC framework itself and establishes the baseline pattern that the Methodologist adapts per project.

The initial assessment used Crystal's C0-C3 scale and a Simple/Complex/Highly-Complex scale. DEC-0013 later introduced plain-language profile names (Casual/Commercial/Critical/Vital) that supersede the C0-C3 notation throughout the framework. The hybrid swarm pattern decision itself remains unchanged.

## Decision

### Framework-Level Assessment

**Criticality: Commercial to Critical (project-dependent)**

The framework serves projects across the full range — from solo proofs of concept (Casual) to regulated systems (Vital). The framework itself is designed to handle this range. Per-project assessment is performed by the Methodologist at project start.

**Complexity: Complex**

Multi-agent coordination, persistent artifact trails, human-in-the-loop gates, tool access control, profile-calibrated behavior — this is a distributed system with stateful orchestration. Not Highly Complex (no real-time constraints, no safety-critical hardware integration in the framework itself).

### Prescribed Swarm Pattern: Hybrid

The swarm operates as a hybrid of Agile and Formal practices, selected by phase:

- **Agile core:** The execution/verification cycle operates with fast feedback, minimal ceremony, and event-driven routing (XP influence).
- **Formal gates:** Phase transitions use architecture-gated milestones with explicit quality criteria and Nexus approval (RUP influence).
- **Empirical adaptation:** The Methodologist monitors swarm health and reconfigures when trigger events occur (Scrum's empirical process control applied to an agent swarm).
- **Human-centric communication:** All Nexus-facing outputs use the Nexus Briefing format, optimized for cognitive efficiency (Crystal influence).

### Dominant Methodology by Phase

| Phase | Dominant Methodology | Rationale |
|---|---|---|
| Ingestion | Crystal | Intent elicitation requires cognitive load management and cooperative communication |
| Decomposition | RUP | Architecture-centric analysis, risk-first prioritization |
| Requirements Gate | Scrum | Transparent inspection of requirements as understood |
| Architecture Gate | RUP | Architecture integrity verification before commitment |
| Plan Gate | Scrum | Empirical review of proposed plan against risk and value |
| Execution Cycle | XP | Engineering discipline, TDD, tight feedback loops |
| Verification Cycle | XP | Continuous verification, automated checks |
| Demo Sign-off | Crystal | Human-centric summary, trust calibration through running software |
| Go-Live | RUP | Milestone quality gate for production readiness |

### Per-Project Adaptation (via Methodologist)

| Profile | Adaptation |
|---|---|
| **Casual** | Minimal agents (Planner, Builder, Verifier). Sketch-weight artifacts. Plan Gate may be informal. Requirements Gate and Architecture Gate may be collapsed or skipped. |
| **Commercial** | Full agent set minus Designer if no UI. Draft-weight artifacts. All gates active. |
| **Critical** | Full agent set. Blueprint-weight artifacts. Strict TDD. Fitness functions required. Sentinel active every cycle. |
| **Vital** | Full agent set. Spec-weight artifacts. Formal Architecture Baseline. Signed-off fitness functions. Nexus explicitly signs off security posture at Demo Sign-off. |

## Reasoning

**Why hybrid over pure Agile:** The human gates (Requirements Gate, Architecture Gate, Plan Gate, Demo Sign-off, Go-Live) are inherently formal — they require structured artifacts and explicit approval. Pure Agile would underserve these moments. The Nexus making a Requirements Gate decision needs a structured Briefing, not an informal conversation.

**Why hybrid over pure Formal:** The execution/verification cycle benefits from speed and minimal ceremony. Formal gates within the iterate loop would add overhead without value. A Builder fixing a failing test does not need a change request.

**Why methodology varies by phase:** Different phases have different natures. Ingestion is a communication problem (Crystal). Decomposition is a structural analysis problem (RUP). Execution is an engineering discipline problem (XP). Matching the methodology to the phase's nature produces better outcomes than applying one methodology uniformly.

**Why per-project adaptation through the Methodologist:** The swarm pattern is a baseline, not a fixed configuration. Real projects sit at different points on the criticality and complexity spectra. The Methodologist's job is to read the project and calibrate the swarm — activating the right agents, setting the right artifact weight, and configuring the right gates. A fixed swarm pattern cannot serve both a weekend script and a medical device.

## Alternatives Considered

**Pure Agile Swarm:** Insufficient rigor for the gates. The Nexus needs structured information to make gate decisions. Rejected for under-serving decision quality.

**Pure Formal Swarm:** Crushing overhead for Casual and Commercial projects. A solo developer building a CLI tool does not need an Architecture Baseline or formal Audit Reports. Rejected for process bloat.

**Fixed single pattern (no per-project adaptation):** Does not accommodate the range from Casual to Vital. A pattern that works for Casual is reckless for Vital. A pattern that works for Vital is suffocating for Casual. Rejected for inflexibility.

**Let the Nexus choose the methodology per phase:** The Nexus should not need to understand RUP, XP, Scrum, and Crystal to use the framework. The methodology mapping is embedded in the agent definitions — the Nexus experiences the result (structured gates, fast execution, clear briefings) without needing to know which tradition it draws from. Rejected for imposing unnecessary methodology knowledge on the user.

## Consequences

- The framework serves projects from Casual to Vital without redesign.
- Each phase uses the methodology best suited to its nature.
- The Methodologist must encode enough methodology knowledge to make good profile assessments and swarm configurations.
- The hybrid model is more complex to understand than a pure-style approach — mitigated by the fact that the user does not need to understand the methodology mapping; it is embedded in the agent definitions.
- C0-C3 and Simple/Complex/Highly-Complex terminology from the initial assessment is superseded by the DEC-0013 profile names (Casual/Commercial/Critical/Vital) throughout the framework.
