# OQ-0007: Evaluation Harness — How to Measure Quality of a Prompt-Based Framework

**Status:** Open
**Date:** 2026-03-12 (reframed 2026-03-13)
**Priority:** Medium

## Question

How should the Nexus SDLC framework be evaluated? The deliverable is a collection of markdown agent definition files that a human loads into LLM sessions. There is no software runtime to unit-test, no state machine to fuzz, no API to benchmark. What does "quality" mean for this kind of artifact, and how do you detect regressions when the deliverable is structured prose?

## Why It Matters

Without an evaluation strategy, changes to agent prompts, process definitions, or handoff protocols are driven by intuition. There is no way to know whether a change to the Builder's behavioral principles improved or degraded implementation quality, whether a new escalation trigger in the Verifier actually catches the failure it targets, or whether a Methodology Manifest reconfiguration made the swarm more effective.

The framework's credibility — both to the Nexus and to anyone adopting it — depends on demonstrable evidence that it works.

## Options Being Considered

**Option A — Dogfooding (self-application):**
Use the Nexus SDLC framework to build a real project. Evaluate the framework by observing how well it performs across the full lifecycle: did the ingestion loop produce good requirements? Did the decomposition produce well-sized tasks? Did the Builder and Verifier converge efficiently? Did the Demo Sign-off feel like a useful checkpoint or a formality?

*Trade-offs:* Maximally realistic. Tests the full lifecycle against real complexity. But creates a bootstrap problem (the framework must be usable before it can be evaluated) and the evaluator (the Nexus) is also the framework designer, which introduces bias.

**Option B — Agent prompt quality review:**
Treat each agent definition file as a specification and evaluate it against defined quality criteria: Are the input/output contracts unambiguous? Are the behavioral principles consistent with each other and with the broader framework? Are the escalation triggers complete — do they cover the failure modes identified in DEC-0006? Are the profile variants consistently calibrated across agents?

*Trade-offs:* Can be done now, before any project uses the framework. Catches internal inconsistencies and specification gaps. But does not test whether well-specified prompts actually produce good agent behavior when loaded into an LLM.

**Option C — Scenario-based evaluation:**
Define a set of 5-10 realistic project scenarios (varying in profile, complexity, and domain) and walk through each scenario using the framework's process. For each scenario: invoke the agents in sequence, observe the outputs, and assess whether the process produced reasonable results. Score on dimensions like: requirements completeness, task sizing quality, iteration efficiency, escalation appropriateness, and Nexus cognitive load.

*Trade-offs:* Tests real agent behavior with real LLMs. Covers multiple project types. But expensive in time and LLM compute, and results are qualitative rather than quantitative.

**Option D — Regression through diffing:**
When a change is made to an agent definition file, re-run a fixed evaluation scenario before and after the change. Compare outputs. If the outputs diverge in ways that were not intended, the change may have introduced a regression. This is the prompt-engineering equivalent of a regression test suite.

*Trade-offs:* LLM outputs are non-deterministic, so exact diffing is not meaningful. Requires defining "equivalent" loosely — same structure, same decisions, same quality level — which is subjective. But even coarse before/after comparison is better than no regression signal at all.

**Option E — Combined approach:**
Start with Option B (prompt quality review) as a lightweight first pass. Use the framework on a real project (Option A) to generate empirical data. Define a small evaluation scenario set (Option C) based on patterns observed during dogfooding. Use before/after comparison (Option D) when making targeted changes to agent files.

*Trade-offs:* Most comprehensive but requires sustained effort. Appropriate if the framework is intended for long-term use and continued evolution.

## Information Needed

1. **Quality criteria for agent prompts:** What makes a good agent definition file? This needs to be defined before Option B is actionable. Candidates: contract completeness, behavioral consistency, escalation coverage, profile variant calibration.

2. **Dogfooding project:** Is there a real project ready to serve as the first evaluation target? The project should be small enough to complete but complex enough to exercise the full lifecycle (not just Casual profile).

3. **Regression tolerance:** How much non-deterministic variation in LLM output is acceptable before a change is flagged as a potential regression? This needs empirical calibration.

## Blocking

- No direct blockers on current design work
- The evaluation strategy should be defined before the framework is used on projects where quality matters (Commercial and above)
