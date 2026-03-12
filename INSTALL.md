# Installing Nexus SDLC

Nexus SDLC delivers as loadable agent definition files. The install script copies them into the right location for your LLM interface. Currently supported: **Claude Code**.

---

## Requirements

- [Claude Code](https://claude.ai/code) (`claude` CLI) installed and authenticated
- `bash` (macOS, Linux, or WSL)
- Git (to clone this repo)

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/your-org/Nexus-SDLC.git ~/nexus-sdlc
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

This copies the 9 Nexus SDLC agent files into `~/my-project/.claude/agents/`.

### 4. Start Claude Code in your project

```bash
cd ~/my-project
claude
```

Claude Code automatically picks up agents from `.claude/agents/`. You can now invoke any Nexus agent by name.

---

## Installation Modes

### Project install (recommended for testing)

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

Installs to `~/.claude/agents/`. Use this when you want Nexus available everywhere.

---

## Running the Ingestion Phase

Once Claude Code is running in your project:

**Option A — Let the Orchestrator drive:**
```
@nexus-orchestrator I'm starting a new project. Here's what I want to build: [describe your project]
```

**Option B — Start with the Methodologist:**
```
@nexus-methodologist I'm starting a new project. Help me configure the swarm.
```

**Option C — Go straight to ingestion:**
```
@nexus-analyst I want to build [describe your project]. Here's the context: [...]
```

The typical ingestion sequence is:
```
nexus-analyst → nexus-auditor → (repeat until clean) → Nexus Gate → nexus-architect → nexus-planner
```

---

## Agents Installed

| Agent | Role | When to invoke |
|---|---|---|
| `nexus-methodologist` | Configures the swarm | First on any new project |
| `nexus-orchestrator` | Control plane | When you want the swarm to decide what's next |
| `nexus-analyst` | Requirements | Start of ingestion, after Nexus feedback |
| `nexus-auditor` | Requirements review | After every Analyst output |
| `nexus-architect` | Architecture | After Requirements Gate |
| `nexus-planner` | Task planning | After Requirements Gate |
| `nexus-builder` | Implementation | One task at a time |
| `nexus-verifier` | Verification | After each Builder output |
| `nexus-integrator` | Assembly | Before Nexus Merge gate |

---

## Updating

Pull the latest from this repo and re-run the install script. It overwrites the existing agent files.

```bash
cd ~/nexus-sdlc
git pull
./install-nexus.sh --claude ~/my-project
```

---

## Uninstalling

**Project:** delete `.claude/agents/nexus-*.md` in your project directory.

**Personal:** delete `~/.claude/agents/nexus-*.md`.
