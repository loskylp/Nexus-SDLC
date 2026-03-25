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

# DEC-0031: Post-Deployment Smoke Test

**Status:** Accepted
**Date:** 2026-03-24
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

The framework's Go-Live gate (DEC-0002) confirms that the Nexus approves production deployment, and DevOps Phase 3 (DEC-0024) validates that the production environment is provisioned, monitoring is wired, and rollback is tested. However, after the release tag is pushed and the image is promoted to production, the only verification is an infrastructure health check — a `/api/health` endpoint returning HTTP 200.

A healthy container is not a healthy application. A health check confirms the process started and can respond to HTTP. It does not confirm that the application can authenticate a user, persist a record, or execute any business operation. Production regressions caused by environment-specific configuration (missing variables, wrong database endpoint, permission mismatches, third-party service connectivity) pass health checks while breaking actual functionality.

This gap was identified as **GAP-3** in the production bug tracking audit. The framework needed a post-deployment verification step that proves the application works, not just that it runs.

The Verifier already produces Demo Scripts as part of the Demo Sign-off gate (DEC-0002). These scripts describe the happy-path scenarios for every task in the cycle — they are human-readable walkthroughs of acceptance-tested behavior. A subset of these scripts, covering basic end-to-end operations, is a natural source for a production smoke suite.

## Decision

**After every production deployment, DevOps executes a two-stage post-deployment verification: an infrastructure health check followed by an application-level smoke test sourced from Demo Scripts. This verification occurs after the release tag pipeline completes and before the Go-Live gate closes.**

### What the Smoke Test Covers

The smoke test has two stages, run sequentially:

**Stage 1 — Infrastructure health check (existing):**
- Health endpoint returns HTTP 200
- Application process is running
- Database connectivity confirmed (if applicable)
- This is the fail-fast gate — if infrastructure is broken, there is no point running application-level checks

**Stage 2 — Application smoke suite:**
- A curated subset of Demo Scripts executed against the live production environment
- Each smoke scenario exercises a basic end-to-end operation: the kind of thing a real user would do in the first five minutes (e.g., log in, create a record, read the record back, verify the expected response)
- Smoke scenarios prove the application stack is functioning through its public interface — not just that containers respond to pings
- The smoke suite is not a full regression suite — it is a minimal confidence check that the deployment did not break fundamental operations

### Who Owns What

**Architect** declares which categories of demo scenarios are smoke-eligible. At the Architecture Gate, the Architect identifies the core user operations that must work in production for the system to be considered functional. These are typically: authentication, primary CRUD operations on the main domain entities, and any critical integration points. The Architect does not write the smoke scripts — they declare the coverage scope.

**Verifier** maintains the smoke suite. At each Demo Sign-off gate, the Verifier reviews the cycle's Demo Scripts and tags smoke-eligible scenarios with `smoke: true` in the demo script frontmatter. The selection criteria are:
- The scenario exercises a core operation identified by the Architect
- The scenario is self-contained — it does not depend on state left by a prior scenario
- The scenario can run safely against production without creating test pollution (or includes its own cleanup)
- The scenario is idempotent or uses clearly identifiable test data that can be cleaned up

**DevOps** executes the smoke suite after production deployment. DevOps does not author or modify smoke scenarios — it runs them and reports results. DevOps is responsible for:
- Configuring the smoke runner to target the production environment
- Executing Stage 1, then Stage 2 if Stage 1 passes
- Reporting pass/fail per scenario to the Orchestrator
- Triggering the appropriate failure response (see below)

**Orchestrator** gates Go-Live closure on the smoke result. The Go-Live gate does not close until DevOps reports a smoke PASS. If smoke fails, the Orchestrator follows the failure response protocol below.

### When It Runs

The smoke test runs **after the release tag pipeline completes and before the Go-Live gate closes**. This makes it the final confirmation step within the Go-Live gate, not a post-gate afterthought.

The sequence within Go-Live is:
1. Nexus approves Go-Live (existing)
2. DevOps pushes release tag (existing, DEC-0024 Phase 3)
3. Pipeline promotes image to production (existing)
4. DevOps runs Stage 1 — infrastructure health check (existing, now formalized)
5. DevOps runs Stage 2 — smoke suite against live production (new)
6. DevOps reports smoke result to Orchestrator (new)
7. Go-Live gate closes on smoke PASS (new gate condition)

This placement ensures the Nexus has approved the deployment intent before it happens, and that the deployment is verified before the gate closes. The Go-Live gate remains open until smoke passes — it is not a separate gate.

### Failure Response

Failure handling is differentiated by stage:

