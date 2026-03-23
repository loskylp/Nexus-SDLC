<!--
Author: Pablo Ochendrowitsch
Session recorded: 2026-03-17 to 2026-03-22
-->

# BrainDump — Process Retrospective

Combined critique from two perspectives: the **Nexus Methodologist** (swarm-side analysis) and the **Nexus** (human-side observations). Both sets were produced independently after the full session completed.

Points marked **[M]** originate from the Methodologist. Points marked **[N]** originate from the Nexus. Points marked **[M+N]** were raised by both independently.

---

## 1. Analyst — Guided Discovery

**[N]** The Analyst took the first sentence of the intake message and immediately produced a full requirements list, then asked for acceptance. There was no guided discovery phase. The correct behaviour is to begin by reflecting what was understood, including explicit and implied features, before asking what is missing:

```
This is what I understand about the project:

<project description>
<main features from input>
<main features implied or assumed>
<other features or details assumed>
<other features proposed>

What other requirements should the project address?
```

This forces active elicitation before a requirements list is written. A requirements list written before this exchange is a premature closure, not an output of discovery.

**[M]** Related: the Analyst must not resolve open context questions by assumption when the Nexus is present and reachable. Open Question 5 (account deletion behaviour) was resolved with a "standing default" without Nexus confirmation. If the Nexus is available in the session, all open context questions must be surfaced before the brief is closed.

---

## 2. Orchestrator — Role Collapse (Building and Verifying Directly)

**[M+N]** The most persistent failure across the project was the Orchestrator collapsing into a general-purpose agent instead of routing work to specialised agents. This manifested in three distinct ways:

**Pattern A — Direct task execution.** When the Nexus approved TASK-016 with "yes", the Orchestrator responded with `nexus-orchestrator(Dispatch TASK-016 to Builder)` and then immediately began writing frontend files itself: `Write(frontend/vite.config.js)`, `Write(frontend/src/main.jsx)`, and 55 more tool uses. The Builder was never invoked. The same occurred for TASK-003 — the Nexus explicitly said "call the builder for Task-003" and the Orchestrator still wrote the code itself.

**Pattern B — CI emergency self-service.** When staging was down (ESC-002), the Orchestrator ran `gh run view`, read CI logs, wrote `docker-compose.staging.yml`, committed it, and executed SSH deployment commands. The label on the agent call was `nexus-orchestrator(Fix CI failures)`. The Orchestrator was simultaneously diagnosing, implementing, and deploying — all three of which are Rule 2 violations. Emergency context does not exempt the Orchestrator from role separation. The correct action is to dispatch DevOps (for infrastructure) and/or Builder (for code), not to act directly.

**Pattern C — Context resume collapse.** After a use-limit interruption, the Orchestrator resumed with a state summary and asked "Shall I dispatch TASK-016 to the Builder?" — a correct gate check. But when the Nexus said "yes", the Orchestrator again executed the task itself rather than dispatching it. Resume state did not restore autonomous dispatch behaviour.

**[M]** Root cause: the framework's Rule 1 (autonomous Builder→Verifier→Builder loop) was a Cycle 1 discovery, not a founding rule. It was codified in manifest-v2 and Cycle 2 was better. But Rule 1 was never extended to cover the resume-after-interruption case, and no rule covers emergency dispatch.

---

## 3. Orchestrator — Autonomy Failures at Gate Transitions

**[M+N]** After the Plan Gate was approved, the DevOps Phase 1 task completed — and the Orchestrator then asked permission to call the Scaffolder instead of dispatching directly. This is the same autonomy failure as above but at a gate transition rather than a task dispatch. Once a gate is approved, the Orchestrator must proceed through the approved sequence without requesting permission for each individual dispatch.

**[M]** The framework specifies that the Orchestrator asks one question at gate boundaries. It does not specify that the Orchestrator must proceed autonomously once the gate is passed. This gap must be made explicit: gate approval authorises the full next phase sequence, not just the first step.

---

## 4. Orchestrator — Process Artefact Version Control

**[N]** No commits were made for the process artefacts in the `process/` folder. The Orchestrator produced routing slips, briefs, requirements, plans, and verification reports — none of which were committed to version control as they were created. If a context limit or crash occurred, the working documents would be unrecoverable from git history.

**[M+N]** This extends the NexusScan Rule 11 (commit after each task passes). The rule must also cover: the Orchestrator must commit process artefacts each time an agent produces output. Specifically:

