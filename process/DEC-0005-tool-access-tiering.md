# DEC-0005: Tool Access Tiering and Blast Radius Control

**Status:** Proposed (Revised 2026-03-12)
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect

**Revision note:** Following the resolution of OQ-0005 (no software runtime), tool access tiers are no longer enforced by code. They are declared behavioral constraints in each agent definition file. Enforcement relies on two mechanisms: (1) the LLM following the prompt instructions, and (2) the human not granting capabilities beyond what the agent file declares.

## Context

The RATIONALE.md establishes "Bounded Blast Radius" as a core design goal: no agent action that affects shared or irreversible state may proceed without prior authorization. In a prompt-only framework, there is no ACL layer, no sandbox, and no programmatic enforcement. Tool access must be controlled through agent behavioral instructions and human discipline.

## Decision

### Tool Access Tiers (Declared, Not Enforced)

The five-tier model is retained as a classification framework. Each agent definition file declares its tier and includes specific behavioral instructions that implement the tier's constraints.

**Tier 0 — Read and Reason (all agents):**
- Read project files and Project Context sections relevant to the role
- Reason about the task and produce structured output
- Emit reasoning traces
- **Agent file instruction:** "You have read-only access. You produce analysis, plans, and recommendations. You do not create, modify, or delete any files."

**Tier 1 — Scoped Write (Coder, QA, Integrator):**
- Create and modify files within the declared scope
- Coder: production code and configuration for the assigned task only
- QA: test files only
- Integrator: branch and merge operations on the working branch only
- **Agent file instruction:** "You may create and modify files, but ONLY within [scope]. You must list every file you create or modify in your output. You must not touch files outside your assigned task scope."

**Tier 2 — Command Execution (Coder, QA, Integrator):**
- Run build commands, test suites, linters
- All execution should be on the working branch in a local environment
- **Agent file instruction:** "You may execute commands to build, test, and lint. You must not execute commands that access the network, modify global system state, or affect files outside the project directory."

**Tier 3 — Restricted (declared, requires Orchestrator acknowledgment):**
- Install new dependencies
- Modify CI/CD configuration
- Create database migrations
- **Agent file instruction:** "Before performing any of the following actions, you must state your intent, explain why it is necessary, and confirm it was anticipated in the approved plan: [list]. If it was not anticipated, flag this as an escalation for the Nexus."

**Tier 4 — Human-Gated (requires explicit Nexus approval within the conversation):**
- Push to any remote branch
- Modify deployment configurations
- Access external APIs
- Modify security-sensitive files
- Delete files outside current task scope
- **Agent file instruction:** "You MUST NOT perform any of the following actions without explicit approval from the Nexus in this conversation: [list]. If you believe one of these actions is necessary, state what you want to do, why, and what the consequences are, then STOP and wait for approval."

### Enforcement Model

```
Enforcement = LLM prompt adherence + Human capability gating
```

1. **LLM prompt adherence:** The agent definition file's "You Must Not" and "Tool Permissions" sections instruct the LLM on behavioral boundaries. Well-designed prompts with strong negative instructions are followed reliably by frontier LLMs.

2. **Human capability gating:** The human controls what capabilities are available to the LLM session. If the Reviewer agent's definition says "read-only," the human should not give the LLM write access to the codebase in that session. The Orchestrator agent's instructions include guidance for the human on what capabilities to grant each agent.

3. **Audit through output contracts:** Every agent must list the actions it took in its output. The human reviews this before applying changes. This is the post-hoc enforcement layer — catching violations after the fact but before they reach the codebase.

### Known Limitation

This enforcement model is weaker than programmatic ACLs. A sufficiently capable LLM given write access may ignore prompt instructions. The mitigations are:
- Strong negative instructions in agent definitions (empirically effective with frontier models)
- Human review of all agent output before applying changes
- The Nexus Check and Nexus Merge gates catch violations before they reach shared state
- The human can always refuse to apply an agent's output

## Rationale

**Why retain the tier model without enforcement:** The tiers serve two purposes — classification (what should this agent be allowed to do?) and communication (what capabilities should the human grant?). Both purposes survive the loss of programmatic enforcement. The tiers become a shared vocabulary between the agent definitions and the human.

**Why "declared, not enforced":** Honest acknowledgment of the constraint. Pretending prompt instructions are equivalent to ACLs would be misleading. By naming the enforcement gap, we can design mitigations (output review, human capability gating) rather than assuming a guarantee that does not exist.

**Why human capability gating:** This is the practical enforcement mechanism. If the human loads the Reviewer agent into a read-only session (no code execution, no file editing), the LLM cannot violate read-only access regardless of what the prompt says. The human's choice of interface capabilities is the real ACL.

## Consequences

**Easier:**
- No infrastructure needed for access control
- Tier classification remains useful for agent definition design
- The human has clear guidance on what capabilities to grant each agent

**Harder:**
- No guarantee that agents stay within bounds — relies on prompt adherence and human vigilance
- More cognitive load on the human to verify that agents acted within scope
- Security-sensitive projects may need stronger enforcement than prompts alone can provide

**Newly constrained:**
- Every agent definition file must include a "Tool Permissions" section with explicit MAY/MAY NOT/MUST ASK instructions
- The Orchestrator agent's definition must include guidance for the human on capability gating per agent role
- Agent outputs must include an "Actions Taken" section for audit purposes

## Alternatives Considered

**Abandon tiering entirely (trust the LLM):** Simpler but provides no framework for the human to reason about what each agent should do. The tiers remain valuable as documentation even without enforcement. Rejected for loss of design guidance.

**Require specific tooling that enforces ACLs:** Would restore programmatic enforcement but violates OQ-0005 (no software runtime). Could be a future enhancement if someone builds a Nexus SDLC runner, but is not viable for the file-based v1. Rejected for infrastructure dependency.

**Binary trust model (trusted agents get everything, untrusted get nothing):** Too coarse. The Coder needs file write but not network access. Binary models cannot express this. Rejected for insufficient granularity.
