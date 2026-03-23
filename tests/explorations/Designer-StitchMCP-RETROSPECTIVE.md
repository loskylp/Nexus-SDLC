<!--
Author: Pablo Ochendrowitsch
Session recorded: 2026-03-23
Test vehicle: Standalone capability exploration — Designer agent with Stitch MCP
Purpose: First live test of the Designer capability and Stitch MCP integration
-->

# Designer + Stitch MCP — Capability Exploration Retrospective

Combined critique from two perspectives: the **Nexus Methodologist** (swarm-side analysis) and the **Nexus** (human-side observations). Both sets were produced after the full design session completed.

Points marked **[M]** originate from the Methodologist. Points marked **[N]** originate from the Nexus. Points marked **[M+N]** were raised by both independently.

---

## 1. Tool Availability — Deferred MCP Tools

**[M]** Stitch MCP tools are deferred — they do not appear in the active tool list until `ToolSearch` is called explicitly. The Designer has no way to know which tools are available without first probing. This created a workflow where the first three tool calls in the session were discovery calls (`ToolSearch`, `ToolSearch`, `ToolSearch`) before any design work could begin.

**[M]** The framework has no instruction for deferred tool resolution. The Designer's routing slip should include an explicit first step: resolve all required tools via `ToolSearch` before proceeding. The graphic-design skill should list the exact tool names to resolve so the Designer does not need to discover them.

---

## 2. Async Behaviour — generate_screen_from_text

**[M+N]** `generate_screen_from_text` completes with no output and no screen ID. The screen is generated in the background and appears in `list_screens` after an indeterminate delay. This behaviour was not understood at the start of the session, which led to:

- **Retries on silence** — when a call returned nothing, the same prompt was re-submitted, producing duplicate screens
- **False negatives** — `list_screens` called immediately after generation showed nothing, creating the impression of failure
- **8 screens instead of 4** — by the end of the session the project contained duplicate screens for Sign Up (×3), Main Workspace (×2), and Version History (×2), all created by retry calls

**[N]** The correct behaviour is: call `generate_screen_from_text` once, proceed with other work, then call `list_screens` after a short wait. Do not retry on silence. This is now documented in the skill but was learned the hard way.

**[M]** `generate_variants` behaves the opposite way — it returns synchronously with full screen data including IDs, screenshot URLs, and the sub-prompt used for each variant. The framework must document this asymmetry explicitly. A Designer treating both tools as async will wait unnecessarily; a Designer treating both as sync will miss screen data from `generate_screen_from_text`.

---

## 3. edit_screens — Creates New Screens, Not Mutations

**[M+N]** `edit_screens` does not modify the selected screen in place. It creates a new screen version and leaves the original intact. This was consistently unexpected:

- After editing the workspace screen, the project had a new screen with a different title and ID — the original was unchanged
- Three edit iterations on the workspace produced three additional screens
- At no point was the original workspace screen modified

**[N]** The practical consequence is that the Designer must track which screen is the current canonical version by title or by the most recent entry in `list_screens`. The original screen IDs are not reused. This is now documented in the skill but must be a first-principle understanding, not a learned surprise.

**[M]** The framework's proposal document format must specify that the canonical screen ID is updated after each edit iteration. A proposal document referencing a superseded screen ID is a traceability failure.

---

## 4. Prompt Quality — Specificity is the Design Constraint

**[N]** The largest source of iteration cost in the session was prompt underspecification. Three distinct failure modes appeared:

**Failure A — Missing feature not stated negatively.** The workspace screen was specified with a 3-panel layout but the center panel was never described as a raw text editor — it was described as showing "a Markdown document." Stitch rendered it as a preview. The correct prompt would have stated explicitly: *"raw Markdown source visible as typed characters — NOT a rendered preview."*

**Failure B — Removal without prohibition.** The request to remove the right metadata panel produced a screen where the panel was replaced with something else. The effective fix required adding: *"Do not replace it with anything."* Omitting this explicit prohibition invites Stitch to fill the space.

**Failure C — Conflicting requirements resolved silently.** The user then observed that the workspace showed raw Markdown but no rendered preview — two valid but contradictory readings of "editor." The correct initial prompt would have specified a split-pane: left raw source, right live rendered preview. The resolution took two additional iterations.

**[M]** The graphic-design skill's prompting strategy section should add a fourth failure mode to the common patterns table: feature omission by absence of negative specification.

---

## 5. Project Type — create_project Limitation

**[M]** `create_project` always creates a `PROJECT_DESIGN` project. The Stitch UI creates `TEXT_TO_UI_PRO` projects. Generation works in `PROJECT_DESIGN` but screens were slower to land. The framework has no tool to create a `TEXT_TO_UI_PRO` project via MCP.

**[N]** The practical workaround is to generate into an existing `TEXT_TO_UI_PRO` project retrieved via `list_projects` when one is available. When no suitable project exists, `create_project` is the only option and the Designer must account for slower or more delayed screen arrival.

**[M]** The graphic-design skill documents this limitation. The Designer's routing slip template should include a step: check `list_projects` for a suitable existing project before creating a new one.

---

## 6. Stitch Docs — Client-Side Rendering Blocks WebFetch

**[M]** The Stitch documentation at `stitch.withgoogle.com/docs/` is client-side rendered. `WebFetch` returns only the minified JavaScript shell — no readable content. Reading the documentation required Playwright to render the pages.

