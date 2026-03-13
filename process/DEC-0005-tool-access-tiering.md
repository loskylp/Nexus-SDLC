# DEC-0005 — Tool Access Tiering and Blast Radius Control

**Status:** Accepted
**Date:** 2026-03-12

## Context

The RATIONALE.md establishes "Bounded Blast Radius" as a core design goal: no agent action that affects shared or irreversible state may proceed without prior authorization. In a framework with no software runtime (OQ-0005), tool access cannot be enforced through programmatic ACLs. The question becomes: how do you control what agents are allowed to do when the only enforcement mechanism is the LLM's prompt adherence and the human's capability gating?

The answer is a classification framework — a tiered model that serves two purposes simultaneously. First, it classifies what each agent should be allowed to do, providing design guidance when writing agent definitions. Second, it communicates to the human what capabilities to grant when invoking each agent in an LLM session.

## Decision

### Tool Access Tiers (Declared, Not Enforced)

**Tier 0 — Read and Reason (all agents):**
- Read project artifacts relevant to the role
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
- Builder: build, test, lint commands
- Verifier: run test suite
- Sentinel: run security tests against staging through its public interface
- DevOps: pipeline commands, deployment commands
- Architect: spike execution commands within `spikes/SPIKE-NNN/` directory only
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

This model is weaker than programmatic ACLs. An LLM may violate prompt instructions. Mitigations: strong negative instructions in agent files, human review of all agent output, and the human gate structure (Requirements Gate, Plan Gate, Demo Sign-off) catches violations before they reach shared state. The framework is honest about this limitation rather than pretending prompt instructions are equivalent to access control.

## Reasoning

**Why retain the tier model without enforcement:** The tiers serve two purposes that survive without programmatic enforcement. Classification tells the agent definition author what scope each agent should have. Communication tells the human what capabilities to grant. Both are valuable even without a runtime to enforce them.

**Why "declared, not enforced" rather than claiming enforcement:** Intellectual honesty. Pretending prompt instructions are equivalent to ACLs would be misleading and would create false confidence. Naming the limitation explicitly directs attention to the actual enforcement mechanisms (human review, capability gating) rather than a fictional one.

**Why five tiers and not fewer:** The Builder needs file write but not production deployment. The Sentinel needs command execution against staging but not file write to source code. A binary trust model (trusted/untrusted) cannot express these distinctions. Five tiers provide the granularity needed to match each agent's actual scope without over-granting.

**Why Tier 3 exists between Tier 2 and Tier 4:** Some actions (installing dependencies, creating migrations) are not as dangerous as production deployment but are more consequential than running a test. They alter the project's dependency tree or schema — changes that propagate to all subsequent work. Requiring the agent to state intent and confirm it was anticipated in the plan catches unplanned scope expansion.

## Alternatives Considered

**Abandon tiering entirely (trust the LLM):** Simpler but provides no framework for the human to reason about what each agent should do. The tiers are valuable as documentation and design guidance even without enforcement. Rejected for loss of design guidance.

**Require specific tooling that enforces ACLs:** Would restore programmatic enforcement but violates OQ-0005 (no software runtime). Could be a future enhancement if someone builds a Nexus SDLC runner, but is not viable for the file-based v1. Rejected for infrastructure dependency.

**Binary trust model (trusted agents get everything, untrusted get nothing):** Too coarse. The Builder needs file write but not network access. The Sentinel needs network access but not file write to source code. Binary models cannot express this. Rejected for insufficient granularity.

**Three tiers (read / write / admin):** Better than binary but still too coarse. Cannot distinguish between "write to test files" (Verifier) and "write to source code" (Builder), or between "execute build commands" (Builder) and "deploy to production" (DevOps). Rejected for the same reason.

## Consequences

- No infrastructure is needed for access control — the framework remains runtime-free.
- Clear guidance for the human on what capabilities to grant each agent session.
- No guarantee agents stay within bounds — the model relies on prompt adherence and human vigilance.
- Every agent definition file must include a "Tool Permissions" section with explicit MAY / MAY NOT / MUST ASK instructions.
- Spike execution (Architect) is Tier 2 — commands run in `spikes/SPIKE-NNN/` only, never in `src/`.
- The human gate structure provides a secondary enforcement layer — misaligned agent behavior is caught at Requirements Gate, Plan Gate, or Demo Sign-off before it affects shared state.
