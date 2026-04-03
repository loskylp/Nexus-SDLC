#!/usr/bin/env bash
# Copyright 2026 Pablo Ochendrowitsch
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# install-nexus.sh — Install Nexus SDLC agents into a Claude Code project or personal config
#
# Agent source files are LLM-agnostic markdown. This script injects the
# platform-specific frontmatter (name, description, model, color) at install time.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="$SCRIPT_DIR/agents"
RESOURCES_SRC="$SCRIPT_DIR/resources"
SKILLS_SRC="$SCRIPT_DIR/skills"

# ── Helpers ───────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: install-nexus.sh <--claude | --opencode> [--personal | <project-dir>]

Install Nexus SDLC agents as Claude Code or OpenCode subagents.

Options:
  --claude                 Install for Claude Code
  --opencode               Install for OpenCode
  
  --personal               Install agents globally
                           (available in every session for the target platform)
  <project-dir>            Install agents into the specified project directory
                           (available only when running inside that project)

Examples:
  ./install-nexus.sh --opencode ~/my-project
  ./install-nexus.sh --claude --personal
  ./install-nexus.sh --opencode .

Agents installed:
  nexus-methodologist  Configure the swarm for a new project (start here)
  nexus-orchestrator   Control plane — determines what happens next
  nexus-analyst        Ingestion phase — turns goals into requirements
  nexus-auditor        Reviews requirements for completeness and consistency
  nexus-architect      Architecture — ADRs and fitness functions
  nexus-planner        Decomposition — ordered Task Plan
  nexus-designer       UX/interaction design — flows and specs for user-facing features
  nexus-scaffolder     Code structure — files, signatures, and contracts for Builder
  nexus-builder        Execution — implements one task at a time
  nexus-verifier       Verification — tests implementation against criteria
  nexus-devops         Delivery infrastructure — CI/CD, environments, config management
  nexus-sentinel       Security — dependency evaluation and live security testing
  nexus-scribe         Release documentation — extracts and publishes versioned docs at release time
EOF
}

die() { echo "error: $*" >&2; exit 1; }

# Returns "name|description|model|color" for a given filename, empty string if unknown.
agent_meta() {
    case "$1" in
        analyst.md)
            echo 'nexus-analyst|Nexus SDLC — Analyst: Turns project goals and context into a structured, numbered requirements list. Invoke at the start of ingestion phase or when incorporating Nexus feedback after an Auditor review.|mid|blue'
            ;;
        architect.md)
            echo 'nexus-architect|Nexus SDLC — Architect: Defines system structure, produces ADRs and fitness functions. Invoke after the Requirements Gate is approved, before the Plan Gate. Also consult during execution when tasks surface architectural decisions.|high|purple'
            ;;
        auditor.md)
            echo 'nexus-auditor|Nexus SDLC — Auditor: Reviews the Analyst Requirements List for completeness, consistency, and traceability. Invoke after every Analyst output. Also runs regression checks when new requirements arrive after a demo.|high|red'
            ;;
        builder.md)
            echo 'nexus-builder|Nexus SDLC — Builder: Implements a single atomic task from the Task Plan. Invoke with one task at a time. Does not plan, architect, or verify — pure implementation.|lo|green'
            ;;
        methodologist.md)
            echo 'nexus-methodologist|Nexus SDLC — Methodologist: Configures the swarm for a project — selects the profile (Casual/Commercial/Critical/Vital) and produces the Methodology Manifest. Invoke first on any new project, and again at major phase transitions or when the process feels broken.|high|yellow'
            ;;
        orchestrator.md)
            echo 'nexus-orchestrator|Nexus SDLC — Orchestrator: Operational control plane. Knows current project state, determines which agent to invoke next, manages the iterate loop, and escalates to the Nexus. Invoke when you want the swarm to determine what happens next.|mid|orange'
            ;;
        planner.md)
            echo 'nexus-planner|Nexus SDLC — Planner: Turns approved Requirements List and Architect output into an ordered Task Plan. Invoke after the Requirements Gate. Also handles plan revisions after demo feedback, spike findings, or Nexus-invoked release map reviews.|mid|blue'
            ;;
        designer.md)
            echo 'nexus-designer|Nexus SDLC — Designer: Translates approved requirements into UX flows, interaction specifications, and component structures that Builder can implement. Invoked when the delivery channel requires a visual interface. At Casual, Builder handles UI directly via the graphic-design skill.|mid|pink'
            ;;
        devops.md)
            echo 'nexus-devops|Nexus SDLC — DevOps: Builds and maintains the delivery infrastructure — CI/CD pipelines, environments, configuration management, and production monitoring. Not invoked at Casual. At Commercial and above, invoke to set up the pipeline before Builder begins, provision environments in parallel with Builder tasks, and prepare production before the Go-Live gate.|lo|gray'
            ;;
        verifier.md)
            echo 'nexus-verifier|Nexus SDLC — Verifier: Verifies a Builder implementation against task acceptance criteria and the requirement Definition of Done. Invoke after each Builder output. Writes and runs tests, produces a structured verification report.|lo|cyan'
            ;;
        sentinel.md)
            echo 'nexus-sentinel|Nexus SDLC — Sentinel: Security and dependency protection. Evaluates new dependencies before adoption (license, CVEs, maintenance, transitive risk) and runs live security testing against staging before each release. Not invoked at Casual.|lo|red'
            ;;
        scaffolder.md)
            echo 'nexus-scaffolder|Nexus SDLC — Scaffolder: Translates architectural decisions into code structure — files, signatures, interfaces, and contracts — that Builder implements against. Invoke after Architecture Gate, before Builder begins. Does not implement logic.|lo|purple'
            ;;
        scribe.md)
            echo 'nexus-scribe|Nexus SDLC — Scribe: Release documentation publisher. Invoked at release time — extracts and transforms living documentation (code annotations, UX flows, Demo Scripts) into versioned release artifacts: reference docs, Swagger specs, user manuals, release notes, and changelog. Not invoked at Casual.|lo|yellow'
            ;;
        *)
            echo ''
            ;;
    esac
}