**[N]** This was not anticipated. Two `WebFetch` calls were made to documentation URLs before the pattern was recognised and Playwright was used instead. The skill and any Designer routing slip should specify: Stitch documentation must be read via Playwright, not WebFetch.

**[M]** More broadly: the framework has no rule distinguishing document types that require Playwright from those that do not. A lightweight heuristic: if the URL is a known SPA (single-page application) framework — React, Angular, Vue-rendered — use Playwright. If it returns raw HTML, use WebFetch. This heuristic should be added to the `demo-script-execution.md` skill or as a new `web-reading.md` skill.

---

## 7. Download URLs — Public but Time-Limited

**[M+N]** Both `htmlCode.downloadUrl` and `screenshot.downloadUrl` returned by Stitch MCP tools are publicly accessible without authentication — plain `curl` works. This was verified during the session for both URL types.

**[N]** However, these are signed URLs. They are not permanent. The graphic-design skill documents this: download at finalization time, not before. A URL referenced in a document 24 hours after generation may return 403. The common failure pattern table in the skill includes this case and the fix: call `get_screen` again to get a fresh URL, then download immediately.

**[M]** The Designer's finalization step must download artifacts in the same session as the Nexus approval — not deferred to the next session. The proposal document must contain local file paths, not remote URLs, as the authoritative references.

---

## 8. DESIGN.md — Underused Design System Artifact

**[M]** The `designTheme.designMd` field is present on every `list_projects` response and contains a complete design system: Creative North Star, color tokens with hex values and semantic roles, surface hierarchy rules, typography pairing, component patterns, and explicit do's and don'ts. This was not used during the design session.

**[N]** The DESIGN.md was discovered during documentation writing, not during design. Had it been extracted and reviewed at the start of the session, the prompt quality issues in section 4 would have been reduced — the exact hex values, font pairings, and surface hierarchy were already codified in the project's designMd.

**[M]** Required rule: at the start of any design session on an existing project, the Designer must extract `designTheme.designMd` from `list_projects` and read it before writing any generation prompts. It is the design vocabulary of the project. Generating screens without reading it is designing without a brief.

---

## 9. Nexus Review — Browser Navigation Responsibility

**[N]** During the session, the Nexus navigated to Stitch manually to inspect the generated screens. The correct workflow — which was codified in the skill during this session but not practiced during it — is for the Designer to open the Stitch project in the browser via Playwright, presenting it directly to the Nexus.

**[M]** The Nexus checkpoint is non-negotiable but its mechanism matters. "Nexus navigates to Stitch" places the burden on the Nexus to find the right project and the right screens. "Designer opens Stitch via Playwright" places the burden on the Designer, where it belongs. The proposal document exists precisely to define what the Nexus should be looking at — it should be presented, not described.

---

## 10. generate_variants — Synchronous and Self-Directing

**[M+N]** `generate_variants` behaves significantly differently from the other generation tools. It is synchronous, returns full screen data in one call, and autonomously chooses a distinct creative direction for each variant. In the test session with `EXPLORE` range and `["LAYOUT", "COLOR_SCHEME"]` aspects, the model produced three internally named directions: Developer Workspace, Editorial Deep Dive, and Brutalist Efficiency — none of which were specified in the prompt.

**[N]** Each variant includes a `prompt` field showing the sub-instruction used for that variant. This is the most useful data in the response — it makes the model's directional decision transparent and gives the Designer a precise starting point for any follow-up editing. The skill documents this. The Designer must read the variant `prompt` fields, not just the screenshots.

**[M]** `generate_variants` is the correct tool for exploration at the start of a design engagement — before committing to a direction. The current skill positions it correctly as "exploration and pivoting" rather than incremental editing. The Designer's workflow should use variants early, then refine with `edit_screens`.

---

## Summary of Required Framework Changes

All 11 findings from this exploration have been incorporated into [`skills/graphic-design.md`](../../skills/graphic-design.md) and [`agents/designer.md`](../../agents/designer.md).

| # | Area | Change required | Owner | Status |
|---|------|-----------------|-------|--------|
| 1 | Designer routing slip | First step must be: resolve all Stitch MCP tools via `ToolSearch` before any design work | Orchestrator | Applied |
| 2 | Async generation | Do not retry `generate_screen_from_text` on silence; wait and call `list_screens` | Designer | Applied |
| 3 | edit_screens behaviour | Designer must track canonical screen ID after each edit; proposal doc updated after each iteration | Designer | Applied |
| 4 | Prompt strategy | Add explicit negative specification as a fourth failure mode | graphic-design skill | Applied |
| 5 | Project type | Check `list_projects` for existing TEXT_TO_UI_PRO project before creating new | Orchestrator | Applied |
| 6 | Stitch docs | Stitch documentation must be read via Playwright, not WebFetch | graphic-design skill | Applied |
| 7 | Download URLs | Download artifacts in the same session as Nexus approval; proposal doc references local paths | Designer | Applied |
| 8 | DESIGN.md usage | Extract and read `designTheme.designMd` before writing any generation prompts | Designer | Applied |
| 9 | Nexus review mechanism | Designer opens Stitch in Playwright for Nexus inspection | Designer | Applied |
| 10 | generate_variants workflow | Use variants early; read `prompt` field per variant | Designer | Applied |
| 11 | SPA reading heuristic | Add rule for Playwright vs WebFetch by URL type | web-reading skill | Pending |
