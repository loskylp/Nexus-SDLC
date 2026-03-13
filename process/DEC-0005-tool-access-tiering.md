# DEC-0005: Tool Access Tiering and Blast Radius Control

**Status:** Accepted (revised — role names updated)
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

## Context

The RATIONALE.md establishes "Bounded Blast Radius" as a core design goal. In a prompt-only framework with no runtime, tool access must be controlled through agent behavioral instructions and human capability gating. The tier model provides a classification framework. This decision is unchanged from the initial proposal except that role names now match the actual agent roster from DEC-0001.

## Decision

### Tool Access Tiers (Declared, Not Enforced)

**Tier 0 — Read and Reason (all agents):**
- Read project artifacts and artifact trail files relevant to the role
- Reason about the task and produce structured output
- Emit reasoning traces
- Instruction: "You have read-only access to project artifacts. You produce analysis, plans, and recommendations. You do not create, modify, or delete any files."

**Tier 1 — Scoped Write:**
- Builder: source code and configuration for the assigned task only; unit tests
- Scaffolder: scaffold files (new files only; never modifies existing implemented files)
- Verifier: test files (integration, system, acceptance, performance)
- Scribe: documentation files in `docs/`, `CHANGELOG.md`, release notes
- DevOps: CI/CD configuration, infrastructure manifests
- Instruction: "You may create and modify files, but ONLY within [scope]. List every file you create or modify in your output. Do not touch files outside your assigned task scope."

**Tier 2 — Command Execution:**
- Builder: build, test, lint
- Verifier: run test suite
- Sentinel: run security tests against the staging environment through its public interface
- DevOps: pipeline commands, deployment commands
- Architect: spike execution commands within `spikes/SPIKE-NNN/` directory
- Instruction: "You may execute commands to build, test, and run security tests. You must not execute commands that access the production environment, modify global system state, or affect files outside the project directory."

**Tier 3 — Restricted (declared, requires Orchestrator acknowledgment):**
- Installing new dependencies
- Creating database migrations
- Modifying CI/CD configuration
- Instruction: "Before performing any Tier 3 action, state your intent, explain why it is necessary, and confirm it was anticipated in the approved plan. If it was not anticipated, flag this as an escalation."

**Tier 4 — Human-Gated (requires explicit Nexus approval):**
- Deploying to production
- Accessing external APIs in a production context
- Modifying security-sensitive files
- Deleting files outside current task scope
- Instruction: "You MUST NOT perform any Tier 4 action without explicit approval from the Nexus in this conversation. State what you want to do, why, and what the consequences are, then STOP and wait for approval."

### Enforcement Model

```
Enforcement = LLM prompt adherence + Human capability gating + Output review
```

1. **LLM prompt adherence:** The "You Must Not" and "Tool Permissions" sections in each agent file instruct the LLM on behavioral boundaries.
2. **Human capability gating:** The human controls what capabilities are available in the LLM session. Loading the Sentinel agent into a session without production access enforces read-only security testing regardless of what the prompt says.
3. **Output review:** Every agent lists actions taken in its output. The human reviews before applying changes.

### Known Limitation

This model is weaker than programmatic ACLs. Mitigations: strong negative instructions, human review of all agent output, and the human gate structure (Requirements Gate, Plan Gate, Demo Sign-off) catches violations before they reach shared state.

## Rationale

**Why retain the tier model without enforcement:** The tiers serve two purposes — classification (what should this agent be allowed to do?) and communication (what capabilities should the human grant?). Both purposes survive without programmatic enforcement.

**Why "declared, not enforced":** Honest acknowledgment of the constraint. Pretending prompt instructions are equivalent to ACLs would be misleading.

## Consequences

**Easier:**
- No infrastructure needed for access control
- Clear guidance for the human on what capabilities to grant each agent

**Harder:**
- No guarantee agents stay within bounds — relies on prompt adherence and human vigilance

**Newly constrained:**
- Every agent definition file must include a "Tool Permissions" section with explicit MAY/MAY NOT/MUST ASK instructions
- Spike execution (Architect) is Tier 2 — commands run in `spikes/SPIKE-NNN/` only, never in `src/`

## Alternatives Considered

**Abandon tiering entirely (trust the LLM):** Simpler but provides no framework for the human to reason about what each agent should do. The tiers remain valuable as documentation even without enforcement. Rejected for loss of design guidance.

**Require specific tooling that enforces ACLs:** Would restore programmatic enforcement but violates OQ-0005 (no software runtime). Could be a future enhancement if someone builds a Nexus SDLC runner, but is not viable for the file-based v1. Rejected for infrastructure dependency.

**Binary trust model (trusted agents get everything, untrusted get nothing):** Too coarse. The Builder needs file write but not network access. Binary models cannot express this. Rejected for insufficient granularity.
