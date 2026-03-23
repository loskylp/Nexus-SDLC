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

# DEC-0002 — Lifecycle Phases and Human Gates

**Status:** Accepted
**Date:** 2026-03-12

## Context

The framework needs a lifecycle structure that defines when agents operate, when the human intervenes, and what transitions are possible. The initial proposal described eight phases (DEFINE, DECOMPOSE, NEXUS CHECK, EXECUTE, VERIFY, ITERATE, INTEGRATE, NEXUS MERGE) with two mandatory human gates and one conditional. This was a reasonable first sketch but collapsed distinct decisions into single gates and assumed a linear release model.

Through collaborative design, the lifecycle was reshaped: the single Nexus Check was split into three gates with distinct purposes (Requirements, Architecture, Plan). The Ingestion phase was defined as a distinct multi-pass loop with the Auditor (see DEC-0015). The Integrator was removed. "Nexus Merge" was replaced by two separate decisions — Demo Sign-off (per-cycle feature approval) and Go-Live (release decision, decoupled from the cycle, with three trigger modes matching different CD philosophies). The retrospective was embedded at Demo Sign-off through the Methodologist (see DEC-0014).

## Decision

### Phases

**1. Ingestion** — Analyst elicits requirements and produces the Brief and Requirements List. Auditor validates in a multi-pass loop: every issue triggers a clarification question to the Nexus; the Analyst incorporates the answer; the Auditor re-checks everything. The loop continues until the Auditor produces a clean pass. Ingestion re-opens after every Demo Sign-off when the Nexus introduces new requirements or changes.

**2. Decomposition** — Architect produces architecture artifacts calibrated to the project profile (from a one-line metaphor in Casual to ADRs with an Architecture Baseline in Vital). Auditor performs an architectural audit. Planner produces the Task Plan with atomic tasks ordered by risk and value, spike tasks for unresolved unknowns. Designer and Scaffolder are invoked when the project requires them.

**3. Execution Cycle** — Builder implements atomic tasks one at a time. Independent tasks (no dependency edges in the task DAG) may execute concurrently.

**4. Verification Cycle** — Verifier and Sentinel run concurrently. Verifier runs all test layers and produces Verification Reports and Demo Scripts. Sentinel performs dependency review and live security testing against staging and produces the Security Report. Both report to the Orchestrator.

**5. Go-Live** — DevOps deploys to production. Scribe produces documentation and release notes. Decoupled from the execution/verification cycle — may target any previously signed-off version, not necessarily the most recent cycle.

### Human Gates

**Requirements Gate** — The Nexus approves the requirements as understood at this point. This is not approval of a complete specification — it is approval of enough to proceed. Big, high-risk requirements must be understood and stable. Smaller requirements may surface during execution cycles and demo discovery.

**Architecture Gate** — After the Architect produces artifacts and the Auditor performs an architectural audit, the Orchestrator prepares an Architecture Gate Briefing. The Nexus approves the architectural approach before planning begins. This is a separate decision from requirements approval: "do we understand the approach?" is distinct from "do we understand the problem?"

**Plan Gate** — After the Planner produces the Task Plan, the Nexus approves the task decomposition, prioritization (by risk and value), and any spike tasks. Profile-calibrated depth: Casual may be a two-minute exchange; Vital is a formal review.

**Demo Sign-off** — At the end of each execution/verification cycle, the Nexus reviews the Verification Summary, the Security Summary, and the Demo (assembled Demo Scripts the Nexus follows to explore running software). Approval authorizes the next cycle. After Demo Sign-off, the Orchestrator hands control to the Methodologist with one question: "Is there anything you want to change for the next iteration?" If yes, the Methodologist reconfigures the swarm before the next cycle begins.

**Go-Live Gate** — Decoupled from Demo Sign-off. Triggered by the CD philosophy declared in the Methodology Manifest:

| CD Philosophy | Trigger |
|---|---|
| **Continuous Deployment** | Automatically triggered when CI is green — no human gate |
| **Continuous Delivery** | Triggered at Demo Sign-off — release happens when features are approved |
| **Cycle-based** | Triggered by the Nexus at any time, against any previously signed-off version |

The Cycle-based model means the Nexus may choose to release a version from January in March, despite additional work completed since. The version released is the specific signed-off version the Nexus selects.

### Gate-Approval Autonomy

When the Nexus approves a gate, that approval authorises the **entire subsequent phase** to execute autonomously. The Orchestrator proceeds through all agent invocations, iterate loops, and sub-phase transitions without returning to the Nexus — until the next gate boundary or an escalation trigger (DEC-0006).

