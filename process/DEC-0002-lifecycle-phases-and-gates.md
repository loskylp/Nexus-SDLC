# DEC-0002: Lifecycle Phases and Human Gates

**Status:** Accepted (revised)
**Date:** 2026-03-12 (revised substantially through conversation)
**Deciders:** Nexus Method Architect (initial proposal); Nexus (Human) shaped the gate structure

## Context

The initial proposal described an 8-phase lifecycle (DEFINE, DECOMPOSE, NEXUS CHECK, EXECUTE, VERIFY, ITERATE, INTEGRATE, NEXUS MERGE) with two mandatory human gates and one conditional. Through conversation this evolved substantially: the single Nexus Check was split into three gates with distinct purposes; the ingestion phase was defined as a distinct multi-pass loop; the Integrator was removed; "Nexus Merge" was replaced by two separate decisions — Demo Sign-off (per-cycle feature approval) and Go-Live (release decision, decoupled, with three trigger modes); and the retrospective was embedded at Demo Sign-off with the Methodologist.

## Decision

### Phases

**1. Ingestion**
Analyst elicits requirements and produces the Brief and Requirements List. Auditor validates in a multi-pass loop — every issue triggers a clarification question to the Nexus; the Analyst incorporates the answer and the Auditor re-checks everything. The loop continues until the Auditor produces a clean pass. Ingestion re-opens after every Demo Sign-off when the Nexus introduces new requirements.

**2. Decomposition**
Architect produces architecture artifacts calibrated to the project profile. Auditor performs an architectural audit (UNCOVERED, INCONSISTENCY, UNGROUNDED, INADEQUATE). Planner produces the Task Plan — atomic tasks ordered by risk and value, spike tasks for unresolved unknowns. Scaffolder optionally produces code structure when invoked.

**3. Execution Cycle**
Builder implements atomic tasks, one at a time. Independent tasks may execute concurrently. Each task produces implementation artifacts and a handoff note.

**4. Verification Cycle**
Verifier and Sentinel run concurrently. Verifier runs all test layers; produces Verification Report and Demo Script per task. Sentinel performs dependency review and live security testing against staging; produces Security Report. Both report to the Orchestrator.

**5. Go-Live**
DevOps deploys to production. Scribe produces documentation and release notes. Decoupled from the execution/verification cycle — may target any previously signed-off version, not necessarily the most recent cycle.

### Human Gates

**Requirements Gate**
The Nexus approves requirements before decomposition begins. This approves enough to proceed — not a complete specification. Big, high-risk requirements must be understood and stable; smaller requirements may surface during execution cycles and demo discovery.

**Architecture Gate**
After the Architect produces artifacts and the Auditor performs an architectural audit, the Orchestrator prepares an Architecture Gate Briefing for the Nexus. The Nexus approves the architectural approach before planning begins. This is a separate decision from requirements approval — "do we understand the approach?" is distinct from "do we understand the problem?"

**Plan Gate**
After the Planner produces the Task Plan, the Nexus approves the task decomposition, prioritization (by risk and value), and any spike tasks. Profile-calibrated depth: Casual may be a two-minute exchange; Vital is a formal review with a signed-off Architecture Baseline.

**Demo Sign-off**
At the end of each execution/verification cycle, the Nexus reviews:
- The Verification Summary (test results per layer)
- The Security Summary (Sentinel's report — Critical or High findings block this gate)
- The Demo (assembled Demo Scripts — the Nexus follows these to explore the running software)

Approval authorizes the next cycle. After Demo Sign-off, the Orchestrator hands control to the Methodologist with one question: "Is there anything you want to change for the next iteration?" If yes, the Methodologist reconfigures the swarm before the next cycle begins. If no, the next cycle proceeds directly.

**Go-Live Gate**
Decoupled from Demo Sign-off. Triggered by the CD philosophy declared in the Methodology Manifest:

| CD Philosophy | Trigger |
|---|---|
| **Continuous Deployment** | Automatically triggered when CI is green — no human gate at this step |
| **Continuous Delivery** | Triggered at Demo Sign-off — the release happens when features are approved |
| **Cycle-based** | Triggered by the Nexus at any time, against any previously signed-off version |

The Cycle-based model means the Nexus may choose to release a version from January in March, despite additional work completed since. The version being released is the specific signed-off version the Nexus selects — not necessarily the latest cycle.

### Iterate Loop

Within a cycle, the iterate loop is bounded by the Manifest's max_iterations. If verification does not converge, the Orchestrator escalates to the Nexus. The convergence signal (non-decreasing failure count across consecutive iterations) triggers early escalation when thrashing is detected.

## Rationale

**Why three pre-execution gates instead of one:** The original single Nexus Check collapsed three distinct decisions. The Requirements Gate asks "do we understand the problem?" The Architecture Gate asks "do we understand the approach?" The Plan Gate asks "do we agree on what to build first?" These are answered at different times with different information — collapsing them creates false choices.

**Why Demo Sign-off is separate from Go-Live:** Feature approval and release decisions have different triggers, different audiences, and different consequences. A Nexus may approve features every two weeks (Demo Sign-off) but choose to release to production only quarterly (Go-Live). Separating the gates makes this natural.

**Why three CD philosophy models:** Continuous Deployment, Continuous Delivery, and Cycle-based cover the full range of delivery practices without prescribing one. The framework serves projects at all points on the deployment frequency spectrum.

**Why the retrospective lives at Demo Sign-off:** The end of a working cycle — when software has been built, tested, and demonstrated — is the natural moment to ask "is our process working?" The Methodologist re-activates every cycle to answer this question, not only at project start.

**Why no auto-approval:** A gate waiting for Nexus response waits. The cost of waiting is lower than the cost of executing on a misaligned decision.

## Consequences

**Easier:**
- Each gate has a distinct purpose and distinct approval criteria
- The Go-Live model is declared upfront in the Methodology Manifest — no ambiguity about when production deployment happens
- Retrospectives are embedded — process improvement happens naturally, not as a project-end exercise

**Harder:**
- Three pre-execution gates add ceremony before any Builder work begins
- The Nexus must be available at five gate types, not two — though Demo Sign-off and Go-Live may be automated depending on CD philosophy

**Newly constrained:**
- The Orchestrator must track which gates are active (declared in the Manifest) and enforce entry criteria for each
- Demo Sign-off is blocked if Sentinel has unresolved Critical or High findings — the Orchestrator enforces this condition

## Alternatives Considered

**Single Nexus Check (initial proposal):** Combined requirements approval and plan approval into one gate. Created the false choice of either rushing the plan to get to the gate, or delaying requirements approval until planning was complete. Replaced.

**Nexus Merge (initial proposal):** A single release gate that combined feature approval with production deployment. Replaced by Demo Sign-off + Go-Live to support the three CD philosophy models.

**No retrospective gate:** Retrospectives would only happen when the Nexus explicitly requested them. Rejected — without a structural trigger, retrospectives don't happen. Embedding it at Demo Sign-off makes it a standing feature of the process.
