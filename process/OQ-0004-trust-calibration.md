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

# OQ-0004: Trust Calibration — How Does the Nexus Develop Appropriate Trust in Agent Output?

**Status:** Open
**Date:** 2026-03-12
**Priority:** High

## Question

How does the human (Nexus) develop calibrated trust in swarm output over time? What signals should the framework provide to help the human know when to trust agent work and when to inspect more deeply? Can confidence signals from agents be made reliable enough to be useful?

## Why It Matters

The framework's value proposition depends on the human trusting agent output enough to approve plans and merge PRs without reviewing every line of code. But trust must be earned and calibrated:

- Over-trust leads to approving flawed plans or merging buggy code
- Under-trust leads to the human re-doing the agents' work, negating the framework's value
- Miscalibrated confidence signals (agent says "high confidence" but is frequently wrong) erode trust in the framework itself

This question affects:
- The content and format of gate briefings (Demo Sign-off Briefing, Go-Live Briefing, etc.)
- Whether the framework tracks and surfaces agent accuracy metrics over time
- The Demo Sign-off and Go-Live experience design

## Options Being Considered

**Option A — Track record metrics:**
The framework maintains per-agent accuracy metrics: how often does the Builder's output pass verification on first attempt? How often does the Planner's effort estimate match actual effort? These metrics are surfaced in gate briefings to give the human data-driven trust signals.

*Trade-offs:* Objective and improves over time. But requires several lifecycle completions before data is statistically meaningful. Cold-start problem.

**Option B — Confidence intervals on agent outputs:**
Each agent outputs a self-assessed confidence score. The framework calibrates these scores against actual outcomes over time and presents calibrated confidence in briefings.

*Trade-offs:* Fine-grained per-output trust signal. But LLM self-confidence is notoriously miscalibrated. Calibration requires outcome tracking which brings us back to Option A.

**Option C — Progressive autonomy:**
Start with tight human oversight (human reviews every task output, not just gates). As track record builds, progressively relax oversight to the standard gate model. The framework suggests autonomy level adjustments based on track record.

*Partial address:* The Demo Sign-off gate design already supports a form of evidence-based trust. The Nexus explores running software — not documents — using the Verifier's Demo Scripts. This means trust is built on observed behavior rather than agent self-reports. The question is whether this gate alone provides sufficient trust calibration, or whether additional signals are needed between gates.

*Trade-offs:* Safest onboarding experience. But the initial tight oversight negates the framework's value for early adopters. Risk that the "training wheels" period is too long or too short.

**Option D — Defer to v2:**
Ship v1 with the gate model and no trust calibration features. Gather user feedback on whether trust is a real problem in practice.

*Trade-offs:* Fastest to ship. But if trust calibration is a real barrier to adoption, v1 users may disengage before v2 arrives.

## Information Needed

1. **User research:** What is the target user's current trust model for AI-generated code? Do they review line-by-line or skim for patterns?

2. **Confidence calibration research:** Current literature on LLM self-confidence calibration. Are there techniques that make confidence scores more reliable?

3. **Adoption friction data:** From analogous tools (Copilot, Cursor, Devin), what is the primary barrier to adoption? Is it trust or something else?

## Blocking

- The Demo Sign-off Briefing format may need trust-related data fields
- The Orchestrator's per-project adaptation logic (DEC-0008) could use trust metrics as an input