translate_model() {
    local internal_model="$1"
    local mode="$2"
    local agent_filename="$3"

    if [[ "$mode" == "claude" ]]; then
        if [[ "$internal_model" == "high" ]]; then
            echo "opus"
        else # mid and lo
            echo "sonnet"
        fi
    elif [[ "$mode" == "opencode" ]]; then
        if [[ "$internal_model" == "high" ]]; then
            echo "google/gemini-3-pro-preview"
        elif [[ "$internal_model" == "mid" ]]; then
            echo "google/gemini-2.5-pro"
        elif [[ "$internal_model" == "lo" ]]; then
            case "$agent_filename" in
                builder.md|verifier.md)
                    echo "google/gemini-3-flash"
                    ;;
                *)
                    echo "google/gemini-2-flash"
                    ;;
            esac
        fi
    fi
}

translate_color_to_hex() {
    case "$1" in
        blue) echo '#579dff' ;;
        purple) echo '#af8dff' ;;
        red) echo '#ff726f' ;;
        green) echo '#50e3c2' ;;
        yellow) echo '#f8e71c' ;;
        orange) echo '#f5a623' ;;
        pink) echo '#ff8de4' ;;
        gray) echo '#9b9b9b' ;;
        cyan) echo '#72f1ff' ;;
        *) echo '#ffffff' ;; # Default to white if color is unknown
    esac
}


install_agent() {
    local src_file="$1"
    local dest_dir="$2"
    local mode="$3"
    local filename
    filename="$(basename "$src_file")"

    local meta
    meta="$(agent_meta "$filename")"

    if [[ -z "$meta" ]]; then
        echo "  ! $filename (no Claude metadata — skipping)"
        return
    fi

    local name description internal_model color target_model
    name="${meta%%|*}";          meta="${meta#*|}"
    description="${meta%%|*}";   meta="${meta#*|}"
    internal_model="${meta%%|*}"; color="${meta#*|}"
    
    target_model="$(translate_model "$internal_model" "$mode" "$filename")"

    {
        printf -- '---\n'
        printf 'name: %s\n' "$name"
        printf 'description: "%s"\n' "$description"
        printf 'model: %s\n' "$target_model"
        
        if [[ "$mode" == "opencode" ]]; then
            printf 'mode: subagent\n'
            local hex_color
            hex_color="$(translate_color_to_hex "$color")"
            printf 'color: %s\n' "$hex_color"
            printf 'permission:\n'
            printf '  edit: deny\n'
            printf '  bash:\n'
            printf '    "*": ask\n'
            printf '    "ls*": allow\n'
            printf '    "cat*": allow\n'
            printf '    "grep*": allow\n'
        else
            printf 'color: %s\n' "$color"
        fi
        
        printf 'author: Pablo Ochendrowitsch\n'
        printf 'license: Apache-2.0\n'
        printf -- '---\n\n'
        awk '/^<!--/{skip=1} skip{if(/-->/)skip=0; next} 1' "$src_file" | sed '/^$/N;/^\n$/D'
    } | sed \
        -e "s|\\.\\./resources/|.\${mode}/resources/|g" \
        -e "s|\`resources/|\`.\${mode}/resources/|g" \
        > "$dest_dir/$filename"

    echo "  ✓ $filename → $name"
}

