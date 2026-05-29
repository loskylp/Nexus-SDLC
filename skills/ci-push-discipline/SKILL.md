---
name: ci-push-discipline
description: Use BEFORE any `git push` to a shared branch in this project. TRIGGER when about to run `git push origin master`, `git push origin <branch>`, or any push that triggers GitHub Actions CI; when the Verifier/DevOps protocol reaches the push step; when multiple agents may be working on the same branch simultaneously. Forbids pushing while a CI run is in-progress on the same branch (cascade cancellations consume the GitHub Actions concurrency budget, exhaust API rate limits, and saturate self-hosted runners). Prescribes the pre-push gate: `gh run list --branch <name> --status in_progress --limit 1`, wait via `gh run watch <id>`, re-check, repeat until clear. Applies to Verifier and DevOps push steps; complements commit-discipline.
---

# CI Push Discipline

## The rule

**Never push while a CI run is active on the same branch.**

Before executing `git push`, check for in-progress CI runs:

```bash
gh run list --branch master --status in_progress --limit 1 --json databaseId --jq '.[0].databaseId'
```

If the command returns a run ID, **wait for it to complete** before pushing:

```bash
gh run watch <run_id> --exit-status || true
```

Then re-check — another agent may have pushed while you were waiting. Repeat
until the branch is clear, then push.

## Why

When multiple agents push near-simultaneously to the same branch:

1. **Cascade cancellations.** GitHub Actions concurrency groups cancel the
   in-progress run when a new push arrives. No run completes; no CI signal
   is produced. The agents then poll for a result that never comes.
2. **Rate-limit exhaustion.** Multiple agents polling `gh run list` and
   `gh api` in parallel burn through GitHub's 5,000 requests/hour budget.
   Once exhausted, all agents stall for up to an hour.
3. **Runner saturation.** Self-hosted runners on the VPS attempt to start
   multiple Docker builds concurrently — each one competing for CPU and
   RAM — degrading all of them and potentially crashing the host.

Serialising pushes eliminates all three problems. Each CI run completes
fully, producing a clean green/red signal. One build at a time keeps the
VPS healthy. API calls stay within budget.

## Who this applies to

Every agent that pushes to a shared branch — **Builder** (when the routing
instruction says to push) and **Verifier** (commit-push-CI protocol from
`commit-discipline`). The Orchestrator does not push source code but
does commit process artefacts; those commits are local-only and do not
trigger CI.

## Practical pattern

```bash
# Before pushing, wait for any active CI run to finish
while true; do
  ACTIVE_RUN=$(gh run list --branch master --status in_progress --limit 1 \
    --json databaseId --jq '.[0].databaseId // empty')
  if [ -z "$ACTIVE_RUN" ]; then
    break
  fi
  echo "CI run $ACTIVE_RUN in progress — waiting..."
  gh run watch "$ACTIVE_RUN" --exit-status 2>/dev/null || true
  sleep 5
done

git push origin master
```

The `|| true` after `gh run watch` is acceptable here — the watch exit
status reflects the *watched run's* outcome, not the push gate. A prior
run failing does not block the current push; it just means the branch was
red before this push, which the new push may fix.

## Integration with commit-discipline

The Verifier commit protocol (step 4: "Verifier pushes to remote") now
includes this pre-push gate. The sequence becomes:

1. Stage + commit (Verifier-owned commit)
2. **Check for active CI runs — wait if any are in progress**
3. Push
4. Wait for *this* CI run to complete (all jobs green)
5. If CI fails → route to Builder → fix → re-verify → repeat from step 1

## What this does NOT change

- Builders still work in parallel (local commits, local ephemeral tests).
- The Orchestrator still dispatches multiple agents simultaneously.
- Only the push-to-remote step is serialised.
