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

# Installing Nexus SDLC

Nexus SDLC delivers as loadable agent definition files. The install script copies them into the right location for your LLM interface. Currently supported: **Claude Code**.

For usage guidance, initial prompts, and special scenario prompts (bugs, late requirements, profile upgrades), see [USAGE.md](USAGE.md).

---

## Requirements

- [Claude Code](https://claude.ai/code) (`claude` CLI) installed and authenticated
- `bash` (macOS, Linux, or WSL)
- Git (to clone this repo)

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/loskylp/Nexus-SDLC.git ~/nexus-sdlc
```

### 2. Create your project directory

```bash
mkdir ~/my-project
cd ~/my-project
git init
```

### 3. Install Nexus agents into your project

```bash
~/nexus-sdlc/install-nexus.sh --claude ~/my-project
```

This installs:
- 13 agent definition files → `~/my-project/.claude/agents/`
- Output templates → `~/my-project/resources/`

### 4. Start Claude Code in your project

```bash
cd ~/my-project
claude
```

Claude Code automatically picks up agents from `.claude/agents/`. Invoke any Nexus agent with `@nexus-<agent-name>`.

### 5. Start your first project

Open [USAGE.md — Starting a project](USAGE.md#starting-a-project) for the prompt that kicks off the swarm.

---

## Installation Modes

### Project install (recommended)

Agents are scoped to a single project directory. Different projects can have different agent versions.

```bash
./install-nexus.sh --claude ~/my-project
./install-nexus.sh --claude .          # install into current directory
```

### Personal install (global)

Agents are available in every Claude Code session, regardless of project.

```bash
./install-nexus.sh --claude --personal
```

Installs agents to `~/.claude/agents/` and templates to `~/.claude/nexus/resources/`.

Agents look for blank templates in `resources/` inside the project they're running in. Before starting a new project, copy the templates there:

```bash
cp -r ~/.claude/nexus/resources ~/my-project/resources
```

A project install (`--claude <dir>`) does this automatically.

---

## Agents Installed

| Agent | Role |
|---|---|
| `nexus-methodologist` | Configures the swarm — profile, active agents, gate behavior |
| `nexus-orchestrator` | Control plane — state, routing, escalation, Nexus briefings |
| `nexus-analyst` | Ingestion — turns goals into a structured Requirements List |
| `nexus-auditor` | Requirements and architecture integrity checking |
| `nexus-architect` | Architecture decisions, ADRs, and fitness functions |
| `nexus-designer` | UX specification — flows, wireframes, interaction spec |
| `nexus-scaffolder` | Code structure — signatures and contracts before Builder begins |
| `nexus-planner` | Task Plan and Release Map |
| `nexus-builder` | Implementation — one task at a time |
| `nexus-verifier` | Verification — tests against acceptance criteria |
| `nexus-sentinel` | Security — dependency evaluation and live security testing |
| `nexus-devops` | Delivery infrastructure — CI/CD, environments, config management |
| `nexus-scribe` | Release documentation — publishes versioned docs at release time |

---

## Updating

Pull the latest from this repo and re-run the install script. It overwrites existing agent and template files.

```bash
cd ~/nexus-sdlc
git pull
./install-nexus.sh --claude ~/my-project
```

---

## Uninstalling

**Project:**

```bash
rm ~/my-project/.claude/agents/nexus-*.md
rm -rf ~/my-project/resources
```

**Personal:**

```bash
rm ~/.claude/agents/nexus-*.md
rm -rf ~/.claude/nexus
```