# ── Argument parsing ──────────────────────────────────────────────────────────

MODE=""
TARGET_DIR=""
PERSONAL=false

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --claude)
            MODE="claude"
            shift
            ;;
        --opencode)
            MODE="opencode"
            shift
            ;;
        --personal)
            PERSONAL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            die "unknown option: $1"
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

[[ -n "$MODE" ]] || die "specify a mode: --claude or --opencode"

# ── Determine install destination ─────────────────────────────────────────────

if [[ "$MODE" == "claude" ]]; then
    if $PERSONAL; then
        DEST_DIR="${HOME}/.claude/agents"
        RESOURCES_DEST="${HOME}/.claude/resources"
        SKILLS_DEST="${HOME}/.claude/skills"
    elif [[ -n "$TARGET_DIR" ]]; then
        TARGET_DIR="${TARGET_DIR%/}"
        TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || die "directory not found: $TARGET_DIR"
        DEST_DIR="$TARGET_DIR/.claude/agents"
        RESOURCES_DEST="$TARGET_DIR/.claude/resources"
        SKILLS_DEST="$TARGET_DIR/.claude/skills"
    else
        die "specify --personal or a project directory"
    fi
elif [[ "$MODE" == "opencode" ]]; then
    if $PERSONAL; then
        DEST_DIR="${HOME}/.config/opencode/agents"
        RESOURCES_DEST="${HOME}/.config/opencode/resources"
        SKILLS_DEST="${HOME}/.config/opencode/skills"
    elif [[ -n "$TARGET_DIR" ]]; then
        TARGET_DIR="${TARGET_DIR%/}"
        TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || die "directory not found: $TARGET_DIR"
        DEST_DIR="$TARGET_DIR/.opencode/agents"
        RESOURCES_DEST="$TARGET_DIR/.opencode/resources"
        SKILLS_DEST="$TARGET_DIR/.opencode/skills"
    else
        die "specify --personal or a project directory"
    fi
fi

# ── Install ───────────────────────────────────────────────────────────────────

echo "Installing Nexus SDLC agents to: $DEST_DIR"
mkdir -p "$DEST_DIR"

