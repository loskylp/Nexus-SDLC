# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Nexus SDLC** is a Human-in-the-Middle (HITM) orchestration framework that coordinates a swarm of specialized autonomous agents to automate the end-to-end software development lifecycle.

The core principle is **Managed Autonomy**: a human ("The Nexus") provides high-level goals and approves critical checkpoints, while specialized agents handle decomposition, implementation, verification, and iteration autonomously.

## Architecture

Three-layer model:

- **The Nexus (Human)** — strategic control: sets goals, approves plans, validates before production
- **The Swarm (Agents)** — autonomous specialized units that decompose tasks, implement, and self-correct via feedback loops
- **Dynamic Orchestration Layer** — manages state, agent hand-offs, and unified context across the lifecycle

**Workflow:**
1. Human defines high-level goal
2. Orchestrator decomposes into atomic tasks → human approves plan
3. Swarm executes with continuous validation (tests, lint, security)
4. On failure, swarm iterates autonomously
5. Clean PR surfaced to Nexus for final merge

## Current State

This repository is in the **design/architecture phase** — no implementation exists yet. No build system, test runner, or language stack has been chosen. Before writing any code, align on the technology stack and scaffold accordingly.

## Key Design Constraints

- **Safety by Design:** Agents must not execute high-risk operations without explicit Nexus approval
- **Traceable Reasoning:** All agent decisions must be logged for audit trails
- **Human checkpoints are non-negotiable** — the Nexus Check (step 3) and final PR merge (step 5) must remain human-gated
