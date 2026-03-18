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

# DEC-0024: DevOps Phased Invocation

**Status:** Accepted
**Date:** 2026-03-18
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

The DevOps agent was described as handling CI/CD pipeline setup, environment provisioning, and production monitoring — but the framework had no explicit routing rule for *when* DevOps was invoked relative to other agents. The Orchestrator knew to expect a production readiness signal before Go-Live, but had no instruction to invoke DevOps Phase 1 before the first Builder task, or Phase 2 after the first Verifier PASS.

Without explicit sequencing, two failure modes were possible:
1. The Builder starts without a CI pipeline — commits have nowhere to land and no automated validation
2. Staging is provisioned before anything is verified — paying infrastructure cost before it is needed

Both contradict Continuous Delivery principles (Humble & Farley): the deployment pipeline must exist before the first line of feature code, and environments should be provisioned just-in-time.

## Decision

**DevOps is invoked in three phases at Commercial and above, with explicit timing for each phase.**

**Phase 1 — Before any Builder task begins:**
- CI pipeline setup
- Development environment configuration
- Environment Contract (names and purposes of all environment variables the application uses)

Phase 1 is a hard prerequisite for Builder work. The Builder programs against the Environment Contract and its commits land on the CI pipeline. Neither can exist without Phase 1.

**Phase 2 — After the first Builder task passes Verifier:**
- Staging environment provisioning
- CD pipeline to staging (automatic deploy of verified builds)

Staging is provisioned only when there is something verified to deploy. This eliminates the cost and complexity of maintaining a staging environment against an unverified, rapidly changing codebase. The Verifier's system tests require a running staging environment — Phase 2 must complete before the Verifier can run system tests on subsequent tasks.

**Phase 3 — Before the Go-Live gate:**
- Production environment provisioning
- Production monitoring configuration against fitness function thresholds
- Fitness function instrumentation and alerting
- Rollback verification (confirm the rollback procedure works before it is needed)

Phase 3 produces the **DevOps production readiness signal** that the Orchestrator requires before issuing the Go-Live Briefing. Production is provisioned only when a Go-Live is imminent — not speculatively in advance.

**The Planner tags DevOps tasks by phase** so the Orchestrator can enforce just-in-time sequencing. The Orchestrator enforces the phase ordering.

## Rationale

**Why just-in-time provisioning:** Environments are infrastructure costs. Standing up staging before anything is verified means paying for an environment that will change rapidly and may be replaced if early Builder tasks reveal architectural issues. Provisioning staging after the first verified build means the environment stabilizes around code that has already passed acceptance criteria.

**Why Phase 1 is a hard prerequisite:** The Builder's contract with the CI pipeline is that every commit gets automatically validated. A Builder session without CI is manual validation — the Verifier cannot rely on CI status. The Environment Contract is an input to the Builder (it cannot introduce undeclared environment variables) — it must exist before the Builder's first session.

**Why Phase 3 is not triggered by Demo Sign-off:** Go-Live and Demo Sign-off are decoupled (DEC-0002). A project may have multiple Demo Sign-off cycles before a Go-Live. Provisioning production at every Demo Sign-off would waste resources. Phase 3 triggers when the Nexus decides a Go-Live is imminent, not at every cycle boundary.

**Why Casual is excluded:** At Casual profile, the Builder absorbs infrastructure tasks. There is no dedicated DevOps agent. The phasing concept still applies implicitly but is not a formal routing concern.

## Consequences

- The Planner must tag DevOps tasks with Phase 1, 2, or 3 in the Task Plan
- The Orchestrator enforces phase sequencing: no Builder task before Phase 1 complete, no Verifier system tests before Phase 2 complete, no Go-Live Briefing before Phase 3 complete and readiness signal received
- The first Verifier session (against the first Builder task) may only run integration and acceptance tests — system tests require staging (Phase 2) which is not yet provisioned
- The Verifier prompt's test layer selection must account for whether staging is available

## Alternatives Considered

**Provision all environments before Builder begins:** Maximizes environment stability but pays infrastructure cost speculatively. If early Builder tasks surface architectural issues that require changes, the environments must be updated. Does not follow just-in-time principles. Rejected.

**No explicit DevOps phasing — DevOps invoked once before Go-Live:** The framework's prior implicit state. Leaves Builder without a CI pipeline and the Verifier without a staging environment during development. Violates Continuous Delivery's pipeline-first principle. Rejected.
