---
name: dispatch-nexus-agent
description: Use BEFORE writing any routing prompt to a Nexus SDLC agent (Analyst, Architect, Auditor, Builder, Designer, DevOps, Methodologist, Orchestrator, Planner, Scaffolder, Scribe, Sentinel, Verifier). Codifies per-agent dispatch rules so the dispatcher never asks an agent to do work that belongs to a different agent.
---

# Dispatch a Nexus SDLC Agent

Before writing a routing prompt for any Nexus agent, read this. The single most common process failure in this project is the dispatcher (Orchestrator or the human-relayed routing) instructing an agent to do work that belongs to a different agent — most often, telling the Builder to commit, push, run acceptance tests, or wait for CI. Those are the Verifier's responsibilities. Once. Never again.

## When this skill applies

- Writing any routing instruction to a Nexus SDLC agent
- Relaying an Orchestrator routing instruction onward to the target agent
- Drafting a dispatch prompt by hand, outside of an Orchestrator turn (emergency, retry, follow-up)

## The single failure mode this skill prevents

**Telling the Builder to push, run acceptance tests, or wait for CI.**

Every other rule below is real, but this is the one that has recurred. If a Builder dispatch prompt contains the words `push`, `acceptance test`, `wait for CI`, `commit`, `gh run`, or `verified`, the prompt is wrong. Delete those steps and re-dispatch.

## Mandatory pre-dispatch checklist

Before sending any routing prompt, answer these three questions in order:

1. **Which agent am I dispatching?** Name it explicitly.
2. **What does its rulebook say it does NOT do?** Open `.claude/agents/<name>.md` and read the **You Must Not** section. Every item there is a thing the dispatch prompt must not ask for.
3. **Does my prompt instruct any of those forbidden actions?** If yes, remove them. If unsure, remove them anyway and let the agent flag the gap.

Skipping this checklist is the source of the recurring failure. Do not skip it.

## Per-agent reference

The authoritative rulebook for each agent is `.claude/agents/<name>.md`. The sections below are a memory aid, not a substitute. When in doubt, read the rulebook.

### Analyst (`.claude/agents/analyst.md`)

- **Does:** Conducts guided discovery with the Nexus (3–4 questions per turn, multi-turn). Produces the Brief (problem statement, scope, stakeholders, user roles, domain model, delivery channel). Produces the Requirements List with REQ-NNN + Definition of Done + Given/When/Then acceptance scenarios. Incorporates Nexus answers when the Auditor raises clarification questions. Incorporates demo feedback into revised requirements.
- **Does NOT:** Produce artifacts (Brief, Requirements List) on the same turn as discovery questions. Begin RA before the delivery channel is known. Invent requirements not grounded in Nexus input. Resolve domain contradictions or open context questions silently when the Nexus is reachable. Let the domain model drift into technical/schema language. Modify architecture, tasks, or any other agent's output.
- **Dispatch prompt MUST contain:** Phase — `guided discovery` for the first invocation, or `produce Brief` / `produce Requirements List` / `incorporate Auditor feedback` / `incorporate demo feedback` for subsequent invocations. Profile (Casual/Commercial/Critical/Vital) so the Analyst weights the artifact correctly. For feedback invocations: the specific Auditor flags or demo feedback items to address.
- **Dispatch prompt MUST NOT contain:** Instructions that collapse discovery and artifact production into a single turn ("conduct discovery and produce the Brief"). Pre-decided requirements the Analyst should be eliciting. Instructions to resolve open context questions by assumption.

### Architect (`.claude/agents/architect.md`)

- **Does:** Identifies load-bearing architectural decisions. Produces trade-off analyses (every choice is a trade-off — First Law). Produces ADRs, Architecture Overview, and fitness functions, weighted to the profile (Casual: metaphor + sketch in Task Plan header; Commercial: Architecture Overview; Critical: ADRs; Vital: ADRs + signed baseline). Escalates contested decisions to the Nexus with one question at a time. Remains available during execution for architectural questions surfaced by the Builder.
- **Does NOT:** Implement. Write production code. Choose what the system should do — that is the Nexus's domain. Decide unilaterally on contested decisions. Skip the trade-off step (a decision presented without its trade-off is unfinished analysis).
- **Dispatch prompt MUST contain:** Link to approved Requirements List (functional and NFRs). Profile. The specific decision(s) to be made or the execution-time question being routed. Any prior ADRs that constrain the decision.
- **Dispatch prompt MUST NOT contain:** Instructions to write production code. Instructions to skip Nexus escalation on contested decisions. A pre-chosen solution presented as a constraint.

### Auditor (`.claude/agents/auditor.md`)

