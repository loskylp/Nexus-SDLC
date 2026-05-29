---
name: ephemeral-stack
description: Use BEFORE standing up or tearing down a disposable test environment in this project. TRIGGER when about to run `docker compose up`/`docker compose down`/`docker-compose ...` for tests; when the Verifier needs to run system or acceptance tests against a real stack (not staging/production); when the Builder runs component-level acceptance tests against a deployed unit with mocked dependencies; when DevOps validates the CI pipeline against a running stack; when integration tasks need full ephemeral system tests. Prescribes the readiness check protocol (container health + port reachable + endpoint 200 + DB accepts connections + queue accepts pub/sub), the teardown rule (`docker compose down -v` — no state persists), and the failure-handling matrix. Forbids running tests against staging/production for integration/system/acceptance layers — those layers must use an ephemeral stack so a failure isolates to code, not environment mystery.
---

# Ephemeral Stack Management

> Apply this skill when standing up disposable environments for integration, system, or acceptance testing. Ephemeral stacks isolate cause — a test failure against a disposable stack is a code defect, not an environment mystery.

## When to Use

- **Verifier:** system and acceptance tests run against an ephemeral stack, not staging or production
- **Builder:** component-level acceptance tests run against the component as a deployed ephemeral unit with mocked dependencies
- **DevOps:** validates the CI pipeline against a real running stack
- **Integration tasks:** system tests validate components working together in the full ephemeral system

## Standing Up the Stack

1. **Use the project's Docker Compose or equivalent** — the DevOps agent maintains the compose file as part of the Environment Contract. Do not write a new one.
2. **Start the stack** — `docker compose up -d` (or the project's equivalent command as specified in the Environment Contract).
3. **Wait for readiness** — do not run tests until all services report healthy. Use health checks defined in the compose file. If no health checks are defined, poll the health endpoint with a timeout (default: 60 seconds, configurable per project).
4. **Confirm readiness** — each service must respond on its declared port. A started container is not a ready service.

## Readiness Check Protocol

```
for each service in the stack:
  1. Wait for the container to report "healthy" (if health check defined)
  2. Confirm the service port is accepting connections
  3. If the service has a health endpoint: confirm it returns HTTP 200
  4. If the service is a database: confirm it accepts connections
  5. If the service is a message queue: confirm it accepts publish/subscribe
```

Timeout: if any service does not reach readiness within the configured timeout, report the failure with the service name and last observed state. Do not retry indefinitely.

## Tearing Down the Stack

After test completion (pass or fail):

1. `docker compose down -v` — remove containers and volumes. Ephemeral means ephemeral — no state persists between test runs.
2. Confirm all containers from the stack are stopped and removed.
3. If teardown fails, log the failure but do not block the test report — stale containers are an operational nuisance, not a test result.

## Integration with the Environment Contract

- Use the same environment variable names defined in the DevOps Environment Contract
- Inject test-appropriate values (e.g., test database credentials, mock API endpoints)
- The compose file should reference the same builder images and runtime images specified in the Build Environment Specification

## Failure Handling

| Failure type | Action |
|---|---|
| Stack fails to start | Report which service failed and the last log output. Do not retry — the compose file or image is likely broken. Escalate to DevOps. |
| Stack starts but readiness check fails | Report which service is not ready and the timeout duration. Check if the service is crashing (restart loop) or simply slow. |
| Tests fail against the stack | This is expected — the test failure is the signal. Report normally. Tear down the stack. |
| Teardown fails | Log the failure. Report it as an operational observation, not a test failure. |
