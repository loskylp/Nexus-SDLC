# Scaffold Manifest — [Project Name]
**Version:** [N] | **Date:** [date]
**Artifact Weight:** [Sketch | Draft | Blueprint | Spec]

## Structure Overview
[Directory tree of what was created]

## Components

### [ComponentName] — [file path]
**Responsibility:** [What this component owns, in one sentence]
**Architectural source:** [ADR-NNN or Architecture Overview section]

#### Exported interfaces

| Element | Kind | Signature summary | Contract |
|---|---|---|---|
| [name] | [class / function / interface / type] | [brief signature] | [what it promises] |

## Dependencies between components
[Which components call which — used by the Planner to sequence Builder tasks correctly]

| Component | Depends on | Nature of dependency |
|---|---|---|
| [component] | [component] | [calls / implements / extends] |

## Builder task surface
[Explicit list of what is left to implement — one entry per unimplemented method or function.
The Planner uses this to create or refine Builder tasks.]

| Element | Location | Complexity signal |
|---|---|---|
| [ClassName.methodName] | [file:line] | [Low / Medium / High — the Scaffolder's read on implementation complexity] |
