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

# DEC-0023: Backward Cascade Protocol

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

The framework's gate rejection handling only routed forward — an Architecture Gate rejection sent the revision back to the Architect and then forward through the Auditor. No agent was responsible for detecting whether an architectural revision had invalidated assumptions in the already-approved Requirements List.

The concrete failure scenario: if the Architecture Gate rejects a proposal and the revised architecture changes the delivery channel (e.g., from Web App to API-only), every acceptance scenario written for a web UI is now based on a false premise. The Analyst wrote those scenarios assuming a channel that no longer holds. The Auditor's forward architectural re-audit would not catch this — it checks the revised architecture against the requirements, not whether the requirements are still valid given the revised architecture.

## Decision

**When an Architecture Gate rejection results in an Architect revision that changes a foundational assumption, the Orchestrator triggers a backward impact check before the gate is re-attempted.**

**Foundational assumptions** are the architectural decisions that acceptance scenarios are most likely to depend on:
- Delivery channel (Web, Mobile, Desktop, CLI, API, TUI)
- Deployment model (on-premise, cloud-hosted, serverless, embedded)
- Auth/identity model (who authenticates, how, and what permissions exist)
- Data persistence strategy (relational, document, event-sourced, no persistence)
- System boundary (what is inside vs. outside the system)

**The backward impact check protocol:**

1. The Orchestrator detects that a foundational assumption has changed in the revised architecture
2. The Orchestrator routes to the Auditor with an explicit **backward impact check instruction** alongside the standard re-audit instruction
3. The Auditor runs the standard architectural re-audit AND checks the approved Requirements List for acceptance scenarios that depend on the changed foundational assumption
4. The Auditor flags any invalidated scenarios as `[INVALIDATED]` with the changed assumption named
5. If `[INVALIDATED]` flags are present, the Auditor does not issue an Architectural PASS — it reports to the Orchestrator
6. The Orchestrator routes the invalidated requirements to the Analyst for revision before the gate is re-attempted
7. If no foundational assumption changed, the standard re-audit proceeds without the backward impact check

## Rationale

**Why scoped to foundational assumptions, not all revisions:** Most Architecture Gate rejections are amendments within the existing structural frame — the database schema changes, the API design is adjusted, a caching strategy is revised. These do not invalidate acceptance scenarios. A general backward cascade that fires on every gate rejection would be process bloat — it would re-open the requirements phase on routine architectural revisions. Scoping to foundational assumptions keeps the protocol proportional.

**Why the Orchestrator detects, not the Auditor:** The Orchestrator has the full project state and knows what the prior approved architecture said. Comparing "what changed" requires access to the prior approved state. The Auditor receives the current artifacts and cannot easily detect what changed between versions unless explicitly told.

**Why the Auditor runs the impact check, not the Analyst:** The Auditor's role is checking integrity and consistency between artifacts. Detecting that a requirement's acceptance scenario depends on a now-changed assumption is an integrity check — the requirement is internally consistent but no longer consistent with the revised architecture. The Analyst would need to be re-invoked only if invalidated requirements need revision — that is a separate step after the Auditor's detection.

### Routing After Backward Impact Check

After the Analyst revises the invalidated requirements (step 6 above), the revised requirements re-enter the standard ingestion loop — not the full ingestion cycle:

1. The Analyst produces revised requirements for the `[INVALIDATED]` items only
2. The Auditor runs a **targeted re-audit**: checks the revised requirements plus any requirements that trace to the same foundational assumption that changed. It does not re-audit the full Requirements List.
3. On clean Auditor pass, the Architecture Gate retry proceeds with both the revised architecture and the updated requirements in scope
4. If the targeted re-audit surfaces new issues (revised requirements introduce inconsistencies), the Analyst revises again before the targeted re-audit repeats

The backward impact check adds at most one Analyst + Auditor pass before the Architecture Gate retry under the happy path. It does not re-open the full ingestion loop, does not require a new Requirements Gate approval (unless the scope of invalidated requirements is so large that the Nexus is effectively re-approving requirements — in that case the Orchestrator presents a targeted Requirements Gate refresh rather than a full gate).

## Consequences

- The Orchestrator must compare architectural revisions against the prior approved architecture to detect foundational assumption changes — this requires reading both versions from the artifact trail
- The Auditor gains a new operational mode (backward impact check) with a new flag type (`[INVALIDATED]`)
- At Casual profile, there is no Architecture Gate and no Auditor-run architectural audit — this protocol does not apply
- False positives (the Orchestrator incorrectly identifies a foundational assumption change) result in an unnecessary backward check; the Auditor will return no `[INVALIDATED]` flags and the gate proceeds normally — the cost is one extra Auditor pass

## Alternatives Considered

**General backward cascade on every gate rejection:** Every rejection at any gate re-opens all upstream phases. This is RUP at its worst — process rigor that serves the process rather than the project. It would make gates prohibitively expensive and discourage the Nexus from using rejection to improve quality. Rejected.

**No backward cascade:** Requirements approved at the Requirements Gate are never revisited unless the Nexus explicitly raises a change. This is the prior state. The risk is that an architectural revision silently invalidates requirements that remain "approved" but are now built on a false premise. The Builder would implement against invalid acceptance scenarios and the Verifier would write tests for behaviors that the revised architecture cannot support. Rejected.