INSTALLED=0
for agent_file in "$AGENTS_SRC"/*.md; do
    install_agent "$agent_file" "$DEST_DIR" "$MODE"
    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Installed $INSTALLED agents."

echo ""
echo "Installing output templates to: $RESOURCES_DEST"
cp -r "$RESOURCES_SRC/." "$RESOURCES_DEST/"
echo "  ✓ resources/ → $RESOURCES_DEST (.${MODE}/resources/)"

echo ""
echo "Installing skills to: $SKILLS_DEST"
mkdir -p "$SKILLS_DEST"
cp -r "$SKILLS_SRC/." "$SKILLS_DEST/"
echo "  ✓ skills/ → $SKILLS_DEST (.${MODE}/skills/)"

# ── Project settings ───────────────────────────────────────────────────────────

if [[ "$MODE" == "claude" ]] && ! $PERSONAL; then
    SETTINGS_FILE="$TARGET_DIR/.claude/settings.json"
    echo ""
    echo "Configuring project settings: $SETTINGS_FILE"
    cat > "$SETTINGS_FILE" <<'EOF_SETTINGS'
{
  "permissions": {
    "allow": [
      "Bash(cp *)",
      "Bash(git status*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git show *)",
      "Bash(mkdir *)",
      "Bash(ls *)"
    ]
  }
}
EOF_SETTINGS
    echo "  ✓ settings.json written"
elif [[ "$MODE" == "opencode" ]] && ! $PERSONAL; then
    SETTINGS_FILE="$TARGET_DIR/.opencode/opencode.json"
    echo ""
    echo "Configuring project settings: $SETTINGS_FILE"
    cat > "$SETTINGS_FILE" <<'EOF_SETTINGS'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "cp *": "allow",
      "git status*": "allow",
      "git add *": "allow",
      "git commit *": "allow",
      "git log *": "allow",
      "git diff *": "allow",
      "git show *": "allow",
      "mkdir *": "allow",
      "ls *": "allow"
    }
  }
}
EOF_SETTINGS
    echo "  ✓ opencode.json written"
fi

# ── Pre-create process/ directories so subagents don't need to mkdir ──────────

if ! $PERSONAL; then
    PROCESS_DIR="$TARGET_DIR/process"
    echo ""
    echo "Pre-creating process/ directories: $PROCESS_DIR"
    for agent_file in "$AGENTS_SRC"/*.md; do
        filename="$(basename "$agent_file" .md)"
        meta="$(agent_meta "$(basename "$agent_file")" "$MODE")"
        [[ -z "$meta" ]] && continue
        mkdir -p "$PROCESS_DIR/$filename"
        echo "  ✓ process/$filename/"
    done
fi

# ── Project Rule File (CLAUDE.md / AGENTS.md) ────────────────────────────────

if ! $PERSONAL; then
    if [[ "$MODE" == "claude" ]]; then
        RULE_FILE="$TARGET_DIR/CLAUDE.md"
    else
        RULE_FILE="$TARGET_DIR/AGENTS.md"
    fi
    
    echo ""
    echo "Writing project rules: $RULE_FILE"
    cat > "$RULE_FILE" <<'EOF_RULES'
# Nexus SDLC Project

## Agent Auto-Chaining

### Any agent → Orchestrator

When a Nexus SDLC agent completes and its output ends with a line of the form:

> **Next:** Invoke @nexus-orchestrator — ...

Automatically invoke @nexus-orchestrator as the next step without waiting for
explicit user instruction.

### Orchestrator → other agents

The Orchestrator is the control plane. When its output instructs invoking a
specific agent (e.g., "invoke @nexus-analyst", "route to @nexus-architect"),
automatically invoke that agent as the next step without waiting for explicit
user instruction.

The Orchestrator is responsible for knowing when to pause for Nexus approval.
If it says "invoke", follow it. If it says "awaiting Nexus approval" or
presents a gate checkpoint, stop and wait for the user.

### Do not auto-chain

Do not auto-chain between non-orchestrator agents. All routing flows through
the Orchestrator.

## Agent Response Relay

When a Nexus SDLC agent's response contains a question for the user, relay the
question **verbatim**. Do not rephrase, restructure, or summarize agent questions.
The agents are designed to ask questions in a specific way — reformatting changes
the kind of answer the user gives, which breaks the intake protocol.

If the agent's response contains a line starting with **Relay:**, that is an
instruction to you, not content for the user. Follow the relay instruction and
strip it from the output.

## Shared Skills

All Nexus agents MUST read and follow the skill files in `.${MODE}/skills/` that
apply to their work:

- `bash-execution.md` — Required for ALL agents that use Bash. Never use
  `cd dir && command`. Use `git -C`, absolute paths, or tool flags instead.
- `mermaid-diagrams.md` — Required for agents producing diagrams (Architect,
  Planner, Analyst at Critical+). Use Mermaid syntax, never ASCII art.
- `graphic-design.md` — Required for the Designer when the delivery channel is
  GUI. Covers the Stitch MCP lifecycle.
EOF_RULES
    echo "  ✓ $(basename "$RULE_FILE") written (project root)"
fi

# ── Post-install hints ────────────────────────────────────────────────────────

echo ""
if $PERSONAL; then
    if [[ "$MODE" == "claude" ]]; then
        echo "Agents are now available globally in all Claude Code sessions."
    else
        echo "Agents are now available globally in all OpenCode sessions."
    fi
    echo "Output templates installed to: $RESOURCES_DEST"
    echo "Skills installed to: $SKILLS_DEST"
    echo ""
    echo "Run '$MODE' in any project and use @nexus-methodologist to start."
    echo "To install resources and skills into a specific project:"
    echo "  cp -r $RESOURCES_DEST <project-dir>/.${MODE}/resources"
    echo "  cp -r $SKILLS_DEST <project-dir>/.${MODE}/skills"
else
    echo "Next steps:"
    echo "  cd $TARGET_DIR"
    if [[ "$MODE" == "claude" ]]; then
        echo "  claude"
    else
        echo "  opencode"
    fi
    echo ""
    echo "Then: @nexus-methodologist to configure the swarm for your project."
    echo "Output templates are in: $RESOURCES_DEST"
fi
