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
Usage: install-nexus.sh --claude [--personal | <project-dir>]

Install Nexus SDLC agents as Claude Code subagents.

Options:
  --claude --personal      Install agents globally to ~/.claude/agents/
                           (available in every Claude Code session)
  --claude <project-dir>   Install agents into <project-dir>/.claude/agents/
                           (available only when running claude inside that project)

Examples:
  ./install-nexus.sh --claude ~/my-project
  ./install-nexus.sh --claude --personal
  ./install-nexus.sh --claude .

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
claude_meta() {
    case "$1" in
        analyst.md)
            echo 'nexus-analyst|Nexus SDLC — Analyst: Turns project goals and context into a structured, numbered requirements list. Invoke at the start of ingestion phase or when incorporating Nexus feedback after an Auditor review.|opus|blue'
            ;;
        architect.md)
            echo 'nexus-architect|Nexus SDLC — Architect: Defines system structure, produces ADRs and fitness functions. Invoke after the Requirements Gate is approved, before the Plan Gate. Also consult during execution when tasks surface architectural decisions.|opus|purple'
            ;;
        auditor.md)
            echo 'nexus-auditor|Nexus SDLC — Auditor: Reviews the Analyst Requirements List for completeness, consistency, and traceability. Invoke after every Analyst output. Also runs regression checks when new requirements arrive after a demo.|opus|red'
            ;;
        builder.md)
            echo 'nexus-builder|Nexus SDLC — Builder: Implements a single atomic task from the Task Plan. Invoke with one task at a time. Does not plan, architect, or verify — pure implementation.|sonnet|green'
            ;;
        methodologist.md)
            echo 'nexus-methodologist|Nexus SDLC — Methodologist: Configures the swarm for a project — selects the profile (Casual/Commercial/Critical/Vital) and produces the Methodology Manifest. Invoke first on any new project, and again at major phase transitions or when the process feels broken.|opus|yellow'
            ;;
        orchestrator.md)
            echo 'nexus-orchestrator|Nexus SDLC — Orchestrator: Operational control plane. Knows current project state, determines which agent to invoke next, manages the iterate loop, and escalates to the Nexus. Invoke when you want the swarm to determine what happens next.|opus|orange'
            ;;
        planner.md)
            echo 'nexus-planner|Nexus SDLC — Planner: Turns approved Requirements List and Architect output into an ordered Task Plan. Invoke after the Requirements Gate. Also handles plan revisions after demo feedback, spike findings, or Nexus-invoked release map reviews.|opus|blue'
            ;;
        designer.md)
            echo 'nexus-designer|Nexus SDLC — Designer: Translates approved requirements into UX flows, interaction specifications, and component structures that Builder can implement. Invoked when the delivery channel requires a visual interface. At Casual, Builder handles UI directly via the graphic-design skill.|opus|pink'
            ;;
        devops.md)
            echo 'nexus-devops|Nexus SDLC — DevOps: Builds and maintains the delivery infrastructure — CI/CD pipelines, environments, configuration management, and production monitoring. Not invoked at Casual. At Commercial and above, invoke to set up the pipeline before Builder begins, provision environments in parallel with Builder tasks, and prepare production before the Go-Live gate.|sonnet|gray'
            ;;
        verifier.md)
            echo 'nexus-verifier|Nexus SDLC — Verifier: Verifies a Builder implementation against task acceptance criteria and the requirement Definition of Done. Invoke after each Builder output. Writes and runs tests, produces a structured verification report.|sonnet|cyan'
            ;;
        sentinel.md)
            echo 'nexus-sentinel|Nexus SDLC — Sentinel: Security and dependency protection. Evaluates new dependencies before adoption (license, CVEs, maintenance, transitive risk) and runs live security testing against staging before each release. Not invoked at Casual.|opus|red'
            ;;
        scaffolder.md)
            echo 'nexus-scaffolder|Nexus SDLC — Scaffolder: Translates architectural decisions into code structure — files, signatures, interfaces, and contracts — that Builder implements against. Invoke after Architecture Gate, before Builder begins. Does not implement logic.|sonnet|purple'
            ;;
        scribe.md)
            echo 'nexus-scribe|Nexus SDLC — Scribe: Release documentation publisher. Invoked at release time — extracts and transforms living documentation (code annotations, UX flows, Demo Scripts) into versioned release artifacts: reference docs, Swagger specs, user manuals, release notes, and changelog. Not invoked at Casual.|sonnet|yellow'
            ;;
        *)
            echo ''
            ;;
    esac
}

install_claude() {
    local src_file="$1"
    local dest_dir="$2"
    local filename
    filename="$(basename "$src_file")"

    local meta
    meta="$(claude_meta "$filename")"

    if [[ -z "$meta" ]]; then
        echo "  ! $filename (no Claude metadata — skipping)"
        return
    fi

    local name description model color
    name="${meta%%|*}";          meta="${meta#*|}"
    description="${meta%%|*}";   meta="${meta#*|}"
    model="${meta%%|*}";         color="${meta#*|}"

    {
        printf -- '---\n'
        printf 'name: %s\n' "$name"
        printf 'description: "%s"\n' "$description"
        printf 'model: %s\n' "$model"
        printf 'color: %s\n' "$color"
        printf 'author: Pablo Ochendrowitsch\n'
        printf 'license: Apache-2.0\n'
        printf -- '---\n\n'
        awk '/^<!--/{skip=1} skip{if(/-->/)skip=0; next} 1' "$src_file"
    } > "$dest_dir/$filename"

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

[[ -n "$MODE" ]] || die "specify a mode: --claude"

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
fi

# ── Install ───────────────────────────────────────────────────────────────────

echo "Installing Nexus SDLC agents to: $DEST_DIR"
mkdir -p "$DEST_DIR"

INSTALLED=0
for agent_file in "$AGENTS_SRC"/*.md; do
    install_claude "$agent_file" "$DEST_DIR"
    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Installed $INSTALLED agents."

echo ""
echo "Installing output templates to: $RESOURCES_DEST"
cp -r "$RESOURCES_SRC/." "$RESOURCES_DEST/"
echo "  ✓ resources/ → $RESOURCES_DEST (.claude/resources/)"

echo ""
echo "Installing skills to: $SKILLS_DEST"
mkdir -p "$SKILLS_DEST"
cp -r "$SKILLS_SRC/." "$SKILLS_DEST/"
echo "  ✓ skills/ → $SKILLS_DEST (.claude/skills/)"

# ── Post-install hints ────────────────────────────────────────────────────────

if [[ "$MODE" == "claude" ]]; then
    echo ""
    if $PERSONAL; then
        echo "Agents are now available globally in all Claude Code sessions."
        echo "Output templates installed to: $RESOURCES_DEST"
        echo "Skills installed to: $SKILLS_DEST"
        echo ""
        echo "Run 'claude' in any project and use @nexus-methodologist to start."
        echo "To install resources and skills into a specific project:"
        echo "  cp -r $RESOURCES_DEST <project-dir>/.claude/resources"
        echo "  cp -r $SKILLS_DEST <project-dir>/.claude/skills"
    else
        echo "Next steps:"
        echo "  cd $TARGET_DIR"
        echo "  claude"
        echo ""
        echo "Then: @nexus-methodologist to configure the swarm for your project."
        echo "Output templates are in: $RESOURCES_DEST"
    fi
fi