- After Analyst produces a brief or requirements version → commit `process/analyst/`
- After Architect produces ADRs → commit `process/architect/`
- After Planner produces a task plan → commit `process/planner/`
- After Verifier produces a verification report → commit `process/verifier/`
- After any routing slip is written → commit `process/orchestrator/`

This gives the full project a recoverable audit trail, not just the source code.

---

## 5. Version Control — Commit and Push Discipline

**[N]** Commits were effectively non-existent during Cycle 1 execution. The base CI script was in place but was never committed to test whether the pipeline was correctly configured. The first commit occurred at end of TASK-016 — not pushed, and no CI verification. The consequence was that when TASK-011 made the first push to GitHub, previous tasks had not committed most of their files, causing CI failures. Additionally, no remote was configured at that point; the Nexus had to manually create the remote and push main.

**[M+N]** The framework's commit rule (NexusScan Rule 11) was violated from the start. The rule must be strengthened: commit-and-push is mandatory, not optional. No task is COMPLETE until its source changes are pushed and the CI pipeline run is green. A commit without a push is not a completed verification.

---

## 6. DevOps — Pipeline Verification with Real Push

**[M+N]** TASK-001 (DevOps Phase 1) was marked COMPLETE after file inspection — the DevOps agent verified file contents but never triggered a real push to confirm the pipeline ran green. The CI workflow had three silent failures that only surfaced during Cycle 1 execution: no `test:unit` script in `backend/package.json`, no ESLint config in `backend/`, and no migration step before integration tests. After TASK-007, the pipeline was pushed but the Orchestrator did not wait for the CI result — the CI failed because ESLint had no configuration.

**[M]** Required rule: at the end of DevOps Phase 1, the DevOps agent must make a first push (even if the source tree is empty/scaffold-only) and wait for the GitHub Actions run to complete. All jobs must pass before TASK-001 is marked COMPLETE and before Builder tasks begin. "The files look correct" is not the same as "the pipeline runs."

---

## 7. CI/CD — Tag-Based Deployment Workflow

**[N]** The project had no defined deployment workflow. Staging was not operational at Demo Sign-off time (Cycle 1), and there was no rule connecting Verifier approvals to CI triggers or environment promotion. A minimal tag-based policy would resolve this:

- **Push to `main`** → triggers build and full regression test suite
- **Push of a demo tag** (e.g., `demo_v1.0.0` at end of Cycle 1, first attempt) → triggers build, regression, Docker build, and push to staging
- **Push of a release tag** (e.g., `v1.0.0`) → retags the already-built and demo-approved Docker image to production without rebuild (image promotion, not re-build)

For larger projects, a multi-branch workflow (git-flow style) is appropriate. For projects at BrainDump's scale, the tag-based approach is sufficient. The framework's Manifest must specify which model applies based on project size/criticality, and the DevOps agent must implement it during Phase 1.

**[M]** The Manifest declared "CI pipeline passing before Builder tasks begin" as the DevOps Phase 1 exit criterion but said nothing about staging availability before Demo Sign-off. Manifest-v2 corrected this for Cycle 2 onward. The staging precondition must be a founding DevOps deliverable, not a post-incident discovery.

---

## 8. Verifier — Commit, Push, and CI Regression Protocol

**[N]** In Cycle 2, the Builder pushed work-in-progress commits before the Verifier had approved the task, creating uncommitted partial task states in the repository. The correct protocol is:

1. Builder completes implementation → does not push
2. Verifier runs acceptance tests for the task
3. If FAIL: Verifier writes report → Orchestrator dispatches Builder for iteration → loop
4. If PASS: Verifier commits all source changes (Builder's code + Verifier's acceptance tests) and pushes
5. Verifier waits for CI regression run to complete
6. If CI regression FAIL: Orchestrator dispatches Builder to fix → Verifier runs task tests + failing tests → pushes → waits for CI → loops if needed
7. If CI regression PASS: task is declared COMPLETE

Lint errors must be caught locally for the files in the task at hand. The full regression lint runs on CI. This prevents the CI from being the first place lint errors are discovered.

**[M]** The framework specifies "commit after each task passes" (NexusScan Rule 11) but does not assign the commit to the Verifier, does not require a push, and does not require CI green confirmation. These three additions are the substance of the rule.

---

## 9. Demo — Playwright Execution and Screenshot Evidence

**[M+N]** Demo scripts were written as markdown documents with curl and manual step descriptions. The Methodologist found that Cycle 3 tagging (the most complex feature) had no demo script at all, and TASK-029's demo covered only the backend API — not the visible Export All button.

