<!--
Copyright 2026 Pablo Ochendrowitsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# OQ-0010: What Defines a "Builder Session" for LLM-Based Agents?

**Status:** Open (Deferred to implementation phase)
**Date:** 2026-03-12
**Priority:** Medium

## Question

The Planner's task atomicity rule states that a task is not atomic if it takes "more than one focused Builder session." But a Builder session has no defined duration, scope, or boundary. For human developers, "one session" has intuitive meaning — a focused block of work, roughly half a day. For an LLM-based Builder agent, this has no operational meaning.

What constitutes a single Builder session in the context of an LLM agent? Is it a single prompt-response cycle? A single context window? A time-boxed period? A scope-bounded unit (e.g., one feature file, one test file, no more than N acceptance criteria)?

## Why It Matters

Task atomicity is a load-bearing concept in the Planner. Every task must be "one Builder session, one Verifier check, one clear acceptance criterion." The Builder agent (builder.md) enforces scope discipline per task — it implements one task per invocation. If the Planner produces tasks that are too large for a single Builder invocation but has no way to judge this, the Builder will either fail silently (produce incomplete implementations) or deviate from scope discipline (implementing only part of the task without flagging it).

This also affects the Verifier — a task that is too large for one Builder session is likely too large for one Verifier check.

## Why Deferred

This question cannot be answered well during the design phase. The answer depends on:
- Which LLMs are used as Builder agents and their effective context window sizes
- Empirical observation of what task scopes LLM Builders handle reliably
- Whether the framework uses single-turn or multi-turn Builder invocations

These are implementation-phase concerns. The current heuristic ("one demonstrable outcome") is sufficient for the design phase. The question should be revisited when Builder agents are being tested against real tasks.

## Resolve By

Before the Builder agent is used on a real project. Specifically, during or immediately after the first implementation-phase pilot where the Planner's task sizing can be validated against actual Builder performance.

## Options Being Considered

**Option A — Define by output scope:**
A task is one Builder session if it produces one feature file and its acceptance criteria can be listed on one screen. Proxy for complexity, not time.

**Option B — Define by context budget:**
A task is one Builder session if the task description, relevant code context, and acceptance criteria fit within a defined fraction of the Builder's context window (e.g., leaving at least 50% for the implementation itself).

**Option C — Keep it as a heuristic and let the Builder signal violations:**
Do not define it precisely. Instead, add a Builder escalation trigger: "If implementing the task requires more than one logical step that could be independently verified, signal that the task may not be atomic." The Planner then splits on the Builder's signal.

**Option D — Empirical calibration:**
Run a pilot with several task sizes and measure Builder success rate. Define "one session" as the scope at which Builder success rate stays above a threshold (e.g., 90% of tasks completed correctly on first attempt).

## Blocking

- Does not block any current design work
- Will affect the Planner's task sizing guidance when implementation begins
- May affect the Builder's escalation triggers (builder.md)