- **Does:** Requirements audit — checks every requirement for consistency, completeness, coherence, traceability, testability; flags issues as CONTRADICTION/GAP/AMBIGUOUS/UNTRACED/DEFERRED. Architectural audit — checks coverage (every REQ has an architectural home), consistency (ADRs don't contradict each other), coherence (the architecture credibly solves the requirements), fitness function traceability. Produces an Audit Report with specific, citation-grounded Nexus clarification questions for each blocking flag. Runs regression checks on previously approved requirements when new ones arrive post-demo. Re-runs after each Analyst/Architect revision until clean.
- **Does NOT:** Modify requirements or architecture (output is a report only). Ask vague Nexus questions ("there is a problem with REQ-004"). Conflate multiple issues into one question. Approve untestable Definitions of Done. Use [DEFERRED] to avoid confronting a real [GAP]. Carry a [DEFERRED] past a second gate without Nexus sign-off.
- **Dispatch prompt MUST contain:** Audit mode (`requirements audit` or `architectural audit`). Link to the artifact under audit (Brief + Requirements List, or Architect output). For regression mode: link to prior approved Requirements Lists. Profile (determines audit depth).
- **Dispatch prompt MUST NOT contain:** Instructions to rewrite requirements or architecture. Pre-decided verdicts ("just confirm this passes"). Multiple-issue questions to relay to the Nexus.

### Builder (`.claude/agents/builder.md`)

- **Does:** Implements ONE atomic task from the Task Plan. Red/green/refactor — failing unit test first, minimum green code, then named refactors from Fowler's catalog. Writes source code and unit tests. Maintains living docstrings (post-refactor docs must match what the code now does). Produces a handoff note. Uses the DevOps build environment (never installs build tools on the host).
- **Does NOT:** Commit. Push. Open PRs. Write integration/system/acceptance/performance/demo tests. Run acceptance tests. Wait for CI. Modify requirements, plans, or other agent outputs. Implement functionality outside the task. Refactor or "improve" code outside scope. Bypass or weaken existing tests. Leave stale docstrings. Proceed when acceptance criteria are ambiguous.
- **Dispatch prompt MUST contain:** Task ID. Link to task acceptance criteria. Links to any Scaffolder/Designer/DevOps inputs the task depends on. Path to write the handoff note. For iteration after a Verifier FAIL: link to the Verification Report and "address the failures listed in the report".
- **Dispatch prompt MUST NOT contain:** "commit", "push", "wait for CI", "run acceptance tests", "verify", "gh run", "open a PR", "after CI green", "stage files", any reference to the Verifier's commit-push protocol.

### Designer (`.claude/agents/designer.md`)

- **Does:** Translates approved requirements into UX flows, interaction spec, and component structure. Follows Garrett's 5 Planes top-down: Structure (IA + flows) → Skeleton (wireframes + navigation + states) → Surface (visual spec, Commercial+). Produces personas grounded in the Brief's user roles (Commercial+). Documents design hypotheses (Commercial+). For GUI channels: uses the Stitch MCP lifecycle (generate → propose in browser → wait for Nexus approval → finalize downloads). For TUI: produces ASCII layouts + key binding map + mode decision.
- **Does NOT:** Skip planes (no Surface before Structure + Skeleton). Design only the happy path — error, empty, loading, disabled states are required. Invent user roles or personas not grounded in the Brief. Make technology decisions (framework, component library) — those are the Architect's. Self-approve the Stitch proposal — Nexus review is non-negotiable even at Casual.
- **Dispatch prompt MUST contain:** Link to approved Requirements (functional + NFRs incl. accessibility). Link to Brief (user roles + domain model + delivery channel). Link to Architect output (framework, fitness functions). Profile. Which requirements / screens are in scope for this dispatch.
- **Dispatch prompt MUST NOT contain:** Pre-chosen visual treatment ("make it look like X"). Instructions to skip the Stitch Nexus review. Instructions to make framework or technology decisions. Instructions that override Architect constraints.

### DevOps (`.claude/agents/devops.md`)

- **Does:** Builds CI/CD pipelines, provisions environments, writes the Environment Contract (variables, secrets, mount paths) AND the Build Environment Specification (builder image, invocation commands). Three phases: Phase 1 (CI + dev env + Environment Contract) before any Builder task; Phase 2 (staging + CD to staging) after first Verifier PASS; Phase 3 (production + monitoring + fitness function instrumentation + rollback) before Go-Live. After writing infra files: stage, commit, push, and WAIT FOR REAL CI to be green before declaring the phase complete.
- **Does NOT:** Implement application code. Write product features. Declare a phase complete based on "the YAML looks right" — only a real green CI run closes a phase. Self-verify deployments as if it were the Verifier; the Verifier confirms the real pipeline is green.
- **Dispatch prompt MUST contain:** Phase number (1/2/3). Profile. Target environment. The Environment Contract fields the Builder/Verifier downstream will depend on. For Phase 3: links to the Architect's fitness functions to be instrumented.
- **Dispatch prompt MUST NOT contain:** Application feature tasks. Instructions to bypass the wait-for-real-CI-green step. Instructions to self-verify the deployment.

### Methodologist (`.claude/agents/methodologist.md`)

- **Does:** Intake — assesses project profile across three dimensions (Nature, Team, Scale) via infer-first protocol; profile is set by the highest-stakes dimension. Produces the Methodology Manifest at `process/methodologist/manifest-vN.md` (Sketch → Spec weight by profile). Selects active/skipped agents, documentation requirements, gate configuration, iteration model and loop bounds. Re-activates at every Demo Sign-off for retrospective: "Is there anything you want to change for the next iteration?" Encoding verification — confirms behavioral findings have been written into agent definitions or skill files before signing off the retrospective.
- **Does NOT:** Write, review, or modify any software artifact. Assign profile without explicit Nexus confirmation of inferred dimensions. Downgrade a profile without explicit Nexus approval. Produce a Manifest so detailed it burdens a Casual project. Skip the retrospective when re-activated. Close a retrospective with unencoded behavioral findings (Manifest is not sufficient — agents read their own definitions).
- **Dispatch prompt MUST contain:** Trigger — `intake` (first invocation), `Demo Sign-off retrospective` (post-cycle), or named trigger event (escalation pattern, team change, scope shift). For retrospective mode: link to Project State Process Metrics + escalation log + prior Manifest. For intake: the Nexus's project description.
- **Dispatch prompt MUST NOT contain:** A pre-assigned profile (the Methodologist assigns it via intake). Instructions to skip the retrospective. Instructions to encode findings only in the Manifest.

### Orchestrator (`.claude/agents/orchestrator.md`)

- **Does:** Routes. Updates `process/orchestrator/project-state.md` before and after every agent handoff. Commits process artefacts after each agent output (`process(<agent>): ...`). Independently confirms CI green before dispatching the next task (mechanical check, not judgment). Prepares Nexus briefings at gate points. Tracks iteration cycles and enforces loop termination. Maintains the escalation log. Sequences DevOps phases, the three-pass Planner protocol, Analyst guided discovery vs. artifact production, Architect → Auditor → Architecture Gate, and post-retrospective encoding verification.
- **Does NOT:** Write, review, or modify any software artifact, requirement, or test. Make strategic decisions about what the system should do. Override human gates. Inject ad-hoc workflow instructions ("also push when done") into agent prompts. Dispatch when CI is red. Search outside the project root. Approve its own routing on behalf of the Nexus.
- **Dispatch prompt MUST contain:** The trigger event ("Builder BUILT TASK-NNN", "Verifier PASS on TASK-NNN", "Nexus approved Plan Gate", "production incident"), pointer to project-state.md, and the question being asked of the Orchestrator (e.g. "route next").
- **Dispatch prompt MUST NOT contain:** A pre-decided next agent the Orchestrator should be deciding itself. Instructions to commit source code. Instructions to bypass CI green confirmation. Instructions to inject behavior-overriding steps into downstream agent prompts.

### Planner (`.claude/agents/planner.md`)

- **Does:** Three-pass initial planning per cycle — Pass 1 decomposition (atomic tasks + acceptance criteria, no scoring), Pass 2 scoring + ordering (Risk H/M/L × Value H/M/L rubrics with cited criteria, walking skeleton, cut line), Pass 3 release map (MVP boundary, rolling confidence, unplaced requirements). Schedules spike tasks ahead of dependents. Tags DevOps tasks by phase (1/2/3). Declares a Demo Script field for every task with user-visible behaviour (or `Demo Script: N/A` with reason). Revision invocations (spike finding, demo feedback, mid-cycle change) are single-pass.
- **Does NOT:** Order tasks purely by dependency. Bury high-value work behind low-value infrastructure beyond what dependencies force. Hide low-value work at the bottom of an undifferentiated list (surface as cut candidate). Invent tasks not grounded in approved requirements or Architect output. Assign implementation approaches (the task says *what*, not *how*). Mark a task atomic if it would exceed one focused Builder session. Plan a task that crosses component boundaries (decompose into per-component + integration). Use inline `- [ ]` checklists. Produce dependency graphs in ASCII (use Mermaid).
- **Dispatch prompt MUST contain:** Invocation mode — `initial Pass 1`, `initial Pass 2`, `initial Pass 3`, or a named revision (`spike finding`, `demo feedback`, `mid-cycle change`). Link to approved Requirements List + Architect output + (for Pass 2/3) prior pass output. Profile. For revision: the specific change to incorporate.
- **Dispatch prompt MUST NOT contain:** A request to collapse the three passes into one. A pre-decided cut line the Planner should be proposing to the Nexus. Implementation approaches inside task descriptions.

### Scaffolder (`.claude/agents/scaffolder.md`)

- **Does:** Translates the Architect's component map into file/directory structure. Produces inter-component contracts (OpenAPI, shared schemas, protobuf, Zod) as first-class artifacts when the iteration spans communicating components — these take priority over internal scaffolding. Defines class/interface/module/function signatures at the right abstraction level. Writes documentation contracts (preconditions, postconditions, errors). Marks all bodies with `TODO` only. Produces a Scaffold Manifest. Uses domain vocabulary from the Brief throughout.
- **Does NOT:** Implement any logic — bodies contain ONLY a TODO marker, never placeholder logic or stub returns. Invent component boundaries or interfaces not in the Architect's output. Choose internal implementation approach. Add convenience methods or helpers beyond the component map. Use technical jargon that conflicts with the domain model.
- **Dispatch prompt MUST contain:** Link to Architect output (component map + ADRs + interface boundaries). Link to Analyst Brief (domain model). Link to current iteration Task Plan with the scope instruction (which components to scaffold this pass). Profile.
- **Dispatch prompt MUST NOT contain:** Instructions to implement bodies, write stub returns, or add helper methods. A request to scaffold components outside the iteration scope. Names that diverge from the domain model.

### Scribe (`.claude/agents/scribe.md`)

- **Does:** At release time only — extracts living documentation (Builder docstrings, Designer UX flows, Verifier Demo Scripts, Release Map) and transforms it for the delivery channel: Library → reference site (Sphinx/Javadoc/godoc/TypeDoc), API → Swagger/OpenAPI at the version URL, User application → user manual from UX flows + Demo Scripts, CLI → man page from help strings. Always produces release notes (organised by feature, references REQ-NNN titles) and a Keep-a-Changelog entry. Publishes a versioned snapshot at `docs/vN.N.N/` — previous versions remain intact.
- **Does NOT:** Write content from scratch (extract and transform what exists; flag gaps rather than invent). Overwrite previous release versions. Modify source code, annotations, or UX specs (flag if the source is wrong). Invent feature descriptions not backed by a Demo Script. Run between releases (Builders maintain living docs between release signals).
- **Dispatch prompt MUST contain:** Release signal with version target. CD model context (Continuous Deployment, Continuous Delivery, Cycle-based) — determines invocation timing and approval flow. Profile (Casual = not invoked; Commercial+ applies). Link to the Release Map version target + scope.
- **Dispatch prompt MUST NOT contain:** Instructions to write new feature copy. Instructions to overwrite a prior `docs/vN.N.N/` snapshot. Instructions to modify code annotations to make documentation cleaner.

### Sentinel (`.claude/agents/sentinel.md`)

- **Does:** Dependency review — evaluates new deps on four criteria (maintenance, CVEs, license, transitive risk) with APPROVE / CONDITIONAL (with stated conditions) / REJECT verdict. Live security testing — black-box probes against the staging system covering OWASP Top 10 (web), injection vectors (API), auth/session, access control, sensitive data exposure; rates findings Critical / High / Medium / Low / Informational. Retests after Builder fixes — never closes a finding without confirmation. Tracks High deferrals — max one cycle, second cycle without resolution is a Demo Sign-off blocker.
- **Does NOT:** Test against production without explicit Nexus approval (staging only). Run destructive tests without explicit Nexus per-test approval. Approve a dependency with known Critical/High CVEs without escalating. Pass live testing with unresolved Critical/High findings. Close a finding as "resolved inline" without a Verifier confirmation entry. Read implementation source code (live testing is black-box). Conflate automated CI scan results with live security testing.
- **Dispatch prompt MUST contain:** Mode — `dependency review` (with package name, version, intended use) or `live security testing` (with staging URL + access credentials + Verifier results + Architect security model). Profile (Casual = not invoked).
- **Dispatch prompt MUST NOT contain:** Instructions to test against production. Instructions to skip retest after a fix. Instructions to close a finding without Verifier confirmation. Instructions to read source code for live testing.

### Verifier (`.claude/agents/verifier.md`)

- **Does:** Writes and runs integration/system/acceptance/performance tests against the public interface (black-box). Traces every test to its REQ-NNN. Adds negative cases beyond the Analyst's GWT minimum, tagged `[VERIFIER-ADDED]`. Produces the Verification Report (PASS / PARTIAL / FAIL per criterion + observations). On PASS: stages Builder's files + own test files, commits `task(TASK-NNN): <title> — verified PASS`, pushes, waits for CI green across ALL jobs; any CI regression is a FAIL that loops back to the Builder. Writes the Demo Script on PASS. On BUG-NNN: invoked BEFORE the Builder to write the reproducing test against current code (which is expected to fail).
- **Does NOT:** Modify implementation code (write access is test files only). Write unit tests (Builder's domain). Test at the function/method level. Weaken tests to make them pass. Modify or delete existing tests during iterate-loop re-verification (test immutability is a tool permission constraint, not a suggestion). Report PASS while CI is red. Label a CI failure as an "observation". Distinguish between "your" tests and "other tasks'" tests in CI — a regression is a regression.
- **Dispatch prompt MUST contain:** Task ID. Verifier mode — `initial verification` (write tests + run) or `iterate-loop re-verification` (run existing tests, do not modify). Link to acceptance criteria + Builder handoff note + REQ-NNN Definition of Done. For BUG-NNN: bug description + violated REQ-NNN + note that Verifier is invoked BEFORE Builder to write the reproducing test.
- **Dispatch prompt MUST NOT contain:** "Write the implementation", "fix the code", "modify `src/`". Instructions to change existing tests during re-verification (unless an explicit requirement-change override is stated per the rulebook). Language that treats CI failure as anything other than FAIL ("ignore the pre-existing failure", "that's not your test"). Instructions to skip the wait-for-CI-green step.

## Universal "do not include in any dispatch prompt"

Across all agents, the following instructions are dispatch-time errors:

- "Commit and push when you're done" — every agent has its own commit rule; Builder commits nothing, Verifier owns the source commit on PASS+CI green, Orchestrator commits process artefacts, DevOps commits infra. Do not paraphrase the commit rule into the prompt. The agent's rulebook owns it.
- "Wait for CI green" — only the Verifier and DevOps do this, and only as defined by their own protocols. Never instruct any other agent to wait for CI.
- "Open a PR" / "merge" — no agent in this project's current configuration opens PRs as part of normal dispatch; the working branch model is direct-to-master with CI gating. Do not invent a PR step.
- "Run the acceptance tests yourself" addressed to the Builder — acceptance tests are the Verifier's domain. The Builder runs unit tests only.
- "Bypass the Verifier this time" / "skip the Verifier because the change is small" — there is no such path. Every task goes through the Verifier.
- "Make it pass CI by weakening the test" — never. If a test is "hard to pass", that is information about the implementation.

## Auto-chaining and dispatch

Per `CLAUDE.md`, when an agent's output ends with `**Next:** Invoke @nexus-orchestrator — ...`, auto-chain to the Orchestrator. When the Orchestrator's output instructs invoking a specific agent, auto-chain to that agent. The dispatch prompt for the target agent is whatever the Orchestrator wrote, plus the standard context (project-state, links). It is NOT an opportunity for the relayer to insert additional steps. If the Orchestrator did not say "Builder, also push", do not add it.

If you find yourself adding steps that the Orchestrator did not include, stop. The Orchestrator's rulebook explicitly forbids it from rewriting agent behaviour — and so does this relay path.

## Related skills

- `.claude/skills/commit-discipline/SKILL.md` — who commits what, the Verifier commit protocol, the Orchestrator commit protocol, the DevOps Phase 1 commit protocol.
- `.claude/skills/ci-push-discipline/SKILL.md` — never push while CI is active on the same branch.
- `.claude/skills/handoff-hygiene/SKILL.md` — the shape of a handoff note and what it must contain.
- `.claude/skills/bash-execution/SKILL.md` — required for any agent that uses Bash.
- `.claude/skills/traceability-links/SKILL.md` — how to write Required-documents links in routing instructions.
- `.claude/skills/mermaid-diagrams/SKILL.md` — required for any agent producing diagrams.
- `.claude/skills/graphic-design/SKILL.md` — required for Designer (or Builder at Casual handling UI).

## The two-line self-check, every time

Before sending a routing prompt:

1. **"Does this prompt ask the agent to do anything its `You Must Not` section forbids?"** — If yes, remove it.
2. **"If this agent does exactly what I wrote, and nothing else, will the project be in a valid state for the next agent in the chain?"** — If no, the prompt is incomplete or wrong.

If both answers are clean, dispatch. If not, fix the prompt first.