**[N]** Demo scripts should be executed via Playwright, generating screenshots as evidence. A demo script is not complete evidence — it is a specification. Screenshots committed to `tests/demo/TASK-XXX/` confirm that the Nexus-facing behaviour is observable in the browser, not just that the API returns the right status code. Playwright execution of demo scripts is the mechanism that bridges the specification and the evidence.

**[M]** Rule 3 clarification required: if a cycle demo is consolidated into `tests/demo/cycle-N/`, this is only permitted when every feature in the cycle has a demo script and screenshots can be unambiguously mapped to scenarios. Where any feature lacks a demo script, per-task directories are mandatory.

---

## 10. Traceability — Markdown Links in Task Briefs

**[N]** Builders and Verifiers routinely read all project files to orient themselves before starting a task. This is context waste. When the Orchestrator writes a routing slip and task brief, the brief should contain markdown links to exactly the documents the receiving agent needs:

- The relevant requirement IDs linked to their location (`[REQ-005](../../analyst/requirements-v2.md#req-005)`)
- The relevant ADR IDs linked to their location
- The relevant acceptance criteria linked to the spec

The document ID becomes a navigable link, not a string to search for. The agent reads exactly what it needs and nothing more. This requires the Analyst, Architect, and Planner to write artefacts with stable anchor IDs, and the Orchestrator to include those links in every routing slip.

---

## 11. Tool Boundary — Project Root Scope

**[N]** During the session, agent tool calls repeatedly searched parent directories (e.g., searching `pattern: "**/manifest.md", path: "/Users/pablo/projects/Nexus"`) instead of the project root. The Nexus had to reject these tool calls repeatedly to prevent file mixups between projects. Agents must treat the project working directory as the search boundary. Any search that escapes the project root is a violation and must not require the Nexus to manually block it.

This is both a Manifest constraint (the Orchestrator must enforce project-root scope in all routing slips) and a candidate for a bash/tool execution skill (see section 13).

---

## 12. Repeated Permission Prompts for Identical Commands

**[N]** The same command pattern triggered a permission prompt on every invocation. The `<command>:*` wildcard in the permission settings did not apply as expected. The root cause in most cases was agents using `cd <project-directory> && <command>` compound forms instead of running commands from the working directory directly. Claude Code treats `cd <dir> && <command>` as a compound command requiring approval to prevent bare repository attacks — it does not match the wildcard because the compound changes the working directory.

The fix is: agents must never use `cd <dir> && <command>`. All commands must be run from the working directory that is already set to the project root. This eliminates the compound form and the repeated approvals.

---

## 13. Agent Skills — Procedural HOW Extracted from Agent Definitions

**[N]** Agent definitions explain what each agent does and what it is responsible for. They are well-scoped. The problem is that procedural "how-to" guidance (correct bash command form, project-root scope enforcement, demo script structure, commit discipline) either has to be repeated in every agent definition or left to the agent's best guess.

The framework needs a `skills/` collection: small, reusable procedural documents that any agent can reference. Agent definitions stay lean by citing skills rather than inlining procedures. Example skills needed immediately:

- `bash-execution.md` — never use `cd <dir> && <command>`; all commands run from working directory
- `commit-discipline.md` — when to commit, when to push, how to wait for CI
- `demo-script-execution.md` — how to run Playwright and store screenshots
- `traceability-links.md` — how to write markdown links in routing slips and task briefs

Skills live in `.claude/skills/` (adjacent to `.claude/agents/`). Agent definitions reference them by path. The Orchestrator's routing slip template should specify which skills the receiving agent must read before starting.

---

## 14. Verifier — Observation Lifecycle

**[M]** Non-blocking Verifier observations that cannot be addressed within the current task have no defined lifecycle. In this project, observations were recorded in Demo Sign-off briefings but some (OBS-V008-02 silent fallback, OBS-V011-01 stale test comments) had no record of being routed or resolved. The Orchestrator must track open observations in the escalation log and confirm their disposition at the start of each cycle.

---

## 15. Auditor — Deferral Expiry

**[M]** AUDIT-003 (design aesthetic lacking a standalone cross-cutting requirement) was deferred across three requirements gates without resolution. A tracked deferral must be re-evaluated at every Requirements Gate. A deferral may survive one gate without resolution. If it is deferred a second time, the Auditor must produce an explicit acceptance statement signed off by the Nexus rather than carrying it forward silently.

---

## 16. Sentinel — Remediation Tracking

