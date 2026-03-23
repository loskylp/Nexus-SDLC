Check the status of the latest GitHub Actions run for this repository and wait for it to complete.

1. Detect the current repo with `git remote get-url origin` and derive the `owner/repo` slug from it.
2. Run `gh run list --repo <owner/repo> --limit 1 --json databaseId,status,conclusion,name --jq '.[0]'` to get the latest run.
3. If no run is found, report that and stop.
4. If the run is already completed, report the conclusion immediately.
5. If the run is in progress, poll every 15 seconds with the same command until status is `completed`.
6. If conclusion is `success`, report success with the run name.
7. If conclusion is `failure` or `cancelled`, fetch the failure logs with `gh run view <databaseId> --repo <owner/repo> --log-failed` and report what went wrong.
