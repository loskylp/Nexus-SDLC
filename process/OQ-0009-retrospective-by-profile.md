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

# OQ-0009: What Does a Retrospective Mean in Each Profile?

**Status:** Open
**Date:** 2026-03-12
**Priority:** Medium

## Question

A Methodologist retrospective will mean something different depending on the project profile. What is the appropriate form, depth, and output of a retrospective at each level — Casual, Commercial, Critical, Vital?

## Why It Matters

The Methodologist re-activates at every Demo Sign-off (methodologist.md Responsibilities). When it does, the Orchestrator hands control with one question: "Is there anything you want to change for the next iteration?" If yes, the Methodologist runs a focused retrospective with the Nexus and updates the Manifest before the next cycle begins.

But:

- A Casual retrospective should not produce a 10-page process audit — that would be self-defeating
- A Vital retrospective probably requires formal documentation, stakeholder sign-off, and an auditable record
- The middle profiles (Commercial, Critical) need definitions that are neither too light nor too heavy

The current methodologist.md describes the retrospective trigger and general behavior but does not specify what the Methodologist produces at each profile level when re-activated. The Manifest output format is profile-weighted ("a Casual project's Manifest is a Sketch; a Vital project's Manifest is a Spec"), but the retrospective observation and analysis step that precedes the Manifest update is not specified per profile.

## Options Being Considered

- **Casual:** The Nexus answers the Orchestrator's question ("anything to change?"). If yes, a brief conversation with the Methodologist — a few bullet points on what to adjust. Updated Manifest Sketch. No standalone retrospective artifact.
- **Commercial:** A short structured retrospective note appended to the Manifest change log — key observations from the cycle, any profile change recommendation, iterate-loop efficiency observations.
- **Critical:** A dedicated retrospective section in the Manifest update — process metrics (iteration counts, escalation frequency, gate pass rates), escalation pattern analysis, swarm configuration recommendations for the next cycle.
- **Vital:** A formal retrospective artifact — structured, signed off by the Nexus, archived alongside the Manifest version history. Includes all of Critical plus compliance-relevant process observations and audit trail completeness verification.

## Information Needed

- Observation of how retrospectives actually function as the project evolves (empirical)
- Whether the retrospective output feeds back into the *next* Manifest version or stands alone
- Whether agents other than the Methodologist contribute to the retrospective (e.g., the Orchestrator's escalation log as input)

## Blocking

- The methodologist.md Responsibilities section describes retrospective triggers but not per-profile output format — this OQ fills that gap
- DEC-0014 retrospective section (currently deferred by design)