Examples:
- **Plan Gate approval** → the Orchestrator invokes DevOps Phase 1 (if active), Builder for each task in the current cycle, Verifier after each Builder output, and iterates up to `max_iterations` — all autonomously. The Nexus re-enters at Demo Sign-off.
- **Requirements Gate approval** → the Orchestrator invokes the Architect, then the Auditor for an architectural audit, then the Planner — all autonomously, without a Nexus prompt between agents.
- **Architecture Gate approval** → Designer (if active), Scaffolder (if active), and Planner proceed in sequence — all autonomously.

The Nexus re-enters only at the next gate in the sequence or on an escalation trigger. Autonomy within a phase is a deliberate design choice: the cost of invoking the Nexus at every agent transition is higher than the cost of running a phase to completion and presenting a structured gate briefing. The Human-in-the-Middle principle applies at gate boundaries, not at every agent invocation within a phase.

### Iterate Loop

Within a cycle, the iterate loop is bounded by the Manifest's max_iterations. If verification does not converge, the Orchestrator escalates to the Nexus. A convergence signal (non-decreasing failure count across consecutive iterations) triggers early escalation when thrashing is detected.

### Security Blocking Condition

Critical or High findings from Sentinel block Demo Sign-off. The Orchestrator enforces this condition — a cycle with unresolved blocking security findings is not ready to present to the Nexus.

## Reasoning

**Why three pre-execution gates instead of one:** The original single Nexus Check collapsed three distinct decisions. The Requirements Gate asks "do we understand the problem?" The Architecture Gate asks "do we understand the approach?" The Plan Gate asks "do we agree on what to build first?" These decisions are made at different times with different information. Collapsing them forces the Nexus to either approve requirements without knowing the approach, or delay requirements approval until planning is complete — both create poor incentives.

**Why Demo Sign-off is separate from Go-Live:** Feature approval and release decisions have different triggers, different audiences, and different consequences. A Nexus may approve features every two weeks (Demo Sign-off) but choose to release to production only quarterly (Go-Live). Separating the gates makes this natural rather than exceptional.

**Why three CD philosophy models:** Continuous Deployment, Continuous Delivery, and Cycle-based cover the full range of delivery practices observed in real teams. The framework does not prescribe a release cadence — it supports whichever the Nexus and Methodologist declare. The Cycle-based model reflects a reality Agile frameworks often obscure: the decision to release is sometimes organizational, regulatory, or market-driven, not technical.

**Why the retrospective lives at Demo Sign-off:** The end of a working cycle — when software has been built, tested, and demonstrated — is the natural moment to ask "is our process working?" Embedding it structurally ensures retrospectives happen. Without a structural trigger, retrospectives do not happen.

**Why no auto-approval for any gate:** A gate waiting for the Nexus waits. The cost of waiting is lower than the cost of executing on a misaligned decision. Gates that auto-approve under time pressure undermine the Human-in-the-Middle principle.

## Alternatives Considered

**Single Nexus Check (initial proposal):** Combined requirements approval and plan approval into one gate. Created the false choice of either rushing the plan to reach the gate or delaying requirements approval until planning was complete. Replaced.

**Nexus Merge (initial proposal):** A single release gate that combined feature approval with production deployment. Could not accommodate the three CD philosophy models — a team using Continuous Deployment does not want a human gate at release time; a team using Cycle-based release does not want to couple release timing to feature sign-off. Replaced by Demo Sign-off + Go-Live.

**No retrospective gate:** Retrospectives would only happen when the Nexus explicitly requested them. Experience across Scrum and Crystal teams demonstrates that optional retrospectives do not happen. Embedding the retrospective at Demo Sign-off makes process improvement a standing feature of the lifecycle. Rejected for practical reasons.

**Eight phases with Integrator (initial proposal):** The INTEGRATE phase assumed a separate Integrator agent for branch integration and merge assembly. This was removed when the Integrator's functions were found to overlap entirely with the Orchestrator and DevOps. Replaced.

## Consequences

- Each gate has a distinct purpose and distinct approval criteria — the Nexus knows what they are deciding at each point.
- The Go-Live model is declared upfront in the Methodology Manifest — no ambiguity about when production deployment happens.
- Retrospectives are embedded — process improvement happens naturally at every cycle boundary.
- Three pre-execution gates add ceremony before Builder work begins — justified by the cost of executing on misaligned requirements, wrong architecture, or poorly ordered plans.
- The Nexus must be available at five gate types — though Demo Sign-off and Go-Live may be automated or deferred depending on CD philosophy and profile.
- The Orchestrator must track which gates are active (declared in the Manifest) and enforce entry criteria for each, including the Sentinel security blocking condition.
