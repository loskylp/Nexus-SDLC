# DEC-0017: Fitness Functions as Dual-Purpose Architectural Specifications

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus (Human), Nexus Method Architect

## Context

Richards & Ford (*Fundamentals of Software Architecture*) introduce **architectural fitness functions** — any mechanism that provides an objective integrity assessment of an architectural characteristic. In their framing, fitness functions are primarily used during development to verify that architectural characteristics (the -ilities) are maintained as the system evolves.

This framework extends that concept: a fitness function is not only a development-time check. It is simultaneously the specification for what to monitor in production and when to raise alarms. The architecture definition and the observability specification are the same artifact.

## Decision

Every architectural characteristic defined in an ADR or Architecture Overview must include a **dual-use fitness function** covering both development verification and production observability:

### Fitness Function Structure

```
Characteristic: [name of the -ility]
Threshold:      [the measurable condition that must hold]

Fitness function:
  Dev (Verifier):     [test or check run during CI/build/verification phase]
  Prod (Monitoring):  [metric to collect when the system is live]
  Warning threshold:  [value at which an alert is raised for attention]
  Critical threshold: [value at which an alert demands immediate action]
  Alarm meaning:      [what this alarm tells the operator — architecture is failing because...]
```

### Examples by -ility

**Performance**
```
Characteristic: Response time
Threshold:      p95 API response < 200ms under expected load

Dev:            Integration test asserting p95 < 200ms against a representative dataset
Prod:           Monitor p95 latency per endpoint
Warning:        p95 > 180ms sustained over 5 minutes
Critical:       p95 > 200ms sustained over 2 minutes
Alarm meaning:  Latency SLA is at risk — investigate query performance,
                cache hit rates, or downstream service health
```

**Reliability**
```
Characteristic: Availability
Threshold:      99.5% uptime measured monthly

Dev:            Smoke test suite runs on every deploy; circuit breaker tests
Prod:           Uptime monitoring with synthetic health checks every 60s
Warning:        Two consecutive health check failures
Critical:       Five consecutive failures or calculated monthly uptime < 99.7%
Alarm meaning:  System availability contract is at risk — check infrastructure
                and recent deployments
```

**Security**
```
Characteristic: Authentication enforcement
Threshold:      Zero unauthenticated access to protected endpoints

Dev:            Security test suite asserting all protected routes reject
                unauthenticated requests
Prod:           Monitor authentication failure rate per endpoint
Warning:        Unusual spike in 401/403 responses (>10x baseline in 5 min)
Critical:       Any successful access to protected resource without valid token
Alarm meaning:  Possible authentication bypass or misconfiguration —
                investigate immediately
```

### Profile Calibration

Fitness functions are scaled to profile weight:

| Profile | Fitness function depth |
|---|---|
| **Casual** | Informally stated as a comment in the Task Plan. No automated monitoring required unless the Nexus explicitly requests it. |
| **Commercial** | Defined in the Architecture Overview. Dev-side checks are expected. Production monitoring is recommended but Nexus decides which to instrument. |
| **Critical** | Defined in each ADR. Both dev and production sides required. Monitoring setup is a task in the Task Plan. |
| **Vital** | Full dual-use specification per characteristic. Warning and critical thresholds documented and signed off. Alarm response procedures defined alongside the fitness function. |

### Who Owns What

| Phase | Owner | Responsibility |
|---|---|---|
| Definition | Architect | Defines the characteristic, threshold, and fitness function specification |
| Dev implementation | Verifier | Implements and runs the dev-side check as part of verification |
| Prod implementation | Builder | Implements monitoring instrumentation as a task in the Task Plan |
| Prod operation | Nexus | Receives alarms, interprets them against the ADR's alarm meaning |

The Orchestrator is responsible for ensuring that fitness function implementation tasks appear in the Task Plan — they are not optional additions.

## Rationale

**Why fitness functions span dev and production:** An architectural characteristic that is only verified during development but not monitored in production provides false confidence. The system may degrade gradually in ways no test catches. Conversely, production monitoring without a clear definition of what the threshold means leads to alarm fatigue. Specifying both in the same ADR ensures the monitoring requirement is never forgotten and the alarm is interpretable.

**Why the Architect defines both sides:** The person (agent) who decides that "p95 response time < 200ms" is the architectural characteristic is also the person best positioned to decide what warning level is meaningful and what the alarm indicates. Separating the definition from the monitoring threshold creates a gap that fills with guesswork.

**Why the Verifier implements dev-side and the Builder implements prod-side:** These are different artifacts: a test file (Verifier's domain) and instrumentation code (Builder's domain). Separating them maintains the concern boundary between the two agents.

## Consequences

- ADR and Architecture Overview templates must include a fitness function section
- The Architect agent definition must include guidance on writing dual-use fitness functions
- The Verifier must check that dev-side fitness functions exist for all architectural characteristics when running verification on a Critical or Vital project
- The Task Plan must include explicit tasks for instrumentation/monitoring setup on Commercial and above projects
- The Methodologist Manifest should note whether production observability is in scope (it always is for Critical/Vital; optional for Casual/Commercial)

## References

- Richards, M., Ford, N. — *Fundamentals of Software Architecture* (O'Reilly) — primary source for fitness function concept and architectural characteristics taxonomy
- Forsgren et al. — *Accelerate* — DORA metrics as a set of fitness functions for delivery pipeline health
