# OQ-0009: What Does a Retrospective Mean in Each Profile?

**Status:** Open
**Date:** 2026-03-12
**Priority:** Medium

## Question

A Methodologist retrospective will mean something different depending on the project profile. What is the appropriate form, depth, and output of a retrospective at each level — Casual, Commercial, Critical, Vital?

## Why It Matters

The Methodologist re-activates at the end of major phases and on trigger events (DEC-0014). When it does, it performs some form of process reflection. But:

- A Casual/Sketch retrospective should not produce a 10-page process audit — that would be self-defeating
- A Vital/Spec retrospective probably requires formal documentation, stakeholder sign-off, and an auditable record
- The middle profiles (Commercial/Draft, Critical/Blueprint) need definitions that are neither too light nor too heavy

Until this is defined, the Methodologist agent definition file cannot specify what to produce when re-invoked.

## Options Being Considered

- **Casual:** A few informal bullet points — what worked, what to change, no formal artifact
- **Commercial:** A short structured note appended to the Manifest — key observations, any profile change recommendation
- **Critical:** A dedicated retrospective document with process metrics, escalation pattern analysis, and swarm configuration recommendations
- **Vital:** A formal process audit artifact — structured, signed off by the Nexus, archived alongside the Manifest version history

## Information Needed

- Observation of how retrospectives actually function as the project evolves (empirical)
- Whether the retrospective output feeds back into the *next* Manifest version or stands alone
- Whether agents other than the Methodologist contribute to the retrospective (e.g., the Orchestrator's escalation log as input)

## Blocking

- Methodologist agent definition file (cannot be fully written until retrospective behavior is specified)
- DEC-0014 retrospective section (currently deferred by design)