**Stage 1 failure (infrastructure):**
- **Response:** Automated rollback to the previous known-good release
- **Rationale:** Infrastructure failure (container won't start, database unreachable) is unambiguous. The deployment is broken at a level that cannot be diagnosed through the application. Rollback is the correct immediate response.
- **Escalation:** After rollback completes, DevOps reports to the Orchestrator. The Orchestrator surfaces a Nexus Briefing (DEC-0006 format) with the failure details. This is an **Incident (Production)** failure mode — the Nexus chooses the track (next-cycle or hotfix).

**Stage 2 failure (smoke scenario fails):**
- **Response:** Halt. Do NOT rollback automatically.
- **Rationale:** A smoke failure means the application started but a business operation is broken. This could be a configuration issue fixable without rollback (missing env var, wrong feature flag), a data migration issue that rollback would make worse, or an actual code regression. Automatic rollback on a smoke failure risks masking the problem or compounding it (e.g., rolling back a database migration that has already run forward).
- **Escalation:** DevOps reports to the Orchestrator with the failing scenario name, the expected vs. actual result, and any relevant logs. The Orchestrator surfaces a Nexus Briefing with:
  - Which smoke scenario(s) failed
  - The expected behavior (from the Demo Script)
  - The actual behavior observed
  - The question: "Rollback to previous release, or investigate and fix forward?"
- The Nexus decides. This aligns with DEC-0006's principle that the Orchestrator routes but does not decide on ambiguous production situations.

### How the Smoke Suite Is Defined and Updated

**Initial creation:** When the first cycle's Demo Scripts are produced, the Verifier tags smoke-eligible scenarios. The initial smoke suite is reviewed by the Nexus at the first Demo Sign-off gate as part of the demo review.

**Per-cycle update:** At each Demo Sign-off gate, the Verifier reviews new Demo Scripts and updates smoke tags. Scenarios for features that are no longer smoke-relevant (superseded, removed, or covered by a broader scenario) have their `smoke: true` tag removed. The smoke suite evolves with the application.

**Review checkpoint:** The current smoke suite is listed in the Go-Live Briefing so the Nexus can see what will be verified post-deployment. The Nexus may request additions or removals before approving Go-Live.

**Demo Script tagging format:**

```markdown
---
task: TASK-NNN
title: [scenario title]
smoke: true
---
```

### Profile Scaling

| Profile | Stage 1 (Infra health) | Stage 2 (Smoke suite) | Failure response |
|---|---|---|---|
| Casual | Health check only — acceptable as the sole post-deployment verification. No formal smoke suite. | Not required. | Manual — no automated rollback at Casual. |
| Commercial | Required. | Minimum one smoke scenario covering the primary user operation. | Stage 1 fail: automated rollback. Stage 2 fail: halt and escalate. |
| Critical | Required. | Full smoke suite — all Architect-declared core operations covered. | Stage 1 fail: automated rollback. Stage 2 fail: halt and escalate. |
| Vital | Required. | Full smoke suite. Smoke results included in the formal release package. | Stage 1 fail: automated rollback. Stage 2 fail: halt and escalate. Smoke failure triggers a mandatory incident review regardless of resolution path. |

## Rationale

**Why inside the Go-Live gate rather than after it:** A post-gate check creates an ambiguous state — the gate is "closed" (signaling success) but the system may be broken. Keeping the smoke test inside the gate means Go-Live closure is an honest signal: the application is deployed AND verified. The Nexus does not need to check back later.

**Why not a full regression suite in production:** The Verifier's full test suite runs against staging at Demo Sign-off. Re-running it against production would be slow, create test data pollution, and exercise scenarios that are not meaningful as a deployment health check (e.g., negative test cases, boundary conditions). The smoke suite is a minimal confidence check: can the application do its basic job?

**Why differentiated failure responses:** Infrastructure failures are unambiguous — rollback is safe and correct. Application-level failures are ambiguous — the cause might be config, data, or code, and rollback might compound the problem (e.g., forward-only database migrations). The human should decide because the human has context the swarm does not.

**Why Demo Scripts as the source:** Demo Scripts are already written, already tested against staging, already reviewed by the Nexus, and already describe the happy-path behavior in human-readable form. Using them as the smoke source avoids creating a parallel set of production verification scripts that would drift from the tested behavior.

**Why the Architect declares smoke scope:** The Architect has the system-level view of which operations are load-bearing. A Verifier looking at individual tasks might tag too many scenarios (noise) or miss a critical integration point that spans multiple tasks. The Architect's declaration provides the strategic filter.

## Consequences

- The Go-Live gate gains a new closure condition: smoke PASS
- DevOps Phase 3 responsibilities expand to include smoke execution
- The Verifier gains a responsibility to tag Demo Scripts with `smoke: true` at Demo Sign-off
- The Architect gains a responsibility to declare smoke-eligible operation categories at the Architecture Gate
- The Go-Live Briefing must include the current smoke suite listing
- The Orchestrator must hold the Go-Live gate open until the smoke result is received
- A new failure mode is implicitly added to DEC-0006's taxonomy: **Smoke Failure** — detection: DevOps post-deployment smoke report; response: halt, do not rollback, Nexus escalation with scenario details and "rollback or fix-forward?" question
- Demo Script template gains an optional `smoke: true` frontmatter field

## Alternatives Considered

**Run smoke tests before promoting to production (in staging only):** This is already done — the Demo Sign-off gate exercises the full demo suite against staging. But staging-production parity is never perfect (DEC-0024 acknowledges this). A test that passes in staging and fails in production is exactly the gap this decision addresses. Rejected as insufficient on its own.

**Always rollback on any post-deployment failure:** Simple and safe for infrastructure failures. Dangerous for application-level failures where database migrations or external state changes may have already occurred. A blanket rollback policy assumes all failures are reversible, which is not true. Rejected for application-level failures.

**Separate smoke test gate after Go-Live:** Creates a gap between "Go-Live approved" and "deployment verified." During that gap the system is live but unverified. Also creates process overhead — another gate to manage, another briefing to produce. Keeping smoke inside Go-Live is simpler and more honest. Rejected.

**No smoke test — rely on production monitoring to catch issues:** Monitoring detects symptoms (latency spikes, error rate increases) after users encounter them. A smoke test detects broken functionality before users do. Monitoring is necessary but not sufficient as a deployment verification mechanism. Rejected as sole strategy.