**[M]** High severity findings may be deferred at most one cycle. If not resolved in the following cycle, they escalate to a Demo Sign-off blocker. This must be stated in the Manifest explicitly — it was not, and the correct outcome only happened because the Planner exercised good judgment.

**[M]** When Sentinel findings are "resolved inline" before cycle close, the Verifier must produce a targeted verification entry confirming the fix. Cycle 3 closed with "both findings resolved inline" in project-state.md but no verification artefact. "Resolved inline" without Verifier confirmation is not an acceptable close state.

---

## Summary of Required Framework Changes

| # | Area | Change required | Owner |
|---|------|-----------------|-------|
| 1 | Analyst / Intake | Guided discovery before requirements list: reflect understanding → propose features → ask what else the project should address | Analyst |
| 2 | Analyst / Open Questions | Analyst must not resolve open questions by assumption when Nexus is present; surface all open questions before closing the brief | Analyst |
| 3 | Orchestrator / Dispatch Rule | Gate approval authorises the full phase sequence; Orchestrator dispatches each step autonomously without per-step permission requests | Orchestrator |
| 4 | Orchestrator / Emergency Protocol | Emergency (CI/staging down) does not exempt Orchestrator from Rule 2; Orchestrator dispatches DevOps/Builder/Verifier and does not act directly | Methodologist |
| 5 | Orchestrator / Resume Protocol | After context-limit resume, state-verification must restore full autonomous dispatch behaviour before any user prompt | Orchestrator |
| 6 | Orchestrator / Process Artefacts | Commit process artefacts after each agent produces output (brief, requirements, ADRs, task plan, routing slip, verification report) | Orchestrator |
| 7 | DevOps / CI Green Confirmation | DevOps Phase 1 is COMPLETE only after a real push and a green CI run for all jobs; file inspection is not sufficient | DevOps |
| 8 | DevOps / Staging Precondition | Staging must be reachable at the health endpoint before Demo Sign-off can open; this is a founding DevOps deliverable, not a post-incident addition | Methodologist |
| 9 | CI/CD / Deployment Workflow | Manifest must specify a tag-based deployment policy: push to main → regression; demo tag → staging promotion; release tag → image promotion to prod | Methodologist |
| 10 | Verifier / Commit-Push-CI Protocol | Task is COMPLETE only when: Verifier commits all changes, pushes, CI regression passes. Builder must not push. Lint checked locally first. | Methodologist / Verifier |
| 11 | Demo / Playwright Execution | Demo scripts must be executed via Playwright generating committed screenshots as evidence; a markdown demo script alone is not sufficient evidence | Methodologist |
| 12 | Demo / Script Coverage | Every task with user-visible behaviour must have a `*-demo.md` file; Planner assigns a Demo Script sub-task to any task without one | Planner |
| 13 | Traceability / Markdown Links | Routing slips and task briefs must include markdown links to the specific requirement, ADR, and acceptance criteria sections the receiving agent needs; agents must not search for documents | Orchestrator / Planner |
| 14 | Tool Boundary / Project Root | All agent tool calls are scoped to the project working directory; searches must not escape the project root | Orchestrator |
| 15 | Agent Skills / Skill Collection | Create `.claude/skills/` with procedural how-to skills referenced by agent definitions; starting set: `bash-execution.md`, `commit-discipline.md`, `demo-script-execution.md`, `traceability-links.md` | Methodologist |
| 16 | Bash Execution / No cd Compound | Agents must never use `cd <dir> && <command>`; all commands run from the working directory; this is codified in `bash-execution.md` skill | All |
| 17 | Verifier / Observation Lifecycle | Open non-blocking observations must be tracked in the escalation log and confirmed at the start of each following cycle | Orchestrator |
| 18 | Auditor / Deferral Expiry | Tracked deferrals survive one gate; a second deferral requires explicit Nexus acceptance statement | Auditor |
| 19 | Sentinel / High Finding Deferral | High findings may be deferred at most one cycle; unresolved in the next cycle → Demo Sign-off blocker | Sentinel |
| 20 | Sentinel / Inline Fix Verification | "Resolved inline" requires a Verifier confirmation entry; project-state note alone is not acceptable | Verifier |
| 21 | Planner / Rolling Confidence | Rolling confidence assessment required in Pass 3 for every cycle, not only the initial plan | Planner |
| 22 | Requirements Gate / Plan Gate Features | Features requested at the Plan Gate follow a mini Requirements Gate: Analyst → Auditor → Nexus approval before Planner includes the task | Orchestrator / Analyst |
